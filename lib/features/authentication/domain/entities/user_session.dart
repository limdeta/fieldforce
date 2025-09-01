
import '../../../../shared/either.dart';
import '../../../../shared/failures.dart';
import 'user.dart';

class UserSession {
  final User user;
  final DateTime loginTime;
  final bool rememberMe;
  final String? deviceId;
  final List<String> permissions;

  const UserSession._({
    required this.user,
    required this.loginTime,
    required this.rememberMe,
    this.deviceId,
    required this.permissions,
  });

  static Either<Failure, UserSession> create({
    required User user,
    required bool rememberMe,
    String? deviceId,
    List<String>? permissions,
  }) {
    return Right(UserSession._(
      user: user,
      loginTime: DateTime.now(),
      rememberMe: rememberMe,
      deviceId: deviceId,
      permissions: permissions ?? _getPermissionsForUser(user),
    ));
  }


  static List<String> _getPermissionsForUser(User user) {
    switch (user.role) {
      case UserRole.admin:
        return [
          ..._getDefaultPermissions(),
          'admin.view',
          'admin.manage',
        ];
      case UserRole.manager:
        return [
          ..._getDefaultPermissions(),
          'manager.view',
          'manager.manage',
        ];
      case UserRole.user:
        return _getDefaultPermissions();
    }
  }

  // TODO убрать, модуль не знает ничего о подобных разрешениях
  static List<String> _getDefaultPermissions() {
    return [
      'routes.view',
      'routes.update',
      'visits.create',
      'visits.view',
      'pricelists.view',
      'reports.create',
      'profile.view',
      'profile.edit',
    ];
  }

  bool get isValid {
    if (rememberMe) return true;
    
    // @todo remove hardcoded session duration
    final maxSessionDuration = Duration(hours: 8);
    return DateTime.now().difference(loginTime) < maxSessionDuration;
  }

  bool hasPermission(String permission) {
    return permissions.contains(permission);
  }

  String get phoneNumber => user.phoneNumber.value;
  String get externalId => user.externalId;

  Duration? get timeUntilExpiry {
    if (rememberMe) return null;
    
    final maxSessionDuration = Duration(hours: 8);
    final elapsed = DateTime.now().difference(loginTime);
    final remaining = maxSessionDuration - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  UserSession copyWith({
    User? user,
    DateTime? loginTime,
    bool? rememberMe,
    String? deviceId,
    List<String>? permissions,
  }) {
    return UserSession._(
      user: user ?? this.user,
      loginTime: loginTime ?? this.loginTime,
      rememberMe: rememberMe ?? this.rememberMe,
      deviceId: deviceId ?? this.deviceId,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserSession &&
        other.user == user &&
        other.loginTime == loginTime &&
        other.rememberMe == rememberMe &&
        other.deviceId == deviceId &&
        _listEquals(other.permissions, permissions);
  }

  @override
  int get hashCode {
    return Object.hash(
      user, 
      loginTime, 
      rememberMe, 
      deviceId, 
      Object.hashAll(permissions)
    );
  }

  @override
  String toString() {
    return 'UserSession(user: ${user.id}, loginTime: $loginTime, rememberMe: $rememberMe, permissions: ${permissions.length})';
  }

  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
