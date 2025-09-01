import 'package:drift/drift.dart';

@DataClassName('TradingPointEntity')
class TradingPointEntities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get externalId => text().unique()();
  TextColumn get name => text()();
  TextColumn get inn => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
