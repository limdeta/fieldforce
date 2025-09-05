import 'package:flutter/material.dart';
import '../../../app/domain/entities/route.dart' as domain;

/// Страница отображения маршрута на карте
class RouteMapPage extends StatelessWidget {
  final domain.Route route;

  const RouteMapPage({
    super.key,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(
        context,
        '/sales-home',
        arguments: {'selectedRoute': route},
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
