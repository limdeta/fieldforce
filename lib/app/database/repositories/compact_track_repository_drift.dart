import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/compact_track_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';


/// Реализация репозитория компактных треков через Drift database
/// 
/// Архитектура:
/// - CompactTrack хранится в бинарном формате для максимальной производительности
/// - Связь с UserTrack через userTrackId
/// - Поддержка ленивой загрузки и пакетных операций
class CompactTrackRepositoryDrift implements CompactTrackRepository {
  final AppDatabase _database;

  CompactTrackRepositoryDrift(this._database);

  @override
  Future<Either<Failure, CompactTrack>> getCompactTrackById(int id) async {
    try {
      final compactTrackData = await (_database.select(_database.compactTracks)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

      if (compactTrackData == null) {
        return const Left(NotFoundFailure('CompactTrack not found'));
      }

      final compactTrack = CompactTrack.fromDatabase(
        coordinatesBlob: compactTrackData.coordinatesBlob,
        timestampsBlob: compactTrackData.timestampsBlob,
        speedsBlob: compactTrackData.speedsBlob,
        accuraciesBlob: compactTrackData.accuraciesBlob,
        bearingsBlob: compactTrackData.bearingsBlob,
      );

      return Right(compactTrack);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get CompactTrack: $e'));
    }
  }

  @override
  Future<Either<Failure, CompactTrack>> saveCompactTrack(CompactTrack track) async {
    // Этот метод не должен использоваться напрямую
    // CompactTrack сегменты сохраняются через UserTrackRepository
    return const Left(ValidationFailure(
      'CompactTrack segments should be saved through UserTrackRepository'
    ));
  }

  @override
  Future<Either<Failure, CompactTrack>> updateCompactTrack(CompactTrack track) async {
    // CompactTrack является immutable, обновления не поддерживаются
    return const Left(ValidationFailure(
      'CompactTrack is immutable and cannot be updated'
    ));
  }

  @override
  Future<Either<Failure, void>> deleteCompactTrack(CompactTrack track) async {
    // Удаление происходит каскадно при удалении UserTrack
    return const Left(ValidationFailure(
      'CompactTrack segments are deleted cascadely with UserTrack'
    ));
  }

  @override
  Future<Either<Failure, List<CompactTrack>>> getCompactTracksByUser(NavigationUser user) async {
    try {
      // Находим внутренний ID пользователя
      final userId = await _getUserId(user);
      if (userId == null) {
        return const Left(NotFoundFailure('User not found in database'));
      }

      // Получаем все UserTrack ID для пользователя
      final userTrackIds = await (_database.select(_database.userTracks)
            ..where((tbl) => tbl.userId.equals(userId)))
          .map((row) => row.id)
          .get();

      if (userTrackIds.isEmpty) {
        return const Right([]);
      }

      // Получаем все CompactTrack сегменты для этих UserTrack
      final compactTracksData = await (_database.select(_database.compactTracks)
            ..where((tbl) => tbl.userTrackId.isIn(userTrackIds))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.segmentOrder)]))
          .get();

      final compactTracks = compactTracksData.map((data) => 
        CompactTrack.fromDatabase(
          coordinatesBlob: data.coordinatesBlob,
          timestampsBlob: data.timestampsBlob,
          speedsBlob: data.speedsBlob,
          accuraciesBlob: data.accuraciesBlob,
          bearingsBlob: data.bearingsBlob,
        )
      ).toList();

      return Right(compactTracks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get CompactTracks by user: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CompactTrack>>> getCompactTracksByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Получаем UserTrack в диапазоне дат
      final userTrackIds = await (_database.select(_database.userTracks)
            ..where((tbl) => 
                tbl.startTime.isBiggerOrEqualValue(startDate) &
                tbl.startTime.isSmallerOrEqualValue(endDate)))
          .map((row) => row.id)
          .get();

      if (userTrackIds.isEmpty) {
        return const Right([]);
      }

      // Получаем все CompactTrack сегменты для этих UserTrack
      final compactTracksData = await (_database.select(_database.compactTracks)
            ..where((tbl) => tbl.userTrackId.isIn(userTrackIds))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.userTrackId), 
                       (tbl) => OrderingTerm.asc(tbl.segmentOrder)]))
          .get();

      final compactTracks = compactTracksData.map((data) => 
        CompactTrack.fromDatabase(
          coordinatesBlob: data.coordinatesBlob,
          timestampsBlob: data.timestampsBlob,
          speedsBlob: data.speedsBlob,
          accuraciesBlob: data.accuraciesBlob,
          bearingsBlob: data.bearingsBlob,
        )
      ).toList();

      return Right(compactTracks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get CompactTracks by date range: $e'));
    }
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================

  /// Получает внутренний ID пользователя через EmployeeRepository
  Future<int?> _getUserId(NavigationUser user) async {
    // Так как Employee реализует NavigationUser, просто возвращаем его id
    // Employee.id уже содержит внутренний database ID
    return user.id == 0 ? null : user.id;
  }
}
