import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// Менеджер сессий для работы с PHPSESSID куками
/// Сохраняет и восстанавливает сессионные куки между запросами
class SessionManager {
  static final Logger _logger = Logger('PostAuthenticationService');
  static const String _sessionCookieKey = 'php_session_cookie';
  static const String _sessionDataKey = 'session_data';

  static SessionManager? _instance;
  http.Client? _client;
  String? _sessionCookie;

  SessionManager._();

  static SessionManager get instance {
    _instance ??= SessionManager._();
    return _instance!;
  }

  Future<http.Client> getSessionClient() async {
    if (_client != null) {
      return _client!;
    }

    // Создаем HTTP клиент с поддержкой самоподписанных сертификатов
    // TODO убрать самоподписаные сертификаты на проде!
    final ioClient = HttpClient();
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    _client = IOClient(ioClient);

    await _restoreSessionCookie();

    return _client!;
  }

  Future<void> saveSessionCookie(http.Response response) async {
    final setCookieHeader = response.headers['set-cookie'];
    if (setCookieHeader != null) {
      _logger.info('SessionManager: Получен заголовок Set-Cookie: $setCookieHeader');
      // Ищем PHPSESSID куку
      final cookies = setCookieHeader.split(',');
      for (final cookie in cookies) {
        if (cookie.contains('PHPSESSID=')) {
          final sessionCookie = _extractSessionCookie(cookie);
          if (sessionCookie != null) {
            _sessionCookie = sessionCookie;
            await _persistSessionCookie(sessionCookie);
            _logger.info('SessionManager: Сохранена сессионная кука: $sessionCookie');
            break;
          }
        }
      }
    }
  }

  Map<String, String> getSessionHeaders() {
    final headers = <String, String>{};

    if (_sessionCookie != null) {
      final cookieHeader = 'PHPSESSID=$_sessionCookie';
      headers['Cookie'] = cookieHeader;
       _logger.info('SessionManager: Отправляем заголовок Cookie: $cookieHeader');
    }

    return headers;
  }

  bool hasActiveSession() {
    return _sessionCookie != null && _sessionCookie!.isNotEmpty;
  }

  Future<void> clearSession() async {
    _sessionCookie = null;
    _client?.close();
    _client = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionCookieKey);
    await prefs.remove(_sessionDataKey);

    _logger.info('SessionManager: Сессия очищена');
  }

  String? _extractSessionCookie(String cookieString) {
    final regex = RegExp(r'PHPSESSID=([^;]+)');
    final match = regex.firstMatch(cookieString);
    return match?.group(1);
  }

  Future<void> _persistSessionCookie(String cookie) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionCookieKey, cookie);
  }

  Future<void> _restoreSessionCookie() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionCookie = prefs.getString(_sessionCookieKey);
    if (_sessionCookie != null) {
      _logger.info('SessionManager: Восстановлена сессионная кука: $_sessionCookie');
    } else {
      _logger.info('⚠️ SessionManager: Сессионная кука не найдена в хранилище');
    }
  }
}