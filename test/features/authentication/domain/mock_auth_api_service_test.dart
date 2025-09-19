import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/authentication/domain/services/mock_auth_api_service.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';

void main() {
  group('MockAuthApiService', () {
    late MockAuthApiService service;

    setUp(() {
      service = MockAuthApiService();
    });

    test('should authenticate with valid credentials', () async {
      final phoneResult = PhoneNumber.create('+79991112233');
      expect(phoneResult.isRight(), true);

      final phoneNumber = phoneResult.fold((l) => null, (r) => r)!;
      const password = 'password123';

      final result = await service.authenticate(phoneNumber, password);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (authResult) {
          expect(authResult.isAuthenticated, true);
          expect(authResult.errorMessage, isNull);
        },
      );
    });

    test('should reject invalid credentials', () async {
      final phoneResult = PhoneNumber.create('+79991119999');
      expect(phoneResult.isRight(), true);

      final phoneNumber = phoneResult.fold((l) => null, (r) => r)!;
      const password = 'wrongpassword';

      final result = await service.authenticate(phoneNumber, password);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (authResult) {
          expect(authResult.isAuthenticated, false);
          expect(authResult.errorMessage, isNotNull);
          expect(authResult.errorMessage, 'Неверный телефон или пароль');
        },
      );
    });

    test('should handle blocked user', () async {
      final phoneResult = PhoneNumber.create('+79991110000');
      expect(phoneResult.isRight(), true);

      final phoneNumber = phoneResult.fold((l) => null, (r) => r)!;
      const password = 'password123';

      final result = await service.authenticate(phoneNumber, password);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (authResult) {
          expect(authResult.isAuthenticated, false);
          expect(authResult.errorMessage, 'Пользователь заблокирован');
        },
      );
    });

    test('should handle too many attempts', () async {
      final phoneResult = PhoneNumber.create('+79991111111');
      expect(phoneResult.isRight(), true);

      final phoneNumber = phoneResult.fold((l) => null, (r) => r)!;
      const password = 'password123';

      final result = await service.authenticate(phoneNumber, password);

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not fail'),
        (authResult) {
          expect(authResult.isAuthenticated, false);
          expect(authResult.errorMessage, 'Слишком много попыток входа');
        },
      );
    });

    test('should handle multiple valid credentials', () async {
      final testCases = [
        {'phone': '+79991112233', 'password': 'password123'},
        {'phone': '+79991113344', 'password': 'admin123'},
        {'phone': '+79991114455', 'password': 'manager123'},
      ];

      for (final testCase in testCases) {
        final phoneResult = PhoneNumber.create(testCase['phone']!);
        expect(phoneResult.isRight(), true);

        final phoneNumber = phoneResult.fold((l) => null, (r) => r)!;
        final password = testCase['password']!;

        final result = await service.authenticate(phoneNumber, password);

        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Should not fail for ${testCase['phone']}'),
          (authResult) {
            expect(authResult.isAuthenticated, true,
                reason: 'Failed for ${testCase['phone']}');
          },
        );
      }
    });
  });
}