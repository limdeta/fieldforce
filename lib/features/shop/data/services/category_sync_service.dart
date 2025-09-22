import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:isolate';
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';

import '../../../../shared/models/sync_config.dart';
import '../../../../shared/models/sync_progress.dart';
import '../../../../shared/models/sync_result.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/entities/category.dart';

/// Абстрактный сервис синхронизации категорий
abstract class CategorySyncService {
  /// Синхронизирует категории согласно конфигурации
  Future<SyncResult> syncCategories(
    SyncConfig config,
    SendPort progressPort,
    CategoryRepository categoryRepository,
  );
}

/// Реализация синхронизации категорий через API
class ApiCategorySyncService implements CategorySyncService {
  static final Logger _logger = Logger('ApiCategorySyncService');

  final String _apiUrl;
  final String? _sessionCookie;

  ApiCategorySyncService({
    required String apiUrl,
    required String? sessionCookie,
  }) : _apiUrl = apiUrl,
       _sessionCookie = sessionCookie;

  @override
  Future<SyncResult> syncCategories(
    SyncConfig config,
    SendPort progressPort,
    CategoryRepository categoryRepository,
  ) async {
    _logger.info('Начало синхронизации категорий через API');

    final startTime = DateTime.now();
    int successCount = 0;
    int errorCount = 0;

    try {
      // Делаем HTTP запрос к API
      final response = await _makeApiRequest(config);

      // Логируем полный ответ для отладки
      _logger.info('Полный JSON ответ от API: ${response.substring(0, min(500, response.length))}...');

      // Парсим категории из JSON
      final categories = _parseCategoriesFromJson(response);
      _logger.info('Получено ${categories.length} категорий из API');

      // Сохраняем категории в базу данных
      _logger.info('Сохранение ${categories.length} категорий в базу данных...');

      final saveResult = await categoryRepository.saveCategories(categories);
      saveResult.fold(
        (failure) => throw Exception('Ошибка сохранения категорий: $failure'),
        (_) => _logger.info('Категории успешно сохранены'),
      );

      successCount = categories.length;

      // Отправляем финальный прогресс
      final progress = SyncProgress(
        type: 'categories',
        current: successCount,
        total: successCount,
        status: 'Синхронизация завершена',
        percentage: 1.0,
      );
      progressPort.send(progress);

      final duration = DateTime.now().difference(startTime);
      return SyncResult.success(
        type: 'categories',
        successCount: successCount,
        duration: duration,
        startTime: startTime,
      );

    } catch (e, st) {
      _logger.severe('Ошибка синхронизации категорий', e, st);
      errorCount++;

      final duration = DateTime.now().difference(startTime);
      return SyncResult.withErrors(
        type: 'categories',
        successCount: successCount,
        errorCount: errorCount,
        errors: [e.toString()],
        duration: duration,
        startTime: startTime,
      );
    }
  }

  Future<String> _makeApiRequest(SyncConfig config) async {
    if (_apiUrl.isEmpty) {
      throw Exception('URL API категорий не настроен');
    }

    // Создаем HTTP клиент с поддержкой самоподписанных сертификатов
    final ioClient = HttpClient();
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioClient);

    try {
      final uri = Uri.parse(_apiUrl);

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'User-Agent': 'FieldForce-Mobile/1.0',
      };

      // Добавляем сессионную куку
      if (_sessionCookie != null && _sessionCookie.isNotEmpty) {
        headers['Cookie'] = 'PHPSESSID=$_sessionCookie';
        _logger.info('Используем сессионную куку: PHPSESSID=${_sessionCookie.substring(0, min(10, _sessionCookie.length))}...');
      } else {
        _logger.warning('Сессионная кука не установлена!');
      }

      _logger.info('Отправка запроса к $uri');

      final response = await client.get(uri, headers: headers);
      _logger.info('Получен ответ: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      final responseString = response.body;
      _logger.info('Размер ответа: ${responseString.length} символов');
      return responseString;

    } finally {
      client.close();
    }
  }

  /// Парсит категории из JSON ответа API
  List<Category> _parseCategoriesFromJson(String jsonString) {
    try {
      final jsonData = jsonDecode(jsonString) as List<dynamic>;
      return jsonData.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка парсинга JSON категорий: $e');
    }
  }
}

class JsonDumpCategorySyncService implements CategorySyncService {
  @override
  Future<SyncResult> syncCategories(
    SyncConfig config,
    SendPort progressPort,
    CategoryRepository categoryRepository,
  ) async {
    // TODO: Реализовать импорт из JSON файла
    throw UnimplementedError('JSON импорт пока не реализован');
  }
}

/// Фабрика для создания сервиса синхронизации категорий
class CategorySyncServiceFactory {
  static CategorySyncService create(
    SyncConfig config,
    String apiUrl,
    String? sessionCookie,
  ) {
    switch (config.source) {
      case SyncDataSource.api:
        return ApiCategorySyncService(
          apiUrl: apiUrl,
          sessionCookie: sessionCookie,
        );
      case SyncDataSource.jsonFile:
        return JsonDumpCategorySyncService();
      case SyncDataSource.archive:
        return JsonDumpCategorySyncService(); // Пока используем тот же
    }
  }
}