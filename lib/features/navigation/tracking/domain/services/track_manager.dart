import 'dart:async';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/enums/track_status.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_buffer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/app/config/app_config.dart';

/// Менеджер GPS треков
/// 
/// Принципы:
/// - Буферизация GPS точек в памяти
/// - Периодическое сохранение в БД
/// - Разделение UI и persistence слоёв
/// - Оптимизация для real-time обновлений
/// - Один активный трек на день для пользователя
class TrackManager {
  static final Logger _logger = Logger('TrackManager');
  
  final UserTrackRepository _repository;
  final GpsBuffer _buffer = GpsBuffer();
  
  UserTrack? _currentTrack;
  StreamSubscription? _autoFlushSubscription;
  Timer? _persistTimer;
  int _updateCounter = 0; // Счетчик отправленных обновлений

  final StreamController<UserTrack> _trackUpdateController = StreamController<UserTrack>.broadcast();
  
  TrackManager(this._repository) {
    // КРИТИЧНО: подписываемся на автосбросы буфера
    _logger.info('🔌 TrackManager: подписываемся на autoFlushes');
    _autoFlushSubscription = _buffer.autoFlushes.listen((segment) {
      _logger.info('🎯 TrackManager: ПОЛУЧИЛИ autoFlush с ${segment.pointCount} точками');
      _onAutoFlush(segment);
    });
  }

  /// Стрим обновлений трека для UI (только при сохранении сегментов)
  Stream<UserTrack> get trackUpdateStream => _trackUpdateController.stream;
  
  /// Стрим live обновлений буфера для UI (каждую новую точку)
  Stream<CompactTrack> get liveBufferStream => _buffer.updateStream;
  
  UserTrack? get currentTrackForUI {
    if (_currentTrack == null) return null;
    
    // Возвращаем трек только с сохраненными сегментами
    // Live buffer передается отдельно через liveBufferStream
    return _currentTrack!;
  }

  /// Единый метод запуска трекинга - автоматически определяет нужно ли создавать новый трек или продолжать существующий
  Future<bool> startTracking({
    required NavigationUser user,
  }) async {
    _logger.info('🚀 TrackManager.startTracking для пользователя: ${user.fullName} (ID: ${user.id})');
    
    if (_currentTrack != null) {
      _logger.info('🛑 Останавливаем предыдущий трек...');
      await stopTracking();
    }

    // Ищем трек за сегодня
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    _logger.info('🔍 Ищем существующие треки за период: $startOfDay - $endOfDay');
    final tracksResult = await _repository.getUserTracksByDateRange(
      user, startOfDay, endOfDay
    );

    UserTrack? existingTrack;
    if (tracksResult.isRight()) {
      final tracks = tracksResult.getOrElse(() => []);
      _logger.info('📊 Найдено треков за день: ${tracks.length}');
      // В dev режиме не продолжаем существующие треки, чтобы избежать наложения
      if (!AppConfig.isDev) {
        // Ищем активный или трек на паузе
        existingTrack = tracks.where((track) =>
          track.status == TrackStatus.active || track.status == TrackStatus.paused
        ).firstOrNull;
      }
    } else {
      _logger.warning('❌ Ошибка получения треков: ${tracksResult.fold((l) => l.toString(), (r) => '')}');
    }

    if (existingTrack != null) {
      _logger.info('🔄 TrackManager: Найден существующий трек (ID: ${existingTrack.id}), продолжаем его');
      _currentTrack = existingTrack.copyWith(
        status: TrackStatus.active,
        endTime: null,
      );
    } else {
      _logger.info('🆕 TrackManager: Создаем новый трек для нового дня');
      _currentTrack = UserTrack.empty(
        id: DateTime.now().millisecondsSinceEpoch,
        user: user,
        status: TrackStatus.active,
        metadata: {
          'created_at': DateTime.now().toIso8601String(),
        },
      );
    }

    _logger.info('✅ Трек готов: ID=${_currentTrack!.id}, Status=${_currentTrack!.status}');
    _buffer.clear();
    
    return true;
  }

  Future<void> stopTracking() async {
    if (_currentTrack == null) return;
    
    // Сохраняем финальный сегмент из буфера если есть данные
    if (_buffer.hasData) {
      final finalSegment = _buffer.flush();
      if (finalSegment.pointCount > 0) {
        _currentTrack!.segments.add(finalSegment);
        await _repository.saveOrUpdateUserTrack(_currentTrack!);
      }
    }
    
    _currentTrack = _currentTrack!.copyWith(
      status: TrackStatus.completed,
      endTime: DateTime.now(),
    );
    
    await _repository.saveOrUpdateUserTrack(_currentTrack!);

    _currentTrack = null;
    _buffer.clear();
  }
  
  Future<void> pauseTracking() async {
    if (_currentTrack == null) return;
    
    // Сохраняем текущий буфер как сегмент
    if (_buffer.hasData) {
      final segment = _buffer.flush();
      if (segment.pointCount > 0) {
        _currentTrack!.segments.add(segment);
        await _repository.saveOrUpdateUserTrack(_currentTrack!);
      }
    }
    
    _currentTrack = _currentTrack!.copyWith(
      status: TrackStatus.paused,
    );
    
    await _repository.saveOrUpdateUserTrack(_currentTrack!);
  }
  
  Future<void> resumeTracking() async {
    if (_currentTrack == null) return;
    
    _currentTrack = _currentTrack!.copyWith(
      status: TrackStatus.active,
    );
    
    _buffer.clear();
  }
  
  void addGpsPoint(Position position) {
    _logger.info('📍 TrackManager.addGpsPoint: ${position.latitude}, ${position.longitude}');
    
    if (_currentTrack == null) {
      _logger.warning('❌ _currentTrack == null, не можем добавить точку');
      return;
    }
    
    if (_currentTrack!.status != TrackStatus.active) {
      _logger.warning('❌ Трек не активен (status: ${_currentTrack!.status}), не можем добавить точку');
      return;
    }
    
    _buffer.addPoint(position);
    _logger.info('✅ Точка добавлена в GPS буфер. Всего точек в буфере: ${_buffer.pointCount}');
  }
  
  void dispose() {
    _autoFlushSubscription?.cancel();
    _persistTimer?.cancel();
    _buffer.dispose();
    _trackUpdateController.close();
  }
  
  /// обрабатывает автоматически сброшенные сегменты из кольцевого буфера
  Future<void> _onAutoFlush(CompactTrack segment) async {
    _logger.info('🚨 TrackManager._onAutoFlush: ВЫЗВАН с сегментом ${segment.pointCount} точек');

    if (_currentTrack == null) {
      _logger.warning('⚠️ TrackManager._onAutoFlush: нет активного трека для сохранения автосброса');
      return;
    }

    if (segment.pointCount == 0) {
      _logger.info('⚠️ TrackManager._onAutoFlush: пустой сегмент, пропускаем');
      return;
    }

    _logger.info('📥 TrackManager._onAutoFlush: currentTrack=${_currentTrack!.id}, сегментов до: ${_currentTrack!.segments.length}');

    try {
      _currentTrack!.segments.add(segment);

      // сохраняем в БД, чтобы не потерять данные
      final result = await _repository.saveOrUpdateUserTrack(_currentTrack!);
      if (result.isRight()) {
        _logger.info('💾 TrackManager._onAutoFlush: автосегмент сохранен в БД! Сегментов стало: ${_currentTrack!.segments.length}');
      } else {
        _logger.severe('❌ TrackManager._onAutoFlush: ошибка сохранения в БД: ${result.fold((l) => l.toString(), (r) => '')}');
      }

      // Уведомляем UI об обновлении трека
      _updateCounter++;
      _logger.info('📢 TrackManager._onAutoFlush: ОТПРАВЛЯЕМ обновление #$_updateCounter в trackUpdateStream');
      _logger.info('   📊 Трек для отправки: ID=${_currentTrack!.id}, сегментов=${_currentTrack!.segments.length}, точек=${_currentTrack!.totalPoints}');
      for (int i = 0; i < _currentTrack!.segments.length; i++) {
        _logger.info('      segment[$i]: ${_currentTrack!.segments[i].pointCount} точек');
      }
      _trackUpdateController.add(_currentTrack!);
      _logger.info('✅ TrackManager._onAutoFlush: трек #$_updateCounter отправлен в UI');
    } catch (e, st) {
      _logger.severe('❌ TrackManager._onAutoFlush: критичная ошибка', e, st);
    }
  }
}
