import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

enum UserRole {
  admin,
  manager,
  user,
}

class User {
  final int? id;
  final String externalId;
  final UserRole role;
  final PhoneNumber phoneNumber;
  final String hashedPassword;
  
  const User({
    this.id,
    required this.externalId,
    required this.role,
    required this.phoneNumber,
    required this.hashedPassword,
  });
  
  static Either<Failure, User> create({
    required String externalId,
    required UserRole role,
    required PhoneNumber phoneNumber,
    required String hashedPassword,
  }) {
    
    if (hashedPassword.trim().isEmpty) {
      return const Left(ValidationFailure('Hashed password cannot be empty'));
    }
        
    return Right(User(
      externalId: externalId,
      phoneNumber: phoneNumber,
      hashedPassword: hashedPassword.trim(),
      role: role
    ));
  }
  
  String get getId {
    return externalId;
  }
  
  bool verifyPassword(String hashedPassword) {
    if (hashedPassword.isEmpty) return false;
    return this.hashedPassword == hashedPassword;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.externalId == externalId &&
        other.phoneNumber == phoneNumber &&
        other.hashedPassword == hashedPassword;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      externalId,
      phoneNumber,
      hashedPassword,
    );
  }
  
  @override
  String toString() {
    return 'User(externalId: $externalId, phone: ${phoneNumber.displayFormat})';
  }
}
