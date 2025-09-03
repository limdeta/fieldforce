import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../features/navigation/map/presentation/widgets/map_widget.dart';
import '../../../features/navigation/tracking/domain/entities/user_track.dart';
import '../../../features/shop/domain/entities/route.dart' as shop;
import '../utils/coordinate_converter.dart';

/// Комбинированный виджет карты для app-слоя
/// Объединяет отображение маршрутов (Route) и треков (Track)
/// Предоставляет единый интерфейс для координации между модулями
class CombinedMapWidget extends StatelessWidget {
  /// Маршрут для отображения
  final shop.Route? route;
  
  /// Центр карты (в удобных LatLng координатах)
  final LatLng? center;
  
  /// Начальный зум
  final double? initialZoom;
  
  /// Callback при тапе на карту (в удобных LatLng координатах)
  final void Function(LatLng)? onTap;
  
  /// Callback при долгом нажатии (в удобных LatLng координатах)
  final void Function(LatLng)? onLongPress;
  
  /// Трек для отображения (может быть null)
  final UserTrack? track;
  
  /// Точки полилинии маршрута (для отображения построенного пути)
  final List<LatLng> routePolylinePoints;

  const CombinedMapWidget({
    super.key,
    this.route,
    this.center,
    this.initialZoom,
    this.onTap,
    this.onLongPress,
    this.track,
    this.routePolylinePoints = const [],
    // Для обратной совместимости - DEPRECATED
    @Deprecated('Use track parameter instead') List<UserTrack>? historicalTracks,
  });

  @override
  Widget build(BuildContext context) {
    // Конвертируем LatLng параметры в MapPoint для базового MapWidget
    return MapWidget(
      route: route,
      center: CoordinateConverter.latLngToMapPoint(center),
      initialZoom: initialZoom,
      onTap: CoordinateConverter.convertLatLngCallback(onTap),
      onLongPress: CoordinateConverter.convertLatLngCallback(onLongPress),
      track: track,
      routePolylinePoints: routePolylinePoints,
    );
  }
}
