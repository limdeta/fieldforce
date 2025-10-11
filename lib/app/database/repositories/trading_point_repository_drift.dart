import 'package:get_it/get_it.dart';
import 'package:drift/drift.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/app/database/app_database.dart';
import '../../../features/shop/domain/entities/trading_point.dart';
import '../../../features/shop/domain/entities/employee.dart';
import '../../../features/shop/domain/repositories/trading_point_repository.dart';

/// Drift реализация репозитория торговых точек
class DriftTradingPointRepository implements TradingPointRepository {
  final AppDatabase _database = GetIt.instance<AppDatabase>();

  @override
  Future<Either<Failure, List<TradingPoint>>> getEmployeePoints(Employee employee) async {
    try {
      final assignments = await (_database.select(_database.employeeTradingPointAssignments)
        ..where((tbl) => tbl.employeeId.equals(employee.id))
      ).get();
      if (assignments.isEmpty) {
        return const Right([]);
      }

      final tradingPointIds = assignments.map((a) => a.tradingPointExternalId).toList();

      // Получаем сами торговые точки
      final tradingPointEntities = await (_database.select(_database.tradingPointEntities)
        ..where((tbl) => tbl.externalId.isIn(tradingPointIds))
      ).get();

    final tradingPoints = tradingPointEntities
      .map(_mapEntityToDomain)
          .toList();
      return Right(tradingPoints);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения торговых точек сотрудника: $e'));
    }
  }

  @override
  Future<Either<Failure, TradingPoint?>> getByExternalId(String externalId) async {
    try {
      final entity = await (_database.select(_database.tradingPointEntities)
        ..where((tbl) => tbl.externalId.equals(externalId))
      ).getSingleOrNull();

      if (entity == null) {
        return const Right(null);
      }

  final tradingPoint = _mapEntityToDomain(entity);

      return Right(tradingPoint);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения торговой точки: $e'));
    }
  }

  @override
  Future<Either<Failure, TradingPoint?>> getById(int id) async {
    try {
      final entity = await (_database.select(_database.tradingPointEntities)
        ..where((tbl) => tbl.id.equals(id))
      ).getSingleOrNull();

      if (entity == null) {
        return const Right(null);
      }

  final tradingPoint = _mapEntityToDomain(entity);

      return Right(tradingPoint);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения торговой точки по ID: $e'));
    }
  }

  @override
  Future<Either<Failure, TradingPoint>> save(TradingPoint tradingPoint) async {
    try {
      final companion = TradingPointEntitiesCompanion.insert(
        externalId: tradingPoint.externalId,
        name: tradingPoint.name,
        inn: tradingPoint.inn != null ? Value(tradingPoint.inn!) : const Value.absent(),
          region: Value(tradingPoint.region),
        updatedAt: Value(DateTime.now()),
      );

      await _database.upsertTradingPoint(companion);

      // Получаем обновленную торговую точку
      final result = await getByExternalId(tradingPoint.externalId);
      return result.fold(
        (failure) => Left(failure),
        (tp) => tp != null 
          ? Right(tp) 
          : Left(const DatabaseFailure('Торговая точка не найдена после сохранения')),
      );
    } catch (e) {
      return Left(DatabaseFailure('Ошибка сохранения торговой точки: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> assignToEmployee(
    TradingPoint tradingPoint, 
    Employee employee
  ) async {
    try {
      // Сначала сохраняем торговую точку если её нет
      await save(tradingPoint);

      // Затем создаем привязку
      await _database.into(_database.employeeTradingPointAssignments).insertOnConflictUpdate(
        EmployeeTradingPointAssignmentsCompanion.insert(
          employeeId: employee.id,
          tradingPointExternalId: tradingPoint.externalId,
        ),
      );

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка привязки торговой точки к сотруднику: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> unassignFromEmployee(
    TradingPoint tradingPoint, 
    Employee employee
  ) async {
    try {
      await (_database.delete(_database.employeeTradingPointAssignments)
        ..where((tbl) => 
          tbl.employeeId.equals(employee.id) & 
          tbl.tradingPointExternalId.equals(tradingPoint.externalId)
        )
      ).go();

      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка отвязки торговой точки от сотрудника: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TradingPoint>>> getAll() async {
    try {
      final entities = await _database.select(_database.tradingPointEntities).get();

  final tradingPoints = entities.map(_mapEntityToDomain).toList();

      return Right(tradingPoints);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения всех торговых точек: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TradingPoint>>> searchByName(String query) async {
    try {
      final entities = await (_database.select(_database.tradingPointEntities)
        ..where((tbl) => tbl.name.like('%$query%'))
      ).get();

  final tradingPoints = entities.map(_mapEntityToDomain).toList();

      return Right(tradingPoints);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка поиска торговых точек: $e'));
    }
  }
  TradingPoint _mapEntityToDomain(TradingPointEntity entity) {
    final region = entity.region;
    if (region == null || region.trim().isEmpty) {
      throw StateError('Trading point ${entity.externalId} saved without region');
    }

    return TradingPoint(
      id: entity.id,
      externalId: entity.externalId,
      name: entity.name,
      inn: entity.inn,
      region: region,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
