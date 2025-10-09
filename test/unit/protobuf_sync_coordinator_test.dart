import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/shop/data/sync/services/protobuf_sync_coordinator.dart';
import 'package:fieldforce/features/shop/data/sync/repositories/protobuf_sync_repository.dart';
import 'package:fieldforce/features/shop/data/sync/services/regional_sync_service.dart';
import 'package:fieldforce/features/shop/data/sync/services/stock_sync_service.dart';
import 'package:fieldforce/features/shop/data/sync/services/outlet_pricing_sync_service.dart';
import 'package:fieldforce/features/shop/domain/repositories/product_repository.dart';
import 'package:fieldforce/features/shop/domain/repositories/stock_item_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'protobuf_sync_coordinator_test.mocks.dart';

@GenerateMocks([
  ProtobufSyncRepository,
  RegionalSyncService,
  StockSyncService,
  OutletPricingSyncService,
  ProductRepository,
  StockItemRepository,
])
void main() {
  group('ProtobufSyncCoordinator', () {
    late ProtobufSyncCoordinator coordinator;
    late MockProtobufSyncRepository mockSyncRepository;
    late MockRegionalSyncService mockRegionalService;
    late MockStockSyncService mockStockService;
    late MockOutletPricingSyncService mockOutletService;
    late MockProductRepository mockProductRepository;
    late MockStockItemRepository mockStockItemRepository;

    setUp(() {
      mockSyncRepository = MockProtobufSyncRepository();
      mockRegionalService = MockRegionalSyncService();
      mockStockService = MockStockSyncService();
      mockOutletService = MockOutletPricingSyncService();
      mockProductRepository = MockProductRepository();
      mockStockItemRepository = MockStockItemRepository();

      coordinator = ProtobufSyncCoordinator(
        syncRepository: mockSyncRepository,
        regionalSyncService: mockRegionalService,
        stockSyncService: mockStockService,
        outletPricingSyncService: mockOutletService,
        productRepository: mockProductRepository,
        stockItemRepository: mockStockItemRepository,
      );
    });

    test('ProtobufSyncCoordinator создается успешно с DI', () {
      expect(coordinator, isNotNull);
    });

    test('setSupportingDataSession устанавливает cookie для всех сервисов', () {
      // Arrange
      const testCookie = 'test-session-cookie';

      // Act
      coordinator.setSupportingDataSession(testCookie);

      // Assert
      verify(mockRegionalService.setSessionCookie(testCookie)).called(1);
      verify(mockStockService.setSessionCookie(testCookie)).called(1);
      verify(mockOutletService.setSessionCookie(testCookie)).called(1);
    });

    test('clearSession очищает сессию для всех сервисов', () {
      // Act
      coordinator.clearSession();

      // Assert
      verify(mockRegionalService.clearSession()).called(1);
      verify(mockStockService.clearSession()).called(1);
      verify(mockOutletService.clearSession()).called(1);
    });
  });
}