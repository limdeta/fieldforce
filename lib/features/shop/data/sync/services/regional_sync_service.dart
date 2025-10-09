// lib/features/shop/data/sync/services/regional_sync_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:fixnum/fixnum.dart';

import '../generated/sync.pb.dart';
import '../generated/product.pb.dart';
import '../models/product_with_price.dart';

/// Сервис для синхронизации региональных данных (продукты без цен)
/// 
/// Выполняется утром 1 раз в день:
/// - Загружает все продукты региона (~7000 товаров)
/// - Использует protobuf для эффективной передачи данных
/// - Сжатие gzip для минимизации трафика
class RegionalSyncService {
  static final Logger _logger = Logger('RegionalSyncService');
  
  final String _baseUrl;
  String? _sessionCookie;

  RegionalSyncService({
    required String baseUrl,
    String? sessionCookie,
  }) : _baseUrl = baseUrl,
       _sessionCookie = sessionCookie;

  /// 🌍 ЭТАП 1: Получить все продукты региона (БЕЗ остатков и цен)
  /// 
  /// Размер: ~15-25 МБ (сжато)
  /// Частота: 1 раз в день утром
  Future<RegionalCacheResponse> getRegionalProducts(String regionFiasId) async {
    _logger.info('🌍 Начинаем загрузку продуктов региона: $regionFiasId');
    
    final url = '$_baseUrl/v1_api/mobile-sync/regional/$regionFiasId';
    final startTime = DateTime.now();
    
    try {
      final response = await _makeProtobufRequest(url);
      final regionalData = RegionalCacheResponse.fromBuffer(response);
      
      final duration = DateTime.now().difference(startTime);
      _logger.info(
        '✅ Региональные продукты загружены: ${regionalData.products.length} товаров '
        'за ${duration.inSeconds}с (размер: ${_formatBytes(response.length)})'
      );
      
      _logSyncStats(regionalData);
      
      return regionalData;
      
    } catch (e, st) {
      _logger.severe('❌ Ошибка загрузки региональных продуктов для $regionFiasId', e, st);
      rethrow;
    }
  }

  /// 🔄 Постраничная загрузка для больших регионов
  /// 
  /// Используется если регион содержит >10,000 товаров
  Future<List<Product>> getRegionalProductsPaginated(
    String regionFiasId, {
    int pageSize = 1000,
    Function(int current, int total)? onProgress,
  }) async {
    _logger.info('📄 Постраничная загрузка продуктов региона: $regionFiasId');
    
    final allProducts = <Product>[];
    int offset = 0;
    bool hasMore = true;
    
    while (hasMore) {
      try {
        final request = RegionalCacheRequest()
          ..regionFiasId = regionFiasId
          ..limit = pageSize
          ..offset = offset
          ..lastSyncTimestamp = Int64(0); // Полная синхронизация
        
        final url = '$_baseUrl/v1_api/mobile-sync/regional/$regionFiasId';
        final response = await _makeProtobufRequest(url, requestData: request.writeToBuffer());
        final pageData = RegionalCacheResponse.fromBuffer(response);
        
        allProducts.addAll(pageData.products);
        hasMore = pageData.hasMore;
        offset += pageSize;
        
        onProgress?.call(allProducts.length, pageData.stats.productsCount);
        
        _logger.fine('📄 Загружена страница: +${pageData.products.length} товаров '
                    '(всего: ${allProducts.length})');
        
      } catch (e) {
        _logger.warning('⚠️ Ошибка загрузки страницы $offset: $e');
        break;
      }
    }
    
    _logger.info('✅ Постраничная загрузка завершена: ${allProducts.length} товаров');
    return allProducts;
  }

  /// 🔍 Инкрементальная синхронизация (только измененные продукты)
  /// 
  /// Используется для обновления продуктов без полной перезагрузки
  Future<RegionalCacheResponse> getRegionalProductsDelta(
    String regionFiasId, 
    DateTime lastSyncTime,
  ) async {
    _logger.info('🔄 Инкрементальная синхронизация продуктов с ${lastSyncTime.toIso8601String()}');
    
    final request = RegionalCacheRequest()
      ..regionFiasId = regionFiasId
      ..lastSyncTimestamp = Int64(lastSyncTime.millisecondsSinceEpoch)
      ..forceRefresh = false;
    
    final url = '$_baseUrl/v1_api/mobile-sync/regional/$regionFiasId';
    
    try {
      final response = await _makeProtobufRequest(url, requestData: request.writeToBuffer());
      final deltaData = RegionalCacheResponse.fromBuffer(response);
      
      _logger.info(
        '✅ Получены изменения: ${deltaData.products.length} обновленных товаров'
      );
      
      return deltaData;
      
    } catch (e, st) {
      _logger.severe('❌ Ошибка инкрементальной синхронизации для $regionFiasId', e, st);
      rethrow;
    }
  }

  /// Выполняет HTTP запрос с protobuf данными
  Future<Uint8List> _makeProtobufRequest(String url, {Uint8List? requestData}) async {
    // Создаем HTTP клиент с поддержкой самоподписанных сертификатов
    final ioClient = HttpClient();
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioClient);
    
    try {
      final uri = Uri.parse(url);
      
      final headers = <String, String>{
        'Accept': 'application/x-protobuf',
        'Accept-Encoding': 'gzip',
        'User-Agent': 'FieldForce-Mobile/1.0',
      };
      
      // Добавляем сессионную куку
      if (_sessionCookie != null && _sessionCookie!.isNotEmpty) {
        final fullCookie = _sessionCookie!.startsWith('PHPSESSID=')
            ? _sessionCookie!
            : 'PHPSESSID=$_sessionCookie';
        headers['Cookie'] = fullCookie;
        _logger.fine('🍪 Используется сессионная кука');
      }
      
      _logger.fine('📤 Отправка protobuf запроса к $uri');
      
      final response = requestData != null
          ? await client.post(uri, headers: headers, body: requestData)
          : await client.get(uri, headers: headers);
      
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
      
      // Обрабатываем gzip сжатие
      var responseBytes = response.bodyBytes;
      final contentEncoding = response.headers['content-encoding'];
      
      if (contentEncoding == 'gzip') {
        responseBytes = Uint8List.fromList(gzip.decode(responseBytes));
        _logger.fine('📦 Данные распакованы из gzip');
      }
      
      _logger.fine('📥 Получен protobuf ответ: ${_formatBytes(responseBytes.length)}');
      
      return responseBytes;
      
    } finally {
      client.close();
    }
  }

  /// Конвертирует protobuf Product в ProductInfo
  ProductInfo convertProductToInfo(Product pbProduct) {
    return ProductInfo(
      code: pbProduct.code,
      bcode: pbProduct.bcode,
      title: pbProduct.title,
      vendorCode: pbProduct.vendorCode,
      barcodes: pbProduct.barcodes,
      isMarked: pbProduct.isMarked,
      novelty: pbProduct.novelty,
      popular: pbProduct.popular,
      amountInPackage: pbProduct.amountInPackage,
      canBuy: pbProduct.canBuy,
      brandName: pbProduct.hasBrand() ? pbProduct.brand.name : null,
      manufacturerName: pbProduct.hasManufacturer() ? pbProduct.manufacturer.name : null,
      categoryName: pbProduct.hasCategory() ? pbProduct.category.name : null,
      typeName: pbProduct.hasType() ? pbProduct.type.name : null,
      seriesName: pbProduct.hasSeries() ? pbProduct.series.name : null,
      defaultImageUrl: pbProduct.hasDefaultImage() ? pbProduct.defaultImage.uri : null,
      imageUrls: pbProduct.images.map((img) => img.uri).toList(),
      description: pbProduct.description.isNotEmpty ? pbProduct.description : null,
      howToUse: pbProduct.howToUse.isNotEmpty ? pbProduct.howToUse : null,
      ingredients: pbProduct.ingredients.isNotEmpty ? pbProduct.ingredients : null,
    );
  }

  /// Логирует статистику синхронизации
  void _logSyncStats(RegionalCacheResponse response) {
    if (response.hasStats()) {
      final stats = response.stats;
      _logger.info(
        '📊 Статистика синхронизации:\n'
        '   Регион: ${stats.regionFiasId}\n'
        '   Продукты: ${stats.productsCount}\n'
        '   Остатки: ${stats.stockItemsCount}\n'
        '   Размер кеша: ${_formatBytes(stats.cacheSizeBytes.toInt())}\n'
        '   Время генерации: ${stats.generationTimeSeconds.toStringAsFixed(2)}с\n'
        '   Версия кеша: ${response.cacheVersion}'
      );
    }
  }

  /// Форматирует размер в байтах
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  /// Устанавливает сессионную куку для аутентификации
  void setSessionCookie(String cookie) {
    _sessionCookie = cookie;
    _logger.fine('🔐 Установлена сессионная кука');
  }

  /// Очищает сессионную куку
  void clearSession() {
    _sessionCookie = null;
    _logger.fine('🚪 Сессия очищена');
  }
}