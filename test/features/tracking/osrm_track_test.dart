import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'dart:io';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track_builder.dart';

void main() {
  test('CompactTrackFactory.fromOSRMResponse should create track from real JSON', () async {
    // Загружаем реальный JSON
    final jsonFile = File('lib/features/tracking/data/fixtures/current_day_track.json');
    expect(await jsonFile.exists(), isTrue, reason: 'JSON файл должен существовать');

    final jsonString = await jsonFile.readAsString();
    final osrmResponse = jsonDecode(jsonString) as Map<String, dynamic>;

    // Создаем трек
    final track = CompactTrackFactory.fromOSRMResponse(
      osrmResponse,
      startTime: DateTime.now(),
      baseSpeed: 45.0,
      baseAccuracy: 4.0,
    );

    // Проверяем результат
    expect(track.isEmpty, isFalse, reason: 'Трек не должен быть пустым');
    expect(track.pointCount, greaterThan(0), reason: 'Должны быть GPS точки');
    
    final distance = track.getTotalDistance();
    final duration = track.getDuration();
    
    // print('✅ GPS точек: ${track.pointCount}');
    // print('✅ Расстояние: ${(distance / 1000).toStringAsFixed(2)} км');
    // print('✅ Длительность: ${duration.inMinutes} минут');
    
    expect(distance, greaterThan(0), reason: 'Расстояние должно быть больше 0');
    expect(duration.inMinutes, greaterThan(0), reason: 'Длительность должна быть больше 0');
  });
}
