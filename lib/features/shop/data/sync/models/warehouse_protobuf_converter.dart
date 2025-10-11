import 'package:fieldforce/features/shop/domain/entities/warehouse.dart';
import '../generated/sync.pb.dart' as proto;

class WarehouseProtobufConverter {
  static Warehouse fromProto(proto.WarehouseInfo info) {
    final now = DateTime.now();
    return Warehouse(
      id: info.id,
      name: info.name,
      vendorId: info.vendorId,
      regionCode: info.region,
      isPickUpPoint: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  static List<Warehouse> fromProtoList(Iterable<proto.WarehouseInfo> warehouses) {
    return warehouses.map(fromProto).toList();
  }
}
