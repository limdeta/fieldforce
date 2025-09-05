import 'package:fieldforce/app/domain/entities/point_of_interest.dart';
import 'package:latlong2/latlong.dart';

enum RouteStatus {
  planned,    
  active,
  completed,
  cancelled,
  paused,
}

/// Маршрут с точками интереса
/// 
/// TODO: Механизм переноса невыполненных точек
/// - Автоматический перенос незавершенных точек в маршрут следующего дня
/// - Приоритизация перенесенных точек (ставить в начало маршрута?)
/// - Уведомления руководителя о переносах
/// - Статистика по переносам для анализа планирования
/// 
/// TODO: Оптимизация маршрутов для повышения завершаемости
/// - Анализ исторических данных по времени выполнения точек
/// - Умное планирование с учетом реального времени в пути
/// - Предупреждения о перегруженных маршрутах (>80% времени дня)
/// - Рекомендации по перераспределению точек между днями
/// 
/// TODO: Механизм гибкого планирования
/// - Возможность пропустить точку и вернуться к ней позже в тот же день
/// - Динамическое перепланирование маршрута в процессе выполнения
/// - Учет приоритетности точек (критичные vs обычные)
class Route {
  final int? id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<PointOfInterest> pointsOfInterest;
  final List<LatLng> path; // Весь путь для отслеживания движения и расчета расхода
  final RouteStatus status;

  Route({
    this.id,
    required this.name,
    required this.pointsOfInterest,
    this.description,
    DateTime? createdAt,
    this.updatedAt,
    this.startTime,
    this.endTime,
    this.path = const [],
    this.status = RouteStatus.planned,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Создает копию с измененными параметрами
  Route copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startTime,
    DateTime? endTime,
    List<PointOfInterest>? pointsOfInterest,
    List<LatLng>? path,
    RouteStatus? status,
  }) {
    return Route(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      pointsOfInterest: pointsOfInterest ?? this.pointsOfInterest,
      path: path ?? this.path,
      status: status ?? this.status,
    );
  }

  /// Получает общую плановую длительность маршрута
  Duration? get plannedDuration {
    if (pointsOfInterest.isEmpty) return null;
    
    final firstPoint = pointsOfInterest.first;
    final lastPoint = pointsOfInterest.last;
    
    if (firstPoint.plannedArrivalTime != null && lastPoint.plannedDepartureTime != null) {
      return lastPoint.plannedDepartureTime!.difference(firstPoint.plannedArrivalTime!);
    }
    return null;
  }

  /// Получает фактическую длительность маршрута
  Duration? get actualDuration {
    if (startTime != null && endTime != null) {
      return endTime!.difference(startTime!);
    }
    return null;
  }

  /// Получает процент выполнения маршрута (0.0 - 1.0)
  double get completionPercentage {
    if (pointsOfInterest.isEmpty) return 0.0;
    
    final processedPoints = pointsOfInterest.where((p) => p.isVisited || p.status == VisitStatus.skipped).length;
    return processedPoints / pointsOfInterest.length;
  }

  /// Получает список клиентских точек
  List<PointOfInterest> get clientPoints {
    return pointsOfInterest.where((p) => p.type == PointType.client).toList();
  }

  /// Получает текущую активную точку (куда направляется или где находится)
  PointOfInterest? get currentPoint {
    // Ищем точку со статусом "arrived" или "enRoute"
    for (final point in pointsOfInterest) {
      if (point.status == VisitStatus.arrived || point.status == VisitStatus.enRoute) {
        return point;
      }
    }
    
    // Если не найдено, возвращаем следующую незавершенную точку
    return getNextPoint();
  }

  /// Получает следующую незавершенную точку
  PointOfInterest? getNextPoint() {
    for (final point in pointsOfInterest) {
      if (point.status == VisitStatus.planned) {
        return point;
      }
    }
    return null;
  }

  /// Получает точку по времени (для timeline навигации)
  PointOfInterest? getPointAtTime(DateTime time) {
    PointOfInterest? closest;
    Duration minDifference = const Duration(days: 1);
    
    for (final point in pointsOfInterest) {
      if (point.actualArrivalTime != null) {
        final difference = (point.actualArrivalTime!.difference(time)).abs();
        if (difference < minDifference) {
          minDifference = difference;
          closest = point;
        }
      } else if (point.plannedArrivalTime != null) {
        final difference = (point.plannedArrivalTime!.difference(time)).abs();
        if (difference < minDifference) {
          minDifference = difference;
          closest = point;
        }
      }
    }
    
    return closest;
  }

  List<LatLng> get coordinates {
    return pointsOfInterest.map((p) => p.coordinates).toList();
  }

  bool get isActive => status == RouteStatus.active;
  bool get isCompleted => status == RouteStatus.completed;

  double get totalDistanceKm {
    if (path.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    final Distance distance = Distance();
    
    for (int i = 1; i < path.length; i++) {
      totalDistance += distance.as(
        LengthUnit.Kilometer,
        path[i-1],
        path[i],
      );
    }
    
    return totalDistance;
  }

  double get pointsDistanceKm {
    if (pointsOfInterest.length < 2) return 0.0;
    
    double totalDistance = 0.0;
    final Distance distance = Distance();
    
    for (int i = 1; i < pointsOfInterest.length; i++) {
      totalDistance += distance.as(
        LengthUnit.Kilometer,
        pointsOfInterest[i-1].coordinates,
        pointsOfInterest[i].coordinates,
      );
    }
    
    return totalDistance;
  }

  /// Получает список незавершенных точек (для переноса на следующий день)
  /// TODO: Реализовать логику переноса в отдельном сервисе
  List<PointOfInterest> get uncompletedPoints {
    return pointsOfInterest.where((p) => 
      p.status == VisitStatus.planned || p.status == VisitStatus.enRoute
    ).toList();
  }

  /// Проверяет, является ли маршрут проблемным (низкая завершаемость)
  /// TODO: Настраиваемый порог через конфигурацию
  bool get isProblematic {
    return completionPercentage < 0.8; // Менее 80% завершенности
  }

  /// Получает приоритетные точки для переноса (клиенты важнее складов)
  /// TODO: Добавить систему приоритетов в PointOfInterest
  List<PointOfInterest> get priorityUncompletedPoints {
    final uncompleted = uncompletedPoints;
    uncompleted.sort((a, b) {
      // Клиенты в приоритете
      if (a.type == PointType.client && b.type != PointType.client) return -1;
      if (b.type == PointType.client && a.type != PointType.client) return 1;
      return 0;
    });
    return uncompleted;
  }

  @override
  String toString() {
    return 'Route(id: $id, name: $name, status: $status, points: ${pointsOfInterest.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Route && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

