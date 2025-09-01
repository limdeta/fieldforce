import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';

/// Агрегат пользователя приложения
/// 
/// Особенности:
/// - Реализует NavigationUser для модуля навигации  
/// - Делегирует User интерфейс через композицию
/// - Агрегирует данные Employee и User из разных модулей
/// - Обеспечивает единую точку доступа к данным пользователя
class AppUser implements NavigationUser {
  final Employee employee;
  final User authUser;
  final Map<String, dynamic> settings;

  AppUser({
    required this.employee,
    required this.authUser,
    Map<String, dynamic>? settings,
  }) : settings = settings ?? _getDefaultSettings();
  
  @override
  String get firstName => employee.firstName ?? '';

  @override
  String? get lastName => employee.lastName;

  @override
  String get fullName => employee.fullName;

  @override
  int get id => employee.id; // Employee.id и есть AppUser.id


  String get phoneNumber => authUser.phoneNumber.value;
  UserRole get role => authUser.role;
  String get externalId => authUser.externalId;

  String get displayName => fullName;
  String get shortName => employee.shortName;
  
  AppUser updateSettings(Map<String, dynamic> newSettings) {
    return AppUser(
      employee: employee,
      authUser: authUser,
      settings: {...settings, ...newSettings},
    );
  }
  
  static Map<String, dynamic> _getDefaultSettings() {
    return {
      'theme': 'light',
      'notifications': true,
      'gps_tracking': true,
      'auto_sync': true,
      'language': 'ru',
    };
  }

  @override
  String toString() {
    return 'AppUser(id: $id, name: $fullName, role: $role, externalId: $externalId)';
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser && 
      runtimeType == other.runtimeType && 
      id == other.id;

  @override
  int get hashCode => id.hashCode;
}