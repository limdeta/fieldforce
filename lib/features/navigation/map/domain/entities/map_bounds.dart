import 'map_point.dart';

/// Границы области карты
class MapBounds {
  final double north;
  final double south;
  final double east;
  final double west;

  const MapBounds({
    required this.north,
    required this.south,
    required this.east,
    required this.west,
  });

  factory MapBounds.fromPoints(List<MapPoint> points) {
    if (points.isEmpty) {
      return const MapBounds(north: 0, south: 0, east: 0, west: 0);
    }

    double north = points.first.latitude;
    double south = points.first.latitude;
    double east = points.first.longitude;
    double west = points.first.longitude;

    for (final point in points) {
      if (point.latitude > north) north = point.latitude;
      if (point.latitude < south) south = point.latitude;
      if (point.longitude > east) east = point.longitude;
      if (point.longitude < west) west = point.longitude;
    }

    return MapBounds(north: north, south: south, east: east, west: west);
  }

  /// Центр области
  MapPoint get center {
    return MapPoint(
      latitude: (north + south) / 2,
      longitude: (east + west) / 2,
    );
  }

  /// Расширяет границы на заданный отступ (в градусах)
  MapBounds expand(double padding) {
    return MapBounds(
      north: north + padding,
      south: south - padding,
      east: east + padding,
      west: west - padding,
    );
  }

  /// Проверяет, содержится ли точка в границах
  bool contains(MapPoint point) {
    return point.latitude >= south &&
        point.latitude <= north &&
        point.longitude >= west &&
        point.longitude <= east;
  }

  @override
  String toString() => 'MapBounds(N:$north, S:$south, E:$east, W:$west)';
}
