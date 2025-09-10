import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as domain;
import 'package:fieldforce/app/domain/entities/work_day.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';

// EVENTS
abstract class SalesRepPageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializePageEvent extends SalesRepPageEvent {
  final domain.Route? preselectedRoute;
  InitializePageEvent({this.preselectedRoute});
  @override
  List<Object?> get props => [preselectedRoute];
}

class RouteSelectedEvent extends SalesRepPageEvent {
  final domain.Route route;
  RouteSelectedEvent(this.route);
  @override
  List<Object?> get props => [route];
}

class WorkDayLoadedEvent extends SalesRepPageEvent {
  final WorkDay? workDay;
  WorkDayLoadedEvent(this.workDay);
  @override
  List<Object?> get props => [workDay];
}

class TrackUpdatedEvent extends SalesRepPageEvent {
  final UserTrack? track;
  TrackUpdatedEvent(this.track);
  @override
  List<Object?> get props => [track];
}

// STATES
abstract class SalesRepPageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SalesRepPageInitial extends SalesRepPageState {}
class SalesRepPageLoading extends SalesRepPageState {
  final String? message;
  SalesRepPageLoading({this.message});
  @override
  List<Object?> get props => [message];
}

class SalesRepPageLoaded extends SalesRepPageState {
  final domain.Route? selectedRoute;
  final WorkDay? selectedWorkDay;
  final UserTrack? activeTrack;
  final NavigationUser? user;

  SalesRepPageLoaded({
    this.selectedRoute,
    this.selectedWorkDay,
    this.activeTrack,
    this.user,
  });

  @override
  List<Object?> get props => [selectedRoute, selectedWorkDay, activeTrack, user];

  SalesRepPageLoaded copyWith({
    domain.Route? selectedRoute,
    WorkDay? selectedWorkDay,
    UserTrack? activeTrack,
    NavigationUser? user,
  }) {
    return SalesRepPageLoaded(
      selectedRoute: selectedRoute ?? this.selectedRoute,
      selectedWorkDay: selectedWorkDay ?? this.selectedWorkDay,
      activeTrack: activeTrack ?? this.activeTrack,
      user: user ?? this.user,
    );
  }
}

class SalesRepPageError extends SalesRepPageState {
  final String error;
  SalesRepPageError(this.error);
  @override
  List<Object?> get props => [error];
}

// BLOC
class SalesRepPageBloc extends Bloc<SalesRepPageEvent, SalesRepPageState> {
  SalesRepPageBloc() : super(SalesRepPageInitial()) {
    on<InitializePageEvent>(_onInitializePage);
    on<RouteSelectedEvent>(_onRouteSelected);
    on<WorkDayLoadedEvent>(_onWorkDayLoaded);
    on<TrackUpdatedEvent>(_onTrackUpdated);
  }

  void _onInitializePage(InitializePageEvent event, Emitter<SalesRepPageState> emit) {
    emit(SalesRepPageLoading(message: 'Загрузка страницы...'));
    // Инициализация будет происходить через слушатели других блоков
  }

  void _onRouteSelected(RouteSelectedEvent event, Emitter<SalesRepPageState> emit) {
    print('[SalesRepPageBloc] Route selected: ${event.route.name}');

    if (state is SalesRepPageLoaded) {
      final currentState = state as SalesRepPageLoaded;
      emit(currentState.copyWith(
        selectedRoute: event.route,
        selectedWorkDay: null, // Сбрасываем, так как будет загружен новый
        activeTrack: null, // Сбрасываем, так как будет загружен новый
      ));
    } else {
      emit(SalesRepPageLoaded(selectedRoute: event.route));
    }
  }

  void _onWorkDayLoaded(WorkDayLoadedEvent event, Emitter<SalesRepPageState> emit) {
    print('[SalesRepPageBloc] WorkDay loaded: id=${event.workDay?.id}');

    if (state is SalesRepPageLoaded) {
      final currentState = state as SalesRepPageLoaded;
      emit(currentState.copyWith(selectedWorkDay: event.workDay));
    }
  }

  void _onTrackUpdated(TrackUpdatedEvent event, Emitter<SalesRepPageState> emit) {
    print('[SalesRepPageBloc] Track updated: id=${event.track?.id}');

    if (state is SalesRepPageLoaded) {
      final currentState = state as SalesRepPageLoaded;
      emit(currentState.copyWith(activeTrack: event.track));
    }
  }
}
