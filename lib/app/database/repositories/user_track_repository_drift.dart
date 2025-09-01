import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/database.dart';
import '../../../../shared/either.dart';
import '../../../../shared/failures.dart';
import '../../../../features/navigation/tracking/domain/entities/navigation_user.dart';
import '../../../../features/navigation/tracking/domain/entities/user_track.dart';
import '../../../../features/navigation/tracking/domain/entities/compact_track.dart';
import '../../../../features/navigation/tracking/domain/repositories/user_track_repository.dart';
import '../../../features/shop/domain/entities/employee.dart' as domain;
import '../mappers/user_track_mapper.dart';

class UserTrackRepositoryDrift implements UserTrackRepository {
  final AppDatabase _database;
  final EmployeeRepositoryDrift _employeeRepository;

  UserTrackRepositoryDrift(this._database, this._employeeRepository);

  @override
  Future<Either<Failure, UserTrack>> getUserTrackById(int id) async {
    try {
      final userTrackData = await (_database.select(_database.userTracks)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();

      if (userTrackData == null) {
        return Left(const NotFoundFailure('UserTrack not found'));
      }

      // Получаем NavigationUser из базы
      final navigationUser = await _getNavigationUserById(userTrackData.userId);
      if (navigationUser == null) {
        return Left(const NotFoundFailure('User not found for UserTrack'));
      }

      // Загружаем CompactTrack сегменты
      final segments = await _loadCompactTrackSegments(id);

      final userTrack = UserTrackMapper.fromDb(
        userTrackData: userTrackData,
        user: navigationUser,
        segments: segments,
      );

      return Right(userTrack);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get UserTrack: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserTrack>>> getUserTracks(NavigationUser user) async {
    try {
      // Находим внутренний ID пользователя
      final userId = await _getUserInternalId(user);
      if (userId == null) {
        return Left(const NotFoundFailure('User not found in database'));
      }

      final userTracksData = await (_database.select(_database.userTracks)
            ..where((tbl) => tbl.userId.equals(userId)))
          .get();

      final userTracks = <UserTrack>[];
      for (final data in userTracksData) {
        // Загружаем сегменты для каждого трека
        final segments = await _loadCompactTrackSegments(data.id);

        final userTrack = UserTrackMapper.fromDb(
          userTrackData: data,
          user: user,
          segments: segments,
        );
        
        userTracks.add(userTrack);
      }

      return Right(userTracks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get UserTracks: $e'));
    }
  }

  @override
  Future<Either<Failure, List<UserTrack>>> getUserTracksByDateRange(
    NavigationUser user,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userId = await _getUserInternalId(user);
      if (userId == null) {
        return Left(const NotFoundFailure('User not found in database'));
      }

      final userTracksData = await (_database.select(_database.userTracks)
            ..where((tbl) => 
                tbl.userId.equals(userId) &
                tbl.startTime.isBiggerOrEqualValue(startDate) &
                tbl.startTime.isSmallerOrEqualValue(endDate)))
          .get();

      final userTracks = <UserTrack>[];
      for (final data in userTracksData) {
        final segments = await _loadCompactTrackSegments(data.id);

        final userTrack = UserTrackMapper.fromDb(
          userTrackData: data,
          user: user,
          segments: segments,
        );
        
        userTracks.add(userTrack);
      }

      return Right(userTracks);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get UserTracks by date range: $e'));
    }
  }

  @override
  Future<Either<Failure, UserTrack?>> getActiveUserTrack(NavigationUser user) async {
    try {
      final userId = await _getUserInternalId(user);
      if (userId == null) {
        return Left(const NotFoundFailure('User not found in database'));
      }

      final activeTrackData = await (_database.select(_database.userTracks)
            ..where((tbl) => 
                tbl.userId.equals(userId) &
                tbl.endTime.isNull()))
          .getSingleOrNull();

      if (activeTrackData == null) {
        return Right(null);
      }

      final segments = await _loadCompactTrackSegments(activeTrackData.id);

      final userTrack = UserTrackMapper.fromDb(
        userTrackData: activeTrackData,
        user: user,
        segments: segments,
      );

      return Right(userTrack);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active UserTrack: $e'));
    }
  }

  @override
  Future<Either<Failure, UserTrack>> saveUserTrack(UserTrack track) async {
    try {
      print('💾 Начало сохранения UserTrack для пользователя: ${track.user.id} (${track.user.fullName})');
      
      final userId = await _getUserInternalId(track.user);
      if (userId == null) {
        print('❌ Пользователь не найден в базе данных: ${track.user.id} (${track.user.fullName})');
        return Left(const NotFoundFailure('User not found in database'));
      }
      
      print('✅ Найден внутренний ID пользователя: $userId');

      // Сохраняем основную запись UserTrack
      final userTrackCompanion = UserTracksCompanion.insert(
        userId: userId,
        startTime: track.startTime,
        status: track.status.name,
        totalPoints: Value(track.totalPoints),
        totalDistanceKm: Value(track.totalDistanceKm),
        totalDurationSeconds: Value(track.totalDuration.inSeconds),
        endTime: Value(track.endTime),
        metadata: Value(_encodeMetadata(track.metadata)),
      );

      final userTrackId = await _database.into(_database.userTracks).insert(userTrackCompanion);
      print('✅ UserTrack сохранен с ID: $userTrackId');

      // Сохраняем сегменты CompactTrack
      for (int i = 0; i < track.segments.length; i++) {
        final segment = track.segments[i];
        
        final compactTrackCompanion = UserTrackMapper.compactTrackToCompanion(
          segment,
          userTrackId,
          i,
        );

        await _database.into(_database.compactTracks).insert(compactTrackCompanion);
      }
      
      print('✅ Сохранено ${track.segments.length} сегментов CompactTrack');

      // Возвращаем трек с новым ID
      final savedTrack = UserTrack(
        id: userTrackId,
        user: track.user,
        status: track.status,
        startTime: track.startTime,
        endTime: track.endTime,
        segments: track.segments,
        totalPoints: track.totalPoints,
        totalDistanceKm: track.totalDistanceKm,
        totalDuration: track.totalDuration,
        metadata: track.metadata,
      );

      return Right(savedTrack);
    } catch (e) {
      print('❌ Критическая ошибка при сохранении UserTrack: $e');
      return Left(DatabaseFailure('Failed to save UserTrack: $e'));
    }
  }

  @override
  Future<Either<Failure, UserTrack>> updateUserTrack(UserTrack track) async {
    try {
      final userId = await _getUserInternalId(track.user);
      if (userId == null) {
        return Left(const NotFoundFailure('User not found in database'));
      }

      // Обновляем основную запись
      final userTrackCompanion = UserTracksCompanion(
        id: Value(track.id),
        userId: Value(userId),
        startTime: Value(track.startTime),
        endTime: Value(track.endTime),
        status: Value(track.status.name),
        totalPoints: Value(track.totalPoints),
        totalDistanceKm: Value(track.totalDistanceKm),
        totalDurationSeconds: Value(track.totalDuration.inSeconds),
        metadata: Value(_encodeMetadata(track.metadata)),
        updatedAt: Value(DateTime.now()),
      );

      await (_database.update(_database.userTracks)
            ..where((tbl) => tbl.id.equals(track.id)))
          .write(userTrackCompanion);

      // Удаляем старые сегменты
      await (_database.delete(_database.compactTracks)
            ..where((tbl) => tbl.userTrackId.equals(track.id)))
          .go();

      // Добавляем новые сегменты
      for (int i = 0; i < track.segments.length; i++) {
        final segment = track.segments[i];
        
        final compactTrackCompanion = UserTrackMapper.compactTrackToCompanion(
          segment,
          track.id,
          i,
        );

        await _database.into(_database.compactTracks).insert(compactTrackCompanion);
      }

      return Right(track);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update UserTrack: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUserTrack(UserTrack track) async {
    try {
      // Удаляем сегменты (каскадно удалятся из-за onDelete: KeyAction.cascade)
      await (_database.delete(_database.userTracks)
            ..where((tbl) => tbl.id.equals(track.id)))
          .go();

      return Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete UserTrack: $e'));
    }
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================

  /// Загружает сегменты CompactTrack для UserTrack
  Future<List<CompactTrack>> _loadCompactTrackSegments(int userTrackId) async {
    final segmentsData = await (_database.select(_database.compactTracks)
          ..where((tbl) => tbl.userTrackId.equals(userTrackId))
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.segmentOrder)]))
        .get();

    return segmentsData.map((data) => UserTrackMapper.compactTrackFromDb(data)).toList();
  }

  /// Кодирует метаданные в JSON
  String? _encodeMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null || metadata.isEmpty) return null;
    try {
      return jsonEncode(metadata);
    } catch (e) {
      return null;
    }
  }

  /// Получает внутренний database ID пользователя через EmployeeRepository
  Future<int?> _getUserInternalId(NavigationUser user) async {
    if (user.runtimeType.toString().contains('AppUser')) {
      try {
        // Используем duck typing - если у объекта есть поле employee, извлекаем его
        final dynamic appUser = user;
        if (appUser.employee != null) {
          final employee = appUser.employee as domain.Employee;
          print('✅ Извлечен Employee из AppUser: ${employee.id} (${employee.fullName})');
          
          final result = await _employeeRepository.getInternalIdForNavigationUser(employee);
          return result.fold(
            (failure) {
              print('❌ Ошибка получения внутреннего ID из AppUser.employee: ${failure.message}');
              return null;
            },
            (id) {
              print('✅ Получен внутренний ID из AppUser.employee: $id');
              return id;
            },
          );
        }
      } catch (e) {
        print('❌ Ошибка извлечения Employee из AppUser: $e');
        return null;
      }
    }
    
    // Приводим NavigationUser к Employee
    if (user is! domain.Employee) {
      print('❌ Пользователь не является Employee: ${user.runtimeType}');
      return null;
    }
    
    
    final result = await _employeeRepository.getInternalIdForNavigationUser(user);
    return result.fold(
      (failure) {
        print('❌ Ошибка получения внутреннего ID: ${failure.message}');
        return null;
      },
      (id) {
        return id;
      },
    );
  }

  Future<NavigationUser?> _getNavigationUserById(int id) async {
    final result = await _employeeRepository.getNavigationUserById(id);
    return result.fold(
      (failure) => null,
      (employee) => employee,
    );
  }
}
