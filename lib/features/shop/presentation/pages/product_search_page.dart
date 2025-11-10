import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/usecases/search_products_usecase.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/pages/product_detail_page.dart';
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
  final SearchProductsUseCase _searchProductsUseCase = GetIt.instance<SearchProductsUseCase>();

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  
  List<ProductWithStock> _searchResults = [];
  bool _isSearching = false;
  String? _error;
  
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
    
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _error = null;
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
      _error = null;
    });
    
    _logger.info('🔍 Глобальный поиск товаров: "$query"');
    
    final result = await _searchProductsUseCase(
      query: query,
      // categoryId НЕ передаём - ищем по всему каталогу
      limit: 50,
    );
    
    if (!mounted) return;
    
    result.fold(
      (failure) {
        _logger.warning('⚠️ Ошибка поиска товаров: ${failure.message}');
        setState(() {
          _isSearching = false;
          _error = failure.message;
        });
      },
      (products) {
        _logger.info('✅ Найдено ${products.length} товаров');
        
        final productsWithStock = products.map((product) => ProductWithStock(
          product: product,
          totalStock: 0,
          maxPrice: 0,
          minPrice: 0,
          hasDiscounts: false,
        )).toList();
        
        if (!mounted) return;
        
        setState(() {
          _searchResults = productsWithStock;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Поиск товаров',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Кнопка домой (скрывается автоматически если уже на домашней странице)
          const HomeIconButton(),
          // Кнопка корзины
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            tooltip: 'Корзина',
          ),
        ],
      ),
      body: _buildBody(),
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
        
        // Результаты поиска
        Expanded(
          child: _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    final theme = Theme.of(context);
    
    // Показываем загрузку
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    // Показываем ошибку
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка поиска',
              style: theme.textTheme.titleLarge,
            ),
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
    if (_searchController.text.trim().isEmpty) {
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
              'Начните вводить название,\nартикул или штрихкод товара',
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
              'Ничего не найдено',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Попробуйте изменить запрос',
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
}
