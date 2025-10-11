import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/mappers/warehouse_mapper.dart';
import 'package:fieldforce/features/shop/domain/entities/warehouse.dart';
import 'package:fieldforce/features/shop/domain/repositories/warehouse_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

class DriftWarehouseRepository implements WarehouseRepository {
  static final Logger _logger = Logger('DriftWarehouseRepository');
  final AppDatabase _database = GetIt.instance<AppDatabase>();

  @override
  Future<Either<Failure, void>> clearWarehouses() async {
    try {
      await _database.delete(_database.warehouses).go();
      _logger.info('🧹 Очищены все склады');
      return const Right(null);
    } catch (e, st) {
      _logger.severe('Ошибка очистки складов', e, st);
      return Left(DatabaseFailure('Ошибка очистки складов: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearWarehousesByRegion(String regionCode) async {
    try {
      await (_database.delete(_database.warehouses)
            ..where((tbl) => tbl.regionCode.equals(regionCode)))
          .go();
      _logger.info('🧹 Очищены склады региона $regionCode');
      return const Right(null);
    } catch (e, st) {
      _logger.severe('Ошибка очистки складов региона $regionCode', e, st);
      return Left(DatabaseFailure('Ошибка очистки складов: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Warehouse>>> getAllWarehouses() async {
    try {
      final rows = await _database.select(_database.warehouses).get();
      return Right(WarehouseMapper.fromDataList(rows));
    } catch (e, st) {
      _logger.severe('Ошибка получения складов', e, st);
      return Left(DatabaseFailure('Ошибка получения складов: $e'));
    }
  }

  @override
  Future<Either<Failure, Warehouse?>> getWarehouseById(int id) async {
    try {
      final query = _database.select(_database.warehouses)
        ..where((tbl) => tbl.id.equals(id));
      final row = await query.getSingleOrNull();
      return Right(row != null ? WarehouseMapper.fromData(row) : null);
    } catch (e, st) {
      _logger.severe('Ошибка получения склада по id=$id', e, st);
      return Left(DatabaseFailure('Ошибка получения склада: $e'));
    }
  }

  @override
  Future<Either<Failure, Warehouse?>> getWarehouseByVendorId(String vendorId) async {
    try {
      final query = _database.select(_database.warehouses)
        ..where((tbl) => tbl.vendorId.equals(vendorId));
      final row = await query.getSingleOrNull();
      return Right(row != null ? WarehouseMapper.fromData(row) : null);
    } catch (e, st) {
      _logger.severe('Ошибка получения склада по vendorId=$vendorId', e, st);
      return Left(DatabaseFailure('Ошибка получения склада: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Warehouse>>> getWarehousesByRegion(String regionCode) async {
    try {
      final query = _database.select(_database.warehouses)
        ..where((tbl) => tbl.regionCode.equals(regionCode));
      final rows = await query.get();
      return Right(WarehouseMapper.fromDataList(rows));
    } catch (e, st) {
      _logger.severe('Ошибка получения складов региона $regionCode', e, st);
      return Left(DatabaseFailure('Ошибка получения складов: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveWarehouses(List<Warehouse> warehouses) async {
    if (warehouses.isEmpty) {
      return const Right(null);
    }

    try {
      await _database.transaction(() async {
        for (final warehouse in warehouses) {
          final companion = WarehouseMapper.toCompanion(
            warehouse.copyWith(updatedAt: DateTime.now()),
          );

          final existing = await (_database.select(_database.warehouses)
                ..where((tbl) => tbl.id.equals(warehouse.id)))
              .getSingleOrNull();

          if (existing != null) {
            await (_database.update(_database.warehouses)
                  ..where((tbl) => tbl.id.equals(warehouse.id)))
                .write(companion);
          } else {
            await _database.into(_database.warehouses).insert(companion);
          }
        }
      });

      _logger.info('💾 Сохранено/обновлено складов: ${warehouses.length}');
      return const Right(null);
    } catch (e, st) {
      _logger.severe('Ошибка сохранения складов', e, st);
      return Left(DatabaseFailure('Ошибка сохранения складов: $e'));
    }
  }
}
