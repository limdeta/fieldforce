# 🚀 Protocol Buffers Sync Module

Этот модуль реализует эффективную синхронизацию через Protocol Buffers,
отдельно от существующей JSON синхронизации.

## 📁 Структура модуля:

```
sync/
├── README.md               # Этот файл
├── proto/                  # .proto схемы с бэкенда
│   ├── product.proto
│   ├── stockitem.proto
│   └── sync.proto
├── generated/              # Сгенерированные Dart классы
│   ├── product.pb.dart
│   ├── stockitem.pb.dart
│   └── sync.pb.dart
├── services/               # Сервисы синхронизации
│   ├── regional_sync_service.dart
│   ├── outlet_sync_service.dart
│   └── protobuf_sync_manager.dart
├── repositories/           # Репозитории для новой схемы
│   ├── sync_product_repository.dart
│   ├── sync_stock_repository.dart
│   └── sync_pricing_repository.dart
├── models/                 # Объединенные модели
│   └── product_with_price.dart
└── strategies/             # Стратегии синхронизации
    ├── morning_sync_strategy.dart
    ├── hourly_sync_strategy.dart
    └── smart_cache_strategy.dart
```

## 🔄 Workflow генерации кода:

1. **Копируем .proto файлы** с бэкенда в `proto/`
2. **Генерируем Dart классы**: `protoc --dart_out=generated proto/*.proto`
3. **Используем в коде**: `import 'generated/product.pb.dart';`

## 🎯 Принципы модуля:

- **Изоляция** от JSON синхронизации
- **Оптимизация** для мобильных устройств  
- **Умное кеширование** по типам данных
- **Дифференциальные обновления**