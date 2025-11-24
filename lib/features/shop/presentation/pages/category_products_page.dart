import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/app/services/warehouse_filter_service.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query_result.dart';
import 'package:fieldforce/features/shop/domain/services/product_query_builder.dart';
import 'package:fieldforce/features/shop/domain/usecases/get_category_products_usecase.dart';
import 'package:fieldforce/features/shop/domain/usecases/search_products_usecase.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_event.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_state.dart';
import 'package:fieldforce/features/shop/presentation/pages/product_detail_page.dart';
import 'package:fieldforce/features/shop/presentation/widgets/app_side_menu.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_scope.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_sheet.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_constants.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_summary_bar.dart';
import 'package:fieldforce/features/shop/presentation/widgets/product_catalog_card_widget.dart';
import 'package:fieldforce/shared/widgets/cached_network_image_widget.dart';

/// Страница списка продуктов для выбранной категории
class CategoryProductsPage extends StatefulWidget {
  final Category category;

  const CategoryProductsPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryProductsPage> createState() => _CategoryProductsPageState();
}

class _CategoryProductsPageState extends State<CategoryProductsPage> {
  static final Logger _logger = Logger('CategoryProductsPage');
  final SearchProductsUseCase _searchProductsUseCase = GetIt.instance<SearchProductsUseCase>();
  final GetCategoryProductsUseCase _getCategoryProductsUseCase =
      GetIt.instance<GetCategoryProductsUseCase>();
  final ProductQueryBuilder _productQueryBuilder = GetIt.instance<ProductQueryBuilder>();
  final WarehouseFilterService _warehouseFilterService = GetIt.instance<WarehouseFilterService>();

  final TextEditingController _searchController = TextEditingController();
    final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;
  
  List<ProductWithStock> _products = [];
  List<ProductWithStock> _searchResults = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _error;
  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;
  int _currentOffset = 0;
  final int _limit = 20;
  final int _prefetchBatchSize = 8;
  final Set<int> _prefetchedProductCodes = <int>{};
  List<int>? _allowedProductCodes;
  late ProductQuery _baseProductQuery;
  late final ValueNotifier<bool> _sideMenuOpenNotifier;

  
  // Отслеживаем выбранные StockItem для каждого продукта
  final Map<int, StockItem> _selectedStockItems = {};

  @override
  void initState() {
    super.initState();
    _baseProductQuery = _productQueryBuilder.forCategory(
      categoryId: widget.category.id,
      limit: _limit,
      allowedProductCodes: _allowedProductCodes,
    );
    _loadProducts();
    _scrollController.addListener(_onScroll);
    
    // Загружаем корзину при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartBloc>().add(const LoadCartEvent());
    });
    _sideMenuOpenNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _sideMenuOpenNotifier.dispose();
    super.dispose();
  }

  void _onAllowedProductCodesChanged(List<int>? codes) {
    if (_areCodeListsEqual(_allowedProductCodes, codes)) {
      return;
    }
    _allowedProductCodes = codes;
    if (codes == null) {
      _baseProductQuery = _baseProductQuery.copyWith(clearAllowedProductCodes: true);
    } else {
      _baseProductQuery = _baseProductQuery.copyWith(
        allowedProductCodes: List<int>.from(codes),
      );
    }
    _loadProducts();
  }

  bool _areCodeListsEqual(List<int>? a, List<int>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == null && b == null;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _toggleSideMenu(FacetFilterBloc bloc, {bool? open}) {
    final shouldOpen = open ?? !_sideMenuOpenNotifier.value;
    if (shouldOpen == _sideMenuOpenNotifier.value) {
      return;
    }
    _sideMenuOpenNotifier.value = shouldOpen;
    if (shouldOpen) {
      bloc.add(const FacetFilterSheetOpened());
      FocusScope.of(context).unfocus();
    } else {
      bloc.add(const FacetFilterEditingCancelled());
      Future.delayed(kFacetFilterFocusDelay, () {
        if (mounted) _searchFocusNode.requestFocus();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreProducts();
      }
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performProductSearch(query.trim());
    });
  }

  Future<void> _performProductSearch(String query) async {
    if (!mounted) return;
    
    setState(() {
      _isSearching = true;
      _searchResults = [];
    });
    
    _logger.info('🔍 Поиск продуктов: "$query"');
    final searchQuery = _productQueryBuilder.forSearch(
      searchText: query,
      categoryId: widget.category.id,
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

  Future<void> _loadProducts() async {
    _logger.info('🚀 _loadProducts: начинаем загрузку для категории "${widget.category.name}" (id: ${widget.category.id})');
    
    setState(() {
      _isLoading = true;
      _error = null;
      _currentOffset = 0;
      _hasMore = true;
    });

    await _loadProductsInternal(reset: true);
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    await _loadProductsInternal(reset: false);
  }

  Future<void> _loadProductsInternal({required bool reset}) async {
    _logger.info('🔄 _loadProductsInternal: categoryId=${widget.category.id}, name="${widget.category.name}", reset=$reset, offset=$_currentOffset, limit=$_limit');
    final filterResult = await _warehouseFilterService.resolveForCurrentSession();
    _logger.info('🔄 _loadProductsInternal: активный регион=${filterResult.regionCode}, warehouses=${filterResult.warehouses.length}');

    if (!filterResult.hasWarehouses) {
      setState(() {
        _isLoading = false;
        _error = 'Для региона ${filterResult.regionCode} нет доступных складов. Выполните синхронизацию данных.';
      });
      return;
    }

    if (filterResult.failure != null) {
      _logger.warning('⚠️ _loadProductsInternal: фильтр складов завершился с ошибкой: ${filterResult.failure!.message}');
    }
    
    // Используем ProductWithStock для отображения остатков
    // В соответствии с архитектурой StockItem-centered
    final pageQuery = _baseProductQuery.copyWith(
      offset: _currentOffset,
      limit: _limit,
    );

    final result = await _getCategoryProductsUseCase(pageQuery);

    if (!mounted) {
      _logger.warning('⚠️ _loadProductsInternal: компонент не смонтирован, прерываем');
      return;
    }

    if (result.isLeft()) {
      setState(() {
        _isLoading = false;
        _error = result.fold((failure) => failure.message, (_) => null);
      });
      _logger.severe('Ошибка загрузки продуктов для категории ${widget.category.id}: $_error');
      return;
    }

    final queryResult = result.getOrElse(() => ProductQueryResult<ProductWithStock>.empty(pageQuery));
    final newProducts = List<ProductWithStock>.from(queryResult.items);
    final int previousLength = _products.length;
    
    setState(() {
      _isLoading = false;
      
      if (reset) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }
      
      _hasMore = queryResult.hasMore;
      _currentOffset = queryResult.nextOffset;
      
      _logger.fine('Загружено ${newProducts.length} продуктов для категории "${widget.category.name}" (всего: ${_products.length})');
    });

    if (newProducts.isNotEmpty) {
      if (reset) {
        _prefetchedProductCodes.clear();
      }
      _schedulePrefetchForProducts(reset ? _products.take(_prefetchBatchSize).toList() : _products.sublist(previousLength));
    }
  }

  void _onProductTap(ProductWithStock productWithStock) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(productWithStock: productWithStock),
      ),
    );
  }



  /// Обработчик выбора StockItem для продукта
  void _onStockItemChanged(ProductWithStock product, StockItem stockItem) {
    _logger.info('Пользователь выбрал StockItem ${stockItem.id} для продукта ${product.product.code}');
    
    setState(() {
      _selectedStockItems[product.product.code] = stockItem;
    });
    
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text('Выбран склад: ${stockItem.warehouseName}'),
    //     duration: const Duration(seconds: 1),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return FacetFilterScope(
      categoryId: widget.category.id,
      child: Builder(
        builder: (scopedContext) {
          final facetBloc = FacetFilterScope.maybeBlocOf(scopedContext)!;
          return BlocListener<FacetFilterBloc, FacetFilterState>(
            bloc: facetBloc,
            listenWhen: (previous, current) =>
                !_areCodeListsEqual(
                  previous.allowedProductCodes,
                  current.allowedProductCodes,
                ),
            listener: (context, state) => _onAllowedProductCodesChanged(state.allowedProductCodes),
            child: Scaffold(
              appBar: MediaQuery.of(context).orientation == Orientation.portrait
                  ? AppBar(
                      title: Text(widget.category.name),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.filter_alt_outlined),
                          tooltip: 'Фильтры',
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useSafeArea: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            builder: (ctx) => BlocProvider.value(
                              value: facetBloc,
                              child: FacetFilterSheet(),
                            ),
                            ).then((_) {
                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                Future.delayed(kFacetFilterFocusDelay, () {
                                  if (mounted) _searchFocusNode.requestFocus();
                                });
                              });
                            });
                          },
                        ),
                      ],
                    )
                  : null,
              body: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      right: (MediaQuery.of(context).viewPadding.right > MediaQuery.of(context).viewPadding.left
                          ? MediaQuery.of(context).viewPadding.right + 16
                          : 0),
                      left: (MediaQuery.of(context).viewPadding.left > MediaQuery.of(context).viewPadding.right
                          ? MediaQuery.of(context).viewPadding.left + 16
                          : 0),
                    ),
                    child: _buildBody(),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _sideMenuOpenNotifier,
                    builder: (context, isOpen, _) => IgnorePointer(
                      ignoring: !isOpen,
                      child: AnimatedOpacity(
                        opacity: isOpen ? 0.32 : 0,
                        duration: isOpen ? kFacetFilterAnimationDuration : Duration.zero,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _toggleSideMenu(facetBloc, open: false),
                          child: Container(color: Colors.black54),
                        ),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: _sideMenuOpenNotifier,
                    builder: (context, isOpen, _) => AppSideMenu(
                      isOpen: isOpen,
                    onToggle: () => _toggleSideMenu(facetBloc),
                    facetBloc: facetBloc,
                    showFilters: true,
                    animationDuration: Duration.zero,
                    ),
                  ),
                  if (MediaQuery.of(context).orientation != Orientation.portrait)
                    Positioned(
                      left: 16 + MediaQuery.of(context).viewPadding.left,
                      bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
                      child: FloatingActionButton(
                        heroTag: 'facet-fab',
                        mini: true,
                        onPressed: () => _toggleSideMenu(facetBloc, open: !_sideMenuOpenNotifier.value),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.filter_alt_outlined),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);
    final bool showSearchResults = _searchController.text.trim().isNotEmpty;
    final List<ProductWithStock> displayProducts = showSearchResults ? _searchResults : _products;
    
    return Column(
      children: [
        // Поисковая строка с учётом safe area
        Container(
          color: theme.colorScheme.surface,
          padding: EdgeInsets.fromLTRB(
            12,
            (MediaQuery.of(context).orientation == Orientation.portrait ? 12 : 12 + MediaQuery.of(context).padding.top),
            12,
            8,
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Поиск по товарам',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const FacetFilterSummaryBar(),
        // Контент
        Expanded(
          child: _buildContent(displayProducts, showSearchResults),
        ),
      ],
    );
  }

  Widget _buildContent(List<ProductWithStock> displayProducts, bool showSearchResults) {
    if (_error != null && displayProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProducts,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Поиск товаров...'),
          ],
        ),
      );
    }

    if (_isLoading && displayProducts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка товаров...'),
          ],
        ),
      );
    }

    if (displayProducts.isEmpty) {
      if (showSearchResults) {
        return _buildNoSearchResultsPlaceholder();
      }
      return _buildNoProductsPlaceholder();
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            12,
            (MediaQuery.of(context).orientation == Orientation.portrait ? 12 : 12 + MediaQuery.of(context).padding.top),
            12,
            8 + MediaQuery.of(context).viewInsets.bottom,
          ),
        itemCount: displayProducts.length + (_hasMore && !showSearchResults ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == displayProducts.length) {
            // Показываем индикатор загрузки в конце списка
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final productWithStock = displayProducts[index];
          if (!showSearchResults) {
            _prefetchAheadOf(index);
          }
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ProductCatalogCardWidget(
              productWithStock: productWithStock,
              selectedStockItem: _selectedStockItems[productWithStock.product.code],
              onTap: () => _onProductTap(productWithStock),
              onStockItemChanged: (stockItem) => _onStockItemChanged(productWithStock, stockItem),
            ),
          );
        },
      ),
    );
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

  void _prefetchAheadOf(int index) {
    final nextIndex = index + 1;
    if (nextIndex >= _products.length) return;

    final end = math.min(_products.length, nextIndex + _prefetchBatchSize);
    final slice = _products.sublist(nextIndex, end);
    _schedulePrefetchForProducts(slice);
  }

  Widget _buildNoSearchResultsPlaceholder() {
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

  Widget _buildNoProductsPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Товары не найдены',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'В категории "${widget.category.name}" пока нет товаров',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}