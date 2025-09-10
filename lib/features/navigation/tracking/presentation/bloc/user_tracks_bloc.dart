import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/usecases/get_user_track_for_date_usecase.dart';
import 'package:fieldforce/features/navigation/tracking/domain/usecases/get_user_tracks_usecase.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:get_it/get_it.dart';

// EVENTS
abstract class UserTracksEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUserTracksEvent extends UserTracksEvent {
  final NavigationUser user;
  LoadUserTracksEvent(this.user);
  @override
  List<Object?> get props => [user];
}

class LoadUserTrackForDateEvent extends UserTracksEvent {
  final NavigationUser user;
  final DateTime date;
  LoadUserTrackForDateEvent(this.user, this.date);
  @override
  List<Object?> get props => [user, date];
}

class ClearTracksEvent extends UserTracksEvent {}

class ActiveTrackUpdatedEvent extends UserTracksEvent {
  final UserTrack activeTrack;
  ActiveTrackUpdatedEvent(this.activeTrack);
  @override
  List<Object?> get props => [activeTrack];
}

// STATES
abstract class UserTracksState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserTracksInitial extends UserTracksState {}

class UserTracksLoading extends UserTracksState {}

class UserTracksLoaded extends UserTracksState {
  final List<UserTrack> userTracks;
  final UserTrack? activeTrack;
  final List<UserTrack> completedTracks;
  UserTracksLoaded({
    required this.userTracks,
    required this.activeTrack,
    required this.completedTracks,
  });
  @override
  List<Object?> get props => [userTracks, activeTrack, completedTracks];
}

class UserTracksError extends UserTracksState {
  final String error;
  UserTracksError(this.error);
  @override
  List<Object?> get props => [error];
}

class UserTrackNotFound extends UserTracksState {
  final DateTime date;
  UserTrackNotFound(this.date);
  @override
  List<Object?> get props => [date];
}

// BLOC
class UserTracksBloc extends Bloc<UserTracksEvent, UserTracksState> {
  final GetUserTracksUseCase _getUserTracksUseCase = GetIt.instance<GetUserTracksUseCase>();
  final GetUserTrackForDateUseCase _getUserTrackForDateUseCase = GetIt.instance<GetUserTrackForDateUseCase>();
  final LocationTrackingServiceBase _locationTrackingService = GetIt.instance<LocationTrackingServiceBase>();

  List<UserTrack> _userTracks = [];
  UserTrack? _activeTrack;
  List<UserTrack> _completedTracks = [];
  String? _error;

  StreamSubscription<UserTrack>? _activeTrackSubscription;

  NavigationUser? _lastLoadedUser;
  DateTime? _lastLoadTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  UserTracksBloc() : super(UserTracksInitial()) {
    on<LoadUserTracksEvent>(_onLoadUserTracks);
    on<LoadUserTrackForDateEvent>(_onLoadUserTrackForDate);
    on<ClearTracksEvent>(_onClearTracks);
    on<ActiveTrackUpdatedEvent>(_onActiveTrackUpdated);
    _subscribeToActiveTrack();
  }

  Future<void> _onLoadUserTracks(LoadUserTracksEvent event, Emitter<UserTracksState> emit) async {
    if (_lastLoadedUser?.id == event.user.id &&
        _lastLoadTime != null &&
        DateTime.now().difference(_lastLoadTime!) < _cacheTimeout) {
      emit(UserTracksLoaded(
        userTracks: _userTracks,
        activeTrack: _activeTrack,
        completedTracks: _completedTracks,
      ));
      return;
    }
    emit(UserTracksLoading());
    final result = await _getUserTracksUseCase.call(event.user);
    result.fold(
      (failure) {
        _error = 'Ошибка загрузки треков: $failure';
        emit(UserTracksError(_error!));
      },
      (tracks) {
        _userTracks = tracks;
        _activeTrack = tracks.where((track) => track.status.isActive).firstOrNull;
        _completedTracks = tracks.where((track) => track.status.name == 'completed').toList();
        _lastLoadedUser = event.user;
        _lastLoadTime = DateTime.now();
        emit(UserTracksLoaded(
          userTracks: _userTracks,
          activeTrack: _activeTrack,
          completedTracks: _completedTracks,
        ));
      },
    );
  }

  Future<void> _onLoadUserTrackForDate(LoadUserTrackForDateEvent event, Emitter<UserTracksState> emit) async {
    print('[UserTracksBloc] _onLoadUserTrackForDate called for user=${event.user.id}, date=${event.date}');
    emit(UserTracksLoading());
    final result = await _getUserTrackForDateUseCase.call(event.user, event.date);
    result.fold(
      (failure) {
        print('[UserTracksBloc] Track not found for date=${event.date}, failure=$failure');
        if (failure is NotFoundFailure) {
          emit(UserTrackNotFound(event.date));
        } else {
          _error = 'Ошибка загрузки трека: $failure';
          emit(UserTracksError(_error!));
        }
      },
      (track) {
        print('[UserTracksBloc] Track loaded for date=${event.date}, trackId=${track?.id}');
        _userTracks = track != null ? [track] : [];
        _activeTrack = track != null && track.status.isActive ? track : null;
        _completedTracks = track != null && track.status.name == 'completed' ? [track] : [];
        emit(UserTracksLoaded(
          userTracks: _userTracks,
          activeTrack: _activeTrack,
          completedTracks: _completedTracks,
        ));
      },
    );
  }

  void _onClearTracks(ClearTracksEvent event, Emitter<UserTracksState> emit) {
    _userTracks.clear();
    _activeTrack = null;
    _completedTracks.clear();
    _error = null;
    _lastLoadedUser = null;
    _lastLoadTime = null;
    emit(UserTracksInitial());
  }

  void _subscribeToActiveTrack() {
    _activeTrackSubscription = _locationTrackingService.trackUpdateStream.listen(
      (activeTrack) {
        add(ActiveTrackUpdatedEvent(activeTrack));
      },
      onError: (error) {
        // Optionally handle error
      },
    );
  }

  void _onActiveTrackUpdated(ActiveTrackUpdatedEvent event, Emitter<UserTracksState> emit) {
    print('[UserTracksBloc] _onActiveTrackUpdated called for trackId=${event.activeTrack.id}');
    final existingIndex = _userTracks.indexWhere((track) => track.id == event.activeTrack.id);
    if (existingIndex != -1) {
      _userTracks[existingIndex] = event.activeTrack;
    } else {
      _userTracks.add(event.activeTrack);
    }
    _activeTrack = event.activeTrack;
    emit(UserTracksLoaded(
      userTracks: _userTracks,
      activeTrack: _activeTrack,
      completedTracks: _completedTracks,
    ));
  }

  @override
  Future<void> close() {
    _activeTrackSubscription?.cancel();
    return super.close();
  }
}
