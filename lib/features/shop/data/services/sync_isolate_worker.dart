// lib/features/shop/data/services/sync_isolate_worker.dart

import 'dart:async';
import 'dart:isolate';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:http/io_client.dart';

import 'sync_messages.dart';
import 'product_parsing_service.dart';
import '../../domain/entities/category.dart' as cat;


/// Точка входа для worker изолята синхронизации
/// 
/// Этот изолят выполняет тяжелые операции синхронизации в фоне,
/// не блокируя главный UI поток. Он получает команды от главного изолята
/// и отправляет обратно прогресс и результаты. 
void syncWorkerEntryPoint(SendPort sendPortToMain) async {
  developer.log('🚀 Sync Worker: Изолят запущен', name: 'SyncWorker');

  final receivePortInWorker = ReceivePort();
  
  sendPortToMain.send(receivePortInWorker.sendPort);
  
  // Отправляем сигнал об успешной инициализации
  sendPortToMain.send(SyncMessage(
    type: SyncResponses.initialized,
    data: {'timestamp': DateTime.now().millisecondsSinceEpoch},
  ).toJson());

  // Создаем экземпляр worker'а для обработки команд
  final worker = SyncWorker(sendPortToMain);
  
  // Слушаем команды от главного изолята
  await for (final message in receivePortInWorker) {
    try {
      if (message is Map<String, dynamic>) {
        final syncMessage = SyncMessage.fromJson(message);
        await worker.handleCommand(syncMessage);
        
        // Если получили команду завершения, выходим из цикла
        if (syncMessage.type == SyncCommands.shutdown) {
          break;
        }
      }
    } catch (e, stackTrace) {
      developer.log(
        '❌ Sync Worker: Ошибка обработки сообщения: $e',
        name: 'SyncWorker',
        error: e,
        stackTrace: stackTrace,
      );
      
      sendPortToMain.send(SyncMessage(
        type: SyncResponses.error,
        data: {
          'syncType': 'worker',
          'error': e.toString(),
          'stackTrace': stackTrace.toString(),
        },
      ).toJson());
    }
  }

  developer.log('👋 Sync Worker: Изолят завершает работу', name: 'SyncWorker');
  receivePortInWorker.close();
}

/// Класс для обработки команд синхронизации в worker изоляте
class SyncWorker {
  final SendPort _sendPortToMain;
  final ProductParsingService _parsingService = ProductParsingService();
  
  Timer? _heartbeatTimer;
  bool _isPaused = false;
  bool _isCancelled = false;

  SyncWorker(this._sendPortToMain) {
    _startHeartbeat();
  }

  /// Запускает отправку heartbeat сообщений каждые 5 секунд
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _sendPortToMain.send(SyncMessage(
        type: SyncResponses.heartbeat,
        data: {
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'isPaused': _isPaused,
          'isCancelled': _isCancelled,
        },
      ).toJson());
    });
  }

  /// Обрабатывает команду от главного изолята
  Future<void> handleCommand(SyncMessage message) async {
    developer.log('📨 Sync Worker: Получена команда ${message.type}', name: 'SyncWorker');

    switch (message.type) {
      case SyncCommands.startProductSync:
        await _handleProductSync(message.data);
        break;
        
      case SyncCommands.startCategorySync:
        await _handleCategorySync(message.data);
        break;
        
      case SyncCommands.pauseSync:
        _handlePause();
        break;
        
      case SyncCommands.resumeSync:
        _handleResume();
        break;
        
      case SyncCommands.cancelSync:
        _handleCancel();
        break;
        
      case SyncCommands.shutdown:
        _handleShutdown();
        break;
        
      default:
        developer.log('⚠️ Sync Worker: Неизвестная команда ${message.type}', name: 'SyncWorker');
    }
  }

  /// Обрабатывает синхронизацию продуктов
  Future<void> _handleProductSync(Map<String, dynamic> data) async {
    if (_isCancelled) return;

    final startTime = DateTime.now();
    developer.log('🛍️ Sync Worker: Начинаем постраничную синхронизацию продуктов', name: 'SyncWorker');

    try {
      final configData = data['config'] as Map<String, dynamic>;
      final apiUrl = data['apiUrl'] as String;
      final sessionHeaders = data['sessionHeaders'] as Map<String, dynamic>?;

      // Устанавливаем размер страницы для постраничной загрузки
      const int pageSize = 100; // Загружаем по 100 продуктов за раз
      int currentOffset = 0;
      int totalImported = 0;
      int? totalCount;
      
      _sendProgress('products', 1, 100, 'Получение информации о количестве продуктов...');
      
      // Сначала делаем запрос для получения totalCount
      final firstPageConfig = Map<String, dynamic>.from(configData);
      firstPageConfig['limit'] = pageSize;
      firstPageConfig['offset'] = currentOffset;
      
      final firstResponse = await _makeProductApiRequest(apiUrl, firstPageConfig, sessionHeaders);
      
      if (_isCancelled) return;
      
      // Парсим первую страницу чтобы узнать totalCount
      final firstApiResponse = _parsingService.parseProductApiResponse(firstResponse);
      totalCount = firstApiResponse.totalCount;
      
      developer.log('� Sync Worker: Всего продуктов к импорту: $totalCount', name: 'SyncWorker');
      
      // Обрабатываем первую страницу
      final firstPageJson = json.decode(firstResponse) as Map<String, dynamic>;
      if (!firstPageJson.containsKey('data')) {
        throw Exception('Ответ API не содержит поля "data". Доступные поля: ${firstPageJson.keys}');
      }
      
      final firstPageProducts = firstPageJson['data'] as List<dynamic>;
      totalImported += firstPageProducts.length;
      
      developer.log('� Worker: Отправляем первую страницу (${firstPageProducts.length} продуктов)', name: 'SyncWorker');
      
      _sendPortToMain.send(SyncMessage(
        type: 'save_products',
        data: {
          'apiItems': firstPageProducts,
        },
      ).toJson());
      
      // Обновляем прогресс
      final progressPercent = ((totalImported / totalCount) * 100).round();
      _sendProgress('products', progressPercent, 100, 'Загружено $totalImported из $totalCount продуктов...');
      
      currentOffset += pageSize;
      
      // Загружаем остальные страницы
      while (currentOffset < totalCount && !_isCancelled) {
        developer.log('📄 Sync Worker: Загружаем страницу с offset=$currentOffset', name: 'SyncWorker');
        
        final pageConfig = Map<String, dynamic>.from(configData);
        pageConfig['limit'] = pageSize;
        pageConfig['offset'] = currentOffset;
        
        final pageResponse = await _makeProductApiRequest(apiUrl, pageConfig, sessionHeaders);
        
        if (_isCancelled) return;
        
        final pageJsonData = json.decode(pageResponse) as Map<String, dynamic>;
        final pageProducts = pageJsonData['data'] as List<dynamic>;
        
        if (pageProducts.isEmpty) {
          developer.log('📄 Sync Worker: Получена пустая страница, завершаем загрузку', name: 'SyncWorker');
          break;
        }
        
        totalImported += pageProducts.length;
        
        developer.log('📤 Worker: Отправляем страницу (${pageProducts.length} продуктов)', name: 'SyncWorker');
        
        _sendPortToMain.send(SyncMessage(
          type: 'save_products',
          data: {
            'apiItems': pageProducts,
          },
        ).toJson());
        
        // Обновляем прогресс
        final progressPercent = ((totalImported / totalCount) * 100).round();
        _sendProgress('products', progressPercent, 100, 'Загружено $totalImported из $totalCount продуктов...');
        
        currentOffset += pageSize;
        
        // Небольшая пауза между запросами чтобы не перегрузить сервер
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      if (_isCancelled) return;
      
      // Отправляем финальный результат
      final duration = DateTime.now().difference(startTime);
      _sendPortToMain.send(createResultMessage(
        syncType: 'products',
        success: true,
        successCount: totalImported,
        durationMs: duration.inMilliseconds,
      ).toJson());

      developer.log('✅ Sync Worker: Постраничная синхронизация завершена. Импортировано: $totalImported/$totalCount продуктов', name: 'SyncWorker');

    } catch (e, stackTrace) {
      developer.log(
        '❌ Sync Worker: Ошибка синхронизации продуктов: $e',
        name: 'SyncWorker',
        error: e,
        stackTrace: stackTrace,
      );
      
      _sendPortToMain.send(createErrorMessage(
        syncType: 'products',
        error: e.toString(),
        stackTrace: stackTrace.toString(),
      ).toJson());
    }
  }

  /// Обрабатывает синхронизацию категорий  
  Future<void> _handleCategorySync(Map<String, dynamic> data) async {
    if (_isCancelled) return;

    final startTime = DateTime.now();
    developer.log('📂 Sync Worker: Начинаем синхронизацию категорий', name: 'SyncWorker');

    try {
      final configData = data['config'] as Map<String, dynamic>;
      final apiUrl = data['apiUrl'] as String;
      final sessionHeaders = data['sessionHeaders'] as Map<String, dynamic>?;

      developer.log('🔧 Categories config: $configData', name: 'SyncWorker');
      developer.log('🌐 Categories API URL: $apiUrl', name: 'SyncWorker');
      developer.log('🔒 Categories session headers: ${sessionHeaders?.keys}', name: 'SyncWorker');

      _sendProgress('categories', 1, 2, 'Загрузка категорий...');
      
      final response = await _makeCategoryApiRequest(apiUrl, configData, sessionHeaders);
      developer.log('📥 Categories response length: ${response.length} chars', name: 'SyncWorker');
      
      if (_isCancelled) return;
      
      _sendProgress('categories', 2, 2, 'Парсинг категорий...');
      
      final categories = _parseCategoriesFromJson(response);
      developer.log('📂 Parsed categories count: ${categories.length}', name: 'SyncWorker');

      // Отправляем результат
      final duration = DateTime.now().difference(startTime);
      _sendPortToMain.send(createResultMessage(
        syncType: 'categories',
        success: true,
        successCount: categories.length,
        durationMs: duration.inMilliseconds,
      ).toJson());

      // Отправляем данные для сохранения
      _sendPortToMain.send(SyncMessage(
        type: 'save_categories',
        data: {
          'categories': categories.map((cat) => _categoryToJson(cat)).toList(),
        },
      ).toJson());

      developer.log('✅ Sync Worker: Синхронизация категорий завершена', name: 'SyncWorker');

    } catch (e, stackTrace) {
      developer.log(
        '❌ Sync Worker: Ошибка синхронизации категорий: $e',
        name: 'SyncWorker',
        error: e,
        stackTrace: stackTrace,
      );
      
      _sendPortToMain.send(createErrorMessage(
        syncType: 'categories',
        error: e.toString(),
        stackTrace: stackTrace.toString(),
      ).toJson());
    }
  }

  Future<String> _makeProductApiRequest(
    String apiUrl,
    Map<String, dynamic> configData,
    Map<String, dynamic>? sessionHeaders,
  ) async {
    if (apiUrl.isEmpty) {
      throw Exception('URL API продуктов не настроен');
    }

    final ioClient = HttpClient();
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioClient);

    try {
      // Добавляем параметры пагинации и фильтрации из конфига
      final queryParams = <String, String>{};
      
      if (configData.containsKey('limit')) {
        queryParams['limit'] = configData['limit'].toString();
      }
      if (configData.containsKey('offset')) {
        queryParams['offset'] = configData['offset'].toString();
      }
      if (configData.containsKey('categories') && configData['categories'] != null) {
        queryParams['categories'] = configData['categories'].toString();
      }
      
      final uri = Uri.parse(apiUrl).replace(queryParameters: queryParams);
      developer.log('🔧 Products: Построен URI с параметрами: $queryParams', name: 'SyncWorker');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'User-Agent': 'FieldForce-Mobile/1.0',
      };

      // Добавляем заголовки сессии (уже готовые от SessionManager)
      if (sessionHeaders != null && sessionHeaders.isNotEmpty) {
        sessionHeaders.forEach((key, value) {
          headers[key] = value.toString();
        });
        developer.log('🔑 Sync Worker: Используем сессионные заголовки: $sessionHeaders', name: 'SyncWorker');
      } else {
        developer.log('⚠️ Sync Worker: СЕССИЯ ОТСУТСТВУЕТ!', name: 'SyncWorker');
      }

      developer.log('🌐 Sync Worker: Отправка запроса к $uri', name: 'SyncWorker');
      developer.log('📋 Sync Worker: Заголовки запроса: $headers', name: 'SyncWorker');
      
      final response = await client.get(uri, headers: headers);
      
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      return response.body;
    } finally {
      client.close();
    }
  }

  /// Выполняет HTTP запрос к API категорий
  Future<String> _makeCategoryApiRequest(
    String apiUrl,
    Map<String, dynamic> configData,
    Map<String, dynamic>? sessionHeaders,
  ) async {
    if (apiUrl.isEmpty) {
      throw Exception('URL API категорий не настроен');
    }

    final ioClient = HttpClient();
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioClient);

    try {
      final uri = Uri.parse(apiUrl);
      developer.log('🔧 Categories: Построен URI без параметров: $uri', name: 'SyncWorker');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'User-Agent': 'FieldForce-Mobile/1.0',
      };

      if (sessionHeaders != null && sessionHeaders.isNotEmpty) {
        sessionHeaders.forEach((key, value) {
          headers[key] = value.toString();
        });
      }

      developer.log('🌐 Categories: Отправка запроса к $uri', name: 'SyncWorker');
      developer.log('🔒 Categories: Заголовки запроса: ${headers.keys}', name: 'SyncWorker');
      
      final response = await client.get(uri, headers: headers);
      
      developer.log('📊 Categories: HTTP ${response.statusCode} - ${response.reasonPhrase}', name: 'SyncWorker');
      
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      return response.body;
    } finally {
      client.close();
    }
  }

  /// Парсит категории из JSON ответа API
  List<cat.Category> _parseCategoriesFromJson(String jsonString) {
    try {
      final jsonData = jsonDecode(jsonString) as List<dynamic>;
      return jsonData.map((item) => cat.Category.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка парсинга JSON категорий: $e');
    }
  }



  /// Сериализует Category в JSON для передачи между изолятами
  Map<String, dynamic> _categoryToJson(cat.Category category) {
    return {
      'id': category.id,
      'name': category.name,
      'lft': category.lft,
      'lvl': category.lvl,
      'rgt': category.rgt,
      'description': category.description,
      'query': category.query,
      'count': category.count,
      'children': category.children.map((child) => _categoryToJson(child)).toList(),
    };
  }

  void _handlePause() {
    _isPaused = true;
    developer.log('⏸️ Sync Worker: Синхронизация приостановлена', name: 'SyncWorker');
    _sendPortToMain.send(SyncMessage(type: SyncResponses.paused, data: {}).toJson());
  }

  void _handleResume() {
    _isPaused = false;
    developer.log('▶️ Sync Worker: Синхронизация возобновлена', name: 'SyncWorker');
    _sendPortToMain.send(SyncMessage(type: SyncResponses.resumed, data: {}).toJson());
  }

  void _handleCancel() {
    _isCancelled = true;
    developer.log('🛑 Sync Worker: Синхронизация отменена', name: 'SyncWorker');
    _sendPortToMain.send(SyncMessage(type: SyncResponses.cancelled, data: {}).toJson());
  }

  void _handleShutdown() {
    _heartbeatTimer?.cancel();
    developer.log('🔌 Sync Worker: Получена команда завершения', name: 'SyncWorker');
  }

  /// Отправляет сообщение о прогрессе
  void _sendProgress(String syncType, int current, int total, String status) {
    _sendPortToMain.send(createProgressMessage(
      syncType: syncType,
      current: current,
      total: total,
      status: status,
    ).toJson());
  }
}