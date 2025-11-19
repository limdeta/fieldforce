import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/shop/data/fixtures/fixture_warehouses.dart';
import 'package:fieldforce/features/shop/domain/entities/warehouse.dart';
import 'package:fieldforce/features/shop/domain/repositories/warehouse_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

/// Результат разрешения фильтра складов для текущей сессии.
class WarehouseFilterResult {
  /// Регион, определённый для активной сессии.
  final String regionCode;

  /// Список складов, доступных в текущем регионе.
  final List<Warehouse> warehouses;

  /// Ошибка, возникшая при получении складов (если есть).
  final Failure? failure;

  const WarehouseFilterResult({
    required this.regionCode,
    required this.warehouses,
    this.failure,
  });

  /// Возвращает true, если для региона найден хотя бы один склад.
  bool get hasWarehouses => warehouses.isNotEmpty;

  /// Возвращает список идентификаторов складов.
  List<int> get warehouseIds => warehouses.map((warehouse) => warehouse.id).toList();

  /// Возвращает список vendorId складов.
  List<String> get warehouseVendorIds => warehouses.map((warehouse) => warehouse.vendorId).toList();

  /// Возвращает список названий складов (для логов и отладки).
  List<String> get warehouseNames => warehouses.map((warehouse) => warehouse.name).toList();
}

/// Сервис разрешения фильтра складов на основе текущей сессии пользователя.
class WarehouseFilterService {
  static final Logger _logger = Logger('WarehouseFilterService');
  static final Set<String> _fixtureVendorIds =
      fixtureWarehouses.map((fixture) => fixture.vendorId).toSet();

  final WarehouseRepository _warehouseRepository;
  WarehouseFilterResult? _cachedResult;
  String? _cachedRegionCode;

  WarehouseFilterService({required WarehouseRepository warehouseRepository})
      : _warehouseRepository = warehouseRepository;

  void invalidateCache() {
    _cachedResult = null;
    _cachedRegionCode = null;
  }

  /// Определяет список складов, которые принадлежат региону активной торговой точки.
  Future<WarehouseFilterResult> resolveForCurrentSession() async {
    final regionCode = await _determineRegionCode();
    final cached = _cachedResult;

    if (cached != null && _cachedRegionCode == regionCode) {
      _logger.info(
        'WarehouseFilterService: cache hit для региона $regionCode (warehouses=${cached.warehouses.length}, ids=${cached.warehouseIds}, names=${cached.warehouseNames})',
      );
      return cached;
    }

    _logger.info('WarehouseFilterService: разрешаем склады для региона $regionCode');

    final warehousesResult = await _warehouseRepository.getWarehousesByRegion(regionCode);
    var result = _buildResult(regionCode, warehousesResult);
    result = await _purgeFixtureWarehousesIfNeeded(regionCode, result);

    _logResult(regionCode, result);
    return result;
  }

  Future<String> _determineRegionCode() async {
    var regionCode = AppConfig.defaultRegionCode;
    var source = 'default';

    try {
      final sessionResult = await AppSessionService.getCurrentAppSession();

      sessionResult.fold(
        (failure) {
          _logger.fine('Не удалось получить текущую сессию: ${failure.message}');
        },
        (session) {
          final tradingPoint = session?.appUser.selectedTradingPoint;
          if (tradingPoint != null) {
            regionCode = tradingPoint.region;
            source = 'tradingPoint:${tradingPoint.id}';
          } else {
            _logger.fine('Торговая точка не выбрана. Используем регион по умолчанию $regionCode');
          }
        },
      );
    } catch (error, stackTrace) {
      _logger.severe('Ошибка определения региона для фильтра складов', error, stackTrace);
    }

    _logger.info('WarehouseFilterService: регион определён как $regionCode (source=$source)');

    return regionCode;
  }

  void _logResult(String regionCode, WarehouseFilterResult result) {
    if (result.failure != null) {
      _logger.warning(
        'WarehouseFilterService: ошибка для региона $regionCode: ${result.failure!.message}',
      );
      return;
    }

    if (result.hasWarehouses) {
      _logger.info(
        'WarehouseFilterService: найдено ${result.warehouses.length} складов для региона $regionCode (ids=${result.warehouseIds}, names=${result.warehouseNames})',
      );
      _cachedResult = result;
      _cachedRegionCode = regionCode;
    } else {
      _logger.warning('WarehouseFilterService: для региона $regionCode склады не найдены');
      _cachedResult = null;
      _cachedRegionCode = null;
    }
  }

  WarehouseFilterResult _buildResult(
    String regionCode,
    Either<Failure, List<Warehouse>> warehousesResult,
  ) {
    return warehousesResult.fold(
      (failure) {
        _logger.warning('Не удалось загрузить склады для региона $regionCode: ${failure.message}');
        return WarehouseFilterResult(
          regionCode: regionCode,
          warehouses: const [],
          failure: failure,
        );
      },
      (warehouses) {
        _logger.fine('Разрешено ${warehouses.length} складов для региона $regionCode');
        return WarehouseFilterResult(
          regionCode: regionCode,
          warehouses: warehouses,
        );
      },
    );
  }

  Future<WarehouseFilterResult> _purgeFixtureWarehousesIfNeeded(
    String regionCode,
    WarehouseFilterResult result,
  ) async {
    if (!AppConfig.isDev || result.failure != null || !result.hasWarehouses) {
      return result;
    }

    final hasRealWarehouses = result.warehouses.any(
      (warehouse) => !_fixtureVendorIds.contains(warehouse.vendorId),
    );

    if (hasRealWarehouses) {
      return result;
    }

    _logger.warning(
      'WarehouseFilterService: обнаружены только фикстурные склады для региона $regionCode. Удаляем их и ждём реальную синхронизацию.',
    );

    final clearResult = await _warehouseRepository.clearWarehousesByRegion(regionCode);
    if (clearResult.isLeft()) {
      clearResult.fold(
        (failure) => _logger.severe(
          'WarehouseFilterService: не удалось удалить фикстурные склады региона $regionCode: ${failure.message}',
        ),
        (_) {},
      );
      return result;
    }

    final refreshed = await _warehouseRepository.getWarehousesByRegion(regionCode);
    final refreshedResult = _buildResult(regionCode, refreshed);
    if (!refreshedResult.hasWarehouses) {
      _logger.info(
        'WarehouseFilterService: фикстурные склады для региона $regionCode удалены. Запустите импорт, чтобы получить реальные данные.',
      );
    }

    return refreshedResult;
  }

}
