import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';

/// Простой сервис автообновлений используя библиотеку upgrader
/// Но с кастомным источником обновлений (ваш сервер)
class SimpleUpdateService {
  static final Logger _logger = Logger('SimpleUpdateService');
  static const String UPDATE_URL = 'https://your-server.com/fieldforce/version.json';
  static const String CURRENT_VERSION = '1.0.0'; // Текущая версия
  
  /// Проверить обновления если включено в конфиге
  static Future<void> checkForUpdatesIfEnabled(BuildContext context) async {
    if (!AppConfig.checkForUpdates) {
      // Проверка обновлений отключена в конфигурации
      return;
    }
    
    // Проверяем обновления...
    await _checkForUpdates(context);
  }

  static Future<void> _checkForUpdates(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Text('Проверка обновлений'),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Проверяем наличие обновлений...'),
          ],
        ),
      ),
    );
    
    try {
      final updateInfo = await _fetchUpdateInfo();
      Navigator.pop(context); // Закрыть диалог загрузки
      
      if (updateInfo != null) {
        _showUpdateDialog(context, updateInfo);
      } else {
        _showNoUpdatesDialog(context);
      }
    } catch (e) {
      Navigator.pop(context); // Закрыть диалог загрузки при ошибке
      _showErrorDialog(context, e.toString());
    }
  }

  static Future<Map<String, dynamic>?> _fetchUpdateInfo() async {
    try {
      final response = await http.get(Uri.parse(UPDATE_URL))
          .timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Проверяем нужно ли обновление
        if (data['version'] != CURRENT_VERSION) {
          // Найдено обновление
          return data;
        } else {
          // Версия актуальна - возвращаем null
          return null;
        }
      } else {
        throw Exception('Сервер вернул код: ${response.statusCode}');
      }
    } catch (e) {
      // Перебрасываем ошибку для обработки в UI
      rethrow;
    }
  }
  
  /// Показать диалог с предложением обновиться
  static void _showUpdateDialog(BuildContext context, Map<String, dynamic> updateInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Colors.blue),
            SizedBox(width: 10),
            Text('Доступно обновление'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Новая версия: ${updateInfo['version']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Текущая версия: $CURRENT_VERSION',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(updateInfo['changelog'] ?? 'Новые улучшения и исправления'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже'),
          ),
          ElevatedButton(
            onPressed: () {
              _downloadUpdate(updateInfo['download_url']);
              Navigator.pop(context);
            },
            child: const Text('Скачать'),
          ),
        ],
      ),
    );
  }
  
  /// Скачать обновление (открыть в браузере)
  static Future<void> _downloadUpdate(String url) async {
    try {
      // Открываем ссылку для скачивания
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        // Не удается открыть ссылку
      }
    } catch (e) {
      // Ошибка при открытии ссылки
    }
  }
  
  /// Показать диалог "обновлений нет"
  static void _showNoUpdatesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Обновлений нет'),
          ],
        ),
        content: Text(
          'У вас установлена актуальная версия приложения: $CURRENT_VERSION',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  /// Показать диалог ошибки
  static void _showErrorDialog(BuildContext context, String error) {
    String userFriendlyMessage;
    
    if (error.contains('TimeoutException')) {
      userFriendlyMessage = 'Не удалось подключиться к серверу обновлений.\nПроверьте подключение к интернету.';
    } else if (error.contains('SocketException')) {
      userFriendlyMessage = 'Сервер обновлений недоступен.\nПопробуйте позже.';
    } else if (error.contains('FormatException')) {
      userFriendlyMessage = 'Получены некорректные данные с сервера обновлений.';
    } else {
      userFriendlyMessage = 'Произошла ошибка при проверке обновлений.\nПопробуйте позже.';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Ошибка проверки'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(userFriendlyMessage),
            const SizedBox(height: 12),
            const Text(
              'Техническая информация:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              error,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
  
  /// Открытие ссылки для скачивания обновления
  Future<void> downloadUpdate(String downloadUrl) async {
    try {
      _logger.info('📱 Открываем ссылку для скачивания: $downloadUrl');
      
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        _logger.info('✅ Ссылка открыта в браузере');
      } else {
        _logger.warning('❌ Не удалось открыть ссылку: $downloadUrl');
        throw Exception('Не удалось открыть ссылку для скачивания');
      }
    } catch (e) {
      _logger.severe('❌ Ошибка при открытии ссылки: $e');
      rethrow;
    }
  }
}

/// Widget обёртка для использования библиотеки upgrader с App Store/Google Play
/// Используется как fallback если ваш сервер недоступен
class UpgraderWrapper extends StatelessWidget {
  final Widget child;
  
  const UpgraderWrapper({
    super.key,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!AppConfig.checkForUpdates) {
      return child; // Проверка обновлений отключена
    }
    
    return UpgradeAlert(
      child: child,
    );
  }
}
