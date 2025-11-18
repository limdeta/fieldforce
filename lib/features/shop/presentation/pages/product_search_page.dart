import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/features/shop/domain/entities/facet.dart';
import 'package:fieldforce/features/shop/domain/entities/product_query.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/services/product_query_builder.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/usecases/search_products_usecase.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_state.dart';
import 'package:fieldforce/features/shop/presentation/pages/product_detail_page.dart';
import 'package:fieldforce/features/shop/presentation/widgets/catalog_app_bar_actions.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_scope.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_summary_bar.dart';
import 'package:fieldforce/features/shop/presentation/widgets/product_catalog_card_widget.dart';
import 'package:fieldforce/shared/presentation/widgets/home_icon_button.dart';

/// Страница глобального поиска товаров по всему каталогу
class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  static final Logger _logger = Logger('ProductSearchPage');
  final SearchProductsUseCase _searchProductsUseCase =
      GetIt.instance<SearchProductsUseCase>();
  final ProductQueryBuilder _productQueryBuilder =
      GetIt.instance<ProductQueryBuilder>();

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  List<ProductWithStock> _searchResults = [];
  bool _isSearching = false;
  String? _error;
  FacetFilter _activeFacetFilter = const FacetFilter();
  bool _hasAppliedFacetFilters = false;

  // Отслеживаем выбранные StockItem для каждого продукта
  final Map<int, StockItem> _selectedStockItems = {};

  @override
  void initState() {
    super.initState();
    // Загружаем корзину при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartBloc>().add(const LoadCartEvent());
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _performProductSearch(query.trim());
    });
  }

  Future<void> _performProductSearch(String query) async {
    if (!mounted) return;

    final trimmedQuery = query.trim();
    final hasFacetFilters = _hasActiveFacetCriteria();

    if (trimmedQuery.isEmpty && !hasFacetFilters) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _error = null;
      });
      _logger.fine('Поиск очищен: нет запроса и активных фасетов');
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = [];
      _error = null;
    });

    final restrictedCodesCount =
        _activeFacetFilter.restrictedProductCodes?.length ?? 0;
    _logger.info(
      'Глобальный поиск: "$trimmedQuery" (restricted=$restrictedCodesCount, facets=${_activeFacetFilter.isEmpty ? 'none' : 'active'})',
    );

    final productQuery = _buildProductQuery(trimmedQuery);

    final result = await _searchProductsUseCase(productQuery);

    if (!mounted) return;

    result.fold(
      (failure) {
        _logger.warning('Ошибка поиска товаров: ${failure.message}');
        setState(() {
          _isSearching = false;
          _error = failure.message;
        });
      },
      (productResult) {
        _logger.info('Найдено ${productResult.items.length} товаров');

        if (!mounted) return;

        setState(() {
          _searchResults = productResult.items;
          _isSearching = false;
        });
      },
    );
  }

  void _onStockItemSelected(int productCode, StockItem stockItem) {
    setState(() {
      _selectedStockItems[productCode] = stockItem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FacetFilterScope(
      categoryId: null,
      child: Builder(
        builder: (scopeContext) {
          final facetBloc = FacetFilterScope.maybeBlocOf(scopeContext);
          return MultiBlocListener(
            listeners: [
              BlocListener<FacetFilterBloc, FacetFilterState>(
                listenWhen: (previous, current) =>
                    previous.appliedFilter != current.appliedFilter ||
                    previous.hasActiveFilters != current.hasActiveFilters,
                listener: (context, state) => _onFacetFilterUpdated(
                  state.appliedFilter,
                  state.hasActiveFilters,
                ),
              ),
            ],
            child: Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Поиск товаров',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                ),
                elevation: 0,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                actions: [
                  CatalogFilterButton(
                    categoryId: null,
                    onPressed: () => showCatalogFilters(
                      scopeContext,
                      blocOverride: facetBloc,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                    tooltip: 'Корзина',
                  ),
                  const HomeIconButton(),
                ],
              ),
              body: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Поисковая строка
        Container(
          color: theme.colorScheme.surface,
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Поиск по всему каталогу...',
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
            ),
          ),
        ),
        const FacetFilterSummaryBar(),

        // Результаты поиска
        Expanded(child: _buildSearchResults()),
      ],
    );
  }

  Widget _buildSearchResults() {
    final theme = Theme.of(context);
    final bool hasActiveFilters = _hasActiveFacetCriteria();

    // Показываем загрузку
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    // Показываем ошибку
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Ошибка поиска', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (_searchController.text.trim().isNotEmpty) {
                  _performProductSearch(_searchController.text.trim());
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    // Показываем placeholder если поиск не начат
    if (_searchController.text.trim().isEmpty && !hasActiveFilters) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Начните ввод или выберите фильтр',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Показываем пустой результат
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              hasActiveFilters
                  ? 'По фильтрам ничего не найдено'
                  : 'Ничего не найдено',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              hasActiveFilters
                  ? 'Попробуйте изменить условия фильтра'
                  : 'Попробуйте изменить запрос',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    // Показываем результаты
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Счётчик результатов
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            'Найдено: ${_searchResults.length}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Список товаров
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final productWithStock = _searchResults[index];
              final product = productWithStock.product;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ProductCatalogCardWidget(
                  productWithStock: productWithStock,
                  selectedStockItem: _selectedStockItems[product.code],
                  onStockItemChanged: (stockItem) {
                    _onStockItemSelected(product.code, stockItem);
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailPage(
                          productWithStock: productWithStock,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onFacetFilterUpdated(
    FacetFilter filter,
    bool hasActiveBadges,
  ) {
    final restrictedCodesCount =
        filter.restrictedProductCodes?.length ?? 0;
    _logger.fine(
      'Facet filter обновлён: empty=${filter.isEmpty}, onlyNovelty=${filter.onlyNovelty}, onlyPopular=${filter.onlyPopular}, badges=$hasActiveBadges, codes=$restrictedCodesCount',
    );
    setState(() {
      _activeFacetFilter = filter;
      _hasAppliedFacetFilters = hasActiveBadges;
    });
    final hasFacetCriteria = hasActiveBadges || restrictedCodesCount > 0;
    final currentQuery = _searchController.text.trim();
    if (currentQuery.isNotEmpty || hasFacetCriteria) {
      _performProductSearch(currentQuery);
    } else {
      setState(() {
        _searchResults = [];
        _error = null;
      });
      _logger.fine('Очистили результаты после снятия facet фильтра');
    }
  }

  bool _hasActiveFacetCriteria() {
    final restrictedCodes = _activeFacetFilter.restrictedProductCodes;
    final hasRestrictedCodes =
        restrictedCodes != null && restrictedCodes.isNotEmpty;
    return hasRestrictedCodes || _hasAppliedFacetFilters;
  }

  ProductQuery _buildProductQuery(String searchText) {
    final baseQuery = _productQueryBuilder.forSearch(
      searchText: searchText,
      categoryId: _activeFacetFilter.baseCategoryId,
      scopedCategoryIds: _effectiveScopedCategories(),
      allowedProductCodes: _activeFacetFilter.restrictedProductCodes,
      limit: 50,
    );

    final session = _productQueryBuilder.edit(baseQuery)
      ..setBrandIds(_activeFacetFilter.brandIds)
      ..setManufacturerIds(_activeFacetFilter.manufacturerIds)
      ..setSeriesIds(_activeFacetFilter.seriesIds)
      ..setProductTypeIds(_activeFacetFilter.typeIds)
      ..setOnlyNovelty(_activeFacetFilter.onlyNovelty)
      ..setOnlyPopular(_activeFacetFilter.onlyPopular)
      ..setScopedCategories(_effectiveScopedCategories());

    return session.build();
  }

  List<int>? _effectiveScopedCategories() {
    if (_activeFacetFilter.selectedCategoryIds.isNotEmpty) {
      return _activeFacetFilter.selectedCategoryIds;
    }
    return _activeFacetFilter.scopeCategoryIds.isEmpty
        ? null
        : _activeFacetFilter.scopeCategoryIds;
  }
}
