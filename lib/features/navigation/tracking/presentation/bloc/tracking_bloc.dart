import 'package:flutter_bloc/flutter_bloc.dart';
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

// Состояния трекинга
abstract class TrackingState {}
class TrackingOff extends TrackingState {}
class TrackingStarting extends TrackingState {}
class TrackingOn extends TrackingState {}
class TrackingNoUser extends TrackingState {}

/// BLoC для управления трекингом как единым процессом
/// NavigationUser должен передаваться извне через события.
class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  final LocationTrackingServiceBase _trackingService;
  NavigationUser? _currentUser;

  TrackingBloc()
    : _trackingService = GetIt.instance<LocationTrackingServiceBase>(),
      super(TrackingNoUser()) {

    //  регистрируем все обработчики событий
    on<TrackingTogglePressed>((event, emit) async {
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

    on<TrackingCheckStatus>((event, emit) {
      print('🎯 TrackingBloc: Получен TrackingCheckStatus event');
      // Синхронизируем состояние с трекинг сервисом
      if (_trackingService.isTracking) {
        print('🎯 TrackingBloc: _trackingService.isTracking == true, emit TrackingOn');
        emit(TrackingOn());
      } else if (_currentUser != null) {
        print('🎯 TrackingBloc: _trackingService.isTracking == false, но пользователь есть');
        // Проверяем, был ли трекинг активен до этого (чтобы не останавливать случайно)
        if (state is TrackingOn) {
          print('⚠️ TrackingBloc: Трекинг был активен, но сервис сообщает false - возможно временная проблема, сохраняем состояние');
          // Не меняем состояние, если оно было активно
          return;
        }
        print('🎯 TrackingBloc: emit TrackingOff');
        emit(TrackingOff());
      } else {
        print('🎯 TrackingBloc: Нет пользователя, emit TrackingNoUser');
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
      print('🚀 Запуск трекинга для пользователя: ${_currentUser!.id}');

      bool success;
      if (!_trackingService.isTracking) {
        // Если трекинг не активен, запускаем автостарт
        success = await _trackingService.autoStartTracking(user: _currentUser!);
      } else {
        // Если трекинг был на паузе, явно возобновляем
        success = await _trackingService.resumeTracking();
      }

      if (success || _trackingService.isTracking) {
        emit(TrackingOn());
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
        await _trackingService.pauseTracking();
      } else {
        print('⚠️ Трекинг не активен');
      }

      emit(TrackingOff());
    } catch (e) {
      print('❌ Ошибка при постановке трекинга на паузу: $e');
      emit(TrackingOff());
    }
  }

  /// Метод для установки пользователя извне (из App слоя)
  void setUser(NavigationUser user) {
    _currentUser = user;
    add(TrackingCheckStatus());
  }
}
