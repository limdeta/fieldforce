import 'dart:math' as math;
import '../../domain/entities/map_point.dart';
import '../../domain/entities/map_bounds.dart';
import '../../domain/repositories/map_service.dart';

/// Реализация сервиса карт для OpenStreetMap
class OSMMapService implements MapService {
  static const String _tileServerUrl = 'https://tile.openstreetmap.org';

  @override
  String getTileUrl(int x, int y, int z) {
    return '$_tileServerUrl/$z/$x/$y.png';
  }

  @override
  MapPoint getCenterForPoints(List<MapPoint> points) {
    if (points.isEmpty) {
      return const MapPoint(latitude: 0, longitude: 0);
    }

    final bounds = MapBounds.fromPoints(points);
    return bounds.center;
  }

  @override
  int getOptimalZoom(MapBounds bounds, double mapWidth, double mapHeight) {
    // Вычисляем масштаб на основе размеров области и размера карты
    const double worldWidth = 256.0; // ширина мира в пикселях на zoom 0
    
    final double latRad = bounds.center.latitude * (math.pi / 180);
    final double latAdjustment = math.cos(latRad);
    
    final double boundsWidth = (bounds.east - bounds.west) * latAdjustment;
    final double boundsHeight = bounds.north - bounds.south;
    
    final int zoomX = (math.log(mapWidth / worldWidth / boundsWidth) / math.ln2).floor();
    final int zoomY = (math.log(mapHeight / worldWidth / boundsHeight) / math.ln2).floor();
    
    final int zoom = math.min(zoomX, zoomY);
    return math.max(minZoom, math.min(maxZoom, zoom));
  }

  @override
  MapPoint coordinatesToTile(MapPoint coordinates, int zoom) {
    final double latRad = coordinates.latitude * (math.pi / 180);
    final int n = math.pow(2, zoom).toInt();
    
    final double x = (coordinates.longitude + 180.0) / 360.0 * n;
    final double y = (1.0 - (math.log(math.tan(latRad) + (1 / math.cos(latRad))) / math.pi)) / 2.0 * n;
    
    return MapPoint(latitude: y, longitude: x);
  }

  @override
  MapPoint tileToCoordinates(MapPoint tile, int zoom) {
    final int n = math.pow(2, zoom).toInt();
    
    final double longitude = tile.longitude / n * 360.0 - 180.0;
    final double latRad = math.atan(math.exp(math.pi * (1 - 2 * tile.latitude / n)) - math.exp(-math.pi * (1 - 2 * tile.latitude / n))) / 2;
    final double latitude = latRad * (180.0 / math.pi);
    
    return MapPoint(latitude: latitude, longitude: longitude);
  }

  @override
  String? getStaticMapUrl(MapBounds bounds, int width, int height) {
    // OSM не предоставляет статические карты в базовом API
    return null;
  }

  @override
  String get providerName => 'OpenStreetMap';

  @override
  String get attribution => '© OpenStreetMap contributors';

  @override
  int get maxZoom => 18;

  @override
  int get minZoom => 1;
}
