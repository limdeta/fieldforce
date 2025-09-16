import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/data/services/product_parsing_service.dart';
import 'package:fieldforce/features/shop/presentation/product_detail_page.dart';
import 'package:fieldforce/features/shop/presentation/widgets/cart_control_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/navigation_fab_widget.dart';

/// Страница списка продуктов категории
class ProductListPage extends StatefulWidget {
  final Category category;

  const ProductListPage({
    super.key,
    required this.category,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final ProductRepository _productRepository = GetIt.instance<ProductRepository>();
  final ProductParsingService _parsingService = GetIt.instance<ProductParsingService>();

  List<ProductCompactView> _products = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _currentOffset = 0;
  final int _limit = 20;
  bool _hasMoreData = true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    print('🎭 ProductListPage: Загружаем продукты для категории ${widget.category.name} (id: ${widget.category.id})');

    final result = await _productRepository.getProductsByCategoryPaginated(
      widget.category.id,
      offset: 0,
      limit: _limit,
    );

    result.fold(
      (failure) {
        print('🎭 ProductListPage: Ошибка загрузки продуктов: $failure');
        setState(() {
          _error = failure.message;
          _isLoading = false;
        });
      },
      (products) {
        print('🎭 ProductListPage: Получено ${products.length} продуктов');
        for (final product in products) {
          print('🎭 Продукт: ${product.title} (код: ${product.code})');
        }
        final compactViews = _parsingService.createCompactViews(products);
        print('🎭 ProductListPage: Создано ${compactViews.length} compact views');
        setState(() {
          _products = compactViews;
          _currentOffset = _limit;
          _hasMoreData = products.length == _limit;
          _isLoading = false;
        });
      },
    );
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMoreData) return;

    print('🎭 ProductListPage: Загружаем дополнительные продукты для категории ${widget.category.name} (offset: $_currentOffset)');

    setState(() {
      _isLoadingMore = true;
    });

    final result = await _productRepository.getProductsByCategoryPaginated(
      widget.category.id,
      offset: _currentOffset,
      limit: _limit,
    );

    result.fold(
      (failure) {
        print('🎭 ProductListPage: Ошибка загрузки дополнительных продуктов: $failure');
        setState(() {
          _error = failure.message;
          _isLoadingMore = false;
        });
      },
      (products) {
        print('🎭 ProductListPage: Получено ${products.length} дополнительных продуктов');
        final compactViews = _parsingService.createCompactViews(products);
        print('🎭 ProductListPage: Создано ${compactViews.length} дополнительных compact views');
        setState(() {
          _products.addAll(compactViews);
          _currentOffset += _limit;
          _hasMoreData = products.length == _limit;
          _isLoadingMore = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
      floatingActionButton: const NavigationFabWidget(
        onCartPressed: null, // Используем дефолтную логику
        onHomePressed: null, // Используем дефолтную логику
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Продукты не найдены',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'В этой категории пока нет товаров',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8),
        itemCount: _products.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final product = _products[index];
          return ProductCard(
            product: product,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(productId: product.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Карточка продукта для списка
class ProductCard extends StatelessWidget {
  final ProductCompactView product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  // Функция для добавления параметров размера к URL изображения
  String _getSizedImageUrl(String url, int width) {
    if (url.contains('?')) {
      return '$url&w=$width';
    } else {
      return '$url?w=$width';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Изображение продукта
                GestureDetector(
                  onTap: product.imageUrl != null ? () => _showFullScreenImage(context, product.imageUrl!, product.title) : null,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: product.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  _getSizedImageUrl(product.imageUrl!, 300),
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    // Логируем ошибку для отладки
                                    debugPrint('Ошибка загрузки изображения продукта: ${product.imageUrl}');
                                    debugPrint('Ошибка: $error');

                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                                // Индикатор кликабельности
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: const Icon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Icon(
                            Icons.inventory_2,
                            color: Colors.grey,
                            size: 32,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Информация о продукте
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Название продукта
                      Text(
                        product.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Код продукта
                      Text(
                        'Код: ${product.code}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      // Вес/упаковка
                      if (product.weight != null || product.amountInPackage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            [
                              if (product.weight != null) product.weight,
                              if (product.amountInPackage != null)
                                '${product.amountInPackage} шт.',
                            ].join(' • '),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Цена
                      Row(
                        children: [
                          if (product.hasDiscount && product.discountPrice != null)
                            Text(
                              product.formattedDiscountPrice,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else if (product.price != null)
                            Text(
                              product.formattedPrice,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else
                            Text(
                              'Цена не указана',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          if (product.hasDiscount && product.price != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Text(
                                product.formattedPrice,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Индикатор акции
                      if (product.hasPromotion)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Акция',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Контрол добавления в корзину
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: CartControlWidget(
                    initialQuantity: 0, // TODO: Получать реальное количество из корзины для каждого продукта
                    amountInPackage: product.amountInPackage,
                    onAddToCart: () {
                      // TODO: Добавить товар в корзину
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Товар добавлен в корзину')),
                      );
                    },
                    onQuantityChanged: (quantity) {
                      // TODO: Обновить количество в корзине
                      print('Количество изменено: $quantity');
                    },
                    showCartIcon: false, // В списке продуктов не показываем иконку корзины слева
                  ),
                ),
                // Стрелка вправо для перехода к товару
                const Align(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }  void _showFullScreenImage(BuildContext context, String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Изображение
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  _getSizedImageUrl(imageUrl, 600),
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Логируем ошибку для отладки
                    debugPrint('Ошибка загрузки полноэкранного изображения: $imageUrl');
                    debugPrint('Ошибка: $error');

                    return Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.broken_image,
                              color: Colors.white70,
                              size: 48,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Изображение недоступно',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Кнопка закрытия
              Positioned(
                top: 40,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 32,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
              // Название товара
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}