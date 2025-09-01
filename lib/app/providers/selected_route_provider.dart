import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../../features/shop/domain/entities/route.dart' as domain;
import '../services/user_preferences_service.dart';

/// Provider для управления состоянием выбранного маршрута
/// 
/// Этот provider:
/// - Отслеживает какой маршрут выбран пользователем
/// - Сохраняет выбор в SharedPreferences для постоянства
/// - Уведомляет виджеты об изменениях через ChangeNotifier
/// - Предоставляет методы для изменения выбранного маршрута
class SelectedRouteProvider extends ChangeNotifier {
  domain.Route? _selectedRoute;
  
  UserPreferencesService? get _preferencesService {
    try {
      return GetIt.instance<UserPreferencesService>();
    } catch (e) {
      return null;
    }
  }

  domain.Route? get selectedRoute => _selectedRoute;
  bool get hasSelectedRoute => _selectedRoute != null;
  int? get selectedRouteId => _selectedRoute?.id;

  DateTime? get selectedRouteDate {
    if (_selectedRoute?.startTime != null) {
      return _selectedRoute!.startTime!;
    }
    // Fallback на сегодня если время начала не установлено
    return DateTime.now();
  }

  /// Устанавливает выбранный маршрут
  /// 
  /// [route] - маршрут для выбора (может быть null для очистки)
  /// [persist] - сохранять ли выбор в SharedPreferences (по умолчанию true)
  Future<void> setSelectedRoute(domain.Route? route, {bool persist = true}) async {
    if (_selectedRoute?.id == route?.id) {
      return;
    }
    
    _selectedRoute = route;
    
    if (persist && _preferencesService != null) {
      await _preferencesService!.setSelectedRouteId(route?.id);
    }
    
    notifyListeners();
  }

  /// Загружает сохраненный выбор маршрута из SharedPreferences
  /// 
  /// [availableRoutes] - список доступных маршрутов для поиска
  /// Возвращает true если маршрут был найден и установлен
  Future<bool> loadSavedSelection(List<domain.Route> availableRoutes) async {
    final savedRouteId = _preferencesService?.getSelectedRouteId();
    
    if (savedRouteId == null) {
      return false;
    }
    
    // Ищем маршрут с сохраненным ID
    try {
      final savedRoute = availableRoutes.firstWhere(
        (route) => route.id == savedRouteId,
      );
      
      // Устанавливаем без сохранения (чтобы избежать цикла)
      await setSelectedRoute(savedRoute, persist: false);
      
      if (kDebugMode) {
        print('✅ Загружен сохраненный маршрут: ${savedRoute.name}');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Сохраненный маршрут с ID $savedRouteId не найден');
      }

      if (_preferencesService != null) {
        await _preferencesService!.setSelectedRouteId(null);
      }
      return false;
    }
  }

  Future<void> clearSelection() async {
    await setSelectedRoute(null);
  }

  /// Переключает маршрут (полезно для кнопок toggle)
  /// 
  /// [route] - маршрут для переключения
  /// Если маршрут уже выбран - очищает выбор
  /// Если не выбран - устанавливает как выбранный
  Future<void> toggleRoute(domain.Route route) async {
    if (_selectedRoute?.id == route.id) {
      await clearSelection();
    } else {
      await setSelectedRoute(route);
    }
  }

  /// Проверяет является ли маршрут выбранным
  bool isRouteSelected(domain.Route route) {
    return _selectedRoute?.id == route.id;
  }

  /// Получает название выбранного маршрута (для UI)
  String getSelectedRouteName() {
    return _selectedRoute?.name ?? 'Маршрут не выбран';
  }

}
