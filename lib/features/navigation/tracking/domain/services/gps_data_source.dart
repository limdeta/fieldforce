import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';

/// Абстракция источника GPS данных
///
/// Позволяет переключаться между реальным GPS (geolocator) и мок-данными
/// для тестирования трекинга в контролируемой среде
abstract class GpsDataSource {
  /// Стрим позиций GPS
  Stream<Position> getPositionStream({required LocationSettings settings});
  Future<bool> checkPermissions();
  Future<Position> getCurrentPosition({required LocationSettings settings});
  Future<void> dispose();
}

/// Реальный источник GPS данных через geolocator с буферизацией
///
/// - Контролируемые интервалы эмиссии через Timer
/// - Буферизация позиций для предотвращения пропусков
/// - Подробное логирование для отладки
class RealGpsDataSource implements GpsDataSource {
  static final Logger _logger = Logger('RealGpsDataSource');
  static const String _tag = 'RealGPS';

  // Буферизация и контролируемая эмиссия
  StreamController<Position>? _positionController;
  StreamSubscription<Position>? _geolocatorSubscription;
  Timer? _emissionTimer;
  Position? _lastBufferedPosition;
  bool _isActive = false;

  // Конфигурация интервалов (как в Mock GPS)
  static const Duration _emissionInterval = Duration(seconds: 2);
  static const Duration _positionTimeout = Duration(seconds: 10);

  @override
  Stream<Position> getPositionStream({required LocationSettings settings}) {
    _logger.info('📍 $_tag: Запуск буферизованного GPS стрима');

    // Создаем контролируемый стрим
    _positionController = StreamController<Position>.broadcast();
    _isActive = true;

    // Подписываемся на реальный GPS
    _startGeolocatorSubscription(settings);

    // Запускаем контролируемую эмиссию
    _startEmissionTimer();

    return _positionController!.stream;
  }

  void _startGeolocatorSubscription(LocationSettings settings) {
    _logger.info('📡 $_tag: Подписка на Geolocator стрим');

    _geolocatorSubscription =
        Geolocator.getPositionStream(locationSettings: settings).listen(
          (position) {
            if (_isActive) {
              _logger.info(
                '📍 $_tag: Получена GPS позиция от системы: ${position.latitude}, ${position.longitude} (accuracy: ${position.accuracy}m)',
              );
              _lastBufferedPosition = position;

              // Forward immediately to the controller to avoid losing updates
              // if the emission timer is paused by the platform when app is backgrounded.
              if (_positionController != null &&
                  !_positionController!.isClosed) {
                try {
                  _positionController!.add(position);
                  _logger.fine(
                    '📤 $_tag: Позиция немедленно отправлена в контроллер',
                  );
                } catch (e, st) {
                  _logger.warning(
                    '⚠️ $_tag: Не удалось немедленно отправить позицию в контроллер',
                    e,
                    st,
                  );
                }
              }
            }
          },
          onError: (error, stackTrace) {
            _logger.severe('❌ $_tag: Ошибка GPS стрима: $error');
            // НЕ передаем ошибку таймаута дальше - это нормальное поведение GPS
            // Поток будет продолжать работать с буферизованными позициями
            if (error is! TimeoutException) {
              if (_positionController != null &&
                  !_positionController!.isClosed) {
                _positionController!.addError(error, stackTrace);
              }
            }
          },
          onDone: () {
            _logger.info('✅ $_tag: GPS стрим завершен');
          },
        );
  }

  void _startEmissionTimer() {
    _logger.info(
      '⏰ $_tag: Запуск таймера контролируемой эмиссии (интервал: $_emissionInterval)',
    );
    Position? _lastEmittedPosition;

    _emissionTimer = Timer.periodic(_emissionInterval, (timer) {
      if (!_isActive ||
          _positionController == null ||
          _positionController!.isClosed) {
        timer.cancel();
        return;
      }

      // Эмитируем ТОЛЬКО если позиция изменилась
      if (_lastBufferedPosition != null) {
        final shouldEmit =
            _lastEmittedPosition == null ||
            _lastEmittedPosition!.latitude != _lastBufferedPosition!.latitude ||
            _lastEmittedPosition!.longitude != _lastBufferedPosition!.longitude;

        if (shouldEmit) {
          try {
            _positionController!.add(_lastBufferedPosition!);
            _lastEmittedPosition = _lastBufferedPosition;
            _logger.info(
              '📤 $_tag: Эмитирована НОВАЯ позиция: ${_lastBufferedPosition!.latitude}, ${_lastBufferedPosition!.longitude} - отправляем в LocationTrackingService',
            );
          } catch (e, st) {
            _logger.severe('❌ $_tag: Ошибка при эмиссии позиции', e, st);
          }
        } else {
          _logger.fine('⏳ $_tag: Позиция не изменилась, пропускаем эмиссию');
        }
      } else {
        _logger.fine('⏳ $_tag: Нет буферизованной позиции для эмиссии');
      }
    });
  }

  @override
  Future<bool> checkPermissions() async {
    try {
      _logger.info('🔐 $_tag: Проверка разрешений GPS');

      LocationPermission permission = await Geolocator.checkPermission()
          .timeout(const Duration(seconds: 5));

      _logger.fine('🔐 $_tag: Текущее разрешение: $permission');

      if (permission == LocationPermission.denied) {
        _logger.info('🔐 $_tag: Запрос разрешения GPS');
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 10),
        );
        _logger.info('🔐 $_tag: Результат запроса: $permission');
      }

      final hasPermission =
          permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;

      _logger.info(
        '🔐 $_tag: Разрешения ${hasPermission ? 'получены' : 'отклонены'}',
      );
      return hasPermission;
    } catch (e, st) {
      _logger.severe('❌ $_tag: Ошибка проверки разрешений', e, st);
      return false;
    }
  }

  @override
  Future<Position> getCurrentPosition({
    required LocationSettings settings,
  }) async {
    try {
      _logger.info('📍 $_tag: Получение текущей позиции');

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: settings.accuracy,
      ).timeout(_positionTimeout);

      _logger.info(
        '✅ $_tag: Получена текущая позиция: ${position.latitude}, ${position.longitude}',
      );
      return position;
    } catch (e, st) {
      _logger.severe('❌ $_tag: Ошибка получения текущей позиции', e, st);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    _logger.info('🧹 $_tag: Освобождение ресурсов');

    _isActive = false;

    _emissionTimer?.cancel();
    _emissionTimer = null;

    await _geolocatorSubscription?.cancel();
    _geolocatorSubscription = null;

    if (_positionController != null && !_positionController!.isClosed) {
      await _positionController!.close();
    }
    _positionController = null;

    _lastBufferedPosition = null;

    _logger.info('✅ $_tag: Ресурсы освобождены');
  }
}
