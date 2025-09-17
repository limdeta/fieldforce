import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logging/logging.dart';

/// Сервис для кэширования изображений с поддержкой разных размеров
class ImageCacheService {
  static final Logger _logger = Logger('ImageCacheService');

  // Конфигурация для разных типов изображений
  static const Duration _defaultCacheTimeout = Duration(days: 7);
  static const Duration _thumbnailCacheTimeout = Duration(days: 30); // Дольше храним миниатюры
  
  // Защита от DDOS: запоминаем битые URL и не запрашиваем их повторно
  static final Set<String> _brokenUrls = <String>{};
  static const Duration _brokenUrlCacheTimeout = Duration(hours: 1); // Повторно пробуем через час
  static final Map<String, DateTime> _brokenUrlTimestamps = <String, DateTime>{};
  
  // Дополнительная защита: счетчик ошибок для каждого URL
  static final Map<String, int> _errorCounts = <String, int>{};
  static const int _maxRetries = 3; // Максимум 3 попытки перед блокировкой

  static Widget getCachedThumbnail({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return _getCachedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      isThumbnail: true,
    );
  }

  /// Получить кэшированное изображение в полном размере
  static Widget getCachedFullImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return _getCachedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      isThumbnail: false,
    );
  }

  static Widget _getCachedImage({
    required String imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    bool isThumbnail = true,
  }) {
    // Проверяем, не является ли URL битым
    if (_isBrokenUrl(imageUrl)) {
      _logger.fine('Пропускаем загрузку битого URL: $imageUrl');
      return errorWidget ?? Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.grey,
            size: 24,
          ),
        ),
      );
    }

    _logger.fine('Loading ${isThumbnail ? 'thumbnail' : 'full'} image: $imageUrl');

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      
      // Конфигурация кэша в зависимости от типа изображения
      cacheManager: isThumbnail ? _getThumbnailCacheManager() : _getFullImageCacheManager(),
      
      // Для миниатюр используем простой placeholder, для больших изображений - прогресс
      // TODO: проверить
      progressIndicatorBuilder: (context, url, downloadProgress) {
        if (isThumbnail) {
          return placeholder ?? _getDefaultPlaceholder(width, height);
        } else {
          // Индикатор прогресса для больших изображений
          return _getProgressIndicator(downloadProgress);
        }
      },
      
      errorWidget: (context, url, error) => errorWidget ?? _getDefaultErrorWidget()(context, url, error),
      
      // Обработчик ошибок загрузки
      errorListener: (exception) {
        _logger.warning('Failed to load ${isThumbnail ? 'thumbnail' : 'full'} image: $imageUrl', exception);
        // Помечаем URL как битый для предотвращения повторных запросов
        _markAsBrokenUrl(imageUrl);
      },
    );
  }

  /// Получить менеджер кэша для миниатюр (более агрессивное кэширование)
  static CacheManager? _thumbnailCacheManager;
  static CacheManager _getThumbnailCacheManager() {
    _thumbnailCacheManager ??= CacheManager(
      Config(
        'thumbnailCache',
        stalePeriod: _thumbnailCacheTimeout,
        maxNrOfCacheObjects: 1000, // Больше объектов для миниатюр
      ),
    );
    return _thumbnailCacheManager!;
  }

  /// Получить менеджер кэша для полных изображений
  static CacheManager? _fullImageCacheManager;
  static CacheManager _getFullImageCacheManager() {
    _fullImageCacheManager ??= CacheManager(
      Config(
        'fullImageCache',
        stalePeriod: _defaultCacheTimeout,
        maxNrOfCacheObjects: 200, // Меньше объектов для больших изображений
      ),
    );
    return _fullImageCacheManager!;
  }

  /// Плейсхолдер по умолчанию
  static Widget _getDefaultPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Icon(
          Icons.image,
          color: Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  /// Виджет ошибки по умолчанию
  static Widget Function(BuildContext, String, dynamic) _getDefaultErrorWidget() {
    return (context, url, error) {
      _logger.warning('Image loading error for URL: $url', error);
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(
            Icons.broken_image,
            color: Colors.grey,
            size: 24,
          ),
        ),
      );
    };
  }

  /// Индикатор прогресса загрузки
  static Widget _getProgressIndicator(DownloadProgress downloadProgress) {
    return Center(
      child: CircularProgressIndicator(
        value: downloadProgress.progress,
        strokeWidth: 2,
      ),
    );
  }

  /// Предзагрузка изображений в кэш
  static Future<void> precacheImages(List<String> imageUrls, {bool thumbnail = true}) async {
    _logger.info('Precaching ${imageUrls.length} ${thumbnail ? 'thumbnail' : 'full'} images');
    
    final cacheManager = thumbnail ? _getThumbnailCacheManager() : _getFullImageCacheManager();
    
    for (final url in imageUrls) {
      try {
        await cacheManager.getSingleFile(url);
        _logger.fine('Precached image: $url');
      } catch (e) {
        _logger.warning('Failed to precache image: $url', e);
      }
    }
  }

  static Future<void> clearCache({bool thumbnails = true, bool fullImages = true}) async {
    _logger.info('Clearing image cache: thumbnails=$thumbnails, fullImages=$fullImages');
    
    if (thumbnails && _thumbnailCacheManager != null) {
      await _thumbnailCacheManager!.emptyCache();
    }
    
    if (fullImages && _fullImageCacheManager != null) {
      await _fullImageCacheManager!.emptyCache();
    }
  }

  static Map<String, bool> getCacheInfo() {
    return {
      'thumbnailCacheActive': _thumbnailCacheManager != null,
      'fullImageCacheActive': _fullImageCacheManager != null,
    };
  }

  static bool _isBrokenUrl(String url) {
    if (!_brokenUrls.contains(url)) return false;
    
    final timestamp = _brokenUrlTimestamps[url];
    if (timestamp == null) return false;
    
    // Если прошло достаточно времени, даем URL второй шанс
    if (DateTime.now().difference(timestamp) > _brokenUrlCacheTimeout) {
      _brokenUrls.remove(url);
      _brokenUrlTimestamps.remove(url);
      _errorCounts.remove(url); // Сбрасываем счетчик ошибок
      _logger.info('Даём второй шанс URL после таймаута: $url');
      return false;
    }
    
    return true;
  }

  static void _markAsBrokenUrl(String url) {
    // Увеличиваем счетчик ошибок
    _errorCounts[url] = (_errorCounts[url] ?? 0) + 1;
    
    // Блокируем URL только после нескольких ошибок
    if (_errorCounts[url]! >= _maxRetries) {
      _brokenUrls.add(url);
      _brokenUrlTimestamps[url] = DateTime.now();
      _logger.warning('URL заблокирован после $_maxRetries ошибок: $url');
    } else {
      _logger.info('Ошибка загрузки URL (${_errorCounts[url]}/$_maxRetries): $url');
    }
  }

  /// Очистить список битых URL (для отладки)
  static void clearBrokenUrls() {
    _brokenUrls.clear();
    _brokenUrlTimestamps.clear();
    _errorCounts.clear();
    _logger.info('Список битых URL и счетчики ошибок очищены');
  }
}