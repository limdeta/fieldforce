import 'package:flutter/material.dart';

/// Опции для выбора домашней страницы приложения
enum HomePageOption {
  menu('/menu', 'Главное меню', Icons.menu),
  map('/sales-home', 'Карта', Icons.map),
  search('/products/search', 'Поиск', Icons.search),
  catalog('/products/catalog', 'Каталог', Icons.inventory),
  cart('/cart', 'Корзина', Icons.shopping_cart);

  const HomePageOption(this.route, this.label, this.icon);

  final String route;
  final String label;
  final IconData icon;

  /// Получить опцию по маршруту
  static HomePageOption fromRoute(String route) {
    return HomePageOption.values.firstWhere(
      (option) => option.route == route,
      orElse: () => HomePageOption.menu, // по умолчанию главное меню
    );
  }
}
