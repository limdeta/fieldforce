import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';

// Инжектим app_user в сессию. Не забывать порядок вызовов (может дёрнуть юзера из бд предыдущего теста/запуска)
Future<void> ensureLoggedInAsDevUser({String phoneContains = '7-999-111-2233'}) async {
  final userRepo = GetIt.instance<UserRepository>();
  final phoneEither = PhoneNumber.create(phoneContains);
  if (phoneEither.isLeft()) {
    throw StateError('Invalid phone format: $phoneContains');
  }
  final phone = phoneEither.fold((l) => throw StateError(l.toString()), (r) => r);
  final userResult = await userRepo.getUserByPhoneNumber(phone);
  if (userResult.isLeft()) {
    throw StateError('No user found with phone "$phoneContains": ${userResult.fold((l) => l, (r) => '')}');
  }
  final user = userResult.fold((l) => throw StateError(l.toString()), (r) => r);

  final sessionEither = UserSession.create(
    user: user,
    rememberMe: true,
  );

  if (sessionEither.isLeft()) {
    throw StateError('Failed to create UserSession: ${sessionEither.fold((l) => l, (r) => '')}');
  }

  final userSession = sessionEither.fold((l) => throw StateError(l.toString()), (r) => r);

  final appSessionResult = await AppSessionService.createFromSecuritySession(userSession);
  if (appSessionResult.isLeft()) {
    throw StateError('Failed to create AppSession: ${appSessionResult.fold((l) => l, (r) => '')}');
  }
  final appSession = appSessionResult.fold((l) => null, (r) => r);
}
