import 'package:latlong2/latlong.dart';
import 'point_of_interest.dart';
import 'trading_point.dart';

/// Торговая точка на маршруте - реализация интерфейса
class TradingPointOfInterest implements PointOfInterest {
  @override
  final int? order;
  @override
  final int? id;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  
  @override
  final String name;
  
  @override
  final String? description;
  
  @override
  final LatLng coordinates;
  
  @override
  final DateTime? plannedArrivalTime;
  
  @override
  final DateTime? plannedDepartureTime;
  
  @override
  final DateTime? actualArrivalTime;
  
  @override
  final DateTime? actualDepartureTime;
  
  @override
  final PointType type;
  
  @override
  final VisitStatus status;
  
  @override
  final String? notes;

  final TradingPoint tradingPoint;

  TradingPointOfInterest({
    this.id,
    required this.name,
    required this.coordinates,
    required this.tradingPoint,
    this.description,
    this.plannedArrivalTime,
    this.plannedDepartureTime,
    this.actualArrivalTime,
    this.actualDepartureTime,
    this.type = PointType.client,
    this.status = VisitStatus.planned,
    this.notes,
  DateTime? createdAt,
  this.updatedAt,
  this.order,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  String? get externalId => tradingPoint.externalId;

  @override
  String get displayName => tradingPoint.name;

  @override
  TradingPointOfInterest copyWith({
    int? id,
    String? name,
    String? description,
    LatLng? coordinates,
    DateTime? plannedArrivalTime,
    DateTime? plannedDepartureTime,
    DateTime? actualArrivalTime,
    DateTime? actualDepartureTime,
    PointType? type,
    VisitStatus? status,
    String? notes,
    TradingPoint? tradingPoint,
    DateTime? createdAt,
  DateTime? updatedAt,
  int? order,
  }) {
    return TradingPointOfInterest(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coordinates: coordinates ?? this.coordinates,
      tradingPoint: tradingPoint ?? this.tradingPoint,
      plannedArrivalTime: plannedArrivalTime ?? this.plannedArrivalTime,
      plannedDepartureTime: plannedDepartureTime ?? this.plannedDepartureTime,
      actualArrivalTime: actualArrivalTime ?? this.actualArrivalTime,
      actualDepartureTime: actualDepartureTime ?? this.actualDepartureTime,
      type: type ?? this.type,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      order: order ?? this.order,
    );
  }

  @override
  bool get isVisited => status == VisitStatus.completed;

  @override
  bool get isCurrentlyAt => status == VisitStatus.arrived;

  @override
  bool get isOnTime {
    if (plannedArrivalTime == null || actualArrivalTime == null) {
      return true;
    }
    return actualArrivalTime!.isBefore(plannedArrivalTime!.add(const Duration(minutes: 15)));
  }

  @override
  Duration? get delay {
    if (plannedArrivalTime == null || actualArrivalTime == null) {
      return null;
    }
    if (actualArrivalTime!.isAfter(plannedArrivalTime!)) {
      return actualArrivalTime!.difference(plannedArrivalTime!);
    }
    return null;
  }

  @override
  String toString() {
    return 'TradingPointOfInterest(id: $id, tradingPoint: ${tradingPoint.name}, status: $status, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TradingPointOfInterest && other.id == id && other.order == order;
  }

  @override
  int get hashCode => Object.hash(id, order);
}
