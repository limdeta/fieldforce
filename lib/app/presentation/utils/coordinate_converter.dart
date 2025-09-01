import 'package:latlong2/latlong.dart';
import '../../../features/navigation/map/domain/entities/map_point.dart';

/// Утилиты для конвертации между типами координат
/// Помогает в интеграции между модулями в app-слое
class CoordinateConverter {
  /// Конвертирует LatLng в MapPoint
  static MapPoint? latLngToMapPoint(LatLng? latLng) {
    if (latLng == null) return null;
    return MapPoint(latitude: latLng.latitude, longitude: latLng.longitude);
  }
  
  /// Конвертирует MapPoint в LatLng
  static LatLng? mapPointToLatLng(MapPoint? mapPoint) {
    if (mapPoint == null) return null;
    return LatLng(mapPoint.latitude, mapPoint.longitude);
  }
  
  /// Конвертирует callback для LatLng в callback для MapPoint
  static Function(MapPoint)? convertLatLngCallback(Function(LatLng)? callback) {
    if (callback == null) return null;
    return (MapPoint mapPoint) {
      final latLng = mapPointToLatLng(mapPoint);
      if (latLng != null) {
        callback(latLng);
      }
    };
  }
}
