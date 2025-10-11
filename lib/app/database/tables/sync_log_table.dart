import 'package:drift/drift.dart';

@DataClassName('SyncLogRow')
class SyncLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get task => text()();
  TextColumn get eventType => text().withDefault(const Constant('info'))();
  TextColumn get status => text().nullable()();
  TextColumn get message => text()();
  TextColumn get detailsJson => text().nullable()();
  TextColumn get regionCode => text().nullable()();
  TextColumn get tradingPointExternalId => text().nullable()();
  IntColumn get durationMs => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

}
