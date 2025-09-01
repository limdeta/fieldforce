import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:fieldforce/features/shop/domain/entities/route.dart' as shop;
import 'package:fieldforce/features/shop/presentation/route_detail_page.dart';
import 'package:fieldforce/app/presentation/widgets/combined_map_widget.dart';
import 'package:fieldforce/app/providers/selected_route_provider.dart';
import 'package:fieldforce/features/navigation/tracking/presentation/providers/user_tracks_provider.dart';
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

  const SalesRepHomePage({
    super.key,
    this.selectedRoute,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SalesRepHomeBloc()
        ..add(SalesRepHomeInitializeEvent(preselectedRoute: selectedRoute)),
      child: const SalesRepHomeView(),
    );
  }
}

/// View компонент для отображения состояния
class SalesRepHomeView extends StatelessWidget {
  const SalesRepHomeView({super.key});

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
              // Карта - основной контент
              _buildMapArea(context, state),
              
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
    return Consumer2<SelectedRouteProvider, UserTracksProvider>(
      builder: (context, selectedRouteProvider, tracksProvider, child) {
        shop.Route? routeToShow;
        List<LatLng> routePolylinePoints = [];
        
        if (state is SalesRepHomeLoaded) {
          routeToShow = state.currentRoute;
          routePolylinePoints = state.routePolylinePoints;
        }
        
        final tracks = tracksProvider.userTracks;
        
        return CombinedMapWidget(
          route: routeToShow,
          historicalTracks: tracks,
          onTap: (point) {
            print('Нажатие на карту: ${point.latitude}, ${point.longitude}');
          },
          routePolylinePoints: routePolylinePoints,
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
