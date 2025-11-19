import 'package:fieldforce/features/shop/domain/entities/warehouse.dart';

class FixtureWarehouseData {
  final int id;
  final String name;
  final String vendorId;
  final String regionCode;
  final bool isPickUpPoint;

  const FixtureWarehouseData({
    required this.id,
    required this.name,
    required this.vendorId,
    required this.regionCode,
    required this.isPickUpPoint,
  });

  Warehouse toEntity(DateTime timestamp) {
    return Warehouse(
      id: id,
      name: name,
      vendorId: vendorId,
      regionCode: regionCode,
      isPickUpPoint: isPickUpPoint,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }
}

const List<FixtureWarehouseData> fixtureWarehouses = <FixtureWarehouseData>[
  FixtureWarehouseData(
    id: 1,
    name: 'Основной склад',
    vendorId: 'P3V_MAIN',
    regionCode: 'P3V',
    isPickUpPoint: false,
  ),
  FixtureWarehouseData(
    id: 2,
    name: 'ПВЗ Центральный',
    vendorId: 'P3V_PICKUP',
    regionCode: 'P3V',
    isPickUpPoint: true,
  ),
  FixtureWarehouseData(
    id: 3,
    name: 'Склад Юг',
    vendorId: 'P3V_SOUTH',
    regionCode: 'P3V',
    isPickUpPoint: false,
  ),
  FixtureWarehouseData(
    id: 101,
    name: 'Камчатка Центральный',
    vendorId: 'K3V_MAIN',
    regionCode: 'K3V',
    isPickUpPoint: false,
  ),
  FixtureWarehouseData(
    id: 102,
    name: 'Камчатка ПВЗ',
    vendorId: 'K3V_PICKUP',
    regionCode: 'K3V',
    isPickUpPoint: true,
  ),
  FixtureWarehouseData(
    id: 201,
    name: 'Магадан Центральный',
    vendorId: 'M3V_MAIN',
    regionCode: 'M3V',
    isPickUpPoint: false,
  ),
  FixtureWarehouseData(
    id: 202,
    name: 'Магадан ПВЗ',
    vendorId: 'M3V_PICKUP',
    regionCode: 'M3V',
    isPickUpPoint: true,
  ),
];

FixtureWarehouseData fixtureWarehouseById(int id) {
  for (final warehouse in fixtureWarehouses) {
    if (warehouse.id == id) {
      return warehouse;
    }
  }
  return fixtureWarehouses.first;
}

FixtureWarehouseData fixtureWarehouseByRegion(
  String regionCode, {
  bool preferPickUp = false,
}) {
  final candidates = fixtureWarehouses
      .where((warehouse) => warehouse.regionCode == regionCode)
      .toList();

  if (candidates.isEmpty) {
    return fixtureWarehouses.first;
  }

  if (preferPickUp) {
    return candidates.firstWhere(
      (warehouse) => warehouse.isPickUpPoint,
      orElse: () => candidates.first,
    );
  }

  return candidates.firstWhere(
    (warehouse) => !warehouse.isPickUpPoint,
    orElse: () => candidates.first,
  );
}

List<Warehouse> buildFixtureWarehouses({DateTime? timestamp}) {
  final now = timestamp ?? DateTime.now();
  return fixtureWarehouses
      .map((fixture) => fixture.toEntity(now))
      .toList(growable: false);
}
