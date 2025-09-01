import '../../../../features/shop/domain/entities/route.dart' as domain;
import '../../../features/shop/domain/entities/point_of_interest.dart' as domain;
import '../../../features/shop/domain/entities/trading_point_of_interest.dart' as domain;
import '../../../features/shop/domain/entities/trading_point.dart' as domain;
import 'package:drift/drift.dart';
import '../app_database.dart' as db;

class RouteMapper {
  static domain.Route fromDb(
    db.RouteData dbRoute,
    List<domain.PointOfInterest> pointsOfInterest,
  ) {
    return domain.Route(
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

  static db.RoutesCompanion toDb(domain.Route route, {int? employeeId}) {
    return db.RoutesCompanion.insert(
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

  static db.PointsOfInterestCompanion pointToDb(
    domain.PointOfInterest point,
    int routeId,
  ) {
    return db.PointsOfInterestCompanion.insert(
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

  static db.TradingPointsCompanion? tradingPointToDb(
    domain.PointOfInterest point,
    int pointOfInterestId,
  ) {
    if (point is domain.TradingPointOfInterest) {
      // Для упрощения, пока оставлю базовые поля
      return db.TradingPointsCompanion.insert(
        pointOfInterestId: pointOfInterestId,
      );
    }
    return null;
  }

  static domain.RouteStatus _stringToRouteStatus(String status) {
    return domain.RouteStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => domain.RouteStatus.planned,
    );
  }

  static String _routeStatusToString(domain.RouteStatus status) {
    return status.name;
  }

  static domain.VisitStatus _stringToVisitStatus(String status) {
    return domain.VisitStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => domain.VisitStatus.planned,
    );
  }

  static String _visitStatusToString(domain.VisitStatus status) {
    return status.name;
  }

  static domain.PointType _stringToPointType(String type) {
    return domain.PointType.values.firstWhere(
      (t) => t.name == type,
      orElse: () => domain.PointType.regular,
    );
  }

  static String _pointTypeToString(domain.PointType type) {
    return type.name;
  }

  // Public методы для использования в репозитории
  static domain.VisitStatus stringToVisitStatus(String status) {
    return _stringToVisitStatus(status);
  }

  static domain.PointType stringToPointType(String type) {
    return _stringToPointType(type);
  }

  // Методы для работы с TradingPoint сущностями
  static domain.TradingPoint tradingPointFromDb(db.TradingPointEntity dbEntity) {
    return domain.TradingPoint(
      id: dbEntity.id,
      externalId: dbEntity.externalId,
      name: dbEntity.name,
      inn: dbEntity.inn,
      createdAt: dbEntity.createdAt,
      updatedAt: dbEntity.updatedAt,
    );
  }

  static db.TradingPointEntitiesCompanion tradingPointToCompanion(domain.TradingPoint point) {
    return db.TradingPointEntitiesCompanion.insert(
      externalId: point.externalId,
      name: point.name,
      inn: point.inn != null 
        ? Value(point.inn!)
        : const Value.absent(),
      updatedAt: point.updatedAt != null 
        ? Value(point.updatedAt!)
        : const Value.absent(),
    );
  }
}
