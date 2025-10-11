import 'package:drift/drift.dart';

/// Таблица со складами для региональной фильтрации остатков.
@DataClassName('WarehouseData')
class Warehouses extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get vendorId => text()();
  TextColumn get regionCode => text()();
  BoolColumn get isPickUpPoint => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'UNIQUE(vendor_id)',
      ];
}
