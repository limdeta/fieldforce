import 'dart:async';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/enums/track_status.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_buffer.dart';
import 'package:geolocator/geolocator.dart';

/// Менеджер GPS треков
/// 
/// Принципы:
/// - Буферизация GPS точек в памяти
/// - Периодическое сохранение в БД
/// - Разделение UI и persistence слоёв
/// - Оптимизация для real-time обновлений
/// - Один активный трек на день для пользователя
class TrackManager {
  final UserTrackRepository _repository;
  final GpsBuffer _buffer = GpsBuffer();
  
  UserTrack? _currentTrack;
  StreamSubscription? _bufferSubscription;
  Timer? _persistTimer;

  final StreamController<UserTrack> _trackUpdateController = StreamController<UserTrack>.broadcast();
  
  // Кэширование для UI трека, чтобы избежать постоянного пересоздания
  UserTrack? _cachedUITrack;
  int _lastBufferPointCount = 0;
  
  // Throttling для UI обновлений
  DateTime? _lastUIUpdateTime;
  
  TrackManager(this._repository) {
    // Подписываемся на обновления буфера
    _bufferSubscription = _buffer.updateStream.listen(_onBufferUpdate);
    
    // ЗАМЕНЯЕМ таймер на умную сегментацию
    // _persistTimer = Timer.periodic(const Duration(seconds: 4), (_) => _persistTrack());
  }

  /// Стрим обновлений трека для UI
  Stream<UserTrack> get trackUpdateStream => _trackUpdateController.stream;
  
  /// Текущий трек (включая буфер для UI)
  UserTrack? get currentTrackForUI {
    if (_currentTrack == null) return null;
    
    // Получаем текущий буфер
    final bufferSegment = _buffer.getCurrentSegment();
    final currentBufferPointCount = bufferSegment.pointCount;
    
    // Если буфер не изменился значительно, возвращаем кэшированный трек
    if (_cachedUITrack != null && 
        _lastBufferPointCount == currentBufferPointCount &&
        _cachedUITrack!.segments.length - 1 == _currentTrack!.segments.length) {
      return _cachedUITrack;
    }
    
    // Объединяем сохранённые сегменты с буфером
    final savedSegments = _currentTrack!.segments;
    
    if (bufferSegment.isEmpty) {
      _cachedUITrack = _currentTrack;
      _lastBufferPointCount = 0;
      return _currentTrack;
    }

    final allSegments = [...savedSegments, bufferSegment];
    final liveSegmentIndex = allSegments.length - 1; // Последний сегмент = живой буфер

    int totalPoints = 0;
    double totalDistance = 0.0;
    Duration totalDuration = Duration.zero;
    
    for (final segment in allSegments) {
      totalPoints += segment.pointCount;
      totalDistance += segment.getTotalDistance();
      totalDuration += segment.getDuration();
    }
    
    _cachedUITrack = _currentTrack!.copyWith(
      segments: allSegments,
      liveSegmentIndex: liveSegmentIndex, // Указываем какой сегмент живой
      totalPoints: totalPoints,
      totalDistanceKm: totalDistance / 1000,
      totalDuration: totalDuration,
    );
    
    _lastBufferPointCount = currentBufferPointCount;
    return _cachedUITrack;
  }

  /// Единый метод запуска трекинг�� - автоматически определяет нужно ли создавать новый трек или продолжать существующий
  Future<bool> startTracking({
    required NavigationUser user,
  }) async {
    if (_currentTrack != null) {
      await stopTracking();
    }

    print('🔍 TrackManager: Ищем существующий трек за сегодня для пользователя ${user.id}');

    // Ищем трек за сегодня
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final tracksResult = await _repository.getUserTracksByDateRange(
      user, startOfDay, endOfDay
    );

    UserTrack? existingTrack;
    if (tracksResult.isRight()) {
      final tracks = tracksResult.getOrElse(() => []);
      // Ищем активный или трек на паузе
      existingTrack = tracks.where((track) =>
        track.status == TrackStatus.active || track.status == TrackStatus.paused
      ).firstOrNull;
    }

    if (existingTrack != null) {
      print('🔄 TrackManager: Найден существующий трек (ID: ${existingTrack.id}), продолжаем его');
      _currentTrack = existingTrack.copyWith(
        status: TrackStatus.active,
        endTime: null,
      );
    } else {
      print('🆕 TrackManager: Создаем новый трек для нового дня');
      _currentTrack = UserTrack.empty(
        id: DateTime.now().millisecondsSinceEpoch,
        user: user,
        status: TrackStatus.active,
        metadata: {
          'created_at': DateTime.now().toIso8601String(),
        },
      );
    }

    _buffer.clear();
    
    // Очищаем кэш UI трека
    _cachedUITrack = null;
    _lastBufferPointCount = 0;
    
    return true;
  }

  Future<void> stopTracking() async {
    if (_currentTrack == null) return;
    
    // Сохраняем буфер перед остановкой
    await _persistTrack();
    
    // Завершаем трек
    _currentTrack = _currentTrack!.copyWith(
      status: TrackStatus.completed,
      endTime: DateTime.now(),
    );
    
    // Финальное сохранение - репозиторий сам решит INSERT или UPDATE
    await _repository.saveOrUpdateUserTrack(_currentTrack!);

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
    // ИЗМЕНЕНО: Отправляем обновления в UI чаще для более плавной отрисовки
    // Отправляем при каждой новой точке, но с учетом времени для throttling
    final now = DateTime.now();
    final timeSinceLastUpdate = _lastUIUpdateTime != null 
        ? now.difference(_lastUIUpdateTime!)
        : Duration.zero;
    
    // Отправляем обновления не чаще чем раз в 500мс ИЛИ при каждой 3-й точке
    final shouldUpdate = bufferSegment.pointCount > 0 && (
      timeSinceLastUpdate.inMilliseconds >= 500 || 
      bufferSegment.pointCount % 3 == 0
    );
    
    if (shouldUpdate) {
      final trackForUI = currentTrackForUI;
      if (trackForUI != null) {
        _trackUpdateController.add(trackForUI);
        _lastUIUpdateTime = now;
      }
    }

    // НОВАЯ ЛОГИКА: Умная сегментация
    _checkSegmentationConditions();
  }

  /// Проверяет условия для создания нового сегмента
  void _checkSegmentationConditions() {
    if (_currentTrack == null || !_buffer.hasData) return;

    final bufferSegment = _buffer.getCurrentSegment();
    final timeSinceLastPersist = _lastPersistTime != null
        ? DateTime.now().difference(_lastPersistTime!)
        : Duration.zero;

    // Условие 1: Буфер заполнен (50+ точек)
    if (bufferSegment.pointCount >= 50) {
      print('📊 TrackManager: Буфер заполнен (${bufferSegment.pointCount} точек), создаем сегмент');
      _persistTrack();
      return;
    }

    // Условие 2: Прошло много времени (5+ минут)
    if (timeSinceLastPersist.inMinutes >= 5) {
      print('⏰ TrackManager: Прошло ${timeSinceLastPersist.inMinutes} минут, создаем сегмент');
      _persistTrack();
      return;
    }

    // Условие 3: Пройдено значительное ��асстояние (2+ км)
    if (bufferSegment.getTotalDistance() >= 2000) {
      print('🛣️ TrackManager: Пройдено ${bufferSegment.getTotalDistance()/1000}км, создаем сегмент');
      _persistTrack();
      return;
    }

    // Условие 4: Обнаружена остановка (детектор активности)
    if (_detectStationaryPeriod(bufferSegment)) {
      print('🛑 TrackManager: Обнаружена остановка, создаем сегмент');
      _persistTrack();
      return;
    }
  }

  DateTime? _lastPersistTime;

  /// Детектор остановок по GPS данным
  bool _detectStationaryPeriod(CompactTrack segment) {
    if (segment.pointCount < 10) return false;

    final lastPoints = segment.pointCount >= 10 ? 10 : segment.pointCount;
    double totalDistance = 0.0;

    for (int i = segment.pointCount - lastPoints; i < segment.pointCount - 1; i++) {
      final (lat1, lng1) = segment.getCoordinates(i);
      final (lat2, lng2) = segment.getCoordinates(i + 1);
      totalDistance += _calculateDistance(lat1, lng1, lat2, lng2);
    }

    // Если за последние 10 точек прошли меньше 50 метров - остановка
    return totalDistance < 50.0;
  }

  static double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
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
      
      // ИСПРАВЛЕНО: Репозиторий сам решает INSERT или UPDATE
      final result = await _repository.saveOrUpdateUserTrack(_currentTrack!);
      if (result.isRight()) {
        // Обновляем трек с ID из БД если это был INSERT
        _currentTrack = result.getOrElse(() => _currentTrack!);
      }

      _lastPersistTime = DateTime.now();
      print('✅ TrackManager: Сегмент сохранён (${newSegment.pointCount} точек)');
      
    } catch (e) {
      print('❌ TrackManager: Ошибка сохранения сегмента: $e');
    }
  }
}
