# Интеграция заказов с бэкендом

## Цель
Реализовать отправку заказов из мобильного приложения на Symfony бэкенд через REST API с сохранением offline-first подхода.

## Архитектурные решения

### Безопасность
- **Используем существующую сессию**: `SessionManager.httpClient` уже настроен с cookies/headers
- На бэкенде `$this->getUser()` автоматически получит пользователя из сессии
- Никаких дополнительных токенов не требуется

### API Endpoint
```
POST /v1_api/mobile/orders
Content-Type: application/json
```

### Payload формат
Упрощённый payload (только необходимые поля):
```json
{
  "clientOrderId": "uuid-v4",
  "outletId": 123,
  "comment": "string|null",
  "name": "string|null",
  "isPickup": true,
  "approvedDeliveryDay": "2026-01-10T00:00:00Z",
  "approvedAssemblyDay": "2026-01-12T00:00:00Z",
  "paymentKind": {
    "payment": "cashless|cash",
    "method": "wholesale|retail",
    "payOnReceive": false
  },
  "lines": [
    {
      "stockItemId": 456,
      "quantity": 10,
      "price": 12500
    }
  ]
}
```

**Убираем из payload:**
- `withRealization` - не нужно с мобильного
- `creator` - бэкенд знает из сессии
- `state` - бэкенд сам управляет
- `totals` - бэкенд пересчитает
- `failureReason` - внутреннее поле мобильного

### Response формат
**Success (201 Created):**
```json
{
  "orderId": 789,
  "status": "confirmed"
}
```

**Error (400 Bad Request):**
```json
{
  "error": "invalid_delivery_date|empty_order|validation_failed",
  "message": "Доставка недоступна в выбранный день",
  "details": {}
}
```

### Идемпотентность
- Каждый заказ при создании получает `clientOrderId` (UUID v4)
- При повторной отправке того же `clientOrderId` бэкенд вернёт существующий заказ (не создаст дубликат)
- Критично для retry logic

## Обработка ошибок

### Типы ошибок
1. **Валидация данных (400)** - заказ возвращается в draft, пользователь исправляет
   - `invalid_delivery_date` - неверная дата доставки
   - `empty_order` - заказ без строк
   - `invalid_outlet` - торговая точка не найдена

2. **Сетевые ошибки (500/timeout)** - retry через queue
   - Автоматический retry (3 попытки)
   - Экспоненциальная задержка (5, 10 минут)

3. **Критические ошибки** - заказ в состояние error
   - После 3 неудачных попыток
   - Требует ручного вмешательства

### Логика обработки
```dart
switch (statusCode) {
  case 201: return success
  case 400: return validation error → draft
  case 401/403: return auth error → logout?
  case 500/502/503: return network error → retry
  case timeout: return network error → retry
}
```

## Расписание доставки торговых точек

### Текущее состояние
- В `TradingPoint` нет поля с расписанием
- Бэкенд самостоятельно валидирует даты доставки
- При невалидной дате возвращает 400 с `invalid_delivery_date`

### Будущая реализация (offline-first)
1. Добавить поле `deliverySchedule` в `TradingPoint`:
   ```dart
   final DeliverySchedule? deliverySchedule;
   ```

2. Создать entity `DeliverySchedule`:
   ```dart
   class DeliverySchedule {
     final List<int> allowedWeekdays; // [1,3,5] = пн,ср,пт
     final List<DateTime> excludedDates; // праздники
   }
   ```

3. Создать `ValidateDeliveryDateUseCase` для локальной проверки

4. В UI блокировать недоступные дни в date picker

5. Синхронизация с бэкенда при загрузке точек

**Важно:** Даже с локальной валидацией бэкенд остаётся source of truth (расписание могло измениться).

## Backend Implementation

### Controller (Symfony)
```php
#[Route('/v1_api/mobile/orders', methods: ['POST'])]
public function submitOrder(Request $request, OrderService $orderService): Response
{
    $user = $this->getUser();
    if (!$user) {
        return $this->errorResponse(["Нет пользователя"], 403);
    }

    $data = json_decode($request->getContent(), true);
    
    // Валидация
    if (!$data || empty($data['lines'])) {
        return $this->errorResponse([
            'error' => 'empty_order',
            'message' => 'Заказ пуст'
        ], 400);
    }

    // Идемпотентность
    if (isset($data['clientOrderId'])) {
        $existing = $orderService->findByClientOrderId($data['clientOrderId']);
        if ($existing) {
            return $this->jsonResponse([
                'orderId' => $existing->getId(),
                'status' => 'confirmed'
            ]);
        }
    }

    // Создание заказа
    try {
        $order = $orderService->createFromMobile($user, $data);
        
        return $this->jsonResponse([
            'orderId' => $order->getId(),
            'status' => 'confirmed'
        ], 201);
        
    } catch (InvalidDeliveryDateException $e) {
        return $this->errorResponse([
            'error' => 'invalid_delivery_date',
            'message' => $e->getMessage()
        ], 400);
    }
}
```

### OrderService::createFromMobile()
```php
public function createFromMobile(User $user, array $data): Order
{
    $outlet = $this->outletRepo->find($data['outletId']);
    if (!$outlet) {
        throw new OutletNotFoundException();
    }

    // Валидация даты доставки
    if ($data['approvedDeliveryDay']) {
        $deliveryDate = new \DateTimeImmutable($data['approvedDeliveryDay']);
        if (!$outlet->canDeliverOn($deliveryDate)) {
            throw new InvalidDeliveryDateException(
                'Доставка недоступна в выбранный день'
            );
        }
    }

    $order = new Order($user, $outlet);
    
    // Добавляем строки
    foreach ($data['lines'] as $lineData) {
        $stockItem = $this->stockItemRepo->find($lineData['stockItemId']);
        $order->addLine($stockItem, $lineData['quantity'], $lineData['price']);
    }
    
    // Настройки
    $order->setPaymentKind(PaymentKind::fromArray($data['paymentKind']));
    $order->setComment($data['comment'] ?? null);
    $order->setName($data['name'] ?? null);
    $order->setIsPickup($data['isPickup'] ?? true);
    
    if ($data['approvedDeliveryDay']) {
        $order->setApprovedDeliveryDay(
            new \DateTimeImmutable($data['approvedDeliveryDay'])
        );
    }
    
    if ($data['approvedAssemblyDay']) {
        $order->setApprovedAssemblyDay(
            new \DateTimeImmutable($data['approvedAssemblyDay'])
        );
    }
    
    // Сохраняем clientOrderId для идемпотентности
    $order->setClientOrderId($data['clientOrderId']);
    
    $this->em->persist($order);
    $this->em->flush();
    
    return $order;
}
```

### Database миграция
Добавить поле `client_order_id` в таблицу `orders`:
```sql
ALTER TABLE orders ADD COLUMN client_order_id VARCHAR(36) UNIQUE NULL;
CREATE INDEX idx_orders_client_order_id ON orders(client_order_id);
```

## Mobile Implementation

### 1. Упростить Order.toApiPayload()
```dart
Map<String, dynamic> toApiPayload() {
  return {
    'clientOrderId': id?.toString() ?? const Uuid().v4(),
    'outletId': outlet.id,
    'comment': comment,
    'name': name,
    'isPickup': isPickup,
    'approvedDeliveryDay': approvedDeliveryDay?.toIso8601String(),
    'approvedAssemblyDay': approvedAssemblyDay?.toIso8601String(),
    'paymentKind': {
      'payment': paymentKind.paymentCode,
      'method': paymentKind.methodCode,
      'payOnReceive': paymentKind.payOnReceive,
    },
    'lines': lines.map((line) => {
      'stockItemId': line.stockItemId,
      'quantity': line.quantity,
      'price': line.price,
    }).toList(),
  };
}
```

### 2. Расширить Order entity
Добавить поле для clientOrderId:
```dart
final String clientOrderId; // UUID для идемпотентности
```

### 3. Создать RealOrderApiService
```dart
class RealOrderApiService implements OrderApiService {
  final SessionManager _sessionManager;
  
  RealOrderApiService(this._sessionManager);

  @override
  Future<Either<OrderSubmissionError, void>> submitOrder(Order order) async {
    try {
      final client = _sessionManager.httpClient;
      final url = Uri.parse('${AppConfig.baseUrl}/v1_api/mobile/orders');
      
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(order.toApiPayload()),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        // Success - можно сохранить serverOrderId
        final data = jsonDecode(response.body);
        _logger.info('Order submitted: ${data['orderId']}');
        return const Right(null);
      }

      if (response.statusCode == 400) {
        // Validation error - не retry
        final error = jsonDecode(response.body);
        return Left(OrderSubmissionError.validationError(
          error['message'] ?? 'Ошибка валидации заказа',
        ));
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return Left(OrderSubmissionError.unauthorized());
      }

      // Server errors - retry
      return Left(OrderSubmissionError.networkError(
        'Server error: ${response.statusCode}',
      ));

    } on TimeoutException {
      return Left(OrderSubmissionError.networkError('Request timeout'));
    } on SocketException {
      return Left(OrderSubmissionError.networkError('No internet connection'));
    } catch (e, st) {
      _logger.severe('Unexpected error submitting order', e, st);
      return Left(OrderSubmissionError.unknownError(e.toString()));
    }
  }
}
```

### 4. Обновить OrderSubmissionError
```dart
enum OrderSubmissionErrorType {
  networkError,      // Retry
  validationError,   // Return to draft
  unauthorized,      // Logout?
  unknownError,      // Mark as error
}

class OrderSubmissionError {
  final OrderSubmissionErrorType type;
  final String message;
  
  bool get shouldRetry => type == OrderSubmissionErrorType.networkError;
  bool get shouldReturnToDraft => type == OrderSubmissionErrorType.validationError;
}
```

### 5. Обновить OrderSubmissionQueueService
```dart
Future<void> _processJob(JobQueueItem job) async {
  final order = await _getOrder(job.relatedEntityId);
  final result = await _orderSubmissionService.submitOrder(order);

  result.fold(
    (error) {
      if (error.shouldReturnToDraft) {
        // Validation error - return to draft
        _orderRepository.update(
          order.returnToDraft().updateComment(
            'Ошибка: ${error.message}'
          )
        );
        _jobQueueRepo.complete(job.id);
      } else if (error.shouldRetry) {
        // Network error - schedule retry
        _scheduleRetry(job);
      } else {
        // Unknown error - mark as error after max attempts
        if (job.attempt >= maxAttempts) {
          _orderRepository.update(
            order.markAsError(reason: error.message)
          );
          _jobQueueRepo.complete(job.id);
        } else {
          _scheduleRetry(job);
        }
      }
    },
    (_) {
      // Success
      _orderRepository.update(order.confirm());
      _jobQueueRepo.complete(job.id);
    },
  );
}
```

### 6. Регистрация в DI
```dart
// lib/app/di/service_locator.dart
void setupOrderServices() {
  if (AppConfig.isProd) {
    getIt.registerLazySingleton<OrderApiService>(
      () => RealOrderApiService(getIt<SessionManager>()),
    );
  } else {
    getIt.registerLazySingleton<OrderApiService>(
      () => MockOrderApiService(),
    );
  }
}
```

## Тестирование

### Best Practices
1. **Unit тесты** - используют MockOrderApiService
   - Тестируют бизнес-логику без реального HTTP
   - Быстрые, изолированные

2. **Integration тесты** - используют fake HTTP server или реальный dev backend
   - Проверяют полный флоу отправки
   - Могут быть медленнее

3. **Не тестируем RealOrderApiService напрямую** - это просто HTTP wrapper
   - Доверяем http пакету
   - Тестируем через интерфейс OrderApiService

### Unit тесты
```dart
// test/features/shop/domain/services/order_submission_queue_service_test.dart

test('returns order to draft on validation error', () async {
  final mockApi = MockOrderApiService();
  mockApi.nextResult = Left(
    OrderSubmissionError.validationError('Invalid date')
  );
  
  // ... test logic
  
  verify(orderRepo.update(argThat(
    predicate<Order>((o) => o.state == OrderState.draft)
  )));
});

test('schedules retry on network error', () async {
  final mockApi = MockOrderApiService();
  mockApi.nextResult = Left(
    OrderSubmissionError.networkError('Timeout')
  );
  
  // ... test logic
  
  verify(jobQueueRepo.scheduleRetry(any, any));
});
```

### Integration тесты
```dart
// integration_test/order_submission_test.dart

testWidgets('submit order successfully', (tester) async {
  // Setup: create order in draft
  // Action: submit order
  // Assert: order confirmed, appears in backend
});

testWidgets('handle validation error gracefully', (tester) async {
  // Setup: create order with invalid date
  // Action: submit order
  // Assert: order returned to draft with error message
});
```

## План внедрения

### Этап 1: Backend (Symfony)
- [ ] Добавить `client_order_id` в Order entity + миграция
- [ ] Создать `OrderService::findByClientOrderId()`
- [ ] Создать `OrderService::createFromMobile()`
- [ ] Реализовать контроллер `submitOrder()`
- [ ] Добавить валидацию дат доставки
- [ ] Написать unit тесты для OrderService

### Этап 2: Mobile (Flutter)
- [ ] Добавить `clientOrderId` в Order entity
- [ ] Упростить `Order.toApiPayload()`
- [ ] Создать `OrderSubmissionError` с типами
- [ ] Реализовать `RealOrderApiService`
- [ ] Обновить `OrderSubmissionQueueService` для обработки ошибок
- [ ] Регистрировать `RealOrderApiService` в prod DI
- [ ] Написать unit тесты

### Этап 3: Тестирование
- [ ] Unit тесты для error handling
- [ ] Integration тесты для submission flow
- [ ] Тестирование идемпотентности
- [ ] Тестирование retry logic
- [ ] Тестирование offline → online transition

### Этап 4: Будущие улучшения
- [ ] Добавить `deliverySchedule` в TradingPoint
- [ ] Реализовать локальную валидацию дат
- [ ] Синхронизация истории заказов с бэкенда
- [ ] Аналитика заказов по торговым точкам

## Checklist перед деплоем

- [ ] AppConfig.baseUrl настроен для prod
- [ ] SessionManager корректно работает с prod бэкендом
- [ ] Тесты проходят на dev окружении
- [ ] Проверена обработка всех типов ошибок
- [ ] Логирование настроено (без секретов)
- [ ] Retry logic протестирован
- [ ] Идемпотентность работает корректно
