import '../../domain/entities/product.dart';
import 'package:logging/logging.dart';
import 'package:drift/drift.dart';
import '../../../../app/database/database.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_line.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/trading_point.dart';
import '../../domain/entities/stock_item.dart';
import '../mappers/order_mapper.dart';

class OrderRepositoryDrift implements OrderRepository {
  static final Logger _logger = Logger('OrderRepositoryDrift');
  
  final AppDatabase _database;
  final ProductRepository _productRepository;

  OrderRepositoryDrift(this._database, this._productRepository);

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
    _logger.info('📦 Building order from entity: id=${orderEntity.id}, creatorId=${orderEntity.creatorId}');
    
    final employee = await _getEmployeeById(orderEntity.creatorId);
    final outlet = await _getTradingPointById(orderEntity.outletId);
    final orderLines = await _getOrderLines(orderEntity.id);
    
    final order = OrderMapper.fromDatabaseEntities(
      orderEntity,
      employee,
      outlet,
      orderLines,
    );
    
    return order;
  }

  /// Сохраняет строки заказ
  Future<void> _saveOrderLines(int orderId, List<OrderLine> lines) async {
    
    if (lines.isEmpty) {
      return;
    }
    
    try {
      // Удаляем существующие строки (только если заказ уже существует)
      await (_database.delete(_database.orderLines)
        ..where((line) => line.orderId.equals(orderId))).go();
    } catch (e) {
      _logger.warning('Error deleting existing order lines (this is normal for new orders): $e');
    }
    
    // Вставляем новые строки
    for (final line in lines) {
      final lineCompanion = OrderLineMapper.toDatabase(line, orderId);
      await _database.into(_database.orderLines).insert(lineCompanion);
    }
  }

  /// Загружает строки заказа с полными данными StockItem и Product
  Future<List<OrderLine>> _getOrderLines(int orderId) async {
    // Получаем строки заказа
    final orderLineEntities = await (_database.select(_database.orderLines)
      ..where((line) => line.orderId.equals(orderId))).get();
    
    final lines = <OrderLine>[];
    
    for (final lineEntity in orderLineEntities) {
      // Загружаем реальный StockItem по stockItemId
      final stockItemEntity = await (_database.select(_database.stockItems)
        ..where((si) => si.id.equals(lineEntity.stockItemId))).getSingleOrNull();
      
      if (stockItemEntity == null) {
        _logger.warning('StockItem не найден: ${lineEntity.stockItemId}');
        continue; // Пропускаем эту строку если товар не найден
      }
      
        // Загружаем Product через ProductRepository
        Product? product;
        try {
          final productResult = await _productRepository.getProductByCode(stockItemEntity.productCode);
          
          product = productResult.fold(
            (failure) {
              _logger.severe('❌ КРИТИЧЕСКАЯ ОШИБКА: Product не найден в репозитории: ${stockItemEntity.productCode}. ${failure.message}');
              _logger.severe('❌ Это указывает на проблему целостности данных: StockItem ссылается на несуществующий Product');
              return null;
            },
            (fullProduct) {
              _logger.info('✅ Product загружен: ${fullProduct?.title}, images: ${fullProduct?.images.length}');
              return fullProduct;
            },
          );
          
          // Если Product не найден - это серьёзная проблема с данными
          if (product == null) {
            _logger.severe('❌ ДАННЫЕ НЕ КОНСИСТЕНТНЫ: StockItem.productCode=${stockItemEntity.productCode} не соответствует ни одному Product');
            _logger.severe('❌ Пропускаем эту строку заказа, так как товар не существует');
            continue; // Пропускаем строку с некорректными данными
          }
        } catch (e) {
          _logger.severe('❌ Критическая ошибка при загрузке Product ${stockItemEntity.productCode}: $e');
          _logger.severe('❌ Пропускаем строку заказа из-за ошибки загрузки товара');
          continue; // Пропускаем строку при критических ошибках
        }      // Создаем StockItem из данных БД
      final stockItem = StockItem(
        id: stockItemEntity.id,
        productCode: stockItemEntity.productCode,
        warehouseId: stockItemEntity.warehouseId,
        warehouseName: stockItemEntity.warehouseName,
        warehouseVendorId: stockItemEntity.warehouseVendorId,
        isPickUpPoint: stockItemEntity.isPickUpPoint,
        stock: stockItemEntity.stock,
        multiplicity: stockItemEntity.multiplicity,
        publicStock: stockItemEntity.publicStock,
        defaultPrice: stockItemEntity.defaultPrice,
        discountValue: stockItemEntity.discountValue,
        availablePrice: stockItemEntity.availablePrice,
        offerPrice: stockItemEntity.offerPrice,
        currency: stockItemEntity.currency,
        promotionJson: stockItemEntity.promotionJson,
        createdAt: stockItemEntity.createdAt,
        updatedAt: stockItemEntity.updatedAt,
      );
      
      final line = OrderLine(
        id: lineEntity.id,
        orderId: orderId,
        stockItem: stockItem,
        product: product, // Добавляем Product
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
    _logger.info('🔍 Querying employee by ID: $employeeId');
    try {
      final employeeEntity = await (_database.select(_database.employees)
        ..where((e) => e.id.equals(employeeId))).getSingle();
      _logger.info('✅ Employee found: ${employeeEntity.firstName} ${employeeEntity.lastName}');
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
    } catch (e) {
      _logger.severe('❌ Employee with ID $employeeId not found: $e');
      // Показать список всех employees для диагностики
      final allEmployees = await _database.select(_database.employees).get();
      _logger.info('📋 Available employees: ${allEmployees.map((e) => 'ID:${e.id} ${e.firstName} ${e.lastName}').join(', ')}');
      rethrow;
    }
  }

  /// Получает торговую точку по ID
  Future<TradingPoint> _getTradingPointById(int outletId) async {
    _logger.info('🔍 Querying trading point by ID: $outletId');
    try {
      final outletEntity = await (_database.select(_database.tradingPointEntities)
        ..where((tp) => tp.id.equals(outletId))).getSingle();
      _logger.info('✅ Trading point found: ${outletEntity.name}');
      
      // TODO: заменить на TradingPointMapper.fromDatabase когда будет доступен
      return TradingPoint(
        id: outletEntity.id,
        externalId: outletEntity.externalId,
        name: outletEntity.name,
        inn: outletEntity.inn,
      );
    } catch (e) {
      _logger.severe('❌ Trading point with ID $outletId not found: $e');
      // Показать список всех торговых точек для диагностики
      final allOutlets = await _database.select(_database.tradingPointEntities).get();
      _logger.info('📋 Available trading points: ${allOutlets.map((tp) => 'ID:${tp.id} ${tp.name}').join(', ')}');
      rethrow;
    }
  }

  @override
  Future<Order> addOrderLine(OrderLine orderLine) async {
    _logger.info('Adding order line to order ${orderLine.orderId}');
    
    final now = DateTime.now();
    final orderLineData = OrderLinesCompanion.insert(
      orderId: orderLine.orderId,
      stockItemId: orderLine.stockItem.id,
      quantity: orderLine.quantity,
      pricePerUnit: orderLine.pricePerUnit,
      createdAt: now,
      updatedAt: now,
    );
    
    await _database.into(_database.orderLines).insert(orderLineData);
    _logger.info('Order line added successfully');
    
    // Возвращаем обновленный заказ
    final orderData = await (_database.select(_database.orders)
        ..where((o) => o.id.equals(orderLine.orderId))).getSingle();
    return await _buildOrderFromEntity(orderData);
  }

  @override
  Future<Order> updateOrderLineQuantity({
    required int orderLineId,
    required int newQuantity,
  }) async {
    _logger.info('Updating order line $orderLineId quantity to $newQuantity');
    
    // Получаем строку заказа для определения orderId
    final orderLineData = await (_database.select(_database.orderLines)
        ..where((ol) => ol.id.equals(orderLineId))).getSingle();
    
    if (newQuantity <= 0) {
      // Если количество 0 или меньше - удаляем строку из корзины
      _logger.info('Removing order line $orderLineId due to zero quantity');
      await (_database.delete(_database.orderLines)..where((ol) => ol.id.equals(orderLineId))).go();
      _logger.info('Order line removed successfully');
    } else {
      // Обновляем количество и timestamp
      await (_database.update(_database.orderLines)..where((ol) => ol.id.equals(orderLineId)))
          .write(OrderLinesCompanion(
            quantity: Value(newQuantity),
            updatedAt: Value(DateTime.now()),
          ));
      _logger.info('Order line quantity updated successfully');
    }
    
    // Возвращаем обновленный заказ
    final orderData = await (_database.select(_database.orders)
        ..where((o) => o.id.equals(orderLineData.orderId))).getSingle();
    return await _buildOrderFromEntity(orderData);
  }

  @override
  Future<Order> removeOrderLine(int orderLineId) async {
    _logger.info('Removing order line $orderLineId');
    
    // Получаем строку заказа для определения orderId
    final orderLineData = await (_database.select(_database.orderLines)
        ..where((ol) => ol.id.equals(orderLineId))).getSingleOrNull();
    
    if (orderLineData == null) {
      _logger.warning('Order line $orderLineId not found');
      throw Exception('Order line $orderLineId not found');
    }
    
    // Удаляем строку
    final deletedRows = await (_database.delete(_database.orderLines)..where((ol) => ol.id.equals(orderLineId))).go();
    
    _logger.info('Order line removed successfully, deleted $deletedRows rows');
    
    // Возвращаем обновленный заказ
    final orderData = await (_database.select(_database.orders)
        ..where((o) => o.id.equals(orderLineData.orderId))).getSingleOrNull();
    
    if (orderData == null) {
      _logger.severe('Order ${orderLineData.orderId} not found after removing line');
      throw Exception('Order ${orderLineData.orderId} not found');
    }
    
    return await _buildOrderFromEntity(orderData);
  }

  @override
  Future<Order> clearCart({
    required int employeeId,
    required int outletId,
  }) async {
    _logger.info('Clearing cart for employee $employeeId, outlet $outletId');
    
    // Получаем текущий draft заказ
    final draftOrder = await getCurrentDraftOrder(employeeId, outletId);
    
    // Удаляем все строки заказа
    await (_database.delete(_database.orderLines)..where((ol) => ol.orderId.equals(draftOrder.id!))).go();
    
    _logger.info('Cart cleared successfully');
    
    // Возвращаем обновленный заказ
    final orderData = await (_database.select(_database.orders)
        ..where((o) => o.id.equals(draftOrder.id!))).getSingle();
    return await _buildOrderFromEntity(orderData);
  }
}