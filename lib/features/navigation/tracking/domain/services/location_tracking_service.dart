import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import '../entities/compact_track.dart';
import '../entities/compact_track_builder.dart';
import '../entities/user_track.dart';
import '../enums/track_status.dart';

/// Высокопроизводительный сервис GPS трекинга с использованием CompactTrack
/// 
/// Особенности:
/// - Использует typed arrays для минимизации создания объектов
/// - Адаптивная частота обновлений GPS
/// - Фильтрация GPS шума
/// - Автоматическое создание сегментов трека
/// - Буферизация точек для batch обработки
class LocationTrackingService {
  static const String _tag = 'LocationTracking';
  
  UserTrack? _currentTrack;
  CompactTrackBuilder? _currentSegmentBuilder;
  
  StreamSubscription<Position>? _positionSubscription;
  
  final StreamController<UserTrack> _trackUpdateController = 
      StreamController<UserTrack>.broadcast();
  
  final StreamController<Position> _positionController = 
      StreamController<Position>.broadcast();
  
  Position? _lastPosition;
  DateTime? _lastUpdateTime;
  int _stationaryCount = 0;
  bool _isActive = false;
  
  // Настройки трекинга
  final LocationSettings _locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 3, // минимальное расстояние между точками в метрах
  );
  
  // Настройки фильтрации
  static const double _minAccuracy = 20.0; // метры
  static const double _maxSpeed = 150.0; // км/ч - максимальная разумная скорость
  static const int _stationaryThreshold = 5; // количество статичных точек для паузы
  static const double _minDistanceMeters = 5.0; // минимальное расстояние между точками
  static const int _minTimeSeconds = 2; // минимальное время между точками

  LocationTrackingService();

  /// Стримы для подписки на обновления
  Stream<Position> get positionStream => _positionController.stream;
  Stream<UserTrack> get trackUpdateStream => _trackUpdateController.stream;
  
  /// Текущий трек
  UserTrack? get currentTrack => _currentTrack;
  
  /// Статус трекинга
  bool get isTracking => _positionSubscription != null;
  bool get isActive => _isActive;
  bool get isPaused => isTracking && !_isActive;
  
  /// Проверяет разрешения на геолокацию
  Future<bool> checkPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      debugPrint('$_tag: Ошибка проверки разрешений: $e');
      return false;
    }
  }
  
  /// Начинает новый трек
  Future<bool> startTracking({required NavigationUser user, String? routeId}) async {
    try {
      if (isTracking) {
        debugPrint('$_tag: Трекинг уже запущен');
        return false;
      }
      
      final hasPermission = await checkPermissions();
      if (!hasPermission) {
        debugPrint('$_tag: Нет разрешений на геолокацию');
        return false;
      }
      
      // Создаём новый трек
      _currentTrack = UserTrack.empty(
        id: DateTime.now().millisecondsSinceEpoch,
        user: user,
        status: TrackStatus.active,
        metadata: {
          'route_id': routeId,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      
      // Создаём первый сегмент
      _currentSegmentBuilder = CompactTrackBuilder();
      _isActive = true;
      
      _lastPosition = null;
      _lastUpdateTime = null;
      _stationaryCount = 0;
      
      // Запускаем подписку на GPS
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: _locationSettings,
      ).listen(_onPositionUpdate, onError: _onPositionError);
      
      debugPrint('$_tag: Трекинг запущен для пользователя ${user.id}');
      return true;
      
    } catch (e) {
      debugPrint('$_tag: Ошибка запуска трекинга: $e');
      return false;
    }
  }
  
  /// Приостанавливает трекинг
  Future<bool> pauseTracking() async {
    if (!isTracking || !_isActive) {
      return false;
    }
    
    // Финализируем текущий сегмент
    _finalizeCurrentSegment();
    
    _isActive = false;
    
    // Обновляем статус трека
    if (_currentTrack != null) {
      _currentTrack = _currentTrack!.copyWith(
        status: TrackStatus.paused,
      );
    }
    
    debugPrint('$_tag: Трекинг приостановлен');
    _broadcastTrackUpdate();
    return true;
  }
  
  /// Возобновляет трекинг
  Future<bool> resumeTracking() async {
    if (!isTracking || _isActive) {
      return false;
    }
    
    _isActive = true;
    
    // Обновляем статус трека
    if (_currentTrack != null) {
      _currentTrack = _currentTrack!.copyWith(
        status: TrackStatus.active,
      );
    }
    
    // Создаём новый сегмент для продолжения
    _currentSegmentBuilder = CompactTrackBuilder();
    
    debugPrint('$_tag: Трекинг возобновлён');
    _broadcastTrackUpdate();
    return true;
  }
  
  /// Завершает трекинг
  Future<bool> stopTracking() async {
    try {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
      
      if (_currentTrack != null) {
        // Финализируем текущий сегмент
        _finalizeCurrentSegment();
        
        _currentTrack = _currentTrack!.copyWith(
          status: TrackStatus.completed,
          endTime: DateTime.now(),
        );
        
        _broadcastTrackUpdate();
        
        debugPrint('$_tag: Трекинг завершён. Общая дистанция: ${_currentTrack!.totalDistanceKm.toStringAsFixed(2)} км');
      }
      
      _currentTrack = null;
      _currentSegmentBuilder = null;
      _lastPosition = null;
      _lastUpdateTime = null;
      _stationaryCount = 0;
      _isActive = false;
      
      return true;
      
    } catch (e) {
      debugPrint('$_tag: Ошибка остановки трекинга: $e');
      return false;
    }
  }
  
  /// Обработчик новой позиции GPS
  void _onPositionUpdate(Position position) {
    try {
      // Фильтруем некачественные точки
      if (!_isValidPosition(position)) {
        return;
      }
      
      // Проверяем минимальное расстояние и время
      if (!_shouldRecordPosition(position)) {
        return;
      }
      
      // Добавляем точку в текущий сегмент только если трекинг активен
      if (_currentSegmentBuilder != null && _isActive) {
        _currentSegmentBuilder!.addPoint(
          latitude: position.latitude,
          longitude: position.longitude,
          timestamp: position.timestamp,
          accuracy: position.accuracy,
          speedKmh: position.speed * 3.6, // м/с -> км/ч
          bearing: position.heading >= 0 ? position.heading : null,
        );
        
        // Обновляем трек (каждые 10 точек или каждую минуту)
        if (_currentSegmentBuilder!.pointCount % 10 == 0 || 
            _shouldUpdateTrack()) {
          _updateCurrentTrack();
        }
      }
      
      _lastPosition = position;
      _lastUpdateTime = DateTime.now();
      
      // Проверяем стационарность
      _checkStationaryState(position);
      
      // Отправляем позицию в стрим
      _positionController.add(position);
      
    } catch (e) {
      debugPrint('$_tag: Ошибка обработки позиции: $e');
    }
  }
  
  /// Обработчик ошибок GPS
  void _onPositionError(dynamic error) {
    debugPrint('$_tag: Ошибка GPS: $error');
  }
  
  /// Проверяет валидность GPS позиции
  bool _isValidPosition(Position position) {
    // Проверяем точность
    if (position.accuracy > _minAccuracy) {
      return false;
    }
    
    // Проверяем разумность координат
    if (position.latitude.abs() > 90 || position.longitude.abs() > 180) {
      return false;
    }
    
    // Проверяем скорость (если доступна)
    if (position.speed > 0 && position.speed * 3.6 > _maxSpeed) {
      return false;
    }
    
    return true;
  }
  
  /// Проверяет, нужно ли записывать эту позицию
  bool _shouldRecordPosition(Position position) {
    if (_lastPosition == null) return true;
    
    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      position.latitude,
      position.longitude,
    );
    
    final timeDiff = position.timestamp.difference(_lastPosition!.timestamp).inSeconds;
    
    return distance >= _minDistanceMeters || timeDiff >= _minTimeSeconds;
  }
  
  /// Проверяет состояние стационарности
  void _checkStationaryState(Position position) {
    if (_lastPosition == null) return;
    
    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      position.latitude,
      position.longitude,
    );
    
    if (distance < _minDistanceMeters) {
      _stationaryCount++;
    } else {
      _stationaryCount = 0;
    }
    
    // Автоматическая пауза при длительной стационарности
    if (_stationaryCount >= _stationaryThreshold && _isActive) {
      pauseTracking();
    }
  }
  
  /// Проверяет, нужно ли обновить трек
  bool _shouldUpdateTrack() {
    if (_lastUpdateTime == null) return true;
    
    return DateTime.now().difference(_lastUpdateTime!).inMinutes >= 1;
  }
  
  /// Обновляет текущий трек с новыми данными
  void _updateCurrentTrack() {
    if (_currentTrack == null || _currentSegmentBuilder == null) return;
    
    // Создаём временный сегмент для расчёта метрик
    final currentSegment = _currentSegmentBuilder!.build();
    
    // Пересчитываем метрики с учётом нового сегмента
    final allSegments = List<CompactTrack>.from(_currentTrack!.segments);
    
    // Заменяем последний сегмент на обновлённый или добавляем новый
    if (allSegments.isNotEmpty && !_currentTrack!.isCompleted) {
      allSegments.removeLast();
    }
    allSegments.add(currentSegment);
    
    // Пересчитываем метрики
    int totalPoints = 0;
    double totalDistance = 0.0;
    Duration totalDuration = Duration.zero;

    for (final segment in allSegments) {
      totalPoints += segment.pointCount;
      totalDistance += segment.getTotalDistance();
      totalDuration += segment.getDuration();
    }
    
    _currentTrack = _currentTrack!.copyWith(
      segments: allSegments,
      totalPoints: totalPoints,
      totalDistanceKm: totalDistance / 1000,
      totalDuration: totalDuration,
    );
    
    _broadcastTrackUpdate();
  }
  
  /// Финализирует текущий сегмент
  void _finalizeCurrentSegment() {
    if (_currentSegmentBuilder != null && _currentSegmentBuilder!.pointCount > 0) {
      final segment = _currentSegmentBuilder!.build();
      final updatedSegments = List<CompactTrack>.from(_currentTrack!.segments)..add(segment);
      
      // Пересчитываем метрики
      int totalPoints = 0;
      double totalDistance = 0.0;
      Duration totalDuration = Duration.zero;

      for (final seg in updatedSegments) {
        totalPoints += seg.pointCount;
        totalDistance += seg.getTotalDistance();
        totalDuration += seg.getDuration();
      }
      
      _currentTrack = _currentTrack!.copyWith(
        segments: updatedSegments,
        totalPoints: totalPoints,
        totalDistanceKm: totalDistance / 1000,
        totalDuration: totalDuration,
      );
      
      _currentSegmentBuilder = null;
    }
  }
  
  /// Отправляет обновление трека в стрим
  void _broadcastTrackUpdate() {
    if (_currentTrack != null) {
      _trackUpdateController.add(_currentTrack!);
    }
  }
  
  /// Освобождает ресурсы
  Future<void> dispose() async {
    await stopTracking();
    await _trackUpdateController.close();
    await _positionController.close();
  }
}
