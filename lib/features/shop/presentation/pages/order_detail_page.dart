import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/entities/payment_kind.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_order_by_id_usecase.dart';
import 'package:fieldforce/features/shop/presentation/pages/product_detail_page.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/shared/services/image_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

class OrderDetailPage extends StatefulWidget {
  final int orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  static final Logger _logger = Logger('OrderDetailPage');

  final GetOrderByIdUseCase _getOrderByIdUseCase =
      GetIt.instance<GetOrderByIdUseCase>();

  bool _isLoading = true;
  Order? _order;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _getOrderByIdUseCase(
      GetOrderByIdParams(orderId: widget.orderId),
    );

    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        _logger.warning(
          'Не удалось загрузить заказ ${widget.orderId}: ${failure.message}',
          failure.details,
        );
        setState(() {
          _isLoading = false;
          _order = null;
          _errorMessage = failure.message;
        });
      },
      (order) {
        setState(() {
          _isLoading = false;
          _order = order;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _order != null
        ? 'Заказ #${_order!.id ?? '—'}'
        : 'Заказ #${widget.orderId}';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadOrder,
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadOrder,
              icon: const Icon(Icons.refresh),
              label: const Text('Попробовать снова'),
            ),
          ],
        ),
      );
    }

    final order = _order;
    if (order == null) {
      return const Center(child: Text('Заказ недоступен'));
    }

    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.outlet.name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Создан: ${_formatDate(order.createdAt)}',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Обновлён: ${_formatDate(order.updatedAt)}',
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            _buildStatusChip(context, order),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Итого: ${_formatMoney(order.totalCost)}',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          '${order.totalQuantity} товар(ов) · ${order.itemCount} позиций',
          style: textTheme.bodyMedium,
        ),
        if (order.failureReason?.isNotEmpty == true) ...[
          const SizedBox(height: 12),
          Text(
            'Причина ошибки',
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            order.failureReason!,
            style: textTheme.bodyMedium?.copyWith(color: Colors.redAccent),
          ),
        ],
        const SizedBox(height: 18),
        _buildInfoSection(order),
        const SizedBox(height: 18),
        Text(
          'Товары',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ..._buildLineItems(order.lines),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context, Order order) {
    final theme = Theme.of(context);
    Color chipColor;
    String label;

    switch (order.state) {
      case OrderState.pending:
        chipColor = const Color(0xFFF59E0B);
        label = 'В обработке';
        break;
      case OrderState.confirmed:
        chipColor = const Color(0xFF2563EB);
        label = 'Подтверждён';
        break;
      case OrderState.error:
        chipColor = const Color(0xFFDC2626);
        label = 'Требует внимания';
        break;
      case OrderState.draft:
        chipColor = const Color(0xFF6B7280);
        label = 'Черновик';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoSection(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Торговая точка', order.outlet.name),
        _buildInfoRow(
          'Комментарий',
          order.comment?.isNotEmpty == true ? order.comment! : '—',
        ),
        _buildInfoRow('Способ оплаты', _describePaymentKind(order.paymentKind)),
      ],
    );
  }

  List<Widget> _buildLineItems(List<OrderLine> lines) {
    if (lines.isEmpty) {
      return [
        Text(
          'В заказе пока нет товаров',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ];
    }

    final children = <Widget>[];
    for (var i = 0; i < lines.length; i++) {
      children.add(_buildLineRow(lines[i]));
      if (i < lines.length - 1) {
        children.add(const Divider(height: 16));
      }
    }
    return children;
  }

  Widget _buildLineRow(OrderLine line) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openProduct(line),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThumbnail(line),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.productTitle,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Артикул: ${line.productVendorCode}',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Склад: ${line.warehouseName}',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${line.quantity} шт.', style: textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoney(line.totalCost),
                    style: textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Colors.grey.shade500,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(OrderLine line) {
    final image = line.product?.defaultImage;
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ImageCacheService.getCachedThumbnail(
                imageUrl: image.getOptimalUrl(),
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            )
          : Icon(
              Icons.image_not_supported_outlined,
              size: 24,
              color: Colors.grey.shade400,
            ),
    );
  }

  void _openProduct(OrderLine line) {
    final product = line.product;
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Информация о товаре недоступна')),
      );
      return;
    }

    final productWithStock = ProductWithStock(
      product: product,
      totalStock: line.stockItem.stock,
      maxPrice: line.stockItem.defaultPrice,
      minPrice: line.stockItem.availablePrice ?? line.stockItem.defaultPrice,
      hasDiscounts: line.stockItem.discountValue > 0,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(productWithStock: productWithStock),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  String _formatMoney(int amountInCents) {
    final sign = amountInCents < 0 ? '-' : '';
    final absValue = amountInCents.abs();
    final rubles = absValue ~/ 100;
    final pennies = absValue % 100;

    final rublesStr = rubles.toString().replaceAll(
      RegExp(r'(?<=\d)(?=(\d{3})+(?!\d))'),
      ' ',
    );

    return '$sign$rublesStr,${pennies.toString().padLeft(2, '0')} ₽';
  }

  String _describePaymentKind(PaymentKind paymentKind) {
    if (!paymentKind.isValid()) {
      return 'Не указан';
    }

    final paymentLabel = paymentKind.paymentLabel;
    final documentLabel = paymentKind.documentLabel;

    if (documentLabel != '—' && documentLabel.isNotEmpty) {
      return '$paymentLabel · $documentLabel';
    }

    return paymentLabel;
  }
}
