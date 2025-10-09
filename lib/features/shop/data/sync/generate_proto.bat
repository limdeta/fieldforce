@echo off
:: Скрипт для генерации Dart классов из Protocol Buffers схем
:: Запуск: generate_proto.bat

echo 🚀 Генерируем Dart классы из proto файлов...

:: Проверка что Dart protoc plugin установлен
dart pub global list | findstr "protoc_plugin" >nul
if %errorlevel% neq 0 (
    echo 📦 Устанавливаем Dart protoc plugin...
    dart pub global activate protoc_plugin
)

:: Папки
set PROTO_DIR=proto
set OUTPUT_DIR=generated

:: Создаем выходную папку если её нет
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: Очищаем старые файлы
del /Q "%OUTPUT_DIR%\*.dart" 2>nul

:: Генерируем классы
protoc --dart_out="%OUTPUT_DIR%" --proto_path="%PROTO_DIR%" "%PROTO_DIR%\*.proto"

if %errorlevel% equ 0 (
    echo ✅ Генерация завершена успешно!
    echo 📁 Сгенерированные файлы:
    dir "%OUTPUT_DIR%\*.dart"
) else (
    echo ❌ Ошибка генерации!
    echo.
    echo 💡 Возможные причины:
    echo 1. protoc не установлен - установите Protocol Buffers compiler
    echo 2. Ошибка в proto файлах - проверьте синтаксис
    pause
    exit /b 1
)

echo.
echo 🎯 Следующие шаги:
echo 1. Запустите: flutter pub get
echo 2. Проверьте сгенерированные файлы в %OUTPUT_DIR%
echo 3. Используйте в коде: import 'generated/product.pb.dart';
pause