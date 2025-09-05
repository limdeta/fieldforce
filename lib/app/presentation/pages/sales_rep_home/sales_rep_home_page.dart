import 'package:fieldforce/app/presentation/pages/route_detail_page.dart';
import 'package:fieldforce/app/presentation/widgets/app_tracking_button.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/providers/user_tracks_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as shop;
import 'package:fieldforce/app/presentation/widgets/combined_map_widget.dart';
import 'package:fieldforce/app/providers/selected_route_provider.dart';
import 'package:fieldforce/app/providers/work_day_provider.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'bloc/sales_rep_home_bloc.dart';
import 'bloc/sales_rep_home_event.dart';
import 'bloc/sales_rep_home_state.dart';

/// Главная страница торгового представителя с BLoC архитектурой
/// 
/// Использует BLoC паттерн:
/// - BLoC управляет состоянием и бизнес-логикой
/// - View реагирует на изменения состояния
/// - Events отправляются в BLoC для выполнения действий
class SalesRepHomePage extends StatelessWidget {
  final shop.Route? selectedRoute;
  final GpsDataManager gpsDataManager; // добавляем зависимость

  const SalesRepHomePage({
    super.key,
    this.selectedRoute,
    required this.gpsDataManager,
  });

  @override
  Widget build(BuildContext context) {
    // Читаем аргументы из именованного роута
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final selectedRouteFromArgs = args?['selectedRoute'] as shop.Route?;

    // Используем аргумент из роута или переданный через конструктор
    final routeToUse = selectedRouteFromArgs ?? selectedRoute;

    return BlocProvider(
      create: (context) => SalesRepHomeBloc()
        ..add(SalesRepHomeInitializeEvent(preselectedRoute: routeToUse)),
      child: SalesRepHomeView(gpsDataManager: gpsDataManager),
    );
  }
}

/// View компонент для отображения состояния
class SalesRepHomeView extends StatelessWidget {
  final GpsDataManager gpsDataManager;
  const SalesRepHomeView({super.key, required this.gpsDataManager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<SalesRepHomeBloc, SalesRepHomeState>(
        listener: (context, state) {
          // Обработка side effects (снэкбары, навигация, etc.)
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
                            const SalesRepHomeInitializeEvent(),
                          );
                        },
                      )
                    : null,
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              _buildMapArea(context, state),

              if (state is SalesRepHomeLoaded)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 70,
                  right: 16,
                  child: const AppTrackingButton(),
                ),

              // Верхняя панель
              if (state is SalesRepHomeLoaded && state.currentRoute != null)
                _buildTopPanel(context, state),
              
              // Нижняя панель
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
    );
  }

  /// Карта с маршрутом и треками
  Widget _buildMapArea(BuildContext context, SalesRepHomeState state) {
    return BlocBuilder<SalesRepHomeBloc, SalesRepHomeState>(
      builder: (context, blocState) {
        print('🏗️ MapArea builder: Вызван с состоянием ${blocState.runtimeType}');

        if (blocState is SalesRepHomeLoaded && blocState.activeTrack != null) {
          print('🗺️ MapArea builder: Активный трек в BLoC состоянии: ${blocState.activeTrack!.id} (${blocState.activeTrack!.totalPoints} точек)');
        }

        // Инициализируем WorkDayProvider при первом рендере
        return Consumer2<SelectedRouteProvider, WorkDayProvider>(
          builder: (context, selectedRouteProvider, workDayProvider, child) {
            if (workDayProvider.workDays.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                workDayProvider.loadWorkDays().then((_) {
                  final todayWorkDay = workDayProvider.todayWorkDay;
                  if (todayWorkDay != null) {
                    workDayProvider.selectWorkDay(todayWorkDay);
                  }
                });
              });
              return const Center(child: CircularProgressIndicator());
            }

            //  Синхронизируем WorkDayProvider с выбранным маршрутом
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final selectedRoute = selectedRouteProvider.selectedRoute;
              final currentSelectedWorkDay = workDayProvider.selectedWorkDay;

              if (selectedRoute != null) {
                final matchingWorkDay = workDayProvider.workDays.firstWhere(
                  (wd) => wd.route?.id == selectedRoute.id,
                  orElse: () => workDayProvider.todayWorkDay ?? workDayProvider.workDays.first,
                );

                if (currentSelectedWorkDay?.id != matchingWorkDay.id) {
                  print('🔄 SalesRepHomePage: Синхронизируем WorkDay с маршрутом "${selectedRoute.name}"');
                  workDayProvider.selectWorkDay(matchingWorkDay);
                }
              }
            });

            shop.Route? routeToShow;
            List<LatLng> routePolylinePoints = [];
            UserTrack? finalTrack;

            if (blocState is SalesRepHomeLoaded) {
              routeToShow = blocState.currentRoute;
              routePolylinePoints = blocState.routePolylinePoints;

              finalTrack = blocState.activeTrack;

              if (finalTrack != null) {
                print('🗺️ MapArea: Используем активный трек из ПАРАМЕТРА blocState: ${finalTrack.id} (${finalTrack.totalPoints} точек)');
              } else {
                // Fallback: получаем трек из выбранного WorkDay только если нет активного трека в BLoC
                final selectedWorkDay = workDayProvider.selectedWorkDay;
                if (selectedWorkDay != null && selectedWorkDay.track != null) {
                  finalTrack = selectedWorkDay.track;
                  if (finalTrack != null) {
                    print('🗺️ MapArea: Используем трек из выбранного WorkDay: ${finalTrack.id} (${finalTrack.totalPoints} точек)');
                  }
                } else {
                  print('🗺️ MapArea: Нет трека для отображения');
                }
              }
            }

            return CombinedMapWidget(
              route: routeToShow,
              track: finalTrack,
              onTap: (point) {
                print('Нажатие на карту: ${point.latitude}, ${point.longitude}');
              },
              routePolylinePoints: routePolylinePoints,
            );
          },
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
              color: Colors.black.withOpacity(0.1),
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
            
            // Информация о маршруте
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
                    const ToggleRoutePanelEvent(),
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
              color: Colors.black.withOpacity(0.1),
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
                      const BuildRouteEvent(),
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
      color: Colors.black.withOpacity(0.3),
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

  // Вспомогательные методы
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
}
