import 'package:fieldforce/shared/failures.dart';

import '../../../../shared/either.dart';
import '../entities/session_state.dart';
import '../repositories/session_repository.dart';

class GetCurrentSessionUseCase {
  final SessionRepository sessionRepository;
  const GetCurrentSessionUseCase({
    required this.sessionRepository,
  });

  /// Возвращает состояние сессии без null!
  /// 
  /// `Either<Failure, SessionState>` где:
  /// - Left(Failure) = техническая ошибка (нет сети, ошибка БД)
  /// - Right(SessionNotFound) = нет сессии (нормальное состояние)
  /// - Right(SessionFound) = есть активная сессия
  Future<Either<Failure, SessionState>> call() async {
    try {
      final result = await sessionRepository.getCurrentSession();
      
      return result.fold(
        // Техническая ошибка - пробрасываем
        (failure) => Left(failure),
        // Успешный ответ - анализируем результат
        (userSession) {
          if (userSession == null) {
            // Нет сессии - это нормально!
            return const Right(SessionNotFound());
          } else {
            // Сессия найдена
            return Right(SessionFound(userSession));
          }
        },
      );
    } catch (e) {
      // Неожиданная ошибка
      return Left(AuthFailure('Session check failed: $e'));
    }
  }
}
