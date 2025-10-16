

import 'package:drift/drift.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/domain/entities/point_of_interest.dart';
import 'package:fieldforce/app/domain/entities/route.dart';
import 'package:fieldforce/app/domain/entities/trading_point_of_interest.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';

class RouteMapper {
  static Route fromDb(
    RouteData dbRoute,
    List<PointOfInterest> pointsOfInterest,
  ) {
    return Route(
      id: dbRoute.id,
      name: dbRoute.name,
      description: dbRoute.description,
      createdAt: dbRoute.createdAt,
      updatedAt: dbRoute.updatedAt,
      startTime: dbRoute.startTime,
      endTime: dbRoute.endTime,
      pointsOfInterest: pointsOfInterest,
      status: _stringToRouteStatus(dbRoute.status),
    );
  }

  static RoutesCompanion toDb(Route route, {int? employeeId}) {
    return RoutesCompanion.insert(
      name: route.name,
      description: route.description != null 
        ? Value(route.description!)
        : const Value.absent(),
      updatedAt: route.updatedAt != null 
        ? Value(route.updatedAt!)
        : const Value.absent(),
      startTime: route.startTime != null 
        ? Value(route.startTime!)
        : const Value.absent(),
      endTime: route.endTime != null 
        ? Value(route.endTime!)
        : const Value.absent(),
      status: _routeStatusToString(route.status),
      employeeId: employeeId != null 
        ? Value(employeeId)
        : const Value.absent(),
    );
  }

  static PointsOfInterestCompanion pointToDb(
    PointOfInterest point,
    int routeId,
  ) {
    return PointsOfInterestCompanion.insert(
      routeId: routeId,
      name: point.name,
      description: point.description != null 
        ? Value(point.description!)
        : const Value.absent(),
      latitude: point.coordinates.latitude,
      longitude: point.coordinates.longitude,
      status: _visitStatusToString(point.status),
      notes: point.notes != null 
        ? Value(point.notes!)
        : const Value.absent(),
      type: _pointTypeToString(point.type),
    );
  }

  static TradingPointsCompanion? tradingPointToDb(
    PointOfInterest point,
    int pointOfInterestId,
  ) {
    if (point is TradingPointOfInterest) {
      // Для упрощения, пока оставлю базовые поля
      return TradingPointsCompanion.insert(
        pointOfInterestId: pointOfInterestId,
      );
    }
    return null;
  }

  static RouteStatus _stringToRouteStatus(String status) {
    return RouteStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => RouteStatus.planned,
    );
  }

  static String _routeStatusToString(RouteStatus status) {
    return status.name;
  }

  static VisitStatus _stringToVisitStatus(String status) {
    return VisitStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => VisitStatus.planned,
    );
  }

  static String _visitStatusToString(VisitStatus status) {
    return status.name;
  }

  static PointType _stringToPointType(String type) {
    return PointType.values.firstWhere(
      (t) => t.name == type,
      orElse: () => PointType.regular,
    );
  }

  static String _pointTypeToString(PointType type) {
    return type.name;
  }

  // Public методы для использования в репозитории
  static VisitStatus stringToVisitStatus(String status) {
    return _stringToVisitStatus(status);
  }

  static PointType stringToPointType(String type) {
    return _stringToPointType(type);
  }

  // Методы для работы с TradingPoint сущностями
  static TradingPoint tradingPointFromDb(TradingPointEntity dbEntity) {
    return TradingPoint(
      id: dbEntity.id,
      externalId: dbEntity.externalId,
      name: dbEntity.name,
      inn: dbEntity.inn,
      region: _requireRegion(dbEntity.region, dbEntity.externalId),
      latitude: dbEntity.latitude,
      longitude: dbEntity.longitude,
      createdAt: dbEntity.createdAt,
      updatedAt: dbEntity.updatedAt,
    );
  }

  static TradingPointEntitiesCompanion tradingPointToCompanion(TradingPoint point) {
    return TradingPointEntitiesCompanion.insert(
      externalId: point.externalId,
      name: point.name,
      inn: point.inn != null 
        ? Value(point.inn!)
        : const Value.absent(),
      region: Value(point.region),
      latitude: point.latitude != null
          ? Value(point.latitude!)
          : const Value.absent(),
      longitude: point.longitude != null
          ? Value(point.longitude!)
          : const Value.absent(),
      updatedAt: point.updatedAt != null 
        ? Value(point.updatedAt!)
        : const Value.absent(),
    );
  }

  static String _requireRegion(String? region, String externalId) {
    if (region == null || region.trim().isEmpty) {
      throw StateError('Trading point $externalId is missing a region');
    }
    return region;
  }
}
