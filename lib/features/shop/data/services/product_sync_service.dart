import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:isolate';
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';

import '../../../../shared/models/sync_config.dart';
import '../../../../shared/models/sync_progress.dart';
import '../../../../shared/models/sync_result.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/stock_item_repository.dart';
import 'product_parsing_service.dart';

abstract class ProductSyncService {
  Future<SyncResult> syncProducts(
    SyncConfig config,
    SendPort progressPort,
    ProductRepository productRepository,
    StockItemRepository stockItemRepository,
  );
}

class ApiProductSyncService implements ProductSyncService {
  static final Logger _logger = Logger('ApiProductSyncService');
  
  final String _apiUrl;
  final String? _sessionCookie;
  final ProductParsingService _parsingService = ProductParsingService();

  ApiProductSyncService({
    required String apiUrl, 
    required String? sessionCookie,
  }) : _apiUrl = apiUrl, 
       _sessionCookie = sessionCookie;

  @override
  Future<SyncResult> syncProducts(
    SyncConfig config,
    SendPort progressPort,
    ProductRepository productRepository,
    StockItemRepository stockItemRepository,
  ) async {
    _logger.info('Начало синхронизации продуктов через API');

    final startTime = DateTime.now();
    int successCount = 0;
    int errorCount = 0;

    try {
      // Делаем HTTP запрос к API
      final response = await _makeApiRequest(config);
      
      // Логируем краткую информацию
      _logger.info('Полный JSON ответ от API: ${response.substring(0, min(200, response.length))}...');
      
      final apiResponse = _parsingService.parseProductApiResponse(response);
      _logger.info('Получено ${apiResponse.products.length} продуктов из API');
      
      // Проверяем наличие stockItems в каждом продукте
      int productsWithStockItems = 0;
      int totalStockItems = 0;
      for (final product in apiResponse.products) {
        if (product.stockItems.isNotEmpty) {
          productsWithStockItems++;
          totalStockItems += product.stockItems.length;
        }
      }
      _logger.info('📊 Продукты с stockItems: $productsWithStockItems/${apiResponse.products.length}, всего stockItems: $totalStockItems');
      
      // Конвертируем продукты
      final convertedProducts = _parsingService.convertApiItemsToProducts(apiResponse.products);
      _logger.info('Конвертировано ${convertedProducts.length} продуктов');
      
      // Сохраняем продукты и stock items в базу данных
      _logger.info('Сохранение ${convertedProducts.length} продуктов в базу данных...');
      
      final products = convertedProducts.map((data) => data.product).toList();
      final allStockItems = convertedProducts.expand((data) => data.stockItems).toList();
      _logger.info('📦 Извлечено ${allStockItems.length} stock_items из ${convertedProducts.length} продуктов');
      
      // Сохраняем продукты
      final productSaveResult = await productRepository.saveProducts(products);
      productSaveResult.fold(
        (failure) => throw Exception('Ошибка сохранения продуктов: ${failure.message}'),
        (_) => _logger.info('Продукты успешно сохранены'),
      );
      
      // Сохраняем stock items
      if (allStockItems.isNotEmpty) {
        _logger.info('💾 Сохраняем ${allStockItems.length} stock_items...');
        final stockSaveResult = await stockItemRepository.saveStockItems(allStockItems);
        stockSaveResult.fold(
          (failure) => throw Exception('Ошибка сохранения остатков: ${failure.message}'),
          (_) => _logger.info('Stock items успешно сохранены (${allStockItems.length} записей)'),
        );
      } else {
        _logger.warning('⚠️ Stock items отсутствуют! allStockItems.isEmpty = true');
      }
      
      successCount = convertedProducts.length;
      
      // Отправляем финальный прогресс
      final progress = SyncProgress(
        type: 'products',
        current: successCount,
        total: apiResponse.totalCount,
        status: 'Синхронизация завершена',
        percentage: 1.0,
      );
      progressPort.send(progress);

      final duration = DateTime.now().difference(startTime);
      return SyncResult.success(
        type: 'products',
        successCount: successCount,
        duration: duration,
        startTime: startTime,
      );

    } catch (e, st) {
      _logger.severe('Ошибка синхронизации продуктов', e, st);
      errorCount++;

      final duration = DateTime.now().difference(startTime);
      return SyncResult.withErrors(
        type: 'products',
        successCount: successCount,
        errorCount: errorCount,
        errors: [e.toString()],
        duration: duration,
        startTime: startTime,
      );
    }
  }

  /// Выполняет HTTP запрос к API продуктов
  Future<String> _makeApiRequest(SyncConfig config) async {
    if (_apiUrl.isEmpty) {
      throw Exception('URL API продуктов не настроен');
    }

    // Создаем HTTP клиент с поддержкой самоподписанных сертификатов
    final ioClient = HttpClient();
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioClient);

    try {
      // Формируем URI с query параметрами
      final queryParams = <String, String>{};
      
      if (config.categories != null && config.categories!.isNotEmpty) {
        queryParams['categories'] = config.categories!;
      }
      
      queryParams['limit'] = config.limit.toString();
      queryParams['offset'] = config.offset.toString();
      
      final uri = Uri.parse(_apiUrl).replace(queryParameters: queryParams);
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'User-Agent': 'FieldForce-Mobile/1.0',
      };

      // Добавляем сессионную куку
      if (_sessionCookie != null && _sessionCookie.isNotEmpty) {
        final fullCookie = _sessionCookie.startsWith('PHPSESSID=') 
            ? _sessionCookie 
            : 'PHPSESSID=$_sessionCookie';
        headers['Cookie'] = fullCookie;
        _logger.info('Используем сессионную куку: $fullCookie');
      } else {
        _logger.warning('Сессионная кука не установлена!');
      }

      _logger.info('Отправка запроса к ');
      
      final response = await client.get(uri, headers: headers);
      _logger.info('Получен ответ: ');

      if (response.statusCode != 200) {
        throw Exception('HTTP : ');
      }

      final responseString = response.body;
      _logger.info('Размер ответа:  символов');
      return responseString;

    } finally {
      client.close();
    }
  }
}

class JsonDumpProductSyncService implements ProductSyncService {
  @override
  Future<SyncResult> syncProducts(
    SyncConfig config,
    SendPort progressPort,
    ProductRepository productRepository,
    StockItemRepository stockItemRepository,
  ) async {
    // TODO: Реализовать импорт из JSON файла
    throw UnimplementedError('JSON импорт пока не реализован');
  }
}

class ArchiveProductSyncService implements ProductSyncService {
  @override
  Future<SyncResult> syncProducts(
    SyncConfig config,
    SendPort progressPort,
    ProductRepository productRepository,
    StockItemRepository stockItemRepository,
  ) async {
    // TODO: Реализовать импорт из архива
    throw UnimplementedError('Архивный импорт пока не реализован');
  }
}

class ProductSyncServiceFactory {
  static ProductSyncService create(
    SyncConfig config, 
    String apiUrl, 
    String? sessionCookie,
  ) {
    switch (config.source) {
      case SyncDataSource.api:
        return ApiProductSyncService(
          apiUrl: apiUrl, 
          sessionCookie: sessionCookie,
        );
      case SyncDataSource.jsonFile:
        return JsonDumpProductSyncService();
      case SyncDataSource.archive:
        return ArchiveProductSyncService();
    }
  }
}
