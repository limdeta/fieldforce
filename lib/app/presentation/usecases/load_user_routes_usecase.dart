import 'package:fieldforce/features/shop/domain/entities/route.dart' as shop;
import 'package:fieldforce/features/shop/domain/repositories/route_repository.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

/// UseCase для загрузки маршрутов пользователя
/// 
/// Инкапсулирует бизнес-логику загрузки маршрутов:
/// - Проверка авторизации пользователя
/// - Получение маршрутов из репозитория
/// - Сортировка и фильтрация маршрутов
class LoadUserRoutesUseCase {
  final RouteRepository _routeRepository;

  LoadUserRoutesUseCase(this._routeRepository);

  /// Выполняет загрузку маршрутов для текущего пользователя
  Future<Either<Failure, List<shop.Route>>> execute() async {
    try {
      final sessionResult = await AppSessionService.getCurrentAppSession();
      if (sessionResult.isLeft()) {
        return Left(GeneralFailure('Пользователь не авторизован'));
      }

      final session = sessionResult.fold((l) => null, (r) => r);
      if (session == null) {
        return Left(GeneralFailure('Сессия не найдена'));
      }

      // Загружаем маршруты через репозиторий
      // Используем stream, но получаем первое значение
      final routesStream = _routeRepository.watchEmployeeRoutes(session.appUser.employee);
      final routes = await routesStream.first;

      final sortedRoutes = _sortRoutes(routes);
      
      return Right(sortedRoutes);
    } catch (e) {
      return Left(GeneralFailure('Ошибка загрузки маршрутов: $e'));
    }
  }

  /// Получает stream маршрутов для подписки
  Stream<Either<Failure, List<shop.Route>>> watchUserRoutes() async* {
    try {
      final sessionResult = await AppSessionService.getCurrentAppSession();
      if (sessionResult.isLeft()) {
        yield Left(GeneralFailure('Пользователь не авторизован'));
        return;
      }

      final session = sessionResult.fold((l) => null, (r) => r);
      if (session == null) {
        yield Left(GeneralFailure('Сессия не найдена'));
        return;
      }

      // Возвращаем stream маршрутов
      await for (final routes in _routeRepository.watchEmployeeRoutes(session.appUser.employee)) {
        final sortedRoutes = _sortRoutes(routes);
        yield Right(sortedRoutes);
      }
    } catch (e) {
      yield Left(GeneralFailure('Ошибка загрузки маршрутов: $e'));
    }
  }

  /// Сортировка маршрутов по приоритету
  List<shop.Route> _sortRoutes(List<shop.Route> routes) {
    final sortedRoutes = List<shop.Route>.from(routes);
    
    sortedRoutes.sort((a, b) {
      // Сначала активные маршруты
      if (a.status == shop.RouteStatus.active && b.status != shop.RouteStatus.active) {
        return -1;
      }
      if (b.status == shop.RouteStatus.active && a.status != shop.RouteStatus.active) {
        return 1;
      }
      
      // Затем по дате начала (новые сверху)
      final aDate = a.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    
    return sortedRoutes;
  }
}
