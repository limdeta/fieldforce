import 'dart:convert';
import 'dart:io';

import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/app/services/session_manager.dart';
import 'package:fieldforce/app/services/trading_point_sync_service.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart' as mockito;
import 'package:mockito/mockito.dart' show provideDummy;

import 'trading_point_sync_service_test.mocks.dart';

@GenerateMocks(
  [TradingPointRepository, AppUserRepository],
  customMocks: [
    MockSpec<SessionManager>(
      as: #MockSessionManager,
    ),
  ],
)
void main() {
  late MockSessionManager sessionManager;
  late MockTradingPointRepository tradingPointRepository;
  late MockAppUserRepository appUserRepository;
  late TradingPointSyncService service;
  late User authUser;
  late Employee employee;
  late String fixtureJson;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();

    fixtureJson = File('assets/fixtures/trading_points_sync_response.json').readAsStringSync();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (message) async {
        if (message == null) {
          return null;
        }

        final String key = utf8.decode(message.buffer.asUint8List());
        if (key == 'assets/fixtures/trading_points_sync_response.json') {
          final Uint8List encoded = Uint8List.fromList(utf8.encode(fixtureJson));
          return ByteData.view(encoded.buffer);
        }

        return null;
      },
    );

    final phoneEither = PhoneNumber.create('+7 999 111 22 33');
    final phone = phoneEither.fold((failure) => throw failure, (value) => value);

    final fallbackEmployee = Employee(
      id: 999,
      lastName: 'Fallback',
      firstName: 'User',
      role: EmployeeRole.sales,
    );

    final fallbackUser = User(
      id: 999,
      externalId: 'fallback-user',
      role: UserRole.user,
      phoneNumber: phone,
      hashedPassword: 'hashed',
    );

  provideDummy<TradingPoint>(TradingPoint(externalId: 'fallback', name: 'Fallback', region: 'P3V'));
    provideDummy<Employee>(Employee(
      id: fallbackEmployee.id,
      lastName: fallbackEmployee.lastName,
      firstName: fallbackEmployee.firstName,
      role: fallbackEmployee.role,
    ));
    provideDummy<AppUser>(AppUser(employee: fallbackEmployee, authUser: fallbackUser));
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', null);
  });

  setUp(() {
    AppConfig.setEnvironment(Environment.test);
    sessionManager = MockSessionManager();
    tradingPointRepository = MockTradingPointRepository();
    appUserRepository = MockAppUserRepository();
    service = TradingPointSyncService(
      sessionManager: sessionManager,
      tradingPointRepository: tradingPointRepository,
      appUserRepository: appUserRepository,
    );

    final phoneEither = PhoneNumber.create('+7 900 000 00 00');
    final phone = phoneEither.fold((failure) => throw failure, (value) => value);

    authUser = User(
      id: 1,
      externalId: 'external-1',
      role: UserRole.user,
      phoneNumber: phone,
      hashedPassword: 'hash',
    );

    employee = Employee(
      id: 42,
      lastName: 'Иванов',
      firstName: 'Иван',
      role: EmployeeRole.sales,
    );
  });

  tearDown(() {
    AppConfig.setEnvironment(Environment.dev);
  });

  group('syncTradingPointsForUser', () {
    test('selects first trading point when user has none', () async {
      final appUser = AppUser(employee: employee, authUser: authUser);

      mockito.when(appUserRepository.getAppUserByUserId(authUser.id!))
          .thenAnswer((_) async => Right(appUser));

      var idCounter = 100;
      final savedPoints = <TradingPoint>[];
      mockito.when(tradingPointRepository.save(mockito.any)).thenAnswer((invocation) async {
        final TradingPoint point = invocation.positionalArguments.first as TradingPoint;
        savedPoints.add(point);
        final savedPoint = point.copyWith(id: idCounter++);
        return Right<Failure, TradingPoint>(savedPoint);
      });

      mockito.when(tradingPointRepository.assignToEmployee(mockito.any, employee))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      AppUser? updatedUser;
      mockito.when(appUserRepository.updateAppUser(mockito.any)).thenAnswer((invocation) async {
        updatedUser = invocation.positionalArguments.first as AppUser;
        return Right<Failure, AppUser>(updatedUser!);
      });

      final result = await service.syncTradingPointsForUser(authUser);

      expect(result.isRight(), isTrue);
      mockito.verify(appUserRepository.getAppUserByUserId(authUser.id!)).called(1);
      mockito.verify(tradingPointRepository.save(mockito.any)).called(3);
      mockito.verify(tradingPointRepository.assignToEmployee(mockito.any, employee)).called(3);
      mockito.verify(appUserRepository.updateAppUser(mockito.any)).called(1);

      expect(updatedUser, isNotNull);
      expect(updatedUser!.selectedTradingPoint?.externalId, '0002300707_8');
      expect(updatedUser!.selectedTradingPoint?.name, 'Днепровская');
      expect(updatedUser!.selectedTradingPoint?.inn, '_____2300707');
      expect(updatedUser!.selectedTradingPoint?.region, 'P3V');
      expect(updatedUser!.employee.assignedTradingPoints, isNotEmpty);
      expect(updatedUser!.employee.assignedTradingPoints.length, 3);
      expect(savedPoints.map((tp) => tp.region).toSet(), containsAll({'M3V', 'K3V', 'P3V'}));
    });

    test('does not change selection when user already has trading point', () async {
      final existingPoint = TradingPoint(
        id: 555,
        externalId: 'EXISTING-TP',
        name: 'Existing TP',
        region: 'P3V',
      );

      final appUser = AppUser(
        employee: employee,
        authUser: authUser,
        selectedTradingPoint: existingPoint,
      );

      mockito.when(appUserRepository.getAppUserByUserId(authUser.id!))
          .thenAnswer((_) async => Right(appUser));

      mockito.when(tradingPointRepository.save(mockito.any)).thenAnswer((invocation) async {
        final TradingPoint point = invocation.positionalArguments.first as TradingPoint;
        return Right<Failure, TradingPoint>(point.copyWith(id: 100));
      });

      mockito.when(tradingPointRepository.assignToEmployee(mockito.any, employee))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await service.syncTradingPointsForUser(authUser);

      expect(result.isRight(), isTrue);
      mockito.verifyNever(appUserRepository.updateAppUser(mockito.any));
    });
  });
}
