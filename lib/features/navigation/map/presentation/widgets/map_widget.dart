import 'package:fieldforce/features/navigation/map/data/repositories/osm_map_service.dart';
import 'package:fieldforce/features/navigation/map/domain/entities/map_point.dart';
import 'package:fieldforce/features/navigation/map/domain/repositories/map_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:fieldforce/app/domain/adapters/route_map_adapter.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as domain;
import 'package:fieldforce/app/services/user_initialization_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
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
  
  /// Live буфер для отображения (текущие точки трекинга)
  final CompactTrack? liveBuffer;
  
  /// Текущее положение пользователя
  final LatLng? currentUserLocation;
  
  /// Направление движения пользователя (в градусах, 0-360)
  final double? currentUserBearing;
  
  /// Максимальное расстояние для соединения сегментов (в метрах)
  final double? maxConnectionDistance;
  
  final List<LatLng> routePolylinePoints;

  const MapWidget({
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
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late final MapController _mapController;
  late final MapService _mapService;

  // Центр карты и масштаб по умолчанию (Владивосток)
  static const LatLng _defaultCenter = LatLng(43.1056, 131.8735);
  static const double _defaultZoom = 12.0;

  // Кэширование последней известной позиции пользователя
  LatLng? _cachedUserLocation;
  double? _cachedUserBearing;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _mapService = OSMMapService(); // В будущем можно inject через DI
    _polylineCache = {}; // Инициализируем кэш
  }

  @override
  void didUpdateWidget(MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Восстанавливаем кэш из старого виджета, если новый не имеет данных
    if (widget.currentUserLocation == null && oldWidget.currentUserLocation != null) {
      _cachedUserLocation = oldWidget.currentUserLocation;
      _cachedUserBearing = oldWidget.currentUserBearing;
    }

    // Обновляем кэш при получении новых данных
    if (widget.currentUserLocation != null) {
      _cachedUserLocation = widget.currentUserLocation;
      _cachedUserBearing = widget.currentUserBearing;
    }
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

  /// Создает все маркеры (маршрута + текущего положения пользователя)
  List<Marker> _buildAllMarkers() {
    final markers = <Marker>[];

    // Маркеры маршрута
    if (widget.route != null) {
      markers.addAll(widget.route!.pointsOfInterest
          .map((poi) => _buildMarkerForPOI(poi)));
    }

    // Маркер текущего положения пользователя
    // Используем текущие данные или кэшированные, если текущие недоступны
    final LatLng? userLocation = widget.currentUserLocation ?? _cachedUserLocation;
    final double? userBearing = widget.currentUserBearing ?? _cachedUserBearing;

    if (userLocation != null) {
      markers.add(_buildCurrentUserMarkerForLocation(userLocation, userBearing));
    }

    return markers;
  }

  /// Создает маркер текущего положения пользователя с направлением
  Marker _buildCurrentUserMarkerForLocation(LatLng location, double? bearing) {
    return Marker(
      point: location,
      width: 32,
      height: 32,
      child: Transform.rotate(
        angle: (bearing ?? 0) * math.pi / 180, // Конвертируем градусы в радианы
        child: CustomPaint(
          painter: TrianglePainter(),
          child: Container(),
        ),
      ),
    );
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

            if (widget.route != null || widget.currentUserLocation != null)
              MarkerLayer(
                markers: _buildAllMarkers(),
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
    // Используем текущую позицию или кэшированную, если текущая недоступна
    final LatLng? userLocation = widget.currentUserLocation ?? _cachedUserLocation;

    // Если есть положение пользователя, центрируем на нём
    if (userLocation != null) {
      _mapController.move(userLocation, 16.0);
    } else {
      // Иначе центрируем на Владивостоке
      const vladivostokCenter = LatLng(43.1056, 131.8735);
      _mapController.move(vladivostokCenter, 12.0);
    }
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


  // Кэш для оптимизации полилиний треков (упрощенный)
  Map<String, List<Polyline>>? _polylineCache;
  
  // Конфигурация цветов и стилей треков
  static const Color _trackColor = Colors.pink; // HOT PINK для всех линий трека
  static const Color _liveBufferColor = Colors.blue; // Синий для live буфера
  static const Color _connectionColor = Colors.purple; // Фиолетовый для соединений
  static const Color _connectionLineColor = Colors.pink; // HOT PINK и для соединений
  static const double _trackStrokeWidth = 4.0;
  static const double _connectionStrokeWidth = 4.0; // Одинаковая толщина
  static const double _connectionOpacity = 1.0; // Без прозрачности
  
  // Максимальное расстояние для соединения сегментов (в метрах)
  static const double _maxConnectionDistance = 150.0;

  /// Рассчитывает расстояние между двумя точками в метрах (формула гаверсинуса)
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371000; // Радиус Земли в метрах
    
    final double dLat = (lat2 - lat1) * (math.pi / 180.0);
    final double dLng = (lng2 - lng1) * (math.pi / 180.0);
    
    final double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1 * math.pi / 180.0) * math.cos(lat2 * math.pi / 180.0) * 
        math.pow(math.sin(dLng / 2), 2);
    
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c;
  }

  /// Создает полилинии для отображения GPS трека
  List<Polyline> _buildTrackPolylines() {
    final track = widget.track;
    if (track == null) {
      return [];
    }

    // Создаем кэш-ключ с учетом live буфера
    String cacheKey;
    if (widget.liveBuffer != null && widget.liveBuffer!.pointCount > 0) {
      // Для треков с live буфером учитываем количество точек для инвалидации при новых точках
      cacheKey = '${track.id}_${track.segments.length}_${track.totalPoints}_live${widget.liveBuffer!.pointCount}';
    } else {
      // Для завершенных треков используем стабильный ключ
      cacheKey = '${track.id}_${track.segments.length}';
    }
    
    // Проверяем кэш
    if (_polylineCache!.containsKey(cacheKey)) {
      return _polylineCache![cacheKey]!;
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

    // 2. Добавляем live буфер как отдельную линию (если есть)
    if (widget.liveBuffer != null && widget.liveBuffer!.pointCount >= 2) {
      final livePoints = <LatLng>[];
      for (int j = 0; j < widget.liveBuffer!.pointCount; j++) {
        final (lat, lng) = widget.liveBuffer!.getCoordinates(j);
        livePoints.add(LatLng(lat, lng));
      }
      
      polylines.add(
        Polyline(
          points: livePoints,
          strokeWidth: _trackStrokeWidth,
          color: _liveBufferColor, // Отдельный цвет для live буфера
        ),
      );
    }

    // 3. Добавляем соединительные линии между сегментами и live буфером
    final connectionLines = _buildConnectionLines(track, widget.liveBuffer);
    polylines.addAll(connectionLines);

    // Кэшируем результат
    _polylineCache![cacheKey] = polylines;
    return polylines;
  }

  /// Создает соединительные линии между сегментами и live буфером
  List<Polyline> _buildConnectionLines(UserTrack track, CompactTrack? liveBuffer) {
    final connectionLines = <Polyline>[];
    
    // 1. Соединения между сегментами трека
    for (int i = 0; i < track.segments.length - 1; i++) {
      final currentSegment = track.segments[i];
      final nextSegment = track.segments[i + 1];
      
      if (currentSegment.pointCount == 0 || nextSegment.pointCount == 0) continue;
      
      // Получаем последнюю точку текущего сегмента
      final (endLat, endLng) = currentSegment.getCoordinates(currentSegment.pointCount - 1);
      
      // Получаем первую точку следующего сегмента
      final (startLat, startLng) = nextSegment.getCoordinates(0);
      
      // Проверяем расстояние
      final distance = _calculateDistance(endLat, endLng, startLat, startLng);
      final maxDistance = widget.maxConnectionDistance ?? _maxConnectionDistance;
      if (distance > maxDistance) {
        print('⚠️ Пропускаем соединение между сегментами ${i} и ${i+1}: расстояние ${distance.toStringAsFixed(1)}м > ${maxDistance}м');
        continue;
      }
      
      // Создаем соединительную линию
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
    
    // 2. Соединение между последним сегментом и live буфером
    if (liveBuffer != null && liveBuffer.pointCount > 0 && track.segments.isNotEmpty) {
      final lastSegment = track.segments.last;
      if (lastSegment.pointCount > 0) {
        final (endLat, endLng) = lastSegment.getCoordinates(lastSegment.pointCount - 1);
        final (startLat, startLng) = liveBuffer.getCoordinates(0);
        
        // Проверяем расстояние
        final distance = _calculateDistance(endLat, endLng, startLat, startLng);
        final maxDistance = widget.maxConnectionDistance ?? _maxConnectionDistance;
        if (distance <= maxDistance) {
          connectionLines.add(
            Polyline(
              points: [
                LatLng(endLat, endLng),
                LatLng(startLat, startLng),
              ],
              strokeWidth: _connectionStrokeWidth,
              color: _connectionColor, // Фиолетовый для соединения с live буфером
            ),
          );
        } else {
          print('⚠️ Пропускаем соединение с live буфером: расстояние ${distance.toStringAsFixed(1)}м > ${maxDistance}м');
        }
      }
    }
    
    return connectionLines;
  }
}

/// Кастомный painter для рисования треугольной стрелки
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color.fromARGB(255, 243, 33, 156).withOpacity(0.9)
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final ui.Path path = ui.Path();

    // Создаем форму стрелки (треугольник с вырезом у основания)
    final double tipHeight = size.height * 0.7; // Высота наконечника (70% от общей высоты)
    final double baseWidth = size.width * 0.4; // Ширина основания (40% от ширины)

    // Рисуем наконечник стрелы (большой треугольник)
    path.moveTo(size.width / 2, 0); // Верхняя точка
    path.lineTo(size.width / 2 - baseWidth / 2, tipHeight); // Левая точка наконечника
    path.lineTo(size.width / 2 + baseWidth / 2, tipHeight); // Правая точка наконечника
    path.close();

    // Рисуем тень
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawPath(path.shift(const Offset(0, 2)), shadowPaint);

    // Рисуем стрелку
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
