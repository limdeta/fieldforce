import 'package:fieldforce/app/domain/entities/point_of_interest.dart';
import 'package:latlong2/latlong.dart';
import 'package:fieldforce/app/domain/entities/route.dart';

/// Сервис для работы с маршрутами
/// 
/// TODO: Сервис переноса незавершенных точек
/// - RouteTransferService для автоматического переноса точек
/// - Анализ причин невыполнения (время, расстояние, приоритеты)
/// - Уведомления руководителей о переносах
/// - История переносов для аналитики
/// 

class RouteService {
  /// Создает новый маршрут
  Route createRoute({
    required String name,
    required List<PointOfInterest> pointsOfInterest,
    String? description,
    DateTime? startTime,
  }) {
    return Route(
      name: name,
      description: description,
      pointsOfInterest: pointsOfInterest,
      startTime: startTime,
    );
  }

  /// Начинает выполнение маршрута
  Route startRoute(Route route) {
    // Находим первую незавершенную точку
    PointOfInterest? firstUncompletedPoint;
    int firstUncompletedIndex = -1;
    
    for (int i = 0; i < route.pointsOfInterest.length; i++) {
      final point = route.pointsOfInterest[i];
      if (point.status != VisitStatus.completed && point.status != VisitStatus.skipped) {
        firstUncompletedPoint = point;
        firstUncompletedIndex = i;
        break;
      }
    }

    final updatedPoints = <PointOfInterest>[];
    for (int i = 0; i < route.pointsOfInterest.length; i++) {
      if (i == firstUncompletedIndex && firstUncompletedPoint != null) {
        updatedPoints.add(firstUncompletedPoint.copyWith(status: VisitStatus.enRoute));
      } else {
        updatedPoints.add(route.pointsOfInterest[i]);
      }
    }

    return route.copyWith(
      status: RouteStatus.active,
      startTime: DateTime.now(),
      pointsOfInterest: updatedPoints,
    );
  }

  /// Завершает выполнение маршрута
  Route completeRoute(Route route) {
    return route.copyWith(
      status: RouteStatus.completed,
      endTime: DateTime.now(),
    );
  }

  /// Приостанавливает маршрут
  Route pauseRoute(Route route) {
    return route.copyWith(status: RouteStatus.paused);
  }

  /// Возобновляет маршрут
  Route resumeRoute(Route route) {
    return route.copyWith(status: RouteStatus.active);
  }

  /// Отмечает прибытие в точку
  Route arriveAtPoint(Route route, String pointId) {
    final updatedPoints = route.pointsOfInterest.map((point) {
      if (point.id?.toString() == pointId) {
        return point.copyWith(
          status: VisitStatus.arrived,
          actualArrivalTime: DateTime.now(),
        );
      }
      return point;
    }).toList();

    return route.copyWith(pointsOfInterest: updatedPoints);
  }

  /// Завершает визит в точку
  Route completeVisit(Route route, String pointId) {
    final updatedPoints = route.pointsOfInterest.map((point) {
      if (point.id?.toString() == pointId) {
        return point.copyWith(
          status: VisitStatus.completed,
          actualDepartureTime: DateTime.now(),
        );
      }
      return point;
    }).toList();

    // Если есть следующая точка, отмечаем её как "в пути"
    final currentIndex = route.pointsOfInterest.indexWhere((p) => p.id?.toString() == pointId);
    if (currentIndex >= 0 && currentIndex < route.pointsOfInterest.length - 1) {
      final nextPoint = updatedPoints[currentIndex + 1];
      if (nextPoint.status == VisitStatus.planned) {
        updatedPoints[currentIndex + 1] = nextPoint.copyWith(status: VisitStatus.enRoute);
      }
    }

    final finalRoute = route.copyWith(pointsOfInterest: updatedPoints);

    // Проверяем, завершен ли весь маршрут
    if (finalRoute.completionPercentage >= 1.0) {
      return completeRoute(finalRoute);
    }

    return finalRoute;
  }

  /// Пропускает точку
  Route skipPoint(Route route, String pointId, String reason) {
    final updatedPoints = route.pointsOfInterest.map((point) {
      if (point.id?.toString() == pointId) {
        return point.copyWith(
          status: VisitStatus.skipped,
          notes: '${point.notes ?? ''}${point.notes?.isNotEmpty == true ? '\n' : ''}Пропущено: $reason',
        );
      }
      return point;
    }).toList();

    // Переходим к следующей точке
    final currentIndex = route.pointsOfInterest.indexWhere((p) => p.id?.toString() == pointId);
    if (currentIndex >= 0 && currentIndex < route.pointsOfInterest.length - 1) {
      final nextPoint = updatedPoints[currentIndex + 1];
      if (nextPoint.status == VisitStatus.planned) {
        updatedPoints[currentIndex + 1] = nextPoint.copyWith(status: VisitStatus.enRoute);
      }
    }

    return route.copyWith(pointsOfInterest: updatedPoints);
  }

  /// Добавляет координаты пути для отслеживания движения
  Route addPathPoint(Route route, LatLng coordinates) {
    final updatedPath = [...route.path, coordinates];
    return route.copyWith(path: updatedPath);
  }

  /// Очищает путь (например, для нового дня)
  Route clearPath(Route route) {
    return route.copyWith(path: []);
  }

  /// Получает статистику по маршруту
  RouteStatistics getRouteStatistics(Route route) {
    final totalPoints = route.pointsOfInterest.length;
    final completedPoints = route.pointsOfInterest.where((p) => p.isVisited).length;
    final skippedPoints = route.pointsOfInterest.where((p) => p.status == VisitStatus.skipped).length;
    final onTimePoints = route.pointsOfInterest.where((p) => p.isVisited && p.isOnTime).length;
    final delayedPoints = route.pointsOfInterest.where((p) => p.isVisited && !p.isOnTime).length;

    Duration totalDelay = Duration.zero;
    for (final point in route.pointsOfInterest.where((p) => p.isVisited)) {
      final delay = point.delay;
      if (delay != null && delay.isNegative == false) {
        totalDelay += delay;
      }
    }

    return RouteStatistics(
      totalPoints: totalPoints,
      completedPoints: completedPoints,
      skippedPoints: skippedPoints,
      onTimePoints: onTimePoints,
      delayedPoints: delayedPoints,
      completionPercentage: route.completionPercentage,
      totalDelay: totalDelay,
      totalDistance: route.totalDistanceKm,
      plannedDuration: route.plannedDuration,
      actualDuration: route.actualDuration,
    );
  }

  /// Создает маршрут по временным интервалам (для проигрывания timeline)
  List<RouteTimelineFrame> createTimeline(Route route, {
    Duration frameInterval = const Duration(minutes: 5),
  }) {
    if (route.pointsOfInterest.isEmpty) return [];

    final frames = <RouteTimelineFrame>[];
    
    // Получаем временные границы
    DateTime? startTime = route.startTime;
    DateTime? endTime = route.endTime;
    
    // Если нет фактических времен, используем плановые
    startTime ??= route.pointsOfInterest.first.plannedArrivalTime ?? DateTime.now();
    endTime ??= route.pointsOfInterest.last.plannedDepartureTime ?? 
               startTime.add(const Duration(hours: 8));

    DateTime currentTime = startTime;
    while (currentTime.isBefore(endTime)) {
      final currentPoint = route.getPointAtTime(currentTime);
      final completedPoints = route.pointsOfInterest
          .where((p) => _isPointCompletedAtTime(p, currentTime))
          .toList();

      frames.add(RouteTimelineFrame(
        timestamp: currentTime,
        currentPoint: currentPoint,
        completedPoints: completedPoints,
        routeProgress: completedPoints.length / route.pointsOfInterest.length,
      ));

      currentTime = currentTime.add(frameInterval);
    }

    return frames;
  }

  /// Проверяет, завершена ли точка на указанное время
  bool _isPointCompletedAtTime(PointOfInterest point, DateTime time) {
    if (point.actualDepartureTime != null) {
      return point.actualDepartureTime!.isBefore(time) || 
             point.actualDepartureTime!.isAtSameMomentAs(time);
    }
    if (point.plannedDepartureTime != null) {
      return point.plannedDepartureTime!.isBefore(time) || 
             point.plannedDepartureTime!.isAtSameMomentAs(time);
    }
    return false;
  }

  /// Генерирует уникальный ID
  String _generateId() {
    return 'route_${DateTime.now().millisecondsSinceEpoch}';
  }

  // TODO: Реализовать после создания data слоя
  /*
  /// Переносит незавершенные точки в маршрут следующего дня
  Future<Route> transferUncompletedPoints(Route currentRoute, String userId) async {
    // 1. Получить незавершенные точки с приоритизацией
    final uncompletedPoints = currentRoute.priorityUncompletedPoints;
    
    // 2. Создать или обновить маршрут на следующий день
    final nextDate = DateTime.now().add(const Duration(days: 1));
    
    // 3. Вставить точки в начало нового маршрута (приоритетные первыми)
    // 4. Обновить статусы в текущем маршруте на 'transferred'
    // 5. Уведомить руководителя о переносе
    
    throw UnimplementedError('Требует data слой');
  }

  /// Анализирует эффективность маршрута и дает рекомендации
  RouteAnalysis analyzeRouteEfficiency(Route route) {
    // TODO: Анализ времени, расстояний, процента выполнения
    // TODO: Сравнение с историческими данными
    // TODO: Рекомендации по улучшению
    
    throw UnimplementedError('Требует исторические данные');
  }
  */
}

/// TODO: Создать после реализации data слоя
/*
class RouteAnalysis {
  final double efficiencyScore; // 0.0 - 1.0
  final List<String> recommendations;
  final Duration estimatedOvertime;
  final List<IPointOfInterest> problematicPoints;
  
  const RouteAnalysis({
    required this.efficiencyScore,
    required this.recommendations,
    required this.estimatedOvertime,
    required this.problematicPoints,
  });
}
*/

/// Статистика по маршруту
class RouteStatistics {
  final int totalPoints;
  final int completedPoints;
  final int skippedPoints;
  final int onTimePoints;
  final int delayedPoints;
  final double completionPercentage;
  final Duration totalDelay;
  final double totalDistance;
  final Duration? plannedDuration;
  final Duration? actualDuration;

  const RouteStatistics({
    required this.totalPoints,
    required this.completedPoints,
    required this.skippedPoints,
    required this.onTimePoints,
    required this.delayedPoints,
    required this.completionPercentage,
    required this.totalDelay,
    required this.totalDistance,
    this.plannedDuration,
    this.actualDuration,
  });

  @override
  String toString() {
    return 'RouteStatistics(total: $totalPoints, completed: $completedPoints, completion: ${(completionPercentage * 100).toStringAsFixed(1)}%)';
  }
}

/// Кадр timeline для проигрывания маршрута
class RouteTimelineFrame {
  final DateTime timestamp;
  final PointOfInterest? currentPoint;
  final List<PointOfInterest> completedPoints;
  final double routeProgress;

  const RouteTimelineFrame({
    required this.timestamp,
    this.currentPoint,
    required this.completedPoints,
    required this.routeProgress,
  });

  @override
  String toString() {
    return 'RouteTimelineFrame(time: $timestamp, current: ${currentPoint?.name}, progress: ${(routeProgress * 100).toStringAsFixed(1)}%)';
  }
}
