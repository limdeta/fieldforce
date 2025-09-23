import 'package:fieldforce/app/domain/usecases/get_current_app_session_usecase.dart';
import 'package:fieldforce/features/authentication/domain/entities/session_state.dart';
import 'package:fieldforce/features/authentication/domain/services/authentication_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/bloc/user_tracks_bloc.dart';

/// Менеджер жизненного цикла приложения для GPS трекинга
class AppLifecycleManager with WidgetsBindingObserver {

  final LocationTrackingServiceBase _trackingService;
  final GetCurrentAppSessionUseCase _sessionUsecase;
  final AuthenticationService _authService;
  
  bool _isInitialized = false;
  bool _wasTrackingBeforePause = false;

  AppLifecycleManager({
    LocationTrackingServiceBase? trackingService,
    GetCurrentAppSessionUseCase? sessionUsecase,
    AuthenticationService? authService,
  }) : _trackingService = trackingService ?? GetIt.instance<LocationTrackingServiceBase>(),
       _sessionUsecase = sessionUsecase ?? GetIt.instance<GetCurrentAppSessionUseCase>(),
       _authService = authService ?? GetIt.instance<AuthenticationService>();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    WidgetsBinding.instance.addObserver(this);
    await _restoreActiveTrackingIfNeeded();
    _isInitialized = true;
  }

  void dispose() {
    if (_isInitialized) {
      WidgetsBinding.instance.removeObserver(this);
      _isInitialized = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _onAppResumed();
        break;
      case AppLifecycleState.paused:
        _onAppPaused();
        break;
      case AppLifecycleState.detached:
        _onAppDetached();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        _log('Приложение скрыто, трекинг продолжается в фоне');
        break;
    }
  }

  Future<void> _onAppResumed() async {
    _log('Приложение восстановлено');

    if (_wasTrackingBeforePause && !_trackingService.isTracking) {
      await _restoreActiveTrackingIfNeeded();
    }
    
    _wasTrackingBeforePause = false;

    // Фоновая проверка и обновление сессии при возвращении в приложение
    try {
      await _authService.refreshSessionIfNeeded();
    } catch (e) {
      _log('Ошибка при обновлении сессии: $e');
    }
  }

  Future<void> _onAppPaused() async {
    _log('Приложение свернуто');
    
    _wasTrackingBeforePause = _trackingService.isTracking;
    
    if (_trackingService.isTracking) {
      _log('Трекинг продолжается в фоновом режиме');
    }
  }

  Future<void> _onAppDetached() async {
    _log('Приложение закрывается');
    
    if (_trackingService.isTracking) {
      _log('Завершаем активный трек при закрытии приложения');
      await _trackingService.stopTracking();
    }
  }

  Future<void> _restoreActiveTrackingIfNeeded() async {
    try {
      final sessionResult = await _sessionUsecase.getSessionState();

      await sessionResult.fold(
        (failure) async {
          _log('Ошибка получения сессии: ${failure.message}');
        },
        (sessionState) async {
          await sessionState.when(
            onNotFound: () async {
              _log('Пользователь не авторизован');
            },
            onFound: (userSession) async {
              _log('Пользователь найден: ${userSession.externalId}');

              // Получаем AppSession/ AppUser через usecase (AppSession содержит AppUser который реализует NavigationUser)
              try {
                final appSessionResult = await _sessionUsecase.call();
                await appSessionResult.fold(
                  (failure) async {
                    _log('Не удалось получить AppSession: ${failure.message}');
                  },
                  (appSession) async {
                    if (appSession == null) {
                      _log('AppSession не найдена, пропускаем восстановление трекинга');
                      return;
                    }

                    final user = appSession.appUser as NavigationUser;

                    // Если сервис трекинга уже активен — синхронизируем BLoC'ы
                    if (_trackingService.isTracking) {
                      _log('TrackingService уже активен - синхронизируем состояние');
                      try {
                        if (GetIt.instance.isRegistered<TrackingBloc>()) {
                          final trackingBloc = GetIt.instance<TrackingBloc>();
                          trackingBloc.setUser(user);
                          trackingBloc.add(TrackingCheckStatus());
                        }
                        if (GetIt.instance.isRegistered<UserTracksBloc>()) {
                          final userTracksBloc = GetIt.instance<UserTracksBloc>();
                          userTracksBloc.add(LoadUserTracksEvent(user, showActiveTrack: true));
                        }
                      } catch (e) {
                        _log('Ошибка синхронизации BLoC при активном трекинге: $e');
                      }

                      return;
                    }

                    // Если трек уже существует в сервисе (например, был создан до паузы), синхронизируем BLoC'ы
                    final currentTrack = _trackingService.currentTrack;
                    if (currentTrack != null) {
                      _log('Найден существующий трек в сервисе (ID: ${currentTrack.id}) - синхронизируем состояние без автозапуска');

                      try {
                        if (GetIt.instance.isRegistered<TrackingBloc>()) {
                          final trackingBloc = GetIt.instance<TrackingBloc>();
                          trackingBloc.setUser(user);
                          trackingBloc.add(TrackingCheckStatus());
                        }
                        if (GetIt.instance.isRegistered<UserTracksBloc>()) {
                          final userTracksBloc = GetIt.instance<UserTracksBloc>();
                          userTracksBloc.add(LoadUserTracksEvent(user, showActiveTrack: true));
                        }
                      } catch (e) {
                        _log('Ошибка синхронизации BLoC после обнаружения трека: $e');
                      }

                      return;
                    }

                    // Если ничего не найдено — не автозапускаем трекинг, оставляем управление пользователю через кнопку
                    _log('Трек не обнаружен и автозапуск отключён в lifecycle manager — ничего не делаем');
                  },
                );
              } catch (e) {
                _log('Ошибка при попытке восстановления трекинга: $e');
              }
            },
          );
        },
      );
    } catch (e) {
      _log('Ошибка при восстановлении трекинга: $e');
    }
  }

  Future<bool> startWorkDayTracking({
    required NavigationUser user,
    String? routeId,
  }) async {
    if (_trackingService.isTracking) {
      _log('Трекинг уже активен');
      return true;
    }

    try {
      final success = await _trackingService.startTracking(user);

      if (success) {
        // Автоматический трекинг рабочего дня начат
      } else {
        // Не удалось начать автоматический трекинг
      }

      return success;
    } catch (e) {
      _log('Ошибка при запуске трекинга: $e');
      return false;
    }
  }

  Future<bool> stopWorkDayTracking() async {
    if (!_trackingService.isTracking) {
      _log('Трекинг не активен');
      return true;
    }

    try {
      await _trackingService.stopTracking();
      _log('Трекинг рабочего дня завершен');
      return true;
    } catch (e) {
      _log('Ошибка при остановке трекинга: $e');
      return false;
    }
  }

  Future<bool> shouldAutoStartTracking() async {
    try {
      final sessionResult = await _sessionUsecase.getSessionState();

      return await sessionResult.fold(
        (failure) async {
          _log('Ошибка получения сессии: ${failure.message}');
          return false;
        },
        (sessionState) async {
          return await sessionState.when(
            onNotFound: () async {
              return false;
            },
            onFound: (userSession) async {
              _log('Проверка автостарта для пользователя: ${userSession.externalId}');
              return false;
            },
          );
        },
      );
    } catch (e) {
      _log('Ошибка при проверке автостарта: $e');
      return false;
    }
  }

  bool get isTracking => _trackingService.isTracking;
  UserTrack? get currentTrack => _trackingService.currentTrack;

  void _log(String message) {
    if (kDebugMode) {
      // Сообщение
    }
  }
}
