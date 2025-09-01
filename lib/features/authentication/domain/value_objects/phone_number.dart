import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/shared/either.dart';

class PhoneNumber {
  final String value;
  
  const PhoneNumber._(this.value);

  static Either<Failure, PhoneNumber> create(String phone) {
    if (phone.isEmpty) {
      return const Left(ValidationFailure('Phone number cannot be empty'));
    }
    
    // Remove all non-digit characters except +
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Convert 8 prefix to +7
    String normalized;
    if (cleaned.startsWith('8') && cleaned.length == 11) {
      normalized = '+7${cleaned.substring(1)}';
    } else if (cleaned.startsWith('+7') && cleaned.length == 12) {
      normalized = cleaned;
    } else if (cleaned.startsWith('7') && cleaned.length == 11) {
      normalized = '+$cleaned';
    } else {
      return const Left(ValidationFailure('Invalid phone number format. Expected Russian phone number.'));
    }
    
    final phoneRegex = RegExp(r'^\+7\d{10}$');
    if (!phoneRegex.hasMatch(normalized)) {
      return const Left(ValidationFailure('Invalid phone number format. Expected Russian phone number.'));
    }
    
    return Right(PhoneNumber._(normalized));
  }
  
  /// Returns formatted phone number for display: +7 (912) 345-67-89
  String get displayFormat {
    if (value.length != 12) return value;
    
    final digits = value.substring(2); // Remove +7
    return '+7 (${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, 8)}-${digits.substring(8, 10)}';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PhoneNumber && other.value == value;
  }
  
  @override
  int get hashCode => value.hashCode;
  
  @override
  String toString() => value;
}
