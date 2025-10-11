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
      'forceRefresh': 'true',
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
    final response = WarehouseSyncResponse.fromBuffer(responseBytes);

    _logger.info('🏭 Получено складов: ${response.warehouses.length} (ts=${response.syncTimestamp})');
    return response;
  }

  Future<Uint8List> _makeProtobufRequest(
    String url, {
    Map<String, String>? queryParameters,
  }) async {
    final ioClient = HttpClient();
    ioClient.badCertificateCallback = (cert, host, port) => true;
    final client = IOClient(ioClient);

    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParameters);
      final headers = <String, String>{
        'Accept': 'application/x-protobuf',
        'Accept-Encoding': 'gzip',
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

      _logger.info('🏭 Ответ склада: ${response.bodyBytes.length} байт, encoding=${response.headers['content-encoding']}');
      return response.bodyBytes;
    } finally {
      client.close();
    }
  }
}
