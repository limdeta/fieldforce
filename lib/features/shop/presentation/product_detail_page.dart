import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/presentation/bloc/product_detail_bloc.dart';
import 'package:fieldforce/features/shop/presentation/bloc/product_detail_event.dart';
import 'package:fieldforce/features/shop/presentation/bloc/product_detail_state.dart';
import 'package:fieldforce/features/shop/presentation/widgets/cart_control_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/navigation_fab_widget.dart';
import 'package:fieldforce/features/shop/presentation/widgets/image_carousel_widget.dart';

/// Страница с детальной информацией о продукте
class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late PageController _imagePageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  // Функция для добавления параметров размера к URL изображения
  String _getSizedImageUrl(String url, int width) {
    if (url.contains('?')) {
      return '$url&w=$width';
    } else {
      return '$url?w=$width';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductDetailBloc()
        ..add(ProductDetailLoadProduct(widget.productId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Детали продукта'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<ProductDetailBloc, ProductDetailState>(
          builder: (context, state) {
            if (state is ProductDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ProductDetailError) {
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
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductDetailBloc>().add(ProductDetailReloadProduct());
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }

            if (state is ProductDetailNotFound) {
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
                      'Продукт не найден',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              );
            }

            if (state is ProductDetailLoaded) {
              return _buildProductContent(context, state.product);
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: const NavigationFabWidget(
          onCartPressed: null, // Используем дефолтную логику
          onHomePressed: null, // Используем дефолтную логику
        ),
      ),
    );
  }

  Widget _buildProductContent(BuildContext context, Product product) {
    // Собираем все изображения для карусели
    final List<ImageData> allImages = [];
    if (product.defaultImage != null) {
      allImages.add(product.defaultImage!);
    }
    allImages.addAll(product.images);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображения продукта с возможностью листания
          GestureDetector(
            onTap: allImages.isNotEmpty
                ? () => showImageCarousel(context, allImages, initialIndex: _currentImageIndex)
                : null,
            child: Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey.shade200,
              child: allImages.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: _imagePageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: allImages.length,
                          itemBuilder: (context, index) {
                            final image = allImages[index];
                            return Container(
                              color: Colors.grey.shade200,
                              child: Hero(
                                tag: 'product_image_${image.uri}_$index',
                                child: Image.network(
                                  _getSizedImageUrl(image.uri, 600),
                                  fit: BoxFit.contain,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    // Логируем ошибку для отладки
                                    debugPrint('Ошибка загрузки изображения: ${image.uri}');
                                    debugPrint('Ошибка: $error');

                                    return Container(
                                      color: Colors.grey.shade100,
                                      child: const Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.broken_image,
                                              color: Colors.grey,
                                              size: 48,
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Изображение недоступно',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        // Индикатор текущего изображения
                        if (allImages.length > 1)
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_currentImageIndex + 1} / ${allImages.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // Индикатор кликабельности для открытия полноэкранной карусели
                        if (allImages.length > 1)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    )
                  : const Icon(
                      Icons.inventory_2,
                      color: Colors.grey,
                      size: 64,
                    ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Название продукта
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 8),

                // Код продукта
                Text(
                  'Код: ${product.code}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),

                // Вес/упаковка
                if (product.amountInPackage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'В упаковке: ${product.amountInPackage} шт.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Цена (пока заглушка, так как в Product нет цены)
                Text(
                  'Цена не указана',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                // Контрол добавления в корзину
                CartControlWidget(
                  initialQuantity: 0, // TODO: Получать реальное количество из корзины
                  amountInPackage: product.amountInPackage,
                  onAddToCart: () {
                    // TODO: Добавить товар в корзину
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Товар добавлен в корзину')),
                    );
                  },
                  onQuantityChanged: (quantity) {
                    // TODO: Обновить количество в корзине
                    print('Количество изменено: $quantity');
                  },
                  showCartIcon: false, // В деталях продукта не показываем иконку корзины
                ),

                const SizedBox(height: 32),

                // Разделитель
                const Divider(),

                const SizedBox(height: 16),

                // Заголовок описания
                Text(
                  'Описание',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                // Описание продукта
                Text(
                  product.description ?? 'Описание не указано',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // Дополнительная информация
                _buildInfoSection(
                  context,
                  'Характеристики',
                  [
                    'Код товара: ${product.code}',
                    if (product.vendorCode != null) 'Артикул: ${product.vendorCode}',
                    if (product.type != null) 'Тип: ${product.type!.name}',
                    if (product.brand != null) 'Бренд: ${product.brand!.name}',
                    if (product.manufacturer != null) 'Производитель: ${product.manufacturer!.name}',
                    if (product.amountInPackage != null) 'В упаковке: ${product.amountInPackage} шт.',
                    if (product.novelty) 'Новинка',
                    if (product.popular) 'Популярный товар',
                  ],
                ),

                // Характеристики продукта
                if (product.numericCharacteristics.isNotEmpty ||
                    product.stringCharacteristics.isNotEmpty ||
                    product.boolCharacteristics.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildCharacteristicsSection(context, product),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicsSection(BuildContext context, Product product) {
    final allCharacteristics = [
      ...product.numericCharacteristics,
      ...product.stringCharacteristics,
      ...product.boolCharacteristics,
    ];

    if (allCharacteristics.isEmpty) return const SizedBox.shrink();

    return _buildInfoSection(
      context,
      'Свойства',
      allCharacteristics.map((char) {
        if (char.adaptValue != null && char.adaptValue!.isNotEmpty) {
          return '${char.attributeName}: ${char.adaptValue}';
        } else if (char.value != null) {
          return '${char.attributeName}: ${char.value}';
        }
        return char.attributeName;
      }).toList(),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            item,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
        )),
      ],
    );
  }
}