// lib/shared/widgets/cached_network_image_widget.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:logging/logging.dart';
import 'dart:math' as math;

/// Виджет для кеширования сетевых изображений с ленивой загрузкой
/// 
/// Особенности:
/// - Загружает только когда виджет попадает в viewport
/// - Автоматически кеширует на диск
/// - Поддерживает WebP оптимизацию
/// - Показывает placeholder во время загрузки
/// - Обрабатывает ошибки загрузки
class CachedNetworkImageWidget extends StatelessWidget {
  static final Logger _logger = Logger('CachedNetworkImageWidget');

  final String? imageUrl;
  final String? webpUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final PlaceholderWidgetBuilder? placeholder;
  final LoadingErrorWidgetBuilder? errorWidget;
  final bool enableLazyLoading;

  const CachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.webpUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableLazyLoading = true,
  });

  /// Создает виджет для изображения продукта
  factory CachedNetworkImageWidget.product({
    required String? imageUrl,
    required String? webpUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    return CachedNetworkImageWidget(
      imageUrl: imageUrl,
      webpUrl: webpUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => _buildProductPlaceholder(width, height),
      errorWidget: (context, url, error) => _buildProductErrorWidget(width, height),
    );
  }

  /// Создает ленивый виджет для изображения продукта (загружает только когда видим)
  static Widget lazyProduct({
    required String? imageUrl,
    required String? webpUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildProductPlaceholder(width, height);
    }

    return LazyLoadImageWidget(
      imageUrl: imageUrl,
      webpUrl: webpUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: _buildProductPlaceholder(width, height),
    );
  }

  /// Предварительно загружает изображение продукта в кэш, чтобы избежать морганий при прокрутке
  static Future<void> prefetchProductImage(
    BuildContext context, {
    required String imageUrl,
    String? webpUrl,
    double? width,
    double? height,
  }) async {
    if (imageUrl.isEmpty) return;

    final optimizedUrl = _resolveOptimizedUrl(
      imageUrl: imageUrl,
      webpUrl: webpUrl,
      width: width,
    );
    final cacheKey = _generateCacheKey(optimizedUrl, width, height);

    try {
      final provider = CachedNetworkImageProvider(
        optimizedUrl,
        cacheKey: cacheKey,
      );

      await precacheImage(provider, context);
      _logger.finer('🗃️ Prefetched image: $optimizedUrl');
    } catch (error, stackTrace) {
      _logger.fine('⚠️ Failed to prefetch image $optimizedUrl: $error');
      _logger.finest('Prefetch stack trace for $optimizedUrl', error, stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Если нет URL изображения
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildNoImageWidget();
    }

    // Выбираем оптимальный URL (предпочитаем WebP)
    final optimizedUrl = _resolveOptimizedUrl(
      imageUrl: imageUrl!,
      webpUrl: webpUrl,
      width: width,
    );
    
    // Логируем только при действительной загрузке
    _logger.fine('🖼️ Загружаем изображение: $optimizedUrl');

    return CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder ?? _buildDefaultPlaceholder,
      errorWidget: (context, url, error) {
        _logger.warning('❌ Ошибка загрузки изображения: $url - $error');
        return errorWidget != null ? errorWidget!(context, url, error) : _buildDefaultErrorWidget();
      },
      // Кеширование
      cacheKey: _generateCacheKey(optimizedUrl, width, height),
      memCacheWidth: width?.round(),
      memCacheHeight: height?.round(),
      // Настройки производительности
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
      useOldImageOnUrlChange: true,
    );
  }

  /// Выбирает оптимальный URL для загрузки
  static String _resolveOptimizedUrl({
    required String imageUrl,
    String? webpUrl,
    double? width,
  }) {
    final baseUrl = (webpUrl != null && webpUrl.isNotEmpty) ? webpUrl : imageUrl;
    return _addWidthParameter(baseUrl, width);
  }

  /// Добавляет параметр ширины к URL изображения для оптимизации загрузки
  static String _addWidthParameter(String imageUrl, double? width) {
    if (imageUrl.isEmpty) return imageUrl;
    
    // Для маленьких размеров (превью) используем 400px
    // Для больших размеров используем 1000px или оригинальную ширину
    final targetWidth = _getThumbnailWidth(width);
    
    // Проверяем, нет ли уже параметра w в URL
    final uri = Uri.tryParse(imageUrl);
    if (uri == null) return imageUrl;
    
    // Проверяем что это действительно HTTP/HTTPS URL
    if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) return imageUrl;
    
    // Если параметр w уже есть, не добавляем повторно
    if (uri.queryParameters.containsKey('w')) return imageUrl;
    
    // Добавляем параметр w к существующим query параметрам
    final newQueryParameters = Map<String, String>.from(uri.queryParameters);
    newQueryParameters['w'] = targetWidth.toString();
    
    final newUri = uri.replace(queryParameters: newQueryParameters);
    return newUri.toString();
  }

  /// Определяет оптимальную ширину для загрузки
  static int _getThumbnailWidth(double? width) {
    // Если ширина не задана или маленькая (меньше 100px) - используем превью 400px
    if (width == null || width < 100) {
      return 400;
    }
    
    // Для больших изображений используем 1000px (full-size)
    if (width > 400) {
      return 1000;
    }
    
    // Для средних размеров используем превью 400px
    return 400;
  }

  /// Генерирует ключ для кеширования
  static String _generateCacheKey(String url, double? width, double? height) {
    // Используем URL + размеры для уникального ключа
    final sizeKey = '${width?.round() ?? 0}x${height?.round() ?? 0}';
    return '$url-$sizeKey';
  }

  /// Виджет когда нет изображения
  Widget _buildNoImageWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey,
        size: 32,
      ),
    );
  }

  /// Плейсхолдер по умолчанию
  Widget _buildDefaultPlaceholder(BuildContext context, String url) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  /// Виджет ошибки по умолчанию
  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[100]!),
      ),
      child: Icon(
        Icons.broken_image_outlined,
        color: Colors.red[300],
        size: 32,
      ),
    );
  }

  /// Плейсхолдер для продуктов
  static Widget _buildProductPlaceholder(double? width, double? height) {
    // Для маленьких размеров показываем только индикатор
    // 70px порог чтобы 60x60 считалось маленьким
    final isSmall = (width != null && width <= 70) || (height != null && height <= 70);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[100]!, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: isSmall 
          ? SizedBox(
              width: math.min(width ?? 24, height ?? 24) * 0.5,
              height: math.min(width ?? 24, height ?? 24) * 0.5,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(strokeWidth: 2),
                SizedBox(height: 8),
                Text('Загрузка...', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
      ),
    );
  }

  /// Виджет ошибки для продуктов
  static Widget _buildProductErrorWidget(double? width, double? height) {
    // Для маленьких размеров показываем только иконку
    // 70px порог чтобы 60x60 считалось маленьким
    final isSmall = (width != null && width <= 70) || (height != null && height <= 70);
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: isSmall 
        ? Center(
            child: Icon(
              Icons.image_not_supported, 
              color: Colors.grey[400], 
              size: math.min(width ?? 24, height ?? 24) * 0.6,
            ),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_not_supported, color: Colors.grey[400], size: 32),
              const SizedBox(height: 4),
              Text('Нет фото', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            ],
          ),
    );
  }
}

/// Виджет для ленивой загрузки изображений в списках
/// 
/// Загружает изображение только когда оно становится видимым
class LazyLoadImageWidget extends StatefulWidget {
  final String? imageUrl;
  final String? webpUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const LazyLoadImageWidget({
    super.key,
    required this.imageUrl,
    this.webpUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  State<LazyLoadImageWidget> createState() => _LazyLoadImageWidgetState();
}

class _LazyLoadImageWidgetState extends State<LazyLoadImageWidget> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.imageUrl),
      onVisibilityChanged: (info) {
        // Загружаем когда видно хотя бы 1% И еще не загружали
        // Используем низкий порог для упреждающей загрузки
        // НЕ сбрасываем _isVisible когда элемент уходит - один раз загрузили, всегда показываем
        if (info.visibleFraction > 0.01 && !_isVisible) {
          setState(() => _isVisible = true);
        }
      },
      child: _isVisible 
        ? CachedNetworkImageWidget(
            imageUrl: widget.imageUrl,
            webpUrl: widget.webpUrl,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
          )
        : widget.placeholder ?? _buildLazyPlaceholder(),
    );
  }

  Widget _buildLazyPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}