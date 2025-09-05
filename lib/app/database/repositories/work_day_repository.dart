import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/mappers/work_day_mapper.dart';
import 'package:fieldforce/app/domain/entities/work_day.dart';
import 'package:fieldforce/app/di/service_locator.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as shop;
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/app/domain/repositories/route_repository.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';

/// Репозиторий для работы с WorkDay в базе данных
class WorkDayRepository {
  final AppDatabase _database;

  WorkDayRepository(this._database);

  /// Получить все WorkDay для пользователя с полной загрузкой связанных данных
  Future<Either<Failure, List<WorkDay>>> getWorkDaysForUserWithFullData(int userId) async {
    try {
      final query = _database.select(_database.workDays)
        ..where((tbl) => tbl.user.equals(userId))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc)]);

      final workDayTables = await query.get();
      final workDays = <WorkDay>[];
      final appUserRepository = getIt<AppUserRepository>();

      for (final table in workDayTables) {
        final userResult = await appUserRepository.getAppUserByUserId(table.user);
        AppUser? appUser;
        userResult.fold(
          (failure) {
            appUser = null;
          },
          (user) => appUser = user,
        );
        if (appUser == null) continue;

        shop.Route? plannedRoute;
        UserTrack? actualTrack;

        // Загружаем маршрут если есть ID
        if (table.routeId != null) {
          try {
            final routeRepository = getIt<RouteRepository>();
            final routeResult = await routeRepository.getRouteById(table.routeId!);
            routeResult.fold(
              (failure) => throw DatabaseFailure('Не удалось загрузить маршрут ID ${table.routeId}: $failure'),
              (route) => plannedRoute = route,
            );
          } catch (e) {
            throw DatabaseFailure('Ошибка загрузки маршрута ID ${table.routeId}: $e');
          }
        }

        // Загружаем трек если есть ID
        if (table.trackId != null) {
          try {
            final trackRepository = getIt<UserTrackRepository>();
            final trackResult = await trackRepository.getUserTrackById(table.trackId!);
            trackResult.fold(
              (failure) => throw DatabaseFailure('Не удалось загрузить трек ID ${table.trackId}: $failure'),
              (track) => actualTrack = track,
            );
          } catch (e) {
            throw DatabaseFailure('Ошибка загрузки трека ID ${table.trackId}: $e');
          }
        }

        final workDay = WorkDayMapper.fromDb(table, user: appUser!, route: plannedRoute, track: actualTrack);
        workDays.add(workDay);
      }
      return Right(workDays);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения WorkDay: $e'));
    }
  }

  /// Получить все WorkDay для пользователя (упрощенная версия)
  Future<Either<Failure, List<WorkDay>>> getWorkDaysForUser(int userId) async {
    try {
      final query = _database.select(_database.workDays)
        ..where((tbl) => tbl.user.equals(userId))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc)]);
      final workDayTables = await query.get();
      final appUserRepository = getIt<AppUserRepository>();
      final workDays = <WorkDay>[];
      for (final table in workDayTables) {
        final userResult = await appUserRepository.getAppUserByUserId(table.user);
        AppUser? appUser;
        userResult.fold(
          (failure) {
            appUser = null;
          },
          (user) => appUser = user,
        );
        if (appUser == null) continue;
        workDays.add(WorkDayMapper.fromDb(table, user: appUser!));
      }
      return Right(workDays);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения WorkDay: $e'));
    }
  }

  /// Получить WorkDay по ID
  Future<Either<Failure, WorkDay?>> getWorkDayById(int id) async {
    try {
      final query = _database.select(_database.workDays)
        ..where((tbl) => tbl.id.equals(id));
      final table = await query.getSingleOrNull();
      if (table == null) return Right(null);
      final appUserRepository = getIt<AppUserRepository>();
      final userResult = await appUserRepository.getAppUserByUserId(table.user);
      AppUser? appUser;
      userResult.fold(
        (failure) {
          appUser = null;
        },
        (user) => appUser = user,
      );
      if (appUser == null) return Right(null);
      return Right(WorkDayMapper.fromDb(table, user: appUser!));
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения WorkDay: $e'));
    }
  }

  /// Получить WorkDay для пользователя на конкретную дату
  Future<Either<Failure, WorkDay?>> getWorkDayForUserAndDate(int userId, DateTime date) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final query = _database.select(_database.workDays)
        ..where((tbl) => tbl.user.equals(userId) & tbl.date.equals(normalizedDate));
      final table = await query.getSingleOrNull();
      if (table == null) return Right(null);
      final appUserRepository = getIt<AppUserRepository>();
      final userResult = await appUserRepository.getAppUserByUserId(table.user);
      AppUser? appUser;
      userResult.fold(
        (failure) {
          appUser = null;
        },
        (user) => appUser = user,
      );
      if (appUser == null) return Right(null);
      return Right(WorkDayMapper.fromDb(table, user: appUser!));
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения WorkDay: $e'));
    }
  }

  /// Создать новый WorkDay
  Future<Either<Failure, WorkDay>> createWorkDay(WorkDay workDay) async {
    try {
      final companion = WorkDayMapper.toCompanion(workDay);
      final id = await _database.into(_database.workDays).insert(companion);
      return Right(workDay.copyWith(id: id, user: workDay.user));
    } catch (e) {
      return Left(EntityCreationFailure('Не удалось создать WorkDay: $e'));
    }
  }

  /// Обновить WorkDay
  Future<Either<Failure, void>> updateWorkDay(WorkDay workDay) async {
    try {
      final companion = WorkDayMapper.toCompanionForUpdate(workDay);
      await (_database.update(_database.workDays)
        ..where((tbl) => tbl.id.equals(workDay.id))
      ).write(companion);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка обновления WorkDay: $e'));
    }
  }

  /// Удалить WorkDay
  Future<Either<Failure, void>> deleteWorkDay(int id) async {
    try {
      await (_database.delete(_database.workDays)
        ..where((tbl) => tbl.id.equals(id))
      ).go();
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка удаления WorkDay: $e'));
    }
  }

  /// Получить трек для конкретного маршрута пользователя
  Future<Either<Failure, int?>> getTrackIdByUserAndRoute(int userId, int routeId) async {
    try {
      final query = _database.select(_database.workDays)
        ..where((tbl) => tbl.user.equals(userId) & tbl.routeId.equals(routeId))
        ..orderBy([(tbl) => OrderingTerm(expression: tbl.date, mode: OrderingMode.desc)])
        ..limit(1);
      final table = await query.getSingleOrNull();
      return Right(table?.trackId);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения trackId: $e'));
    }
  }
}
