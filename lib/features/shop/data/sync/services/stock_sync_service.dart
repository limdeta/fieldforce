import 'dart:io';
import 'dart:typed_data';
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';

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

  /// Получить остатки товаров для региона  
  /// 
  /// [regionCode] - строковый код региона (например, P3V, M3V, K3V)
  /// 
  /// Возвращает остатки товаров на складах в регионе
  Future<RegionalStockResponse> getRegionalStock(String regionCode) async {
    _logger.info('📦 Загрузка остатков для региона $regionCode');
    
    final url = '$_baseUrl/mobile-sync/regional-stock/$regionCode';
    Uint8List? responseBytes;
    
    try {
      responseBytes = await _makeProtobufRequest(url);
      
      // Диагностика данных перед парсингом
      _logger.info('🔍 Размер буфера остатков: ${responseBytes.length} байт');
      if (responseBytes.length < 10) {
        _logger.warning('⚠️ Слишком маленький размер ответа для протобуф');
        _logger.info('📋 Первые байты: ${responseBytes.take(responseBytes.length).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      } else {
        _logger.info('📋 Первые 10 байт: ${responseBytes.take(10).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
        _logger.info('📋 Последние 10 байт: ${responseBytes.skip(responseBytes.length - 10).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      }
      
      final stockData = RegionalStockResponse.fromBuffer(responseBytes);
      
      _logger.info('✅ Получено остатков для ${stockData.stockItems.length} товаров');
      
      // Диагностика первых элементов
      if (stockData.stockItems.isNotEmpty) {
        _logger.info('🔍 ДИАГНОСТИКА первых 3 StockItems из protobuf:');
        for (int i = 0; i < stockData.stockItems.take(3).length; i++) {
          final item = stockData.stockItems[i];
          _logger.info('  [$i] productCode=${item.productCode}, stock=${item.stock}, hasStock=${item.hasStock()}, publicStock="${item.publicStock}"');
        }
        
        // Проверим есть ли элементы с stock > 0
        final itemsWithStock = stockData.stockItems.where((item) => item.stock > 0).toList();
        _logger.info('🔍 Элементов с stock > 0: ${itemsWithStock.length} из ${stockData.stockItems.length}');
        
        if (itemsWithStock.isNotEmpty) {
          _logger.info('🔍 Примеры элементов с stock > 0:');
          for (int i = 0; i < itemsWithStock.take(3).length; i++) {
            final item = itemsWithStock[i];
            _logger.info('  productCode=${item.productCode}, stock=${item.stock}, publicStock="${item.publicStock}"');
          }
        }
      }
      
      return stockData;
    } catch (e, stackTrace) {
      if (e.toString().contains('Protocol message end-group tag')) {
        _logger.severe('❌ Ошибка парсинга protobuf - неправильный формат данных от сервера');
        _logger.info('🔍 Проверьте что сервер возвращает правильный RegionalStockResponse в ответе на /mobile-sync/regional-stock/');
        
        // Попробуем прочитать как текст для диагностики
        if (responseBytes != null) {
          try {
            final textContent = String.fromCharCodes(responseBytes.take(200));
            _logger.info('🔍 Начало ответа как текст: "$textContent"');
          } catch (textError) {
            _logger.info('🔍 Не удалось прочитать ответ как текст');
          }
        }
      }
      
  _logger.severe('❌ Ошибка загрузки остатков: $e', e, stackTrace);
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
      final isGzipCompressed = response.headers['content-encoding'] == 'gzip';
      
      _logger.info('🔍 Content-Encoding: ${response.headers['content-encoding']}');
      _logger.info('🔍 Content-Type: ${response.headers['content-type']}');
      _logger.info('🔍 Content-Length: ${response.headers['content-length']}');
      _logger.info('🔍 Размер сырых данных: ${responseBytes.length} байт');
      
      // Проверяем начало данных ДО gzip декодирования
      if (responseBytes.isNotEmpty) {
        _logger.info('🔍 Первые 20 байт СЫРЫХ данных: ${responseBytes.take(20).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
        
        // Проверяем корректность gzip заголовка
        if (isGzipCompressed && responseBytes.length >= 2) {
          final gzipMagic = responseBytes[0] == 0x1f && responseBytes[1] == 0x8b;
          _logger.fine('🔍 Gzip Magic Number корректен: $gzipMagic (ожидается 1f 8b)');
          
          if (!gzipMagic) {
            _logger.fine('⚠️ Сервер указывает gzip, но данные не сжаты - используем как есть');
            // Попробуем прочитать как текст
            try {
              final textContent = String.fromCharCodes(responseBytes.take(200));
              _logger.fine('🔍 Начало ответа как текст: "$textContent"');
            } catch (textError) {
              _logger.fine('🔍 Не удалось прочитать ответ как текст');
            }
          }
        }
      }
      
      if (isGzipCompressed) {
        // Проверяем действительно ли данные сжаты gzip
        if (responseBytes.length >= 2 && responseBytes[0] == 0x1f && responseBytes[1] == 0x8b) {
          try {
            _logger.fine('📦 Распаковка gzip данных');
            responseBytes = Uint8List.fromList(gzip.decode(responseBytes));
            _logger.info('✅ Gzip данные успешно распакованы (${responseBytes.length} байт)');
          } catch (e) {
            _logger.severe('❌ Критическая ошибка распаковки gzip: $e');
            _logger.info('🔍 Первые 50 байт сырых данных: ${responseBytes.take(50).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
            rethrow;
          }
        } else {
          _logger.fine('⚠️ Сервер указал content-encoding=gzip, но данные не сжаты. Используем как есть.');
          _logger.info('� Вероятно ошибка конфигурации веб-сервера - он указывает gzip когда данные не сжаты');
        }
      }
      
      // Проверяем валидность protobuf данных
      if (responseBytes.isEmpty) {
        _logger.warning('⚠️ Пустой ответ от сервера');
      } else if (responseBytes.length < 2) {
        _logger.warning('⚠️ Слишком короткий ответ для protobuf');
      } else {
        _logger.info('🔍 Первые 10 байт после обработки: ${responseBytes.take(10).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
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