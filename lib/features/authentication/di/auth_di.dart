import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/database/repositories/app_user_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/employee_repository_drift.dart';
import 'package:fieldforce/app/database/repositories/user_repository_drift.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/app/domain/usecases/app_user_login_usecase.dart';
import 'package:fieldforce/app/domain/usecases/app_user_logout_usecase.dart';
import 'package:fieldforce/app/domain/usecases/create_app_user_usecase.dart';
import 'package:fieldforce/app/domain/usecases/get_current_app_session_usecase.dart';
import 'package:fieldforce/features/authentication/domain/repositories/session_repository.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';
import 'package:fieldforce/features/authentication/domain/services/auth_api_service.dart';
import 'package:fieldforce/features/authentication/domain/services/authentication_service.dart';
import 'package:fieldforce/features/authentication/domain/services/i_auth_api_service.dart';
import 'package:fieldforce/features/authentication/domain/services/mock_auth_api_service.dart';
import 'package:fieldforce/features/authentication/domain/services/user_service.dart';
import 'package:fieldforce/features/authentication/domain/usecases/get_current_session_usecase.dart';
import 'package:fieldforce/features/authentication/domain/usecases/login_usecase.dart';
import 'package:fieldforce/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:fieldforce/features/authentication/presentation/bloc/bloc.dart';
import 'package:get_it/get_it.dart';

void registerAuthenticationDependencies(GetIt getIt) {
  getIt
    ..registerLazySingleton<AppUserRepository>(
      () => AppUserRepositoryDrift(
        database: getIt<AppDatabase>(),
        employeeRepository: getIt<EmployeeRepositoryDrift>(),
        userRepository: getIt<UserRepositoryImpl>(),
      ),
    )
    ..registerLazySingleton<IAuthApiService>(
      () => AppConfig.useMockAuth ? MockAuthApiService() : AuthApiService(),
    )
    ..registerLazySingleton<AuthenticationService>(
      () => AuthenticationService(
        userRepository: getIt<UserRepository>(),
        sessionRepository: getIt<SessionRepository>(),
        authApiService: getIt<IAuthApiService>(),
      ),
    )
    ..registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthenticationService>()),
    )
    ..registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(authenticationService: getIt<AuthenticationService>()),
    )
    ..registerLazySingleton<GetCurrentSessionUseCase>(
      () => GetCurrentSessionUseCase(sessionRepository: getIt<SessionRepository>()),
    )
    ..registerLazySingleton<GetCurrentAppSessionUseCase>(
      () => GetCurrentAppSessionUseCase(),
    )
    ..registerLazySingleton<AppUserLoginUseCase>(
      () => AppUserLoginUseCase(),
    )
    ..registerLazySingleton<AppUserLogoutUseCase>(
      () => AppUserLogoutUseCase(),
    )
    ..registerLazySingleton<UserService>(
      () => UserService(getIt<UserRepository>()),
    )
    ..registerLazySingleton<CreateAppUserUseCase>(
      () => CreateAppUserUseCase(getIt<AppUserRepository>()),
    )
    ..registerFactory<AuthenticationBloc>(
      () => AuthenticationBloc(
        loginUseCase: getIt<LoginUseCase>(),
        logoutUseCase: getIt<LogoutUseCase>(),
        getCurrentSessionUseCase: getIt<GetCurrentSessionUseCase>(),
      ),
    );
}
