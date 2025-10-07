import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';

void main() {
  group('User', () {
    test('should create valid user with all fields', () {
      final phoneNumber = PhoneNumber.create('+79123456789').getOrElse(() => throw Exception());

      final result = User.create(
        externalId: 'ext_123',
        role: UserRole.user,
        phoneNumber: phoneNumber,
        hashedPassword: 'hashed_password_123',
      );

      expect(result.isRight(), true);
      result.getOrElse(() => throw Exception());
    });

    test('should verify password correctly', () {
      final phoneNumber = PhoneNumber.create('+79123456789').getOrElse(() => throw Exception());
      final user = User.create(
        externalId: 'ext_123',
        role: UserRole.user,
        phoneNumber: phoneNumber,
        hashedPassword: 'correct_hash',
      ).getOrElse(() => throw Exception());

      expect(user.verifyPassword('correct_hash'), true);
      expect(user.verifyPassword('wrong_hash'), false);
      expect(user.verifyPassword(''), false);
    });
  });
}
