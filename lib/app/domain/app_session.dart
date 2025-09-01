import '../domain/app_user.dart';
import '../../features/authentication/domain/entities/user_session.dart';
import '../../features/authentication/domain/entities/user.dart';

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
  
  String get externalId => securitySession.externalId;
  DateTime get loginTime => securitySession.loginTime;
  bool get rememberMe => securitySession.rememberMe;
  Duration? get timeUntilExpiry => securitySession.timeUntilExpiry;
  List<String> get permissions => securitySession.permissions;
  bool get isValid => securitySession.isValid;
  
  String get fullName => appUser.fullName;
  String get shortName => appUser.shortName;
  String get phoneNumber => appUser.phoneNumber;
  String get displayName => appUser.displayName;
  int get id => appUser.id;
  
  bool get isAdmin => permissions.contains('admin');
  bool get isManager => permissions.contains('manager') || isAdmin;
  bool get canAccessMap => permissions.isNotEmpty;
  bool get canAccessAdminPanel => isAdmin || isManager;

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
    return 'AppSession(user: ${appUser.fullName}, id: $externalId, valid: $isValid)';
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