import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import 'package:fieldforce/app/services/category_tree_cache_service.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/presentation/state/catalog_split_state.dart';
import 'package:fieldforce/features/shop/presentation/widgets/split_category_products_panel.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_event.dart';
import 'package:fieldforce/features/shop/presentation/bloc/facet_filter_state.dart';
import 'package:fieldforce/features/shop/presentation/widgets/app_side_menu.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_scope.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_sheet.dart';
import 'package:fieldforce/features/shop/presentation/widgets/facet_filter_constants.dart';

/// Альтернативная страница каталога в формате сплит-экрана.
class ProductCatalogSplitPage extends StatefulWidget {
  const ProductCatalogSplitPage({super.key});

  @override
  State<ProductCatalogSplitPage> createState() => _ProductCatalogSplitPageState();
}


class _ProductCatalogSplitPageState extends State<ProductCatalogSplitPage> {
  static final Logger _logger = Logger('ProductCatalogSplitPage');

  final CategoryTreeCacheService _categoryTreeCacheService =
      GetIt.instance<CategoryTreeCacheService>();
  final CatalogSplitStateStore _stateStore = CatalogSplitStateStore.instance;
  List<int>? _activeFacetProductCodes;
  late final ValueNotifier<bool> _sideMenuOpenNotifier;

  late double _horizontalSplitRatio;
  late double _verticalSplitRatio;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _categorySearchFocusNode = FocusNode();
  final FocusNode _productsSearchFocusNode = FocusNode();
  String _lastFocusedSearch = 'category';
  late final ScrollController _categoryScrollController;

  List<Category> _categories = <Category>[];
  List<Category> _filteredCategories = <Category>[];
  Map<int, Category> _categoryIndex = <int, Category>{};
  Map<int, int?> _categoryParentIndex = <int, int?>{};
  Set<int> _expandedCategoryIds = <int>{};
  int? _selectedCategoryId;

  bool _isLoadingCategories = true;
  String? _categoriesError;

  final Map<int, StockItem> _selectedStockItems = <int, StockItem>{};
  
  // Состояния для анимации нажатия разделителей
  bool _isHorizontalDividerPressed = false;
  bool _isVerticalDividerPressed = false;

  @override
  void initState() {
    super.initState();

    _horizontalSplitRatio = _stateStore.horizontalSplitRatio;
    _verticalSplitRatio = _stateStore.verticalSplitRatio;
    _expandedCategoryIds = Set<int>.from(_stateStore.expandedCategoryIds);
    _selectedCategoryId = _stateStore.selectedCategoryId;
    _selectedStockItems.addAll(_stateStore.selectedStockItems);
    _searchController.text = _stateStore.searchQuery;
    _categorySearchFocusNode.addListener(() {
      if (_categorySearchFocusNode.hasFocus) _lastFocusedSearch = 'category';
    });
    _productsSearchFocusNode.addListener(() {
      if (_productsSearchFocusNode.hasFocus) _lastFocusedSearch = 'products';
    });

    _categoryScrollController = ScrollController(
      initialScrollOffset: _stateStore.categoryPanelScrollOffset,
    )..addListener(_onCategoryScroll);

    _loadCategories();
    _sideMenuOpenNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _stateStore.horizontalSplitRatio = _horizontalSplitRatio;
    _stateStore.verticalSplitRatio = _verticalSplitRatio;
    _stateStore.expandedCategoryIds = Set<int>.from(_expandedCategoryIds);
    _stateStore.selectedCategoryId = _selectedCategoryId;
    _stateStore.searchQuery = _searchController.text;
    _stateStore.selectedStockItems = Map<int, StockItem>.from(_selectedStockItems);
    _stateStore.categoryPanelScrollOffset =
        _categoryScrollController.hasClients ? _categoryScrollController.offset : 0;

    _categoryScrollController.removeListener(_onCategoryScroll);
    _categoryScrollController.dispose();
    _searchController.dispose();
    _sideMenuOpenNotifier.dispose();
    _categorySearchFocusNode.dispose();
    _productsSearchFocusNode.dispose();
    super.dispose();
  }

  void _onFacetCodesChanged(List<int>? codes) {
    if (_areCodeListsEqual(_activeFacetProductCodes, codes)) {
      return;
    }
    setState(() {
      _activeFacetProductCodes = codes;
    });
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
        if (!mounted) return;
        if (_lastFocusedSearch == 'products') {
          _productsSearchFocusNode.requestFocus();
        } else {
          _categorySearchFocusNode.requestFocus();
        }
      });
    }
  }

  void _onCategoryScroll() {
    if (_categoryScrollController.hasClients) {
      _stateStore.categoryPanelScrollOffset = _categoryScrollController.offset;
    }
  }

  Future<void> _loadCategories({bool forceRefresh = false}) async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    final result = await _categoryTreeCacheService.getTreeForCurrentRegion(
      forceRefresh: forceRefresh,
    );

    if (!mounted) return;

    if (result.isLeft()) {
      setState(() {
        _isLoadingCategories = false;
        _categoriesError = result.fold((failure) => failure.message, (_) => null);
        _categories = <Category>[];
        _filteredCategories = <Category>[];
      });
      return;
    }

    final categories = result.getOrElse(() => <Category>[]);
  _logger.fine('Split catalog: загружено ${categories.length} корневых категорий');
    final indexData = _buildCategoryIndex(categories);
    final parentData = _buildParentIndex(categories);

  _stateStore.categoryProductsCache
    .removeWhere((key, _) => !indexData.containsKey(key));
  _stateStore.pruneProductScrollOffsets(indexData.keys.toSet());

    final normalizedExpanded =
        _expandedCategoryIds.where((id) => indexData.containsKey(id)).toSet();

    int? selectedId = _selectedCategoryId;
    if (selectedId == null || !indexData.containsKey(selectedId)) {
      selectedId = _pickDefaultCategory(categories)?.id;
    }

    if (selectedId != null) {
      normalizedExpanded.addAll(_collectAncestorIds(selectedId, parentData));
    }

    setState(() {
      _isLoadingCategories = false;
      _categories = categories;
      _categoryIndex = indexData;
      _categoryParentIndex = parentData;
      _expandedCategoryIds = normalizedExpanded;
      _selectedCategoryId = selectedId;
    });

    _applySearchFilter();
  }

  Map<int, Category> _buildCategoryIndex(List<Category> categories) {
    final map = <int, Category>{};

    void visit(Category category) {
      map[category.id] = category;
      for (final child in category.children) {
        visit(child);
      }
    }

    for (final category in categories) {
      visit(category);
    }

    return map;
  }

  Map<int, int?> _buildParentIndex(List<Category> categories) {
    final map = <int, int?>{};

    void visit(Category category, int? parentId) {
      map[category.id] = parentId;
      for (final child in category.children) {
        visit(child, category.id);
      }
    }

    for (final category in categories) {
      visit(category, null);
    }

    return map;
  }

  Set<int> _collectAncestorIds(int categoryId, Map<int, int?> parentIndex) {
    final ancestors = <int>{};
    int? current = parentIndex[categoryId];
    while (current != null) {
      ancestors.add(current);
      current = parentIndex[current];
    }
    return ancestors;
  }

  Category? _pickDefaultCategory(List<Category> categories) {
    for (final category in categories) {
      if (category.count > 0) return category;
      final candidate = _pickDefaultCategory(category.children);
      if (candidate != null) return candidate;
    }
    return categories.isNotEmpty ? categories.first : null;
  }

  void _applySearchFilter() {
    final query = _searchController.text.trim().toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _categories;
        // Сбрасываем раскрытие категорий при очистке поиска
        _expandedCategoryIds.clear();
        _stateStore.expandedCategoryIds = Set<int>.from(_expandedCategoryIds);
      } else {
        _filteredCategories = _filterCategories(_categories, query);
        // Автоматически раскрываем все найденные категории
        _expandFilteredCategories(_filteredCategories);
        _stateStore.expandedCategoryIds = Set<int>.from(_expandedCategoryIds);
      }
    });
  }

  /// Собирает ID всех категорий из отфильтрованного дерева для авто-раскрытия
  void _expandFilteredCategories(List<Category> categories) {
    _expandedCategoryIds.clear();
    
    void collectIds(Category category) {
      if (category.children.isNotEmpty) {
        _expandedCategoryIds.add(category.id);
        for (final child in category.children) {
          collectIds(child);
        }
      }
    }
    
    for (final category in categories) {
      collectIds(category);
    }
  }

  List<Category> _filterCategories(List<Category> categories, String query) {
    // Находим все категории, которые совпадают с поиском
    final matchedCategories = _categoryIndex.values
        .where((cat) => cat.name.toLowerCase().contains(query))
        .toList();

    if (matchedCategories.isEmpty) {
      return [];
    }

    // Собираем ID всех категорий, которые нужно показать
    // (найденные + все их предки для построения путей)
    final categoriesToShow = <int>{};
    
    for (final matched in matchedCategories) {
      categoriesToShow.add(matched.id);
      
      // Добавляем всех предков используя nested set model
      // Предок: lft < matched.lft AND rgt > matched.rgt
      for (final candidate in _categoryIndex.values) {
        if (candidate.lft < matched.lft && candidate.rgt > matched.rgt) {
          categoriesToShow.add(candidate.id);
        }
      }
    }

    // Рекурсивно строим дерево, оставляя только нужные категории
    Category? filterRecursive(Category category) {
      if (!categoriesToShow.contains(category.id)) {
        return null;
      }

      // Фильтруем детей - оставляем только те, что в нашем наборе
      final filteredChildren = category.children
          .map((child) => filterRecursive(child))
          .where((child) => child != null)
          .cast<Category>()
          .toList();

      return Category(
        id: category.id,
        name: category.name,
        lft: category.lft,
        lvl: category.lvl,
        rgt: category.rgt,
        description: category.description,
        query: category.query,
        count: category.count,
        children: filteredChildren,
      );
    }

    return categories
        .map((category) => filterRecursive(category))
        .where((category) => category != null)
        .cast<Category>()
        .toList();
  }

  Category? get _selectedCategory =>
      _selectedCategoryId != null ? _categoryIndex[_selectedCategoryId!] : null;

  void _onSearchChanged(String value) {
    _stateStore.searchQuery = value;
    _applySearchFilter();
  }

  void _toggleCategoryExpansion(int categoryId) {
    setState(() {
      if (_expandedCategoryIds.contains(categoryId)) {
        _expandedCategoryIds.remove(categoryId);
      } else {
        _expandedCategoryIds.add(categoryId);
      }
    });
    _stateStore.expandedCategoryIds = Set<int>.from(_expandedCategoryIds);
  }

  void _selectCategory(Category category) {
    if (_selectedCategoryId == category.id) return;

    setState(() {
      _selectedCategoryId = category.id;
      _expandedCategoryIds.addAll(_collectAncestorIds(category.id, _categoryParentIndex));
    });

    _stateStore.selectedCategoryId = category.id;
    _stateStore.expandedCategoryIds = Set<int>.from(_expandedCategoryIds);
  }

  void _handleStockItemChange(int productCode, StockItem stockItem) {
    setState(() {
      _selectedStockItems[productCode] = stockItem;
    });
    _stateStore.selectedStockItems = Map<int, StockItem>.from(_selectedStockItems);
  }

  @override
  Widget build(BuildContext context) {
    return FacetFilterScope(
      categoryId: _selectedCategoryId,
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
            listener: (context, state) => _onFacetCodesChanged(
              state.allowedProductCodes,
            ),
            child: Scaffold(
              appBar: MediaQuery.of(context).orientation == Orientation.portrait
                  ? AppBar(
                      title: const Text('Каталог'),
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
                              Future.delayed(kFacetFilterFocusDelay, () {
                                if (!mounted) return;
                                if (_lastFocusedSearch == 'products') {
                                  _productsSearchFocusNode.requestFocus();
                                } else {
                                  _categorySearchFocusNode.requestFocus();
                                }
                              });
                            });
                          },
                        ),
                      ],
                    )
                  : null,
              body: Stack(
                  children: [
                    // Основной контент без AppBar
                    Padding(
                      padding: EdgeInsets.only(
                        right: (MediaQuery.of(context).viewPadding.right > MediaQuery.of(context).viewPadding.left ? MediaQuery.of(context).viewPadding.right + 32 : 0),
                        left: (MediaQuery.of(context).viewPadding.left > MediaQuery.of(context).viewPadding.right ? MediaQuery.of(context).viewPadding.left + 32 : 0),
                      ),
                      child: LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final mediaQuery = MediaQuery.of(context);
                        final height = constraints.maxHeight.isFinite
                            ? constraints.maxHeight
                            : mediaQuery.size.height;
                        final isPortrait = mediaQuery.orientation == Orientation.portrait;
                        final bool useVerticalLayout =
                            isPortrait || width < _compactWidthBreakpoint;

                        if (width <= 0) {
                          return const SizedBox.shrink();
                        }

                        if (useVerticalLayout) {
                          final topFlex =
                              (_verticalSplitRatio.clamp(_minSplitRatio, _maxSplitRatio) * 1000)
                                  .round();
                          final bottomFlex = 1000 - topFlex;

                          return Column(
                            children: [
                              Expanded(
                                flex: topFlex,
                                child: _buildCategoryPanel(
                                  context,
                                  isVertical: true,
                                  isTopPanel: true,
                                ),
                              ),
                              _buildVerticalDivider(height),
                              Expanded(
                                flex: bottomFlex,
                                child: _buildProductsPanel(
                                  isVertical: true,
                                  isTopPanel: false,
                                ),
                              ),
                            ],
                          );
                        }

                        final leftFlex =
                            (_horizontalSplitRatio.clamp(_minSplitRatio, _maxSplitRatio) * 1000)
                                .round();
                        final rightFlex = 1000 - leftFlex;

                        return Row(
                          children: [
                            Expanded(
                              flex: leftFlex,
                              child: _buildCategoryPanel(
                                context,
                                isVertical: false,
                                isTopPanel: true,
                              ),
                            ),
                            _buildHorizontalDivider(width),
                            Expanded(
                              flex: rightFlex,
                              child: _buildProductsPanel(
                                isVertical: false,
                                isTopPanel: true,
                              ),
                            ),
                          ],
                        );
                      },
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _sideMenuOpenNotifier,
                      builder: (context, isOpen, _) {
                        return IgnorePointer(
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
                        );
                      },
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _sideMenuOpenNotifier,
                      builder: (context, isOpen, _) {
                        return AppSideMenu(
                          isOpen: isOpen,
                          onToggle: () => _toggleSideMenu(facetBloc),
                          facetBloc: facetBloc,
                          showFilters: true,
                          horizontalGap: 48.0,
                          animationDuration: Duration.zero,
                        );
                      },
                    ),
                    // FAB in landscape mode to open/close facets
                    if (MediaQuery.of(context).orientation != Orientation.portrait)
                      Positioned(
                        left: 16 + MediaQuery.of(context).viewPadding.left + 12,
                        bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
                        child: FloatingActionButton(
                          heroTag: 'facet-fab',
                          mini: true,
                          onPressed: () => _toggleSideMenu(facetBloc, open: !_sideMenuOpenNotifier.value),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.filter_alt_outlined),
                        ),
                      ),
                  ], // children
                ), // Stack
              ), // Scaffold
            ); // return BlocListener
        },
      ),
    );
  }

  Widget _buildCategoryPanel(BuildContext context, {required bool isVertical, required bool isTopPanel}) {
    if (_isLoadingCategories) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categoriesError != null) {
      return _buildCategoriesErrorState(context, _categoriesError!);
    }

    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Отступы для безопасной зоны - только для верхней панели в вертикальном режиме
    final topPadding = (isVertical && isTopPanel) ? mediaQuery.padding.top : 0.0;
    const double bottomExtra = 72.0; // extra space at bottom to allow comfortable scroll beyond last item
    final bottomPadding = mediaQuery.viewPadding.bottom + bottomExtra;

    return Column(
      children: [
        // Компактное поле поиска категорий с учётом safe area
        Container(
          color: theme.colorScheme.surface,
          padding: EdgeInsets.fromLTRB(
            8, 
            6 + topPadding, // Добавляем отступ сверху в вертикальном режиме
            8, 
            6,
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _categorySearchFocusNode,
            onChanged: _onSearchChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Поиск категорий',
              hintStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 20),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
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
        // Показываем либо список категорий, либо пустое состояние
        Expanded(
          child: _filteredCategories.isEmpty
              ? _buildEmptyCategoriesContent(context)
              : RefreshIndicator(
                  onRefresh: () => _loadCategories(forceRefresh: true),
                  child: ListView(
                    controller: _categoryScrollController,
                    padding: EdgeInsets.fromLTRB(
                      4,
                      4,
                      4,
                      4 + bottomPadding, // Добавляем отступ снизу в горизонтальном режиме
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: _filteredCategories
                        .map((category) => _buildCategoryCard(context, category, 0))
                        .toList(),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildCategoriesErrorState(BuildContext context, String message) {
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
              'Ошибка загрузки категорий',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadCategories(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCategoriesContent(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Категории не найдены',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить параметры поиска',
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

  Widget _buildCategoryCard(BuildContext context, Category category, int level) {
    final hasChildren = category.children.isNotEmpty;
    final isExpanded = _expandedCategoryIds.contains(category.id);
    final isSelected = _selectedCategoryId == category.id;
    final theme = Theme.of(context);

    return Card(
      key: ValueKey('split_category_${category.id}_level_$level'),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 4),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : _getCategoryColor(level),
              border: Border(
                left: BorderSide(
                  color: _getLevelBorderColor(level),
                  width: _getLevelBorderWidth(level),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 7,
                  child: InkWell(
                    onTap: () => _selectCategory(category),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12 + level * 4,
                        vertical: 10,
                      ),
                      child: Text(
                        '${category.name} (${category.count})',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : (level == 0 ? FontWeight.w600 : FontWeight.w500),
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.black87,
                          fontSize: _getFontSize(level),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: InkWell(
                    onTap: hasChildren ? () => _toggleCategoryExpansion(category.id) : null,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerRight,
                      child: AnimatedRotation(
                        turns: hasChildren && isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          hasChildren ? Icons.expand_more : Icons.chevron_right,
                          size: 18,
                          color: hasChildren
                              ? theme.colorScheme.primary
                              : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (hasChildren && isExpanded)
            Container(
              color: _getChildCategoryColor(level),
              child: Column(
                children: category.children
                    .map((child) => _buildCategoryCard(context, child, level + 1))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsPanel({required bool isVertical, required bool isTopPanel}) {
    return SplitCategoryProductsPanel(
      category: _selectedCategory,
      selectedStockItems: _selectedStockItems,
      onStockItemChanged: _handleStockItemChange,
      isVertical: isVertical,
      isTopPanel: isTopPanel,
      allowedProductCodes: _activeFacetProductCodes,
      productSearchFocusNode: _productsSearchFocusNode,
    );
  }

  Widget _buildHorizontalDivider(double availableWidth) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) {
        setState(() => _isHorizontalDividerPressed = true);
      },
      onPanEnd: (_) {
        setState(() => _isHorizontalDividerPressed = false);
      },
      onPanCancel: () {
        setState(() => _isHorizontalDividerPressed = false);
      },
      onPanUpdate: (details) {
        setState(() {
          final delta = details.delta.dx / availableWidth;
          _horizontalSplitRatio =
              (_horizontalSplitRatio + delta).clamp(_minSplitRatio, _maxSplitRatio);
        });
        _stateStore.horizontalSplitRatio = _horizontalSplitRatio;
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeColumn,
        child: Container(
          width: _dividerThickness,
          color: Colors.grey.shade200,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              width: _isHorizontalDividerPressed ? 26 : 28,
              height: _isHorizontalDividerPressed ? 76 : 80,
              decoration: BoxDecoration(
                color: _isHorizontalDividerPressed ? Colors.grey.shade400 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isHorizontalDividerPressed ? 0.15 : 0.1),
                    blurRadius: _isHorizontalDividerPressed ? 2 : 4,
                    offset: Offset(0, _isHorizontalDividerPressed ? 1 : 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 1.5, horizontal: 8),
                    height: 3,
                    decoration: BoxDecoration(
                      color: _isHorizontalDividerPressed ? Colors.grey.shade600 : Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalDivider(double availableHeight) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) {
        setState(() => _isVerticalDividerPressed = true);
      },
      onPanEnd: (_) {
        setState(() => _isVerticalDividerPressed = false);
      },
      onPanCancel: () {
        setState(() => _isVerticalDividerPressed = false);
      },
      onPanUpdate: (details) {
        final safeHeight = availableHeight <= 0 ? 1.0 : availableHeight;
        setState(() {
          final delta = details.delta.dy / safeHeight;
          _verticalSplitRatio =
              (_verticalSplitRatio + delta).clamp(_minSplitRatio, _maxSplitRatio);
        });
        _stateStore.verticalSplitRatio = _verticalSplitRatio;
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeRow,
        child: Container(
          height: _dividerThickness,
          color: Colors.grey.shade200,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              width: _isVerticalDividerPressed ? 76 : 80,
              height: _isVerticalDividerPressed ? 26 : 28,
              decoration: BoxDecoration(
                color: _isVerticalDividerPressed ? Colors.grey.shade400 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: _isVerticalDividerPressed ? 0.15 : 0.1),
                    blurRadius: _isVerticalDividerPressed ? 2 : 4,
                    offset: Offset(0, _isVerticalDividerPressed ? 1 : 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5, vertical: 8),
                    width: 3,
                    decoration: BoxDecoration(
                      color: _isVerticalDividerPressed ? Colors.grey.shade600 : Colors.grey.shade500,
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(int level) {
    switch (level) {
      case 0:
        return const Color.fromARGB(255, 255, 255, 255);
      case 1:
        return const Color.fromARGB(230, 230, 230, 230);
      case 2:
        return const Color.fromARGB(210, 210, 210, 210);
      case 3:
        return const Color.fromARGB(190, 190, 190, 190);
      default:
        return const Color.fromARGB(255, 114, 114, 114);
    }
  }

  Color _getChildCategoryColor(int level) {
    switch (level) {
      case 0:
        return const Color.fromARGB(255, 255, 255, 255);
      case 1:
        return const Color.fromARGB(230, 230, 230, 230);
      case 2:
        return const Color.fromARGB(210, 210, 210, 210);
      case 3:
        return const Color.fromARGB(190, 190, 190, 190);
      default:
        return const Color.fromARGB(180, 180, 180, 180);
    }
  }

  Color _getLevelBorderColor(int level) {
    switch (level) {
      case 0:
        return const Color.fromARGB(255, 253, 228, 2);
      case 1:
        return const Color.fromARGB(255, 221, 224, 2);
      case 2:
        return const Color.fromARGB(255, 255, 115, 0);
      case 3:
        return const Color.fromARGB(255, 255, 33, 0);
      default:
        return Colors.grey.shade300;
    }
  }

  double _getLevelBorderWidth(int level) {
    switch (level) {
      case 0:
        return 4.0;
      case 1:
        return 3.0;
      case 2:
        return 2.0;
      case 3:
        return 1.0;
      default:
        return 0.5;
    }
  }

  double _getFontSize(int level) {
    switch (level) {
      case 0:
        return 15.0;
      case 1:
        return 14.0;
      case 2:
        return 13.0;
      case 3:
        return 12.0;
      default:
        return 11.0;
    }
  }

  static const double _dividerThickness = 8;
  static const double _minSplitRatio = 0.2;
  static const double _maxSplitRatio = 0.8;
  static const double _compactWidthBreakpoint = 620;
}
