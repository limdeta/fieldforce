import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/app/providers/work_day_provider.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/app/domain/app_session.dart';
import 'package:fieldforce/app/domain/app_user.dart';
import 'package:fieldforce/app/domain/work_day.dart';
import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';

void main() {
  group('BDD: Торговый представитель видит свой рабочий день', () {
    
    testWidgets(
      'Given у меня есть маршрут на сегодня, When я проверяю WorkDay, Then я вижу правильный рабочий день',
      (tester) async {
        
        // Given: создаем тестового пользователя (минимальные моки)
        final testUser = User(
          id: 1,
          externalId: 'test_user_001',
          role: UserRole.user,
          phoneNumber: PhoneNumber('+79991112233'),
          hashedPassword: 'test_hash',
        );
        
        final testEmployee = Employee(
          id: 288,
          lastName: 'Тестовый',
          firstName: 'Пользователь', 
          role: EmployeeRole.sales,
        );
        
        final testAppUser = AppUser(
          authUser: testUser,
          employee: testEmployee,
        );
        
        final todayRoute = shop.Route(
          name: 'Текущий маршрут 3 сентября',
          description: 'Тестовый маршрут',
          createdAt: DateTime.now(),
          startTime: DateTime(2025, 9, 3, 9, 0),
          status: shop.RouteStatus.active,
          pointsOfInterest: [],
        );
        
        // When: устанавливаем сессию и создаем WorkDayProvider
        final userSessionResult = UserSession.create(
          user: testUser,
          rememberMe: false,
        );
        
        final userSession = userSessionResult.fold(
          (failure) => throw Exception('Не удалось создать UserSession: $failure'),
          (session) => session,
        );
        
        final appSession = AppSession(
          appUser: testAppUser,
          securitySession: userSession,
          createdAt: DateTime.now(),
        );
        
        AppSessionService.setCurrentSession(appSession);
        
        // Создаем WorkDayProvider и загружаем базовые данные (без dev фикстур)
        final workDayProvider = WorkDayProvider();
        await workDayProvider.loadWorkDays();
        
        // Then: проверяем что WorkDay создан правильно
        expect(workDayProvider.workDays, isNotEmpty, reason: 'WorkDays должны быть созданы');
        expect(workDayProvider.workDays.length, equals(3), reason: 'Должно быть 3 WorkDay: вчера, сегодня, завтра');
        
        final todayWorkDay = workDayProvider.todayWorkDay;
        expect(todayWorkDay, isNotNull, reason: 'Сегодняшний WorkDay должен существовать');
        expect(todayWorkDay!.isToday, isTrue, reason: 'isToday должно быть true');
        expect(todayWorkDay.userId, equals(testEmployee.id), reason: 'WorkDay должен принадлежать тестовому пользователю');
        expect(todayWorkDay.status, equals(WorkDayStatus.active), reason: 'Сегодняшний WorkDay должен быть активным');
        
        print('✅ BDD тест прошел: Торговый представитель правильно видит свой рабочий день');
        print('   - Пользователь: ${testAppUser.fullName} (ID: ${testEmployee.id})');
        print('   - Сегодняшний WorkDay создан и активен');
        print('   - Статус: ${todayWorkDay.status}');
        print('   - isToday: ${todayWorkDay.isToday}');
      },
    );
  });
}
