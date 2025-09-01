import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fieldforce/features/navigation/map/domain/entities/map_point.dart';
import 'path_prediction_service.dart';

class OsrmPathPredictionService implements PathPredictionService {
  /// Старый метод: возвращает оптимальный порядок точек (TSP, не нужен если порядок фиксирован)
  @override
  Future<List<MapPoint>> predictPaths(List<MapPoint> points) async {
    // Для совместимости, просто возвращаем исходный порядок
    return points;
  }

  /// Новый метод: возвращает маршрут по дорогам между точками в заданном порядке
  /// Возвращает: geometry (GeoJSON LineString) и список MapPoint (точки линии маршрута)
  Future<RouteGeometryResult> predictRouteGeometry(List<MapPoint> points) async {
    if (points.length < 2) {
      throw ArgumentError('At least two points are required');
    }
    final coords = points.map((p) => '${p.longitude},${p.latitude}').join(';');
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson',
    );
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch route: ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    if (data['code'] != 'Ok') {
      throw Exception('OSRM error: ${data['message']}');
    }
    // geometry: { type: "LineString", coordinates: [[lon,lat],[lon,lat],...] }
    final geometry = data['routes'][0]['geometry'];
    final List coordsList = geometry['coordinates'];
    final List<MapPoint> routePoints = coordsList
        .map<MapPoint>((c) => MapPoint(latitude: c[1], longitude: c[0]))
        .toList();
    return RouteGeometryResult(
      geometry: geometry,
      routePoints: routePoints,
    );
  }
}

/// Результат маршрута: geojson geometry и список MapPoint (точки линии маршрута)
class RouteGeometryResult {
  final Map<String, dynamic> geometry; // GeoJSON LineString
  final List<MapPoint> routePoints;    // Точки линии маршрута
  RouteGeometryResult({
    required this.geometry,
    required this.routePoints,
  });
}