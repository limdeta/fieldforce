import 'package:drift/drift.dart';
import 'point_of_interest_table.dart';

/// Таблица географических торговых точек на маршрутах  
/// Связана с PointsOfInterest - это точки для навигации и визитов
@DataClassName('TradingPointData')
class TradingPoints extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pointOfInterestId => integer().references(PointsOfInterest, #id)();
  TextColumn get address => text().nullable()();
  TextColumn get contactPerson => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get workingHours => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
