import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../entities/user_track.dart';
import '../entities/compact_track.dart';
import '../entities/navigation_user.dart';
import '../enums/track_status.dart';
import '../repositories/user_track_repository.dart';
import 'gps_buffer.dart';

/// Менеджер GPS треков с правильной архитектурой
/// 
/// Принципы:
/// - Буферизация GPS точек в памяти
/// - Периодическое сохранение в БД
/// - Разделение UI и persistence слоёв
/// - Оптимизация для real-time обновлений
class OptimizedTrackManager {
  final UserTrackRepository _repository;
  final GpsBuffer _buffer = GpsBuffer();
  
  UserTrack? _currentTrack;
  StreamSubscription? _bufferSubscription;
  Timer? _persistTimer;
  
  final StreamController<UserTrack> _trackUpdateController = StreamController<UserTrack>.broadcast();
  
  OptimizedTrackManager(this._repository) {
    // Подписываемся на обновления буфера
    _bufferSubscription = _buffer.updateStream.listen(_onBufferUpdate);
    
    // Периодическое сохранение в БД
    _persistTimer = Timer.periodic(const Duration(minutes: 1), (_) => _persistTrack());
  }
  
  /// Стрим обновлений трека для UI
  Stream<UserTrack> get trackUpdateStream => _trackUpdateController.stream;
  
  /// Текущий трек (включая буфер для UI)
  UserTrack? get currentTrackForUI {
    if (_currentTrack == null) return null;
    
    // Объединяем сохранённые сегменты с буфером
    final savedSegments = _currentTrack!.segments;
    final bufferSegment = _buffer.getCurrentSegment();
    
    if (bufferSegment.isEmpty) {
      return _currentTrack;
    }
    
    // Возвращаем трек с добавленным буфером
    final allSegments = [...savedSegments, bufferSegment];
    
    // Пересчитываем метрики
    int totalPoints = 0;
    double totalDistance = 0.0;
    Duration totalDuration = Duration.zero;
    
    for (final segment in allSegments) {
      totalPoints += segment.pointCount;
      totalDistance += segment.getTotalDistance();
      totalDuration += segment.getDuration();
    }
    
    return _currentTrack!.copyWith(
      segments: allSegments,
      totalPoints: totalPoints,
      totalDistanceKm: totalDistance / 1000,
      totalDuration: totalDuration,
    );
  }
  
  /// Начинает новый трек
  Future<bool> startTracking({
    required NavigationUser user,
    String? routeId,
  }) async {
    if (_currentTrack != null) {
      await stopTracking();
    }
    
    _currentTrack = UserTrack.empty(
      id: DateTime.now().millisecondsSinceEpoch,
      user: user,
      status: TrackStatus.active,
      metadata: {
        'route_id': routeId,
        'created_at': DateTime.now().toIso8601String(),
      },
    );
    
    _buffer.clear();
    return true;
  }
  
  /// Продолжает существующий трек
  Future<bool> continueTracking(UserTrack existingTrack) async {
    _currentTrack = existingTrack.copyWith(
      status: TrackStatus.active,
      endTime: null,
    );
    
    _buffer.clear();
    return true;
  }
  
  /// Останавливает трекинг
  Future<void> stopTracking() async {
    if (_currentTrack == null) return;
    
    // Сохраняем буфер перед остановкой
    await _persistTrack();
    
    // Завершаем трек
    _currentTrack = _currentTrack!.copyWith(
      status: TrackStatus.completed,
      endTime: DateTime.now(),
    );
    
    // Финальное сохранение
    await _repository.saveUserTrack(_currentTrack!);
    
    _currentTrack = null;
    _buffer.clear();
  }
  
  /// Ставит трекинг на паузу
  Future<void> pauseTracking() async {
    if (_currentTrack == null) return;
    
    // Сохраняем текущий буфер как сегмент
    await _persistTrack();
    
    _currentTrack = _currentTrack!.copyWith(
      status: TrackStatus.paused,
    );
  }
  
  /// Возобновляет трекинг после паузы
  Future<void> resumeTracking() async {
    if (_currentTrack == null) return;
    
    _currentTrack = _currentTrack!.copyWith(
      status: TrackStatus.active,
    );
    
    _buffer.clear();
  }
  
  /// Добавляет GPS точку
  void addGpsPoint(Position position) {
    if (_currentTrack == null || _currentTrack!.status != TrackStatus.active) {
      return;
    }
    
    _buffer.addPoint(position);
  }
  
  /// Освобождает ресурсы
  void dispose() {
    _bufferSubscription?.cancel();
    _persistTimer?.cancel();
    _buffer.dispose();
    _trackUpdateController.close();
  }
  
  // Приватные методы
  
  void _onBufferUpdate(CompactTrack bufferSegment) {
    // При обновлении буфера уведомляем UI
    final trackForUI = currentTrackForUI;
    if (trackForUI != null) {
      _trackUpdateController.add(trackForUI);
    }
  }
  
  Future<void> _persistTrack() async {
    if (_currentTrack == null || !_buffer.hasData) return;
    
    try {
      // Получаем сегмент из буфера
      final newSegment = _buffer.flush();
      
      // Добавляем сегмент к треку
      final updatedSegments = [..._currentTrack!.segments, newSegment];
      
      // Пересчитываем метрики
      int totalPoints = 0;
      double totalDistance = 0.0;
      Duration totalDuration = Duration.zero;
      
      for (final segment in updatedSegments) {
        totalPoints += segment.pointCount;
        totalDistance += segment.getTotalDistance();
        totalDuration += segment.getDuration();
      }
      
      _currentTrack = _currentTrack!.copyWith(
        segments: updatedSegments,
        totalPoints: totalPoints,
        totalDistanceKm: totalDistance / 1000,
        totalDuration: totalDuration,
      );
      
      // Сохраняем в БД
      await _repository.saveUserTrack(_currentTrack!);
      
      print('✅ TrackManager: Сегмент сохранён (${newSegment.pointCount} точек)');
      
    } catch (e) {
      print('❌ TrackManager: Ошибка сохранения сегмента: $e');
    }
  }
}
