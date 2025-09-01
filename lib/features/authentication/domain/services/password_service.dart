import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Service for password hashing and verification
/// Uses PBKDF2 algorithm similar to Symfony's PasswordHasher
class PasswordService {
  static const int _iterations = 100000;
  static const int _saltLength = 32;
  
  /// Hashes a plain text password with salt
  /// Returns a string in format: hash$salt$iterations
  static String hashPassword(String plainPassword) {
    final salt = _generateSalt();
    final hash = _pbkdf2(plainPassword, salt, _iterations);
    return '${base64Encode(hash)}\$${base64Encode(salt)}\$$_iterations';
  }
  
  /// Verifies if plain password matches hashed password
  static bool verifyPassword(String plainPassword, String hashedPassword) {
    try {
      final parts = hashedPassword.split('\$');
      if (parts.length != 3) return false;
      
      final hash = base64Decode(parts[0]);
      final salt = base64Decode(parts[1]);
      final iterations = int.parse(parts[2]);
      
      final computedHash = _pbkdf2(plainPassword, salt, iterations);
      return _constantTimeEquals(hash, computedHash);
    } catch (e) {
      return false;
    }
  }
  
  static List<int> _generateSalt() {
    final random = Random.secure();
    return List.generate(_saltLength, (_) => random.nextInt(256));
  }
  
  /// PBKDF2 key derivation function
  static List<int> _pbkdf2(String password, List<int> salt, int iterations) {
    const keyLength = 32; // 256 bits
    final hmac = Hmac(sha256, utf8.encode(password));
    
    final blocks = <int>[];
    for (int i = 1; i <= (keyLength / 32).ceil(); i++) {
      final block = _pbkdf2Block(hmac, salt, iterations, i);
      blocks.addAll(block);
    }
    
    return blocks.take(keyLength).toList();
  }
  
  /// Single block of PBKDF2
  static List<int> _pbkdf2Block(Hmac hmac, List<int> salt, int iterations, int blockIndex) {
    // First iteration: HMAC(password, salt || blockIndex)
    final u = hmac.convert([...salt, ...utf8.encode(blockIndex.toString())]).bytes;
    var result = List<int>.from(u);
    
    // Subsequent iterations
    for (int i = 1; i < iterations; i++) {
      final ui = hmac.convert(result).bytes;
      for (int j = 0; j < result.length; j++) {
        result[j] ^= ui[j];
      }
    }
    
    return result;
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
