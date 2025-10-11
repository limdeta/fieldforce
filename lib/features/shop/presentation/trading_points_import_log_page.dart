import 'package:fieldforce/app/theme/app_colors.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:flutter/material.dart';

/// Простая страница-лог импортированных торговых точек.
class TradingPointsImportLogPage extends StatelessWidget {
  final List<TradingPoint> tradingPoints;

  const TradingPointsImportLogPage({
    super.key,
    required this.tradingPoints,
  });

  @override
  Widget build(BuildContext context) {
    final sortedPoints = List<TradingPoint>.from(tradingPoints)
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Лог импорта торговых точек'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemBuilder: (context, index) {
          final point = sortedPoints[index];
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              child: Text(
                point.region.substring(0, 1).toUpperCase(),
              ),
            ),
            title: Text(
              point.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (point.externalId.isNotEmpty)
                  Text('ID: ${point.externalId}'),
                Text('Регион: ${point.region}'),
                if (point.inn != null && point.inn!.isNotEmpty)
                  Text('ИНН: ${point.inn}'),
              ],
            ),
            trailing: Text(
              '#${point.id}',
              style: const TextStyle(color: Colors.black54),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          );
        },
  separatorBuilder: (context, _) => const Divider(height: 1),
        itemCount: sortedPoints.length,
      ),
    );
  }
}
