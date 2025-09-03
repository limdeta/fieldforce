import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../entities/compact_track.dart';
import '../entities/compact_track_builder.dart';

/// Буфер GPS точек для оптимизации real-time трекинга
/// 
/// Решает проблемы:
/// - Частые записи в БД при каждой GPS точке
/// - Лишние перестроения UI
/// - GPS шум и избыточные данные
/// - Правильная сегментация треков
class GpsBuffer {
  final CompactTrackBuilder _builder = CompactTrackBuilder();
  final StreamController<CompactTrack> _updateController = StreamController<CompactTrack>.broadcast();
  
  Timer? _flushTimer;
  DateTime? _lastFlushTime;
  
  // Настройки буферизации
  static const int _maxBufferSize = 20; // Максимум точек в буфере
  static const Duration _maxBufferTime = Duration(seconds: 30); // Максимальное время буферизации
  static const double _minDistanceMeters = 3.0; // Минимальное расстояние между точками
  
  Position? _lastPosition;
  
  /// Стрим обновлений буфера для UI
  Stream<CompactTrack> get updateStream => _updateController.stream;
  
  /// Текущее количество точек в буфере
  int get pointCount => _builder.pointCount;
  
  /// Есть ли данные в буфере
  bool get hasData => _builder.pointCount > 0;
  
  /// Добавляет GPS точку в буфер
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
    
    // Уведомляем UI об обновлении
    _notifyUpdate();
    
    // Проверяем необходимость флаша
    _checkFlushConditions();
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
  
  /// Очищает буфер
  void clear() {
    _builder.clear();
    _lastPosition = null;
    _cancelFlushTimer();
  }
  
  /// Освобождает ресурсы
  void dispose() {
    _cancelFlushTimer();
    _updateController.close();
  }
  
  // Приватные методы
  
  void _notifyUpdate() {
    if (_builder.pointCount > 0) {
      _updateController.add(_builder.build());
    }
  }
  
  void _checkFlushConditions() {
    // Условие 1: Превышен размер буфера
    if (_builder.pointCount >= _maxBufferSize) {
      _scheduleFlush();
      return;
    }
    
    // Условие 2: Превышено время буферизации
    if (_lastFlushTime != null) {
      final timeSinceFlush = DateTime.now().difference(_lastFlushTime!);
      if (timeSinceFlush >= _maxBufferTime) {
        _scheduleFlush();
        return;
      }
    }
    
    // Планируем флаш через максимальное время
    _scheduleFlushTimer();
  }
  
  void _scheduleFlush() {
    _cancelFlushTimer();
    
    // Небольшая задержка для группировки точек
    _flushTimer = Timer(const Duration(milliseconds: 100), () {
      if (_builder.pointCount > 0) {
        flush(); // Просто флашим буфер, сохранение будет в TrackManager
      }
    });
  }
  
  void _scheduleFlushTimer() {
    _cancelFlushTimer();
    
    _flushTimer = Timer(_maxBufferTime, () {
      if (_builder.pointCount > 0) {
        _scheduleFlush();
      }
    });
  }
  
  void _cancelFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = null;
  }
}
