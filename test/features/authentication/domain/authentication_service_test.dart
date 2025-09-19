import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';
import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';
import 'package:fieldforce/features/authentication/domain/repositories/session_repository.dart';
import 'package:fieldforce/features/authentication/domain/services/authentication_service.dart';
import 'package:fieldforce/features/authentication/domain/services/password_service.dart';
import 'package:fieldforce/features/authentication/domain/services/i_auth_api_service.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import '../../../helpers/test_factories.dart';

// Generate mocks
@GenerateMocks([
  UserRepository,
  SessionRepository,
  IAuthApiService,
])
import 'authentication_service_test.mocks.dart';

void main() {
  group('AuthenticationService - Smart Login Tests', () {
    late MockUserRepository mockUserRepository;
    late MockSessionRepository mockSessionRepository;
    late MockIAuthApiService mockAuthApiService;
    late AuthenticationService authenticationService;

    setUp(() {
      mockUserRepository = MockUserRepository();
      mockSessionRepository = MockSessionRepository();
      mockAuthApiService = MockIAuthApiService();

      authenticationService = AuthenticationService(
        userRepository: mockUserRepository,
        sessionRepository: mockSessionRepository,
        authApiService: mockAuthApiService,
      );
    });

    test('should authenticate successfully when API and local auth both succeed', () async {
      // Arrange
      final phoneNumber = PhoneNumber.create('+79991112233').getOrElse(() => throw Exception());
      const password = 'password123';

      final user = await TestFactories.createAdminUser(
        phoneNumber: phoneNumber.value,
        externalId: 'test_user',
      );

      when(mockAuthApiService.authenticate(phoneNumber, password))
          .thenAnswer((_) async => Right(AuthApiResult.success()));

      when(mockUserRepository.getUserByPhoneNumber(phoneNumber))
          .thenAnswer((_) async => Right(user));

      when(mockSessionRepository.saveSession(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await authenticationService.authenticateUser(
        phoneNumber,
        password,
        rememberMe: false,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should succeed'),
        (actualSession) {
          expect(actualSession.user.externalId, user.externalId);
        },
      );

      verify(mockAuthApiService.authenticate(phoneNumber, password)).called(1);
      verify(mockUserRepository.getUserByPhoneNumber(phoneNumber)).called(1);
      verify(mockSessionRepository.saveSession(any)).called(1);
    });

    test('should use existing session when API fails but session is fresh (< 24h)', () async {
      // Arrange
      final phoneNumber = PhoneNumber.create('+79991112233').getOrElse(() => throw Exception());
      const password = 'password123';

      final user = await TestFactories.createAdminUser(
        phoneNumber: phoneNumber.value,
        externalId: 'test_user',
      );

      // Создаем сессию, которая была создана 12 часов назад (свежая)
      final freshLoginTime = DateTime.now().subtract(const Duration(hours: 12));
      final existingSessionResult = UserSession.create(
        user: user,
        rememberMe: false,
      );

      final existingSession = existingSessionResult.fold(
        (failure) => throw Exception('Failed to create session'),
        (session) => session.copyWith(loginTime: freshLoginTime),
      );

      when(mockAuthApiService.authenticate(phoneNumber, password))
          .thenAnswer((_) async => Left(NetworkFailure('API unavailable')));

      when(mockSessionRepository.getCurrentSession())
          .thenAnswer((_) async => Right(existingSession));

      // Act
      final result = await authenticationService.authenticateUser(
        phoneNumber,
        password,
        rememberMe: false,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should succeed with existing session'),
        (actualSession) {
          expect(actualSession.user.externalId, user.externalId);
          expect(actualSession.loginTime, freshLoginTime); // Должна вернуться существующая сессия
        },
      );

      verify(mockAuthApiService.authenticate(phoneNumber, password)).called(1);
      verify(mockSessionRepository.getCurrentSession()).called(1);
      verifyNever(mockUserRepository.getUserByPhoneNumber(any)); // Не должно быть обращений к репозиторию пользователей
    });

    test('should create new user when API succeeds but local user not found', () async {
      // Arrange
      final phoneNumber = PhoneNumber.create('+79991119999').getOrElse(() => throw Exception());
      const password = 'password123';

      when(mockAuthApiService.authenticate(phoneNumber, password))
          .thenAnswer((_) async => Right(AuthApiResult.success()));

      when(mockUserRepository.getUserByPhoneNumber(phoneNumber))
          .thenAnswer((_) async => Left(DatabaseFailure('User not found')));

      when(mockUserRepository.createUser(any))
          .thenAnswer((_) async {
            final user = User(
              externalId: 'auth_${phoneNumber.value}',
              role: UserRole.user,
              phoneNumber: phoneNumber,
              hashedPassword: PasswordService.hashPassword(password),
            );
            return Right(user);
          });

      when(mockUserRepository.saveUser(any))
          .thenAnswer((_) async {
            final user = User(
              externalId: 'auth_${phoneNumber.value}',
              role: UserRole.user,
              phoneNumber: phoneNumber,
              hashedPassword: PasswordService.hashPassword(password),
            );
            return Right(user);
          });

      when(mockSessionRepository.saveSession(any))
          .thenAnswer((_) async => Right(null));

      // Act
      final result = await authenticationService.authenticateUser(
        phoneNumber,
        password,
        rememberMe: false,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should succeed'),
        (actualSession) {
          expect(actualSession.user.phoneNumber.value, phoneNumber.value);
          expect(actualSession.user.externalId, 'auth_${phoneNumber.value}');
          expect(actualSession.user.role, UserRole.user);
        },
      );

      verify(mockAuthApiService.authenticate(phoneNumber, password)).called(1);
      verify(mockUserRepository.getUserByPhoneNumber(phoneNumber)).called(1);
      verify(mockUserRepository.createUser(any)).called(1);
      verify(mockSessionRepository.saveSession(any)).called(1);
    });

    test('should update password when API succeeds but local password differs', () async {
      // Arrange
      final phoneNumber = PhoneNumber.create('+79991112233').getOrElse(() => throw Exception());
      const newPassword = 'newpassword123';

      final existingUser = await TestFactories.createAdminUser(
        phoneNumber: phoneNumber.value,
        externalId: 'test_user',
      );

      when(mockAuthApiService.authenticate(phoneNumber, newPassword))
          .thenAnswer((_) async => Right(AuthApiResult.success()));

      when(mockUserRepository.getUserByPhoneNumber(phoneNumber))
          .thenAnswer((_) async => Right(existingUser));

      when(mockUserRepository.saveUser(any))
          .thenAnswer((_) async {
            final user = User(
              externalId: existingUser.externalId,
              role: existingUser.role,
              phoneNumber: existingUser.phoneNumber,
              hashedPassword: PasswordService.hashPassword(newPassword),
            );
            return Right(user);
          });

      when(mockSessionRepository.saveSession(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await authenticationService.authenticateUser(
        phoneNumber,
        newPassword,
        rememberMe: false,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should succeed'),
        (actualSession) {
          expect(actualSession.user.externalId, existingUser.externalId);
          expect(actualSession.user.role, existingUser.role);
        },
      );

      verify(mockAuthApiService.authenticate(phoneNumber, newPassword)).called(1);
      verify(mockUserRepository.getUserByPhoneNumber(phoneNumber)).called(1);
      verify(mockUserRepository.saveUser(any)).called(1); // Password should be updated
      verify(mockSessionRepository.saveSession(any)).called(1);
    });

    test('should fail when API rejects authentication', () async {
      // Arrange
      final phoneNumber = PhoneNumber.create('+79991112233').getOrElse(() => throw Exception());
      const password = 'wrongpassword';

      when(mockAuthApiService.authenticate(phoneNumber, password))
          .thenAnswer((_) async => Right(AuthApiResult.failure('Invalid credentials')));

      // Act
      final result = await authenticationService.authenticateUser(
        phoneNumber,
        password,
        rememberMe: false,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Invalid credentials'),
        (session) => fail('Should fail'),
      );

      verify(mockAuthApiService.authenticate(phoneNumber, password)).called(1);
      verifyNever(mockUserRepository.getUserByPhoneNumber(phoneNumber));
      verifyNever(mockSessionRepository.saveSession(any));
    });

    test('should update password when API succeeds but local password differs', () async {
      // Arrange
      final phoneNumber = PhoneNumber.create('+79991112233').getOrElse(() => throw Exception());
      const newPassword = 'newpassword123';

      final existingUser = await TestFactories.createAdminUser(
        phoneNumber: phoneNumber.value,
        externalId: 'test_user',
      );

      when(mockAuthApiService.authenticate(phoneNumber, newPassword))
          .thenAnswer((_) async => Right(AuthApiResult.success()));

      when(mockUserRepository.getUserByPhoneNumber(phoneNumber))
          .thenAnswer((_) async => Right(existingUser));

      when(mockUserRepository.saveUser(any))
          .thenAnswer((_) async {
            final user = User(
              id: existingUser.id,
              externalId: existingUser.externalId,
              role: existingUser.role,
              phoneNumber: existingUser.phoneNumber,
              hashedPassword: PasswordService.hashPassword(newPassword),
            );
            return Right(user);
          });

      when(mockSessionRepository.saveSession(any))
          .thenAnswer((_) async => Right(null));

      // Act
      final result = await authenticationService.authenticateUser(
        phoneNumber,
        newPassword,
        rememberMe: false,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should succeed'),
        (actualSession) {
          expect(actualSession.user.externalId, existingUser.externalId);
          expect(actualSession.user.role, existingUser.role);
        },
      );

      verify(mockAuthApiService.authenticate(phoneNumber, newPassword)).called(1);
      verify(mockUserRepository.getUserByPhoneNumber(phoneNumber)).called(1);
      verify(mockUserRepository.saveUser(any)).called(1); // Password should be updated
      verify(mockSessionRepository.saveSession(any)).called(1);
    });

    test('should reject authentication when API returns isActive = false', () async {
      // Arrange
      final phoneNumber = PhoneNumber.create('+79991112233').getOrElse(() => throw Exception());
      const password = 'password123';

      when(mockAuthApiService.authenticate(phoneNumber, password))
          .thenAnswer((_) async => Right(AuthApiResult.success(isActive: false)));

      // Act
      final result = await authenticationService.authenticateUser(
        phoneNumber,
        password,
        rememberMe: false,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, 'Аккаунт отключен. Обратитесь к администратору.');
        },
        (session) => fail('Should fail when account is inactive'),
      );

      verify(mockAuthApiService.authenticate(phoneNumber, password)).called(1);
      verifyNever(mockUserRepository.getUserByPhoneNumber(any));
      verifyNever(mockSessionRepository.saveSession(any));
    });

    test('should reject authentication when session is expired (> 24h)', () async {
      // Arrange
      final phoneNumber = PhoneNumber.create('+79991112233').getOrElse(() => throw Exception());
      const password = 'password123';

      final user = await TestFactories.createAdminUser(
        phoneNumber: phoneNumber.value,
        externalId: 'test_user',
      );

      // Создаем сессию, которая была создана более 24 часов назад
      final expiredLoginTime = DateTime.now().subtract(const Duration(hours: 25));
      final existingSessionResult = UserSession.create(
        user: user,
        rememberMe: false,
      );

      final expiredSession = existingSessionResult.fold(
        (failure) => throw Exception('Failed to create session'),
        (session) => session.copyWith(loginTime: expiredLoginTime),
      );

      when(mockAuthApiService.authenticate(phoneNumber, password))
          .thenAnswer((_) async => Left(NetworkFailure('API unavailable')));

      when(mockSessionRepository.getCurrentSession())
          .thenAnswer((_) async => Right(expiredSession));

      // Act
      final result = await authenticationService.authenticateUser(
        phoneNumber,
        password,
        rememberMe: false,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure.message, contains('Истекло время сессии'));
          expect(failure.message, contains('25'));
        },
        (session) => fail('Should fail when session is expired'),
      );

      verify(mockAuthApiService.authenticate(phoneNumber, password)).called(1);
      verify(mockSessionRepository.getCurrentSession()).called(1);
    });

    test('should refresh session when API is available and session is old (> 12h)', () async {
      // Arrange
      final user = await TestFactories.createAdminUser(
        phoneNumber: '+79991112233',
        externalId: 'test_user',
      );

      // Создаем сессию старше 12 часов
      final oldLoginTime = DateTime.now().subtract(const Duration(hours: 15));
      final existingSessionResult = UserSession.create(
        user: user,
        rememberMe: false,
      );

      final oldSession = existingSessionResult.fold(
        (failure) => throw Exception('Failed to create session'),
        (session) => session.copyWith(loginTime: oldLoginTime),
      );

      when(mockSessionRepository.getCurrentSession())
          .thenAnswer((_) async => Right(oldSession));

      when(mockAuthApiService.getUserInfo())
          .thenAnswer((_) async => Right({
            'id': '123',
            'firstName': 'John',
            'lastName': 'Doe',
            'fatherName': 'Smith',
            'isActive': true,
          }));

      when(mockSessionRepository.saveSession(any))
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await authenticationService.refreshSessionIfNeeded();

      // Assert
      expect(result.isRight(), true);

      verify(mockSessionRepository.getCurrentSession()).called(1);
      verify(mockAuthApiService.getUserInfo()).called(1);
      verify(mockSessionRepository.saveSession(any)).called(1);
    });

    test('should not refresh session when it is fresh (< 12h)', () async {
      // Arrange
      final user = await TestFactories.createAdminUser(
        phoneNumber: '+79991112233',
        externalId: 'test_user',
      );

      // Создаем свежую сессию (< 12 часов)
      final freshLoginTime = DateTime.now().subtract(const Duration(hours: 6));
      final existingSessionResult = UserSession.create(
        user: user,
        rememberMe: false,
      );

      final freshSession = existingSessionResult.fold(
        (failure) => throw Exception('Failed to create session'),
        (session) => session.copyWith(loginTime: freshLoginTime),
      );

      when(mockSessionRepository.getCurrentSession())
          .thenAnswer((_) async => Right(freshSession));

      // На случай, если getUserInfo все-таки будет вызван (хотя не должен для свежей сессии)
      when(mockAuthApiService.getUserInfo())
          .thenAnswer((_) async => Left(NetworkFailure('Should not be called')));

      // Act
      final result = await authenticationService.refreshSessionIfNeeded();

      // Assert
      expect(result.isRight(), true);

      verify(mockSessionRepository.getCurrentSession()).called(1);
      verifyNever(mockAuthApiService.getUserInfo()); // Не должно вызываться для свежей сессии
      verifyNever(mockSessionRepository.saveSession(any)); // Не должно сохраняться
    });
  });
}