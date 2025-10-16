import 'package:fieldforce/app/presentation/widgets/trading_point_map/trading_point_map_factory.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_trading_point_orders_usecase.dart';
import 'package:fieldforce/features/shop/presentation/pages/order_detail_page.dart';
import 'package:fieldforce/features/shop/presentation/widgets/order_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

/// Страница детализации торговой точки
class TradingPointDetailPage extends StatefulWidget {
  final TradingPoint tradingPoint;

  const TradingPointDetailPage({super.key, required this.tradingPoint});

  @override
  State<TradingPointDetailPage> createState() => _TradingPointDetailPageState();
}

class _TradingPointDetailPageState extends State<TradingPointDetailPage> {
  static final Logger _logger = Logger('TradingPointDetailPage');

  final TradingPointMapFactory _mapFactory =
      GetIt.instance<TradingPointMapFactory>();
  final GetTradingPointOrdersUseCase _getTradingPointOrdersUseCase =
      GetIt.instance<GetTradingPointOrdersUseCase>();
  final DateFormat _orderDateFormat = DateFormat('dd.MM.yyyy HH:mm');
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'ru_RU',
    symbol: '₽',
    decimalDigits: 2,
  );

  bool _isProcessing = false;
  int? _selectedTradingPointId;
  bool _ordersLoading = false;
  List<Order> _orders = const [];
  String? _ordersError;

  @override
  void initState() {
    super.initState();
    _loadSelectionState();
    _loadOrders();
  }

  Future<void> _loadSelectionState() async {
    final sessionResult = await AppSessionService.getCurrentAppSession();
    if (!mounted) return;

    sessionResult.fold((_) {}, (session) {
      setState(() {
        _selectedTradingPointId = session?.appUser.selectedTradingPointId;
      });
    });
  }

  bool get _isCurrentlySelected =>
      _selectedTradingPointId == widget.tradingPoint.id;

  Future<void> _handleSelect() async {
    if (_isCurrentlySelected) {
      Navigator.pop(context, false);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final result = await AppSessionService.selectTradingPoint(
      widget.tradingPoint,
    );
    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Не удалось выбрать торговую точку: ${failure.message}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      },
      (session) {
        setState(() {
          _selectedTradingPointId = session.appUser.selectedTradingPointId;
        });
        Navigator.pop(context, true);
      },
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _handleClearSelection() async {
    if (!_isCurrentlySelected) {
      Navigator.pop(context, false);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final result = await AppSessionService.clearSelectedTradingPoint();
    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось снять выбор: ${failure.message}'),
            backgroundColor: Colors.red,
          ),
        );
      },
      (session) {
        setState(() {
          _selectedTradingPointId = session.appUser.selectedTradingPointId;
        });
        Navigator.pop(context, true);
      },
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _loadOrders() async {
    final tradingPointId = widget.tradingPoint.id;
    if (tradingPointId == null) {
      setState(() {
        _ordersLoading = false;
        _orders = const [];
        _ordersError = 'Торговая точка ещё не синхронизирована с базой';
      });
      return;
    }

    setState(() {
      _ordersLoading = true;
      _ordersError = null;
    });

    final result = await _getTradingPointOrdersUseCase(tradingPointId);
    if (!mounted) {
      return;
    }

    result.fold(
      (failure) {
        _logger.warning(
          'Не удалось загрузить заказы для торговой точки $tradingPointId: ${failure.message}',
          failure.details,
        );

        setState(() {
          _ordersLoading = false;
          _orders = const [];
          _ordersError = failure.message;
        });
      },
      (orders) {
        setState(() {
          _ordersLoading = false;
          _orders = orders;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tradingPoint.name),

        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _isProcessing ? null : _handleSelect,
            icon: Icon(
              _isCurrentlySelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
            ),
            tooltip: _isCurrentlySelected
                ? 'Текущая торговая точка'
                : 'Сделать текущей',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isCurrentlySelected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Эта торговая точка выбрана как текущая',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
            // Основная информация
            _DetailSection(
              icon: Icons.store,
              title: 'Основная информация',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Название', widget.tradingPoint.name),
                  _buildInfoRow('Регион', widget.tradingPoint.region),
                  if (widget.tradingPoint.inn != null)
                    _buildInfoRow('ИНН', widget.tradingPoint.inn!),
                  _buildInfoRow('Внешний ID', widget.tradingPoint.externalId),
                  _buildInfoRow(
                    'Дата создания',
                    _formatDate(widget.tradingPoint.createdAt),
                  ),
                  if (widget.tradingPoint.updatedAt != null)
                    _buildInfoRow(
                      'Дата обновления',
                      _formatDate(widget.tradingPoint.updatedAt!),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _DetailSection(
              icon: Icons.shopping_cart_outlined,
              title: 'Заказы',
              child: _buildOrdersSection(),
            ),
            // Заглушка под карту
            _DetailSection(
              icon: Icons.location_on_outlined,
              title: 'Местоположение',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _mapFactory.build(tradingPoint: widget.tradingPoint),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatCoordinates(widget.tradingPoint),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (widget.tradingPoint.latitude != null &&
                          widget.tradingPoint.longitude != null)
                        IconButton(
                          onPressed: () =>
                              _copyCoordinates(widget.tradingPoint),
                          icon: const Icon(Icons.copy, size: 18),
                          tooltip: 'Скопировать координаты',
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Дополнительная информация (заглушка)
            _DetailSection(
              icon: Icons.info_outline,
              title: 'Дополнительно',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.pending, color: Colors.black54),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Дополнительные данные будут доступны позднее.',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _handleSelect,
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isCurrentlySelected
                                ? Icons.check_circle
                                : Icons.radio_button_checked,
                          ),
                    label: Text(
                      _isCurrentlySelected
                          ? 'Точка выбрана'
                          : 'Сделать текущей',
                    ),
                  ),
                ),
              ],
            ),
            if (_isCurrentlySelected) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _isProcessing ? null : _handleClearSelection,
                  child: const Text('Снять выбор'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersSection() {
    final headerText = _ordersLoading
        ? 'Загружаем заказы...'
        : 'Всего заказов: ${_orders.length}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              headerText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            IconButton(
              onPressed: _ordersLoading ? null : _loadOrders,
              icon: const Icon(Icons.refresh, size: 18),
              tooltip: 'Обновить заказы',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_ordersLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (_ordersError != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _ordersError!,
                style: const TextStyle(color: Colors.redAccent),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _loadOrders,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Попробовать снова'),
              ),
            ],
          )
        else if (_orders.isEmpty)
          Text(
            'Заказы ещё не оформляли',
            style: TextStyle(color: Colors.grey.shade600),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = _orders[index];
              return _buildOrderTile(order);
            },
          ),
      ],
    );
  }

  Widget _buildOrderTile(Order order) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openOrder(order),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    order.id != null ? 'Заказ #${order.id}' : 'Черновик',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OrderStatusChip(status: order.state),
                  const Spacer(),
                  Text(
                    _orderDateFormat.format(order.updatedAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Позиций: ${order.lines.length}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.payments_outlined,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatOrderAmount(order),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              if ((order.comment?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 8),
                Text(
                  order.comment!,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatOrderAmount(Order order) {
    final amount = order.totalCost / 100;
    return _currencyFormat.format(amount);
  }

  Future<void> _openOrder(Order order) async {
    final orderId = order.id;
    if (orderId == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Заказ ещё не синхронизирован и недоступен для просмотра',
          ),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderDetailPage(orderId: orderId)),
    );

    if (!mounted) {
      return;
    }

    _loadOrders();
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatCoordinates(TradingPoint tradingPoint) {
    final lat = tradingPoint.latitude;
    final lon = tradingPoint.longitude;
    if (lat == null || lon == null) {
      return 'Координаты недоступны';
    }
    return 'Широта: ${lat.toStringAsFixed(6)}, долгота: ${lon.toStringAsFixed(6)}';
  }

  Future<void> _copyCoordinates(TradingPoint tradingPoint) async {
    final lat = tradingPoint.latitude;
    final lon = tradingPoint.longitude;
    if (lat == null || lon == null) return;

    final coordinates = '${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';
    await Clipboard.setData(ClipboardData(text: coordinates));

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Скопировано: $coordinates')));
  }
}

class _DetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _DetailSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.black87, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
