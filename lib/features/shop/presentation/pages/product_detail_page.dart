import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/widgets/cart_control_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/image_carousel_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/stock_item_selector_widget.dart';
import 'package:fieldforce/features/shop/presentation/helpers/price_color_helper.dart';
import 'package:fieldforce/shared/services/image_cache_service.dart';
import 'package:fieldforce/shared/presentation/widgets/home_icon_button.dart';

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
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              // Кнопка корзины
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                tooltip: 'Корзина',
              ),
              // Кнопка домой (скрывается автоматически если уже на домашней странице)
              const HomeIconButton(),
            ],
          ),
          body: _buildProductContent(context, widget.productWithStock),
        ),
      );
  }

  Widget _buildProductContent(BuildContext context, ProductWithStock productWithStock) {
    final product = productWithStock.product;
    
    // Собираем все изображения для карусели (без дублирования)
    final List<ImageData> allImages = [];
    
    // Добавляем defaultImage первым, если он есть
    if (product.defaultImage != null) {
      allImages.add(product.defaultImage!);
    }
    
    // Добавляем остальные изображения, исключая дубликат defaultImage
    for (final image in product.images) {
      // Проверяем, не является ли это изображение тем же самым, что и defaultImage
      final isDuplicate = product.defaultImage != null && 
          image.getOptimalUrl() == product.defaultImage!.getOptimalUrl();
      
      if (!isDuplicate) {
        allImages.add(image);
      }
    }

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
                                tag: 'product_image_${image.getOptimalUrl()}_$index',
                                child: ImageCacheService.getCachedFullImage(
                                  imageUrl: image.getOptimalUrl(), // Используем оптимальный URL (WebP если доступен)
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

          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                _buildHeroSection(context, product, productWithStock),
                const SizedBox(height: 28),
                _buildActionSection(context, productWithStock),
                const SizedBox(height: 28),
                _buildDescriptionSection(context, product),
                const SizedBox(height: 24),
                _buildFactsSection(context, product),
                if (product.numericCharacteristics.isNotEmpty ||
                    product.stringCharacteristics.isNotEmpty ||
                    product.boolCharacteristics.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  _buildCharacteristicsSection(context, product),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    Product product,
    ProductWithStock productWithStock,
  ) {
    final theme = Theme.of(context);

    return _buildMagazineSection(
      context: context,
      backgroundColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.35),
      accentColor: theme.colorScheme.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                'КОД: ${product.code}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              if (product.vendorCode != null)
                Text(
                  'АРТИКУЛ: ${product.vendorCode}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
            ],
          ),
          if (productWithStock.totalStock > 0) ...[
            const SizedBox(height: 18),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  productWithStock.stockStatusColor.icon,
                  size: 18,
                  color: productWithStock.stockStatusColor.color,
                ),
                const SizedBox(width: 8),
                Text(
                  productWithStock.stockStatusText.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    letterSpacing: 0.8,
                    color: productWithStock.stockStatusColor.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          if (product.amountInPackage != null) ...[
            const SizedBox(height: 16),
            Text(
              'Упаковка: ${product.amountInPackage} шт.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionSection(BuildContext context, ProductWithStock productWithStock) {
    final theme = Theme.of(context);

    return _buildMagazineSection(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StockItemSelectorWidget(
            productCode: productWithStock.product.code,
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
          const SizedBox(height: 20),
          if (_selectedStockItem != null && _selectedStockItem!.stock > 0)
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                int currentQuantity = _lastKnownQuantity;

                if (state is CartLoaded) {
                  final orderLine = state.orderLines.where(
                    (line) =>
                        line.productCode.toString() == productWithStock.product.code.toString(),
                  ).firstOrNull;
                  currentQuantity = orderLine?.quantity ?? 0;
                  _lastKnownQuantity = currentQuantity;
                }

                return Align(
                  alignment: Alignment.centerLeft,
                  child: CartControlWidget(
                    initialQuantity: currentQuantity,
                    amountInPackage: productWithStock.product.amountInPackage,
                    onAddToCart: () {
                      context.read<CartBloc>().add(
                            AddToCartEvent(
                              productCode: productWithStock.product.code.toString(),
                              quantity: 1,
                            ),
                          );
                    },
                    onQuantityChanged: (quantity) {
                      context.read<CartBloc>().add(
                            AddToCartEvent(
                              productCode: productWithStock.product.code.toString(),
                              quantity: quantity,
                            ),
                          );
                    },
                    showCartIcon: false,
                  ),
                );
              },
            )
          else if (_selectedStockItem != null && _selectedStockItem!.stock == 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, color: theme.hintColor),
                  const SizedBox(width: 8),
                  Text(
                    'Нет на выбранном складе',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, Product product) {
    final theme = Theme.of(context);

    return _buildMagazineSection(
      context: context,
      backgroundColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(context, 'Описание'),
          const SizedBox(height: 12),
          Text(
            product.description ?? 'Описание не указано',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactsSection(BuildContext context, Product product) {
    final theme = Theme.of(context);
    final facts = <MapEntry<String, String>>[
      MapEntry('Код товара', product.code.toString()),
      if (product.type != null) MapEntry('Тип', product.type!.name),
      if (product.brand != null) MapEntry('Бренд', product.brand!.name),
      if (product.manufacturer != null)
        MapEntry('Производитель', product.manufacturer!.name),
      if (product.amountInPackage != null)
        MapEntry('В упаковке', '${product.amountInPackage} шт.'),
      if (product.novelty) MapEntry('Статус', 'Новинка коллекции'),
      if (product.popular) MapEntry('Популярность', 'Хит продаж'),
    ];

    return _buildMagazineSection(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(context, 'Основные факты'),
          const SizedBox(height: 12),
          ...facts.map(
            (fact) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      fact.key.toUpperCase(),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fact.value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
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
    return _buildMagazineSection(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(context, 'Свойства и детали'),
          const SizedBox(height: 16),
          ...allCharacteristics.map((char) {
            final String value = char.adaptValue?.isNotEmpty == true
                ? char.adaptValue!
                : (char.value?.toString() ?? '—');
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      char.attributeName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.titleMedium?.copyWith(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildMagazineSection({
    required BuildContext context,
    required Widget child,
    Color? backgroundColor,
    Color? accentColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surface,
        border: accentColor == null
            ? null
            : Border(left: BorderSide(color: accentColor, width: 4)),
      ),
      child: child,
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
              color: PriceColorHelper.getPriceColor(stockItem),
            ),
          ),
        ] else
          // Обычная цена
          Text(
            '${(stockItem.defaultPrice / 100).toStringAsFixed(2)} ₽',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: PriceColorHelper.getPriceColor(stockItem),
            ),
          ),
      ],
    );
  }
}