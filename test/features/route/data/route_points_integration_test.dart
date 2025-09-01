import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:fieldforce/app/test_service_locator.dart';
import 'package:fieldforce/features/shop/data/di/route_di.dart';
import 'package:fieldforce/features/shop/domain/entities/route.dart';
import 'package:fieldforce/features/shop/domain/entities/regular_point_of_interest.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point_of_interest.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/entities/point_of_interest.dart';
void main() {
  group('Route Points Integration Tests', () {

    test('должен создать маршрут с точками и корректно загрузить его из БД', () async {

        final route = Route(
          name: 'Тестовый маршрут',
          description: 'Маршрут для проверки сохранения точек',
          createdAt: DateTime.now(),
          startTime: DateTime.now(),
          status: RouteStatus.planned,
          pointsOfInterest: [
            RegularPointOfInterest(
              name: 'Склад',
              description: 'Точка загрузки товара',
              coordinates: const LatLng(43.1158, 131.8858),
              type: PointType.warehouse,
              plannedArrivalTime: DateTime.now(),
              plannedDepartureTime: DateTime.now().add(const Duration(minutes: 30)),
              status: VisitStatus.planned,
              order: 1,
            ),
            TradingPointOfInterest(
              name: 'Визит к клиенту',
              tradingPoint: TradingPoint(
                externalId: 'CLIENT_TEST_001',
                name: 'ООО "Тестовый клиент"',
                inn: '1234567890',
              ),
              coordinates: const LatLng(43.1356, 131.9113),
              plannedArrivalTime: DateTime.now().add(const Duration(hours: 1)),
              plannedDepartureTime: DateTime.now().add(const Duration(hours: 2)),
              status: VisitStatus.planned,
              order: 2,
            ),
            RegularPointOfInterest(
              name: 'Обеденный перерыв',
              description: 'Кафе в центре города',
              coordinates: const LatLng(43.1200, 131.9000),
              type: PointType.break_,
              plannedArrivalTime: DateTime.now().add(const Duration(hours: 3)),
              plannedDepartureTime: DateTime.now().add(const Duration(hours: 4)),
              status: VisitStatus.planned,
              order: 3,
            ),
          ],
        );

        // 2. Сохраняем маршрут через репозиторий
        final createResult = await GetIt.instance.routeRepository.saveRoute(route, null);

        expect(createResult.isRight(), true, reason: 'Маршрут должен быть создан успешно');

        final createdRoute = createResult.fold((l) => throw Exception(l), (r) => r);

        // 3. Проверяем что маршрут сохранился с правильным количеством точек
        expect(createdRoute.pointsOfInterest.length, equals(3), 
               reason: 'Созданный маршрут должен содержать 3 точки');

        // 4. Загружаем маршрут по ID из БД
        final loadResult = await GetIt.instance.routeRepository.getRouteById(createdRoute.id!);

        expect(loadResult.isRight(), true, reason: 'Маршрут должен быть найден по ID');

        final loadedRoute = loadResult.fold((l) => throw Exception(l), (r) => r);

        // 5. Проверяем что загруженный маршрут содержит все точки
        expect(loadedRoute.pointsOfInterest.length, equals(3), 
               reason: 'Загруженный маршрут должен содержать 3 точки');

      });
    });
}
