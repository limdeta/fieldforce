#!/usr/bin/env dart
// ignore_for_file: avoid_print, non_constant_identifier_names
// FieldForce Update Deployment Script in Dart
// Использование: dart deploy_update.dart "changelog текст"
// Версия автоматически берется из pubspec.yaml

import 'dart:io';
import 'dart:convert';

// Глобальные переменные конфигурации (загружаются из .env)
late String SERVER_HOST;
late String SERVER_USER;
late String SERVER_PATH;
late String UPDATE_SECRET;
String? SERVER_PASSWORD; // опциональный пароль
String DEFAULT_MIN_SUPPORTED_VERSION = '1.0.0';

// Функция для чтения .env файла
Map<String, String> readEnvFile(String envPath) {
  final envVars = <String, String>{};
  
  final envFile = File(envPath);
  if (!envFile.existsSync()) {
    printError('❌ Файл .env не найден: $envPath');
    printInfo('💡 Скопируйте .env.example в .env и настройте параметры');
    exit(1);
  }
  
  final lines = envFile.readAsLinesSync();
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    
    final parts = trimmed.split('=');
    if (parts.length >= 2) {
      final key = parts[0].trim();
      var value = parts.sublist(1).join('=').trim();
      
      // Убираем кавычки если есть
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      
      envVars[key] = value;
    }
  }
  
  return envVars;
}

// Функция для загрузки конфигурации
void loadConfig() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final envPath = '${scriptDir.path}/.env';
  final config = readEnvFile(envPath);
  
  // Загружаем обязательные параметры
  SERVER_HOST = config['SERVER_HOST'] ?? '';
  SERVER_USER = config['SERVER_USER'] ?? '';
  SERVER_PATH = config['SERVER_PATH'] ?? '/var/www/mobile-app';
  UPDATE_SECRET = config['UPDATE_SECRET'] ?? '';
  
  // Загружаем опциональные параметры
  SERVER_PASSWORD = config['SERVER_PASSWORD']; // может быть null
  
  // Проверяем обязательные параметры
  if (SERVER_HOST.isEmpty || SERVER_USER.isEmpty || UPDATE_SECRET.isEmpty) {
    printError('❌ Не все обязательные параметры настроены в .env файле');
    printInfo('💡 Проверьте SERVER_HOST, SERVER_USER, UPDATE_SECRET в .env');
    exit(1);
  }
  
  // Загружаем опциональные параметры
  if (config['DEFAULT_MIN_SUPPORTED_VERSION']?.isNotEmpty == true) {
    DEFAULT_MIN_SUPPORTED_VERSION = config['DEFAULT_MIN_SUPPORTED_VERSION']!;
  }
}

void main(List<String> args) async {
  // Загружаем конфигурацию из .env файла
  loadConfig();
  
  print('🚀 FieldForce Update Deployment Script (Dart)');
  print('==============================================');

  final deployDir = Directory.current;
  final projectDir = deployDir.parent;

  // Проверяем что мы в папке deploy проекта Flutter
  if (!File('${projectDir.path}/pubspec.yaml').existsSync()) {
    printError('❌ Запустите скрипт из папки deploy проекта Flutter');
    exit(1);
  }

  // Проверяем флаги
  bool skipBuild = args.contains('--skip-build');
  bool interactiveMode = args.contains('--interactive');
  bool showCommandsOnly = args.contains('--show-commands');

  printInfo('🔧 Режим сборки: ${skipBuild ? "пропустить" : "собрать"}');
  printInfo('🔧 Режим SSH: ${interactiveMode ? "интерактивный" : "автоматический"}');
  if (showCommandsOnly) printInfo('🔧 Режим: только показать команды');

  // Читаем версию из pubspec.yaml (единственный источник версии)
  final pubspecContent = await File('${projectDir.path}/pubspec.yaml').readAsString();
  final versionMatch = RegExp(r'version:\s*([0-9]+\.[0-9]+\.[0-9]+)').firstMatch(pubspecContent);
  
  if (versionMatch == null) {
    printError('❌ Не удалось определить версию из pubspec.yaml');
    exit(1);
  }
  
  final version = versionMatch.group(1)!;
  printInfo('📝 Версия из pubspec.yaml: $version');

  // Получаем changelog из аргументов
  final filteredArgs = args.where((arg) => !arg.startsWith('--')).toList();
  final changelog = filteredArgs.isNotEmpty ? filteredArgs.join(' ') : null;

  final apkName = 'fieldforce-v$version.apk';

  printInfo('📱 Версия для деплоя: $version');
  printInfo('📁 APK файл: $apkName');

  if (skipBuild) {
    printWarning('⏭️ Сборка пропущена (--skip-build)');
    
    // Проверяем что APK уже существует в deploy/releases
    final existingApk = File('releases/$apkName');
    if (!existingApk.existsSync()) {
      printError('❌ APK файл не найден: ${existingApk.path}');
      printInfo('💡 Запустите без --skip-build для сборки');
      exit(1);
    }
    
    printSuccess('✅ Найден готовый APK: releases/$apkName');
  } else {
    print('');
    printInfo('🔨 Начинаем сборку приложений...');

    // Переходим в корень проекта для сборки
  Directory.current = projectDir;

    // Собираем Android APK
    printInfo('📱 Собираем Android APK...');
    await runCommand('flutter', ['clean']);
    await runCommand('flutter', ['pub', 'get']);
    await runCommand('flutter', ['build', 'apk', '--release', '--dart-define=ENV=prod']);

    // Переименовываем APK в папку deploy/releases
    final originalApk = File('build/app/outputs/flutter-apk/app-release.apk');
    final targetApk = File('deploy/releases/$apkName');
    
    if (originalApk.existsSync()) {
      // Создаем папку если не существует
      await targetApk.parent.create(recursive: true);
      await originalApk.copy(targetApk.path);
      printSuccess('✅ Android APK собран: deploy/releases/$apkName');
    } else {
      printError('❌ APK файл не найден: ${originalApk.path}');
      exit(1);
    }

    // Возвращаемся в папку deploy для дальнейших операций
    Directory.current = deployDir;
  }
  
  // Убеждаемся, что текущая директория снова указывает на deploy
  Directory.current = deployDir;

  // Создаем update-info.json в папке deploy
  final updateInfo = {
    'changelog': changelog ?? 'Обновление до версии $version\n',
    'required': false,
    'min_supported_version': DEFAULT_MIN_SUPPORTED_VERSION,
  };

  final updateInfoFile = File('update-info.json');
  await updateInfoFile.writeAsString(
    JsonEncoder.withIndent('  ').convert(updateInfo),
    encoding: utf8,
  );
  printSuccess('✅ Создан update-info.json в папке deploy');

  print('');
  printInfo('📤 Загружаем файлы на сервер...');

  if (showCommandsOnly) {
    printInfo('📋 Команды для ручной загрузки:');
    print('');
    printInfo('scp releases/fieldforce-v$version.apk $SERVER_USER@$SERVER_HOST:$SERVER_PATH/releases/');
    printInfo('scp update-info.json $SERVER_USER@$SERVER_HOST:$SERVER_PATH/');
    print('');
    printInfo('📡 API для обновления версии:');
    printInfo('curl -X POST -H "X-Update-Secret: $UPDATE_SECRET" https://$SERVER_HOST/v1_api/mobile-sync/app/refresh');
    print('');
    printWarning('⚠️ Выполните эти команды вручную, затем проверьте:');
    printInfo('🔗 https://$SERVER_HOST/v1_api/mobile-sync/app/version');
    return;
  }

  // Проверяем наличие scp
  final scpResult = await Process.run('where', ['scp'], runInShell: true);
  if (scpResult.exitCode != 0) {
    printError('❌ SCP не найден. Установите OpenSSH или Git for Windows');
    exit(1);
  }

  // Тестируем SSH подключение
  printInfo('🔑 Тестируем SSH подключение к серверу...');
  try {
    final sshTest = await Process.run(
      'ssh',
      [
        '-o', 'ConnectTimeout=10',
        '-o', 'BatchMode=yes', // не запрашивать пароль
        '-o', 'StrictHostKeyChecking=no', // автоматически принимаем ключи
        '-o', 'UserKnownHostsFile=/dev/null', // не сохраняем ключи
        '$SERVER_USER@$SERVER_HOST',
        'echo "SSH connection test successful"'
      ],
      runInShell: true,
    ).timeout(Duration(seconds: 15));

    if (sshTest.exitCode == 0) {
      printSuccess('✅ SSH подключение работает');
    } else {
      printWarning('⚠️ Проблемы с SSH подключением (exit code: ${sshTest.exitCode})');
      printInfo('💡 Убедитесь что у вас настроен SSH-ключ или будьте готовы ввести пароль');
      printWarning('Stderr: ${sshTest.stderr}');
    }
  } catch (e) {
    printWarning('⚠️ Не удалось протестировать SSH: $e');
    printInfo('💡 Продолжаем, но возможны проблемы с загрузкой');
  }

  // Загружаем файлы
  bool uploadSuccess = true;

  for (final file in [apkName, 'update-info.json']) {
    String localFilePath;
    if (file == 'update-info.json') {
      // update-info.json находится в папке deploy
      localFilePath = file;
    } else {
      // APK файл находится в папке deploy/releases
      localFilePath = 'releases/$file';
    }
    
    if (File(localFilePath).existsSync()) {
      String remotePath;
      if (file == 'update-info.json') {
        // Сначала загружаем в tmp, потом перемещаем
        remotePath = '/tmp/$file';
        printInfo('📤 Загружаем в tmp: $file');
        uploadSuccess = uploadSuccess && await uploadFile(localFilePath, remotePath, interactiveMode);
        
        if (uploadSuccess) {
          // Перемещаем файл на место с помощью sudo
          printInfo('🔄 Перемещаем файл на место...');
          final moveResult = await Process.run('ssh', [
            '-o', 'ConnectTimeout=30',
            '-o', 'StrictHostKeyChecking=no',
            '$SERVER_USER@$SERVER_HOST',
            'sudo cp /tmp/$file $SERVER_PATH/$file && sudo chown www-data:www-data $SERVER_PATH/$file'
          ], runInShell: true);
          
          if (moveResult.exitCode != 0) {
            printError('❌ Не удалось переместить $file');
            printWarning('Stderr: ${moveResult.stderr}');
            uploadSuccess = false;
          } else {
            printSuccess('✅ Файл $file перемещен на место');
          }
        }
      } else {
        // APK файлы в releases/
        remotePath = '$SERVER_PATH/releases/$file';
        uploadSuccess = uploadSuccess && await uploadFile(localFilePath, remotePath, interactiveMode);
      }
    } else {
      printError('❌ Файл не найден: $localFilePath');
      uploadSuccess = false;
    }
  }

  if (!uploadSuccess) {
    printError('❌ Не все файлы удалось загрузить');
    exit(1);
  }

  print('');
  printInfo('🔄 Обновляем информацию о версии на сервере...');

  // Вызываем API для обновления version.json
  try {
    final result = await Process.run('curl', [
      '-X', 'POST',
      '-H', 'X-Update-Secret: $UPDATE_SECRET',
      '-H', 'Content-Type: application/json',
      'https://$SERVER_HOST/v1_api/mobile-sync/app/refresh'
    ]);

    if (result.exitCode == 0) {
      printSuccess('✅ Информация о версии обновлена на сервере');
    } else {
      printWarning('⚠️ Не удалось автоматически обновить version.json');
    }
  } catch (e) {
    printWarning('⚠️ Ошибка при обновлении version.json: $e');
  }

  print('');
  printSuccess('🎉 Деплой завершен успешно!');
  printInfo('📱 APK: https://$SERVER_HOST/v1_api/mobile-sync/app/download/$apkName');
  printInfo('🔗 Version API: https://$SERVER_HOST/v1_api/mobile-sync/app/version');

  print('');
  printInfo('🧹 Очистка временных файлов...');

  // Удаляем временные файлы
  final filesToClean = [
    'releases/$apkName', // APK в deploy/releases
    'update-info.json' // JSON в папке deploy
  ];
  
  for (final file in filesToClean) {
    final f = File(file);
    if (f.existsSync()) {
      await f.delete();
      printInfo('🗑️ Удален: $file');
    }
  }

  printSuccess('✅ Готово! Теперь пользователи могут обновить приложение');
}

Future<void> runCommand(String command, List<String> args) async {
  final result = await Process.run(command, args, runInShell: true);
  if (result.exitCode != 0) {
    printError('❌ Команда провалилась: $command ${args.join(' ')}');
    printError('Вывод: ${result.stderr}');
    exit(1);
  }
}

Future<bool> uploadFile(String localPath, String remotePath, [bool interactive = false]) async {
  printInfo('📤 Загружаем $localPath...');
  
  // Если есть пароль, используем sshpass
  if (SERVER_PASSWORD != null && SERVER_PASSWORD!.isNotEmpty) {
    printInfo('� Используем пароль для подключения');
    return await _uploadWithPassword(localPath, remotePath);
  }
  
  printInfo('�🔗 Команда: scp $localPath $SERVER_USER@$SERVER_HOST:$remotePath');
  
  try {
    List<String> scpArgs = [
      '-o', 'ConnectTimeout=30',
      '-o', 'ServerAliveInterval=10', 
      '-o', 'ServerAliveCountMax=3',
    ];

    if (!interactive) {
      // В неинтерактивном режиме отключаем проверки ключей
      scpArgs.addAll([
        '-o', 'StrictHostKeyChecking=no',
        '-o', 'UserKnownHostsFile=/dev/null',
        '-o', 'BatchMode=yes', // не запрашиваем пароль
      ]);
    }

    scpArgs.addAll([
      '-v', // verbose для отладки
      localPath,
      '$SERVER_USER@$SERVER_HOST:$remotePath'
    ]);

    final result = await Process.run(
      'scp', 
      scpArgs,
      runInShell: true,
    ).timeout(Duration(minutes: 5));

    printInfo('📋 Stdout: ${result.stdout}');
    if (result.stderr.isNotEmpty) {
      printWarning('⚠️ Stderr: ${result.stderr}');
    }

    if (result.exitCode == 0) {
      printSuccess('✅ Загружен: $localPath');
      return true;
    } else {
      printError('❌ Ошибка загрузки: $localPath (exit code: ${result.exitCode})');
      printError('💡 Попробуйте запустить с --show-commands для ручной загрузки');
      return false;
    }
  } catch (e) {
    printError('❌ Таймаут или ошибка при загрузке: $localPath');
    printError('Ошибка: $e');
    printError('💡 Попробуйте запустить с --show-commands для ручной загрузки');
    return false;
  }
}

// Альтернативная загрузка с паролем (требует sshpass)
Future<bool> _uploadWithPassword(String localPath, String remotePath) async {
  try {
    final result = await Process.run(
      'sshpass',
      [
        '-p', SERVER_PASSWORD!,
        'scp',
        '-o', 'ConnectTimeout=30',
        '-o', 'StrictHostKeyChecking=no',
        '-o', 'UserKnownHostsFile=/dev/null',
        localPath,
        '$SERVER_USER@$SERVER_HOST:$remotePath'
      ],
      runInShell: true,
    ).timeout(Duration(minutes: 5));

    if (result.exitCode == 0) {
      printSuccess('✅ Загружен с паролем: $localPath');
      return true;
    } else {
      printError('❌ Ошибка загрузки с паролем: $localPath');
      printError('Stderr: ${result.stderr}');
      return false;
    }
  } catch (e) {
    printWarning('⚠️ sshpass не найден или ошибка: $e');
    printInfo('💡 Установите sshpass или используйте --show-commands');
    return false;
  }
}

void printSuccess(String message) {
  print('\x1B[32m$message\x1B[0m'); // Green
}

void printError(String message) {
  print('\x1B[31m$message\x1B[0m'); // Red
}

void printWarning(String message) {
  print('\x1B[33m$message\x1B[0m'); // Yellow  
}

void printInfo(String message) {
  print('\x1B[36m$message\x1B[0m'); // Cyan
}