# 🚀 Protobuf Sync Module

Модуль синхронизации данных с использованием Protocol Buffers для мобильного приложения FieldForce.

## 🏗️ Архитектура

Модуль реализует двухуровневую систему кэширования:

### 1. Региональный уровень (ежедневно)
- **RegionalSyncService** - синхронизация базовых данных продуктов для региона
- Endpoint: `/v1_api/mobile-sync/regional/{regionFiasId}`
- Частота: раз в день или при смене региона
- Объем: полный каталог продуктов с базовыми ценами

### 2. Уровень точек (ежечасно)  
- **StockSyncService** - обновление остатков на складах
- **OutletPricingSyncService** - дифференциальные цены для торговых точек
- Endpoints: 
  - `/v1_api/mobile-sync/regional-stock/{regionFiasId}`
  - `/v1_api/mobile-sync/outlet-pricing/{outletId}`
- Частота: каждые 15-60 минут
- Объем: только изменения остатков и цен

## 📁 Структура модуля

```
lib/features/shop/data/sync/
├── proto/                    # .proto файлы (копии с бэкенда)
│   ├── product.proto
│   ├── stockitem.proto
│   └── sync.proto
├── generated/               # Сгенерированные Dart классы
│   ├── product.pb.dart
│   ├── stockitem.pb.dart
│   └── sync.pb.dart
├── services/               # Сервисы синхронизации
│   ├── regional_sync_service.dart
│   ├── stock_sync_service.dart
│   ├── outlet_pricing_sync_service.dart
│   └── protobuf_sync_coordinator.dart
├── models/                # DTO и конверторы
├── repositories/         # Локальное сохранение
└── README.md           # Эта документация
```

## 🔧 Использование

### Настройка в DI контейнере

```dart
// В service_locator.dart
void _registerSyncServices() {
  final baseUrl = AppConfig.apiBaseUrl;
  
  GetIt.instance.registerLazySingleton(() => RegionalSyncService(
    baseUrl: baseUrl,
  ));
  
  GetIt.instance.registerLazySingleton(() => StockSyncService(
    baseUrl: baseUrl,
  ));
  
  GetIt.instance.registerLazySingleton(() => OutletPricingSyncService(
    baseUrl: baseUrl,
  ));
  
  GetIt.instance.registerLazySingleton(() => ProtobufSyncCoordinator(
    regionalSyncService: GetIt.instance<RegionalSyncService>(),
    stockSyncService: GetIt.instance<StockSyncService>(),
    outletPricingSyncService: GetIt.instance<OutletPricingSyncService>(),
  ));
}
```

### Полная синхронизация региона

```dart
final coordinator = GetIt.instance<ProtobufSyncCoordinator>();

// Устанавливаем сессионную куку для аутентификации
coordinator.setSessionCookie('PHPSESSID=abc123...');

// Выполняем полную синхронизацию
final result = await coordinator.performFullRegionalSync(
  'c2deb16a-0330-4f05-821f-1d09c93331e6', // FIAS код Краснодара
  [123, 456, 789], // ID торговых точек
  forceFullSync: true,
);

print('Синхронизировано: ${result}');
```

### Инкрементальная синхронизация

```dart
// Быстрое обновление только изменений
final result = await coordinator.performIncrementalSync(
  'c2deb16a-0330-4f05-821f-1d09c93331e6',
  [123, 456], // Только активные точки
);
```

## 🌐 Endpoints API

### Regional Cache
```
POST /v1_api/mobile-sync/regional/{regionFiasId}
Content-Type: application/x-protobuf
Accept-Encoding: gzip

Request: RegionalCacheRequest
Response: RegionalCacheResponse (gzip-compressed)
```

### Regional Stock  
```
POST /v1_api/mobile-sync/regional-stock/{regionFiasId}
Content-Type: application/x-protobuf

Request: RegionalCacheRequest (с lastSyncTimestamp)
Response: RegionalCacheResponse (только изменившиеся остатки)
```

### Outlet Pricing
```
POST /v1_api/mobile-sync/outlet-pricing/{outletId}  
Content-Type: application/x-protobuf

Request: OutletSpecificRequest
Response: OutletSpecificResponse (цены для конкретной точки)
```

## ⚡ Преимущества protobuf

1. **Компактность**: ~60% меньше трафика по сравнению с JSON
2. **Скорость**: быстрая сериализация/десериализация
3. **Типобезопасность**: строгие схемы данных
4. **Совместимость**: эволюция схем без breaking changes
5. **Gzip-сжатие**: дополнительное сжатие для мобильных сетей

## 📊 Мониторинг и логирование

Все сервисы используют пакет `logging` с эмодзи для удобства:

- 🔄 Начало синхронизации
- 📦 Обработка продуктов  
- 💰 Работа с ценами
- ✅ Успешное завершение
- ❌ Ошибки
- 🍪 Аутентификация

## 📋 TODO

- [ ] Реализовать конверторы protobuf -> domain entities
- [ ] Добавить сохранение в локальную БД через repositories
- [ ] Реализовать отслеживание времени последних обновлений
- [ ] Добавить метрики производительности
- [ ] Создать unit тесты для всех сервисов
- [ ] Добавить retry логику для network failures
- [ ] Реализовать queue-based синхронизацию для офлайн режима

## 🆚 Сравнение с JSON API

| Параметр | JSON API | Protobuf API |
|----------|----------|--------------|
| Размер данных | 100% | ~40% |
| Скорость парсинга | Средняя | Высокая |
| Типобезопасность | Слабая | Строгая |
| Поддержка схем | Нет | Да |
| Gzip-сжатие | Да | Да |
| Человекочитаемость | Да | Нет |
| IDE поддержка | Слабая | Сильная |

**Результат**: Protobuf API рекомендуется для критически важных операций синхронизации, где важна скорость и экономия трафика.

## 🔧 Генерация кода

```bash
# Установка protoc (Windows с Chocolatey)
choco install protoc

# Установка Dart плагина
flutter pub global activate protoc_plugin

# Генерация Dart классов
protoc --dart_out=generated proto/*.proto
```

## 🚀 Следующие шаги

1. **Интеграция с существующими сервисами**: Подключить protobuf sync к текущим BLoC и use cases
2. **Тестирование производительности**: Сравнить скорость и размер данных с JSON API  
3. **Офлайн поддержка**: Добавить queue-based синхронизацию для работы без сети
4. **Мониторинг**: Интегрировать метрики синхронизации в общую систему телеметрии