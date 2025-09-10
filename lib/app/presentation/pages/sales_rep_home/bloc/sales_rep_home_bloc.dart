import 'dart:async';
import 'package:fieldforce/app/domain/entities/point_of_interest.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as shop;
import 'package:fieldforce/app/domain/repositories/route_repository.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as domain;
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:fieldforce/features/navigation/map/domain/entities/map_point.dart';
import 'package:fieldforce/features/navigation/path_predictor/osrm_path_prediction_service.dart';
import 'sales_rep_home_event.dart';
import 'sales_rep_home_state.dart';

/// BLoC для главной страницы торгового представителя
class SalesRepHomeBloc extends Bloc<SalesRepHomeEvent, SalesRepHomeState> {
  final RouteRepository _routeRepository = GetIt.instance<RouteRepository>();
  final LocationTrackingServiceBase _trackingService = GetIt.instance<LocationTrackingServiceBase>();

  StreamSubscription<List<shop.Route>>? _routesSubscription;
  StreamSubscription? _activeTrackSubscription;

  SalesRepHomeBloc() : super(const SalesRepHomeInitial()) {
    // Регистрируем обработчики событий
    on<SalesRepHomeInitializeEvent>(_onInitialize);
    on<LoadUserRoutesEvent>(_onLoadUserRoutes);
    on<SelectRouteEvent>(_onSelectRoute);
    on<ToggleRoutePanelEvent>(_onToggleRoutePanel);
    on<BuildRouteEvent>(_onBuildRoute);
    on<RoutesUpdatedEvent>(_onRoutesUpdated);
    on<SyncTracksWithRouteEvent>(_onSyncTracksWithRoute);
    on<ActiveTrackUpdatedEvent>(_onActiveTrackUpdated);

    // Подписываемся на активный трек сразу при создании блока
    _setupActiveTrackListener();
  }

  /// Обработчик обновления активного трека с дебаунсингом
  void _onActiveTrackUpdated(
    ActiveTrackUpdatedEvent event,
    Emitter<SalesRepHomeState> emit,
  ) {
    // ОПТИМИЗАЦИЯ: Немедленно обновляем состояние без дебаунсинга для UI отзывчивости
    // Дебаунсинг уже происходит в TrackManager (каждые 5 точек) и UserTracksBloc
    if (state is SalesRepHomeLoaded) {
      final currentState = state as SalesRepHomeLoaded;
      final newTrack = event.activeTrack;
      final newState = currentState.copyWith(activeTrack: newTrack);
      emit(newState);
    }
  }

  /// Настройка слушателя активного трека
  void _setupActiveTrackListener() {
    _activeTrackSubscription?.cancel();

    _activeTrackSubscription = _trackingService.trackUpdateStream.listen(
      (activeTrack) {
        add(ActiveTrackUpdatedEvent(activeTrack));
      },
      onError: (error) {
        print('⚠️ SalesRepHomeBloc: Ошибка прямой подписки на трек: $error');
      },
    );
  }

  /// Инициализация BLoC
  Future<void> _onInitialize(
    SalesRepHomeInitializeEvent event,
    Emitter<SalesRepHomeState> emit,
  ) async {
    emit(const SalesRepHomeLoading(message: 'Инициализация...'));

    try {
      final sessionResult = await AppSessionService.getCurrentAppSession();
      if (sessionResult.isLeft()) {
        emit(const SalesRepHomeError(
          message: 'Не удалось получить сессию пользователя',
          canRetry: true,
        ));
        return;
      }

      final session = sessionResult.fold((l) => null, (r) => r);
      if (session == null) {
        emit(const SalesRepHomeError(
          message: 'Пользователь не найден в сессии',
          canRetry: true,
        ));
        return;
      }

      _setupRouteStreamListener(session);
      add(const LoadUserRoutesEvent());

    } catch (e) {
      emit(SalesRepHomeError(
        message: 'Ошибка инициализации: $e',
        canRetry: true,
      ));
    }
  }

  /// Загрузка маршрутов пользователя
  Future<void> _onLoadUserRoutes(
    LoadUserRoutesEvent event,
    Emitter<SalesRepHomeState> emit,
  ) async {
    try {
      final sessionResult = await AppSessionService.getCurrentAppSession();
      final session = sessionResult.fold((l) => throw Exception('No session'), (r) => r);

      if (session == null) {
        throw Exception('Session is null');
      }

      emit(const SalesRepHomeLoading(message: 'Загрузка маршрутов...'));
    } catch (e) {
      emit(SalesRepHomeError(
        message: 'Ошибка загрузки маршрутов: $e',
        canRetry: true,
      ));
    }
  }

  Future<void> _onSelectRoute(
    SelectRouteEvent event,
    Emitter<SalesRepHomeState> emit,
  ) async {
    try {
      add(SyncTracksWithRouteEvent(event.route));

      if (state is SalesRepHomeLoaded) {
        final currentState = state as SalesRepHomeLoaded;
        emit(currentState.copyWith(currentRoute: event.route));
      }
    } catch (e) {
      print('❌ SalesRepHomeBloc._onSelectRoute: Критическая ошибка: $e');
      emit(SalesRepHomeError(
        message: 'Ошибка выбора маршрута: $e',
        currentRoute: (state is SalesRepHomeLoaded) ? (state as SalesRepHomeLoaded).currentRoute : null,
      ));
    }
  }

  void _onToggleRoutePanel(
    ToggleRoutePanelEvent event,
    Emitter<SalesRepHomeState> emit,
  ) {
    if (state is SalesRepHomeLoaded) {
      final currentState = state as SalesRepHomeLoaded;
      emit(currentState.copyWith(showRoutePanel: !currentState.showRoutePanel));
    }
  }

  Future<void> _onBuildRoute(
    BuildRouteEvent event,
    Emitter<SalesRepHomeState> emit,
  ) async {
    if (state is! SalesRepHomeLoaded) return;

    final currentState = state as SalesRepHomeLoaded;
    final currentRoute = currentState.currentRoute;
    if (currentRoute == null) return;

    emit(currentState.copyWith(isBuildingRoute: true));

    try {
      final pathPredictionService = GetIt.instance<OsrmPathPredictionService>();

      int lastCompletedIndex = -1;
      for (int i = 0; i < currentRoute.pointsOfInterest.length; i++) {
        if (currentRoute.pointsOfInterest[i].status == VisitStatus.completed) {
          lastCompletedIndex = i;
        }
      }

      final startIndex = lastCompletedIndex >= 0 ? lastCompletedIndex : 0;
      final routePoints = currentRoute.pointsOfInterest.sublist(startIndex);

      if (routePoints.length < 2) {
        print('⚠️ Недостаточно точек для построения маршрута');
        emit(currentState.copyWith(isBuildingRoute: false));
        return;
      }

      final mapPoints = routePoints.map((poi) => MapPoint(
        latitude: poi.coordinates.latitude,
        longitude: poi.coordinates.longitude,
      )).toList();

      final result = await pathPredictionService.predictRouteGeometry(mapPoints);

      if (result.routePoints.isNotEmpty) {
        final polylinePoints = result.routePoints.map((point) =>
          LatLng(point.latitude, point.longitude)
        ).toList();

        emit(currentState.copyWith(
          isBuildingRoute: false,
          routePolylinePoints: polylinePoints,
        ));
      } else {
        emit(currentState.copyWith(isBuildingRoute: false));
      }
    } catch (e) {
      print('❌ Ошибка построения маршрута: $e');
      emit(currentState.copyWith(isBuildingRoute: false));
    }
  }

  Future<void> _onRoutesUpdated(
    RoutesUpdatedEvent event,
    Emitter<SalesRepHomeState> emit,
  ) async {
    if (event.routes.isEmpty) {
      emit(const SalesRepHomeLoaded(
        availableRoutes: [],
      ));
      return;
    }

    shop.Route? routeToDisplay;
    routeToDisplay = _findCurrentRoute(event.routes);

    emit(SalesRepHomeLoaded(
      currentRoute: routeToDisplay,
      availableRoutes: event.routes,
      showRoutePanel: state is SalesRepHomeLoaded ? (state as SalesRepHomeLoaded).showRoutePanel : true,
      isBuildingRoute: state is SalesRepHomeLoaded ? (state as SalesRepHomeLoaded).isBuildingRoute : false,
    ));
  }

  Future<void> _onSyncTracksWithRoute(
    SyncTracksWithRouteEvent event,
    Emitter<SalesRepHomeState> emit,
  ) async {
    try {
      final sessionResult = await AppSessionService.getCurrentAppSession();
      final session = sessionResult.fold((l) => null, (r) => r);

      if (session != null) {
        final routeDate = event.route.startTime ?? DateTime.now();
        print('[SalesRepHomeBloc] Syncing tracks for route: ${event.route.name}');
      }
    } catch (e) {
      print('⚠️ Ошибка синхронизации треков: $e');
    }
  }

  void _setupRouteStreamListener(session) {
    _routesSubscription?.cancel();
    _routesSubscription = _routeRepository
        .watchEmployeeRoutes(session.appUser.employee)
        .listen(
          (routes) => add(RoutesUpdatedEvent(routes)),
          onError: (error) {
            add(const LoadUserRoutesEvent());
            print('⚠️ Ошибка загрузки маршрутов: $error');
          },
        );
  }

  shop.Route? _findCurrentRoute(List<shop.Route> routes) {
    var activeRoute = routes.where((r) => r.status == shop.RouteStatus.active).firstOrNull;
    if (activeRoute != null) return activeRoute;

    final today = DateTime.now();
    var todayRoute = routes.where((r) {
      if (r.startTime == null) return false;
      return r.startTime!.year == today.year &&
             r.startTime!.month == today.month &&
             r.startTime!.day == today.day;
    }).firstOrNull;

    if (todayRoute != null) return todayRoute;
    return routes.isNotEmpty ? routes.first : null;
  }

  @override
  Future<void> close() {
    _routesSubscription?.cancel();
    _activeTrackSubscription?.cancel();
    return super.close();
  }
}
