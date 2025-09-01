import 'dart:convert';
import 'dart:io';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Временно отключено для Windows сборки
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fieldforce/shared/failures.dart';

import '../../../features/authentication/domain/entities/user_session.dart';
import '../../../features/authentication/domain/entities/user.dart';
import '../../../features/authentication/domain/repositories/session_repository.dart';
import '../../../features/authentication/domain/value_objects/phone_number.dart';
import '../../../shared/either.dart';


/// Временная заглушка для FlutterSecureStorage
class _MockSecureStorage {
  static final Map<String, String> _storage = {};
  
  const _MockSecureStorage();
  
  Future<String?> read({required String key}) async {
    return _storage[key];
  }
  
  Future<void> write({required String key, required String value}) async {
    _storage[key] = value;
  }
  
  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }
  
  Future<void> deleteAll() async {
    _storage.clear();
  }
}

/// Реализация репозитория сессий с использованием зашифрованного хранилища
class SessionRepositoryImpl implements SessionRepository {
  static const String _sessionKey = 'user_session';
  final _MockSecureStorage _secureStorage;

  const SessionRepositoryImpl({
    _MockSecureStorage? secureStorage,
  }) : _secureStorage = secureStorage ?? const _MockSecureStorage();

  @override
  Future<Either<AuthFailure, UserSession?>> getCurrentSession() async {
    try {
      final sessionJson = await _secureStorage.read(key: _sessionKey);
      if (sessionJson == null) {
        return const Right(null);
      }

      final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
      final session = await _sessionFromJson(sessionData);
      
      if (session == null) {
        await clearSession(); // Очищаем невалидную сессию
        return const Right(null);
      }

      if (!session.isValid) {
        await clearSession(); // Очищаем истекшую сессию
        return const Right(null);
      }

      return Right(session);
    } catch (e) {
      return Left(AuthFailure('Failed to get current session: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, void>> saveSession(UserSession session) async {
    try {
      final deviceId = await _getDeviceId();
      final sessionWithDevice = session.copyWith(deviceId: deviceId);
      
      final sessionJson = jsonEncode(_sessionToJson(sessionWithDevice));
      await _secureStorage.write(key: _sessionKey, value: sessionJson);
      
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Failed to save session: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, void>> clearSession() async {
    try {
      await _secureStorage.delete(key: _sessionKey);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure('Failed to clear session: ${e.toString()}'));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> hasValidSession() async {
    final result = await getCurrentSession();
    return result.fold(
      (failure) => Left(failure),
      (session) => Right(session != null && session.isValid),
    );
  }

  @override
  Future<Either<AuthFailure, void>> refreshSession() async {
    final sessionResult = await getCurrentSession();
    return sessionResult.fold(
      (failure) => Left(failure),
      (session) async {
        if (session == null) {
          return const Left(AuthFailure('No session to refresh'));
        }
        
        // Обновляем время входа
        final refreshedSession = session.copyWith(loginTime: DateTime.now());
        return await saveSession(refreshedSession);
      },
    );
  }

  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios';
      }
      return 'unknown_device';
    } catch (e) {
      return 'device_id_error';
    }
  }

  Map<String, dynamic> _sessionToJson(UserSession session) {
    return {
      'user': {
        'externalId': session.user.externalId,
        'phoneNumber': session.user.phoneNumber.value,
        'hashedPassword': session.user.hashedPassword,
      },
      'loginTime': session.loginTime.toIso8601String(),
      'rememberMe': session.rememberMe,
      'deviceId': session.deviceId,
      'permissions': session.permissions,
    };
  }

  Future<UserSession?> _sessionFromJson(Map<String, dynamic> json) async {
    try {
      final userData = json['user'] as Map<String, dynamic>;
      
      // Восстанавливаем PhoneNumber
      final phoneResult = PhoneNumber.create(userData['phoneNumber'] as String);
      if (phoneResult.isLeft()) return null;

      // Восстанавливаем User
      final roleStr = userData['role'] as String? ?? 'user';
      final role = UserRole.values.firstWhere(
        (r) => r.name == roleStr,
        orElse: () => UserRole.user,
      );
      final userResult = User.create(
        externalId: userData['externalId'] as String,
        phoneNumber: (phoneResult as Right).value,
        hashedPassword: userData['hashedPassword'] as String,
        role: role,
      );
      
      if (userResult.isLeft()) return null;

      // Создаем UserSession
      final sessionResult = UserSession.create(
        user: (userResult as Right).value,
        rememberMe: json['rememberMe'] as bool? ?? false,
        deviceId: json['deviceId'] as String?,
        permissions: (json['permissions'] as List?)?.cast<String>(),
      );

      if (sessionResult.isLeft()) return null;

      final session = (sessionResult as Right).value;
      
      // Восстанавливаем время входа
      final loginTime = DateTime.parse(json['loginTime'] as String);
      return session.copyWith(loginTime: loginTime);
      
    } catch (e) {
      return null;
    }
  }
}
