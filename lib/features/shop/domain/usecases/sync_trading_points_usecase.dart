import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/app/services/trading_point_sync_service.dart';
import 'package:fieldforce/features/shop/domain/entities/sync_report.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:logging/logging.dart';

/// Запускает синхронизацию торговых точек через [TradingPointSyncService]
/// и приводит результат к унифицированному [SyncReport].
class SyncTradingPointsUseCase {
  SyncTradingPointsUseCase(this._tradingPointSyncService);

  static final Logger _logger = Logger('SyncTradingPointsUseCase');

  final TradingPointSyncService _tradingPointSyncService;

  Future<Either<Failure, SyncReport>> call() async {
    final sessionResult = await AppSessionService.getCurrentAppSession();

    return await sessionResult.fold(
      (failure) {
        _logger.warning('Не удалось получить текущую сессию перед синхронизацией торговых точек: ${failure.message}');
        return Future.value(Left(failure));
      },
      (session) async {
        final appUser = session?.appUser;
        final authUser = appUser?.authUser;

        if (authUser == null) {
          _logger.warning('В сессии отсутствует авторизованный пользователь для синхронизации торговых точек');
          return const Left(ValidationFailure('Нет активного пользователя для синхронизации торговых точек'));
        }

        final start = DateTime.now();
        final result = await _tradingPointSyncService.syncTradingPointsForUser(authUser);

        return result.fold(
          (failure) {
            _logger.warning('Синхронизация торговых точек завершилась ошибкой: ${failure.message}');
            return Left(failure);
          },
          (summary) {
            final duration = DateTime.now().difference(start);
            final description = summary.savedCount == 0
                ? 'Новых торговых точек не найдено'
                : 'Обновлено ${summary.savedCount} торговых точек';

            return Right(
              SyncReport(
                processedCount: summary.savedCount,
                duration: duration,
                description: description,
                details: <String, dynamic>{
                  'assignedCount': summary.assignedCount,
                  'selectedExternalId': summary.selectedExternalId,
                  'regions': summary.regionCodes,
                },
              ),
            );
          },
        );
      },
    );
  }
}
