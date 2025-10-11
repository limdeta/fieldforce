import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/features/shop/domain/entities/warehouse.dart';

class WarehouseMapper {
  static Warehouse fromData(WarehouseData data) {
    return Warehouse(
      id: data.id,
      name: data.name,
      vendorId: data.vendorId,
      regionCode: data.regionCode,
      isPickUpPoint: data.isPickUpPoint,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  static List<Warehouse> fromDataList(List<WarehouseData> dataList) {
    return dataList.map(fromData).toList();
  }

  static WarehousesCompanion toCompanion(Warehouse warehouse) {
    return WarehousesCompanion(
      id: Value(warehouse.id),
      name: Value(warehouse.name),
      vendorId: Value(warehouse.vendorId),
      regionCode: Value(warehouse.regionCode),
      isPickUpPoint: Value(warehouse.isPickUpPoint),
      createdAt: Value(warehouse.createdAt),
      updatedAt: Value(warehouse.updatedAt),
    );
  }
}
