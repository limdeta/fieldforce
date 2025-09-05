import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/services.dart' show rootBundle;

class TestCoordinatesLoader {
  final double _nominalSpeedMps;
  final double _speedMultiplier;

  TestCoordinatesLoader({double nominalSpeedMps = 5.0, double speedMultiplier = 1.0})
      : _nominalSpeedMps = nominalSpeedMps,
        _speedMultiplier = speedMultiplier;

  /// Load and normalize route from an asset JSON file.
  /// Supports:
  /// - OSRM response with `routes[].geometry.coordinates` (geojson)
  /// - OSRM encoded polyline string in `routes[].geometry` (if file uses that)
  /// - Plain `{ "coordinates": [...] }` or raw array
  Future<List<Map<String, dynamic>>> loadFromAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final data = json.decode(jsonString);
    if (data is Map<String, dynamic>) {
      if (data.containsKey('routes')) {
        return _loadFromOSRMResponse(data);
      } else if (data.containsKey('coordinates')) {
        return _loadFromCoordinatesArray(data['coordinates']);
      }
    } else if (data is List) {
      return _loadFromCoordinatesArray(data);
    }
    throw Exception('Unsupported route JSON format: $assetPath');
  }

  List<Map<String, dynamic>> _loadFromOSRMResponse(Map<String, dynamic> osrmData) {
    final routes = (osrmData['routes'] as List?) ?? [];
    if (routes.isEmpty) return <Map<String, dynamic>>[];
    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'];
    if (geometry is String) {
      final coords = _decodePolyline(geometry);
      return _normalizeAndEnrich(coords.map((c) => [c[0], c[1]]).toList());
    } else if (geometry is Map && geometry['coordinates'] is List) {
      return _loadFromCoordinatesArray(geometry['coordinates'] as List);
    } else if (route['coordinates'] is List) {
      return _loadFromCoordinatesArray(route['coordinates'] as List);
    }
    return <Map<String, dynamic>>[];
  }

  List<Map<String, dynamic>> _loadFromCoordinatesArray(List coordinates) {
    final normalized = <Map<String, dynamic>>[];
    for (final coord in coordinates) {
      if (coord is List && coord.length >= 2) {
        // detect order: likely [lng, lat] for geojson / OSRM
        final a = (coord[0] as num).toDouble();
        final b = (coord[1] as num).toDouble();
        if (_looksLikeLat(a, b)) {
          normalized.add({'lat': a, 'lng': b, if (coord.length >= 3) 'elevation': (coord[2] as num?)?.toDouble()});
        } else {
          normalized.add({'lat': b, 'lng': a, if (coord.length >= 3) 'elevation': (coord[2] as num?)?.toDouble()});
        }
      } else if (coord is Map<String, dynamic>) {
        final lat = (coord['lat'] ?? coord['latitude'] ?? coord['y']) as num?;
        final lng = (coord['lng'] ?? coord['lon'] ?? coord['longitude'] ?? coord['x']) as num?;
        if (lat != null && lng != null) {
          final entry = <String, dynamic>{
            'lat': lat.toDouble(),
            'lng': lng.toDouble(),
          };
          if (coord.containsKey('timestamp')) entry['timestamp'] = coord['timestamp'];
          if (coord.containsKey('elevation')) entry['elevation'] = coord['elevation'];
          normalized.add(entry);
        }
      }
    }
    return _normalizeAndEnrich(normalized.map((m) => [m['lng'], m['lat'], m['elevation']]).toList());
  }

  List<Map<String, dynamic>> _normalizeAndEnrich(List coords) {
    // Convert to list of maps with lat/lng and then generate timestamps/meta
    final pts = <Map<String, dynamic>>[];
    for (final c in coords) {
      if (c is List && c.length >= 2) {
        final lng = (c[0] as num).toDouble();
        final lat = (c[1] as num).toDouble();
        final elevation = c.length >= 3 ? (c[2] as num?)?.toDouble() : null;
        pts.add({'lat': lat, 'lng': lng, if (elevation != null) 'elevation': elevation});
      } else if (c is Map<String, dynamic>) {
        final lat = (c['lat'] as num).toDouble();
        final lng = (c['lng'] as num).toDouble();
        pts.add({'lat': lat, 'lng': lng, if (c.containsKey('elevation')) 'elevation': c['elevation']});
      }
    }
    if (pts.isEmpty) return <Map<String, dynamic>>[];
    return _generateTimestampsAndMeta(pts);
  }

  List<Map<String, dynamic>> _generateTimestampsAndMeta(List<Map<String, dynamic>> pts) {
    final result = <Map<String, dynamic>>[];
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final speedMps = _nominalSpeedMps * _speedMultiplier;
    double accumulatedSec = 0.0;

    for (var i = 0; i < pts.length; i++) {
      final cur = pts[i];
      final prev = i > 0 ? pts[i - 1] : null;

      double segTimeSec = 0.0;
      double bearing = 0.0;
      double speed = speedMps;

      if (prev != null) {
        final d = _haversineMeters(
          prev['lat'] as double,
          prev['lng'] as double,
          cur['lat'] as double,
          cur['lng'] as double,
        );
        segTimeSec = d / speedMps;
        if (segTimeSec <= 0) segTimeSec = 1.0;
        bearing = _bearingBetweenPoints(prev['lat'] as double, prev['lng'] as double, cur['lat'] as double, cur['lng'] as double);
        // slight speed variation
        speed = speedMps * (0.8 + math.Random().nextDouble() * 0.6);
      } else {
        segTimeSec = 1.0;
      }

      accumulatedSec += segTimeSec;
      final ts = nowMs + (accumulatedSec * 1000).round();

      result.add({
        'lat': (cur['lat'] as num).toDouble(),
        'lng': (cur['lng'] as num).toDouble(),
        'timestamp': cur.containsKey('timestamp') ? cur['timestamp'] : ts,
        'elevation': (cur['elevation'] as num?)?.toDouble() ?? 0.0,
        'bearing': bearing,
        'speed': speed, // m/s
      });
    }
    return result;
  }

  // Helpers

  bool _looksLikeLat(double a, double b) {
    // heuristics: lat in [-90,90], lng in [-180,180]
    return (a.abs() <= 90.0 && b.abs() <= 180.0);
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) * math.cos(_degToRad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _bearingBetweenPoints(double lat1, double lon1, double lat2, double lon2) {
    final phi1 = _degToRad(lat1);
    final phi2 = _degToRad(lat2);
    final lambda1 = _degToRad(lon1);
    final lambda2 = _degToRad(lon2);
    final y = math.sin(lambda2 - lambda1) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) - math.sin(phi1) * math.cos(phi2) * math.cos(lambda2 - lambda1);
    final theta = math.atan2(y, x);
    return (theta * 180.0 / math.pi + 360.0) % 360.0;
  }

  // Google encoded polyline decoder -> returns List<[lng, lat]>
  List<List<double>> _decodePolyline(String encoded) {
    final coords = <List<double>>[];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      coords.add([lng / 1e5, lat / 1e5]);
    }

    return coords;
  }
}
