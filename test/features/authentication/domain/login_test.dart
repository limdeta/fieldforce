import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';
import 'package:fieldforce/features/authentication/domain/usecases/login_usecase.dart';
import '../../../helpers/test_factories.dart';

void main() {
  group('LoginUseCase - Автоматические тесты', () {
    
    test('админ логин успешно', () async {
      final admin = await TestFactories.createAdminUser(
        phoneNumber: TestPhones.admin,
        externalId: 'auto_admin_test',
      );
      
      // Сохраняем
      await GetIt.instance<UserRepository>().saveUser(admin);
      
      // Тестируем
      final result = await GetIt.instance<LoginUseCase>()(
        phoneString: admin.phoneNumber.value,
        password: 'password123',
      );
      
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Ожидался успех: ${failure.message}'),
        (session) {
          expect(session.user.externalId, admin.externalId);
          expect(session.user.role, UserRole.admin);
        },
      );
    });
    
    test('менеджер логин успешно', () async {
      final manager = await TestFactories.createManagerUser(
        phoneNumber: TestPhones.manager,
        externalId: 'auto_manager_test',
      );
      
      await GetIt.instance<UserRepository>().saveUser(manager);
      
      final result = await GetIt.instance<LoginUseCase>()(
        phoneString: manager.phoneNumber.value,
        password: 'password123',
      );
      
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Ожидался успех: ${failure.message}'),
        (session) => expect(session.user.role, UserRole.manager),
      );
    });
    
    test('неверный пароль', () async {
      final user = await TestFactories.createAdminUser(
        phoneNumber: TestPhones.admin,
        externalId: 'auto_wrong_password_test',
      );
      
      await GetIt.instance<UserRepository>().saveUser(user);
      
      final result = await GetIt.instance<LoginUseCase>()(
        phoneString: user.phoneNumber.value,
        password: 'wrong_password',
      );
      
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('Неверный пароль')),
        (session) => fail('Ожидалась ошибка'),
      );
    });
    
    test('несуществующий пользователь', () async {
      final result = await GetIt.instance<LoginUseCase>()(
        phoneString: TestPhones.nonExistent,
        password: 'password123',
      );
      
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('не найден')),
        (session) => fail('Ожидалась ошибка'),
      );
    });
    
    test('множественные пользователи', () async {
      final users = await TestFactories.createUserBatch(
        adminCount: 2,
        managerCount: 1,
        salesRepCount: 2,
      );
      
      // Сохраняем всех
      final userRepo = GetIt.instance<UserRepository>();
      for (final user in users) {
        await userRepo.saveUser(user);
      }
      
      // Тестируем первого админа
      final firstAdmin = users.where((u) => u.role == UserRole.admin).first;
      final result = await GetIt.instance<LoginUseCase>()(
        phoneString: firstAdmin.phoneNumber.value,
        password: 'password123',
      );
      
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Ожидался успех: ${failure.message}'),
        (session) => expect(session.user.role, UserRole.admin),
      );
    });
    
    test('кастомные данные', () async {
      final customUser = await TestFactories.createManagerUser(
        phoneNumber: '+79991234567',
        externalId: 'auto_custom_test',
        password: 'custom_password_456',
      );
      
      await GetIt.instance<UserRepository>().saveUser(customUser);
      
      final result = await GetIt.instance<LoginUseCase>()(
        phoneString: customUser.phoneNumber.value,
        password: 'custom_password_456',
      );
      
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Ожидался успех: ${failure.message}'),
        (session) => expect(session.user.role, UserRole.manager),
      );
    });
  });
}
