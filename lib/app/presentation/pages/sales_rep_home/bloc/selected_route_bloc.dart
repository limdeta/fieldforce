import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as domain;
import 'package:fieldforce/app/services/user_preferences_service.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/app/domain/repositories/route_repository.dart';
import 'package:get_it/get_it.dart';

// EVENTS
abstract class SelectedRouteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadInitialRouteEvent extends SelectedRouteEvent {}
class SelectRouteEvent extends SelectedRouteEvent {
  final domain.Route route;
  SelectRouteEvent(this.route);
  @override
  List<Object?> get props => [route];
}
class LoadRouteForTodayEvent extends SelectedRouteEvent {}
class ClearRouteSelectionEvent extends SelectedRouteEvent {}

// STATES
abstract class SelectedRouteState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SelectedRouteInitial extends SelectedRouteState {}
class SelectedRouteLoading extends SelectedRouteState {}
class SelectedRouteLoaded extends SelectedRouteState {
  final domain.Route selectedRoute;
  final List<domain.Route> availableRoutes;
  SelectedRouteLoaded({required this.selectedRoute, required this.availableRoutes});
  @override
  List<Object?> get props => [selectedRoute, availableRoutes];
}
class SelectedRouteError extends SelectedRouteState {
  final String error;
  SelectedRouteError(this.error);
  @override
  List<Object?> get props => [error];
}
class NoRouteSelected extends SelectedRouteState {
  final List<domain.Route> availableRoutes;
  NoRouteSelected({required this.availableRoutes});
  @override
  List<Object?> get props => [availableRoutes];
}

// BLOC
class SelectedRouteBloc extends Bloc<SelectedRouteEvent, SelectedRouteState> {
  final UserPreferencesService _preferencesService = GetIt.instance<UserPreferencesService>();
  final RouteRepository _routeRepository = GetIt.instance<RouteRepository>();

  domain.Route? _selectedRoute;
  List<domain.Route> _availableRoutes = [];

  SelectedRouteBloc() : super(SelectedRouteInitial()) {
    on<LoadInitialRouteEvent>(_onLoadInitialRoute);
    on<SelectRouteEvent>(_onSelectRoute);
    on<LoadRouteForTodayEvent>(_onLoadRouteForToday);
    on<ClearRouteSelectionEvent>(_onClearRouteSelection);
  }

  Future<void> _onLoadInitialRoute(LoadInitialRouteEvent event, Emitter<SelectedRouteState> emit) async {
    emit(SelectedRouteLoading());
    try {
      final session = AppSessionService.currentSession;
      if (session == null) {
        emit(SelectedRouteError('Нет активной сессии'));
        return;
      }

      // Загружаем доступные маршруты
      _routeRepository.watchEmployeeRoutes(session.appUser.employee).listen((routes) {
        if (!emit.isDone) {
          _processLoadedRoutes(routes, emit);
        }
      }).onError((error) {
        if (!emit.isDone) {
          emit(SelectedRouteError('Ошибка загрузки маршрутов: $error'));
        }
      });
    } catch (e) {
      emit(SelectedRouteError('Ошибка загрузки маршрута: $e'));
    }
  }

  void _processLoadedRoutes(List<domain.Route> routes, Emitter<SelectedRouteState> emit) {
    _availableRoutes = routes;
    print('[SelectedRouteBloc] Loaded routes: count=${routes.length}');

    // Пытаемся загрузить сохраненный маршрут
    final savedRouteId = _preferencesService.getSelectedRouteId();
    domain.Route? routeToSelect;

    if (savedRouteId != null) {
      routeToSelect = routes.where((r) => r.id == savedRouteId).firstOrNull;
      print('[SelectedRouteBloc] Trying to restore saved route: id=$savedRouteId, found=${routeToSelect != null}');
    }

    // Если сохраненный не найден, берем маршрут на сегодня
    if (routeToSelect == null) {
      routeToSelect = _findTodayRoute(routes);
      print('[SelectedRouteBloc] Using today route: ${routeToSelect?.name}');
    }

    if (routeToSelect != null) {
      _selectedRoute = routeToSelect;
      _preferencesService.setSelectedRouteId(routeToSelect.id);
      emit(SelectedRouteLoaded(selectedRoute: routeToSelect, availableRoutes: routes));
    } else {
      emit(NoRouteSelected(availableRoutes: routes));
    }
  }

  Future<void> _onSelectRoute(SelectRouteEvent event, Emitter<SelectedRouteState> emit) async {
    try {
      _selectedRoute = event.route;
      await _preferencesService.setSelectedRouteId(event.route.id);
      print('[SelectedRouteBloc] Route selected: ${event.route.name} (id=${event.route.id})');
      emit(SelectedRouteLoaded(selectedRoute: event.route, availableRoutes: _availableRoutes));
    } catch (e) {
      emit(SelectedRouteError('Ошибка выбора маршрута: $e'));
    }
  }

  Future<void> _onLoadRouteForToday(LoadRouteForTodayEvent event, Emitter<SelectedRouteState> emit) async {
    final todayRoute = _findTodayRoute(_availableRoutes);
    if (todayRoute != null) {
      add(SelectRouteEvent(todayRoute));
    }
  }

  void _onClearRouteSelection(ClearRouteSelectionEvent event, Emitter<SelectedRouteState> emit) {
    _selectedRoute = null;
    _preferencesService.setSelectedRouteId(null);
    emit(NoRouteSelected(availableRoutes: _availableRoutes));
  }

  domain.Route? _findTodayRoute(List<domain.Route> routes) {
    // Сначала ищем активный маршрут
    var activeRoute = routes.where((r) => r.status == domain.RouteStatus.active).firstOrNull;
    if (activeRoute != null) return activeRoute;

    // Потом ищем маршрут на сегодня
    final today = DateTime.now();
    var todayRoute = routes.where((r) {
      if (r.startTime == null) return false;
      return r.startTime!.year == today.year &&
             r.startTime!.month == today.month &&
             r.startTime!.day == today.day;
    }).firstOrNull;

    if (todayRoute != null) return todayRoute;

    // В крайнем случае берем первый доступный
    return routes.isNotEmpty ? routes.first : null;
  }

  // Геттеры для удобности
  domain.Route? get selectedRoute => _selectedRoute;
  List<domain.Route> get availableRoutes => _availableRoutes;
  bool get hasSelectedRoute => _selectedRoute != null;
}
