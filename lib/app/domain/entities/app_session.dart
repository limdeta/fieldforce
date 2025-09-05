import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';

/// Сессия приложения (App-уровень)
/// 
/// Особенности:
/// - Содержит AppUser вместо обычного User
/// - Агрегирует данные из UserSession (security) 
/// - Предоставляет удобные геттеры для UI слоя
/// - Является основной сессией для всего приложения
class AppSession {
  final AppUser appUser;
  final UserSession securitySession;
  final DateTime createdAt;
  final Map<String, dynamic> appSettings;

  const AppSession({
    required this.appUser,
    required this.securitySession,
    required this.createdAt,
    this.appSettings = const {},
  });
  
  // === Делегирование к SecuritySession ===
  String get externalId => securitySession.externalId;
  DateTime get loginTime => securitySession.loginTime;
  bool get rememberMe => securitySession.rememberMe;
  Duration? get timeUntilExpiry => securitySession.timeUntilExpiry;
  List<String> get permissions => securitySession.permissions;
  bool get isValid => securitySession.isValid;
  
  // === Делегирование к AppUser ===
  String get fullName => appUser.fullName;
  String get shortName => appUser.shortName;
  String get phoneNumber => appUser.phoneNumber;
  String get displayName => appUser.displayName;
  int get id => appUser.id;
  
  // === Проверки авторизации и прав ===

  /// Проверяет полностью ли пользователь авторизован
  bool get isAuthenticated => isValid && appUser.id > 0;

  /// Проверяет активна ли сессия (не истекла)
  bool get isActive => isValid;

  /// Проверяет есть ли права администратора
  bool get isAdmin => permissions.contains('admin');

  /// Проверяет есть ли права менеджера
  bool get isManager => permissions.contains('manager') || isAdmin;

  /// Может ли пользователь получить доступ к карте
  bool get canAccessMap => permissions.isNotEmpty;

  /// Может ли пользователь получить доступ к админ панели
  bool get canAccessAdminPanel => isAdmin || isManager;

  /// Может ли пользователь запускать GPS трекинг
  bool get canStartTracking => isAuthenticated && permissions.isNotEmpty;

  /// Краткая информация о статусе для отладки
  String get statusInfo => 'Authenticated: $isAuthenticated, Valid: $isValid, Permissions: ${permissions.length}';

  AppSession updateAppUser(AppUser newAppUser) {
    return AppSession(
      appUser: newAppUser,
      securitySession: securitySession,
      createdAt: createdAt,
      appSettings: appSettings,
    );
  }
  
  AppSession updateSettings(Map<String, dynamic> newSettings) {
    return AppSession(
      appUser: appUser,
      securitySession: securitySession,
      createdAt: createdAt,
      appSettings: {...appSettings, ...newSettings},
    );
  }

  @override
  String toString() {
    return 'AppSession(user: $fullName, id: $externalId, authenticated: $isAuthenticated)';
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSession && 
      runtimeType == other.runtimeType && 
      externalId == other.externalId;

  @override
  int get hashCode => externalId.hashCode;
}