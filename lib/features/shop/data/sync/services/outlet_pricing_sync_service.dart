import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:http/http.dart' show Response;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';

import '../generated/sync.pb.dart';

/// Сервис для синхронизации дифференциальных цен для конкретных торговых точек
/// Отвечает за получение специфичных для точки цен через outlet-prices endpoint
class OutletPricingSyncService {
  static final Logger _logger = Logger('OutletPricingSyncService');
  static final GZipCodec _gzipCodec = GZipCodec();
  static final ZLibCodec _zlibCodec = ZLibCodec();
  static final ZLibCodec _zlibRawCodec = ZLibCodec(raw: true);
  
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
  Future<OutletSpecificCacheResponse> getOutletPrices(String outletVendorId) async {
    _logger.info('💰 Загрузка цен для торговой точки $outletVendorId');
    
    final url = '$_baseUrl/mobile-sync/outlet-prices/$outletVendorId';
    
    try {
      final payload = await _makeProtobufRequest(url, debugLabel: 'outlet:$outletVendorId');
  final priceData = _parseProtobufPayload(payload, debugLabel: 'outlet:$outletVendorId');

  final pricingCount = priceData.outletPricing.length;
  final promotionsCount = priceData.activePromotions.length;
  _logger.info('✅ Получено ${pricingCount} ценовых записей (акций: $promotionsCount) для точки $outletVendorId');
      
      return priceData;
    } catch (e, stackTrace) {
      _logger.severe('❌ Ошибка загрузки цен для точки $outletVendorId: $e', e, stackTrace);
      rethrow;
    }
  }

  /// Выполняет HTTP запрос с protobuf данными
  Future<Uint8List> _makeProtobufRequest(String url, {Uint8List? requestData, required String debugLabel}) async {
    // Создаем HTTP клиент с поддержкой самоподписанных сертификатов
  final ioClient = HttpClient()..autoUncompress = false;
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioClient);
    
    try {
      final uri = Uri.parse(url);
      
      final headers = <String, String>{
  'Accept': 'application/x-protobuf',
  'Accept-Encoding': 'gzip, deflate',
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
        return _processResponse(response, debugLabel: debugLabel);
        
      } else {
        _logger.info('🌐 GET запрос (без данных)');
        final response = await client.get(uri, headers: headers);
        
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
        return _processResponse(response, debugLabel: debugLabel);
      }
      
    } finally {
      client.close();
    }
  }

  /// 🔧 Обработка HTTP ответа с gzip и protobuf
  Uint8List _processResponse(Response response, {required String debugLabel}) {
    final Uint8List rawBytes = response.bodyBytes;
    var responseBytes = rawBytes;
    final String? contentEncoding = response.headers['content-encoding'];
    final String normalizedEncoding = contentEncoding?.toLowerCase() ?? '';

    if (normalizedEncoding == 'gzip') {
      try {
  responseBytes = Uint8List.fromList(_gzipCodec.decode(rawBytes));
        _logger.fine('📦 Данные распакованы из gzip');
      } catch (e, stackTrace) {
        throw ProtobufPayloadException(
          'Не удалось распаковать gzip-ответ',
          _buildDebugData(
            debugLabel: debugLabel,
            stage: 'gzip-decode',
            response: response,
            rawBytes: rawBytes,
            error: e,
            stackTrace: stackTrace,
          ),
        );
      }
    } else if (normalizedEncoding == 'deflate') {
      try {
  responseBytes = Uint8List.fromList(_zlibCodec.decode(rawBytes));
        _logger.fine('📦 Данные распакованы из deflate (zlib)');
      } catch (zlibError, zlibStack) {
        _logger.warning('⚠️ Стандартный ZLibCodec не смог распаковать deflate: $zlibError');
        try {
          responseBytes = Uint8List.fromList(_zlibRawCodec.decode(rawBytes));
          _logger.fine('📦 Данные распакованы из deflate (raw) после повторного прогона');
        } catch (rawError, rawStack) {
          throw ProtobufPayloadException(
            'Не удалось распаковать deflate-ответ',
            _buildDebugData(
              debugLabel: debugLabel,
              stage: 'deflate-decode',
              response: response,
              rawBytes: rawBytes,
              error: rawError,
              stackTrace: rawStack,
            )..addAll(<String, dynamic>{
                'zlibDecodeError': zlibError.toString(),
                'zlibDecodeStack': zlibStack.toString().split('\n').take(12).join('\n'),
              }),
          );
        }
      }
    }

    _logger.fine('📥 Получен protobuf ответ: ${_formatBytes(responseBytes.length)}');

    return responseBytes;
  }

  OutletSpecificCacheResponse _parseProtobufPayload(Uint8List payload, {required String debugLabel}) {
    try {
      return OutletSpecificCacheResponse.fromBuffer(payload);
    } catch (e, stackTrace) {
      throw ProtobufPayloadException(
        'Не удалось распарсить protobuf-ответ',
        <String, dynamic>{
          'debugLabel': debugLabel,
          'stage': 'protobuf-parse',
          'payloadLength': payload.length,
          'previewHex': _buildHexPreview(payload),
          'previewAscii': _buildAsciiPreview(payload),
          'error': e.toString(),
          'stackTrace': stackTrace.toString().split('\n').take(12).join('\n'),
        },
      );
    }
  }

  /// 🔍 Форматирование размера в байтах для логирования
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  Map<String, dynamic> _buildDebugData({
    required String debugLabel,
    required String stage,
    required Response response,
    required Uint8List rawBytes,
    required Object error,
    required StackTrace stackTrace,
  }) {
    return <String, dynamic>{
      'debugLabel': debugLabel,
      'stage': stage,
      'statusCode': response.statusCode,
      'contentEncoding': response.headers['content-encoding'],
      'contentType': response.headers['content-type'],
      'rawLength': rawBytes.length,
      'previewHex': _buildHexPreview(rawBytes),
      'previewAscii': _buildAsciiPreview(rawBytes),
      'headers': response.headers,
      'error': error.toString(),
      'stackTrace': stackTrace.toString().split('\n').take(12).join('\n'),
    };
  }

  String _buildHexPreview(Uint8List bytes, {int maxBytes = 96}) {
    final int length = math.min(maxBytes, bytes.length);
    final String preview = bytes.take(length).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    return bytes.length > maxBytes ? '$preview …' : preview;
  }

  String _buildAsciiPreview(Uint8List bytes, {int maxBytes = 160}) {
    final int length = math.min(maxBytes, bytes.length);
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < length; i++) {
      final int codeUnit = bytes[i];
      final bool isPrintable = codeUnit >= 32 && codeUnit <= 126;
      buffer.write(isPrintable ? String.fromCharCode(codeUnit) : '.');
    }
    if (bytes.length > maxBytes) {
      buffer.write(' …');
    }
    return buffer.toString();
  }
}

class ProtobufPayloadException implements Exception {
  ProtobufPayloadException(this.message, this.debugData);

  final String message;
  final Map<String, dynamic> debugData;

  @override
  String toString() => message;
}