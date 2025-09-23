import 'dart:async';

import 'package:fieldforce/app/theme/app_colors.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/bloc/tracking_bloc.dart';
import 'package:fieldforce/app/presentation/pages/route_detail_page.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/bloc/user_tracks_bloc.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/app/presentation/widgets/combined_map_widget.dart';
import 'package:fieldforce/app/presentation/widgets/app_tracking_button.dart';
import 'package:fieldforce/app/presentation/widgets/tracking_debug_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as shop;
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'bloc/sales_rep_home_bloc.dart';
import 'bloc/sales_rep_home_event.dart' as home_events;
import 'bloc/sales_rep_home_state.dart';

/// Главная страница торгового представителя с BLoC архитектурой
class SalesRepHomePage extends StatelessWidget {
  final GpsDataManager gpsDataManager;

  const SalesRepHomePage({super.key, required this.gpsDataManager});

  @override
  Widget build(BuildContext context) {
    // Получаем аргументы маршрута
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final preselectedRoute = arguments?['selectedRoute'] as shop.Route?;

    return MultiBlocProvider(
      providers: [
        // Основные блоки
        BlocProvider<SalesRepHomeBloc>(
          create: (context) => SalesRepHomeBloc()
            ..add(
              home_events.SalesRepHomeInitializeEvent(
                preselectedRoute: preselectedRoute,
              ),
            ),
        ),
        // Use singleton UserTracksBloc from DI so it survives navigation
        BlocProvider<UserTracksBloc>.value(
          value: GetIt.instance<UserTracksBloc>(),
        ),
        // TrackingBloc из DI (синглтон для сохранения состояния)
        BlocProvider<TrackingBloc>.value(value: GetIt.instance<TrackingBloc>()),
      ],
      child: SalesRepHomeView(gpsDataManager: gpsDataManager),
    );
  }
}

class SalesRepHomeView extends StatefulWidget {
  final GpsDataManager gpsDataManager;
  const SalesRepHomeView({super.key, required this.gpsDataManager});

  @override
  State<SalesRepHomeView> createState() => _SalesRepHomeViewState();
}

class _SalesRepHomeViewState extends State<SalesRepHomeView> {
  NavigationUser? _user;
  bool _initialized = false;

  // Кэширование последней известной позиции пользователя
  LatLng? _cachedUserLocation;
  double? _cachedUserBearing;
  // Подписка на обновления TrackingBloc чтобы восстанавливать последнее положение
  StreamSubscription? _trackingBlocSubscription;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    // Подписываемся на TrackingBloc и восстанавливаем состояние после первого фрейма
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final trackingBloc = context.read<TrackingBloc>();

        // Восстанавливаем последнюю известную позицию из текущего состояния, если есть
        final currentState = trackingBloc.state;
        if (currentState is TrackingOn && currentState.latitude != null && currentState.longitude != null) {
          setState(() {
            _cachedUserLocation = LatLng(currentState.latitude!, currentState.longitude!);
            _cachedUserBearing = currentState.bearing;
          });
        }

        // Подписываемся на последующие обновления позиций
        _trackingBlocSubscription = trackingBloc.stream.listen((state) {
          if (!mounted) return;
          if (state is TrackingOn && state.latitude != null && state.longitude != null) {
            setState(() {
              _cachedUserLocation = LatLng(state.latitude!, state.longitude!);
              _cachedUserBearing = state.bearing;
            });
          }
        });
      } catch (e) {
        // Если контекст/блок ещё не доступен — игнорируем, это не критично
      }
    });
  }

  Future<void> _initializeUser() async {
    final sessionResult = await AppSessionService.getCurrentAppSession();
    final session = sessionResult.fold((l) => null, (r) => r);
    if (session != null && !_initialized) {
      setState(() {
        _user = session.appUser;
        _initialized = true;
      });

      // Инициализируем треки для пользователя и показываем активный трек
      if (mounted) {
        context.read<UserTracksBloc>().add(
          LoadUserTracksEvent(_user!, showActiveTrack: true),
        );

        // Обязательно установим пользователя в TrackingBloc чтобы кнопка трекинга работала
        try {
          final trackingBloc = context.read<TrackingBloc>();
          trackingBloc.setUser(_user!);
        } catch (_) {
          // Если блок недоступен — игнорируем (не критично)
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          // Слушаем обновления треков
          // Слушаем обновления позиции из TrackingBloc
          BlocListener<TrackingBloc, TrackingState>(
            listener: (context, state) {
              if (state is TrackingOn &&
                  state.latitude != null &&
                  state.longitude != null) {
                setState(() {
                  _cachedUserLocation = LatLng(
                    state.latitude!,
                    state.longitude!,
                  );
                  _cachedUserBearing = state.bearing;
                });
                // ИСПРАВЛЕНО: Debug панель покажет что происходит с позицией
              } else if (state is TrackingOff) {
                // НЕ сбрасываем позицию при остановке - сохраняем последнюю известную
                // setState(() {
                //   _cachedUserLocation = null;
                //   _cachedUserBearing = null;
                // });
              }
            },
          ),
          // Обработка ошибок
          BlocListener<SalesRepHomeBloc, SalesRepHomeState>(
            listener: (context, state) {
              if (state is SalesRepHomeError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    action: state.canRetry
                        ? SnackBarAction(
                            label: 'Повторить',
                            onPressed: () {
                              context.read<SalesRepHomeBloc>().add(
                                const home_events.SalesRepHomeInitializeEvent(),
                              );
                            },
                          )
                        : null,
                  ),
                );
              }
            },
          ),
          // Слушаем изменения маршрута для синхронизации треков
          BlocListener<SalesRepHomeBloc, SalesRepHomeState>(
            listener: (context, state) {
              if (state is SalesRepHomeLoaded &&
                  state.currentRoute != null &&
                  _user != null) {
                // Route changed

                // Синхронизируем треки с новым маршрутом
                _syncTracksWithRoute(state.currentRoute!);
              }
            },
          ),
        ],
        child: BlocBuilder<SalesRepHomeBloc, SalesRepHomeState>(
          builder: (context, state) {
            return Stack(
              children: [
                // Основная карта
                _buildMapArea(context, state),

                // Кнопка трекинга
                if (state is SalesRepHomeLoaded)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 70,
                    right: 16,
                    child: AppTrackingButton(),
                  ),

                // Debug панель для трекинга
                const TrackingDebugPanel(),

                // Верхняя панель с маршрутом
                if (state is SalesRepHomeLoaded) _buildTopPanel(context, state),

                // Нижняя панель с кнопками
                if (state is SalesRepHomeLoaded &&
                    state.currentRoute != null &&
                    state.showRoutePanel)
                  _buildBottomPanel(context, state),

                // Overlay загрузки
                if (state is SalesRepHomeLoading)
                  _buildLoadingOverlay(state.message),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _trackingBlocSubscription?.cancel();
    super.dispose();
  }

  /// Карта с маршрутом и треками (основной компонент)
  Widget _buildMapArea(BuildContext context, SalesRepHomeState state) {
    return BlocBuilder<SalesRepHomeBloc, SalesRepHomeState>(
      builder: (context, blocState) {
        if (blocState is SalesRepHomeLoaded) {
          final route = blocState.currentRoute;
          var track = blocState.activeTrack;
          final routePolylinePoints = blocState.routePolylinePoints;

          // Получаем liveBuffer из UserTracksBloc
          return BlocBuilder<UserTracksBloc, UserTracksState>(
            builder: (context, userTracksState) {
              CompactTrack? liveBuffer;
              if (userTracksState is UserTracksLoaded) {
                liveBuffer = userTracksState.liveBuffer;
                // Если в SalesRepHomeBloc нет activeTrack, используем отображаемый трек из UserTracksBloc
                if (track == null && userTracksState.activeTrack != null) {
                  track = userTracksState.activeTrack;
                }

                // Defensive: if the UI state lacks liveBuffer or displayed track
                // (for example when returning from a pushed route), attempt to
                // replay the last known snapshot from the LocationTrackingService
                // so the map receives immediate data without waiting for a new
                // GPS point. This is cheap and guarded to avoid spamming events.
                try {
                  final locationService = GetIt.instance<LocationTrackingServiceBase>();
                  final snapshot = locationService.getCurrentSnapshot();
                  if (!snapshot.isEmpty) {
                    // If bloc doesn't have persisted track but snapshot does, set it
                    if (snapshot.persistedTrack != null && userTracksState.activeTrack == null) {
                      context.read<UserTracksBloc>().add(SetDisplayedTrackEvent(snapshot.persistedTrack));
                    }
                    // If snapshot has live buffer but bloc state doesn't, push it
                    if (snapshot.liveBuffer != null && (userTracksState.liveBuffer == null || userTracksState.liveBuffer!.pointCount == 0)) {
                      context.read<UserTracksBloc>().add(LiveBufferUpdatedEvent(snapshot.liveBuffer!));
                    }
                  }
                } catch (e) {
                  // Ignore failures here - this is a best-effort UI hydration
                }
              }

              // Получаем позицию из TrackingBloc если кэшированной нет
              LatLng? userLocation = _cachedUserLocation;
              double? userBearing = _cachedUserBearing;

              // Если кэшированной позиции нет, берем из TrackingBloc
              return BlocBuilder<TrackingBloc, TrackingState>(
                builder: (context, trackingState) {
                  if (trackingState is TrackingOn &&
                      trackingState.latitude != null) {
                    userLocation ??= LatLng(
                      trackingState.latitude!,
                      trackingState.longitude!,
                    );
                    userBearing ??= trackingState.bearing;
                  }

                  return CombinedMapWidget(
                    route: route,
                    track: track,
                    liveBuffer: liveBuffer,
                    currentUserLocation: userLocation,
                    currentUserBearing: userBearing,
                    maxConnectionDistance:
                        250.0, // Максимальное расстояние для соединения сегментов
                    onTap: (point) {
                      // Обработка нажатия на карту
                    },
                    routePolylinePoints: routePolylinePoints,
                  );
                },
              );
            },
          );
        }

        // Состояние загрузки или ошибка - показываем карту с последним известным треком/буфером
        final userTracksState = context.read<UserTracksBloc>().state;
        UserTrack? displayedTrack;
        CompactTrack? liveBuffer;
        if (userTracksState is UserTracksLoaded) {
          displayedTrack = userTracksState.activeTrack;
          liveBuffer = userTracksState.liveBuffer;
        } else {
          displayedTrack = null;
          liveBuffer = null;
        }

        return CombinedMapWidget(
          route: null,
          track: displayedTrack,
          liveBuffer: liveBuffer,
          currentUserLocation: _cachedUserLocation,
          currentUserBearing: _cachedUserBearing,
          maxConnectionDistance: 150.0,
          onTap: (point) {},
          routePolylinePoints: const [],
        );
      },
    );
  }

  /// Верхняя панель с меню и информацией о маршруте
  Widget _buildTopPanel(BuildContext context, SalesRepHomeLoaded state) {
    final route = state.currentRoute;

    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            // Кнопка меню
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(color: AppColors.primary),
              child: IconButton(
                onPressed: () => Navigator.pushNamed(context, '/menu'),
                icon: const Icon(Icons.menu, color: Colors.white, size: 24),
              ),
            ),

            // Информация о маршруте или уведомление
            Expanded(
              child: route != null
                  ? GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RouteDetailPage(route: route),
                          ),
                        );
                      },
                      child: Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              route.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getRouteStatusColor(route.status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getRouteStatusText(route.status),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${_getCompletedCount(route)}/${route.pointsOfInterest.length}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Маршрут не установлен',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            'Выберите маршрут для начала работы',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
            ),

            // Кнопка скрыть/показать панель (только если есть маршрут)
            if (route != null)
              Container(
                width: 50,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(left: BorderSide(color: Colors.grey.shade300)),
                ),
                child: IconButton(
                  icon: Icon(
                    state.showRoutePanel
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () {
                    context.read<SalesRepHomeBloc>().add(
                      const home_events.ToggleRoutePanelEvent(),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Нижняя панель с кнопками
  Widget _buildBottomPanel(BuildContext context, SalesRepHomeLoaded state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              offset: const Offset(0, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: state.isBuildingRoute
                ? null
                : () {
                    context.read<SalesRepHomeBloc>().add(
                      home_events.BuildRouteEvent(
                        currentLocation: _cachedUserLocation,
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: state.isBuildingRoute
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Построить маршрут',
                    style: TextStyle(fontSize: 16),
                  ),
          ),
        ),
      ),
    );
  }

  /// Overlay загрузки
  Widget _buildLoadingOverlay(String? message) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'Загрузка...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Вспомогательные методы из оригинала
  Color _getRouteStatusColor(shop.RouteStatus status) {
    switch (status) {
      case shop.RouteStatus.planned:
        return Colors.blue;
      case shop.RouteStatus.active:
        return Colors.orange;
      case shop.RouteStatus.completed:
        return Colors.green;
      case shop.RouteStatus.cancelled:
        return Colors.red;
      case shop.RouteStatus.paused:
        return Colors.grey;
    }
  }

  String _getRouteStatusText(shop.RouteStatus status) {
    switch (status) {
      case shop.RouteStatus.planned:
        return 'Запланирован';
      case shop.RouteStatus.active:
        return 'Активный';
      case shop.RouteStatus.completed:
        return 'Завершен';
      case shop.RouteStatus.cancelled:
        return 'Отменен';
      case shop.RouteStatus.paused:
        return 'Приостановлен';
    }
  }

  int _getCompletedCount(shop.Route route) {
    return route.pointsOfInterest.where((point) => point.isVisited).length;
  }

  /// Синхронизирует треки с выбранным маршрутом
  void _syncTracksWithRoute(shop.Route route) {
    if (_user == null) return;

    // NOTE: do NOT clear displayed tracks immediately. Clearing here causes
    // the map to 'blink' (active track disappears) when navigating away and
    // back. Instead, let the subsequent LoadUserTracksEvent /
    // LoadUserTrackForDateEvent replace the tracks when new data arrives.
    // If a full clear is ever required, dispatch ClearTracksEvent explicitly
    // from user action.

    // Загружаем треки в зависимости от типа маршрута
    if (route.isActive) {
      // Active route - loading all tracks and showing active
      context.read<UserTracksBloc>().add(
        LoadUserTracksEvent(_user!, showActiveTrack: true),
      );
    } else {
      // Historical route - loading track for route date
      final routeDate = route.startTime ?? DateTime.now();
      // Loading track for route date
      context.read<UserTracksBloc>().add(
        LoadUserTrackForDateEvent(_user!, routeDate),
      );
    }
  }
}
