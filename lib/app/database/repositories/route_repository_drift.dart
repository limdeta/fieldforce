import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/shared/failures.dart';

import '../../../../features/shop/domain/entities/route.dart' as domain;
import '../../../features/shop/domain/entities/point_of_interest.dart' as domain;
import '../../../features/shop/domain/repositories/route_repository.dart';
import '../../../../shared/either.dart';
import 'package:latlong2/latlong.dart';
import '../app_database.dart' as db;
import '../mappers/route_mapper.dart';

class RouteRepositoryDrift implements RouteRepository {
  final db.AppDatabase _database;

  RouteRepositoryDrift(this._database);

  @override
  Future<List<domain.Route>> getAllRoutes() async {
    try {
      final allRoutes = await _database.select(_database.routes).get();
      final routesList = <domain.Route>[];
      
      for (final routeData in allRoutes) {
        final points = await _loadRoutePoints(routeData.id);
        final route = RouteMapper.fromDb(routeData, points);
        routesList.add(route);
      }
      
      return routesList;
    } catch (e) {
      return [];
    }
  }
  
  @override
  Stream<List<domain.Route>> watchEmployeeRoutes(Employee employee) async* {
    try {
      final employeeId = employee.id;

      final query = _database.select(_database.routes)
        ..where((route) => route.employeeId.equals(employeeId));
      
      yield* query.watch().asyncMap((routesData) async {
        final routesList = <domain.Route>[];
        
        for (final routeData in routesData) {
          final points = await _loadRoutePoints(routeData.id);
          final route = RouteMapper.fromDb(routeData, points);
          routesList.add(route);
        }
        
        return routesList;
      });
    } catch (e) {
      yield [];
    }
  }

  @override
  Future<Either<NotFoundFailure, domain.Route>> getRouteById(int routeId) async {
    try {
      final query = _database.select(_database.routes)
        ..where((route) => route.id.equals(routeId));
      
      final routeData = await query.getSingleOrNull();
      if (routeData == null) {
        return const Left(NotFoundFailure('Route not found'));
      }
      
      final points = await _loadRoutePoints(routeData.id);
      final route = RouteMapper.fromDb(routeData, points);
      return Right(route);
    } catch (e) {
      return Left(NotFoundFailure('Failed to get route: $e'));
    }
  }

  @override
  Future<Either<EntityCreationFailure, domain.Route>> saveRoute(
    domain.Route route, 
    Employee? employee,
  ) async {
    try {
      final employeeId = employee?.id;
      final routeCompanion = RouteMapper.toDb(route, employeeId: employeeId);
      
      final routeId = await _database.into(_database.routes).insert(routeCompanion);
      
      // Сохраняем точки интереса
      await _saveRoutePoints(route.pointsOfInterest, routeId);
      
      final createdRoute = route.copyWith(id: routeId);
      return Right(createdRoute);
    } catch (e) {
      return Left(EntityCreationFailure('Failed to save route: $e'));
    }
  }

  @override
  Future<Either<EntityUpdateFailure, domain.Route>> updateRoute(
    domain.Route route, 
    Employee? employee,
  ) async {
    try {
      if (route.id == null) {
        return const Left(EntityUpdateFailure('Cannot update route without id'));
      }

      final employeeId = employee?.id;
      final routeCompanion = RouteMapper.toDb(route, employeeId: employeeId);
      
      _database.update(_database.routes)
        ..where((r) => r.id.equals(route.id!))
        ..write(routeCompanion);
      
      // Удаляем старые точки и создаем новые
      await _deleteRoutePoints(route.id!);
      await _saveRoutePoints(route.pointsOfInterest, route.id!);
      
      return Right(route);
    } catch (e) {
      return Left(EntityUpdateFailure('Failed to update route: $e'));
    }
  }

  @override
  Future<void> deleteRoute(domain.Route route) async {
    if (route.id != null) {
      await _deleteRoutePoints(route.id!);
      await (_database.delete(_database.routes)
        ..where((r) => r.id.equals(route.id!))).go();
    }
  }

  @override
  Future<void> clearAllTradingPoints() async {
    await _database.delete(_database.tradingPoints).go();
  }

  // Вспомогательные методы
  Future<List<domain.PointOfInterest>> _loadRoutePoints(int routeId) async {
    final pointsQuery = _database.select(_database.pointsOfInterest)
      ..where((point) => point.routeId.equals(routeId));
    
    final dbPoints = await pointsQuery.get();
    final points = <domain.PointOfInterest>[];
    
    for (final dbPoint in dbPoints) {
      // Простая имплементация для basic PointOfInterest
      // В будущем можно расширить для TradingPointOfInterest
      final point = _createBasicPoint(dbPoint);
      points.add(point);
    }
    
    return points;
  }

  domain.PointOfInterest _createBasicPoint(db.PointOfInterestData dbPoint) {
    // Временная реализация базовой точки интереса
    // Нужно будет создать конкретную имплементацию PointOfInterest
    return BasicPointOfInterest(
      id: dbPoint.id,
      name: dbPoint.name,
      description: dbPoint.description,
      coordinates: LatLng(dbPoint.latitude, dbPoint.longitude),
      createdAt: dbPoint.createdAt,
      status: RouteMapper.stringToVisitStatus(dbPoint.status),
      type: RouteMapper.stringToPointType(dbPoint.type),
      notes: dbPoint.notes,
    );
  }

  Future<void> _saveRoutePoints(List<domain.PointOfInterest> points, int routeId) async {
    for (final point in points) {
      final pointCompanion = RouteMapper.pointToDb(point, routeId);
      final pointId = await _database.into(_database.pointsOfInterest).insert(pointCompanion);
      
      final tradingCompanion = RouteMapper.tradingPointToDb(point, pointId);
      if (tradingCompanion != null) {
        await _database.into(_database.tradingPoints).insert(tradingCompanion);
      }
    }
  }

  Future<void> _deleteRoutePoints(int routeId) async {
    // Сначала удаляем торговые точки
    final pointsToDelete = await (_database.select(_database.pointsOfInterest)
      ..where((point) => point.routeId.equals(routeId))).get();
    
    for (final point in pointsToDelete) {
      await (_database.delete(_database.tradingPoints)
        ..where((tp) => tp.pointOfInterestId.equals(point.id))).go();
    }
    
    // Затем удаляем точки интереса
    await (_database.delete(_database.pointsOfInterest)
      ..where((point) => point.routeId.equals(routeId))).go();
  }
}

// Временная базовая имплементация PointOfInterest
class BasicPointOfInterest implements domain.PointOfInterest {
  @override
  final int? id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final LatLng coordinates;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final domain.VisitStatus status;
  @override
  final domain.PointType type;
  @override
  final String? notes;

  const BasicPointOfInterest({
    this.id,
    required this.name,
    this.description,
    required this.coordinates,
    required this.createdAt,
    this.updatedAt,
    required this.status,
    required this.type,
    this.notes,
  });

  @override
  int? get order => null;

  @override
  DateTime? get plannedArrivalTime => null;

  @override
  DateTime? get plannedDepartureTime => null;

  @override
  DateTime? get actualArrivalTime => null;

  @override
  DateTime? get actualDepartureTime => null;

  @override
  String? get externalId => null;

  @override
  String get displayName => name;

  @override
  domain.PointOfInterest copyWith({
    domain.VisitStatus? status,
    DateTime? actualArrivalTime,
    DateTime? actualDepartureTime,
    String? notes,
  }) {
    return BasicPointOfInterest(
      id: id,
      name: name,
      description: description,
      coordinates: coordinates,
      createdAt: createdAt,
      updatedAt: updatedAt,
      status: status ?? this.status,
      type: type,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool get isVisited => status == domain.VisitStatus.completed;

  @override
  bool get isCurrentlyAt => status == domain.VisitStatus.arrived;

  @override
  bool get isOnTime => true; // Упрощенная логика

  @override
  Duration? get delay => null; // Упрощенная логика
}
