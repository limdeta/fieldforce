import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/shop/domain/entities/warehouse.dart';
import 'package:fieldforce/features/shop/domain/repositories/warehouse_repository.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

/// Результат разрешения фильтра складов для текущей сессии.
class WarehouseFilterResult {
  /// Регион, определённый для активной сессии.
  final String regionCode;

  /// Список складов, доступных в текущем регионе.
  final List<Warehouse> warehouses;

  /// Флаг указывает, что в dev-режиме фильтрация была пропущена.
  final bool devBypass;

  /// Ошибка, возникшая при получении складов (если есть).
  final Failure? failure;

  const WarehouseFilterResult({
    required this.regionCode,
    required this.warehouses,
    this.devBypass = false,
    this.failure,
  });

  /// Возвращает true, если для региона найден хотя бы один склад.
  bool get hasWarehouses => warehouses.isNotEmpty;

  /// Возвращает список идентификаторов складов.
  List<int> get warehouseIds => warehouses.map((warehouse) => warehouse.id).toList();

  /// Возвращает список vendorId складов.
  List<String> get warehouseVendorIds => warehouses.map((warehouse) => warehouse.vendorId).toList();
}

/// Сервис разрешения фильтра складов на основе текущей сессии пользователя.
class WarehouseFilterService {
  static final Logger _logger = Logger('WarehouseFilterService');

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
  ///
  /// Если приложение запущено в dev-режиме, фильтрация пропускается (возвращается `devBypass = true`).
  /// В случае ошибки при загрузке складов возвращается пустой список с заполненным `failure`.
  Future<WarehouseFilterResult> resolveForCurrentSession({bool bypassInDev = true}) async {
    final regionCode = await _determineRegionCode();
    final useCache = !bypassInDev;

    if (useCache && _cachedResult != null && _cachedRegionCode == regionCode) {
      _logger.fine('WarehouseFilterService: используем кеш складов для региона $regionCode');
      return _cachedResult!;
    }

    if (bypassInDev && AppConfig.isDev) {
      _logger.fine('Dev режим — пропускаем фильтрацию складов для региона $regionCode');
      return WarehouseFilterResult(
        regionCode: regionCode,
        warehouses: const [],
        devBypass: true,
      );
    }

    final warehousesResult = await _warehouseRepository.getWarehousesByRegion(regionCode);

    final result = warehousesResult.fold(
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

    if (useCache && result.failure == null) {
      _cachedResult = result;
      _cachedRegionCode = regionCode;
    }

    return result;
  }

  Future<String> _determineRegionCode() async {
    var regionCode = AppConfig.defaultRegionCode;

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
          } else {
            _logger.fine('Торговая точка не выбрана. Используем регион по умолчанию $regionCode');
          }
        },
      );
    } catch (error, stackTrace) {
      _logger.severe('Ошибка определения региона для фильтра складов', error, stackTrace);
    }

    return regionCode;
  }
}
