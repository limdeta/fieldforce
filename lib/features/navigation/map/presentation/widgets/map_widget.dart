import 'dart:math';

import 'package:fieldforce/features/navigation/tracking/domain/enums/track_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/map_point.dart';
import '../../domain/repositories/map_service.dart';
import '../../../../../app/domain/adapters/route_map_adapter.dart';
import '../../data/repositories/osm_map_service.dart';
import '../../../../../app/domain/entities/route.dart' as domain;
import '../../../../../app/services/user_initialization_service.dart';
import '../../../tracking/domain/entities/user_track.dart';
import 'route_polyline.dart';

/// Основной виджет карты с поддержкой различных провайдеров
class MapWidget extends StatefulWidget {
  final domain.Route? route;
  final MapPoint? center;
  final double? initialZoom;
  final Function(MapPoint)? onTap;
  final Function(MapPoint)? onLongPress;
  
  /// Трек для отображения (может быть null)
  final UserTrack? track;
  
  final List<LatLng> routePolylinePoints;

  const MapWidget({
    super.key,
    this.route,
    this.center,
    this.initialZoom,
    this.onTap,
    this.onLongPress,
    this.track,
    this.routePolylinePoints = const [],
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late final MapController _mapController;
  late final MapService _mapService;
  
  // Центр карты и масштаб по умолчанию (Владивосток)
  static const LatLng _defaultCenter = LatLng(43.1056, 131.8735);
  static const double _defaultZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _mapService = OSMMapService(); // В будущем можно inject через DI
  }

  @override
  void dispose() {
    _saveMapState(); // Сохраняем состояние при выходе
    _mapController.dispose();
    super.dispose();
  }

  /// Сохраняет текущее состояние карты
  void _saveMapState() {
    final preferencesService = UserInitializationService.getPreferencesService();
    if (preferencesService != null) {
      final camera = _mapController.camera;
      preferencesService.setMapState(
        centerLat: camera.center.latitude,
        centerLng: camera.center.longitude,
        zoom: camera.zoom,
      );
    }
  }

  /// Получает центр карты на основе маршрута или переданного центра
  LatLng _getMapCenter() {
    if (widget.center != null) {
      return LatLng(widget.center!.latitude, widget.center!.longitude);
    }

    final preferencesService = UserInitializationService.getPreferencesService();
    if (preferencesService != null) {
      final savedState = preferencesService.getMapState();
      if (savedState != null) {
        return LatLng(savedState.centerLat, savedState.centerLng);
      }
    }

    // Если есть маршрут - центрируем по нему
    if (widget.route != null && widget.route!.pointsOfInterest.isNotEmpty) {
      final centerPoint = RouteMapAdapter.getRouteCenterPoint(widget.route!);
      if (centerPoint != null) {
        return LatLng(centerPoint.latitude, centerPoint.longitude);
      }
    }

    return _defaultCenter;
  }

  /// Получает оптимальный масштаб на основе маршрута
  double _getMapZoom() {
    // 1. Приоритет: явно переданный зум
    if (widget.initialZoom != null) {
      return widget.initialZoom!;
    }

    // 2. Проверяем сохраненное состояние карты
    final preferencesService = UserInitializationService.getPreferencesService();
    if (preferencesService != null) {
      final savedState = preferencesService.getMapState();
      if (savedState != null) {
        return savedState.zoom;
      }
    }

    // 3. Если есть маршрут - рассчитываем оптимальный зум
    if (widget.route != null && widget.route!.pointsOfInterest.isNotEmpty) {
      final bounds = RouteMapAdapter.getRouteBounds(widget.route!);
      if (bounds != null) {
        final context = this.context;
        final size = MediaQuery.of(context).size;
        
        // Получаем оптимальный масштаб, но ограничиваем его
        final optimalZoom = _mapService.getOptimalZoom(bounds, size.width, size.height);
        final clampedZoom = optimalZoom.toDouble().clamp(8.0, 16.0);
        return clampedZoom;
      }
    }

    return _defaultZoom;
  }

  /// Создает маркеры для точек маршрута
  List<Marker> _buildRouteMarkers() {
    if (widget.route == null) return [];

    return widget.route!.pointsOfInterest
        .map((poi) => _buildMarkerForPOI(poi))
        .toList();
  }

  /// Создает маркер для точки интереса
  Marker _buildMarkerForPOI(dynamic poi) {
    final colorName = RouteMapAdapter.getMarkerColorByStatus(poi.status);
    final iconName = RouteMapAdapter.getMarkerIconByType(poi.type);
    Color markerColor = _getColorFromName(colorName);
    IconData markerIcon = _getIconFromName(iconName);

    return Marker(
      point: LatLng(poi.coordinates.latitude, poi.coordinates.longitude),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _onMarkerTap(poi),
        child: Container(
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            markerIcon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'blue':
        return Colors.blue;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'warehouse':
        return Icons.warehouse;
      case 'business':
        return Icons.business;
      case 'home':
        return Icons.home;
      case 'flag':
        return Icons.flag;
      case 'store':
        return Icons.store;
      case 'meeting_room':
        return Icons.meeting_room;
      case 'restaurant':
        return Icons.restaurant;
      case 'location_on':
      default:
        return Icons.location_on;
    }
  }

  void _onMarkerTap(dynamic poi) {
    _showPOIDetails(poi);
  }

  void _showPOIDetails(dynamic poi) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              poi.name ?? 'Точка маршрута',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (poi.description != null) ...[
              Text('Описание: ${poi.description}'),
              const SizedBox(height: 4),
            ],
            Text('Тип: ${RouteMapAdapter.getTypeDisplayText(poi.type)}'),
            Text('Статус: ${RouteMapAdapter.getStatusDisplayText(poi.status)}'),
            if (poi.plannedArrivalTime != null) ...[
              const SizedBox(height: 4),
              Text('Планируем����е время: ${poi.plannedArrivalTime}'),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Основная карта
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _getMapCenter(),
            initialZoom: _getMapZoom(),
            minZoom: _mapService.minZoom.toDouble(),
            maxZoom: _mapService.maxZoom.toDouble(),
            onPositionChanged: (MapCamera position, bool hasGesture) {
              // Сохраняем состояние карты при каждом изменении позиции/зума
              if (hasGesture) {
                // Сохраняем с небольшой задержкой чтобы не спамить
                Future.delayed(const Duration(milliseconds: 500), () {
                  _saveMapState();
                });
              }
            },
            onTap: (tapPosition, point) {
              if (widget.onTap != null) {
                widget.onTap!(MapPoint(latitude: point.latitude, longitude: point.longitude));
              }
            },
            onLongPress: (tapPosition, point) {
              if (widget.onLongPress != null) {
                widget.onLongPress!(MapPoint(latitude: point.latitude, longitude: point.longitude));
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: _mapService.getTileUrl(0, 0, 0).replaceAll('/0/0/0.png', '/{z}/{x}/{y}.png'),
              userAgentPackageName: 'com.fieldforce.app.fieldforce',
              maxZoom: _mapService.maxZoom.toDouble(),
            ),
            
            // Слой GPS трека (polyline) - простое отображение одного трека
            if (widget.track != null)
              PolylineLayer(polylines: _buildTrackPolylines()),
            
            // Слой маршрута (построенного через OSRM)
            if (widget.routePolylinePoints.isNotEmpty)
              RoutePolyline(points: widget.routePolylinePoints),

            if (widget.route != null)
              MarkerLayer(
                markers: _buildRouteMarkers(),
              ),
          ],
        ),

        _buildMapControls(context),
      ],
    );
  }

  /// Строит кнопки управления картой
  Widget _buildMapControls(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 88,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Кнопка текущего положения
          FloatingActionButton(
            mini: true,
            heroTag: "location",
            onPressed: _onLocationPressed,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            child: const Icon(Icons.my_location),
          ),
          
          const SizedBox(height: 8),

          FloatingActionButton(
            mini: true,
            heroTag: "zoom_in",
            onPressed: _onZoomInPressed,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            child: const Icon(Icons.add),
          ),
          
          const SizedBox(height: 8),
          
          // Кнопка уменьшения
          FloatingActionButton(
            mini: true,
            heroTag: "zoom_out",
            onPressed: _onZoomOutPressed,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            child: const Icon(Icons.remove),
          ),
        ],
      ),
    );
  }

  /// Обработчик кнопки текущего положения
  void _onLocationPressed() {
    // TODO: Получить текущее положение пользователя и переместить карту
    // Пока центрируем на Владивостоке
    const vladivostokCenter = LatLng(43.1056, 131.8735);
    _mapController.move(vladivostokCenter, 12.0);
    _saveMapState(); // Сохраняем новое состояние
  }

  /// Обработчик кнопки увеличения
  void _onZoomInPressed() {
    final currentZoom = _mapController.camera.zoom;
    final newZoom = (currentZoom + 1).clamp(_mapService.minZoom.toDouble(), _mapService.maxZoom.toDouble());
    _mapController.move(_mapController.camera.center, newZoom);
    _saveMapState(); // Сохраняем новое состояние
  }

  /// Обработчик кнопки уменьшения  
  void _onZoomOutPressed() {
    final currentZoom = _mapController.camera.zoom;
    final newZoom = (currentZoom - 1).clamp(_mapService.minZoom.toDouble(), _mapService.maxZoom.toDouble());
    _mapController.move(_mapController.camera.center, newZoom);
    _saveMapState(); // Сохраняем новое состояние
  }

  /// Создает маркеры начала/конца GPS треков (не реализовано)
  // List<Marker> _buildTrackMarkers() {
  //   final markers = <Marker>[];
  //   return markers;
  // }


  // Кэш для оптимизации полилиний треков
  static final Map<String, List<Polyline>> _polylineCache = {};
  
  /// Создает полилинии для отображения GPS трека
  /// Отдельно рисует сохраненные сегменты и live буфер
  List<Polyline> _buildTrackPolylines() {
    final track = widget.track;
    if (track == null) {
      return [];
    }

    final polylines = <Polyline>[];
    int totalPoints = 0;

    // 1. Рисуем сохраненные сегменты из БД
    // 2. Рисуем live буфер
    for (int segmentIndex = 0; segmentIndex < track.segments.length; segmentIndex++) {
      final segment = track.segments[segmentIndex];
      totalPoints += segment.pointCount.toInt();

      if (segment.isEmpty) continue;

      final segmentPoints = <LatLng>[];

      // Прореживание для производительности (только для больших сегментов)
      final maxPointsPerSegment = 100;
      final skipFactor = segment.pointCount > maxPointsPerSegment
          ? (segment.pointCount / maxPointsPerSegment).ceil()
          : 1;

      // Добавляем точки сегмента
      for (int i = 0; i < segment.pointCount; i += skipFactor) {
        final (lat, lng) = segment.getCoordinates(i);
        segmentPoints.add(LatLng(lat, lng));
      }

      // Всегда добавляем последнюю точку сегмента для точности
      if (segment.pointCount > 1 && skipFactor > 1) {
        final (lat, lng) = segment.getCoordinates(segment.pointCount.toInt() - 1);
        if (segmentPoints.isEmpty ||
            segmentPoints.last.latitude != lat ||
            segmentPoints.last.longitude != lng) {
          segmentPoints.add(LatLng(lat, lng));
        }
      }

      if (segmentPoints.length < 2) continue;

      final isLiveSegment = track.isSegmentLive(segmentIndex);

      Color segmentColor;
      double strokeWidth;
      double opacity;

      // TODO вынести в настройки а не хардкодить
      if (isLiveSegment) {
        segmentColor = const Color(0xFFFF006A);
        strokeWidth = 5.0;
        opacity = 0.9;
      } else {
        segmentColor = const Color(0xFFFF1493); // Hot Pink
        strokeWidth = 4.0;
        opacity = 0.7;
      }

      final polyline = Polyline(
        points: segmentPoints,
        strokeWidth: strokeWidth,
        color: segmentColor.withOpacity(opacity),
      );

      polylines.add(polyline);
    }

    // Cоединяем разные сегменты
    for (int i = 0; i < track.segments.length - 1; i++) {
      final currentSegment = track.segments[i];
      final nextSegment = track.segments[i + 1];

      if (currentSegment.isNotEmpty && nextSegment.isNotEmpty) {
        final (lat1, lng1) = currentSegment.getCoordinates(currentSegment.pointCount.toInt() - 1);
        final (lat2, lng2) = nextSegment.getCoordinates(0);

        // Calculate distance between segments
        final distance = _calculateDistance(lat1, lng1, lat2, lng2);

        // Соединяем если не дальше километра TODO вынести в настройки
        if (distance < 1000) {
          polylines.add(
            Polyline(
              points: [LatLng(lat1, lng1), LatLng(lat2, lng2)],
              color: const Color(0xFFFF1493),
              strokeWidth: 4.0,
            ),
          );
        }
      }
    }
    return polylines;
  }

  /// Calculate distance between two points in meters using Haversine formula
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // Earth's radius in meters
    final double dLat = (lat2 - lat1) * (pi / 180);
    final double dLng = (lng2 - lng1) * (pi / 180);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) * cos(lat2 * (pi / 180)) *
            sin(dLng / 2) * sin(dLng / 2);
    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  /// Очищает кэш полилиний при изменении треков (оптимизация памяти)
  void _clearPolylineCache() {
    if (_polylineCache.isNotEmpty) {
      _polylineCache.clear();
      print('🧹 MapWidget: Кэш полилиний очищен для экономии памяти');
    }
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Очищаем кэш при изменении трека
    if (oldWidget.track?.id != widget.track?.id) {
      _clearPolylineCache();
    }
  }

}
