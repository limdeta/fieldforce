import 'package:drift/drift.dart';
import 'route_table.dart';

@DataClassName('PointOfInterestData')
class PointsOfInterest extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get routeId => integer().references(Routes, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  TextColumn get status => text()(); // PointStatus enum as string
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get visitedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get type => text()(); // PointType enum as string
}
