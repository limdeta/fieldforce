import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Централизованный сервис синхронизации
/// В будущем можно будет разбить на отдельные адаптеры
class SyncService {
  final TradingPointRepository _tradingPointRepository;
  final String _baseUrl;

  SyncService({
    required TradingPointRepository tradingPointRepository,
    required String baseUrl,
  }) : _tradingPointRepository = tradingPointRepository,
       _baseUrl = baseUrl;

  /// Синхронизирует все торговые точки
  Future<Either<Failure, void>> syncTradingPoints() async {
    try {
      // 1. Получаем данные с удаленного сервера
      final remoteResult = await _fetchTradingPointsFromRemote();
      
      return remoteResult.fold(
        (failure) => Left(failure),
        (remoteTradingPoints) async {
          // 2. Сохраняем полученные данные локально
          return await _saveTradingPointsLocally(remoteTradingPoints);
        },
      );
    } catch (e) {
      return Left(NetworkFailure('Ошибка синхронизации торговых точек: $e'));
    }
  }

  /// Получает торговые точки с удаленного сервера
  Future<Either<Failure, List<TradingPoint>>> _fetchTradingPointsFromRemote() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trading-points'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Добавить авторизацию когда понадобится
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        final tradingPoints = jsonData.map((json) {
          return TradingPoint.fromJson(json);
        }).toList();

        return Right(tradingPoints);
      } else {
        return Left(NetworkFailure(
          'Ошибка сервера при получении торговых точек: ${response.statusCode}',
          details: response.body,
        ));
      }
    } on FormatException catch (e) {
      return Left(NetworkFailure(
        'Ошибка парсинга JSON ответа',
        details: e.toString(),
      ));
    } catch (e) {
      return Left(NetworkFailure(
        'Ошибка сети при получении торговых точек',
        details: e.toString(),
      ));
    }
  }

  Future<Either<Failure, void>> _saveTradingPointsLocally(List<TradingPoint> tradingPoints) async {
    try {
      // TODO: Возможно в будущем добавить batch операции для производительности
      for (final tradingPoint in tradingPoints) {
        final saveResult = await _tradingPointRepository.save(tradingPoint);
        
        // Если хотя бы одна точка не сохранилась - возвращаем ошибку
        if (saveResult.isLeft()) {
          return saveResult.fold(
            (failure) => Left(failure),
            (_) => Right(null), // Этот случай не произойдет при isLeft()
          );
        }
      }
      
      return Right(null);
    } catch (e) {
      return Left(DatabaseFailure(
        'Ошибка сохранения торговых точек в локальную базу',
        details: e.toString(),
      ));
    }
  }


  Future<Either<Failure, void>> syncAll() async {
    final tradingPointsResult = await syncTradingPoints();
    
    // TODO: Добавить синхронизацию других сущностей
    // final employeesResult = await syncEmployees();
    // final routesResult = await syncRoutes();
    
    return tradingPointsResult;
  }

  Future<Either<Failure, DateTime?>> getLastSyncTime() async {
    try {
      // Получаем все торговые точки и находим самую свежую по updatedAt
      final localPointsResult = await _tradingPointRepository.getAll();
      
      return localPointsResult.fold(
        (failure) => Left(failure),
        (points) {
          if (points.isEmpty) {
            return Right(null); // Нет данных - нужна полная синхронизация
          }
          
          // Находим самую свежую дату обновления среди всех точек
          final latestUpdate = points
              .where((point) => point.updatedAt != null)
              .map((point) => point.updatedAt!)
              .fold<DateTime?>(null, (latest, current) {
                if (latest == null) return current;
                return current.isAfter(latest) ? current : latest;
              });
          
          return Right(latestUpdate);
        },
      );
    } catch (e) {
      return Left(DatabaseFailure(
        'Ошибка получения времени последней синхронизации',
        details: e.toString(),
      ));
    }
  }

  Future<Either<Failure, bool>> shouldSyncTradingPoints() async {
    try {
      final lastSyncResult = await getLastSyncTime();
      
      return lastSyncResult.fold(
        (failure) => Left(failure),
        (lastSyncTime) async {
          if (lastSyncTime == null) {
            return Right(true);
          }

          final hasUpdatesResult = await _checkForUpdatesOnServer(lastSyncTime);
          return hasUpdatesResult;
        },
      );
    } catch (e) {
      return Left(NetworkFailure(
        'Ошибка проверки необходимости синхронизации',
        details: e.toString(),
      ));
    }
  }

  /// Проверяет есть ли обновления на сервере после указанного времени
  Future<Either<Failure, bool>> _checkForUpdatesOnServer(DateTime lastSyncTime) async {
    try {
      // Запрашиваем только метаданные для проверки обновлений
      final response = await http.get(
        Uri.parse('$_baseUrl/trading-points/check-updates?since=${lastSyncTime.toIso8601String()}'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Добавить авторизацию когда понадобится
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hasUpdates = data['has_updates'] ?? false;
        return Right(hasUpdates);
      } else if (response.statusCode == 404) {
        // Если эндпоинт не поддерживается - делаем полную синхронизацию
        return Right(true);
      } else {
        return Left(NetworkFailure(
          'Ошибка проверки обновлений: ${response.statusCode}',
          details: response.body,
        ));
      }
    } catch (e) {
      // В случае ошибки сети - лучше синхронизировать
      return Right(true);
    }
  }

  /// Альтернативный способ - получение только обновленных записей
  Future<Either<Failure, List<TradingPoint>>> _fetchUpdatedTradingPointsOnly() async {
    try {
      final lastSyncResult = await getLastSyncTime();
      
      return lastSyncResult.fold(
        (failure) => Left(failure),
        (lastSyncTime) async {
          String url = '$_baseUrl/trading-points';
          
          // Если есть время последней синхронизации - запрашиваем только обновления
          if (lastSyncTime != null) {
            url += '?updated_since=${lastSyncTime.toIso8601String()}';
          }
          
          final response = await http.get(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
          );

          if (response.statusCode == 200) {
            final List<dynamic> jsonData = json.decode(response.body);
            final tradingPoints = jsonData.map((json) {
              return TradingPoint.fromJson(json);
            }).toList();

            return Right(tradingPoints);
          } else {
            return Left(NetworkFailure(
              'Ошибка получения обновлений: ${response.statusCode}',
              details: response.body,
            ));
          }
        },
      );
    } catch (e) {
      return Left(NetworkFailure(
        'Ошибка получения инкрементальных обновлений',
        details: e.toString(),
      ));
    }
  }

  /// Улучшенная синхронизация с проверкой необходимости
  Future<Either<Failure, void>> smartSyncTradingPoints() async {
    try {
      // 1. Проверяем нужна ли синхронизация
      final shouldSyncResult = await shouldSyncTradingPoints();
      
      return shouldSyncResult.fold(
        (failure) => Left(failure),
        (needsSync) async {
          if (!needsSync) {
            print('Синхронизация торговых точек не требуется');
            return Right(null);
          }
          
          // 2. Получаем только обновленные данные
          final updatedDataResult = await _fetchUpdatedTradingPointsOnly();
          
          return updatedDataResult.fold(
            (failure) => Left(failure),
            (updatedPoints) async {
              if (updatedPoints.isEmpty) {
                print('Нет обновлений для синхронизации');
                return Right(null);
              }
              
              print('Найдено ${updatedPoints.length} обновлений');
              
              // 3. Сохраняем только обновленные данные
              return await _saveTradingPointsLocally(updatedPoints);
            },
          );
        },
      );
    } catch (e) {
      return Left(NetworkFailure('Ошибка умной синхронизации: $e'));
    }
  }

  /// Проверяет, нужна ли синхронизация (упрощенная версия)
  Future<bool> shouldSync() async {
    final result = await shouldSyncTradingPoints();
    return result.fold(
      (failure) => true, // В случае ошибки лучше синхронизировать
      (needsSync) => needsSync,
    );
  }
}
