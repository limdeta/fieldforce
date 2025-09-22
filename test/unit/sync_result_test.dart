import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/shared/models/sync_result.dart';

void main() {
  group('SyncResult', () {
    test('withErrors сохраняет ошибки', () {
      final errors = ['Ошибка 1', 'Ошибка 2', 'Ошибка 3'];
      final result = SyncResult.withErrors(
        type: 'test',
        successCount: 5,
        errorCount: 2,
        errors: errors,
        duration: const Duration(seconds: 10),
        startTime: DateTime.now(),
      );

      expect(result.successCount, 5);
      expect(result.errorCount, 2);
      expect(result.errors, errors);
      expect(result.hasErrors, true);
      expect(result.isSuccessful, false);
    });

    test('withErrors ограничивает количество ошибок до 10', () {
      final manyErrors = List.generate(15, (i) => 'Ошибка $i');
      final result = SyncResult.withErrors(
        type: 'test',
        successCount: 0,
        errorCount: 15,
        errors: manyErrors,
        duration: const Duration(seconds: 10),
        startTime: DateTime.now(),
      );

      expect(result.errors.length, 10);
      expect(result.errors.first, 'Ошибка 0');
      expect(result.errors.last, 'Ошибка 9');
    });
  });
}