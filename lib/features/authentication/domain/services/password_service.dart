import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:argon2/argon2.dart';

/// Service for password hashing and verification
/// Uses Argon2 algorithm for secure password hashing
class PasswordService {
  static const int _iterations = 4; // Time cost
  static const int _memoryPowerOf2 = 16; // 2^16 = 65536 KiB (64 MiB)
  static const int _parallelism = 2; // Parallelism factor
  static const int _hashLength = 32; // Hash length in bytes
  static const int _saltLength = 16; // Salt length in bytes

  /// Hashes a plain text password with Argon2
  /// Returns a string in format: $argon2i$v=19$m=65536,t=4,p=2$salt$hash
  static String hashPassword(String plainPassword) {
    final salt = _generateSalt();
    final parameters = Argon2Parameters(
      Argon2Parameters.ARGON2_i,
      Uint8List.fromList(salt),
      version: Argon2Parameters.ARGON2_VERSION_10,
      iterations: _iterations,
      memoryPowerOf2: _memoryPowerOf2,
    );

    final argon2 = Argon2BytesGenerator();
    argon2.init(parameters);

    final passwordBytes = parameters.converter.convert(plainPassword);
    final result = Uint8List(_hashLength);
    argon2.generateBytes(passwordBytes, result, 0, result.length);

    final saltBase64 = base64Encode(salt);
    final hashBase64 = base64Encode(result);

    return '\$argon2i\$v=19\$m=${1 << _memoryPowerOf2},t=$_iterations,p=$_parallelism\$$saltBase64\$$hashBase64';
  }

  /// Verifies if plain password matches hashed password
  static bool verifyPassword(String plainPassword, String hashedPassword) {
    try {
      final parts = hashedPassword.split('\$');
      if (parts.length != 6 || parts[1] != 'argon2i') {
        return false;
      }

      final salt = base64Decode(parts[4]);
      final expectedHash = base64Decode(parts[5]);

      final parameters = Argon2Parameters(
        Argon2Parameters.ARGON2_i,
        Uint8List.fromList(salt),
        version: Argon2Parameters.ARGON2_VERSION_10,
        iterations: _iterations,
        memoryPowerOf2: _memoryPowerOf2,
      );

      final argon2 = Argon2BytesGenerator();
      argon2.init(parameters);

      final passwordBytes = parameters.converter.convert(plainPassword);
      final computedHash = Uint8List(_hashLength);
      argon2.generateBytes(passwordBytes, computedHash, 0, computedHash.length);

      return _constantTimeEquals(expectedHash, computedHash);
    } catch (e) {
      return false;
    }
  }

  static List<int> _generateSalt() {
    final random = Random.secure();
    return List.generate(_saltLength, (_) => random.nextInt(256));
  }

  /// Constant-time comparison to prevent timing attacks
  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }

    return result == 0;
  }
}
