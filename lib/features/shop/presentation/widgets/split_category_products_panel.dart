import 'dart:async';
import 'dart:math' as math;

import 'package:fieldforce/app/services/warehouse_filter_service.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query_result.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/services/product_query_builder.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_category_products_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/search_products_usecase.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/pages/product_detail_page.dart';
import 'package:fieldforce/features/shop/presentation/state/catalog_split_state.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_summary_bar.dart';
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
  final bool isVertical; // Для определения safe area padding
  final bool isTopPanel; // Для определения, применять ли top padding
  final List<int>? allowedProductCodes;

  const SplitCategoryProductsPanel({
    super.key,
    required this.category,
    required this.selectedStockItems,
    required this.onStockItemChanged,
    this.isVertical = true,
    this.isTopPanel = true,
    this.allowedProductCodes,
  });

  @override
  State<SplitCategoryProductsPanel> createState() => _SplitCategoryProductsPanelState();
}

class _SplitCategoryProductsPanelState extends State<SplitCategoryProductsPanel> {
  static final Logger _logger = Logger('SplitCategoryProductsPanel');

  final SearchProductsUseCase _searchProductsUseCase = GetIt.instance<SearchProductsUseCase>();
  final GetCategoryProductsUseCase _getCategoryProductsUseCase =
      GetIt.instance<GetCategoryProductsUseCase>();
  final ProductQueryBuilder _productQueryBuilder = GetIt.instance<ProductQueryBuilder>();
  final WarehouseFilterService _warehouseFilterService = GetIt.instance<WarehouseFilterService>();
  final CatalogSplitStateStore _stateStore = CatalogSplitStateStore.instance;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _productSearchController = TextEditingController();
  Timer? _searchDebounce;
  
  List<ProductWithStock> _products = <ProductWithStock>[];
  List<ProductWithStock> _searchResults = <ProductWithStock>[];
  bool _isLoading = false;
  bool _isSearching = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  String? _error;
  final int _limit = 20;
  final int _prefetchBatchSize = 15; // Увеличено с 8 до 15 для упреждающей загрузки
  final Set<int> _prefetchedProductCodes = <int>{};
  late int? _currentCategoryId;
  List<int>? _allowedProductCodes;
  ProductQuery? _baseProductQuery;

  @override
  void initState() {
    super.initState();
    _currentCategoryId = widget.category?.id;
    _allowedProductCodes = widget.allowedProductCodes;
    _rebuildBaseQuery();

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
      _rebuildBaseQuery();
      _restoreState();
      return;
    }

    if (!_areCodeListsEqual(widget.allowedProductCodes, _allowedProductCodes)) {
      _allowedProductCodes = widget.allowedProductCodes;
      _rebuildBaseQuery();
      if (_currentCategoryId != null) {
        _stateStore.categoryProductsCache.remove(_currentCategoryId);
        _stateStore.removeProductScrollOffset(_currentCategoryId!);
      }
      _loadProducts(reset: true);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _productSearchController.dispose();
    super.dispose();
  }

  void _restoreState() {
    final categoryId = _currentCategoryId;

    if (categoryId == null) {
      _baseProductQuery = null;
      setState(() {
        _products = <ProductWithStock>[];
        _isLoading = false;
        _hasMore = false;
        _currentOffset = 0;
        _error = null;
      });
      return;
    }

    _rebuildBaseQuery();

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

  void _rebuildBaseQuery() {
    final categoryId = _currentCategoryId;
    if (categoryId == null) {
      _baseProductQuery = null;
      return;
    }

    _baseProductQuery = _productQueryBuilder.forCategory(
      categoryId: categoryId,
      limit: _limit,
      allowedProductCodes: _allowedProductCodes == null
          ? null
          : List<int>.from(_allowedProductCodes!),
    );
  }

  void _onScroll() {
    final categoryId = _currentCategoryId;
    if (categoryId != null && _scrollController.hasClients) {
      _stateStore.setProductScrollOffset(categoryId, _scrollController.offset);
    }

    // Начинаем загрузку за 500px до конца для более агрессивного prefetch
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (!_isLoading && _hasMore) {
        _loadProducts(reset: false);
      }
    }
  }

  void _onProductSearchChanged(String query) {
    // Отменяем предыдущий debounce
    _searchDebounce?.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = <ProductWithStock>[];
        _isSearching = false;
      });
      return;
    }
    
    // Debounce на 500ms (люди печатают медленно)
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performProductSearch(query.trim());
    });
  }

  Future<void> _performProductSearch(String query) async {
    if (!mounted) return;
    
    setState(() {
      _isSearching = true;
      _searchResults = <ProductWithStock>[];
    });
    
    _logger.info('🔍 Поиск продуктов: "$query"');
    final searchQuery = _productQueryBuilder.forSearch(
      searchText: query,
      categoryId: widget.category?.id,
      allowedProductCodes: _allowedProductCodes,
      limit: 50,
    );

    final result = await _searchProductsUseCase(searchQuery);
    
    if (!mounted) return;
    
    result.fold(
      (failure) {
        _logger.warning('⚠️ Ошибка поиска продуктов: ${failure.message}');
        setState(() {
          _isSearching = false;
        });
      },
      (productsResult) {
        _logger.info('✅ Найдено ${productsResult.items.length} продуктов');

        if (!mounted) return;

        setState(() {
          _searchResults = productsResult.items;
          _isSearching = false;
        });
      },
    );
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

    _baseProductQuery ??= _productQueryBuilder.forCategory(
      categoryId: categoryId,
      limit: _limit,
      allowedProductCodes: _allowedProductCodes,
    );

    final baseQuery = _baseProductQuery;
    if (baseQuery == null) {
      setState(() {
        _isLoading = false;
        _error = 'Категория не выбрана';
      });
      return;
    }

    final pageQuery = baseQuery.copyWith(
      offset: reset ? 0 : _currentOffset,
      limit: _limit,
    );

    final result = await _getCategoryProductsUseCase(pageQuery);

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

    final queryResult = result.getOrElse(() => ProductQueryResult<ProductWithStock>.empty(pageQuery));
    final newProducts = List<ProductWithStock>.from(queryResult.items);
    final previousLength = _products.length;

    setState(() {
      _isLoading = false;
      if (reset) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }
      _currentOffset = queryResult.nextOffset;
      _hasMore = queryResult.hasMore;
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
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    // Отступы для безопасной зоны - только для верхней панели в вертикальном режиме
    final topPadding = (widget.isVertical && widget.isTopPanel) ? mediaQuery.padding.top : 0.0;
    final bottomPadding = widget.isVertical ? 0.0 : mediaQuery.padding.bottom;
    
    // Определяем какой список показывать
    final bool showSearchResults = _productSearchController.text.trim().isNotEmpty;
    final List<ProductWithStock> displayProducts = showSearchResults ? _searchResults : _products;
    
    return Column(
      children: [
        // Компактная поисковая строка для продуктов с учётом safe area
        Container(
          color: theme.colorScheme.surface,
          padding: EdgeInsets.fromLTRB(
            8,
            6 + topPadding, // Добавляем отступ сверху в вертикальном режиме
            8,
            6,
          ),
          child: TextField(
            controller: _productSearchController,
            onChanged: _onProductSearchChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Поиск товаров',
              hintStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 20),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
              suffixIcon: _productSearchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _productSearchController.clear();
                        _onProductSearchChanged('');
                      },
                      icon: const Icon(Icons.clear, size: 18),
                      iconSize: 18,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: const UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
          ),
        ),
        const FacetFilterSummaryBar(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        // Контент
        Expanded(
          child: _buildContent(context, displayProducts, showSearchResults, bottomPadding),
        ),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context, 
    List<ProductWithStock> displayProducts, 
    bool showSearchResults,
    double bottomPadding,
  ) {
    if (widget.category == null && !showSearchResults) {
      return _buildEmptyCategoryPlaceholder(context);
    }

    if (_isLoading && displayProducts.isEmpty && _error == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && displayProducts.isEmpty) {
      return _buildErrorPlaceholder(context, _error!);
    }

    if (!_isLoading && !_isSearching && displayProducts.isEmpty) {
      if (showSearchResults) {
        return _buildNoSearchResultsPlaceholder(context);
      }
      return _buildNoProductsPlaceholder(context, widget.category!);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
          4,
          6,
          4,
          6 + bottomPadding, // Добавляем отступ снизу в горизонтальном режиме
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: displayProducts.length + (_hasMore && !showSearchResults ? 1 : 0) + (_shouldShowHeader && !showSearchResults ? 1 : 0),
        itemBuilder: (context, index) {
          int adjustedIndex = index;

          if (_shouldShowHeader && !showSearchResults) {
            if (index == 0) {
              return _buildCategoryHeader(context, widget.category!);
            }
            adjustedIndex -= 1;
          }

          if (adjustedIndex == displayProducts.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (adjustedIndex >= displayProducts.length) {
            return const SizedBox.shrink();
          }

          final productWithStock = displayProducts[adjustedIndex];
          if (!showSearchResults) {
            _prefetchAheadOf(adjustedIndex);
          }

          return ProductCatalogCardWidget(
            productWithStock: productWithStock,
            selectedStockItem: widget.selectedStockItems[productWithStock.product.code],
            onTap: () => _onProductTap(productWithStock),
            onStockItemChanged: (stockItem) => widget.onStockItemChanged(
              productWithStock.product.code,
              stockItem,
            ),
            compact: true, // Компактный режим для сплит-экрана
          );
        },
      ),
    );
  }

  Widget _buildNoSearchResultsPlaceholder(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Ничего не найдено',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить поисковый запрос',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool get _shouldShowHeader => widget.category != null;

  Widget _buildCategoryHeader(BuildContext context, Category category) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          if (category.count > 0 || _filteredProductCount != null)
            Text(
              _buildCountLabel(category, _filteredProductCount),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          if (_error != null) ...[
            const SizedBox(height: 6),
            _buildErrorBanner(context, _error!),
          ],
        ],
      ),
    );
  }

  String _buildCountLabel(Category category, int? filteredCount) {
    if (filteredCount == null) {
      return 'Товаров: ${category.count}';
    }

    final totalSuffix = category.count > 0 ? ' из ${category.count}' : '';
    return 'Товаров: $filteredCount$totalSuffix';
  }

  int? get _filteredProductCount => _allowedProductCodes?.length;

  Widget _buildErrorBanner(BuildContext context, String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            size: 18,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
          ),
          TextButton(
            onPressed: () => _loadProducts(reset: true),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: const Size(0, 28),
            ),
            child: const Text('Повторить', style: TextStyle(fontSize: 12)),
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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

  bool _areCodeListsEqual(List<int>? a, List<int>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
