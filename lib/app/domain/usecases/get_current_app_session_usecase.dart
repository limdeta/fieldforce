import 'package:fieldforce/app/domain/entities/app_session.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/authentication/domain/entities/session_state.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

class GetCurrentAppSessionUseCase {

  Future<Either<Failure, SessionState>> getSessionState() async {
    return await AppSessionService.getCurrentSessionState();
  }

  Future<Either<Failure, AppSession?>> call() async {
    return await AppSessionService.getCurrentAppSession();
  }

  bool hasActiveSession() {
    return AppSessionService.hasActiveSession;
  }

  AppSession? get currentSession => AppSessionService.currentSession;
  bool get isUserAuthenticated => AppSessionService.hasActiveSession;

  AppSession? get authenticatedSession => AppSessionService.hasActiveSession
      ? AppSessionService.currentSession
      : null;
}
