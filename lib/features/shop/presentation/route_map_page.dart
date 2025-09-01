import 'package:flutter/material.dart';
import 'package:fieldforce/app/presentation/pages/sales_rep_home/sales_rep_home_page.dart';
import '../domain/entities/route.dart' as domain;

/// Страница отображения маршрута на карте
class RouteMapPage extends StatelessWidget {
  final domain.Route route;

  const RouteMapPage({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    // Вместо создания новой страницы, переходим на главный экран с выбранным маршрутом
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SalesRepHomePage(selectedRoute: route),
        ),
      );
    });

    // Показываем индикатор загрузки пока переходим
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Загрузка карты...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
