# App Layer Architecture

## Обзор

App layer (слой приложения) является оркестратором, который координирует работу независимых модулей (features) и обеспечивает их взаимодействие.

## Принципы

### 1. Оркестрация модулей
- App layer координирует взаимодействие между изолированными модулями
- Каждый модуль остается независимым и не знает о других модулях
- App layer знает обо всех модулях и организует их совместную работу

### 2. Презентационная архитектура
```
lib/
├── features/           # Независимые модули
│   ├── authentication/
│   │   └── presentation/
│   │       └── widgets/
│   │           └── authentication_widget.dart  # Независимый виджет
│   ├── navigation/
│   └── shop/
└── app/                # Слой приложения
    └── presentation/
        ├── pages/      # Страницы-оркестраторы
        │   ├── login_page.dart              # Использует AuthenticationWidget
        │   └── sales_rep_home_page.dart     # Комбинирует Route + Track
        └── widgets/    # Комбинированные виджеты
            └── combined_map_widget.dart     # Объединяет Map + Route + Track
```

### 3. Session Management
- **AppSession** - основная сессия приложения с удобными геттерами
- **AppUser** - агрегат пользователя, реализующий интерфейсы модулей
- **AppSessionService** - сервис управления сессией

## Компоненты App Layer

### Страницы-оркестраторы
Страницы в `app/presentation/pages/` координируют работу модулей:

```dart
// login_page.dart - оркестратор авторизации
class LoginPage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthenticationWidget(  // Независимый виджет из модуля
        onSuccess: (user) {
          // App layer знает что делать после авторизации
          _createAppSession(user);
          _navigateToHome();
        },
      ),
    );
  }
}
```

### Комбинированные виджеты
Виджеты в `app/presentation/widgets/` объединяют функциональность модулей:

```dart
// combined_map_widget.dart - объединяет Map + Route + Track
class CombinedMapWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    // Конвертирует типы и делегирует базовому MapWidget
    return MapWidget(
      route: route,                    // из shop/route модуля  
      historicalTracks: tracks,        // из navigation/tracking модуля
      center: convertCoordinates(center),  // конвертация типов
    );
  }
}
```

### Утилиты координации
App layer содержит утилиты для интеграции модулей:

```dart
// coordinate_converter.dart - конвертация между типами модулей
class CoordinateConverter {
  static MapPoint? latLngToMapPoint(LatLng? latLng) {
    // Конвертация между типами navigation и shop модулей
  }
}
```

## Примеры использования

### Фиксация после рефакторинга Route/Track

**Проблема**: После разделения Route и Track доменов, страницы которые показывали и маршруты и треки перестали работать.

**Решение App Layer**:
1. **CombinedMapWidget** - объединяет отображение Route и Track на карте
2. **SalesRepHomePage** - оркестратор, использует CombinedMapWidget
3. **CoordinateConverter** - решает проблемы совместимости типов

### Миграция с UserSession на AppSession

**Проблема**: Страницы использовали старый UserSession и GetCurrentSessionUseCase.

**Решение App Layer**:
1. Обновили страницы для использования **AppSessionService.getCurrentAppSession()**
2. Используем **session.appUser.employee** для получения данных Employee
3. **AppSession** предоставляет удобные геттеры для UI

## Паттерны

### 1. Delegation Pattern
App layer делегирует работу специализированным модулям:
```dart
// App layer не реализует карту сам, а использует MapWidget
return MapWidget(/* параметры из разных модулей */);
```

### 2. Adapter Pattern  
App layer адаптирует интерфейсы модулей друг к другу:
```dart
// Конвертирует LatLng в MapPoint для совместимости
center: CoordinateConverter.latLngToMapPoint(center)
```

### 3. Orchestrator Pattern
App layer координирует жизненный цикл и взаимодействие модулей:
```dart
// Загружает данные из разных модулей и координирует их отображение
final session = await AppSessionService.getCurrentAppSession();
final routes = _routeRepository.watchEmployeeRoutes(session.appUser.employee);
final tracks = await tracksProvider.loadUserTracks(session.appUser);
```

## Преимущества

1. **Модульность**: Каждый модуль остается независимым
2. **Переиспользование**: Модули можно использовать в разных комбинациях  
3. **Тестируемость**: Модули можно тестировать изолированно
4. **Расширяемость**: Легко добавлять новые модули или их комбинации
5. **Единообразие**: Централизованная координация в app layer

## Недостатки и компромиссы

1. **Сложность**: Дополнительный слой абстракции
2. **Дублирование**: Некоторые типы и адаптеры могут дублироваться
3. **Зависимости**: App layer знает обо всех модулях

Эти компромиссы оправданы для больших приложений где важна модульность и переиспользование кода.
