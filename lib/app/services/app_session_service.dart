import 'package:get_it/get_it.dart';
import '../../shared/either.dart';
import '../../shared/failures.dart';
import '../domain/app_session.dart';
import '../domain/app_user.dart';
import '../domain/repositories/app_user_repository.dart';
import '../../features/authentication/domain/entities/user_session.dart';
import '../../features/authentication/domain/entities/user.dart';
import '../../features/authentication/domain/entities/session_state.dart';
import '../../features/authentication/domain/repositories/user_repository.dart';
import '../../features/authentication/domain/usecases/get_current_session_usecase.dart';

/// Сервис для управления сессией приложения
/// 
/// Ответственности:
/// - Создание AppSession из UserSession
/// - Инициализация AppUser с данными Employee
/// - Управление глобальной сессией приложения
/// - Синхронизация состояния между модулями
class AppSessionService {
  static AppSession? _currentSession;
  
  static final GetCurrentSessionUseCase _getSecuritySession = 
      GetIt.instance<GetCurrentSessionUseCase>();

  static AppSession? get currentSession => _currentSession;
  static bool get hasActiveSession => _currentSession?.isValid ?? false;

  static Future<Either<Failure, AppSession>> createFromSecuritySession(
    UserSession securitySession
  ) async {
    try {
      // Загружаем реальный AppUser из базы данных по User
      final appUserResult = await _loadAppUserBySecurityUser(securitySession.user);
      
      return appUserResult.fold(
        (failure) {
          print('❌ Ошибка загрузки AppUser: ${failure.message}');
          return Left(failure);
        },
        (appUser) {
          print('✅ AppUser загружен: Employee ID ${appUser.employee.id}');
          
          final appSession = AppSession(
            appUser: appUser,
            securitySession: securitySession,
            createdAt: DateTime.now(),
            appSettings: _getDefaultAppSettings(),
          );
          
          _currentSession = appSession;
          return Right(appSession);
        },
      );
    } catch (e) {
      print('❌ Критическая ошибка создания AppSession: $e');
      return Left(DatabaseFailure('Ошибка создания AppSession: $e'));
    }
  }

  /// Создает AppSession напрямую из User (упрощенный вариант)
  static Future<Either<Failure, AppSession>> createFromSecurityUser(
    User securityUser
  ) async {
    try {
      final sessionResult = await _getSecuritySession.call();
      
      return sessionResult.fold(
        (failure) => Left(failure),
        (sessionState) {
          // Используем новый SessionState БЕЗ null-проверок!
          return sessionState.when(
            onNotFound: () => const Left(NotFoundFailure('Security session not found')),
            onFound: (userSession) {
              // Создаем AppSession через основной метод
              return createFromSecuritySession(userSession);
            },
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Ошибка создания AppSession из User: $e'));
    }
  }

  /// Получает текущую AppSession (или создает если нет)
  static Future<Either<Failure, AppSession?>> getCurrentAppSession() async {
    try {
      // Если есть кешированная сессия и она валидна
      if (_currentSession?.isValid == true) {
        return Right(_currentSession);
      }
      
      // Получаем security session
      final sessionResult = await _getSecuritySession.call();
      
      return sessionResult.fold(
        (failure) => Left(failure),
        (sessionState) async {
          // Используем новый SessionState БЕЗ null-проверок!
          return sessionState.when(
            onNotFound: () async {
              _currentSession = null;
              return const Right(null);
            },
            onFound: (userSession) async {
              // Создаем новую AppSession
              final appSessionResult = await createFromSecuritySession(userSession);
              
              return appSessionResult.fold(
                (failure) => Left(failure),
                (appSession) => Right(appSession),
              );
            },
          );
        },
      );
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения AppSession: $e'));
    }
  }

  static AppSession? updateAppUser(AppUser newAppUser) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.updateAppUser(newAppUser);
    }
    return _currentSession;
  }

  static AppSession? updateAppSettings(Map<String, dynamic> newSettings) {
    if (_currentSession != null) {
      _currentSession = _currentSession!.updateSettings(newSettings);
    }
    return _currentSession;
  }

  static void setCurrentSession(AppSession? session) {
    _currentSession = session;
  }

  /// Очищает текущую сессию (при logout)
  static void clearSession() {
    _currentSession = null;
  }

  static bool isSessionValid() {
    return _currentSession?.isValid ?? false;
  }

  static Map<String, dynamic> _getDefaultAppSettings() {
    return {
      'theme': 'light',
      'language': 'ru',
      'notifications_enabled': true,
      'location_tracking': true,
      'auto_sync': true,
      'map_style': 'standard',
      'route_optimization': true,
    };
  }

  static Future<Either<Failure, AppUser>> _loadAppUserBySecurityUser(User securityUser) async {
    try {
      print('🔍 Поиск AppUser для User: ${securityUser.externalId}');
      
      final userRepository = GetIt.instance<UserRepository>();
      // TODO проверить по какому id получать в итоге
      final userResult = await userRepository.getUserByExternalId(securityUser.externalId);
      
      return await userResult.fold(
        (failure) async {
          print('❌ User не найден в базе: ${securityUser.externalId}: ${failure.message}');
          return Left(NotFoundFailure('User не найден в базе: ${securityUser.externalId}'));
        },
        (databaseUser) async {
          print('✅ User найден в базе: ${databaseUser.externalId} (ID: ${databaseUser.id})');
          
          if (databaseUser.id == null) {
            print('❌ Database User ID равен null');
            return Left(NotFoundFailure('Database User ID не может быть null'));
          }
          
          // Теперь получаем AppUser по User ID через app_users таблицу
          final appUserRepository = GetIt.instance<AppUserRepository>();
          final appUserResult = await appUserRepository.getAppUserByUserId(databaseUser.id!);
          
          return appUserResult.fold(
            (failure) {
              print('❌ AppUser не найден для User ${databaseUser.externalId}: ${failure.message}');
              return Left(NotFoundFailure('AppUser не найден для пользователя ${databaseUser.externalId}'));
            },
            (appUser) {
              print('✅ AppUser найден: Employee ID ${appUser.employee.id}, User ID ${appUser.authUser.id}');
              return Right(appUser);
            },
          );
        },
      );
    } catch (e) {
      print('❌ Ошибка поиска AppUser: $e');
      return Left(DatabaseFailure('Ошибка загрузки AppUser: $e'));
    }
  }
}
