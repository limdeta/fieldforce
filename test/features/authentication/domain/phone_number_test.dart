import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';

void main() {
  group('PhoneNumber', () {
    test('should create valid phone number with Russian format', () {
      const phoneString = '+79123456789';

      final result = PhoneNumber.create(phoneString);

      expect(result.isRight(), true);
      expect(result.fold((l) => null, (r) => r.value), phoneString);
    });

    test('should create valid phone number with 8 prefix', () {
      const phoneString = '89123456789';

      final result = PhoneNumber.create(phoneString);

      expect(result.isRight(), true);
      expect(result.fold((l) => null, (r) => r.value), '+79123456789');
    });

    test('should reject invalid phone number', () {
      const invalidPhone = '123';

      final result = PhoneNumber.create(invalidPhone);

      expect(result.isLeft(), true);
      expect(
        result.fold((l) => l.message, (r) => null),
        contains('Invalid phone number format'),
      );
    });

    test('should reject empty phone number', () {
      const emptyPhone = '';

      final result = PhoneNumber.create(emptyPhone);

      expect(result.isLeft(), true);
    });

    test('should format phone number for display', () {
      const phoneString = '+79123456789';
      final phoneNumber = PhoneNumber.create(phoneString).getOrElse(() => throw Exception());

      final formatted = phoneNumber.displayFormat;

      expect(formatted, '+7 (912) 345-67-89');
    });
  });
}
