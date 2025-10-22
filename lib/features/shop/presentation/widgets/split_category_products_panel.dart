import 'dart:async';
import 'dart:math' as math;

import 'package:fieldforce/app/services/warehouse_filter_service.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/pages/product_detail_page.dart';
import 'package:fieldforce/features/shop/presentation/state/catalog_split_state.dart';
import 'package:fieldforce/features/shop/presentation/widgets/product_catalog_card_widget.dart';
import 'package:fieldforce/shared/widgets/cached_network_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

/// Панель списка товаров для сплит-каталога.
///
/// Повторяет функциональность `CategoryProductsPage`, но работает внутри
/// сплит-экрана и переиспользует глобальное хранилище состояния.
class SplitCategoryProductsPanel extends StatefulWidget {
  final Category? category;
  final Map<int, StockItem> selectedStockItems;
  final void Function(int productCode, StockItem stockItem) onStockItemChanged;

  const SplitCategoryProductsPanel({
    super.key,
    required this.category,
    required this.selectedStockItems,
    required this.onStockItemChanged,
  });

  @override
  State<SplitCategoryProductsPanel> createState() => _SplitCategoryProductsPanelState();
}

class _SplitCategoryProductsPanelState extends State<SplitCategoryProductsPanel> {
  static final Logger _logger = Logger('SplitCategoryProductsPanel');

  final ProductRepository _productRepository = GetIt.instance<ProductRepository>();
  final WarehouseFilterService _warehouseFilterService = GetIt.instance<WarehouseFilterService>();
  final CatalogSplitStateStore _stateStore = CatalogSplitStateStore.instance;

  final ScrollController _scrollController = ScrollController();
  List<ProductWithStock> _products = <ProductWithStock>[];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  String? _error;
  final int _limit = 20;
  final int _prefetchBatchSize = 8;
  final Set<int> _prefetchedProductCodes = <int>{};
  late int? _currentCategoryId;

  @override
  void initState() {
    super.initState();
    _currentCategoryId = widget.category?.id;

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CartBloc>().add(const LoadCartEvent());
    });

    _restoreState();
  }

  @override
  void didUpdateWidget(covariant SplitCategoryProductsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final int? newCategoryId = widget.category?.id;
    if (newCategoryId != _currentCategoryId) {
      _currentCategoryId = newCategoryId;
      _prefetchedProductCodes.clear();
      _restoreState();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _restoreState() {
    final categoryId = _currentCategoryId;

    if (categoryId == null) {
      setState(() {
        _products = <ProductWithStock>[];
        _isLoading = false;
        _hasMore = false;
        _currentOffset = 0;
        _error = null;
      });
      return;
    }

    final cached = _stateStore.categoryProductsCache[categoryId];
    if (cached != null) {
      setState(() {
        _products = List<ProductWithStock>.from(cached.products);
        _hasMore = cached.hasMore;
        _currentOffset = cached.offset;
        _error = cached.error;
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final storedOffset = _stateStore.getProductScrollOffset(categoryId) ?? 0;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(storedOffset);
        }
      });
      return;
    }

    _loadProducts(reset: true);
  }

  void _onScroll() {
    final categoryId = _currentCategoryId;
    if (categoryId != null && _scrollController.hasClients) {
      _stateStore.setProductScrollOffset(categoryId, _scrollController.offset);
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadProducts(reset: false);
      }
    }
  }

  Future<void> _loadProducts({required bool reset}) async {
    final categoryId = _currentCategoryId;
    final currentCategory = widget.category;
    if (categoryId == null || currentCategory == null) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      if (reset) {
        _error = null;
        _products = <ProductWithStock>[];
        _hasMore = true;
        _currentOffset = 0;
        _stateStore.categoryProductsCache.remove(categoryId);
        _stateStore.removeProductScrollOffset(categoryId);
      }
    });

    await _loadProductsInternal(categoryId: categoryId, categoryName: currentCategory.name, reset: reset);
  }

  Future<void> _loadProductsInternal({
    required int categoryId,
    required String categoryName,
    required bool reset,
  }) async {
    _logger.info('🔄 Split: загрузка товаров для категории $categoryName ($categoryId), reset=$reset offset=$_currentOffset');

    final filterResult = await _warehouseFilterService.resolveForCurrentSession(bypassInDev: false);
    if (!filterResult.devBypass && !filterResult.hasWarehouses) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Для региона ${filterResult.regionCode} нет доступных складов. Выполните синхронизацию данных.';
      });
      _persistProductsState();
      return;
    }

    if (filterResult.failure != null) {
      _logger.warning('⚠️ Split: фильтр складов завершился с ошибкой: ${filterResult.failure!.message}');
    }

    final result = await _productRepository.getProductsWithStockByCategoryPaginated(
      categoryId,
      offset: reset ? 0 : _currentOffset,
      limit: _limit,
    );

    if (!mounted) {
      _logger.warning('⚠️ Split: компонент уже размонтирован, прерываем обработку');
      return;
    }

    if (result.isLeft()) {
      setState(() {
        _isLoading = false;
        _error = result.fold((failure) => failure.message, (_) => null);
      });
      _logger.severe('Ошибка загрузки продуктов (split) для $categoryId: $_error');
      _persistProductsState();
      return;
    }

    final newProducts = result.getOrElse(() => <ProductWithStock>[]);
    final previousLength = _products.length;

    setState(() {
      _isLoading = false;
      if (reset) {
        _products = newProducts;
        _currentOffset = newProducts.length;
      } else {
        _products.addAll(newProducts);
        _currentOffset += newProducts.length;
      }
      _hasMore = newProducts.length == _limit;
    });

    _persistProductsState();

    if (newProducts.isNotEmpty) {
      if (reset) {
        _prefetchedProductCodes.clear();
      }
      _schedulePrefetchForProducts(reset ? _products.take(_prefetchBatchSize).toList() :
          _products.sublist(previousLength));
    }
  }

  void _persistProductsState() {
    final categoryId = _currentCategoryId;
    if (categoryId == null) return;

    _stateStore.categoryProductsCache[categoryId] = CatalogSplitCategoryProductsCache(
      products: List<ProductWithStock>.from(_products),
      hasMore: _hasMore,
      offset: _currentOffset,
      error: _error,
    );
  }

  Future<void> _onRefresh() async {
    await _loadProducts(reset: true);
  }

  void _schedulePrefetchForProducts(List<ProductWithStock> products) {
    if (!_hasImagesToPrefetch(products)) return;

    Future.microtask(() async {
      if (!mounted) return;
      final toPrefetch = products.take(_prefetchBatchSize).toList(growable: false);

      await Future.wait(toPrefetch.map((product) async {
        final image = product.product.defaultImage;
        if (image == null) return;
        if (!_prefetchedProductCodes.add(product.product.code)) return;

        final rawUrl = image.uri;
        final fallbackUrl = image.getOptimalUrl();
        final resolvedUrl = rawUrl.isNotEmpty ? rawUrl : fallbackUrl;
        if (resolvedUrl.isEmpty) return;

        await CachedNetworkImageWidget.prefetchProductImage(
          context,
          imageUrl: resolvedUrl,
          webpUrl: image.webp,
          width: 48,
          height: 48,
        );
      }));
    });
  }

  bool _hasImagesToPrefetch(List<ProductWithStock> products) {
    return products.any((product) {
      final image = product.product.defaultImage;
      if (image == null) return false;
      if (_prefetchedProductCodes.contains(product.product.code)) return false;
      return image.uri.isNotEmpty || image.getOptimalUrl().isNotEmpty;
    });
  }

  void _onProductTap(ProductWithStock productWithStock) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ProductDetailPage(productWithStock: productWithStock),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.category == null) {
      return _buildEmptyCategoryPlaceholder(context);
    }

    if (_isLoading && _products.isEmpty && _error == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _products.isEmpty) {
      return _buildErrorPlaceholder(context, _error!);
    }

    if (!_isLoading && _products.isEmpty) {
      return _buildNoProductsPlaceholder(context, widget.category!);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _products.length + (_hasMore ? 1 : 0) + (_shouldShowHeader ? 1 : 0),
        itemBuilder: (context, index) {
          int adjustedIndex = index;

          if (_shouldShowHeader) {
            if (index == 0) {
              return _buildCategoryHeader(context, widget.category!);
            }
            adjustedIndex -= 1;
          }

          if (adjustedIndex == _products.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (adjustedIndex >= _products.length) {
            return const SizedBox.shrink();
          }

          final productWithStock = _products[adjustedIndex];
          _prefetchAheadOf(adjustedIndex);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductCatalogCardWidget(
              productWithStock: productWithStock,
              selectedStockItem: widget.selectedStockItems[productWithStock.product.code],
              onTap: () => _onProductTap(productWithStock),
              onStockItemChanged: (stockItem) => widget.onStockItemChanged(
                productWithStock.product.code,
                stockItem,
              ),
            ),
          );
        },
      ),
    );
  }

  bool get _shouldShowHeader => widget.category != null;

  Widget _buildCategoryHeader(BuildContext context, Category category) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          if (category.count > 0)
            Text(
              'Товаров в категории: ${category.count}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            _buildErrorBanner(context, _error!),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
          ),
          TextButton(
            onPressed: () => _loadProducts(reset: true),
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки товаров',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadProducts(reset: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoProductsPlaceholder(BuildContext context, Category category) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Товары не найдены',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'В категории "${category.name}" пока нет товаров',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCategoryPlaceholder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Выберите категорию',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Список товаров появится после выбора категории слева',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _prefetchAheadOf(int index) {
    final nextIndex = index + 1;
    if (nextIndex >= _products.length) return;

    final end = math.min(_products.length, nextIndex + _prefetchBatchSize);
    final slice = _products.sublist(nextIndex, end);
    _schedulePrefetchForProducts(slice);
  }
}
