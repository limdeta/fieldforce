import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

// App imports
import 'package:fieldforce/app/service_locator.dart';
import 'package:fieldforce/app/fixtures/dev_fixture_orchestrator.dart';
import 'package:fieldforce/app/providers/work_day_provider.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/app/domain/app_user.dart';
import 'package:fieldforce/app/domain/app_session.dart';
import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';

void main() {
  group('BDD: Пользователь заходит на главную страницу', () {
    late DevAppUsers devAppUsers;
    late AppUser salesRepAppUser;
    late WorkDayProvider workDayProvider;

    /// GIVEN: У меня есть пользователь с реальными dev данными
    setUpAll(() async {
      print('🚀 BDD Setup: Создаем dev данные...');
      
      // Очищаем GetIt перед тестом
      await GetIt.instance.reset();
      
      // Инициализируем сервисы как в реальном приложении
      await setupServiceLocator();
      
      // Создаем ТОЧНО те же данные что и в dev режиме
      final orchestrator = DevFixtureOrchestratorFactory.create();
      final devData = await orchestrator.createFullDevDataset();
      
      devAppUsers = devData.appUsers;
      salesRepAppUser = devAppUsers.salesReps.first; // Employee ID 288
      
      print('✅ BDD Setup: Пользователь создан - ${salesRepAppUser.fullName} (ID: ${salesRepAppUser.employee.id})');
      
      // Создаем тестовую сессию
      final userSession = UserSession(
        externalId: salesRepAppUser.authUser.externalId,
        loginTime: DateTime.now(),
        rememberMe: false,
        permissions: ['sales_rep'],
      );
      
      final appSession = AppSession(
        appUser: salesRepAppUser,
        securitySession: userSession,
        createdAt: DateTime.now(),
      );
      
      // Устанавливаем сессию как в реальном приложении
      AppSessionService.setCurrentSession(appSession);
      print('✅ BDD Setup: Сессия установлена');
    });

    tearDownAll(() async {
      await GetIt.instance.reset();
    });

    testWidgets(
      'WHEN я захожу на главную страницу THEN WorkDayProvider загружает мои рабочие дни',
      (WidgetTester tester) async {
        
        // GIVEN: Данные уже созданы в setUpAll
        expect(salesRepAppUser.employee.id, equals(288)); // Проверяем что это тот же пользователь что в dev
        
        // WHEN: Создаем WorkDayProvider как на главной странице
        workDayProvider = WorkDayProvider();
        await workDayProvider.loadWorkDays();
        
        // THEN: WorkDayProvider загрузил рабочие дни
        expect(workDayProvider.workDays.length, greaterThan(0), 
          reason: 'Должны быть загружены рабочие дни');
        
        // AND: Есть сегодняшний WorkDay
        final todayWorkDay = workDayProvider.todayWorkDay;
        expect(todayWorkDay, isNotNull, 
          reason: 'Должен быть WorkDay на сегодня');
        
        // AND: Сегодняшний WorkDay принадлежит правильному пользователю
        expect(todayWorkDay!.userId, equals(salesRepAppUser.employee.id),
          reason: 'WorkDay должен принадлежать текущему пользователю');
        
        // AND: Сегодняшний WorkDay имеет статус "активный"
        expect(todayWorkDay.status.name, equals('active'),
          reason: 'Сегодняшний WorkDay должен быть активным');
        
        print('✅ BDD Test: WorkDayProvider корректно загрузил ${workDayProvider.workDays.length} рабочих дней');
        print('✅ BDD Test: Сегодняшний WorkDay найден - статус: ${todayWorkDay.status.name}');
      },
    );
  });
}
