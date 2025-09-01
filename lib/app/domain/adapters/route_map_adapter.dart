import '../../../features/navigation/map/domain/entities/map_point.dart';
import '../../../features/navigation/map/domain/entities/map_bounds.dart';
import '../../../features/shop/domain/entities/route.dart' as domain;
import '../../../features/shop/domain/entities/point_of_interest.dart';

/// Адаптер для преобразования данных между модулями Route и Map
class RouteMapAdapter {
  /// Преобразует маршрут в список точек для карты
  static List<MapPoint> routeToMapPoints(domain.Route route) {
    return route.pointsOfInterest
        .map((poi) => _poiToMapPoint(poi))
        .toList();
  }

  static MapPoint _poiToMapPoint(PointOfInterest poi) {
    return MapPoint(
      latitude: poi.coordinates.latitude,
      longitude: poi.coordinates.longitude,
      metadata: {
        'id': poi.id,
        'name': poi.name,
        'description': poi.description,
        'type': poi.type.toString(),
        'status': poi.status.toString(),
        'plannedArrivalTime': poi.plannedArrivalTime?.toIso8601String(),
        'actualArrivalTime': poi.actualArrivalTime?.toIso8601String(),
        'notes': poi.notes,
        // Удаляем проверку TradingPointOfInterest пока не разберемся с типами
      },
    );
  }

  /// Получает центр карты для маршрута
  static MapPoint? getRouteCenterPoint(domain.Route route) {
    final points = routeToMapPoints(route);
    if (points.isEmpty) return null;

    // Вычисляем центр как средние координаты всех точек
    final avgLat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final avgLng = points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    
    return MapPoint(latitude: avgLat, longitude: avgLng);
  }

  /// Получает границы карты для маршрута
  static MapBounds? getRouteBounds(domain.Route route) {
    final points = routeToMapPoints(route);
    if (points.isEmpty) return null;

    return MapBounds.fromPoints(points);
  }

  /// Получает цвет маркера по статусу точки
  static String getMarkerColorByStatus(VisitStatus status) {
    switch (status) {
      case VisitStatus.completed:
        return 'green';
      case VisitStatus.arrived:
        return 'orange';
      case VisitStatus.enRoute:
        return 'yellow';
      case VisitStatus.planned:
        return 'blue';
      case VisitStatus.skipped:
        return 'grey';
    }
  }

  /// Получает иконку маркера по типу точки
  static String getMarkerIconByType(PointType type) {
    switch (type) {
      case PointType.warehouse:
        return 'warehouse';
      case PointType.office:
        return 'business';
      case PointType.startPoint:
        return 'home';
      case PointType.endPoint:
        return 'flag';
      case PointType.client:
        return 'store';
      case PointType.meeting:
        return 'meeting_room';
      case PointType.break_:
        return 'restaurant';
      case PointType.regular:
        return 'location_on';
    }
  }

  /// Получает текстовое описание статуса для UI
  static String getStatusDisplayText(VisitStatus status) {
    switch (status) {
      case VisitStatus.completed:
        return 'Выполнено';
      case VisitStatus.arrived:
        return 'Прибыл';
      case VisitStatus.enRoute:
        return 'В пути';
      case VisitStatus.planned:
        return 'Запланировано';
      case VisitStatus.skipped:
        return 'Пропущено';
    }
  }

  static String getTypeDisplayText(PointType type) {
    switch (type) {
      case PointType.warehouse:
        return 'Склад';
      case PointType.office:
        return 'Офис';
      case PointType.startPoint:
        return 'Начальная точка';
      case PointType.endPoint:
        return 'Конечная точка';
      case PointType.client:
        return 'Клиент';
      case PointType.meeting:
        return 'Встреча';
      case PointType.break_:
        return 'Перерыв';
      case PointType.regular:
        return 'Торговая точка';
    }
  }
}
