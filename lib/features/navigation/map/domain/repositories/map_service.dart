import '../entities/map_point.dart';
import '../entities/map_bounds.dart';

/// Абстракция для работы с картами
/// Позволяет легко менять провайдеров (OSM, Google Maps, Apple Maps)
abstract class MapService {
  String getTileUrl(int x, int y, int z);

  MapPoint getCenterForPoints(List<MapPoint> points);

  int getOptimalZoom(MapBounds bounds, double mapWidth, double mapHeight);

  /// Конвертация координат в пиксели тайла
  MapPoint coordinatesToTile(MapPoint coordinates, int zoom);

  /// Конвертация пикселей тайла в координаты
  MapPoint tileToCoordinates(MapPoint tile, int zoom);

  /// Построение URL для статической карты (если поддерживается)
  String? getStaticMapUrl(MapBounds bounds, int width, int height);

  String get providerName;
  String get attribution;
  int get maxZoom;
  int get minZoom;
}
