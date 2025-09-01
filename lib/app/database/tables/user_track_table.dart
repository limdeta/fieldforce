import 'package:drift/drift.dart';
import 'user_table.dart';
import 'route_table.dart';

@DataClassName('UserTrackData')
class UserTracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  /// Ссылка на пользователя в таблице Users
  IntColumn get userId => integer().references(Users, #id)();
  
  /// Ссылка на маршрут (может быть null для свободного трекинга)
  IntColumn get routeId => integer().nullable().references(Routes, #id)();
  
  /// Время начала трека
  DateTimeColumn get startTime => dateTime()();
  
  /// Время завершения трека (null для активных треков)
  DateTimeColumn get endTime => dateTime().nullable()();
  
  /// Статус трека (active, paused, completed, cancelled)
  TextColumn get status => text().withLength(min: 1, max: 20)();
  
  /// Общее количество точек во всех сегментах
  IntColumn get totalPoints => integer().withDefault(const Constant(0))();
  
  /// Общее расстояние в километрах
  RealColumn get totalDistanceKm => real().withDefault(const Constant(0.0))();
  
  /// Общая продолжительность в секундах
  IntColumn get totalDurationSeconds => integer().withDefault(const Constant(0))();
  
  /// Дополнительные метаданные (JSON)
  TextColumn get metadata => text().nullable()();
  
  /// Время создания
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  /// Время последнего обновления
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
