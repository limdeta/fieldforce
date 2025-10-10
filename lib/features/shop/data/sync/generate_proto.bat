@echo off
chcp 65001 >nul
:: Скрипт для генерации Dart классов из Protocol Buffers схем
:: Запуск: generate_proto.bat

echo Generating Dart classes from proto files...

:: Добавляем Dart pub cache в PATH
set PATH=%PATH%;%USERPROFILE%\AppData\Local\Pub\Cache\bin

:: Проверка что Dart protoc plugin установлен
dart pub global list | findstr "protoc_plugin" >nul
if %errorlevel% neq 0 (
    echo Installing Dart protoc plugin...
    dart pub global activate protoc_plugin
)

:: Папки
set PROTO_DIR=Proto
set OUTPUT_DIR=generated

:: Создаем выходную папку если её нет
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: Очищаем старые файлы
del /Q "%OUTPUT_DIR%\*.dart" 2>nul

:: Генерируем классы
protoc --dart_out="%OUTPUT_DIR%" --proto_path="%PROTO_DIR%" "%PROTO_DIR%\*.proto"

if %errorlevel% equ 0 (
    echo Generation completed successfully!
    echo Generated files:
    dir "%OUTPUT_DIR%\*.dart"
) else (
    echo Generation failed!
    echo.
    echo Possible causes:
    echo 1. protoc not installed - install Protocol Buffers compiler
    echo 2. Error in proto files - check syntax
    exit /b 1
)

echo.
echo Next steps:
echo 1. Run: flutter pub get
echo 2. Check generated files in %OUTPUT_DIR%
echo 3. Use in code: import 'generated/product.pb.dart';