import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/app/services/category_tree_cache_service.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/presentation/widgets/catalog_app_bar_actions.dart';
import 'category_products_page.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage>
    with TickerProviderStateMixin {
  static final Logger _logger = Logger('ProductCatalogPage');
  final CategoryTreeCacheService _categoryTreeCacheService = GetIt.instance<CategoryTreeCacheService>();

  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  bool _isLoading = true;
  String? _error;
  final Set<int> _expandedCategories = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Популярные категории для быстрого доступа
  final List<String> _popularCategoryNames = ['work', 'in', 'progress'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _categoryTreeCacheService.getTreeForCurrentRegion(
      forceRefresh: forceRefresh,
    );

    if (result.isLeft()) {
      setState(() {
        _isLoading = false;
        _error = result.fold((failure) => failure.message, (_) => null);
      });
      return;
    }

    final categories = result.getOrElse(() => []);

    setState(() {
      _isLoading = false;
      _categories = categories;
      _filteredCategories = categories;
      _logger.fine('Категории обновлены. Корневых категорий: ${categories.length}');
      for (final cat in categories) {
        if (cat.count > 0) {
          _logger.fine('Категория с товарами: ${cat.name} (id: ${cat.id}) = ${cat.count}');
        }
      }
      _animationController.forward(from: 0.0);
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      if (_searchQuery.isEmpty) {
        _filteredCategories = _categories;
      } else {
        _filteredCategories = _filterCategories(_categories, _searchQuery);
      }
    });
  }

  List<Category> _filterCategories(List<Category> categories, String query) {
    return categories.where((category) {
      final matchesName = category.name.toLowerCase().contains(query);
      final matchesChildren = category.children.isNotEmpty &&
          _filterCategories(category.children, query).isNotEmpty;
      return matchesName || matchesChildren;
    }).toList();
  }

  void _toggleCategoryExpansion(int categoryId) {
    setState(() {
      if (_expandedCategories.contains(categoryId)) {
        _expandedCategories.remove(categoryId);
      } else {
        _expandedCategories.add(categoryId);
      }
    });
  }

  void _onCategoryTap(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryProductsPage(category: category),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    // Напитки и еда
    if (name.contains('напит')) return Icons.local_drink;
    if (name.contains('сладост') || name.contains('конфет')) return Icons.cake;
    if (name.contains('молоч')) return Icons.restaurant;
    if (name.contains('хлеб') || name.contains('выпечк')) return Icons.bakery_dining;
    if (name.contains('мяс') || name.contains('колбас')) return Icons.restaurant_menu;
    if (name.contains('рыб')) return Icons.set_meal;
    if (name.contains('фрукт') || name.contains('овощ')) return Icons.eco;

    // Бытовая химия и уход
    if (name.contains('бытов')) return Icons.cleaning_services;
    if (name.contains('космет')) return Icons.spa;
    if (name.contains('гигиен') || name.contains('уход')) return Icons.clean_hands;
    if (name.contains('мыло')) return Icons.soap;
    if (name.contains('зубн')) return Icons.cleaning_services; // или Icons.brush, но cleaning_services лучше

    // Строительство и ремонт
    if (name.contains('строитель') || name.contains('ремонт')) return Icons.build;
    if (name.contains('инструмент')) return Icons.build;
    if (name.contains('лакокрас') || name.contains('краск')) return Icons.format_paint;
    if (name.contains('электр')) return Icons.electrical_services;
    if (name.contains('плинтус') || name.contains('двер') || name.contains('окн')) return Icons.house;

    // Текстиль и одежда
    if (name.contains('бель') || name.contains('текстил')) return Icons.checkroom;
    if (name.contains('одежд')) return Icons.dry_cleaning;
    if (name.contains('постель')) return Icons.king_bed;

    // Дом и сад
    if (name.contains('сад') || name.contains('огород')) return Icons.grass;
    if (name.contains('дом') || name.contains('хозяйств')) return Icons.home;
    if (name.contains('товар') && name.contains('дом')) return Icons.chair;

    // Здоровье и аптека
    if (name.contains('аптек') || name.contains('медицин')) return Icons.medical_services;
    if (name.contains('здоров')) return Icons.healing;

    // Дети
    if (name.contains('дет') || name.contains('ребенок')) return Icons.child_care;

    // Спорт и отдых
    if (name.contains('спорт') || name.contains('активн')) return Icons.sports_soccer;
    if (name.contains('отдых')) return Icons.beach_access;

    // Профессиональные товары
    if (name.contains('проф')) return Icons.business_center;

    // Прочее
    if (name.contains('книг') || name.contains('учеб')) return Icons.menu_book;
    if (name.contains('игруш')) return Icons.toys;
    if (name.contains('авто') || name.contains('машин')) return Icons.directions_car;

    return Icons.category;
  }

  Color _getCategoryColor(int level) {
    // Градиент от светлого к темному для ощущения глубины вложенности
    switch (level) {
      case 0: return const Color.fromARGB(255, 255, 255, 255);
      case 1: return const Color.fromARGB(230, 230, 230, 230);
      case 2: return const Color.fromARGB(210, 210, 210, 210);
      case 3: return const Color.fromARGB(190, 190, 190, 190); 
      default: return const Color.fromARGB(255, 114, 114, 114); // Самый темный для глубоких уровней
    }
  }

  Color _getChildCategoryColor(int parentLevel) {
    // Цвета дочерних категорий чуть светлее родительских для контраста
    switch (parentLevel) {
      case 0: return const Color.fromARGB(255, 255, 255, 255);
      case 1: return const Color.fromARGB(230, 230, 230, 230);
      case 2: return const Color.fromARGB(210, 210, 210, 210);
      case 3: return const Color.fromARGB(190, 190, 190, 190); 
      default: return const Color.fromARGB(180, 180, 180, 180); 
    }
  }

  // Визуальные хелперы для уровней (цвета, размеры) оставлены выше.

  Color _getLevelBorderColor(int level) {
    switch (level) {
      case 0: return const Color.fromARGB(255, 253, 228, 2); // Синяя граница для корневых
      case 1: return const Color.fromARGB(255, 221, 224, 2); 
      case 2: return const Color.fromARGB(255, 255, 115, 0);
      case 3: return const Color.fromARGB(255, 255, 33, 0); // 
      default: return Colors.grey.shade300; // 
    }
  }

  double _getLevelBorderWidth(int level) {
    switch (level) {
      case 0: return 4.0;
      case 1: return 3.0; 
      case 2: return 2.0;
      case 3: return 1.0;
      default: return 0.5;
    }
  }

  // Icon size helper removed because it's currently unused. Sizes are controlled
  // inline where necessary. Re-add if a new design requires per-level icon sizing.

  double _getFontSize(int level) {
    switch (level) {
      case 0: return 15.0;
      case 1: return 14.0; 
      case 2: return 13.0;
      case 3: return 12.0;
      default: return 11.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
  appBar: _buildAppBar(),
  body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      toolbarHeight: 50,
      centerTitle: false,
      titleSpacing: 0,

      foregroundColor: Colors.white,
      title: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  'Каталог товаров',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: Center(
              child: CatalogFilterButton(
                onPressed: () => showCatalogFilterPlaceholder(context),
              ),
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/menu');
        },
      ),
      actions: const [CatalogAppBarActions(showFilter: false)],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Container(
          // Reduced horizontal padding to bring the search field closer to the screen edges
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Поиск по категориям...',
              prefixIcon: const Icon(Icons.search, color: Color.fromARGB(255, 100, 100, 100)),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_filteredCategories.isEmpty) {
      return _buildEmptyState();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: () => _loadCategories(forceRefresh: true),
        color: const Color.fromARGB(255, 97, 118, 134),
        child: CustomScrollView(
          slivers: [
            if (_searchQuery.isEmpty) _buildPopularCategories(),
            // Reduce horizontal padding so list items reach closer to edges
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = _filteredCategories[index];
                    return _buildCategoryCard(category, 0);
                  },
                  childCount: _filteredCategories.length,
                  // Упрощенная логика для ключей - используем ID категории
                  findChildIndexCallback: (Key key) {
                    if (key is! ValueKey<String>) return null;
                    final keyValue = key.value;
                    
                    // Извлекаем ID категории из ключа
                    final regex = RegExp(r'category_\w+_(\d+)_');
                    final match = regex.firstMatch(keyValue);
                    if (match == null) return null;
                    
                    final categoryId = int.tryParse(match.group(1) ?? '');
                    if (categoryId == null) return null;

                    // Ищем категорию по ID
                    for (int i = 0; i < _filteredCategories.length; i++) {
                      if (_filteredCategories[i].id == categoryId) {
                        return i;
                      }
                    }
                    return null;
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCategories() {
    final popularCategories = _categories
        .where((cat) => _popularCategoryNames.contains(cat.name))
        .toList();

    if (popularCategories.isEmpty) return const SliverToBoxAdapter();

    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              // Align popular section padding with the main list
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Text(
                'Популярные категории',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(0, 236, 236, 236),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                // reduced horizontal padding between screen edge and popular list
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: popularCategories.length,
                itemBuilder: (context, index) {
                  final category = popularCategories[index];
                  return Container(
                    width: 100,
                    // slightly reduced gap between popular items
                    margin: const EdgeInsets.only(right: 8),
                    child: _buildPopularCategoryCard(category),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCategoryCard(Category category) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _onCategoryTap(category),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getCategoryIcon(category.name),
                color: Colors.blue.shade600,
                size: 32,
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  category.name,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(Category category, int level, [int? parentId]) {
    final hasChildren = category.children.isNotEmpty;
    final isExpanded = _expandedCategories.contains(category.id);
    final categoryColor = _getCategoryColor(level);

    // Логирование для отладки корневых категорий
    if (level == 0) {
      _logger.finer('Строим карточку для ${category.name} (id: ${category.id}) с count = ${category.count}, hasChildren = $hasChildren');
      if (hasChildren) {
        _logger.finer('Дети категории ${category.name}: ${category.children.map((c) => '${c.name}(${c.id})').join(', ')}');
      }
    }

  // Префикс уровня оставлен для возможного будущего использования
  // final levelPrefix = _getLevelPrefix(level);

    return Card(
      key: ValueKey('category_card_${category.id}_level_${level}_expanded_${isExpanded}_parent_${parentId ?? 'root'}'),
      elevation: 0,
      margin: const EdgeInsets.only(
        left: 0,
        bottom: 1,
        right: 0,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          // Основная строка с категорией
          Container(
            decoration: BoxDecoration(
              color: categoryColor,
              border: Border(
                left: BorderSide(
                  color: _getLevelBorderColor(level),
                  width: _getLevelBorderWidth(level),
                ),
              ),
            ),
            child: Row(
              children: [
                // Левая + средняя колонка объединены: название + (count)
                Expanded(
                  flex: 7, // ~70% ширины
                  child: InkWell(
                    key: ValueKey('category_navigate_${category.id}_level_${level}_parent_${parentId ?? 'root'}'),
                    onTap: () => _onCategoryTap(category),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Название категории и количество в скобках
                          Expanded(
                            child: Text(
                              '${category.name} (${category.count})',
                              style: TextStyle(
                                fontSize: _getFontSize(level),
                                fontWeight: level == 0 ? FontWeight.w600 : FontWeight.w500,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Правая половина - область клика для разворачивания/сворачивания
                Expanded(
                  flex: 3, // ~30% ширины
                  child: InkWell(
                    key: ValueKey('category_expand_${category.id}_level_${level}_parent_${parentId ?? 'root'}'),
                    onTap: hasChildren ? () => _toggleCategoryExpansion(category.id) : null,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      alignment: Alignment.centerRight,
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          hasChildren ? Icons.expand_more : Icons.chevron_right,
                          color: hasChildren ? Colors.blue.shade600 : Colors.grey.shade400,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Дочерние категории
          if (hasChildren && isExpanded)
            Container(
              decoration: BoxDecoration(
                color: _getChildCategoryColor(level),
              ),
              child: Column(
                children: category.children.map(
                  (child) => _buildCategoryCard(child, level + 1, category.id),
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки категорий',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCategories,
            icon: const Icon(Icons.refresh),
            label: const Text('Повторить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.category,
              size: 64,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Категории не найдены' : 'Ничего не найдено',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить запрос',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

}
