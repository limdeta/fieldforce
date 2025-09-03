import 'package:fieldforce/app/domain/work_day.dart';
import 'package:fieldforce/app/domain/app_user.dart';
import 'package:fieldforce/features/shop/domain/entities/route.dart' as shop;
import 'package:fieldforce/features/navigation/tracking/data/fixtures/track_fixtures.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/shop/domain/repositories/route_repository.dart';
import 'package:get_it/get_it.dart';

/// Сервис для создания фикстур WorkDay
/// 
/// Создает логические единицы "рабочий день" которые объединяют:
/// - Пользователя
/// - Дату
/// - Запланированный маршрут 
/// - Фактический трек (если есть)
class WorkDayFixtureService {
  final RouteRepository _routeRepository;
  
  WorkDayFixtureService(this._routeRepository);

  /// Создает WorkDay фикстуры для торгового представителя
  /// 
  /// Создает:
  /// - Вчерашний WorkDay: есть маршрут и завершенный трек
  /// - Сегодняшний WorkDay: есть маршрут, частично пройденный трек + активный трекинг
  /// - Завтрашний WorkDay: только маршрут, без трека
  Future<List<WorkDay>> createWorkDaysForSalesRep(AppUser salesRepAppUser) async {
    print('🔧 Создаем WorkDay фикстуры для ${salesRepAppUser.fullName}');
    
    final workDays = <WorkDay>[];
    final now = DateTime.now();
    
    // Получаем все маршруты пользователя (одноразово, без stream)
    final routes = await _routeRepository.getEmployeeRoutes(salesRepAppUser.employee);
    
    if (routes.isEmpty) {
      print('⚠️ У пользователя ${salesRepAppUser.fullName} нет маршрутов для WorkDay');
      return workDays;
    }

    // 1. ВЧЕРАШНИЙ WorkDay - есть маршрут и завершенный трек
    final yesterdayDate = DateTime(now.year, now.month, now.day - 1);
    final yesterdayRoute = routes.firstWhere(
      (route) => route.name.contains('2 сентября'), 
      orElse: () => routes.first,
    );
    
    print('🎯 Создаем вчерашний WorkDay для маршрута "${yesterdayRoute.name}"');
    
    // Создаем завершенный трек для вчерашнего дня
    final yesterdayTrack = await TrackFixtures.createCurrentDayTrack(
      user: salesRepAppUser.employee,
      route: yesterdayRoute,
    );
    
    final yesterdayWorkDay = WorkDay(
      id: DateTime.now().millisecondsSinceEpoch - 1000, // Уникальный ID
      userId: salesRepAppUser.employee.id,
      date: yesterdayDate,
      plannedRoute: yesterdayRoute,
      actualTrack: yesterdayTrack,
      status: WorkDayStatus.completed,
      startTime: DateTime(yesterdayDate.year, yesterdayDate.month, yesterdayDate.day, 9, 0),
      endTime: DateTime(yesterdayDate.year, yesterdayDate.month, yesterdayDate.day, 18, 0),
    );
    
    workDays.add(yesterdayWorkDay);
    print('✅ Вчерашний WorkDay создан: ${yesterdayTrack?.totalPoints ?? 0} точек');

    // 2. СЕГОДНЯШНИЙ WorkDay - есть маршрут, частично пройденный трек
    final todayDate = DateTime(now.year, now.month, now.day);
    final todayRoute = routes.firstWhere(
      (route) => route.name.contains('3 сентября') || route.name.contains('Текущий'),
      orElse: () => routes.last,
    );
    
    print('🎯 Создаем сегодняшний WorkDay для маршрута "${todayRoute.name}"');
    
    // Сегодняшний трек создастся через активный GPS трекинг
    // Здесь мы создаем только WorkDay структуру
    final todayWorkDay = WorkDay(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: salesRepAppUser.employee.id,
      date: todayDate,
      plannedRoute: todayRoute,
      actualTrack: null, // Будет заполнен через активный трекинг
      status: WorkDayStatus.active,
      startTime: DateTime(todayDate.year, todayDate.month, todayDate.day, 9, 0),
    );
    
    workDays.add(todayWorkDay);
    print('✅ Сегодняшний WorkDay создан для активного трекинга');

    // 3. ЗАВТРАШНИЙ WorkDay - только маршрут, без трека
    final tomorrowDate = DateTime(now.year, now.month, now.day + 1);
    final tomorrowRoute = routes.firstWhere(
      (route) => route.name.contains('4 сентября'),
      orElse: () => routes.first,
    );
    
    print('🎯 Создаем завтрашний WorkDay для маршрута "${tomorrowRoute.name}"');
    
    final tomorrowWorkDay = WorkDay(
      id: DateTime.now().millisecondsSinceEpoch + 1000,
      userId: salesRepAppUser.employee.id,
      date: tomorrowDate,
      plannedRoute: tomorrowRoute,
      actualTrack: null, // Нет трека - день еще не начался
      status: WorkDayStatus.planned,
    );
    
    workDays.add(tomorrowWorkDay);
    print('✅ Завтрашний WorkDay создан (только план)');

    print('✅ WorkDay фикстуры созданы: ${workDays.length} дней');
    return workDays;
  }

  /// Создает WorkDay для конкретного дня и маршрута
  Future<WorkDay> createWorkDayForDate({
    required AppUser salesRepAppUser,
    required DateTime date,
    required shop.Route plannedRoute,
    UserTrack? actualTrack,
    WorkDayStatus status = WorkDayStatus.planned,
  }) async {
    return WorkDay(
      id: DateTime.now().millisecondsSinceEpoch,
      userId: salesRepAppUser.employee.id,
      date: date,
      plannedRoute: plannedRoute,
      actualTrack: actualTrack,
      status: status,
    );
  }
}

/// Factory для создания WorkDayFixtureService
class WorkDayFixtureServiceFactory {
  static WorkDayFixtureService create() {
    final routeRepository = GetIt.instance<RouteRepository>();
    return WorkDayFixtureService(routeRepository);
  }
}
