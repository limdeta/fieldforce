import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:fixnum/fixnum.dart';

import '../generated/sync.pb.dart';

/// Сервис для синхронизации остатков товаров по региону
/// Отвечает за обновление цен и остатков на складах в регионе
class StockSyncService {
  static final Logger _logger = Logger('StockSyncService');
  
  final String _baseUrl;
  String? _sessionCookie;
  
  StockSyncService({
    required String baseUrl,
    String? sessionCookie,
  }) : _baseUrl = baseUrl, _sessionCookie = sessionCookie;

  /// Обновляет остатки товаров для региона через regional-stock endpoint
  /// 
  /// [regionFiasId] - FIAS код региона
  /// [lastUpdate] - время последнего обновления остатков (null для полной синхронизации)
  /// 
  /// Возвращает количество обновленных записей
  Future<int> syncRegionalStock(
    String regionFiasId, {
    DateTime? lastUpdate,
  }) async {
    _logger.info('📦 Синхронизация остатков для региона $regionFiasId');
    
    final request = RegionalCacheRequest()
      ..regionFiasId = regionFiasId
      ..lastSyncTimestamp = Int64(lastUpdate?.millisecondsSinceEpoch ?? 0)
      ..forceRefresh = lastUpdate == null; // Полная синхронизация если время не указано
    
    final url = '$_baseUrl/v1_api/mobile-sync/regional-stock/$regionFiasId';
    
    try {
      final response = await _makeProtobufRequest(url, requestData: request.writeToBuffer());
      final stockData = RegionalCacheResponse.fromBuffer(response);
      
      _logger.info('✅ Получено ${stockData.products.length} товаров с данными остатков');
      
      // TODO: Сохранение данных в локальную БД через repository
      // TODO: Конвертация protobuf -> domain entities
      
      return stockData.products.length;
    } catch (e, stackTrace) {
      _logger.severe('❌ Ошибка синхронизации остатков: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Получает дифференциальные цены для торговой точки
  /// 
  /// [outletId] - ID торговой точки
  /// [productCodes] - список кодов товаров
  /// 
  /// Используется для получения специфичных для точки цен
  Future<int> getOutletSpecificPricing(
    int outletId,
    List<int> productCodes,
  ) async {
    _logger.info('💰 Запрос цен для ${productCodes.length} товаров в точке $outletId');
    
    final request = OutletSpecificRequest()
      ..productCodes.addAll(productCodes);
    
    final url = '$_baseUrl/v1_api/mobile-sync/outlet-pricing/$outletId';
    
    try {
      await _makeProtobufRequest(url, requestData: request.writeToBuffer());
      // TODO: Парсинг ответа после уточнения protobuf структуры
      
      _logger.info('✅ Получены дифференциальные цены для точки $outletId');
      
      // TODO: Обработка ответа и сохранение цен
      return productCodes.length;
    } catch (e, stackTrace) {
      _logger.severe('❌ Ошибка получения цен: $e', e, stackTrace);
      rethrow;
    }
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