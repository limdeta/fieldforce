import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/data/services/product_parsing_service.dart';

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
      ),
      body: _buildBody(),
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
        padding: const EdgeInsets.all(16),
        itemCount: _products.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final product = _products[index];
          return ProductCard(
            product: product,
            onTap: () {
              // TODO: Навигация к деталям продукта
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Выбран продукт: ${product.title}'),
                  duration: const Duration(seconds: 1),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Изображение продукта
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.inventory_2,
                        color: Colors.grey,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 16),
              // Информация о продукте
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          borderRadius: BorderRadius.circular(12),
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
              // Стрелка вправо
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}