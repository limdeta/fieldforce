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
void syncWorkerEntryPoint(SendPort sendPortToMain) async {
  final receivePortInWorker = ReceivePort();
  
  sendPortToMain.send(receivePortInWorker.sendPort);
  
  sendPortToMain.send(SyncMessage(
    type: SyncResponses.initialized,
    data: {'timestamp': DateTime.now().millisecondsSinceEpoch},
  ).toJson());

  final worker = SyncWorker(sendPortToMain);
  
  await for (final message in receivePortInWorker) {
    try {
      if (message is Map<String, dynamic>) {
        final syncMessage = SyncMessage.fromJson(message);
        await worker.handleCommand(syncMessage);
        
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
  developer.log('Sync Worker: команда ${message.type}', name: 'SyncWorker');

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
  developer.log('Sync Worker: начинаем синхронизацию продуктов', name: 'SyncWorker');

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
      
      // Обрабатываем первую страницу
      final firstPageJson = json.decode(firstResponse) as Map<String, dynamic>;
      if (!firstPageJson.containsKey('data')) {
        throw Exception('Ответ API не содержит поля "data". Доступные поля: ${firstPageJson.keys}');
      }
      
      final firstPageProducts = firstPageJson['data'] as List<dynamic>;
      totalImported += firstPageProducts.length;
      
  developer.log('Sync Worker: отправка первой страницы', name: 'SyncWorker');
      
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
  developer.log('Sync Worker: загрузка страницы offset=$currentOffset', name: 'SyncWorker');
        
        final pageConfig = Map<String, dynamic>.from(configData);
        pageConfig['limit'] = pageSize;
        pageConfig['offset'] = currentOffset;
        
        final pageResponse = await _makeProductApiRequest(apiUrl, pageConfig, sessionHeaders);
        
        if (_isCancelled) return;
        
        final pageJsonData = json.decode(pageResponse) as Map<String, dynamic>;
        final pageProducts = pageJsonData['data'] as List<dynamic>;
        
        if (pageProducts.isEmpty) {
          developer.log('Sync Worker: получена пустая страница, завершаем', name: 'SyncWorker');
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

  developer.log('Sync Worker: синхронизация продуктов завершена', name: 'SyncWorker');

    } catch (e, stackTrace) {
      developer.log('Sync Worker: ошибка синхронизации продуктов', name: 'SyncWorker', error: e, stackTrace: stackTrace);
      
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
  developer.log('Sync Worker: начинаем синхронизацию категорий', name: 'SyncWorker');

    try {
      final configData = data['config'] as Map<String, dynamic>;
      final apiUrl = data['apiUrl'] as String;
      final sessionHeaders = data['sessionHeaders'] as Map<String, dynamic>?;

  developer.log('Sync Worker: categories sync', name: 'SyncWorker');

      _sendProgress('categories', 1, 2, 'Загрузка категорий...');
      
      final response = await _makeCategoryApiRequest(apiUrl, configData, sessionHeaders);
  developer.log('Sync Worker: categories response received', name: 'SyncWorker');
      
      if (_isCancelled) return;
      
      _sendProgress('categories', 2, 2, 'Парсинг категорий...');
      
      final categories = _parseCategoriesFromJson(response);
  developer.log('Sync Worker: parsed categories count ${categories.length}', name: 'SyncWorker');

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

  developer.log('Sync Worker: categories sync finished', name: 'SyncWorker');

    } catch (e, stackTrace) {
      developer.log('Sync Worker: ошибка синхронизации категорий', name: 'SyncWorker', error: e, stackTrace: stackTrace);
      
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

    // Создаём максимально permissive HTTP client для dev
    final context = SecurityContext.defaultContext;
    final ioClient = HttpClient(context: context);
    
    // Принимаем самоподписанные сертификаты в dev режиме
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    ioClient.connectionTimeout = const Duration(seconds: 10);
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
  developer.log('Sync Worker: построен URI для продуктов', name: 'SyncWorker');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'User-Agent': 'FieldForce-Mobile/1.0',
        'Accept': 'application/json',
      };

      // Добавляем заголовки сессии (уже готовые от SessionManager)
      if (sessionHeaders != null && sessionHeaders.isNotEmpty) {
        sessionHeaders.forEach((key, value) {
          headers[key] = value.toString();
        });
      }

      final response = await client.get(uri, headers: headers).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Сервер не отвечает более 15 секунд. Проверьте:\n'
            '• Запущен ли сервер?\n'
            '• Доступен ли он по адресу $uri?\n'
            '• На Android эмуляторе используйте 10.0.2.2 вместо localhost');
        },
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      return response.body;
    } on SocketException catch (e) {
      // Connection refused, host not found, etc
      throw Exception('Не удалось подключиться к серверу:\n'
        '${e.message}\n\n'
        'Возможные причины:\n'
        '• Сервер не запущен\n'
        '• Неверный адрес (на Android эмуляторе используйте 10.0.2.2)\n'
        '• Firewall блокирует соединение');
    } on TimeoutException catch (e) {
      throw Exception('Превышено время ожидания: ${e.message}');
    } on HandshakeException catch (e) {
      // SSL certificate problems
      throw Exception('Ошибка SSL сертификата:\n'
        '${e.message}\n\n'
        'Убедитесь что сервер использует правильный сертификат');
    } on HttpException catch (e) {
      throw Exception('HTTP ошибка: ${e.message}');
    } catch (e) {
      throw Exception('Неожиданная ошибка при запросе: $e');
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

    // Создаём максимально permissive HTTP client для dev
    final context = SecurityContext.defaultContext;
    final ioClient = HttpClient(context: context);
    
    // Принимаем самоподписанные сертификаты в dev режиме
    ioClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    ioClient.connectionTimeout = const Duration(seconds: 10);
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
      
      final response = await client.get(uri, headers: headers).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Сервер не отвечает более 15 секунд. Проверьте:\n'
            '• Запущен ли сервер?\n'
            '• Доступен ли он по адресу $uri?\n'
            '• На Android эмуляторе используйте 10.0.2.2 вместо localhost');
        },
      );
      
      developer.log('📊 Categories: HTTP ${response.statusCode} - ${response.reasonPhrase}', name: 'SyncWorker');
      
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }

      return response.body;
    } on SocketException catch (e) {
      // Connection refused, host not found, etc
      throw Exception('Не удалось подключиться к серверу:\n'
        '${e.message}\n\n'
        'Возможные причины:\n'
        '• Сервер не запущен\n'
        '• Неверный адрес (на Android эмуляторе используйте 10.0.2.2)\n'
        '• Firewall блокирует соединение');
    } on TimeoutException catch (e) {
      throw Exception('Превышено время ожидания: ${e.message}');
    } on HandshakeException catch (e) {
      // SSL certificate problems
      throw Exception('Ошибка SSL сертификата:\n'
        '${e.message}\n\n'
        'Убедитесь что сервер использует правильный сертификат');
    } on HttpException catch (e) {
      throw Exception('HTTP ошибка: ${e.message}');
    } catch (e) {
      throw Exception('Неожиданная ошибка при запросе: $e');
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
    final message = createProgressMessage(
      syncType: syncType,
      current: current,
      total: total,
      status: status,
    );
    _sendPortToMain.send(message.toJson());
  }
}