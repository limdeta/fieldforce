import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fieldforce/app/domain/entities/work_day.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as domain;
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:get_it/get_it.dart';
import 'working_day_mode_bloc.dart';

// EVENTS
abstract class WorkingDayCoordinatorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializeCoordinatorEvent extends WorkingDayCoordinatorEvent {}
class RouteSelectedEvent extends WorkingDayCoordinatorEvent {
  final domain.Route route;
  RouteSelectedEvent(this.route);
  @override
  List<Object?> get props => [route];
}
class WorkDaySelectedEvent extends WorkingDayCoordinatorEvent {
  final WorkDay workDay;
  WorkDaySelectedEvent(this.workDay);
  @override
  List<Object?> get props => [workDay];
}
class TrackingDataUpdatedEvent extends WorkingDayCoordinatorEvent {
  final UserTrack track;
  TrackingDataUpdatedEvent(this.track);
  @override
  List<Object?> get props => [track];
}
class StartTrackingEvent extends WorkingDayCoordinatorEvent {}
class StopTrackingEvent extends WorkingDayCoordinatorEvent {}
class PauseTrackingEvent extends WorkingDayCoordinatorEvent {}

// STATES
abstract class WorkingDayCoordinatorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkingDayCoordinatorInitial extends WorkingDayCoordinatorState {}
class WorkingDayCoordinatorLoading extends WorkingDayCoordinatorState {}

class WorkingDayCoordinatorLoaded extends WorkingDayCoordinatorState {
  final WorkingDayModeState modeState;
  final domain.Route? currentRoute;
  final WorkDay? currentWorkDay;
  final UserTrack? currentTrack;
  final NavigationUser? user;
  final DateTime lastUpdate;

  WorkingDayCoordinatorLoaded({
    required this.modeState,
    this.currentRoute,
    this.currentWorkDay,
    this.currentTrack,
    this.user,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [modeState, currentRoute, currentWorkDay, currentTrack, user, lastUpdate];

  WorkingDayCoordinatorLoaded copyWith({
    WorkingDayModeState? modeState,
    domain.Route? currentRoute,
    WorkDay? currentWorkDay,
    UserTrack? currentTrack,
    NavigationUser? user,
    DateTime? lastUpdate,
  }) {
    return WorkingDayCoordinatorLoaded(
      modeState: modeState ?? this.modeState,
      currentRoute: currentRoute ?? this.currentRoute,
      currentWorkDay: currentWorkDay ?? this.currentWorkDay,
      currentTrack: currentTrack ?? this.currentTrack,
      user: user ?? this.user,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

class WorkingDayCoordinatorError extends WorkingDayCoordinatorState {
  final String error;
  WorkingDayCoordinatorError(this.error);
  @override
  List<Object?> get props => [error];
}

// COORDINATOR BLOC
class WorkingDayCoordinatorBloc extends Bloc<WorkingDayCoordinatorEvent, WorkingDayCoordinatorState> {
  final LocationTrackingServiceBase _trackingService = GetIt.instance<LocationTrackingServiceBase>();

  StreamSubscription<UserTrack>? _trackingSubscription;
  NavigationUser? _currentUser;
  domain.Route? _currentRoute;
  WorkDay? _currentWorkDay;
  UserTrack? _currentTrack;

  WorkingDayCoordinatorBloc() : super(WorkingDayCoordinatorInitial()) {
    on<InitializeCoordinatorEvent>(_onInitialize);
    on<RouteSelectedEvent>(_onRouteSelected);
    on<WorkDaySelectedEvent>(_onWorkDaySelected);
    on<TrackingDataUpdatedEvent>(_onTrackingDataUpdated);
    on<StartTrackingEvent>(_onStartTracking);
    on<StopTrackingEvent>(_onStopTracking);
    on<PauseTrackingEvent>(_onPauseTracking);
  }

  Future<void> _onInitialize(InitializeCoordinatorEvent event, Emitter<WorkingDayCoordinatorState> emit) async {
    emit(WorkingDayCoordinatorLoading());

    try {
      // Получаем текущего пользователя
      final sessionResult = await AppSessionService.getCurrentAppSession();
      final session = sessionResult.fold((l) => null, (r) => r);

      if (session == null) {
        emit(WorkingDayCoordinatorError('Нет активной сессии'));
        return;
      }

      _currentUser = session.appUser;

      // Подписываемся на обновления трекинга только в активном режиме
      _setupTrackingSubscription();

      emit(WorkingDayCoordinatorLoaded(
        modeState: WorkingDayModeInitial(),
        user: _currentUser,
        lastUpdate: DateTime.now(),
      ));

    } catch (e) {
      emit(WorkingDayCoordinatorError('Ошибка инициализации: $e'));
    }
  }

  void _onRouteSelected(RouteSelectedEvent event, Emitter<WorkingDayCoordinatorState> emit) {
    print('[WorkingDayCoordinator] Route selected: ${event.route.name}');
    _currentRoute = event.route;

    if (state is WorkingDayCoordinatorLoaded) {
      final currentState = state as WorkingDayCoordinatorLoaded;
      emit(currentState.copyWith(
        currentRoute: event.route,
        lastUpdate: DateTime.now(),
      ));
    }
  }

  void _onWorkDaySelected(WorkDaySelectedEvent event, Emitter<WorkingDayCoordinatorState> emit) {
    print('[WorkingDayCoordinator] WorkDay selected: ${event.workDay.id}');
    _currentWorkDay = event.workDay;

    // Определяем, это текущий день или исторический
    final isToday = _isSameDay(event.workDay.date, DateTime.now());

    if (state is WorkingDayCoordinatorLoaded) {
      final currentState = state as WorkingDayCoordinatorLoaded;

      if (isToday) {
        // Переключаемся в активный режим
        _setupActiveTrackingForWorkDay(event.workDay);
        emit(currentState.copyWith(
          modeState: ActiveWorkingDayState(
            currentWorkDay: event.workDay,
            activeTrack: _currentTrack,
            isTrackingActive: true,
            lastUpdate: DateTime.now(),
          ),
          currentWorkDay: event.workDay,
          lastUpdate: DateTime.now(),
        ));
      } else {
        // Переключаемся в просмотровый режим
        _pauseActiveTracking();
        emit(currentState.copyWith(
          modeState: ViewingWorkingDayState(
            viewingWorkDay: event.workDay,
            historicalTrack: event.workDay.track,
            canSwitchToActive: false,
          ),
          currentWorkDay: event.workDay,
          lastUpdate: DateTime.now(),
        ));
      }
    }
  }

  void _onTrackingDataUpdated(TrackingDataUpdatedEvent event, Emitter<WorkingDayCoordinatorState> emit) {
    print('[WorkingDayCoordinator] Tracking data updated: ${event.track.id} (${event.track.totalPoints} points)');
    _currentTrack = event.track;

    if (state is WorkingDayCoordinatorLoaded) {
      final currentState = state as WorkingDayCoordinatorLoaded;

      // Обновляем трек только в активном режиме
      if (currentState.modeState is ActiveWorkingDayState) {
        final activeState = currentState.modeState as ActiveWorkingDayState;
        emit(currentState.copyWith(
          modeState: activeState.copyWith(
            activeTrack: event.track,
            lastUpdate: DateTime.now(),
          ),
          currentTrack: event.track,
          lastUpdate: DateTime.now(),
        ));
      }
    }
  }

  Future<void> _onStartTracking(StartTrackingEvent event, Emitter<WorkingDayCoordinatorState> emit) async {
    print('[WorkingDayCoordinator] Starting tracking');
    try {
      await _trackingService.startTracking(_currentUser!);
      _setupTrackingSubscription();
    } catch (e) {
      print('Error starting tracking: $e');
    }
  }

  Future<void> _onStopTracking(StopTrackingEvent event, Emitter<WorkingDayCoordinatorState> emit) async {
    print('[WorkingDayCoordinator] Stopping tracking');
    try {
      await _trackingService.stopTracking();
      _trackingSubscription?.cancel();
    } catch (e) {
      print('Error stopping tracking: $e');
    }
  }

  Future<void> _onPauseTracking(PauseTrackingEvent event, Emitter<WorkingDayCoordinatorState> emit) async {
    print('[WorkingDayCoordinator] Pausing tracking');
    try {
      await _trackingService.pauseTracking();
    } catch (e) {
      print('Error pausing tracking: $e');
    }
  }

  void _setupTrackingSubscription() {
    _trackingSubscription?.cancel();
    _trackingSubscription = _trackingService.trackUpdateStream.listen(
      (track) {
        add(TrackingDataUpdatedEvent(track));
      },
      onError: (error) {
        print('Tracking stream error: $error');
      },
    );
  }

  void _setupActiveTrackingForWorkDay(WorkDay workDay) {
    print('[WorkingDayCoordinator] Setting up active tracking for WorkDay: ${workDay.id}');
    // Здесь можно настроить специфичный трекинг для рабочего дня
    _setupTrackingSubscription();
  }

  void _pauseActiveTracking() {
    print('[WorkingDayCoordinator] Pausing active tracking');
    // Не останавливаем трекинг полностью, но переводим в пассивный режим
    add(PauseTrackingEvent());
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  Future<void> close() {
    _trackingSubscription?.cancel();
    return super.close();
  }
}
