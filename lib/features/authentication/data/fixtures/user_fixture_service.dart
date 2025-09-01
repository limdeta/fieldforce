import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';
import 'package:fieldforce/features/authentication/domain/services/password_service.dart';

class UserFixtureService {
  final UserRepository _repository;
  
  UserFixtureService(this._repository);

  /// Создает администратора
  /// Логин: +7-999-000-0001, Пароль: password123
  Future<User> createAdmin() async {
    print('🔍 Создание Admin...');
    
    final phoneResult = PhoneNumber.create('+7-999-000-0001');
    if (phoneResult.isLeft()) {
      throw Exception('Не удалось создать номер телефона для администратора');
    }
    
    // Проверяем, не существует ли уже такой пользователь
    final phone = phoneResult.fold((l) => throw Exception(l), (r) => r);
    final existingResult = await _repository.getUserByPhoneNumber(phone);
    if (existingResult.isRight()) {
      final existing = existingResult.fold((l) => null, (r) => r);
      if (existing != null) {
        print('⚠️ Admin уже существует, возвращаем существующего');
        return existing;
      }
    }
    
    final userResult = User.create(
      externalId: 'admin_001',
      role: UserRole.admin,
      phoneNumber: phone,
      hashedPassword: PasswordService.hashPassword('password123'),
    );
    
    if (userResult.isLeft()) {
      throw Exception('Не удалось создать администратора: ${userResult.fold((l) => l, (r) => '')}');
    }
    
    final admin = userResult.fold((l) => throw Exception(l), (r) => r);
    final createResult = await _repository.createUser(admin);
    
    if (createResult.isLeft()) {
      throw Exception('Не удалось сохранить администратора: ${createResult.fold((l) => l, (r) => '')}');
    }
    
    // Возвращаем сохраненного пользователя с ID, а не исходный объект
    final savedUser = createResult.fold((l) => throw Exception(l), (r) => r);
    print('✅ Admin создан с ID: ${savedUser.id}');
    return savedUser;
  }

  /// Создает менеджера
  /// Логин: +7-999-000-0002, Пароль: password123
  Future<User> createManager() async {
    final phoneResult = PhoneNumber.create('+7-999-000-0002');
    if (phoneResult.isLeft()) {
      throw Exception('Не удалось создать номер телефона для менеджера');
    }
    
    final userResult = User.create(
      externalId: 'manager_001',
      role: UserRole.manager,
      phoneNumber: phoneResult.fold((l) => throw Exception(l), (r) => r),
      hashedPassword: PasswordService.hashPassword('password123'),
    );
    
    if (userResult.isLeft()) {
      throw Exception('Не удалось создать менеджера: ${userResult.fold((l) => l, (r) => '')}');
    }
    
    final manager = userResult.fold((l) => throw Exception(l), (r) => r);
    final createResult = await _repository.createUser(manager);
    
    if (createResult.isLeft()) {
      throw Exception('Не удалось сохранить менеджера: ${createResult.fold((l) => l, (r) => '')}');
    }
    
    // Возвращаем сохраненного пользователя с ID, а не исходный объект
    return createResult.fold((l) => throw Exception(l), (r) => r);
  }

  /// Создает торгового представителя с заданными параметрами
  /// Пароль для всех торговых представителей: password123
  Future<User> createSalesRep({
    required String name,
    required String email, // для externalId
    required String phone,
  }) async {
    final phoneResult = PhoneNumber.create(phone);
    if (phoneResult.isLeft()) {
      throw Exception('Не удалось создать номер телефона $phone: ${phoneResult.fold((l) => l, (r) => '')}');
    }
    
    final userResult = User.create(
      externalId: email, // Используем email как externalId
      role: UserRole.user,
      phoneNumber: phoneResult.fold((l) => throw Exception(l), (r) => r),
      hashedPassword: PasswordService.hashPassword('password123'),
    );
    
    if (userResult.isLeft()) {
      throw Exception('Не удалось создать торгового представителя $name: ${userResult.fold((l) => l, (r) => '')}');
    }
    
    final salesRep = userResult.fold((l) => throw Exception(l), (r) => r);
    final createResult = await _repository.createUser(salesRep);
    
    if (createResult.isLeft()) {
      throw Exception('Не удалось сохранить торгового представителя $name: ${createResult.fold((l) => l, (r) => '')}');
    }
    
    // Возвращаем сохраненного пользователя с ID, а не исходный объект
    return createResult.fold((l) => throw Exception(l), (r) => r);
  }

  Future<void> clearAllUsers() async {
    try {
      final allUsersResult = await _repository.getAllUsers();
      
      await allUsersResult.fold(
        (failure) async {
          print('ℹ️ Не удалось получить список пользователей: ${failure.message}');
        },
        (allUsers) async {
          for (final user in allUsers) {
            // Удаляем пользователей с dev префиксами или email
            if (_isDevUser(user)) {
              final deleteResult = await _repository.deleteUser(user.externalId);
              deleteResult.fold(
                (failure) => print('⚠️ Не удалось удалить ${user.id}: ${failure.message}'),
                (_) => {}, // Успешно удален
              );
            }
          }
          
          print('🧹 Dev пользователи очищены');
        },
      );
    } catch (e) {
      print('ℹ️ Ошибка при очистке пользователей: $e');
    }
  }

  bool _isDevUser(User user) {
    return user.externalId.startsWith('admin_') ||
           user.externalId.startsWith('manager_') ||
           user.externalId.contains('@fieldforce.dev');
  }
}

class UserFixtureServiceFactory {
  static UserFixtureService create() {
    final repository = GetIt.instance<UserRepository>();
    return UserFixtureService(repository);
  }
}
