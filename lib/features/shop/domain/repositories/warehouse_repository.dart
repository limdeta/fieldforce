// lib/features/shop/domain/repositories/warehouse_repository.dart

import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import '../entities/warehouse.dart';

abstract class WarehouseRepository {
  /// Сохранить список складов (upsert по ID).
  Future<Either<Failure, void>> saveWarehouses(List<Warehouse> warehouses);

  /// Очистить все склады.
  Future<Either<Failure, void>> clearWarehouses();

  /// Очистить склады конкретного региона.
  Future<Either<Failure, void>> clearWarehousesByRegion(String regionCode);

  /// Получить склад по идентификатору.
  Future<Either<Failure, Warehouse?>> getWarehouseById(int id);

  /// Получить склады по региональному коду (например, "P3V").
  Future<Either<Failure, List<Warehouse>>> getWarehousesByRegion(String regionCode);

  /// Получить склады по vendorId (используется для отображения названия склада в UI).
  Future<Either<Failure, Warehouse?>> getWarehouseByVendorId(String vendorId);

  /// Получить все склады.
  Future<Either<Failure, List<Warehouse>>> getAllWarehouses();
}
