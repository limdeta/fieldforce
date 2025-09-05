import 'package:drift/drift.dart';

@DataClassName('WorkDayData')
class WorkDays extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get user => integer()();
  DateTimeColumn get date => dateTime()();
  IntColumn get routeId => integer().nullable()();
  IntColumn get trackId => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('planned'))(); // planned, active, completed
  DateTimeColumn get startTime => dateTime().nullable()();
  DateTimeColumn get endTime => dateTime().nullable()();
  TextColumn get metadata => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {user, date}, // Один WorkDay на пользователя в день
  ];
}
