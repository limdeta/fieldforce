import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track_builder.dart';

class GpsBuffer {
  final CompactTrackBuilder _builder = CompactTrackBuilder();
  final StreamController<CompactTrack> _updateController = StreamController<CompactTrack>.broadcast();
  
  Timer? _flushTimer;
  DateTime? _lastFlushTime;
  
  // Оптимизированные настройки буферизации
  static const int _maxBufferSize = 50; // Увеличено для лучшей производительности
  static const Duration _maxBufferTime = Duration(minutes: 10); // Увеличено
  static const double _minDistanceMeters = 2.0; // Фильтр по расстоянию

  Position? _lastPosition;

  Stream<CompactTrack> get updateStream => _updateController.stream;
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

    _notifyUpdate();
  }
  
  /// Принудительно сбрасывает буфер и возвращает сегмент
  CompactTrack flush() {
    _cancelFlushTimer();
    
    final segment = _builder.build();
    _builder.clear();
    _lastFlushTime = DateTime.now();
    
    return segment;
  }
  
  /// Получает текущий сегмент без очистки буфера (для UI)
  CompactTrack getCurrentSegment() {
    return _builder.build();
  }

  void clear() {
    _builder.clear();
    _lastPosition = null;
    _cancelFlushTimer();
  }

  void dispose() {
    _cancelFlushTimer();
    _updateController.close();
  }

  void _notifyUpdate() {
    if (_builder.pointCount > 0) {
      _updateController.add(_builder.build());
    }
  }
  
  /// Проверяет, готов ли буфер к сбросу
  bool _shouldFlush() {
    if (_builder.pointCount == 0) return false;
    
    // Условие 1: Превышен размер буфера
    if (_builder.pointCount >= _maxBufferSize) {
      return true;
    }
    
    // Условие 2: Превышено время буферизации
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
