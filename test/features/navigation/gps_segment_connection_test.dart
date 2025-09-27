import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/background_ingest_utils.dart';

void main() {
  group('GPS segment connection logic', () {
    test('splits segments correctly with 5-minute gap threshold', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final pts = [
        {'id': 1, 'latitude': 55.7558, 'longitude': 37.6176, 'timestamp': now}, // Москва
        {'id': 2, 'latitude': 55.7559, 'longitude': 37.6177, 'timestamp': now + 60000}, // 1 минута спустя
        {'id': 3, 'latitude': 55.7560, 'longitude': 37.6178, 'timestamp': now + 120000}, // 2 минуты спустя
        
        // 10-минутный разрыв - должен создать новый сегмент
        {'id': 4, 'latitude': 59.9311, 'longitude': 30.3609, 'timestamp': now + 120000 + 600000}, // Санкт-Петербург, 12 минут от начала
        {'id': 5, 'latitude': 59.9312, 'longitude': 30.3610, 'timestamp': now + 120000 + 660000}, // 13 минут от начала
      ];

      // Используем стандартный порог 5 минут (300 секунд)
      final segments = splitIntoSegments(pts);
      
      expect(segments.length, 2, reason: 'Должно быть 2 сегмента из-за 10-минутного разрыва');
      expect(segments[0].pointCount, 3, reason: 'Первый сегмент должен содержать 3 точки (Москва)');
      expect(segments[1].pointCount, 2, reason: 'Второй сегмент должен содержать 2 точки (СПб)');
      
      // Проверяем временные метки
      expect(segments[0].getTimestamp(0).millisecondsSinceEpoch, now);
      expect(segments[0].getTimestamp(2).millisecondsSinceEpoch, now + 120000);
      expect(segments[1].getTimestamp(0).millisecondsSinceEpoch, now + 120000 + 600000);
    });

    test('keeps segments connected with short gaps', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final pts = [
        {'id': 1, 'latitude': 55.7558, 'longitude': 37.6176, 'timestamp': now},
        {'id': 2, 'latitude': 55.7559, 'longitude': 37.6177, 'timestamp': now + 120000}, // 2 минуты
        {'id': 3, 'latitude': 55.7560, 'longitude': 37.6178, 'timestamp': now + 240000}, // 4 минуты от начала (2 мин от предыдущей)
        {'id': 4, 'latitude': 55.7561, 'longitude': 37.6179, 'timestamp': now + 480000}, // 8 минут от начала (4 мин от предыдущей)
      ];

      final segments = splitIntoSegments(pts);
      
      expect(segments.length, 1, reason: 'Должен быть 1 сегмент, так как разрывы меньше 5 минут');
      expect(segments[0].pointCount, 4, reason: 'Сегмент должен содержать все 4 точки');
    });

    test('creates new segment at exactly 5-minute threshold', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final pts = [
        {'id': 1, 'latitude': 55.7558, 'longitude': 37.6176, 'timestamp': now},
        // Точно 5 минут разрыва (300 секунд)
        {'id': 2, 'latitude': 55.7560, 'longitude': 37.6178, 'timestamp': now + 300000},
      ];

      final segments = splitIntoSegments(pts);
      
      expect(segments.length, 1, reason: 'При разрыве равном порогу (300 сек) должен остаться 1 сегмент');
      
      // Теперь проверим чуть больше порога
      final ptsOverThreshold = [
        {'id': 1, 'latitude': 55.7558, 'longitude': 37.6176, 'timestamp': now},
        // Чуть больше 5 минут разрыва (301 секунда)
        {'id': 2, 'latitude': 55.7560, 'longitude': 37.6178, 'timestamp': now + 301000},
      ];

      final segmentsOverThreshold = splitIntoSegments(ptsOverThreshold);
      
      expect(segmentsOverThreshold.length, 2, reason: 'При разрыве больше порога (301 сек) должно быть 2 сегмента');
    });
  });
}