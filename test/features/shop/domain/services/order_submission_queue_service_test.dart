import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:fieldforce/app/database/app_database.dart';
import 'package:fieldforce/app/jobs/job_record.dart';
import 'package:fieldforce/app/jobs/job_status.dart';
import 'package:fieldforce/features/shop/data/repositories/order_job_repository_impl.dart';
import 'package:fieldforce/features/shop/data/repositories/order_repository_drift.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/order.dart';
import 'package:fieldforce/features/shop/domain/entities/order_line.dart';
import 'package:fieldforce/features/shop/domain/entities/order_state.dart';
import 'package:fieldforce/features/shop/domain/entities/payment_kind.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/jobs/order_submission_job.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/features/shop/domain/services/order_api_service.dart';
import 'package:fieldforce/features/shop/domain/services/order_submission_queue_service.dart';
import 'package:fieldforce/features/shop/domain/services/order_submission_service.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('OrderSubmissionQueueService (sqlite-backed)', () {
    const MethodChannel connectivityChannel = MethodChannel('dev.fluttercommunity.plus/connectivity');
    late Directory tempDir;
    late AppDatabase database;
    late TestProductRepository productRepository;
    late OrderRepositoryDrift orderRepository;
    late OrderJobRepositoryImpl jobRepository;
    late TestOrderApiService apiService;
    late OrderSubmissionService submissionService;
    late OrderSubmissionQueueService queueService;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      connectivityChannel.setMockMethodCallHandler((methodCall) async {
        if (methodCall.method == 'check') {
          return <String>[ConnectivityResult.wifi.name];
        }
        return null;
      });

      tempDir = await Directory.systemTemp.createTemp('order_queue_test');
      final dbFile = File(p.join(tempDir.path, 'orders_test.db'));
  final connection = DatabaseConnection(NativeDatabase(dbFile));
      database = AppDatabase.forTesting(connection);

      productRepository = TestProductRepository();
      orderRepository = OrderRepositoryDrift(database, productRepository);
      jobRepository = OrderJobRepositoryImpl(database);
      apiService = TestOrderApiService();
      submissionService = OrderSubmissionService(apiService: apiService);
      queueService = OrderSubmissionQueueService(
        repository: jobRepository,
        orderRepository: orderRepository,
        submissionService: submissionService,
        retryDelayBuilder: (_) => const Duration(seconds: 1),
      );
    });

    tearDown(() async {
      await database.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
      connectivityChannel.setMockMethodCallHandler(null);
    });

    test('keeps order pending and schedules retry when API returns failure', () async {
      final seed = await _preparePendingOrder(
        database: database,
        productRepository: productRepository,
        orderRepository: orderRepository,
      );

      final job = OrderSubmissionJob.create(
        id: 'order-${seed.order.id}-job',
        orderId: seed.order.id!,
        payload: seed.order.toApiPayload(),
        createdAt: DateTime.now(),
      );

      final record = JobRecord<OrderSubmissionJob>(
        job: job,
        status: JobStatus.queued,
        attempts: 0,
        createdAt: job.createdAt,
        updatedAt: job.createdAt,
      );
      await jobRepository.save(record);

      apiService.enqueueResponses([
        const Left(GeneralFailure('Серверная ошибка при обработке заказа')),
      ]);

      await queueService.triggerProcessing();

      final updatedOrder = await orderRepository.getOrderById(seed.order.id!);
      expect(updatedOrder, isNotNull);
      expect(updatedOrder!.state, OrderState.pending);
      expect(updatedOrder.failureReason, isNull);

      final storedJob = await jobRepository.findById(job.id);
      expect(storedJob, isNotNull);
      expect(storedJob!.status, JobStatus.retryScheduled);
      expect(storedJob.attempts, 1);
      expect(storedJob.failureReason, 'Серверная ошибка при обработке заказа');
      expect(storedJob.nextRunAt, isNotNull);

      expect(apiService.sentPayloads.length, 1);
      expect(apiService.sentPayloads.single['id'], seed.order.id);
    });

    test('transitions order to error after reaching max attempts', () async {
      final seed = await _preparePendingOrder(
        database: database,
        productRepository: productRepository,
        orderRepository: orderRepository,
      );

      final job = OrderSubmissionJob.create(
        id: 'order-${seed.order.id}-max-attempts-job',
        orderId: seed.order.id!,
        payload: seed.order.toApiPayload(),
        createdAt: DateTime.now(),
      );

      final record = JobRecord<OrderSubmissionJob>(
        job: job,
        status: JobStatus.queued,
        attempts: 0,
        createdAt: job.createdAt,
        updatedAt: job.createdAt,
      );
      await jobRepository.save(record);

      queueService = OrderSubmissionQueueService(
        repository: jobRepository,
        orderRepository: orderRepository,
        submissionService: submissionService,
        retryDelayBuilder: (_) => Duration.zero,
        maxAttempts: 3,
      );

      const failureMessage = 'API responded with validation error';
      apiService.enqueueResponses([
        const Left(GeneralFailure(failureMessage)),
        const Left(GeneralFailure(failureMessage)),
        const Left(GeneralFailure(failureMessage)),
      ]);

      for (var i = 0; i < 3; i++) {
        await queueService.triggerProcessing();
      }

      final updatedOrder = await orderRepository.getOrderById(seed.order.id!);
      expect(updatedOrder, isNotNull);
      expect(updatedOrder!.state, OrderState.error);
      expect(updatedOrder.failureReason, failureMessage);

      final storedJob = await jobRepository.findById(job.id);
      expect(storedJob, isNotNull);
      expect(storedJob!.status, JobStatus.failed);
      expect(storedJob.attempts, 3);
      expect(storedJob.failureReason, failureMessage);

      expect(apiService.sentPayloads.length, 3);
      expect(apiService.sentPayloads.every((payload) => payload['id'] == seed.order.id), isTrue);
    });

    test('offline order is submitted successfully when API responds with success payload', () async {
      final seed = await _preparePendingOrder(
        database: database,
        productRepository: productRepository,
        orderRepository: orderRepository,
      );

      final job = OrderSubmissionJob.create(
        id: 'order-${seed.order.id}-success-job',
        orderId: seed.order.id!,
        payload: seed.order.toApiPayload(),
        createdAt: DateTime.now(),
      );

      final record = JobRecord<OrderSubmissionJob>(
        job: job,
        status: JobStatus.queued,
        attempts: 0,
        createdAt: job.createdAt,
        updatedAt: job.createdAt,
      );
      await jobRepository.save(record);

      const successPayload = {
        'data': {'orderId': 50432},
        'errors': [],
      };

      apiService.enqueueResponses([
        const Right(successPayload),
      ]);

      await queueService.triggerProcessing();

      final updatedOrder = await orderRepository.getOrderById(seed.order.id!);
      expect(updatedOrder, isNotNull);
      expect(updatedOrder!.state, OrderState.confirmed);
      expect(updatedOrder.failureReason, isNull);

      final storedJob = await jobRepository.findById(job.id);
      expect(storedJob, isNull);

      expect(apiService.sentPayloads.length, 1);
      expect(apiService.sentPayloads.single['id'], seed.order.id);
      expect(apiService.successfulResponses.single, successPayload);
    });
  });
}

class _SeedResult {
  final Order order;

  _SeedResult({required this.order});
}

Future<_SeedResult> _preparePendingOrder({
  required AppDatabase database,
  required TestProductRepository productRepository,
  required OrderRepositoryDrift orderRepository,
}) async {
  final now = DateTime.now();

  final employeeId = await database.into(database.employees).insert(
        EmployeesCompanion.insert(
          lastName: 'Иванов',
          firstName: 'Иван',
          role: 'sales',
        ),
      );

  final tradingPointId = await database.into(database.tradingPointEntities).insert(
        TradingPointEntitiesCompanion.insert(
          externalId: 'TP-$employeeId',
          name: 'Тестовая точка',
        ),
      );

  const productCode = 100500;
  final productJson = jsonEncode({
    'code': productCode,
    'title': 'Тестовый товар',
  });

  await database.into(database.products).insert(
        ProductsCompanion.insert(
          catalogId: 1000,
          code: productCode,
          bcode: 1000,
          title: 'Тестовый товар',
          description: const Value('Описание'),
          vendorCode: const Value('ART-001'),
          amountInPackage: const Value(1),
          novelty: false,
          popular: false,
          isMarked: false,
          canBuy: true,
          categoryId: const Value(null),
          typeId: const Value(null),
          priceListCategoryId: const Value(null),
          defaultImageJson: const Value(null),
          imagesJson: const Value(null),
          barcodesJson: Value(jsonEncode(['123456789'])),
          howToUse: const Value(null),
          ingredients: const Value(null),
          rawJson: productJson,
        ),
      );

  final product = Product(
    title: 'Тестовый товар',
    barcodes: const ['123456789'],
    code: productCode,
    bcode: 1000,
    catalogId: 1000,
    novelty: false,
    popular: false,
    isMarked: false,
    brand: null,
    manufacturer: null,
    colorImage: null,
    defaultImage: null,
    images: const [],
    description: 'Описание',
    howToUse: null,
    ingredients: null,
    series: null,
    category: null,
    priceListCategoryId: null,
    amountInPackage: 1,
    vendorCode: 'ART-001',
    type: null,
    categoriesInstock: const [],
    numericCharacteristics: const [],
    stringCharacteristics: const [],
    boolCharacteristics: const [],
    canBuy: true,
  );
  productRepository.register(product);

  final stockItemId = await database.into(database.stockItems).insert(
        StockItemsCompanion.insert(
          productCode: productCode,
          warehouseId: 77,
          warehouseName: 'Главный склад',
          warehouseVendorId: 'MAIN',
          isPickUpPoint: const Value(true),
          stock: const Value(50),
          multiplicity: const Value(1),
          publicStock: '50',
          defaultPrice: 15000,
          discountValue: const Value(0),
          availablePrice: const Value(15000),
          offerPrice: const Value(null),
          currency: const Value('RUB'),
          promotionJson: const Value(null),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

  final employee = Employee(
    id: employeeId,
    lastName: 'Иванов',
    firstName: 'Иван',
    role: EmployeeRole.sales,
  );

  final outlet = TradingPoint(
    id: tradingPointId,
    externalId: 'TP-$employeeId',
    name: 'Тестовая точка',
    region: 'P3V',
  );

  final stockItem = StockItem(
    id: stockItemId,
    productCode: productCode,
    warehouseId: 77,
    warehouseName: 'Главный склад',
    warehouseVendorId: 'MAIN',
    isPickUpPoint: true,
    stock: 50,
    multiplicity: 1,
    publicStock: '50',
    defaultPrice: 15000,
    discountValue: 0,
    availablePrice: 15000,
    offerPrice: null,
    currency: 'RUB',
    promotionJson: null,
    createdAt: now,
    updatedAt: now,
  );

  final line = OrderLine.create(
    orderId: 0,
    stockItem: stockItem,
    product: product,
    quantity: 2,
  );

  final pendingOrder = Order.createDraft(
    creator: employee,
    outlet: outlet,
  )
      .addProduct(productId: product.code, orderLine: line)
      .updatePaymentKind(const PaymentKind.cash())
      .submit();

  final savedOrder = await orderRepository.saveOrder(pendingOrder);

  return _SeedResult(order: savedOrder);
}

class TestOrderApiService implements OrderApiService {
  final Queue<Either<Failure, Map<String, dynamic>>> _responses =
      Queue<Either<Failure, Map<String, dynamic>>>();
  final List<Map<String, dynamic>> sentPayloads = [];
  final List<Map<String, dynamic>> successfulResponses = [];

  void enqueueResponses(Iterable<Either<Failure, Map<String, dynamic>>> responses) {
    _responses.addAll(responses);
  }

  @override
  Future<Either<Failure, void>> submitOrder(Map<String, dynamic> orderJson) async {
    sentPayloads.add(orderJson);
    if (_responses.isEmpty) {
      return const Right(null);
    }

    final response = _responses.removeFirst();
    return response.fold(
      Left.new,
      (payload) {
        successfulResponses.add(payload);
        return const Right(null);
      },
    );
  }
}

class TestProductRepository implements ProductRepository {
  final Map<int, Product> _productsByCode = {};

  void register(Product product) {
    _productsByCode[product.code] = product;
  }

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Product?>> getProductById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Product?>> getProductByCatalogId(int catalogId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Product?>> getProductByCode(int code) async {
    final product = _productsByCode[code];
    if (product == null) {
      return const Left(NotFoundFailure('Product not registered in TestProductRepository'));
    }
    return Right(product);
  }

  @override
  Future<Either<Failure, ProductWithStock?>> getProductWithStockByCode(int code, String vendorId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategoryPaginated(int categoryId, {int offset = 0, int limit = 20}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<ProductWithStock>>> getProductsWithStockByCategoryPaginated(int categoryId, {String? vendorId, int offset = 0, int limit = 20}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByTypePaginated(int typeId, {int offset = 0, int limit = 20}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Product>>> searchProductsPaginated(String query, {int offset = 0, int limit = 20}) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> saveProducts(List<Product> products) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int catalogId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> deleteAllProducts() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsWithPromotions() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Product>>> getPopularProducts() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Product>>> getNoveltyProducts() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, int>> getProductsCount() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, int>> getProductsCountByCategory(int categoryId) {
    throw UnimplementedError();
  }
}
