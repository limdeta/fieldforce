import '../../../../features/authentication/domain/entities/user.dart' as domain;
import '../../../../features/authentication/domain/value_objects/phone_number.dart';
import '../app_database.dart' as db;

class UserMapper {
  static domain.User fromDb(db.UserData dbUser) {
    final phoneResult = PhoneNumber.create(dbUser.phoneNumber);
    final phoneNumber = phoneResult.fold(
      (failure) => throw Exception('Invalid phone number in database: ${dbUser.phoneNumber}'),
      (phone) => phone,
    );

    return domain.User(
      id: dbUser.id,
      externalId: dbUser.externalId,
      role: _stringToUserRole(dbUser.role),
      phoneNumber: phoneNumber,
      hashedPassword: dbUser.hashedPassword,
    );
  }

  static db.UsersCompanion toDb(domain.User user) {
    return db.UsersCompanion.insert(
      externalId: user.externalId,
      role: userRoleToString(user.role),
      phoneNumber: user.phoneNumber.value,
      hashedPassword: user.hashedPassword,
    );
  }

  static domain.UserRole _stringToUserRole(String role) {
    return domain.UserRole.values.firstWhere(
      (r) => r.name == role,
      orElse: () => domain.UserRole.user,
    );
  }

  static String userRoleToString(domain.UserRole role) {
    return role.name;
  }
}
