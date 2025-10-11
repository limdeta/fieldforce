import 'package:fieldforce/features/shop/data/sync/services/protobuf_sync_coordinator.dart';
import 'package:fieldforce/features/shop/domain/entities/sync_report.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

/// Синхронизирует склады, остатки и базовые цены для региона.
class SyncRegionStockUseCase {
  SyncRegionStockUseCase(this._coordinator);

  static final Logger _logger = Logger('SyncRegionStockUseCase');

  final ProtobufSyncCoordinator _coordinator;

  Future<Either<Failure, SyncReport>> call(String regionCode) async {
    _logger.info('Запуск синхронизации остатков для региона $regionCode');
    return _coordinator.syncRegionalStock(regionCode);
  }
}
