import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:get_it/get_it.dart';

// События для управления трекингом
abstract class TrackingEvent {}
class TrackingTogglePressed extends TrackingEvent {}
class TrackingStart extends TrackingEvent {
  final NavigationUser user;
  TrackingStart(this.user);
}
class TrackingCheckStatus extends TrackingEvent {}
class TrackingPositionUpdated extends TrackingEvent {
  final double latitude;
  final double longitude;
  final double bearing;
  TrackingPositionUpdated(this.latitude, this.longitude, this.bearing);
}

// Состояния трекинга
abstract class TrackingState {}
class TrackingOff extends TrackingState {}
class TrackingStarting extends TrackingState {}
class TrackingOn extends TrackingState {
  final double? latitude;
  final double? longitude;
  final double? bearing;
  
  TrackingOn({this.latitude, this.longitude, this.bearing});
}
class TrackingNoUser extends TrackingState {}

/// BLoC для управления трекингом как единым процессом
/// NavigationUser должен передаваться извне через события.
class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final LocationTrackingServiceBase _trackingService;
  NavigationUser? _currentUser;
  StreamSubscription? _positionSubscription;
  static final Logger _logger = Logger('TrackingBloc');
  
  // Последняя известная позиция пользователя
  double? _lastLatitude;
  double? _lastLongitude;
  double? _lastBearing;

  TrackingBloc()
    : _trackingService = GetIt.instance<LocationTrackingServiceBase>(),
      super(TrackingNoUser()) {

    //  регистрируем все обработчики событий
    on<TrackingTogglePressed>((event, emit) async {
      _logger.info('TrackingTogglePressed received - current state=${state.runtimeType}');
      if (_currentUser == null) {
        emit(TrackingNoUser());
        return;
      }

      if (state is TrackingOff) {
        await _startTracking(emit);
      } else if (state is TrackingOn) {
        await _pauseTracking(emit);
      }
    });

    on<TrackingStart>((event, emit) async {
      _currentUser = event.user;
      await _startTracking(emit);
    });

    on<TrackingPositionUpdated>((event, emit) {
      if (state is TrackingOn) {
        emit(TrackingOn(latitude: event.latitude, longitude: event.longitude, bearing: event.bearing));
      }
    });

    on<TrackingCheckStatus>((event, emit) {
      // Синхронизируем состояние с трекинг сервисом
      if (_trackingService.isTracking) {
        emit(TrackingOn(latitude: _lastLatitude, longitude: _lastLongitude, bearing: _lastBearing));
      } else if (_currentUser != null) {
        // ИСПРАВЛЕНО: НЕ автовосстанавливаем трекинг, только показываем правильное состояние
        emit(TrackingOff());
      } else {
        emit(TrackingNoUser());
      }
    });

    // после регистрации обработчиков проверяем текущий статус
    add(TrackingCheckStatus());
  }

  Future<void> _startTracking(Emitter<TrackingState> emit) async {
    if (_currentUser == null) {
      emit(TrackingNoUser());
      return;
    }

    emit(TrackingStarting());

    try {
      bool success;
      if (!_trackingService.isTracking) {
        // Если трекинг не активен, запускаем автостарт
        success = await _trackingService.autoStartTracking(user: _currentUser!);
      } else {
        // Если трекинг был на паузе, явно возобновляем
        success = await _trackingService.resumeTracking();
      }

      if (success || _trackingService.isTracking) {
        // Подписываемся на поток позиций для отслеживания текущего положения
        _setupPositionSubscription();
        emit(TrackingOn(latitude: _lastLatitude, longitude: _lastLongitude, bearing: _lastBearing));
      } else {
        emit(TrackingOff());
      }
    } catch (e) {
      emit(TrackingOff());
    }
  }

  Future<void> _pauseTracking(Emitter<TrackingState> emit) async {
    try {
      if (_trackingService.isTracking) {
        _logger.info('Attempting to pause tracking via trackingService');
        final paused = await _trackingService.pauseTracking();
        _logger.info('pauseTracking returned: $paused');

        if (!paused) {
          _logger.warning('pauseTracking failed; attempting full stop');
          try {
            final stopped = await _trackingService.stopTracking();
            _logger.info('stopTracking fallback returned: $stopped');
          } catch (e, st) {
            _logger.severe('stopTracking fallback failed', e, st);
          }
        }
      }

      emit(TrackingOff());
    } catch (e) {
      emit(TrackingOff());
    }
  }

  /// Метод для установки пользователя извне (из App слоя)
  void setUser(NavigationUser user) {
    _currentUser = user;
    add(TrackingCheckStatus());
  }

  /// Настроить подписку на поток позиций
  void _setupPositionSubscription() {
    _positionSubscription?.cancel();
    
    try {
        _positionSubscription = _trackingService.positionStream.listen(
        (position) {
          // Сохраняем последнюю позицию
          _lastLatitude = position.latitude;
          _lastLongitude = position.longitude;
          _lastBearing = position.heading;
          
          // Отправляем событие обновления позиции
          add(TrackingPositionUpdated(position.latitude, position.longitude, position.heading));
        },
        onError: (error) {
          // Ошибки обрабатываются внутри TrackingService
        },
        onDone: () {
          // Завершение стрима - нормальное поведение при остановке трекинга
        },
      );
    } catch (e) {
      // Subscription может быть отменена, игнорируем
    }
  }

  /// Получить текущую позицию пользователя
  (double?, double?, double?) getCurrentPosition() {
    return (_lastLatitude, _lastLongitude, _lastBearing);
  }
}
