<!-- Составлено на основе README.md, docs/ и ключевых файлов в lib/ -->
# fieldforce — краткое руководство для AI-кодингового ассистента

Этот файл даёт краткие, практичные подсказки для AI-агентов, чтобы быстро работать с этим репозиторием.

1) Краткая суть проекта
- Архитектура: модульное Flutter-приложение, где каждая фича живёт в `lib/features/`. Папка `app/` — уровень оркестрации (страницы, DI, фикстуры, сервисы). См. `docs/APP_LAYER_ARCHITECTURE.md` для деталей.
- Точка входа: `lib/main.dart`. Она читает `AppConfig` (dart-define), настраивает контейнер зависимостей (prod vs test) и поднимает фикстуры/менеджеры жизненного цикла.

О приложении — для чего оно
- Это внутреннее приложение компании: инструмент для торговых представителей и супервайзеров.
- Супервайзер в отдельной админ-панели (не в этом репозитории) создаёт сущности — маршруты, задачи, планы и т.д. Эти сущности назначаются конкретным торговым представителям (ТП).
- ТП ежедневно объезжают маршруты, посещают торговые точки и выполняют задачи, поставленные руководством. Приложение отслеживает с помощью GPS где и когда ТП перемещаются и какие действия выполняют.
- В этом репозитории нет реального бэкенда. Для разработки мы рассматриваем бэкенд как внешнюю систему и генерируем данные-фейковые (фикстуры) с помощью `DevFixtureOrchestrator`.
- Приложение офлайн-первичное (offline-first): данные кэшируются локально и синхронизируются с админ-панелью при доступе в сеть. Ожидается, что ТП часто работают оффлайн и на старых устройствах — фокус на устойчивость, экономию батареи и трафика.
- Тестирование: предпочитаем `integration_test` для end-to-end сценариев (в будущем возможно BDD). Unit-тесты важны; TDD желателен, но не всегда применим.

2) Основные команды и рабочие потоки
- Генерация кода (drift / build_runner):
  - `flutter pub run build_runner build --delete-conflicting-outputs`
- Запуск всех тестов:
  - `flutter test`
- Пример запуска одного интеграционного теста (Windows):
  - `flutter test .\\integration_test\\login_test.dart -d windows --dart-define=ENV=dev`
- Запуск приложения локально (dev — фикстуры по умолчанию):
  - `flutter run -d windows --dart-define=flutter.flutter_map.unblockOSM="Our tile servers are not." --dart-define=ENV=dev`
- Сборка релиза (APK / Windows):
  - `flutter build apk --dart-define=ENV=prod --release`
  - `flutter build windows --dart-define=ENV=prod --release`

3) DI и среда выполнения
- Контейнер зависимостей: `lib/app/di/service_locator.dart` (prod) и `lib/app/di/test_service_locator.dart` (dev/test). В `main.dart` вызывается `AppConfig.configureFromArgs()` и выбирается нужный DI.
- Флаги конфигурации: `lib/app/config/app_config.dart`. Используйте `--dart-define=ENV=dev|prod` и другие флаги в `AppConfig` для переключения поведения (кеширование тайлов, чек обновлений, mock GPS и т.д.).

4) Фикстуры, тестовые данные и GPS-mock
- Оркестратор фикстур: `lib/app/fixtures/dev_fixture_orchestrator.dart` — создаёт маршруты, точки и треки в dev режиме.
- `GpsDataManager` поддерживает mock-режим (в `test_service_locator.dart` инициализируется с `GpsMode.mock`) и реальный GPS в проде.

5) Конвенции и паттерны
- Изоляция фич: реализация фич должна находиться в `lib/features/<feature>/` с разделением domain / data / presentation. Логика оркестрации — в `lib/app/`.
- BLoC: проект использует BLoC (см. `docs/BLOC_REFACTORING_SUMMARY.md`). Структура: `bloc/` (events, states, bloc), `page.dart` для UI, `usecases` в domain. DI — через GetIt.
- База данных: Drift; репозитории находятся в `lib/app/database/repositories/`. В DI регистрируется `AppDatabase.withFile(AppConfig.databaseName)`.

6) Тесты и CI рекомендации
- Тесты полагаются на `test_service_locator` — регистрация тестового DI (setupTestServiceLocator) обеспечивает DB и mock-объекты.
- Интеграционные тесты часто требуют `--dart-define=ENV=dev` для использования фикстур.

7) Файлы для быстрого старта при изменениях архитектуры
- DI и оркестрация: `lib/app/di/service_locator.dart`, `lib/app/di/test_service_locator.dart`
- Точка входа и таблица маршрутов: `lib/main.dart`
- Документация app-уровня: `docs/APP_LAYER_ARCHITECTURE.md`
- Руководство по BLoC: `docs/BLOC_REFACTORING_SUMMARY.md`
- Фикстуры: `lib/app/fixtures/`, `lib/features/*/data/fixtures/`

8) Примеры и шаблоны (для PR)
- Добавление страницы-фичи: положите страницу в `app/presentation/pages/`, создайте BLoC в `feature/.../presentation/bloc/`, зарегистрируйте use-cases/репозитории в `service_locator.dart` и добавьте маршрут в `main.dart`.
- Создание dev-фикстур: добавьте FixtureService, зарегистрируйте его в `test_service_locator.dart` и подключите в `DevFixtureOrchestrator`.

9) Безопасность и локальная разработка
- Внешние интеграции должны быть заглушками в процессе разработки. README прямо указывает: хранить внешние вызовы как мок/заглушки.
- Не коммитить секреты. Имя БД и флаги отладки контролируются `AppConfig` и `--dart-define`.

10) Логирование (важно)
- В приложении используется пакет `logging`. Пожалуйста, не оставляйте `print(...)` или `debugPrint(...)` в коде — мы их постепенно удаляем и переходим на `logging`.
- Используйте отдельный логгер для каждого класса/модуля. Пример (как в `TileCacheService`):

```dart
class TileCacheService {
  static final Logger _logger = Logger('TileCacheService');
  // ...existing code...
}
```

- В `main.dart` настраивается глобальный уровень и слушатель записей, например:

```dart
Logger.root.level = Level.INFO; // или Level.FINER для локальной отладки
Logger.root.onRecord.listen((record) {
  debugPrint('${record.level.name}: ${record.time}: ${record.message}');
});
```

- Уровни логирования: используйте `severe` для критичных ошибок, `warning` для потенциальных проблем, `info` для важных событий, `fine/finer` для детальной отладки. Не логируйте секреты/персональные данные.
- Для ошибок передавайте `error` и `stackTrace` в `_logger.severe(...)` или `_logger.shout(...)`, чтобы записи содержали трассировку:

```dart
try {
  // ...
} catch (e, st) {
  _logger.severe('Ошибка обработки тайла', e, st);
}
```

- В тестах и CI установите подходящий уровень логирования или перенаправляйте записи в тестовый обработчик, чтобы избегать шумных логов.
