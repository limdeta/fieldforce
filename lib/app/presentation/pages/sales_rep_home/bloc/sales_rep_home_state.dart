import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:fieldforce/features/shop/domain/entities/route.dart' as shop;

/// Состояния для SalesRepHome BLoC
/// 
/// Состояния представляют текущее состояние UI
abstract class SalesRepHomeState extends Equatable {
  const SalesRepHomeState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class SalesRepHomeInitial extends SalesRepHomeState {
  const SalesRepHomeInitial();
}

/// Состояние загрузки
class SalesRepHomeLoading extends SalesRepHomeState {
  final String? message;

  const SalesRepHomeLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// Состояние с загруженными данными
class SalesRepHomeLoaded extends SalesRepHomeState {
  final shop.Route? currentRoute;
  final List<shop.Route> availableRoutes;
  final bool showRoutePanel;
  final bool isBuildingRoute;
  final List<LatLng> routePolylinePoints; // Точки полилинии маршрута

  const SalesRepHomeLoaded({
    this.currentRoute,
    required this.availableRoutes,
    this.showRoutePanel = true,
    this.isBuildingRoute = false,
    this.routePolylinePoints = const [],
  });

  /// Создание копии состояния с измененными полями
  SalesRepHomeLoaded copyWith({
    shop.Route? currentRoute,
    List<shop.Route>? availableRoutes,
    bool? showRoutePanel,
    bool? isBuildingRoute,
    List<LatLng>? routePolylinePoints,
  }) {
    return SalesRepHomeLoaded(
      currentRoute: currentRoute ?? this.currentRoute,
      availableRoutes: availableRoutes ?? this.availableRoutes,
      showRoutePanel: showRoutePanel ?? this.showRoutePanel,
      isBuildingRoute: isBuildingRoute ?? this.isBuildingRoute,
      routePolylinePoints: routePolylinePoints ?? this.routePolylinePoints,
    );
  }

  @override
  List<Object?> get props => [
    currentRoute,
    availableRoutes,
    showRoutePanel,
    isBuildingRoute,
    routePolylinePoints,
  ];
}

/// Состояние ошибки
class SalesRepHomeError extends SalesRepHomeState {
  final String message;
  final shop.Route? currentRoute; // Сохраняем текущий маршрут при ошибке
  final bool canRetry;

  const SalesRepHomeError({
    required this.message,
    this.currentRoute,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, currentRoute, canRetry];
}

/// Состояние успешного построения маршрута
class SalesRepHomeRouteBuilt extends SalesRepHomeState {
  final shop.Route route;
  final List<dynamic> routePoints; // Полилиния маршрута

  const SalesRepHomeRouteBuilt({
    required this.route,
    required this.routePoints,
  });

  @override
  List<Object> get props => [route, routePoints];
}
