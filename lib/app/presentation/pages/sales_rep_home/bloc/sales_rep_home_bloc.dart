import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:fieldforce/features/shop/domain/entities/route.dart' as shop;
import 'package:fieldforce/features/shop/domain/repositories/route_repository.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/app/providers/selected_route_provider.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/providers/user_tracks_provider.dart';
import 'package:fieldforce/features/navigation/map/domain/entities/map_point.dart';
import 'package:fieldforce/features/navigation/path_predictor/osrm_path_prediction_service.dart';
import 'package:fieldforce/features/shop/domain/entities/point_of_interest.dart';
import 'sales_rep_home_event.dart';
import 'sales_rep_home_state.dart';

/// BLoC для главной страницы торгового представителя
/// 
/// Управляет состоянием страницы и обрабатывает бизнес-логику:
/// - Загрузка маршрутов пользователя
/// - Выбор и синхронизация маршрутов
/// - Построение маршрутов
/// - Управление UI состоянием
class SalesRepHomeBloc extends Bloc<SalesRepHomeEvent, SalesRepHomeState> {
  final RouteRepository _routeRepository = GetIt.instance<RouteRepository>();
  final SelectedRouteProvider _selectedRouteProvider = GetIt.instance<SelectedRouteProvider>();
  final UserTracksProvider _userTracksProvider = GetIt.instance<UserTracksProvider>();

  StreamSubscription<List<shop.Route>>? _routesSubscription;
  StreamSubscription? _selectedRouteSubscription;

  SalesRepHomeBloc() : super(const SalesRepHomeInitial()) {
    // Регистрируем обработчики событий
    on<SalesRepHomeInitializeEvent>(_onInitialize);
    on<LoadUserRoutesEvent>(_onLoadUserRoutes);
    on<SelectRouteEvent>(_onSelectRoute);
    on<ToggleRoutePanelEvent>(_onToggleRoutePanel);
    on<BuildRouteEvent>(_onBuildRoute);
    on<RoutesUpdatedEvent>(_onRoutesUpdated);
    on<SyncTracksWithRouteEvent>(_onSyncTracksWithRoute);
  }

  /// Инициализация BLoC
  Future<void> _onInitialize(
    SalesRepHomeInitializeEvent event,
    Emitter<SalesRepHomeState> emit,
  ) async {
    emit(const SalesRepHomeLoading(message: 'Инициализация...'));

    try {
      // Проверяем сессию пользователя
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

      // Если есть предварительно выбранный маршрут
      if (event.preselectedRoute != null) {
        await _selectedRouteProvider.setSelectedRoute(event.preselectedRoute!);
        add(SyncTracksWithRouteEvent(event.preselectedRoute!));
      } else {
        // Загружаем все треки пользователя
        await _userTracksProvider.loadUserTracks(session.appUser);
      }

      // Настраиваем слушатели
      _setupRouteStreamListener(session);
      _setupSelectedRouteListener();

      // Загружаем маршруты
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

      // Получаем маршруты один раз для инициализации
      // Далее будут использоваться updates из stream
      emit(const SalesRepHomeLoading(message: 'Загрузка маршрутов...'));
      
    } catch (e) {
      emit(SalesRepHomeError(
        message: 'Ошибка загрузки маршрутов: $e',
        canRetry: true,
      ));
    }
  }

  /// Выбор маршрута
  Future<void> _onSelectRoute(
    SelectRouteEvent event,
    Emitter<SalesRepHomeState> emit,
  ) async {
    try {
      await _selectedRouteProvider.setSelectedRoute(event.route);
      add(SyncTracksWithRouteEvent(event.route));
      
      // Обновляем состояние если оно загружено
      if (state is SalesRepHomeLoaded) {
        final currentState = state as SalesRepHomeLoaded;
        emit(currentState.copyWith(currentRoute: event.route));
      }
    } catch (e) {
      emit(SalesRepHomeError(
        message: 'Ошибка выбора маршрута: $e',
        currentRoute: (state is SalesRepHomeLoaded) ? (state as SalesRepHomeLoaded).currentRoute : null,
      ));
    }
  }

  /// Переключение панели маршрута
  void _onToggleRoutePanel(
    ToggleRoutePanelEvent event,
    Emitter<SalesRepHomeState> emit,
  ) {
    if (state is SalesRepHomeLoaded) {
      final currentState = state as SalesRepHomeLoaded;
      emit(currentState.copyWith(showRoutePanel: !currentState.showRoutePanel));
    }
  }

  /// Построение маршрута
  Future<void> _onBuildRoute(
    BuildRouteEvent event,
    Emitter<SalesRepHomeState> emit,
  ) async {
    if (state is! SalesRepHomeLoaded) return;
    
    final currentState = state as SalesRepHomeLoaded;
    final currentRoute = currentState.currentRoute;
    
    if (currentRoute == null) return;

    print('🚀 Построение маршрута начато для ${currentRoute.pointsOfInterest.length} точек');

    // Устанавливаем флаг построения маршрута
    emit(currentState.copyWith(isBuildingRoute: true));

    try {
      final pathPredictionService = GetIt.instance<OsrmPathPredictionService>();
      
      // Находим последнюю завершенную точку (индекс начала маршрута)
      int lastCompletedIndex = -1;
      for (int i = 0; i < currentRoute.pointsOfInterest.length; i++) {
        if (currentRoute.pointsOfInterest[i].status == VisitStatus.completed) {
          lastCompletedIndex = i;
        }
      }
      
      // Если есть завершенные точки, начинаем с последней завершенной
      // Иначе начинаем с первой точки
      final startIndex = lastCompletedIndex >= 0 ? lastCompletedIndex : 0;
      final routePoints = currentRoute.pointsOfInterest.sublist(startIndex);
      
      if (routePoints.length < 2) {
        print('⚠️ Недостаточно точек для построения маршрута (нужно минимум 2, есть ${routePoints.length})');
        emit(currentState.copyWith(isBuildingRoute: false));
        return;
      }

      print('🎯 Строим маршрут от точки ${startIndex + 1} до конца: ${routePoints.length} точек');

      // Преобразуем в MapPoint для OSRM сервиса
      final mapPoints = routePoints.map((poi) => MapPoint(
        latitude: poi.coordinates.latitude,
        longitude: poi.coordinates.longitude,
      )).toList();

      // Вызываем OSRM сервис
      final result = await pathPredictionService.predictRouteGeometry(mapPoints);
      
      if (result.routePoints.isNotEmpty) {
        final polylinePoints = result.routePoints.map((point) => 
          LatLng(point.latitude, point.longitude)
        ).toList();
        
        print('✅ Маршрут построен успешно: ${polylinePoints.length} точек');
        
        // Обновляем состояние с новой полилинией
        emit(currentState.copyWith(
          isBuildingRoute: false,
          routePolylinePoints: polylinePoints,
        ));
      } else {
        print('❌ OSRM вернул пустой результат');
        emit(currentState.copyWith(isBuildingRoute: false));
        emit(SalesRepHomeError(
          message: 'Не удалось построить маршрут: сервис вернул пустой результат',
          currentRoute: currentRoute,
        ));
      }
    } catch (e) {
      print('❌ Ошибка построения маршрута: $e');
      emit(currentState.copyWith(isBuildingRoute: false));
      emit(SalesRepHomeError(
        message: 'Ошибка построения маршрута: $e',
        currentRoute: currentRoute,
      ));
    }
  }

  /// Обновление списка маршрутов (от stream)
  void _onRoutesUpdated(
    RoutesUpdatedEvent event,
    Emitter<SalesRepHomeState> emit,
  ) {
    if (event.routes.isEmpty) {
      emit(const SalesRepHomeLoaded(
        currentRoute: null,
        availableRoutes: [],
      ));
      return;
    }

    shop.Route? routeToDisplay;
    
    // Если маршрут не выбран, выбираем автоматически
    if (_selectedRouteProvider.selectedRoute == null) {
      routeToDisplay = _findCurrentRoute(event.routes);
      if (routeToDisplay != null) {
        _selectedRouteProvider.setSelectedRoute(routeToDisplay);
      }
    } else {
      routeToDisplay = _selectedRouteProvider.selectedRoute;
    }

    emit(SalesRepHomeLoaded(
      currentRoute: routeToDisplay,
      availableRoutes: event.routes,
      showRoutePanel: state is SalesRepHomeLoaded ? (state as SalesRepHomeLoaded).showRoutePanel : true,
      isBuildingRoute: state is SalesRepHomeLoaded ? (state as SalesRepHomeLoaded).isBuildingRoute : false,
    ));
  }

  /// Синхронизация треков с маршрутом
  Future<void> _onSyncTracksWithRoute(
    SyncTracksWithRouteEvent event,
    Emitter<SalesRepHomeState> emit,
  ) async {
    try {
      final sessionResult = await AppSessionService.getCurrentAppSession();
      final session = sessionResult.fold((l) => null, (r) => r);
      
      if (session != null) {
        final routeDate = event.route.startTime ?? DateTime.now();
        await _userTracksProvider.loadUserTracksForDate(session.appUser, routeDate);
        
        print('✅ Треки синхронизированы с маршрутом: ${event.route.name}');
      }
    } catch (e) {
      print('⚠️ Ошибка синхронизации треков: $e');
    }
  }

  /// Настройка слушателя stream маршрутов
  void _setupRouteStreamListener(session) {
    _routesSubscription?.cancel();
    _routesSubscription = _routeRepository
        .watchEmployeeRoutes(session.appUser.employee)
        .listen(
          (routes) => add(RoutesUpdatedEvent(routes)),
          onError: (error) {
            add(LoadUserRoutesEvent()); // Retry через event
            print('⚠️ Ошибка загрузки маршрутов: $error');
          },
        );
  }

  /// Настройка слушателя выбранного маршрута
  void _setupSelectedRouteListener() {
    _selectedRouteSubscription?.cancel();
    _selectedRouteProvider.addListener(() {
      final selectedRoute = _selectedRouteProvider.selectedRoute;
      if (selectedRoute != null) {
        add(SyncTracksWithRouteEvent(selectedRoute));
      }
    });
  }

  /// Поиск текущего маршрута (активный или сегодняшний)
  shop.Route? _findCurrentRoute(List<shop.Route> routes) {
    // Ищем активный маршрут
    var activeRoute = routes.where((r) => r.status == shop.RouteStatus.active).firstOrNull;
    if (activeRoute != null) return activeRoute;
    
    // Ищем сегодняшний маршрут
    final today = DateTime.now();
    var todayRoute = routes.where((r) {
      if (r.startTime == null) return false;
      return r.startTime!.year == today.year &&
             r.startTime!.month == today.month &&
             r.startTime!.day == today.day;
    }).firstOrNull;
    
    if (todayRoute != null) return todayRoute;
    
    // Возвращаем первый доступный
    return routes.isNotEmpty ? routes.first : null;
  }

  @override
  Future<void> close() {
    _routesSubscription?.cancel();
    _selectedRouteSubscription?.cancel();
    return super.close();
  }
}
