import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:fieldforce/app/config/app_config.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:fieldforce/features/shop/presentation/bloc/cart_bloc.dart';
import 'package:fieldforce/features/shop/presentation/widgets/navigation_fab_widget.dart';
import 'package:fieldforce/features/shop/presentation/pages/product_detail_page.dart';
import 'package:fieldforce/features/shop/presentation/widgets/product_catalog_card_widget.dart';

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
  final ProductRepository _productRepository = GetIt.instance<ProductRepository>();
  final StockItemRepository _stockItemRepository = GetIt.instance<StockItemRepository>();

  List<ProductWithStock> _products = [];
  bool _isLoading = true;
  String? _error;
  final ScrollController _scrollController = ScrollController();
  bool _hasMore = true;
  int _currentOffset = 0;
  final int _limit = 20;

  String? _vendorId;
  bool _vendorResolved = false;
  bool _vendorResolutionFailed = false;
  
  // Отслеживаем выбранные StockItem для каждого продукта
  final Map<int, StockItem> _selectedStockItems = {};

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
    
    // Загружаем корзину при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartBloc>().add(const LoadCartEvent());
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMoreProducts();
      }
    }
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

    final vendorId = await _resolveVendorId();
    _logger.info('🔄 _loadProductsInternal: resolved vendorId = $vendorId');
    
    if (_vendorResolutionFailed) {
      setState(() {
        _isLoading = false;
        _error = 'Не удалось определить склад для отображения остатков';
      });
      return;
    }
    
    // Используем ProductWithStock для отображения остатков
    // В соответствии с архитектурой StockItem-centered
    final result = await _productRepository.getProductsWithStockByCategoryPaginated(
      widget.category.id,
      vendorId: vendorId,
      offset: _currentOffset,
      limit: _limit,
    );

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

    final newProducts = result.getOrElse(() => []);
    
    setState(() {
      _isLoading = false;
      
      if (reset) {
        _products = newProducts;
      } else {
        _products.addAll(newProducts);
      }
      
      _hasMore = newProducts.length == _limit;
      _currentOffset += newProducts.length;
      
      _logger.fine('Загружено ${newProducts.length} продуктов для категории "${widget.category.name}" (всего: ${_products.length})');
    });
  }

  Future<String?> _resolveVendorId() async {
    if (_vendorResolved) {
      return _vendorId;
    }

    // В dev режиме не фильтруем по складу, чтобы видеть все товары
    if (AppConfig.isDev) {
      _logger.info('🔍 _resolveVendorId: DEV режим - не фильтруем по складу');
      _vendorResolved = true;
      _vendorId = null;
      return _vendorId;
    }

    try {
      final stockResult = await _stockItemRepository.getAvailableStockItems();

      if (stockResult.isLeft()) {
        final failure = stockResult.fold((failure) => failure, (_) => null);
        _logger.warning('⚠️ _resolveVendorId: не удалось получить остатки: ${failure?.message}');
        _vendorResolved = true;
        _vendorId = null;
        return _vendorId;
      }

      final stockItems = stockResult.getOrElse(() => []);
      _logger.info('🔍 _resolveVendorId: найдено ${stockItems.length} остатков в базе');
      
      if (stockItems.isEmpty) {
        _logger.warning('⚠️ _resolveVendorId: не найдено остатков > 0, используем все склады');
        _vendorResolved = true;
        _vendorId = null;
        return _vendorId;
      }

      final vendorIds = stockItems.map((item) => item.warehouseVendorId).where((id) => id.isNotEmpty).toSet();
      _logger.info('🔍 _resolveVendorId: уникальные vendorIds: $vendorIds');

      if (vendorIds.isEmpty) {
        _logger.warning('⚠️ _resolveVendorId: складские записи без vendorId');
        _vendorResolved = true;
        _vendorId = null;
        return _vendorId;
      }

      if (vendorIds.length > 1) {
        _logger.info('ℹ️ _resolveVendorId: обнаружено несколько vendorId ($vendorIds), используем первый');
      }

      _vendorId = vendorIds.first;
      _vendorResolved = true;
      _logger.info('✅ _resolveVendorId: выбран vendorId = $_vendorId');
      return _vendorId;
    } catch (error, stackTrace) {
      _logger.severe('Ошибка определения vendorId для остатков', error, stackTrace);
      _vendorResolutionFailed = true;
      return null;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          // Показываем количество товаров в категории
          if (widget.category.count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.category.count}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: const NavigationFabWidget(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
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
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
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

    if (_isLoading && _products.isEmpty) {
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

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        controller: _scrollController,
        // Reduced horizontal padding so cards align with screen edges
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        itemCount: _products.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _products.length) {
            // Показываем индикатор загрузки в конце списка
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final productWithStock = _products[index];
          
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
}