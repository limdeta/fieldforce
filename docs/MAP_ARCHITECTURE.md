# Архитектура карт и GPS-трекинга

## 🏗️ Основные компоненты

### 1. Map Service (Абстракция карт)
```
lib/features/map/
├── domain/
│   ├── entities/
│   │   ├── map_point.dart          # Координаты с метаданными
│   │   ├── map_bounds.dart         # Границы области карты
│   │   ├── map_tile.dart           # Тайлы карты для кеширования
│   │   └── navigation_route.dart   # Построенный маршрут
│   ├── repositories/
│   │   ├── imap_service.dart       # Абстракция карт
│   │   └── imap_cache_repository.dart # Кеширование тайлов
│   └── usecases/
│       ├── get_map_tiles_usecase.dart
│       ├── calculate_route_usecase.dart
│       └── get_current_location_usecase.dart
├── data/
│   ├── repositories/
│   │   ├── osm_map_service.dart    # OpenStreetMap реализация
│   │   ├── google_map_service.dart # Google Maps (будущее)
│   │   └── map_cache_repository.dart
│   └── datasources/
│       ├── osm_api_datasource.dart
│       └── map_cache_datasource.dart
└── presentation/
    ├── widgets/
    │   ├── map_widget.dart         # Основной виджет карты
    │   ├── route_overlay.dart      # Отображение маршрута
    │   └── poi_markers.dart        # Маркеры точек интереса
    └── providers/
        └── map_state_provider.dart
```

### 2. GPS Tracking Service
```
lib/features/gps_tracking/
├── domain/
│   ├── entities/
│   │   ├── gps_point.dart          # GPS координата с временем
│   │   ├── tracking_session.dart   # Сессия трекинга (рабочий день)
│   │   └── movement_segment.dart   # Сегмент движения
│   ├── repositories/
│   │   └── igps_tracking_repository.dart
│   └── usecases/
│       ├── start_tracking_usecase.dart
│       ├── stop_tracking_usecase.dart
│       └── get_tracking_data_usecase.dart
├── data/
│   ├── repositories/
│   │   └── gps_tracking_repository.dart
│   └── datasources/
│       ├── gps_sensor_datasource.dart
│       └── tracking_cache_datasource.dart
└── presentation/
    └── providers/
        └── gps_tracking_provider.dart
```

### 3. Navigation Service (будущее)
```
lib/features/navigation/
├── domain/
│   ├── entities/
│   │   ├── turn_instruction.dart
│   │   ├── traffic_info.dart
│   │   └── route_optimization.dart
│   └── usecases/
│       ├── build_optimized_route_usecase.dart
│       └── get_traffic_info_usecase.dart
└── data/
    └── datasources/
        ├── osrm_routing_datasource.dart # Open Source Routing
        └── traffic_api_datasource.dart
```

## 🔄 Интеграция с существующими маршрутами

### Связь Route (бизнес) ↔ GPS данные:
- Route содержит plannedPath (запланированный путь)
- TrackingSession записывает actualPath (фактический путь)
- Система сравнивает planned vs actual для аналитики

### Оптимизация данных:
- GPS точки группируются по времени/расстоянию
- Сжатие треков алгоритмом Douglas-Peucker
- Кеширование часто используемых областей карты

## 🛠️ Этапы реализации

### Этап 1 (текущий): Базовая карта
- [x] Интеграция OpenStreetMap
- [x] Отображение точек маршрута
- [ ] Простые маркеры POI

### Этап 2: GPS трекинг
- [ ] Непрерывная запись координат
- [ ] Оптимизация батареи
- [ ] Базовая аналитика пути

### Этап 3: Продвинутая навигация
- [ ] Построение маршрутов
- [ ] Учет трафика
- [ ] Голосовые подсказки

### Этап 4: Оффлайн режим
- [ ] Кеширование карт
- [ ] Локальная маршрутизация
- [ ] Синхронизация данных
