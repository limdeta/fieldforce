import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

/// Менеджер сессий для работы с PHPSESSID куками
/// Сохраняет и восстанавливает сессионные куки между запросами
class SessionManager {
  static final Logger _logger = Logger('SessionManager');
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
      _logger.fine('SessionManager: Получен заголовок Set-Cookie');
      // Set-Cookie может содержать запятые в части Expires, поэтому не делаем split(',')
      // Ищем PHPSESSID с помощью regex по всему заголовку
      final sessionCookie = _extractSessionCookie(setCookieHeader);
      if (sessionCookie != null) {
  _sessionCookie = sessionCookie;
  await _persistSessionCookie(sessionCookie);
  _logger.fine('SessionManager: Сессионная кука сохранена');
      } else {
        _logger.info('SessionManager: PHPSESSID не найден в Set-Cookie');
      }
    }
  }

  Future<Map<String, String>> getSessionHeaders() async {
    // Важно: восстанавливаем куку если она еще не загружена
    if (_sessionCookie == null) {
      _logger.info('SessionManager: Кука не загружена, восстанавливаем из SharedPreferences...');
      await _restoreSessionCookie();
    }

    final headers = <String, String>{};

    if (_sessionCookie != null) {
      headers['Cookie'] = _sessionCookie!;
      _logger.info('SessionManager: Возвращаем сессионные заголовки с кукой');
    } else {
      _logger.warning('SessionManager: ⚠️ Сессионная кука отсутствует! Возвращаем пустые заголовки');
    }

    return headers;
  }

  String? getSessionCookie() {
    _logger.fine('SessionManager: Запрошена сессионная кука: ${_sessionCookie != null ? 'есть' : 'нет'}');
    return _sessionCookie;
  }

  Future<bool> hasActiveSession() async {
    // Восстанавливаем куку если она еще не загружена
    if (_sessionCookie == null) {
      await _restoreSessionCookie();
    }
    
    final hasSession = _sessionCookie != null && _sessionCookie!.isNotEmpty;
    _logger.fine('SessionManager: hasActiveSession = $hasSession');
    return hasSession;
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
    final regex = RegExp(r'(PHPSESSID=[^;]+)');
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
      _logger.info('SessionManager: Сессионная кука восстановлена из SharedPreferences');
    } else {
      _logger.warning('SessionManager: Сессионная кука не найдена в хранилище');
    }
  }
}