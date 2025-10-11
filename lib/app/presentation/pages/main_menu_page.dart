import 'package:fieldforce/app/services/simple_update_service.dart';
import 'package:fieldforce/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:fieldforce/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

/// Элемент меню
class MenuItem {
  final String title;
  final IconData icon;
  final String? route;
  final List<MenuItem>? subItems;
  
  const MenuItem({
    required this.title,
    required this.icon,
    this.route,
    this.subItems,
  });
}

/// Главное меню приложения для торгового представителя
class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final Set<String> _expandedItems = {};

  /// Структура меню
  final List<MenuItem> _menuItems = const [
    MenuItem(
      title: 'Маршруты',
      icon: Icons.route,
      route: '/routes',
    ),
    MenuItem(
      title: 'Товары',
      icon: Icons.inventory,
      subItems: [
        MenuItem(
          title: 'Каталог',
          icon: Icons.list,
          route: '/products/catalog',
        ),
        MenuItem(
          title: 'Категории прайса',
          icon: Icons.category,
          route: '/products/categories',
        ),
        MenuItem(
          title: 'Акции',
          icon: Icons.local_offer,
          route: '/products/promotions',
        ),
      ],
    ),
    MenuItem(
      title: 'Торговые Точки',
      icon: Icons.store,
      route: '/outlets',
    ),
    MenuItem(
      title: 'Корзина',
      icon: Icons.shopping_cart,
      route: '/cart',
    ),
    MenuItem(
      title: 'Мои Заказы',
      icon: Icons.receipt_long,
      route: '/orders',
    ),
    MenuItem(
      title: 'Данные',
      icon: Icons.cloud_upload,
      route: '/data-sync',
    ),
    MenuItem(
      title: 'Профиль',
      icon: Icons.person,
      route: '/profile',
    ),
    MenuItem(
      title: 'Проверить обновления',
      icon: Icons.system_update,
      route: '/check-updates',
    ),
    MenuItem(
      title: 'Выйти',
      icon: Icons.exit_to_app,
      route: '/logout',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главное меню'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/sales-home');
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _menuItems.length,
        itemBuilder: (context, index) {
          final item = _menuItems[index];
          return _buildMenuItem(item);
        },
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;
    final isExpanded = _expandedItems.contains(item.title);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: const RoundedRectangleBorder(),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              item.icon,
              color: AppColors.primary,
              size: 28,
            ),
            title: Text(
              item.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: hasSubItems
                ? Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  )
                : const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
            onTap: () {
              if (hasSubItems) {
                _toggleExpansion(item.title);
              } else {
                _navigateToItem(item);
              }
            },
          ),
          if (hasSubItems && isExpanded) _buildSubMenu(item.subItems!),
        ],
      ),
    );
  }

  Widget _buildSubMenu(List<MenuItem> subItems) {
    return Container(
      color: Colors.grey[50],
      child: Column(
        children: subItems.map((subItem) {
          return ListTile(
            contentPadding: const EdgeInsets.only(left: 56, right: 16),
            leading: Icon(
              subItem.icon,
              color: AppColors.primary,
              size: 24,
            ),
            title: Text(
              subItem.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 14,
            ),
            onTap: () => _navigateToItem(subItem),
          );
        }).toList(),
      ),
    );
  }

  void _toggleExpansion(String itemTitle) {
    setState(() {
      if (_expandedItems.contains(itemTitle)) {
        _expandedItems.remove(itemTitle);
      } else {
        _expandedItems.add(itemTitle);
      }
    });
  }

  void _navigateToItem(MenuItem item) {
    if (item.route != null) {
      if (item.route == '/routes') {
        Navigator.pushNamed(context, '/routes');
      } else if (item.route == '/profile') {
        Navigator.pushNamed(context, '/profile');
      } else if (item.route == '/outlets') {
        Navigator.pushNamed(context, '/outlets');
      } else if (item.route == '/products/catalog') {
        Navigator.pushNamed(context, '/products/catalog');
      } else if (item.route == '/cart') {
        Navigator.pushNamed(context, '/cart');
      } else if (item.route == '/orders') {
        Navigator.pushNamed(context, '/orders');
      } else if (item.route == '/data-sync') {
        Navigator.pushNamed(context, '/data-sync');
      } else if (item.route == '/check-updates') {
        _handleCheckUpdates();
      } else if (item.route == '/logout') {
        _handleLogout();
      } else {
        Navigator.pushReplacementNamed(context, '/sales-home');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} - работает через главную карту'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Обработка logout
  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выйти из приложения?'),
        content: const Text('Вы уверены что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      final result = await GetIt.instance<LogoutUseCase>()();
      if (mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка logout: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          },
          (_) {
            // Переходим на страницу входа и очищаем весь стек навигации
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false, // Удаляем все предыдущие маршруты
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Неожиданная ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Обработка проверки обновлений
  void _handleCheckUpdates() {
    SimpleUpdateService.checkForUpdatesIfEnabled(context);
  }
}