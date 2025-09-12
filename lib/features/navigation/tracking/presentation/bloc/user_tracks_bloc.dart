import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
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
  final bool showActiveTrack; // Показать активный трек после загрузки
  LoadUserTracksEvent(this.user, {this.showActiveTrack = false});
  @override
  List<Object?> get props => [user, showActiveTrack];
}

class LoadUserTrackForDateEvent extends UserTracksEvent {
  final NavigationUser user;
  final DateTime date;
  LoadUserTrackForDateEvent(this.user, this.date);
  @override
  List<Object?> get props => [user, date];
}

class ClearTracksEvent extends UserTracksEvent {}

class SetDisplayedTrackEvent extends UserTracksEvent {
  final UserTrack? track; // null = ничего не отображаем
  SetDisplayedTrackEvent(this.track);
  @override
  List<Object?> get props => [track];
}

class ShowActiveTrackEvent extends UserTracksEvent {}

class ActiveTrackUpdatedEvent extends UserTracksEvent {
  final UserTrack activeTrack;
  ActiveTrackUpdatedEvent(this.activeTrack);
  @override
  List<Object?> get props => [activeTrack];
}

class LiveBufferUpdatedEvent extends UserTracksEvent {
  final CompactTrack bufferSegment;
  LiveBufferUpdatedEvent(this.bufferSegment);
  @override
  List<Object?> get props => [bufferSegment];
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
  final String? notificationMessage; // Уведомление для пользователя
  final CompactTrack? liveBuffer; // Live данные буфера для отрисовки
  UserTracksLoaded({
    required this.userTracks,
    required this.activeTrack,
    required this.completedTracks,
    this.notificationMessage,
    this.liveBuffer,
  });
  @override
  List<Object?> get props => [userTracks, activeTrack, completedTracks, notificationMessage, liveBuffer];

  UserTracksLoaded copyWith({
    List<UserTrack>? userTracks,
    UserTrack? activeTrack,
    List<UserTrack>? completedTracks,
    String? notificationMessage,
    CompactTrack? liveBuffer,
  }) {
    return UserTracksLoaded(
      userTracks: userTracks ?? this.userTracks,
      activeTrack: activeTrack ?? this.activeTrack,
      completedTracks: completedTracks ?? this.completedTracks,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      liveBuffer: liveBuffer ?? this.liveBuffer,
    );
  }
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
  UserTrack? _displayedTrack; // Единственный трек который отображается
  List<UserTrack> _completedTracks = [];
  String? _error;
  
  StreamSubscription<UserTrack>? _trackUpdateSubscription;
  StreamSubscription<CompactTrack>? _liveBufferSubscription;

  StreamSubscription<UserTrack>? _activeTrackSubscription;

  NavigationUser? _lastLoadedUser;
  DateTime? _lastLoadTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  UserTrack? get activeTrack => _userTracks.where((track) => track.status.isActive).firstOrNull;

  UserTracksBloc() : super(UserTracksInitial()) {
    on<LoadUserTracksEvent>(_onLoadUserTracks);
    on<LoadUserTrackForDateEvent>(_onLoadUserTrackForDate);
    on<ClearTracksEvent>(_onClearTracks);
    on<SetDisplayedTrackEvent>(_onSetDisplayedTrack);
    on<ShowActiveTrackEvent>(_onShowActiveTrack);
    on<ActiveTrackUpdatedEvent>(_onActiveTrackUpdated);
    on<LiveBufferUpdatedEvent>(_onLiveBufferUpdated);
    _subscribeToActiveTrack();
  }

  Future<void> _onLoadUserTracks(LoadUserTracksEvent event, Emitter<UserTracksState> emit) async {
    if (_lastLoadedUser?.id == event.user.id &&
        _lastLoadTime != null &&
        DateTime.now().difference(_lastLoadTime!) < _cacheTimeout) {
      emit(UserTracksLoaded(
        userTracks: _userTracks,
        activeTrack: _displayedTrack,
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
        final currentActiveTrack = tracks.where((track) => track.status.isActive).firstOrNull;
        _completedTracks = tracks.where((track) => track.status.name == 'completed').toList();
        _lastLoadedUser = event.user;
        _lastLoadTime = DateTime.now();
        
        // Если нужно показать активный трек после загрузки
        if (event.showActiveTrack && currentActiveTrack != null) {
          _displayedTrack = currentActiveTrack;
        }
        
        emit(UserTracksLoaded(
          userTracks: _userTracks,
          activeTrack: _displayedTrack, // Отображаемый трек
          completedTracks: _completedTracks,
        ));
      },
    );
  }

  Future<void> _onLoadUserTrackForDate(LoadUserTrackForDateEvent event, Emitter<UserTracksState> emit) async {
    // print('[UserTracksBloc] _onLoadUserTrackForDate called for user=${event.user.id}, date=${event.date}');
    emit(UserTracksLoading());
    final result = await _getUserTrackForDateUseCase.call(event.user, event.date);
    result.fold(
      (failure) {
        // print('[UserTracksBloc] Track not found for date=${event.date}, failure=$failure');
        if (failure is NotFoundFailure) {
          // Трек не найден - просто не показываем ничего с уведомлением
          // print('[UserTracksBloc] Track not found for date=${event.date}');
          
          _userTracks = [];
          _displayedTrack = null; // Ничего не показываем
          _completedTracks = [];
          
          emit(UserTracksLoaded(
            userTracks: _userTracks,
            activeTrack: _displayedTrack,
            completedTracks: _completedTracks,
            notificationMessage: 'Нет данных за ${event.date.day}.${event.date.month}.${event.date.year}',
          ));
        } else {
          _error = 'Ошибка загрузки трека: $failure';
          emit(UserTracksError(_error!));
        }
      },
      (track) {
        // print('[UserTracksBloc] Track loaded for date=${event.date}, trackId=${track?.id}');
        _userTracks = track != null ? [track] : [];
        _displayedTrack = track; // Устанавливаем загруженный трек как отображаемый
        _completedTracks = track != null && track.status.name == 'completed' ? [track] : [];
        emit(UserTracksLoaded(
          userTracks: _userTracks,
          activeTrack: _displayedTrack, // отображаем загруженный трек
          completedTracks: _completedTracks,
        ));
      },
    );
  }

  void _onClearTracks(ClearTracksEvent event, Emitter<UserTracksState> emit) {
    // print('[UserTracksBloc] Clearing all tracks including displayedTrack');
    _userTracks.clear();
    _displayedTrack = null; // Очищаем отображаемый трек!
    _completedTracks.clear();
    _error = null;
    _lastLoadedUser = null;
    _lastLoadTime = null;
    emit(UserTracksInitial());
  }

  void _onSetDisplayedTrack(SetDisplayedTrackEvent event, Emitter<UserTracksState> emit) {
    // print('[UserTracksBloc] Setting displayed track: ${event.track?.id ?? "null"}');
    _displayedTrack = event.track;
    
    // Отрисовываем трек
    emit(UserTracksLoaded(
      userTracks: _userTracks,
      activeTrack: _displayedTrack, // отображаемый трек
      completedTracks: _completedTracks,
    ));
  }

  void _onShowActiveTrack(ShowActiveTrackEvent event, Emitter<UserTracksState> emit) {
    final currentActiveTrack = activeTrack; // используем getter
    add(SetDisplayedTrackEvent(currentActiveTrack));
  }

  void _subscribeToActiveTrack() {
    // Подписка на обновления сохраненных треков (редкие обновления)
    _trackUpdateSubscription = _locationTrackingService.trackUpdateStream.listen(
      (activeTrack) {
        add(ActiveTrackUpdatedEvent(activeTrack));
      },
      onError: (error) {
        print('❌ UserTracksBloc: Ошибка в trackUpdateStream: $error');
      },
    );
    
    // Подписка на live обновления буфера (частые обновления)
    _liveBufferSubscription = _locationTrackingService.liveBufferStream?.listen(
      (bufferSegment) {
        add(LiveBufferUpdatedEvent(bufferSegment));
      },
      onError: (error) {
        print('❌ UserTracksBloc: Ошибка в liveBufferStream: $error');
      },
    );
  }

  void _onActiveTrackUpdated(ActiveTrackUpdatedEvent event, Emitter<UserTracksState> emit) {
    // Всегда обновляем активный трек в памяти (для фонового трекинга)
    final existingIndex = _userTracks.indexWhere((track) => track.id == event.activeTrack.id);
    if (existingIndex != -1) {
      _userTracks[existingIndex] = event.activeTrack;
    } else {
      _userTracks.add(event.activeTrack);
    }
    
    // Обновляем UI только если активный трек сейчас отображается
    if (_displayedTrack?.id == event.activeTrack.id) {
      _displayedTrack = event.activeTrack;
      emit(UserTracksLoaded(
        userTracks: _userTracks,
        activeTrack: event.activeTrack,
        completedTracks: _completedTracks,
      ));
    } else {
      print('[UserTracksBloc] ❌ Активный трек НЕ отображается - игнорируем обновление UI');
    }
  }

  void _onLiveBufferUpdated(LiveBufferUpdatedEvent event, Emitter<UserTracksState> emit) {
    if (state is UserTracksLoaded) {
      final currentState = state as UserTracksLoaded;
      emit(currentState.copyWith(liveBuffer: event.bufferSegment));
    }
  }

  @override
  Future<void> close() {
    _activeTrackSubscription?.cancel();
    _trackUpdateSubscription?.cancel();
    _liveBufferSubscription?.cancel();
    return super.close();
  }
}
