import '../../../shared/either.dart';
import '../../../shared/failures.dart';
import '../app_session.dart';
import '../../services/app_session_service.dart';

/// UseCase для получения текущей сессии приложения
/// 
/// Заменяет GetCurrentSessionUseCase из authentication модуля
/// для использования на app-уровне
class GetCurrentAppSessionUseCase {

  Future<Either<Failure, AppSession?>> call() async {
    return await AppSessionService.getCurrentAppSession();
  }

  bool hasActiveSession() {
    return AppSessionService.hasActiveSession;
  }

  AppSession? get currentSession => AppSessionService.currentSession;
}
