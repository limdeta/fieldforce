import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:logging/logging.dart';

/// Utility: normalizes an angle to the [0, 360) range.
double normalizeHeading(double value) {
  final normalized = value % 360;
  return normalized < 0 ? normalized + 360 : normalized;
}

/// Utility: calculates the shortest signed difference (in degrees) between two angles.
double shortestHeadingDelta(double target, double current) {
  double diff = normalizeHeading(target) - normalizeHeading(current);
  if (diff > 180) diff -= 360;
  if (diff < -180) diff += 360;
  return diff;
}

/// Service abstraction for retrieving device orientation (bearing relative to north).
abstract class DeviceOrientationService {
  Stream<double> get headingStream;
  double? get lastHeading;

  Future<void> start();
  Future<void> stop();
  Future<void> dispose();
}

/// Implementation backed by the platform compass sensor.
class CompassDeviceOrientationService implements DeviceOrientationService {
  static final Logger _logger = Logger('CompassDeviceOrientationService');

  final StreamController<double> _controller = StreamController<double>.broadcast();
  StreamSubscription<CompassEvent>? _subscription;

  double? _lastHeading;
  double? _filteredHeading;
  DateTime? _lastEmittedAt;

  @override
  Stream<double> get headingStream => _controller.stream;

  @override
  double? get lastHeading => _lastHeading;

  @override
  Future<void> start() async {
    if (_subscription != null) {
      return;
    }

    final stream = FlutterCompass.events;
    if (stream == null) {
      _logger.warning('Compass events stream is null; device may not support a compass sensor.');
      return;
    }

    _subscription = stream.listen((event) {
      final raw = event.heading;
      if (raw == null) {
        return;
      }

      final normalized = normalizeHeading(raw);
      final smoothed = _applySmoothing(normalized);
      _lastHeading = smoothed;

      final now = DateTime.now();
      if (_lastEmittedAt != null && now.difference(_lastEmittedAt!) < const Duration(milliseconds: 100)) {
        return;
      }

      _lastEmittedAt = now;
      if (!_controller.isClosed) {
        _controller.add(smoothed);
      }
    }, onError: (error, stackTrace) {
      if (!_controller.isClosed) {
        _controller.addError(error, stackTrace);
      }
    });
  }

  double _applySmoothing(double value) {
    if (_filteredHeading == null) {
      _filteredHeading = value;
      return value;
    }

    const alpha = 0.18;
    final delta = shortestHeadingDelta(value, _filteredHeading!);
    _filteredHeading = normalizeHeading(_filteredHeading! + delta * alpha);
    return _filteredHeading!;
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _lastEmittedAt = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}

/// Stub implementation for platforms without a compass sensor.
class NoopDeviceOrientationService implements DeviceOrientationService {
  final StreamController<double> _controller = StreamController<double>.broadcast();

  @override
  Stream<double> get headingStream => _controller.stream;

  @override
  double? get lastHeading => null;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {
    await _controller.close();
  }
}

DeviceOrientationService createDeviceOrientationService() {
  if (kIsWeb) {
    return NoopDeviceOrientationService();
  }

  if (Platform.isAndroid || Platform.isIOS) {
    return CompassDeviceOrientationService();
  }

  return NoopDeviceOrientationService();
}
