import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/route.dart' as domain;
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';


/// Интерфейс репозитория для маршрутов
/// 
/// Определяет контракт для работы с данными маршрутов.
/// Будет реализован в data слое через Drift database.
abstract class RouteRepository {
  Stream<List<domain.Route>> watchEmployeeRoutes(Employee employee);
  Future<List<domain.Route>> getEmployeeRoutes(Employee employee);
  Future<List<domain.Route>> getAllRoutes();
  Future<Either<NotFoundFailure, domain.Route>> getRouteById(int routeId);
  Future<Either<EntityCreationFailure, domain.Route>> saveRoute(domain.Route route, Employee? employee);
  Future<Either<EntityUpdateFailure, domain.Route>> updateRoute(domain.Route route, Employee? employee);
  Future<void> deleteRoute(domain.Route route);

  /// (для dev режима)
  Future<void> clearAllTradingPoints();
  
  /// TODO: Реализация переноса точек на следующий день
  // Future<Route> transferUncompletedPoints({
  //   required int fromRouteId,
  //   required int toRouteId,
  //   required List<int> pointIds,
  // });
}

