import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:fieldforce/app/services/user_preferences_service.dart';
import 'package:fieldforce/features/shop/domain/entities/catalog_display_mode.dart';
import 'package:fieldforce/features/shop/presentation/pages/product_catalog_page.dart';
import 'package:fieldforce/features/shop/presentation/pages/product_catalog_split_page.dart';

/// Страница-маршрутизатор, выбирающая режим каталога в зависимости от настроек пользователя.
class CatalogRouterPage extends StatelessWidget {
  const CatalogRouterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final preferences = GetIt.instance<UserPreferencesService>();
    final mode = preferences.getCatalogDisplayMode();

    switch (mode) {
      case CatalogDisplayMode.split:
        return const ProductCatalogSplitPage();
      case CatalogDisplayMode.classic:
        return const ProductCatalogPage();
    }
  }
}
