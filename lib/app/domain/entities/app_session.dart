import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/features/authentication/domain/entities/user_session.dart';

/// Сессия приложения (App-уровень)
/// 
/// Особенности:
/// - Содержит AppUser вместо обычного User
/// - Агрегирует данные из UserSession (security) 
/// - Предоставляет удобные геттеры для UI слоя
/// - Является основной сессией для всего приложения
/// - Хранит информацию о текущей корзине и торговой точке
class AppSession {
  final AppUser appUser;
  final UserSession securitySession;
  final DateTime createdAt;
  final Map<String, dynamic> appSettings;
  
  // === Информация о корзине ===
  final int? currentOrderId; // ID текущего draft заказа (корзины)

  const AppSession({
    required this.appUser,
    required this.securitySession,
    required this.createdAt,
    this.appSettings = const {},
    this.currentOrderId,
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
  
  /// ID выбранной торговой точки (делегирует к AppUser)
  int? get currentOutletId => appUser.selectedTradingPointId;
  
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
  
  // === Геттеры для корзины ===
  
  /// Есть ли активная корзина (draft заказ)
  bool get hasActiveCart => currentOrderId != null;
  
  /// Выбрана ли торговая точка для заказов
  bool get hasSelectedOutlet => currentOutletId != null;
  
  /// Готов ли к работе с заказами (есть и корзина и торговая точка)
  bool get isReadyForOrders => hasActiveCart && hasSelectedOutlet;

  /// Краткая информация о статусе для отладки
  String get statusInfo => 'Authenticated: $isAuthenticated, Valid: $isValid, Permissions: ${permissions.length}, Cart: $currentOrderId, Outlet: $currentOutletId';

  AppSession updateAppUser(AppUser newAppUser) {
    return AppSession(
      appUser: newAppUser,
      securitySession: securitySession,
      createdAt: createdAt,
      appSettings: appSettings,
      currentOrderId: currentOrderId,
    );
  }
  
  AppSession updateSettings(Map<String, dynamic> newSettings) {
    return AppSession(
      appUser: appUser,
      securitySession: securitySession,
      createdAt: createdAt,
      appSettings: {...appSettings, ...newSettings},
      currentOrderId: currentOrderId,
    );
  }
  
  /// Обновить информацию о текущей корзине
  AppSession updateCurrentCart(int? orderId) {
    return AppSession(
      appUser: appUser,
      securitySession: securitySession,
      createdAt: createdAt,
      appSettings: appSettings,
      currentOrderId: orderId,
    );
  }
  
  /// Обновить выбранную торговую точку через AppUser
  /// 
  /// Требует импорт TradingPoint для использования
  AppSession updateSelectedTradingPoint(dynamic tradingPoint) {
    final updatedAppUser = appUser.selectTradingPoint(tradingPoint);
    return AppSession(
      appUser: updatedAppUser,
      securitySession: securitySession,
      createdAt: createdAt,
      appSettings: appSettings,
      currentOrderId: currentOrderId,
    );
  }
  
  /// Обновить и корзину и торговую точку одновременно
  /// 
  /// Требует импорт TradingPoint для использования
  AppSession updateCartAndTradingPoint(int? orderId, dynamic tradingPoint) {
    final updatedAppUser = appUser.selectTradingPoint(tradingPoint);
    return AppSession(
      appUser: updatedAppUser,
      securitySession: securitySession,
      createdAt: createdAt,
      appSettings: appSettings,
      currentOrderId: orderId,
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