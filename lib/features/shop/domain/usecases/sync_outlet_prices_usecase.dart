import 'package:fieldforce/features/shop/data/sync/services/protobuf_sync_coordinator.dart';
import 'package:fieldforce/features/shop/domain/entities/sync_report.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

/// Синхронизирует дифференциальные цены для набора торговых точек.
class SyncOutletPricesUseCase {
  SyncOutletPricesUseCase(this._coordinator);

  static final Logger _logger = Logger('SyncOutletPricesUseCase');

  final ProtobufSyncCoordinator _coordinator;

  Future<Either<Failure, SyncReport>> call(List<String> outletVendorIds) async {
    _logger.info('Запуск синхронизации цен для точек: $outletVendorIds');
    return _coordinator.syncOutletPrices(outletVendorIds);
  }
}
