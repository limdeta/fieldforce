import 'package:equatable/equatable.dart';
import 'package:fieldforce/features/shop/domain/entities/route.dart' as shop;

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
  const BuildRouteEvent();
}

/// Обновление списка маршрутов (от stream)
class RoutesUpdatedEvent extends SalesRepHomeEvent {
  final List<shop.Route> routes;

  const RoutesUpdatedEvent(this.routes);

  @override
  List<Object> get props => [routes];
}

/// Синхронизация треков с выбранным маршрутом
class SyncTracksWithRouteEvent extends SalesRepHomeEvent {
  final shop.Route route;

  const SyncTracksWithRouteEvent(this.route);

  @override
  List<Object> get props => [route];
}
