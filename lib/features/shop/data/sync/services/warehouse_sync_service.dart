import 'dart:io';
import 'dart:typed_data';

import 'package:http/io_client.dart';
import 'package:logging/logging.dart';

import '../generated/sync.pb.dart';

class WarehouseSyncService {
  static final Logger _logger = Logger('WarehouseSyncService');

  final String _baseUrl;
  String? _sessionCookie;

  WarehouseSyncService({
    required String baseUrl,
    String? sessionCookie,
  })  : _baseUrl = baseUrl,
        _sessionCookie = sessionCookie;

  set sessionCookie(String? cookie) => _sessionCookie = cookie;

  void setSessionCookie(String cookie) {
    _sessionCookie = cookie;
  }

  void clearSessionCookie() {
    _sessionCookie = null;
  }

  Future<WarehouseSyncResponse> fetchWarehouses({
    String? regionVendorId,
    int? lastSyncTimestamp,
  }) async {
    final url = '$_baseUrl/mobile-sync/warehouses';
    final queryParameters = <String, String>{
      'forceRefresh': 'false',
      'limit': '1000',
    };
    
    if (regionVendorId != null && regionVendorId.isNotEmpty) {
      queryParameters['regionVendorId'] = regionVendorId;
    }
    
    if (lastSyncTimestamp != null) {
      queryParameters['lastSyncTimestamp'] = lastSyncTimestamp.toString();
    }
    
    _logger.info('🏭 Запрос складов (region=$regionVendorId, params=$queryParameters)');
    
    final responseBytes = await _makeProtobufRequest(
      url,
      queryParameters: queryParameters,
    );
    try {
      final response = WarehouseSyncResponse.fromBuffer(responseBytes);
      _logger.info('🏭 Получено складов: ${response.warehouses.length} (ts=${response.syncTimestamp})');
      return response;
    } catch (e, stackTrace) {
      final previewBytes = responseBytes.take(40).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      _logger.severe('❌ Ошибка парсинга ответа складов: $e. Первые байты: $previewBytes', e, stackTrace);
      rethrow;
    }
  }

  Future<Uint8List> _makeProtobufRequest(
    String url, {
    Map<String, String>? queryParameters,
  }) async {
    final ioClient = HttpClient()..autoUncompress = false;
    ioClient.badCertificateCallback = (cert, host, port) => true;
    final client = IOClient(ioClient);

    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);
      final headers = <String, String>{
        'Accept': 'application/x-protobuf',
        'Accept-Encoding': 'gzip, deflate',
        'User-Agent': 'FieldForce-Mobile/1.0',
      };

      if (_sessionCookie != null && _sessionCookie!.isNotEmpty) {
        final fullCookie = _sessionCookie!.startsWith('PHPSESSID=')
            ? _sessionCookie!
            : 'PHPSESSID=$_sessionCookie';
        headers['Cookie'] = fullCookie;
      }

      final response = await client.get(uri, headers: headers);
      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}: ${response.reasonPhrase}', uri: uri);
      }

      var responseBytes = response.bodyBytes;
      final String? encodingHeader = response.headers['content-encoding'];
      final normalizedEncoding = encodingHeader?.toLowerCase() ?? '';

      _logger.info('🏭 Ответ склада: ${responseBytes.length} байт, encoding=$encodingHeader');
      if (responseBytes.isNotEmpty) {
        _logger.fine('🏭 Первые 16 байт (raw): ${responseBytes.take(16).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      }

      try {
        if (normalizedEncoding == 'gzip') {
          if (responseBytes.length >= 2 && responseBytes[0] == 0x1f && responseBytes[1] == 0x8b) {
            _logger.fine('🏭 Распаковка gzip ответа складов');
            responseBytes = Uint8List.fromList(gzip.decode(responseBytes));
            _logger.info('🏭 Gzip распакован: ${responseBytes.length} байт');
          } else {
            _logger.warning('⚠️ Заголовок gzip указан, но сигнатура не совпадает. Используем данные как есть.');
          }
        } else if (normalizedEncoding == 'deflate') {
          _logger.fine('🏭 Распаковка deflate ответа складов');
          try {
            responseBytes = Uint8List.fromList(ZLibCodec().decode(responseBytes));
          } catch (_) {
            responseBytes = Uint8List.fromList(ZLibCodec(raw: true).decode(responseBytes));
          }
          _logger.info('🏭 Deflate распакован: ${responseBytes.length} байт');
        }
      } catch (decodeError, decodeStack) {
        _logger.severe('❌ Не удалось распаковать ответ складов: $decodeError', decodeError, decodeStack);
        rethrow;
      }

      if (responseBytes.isNotEmpty) {
        _logger.fine('🏭 Первые 16 байт после распаковки: ${responseBytes.take(16).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}');
      }

      return responseBytes;
    } finally {
      client.close();
    }
  }
}
