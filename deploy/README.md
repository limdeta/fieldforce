# FieldForce Deployment Scripts

Скрипты для автоматического деплоя обновлений FieldForce на продакшен сервер.

## 🚀 Быстрый старт для нового разработчика

### Пошаговая инструкция для создания новой версии:

1. **Внесите изменения в код** и протестируйте их локально
2. **Обновите версию в `pubspec.yaml`** (например, с `1.0.0` на `1.0.1`)
3. **Настройте конфигурацию** (только первый раз):
   ```bash
   cd deploy
   cp .env.example .env
   # Отредактируйте .env файл, укажите ваш SERVER_USER
   ```
4. **Соберите и задеплойте новую версию**:
   ```bash
   # Автоматический деплой
   dart deploy_update.dart "🚀 Описание изменений в этой версии"
   
   # Или пошагово:
   dart deploy_update.dart --show-commands "🚀 Описание изменений"
   # Выполните показанные команды вручную
   ```
5. **Проверьте результат**: приложения получат уведомление об обновлении!

### ⚡ Если у вас уже есть собранный APK:
```bash
dart deploy_update.dart --skip-build "🚀 Описание изменений"
```

### 🛠️ Если есть проблемы с SSH:
```bash
dart deploy_update.dart --show-commands "🚀 Описание изменений"
# Выполните показанные scp команды вручную
```

---

## 📋 Подробная документация

### Что делают скрипты

1. **Сборка APK**: `flutter build apk --release --dart-define=ENV=prod`
2. **Создание metadata**: Генерируют `update-info.json` с changelog
3. **Загрузка на сервер**: 
   - APK → `/var/www/mobile-app/releases/`
   - Metadata → `/var/www/mobile-app/update-info.json`
4. **Обновление версии**: POST к `/v1_api/mobile-sync/app/refresh`
5. **Очистка**: Удаление временных файлов

### Доступные команды

#### PowerShell (Windows):
```powershell
.\deploy-update.ps1 "1.2.0" "🚀 Новые функции в каталоге товаров"
```

#### Dart (кроссплатформенно):
```bash
# Полный цикл с указанием версии и changelog
dart deploy_update.dart "1.2.0" "🚀 Новые функции в каталоге товаров"

# Автоматическая версия из pubspec.yaml
dart deploy_update.dart "🚀 Новые функции в каталоге товаров"

# Пропустить сборку (если APK уже собран)
dart deploy_update.dart --skip-build "🔧 Исправления ошибок"

# Только показать команды для ручного выполнения
dart deploy_update.dart --show-commands "✨ Улучшения интерфейса"

# Интерактивный режим (если нужен ввод пароля)
dart deploy_update.dart --interactive "🎨 Обновления дизайна"
```

### Структура файлов

```
deploy/
├── deploy_update.dart      # 🎯 Основной скрипт (Dart)
├── deploy-update.ps1       # 🔧 PowerShell альтернатива  
├── .env                    # 🔐 Ваша конфигурация (НЕ в git)
├── .env.example           # 📝 Пример конфигурации
├── releases/              # 📱 Собранные APK файлы
│   └── fieldforce-v*.apk  # (временные, удаляются после деплоя)
├── update-info.json       # 📄 Metadata с changelog (временный)
└── README.md              # 📖 Эта инструкция
```

### Настройка конфигурации

Создайте файл `.env` из примера:
```bash
cp .env.example .env
```

Обязательные параметры в `.env`:
```properties
# Сервер
SERVER_HOST=api.instock-dv.ru
SERVER_USER=ваш-пользователь
SERVER_PATH=/var/www/mobile-app

# Безопасность  
UPDATE_SECRET=frozenseaoverganimede
```

### Требования

- **Flutter SDK** (для сборки APK)
- **SSH доступ** к серверу (ключи или пароль)
- **SCP** (OpenSSH или Git for Windows)
- **Dart** (входит в Flutter SDK)

### API Endpoints

После деплоя доступны:

- **📋 Version API**: `https://api.instock-dv.ru/v1_api/mobile-sync/app/version`
- **📥 Download**: `https://www.instock-dv.ru/v1_api/mobile-sync/app/download/fieldforce-v1.2.0.apk`
- **🔄 Refresh**: `POST https://api.instock-dv.ru/v1_api/mobile-sync/app/refresh`

### Безопасность

- ✅ Конфигурация в `.env` файлах (не в git)
- ✅ Секретный ключ для API обновлений
- ✅ Валидация версий и файлов
- ✅ Временные файлы автоматически удаляются

### Как работает обновление в приложении

1. **Автоматическая проверка**: При запуске (если включено в настройках)
2. **Ручная проверка**: Через меню "Проверить обновления"  
3. **Сравнение версий**: Приложение сравнивает свою версию с API
4. **Диалог обновления**: Показывает changelog и кнопки действий
5. **Android**: Автоматическое скачивание и установка APK
6. **Другие платформы**: Открывает ссылку в браузере

### Troubleshooting

**🔧 APK не собирается:**
```bash
flutter clean
flutter pub get
dart deploy_update.dart
```

**🔧 SSH зависает:**
```bash
# Используйте режим показа команд
dart deploy_update.dart --show-commands "описание"
# Выполните scp команды вручную
```

**🔧 Проблемы с правами на сервере:**
```bash
# На сервере выполните:
sudo usermod -a -G www-data ваш-пользователь
sudo chmod 664 /var/www/mobile-app/update-info.json
```

**🔧 Кодировка в changelog:**
- Используйте UTF-8 в терминале
- Эмодзи и кириллица поддерживаются ✨🚀

---

## 🎉 Готово!

После успешного деплоя пользователи получат уведомление об обновлении с вашим changelog!