import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/background_ingest_utils.dart';

void main() {
  group('parseBatchLines', () {
    test('parses valid JSON lines and skips malformed', () {
      final lines = [
        '{"id":1,"latitude":10.0,"longitude":20.0,"timestamp":1600000000000}',
        'not a json',
        '{"id":2,"latitude":11.0,"longitude":21.0}'
      ];

      final pts = parseBatchLines(lines);
      expect(pts.length, 2);
      expect(pts[0]['id'], 1);
      expect(pts[1]['id'], 2);
      expect(pts[1]['timestamp'], isNotNull);
    });
  });

  group('splitIntoSegments', () {
    test('splits by time gap and orders points', () {
      final pts = [
        {'id': 3, 'latitude': 0.0, 'longitude': 0.0, 'timestamp': 1000},
        {'id': 1, 'latitude': 1.0, 'longitude': 1.0, 'timestamp': 500},
        {'id': 2, 'latitude': 2.0, 'longitude': 2.0, 'timestamp': 800},
        // gap of 200s -> new segment
        {'id': 4, 'latitude': 3.0, 'longitude': 3.0, 'timestamp': 1000 + 201 * 1000},
      ];

  final segs = splitIntoSegments(pts, gapThresholdSeconds: 200);
  expect(segs.length, 2);
  expect(segs[0].pointCount, 3);
  expect(segs[1].pointCount, 1);
  // check ordering by timestamps
  expect(segs[0].getTimestamp(0).millisecondsSinceEpoch, 500);
  expect(segs[0].getTimestamp(1).millisecondsSinceEpoch, 800);
  expect(segs[0].getTimestamp(2).millisecondsSinceEpoch, 1000);
    });
  });
}
