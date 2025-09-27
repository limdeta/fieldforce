import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logging/logging.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/track_manager.dart';
import 'package:flutter/foundation.dart';

import 'gps_data_source.dart';
import 'mock_gps_data_source.dart';
import 'background_ingest_utils.dart';

/// Clean GpsDataManager implementing the native Room contract.
enum GpsMode { real, mock }

class GpsTestConfig {
  final String? mockDataPath;
  final double speedMultiplier;
  final bool addGpsNoise;
  final double baseAccuracy;
  final double? startProgress;

  const GpsTestConfig({
    this.mockDataPath,
    this.speedMultiplier = 1.0,
    this.addGpsNoise = true,
    this.baseAccuracy = 5.0,
    this.startProgress,
  });

  static const defaultTest = GpsTestConfig(
    mockDataPath: 'assets/data/tracks/continuation_scenario.json',
    speedMultiplier: 1.5,
    addGpsNoise: true,
    baseAccuracy: 4.0,
  );

  static const fastTest = GpsTestConfig(
    mockDataPath: 'assets/data/tracks/current_day_track.json',
    speedMultiplier: 10.0,
    addGpsNoise: false,
    baseAccuracy: 3.0,
    startProgress: 0.8,
  );
}

class GpsDataManager {
  static final Logger _logger = Logger('GpsDataManager');

  GpsDataSource? _currentSource;
  GpsMode _currentMode = GpsMode.real;

  static const MethodChannel _platformChannel = MethodChannel('fieldforce/background_location');
  final StreamController<Position> _nativePositionController = StreamController<Position>.broadcast();

  static final GpsDataManager _instance = GpsDataManager._internal();
  factory GpsDataManager() => _instance;

  bool _nativeServiceStarted = false;
  bool _hasBackgroundPermission = false;
  bool _permissionRequestInProgress = false;
  DateTime? _lastPermissionRequestAt;

  GpsDataManager._internal() {
    _platformChannel.setMethodCallHandler((call) async {
      try {
        if (call.method == 'onLocation') {
          final args = Map<String, dynamic>.from(call.arguments as Map);
          final double lat = (args['latitude'] as num).toDouble();
          final double lon = (args['longitude'] as num).toDouble();
          final double accuracy = args.containsKey('accuracy') ? (args['accuracy'] as num).toDouble() : 0.0;
          final int timestamp = args.containsKey('timestamp') ? (args['timestamp'] as int) : DateTime.now().millisecondsSinceEpoch;

          final pos = Position(
            latitude: lat,
            longitude: lon,
            timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp),
            accuracy: accuracy,
            altitude: 0.0,
            heading: 0.0,
            altitudeAccuracy: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );

          _nativePositionController.add(pos);
        } else if (call.method == 'onStatus') {
          _logger.info('GpsDataManager: native status=${call.arguments}');
        }
      } catch (e, st) {
        _logger.warning('Error handling platform channel call', e, st);
      }
    });
  }

  GpsMode get currentMode => _currentMode;
  GpsDataSource? get currentSource => _currentSource;

  Future<void> initialize({required GpsMode mode, GpsTestConfig testConfig = GpsTestConfig.defaultTest}) async {
    await _disposeCurrentSource();
  _currentMode = mode;

    switch (mode) {
      case GpsMode.real:
        _currentSource = RealGpsDataSource();
        break;
      case GpsMode.mock:
        final mockSource = MockGpsDataSource(
          speedMultiplier: testConfig.speedMultiplier,
          addGpsNoise: testConfig.addGpsNoise,
          baseAccuracy: testConfig.baseAccuracy,
        );
        if (testConfig.mockDataPath != null) await mockSource.loadRoute(testConfig.mockDataPath!);
        if (testConfig.startProgress != null) mockSource.setProgress(testConfig.startProgress!);
        _currentSource = mockSource;
        break;
    }
  }

  Future<void> _disposeCurrentSource() async {
    if (_currentSource != null) {
      await _currentSource!.dispose();
      _currentSource = null;
    }
  }

  Stream<Position> getPositionStream({required LocationSettings settings}) {
    if (_currentSource == null) {
      if (Platform.isAndroid) return _nativePositionController.stream;
      throw StateError('GPS source not initialized');
    }

    return Stream<Position>.multi((controller) {
      final subs = <StreamSubscription<Position>>[];
      subs.add(_currentSource!.getPositionStream(settings: settings).listen(controller.add, onError: controller.addError));
      if (Platform.isAndroid) subs.add(_nativePositionController.stream.listen(controller.add, onError: controller.addError));
      controller.onCancel = () {
        for (final s in subs) s.cancel();
      };
    });
  }

  Future<bool> checkPermissions() async {
    if (_currentSource == null) throw StateError('GPS source not initialized');
    return _currentSource!.checkPermissions();
  }

  // Native-backed Room PoC helpers
  /// Reads a batch from native Room and returns a list of maps representing points.
  Future<List<Map<String, dynamic>>> readBatchFromNative({int limit = 200}) async {
    if (!Platform.isAndroid) return [];
    try {
      final res = await _platformChannel.invokeMethod<List>('readBatch', {'limit': limit});
      if (res == null) return [];
      // Each element should be a Map coming from the platform channel
      final out = <Map<String, dynamic>>[];
      for (final e in res) {
        try {
          final m = Map<String, dynamic>.from(e as Map);
          out.add(m);
        } catch (_) {
          // ignore malformed
        }
      }
      return out;
    } catch (e, st) {
      _logger.warning('readBatchFromNative failed', e, st);
      return [];
    }
  }

  Future<bool> markProcessedOnNative(List<int> ids) async {
    if (!Platform.isAndroid) return false;
    try {
      final res = await _platformChannel.invokeMethod<bool>('markProcessed', {'ids': ids});
      return res == true;
    } catch (e, st) {
      _logger.warning('markProcessedOnNative failed', e, st);
      return false;
    }
  }

  /// Read one batch, parse minimal info and run isolate worker for heavy merging.
  Future<int> processOneBatchFromNative({int limit = 200}) async {
    final batch = await readBatchFromNative(limit: limit);
    if (batch.isEmpty) return 0;

    final rawIds = <int>[];
    for (final m in batch) {
      try {
        rawIds.add((m['id'] as num).toInt());
      } catch (_) {
        // skip malformed
      }
    }
    if (rawIds.isEmpty) return 0;

    try {
      final Map<String, dynamic> res = await compute<_BatchProcessInput, Map<String, dynamic>>(
        _processBatchIsolate,
        _BatchProcessInput(batch.map((e) => e).toList()),
      );

      final List<dynamic>? idsDyn = res['ids'] as List<dynamic>?;
      final List<dynamic>? pointsDyn = res['points'] as List<dynamic>?;
      if (idsDyn == null || idsDyn.isEmpty) return 0;

      final ids = idsDyn.map((e) => (e as num).toInt()).toList();

      // Rehydrate points on main isolate, order them, split by time gaps into
      // CompactTrack segments and persist them atomically via TrackManager.
      try {
        final trackManager = GetIt.instance<TrackManager>();
        if (pointsDyn == null || pointsDyn.isEmpty) {
          // Nothing to persist; ack ids to avoid reprocessing
          final ok = await markProcessedOnNative(ids);
          if (!ok) _logger.warning('Failed to mark processed ids on native side');
          return ids.length;
        }

        // Rehydrate and collect points
        final pts = <Map<String, dynamic>>[];
        for (final p in pointsDyn) {
          try {
            final m = p as Map<String, dynamic>;
            pts.add(m);
          } catch (_) {
            // ignore malformed
          }
        }

        if (pts.isEmpty) {
          final ok = await markProcessedOnNative(ids);
          if (!ok) _logger.warning('Failed to mark processed ids on native side');
          return ids.length;
        }

        // Sort by timestamp ascending
        pts.sort((a, b) => (a['timestamp'] as num).toInt().compareTo((b['timestamp'] as num).toInt()));

        // Используем общую логику разделения на сегменты (5 минут по умолчанию)
        final segments = splitIntoSegments(pts);

        if (segments.isEmpty) {
          final ok = await markProcessedOnNative(ids);
          if (!ok) _logger.warning('Failed to mark processed ids on native side');
          return ids.length;
        }

        final persisted = await trackManager.persistExternalSegments(segments);
        if (persisted) {
          final ok = await markProcessedOnNative(ids);
          if (!ok) _logger.warning('Failed to mark processed ids on native side');
          return ids.length;
        } else {
          _logger.warning('persistExternalSegments failed - skipping native ack');
          return 0;
        }
      } catch (e, st) {
        _logger.warning('Failed persisting points via TrackManager', e, st);
        return 0;
      }
    } catch (e, st) {
      _logger.warning('Isolate batch processing failed', e, st);
      final ok = await markProcessedOnNative(rawIds);
      return ok ? rawIds.length : 0;
    }
  }

  Future<int> drainNativeQueue({int maxBatches = 100, int batchSize = 200}) async {
    var total = 0;
    for (var i = 0; i < maxBatches; i++) {
      final processed = await processOneBatchFromNative(limit: batchSize);
      if (processed == 0) break;
      total += processed;
      await Future.delayed(const Duration(milliseconds: 50));
    }
    return total;
  }

  // Получаем разрешения и стартуем наш Kotlin FGS
  Future<bool> startGps() async {
    try {
      if (_currentSource is MockGpsDataSource) {
        (_currentSource as MockGpsDataSource).resumeStream();
        return true;
      }

      final hasPermission = await checkPermissions();
      if (!hasPermission) return false;

      if (Platform.isAndroid) {
        try {
          final current = await Geolocator.checkPermission();
          if (current == LocationPermission.denied) {
            await Geolocator.requestPermission();
          }

          final after = await Geolocator.checkPermission();
          final now = DateTime.now();
          final recentlyRequested = _lastPermissionRequestAt != null && now.difference(_lastPermissionRequestAt!).inSeconds < 3;

          if (after != LocationPermission.always && !_permissionRequestInProgress && !recentlyRequested) {
            _permissionRequestInProgress = true;
            _lastPermissionRequestAt = DateTime.now();
            try {
              await Geolocator.requestPermission();
            } finally {
              _permissionRequestInProgress = false;
            }
          }

          final finalPerm = await Geolocator.checkPermission();
          _hasBackgroundPermission = finalPerm == LocationPermission.always;
          if (_hasBackgroundPermission && !_nativeServiceStarted) {
            await _platformChannel.invokeMethod('startService', {'minDistance': 5.0, 'intervalMillis': 15000});
            _nativeServiceStarted = true;
          }
        } catch (e, st) {
          _logger.warning('startGps: error while requesting permissions/startService', e, st);
        }
      }

      return true;
    } catch (e, st) {
      _logger.warning('startGps failed', e, st);
      return false;
    }
  }

  void stopGps() {
    try {
      if (_currentSource is MockGpsDataSource) {
        (_currentSource as MockGpsDataSource).pauseStream();
      }
      if (Platform.isAndroid) {
        _platformChannel.invokeMethod('stopService');
      }
    } catch (e, st) {
      _logger.warning('stopGps failed', e, st);
    } finally {
      _nativeServiceStarted = false;
      _hasBackgroundPermission = false;
    }
  }
}

class _BatchProcessInput {
  final List<Map<String, dynamic>> points;
  _BatchProcessInput(this.points);
}

// Isolate entrypoint: normalize maps, ensure types, and return ids + points.
Map<String, dynamic> _processBatchIsolate(_BatchProcessInput input) {
  final ids = <int>[];
  final points = <Map<String, dynamic>>[];

  for (final m in input.points) {
    try {
      final id = (m['id'] as num).toInt();
      final lat = (m['latitude'] as num).toDouble();
      final lon = (m['longitude'] as num).toDouble();
      final acc = m.containsKey('accuracy') ? (m['accuracy'] as num).toDouble() : 0.0;
      final timestamp = m.containsKey('timestamp') ? (m['timestamp'] as num).toInt() : DateTime.now().millisecondsSinceEpoch;

      ids.add(id);
      points.add({
        'id': id,
        'latitude': lat,
        'longitude': lon,
        'accuracy': acc,
        'timestamp': timestamp,
      });
    } catch (_) {
      // ignore malformed entry
    }
  }

  return {
    'ids': ids,
    'points': points,
  };
}

