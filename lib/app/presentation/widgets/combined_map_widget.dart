import 'package:fieldforce/app/presentation/utils/coordinate_converter.dart';
import 'package:fieldforce/features/navigation/map/presentation/widgets/map_widget.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as shop;


/// Комбинированный виджет карты для app-слоя
/// Объединяет отображение маршрутов (Route) и треков (Track)
/// Предоставляет единый интерфейс для координации между модулями
class CombinedMapWidget extends StatelessWidget {
  /// Маршрут для отображения
  final shop.Route? route;

  final LatLng? center;
  final double? initialZoom;

  final void Function(LatLng)? onTap;
  final void Function(LatLng)? onLongPress;
  final UserTrack? track;
  final CompactTrack? liveBuffer;
  final LatLng? currentUserLocation;
  
  /// Направление движения пользователя (в градусах, 0-360)
  final double? currentUserBearing;
  
  /// Максимальное расстояние для соединения сегментов (в метрах)
  final double? maxConnectionDistance;
  
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
    this.liveBuffer,
    this.currentUserLocation,
    this.currentUserBearing,
    this.maxConnectionDistance,
    this.routePolylinePoints = const [],
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
      liveBuffer: liveBuffer,
      currentUserLocation: currentUserLocation,
      currentUserBearing: currentUserBearing,
      maxConnectionDistance: maxConnectionDistance,
      routePolylinePoints: routePolylinePoints,
    );
  }
}
