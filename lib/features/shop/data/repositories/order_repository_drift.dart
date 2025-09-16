import 'package:logging/logging.dart';
import 'package:drift/drift.dart';
import '../../../../app/database/database.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_line.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/trading_point.dart';
import '../../domain/entities/product.dart';
import '../mappers/order_mapper.dart';

class OrderRepositoryDrift implements OrderRepository {
  static final Logger _logger = Logger('OrderRepositoryDrift');
  
  final AppDatabase _database;

  OrderRepositoryDrift(this._database);

  @override
  Future<Order> getCurrentDraftOrder(int employeeId, int outletId) async {
    _logger.info('Getting current draft order for employee: $employeeId, outlet: $outletId');
    
    // Ищем существующий черновик
    final query = _database.select(_database.orders)
      ..where((order) => 
          order.creatorId.equals(employeeId) & 
          order.outletId.equals(outletId) &
          order.state.equals('draft'));
    
    final existingOrder = await query.getSingleOrNull();
    
    if (existingOrder != null) {
      _logger.info('Found existing draft order: ${existingOrder.id}');
      return await _buildOrderFromEntity(existingOrder);
    }
    
    // Создаем новый черновик если не найден
    _logger.info('Creating new draft order');
    
    // Получаем сотрудника и торговую точку
    final employee = await _getEmployeeById(employeeId);
    final outlet = await _getTradingPointById(outletId);
    
    final newOrder = Order.createDraft(
      creator: employee,
      outlet: outlet,
    );
    
    return await saveOrder(newOrder);
  }

  @override
  Future<Order> saveOrder(Order order) async {
    _logger.info('Saving order: ${order.id}');
    
    return await _database.transaction(() async {
      OrderEntity savedOrderEntity;
      
      if (order.id == null) {
        // Создаем новый заказ
        final orderCompanion = OrderMapper.toDatabase(order);
        final orderId = await _database.into(_database.orders).insert(orderCompanion);
        
        savedOrderEntity = await (_database.select(_database.orders)
          ..where((o) => o.id.equals(orderId))).getSingle();
        
        _logger.info('Created new order with id: $orderId');
      } else {
        // Обновляем существующий заказ
        final orderCompanion = OrderMapper.toDatabase(order);
        await (_database.update(_database.orders)
          ..where((o) => o.id.equals(order.id!)))
          .write(orderCompanion);
        
        savedOrderEntity = await (_database.select(_database.orders)
          ..where((o) => o.id.equals(order.id!))).getSingle();
        
        _logger.info('Updated order: ${order.id}');
      }
      
      // Сохраняем строки заказа
      await _saveOrderLines(savedOrderEntity.id, order.lines);
      
      return await _buildOrderFromEntity(savedOrderEntity);
    });
  }

  @override
  Future<Order?> getOrderById(int id) async {
    _logger.info('Getting order by id: $id');
    
    final orderEntity = await (_database.select(_database.orders)
      ..where((order) => order.id.equals(id))).getSingleOrNull();
    
    if (orderEntity == null) {
      _logger.warning('Order not found: $id');
      return null;
    }
    
    return await _buildOrderFromEntity(orderEntity);
  }

  @override
  Future<List<Order>> getOrdersByEmployee(int employeeId) async {
    _logger.info('Getting orders by employee: $employeeId');
    
    final orderEntities = await (_database.select(_database.orders)
      ..where((order) => order.creatorId.equals(employeeId))).get();
    
    final orders = <Order>[];
    for (final entity in orderEntities) {
      orders.add(await _buildOrderFromEntity(entity));
    }
    
    return orders;
  }

  @override
  Future<List<Order>> getOrdersByState(String state) async {
    _logger.info('Getting orders by state: $state');
    
    final orderEntities = await (_database.select(_database.orders)
      ..where((order) => order.state.equals(state))).get();
    
    final orders = <Order>[];
    for (final entity in orderEntities) {
      orders.add(await _buildOrderFromEntity(entity));
    }
    
    return orders;
  }

  @override
  Future<List<Order>> getOrdersByOutlet(int outletId) async {
    _logger.info('Getting orders by outlet: $outletId');
    
    final orderEntities = await (_database.select(_database.orders)
      ..where((order) => order.outletId.equals(outletId))).get();
    
    final orders = <Order>[];
    for (final entity in orderEntities) {
      orders.add(await _buildOrderFromEntity(entity));
    }
    
    return orders;
  }

  @override
  Future<void> deleteOrder(int id) async {
    _logger.info('Deleting order: $id');
    
    await _database.transaction(() async {
      // Сначала удаляем строки заказа (cascade должен сработать автоматически)
      await (_database.delete(_database.orderLines)
        ..where((line) => line.orderId.equals(id))).go();
      
      // Затем удаляем сам заказ
      await (_database.delete(_database.orders)
        ..where((order) => order.id.equals(id))).go();
    });
  }

  @override
  Future<void> clearAllDrafts() async {
    _logger.info('Clearing all draft orders');
    
    await _database.transaction(() async {
      // Получаем все ID черновиков
      final draftIds = await (_database.select(_database.orders)
        ..where((order) => order.state.equals('draft')))
        .map((order) => order.id).get();
      
      // Удаляем строки заказов
      for (final orderId in draftIds) {
        await (_database.delete(_database.orderLines)
          ..where((line) => line.orderId.equals(orderId))).go();
      }
      
      // Удаляем сами заказы
      await (_database.delete(_database.orders)
        ..where((order) => order.state.equals('draft'))).go();
    });
  }

  /// Собирает Order из OrderEntity с загрузкой связанных данных
  Future<Order> _buildOrderFromEntity(OrderEntity orderEntity) async {
    // Загружаем сотрудника
    final employee = await _getEmployeeById(orderEntity.creatorId);
    
    // Загружаем торговую точку
    final outlet = await _getTradingPointById(orderEntity.outletId);
    
    // Загружаем строки заказа
    final orderLines = await _getOrderLines(orderEntity.id);
    
    return OrderMapper.fromDatabaseEntities(
      orderEntity,
      employee,
      outlet,
      orderLines,
    );
  }

  /// Сохраняет строки заказа
  Future<void> _saveOrderLines(int orderId, List<OrderLine> lines) async {
    // Удаляем существующие строки
    await (_database.delete(_database.orderLines)
      ..where((line) => line.orderId.equals(orderId))).go();
    
    // Вставляем новые строки
    for (final line in lines) {
      final lineCompanion = OrderLineMapper.toDatabase(line, orderId);
      await _database.into(_database.orderLines).insert(lineCompanion);
    }
  }

  /// Загружает строки заказа с полными данными StockItem
  Future<List<OrderLine>> _getOrderLines(int orderId) async {
    // Получаем строки заказа
    final orderLineEntities = await (_database.select(_database.orderLines)
      ..where((line) => line.orderId.equals(orderId))).get();
    
    final lines = <OrderLine>[];
    
    for (final lineEntity in orderLineEntities) {
      // TODO: Здесь нужно загрузить реальный StockItem по lineEntity.stockItemId
      // Пока создаем заглушку StockItem
      final stockItem = _createStockItemStub(lineEntity.stockItemId);
      
      final line = OrderLine(
        id: lineEntity.id,
        orderId: orderId,
        stockItem: stockItem,
        quantity: lineEntity.quantity,
        pricePerUnit: lineEntity.pricePerUnit,
        createdAt: lineEntity.createdAt,
        updatedAt: lineEntity.updatedAt,
      );
      
      lines.add(line);
    }
    
    return lines;
  }

  /// Получает сотрудника по ID
  Future<Employee> _getEmployeeById(int employeeId) async {
    final employeeEntity = await (_database.select(_database.employees)
      ..where((e) => e.id.equals(employeeId))).getSingle();
    
    // TODO: заменить на EmployeeMapper.fromDatabase когда будет доступен
    return Employee(
      id: employeeEntity.id,
      firstName: employeeEntity.firstName,
      lastName: employeeEntity.lastName,
      middleName: employeeEntity.middleName,
      role: EmployeeRole.values.firstWhere(
        (role) => role.name == employeeEntity.role,
        orElse: () => EmployeeRole.sales,
      ),
      assignedTradingPoints: [],
    );
  }

  /// Получает торговую точку по ID
  Future<TradingPoint> _getTradingPointById(int outletId) async {
    final outletEntity = await (_database.select(_database.tradingPointEntities)
      ..where((tp) => tp.id.equals(outletId))).getSingle();
    
    // TODO: заменить на TradingPointMapper.fromDatabase когда будет доступен
    return TradingPoint(
      id: outletEntity.id,
      externalId: outletEntity.externalId,
      name: outletEntity.name,
      inn: outletEntity.inn,
    );
  }

  /// Создает заглушку StockItem для тестирования
  /// TODO: заменить на загрузку из базы данных когда StockItem будет в БД
  StockItem _createStockItemStub(int stockItemId) {
    // Создаем заглушки
    final warehouse = Warehouse(
      id: 1,
      name: 'Тестовый склад',
      vendorId: 'test_warehouse',
      isPickUpPoint: false,
    );
    
    final product = Product(
      title: 'Тестовый продукт $stockItemId',
      barcodes: [],
      code: stockItemId,
      bcode: stockItemId,
      catalogId: 1,
      novelty: false,
      popular: false,
      isMarked: false,
      images: [],
      categoriesInstock: [],
      numericCharacteristics: [],
      stringCharacteristics: [],
      boolCharacteristics: [],
      stockItems: [], // Будет заполнено позже
      canBuy: true,
    );
    
    return StockItem(
      id: stockItemId,
      product: product,
      warehouse: warehouse,
      stock: 100, // Заглушка остатка
      multiplicity: 1,
      publicStock: '100+ шт',
      defaultPrice: 10000, // 100 рублей в копейках
      discountValue: 0,
      availablePrice: null,
      offerPrice: 9500, // 95 рублей в копейках (со скидкой)
      promotion: null,
    );
  }
}