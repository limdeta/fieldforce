import 'package:latlong2/latlong.dart';
import 'point_of_interest.dart';

/// Обычная точка интереса (офис, склад, перерыв и т.д.)
class RegularPointOfInterest implements PointOfInterest {
  @override
  final int? id;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
    @override
    final int? order;
  
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

  RegularPointOfInterest({
    this.id,
    required this.name,
    required this.coordinates,
    this.description,
    this.plannedArrivalTime,
    this.plannedDepartureTime,
    this.actualArrivalTime,
    this.actualDepartureTime,
    this.type = PointType.regular,
    this.status = VisitStatus.planned,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
    this.order,
  }) : createdAt = createdAt ?? DateTime.now();

  @override
  String? get externalId => null; // Обычные точки не связаны с внешней системой

  @override
  String get displayName => name;

  @override
  String? get additionalInfo => description;

  @override
  RegularPointOfInterest copyWith({
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
    DateTime? createdAt,
    DateTime? updatedAt,
      int? order,
  }) {
    return RegularPointOfInterest(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coordinates: coordinates ?? this.coordinates,
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
    return 'RegularPointOfInterest(id: $id, name: $name, type: $type, status: $status, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegularPointOfInterest && other.id == id;
  }

  @override
  int get hashCode => Object.hash(id, order);
}
