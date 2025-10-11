// lib/features/shop/domain/usecases/sync_warehouses_only_usecase.dart

import 'package:logging/logging.dart';

import 'package:fieldforce/features/shop/data/sync/models/warehouse_protobuf_converter.dart';
import 'package:fieldforce/features/shop/data/sync/services/warehouse_sync_service.dart';
import 'package:fieldforce/features/shop/domain/repositories/warehouse_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

class SyncWarehousesOnlyUseCase {
  static final Logger _logger = Logger('SyncWarehousesOnlyUseCase');

  final WarehouseSyncService _warehouseSyncService;
  final WarehouseRepository _warehouseRepository;

  SyncWarehousesOnlyUseCase({
    required WarehouseSyncService warehouseSyncService,
    required WarehouseRepository warehouseRepository,
  })  : _warehouseSyncService = warehouseSyncService,
        _warehouseRepository = warehouseRepository;

  Future<Either<Failure, WarehouseSyncOnlyResult>> call({
    required String regionCode,
    int? lastSyncTimestamp,
    bool clearBeforeSave = true,
  }) async {
    try {
      _logger.info('🏭 Старт синхронизации только складов (region=$regionCode, lastSync=$lastSyncTimestamp)');

      final response = await _warehouseSyncService.fetchWarehouses(
        regionVendorId: regionCode,
        lastSyncTimestamp: lastSyncTimestamp,
      );

      final warehouses = WarehouseProtobufConverter.fromProtoList(response.warehouses);
      _logger.info('🏭 Получено складов: ${warehouses.length} (ts=${response.syncTimestamp})');

      if (clearBeforeSave) {
        final clearResult = await _warehouseRepository.clearWarehousesByRegion(regionCode);
        if (clearResult.isLeft()) {
          final failure = clearResult.fold((f) => f, (_) => throw StateError('unreachable'));
          _logger.severe('❌ Ошибка очистки складов региона $regionCode: ${failure.message}');
          return Left(failure);
        }
      }

      final saveResult = await _warehouseRepository.saveWarehouses(warehouses);
      if (saveResult.isLeft()) {
        final failure = saveResult.fold((f) => f, (_) => throw StateError('unreachable'));
        _logger.severe('❌ Ошибка сохранения складов региона $regionCode: ${failure.message}');
        return Left(failure);
      }

      return Right(
        WarehouseSyncOnlyResult(
          regionCode: regionCode,
          fetchedCount: warehouses.length,
          savedCount: warehouses.length,
          syncTimestamp: response.syncTimestamp.toInt(),
        ),
      );
    } catch (error, stackTrace) {
      _logger.severe('❌ Критическая ошибка синхронизации складов', error, stackTrace);
      return Left(GeneralFailure('Ошибка синхронизации складов: $error', details: stackTrace));
    }
  }
}

class WarehouseSyncOnlyResult {
  final String regionCode;
  final int fetchedCount;
  final int savedCount;
  final int syncTimestamp;

  const WarehouseSyncOnlyResult({
    required this.regionCode,
    required this.fetchedCount,
    required this.savedCount,
    required this.syncTimestamp,
  });
}