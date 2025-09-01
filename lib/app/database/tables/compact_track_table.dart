import 'package:drift/drift.dart';
import 'user_track_table.dart';

@DataClassName('CompactTrackData')
class CompactTracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userTrackId => integer().references(UserTracks, #id, onDelete: KeyAction.cascade)();
  IntColumn get segmentOrder => integer()();
  BlobColumn get coordinatesBlob => blob()();
  
  /// Временные метки (timestamps в binary)
  BlobColumn get timestampsBlob => blob()();
  
  /// Скорости (speeds в binary)
  BlobColumn get speedsBlob => blob()();
  
  /// Точности GPS (accuracies в binary)
  BlobColumn get accuraciesBlob => blob()();
  
  /// Направления движения (bearings в binary)
  BlobColumn get bearingsBlob => blob()();
  
  /// Время создания
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
