import 'package:fieldforce/app/domain/entities/point_of_interest.dart';
import 'package:fieldforce/app/domain/entities/regular_point_of_interest.dart';
import 'package:fieldforce/app/domain/entities/trading_point_of_interest.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as domain;
import 'package:flutter/material.dart';

/// Детальная страница маршрута со списком всех точек
class RouteDetailPage extends StatelessWidget {
  final domain.Route route;

  const RouteDetailPage({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(route.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Заголовок с информацией о маршруте
          _buildRouteHeader(),
          
          // Список точек интереса
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: route.pointsOfInterest.length,
              itemBuilder: (context, index) {
                final point = route.pointsOfInterest[index];
                return _buildPointCard(point, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            route.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (route.description != null) ...[
            const SizedBox(height: 4),
            Text(
              route.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${route.pointsOfInterest.length} точек',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _formatDuration(route.plannedDuration),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              _buildStatusChip(route.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointCard(PointOfInterest point, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getPointStatusColor(point.status),
                  child: Text(
                    index.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        point.name.isNotEmpty ? point.name : 'Точка $index',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (point.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          point.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildPointStatusChip(point.status),
              ],
            ),
            const SizedBox(height: 12),
            
            // Информация о типе точки
            Row(
              children: [
                Icon(
                  _getPointTypeIcon(point),
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _getPointTypeText(point),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            // Временная информация
            if (point.plannedArrivalTime != null) ...[
              const SizedBox(height: 8),
              _buildTimeInfo(point),
            ],
            
            // Заметки
            if (point.notes != null && point.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point.notes!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(PointOfInterest point) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              'План: ${_formatTime(point.plannedArrivalTime)} - ${_formatTime(point.plannedDepartureTime)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        if (point.actualArrivalTime != null || point.actualDepartureTime != null) ...[
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(Icons.check_circle, size: 14, color: Colors.green[600]),
              const SizedBox(width: 4),
              Text(
                'Факт: ${_formatTime(point.actualArrivalTime)} - ${_formatTime(point.actualDepartureTime)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatusChip(domain.RouteStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getRouteStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRouteStatusColor(status),
          width: 1,
        ),
      ),
      child: Text(
        _getRouteStatusText(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getRouteStatusColor(status),
        ),
      ),
    );
  }

  Widget _buildPointStatusChip(VisitStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getPointStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getPointStatusColor(status),
          width: 1,
        ),
      ),
      child: Text(
        _getPointStatusText(status),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getPointStatusColor(status),
        ),
      ),
    );
  }

  IconData _getPointTypeIcon(PointOfInterest point) {
    if (point is TradingPointOfInterest) {
      return Icons.store;
    } else if (point is RegularPointOfInterest) {
      switch (point.type) {
        case PointType.warehouse:
          return Icons.warehouse;
        case PointType.break_:
          return Icons.restaurant;
        case PointType.startPoint:
          return Icons.home;
        case PointType.endPoint:
          return Icons.flag;
        default:
          return Icons.location_on;
      }
    }
    return Icons.location_on;
  }

  String _getPointTypeText(PointOfInterest point) {
    if (point is TradingPointOfInterest) {
      return 'Торговая точка';
    } else if (point is RegularPointOfInterest) {
      switch (point.type) {
        case PointType.warehouse:
          return 'Склад';
        case PointType.break_:
          return 'Перерыв';
        case PointType.startPoint:
          return 'Начало';
        case PointType.endPoint:
          return 'Конец';
        case PointType.client:
          return 'Клиент';
        default:
          return 'Точка';
      }
    }
    return 'Точка';
  }

  Color _getPointStatusColor(VisitStatus status) {
    switch (status) {
      case VisitStatus.planned:
        return Colors.blue;
      case VisitStatus.enRoute:
        return Colors.orange;
      case VisitStatus.arrived:
        return Colors.purple;
      case VisitStatus.completed:
        return Colors.green;
      case VisitStatus.skipped:
        return Colors.grey;
    }
  }

  String _getPointStatusText(VisitStatus status) {
    switch (status) {
      case VisitStatus.planned:
        return 'План';
      case VisitStatus.enRoute:
        return 'В пути';
      case VisitStatus.arrived:
        return 'Прибыл';
      case VisitStatus.completed:
        return 'Выполнено';
      case VisitStatus.skipped:
        return 'Пропущено';
    }
  }

  Color _getRouteStatusColor(domain.RouteStatus status) {
    switch (status) {
      case domain.RouteStatus.planned:
        return Colors.blue;
      case domain.RouteStatus.active:
        return Colors.orange;
      case domain.RouteStatus.completed:
        return Colors.green;
      case domain.RouteStatus.cancelled:
        return Colors.red;
      case domain.RouteStatus.paused:
        return Colors.grey;
    }
  }

  String _getRouteStatusText(domain.RouteStatus status) {
    switch (status) {
      case domain.RouteStatus.planned:
        return 'Запланирован';
      case domain.RouteStatus.active:
        return 'Активный';
      case domain.RouteStatus.completed:
        return 'Завершен';
      case domain.RouteStatus.cancelled:
        return 'Отменен';
      case domain.RouteStatus.paused:
        return 'Приостановлен';
    }
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'Неизвестно';
    
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    
    if (hours > 0) {
      return '$hoursч $minutesм';
    } else {
      return '$minutesм';
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--';
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
