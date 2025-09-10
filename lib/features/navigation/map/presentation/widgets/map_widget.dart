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
  
  // Конфигурация цветов и стилей треков
  static const Color _trackColor = Colors.pink; // HOT PINK для всех линий трека
  static const Color _connectionLineColor = Colors.pink; // HOT PINK и для соединений
  static const double _trackStrokeWidth = 4.0;
  static const double _connectionStrokeWidth = 4.0; // Одинаковая толщина
  static const double _connectionOpacity = 1.0; // Без прозрачности

  /// Создает полилинии для отображения GPS трека
  List<Polyline> _buildTrackPolylines() {
    final track = widget.track;
    if (track == null) {
      return [];
    }

    // Создаем кэш-ключ с учетом live сегмента
    String cacheKey;
    if (track.liveSegmentIndex != null) {
      // Для треков с live сегментом учитываем totalPoints для инвалидации при новых точках
      cacheKey = '${track.id}_${track.segments.length}_${track.totalPoints}_live${track.liveSegmentIndex}';
    } else {
      // Для завершенных треков используем стабильный ключ
      cacheKey = '${track.id}_${track.segments.length}';
    }
    
    // Проверяем кэш
    if (_polylineCache.containsKey(cacheKey)) {
      return _polylineCache[cacheKey]!;
    }

    final polylines = <Polyline>[];

    // 1. Рендерим основные сегменты
    for (int i = 0; i < track.segments.length; i++) {
      final segment = track.segments[i];
      if (segment.pointCount < 2) continue; // Нужно минимум 2 точки для линии

      // Извлекаем координаты из CompactTrack
      final points = <LatLng>[];
      for (int j = 0; j < segment.pointCount; j++) {
        final (lat, lng) = segment.getCoordinates(j);
        points.add(LatLng(lat, lng));
      }

      // Все сегменты одинакового цвета HOT PINK
      polylines.add(
        Polyline(
          points: points,
          strokeWidth: _trackStrokeWidth,
          color: _trackColor,
        ),
      );
    }

    // 2. Добавляем соединительные линии между сегментами
    final connectionLines = _buildConnectionLines(track);
    polylines.addAll(connectionLines);

    // Кэшируем результат
    _polylineCache[cacheKey] = polylines;
    return polylines;
  }

  /// Создает соединительные линии между сегментами
  List<Polyline> _buildConnectionLines(UserTrack track) {
    final connectionLines = <Polyline>[];
    
    for (int i = 0; i < track.segments.length - 1; i++) {
      final currentSegment = track.segments[i];
      final nextSegment = track.segments[i + 1];
      
      if (currentSegment.pointCount == 0 || nextSegment.pointCount == 0) continue;
      
      // Получаем последнюю точку текущего сегмента
      final (endLat, endLng) = currentSegment.getCoordinates(currentSegment.pointCount - 1);
      
      // Получаем первую точку следующего сегмента
      final (startLat, startLng) = nextSegment.getCoordinates(0);
      
      // Создаем соединительную линию того же цвета и толщины
      connectionLines.add(
        Polyline(
          points: [
            LatLng(endLat, endLng),
            LatLng(startLat, startLng),
          ],
          strokeWidth: _connectionStrokeWidth,
          color: _connectionLineColor.withOpacity(_connectionOpacity),
        ),
      );
    }
    
    return connectionLines;
  }

  /// Очищает кэш полилиний при изменении треков (оптимизация памяти)
  void _clearPolylineCache() {
    if (_polylineCache.isNotEmpty) {
      _polylineCache.clear();
    }
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Очищаем кэш при изменении трека
    if (oldWidget.track?.id != widget.track?.id) {
      _clearPolylineCache();
    }
    // Также очищаем кэш если изменилось количество точек в live треке
    else if (oldWidget.track != null && widget.track != null) {
      final oldTrack = oldWidget.track!;
      final newTrack = widget.track!;
      
      // Если есть live сегмент и изменилось количество точек - очищаем кэш
      if (newTrack.liveSegmentIndex != null && 
          oldTrack.totalPoints != newTrack.totalPoints) {
        _clearPolylineCache();
      }
    }
  }

}
