import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/app/presentation/pages/route_detail_page.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/bloc/user_tracks_bloc.dart';
import 'package:fieldforce/app/presentation/widgets/combined_map_widget.dart';
import 'package:fieldforce/app/presentation/widgets/app_tracking_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as shop;
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'bloc/sales_rep_home_bloc.dart';
import 'bloc/sales_rep_home_event.dart' as home_events;
import 'bloc/sales_rep_home_state.dart';

/// Главная страница торгового представителя с BLoC архитектурой
class SalesRepHomePage extends StatelessWidget {
  final GpsDataManager gpsDataManager;

  const SalesRepHomePage({
    super.key,
    required this.gpsDataManager,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем аргументы маршрута
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final preselectedRoute = arguments?['selectedRoute'] as shop.Route?;

    return MultiBlocProvider(
      providers: [
        // Основные блоки
        BlocProvider<SalesRepHomeBloc>(
          create: (context) => SalesRepHomeBloc()
            ..add(home_events.SalesRepHomeInitializeEvent(preselectedRoute: preselectedRoute)),
        ),
        BlocProvider<UserTracksBloc>(
          create: (context) => UserTracksBloc(),
        ),
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

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final sessionResult = await AppSessionService.getCurrentAppSession();
    final session = sessionResult.fold((l) => null, (r) => r);
    if (session != null && !_initialized) {
      setState(() {
        _user = session.appUser;
        _initialized = true;
      });
      
      // Инициализируем треки для пользователя
      if (mounted) {
        context.read<UserTracksBloc>().add(LoadUserTracksEvent(_user!));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          // Слушаем обновления треков
          BlocListener<UserTracksBloc, UserTracksState>(
            listener: (context, state) {
              if (state is UserTracksLoaded && state.activeTrack != null) {
                print('[UI] Track loaded: id=${state.activeTrack!.id}');
                // Уведомляем SalesRepHomeBloc об обновлении трека
                context.read<SalesRepHomeBloc>().add(home_events.ActiveTrackUpdatedEvent(state.activeTrack!));
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
              if (state is SalesRepHomeLoaded && state.currentRoute != null && _user != null) {
                print('[UI] Route changed: ${state.currentRoute!.name}');
                
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

                // Верхняя панель с маршрутом
                if (state is SalesRepHomeLoaded && state.currentRoute != null)
                  _buildTopPanel(context, state),

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

  /// Карта с маршрутом и треками (основной компонент)
  Widget _buildMapArea(BuildContext context, SalesRepHomeState state) {
    return BlocBuilder<SalesRepHomeBloc, SalesRepHomeState>(
      builder: (context, blocState) {
        print('🏗��� MapArea builder: состояние ${blocState.runtimeType}');

        if (blocState is SalesRepHomeLoaded) {
          final route = blocState.currentRoute;
          final track = blocState.activeTrack;
          final routePolylinePoints = blocState.routePolylinePoints;

          if (track != null) {
            print('🗺️ MapArea: Отображаем трек ${track.id} (${track.totalPoints} точек)');
          }

          // Получаем liveBuffer из UserTracksBloc
          return BlocBuilder<UserTracksBloc, UserTracksState>(
            builder: (context, userTracksState) {
              CompactTrack? liveBuffer;
              if (userTracksState is UserTracksLoaded) {
                liveBuffer = userTracksState.liveBuffer;
                if (liveBuffer != null) {
                  print('📍 MapArea: Live буфер содержит ${liveBuffer.pointCount} точек');
                }
              }

              return CombinedMapWidget(
                route: route,
                track: track,
                liveBuffer: liveBuffer,
                onTap: (point) {
                  print('Нажатие на карту: ${point.latitude}, ${point.longitude}');
                },
                routePolylinePoints: routePolylinePoints,
              );
            },
          );
        }

        // Состояние загрузки или ошибки - показываем пустую карту
        return CombinedMapWidget(
          route: null,
          track: null,
          liveBuffer: null,
          onTap: (point) {},
          routePolylinePoints: const [],
        );
      },
    );
  }

  /// Верхняя панель с меню и информацией о маршруте
  Widget _buildTopPanel(BuildContext context, SalesRepHomeLoaded state) {
    final route = state.currentRoute!;

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
              decoration: const BoxDecoration(color: Colors.blue),
              child: IconButton(
                onPressed: () => Navigator.pushNamed(context, '/menu'),
                icon: const Icon(Icons.menu, color: Colors.white, size: 24),
              ),
            ),

            // Инф��рмация о маршруте
            Expanded(
              child: GestureDetector(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              ),
            ),

            // Кнопка скрыть/показать панель
            Container(
              width: 50,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  left: BorderSide(color: Colors.grey.shade300),
                ),
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
                      const home_events.BuildRouteEvent(),
                    );
                  },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: Colors.blue,
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
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
    return route.pointsOfInterest
        .where((point) => point.isVisited)
        .length;
  }

  /// Синхронизирует треки с выбранным маршрутом
  void _syncTracksWithRoute(shop.Route route) {
    if (_user == null) return;

    // Очищаем старые треки
    context.read<UserTracksBloc>().add(ClearTracksEvent());

    // Загружаем треки в зависимости от типа маршрута
    if (route.isActive) {
      print('[UI] Active route - loading all tracks and showing active');
      context.read<UserTracksBloc>().add(LoadUserTracksEvent(_user!, showActiveTrack: true));
    } else {
      print('[UI] Historical route - loading track for route date');
      final routeDate = route.startTime ?? DateTime.now();
      print('[UI] Loading track for route date: $routeDate');
      context.read<UserTracksBloc>().add(LoadUserTrackForDateEvent(_user!, routeDate));
    }
  }
}
