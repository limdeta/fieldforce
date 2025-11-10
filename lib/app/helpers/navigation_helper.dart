import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/services/user_preferences_service.dart';

/// Хелпер для навигации с поддержкой настраиваемой домашней страницы
class NavigationHelper {
  /// Получить маршрут домашней страницы из настроек
  static String getHomeRoute() {
    try {
      if (GetIt.instance.isRegistered<UserPreferencesService>()) {
        final prefs = GetIt.instance<UserPreferencesService>();
        return prefs.getHomePageRoute();
      }
    } catch (e) {
      // Если не удалось получить настройки, используем дефолт
    }
    // Fallback: если сервис не зарегистрирован или произошла ошибка
    return '/menu';
  }

  /// Перейти на домашнюю страницу
  /// 
  /// [context] - контекст для навигации
  /// [clearStack] - если true, очистит весь стек навигации
  static void navigateHome(BuildContext context, {bool clearStack = false}) {
    final route = getHomeRoute();
    
    // Получаем текущий маршрут
    final currentRoute = ModalRoute.of(context)?.settings.name;
    
    // Если мы уже на домашней странице, просто закрываем все поверх неё
    if (currentRoute == route) {
      // Уже на домашней странице - ничего не делаем или просто pop до корня
      if (Navigator.canPop(context)) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
      return;
    }
    
    if (clearStack) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        route,
        (route) => false,
      );
    } else {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  /// Проверить, является ли текущий маршрут домашней страницей
  static bool isHomeRoute(String currentRoute) {
    return currentRoute == getHomeRoute();
  }
}
