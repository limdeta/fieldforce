import 'package:fieldforce/app/sync/syncable_entity.dart';

/// Торговая точка - бизнес-сущность из CRM/учетной системы
/// Используется для заказов, каталогов, остатков товаров
/// Сохраняется в таблице TradingPointEntities (НЕ TradingPoints!)
class TradingPoint implements SyncableEntity {
  final int? id;
  @override
  final String externalId;  // ID во внешней учетной системе
  final String name;
  final String? inn;
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  TradingPoint({
    this.id,
    required this.externalId,
    required this.name,
    this.inn,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();


  TradingPoint copyWith({
    int? id,
    String? externalId,
    String? name,
    String? inn,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TradingPoint(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      name: name ?? this.name,
      inn: inn ?? this.inn,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TradingPoint(id: $id, externalId: $externalId, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TradingPoint && other.externalId == externalId;
  }

  /// Создает TradingPoint из JSON данных
  factory TradingPoint.fromJson(Map<String, dynamic> json) {
    return TradingPoint(
      id: json['id'] as int?,
      externalId: json['external_id'] ?? json['externalId'] ?? '',
      name: json['name'] ?? '',
      inn: json['inn'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
    );
  }

  /// Преобразует TradingPoint в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'external_id': externalId,
      'name': name,
      'inn': inn,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

}
