import 'package:drift/drift.dart';

@DataClassName('UserData')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get externalId => text().unique()();
  TextColumn get role => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get hashedPassword => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
