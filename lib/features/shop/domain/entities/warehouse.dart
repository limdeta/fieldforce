// lib/features/shop/domain/entities/warehouse.dart

import 'package:equatable/equatable.dart';

/// Описание склада, доступного торговому представителю в конкретном регионе.
class Warehouse extends Equatable {
  final int id;
  final String name;
  final String vendorId;
  final String regionCode;
  final bool isPickUpPoint;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Warehouse({
    required this.id,
    required this.name,
    required this.vendorId,
    required this.regionCode,
    this.isPickUpPoint = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Warehouse copyWith({
    int? id,
    String? name,
    String? vendorId,
    String? regionCode,
    bool? isPickUpPoint,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Warehouse(
      id: id ?? this.id,
      name: name ?? this.name,
      vendorId: vendorId ?? this.vendorId,
      regionCode: regionCode ?? this.regionCode,
      isPickUpPoint: isPickUpPoint ?? this.isPickUpPoint,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        vendorId,
        regionCode,
        isPickUpPoint,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'Warehouse(id: $id, name: $name, vendorId: $vendorId, region: $regionCode, pickUp: $isPickUpPoint)';
  }
}
