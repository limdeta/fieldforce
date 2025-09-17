// lib/features/shop/presentation/widgets/order_card_widget.dart

import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:intl/intl.dart';

/// Карточка заказа, вдохновленная дизайном React-версии
/// Поддерживает различные режимы отображения и действия
class OrderCardWidget extends StatelessWidget {
  final Order order;
  final bool withHeader;
  final bool withContractor;
  final String? customName;
  final List<Widget>? actions;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onChange;

  const OrderCardWidget({
    super.key,
    required this.order,
    this.withHeader = true,
    this.withContractor = true,
    this.customName,
    this.actions,
    this.onTap,
    this.onDelete,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      color: Colors.white.withOpacity(0.7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content section
              _buildContent(context),
              
              const SizedBox(height: 12),
              
              // Footer section
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom name или header
        if (customName != null) ...[
          Text(
            customName!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569), // text-accents-7
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        // Header с номером заказа и датой
        if (withHeader) ...[
          Row(
            children: [
              Text(
                'Заказ #${order.id}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569), // text-accents-7 (orderId)
                ),
              ),
              const Spacer(),
              Text(
                'от ${_formatDate(order.updatedAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B), // text-accents-6
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        
        // Торговая точка (вместо контрагента)
        if (withContractor) ...[
          Text(
            order.outlet.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
        ],
        
        // ИНН точки (если есть)
        if (order.outlet.inn != null) ...[
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFFE2E8F0), // border-t
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'ИНН: ${order.outlet.inn}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B), // text-accents-6
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Действия
        Row(
          children: [
            ...?actions,
            
            // Кнопка удаления для draft заказов
            if (order.state == OrderState.draft && onDelete != null) ...[
              if (actions?.isNotEmpty == true) const SizedBox(width: 8),
              _buildDeleteButton(context),
            ],
          ],
        ),
        
        // Итоговая стоимость
        if (order.totalCost > 0)
          Row(
            children: [
              Text(
                '${(order.totalCost / 100).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF475569), // text-accents-7
                ),
              ),
              const Text(
                ' ₽',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _showDeleteConfirmation(context),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red.shade600,
        side: BorderSide(color: Colors.red.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: const Size(60, 28),
      ),
      child: const Text(
        'удалить',
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Удалить заказ?'),
          content: Text('Заказ #${order.id} будет удален безвозвратно.'),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'отмена',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete?.call();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade600,
              ),
              child: const Text('удалить'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy.MM.dd HH:mm').format(date);
  }


}

/// Варианты отображения статуса заказа с цветовым кодированием
class OrderStatusChip extends StatelessWidget {
  final OrderState status;
  final String? customText;

  const OrderStatusChip({
    super.key,
    required this.status,
    this.customText,
  });

  @override
  Widget build(BuildContext context) {
    final (color, backgroundColor, text) = _getStatusStyle();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        customText ?? text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  (Color, Color, String) _getStatusStyle() {
    switch (status) {
      case OrderState.draft:
        return (
          const Color(0xFF92400E), // yellow-800
          const Color(0xFFFEF3C7), // yellow-100
          'черновик'
        );
      case OrderState.pending:
        return (
          const Color(0xFF1E40AF), // blue-800
          const Color(0xFFDBEAFE), // blue-100
          'отправляется'
        );
      case OrderState.completed:
        return (
          const Color(0xFF166534), // green-800
          const Color(0xFFDCFCE7), // green-100
          'завершен'
        );
      case OrderState.failed:
        return (
          const Color(0xFFB91C1C), // red-700
          const Color(0xFFFECACA), // red-100
          'ошибка'
        );
    }
  }
}