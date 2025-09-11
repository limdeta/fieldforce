import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as shop;
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';

/// События для SalesRepHome BLoC
/// 
/// События представляют намерения пользователя или внешние триггеры
abstract class SalesRepHomeEvent extends Equatable {
  const SalesRepHomeEvent();

  @override
  List<Object?> get props => [];
}

/// Инициализация страницы
class SalesRepHomeInitializeEvent extends SalesRepHomeEvent {
  final shop.Route? preselectedRoute;

  const SalesRepHomeInitializeEvent({this.preselectedRoute});

  @override
  List<Object?> get props => [preselectedRoute];
}

/// Загрузка маршрутов пользователя
class LoadUserRoutesEvent extends SalesRepHomeEvent {
  const LoadUserRoutesEvent();
}

/// Выбор конкретного маршрута
class SelectRouteEvent extends SalesRepHomeEvent {
  final shop.Route route;

  const SelectRouteEvent(this.route);

  @override
  List<Object> get props => [route];
}

/// Переключение видимости панели маршрута
class ToggleRoutePanelEvent extends SalesRepHomeEvent {
  const ToggleRoutePanelEvent();
}

/// Построение маршрута
class BuildRouteEvent extends SalesRepHomeEvent {
  final LatLng? currentLocation;

  const BuildRouteEvent({this.currentLocation});

  @override
  List<Object?> get props => [currentLocation];
}

/// Обновление списка маршрутов (от stream)
class RoutesUpdatedEvent extends SalesRepHomeEvent {
  final List<shop.Route> routes;

  const RoutesUpdatedEvent(this.routes);

  @override
  List<Object> get props => [routes];
}

/// Обновление активного трека (от LocationTrackingService)
class ActiveTrackUpdatedEvent extends SalesRepHomeEvent {
  final UserTrack activeTrack;

  const ActiveTrackUpdatedEvent(this.activeTrack);

  @override
  List<Object> get props => [activeTrack];
}

/// Синхронизация треков с маршрутом
class SyncTracksWithRouteEvent extends SalesRepHomeEvent {
  final shop.Route route;

  const SyncTracksWithRouteEvent(this.route);

  @override
  List<Object> get props => [route];
}
