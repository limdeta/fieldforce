import 'package:flutter/material.dart';

import '../../domain/entities/payment_kind.dart';

/// Карточка выбора способа оплаты и сопутствующего документа
class PaymentMethodSelector extends StatelessWidget {
  final PaymentKind selected;
  final ValueChanged<PaymentKind> onSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = PaymentKind.predefinedOptions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Способ оплаты',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...options.map((option) {
          final isSelected =
              selected.paymentCode != null &&
              selected.paymentCode == option.paymentCode;
          return Column(
            children: [
              RadioListTile<String>(
                value: option.paymentCode!,
                groupValue: selected.paymentCode,
                contentPadding: EdgeInsets.zero,
                activeColor: theme.colorScheme.primary,
                onChanged: (_) {
                  if (!isSelected) {
                    onSelected(option);
                  }
                },
                title: Text(
                  option.paymentLabel,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Документ: ${option.documentLabel}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              if (option != options.last)
                const Divider(
                  height: 0,
                  thickness: 0.5,
                ),
            ],
          );
        }),
      ],
    );
  }
}
