import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/widgets/cart_control_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/navigation_fab_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/image_carousel_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/stock_item_selector_widget.dart';
import 'package:fieldforce/shared/services/image_cache_service.dart';

/// Страница с детальной информацией о продукте
class ProductDetailPage extends StatefulWidget {
  final ProductWithStock productWithStock;

  const ProductDetailPage({
    super.key,
    required this.productWithStock,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late PageController _imagePageController;
  int _currentImageIndex = 0;
  int _lastKnownQuantity = 0; // Сохраняем последнее известное количество товара в корзине
  StockItem? _selectedStockItem; // Выбранный склад для товара

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    
    // Инициализируем последнее известное количество из текущего состояния корзины
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = context.read<CartBloc>().state;
      if (currentState is CartLoaded) {
        final orderLine = currentState.orderLines.where(
          (line) => line.productCode.toString() == widget.productWithStock.product.code.toString()
        ).firstOrNull;
        _lastKnownQuantity = orderLine?.quantity ?? 0;
      }
      
      context.read<CartBloc>().add(const LoadCartEvent());
    });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ошибка: ${state.message}')),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Детали продукта'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: _buildProductContent(context, widget.productWithStock),
          floatingActionButton: const NavigationFabWidget(
            onCartPressed: null,
            onHomePressed: null,
          ),
        ),
      );
  }

  Widget _buildProductContent(BuildContext context, ProductWithStock productWithStock) {
    final product = productWithStock.product;
    
    // Собираем все изображения для карусели
    final List<ImageData> allImages = [];
    if (product.defaultImage != null) {
      allImages.add(product.defaultImage!);
    }
    allImages.addAll(product.images);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображения продукта с возможностью листания
          GestureDetector(
            onTap: allImages.isNotEmpty
                ? () => showImageCarousel(context, allImages, initialIndex: _currentImageIndex)
                : null,
            child: Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey.shade200,
              child: allImages.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: _imagePageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: allImages.length,
                          itemBuilder: (context, index) {
                            final image = allImages[index];
                            return Container(
                              color: Colors.grey.shade200,
                              child: Hero(
                                tag: 'product_image_${image.uri}_$index',
                                child: ImageCacheService.getCachedFullImage(
                                  imageUrl: image.uri, // Используем оригинальный URL без изменений
                                  fit: BoxFit.contain,
                                  placeholder: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: Container(
                                    color: Colors.grey.shade100,
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                            size: 48,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Изображение недоступно',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Индикатор текущего изображения
                        if (allImages.length > 1)
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_currentImageIndex + 1} / ${allImages.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Индикатор кликабельности для открытия полноэкранной карусели
                        if (allImages.length > 1)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    )
                  : const Icon(
                      Icons.inventory_2,
                      color: Colors.grey,
                      size: 64,
                    ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название продукта
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // Код продукта
                Text(
                  'Код: ${product.code}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Статус остатков
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: productWithStock.stockStatusColor.color.withOpacity(0.1),
                    border: Border.all(color: productWithStock.stockStatusColor.color),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        productWithStock.stockStatusColor.icon,
                        size: 16,
                        color: productWithStock.stockStatusColor.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        productWithStock.stockStatusText,
                        style: TextStyle(
                          color: productWithStock.stockStatusColor.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Вес/упаковка
                if (product.amountInPackage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'В упаковке: ${product.amountInPackage} шт.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                
                // Селектор склада
                StockItemSelectorWidget(
                  productCode: widget.productWithStock.product.code,
                  selectedStockItem: _selectedStockItem,
                  onStockItemSelected: (stockItem) {
                    setState(() {
                      _selectedStockItem = stockItem;
                    });
                  },
                  showFullInfo: true,
                ),

                const SizedBox(height: 16),

                _selectedStockItem != null 
                  ? _buildPriceSectionFromStockItem(context, _selectedStockItem!)
                  : _buildPriceSection(context, productWithStock),

                const SizedBox(height: 24),

                if (widget.productWithStock.isAvailable) 
                  BlocBuilder<CartBloc, CartState>(
                    builder: (context, state) {
                      int currentQuantity = _lastKnownQuantity; 
                      
                      if (state is CartLoaded) {
                        final orderLine = state.orderLines.where(
                          (line) => line.productCode.toString() == product.code.toString()
                        ).firstOrNull;
                        currentQuantity = orderLine?.quantity ?? 0;
                        _lastKnownQuantity = currentQuantity;
                      }
                      
                      return CartControlWidget(
                        initialQuantity: currentQuantity,
                        amountInPackage: product.amountInPackage,
                        onAddToCart: () {
                          // Добавляем товар в корзину через CartBloc
                          context.read<CartBloc>().add(AddToCartEvent(
                            productCode: product.code.toString(),
                            quantity: 1,
                          ));
                        },
                    onQuantityChanged: (quantity) {
                      context.read<CartBloc>().add(AddToCartEvent(
                        productCode: product.code.toString(),
                        quantity: quantity,
                      ));
                    },
                        showCartIcon: false, // В деталях продукта не показываем иконку корзины
                      );
                    },
                  )
                else
                  // Показываем сообщение для недоступных товаров
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Товар недоступен для заказа',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                const Divider(),

                const SizedBox(height: 16),

                // Заголовок описания
                Text(
                  'Описание',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  product.description ?? 'Описание не указано',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                _buildInfoSection(
                  context,
                  'Характеристики',
                  [
                    'Код товара: ${product.code}',
                    if (product.vendorCode != null) 'Артикул: ${product.vendorCode}',
                    if (product.type != null) 'Тип: ${product.type!.name}',
                    if (product.brand != null) 'Бренд: ${product.brand!.name}',
                    if (product.manufacturer != null) 'Производитель: ${product.manufacturer!.name}',
                    if (product.amountInPackage != null) 'В упаковке: ${product.amountInPackage} шт.',
                    if (product.novelty) 'Новинка',
                    if (product.popular) 'Популярный товар',
                  ],
                ),

                // Характеристики продукта
                if (product.numericCharacteristics.isNotEmpty ||
                    product.stringCharacteristics.isNotEmpty ||
                    product.boolCharacteristics.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildCharacteristicsSection(context, product),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicsSection(BuildContext context, Product product) {
    final allCharacteristics = [
      ...product.numericCharacteristics,
      ...product.stringCharacteristics,
      ...product.boolCharacteristics,
    ];

    if (allCharacteristics.isEmpty) return const SizedBox.shrink();

    return _buildInfoSection(
      context,
      'Свойства',
      allCharacteristics.map((char) {
        if (char.adaptValue != null && char.adaptValue!.isNotEmpty) {
          return '${char.attributeName}: ${char.adaptValue}';
        } else if (char.value != null) {
          return '${char.attributeName}: ${char.value}';
        }
        return char.attributeName;
      }).toList(),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            item,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color.fromARGB(255, 97, 97, 97),
            ),
          ),
        )),
      ],
    );
  }

  /// Секция с ценой товара
  Widget _buildPriceSection(BuildContext context, ProductWithStock productWithStock) {
    if (!productWithStock.isAvailable) {
      return Text(
        'Товар недоступен',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.grey.shade600,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Основная цена
        Text(
          '${(productWithStock.displayPrice / 100).toStringAsFixed(2)} ₽',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green.shade700,
          ),
        ),
        
        // Диапазон цен если есть разные склады с разными ценами
        if (productWithStock.hasPriceRange)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'от ${(productWithStock.minPrice / 100).toStringAsFixed(2)} до ${(productWithStock.maxPrice / 100).toStringAsFixed(2)} ₽',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          
        // Информация о скидках
        if (productWithStock.hasDiscounts)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Доступны скидки',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
  
  /// Секция с ценой из конкретного StockItem
  Widget _buildPriceSectionFromStockItem(BuildContext context, StockItem stockItem) {
    if (stockItem.stock <= 0) {
      return Text(
        'Товар недоступен на складе "${stockItem.warehouseName}"',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: Colors.grey.shade600,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Склад
        Text(
          'Склад: ${stockItem.warehouseName}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Остаток
        Text(
          'В наличии: ${stockItem.stock} шт.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Цены
        if (stockItem.offerPrice != null) ...[
          // Зачеркнутая обычная цена
          Text(
            '${(stockItem.defaultPrice / 100).toStringAsFixed(2)} ₽',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Colors.grey.shade600,
            ),
          ),
          // Акционная цена
          Text(
            '${(stockItem.offerPrice! / 100).toStringAsFixed(2)} ₽',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
        ] else
          // Обычная цена
          Text(
            '${(stockItem.defaultPrice / 100).toStringAsFixed(2)} ₽',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
      ],
    );
  }
}