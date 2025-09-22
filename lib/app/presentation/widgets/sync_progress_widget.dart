import 'package:flutter/material.dart';

import '../../../shared/models/sync_progress.dart';

/// Виджет отображения прогресса синхронизации
class SyncProgressWidget extends StatelessWidget {
  final SyncProgress progress;
  final bool isActive;

  const SyncProgressWidget({
    super.key,
    required this.progress,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Статус
        Text(
          progress.status,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        // Прогресс-бар
        LinearProgressIndicator(
          value: progress.percentage,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getProgressColor(),
          ),
        ),
        const SizedBox(height: 4),

        // Процент и детали
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress.percentage * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (progress.current > 0 || progress.total > 0)
              Text(
                '${progress.current}/${progress.total}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
          ],
        ),

        // Оставшееся время
        if (progress.estimatedTimeRemaining != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Осталось: ${_formatTime(progress.estimatedTimeRemaining!)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }

  Color _getProgressColor() {
    if (!isActive) {
      return Colors.grey;
    }

    if (progress.percentage < 0.3) {
      return Colors.red;
    } else if (progress.percentage < 0.7) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '$seconds сек';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '$minutes мин $remainingSeconds сек';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '$hours ч $minutes мин';
    }
  }
}