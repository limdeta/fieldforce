import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/authentication/domain/services/password_service.dart';

void main() {
  group('PasswordService', () {
    test('should hash password and verify it correctly', () {
      const plainPassword = 'SecurePassword123!';

      final hashedPassword = PasswordService.hashPassword(plainPassword);
      final isValid = PasswordService.verifyPassword(plainPassword, hashedPassword);

      expect(hashedPassword, isNotEmpty);
      expect(hashedPassword.contains('\$'), true); // Should have separators
      expect(isValid, true);
    });

    test('should reject wrong password', () {
      const plainPassword = 'SecurePassword123!';
      const wrongPassword = 'WrongPassword456!';

      final hashedPassword = PasswordService.hashPassword(plainPassword);
      final isValid = PasswordService.verifyPassword(wrongPassword, hashedPassword);

      expect(isValid, false);
    });

    test('should generate different hashes for same password', () {
      const plainPassword = 'SamePassword';

      final hash1 = PasswordService.hashPassword(plainPassword);
      final hash2 = PasswordService.hashPassword(plainPassword);

      expect(hash1, isNot(equals(hash2)));
      expect(PasswordService.verifyPassword(plainPassword, hash1), true);
      expect(PasswordService.verifyPassword(plainPassword, hash2), true);
    });

    test('should handle invalid hash format gracefully', () {
      const plainPassword = 'password';
      const invalidHash = 'not_a_valid_hash';

      final isValid = PasswordService.verifyPassword(plainPassword, invalidHash);

      expect(isValid, false);
    });

    test('should handle empty password correctly', () {
      const emptyPassword = '';

      final hashedPassword = PasswordService.hashPassword(emptyPassword);
      final isValid = PasswordService.verifyPassword(emptyPassword, hashedPassword);

      expect(isValid, true);
    });
  });
}
