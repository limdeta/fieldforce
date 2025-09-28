import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';
import 'package:fieldforce/features/authentication/domain/services/authentication_service.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/shared/either.dart';

class LoginUseCase {
  final AuthenticationService authenticationService;
  
  const LoginUseCase(this.authenticationService);
  
  Future<Either<AuthFailure, UserSession>> call({
    required String phoneString,
    required String password,
    bool rememberMe = true,
  }) async {

    final phoneResult = PhoneNumber.create(phoneString);
    if (phoneResult.isLeft()) {
      return Left(AuthFailure('Неверный формат номера телефона'));
    }
    
    final phoneNumber = phoneResult.getOrElse(() => throw Exception());
    
    final validationResult = authenticationService.validateAuthenticationRequest(
      phoneNumber, 
      password,
    );
    if (validationResult.isLeft()) {
      return validationResult.fold(
        (failure) => Left(failure),
        (_) => const Left(AuthFailure('Неожиданная ошибка валидации')),
      );
    }
    
    return await authenticationService.authenticateUser(
      phoneNumber,
      password.trim(),
      rememberMe: rememberMe,
    );
  }
}
