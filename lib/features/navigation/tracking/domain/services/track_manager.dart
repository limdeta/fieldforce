import 'dart:async';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/enums/track_status.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_buffer.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/external_segment_persister.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';

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
  /// Keep the last saved/completed track in memory so UI can show it after stop
  UserTrack? _lastSavedTrack;
  StreamSubscription? _autoFlushSubscription;
  Timer? _persistTimer;
  int _updateCounter = 0; // Счетчик отправленных обновлений

  final StreamController<UserTrack> _trackUpdateController = StreamController<UserTrack>.broadcast();
  
  final ExternalSegmentPersister _externalPersister;

  TrackManager(this._repository, {ExternalSegmentPersister? externalPersister}) : _externalPersister = externalPersister ?? DefaultExternalSegmentPersister(_repository) {
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
    // If we have an active in-memory track, prefer it. Otherwise return
    // the last saved/completed track so UI can render the latest data even
    // after stopTracking() has been called.
    final track = _currentTrack ?? _lastSavedTrack;
    if (track == null) return null;
    // Return only saved segments here; live buffer is provided separately
    return track;
  }

  /// Единый метод запуска трекинга - автоматически определяет нужно ли создавать новый трек или продолжать существующий
  Future<bool> startTracking({
    required NavigationUser user,
  }) async {
    _logger.info('🚀 TrackManager.startTracking для пользователя: ${user.fullName} (ID: ${user.id})');
    
    if (_currentTrack != null) {
      // If we already have a _currentTrack in memory but it's paused, resume it.
      if (_currentTrack!.status != TrackStatus.active) {
        _logger.info('🔄 TrackManager.startTracking: есть трек в памяти, возобновляем (ID: ${_currentTrack!.id})');
        _currentTrack = _currentTrack!.copyWith(status: TrackStatus.active, endTime: null);
        // clear live buffer on resume to avoid showing stale points
        _buffer.clear();
        return true;
      }

      _logger.info('⚠️ TrackManager.startTracking: трек уже активен (ID: ${_currentTrack!.id}), ничего не делаем.');
      return true;
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
      // Always try to continue an existing active or paused track for the day
      final candidates = tracks.where((track) =>
        track.status == TrackStatus.active || track.status == TrackStatus.paused
      ).toList();
      if (candidates.isNotEmpty) {
        // If there are duplicates (shouldn't happen by business rules) prefer the most recent one
        if (candidates.length > 1) {
          _logger.warning('⚠️ TrackManager.startTracking: найдено несколько активных/паузы треков (${candidates.length}), выбираем самый свежий и логируем дубликаты');
          for (final t in candidates) {
            _logger.info('   candidate: id=${t.id}, start=${t.startTime}, status=${t.status}, segments=${t.segments.length}');
          }
          candidates.sort((a, b) => b.startTime.compareTo(a.startTime));
        }
        existingTrack = candidates.first;
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
      // Keep lastSavedTrack pointing to the persisted track so UI can render immediately
      try { _lastSavedTrack = _currentTrack; } catch (_) {}
    } else {
      // No existing track for today — create a new one
      _logger.info('🆕 TrackManager: Создаем новый трек для нового дня');
      _currentTrack = UserTrack.empty(
        id: DateTime.now().millisecondsSinceEpoch,
        user: user,
        status: TrackStatus.active,
        metadata: {
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      // For a brand new track we do not have a lastSavedTrack yet
    }

    _logger.info('✅ Трек готов: ID=${_currentTrack!.id}, Status=${_currentTrack!.status}');
  // When starting, clear live buffer to avoid showing stale points.
  _buffer.clear();
    
    return true;
  }

  Future<void> stopTracking() async {
    if (_currentTrack == null) return;
    
    // Сохраняем финальный сегмент из буфера если есть данные
    // For now we do NOT finalize the track on stop: instead we persist any
    // buffered points and mark the track as paused so it can be resumed later
    // during the same day. Closing a track (status=completed) will be done
    // only when day finalization is introduced.
    if (_buffer.hasData) {
      _logger.info('TRACK_SAVE_START: draining buffer for stopTracking (pause semantics)');
      final finalSegment = _buffer.drain();
      if (finalSegment.pointCount > 0) {
        _currentTrack!.segments.add(finalSegment);
        _logger.info('TRACK_SAVE_SAVING: finalSegment.pointCount=${finalSegment.pointCount}');
        final result = await _repository.saveOrUpdateUserTrack(_currentTrack!);
        if (result.isRight()) {
          _logger.info('TRACK_SAVE_COMPLETE: saved final segment (pause) and will emit track');
          // Уведомляем UI об обновлённом треке
          _trackUpdateController.add(_currentTrack!);
          // Cache last saved so UI can show persisted state
          try { _lastSavedTrack = _currentTrack; } catch (_) {}
        } else {
          _logger.warning('TRACK_SAVE_FAILED: failed to save final segment (pause)');
        }
      }
    }

    // Mark the in-memory track as paused (do not complete or drop it)
    _currentTrack = _currentTrack!.copyWith(
      status: TrackStatus.paused,
    );

    final result2 = await _repository.saveOrUpdateUserTrack(_currentTrack!);
    if (result2.isRight()) {
      _trackUpdateController.add(_currentTrack!);
      try { _lastSavedTrack = _currentTrack; } catch (_) {}
    }

    // Clear the live buffer but keep the _currentTrack in memory so we can
    // continue appending points until explicit end-of-day finalization.
    _buffer.clear();
  }
  
  Future<void> pauseTracking() async {
    if (_currentTrack == null) return;
    
    // Сохраняем текущий буфер как сегмент
    if (_buffer.hasData) {
      _logger.info('TRACK_SAVE_START: draining buffer for pauseTracking');
      final segment = _buffer.drain();
      if (segment.pointCount > 0) {
        _logger.info('TRACK_SAVE_SAVING: pause segment.pointCount=${segment.pointCount}');
        _currentTrack!.segments.add(segment);
        final result = await _repository.saveOrUpdateUserTrack(_currentTrack!);
        if (result.isRight()) {
          _logger.info('TRACK_SAVE_COMPLETE: pause saved segment and will emit track');
          // Уведомляем UI, чтобы он увидел сохранённый сегмент
          _trackUpdateController.add(_currentTrack!);
          _lastSavedTrack = _currentTrack;
        } else {
          _logger.warning('TRACK_SAVE_FAILED: pause failed to save segment');
        }
      }
    }
    
    _currentTrack = _currentTrack!.copyWith(
      status: TrackStatus.paused,
    );
    
    final result2 = await _repository.saveOrUpdateUserTrack(_currentTrack!);
    if (result2.isRight()) {
      _trackUpdateController.add(_currentTrack!);
    }
  }

  /// Слить текущий буфер в трек и сохранить без изменения статуса трека
  Future<bool> flushBufferToCurrentTrack() async {
    if (_currentTrack == null) return false;
    if (!_buffer.hasData) return false;

    final segment = _buffer.drain();
    if (segment.pointCount == 0) return false;

    try {
      _logger.info('TRACK_SAVE_START: explicit flushBufferToCurrentTrack');
      _currentTrack!.segments.add(segment);
      final result = await _repository.saveOrUpdateUserTrack(_currentTrack!);
      if (result.isRight()) {
        _logger.info('TRACK_SAVE_COMPLETE: flush saved segment');
        _trackUpdateController.add(_currentTrack!);
        _logger.info('💾 TrackManager.flushBufferToCurrentTrack: buffered segment saved and emitted');
        _lastSavedTrack = _currentTrack;
        return true;
      } else {
        _logger.severe('❌ TrackManager.flushBufferToCurrentTrack: ошибка сохранения');
        return false;
      }
    } catch (e, st) {
      _logger.severe('❌ TrackManager.flushBufferToCurrentTrack: исключение', e, st);
      return false;
    }
  }

  /// Принудительно завершает текущий сегмент, чтобы избежать "телепортов".
  Future<void> breakCurrentSegment({String? reason}) async {
    if (_currentTrack == null) {
      _logger.warning('TrackManager.breakCurrentSegment: нет активного трека (reason=$reason)');
      _buffer.clear();
      return;
    }

    _logger.warning('TrackManager.breakCurrentSegment: reason=$reason, bufferedPoints=${_buffer.pointCount}');

    if (_buffer.hasData) {
      final saved = await flushBufferToCurrentTrack();
      if (!saved) {
        _logger.severe('TrackManager.breakCurrentSegment: не удалось сохранить буфер, очищаем чтобы не допустить телепорта');
        _buffer.clear();
      } else {
        _buffer.clear();
      }
    } else {
      _buffer.clear();
    }
  }

  void clearLiveBuffer() {
    _buffer.clear();
  }

  /// Persist externally-provided segments (for example from native background queue).
  ///
  /// Rules:
  /// - Segments should be ordered by time before calling this method.
  /// - Segments that are entirely older than the current track end by more than
  ///   [allowedBackfillSeconds] will be dropped as likely invalid/replayed points.
  /// - Each accepted segment is appended to the in-memory current track and
  ///   persisted via repository.saveOrUpdateUserTrack. The method returns true
  ///   only if all persistence operations succeed.
  Future<bool> persistExternalSegments(List<CompactTrack> segments, {int allowedBackfillSeconds = 30}) async {
    if (segments.isEmpty) return true;

    if (_currentTrack == null) {
      _logger.warning('TrackManager.persistExternalSegments: no active _currentTrack in memory');
      return false;
    }

    _logger.info('TrackManager.persistExternalSegments: delegating to persister for track id=${_currentTrack!.id} segments=${segments.length}');
    print('TRACE: persistExternalSegments -> track id=${_currentTrack!.id} segments=${segments.length}');
    final success = await _externalPersister.persistExternalSegments(_currentTrack!, segments, allowedBackfillSeconds: allowedBackfillSeconds);
    print('TRACE: persister returned $success');
    if (success) {
      _updateCounter++;
      _trackUpdateController.add(_currentTrack!);
      try { _lastSavedTrack = _currentTrack; } catch (_) {}
    }
    return success;
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
        // Cache last saved track for UI restore
        try { _lastSavedTrack = _currentTrack; } catch (_) {}
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
