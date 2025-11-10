// lib/features/shop/presentation/widgets/stock_item_selector_widget.dart

import 'package:fieldforce/app/theme/app_colors.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';


/// Универсальный селектор товаров для продукта
/// 
/// Продукт (Product) = абстрактная сущность с характеристиками
/// Товар = Product + StockItem = конкретная вещь на конкретном складе
/// 
/// Этот виджет получает все товары (StockItem) для заданного продукта из базы 
/// и позволяет выбрать конкретный товар для покупки
class StockItemSelectorWidget extends StatefulWidget {
  final int productCode;
  final StockItem? selectedStockItem;
  
  final void Function(StockItem stockItem) onStockItemSelected;
  
  final bool showFullInfo;
  // Optional outer margin so parent can control spacing. Default to zero.
  final EdgeInsetsGeometry outerMargin;
  // Compact mode reduces paddings and font sizes for inline usage
  final bool compact;

  const StockItemSelectorWidget({
    super.key,
    required this.productCode,
    required this.onStockItemSelected,
    this.selectedStockItem,
    this.showFullInfo = true,
    this.outerMargin = EdgeInsets.zero,
    this.compact = false,
  });

  @override
  State<StockItemSelectorWidget> createState() => _StockItemSelectorWidgetState();
}

class _StockItemSelectorWidgetState extends State<StockItemSelectorWidget> {
  static final Logger _logger = Logger('StockItemSelectorWidget');
  
  late final StockItemRepository _stockItemRepository;
  List<StockItem> _stockItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _stockItemRepository = GetIt.instance<StockItemRepository>();
    _loadStockItems();
  }

  Future<void> _loadStockItems() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _logger.info('Загружаем товары для продукта ${widget.productCode}');
      
      final result = await _stockItemRepository.getStockItemsByProductCode(widget.productCode);
      
      if (!mounted) return;
      
      result.fold(
        (failure) {
          _logger.warning('Ошибка загрузки товаров: $failure');
          if (!mounted) return;
          setState(() {
            _errorMessage = 'Ошибка загрузки складских остатков';
            _isLoading = false;
          });
        },
        (stockItems) {
          _logger.info('Загружено ${stockItems.length} товаров для продукта ${widget.productCode}');
          if (!mounted) return;
          setState(() {
            _stockItems = stockItems;
            _isLoading = false;
          });
          
          // Автоматически выбираем первый StockItem если он не выбран
          if (widget.selectedStockItem == null && stockItems.isNotEmpty) {
            final firstStockItem = stockItems.first;
            _logger.info('Автовыбор первого товара: склад=${firstStockItem.warehouseName}');
            widget.onStockItemSelected(firstStockItem);
          }
        },
      );
    } catch (e, st) {
      _logger.severe('Неожиданная ошибка при загрузке StockItem', e, st);
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Неожиданная ошибка';
        _isLoading = false;
      });
    }
  }

  void _selectStockItem(StockItem stockItem) {
    _logger.info('Выбран товар: склад=${stockItem.warehouseName}, остаток=${stockItem.stock}');
    widget.onStockItemSelected(stockItem);
  }

  String _formatPrice(int priceInKopecks) {
    return (priceInKopecks / 100).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            _errorMessage!,
            style: TextStyle(color: Colors.red.shade700),
          ),
        ),
      );
    }

    if (_stockItems.isEmpty) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Товар не найден на складах',
            style: TextStyle(color: Colors.orange),
          ),
        ),
      );
    }

    // Основная кнопка селектора
    final selectedStockItem = widget.selectedStockItem;
    final hasMultipleStockItems = _stockItems.length > 1;
    
    return Container(
      margin: widget.outerMargin,
      child: hasMultipleStockItems
        ? Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
            elevation: 0,
            child: Container(
              // Reduced padding for compact inline selector
              padding: widget.compact ? const EdgeInsets.symmetric(horizontal: 2, vertical: 0) : const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                // Removed border to make selector look inline; keep a subtle background
                color: Colors.grey.shade50,
              ),
              child: DropdownButton<StockItem>(
            value: selectedStockItem,
            onChanged: (StockItem? stockItem) {
              if (stockItem != null) {
                _selectStockItem(stockItem);
              }
            },
            isExpanded: true, // Заставляем занимать всю ширину контейнера
            underline: const SizedBox(), // Убираем подчеркивание
            icon: Container(
              width: widget.compact ? 28 : 32,
              height: widget.compact ? 20 : 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade800, // rectangle color (text-color like)
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: widget.compact ? 14 : 16,
                  // Paint the arrow with scaffold background color to make it look like a cutout
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
            dropdownColor: Colors.white, // Белый фон выпадающего списка
            borderRadius: BorderRadius.circular(4), // Минимальные скругления для меню
            style: TextStyle(
              color: Colors.black,
              fontSize: widget.compact ? 12 : 14,
            ),
            items: _stockItems.map((stockItem) {
              return DropdownMenuItem<StockItem>(
                value: stockItem,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Warehouse name
                            Expanded(
                              child: Text(
                                stockItem.warehouseName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: widget.selectedStockItem?.id == stockItem.id
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                                  color: widget.selectedStockItem?.id == stockItem.id
                                    ? AppColors.slate800 
                                    : Colors.black,
                                  fontSize: widget.compact ? 12 : 14,
                                ),
                              ),
                            ),
                            SizedBox(width: widget.compact ? 6 : 8),
                            // Stock count between name and price (show in fullInfo or compact modes)
                            if (widget.showFullInfo || widget.compact) ...[
                              Padding(
                                padding: EdgeInsets.only(right: widget.compact ? 6 : 8),
                                child: Text(
                                  '${stockItem.stock} шт.',
                                  style: TextStyle(
                                    fontSize: widget.compact ? 11 : 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                            // Price aligned to the end, constrained width to avoid overflow
                            ConstrainedBox(
                              constraints: widget.compact ? const BoxConstraints(minWidth: 48, maxWidth: 80) : const BoxConstraints(minWidth: 64, maxWidth: 100),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      stockItem.offerPrice != null
                                        ? '${_formatPrice(stockItem.offerPrice!)} ₽'
                                        : '${_formatPrice(stockItem.defaultPrice)} ₽',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        fontSize: widget.compact ? 12 : 14,
                                        fontWeight: widget.compact ? FontWeight.w500 : FontWeight.w500,
                                        color: stockItem.offerPrice != null 
                                          ? const Color.fromARGB(255, 54, 48, 48) 
                                          : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: widget.compact ? 6 : 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // removed duplicate bottom stock line; inline count above is used instead
                      ],
                    ),
                ),
              );
            }).toList(),
              ),
            ),
          )
        : Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4), // Минимальные скругления
            elevation: 0, 
            child: Container(
              padding: widget.compact ? const EdgeInsets.symmetric(horizontal: 6, vertical: 4) : const EdgeInsets.all(8),
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(4), // Минимальные скругления
                // border: Border.all(color: Colors.grey.shade400, width: 1.5), // Более четкая рамка
              ),
              child: selectedStockItem != null
                  ? Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: warehouse name
                        Expanded(
                          child: Text(
                            selectedStockItem.warehouseName,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: widget.compact ? 13 : 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Inline stock count centered between name and price
                        if (widget.showFullInfo || widget.compact) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: widget.compact ? 6 : 8),
                            child: Text(
                              '${selectedStockItem.stock} шт.',
                              style: TextStyle(
                                fontSize: widget.compact ? 11 : 12,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                        // Right: price placeholder (kept empty here) — parent cards should show price
                        const SizedBox(width: 8),
                      ],
                    )
                  : const Text(
                      'Выберите склад',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
    );
  }
}