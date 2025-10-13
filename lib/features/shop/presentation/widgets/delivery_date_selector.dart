import 'package:flutter/material.dart';

/// Выбор даты доставки с ограничением на ближайшие два месяца
class DeliveryDateSelector extends StatelessWidget {
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DeliveryDateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateUtils.dateOnly(DateTime.now());
    final firstDate = now.add(const Duration(days: 1));
    final lastDate = DateTime(now.year, now.month + 2, now.day);

    DateTime initialDate = selectedDate ?? firstDate;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    } else if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final lastDateLabel = _formatDate(lastDate);

    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Дата доставки',
              style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Доступно с завтра и не позднее $lastDateLabel.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            CalendarDatePicker(
              initialDate: initialDate,
              firstDate: firstDate,
              lastDate: lastDate,
              currentDate: now,
              onDateChanged: (date) => onDateSelected(DateUtils.dateOnly(date)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day.$month.$year';
  }
}
