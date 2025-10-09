#!/bin/bash

# Скрипт для генерации Dart классов из Protocol Buffers схем
# Запуск: bash generate_proto.sh

# Проверка что protoc установлен
if ! command -v protoc &> /dev/null; then
    echo "❌ protoc не найден! Установите Protocol Buffers compiler"
    echo "Windows: chocolatey install protobuf"
    echo "macOS: brew install protobuf"
    echo "Linux: sudo apt-get install protobuf-compiler"
    exit 1
fi

# Проверка что Dart protoc plugin установлен
if ! dart pub global list | grep -q "protoc_plugin"; then
    echo "📦 Устанавливаем Dart protoc plugin..."
    dart pub global activate protoc_plugin
fi

# Папки
PROTO_DIR="lib/features/shop/data/sync/Proto"
OUTPUT_DIR="lib/features/shop/data/sync/generated"

# Создаем выходную папку если её нет
mkdir -p "$OUTPUT_DIR"

# Очищаем старые файлы
rm -f "$OUTPUT_DIR"/*.dart

echo "🚀 Генерируем Dart классы из proto файлов..."

# Генерируем классы
protoc \
    --dart_out="$OUTPUT_DIR" \
    --proto_path="$PROTO_DIR" \
    "$PROTO_DIR"/*.proto

if [ $? -eq 0 ]; then
    echo "✅ Генерация завершена успешно!"
    echo "📁 Сгенерированные файлы:"
    ls -la "$OUTPUT_DIR"/*.dart
else
    echo "❌ Ошибка генерации!"
    exit 1
fi

echo ""
echo "🎯 Следующие шаги:"
echo "1. Запустите: flutter pub get"
echo "2. Проверьте сгенерированные файлы в $OUTPUT_DIR"
echo "3. Используйте в коде: import 'generated/product.pb.dart';"