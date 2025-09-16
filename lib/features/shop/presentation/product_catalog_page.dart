import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/presentation/widgets/navigation_fab_widget.dart';
import 'product_list_page.dart';
class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key});

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage>
    with TickerProviderStateMixin {
  final CategoryRepository _categoryRepository = GetIt.instance<CategoryRepository>();

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

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _categoryRepository.getAllCategories();

    if (result.isLeft()) {
      setState(() {
        _isLoading = false;
        _error = result.fold((failure) => failure.message, (_) => null);
      });
      return;
    }

    final categories = result.getOrElse(() => []);

    // Обновляем количество продуктов в категориях
    final updateResult = await _categoryRepository.updateCategoryCountsWithCategories(categories);
    if (updateResult.isLeft()) {
      print('⚠️ Предупреждение: не удалось обновить количество продуктов в категориях');
      // Продолжаем с загруженными категориями
    } else {
      print('✅ updateCategoryCounts выполнен успешно');
      // Категории уже обновлены в памяти, используем их напрямую
    }

    // Категории уже обновлены, используем их напрямую
    setState(() {
      _isLoading = false;
      _categories = categories;
      _filteredCategories = categories;
      print('🔄 UI: Категории обновлены. Корневые категории:');
      for (final cat in categories) {
        if (cat.count > 0) {
          print('🔄 UI: ${cat.name} (id: ${cat.id}) = ${cat.count}');
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
        builder: (context) => ProductListPage(category: category),
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
      case 0: return const Color(0xFFFAFAFA); // Почти белый для корневых категорий
      case 1: return const Color(0xFFF5F5F5); // Светло-серый для уровня 1
      case 2: return const Color(0xFFEEEEEE); // Серый для уровня 2
      case 3: return const Color(0xFFE8E8E8); // Темно-серый для уровня 3
      case 4: return const Color(0xFFE0E0E0); // Еще темнее для уровня 4
      default: return const Color(0xFFD0D0D0); // Самый темный для глубоких уровней
    }
  }

  Color _getChildCategoryColor(int parentLevel) {
    // Цвета дочерних категорий чуть светлее родительских для контраста
    switch (parentLevel) {
      case 0: return const Color(0xFFFFFFFF); // Белый для детей корневых
      case 1: return const Color(0xFFFAFAFA); // Почти белый для детей уровня 1
      case 2: return const Color(0xFFF8F8F8); // Светло-серый для детей уровня 2
      case 3: return const Color(0xFFF5F5F5); // Серый для детей уровня 3
      default: return const Color(0xFFF0F0F0); // Светло-серый для глубоких уровней
    }
  }

  // Новые методы для визуальной иерархии
  String _getLevelPrefix(int level) {
    switch (level) {
      case 0: return '●'; // Крупная точка для корневых
      case 1: return '○'; // Круг для уровня 1
      case 2: return '◦'; // Маленькая точка для уровня 2
      case 3: return '•'; // Маркер для уровня 3
      default: return '·'; // Точка для глубоких уровней
    }
  }

  Color _getLevelBorderColor(int level) {
    switch (level) {
      case 0: return Colors.blue.shade300; // Синяя граница для корневых
      case 1: return Colors.green.shade300; // Зеленая для уровня 1
      case 2: return Colors.orange.shade300; // Оранжевая для уровня 2
      case 3: return Colors.purple.shade300; // Фиолетовая для уровня 3
      default: return Colors.grey.shade300; // Серая для глубоких уровней
    }
  }

  double _getLevelBorderWidth(int level) {
    switch (level) {
      case 0: return 4.0; // Толстая граница для корневых
      case 1: return 3.0; // Средняя для уровня 1
      case 2: return 2.0; // Тонкая для уровня 2
      case 3: return 1.0; // Очень тонкая для уровня 3
      default: return 0.5; // Минимальная для глубоких уровней
    }
  }

  double _getIconSize(int level) {
    switch (level) {
      case 0: return 22.0; // Крупная иконка для корневых
      case 1: return 20.0; // Средняя для уровня 1
      case 2: return 18.0; // Меньше для уровня 2
      case 3: return 16.0; // Маленькая для уровня 3
      default: return 14.0; // Минимальная для глубоких уровней
    }
  }

  double _getFontSize(int level) {
    switch (level) {
      case 0: return 15.0; // Крупный шрифт для корневых
      case 1: return 14.0; // Средний для уровня 1
      case 2: return 13.0; // Меньше для уровня 2
      case 3: return 12.0; // Маленький для уровня 3
      default: return 11.0; // Минимальный для глубоких уровней
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Белый фон для экономии места
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      title: const Text(
        'Каталог товаров',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/menu');
        },
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50), // Уменьшаем высоту
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), // Уменьшаем нижний padding
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Поиск по категориям...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero, // Прямые углы
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8), // Уменьшаем вертикальный padding
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
        onRefresh: _loadCategories,
        color: Colors.blue,
        child: CustomScrollView(
          slivers: [
            if (_searchQuery.isEmpty) _buildPopularCategories(),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return _buildCategoryCard(_filteredCategories[index], 0);
                  },
                  childCount: _filteredCategories.length,
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
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Популярные категории',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: popularCategories.length,
                itemBuilder: (context, index) {
                  final category = popularCategories[index];
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(right: 12),
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

    // Отладка для корневых категорий
    if (level == 0) {
      print('🎨 UI: Строим карточку для ${category.name} (id: ${category.id}) с count = ${category.count}, hasChildren = $hasChildren, children.length = ${category.children.length}');
      if (hasChildren) {
        print('🎨 UI: Дети категории ${category.name}: ${category.children.map((c) => '${c.name}(${c.id})').join(', ')}');
      }
    }

    // Создаем префикс для обозначения уровня
    final levelPrefix = _getLevelPrefix(level);

    return Card(
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
                // Левая половина - кликабельна для перехода к товарам
                Expanded(
                  flex: 1,
                  child: InkWell(
                    onTap: () => _onCategoryTap(category),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Префикс уровня
                          Text(
                            levelPrefix,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Иконка
                          Icon(
                            _getCategoryIcon(category.name),
                            color: Colors.blue.shade600,
                            size: _getIconSize(level),
                          ),
                          const SizedBox(width: 12),
                          // Название категории
                          Expanded(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontSize: _getFontSize(level),
                                fontWeight: level == 0 ? FontWeight.w600 : FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Количество товаров (справа от названия)
                          Text(
                            category.count.toString(),
                            style: TextStyle(
                              fontSize: _getFontSize(level) - 2,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Правая половина - кликабельна для разворачивания/сворачивания
                Expanded(
                  flex: 1,
                  child: InkWell(
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

  Widget _buildFloatingActionButton() {
    return const NavigationFabWidget(
      onCartPressed: null, // Используем дефолтную логику
      onHomePressed: null, // Используем дефолтную логику
    );
  }
}
