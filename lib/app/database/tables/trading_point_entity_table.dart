import 'package:drift/drift.dart';

/// Таблица бизнес-сущностей торговых точек из CRM/учетной системы
/// Используется для заказов, каталогов, остатков товаров
@DataClassName('TradingPointEntity')
class TradingPointEntities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get externalId => text().unique()();
  TextColumn get name => text()();
  TextColumn get inn => text().nullable()();
  TextColumn get region => text().withDefault(const Constant('P3V'))();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
