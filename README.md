# Instock FieldForce

Приложение для торговых представителей компании

Любые взаимодействия с внешними сервисами делать в виде заглушек/моков которые будут максимально приближены к реальным api.

Roadmap:
 - Активация и запись реального трека (индикация, кнопки, логи для отладки)
 - Почистить test_service_locator
 - Поправить тесты
 - Синхронизация общий механизм
 - Синхронизация торговых точек
 - Страницы торговых точек
 - Оркестатор фикстур и рефакторинг фикстур
 - Задачи и планы продаж
 - Базовый сервис обновления
 - Взаимодействие с магазином (продукты, категории, заказ)
 - История заказов торговых точек
 - Разобраться с логами, дебаг-принтами и kDebugMode
 - Почистить модуль авторизации от ненужного

flutter pub run build_runner build --delete-conflicting-outputs
flutter test

пример интеграционного теста 
flutter test .\integration_test\login_test.dart -d windows --dart-define=ENV=dev

для разработки (dev режим по умолчанию с фикстурами)
flutter run -d windows --dart-define=flutter.flutter_map.unblockOSM="Our tile servers are not." --dart-define=ENV=dev

собрать для продакшена
flutter build apk --dart-define=ENV=prod --release 

под винду
flutter build windows --dart-define=ENV=prod --release