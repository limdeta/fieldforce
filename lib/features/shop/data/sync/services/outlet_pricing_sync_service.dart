import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' show Response;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';

import '../generated/sync.pb.dart';

/// Сервис для синхронизации дифференциальных цен для конкретных торговых точек
/// Отвечает за получение специфичных для точки цен через outlet-prices endpoint
class OutletPricingSyncService {
  static final Logger _logger = Logger('OutletPricingSyncService');
  
  final String _baseUrl;
  String? _sessionCookie;
  
  OutletPricingSyncService({
    required String baseUrl,
    String? sessionCookie,
  }) : _baseUrl = baseUrl, _sessionCookie = sessionCookie;

  /// Получить дифференциальные цены для конкретной торговой точки
  /// 
  /// [outletVendorId] - Vendor ID торговой точки
  /// 
  /// Возвращает специфичные для точки цены
  Future<RegionalCacheResponse> getOutletPrices(String outletVendorId) async {
    _logger.info('💰 Загрузка цен для торговой точки $outletVendorId');
    
    final url = '$_baseUrl/mobile-sync/outlet-prices/$outletVendorId';
    
    try {
      final response = await _makeProtobufRequest(url);
      final priceData = RegionalCacheResponse.fromBuffer(response);
      
      _logger.info('✅ Получено цен для ${priceData.products.length} товаров');
      
      return priceData;
    } catch (e, stackTrace) {
      _logger.severe('❌ Ошибка загрузки цен для точки $outletVendorId: $e', e, stackTrace);
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
    // Обрабатываем gzip сжатие
    var responseBytes = response.bodyBytes;
    final contentEncoding = response.headers['content-encoding'];
    
    if (contentEncoding == 'gzip') {
      responseBytes = Uint8List.fromList(gzip.decode(responseBytes));
      _logger.fine('📦 Данные распакованы из gzip');
    }
    
    _logger.fine('📥 Получен protobuf ответ: ${_formatBytes(responseBytes.length)}');
    
    return responseBytes;
  }

  /// 🔍 Форматирование размера в байтах для логирования
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}