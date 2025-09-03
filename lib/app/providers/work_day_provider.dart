import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../domain/work_day.dart';
import '../services/location_tracking_service.dart';
import '../services/app_session_service.dart';
import '../../features/shop/domain/entities/route.dart' as shop;
import '../../features/navigation/tracking/domain/entities/user_track.dart';

extension ListExtensions<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Provider для управления рабочими днями
/// Объединяет маршруты и треки в логические единицы WorkDay
class WorkDayProvider extends ChangeNotifier {
  final LocationTrackingService _trackingService = GetIt.instance<LocationTrackingService>();
  
  List<WorkDay> _workDays = [];
  WorkDay? _selectedWorkDay;
  UserTrack? _activeTrack;
  bool _initialized = false;

  List<WorkDay> get workDays => _workDays;
  WorkDay? get selectedWorkDay => _selectedWorkDay;
  UserTrack? get activeTrack => _activeTrack;

  WorkDayProvider() {
    _initialize();
  }

  /// Инициализация провайдера - подписка на треки
  void _initialize() {
    if (_initialized) return;
    _initialized = true;
    
    // Подписываемся на обновления активного трека
    _trackingService.trackUpdateStream.listen((track) {
      print('🔄 WorkDayProvider: Получен активный трек: ${track.id} (${track.totalPoints} точек)');
      _activeTrack = track;
      notifyListeners();
    });
    
    print('✅ WorkDayProvider инициализирован');
  }

  /// Получаем WorkDay для конкретной даты
  WorkDay? getWorkDayForDate(DateTime date) {
    return _workDays.where((wd) => 
      wd.date.year == date.year && 
      wd.date.month == date.month && 
      wd.date.day == date.day
    ).firstOrNull;
  }

  /// Получаем сегодняшний WorkDay
  WorkDay? get todayWorkDay => getWorkDayForDate(DateTime.now());

  /// Выбираем рабочий день для отображения
  void selectWorkDay(WorkDay workDay) {
    _selectedWorkDay = workDay;
    notifyListeners();
  }

  /// Выбираем рабочий день по дате
  void selectWorkDayByDate(DateTime date) {
    final workDay = getWorkDayForDate(date);
    if (workDay != null) {
      selectWorkDay(workDay);
    }
  }

  /// Создаем новый рабочий день
  Future<WorkDay> createWorkDay({
    required DateTime date,
    shop.Route? plannedRoute,
  }) async {
    final session = AppSessionService.currentSession;
    if (session == null) throw Exception('Нет активной сессии');

    final workDay = WorkDay(
      id: DateTime.now().millisecondsSinceEpoch, // Временный ID
      userId: session.appUser.employee.id,
      date: date,
      plannedRoute: plannedRoute,
      actualTrack: null,
      status: WorkDayStatus.planned,
    );

    _workDays.add(workDay);
    notifyListeners();
    return workDay;
  }

  /// Начинаем рабочий день (запускаем трекинг)
  Future<bool> startWorkDay(WorkDay workDay) async {
    if (!workDay.canStart) return false;

    // Запускаем GPS трекинг
    final success = await _trackingService.startTracking();
    if (!success) return false;

    // Обновляем статус
    final updatedWorkDay = workDay.copyWith(
      status: WorkDayStatus.active,
      startTime: DateTime.now(),
    );

    _updateWorkDay(updatedWorkDay);
    
    // Подписываемся на активный трек
    _trackingService.trackUpdateStream.listen((track) {
      _activeTrack = track;
      
      // Обновляем actualTrack в текущем WorkDay
      if (_selectedWorkDay?.isToday == true) {
        final updated = _selectedWorkDay!.copyWith(actualTrack: track);
        _updateWorkDay(updated);
      }
    });

    return true;
  }

  /// Завершаем рабочий день
  Future<void> finishWorkDay(WorkDay workDay) async {
    await _trackingService.stopTracking();
    
    final updatedWorkDay = workDay.copyWith(
      status: WorkDayStatus.completed,
      endTime: DateTime.now(),
      actualTrack: _activeTrack,
    );
    
    _updateWorkDay(updatedWorkDay);
    _activeTrack = null;
  }

  /// Приостанавливаем трекинг
  Future<void> pauseTracking() async {
    _trackingService.pauseTracking();
  }

  /// Возобновляем трекинг
  Future<void> resumeTracking() async {
    _trackingService.resumeTracking();
  }

  void _updateWorkDay(WorkDay updatedWorkDay) {
    final index = _workDays.indexWhere((wd) => wd.id == updatedWorkDay.id);
    if (index != -1) {
      _workDays[index] = updatedWorkDay;
      
      // Обновляем выбранный день, если это он
      if (_selectedWorkDay?.id == updatedWorkDay.id) {
        _selectedWorkDay = updatedWorkDay;
      }
      
      notifyListeners();
    }
  }

  /// Загружаем рабочие дни из базы данных
  Future<void> loadWorkDays() async {
    print('📅 WorkDayProvider: Загружаем рабочие дни...');
    // TODO: Загрузка из repository
    // Пока создаем моковые данные
    _createMockWorkDays();
    print('✅ WorkDayProvider: Загружено ${_workDays.length} рабочих дней');
    notifyListeners();
  }

  void _createMockWorkDays() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    _workDays = [
      // Вчера - завершен
      WorkDay(
        id: 1,
        userId: 279,
        date: yesterday,
        plannedRoute: null, // Был без плана
        actualTrack: null, // Трека не было
        status: WorkDayStatus.completed,
      ),
      // Сегодня - активный
      WorkDay(
        id: 2,
        userId: 279,
        date: today,
        plannedRoute: null, // Будет заполнен из fixtures
        actualTrack: null, // Будет обновлен из активного трека
        status: WorkDayStatus.active,
        startTime: today.subtract(const Duration(hours: 2)),
      ),
      // Завтра - запланирован
      WorkDay(
        id: 3,
        userId: 279,
        date: tomorrow,
        plannedRoute: null, // Будет заполнен из fixtures
        actualTrack: null,
        status: WorkDayStatus.planned,
      ),
    ];
  }
}
