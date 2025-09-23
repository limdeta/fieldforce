import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track_builder.dart';
import 'package:logging/logging.dart';

class GpsBuffer {
  static final Logger _logger = Logger('GpsBuffer');
  final CompactTrackBuilder _builder = CompactTrackBuilder();
  final StreamController<CompactTrack> _updateController = StreamController<CompactTrack>.broadcast();
  final StreamController<CompactTrack> _autoFlushController = StreamController<CompactTrack>.broadcast();
  
  Timer? _flushTimer;
  DateTime? _lastFlushTime;
  
  // Кольцевой буфер настройки
  static const int _maxBufferSize = 10; // Размер буфера для сброса (уменьшен для более частого создания сегментов)
  static const int _overlapSize = 3; // Количество точек для перекрытия (обеспечивает непрерывность)
  static const Duration _maxBufferTime = Duration(minutes: 1); // Уменьшен для более частого сброса по времени
  static const double _minDistanceMeters = 2.0;

  Position? _lastPosition;

  Stream<CompactTrack> get updateStream => _updateController.stream;
  Stream<CompactTrack> get autoFlushes => _autoFlushController.stream;
  int get pointCount => _builder.pointCount;
  bool get hasData => _builder.pointCount > 0;
  bool get isReadyToFlush => _shouldFlush();

  void addPoint(Position position) {
    // Фильтруем точки по расстоянию
    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      
      if (distance < _minDistanceMeters) {
        _logger.fine('🚫 GpsBuffer: точка отфильтрована по расстоянию: ${distance.toStringAsFixed(1)}m < $_minDistanceMeters');
        return; // Слишком близко к предыдущей точке
      }
    }
    
    // Добавляем точку в буфер
    _builder.addPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
      accuracy: position.accuracy,
      speedKmh: position.speed * 3.6, // м/с -> км/ч
      bearing: position.heading >= 0 ? position.heading : null,
    );
    
    _lastPosition = position;
    _logger.fine('✅ GpsBuffer: точка добавлена! Всего точек: ${_builder.pointCount}');

    // КОЛЬЦЕВОЙ БУФЕР: автоматический сброс при переполнении
    if (_shouldAutoFlush()) {
      _logger.info('🔄 GpsBuffer: автосброс буфера при достижении ${_builder.pointCount} точек');
      _autoFlush();
    }

    _notifyUpdate();
  }
  
  /// Принудительно сбрасывает буфер и возвращает сегмент (для ручного вызова из TrackManager)
  CompactTrack flush() {
    _cancelFlushTimer();
    // Используем тот же алгоритм кольцевого буфера для согласованности
    return _autoFlush();
  }
  
  /// Получает текущий сегмент без очистки буфера (для UI)
  CompactTrack getCurrentSegment() {
    return _builder.build();
  }

  /// Возвращает полный текущий сегмент (включая все точки) и очищает буфер.
  /// Используется для ручного принудительного сохранения (pause/stop/flush).
  CompactTrack drain() {
    _cancelFlushTimer();
    final seg = _builder.build();
    _builder.clear();
    _lastPosition = null;
    return seg;
  }

  void clear() {
    _builder.clear();
    _lastPosition = null;
    _cancelFlushTimer();
  }

  void dispose() {
    _cancelFlushTimer();
    _updateController.close();
    _autoFlushController.close();
  }

  void _notifyUpdate() {
    if (_builder.pointCount > 0) {
      _updateController.add(_builder.build());
    }
  }
  
  /// Проверяет, нужен ли автосброс (кольцевой буфер)
  bool _shouldAutoFlush() {
    return _builder.pointCount >= _maxBufferSize;
  }
  
  /// Автоматический сброс с сохранением перекрытия (кольцевой буфер)
  CompactTrack _autoFlush() {
    if (_builder.pointCount == 0) return _builder.build();

    // Сначала строим полный трек, чтобы получить доступ к данным
    final fullTrack = _builder.build();

    // Сохраняем последние _overlapSize точек для непрерывности
    final overlapPoints = <Position>[];
    final pointsToKeep = math.min(_overlapSize, fullTrack.pointCount);

    for (int i = fullTrack.pointCount - pointsToKeep; i < fullTrack.pointCount; i++) {
      final (lat, lng) = fullTrack.getCoordinates(i);
      final timestamp = fullTrack.getTimestamp(i);
      final accuracy = fullTrack.getAccuracy(i) ?? 5.0;
      final speed = fullTrack.getSpeed(i) ?? 0.0;
      final bearing = fullTrack.getBearing(i);

      overlapPoints.add(Position(
        latitude: lat,
        longitude: lng,
        timestamp: timestamp,
        accuracy: accuracy,
        altitude: 0.0,
        altitudeAccuracy: 10.0,
        heading: bearing ?? 0.0,
        headingAccuracy: 15.0,
        speed: speed / 3.6, // км/ч -> м/с
        speedAccuracy: 2.0,
      ));
    }

    // КРИТИЧНО: Создаем сегмент ТОЛЬКО из точек до перекрытия!
    // Исключаем последние overlapSize точек, чтобы избежать дублирования
    final segmentPointCount = fullTrack.pointCount - pointsToKeep;
    final segment = segmentPointCount > 0
        ? fullTrack.subtrack(0, segmentPointCount)
        : CompactTrack.empty(); // Пустой сегмент если точек меньше чем overlapSize

    // Очищаем буфер и восстанавливаем ТОЛЬКО перекрывающиеся точки
    _builder.clear();
    for (final position in overlapPoints) {
      _builder.addPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: position.timestamp,
        accuracy: position.accuracy,
        speedKmh: position.speed * 3.6,
        bearing: position.heading >= 0 ? position.heading : null,
      );
    }

    if (overlapPoints.isNotEmpty) {
      _lastPosition = overlapPoints.last;
      _logger.fine('🔄 GpsBuffer._autoFlush(): сегмент ${segment.pointCount} точек + ${overlapPoints.length} точек перекрытия сохранено');
    }

    _lastFlushTime = DateTime.now();

    // КРИТИЧНО: уведомляем TrackManager об автосбросе
    _logger.fine('📤 GpsBuffer._autoFlush(): отправляем сегмент ${segment.pointCount} точек в TrackManager');
    _autoFlushController.add(segment);

    return segment;
  }
  
  /// Проверяет, готов ли буфер к ручному сбросу
  bool _shouldFlush() {
    if (_builder.pointCount == 0) return false;
    
    // Условие: Превышено время буферизации  
    if (_lastFlushTime != null) {
      final timeSinceFlush = DateTime.now().difference(_lastFlushTime!);
      if (timeSinceFlush >= _maxBufferTime) {
        return true;
      }
    }
    
    return false;
  }
  
  void _cancelFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = null;
  }
}
