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

  const StockItemSelectorWidget({
    super.key,
    required this.productCode,
    required this.onStockItemSelected,
    this.selectedStockItem,
    this.showFullInfo = true,
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
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _logger.info('Загружаем товары для продукта ${widget.productCode}');
      
      final result = await _stockItemRepository.getStockItemsByProductCode(widget.productCode);
      
      result.fold(
        (failure) {
          _logger.warning('Ошибка загрузки товаров: $failure');
          setState(() {
            _errorMessage = 'Ошибка загрузки складских остатков';
            _isLoading = false;
          });
        },
        (stockItems) {
          _logger.info('Загружено ${stockItems.length} товаров для продукта ${widget.productCode}');
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: hasMultipleStockItems
        ? Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4), // Минимальные скругления
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4), // Минимальные скругления
                border: Border.all(color: Colors.grey.shade300, width: 1.5), // Более четкая рамка
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
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: Colors.grey.shade600,
            ),
            dropdownColor: Colors.white, // Белый фон выпадающего списка
            borderRadius: BorderRadius.circular(4), // Минимальные скругления для меню
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            items: _stockItems.map((stockItem) {
              return DropdownMenuItem<StockItem>(
                value: stockItem,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          if (widget.selectedStockItem?.id == stockItem.id) ...[
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: AppColors.slate800,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              stockItem.warehouseName,
                              style: TextStyle(
                                fontWeight: widget.selectedStockItem?.id == stockItem.id
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                                color: widget.selectedStockItem?.id == stockItem.id
                                  ? AppColors.slate800 
                                  : Colors.black,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (widget.showFullInfo) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Остаток: ${stockItem.stock} шт.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              stockItem.offerPrice != null
                                ? '${_formatPrice(stockItem.offerPrice!)} ₽'
                                : '${_formatPrice(stockItem.defaultPrice)} ₽',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: stockItem.offerPrice != null 
                                  ? const Color.fromARGB(255, 54, 48, 48) 
                                  : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(4), // Минимальные скругления
                // border: Border.all(color: Colors.grey.shade400, width: 1.5), // Более четкая рамка
              ),
              child: selectedStockItem != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedStockItem.warehouseName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      if (widget.showFullInfo) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Остаток: ${selectedStockItem.stock} шт.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                              ),
                            ),
                            // Text(
                            //   selectedStockItem.offerPrice != null
                            //     ? '${_formatPrice(selectedStockItem.offerPrice!)} ₽'
                            //     : '${_formatPrice(selectedStockItem.defaultPrice)} ₽',
                            //   style: TextStyle(
                            //     fontSize: 12,
                            //     fontWeight: FontWeight.w500,
                            //     color: selectedStockItem.offerPrice != null 
                            //       ? Colors.red 
                            //       : Colors.grey.shade700,
                            //   ),
                            // ),
                          ],
                        ),
                      ],
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