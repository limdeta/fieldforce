import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/employee_repository.dart';
import 'package:logging/logging.dart';

class TradingPointsFixtureService {
  static final Logger _logger = Logger('TradingPointsFixtureService');
  Future<List<TradingPoint>> createBaseTradingPoints() async {
    final points = [
      // Совпадает с ответом синхронизации торговых точек
      TradingPoint(
        externalId: '0002300707_11',
        name: 'Магадан',
        inn: '_____2300707',
        region: 'M3V',
        latitude: 43.144173,
        longitude: 131.9266,
      ),
      TradingPoint(
        externalId: '0002300707_9',
        name: 'Камчатка',
        inn: '_____2300707',
        region: 'K3V',
        latitude: 53.0370074,
        longitude: 158.65595,
      ),
      TradingPoint(
        externalId: '0002300707_8',
        name: 'Днепровская',
        inn: '_____2300707',
        region: 'P3V',
        latitude: 43.144173,
        longitude: 131.9266,
      ),
    ];
    
    // Сохраняем все точки в базу данных
    for (final point in points) {
      await _saveTradingPoint(point);
    }

    _logger.info("✅ Создано ${points.length} торговых точек");
    return points;
  }
  
  /// Привязывает все торговые точки из маршрутов к первому найденному сотруднику
  Future<void> assignTradingPointsToEmployee(Employee user) async {
    try {
      // Получаем первого сотрудника из базы
      final employeeRepository = GetIt.instance<EmployeeRepository>();
      final employeeResult = await employeeRepository.getById(user.id);
      final employee = employeeResult.fold(
        (failure) => throw("Пользователь для привязки точек не найден"),
        (employees) => employees,
      );

      final tradingPoints = await createBaseTradingPoints();
      
      // Получаем репозиторий торговых точек
      final tradingPointRepository = GetIt.instance<TradingPointRepository>();
      
      // Привязываем все торговые точки к сотруднику
      int successCount = 0;
      for (final tradingPoint in tradingPoints) {
        final result = await tradingPointRepository.assignToEmployee(tradingPoint, employee);
        result.fold(
          (failure) => _logger.warning('⚠️ Не удалось привязать ${tradingPoint.name}: ${failure.message}'),
          (_) => successCount++,
        );
      }
      
      _logger.info('✅ Привязано $successCount из ${tradingPoints.length} торговых точек к сотруднику ${employee.fullName}');
      
    } catch (e) {
      _logger.severe('❌ Ошибка при привязке торговых точек: $e');
    }
  }

  /// Получает торговую точку по external_id
  TradingPoint getTradingPointById(String externalId, List<TradingPoint> points) {
    final point = points.where((p) => p.externalId == externalId).firstOrNull;
    if (point == null) {
      throw Exception('Торговая точка с ID $externalId не найдена');
    }
    return point;
  }
  
  /// Приватный метод для сохранения торговой точки
  Future<void> _saveTradingPoint(TradingPoint point) async {
    final database = GetIt.instance<AppDatabase>();
    final companion = TradingPointEntitiesCompanion.insert(
      externalId: point.externalId,
      name: point.name,
      inn: point.inn != null ? Value(point.inn!) : const Value.absent(),
      region: Value(point.region),
      latitude: point.latitude != null
          ? Value(point.latitude!)
          : const Value.absent(),
      longitude: point.longitude != null
          ? Value(point.longitude!)
          : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );
    await database.upsertTradingPoint(companion);
  }
}

/// Factory для создания TradingPointsFixtureService  
class TradingPointsFixtureServiceFactory {
  static TradingPointsFixtureService create() {
    return TradingPointsFixtureService();
  }
}
