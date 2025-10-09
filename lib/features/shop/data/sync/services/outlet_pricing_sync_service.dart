import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:fixnum/fixnum.dart';

import '../generated/sync.pb.dart';

/// Сервис для синхронизации дифференциальных цен для конкретных торговых точек
/// Отвечает за получение и кэширование специфичных для точки цен и остатков
class OutletPricingSyncService {
  static final Logger _logger = Logger('OutletPricingSyncService');
  
  final String _baseUrl;
  String? _sessionCookie;
  
  OutletPricingSyncService({
    required String baseUrl,
    String? sessionCookie,
  }) : _baseUrl = baseUrl, _sessionCookie = sessionCookie;

  /// Синхронизирует дифференциальные цены для конкретной торговой точки
  /// 
  /// [outletId] - ID торговой точки
  /// [productCodes] - список кодов товаров (null для всех товаров)
  /// [lastUpdate] - время последнего обновления (null для полной синхронизации)
  /// 
  /// Возвращает количество обновленных ценовых записей
  Future<int> syncOutletPricing(
    int outletId, {
    List<int>? productCodes,
    DateTime? lastUpdate,
  }) async {
    _logger.info('💰 Синхронизация цен для торговой точки $outletId');
    
    final request = OutletSpecificRequest();
    
    if (productCodes != null && productCodes.isNotEmpty) {
      request.productCodes.addAll(productCodes);
      _logger.fine('🎯 Синхронизация для ${productCodes.length} конкретных товаров');
    } else {
      _logger.fine('📦 Полная синхронизация всех товаров точки');
    }
    
    final url = '$_baseUrl/v1_api/mobile-sync/outlet-pricing/$outletId';
    
    try {
      final response = await _makeProtobufRequest(url, requestData: request.writeToBuffer());
      // TODO: Парсинг ответа OutletSpecificResponse после уточнения protobuf структуры
      
      _logger.info('✅ Получены дифференциальные цены для точки $outletId');
      
      // TODO: Сохранение цен в локальную БД через repository
      // TODO: Конвертация protobuf -> domain entities
      
      // Заглушка - возвращаем количество запрошенных товаров
      return productCodes?.length ?? 100; // Предполагаем ~100 товаров для полной синхронизации
    } catch (e, stackTrace) {
      _logger.severe('❌ Ошибка синхронизации цен для точки $outletId: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Получает текущие цены для списка товаров в конкретной точке
  /// 
  /// [outletId] - ID торговой точки
  /// [productCodes] - список кодов товаров для проверки цен
  /// 
  /// Используется для точечных проверок цен при добавлении в корзину
  Future<Map<int, double>> getCurrentPrices(
    int outletId,
    List<int> productCodes,
  ) async {
    _logger.info('🔍 Запрос текущих цен для ${productCodes.length} товаров в точке $outletId');
    
    final request = OutletSpecificRequest()
      ..productCodes.addAll(productCodes);
    
    final url = '$_baseUrl/v1_api/mobile-sync/outlet-pricing/$outletId/current';
    
    try {
      await _makeProtobufRequest(url, requestData: request.writeToBuffer());
      // TODO: Парсинг ответа и формирование Map<productCode, price>
      
      _logger.info('✅ Получены текущие цены для ${productCodes.length} товаров');
      
      // TODO: Реальная обработка ответа
      // Заглушка - возвращаем пример цен
      final prices = <int, double>{};
      for (final code in productCodes) {
        prices[code] = 100.0 + (code % 50); // Пример цены
      }
      
      return prices;
    } catch (e, stackTrace) {
      _logger.severe('❌ Ошибка получения цен: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Выполняет batch-обновление цен для нескольких торговых точек
  /// 
  /// [outletIds] - список ID торговых точек
  /// [productCodes] - список кодов товаров (null для всех товаров)
  /// 
  /// Используется для массовых обновлений цен в регионе
  Future<Map<int, int>> batchSyncOutletPricing(
    List<int> outletIds,
    List<int>? productCodes,
  ) async {
    _logger.info('📊 Batch-синхронизация цен для ${outletIds.length} точек');
    
    final results = <int, int>{};
    
    // Выполняем синхронизацию последовательно для избежания перегрузки сервера
    for (final outletId in outletIds) {
      try {
        final count = await syncOutletPricing(
          outletId,
          productCodes: productCodes,
        );
        results[outletId] = count;
        
        // Небольшая задержка между запросами
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        _logger.warning('⚠️ Не удалось синхронизировать цены для точки $outletId: $e');
        results[outletId] = 0;
      }
    }
    
    _logger.info('✅ Batch-синхронизация завершена: ${results.values.fold(0, (a, b) => a + b)} записей');
    
    return results;
  }

  /// Выполняет HTTP запрос с protobuf данными
  Future<Uint8List> _makeProtobufRequest(
    String url, {
    Uint8List? requestData,
  }) async {
    // Создаем HTTP клиент с поддержкой самоподписанных сертификатов
    final ioClient = HttpClient();
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioClient);
    
    try {
      final uri = Uri.parse(url);
      
      final headers = <String, String>{
        'Accept': 'application/x-protobuf',
        'Accept-Encoding': 'gzip',
        'Content-Type': 'application/x-protobuf',
        'User-Agent': 'FieldForce/1.0 (Mobile)',
      };
      
      // Добавляем сессионную куку если есть
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
      
      _logger.fine('📥 Получен ответ ${response.statusCode} (${response.contentLength} байт)');
      
      if (response.statusCode != 200) {
        throw HttpException(
          'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          uri: uri,
        );
      }
      
      // Обрабатываем gzip-сжатые данные
      var responseBytes = response.bodyBytes;
      if (response.headers['content-encoding'] == 'gzip') {
        _logger.fine('📦 Распаковка gzip данных');
        responseBytes = Uint8List.fromList(gzip.decode(responseBytes));
      }
      
      _logger.fine('✅ Protobuf данные получены (${responseBytes.length} байт)');
      return responseBytes;
      
    } finally {
      client.close();
    }
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