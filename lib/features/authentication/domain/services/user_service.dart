import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';
import 'package:fieldforce/features/authentication/domain/services/password_service.dart';

class UserService {
  final UserRepository _repository;

  UserService(this._repository);

  Future<User> createUser({
    required String externalId,
    required UserRole role,
    required String phone,
    required String rawPassword,
  }) async {
    final phoneResult = PhoneNumber.create(phone);
    if (phoneResult.isLeft()) {
      throw Exception('Не удалось создать номер телефона $phone: ${phoneResult.fold((l) => l, (r) => '')}');
    }
    final hashedPassword = PasswordService.hashPassword(rawPassword);
    final userResult = User.create(
      externalId: externalId,
      role: role,
      phoneNumber: phoneResult.fold((l) => throw Exception(l), (r) => r),
      hashedPassword: hashedPassword,
    );
    if (userResult.isLeft()) {
      throw Exception('Не удалось создать пользователя $externalId: ${userResult.fold((l) => l, (r) => '')}');
    }
    final user = userResult.fold((l) => throw Exception(l), (r) => r);
    final createResult = await _repository.createUser(user);
    if (createResult.isLeft()) {
      throw Exception('Не удалось сохранить пользователя $externalId: ${createResult.fold((l) => l, (r) => '')}');
    }
    return createResult.fold((l) => throw Exception(l), (r) => r);
  }

  Future<void> deleteUser(String externalId) async {
    final deleteResult = await _repository.deleteUser(externalId);
    if (deleteResult.isLeft()) {
      throw Exception('Не удалось удалить пользователя $externalId: ${deleteResult.fold((l) => l, (r) => '')}');
    }
  }

  Future<List<User>> getAllUsers() async {
    final allUsersResult = await _repository.getAllUsers();
    if (allUsersResult.isLeft()) {
      throw Exception('Не удалось получить список пользователей: ${allUsersResult.fold((l) => l, (r) => '')}');
    }
    return allUsersResult.fold((l) => throw Exception(l), (r) => r);
  }
}

class UserServiceFactory {
  static UserService create() {
    final repository = GetIt.instance<UserRepository>();
    return UserService(repository);
  }
}

