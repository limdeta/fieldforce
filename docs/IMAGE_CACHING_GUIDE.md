# Руководство по кэшированию изображений в fieldforce

## Обзор

В приложении fieldforce реализована система кэширования изображений с использованием библиотеки `cached_network_image`. Система оптимизирована для работы в условиях нестабильного интернета и экономии трафика.

## Основные компоненты

### ImageCacheService

Основной сервис для работы с кэшированием изображений расположен в `lib/shared/services/image_cache_service.dart`.

#### Методы для получения изображений:

```dart
// Для миниатюр (карточки продуктов, списки)
ImageCacheService.getCachedThumbnail(
  imageUrl: 'https://example.com/image.jpg',
  width: 56,
  height: 56,
  fit: BoxFit.cover,
)

// Для полноразмерных изображений (детали продукта, карусель)
ImageCacheService.getCachedFullImage(
  imageUrl: 'https://example.com/image.jpg',
  fit: BoxFit.contain,
)
```

#### Методы управления кэшем:

```dart
// Предзагрузка изображений
await ImageCacheService.precacheImages([
  'https://example.com/image1.jpg',
  'https://example.com/image2.jpg',
], thumbnail: true);

// Очистка кэша
await ImageCacheService.clearCache(
  thumbnails: true, 
  fullImages: true
);

// Информация о кэше
final info = ImageCacheService.getCacheInfo();
```

## Стратегия кэширования

### Два типа кэша

1. **Миниатюры** (`thumbnailCache`):
   - Время хранения: 30 дней
   - Максимум объектов: 1000
   - Используется для карточек продуктов, списков, превью

2. **Полные изображения** (`fullImageCache`):
   - Время хранения: 7 дней  
   - Максимум объектов: 200
   - Используется для детальных страниц, карусели изображений

### Принципы использования

1. **URL без изменений**: Не модифицируйте URL изображений (удален `_getSizedImageUrl`)
2. **Автоматические плейсхолдеры**: Встроенные индикаторы загрузки и обработка ошибок
3. **Предзагрузка**: Используйте `precacheImages` для улучшения UX
4. **Ленивая загрузка**: Кэш-менеджеры создаются только при первом использовании

## Примеры использования

### В виджетах продуктов

```dart
// Замените Image.network на кэшированную версию:

// Было:
Image.network(
  imageUrl,
  fit: BoxFit.cover,
  loadingBuilder: ...,
  errorBuilder: ...,
)

// Стало:
ImageCacheService.getCachedThumbnail(
  imageUrl: imageUrl,
  width: 56,
  height: 56,
  fit: BoxFit.cover,
)
```

### Предзагрузка в BLoC

```dart
void _precacheCartImages(List<OrderLine> orderLines) {
  final imageUrls = orderLines
      .where((line) => line.product?.defaultImage?.uri != null)
      .map((line) => line.product!.defaultImage!.uri)
      .toSet()
      .toList();

  if (imageUrls.isNotEmpty) {
    ImageCacheService.precacheImages(imageUrls, thumbnail: true);
  }
}
```

## Обновленные файлы

### Основные компоненты:
- `lib/shared/services/image_cache_service.dart` - новый сервис кэширования
- `pubspec.yaml` - добавлена зависимость `cached_network_image: ^3.3.1`

### Обновленные виджеты:
- `lib/features/shop/presentation/widgets/product_card_widget.dart` - миниатюры с кэшированием
- `lib/features/shop/presentation/product_detail_page.dart` - полные изображения с кэшированием  
- `lib/features/shop/presentation/widgets/image_carousel_widget.dart` - карусель с кэшированием
- `lib/features/shop/presentation/bloc/cart_bloc.dart` - предзагрузка изображений корзины

### Удаленная функциональность:
- Методы `_getSizedImageUrl` удалены из всех компонентов (использовались для добавления параметров размера)
- Прямое использование `Image.network` заменено на кэшированные варианты

## Преимущества

1. **Экономия трафика**: Изображения загружаются только один раз
2. **Быстрая отрисовка**: Кэшированные изображения отображаются мгновенно
3. **Офлайн-поддержка**: Кэшированные изображения доступны без сети
4. **Автоматическая очистка**: Старые файлы удаляются автоматически
5. **Оптимизация памяти**: Разные стратегии для миниатюр и полных изображений
6. **Защита от DDOS**: Битые URL блокируются после 3 неудачных попыток на 1 час
7. **Умный ретрай**: Повторные попытки через таймаут для восстановленных ресурсов

## Рекомендации

1. **Используйте правильный тип**: `getCachedThumbnail` для списков, `getCachedFullImage` для деталей
2. **Предзагружайте важные изображения**: Особенно для часто используемых продуктов
3. **Не изменяйте URL**: Сервис оптимизирован для работы с оригинальными URL
4. **Мониторьте размер кэша**: При необходимости используйте `clearCache()`

## Технические детали

- Библиотека: `cached_network_image ^3.3.1` + `flutter_cache_manager`
- Локация кэша: Определяется системой (временные файлы устройства)
- Стратегия выселения: LRU (Least Recently Used)
- Логирование: Интегрировано с системой логирования приложения (`logging` package)