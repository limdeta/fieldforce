import 'package:flutter/material.dart';
import 'package:fieldforce/app/helpers/navigation_helper.dart';

/// Универсальная иконка "Домой" для AppBar
/// 
/// Автоматически скрывается, если текущая страница уже является домашней.
/// Используй в AppBar.actions вместо ручной проверки на каждой странице.
class HomeIconButton extends StatelessWidget {
  /// Цвет иконки (опционально)
  final Color? color;
  
  /// Размер иконки (по умолчанию 24)
  final double iconSize;

  const HomeIconButton({
    super.key,
    this.color,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    // Получаем текущий маршрут
    final currentRoute = ModalRoute.of(context)?.settings.name;
    
    // Получаем домашний маршрут из настроек
    final homeRoute = NavigationHelper.getHomeRoute();
    
    // Если мы уже на домашней странице - не показываем кнопку
    if (currentRoute == homeRoute) {
      return const SizedBox.shrink();
    }
    
    // Иначе показываем иконку Home
    return IconButton(
      icon: Icon(Icons.home, color: color),
      iconSize: iconSize,
      onPressed: () => NavigationHelper.navigateHome(context, clearStack: true),
      tooltip: 'На главную',
    );
  }
}
