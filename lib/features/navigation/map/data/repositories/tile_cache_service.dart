import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:logging/logging.dart';

/// Сервис для кеширования тайлов карты
class TileCacheService {
  static final Logger _logger = Logger('TileCacheService');
  static DefaultCacheManager? _cacheManager;
  static TileProvider? _tileProvider;

  /// Получить провайдер тайлов с кешированием
  static TileProvider getTileProvider() {
    if (_tileProvider != null) return _tileProvider!;

    _cacheManager ??= DefaultCacheManager();
    _tileProvider = CachedNetworkTileProvider();
    _logger.info('🗺️ Создаем провайдер тайлов с кешированием');
    return _tileProvider!;
  }

  static TileProvider getTileProviderWithCaching({required bool enableCaching}) {
    if (enableCaching) {
      return getTileProvider();
    } else {
      _logger.info('🗺️ Используем провайдер без кеширования');
      return NetworkTileProvider();
    }
  }

  static Future<void> clearCache() async {
    await _cacheManager?.emptyCache();
    _logger.info('🗑️ Кэш тайлов очищен');
  }
}

class CachedNetworkTileProvider extends TileProvider {
  final DefaultCacheManager _cacheManager;

  CachedNetworkTileProvider()
      : _cacheManager = DefaultCacheManager();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    return CachedTileImageProvider(
      url: url,
      cacheManager: _cacheManager,
      headers: headers,
    );
  }
}

/// ImageProvider для кешированных тайлов
class CachedTileImageProvider extends ImageProvider<CachedTileImageProvider> {
  final String url;
  final DefaultCacheManager cacheManager;
  final Map<String, String>? headers;
  final Logger _logger = Logger('CachedTileImageProvider');

  // Кеширование placeholder изображения для избежания повторного создания
  static ImageInfo? _cachedPlaceholder;
  // Счетчик placeholder'ов для мониторинга
  static int _placeholderCount = 0;

  CachedTileImageProvider({
    required this.url,
    required this.cacheManager,
    this.headers,
  });

  @override
  Future<CachedTileImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<CachedTileImageProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(CachedTileImageProvider key, ImageDecoderCallback decode) {
    return OneFrameImageStreamCompleter(_loadAsync(key, decode));
  }

  Future<ImageInfo> _loadAsync(CachedTileImageProvider key, ImageDecoderCallback decode) async {
    final tileName = _extractTileNameFromUrl(url);

    // Пытаемся загрузить до 3 раз
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        // Проверяем кэш
        final fileInfo = await cacheManager.getFileFromCache(url);

        if (fileInfo != null) {
          final file = fileInfo.file;
          final exists = await file.exists();
          final length = exists ? await file.length() : 0;

          if (exists && length > 0) {
            if (length < 1000) {
              _logger.warning('⚠️ Кешированный файл слишком маленький, удаляем: $tileName');
              await cacheManager.removeFile(url);
            } else {
              try {
                final Uint8List bytes = await file.readAsBytes();
                final codec = await ui.instantiateImageCodec(bytes);
                final frame = await codec.getNextFrame();
                _logger.finer('💾 Тайл из кеша: $tileName');
                return ImageInfo(image: frame.image);
              } catch (decodeError) {
                _logger.warning('⚠️ Поврежденный кеш, удаляем файл: $tileName - $decodeError');
                await cacheManager.removeFile(url);
              }
            }
          } else {
            _logger.warning('⚠️ Файл кеша существует но пустой или поврежденный: $tileName');
          }
        }

        // Загружаем из сети
        if (attempt > 1) {
          _logger.info('🔄 Повторная попытка $attempt/3 загрузки: $tileName');
        }

        final file = await cacheManager.getSingleFile(url, headers: headers);
        final bytes = await file.readAsBytes();

        // Проверяем, что файл является валидным изображением
        if (bytes.length <= 103) {
          _placeholderCount++;
          _logger.finer('OSM placeholder #$_placeholderCount detected (${bytes.length} bytes), returning placeholder');
          // Вместо исключения возвращаем серое placeholder изображение
          return _createPlaceholderImage();
        }

        // Проверяем, что можем декодировать изображение
        try {
          final codec = await ui.instantiateImageCodec(bytes);
          final frame = await codec.getNextFrame();
          final imageInfo = ImageInfo(image: frame.image);

          _logger.finer('✅ Тайл закеширован: $tileName');
          return imageInfo;
        } catch (decodeError) {
          _logger.warning('⚠️ Не удалось декодировать изображение, возможно поврежденный тайл: $tileName - $decodeError');
          // Удаляем из кеша поврежденный файл
          await cacheManager.removeFile(url);
          if (attempt == 3) {
            throw Exception('Failed to decode image after 3 attempts: $decodeError');
          }
          continue; // Пробуем еще раз
        }

      } catch (e, stackTrace) {
        if (attempt == 3) {
          _logger.severe('❌ Ошибка загрузки тайла после 3 попыток $tileName: $e', e, stackTrace);
          rethrow;
        } else {
          _logger.warning('⚠️ Попытка $attempt не удалась для $tileName: $e');
          // Небольшая задержка перед повторной попыткой
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }

    // Этот код никогда не должен выполняться, но на всякий случай
    throw Exception('Unexpected end of _loadAsync for $tileName');
  }

  Future<ImageInfo> _createPlaceholderImage() async {
    if (_cachedPlaceholder != null) return _cachedPlaceholder!;

    // Создаем серое изображение 256x256 для placeholder
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Colors.grey[300]!;

    canvas.drawRect(const Rect.fromLTWH(0, 0, 256, 256), paint);

    // Добавляем иконку карты в центр
    const iconSize = 48.0;

    // Простой способ нарисовать иконку - рисуем круг с буквой M
    final iconPaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(128, 128), iconSize / 2, iconPaint);

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'M',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(128 - textPainter.width / 2, 128 - textPainter.height / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(256, 256);
    _cachedPlaceholder = ImageInfo(image: image);
    return _cachedPlaceholder!;
  }

  String _extractTileNameFromUrl(String url) {
    // Извлекаем имя тайла из URL типа https://tile.openstreetmap.org/12/2254/1302.png
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    if (segments.length >= 3) {
      final z = segments[segments.length - 3];
      final x = segments[segments.length - 2];
      final y = segments[segments.length - 1].split('.').first;
      return '$z/$x/$y.png';
    }
    return url.split('/').last;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is CachedTileImageProvider && other.url == url;
  }

  @override
  int get hashCode => url.hashCode;
}