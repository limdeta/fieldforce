import 'dart:async';
import 'dart:convert';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/app/services/session_manager.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logging/logging.dart';

class TradingPointSyncService {
  TradingPointSyncService({
    required SessionManager sessionManager,
    required TradingPointRepository tradingPointRepository,
    required AppUserRepository appUserRepository,
  })  : _sessionManager = sessionManager,
        _tradingPointRepository = tradingPointRepository,
        _appUserRepository = appUserRepository;

  static final Logger _logger = Logger('TradingPointSyncService');

  final SessionManager _sessionManager;
  final TradingPointRepository _tradingPointRepository;
  final AppUserRepository _appUserRepository;

  Future<Either<Failure, TradingPointSyncSummary>> syncTradingPointsForUser(
    User authUser,
  ) async {
    if (authUser.id == null) {
      return const Left(ValidationFailure('User id is required to sync trading points'));
    }

    try {
      final appUserResult = await _appUserRepository.getAppUserByUserId(authUser.id!);

      return await appUserResult.fold(
        (failure) {
          _logger.warning('Не удалось загрузить AppUser для синхронизации торговых точек: ${failure.message}');
          return Future.value(Left(failure));
        },
        (appUser) async {
          final payload = await _fetchTradingPointsPayload();

          if (payload.tradingPoints.isEmpty) {
            _logger.info('API синхронизации торговых точек вернул пустой список.');
            return Right(
              TradingPointSyncSummary(
                savedCount: 0,
                assignedCount: 0,
                regionCodes: const [],
                selectedExternalId: payload.selectedExternalId,
              ),
            );
          }

          final savedResult = await _saveAndAssignTradingPoints(
            payload.tradingPoints,
            appUser.employee,
          );

          final selectedTradingPoint = await _updateAppUserState(
            appUser: appUser,
            savedPoints: savedResult.savedPoints,
            selectedExternalId: payload.selectedExternalId,
          );

          final summary = TradingPointSyncSummary(
            savedCount: savedResult.savedPoints.length,
            assignedCount: savedResult.assignedCount,
            regionCodes: savedResult.savedPoints.values
                .map((tp) => tp.region)
                .whereType<String>()
                .map((region) => region.trim())
                .where((region) => region.isNotEmpty)
                .toSet()
                .toList(),
            selectedExternalId:
                selectedTradingPoint?.externalId ?? payload.selectedExternalId,
          );

          return Right(summary);
        },
      );
    } catch (e, stackTrace) {
      _logger.severe('Ошибка синхронизации торговых точек', e, stackTrace);
      return Left(DatabaseFailure('Ошибка синхронизации торговых точек: $e'));
    }
  }

  Future<_TradingPointSyncPayload> _fetchTradingPointsPayload() async {
    final url = AppConfig.tradingPointsApiUrl;

    if (url.isEmpty) {
      _logger.info('tradingPointsApiUrl не настроен — используем фейковые данные.');
      return await _fixturePayload();
    }

    try {
      final client = await _sessionManager.getSessionClient();
      final headers = await _sessionManager.getSessionHeaders();

      final response = await client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'FieldForce-Mobile/1.0',
          ...headers,
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        _logger.warning('Сервер вернул статус ${response.statusCode} при синхронизации торговых точек');
        return await _fixturePayload();
      }

      final dynamic decoded = jsonDecode(response.body);
      return _parsePayload(decoded);
    } catch (e, stackTrace) {
      _logger.warning('Ошибка запроса торговых точек, используем фикстуру: $e', e, stackTrace);
      return await _fixturePayload();
    }
  }

  Future<_SavedTradingPointsResult> _saveAndAssignTradingPoints(
    List<Map<String, dynamic>> pointsJson,
    Employee employee,
  ) async {
    final Map<String, TradingPoint> savedPoints = {};
    var assignedCount = 0;

    for (final pointJson in pointsJson) {
      late TradingPoint tradingPoint;
      try {
        final normalizedJson = _normalizeTradingPointJson(pointJson);
        tradingPoint = TradingPoint.fromJson(normalizedJson);
      } catch (e, stackTrace) {
        _logger.warning('Пропускаем торговую точку из-за некорректных данных: $e', e, stackTrace);
        continue;
      }

      final saveResult = await _tradingPointRepository.save(tradingPoint);
      await saveResult.fold(
        (failure) async {
          _logger.warning('Не удалось сохранить торговую точку ${tradingPoint.externalId}: ${failure.message}');
        },
        (savedPoint) async {
          savedPoints[savedPoint.externalId] = savedPoint;

          final assignmentResult = await _tradingPointRepository.assignToEmployee(savedPoint, employee);
          assignmentResult.fold(
            (failure) => _logger.warning(
              'Не удалось привязать торговую точку ${savedPoint.externalId} к сотруднику ${employee.id}: ${failure.message}',
            ),
            (_) {
              assignedCount++;
              _logger.fine('Торговая точка ${savedPoint.externalId} привязана к сотруднику ${employee.id}');
            },
          );
        },
      );
    }

    return _SavedTradingPointsResult(
      savedPoints: savedPoints,
      assignedCount: assignedCount,
    );
  }

  Future<TradingPoint?> _updateAppUserState({
    required AppUser appUser,
    required Map<String, TradingPoint> savedPoints,
    required String? selectedExternalId,
  }) async {
    if (savedPoints.isEmpty) {
      _logger.info('Нет сохраненных торговых точек для обновления состояния пользователя.');
      return appUser.selectedTradingPoint;
    }

    final updatedEmployee = appUser.employee.copyWithTradingPoints(savedPoints.values.toList());
    TradingPoint? selectedTradingPoint = appUser.selectedTradingPoint;

    if (!appUser.hasSelectedTradingPoint) {
      if (selectedExternalId != null) {
        selectedTradingPoint = savedPoints[selectedExternalId] ?? selectedTradingPoint;

        // Если по externalId не нашли (например точка уже была в БД), пробуем загрузить из репозитория
        if (selectedTradingPoint == null) {
          final lookupResult = await _tradingPointRepository.getByExternalId(selectedExternalId);
          lookupResult.fold(
            (failure) => _logger.warning('Не удалось получить выбранную торговую точку $selectedExternalId: ${failure.message}'),
            (tp) => selectedTradingPoint = tp,
          );
        }
      } else {
        // Fallback: выбираем предпочтительную точку из сохраненных
        final pointsList = savedPoints.values.toList();
        final p3vPoint = pointsList.where((tp) => tp.region == 'P3V').toList();
        final k3vPoint = pointsList.where((tp) => tp.region == 'K3V').toList();
        
        if (p3vPoint.isNotEmpty) {
          selectedTradingPoint = p3vPoint.first;
        } else if (k3vPoint.isNotEmpty) {
          selectedTradingPoint = k3vPoint.first;
        } else if (pointsList.isNotEmpty) {
          selectedTradingPoint = pointsList.first;
        }
      }
    }

    final updatedAppUser = AppUser(
      employee: updatedEmployee,
      authUser: appUser.authUser,
      settings: appUser.settings,
      selectedTradingPoint: selectedTradingPoint,
    );

    if (selectedTradingPoint?.id != appUser.selectedTradingPoint?.id) {
      final updateResult = await _appUserRepository.updateAppUser(updatedAppUser);
      updateResult.fold(
        (failure) => _logger.warning('Не удалось обновить AppUser с новой торговой точкой: ${failure.message}'),
        (savedUser) {
          _logger.info('Выбранная торговая точка обновлена на ${savedUser.selectedTradingPoint?.externalId}');
        },
      );
    }

    final sessionUpdateResult = await AppSessionService.updateCurrentUser(updatedAppUser);
    sessionUpdateResult.fold(
      (failure) => _logger.warning('Не удалось обновить AppSession после синхронизации торговых точек: ${failure.message}'),
      (_) => _logger.fine('AppSession обновлен с актуальными торговыми точками'),
    );

    return selectedTradingPoint;
  }

  _TradingPointSyncPayload _parsePayload(dynamic data) {
    List<Map<String, dynamic>> points = [];
    String? selectedExternalId;

    if (data is List) {
      points = data
          .map((item) {
            if (item is Map && item['outlet'] is Map) {
              return Map<String, dynamic>.from(item['outlet'] as Map);
            }
            return Map<String, dynamic>.from(item as Map);
          })
          .toList();
      selectedExternalId = _extractSelectedExternalId(points);
    } else if (data is Map) {
      if (data['tradingPoints'] is List) {
        points = (data['tradingPoints'] as List)
            .map((item) {
              if (item is Map && item['outlet'] is Map) {
                return Map<String, dynamic>.from(item['outlet'] as Map);
              }
              return Map<String, dynamic>.from(item as Map);
            })
            .toList();
      } else if (data['points'] is List) {
        points = (data['points'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      selectedExternalId = _extractSelectedExternalId(points) ?? _extractSelectedFromMap(data);
    }

    selectedExternalId ??= points.isNotEmpty ? _selectPreferredPoint(points) : null;

    return _TradingPointSyncPayload(
      tradingPoints: points,
      selectedExternalId: selectedExternalId,
    );
  }

  String? _extractExternalId(Map<String, dynamic> point) {
    return point['external_id']?.toString() ?? point['externalId']?.toString() ?? point['vendorId']?.toString();
  }

  /// Выбирает предпочтительную торговую точку для автоматического выбора
  /// Приоритет: P3V > K3V > первая в списке
  String? _selectPreferredPoint(List<Map<String, dynamic>> points) {
    // Ищем P3V точку
    for (final point in points) {
      if (point['region'] == 'P3V') {
        return _extractExternalId(point);
      }
    }
    
    // Ищем K3V точку
    for (final point in points) {
      if (point['region'] == 'K3V') {
        return _extractExternalId(point);
      }
    }
    
    // Если ни P3V, ни K3V не найдены, берем первую
    return _extractExternalId(points.first);
  }

  String? _extractSelectedExternalId(List<Map<String, dynamic>> points) {
    for (final point in points) {
      if (point['isSelected'] == true) {
        return point['external_id']?.toString() ?? point['externalId']?.toString() ?? point['vendorId']?.toString();
      }
    }
    return null;
  }

  String? _extractSelectedFromMap(Map<dynamic, dynamic> data) {
    final selected = data['selected'] ?? data['selectedTradingPoint'];

    if (selected is Map) {
      return selected['external_id']?.toString() ?? selected['externalId']?.toString();
    }

    if (selected is String) {
      return selected;
    }

    return data['selectedExternalId']?.toString();
  }

  Map<String, dynamic> _normalizeTradingPointJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    final contractor = normalized['contractor'];
    if (contractor is Map) {
      normalized['inn'] = normalized['inn'] ?? contractor['inn']?.toString();
    }

    normalized['external_id'] = normalized['external_id'] ?? normalized['externalId'] ?? normalized['vendorId'];
    normalized['name'] = normalized['name'] ?? normalized['title'];
    normalized['region'] = normalized['region'] ?? normalized['region_code'] ?? normalized['regionCode'];
    final regionValue = normalized['region'];
    if (regionValue == null || regionValue.toString().trim().isEmpty) {
      throw StateError('Trading point ${normalized['external_id']} is missing region');
    }
    normalized['region'] = regionValue.toString().trim();
    normalized['created_at'] = normalized['created_at'] ?? normalized['createdAt'] ?? DateTime.now().toIso8601String();
    normalized['updated_at'] = normalized['updated_at'] ?? normalized['updatedAt'];

    if (normalized['id'] is String) {
      normalized['id'] = int.tryParse(normalized['id'] as String);
    }

    return normalized;
  }

  Future<_TradingPointSyncPayload> _fixturePayload() async {
    try {
      final rawJson = await rootBundle.loadString('assets/fixtures/trading_points_sync_response.json');
      final decoded = jsonDecode(rawJson);
      final payload = _parsePayload(decoded);

      if (payload.tradingPoints.isEmpty) {
        _logger.warning('Фикстура торговых точек пуста, используем запасной набор.');
        return _fallbackPayload();
      }

      return payload;
    } catch (e, stackTrace) {
      _logger.warning('Не удалось загрузить фикстуру торговых точек: $e', e, stackTrace);
      return _fallbackPayload();
    }
  }

  _TradingPointSyncPayload _fallbackPayload() {
    final now = DateTime.now().toIso8601String();
    final points = [
      {
        'id': 501,
        'external_id': 'FAKE-TP-001',
        'name': 'ООО "Demo Foods"',
        'inn': '2536700001',
        'created_at': now,
        'isSelected': true,
        'region': 'P3V',
      },
      {
        'id': 502,
        'external_id': 'FAKE-TP-002',
        'name': 'ИП "Гастроном №1"',
        'inn': '2536700002',
        'created_at': now,
        'region': 'P3V',
      },
      {
        'id': 503,
        'external_id': 'FAKE-TP-003',
        'name': 'Сеть "Продукты 24"',
        'inn': '2536700003',
        'created_at': now,
        'region': 'P3V',
      },
    ];

    return _TradingPointSyncPayload(
      tradingPoints: points.map((item) => Map<String, dynamic>.from(item)).toList(),
      selectedExternalId: 'FAKE-TP-001',
    );
  }
}

class _TradingPointSyncPayload {
  const _TradingPointSyncPayload({
    required this.tradingPoints,
    required this.selectedExternalId,
  });

  final List<Map<String, dynamic>> tradingPoints;
  final String? selectedExternalId;
}

class TradingPointSyncSummary {
  const TradingPointSyncSummary({
    required this.savedCount,
    required this.assignedCount,
    required this.regionCodes,
    required this.selectedExternalId,
  });

  final int savedCount;
  final int assignedCount;
  final List<String> regionCodes;
  final String? selectedExternalId;
}

class _SavedTradingPointsResult {
  const _SavedTradingPointsResult({
    required this.savedPoints,
    required this.assignedCount,
  });

  final Map<String, TradingPoint> savedPoints;
  final int assignedCount;
}
