import 'dart:convert';

import '../entities/compact_track.dart';
import '../entities/compact_track_builder.dart';

/// Parse JSON lines from native readBatch into a list of point maps.
/// Malformed lines are skipped.
List<Map<String, dynamic>> parseBatchLines(List<String> lines) {
  final out = <Map<String, dynamic>>[];
  for (final line in lines) {
    try {
      final m = jsonDecode(line) as Map<String, dynamic>;
      // Expect at least id, latitude, longitude, timestamp
      if (!m.containsKey('id') || !m.containsKey('latitude') || !m.containsKey('longitude')) continue;
      // Ensure timestamp exists
      if (!m.containsKey('timestamp')) m['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      out.add(m);
    } catch (_) {
      // skip malformed
    }
  }
  return out;
}

/// Sort points by numeric timestamp ascending.
List<Map<String, dynamic>> sortPointsByTimestamp(List<Map<String, dynamic>> pts) {
  final copy = List<Map<String, dynamic>>.from(pts);
  copy.sort((a, b) => (a['timestamp'] as num).toInt().compareTo((b['timestamp'] as num).toInt()));
  return copy;
}

List<CompactTrack> splitIntoSegments(List<Map<String, dynamic>> pts, {int gapThresholdSeconds = 300}) {
  if (pts.isEmpty) return [];

  final sorted = sortPointsByTimestamp(pts);
  final segments = <CompactTrack>[];
  final builder = CompactTrackBuilder();
  int? lastTs;

  for (final m in sorted) {
    final lat = (m['latitude'] as num).toDouble();
    final lon = (m['longitude'] as num).toDouble();
    final ts = (m['timestamp'] as num).toInt();
    final acc = m.containsKey('accuracy') ? (m['accuracy'] as num).toDouble() : null;

    if (lastTs != null && (ts - lastTs) / 1000 > gapThresholdSeconds && builder.pointCount > 0) {
      segments.add(builder.buildAndClear());
    }

    builder.addPoint(latitude: lat, longitude: lon, timestamp: DateTime.fromMillisecondsSinceEpoch(ts), accuracy: acc);
    lastTs = ts;
  }

  if (builder.pointCount > 0) segments.add(builder.buildAndClear());
  return segments;
}
