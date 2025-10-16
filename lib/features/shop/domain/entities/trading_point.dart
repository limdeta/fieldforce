import 'package:fieldforce/app/sync/syncable_entity.dart';

/// Торговая точка - бизнес-сущность из CRM/учетной системы
/// Используется для заказов, каталогов, остатков товаров
/// Сохраняется в таблице TradingPointEntities (НЕ TradingPoints!)
class TradingPoint implements SyncableEntity {
  static const String defaultRegion = 'P3V';

  final int? id;
  @override
  final String externalId;  // ID во внешней учетной системе
  final String name;
  final String? inn;
  final String region;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  TradingPoint({
    this.id,
    required this.externalId,
    required this.name,
    this.inn,
    String? region,
    this.latitude,
    this.longitude,
    DateTime? createdAt,
    this.updatedAt,
  })  : region = _normalizeRegion(region),
        createdAt = createdAt ?? DateTime.now();


  TradingPoint copyWith({
    int? id,
    String? externalId,
    String? name,
    String? inn,
    String? region,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TradingPoint(
      id: id ?? this.id,
      externalId: externalId ?? this.externalId,
      name: name ?? this.name,
      inn: inn ?? this.inn,
      region: region ?? this.region,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
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

  @override
  int get hashCode => externalId.hashCode;

  /// Создает TradingPoint из JSON данных
  factory TradingPoint.fromJson(Map<String, dynamic> json) {
    return TradingPoint(
      id: json['id'] as int?,
      externalId: json['external_id'] ?? json['externalId'] ?? '',
      name: json['name'] ?? '',
      inn: json['inn'] as String?,
      region: _requireRegion(json),
      latitude: _parseCoordinate(json, 'latitude'),
      longitude: _parseCoordinate(json, 'longitude'),
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
      'region': region,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static String _requireRegion(Map<String, dynamic> json) {
    final value = json['region'] ?? json['region_code'] ?? json['regionCode'];
    if (value == null) {
      throw FormatException('TradingPoint region is missing in payload: $json');
    }

    final region = value.toString().trim();
    if (region.isEmpty) {
      throw FormatException('TradingPoint region is empty in payload: $json');
    }

    return region;
  }

  static String _normalizeRegion(String? value) {
    if (value == null) {
      return defaultRegion;
    }

    final region = value.trim();
    if (region.isEmpty) {
      throw ArgumentError('TradingPoint region cannot be empty');
    }

    return region;
  }

  static double? _parseCoordinate(Map<String, dynamic> json, String key) {
    if (json.containsKey(key)) {
      final value = json[key];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value);
      }
    }

    final address = json['address'];
    if (address is Map<String, dynamic>) {
      final value = address[key];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value);
      }
    }

    return null;
  }
}
