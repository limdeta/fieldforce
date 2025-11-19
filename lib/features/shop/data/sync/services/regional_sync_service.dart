// lib/features/shop/data/sync/services/regional_sync_service.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' show Response;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';

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
  /// [regionCode] - строковый идентификатор региона (например, P3V, M3V, K3V)
  Future<RegionalCacheResponse> getRegionalProducts(String regionCode) async {
    _logger.info('🌍 Начинаем загрузку продуктов региона: $regionCode');
    
    final url = '$_baseUrl/mobile-sync/regional/$regionCode';
    final startTime = DateTime.now();
    
    try {
      final response = await _makeProtobufRequest(url);
      
      _logger.info('📊 Пытаемся парсить protobuf данные размером ${response.length} байт');
      
      try {
        final regionalData = RegionalCacheResponse.fromBuffer(response);
        
        // 🔍 ДИАГНОСТИКА PROTOBUF ДАННЫХ
        _logger.info('📦 Protobuf данные успешно распакованы');
        _logger.info('📊 Количество продуктов: ${regionalData.products.length}');
        
        if (regionalData.products.isNotEmpty) {
          final firstProduct = regionalData.products.first;
          _logger.info('🔍 ПЕРВЫЙ ПРОДУКТ:');
          _logger.info('   code: ${firstProduct.code}');
          _logger.info('   bcode: ${firstProduct.bcode}');
          _logger.info('   hasCatalogId: ${firstProduct.hasCatalogId()}');
          _logger.info('   catalogId: ${firstProduct.catalogId}');
          _logger.info('   title: ${firstProduct.title}');
          _logger.info('   priceListCategoryId: ${firstProduct.priceListCategoryId}');
        }
        
        final duration = DateTime.now().difference(startTime);
        _logger.info(
          '✅ Региональные продукты загружены: ${regionalData.products.length} товаров '
          'за ${duration.inSeconds}с (размер: ${_formatBytes(response.length)})'
        );
        
        _logSyncStats(regionalData);
        
        return regionalData;
      } catch (protobufError) {
        _logger.severe('❌ Ошибка парсинга protobuf: $protobufError');
        _logger.info('🔍 Возможно, сервер вернул не protobuf данные');
        
        // Попробуем интерпретировать как текст для диагностики
        try {
          final textData = String.fromCharCodes(response.take(500)); // первые 500 символов
          _logger.info('📝 Данные как текст (первые 500 символов): $textData');
        } catch (_) {
          _logger.info('📝 Данные не являются текстом');
        }
        
        rethrow;
      }
      
    } catch (e, st) {
      _logger.severe('❌ Ошибка загрузки региональных продуктов для $regionCode', e, st);
      rethrow;
    }
  }

  /// Выполняет HTTP запрос с protobuf данными
  Future<Uint8List> _makeProtobufRequest(String url, {Uint8List? requestData}) async {
    // Создаем HTTP клиент с поддержкой самоподписанных сертификатов
  final ioClient = HttpClient()..autoUncompress = false;
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
      
      // Проверяем тип запроса
      if (requestData != null) {
        _logger.info('📤 POST запрос с данными (${requestData.length} байт)');
        final response = await client.post(uri, headers: headers, body: requestData);
        
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
        return _processResponse(response);
        
      } else {
        _logger.info('🌐 GET запрос (без данных)');
        final response = await client.get(uri, headers: headers);
        
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
        return _processResponse(response);
      }
      
    } finally {
      client.close();
    }
  }

  /// 🔧 Обработка HTTP ответа с gzip и protobuf
  Uint8List _processResponse(Response response) {
    // Диагностическая информация
    _logger.info('🔍 ДИАГНОСТИКА ОТВЕТА:');
    _logger.info('   Status Code: ${response.statusCode}');
    _logger.info('   Content-Length: ${response.headers['content-length'] ?? 'не указан'}');
    _logger.info('   Content-Type: ${response.headers['content-type'] ?? 'не указан'}');
    _logger.info('   Content-Encoding: ${response.headers['content-encoding'] ?? 'нет'}');
    _logger.info('   Размер тела: ${response.bodyBytes.length} байт');
    
    // Показываем первые байты для диагностики
    if (response.bodyBytes.isNotEmpty) {
      final firstBytes = response.bodyBytes.take(20).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      _logger.info('   Первые байты: $firstBytes');
    }
    
    // Обрабатываем gzip сжатие
    var responseBytes = response.bodyBytes;
    final contentEncoding = response.headers['content-encoding'];
    
    if (contentEncoding == 'gzip') {
      try {
        responseBytes = Uint8List.fromList(gzip.decode(responseBytes));
        _logger.info('✅ Данные успешно распакованы из gzip: ${responseBytes.length} байт');
      } catch (e) {
        _logger.warning('⚠️ Ошибка распаковки gzip, используем сырые данные: $e');
        // Если gzip не работает, используем сырые данные
        responseBytes = response.bodyBytes;
      }
    }
    
    _logger.fine('📥 Финальный размер данных: ${_formatBytes(responseBytes.length)}');
    
    return responseBytes;
  }

  /// Конвертирует protobuf Product в ProductInfo
  ProductInfo convertProductToInfo(Product pbProduct) {
    final canBuy = pbProduct.hasCanBuy() ? pbProduct.canBuy : true;
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
      canBuy: canBuy,
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