import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:app_installer/app_installer.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import '../config/app_config.dart';

/// Сервис автообновлений с поддержкой:
/// - Семантического версионирования
/// - Скачивания с прогрессом  
/// - Автоматической установки APK на Android
/// - Получения версии из pubspec.yaml
class UpdateService {
  static final Logger _logger = Logger('UpdateService');
  
  // URL сервера обновлений - всегда один и тот же для всех окружений
  static String get updateUrl => AppConfig.updateServerUrl;

  static late PackageInfo _packageInfo;
  static Version? _currentVersion;
  static late Dio _dio;

  /// Инициализация сервиса - вызывать при старте приложения
  static Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
    _currentVersion = Version.parse(_packageInfo.version);
    _dio = Dio();
    
    _logger.info('🚀 UpdateService initialized');
    _logger.info('📱 Current version: ${_packageInfo.version}');
    _logger.info('🔗 Update URL: $updateUrl');
  }

  /// Проверить обновления если включено в конфиге
  static Future<void> checkForUpdatesIfEnabled(BuildContext context) async {
    if (!AppConfig.checkForUpdates) {
      _logger.info('⏸️ Проверка обновлений отключена в конфигурации');
      return;
    }

    if (_currentVersion == null) {
      _logger.warning('⚠️ Сервис не инициализирован, инициализируем...');
      await initialize();
      if (!context.mounted) {
        _logger.fine('Контекст размонтирован после инициализации, прекращаем проверку обновлений');
        return;
      }
    }

    await _checkForUpdates(context);
  }

  /// Проверить обновления принудительно (из настроек)
  static Future<void> checkForUpdatesManually(BuildContext context) async {
    if (_currentVersion == null) {
      await initialize();
      if (!context.mounted) {
        _logger.fine('Контекст размонтирован после инициализации (ручная проверка)');
        return;
      }
    }
    await _checkForUpdates(context);
  }

  static Future<void> _checkForUpdates(BuildContext context) async {
    _logger.info('🔍 Начинаем проверку обновлений...');
    final navigator = Navigator.of(context, rootNavigator: true);

    // Показываем диалог загрузки
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const AlertDialog(
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
      if (navigator.mounted) {
        navigator.pop();
      }

      if (!navigator.mounted) {
        return;
      }

      if (updateInfo != null) {
        _logger.info('✅ Найдено обновление: ${updateInfo.version}');
        _showUpdateDialog(navigator.context, updateInfo);
      } else {
        _logger.info('✅ Обновлений не найдено');
        _showNoUpdatesDialog(navigator.context);
      }
    } catch (e, stackTrace) {
      if (navigator.mounted) {
        navigator.pop();
      }
      _logger.severe('❌ Ошибка при проверке обновлений', e, stackTrace);
      if (navigator.mounted) {
        _showErrorDialog(navigator.context, e.toString());
      }
    }
  }

  static Future<UpdateInfo?> _fetchUpdateInfo() async {
    try {
      _logger.info('📡 Запрашиваем информацию с сервера: $updateUrl');
      
      final response = await _dio.get(
        updateUrl,
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _logger.fine('📥 Получен ответ: $data');
        
        final updateInfo = UpdateInfo.fromJson(data);
        
        // Сравниваем версии семантически
        if (updateInfo.version > _currentVersion!) {
          _logger.info('🆕 Доступно обновление: ${_currentVersion!} -> ${updateInfo.version}');
          return updateInfo;
        } else {
          _logger.info('✅ Текущая версия актуальна: ${_currentVersion!}');
          return null;
        }
      } else {
        throw Exception('Сервер вернул код: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('❌ Ошибка при запросе к серверу: $e');
      rethrow;
    }
  }

  /// Показать диалог с предложением обновиться
  static void _showUpdateDialog(BuildContext context, UpdateInfo updateInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.system_update,
              color: updateInfo.isRequired ? Colors.red : Colors.blue,
            ),
            const SizedBox(width: 10),
            Text(updateInfo.isRequired ? 'Обязательное обновление' : 'Доступно обновление'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Новая версия: ${updateInfo.version}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Текущая версия: ${_currentVersion!}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            if (updateInfo.changelog.isNotEmpty) ...[
              const Text(
                'Что нового:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(updateInfo.changelog),
              const SizedBox(height: 12),
            ],
            if (updateInfo.isRequired)
              const Text(
                '⚠️ Это обязательное обновление. Старая версия больше не поддерживается.',
                style: TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
        actions: [
          if (!updateInfo.isRequired)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Позже'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _startDownload(context, updateInfo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: updateInfo.isRequired ? Colors.red : null,
            ),
            child: Text(Platform.isAndroid ? 'Скачать и установить' : 'Скачать'),
          ),
        ],
      ),
    );
  }

  /// Начать скачивание обновления
  static Future<void> _startDownload(BuildContext context, UpdateInfo updateInfo) async {
    if (Platform.isAndroid && updateInfo.downloadUrl.endsWith('.apk')) {
      // Android APK - скачиваем и устанавливаем
      await _downloadAndInstallApk(context, updateInfo);
    } else {
      // Windows/iOS/другие - открываем в браузере
      await _openDownloadLink(updateInfo.downloadUrl);
    }
  }

  /// Скачать и установить APK на Android
  static Future<void> _downloadAndInstallApk(BuildContext context, UpdateInfo updateInfo) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final progressNotifier = ValueNotifier<double>(0.0);
    var dialogDismissed = false;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Скачивание обновления'),
          content: ValueListenableBuilder<double>(
            valueListenable: progressNotifier,
            builder: (_, value, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: value.clamp(0.0, 1.0)),
                const SizedBox(height: 16),
                Text('${(value * 100).toInt()}%'),
              ],
            ),
          ),
        ),
      );

      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        throw Exception('Не удалось получить директорию для загрузки обновления');
      }

      final fileName = 'fieldforce-${updateInfo.version}.apk';
      final filePath = '${dir.path}/$fileName';

      _logger.info('📥 Скачиваем APK: ${updateInfo.downloadUrl} -> $filePath');

      await _dio.download(
        updateInfo.downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total <= 0 || dialogDismissed) {
            return;
          }
          progressNotifier.value = received / total;
        },
      );

      if (navigator.mounted) {
        dialogDismissed = true;
        navigator.pop();
      }

      _logger.info('✅ APK скачан успешно');
      _logger.info('📲 Устанавливаем APK...');
      await AppInstaller.installApk(filePath);
      _logger.info('✅ APK установка инициирована');

    } catch (e, stackTrace) {
      dialogDismissed = true;
      if (navigator.mounted) {
        navigator.pop();
      }
      _logger.severe('❌ Ошибка при скачивании/установке APK', e, stackTrace);
      if (navigator.mounted) {
        _showErrorDialog(navigator.context, 'Ошибка при скачивании: $e');
      }
    } finally {
      progressNotifier.dispose();
    }
  }


  /// Открыть ссылку для скачивания в браузере
  static Future<void> _openDownloadLink(String downloadUrl) async {
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
          'У вас установлена актуальная версия приложения: ${_currentVersion!}',
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

    if (error.contains('DioException')) {
      if (error.contains('CONNECT_TIMEOUT') || error.contains('RECEIVE_TIMEOUT')) {
        userFriendlyMessage = 'Время ожидания истекло.\nПроверьте подключение к интернету.';
      } else if (error.contains('CONNECTION_ERROR')) {
        userFriendlyMessage = 'Сервер обновлений недоступен.\nПопробуйте позже.';
      } else {
        userFriendlyMessage = 'Ошибка сети при проверке обновлений.';
      }
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
}

/// Модель информации об обновлении
class UpdateInfo {
  final Version version;
  final String changelog;
  final String downloadUrl;
  final bool isRequired;
  final Version? minSupportedVersion;

  UpdateInfo({
    required this.version,
    required this.changelog,
    required this.downloadUrl,
    this.isRequired = false,
    this.minSupportedVersion,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: Version.parse(json['version']),
      changelog: json['changelog'] ?? '',
      downloadUrl: json['download_url'],
      isRequired: json['required'] ?? false,
      minSupportedVersion: json['min_supported_version'] != null
          ? Version.parse(json['min_supported_version'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version.toString(),
      'changelog': changelog,
      'download_url': downloadUrl,
      'required': isRequired,
      'min_supported_version': minSupportedVersion?.toString(),
    };
  }
}