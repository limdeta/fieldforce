import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../features/navigation/map/presentation/widgets/map_widget.dart';
import '../../../features/navigation/tracking/domain/entities/user_track.dart';
import '../../../features/navigation/tracking/domain/services/location_tracking_service.dart';
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
  
  /// Сервис отслеживания (для трекинга)
  final LocationTrackingService? trackingService;
  
  /// Показывать ли текущий трек пользователя
  final bool showUserTrack;
  
  /// Исторические треки для отображения
  final List<UserTrack> historicalTracks;
  
  /// Точки полилинии маршрута (для отображения построенного пути)
  final List<LatLng> routePolylinePoints;

  const CombinedMapWidget({
    super.key,
    this.route,
    this.center,
    this.initialZoom,
    this.onTap,
    this.onLongPress,
    this.trackingService,
    this.showUserTrack = false,
    this.historicalTracks = const [],
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
      trackingService: trackingService,
      showUserTrack: showUserTrack,
      historicalTracks: historicalTracks,
      routePolylinePoints: routePolylinePoints,
    );
  }
}
