import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_employee_trading_points_usecase.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/employee_repository.dart';
import '../../helpers/test_factories.dart';

void main() {
  group('Employee TradingPoints Integration Tests', () {
    late TradingPointRepository tradingPointRepository;
    late EmployeeRepository employeeRepository;
    late GetEmployeeTradingPointsUseCase useCase;

    setUp(() {
      // Используем автоматически зарегистрированные зависимости
      tradingPointRepository = GetIt.instance<TradingPointRepository>();
      employeeRepository = GetIt.instance<EmployeeRepository>();
      useCase = GetEmployeeTradingPointsUseCase(tradingPointRepository);
    });

    test('should get trading points for employee', () async {
      // Создаем тестовый сценарий с сотрудником и торговыми точками
      final scenario = TestFactories.createEmployeeWithTradingPointsScenario(
        employeeLastName: 'Тестов',
        employeeFirstName: 'Сотрудник',
        tradingPointsCount: 3,
      );

      final employee = scenario['employee'];
      final tradingPoints = scenario['tradingPoints'] as List;

      // Сначала сохраняем сотрудника в базу
      final createResult = await employeeRepository.create(employee);
      
      // Получаем сотрудника с присвоенным ID
      late final Employee savedEmployee;
      createResult.fold(
        (failure) => fail('Failed to create employee: ${failure.message}'),
        (emp) => savedEmployee = emp,
      );

      // Затем привязываем торговые точки к сотруднику
      for (final tradingPoint in tradingPoints) {
        final assignResult = await tradingPointRepository.assignToEmployee(tradingPoint, savedEmployee);
        assignResult.fold(
          (failure) => fail('Error assigning ${tradingPoint.name}: ${failure.message}'),
          (_) {}, // Успешно привязано
        );
      }

      // Получаем торговые точки сотрудника
      final result = await useCase.call(savedEmployee);
      // Проверяем результат
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Ожидался успех: ${failure.message}'),
        (tradingPointsList) {
          expect(tradingPointsList.length, 3);
          expect(tradingPointsList.first.name, contains('Магазин'));
        },
      );
    });

    test('should filter trading points by name', () async {
      // Создаем тестовый сценарий
      final scenario = TestFactories.createEmployeeWithTradingPointsScenario(
        tradingPointsCount: 5,
      );

      final employee = scenario['employee'];
      final tradingPoints = scenario['tradingPoints'] as List;

      // Сохраняем сотрудника и торговые точки в базу
      final createResult = await employeeRepository.create(employee);
      late final Employee savedEmployee;
      createResult.fold(
        (failure) => fail('Failed to create employee: ${failure.message}'),
        (emp) => savedEmployee = emp,
      );

      for (final tradingPoint in tradingPoints) {
        final assignResult = await tradingPointRepository.assignToEmployee(tradingPoint, savedEmployee);
        assignResult.fold(
          (failure) => fail('Error assigning ${tradingPoint.name}: ${failure.message}'),
          (_) {}, // Успешно привязано
        );
      }

      // Фильтруем по названию
      final result = await useCase.callWithFilter(savedEmployee, nameFilter: '№1');

      // Проверяем результат
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Ожидался успех: ${failure.message}'),
        (filteredList) {
          expect(filteredList.length, 1);
          expect(filteredList.first.name, contains('№1'));
        },
      );
    });

    test('should return empty list for employee without trading points', () async {
      // Создаем сотрудника без торговых точек
      final employee = TestFactories.createEmployeeWithTradingPoints(
        tradingPointsCount: 0,
      );

      // Сохраняем сотрудника в базу
      final createResult = await employeeRepository.create(employee);
      late final Employee savedEmployee;
      createResult.fold(
        (failure) => fail('Failed to create employee: ${failure.message}'),
        (emp) => savedEmployee = emp,
      );

      // Получаем торговые точки
      final result = await useCase.call(savedEmployee);

      // Проверяем результат
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Ожидался успех: ${failure.message}'),
        (tradingPointsList) {
          expect(tradingPointsList.isEmpty, true);
        },
      );
    });
  });
}
