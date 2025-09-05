import 'package:fieldforce/app/domain/entities/work_day.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/app/domain/usecases/get_work_days_for_user_usecase.dart';

extension ListExtensions<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

/// Provider для управления рабочими днями
/// Объединяет маршруты и треки в логические единицы WorkDay
class WorkDayProvider extends ChangeNotifier {
  final LocationTrackingServiceBase _trackingService = GetIt.instance<LocationTrackingServiceBase>();
  final GetWorkDaysForUserUseCase _getWorkDaysForUser = GetIt.instance<GetWorkDaysForUserUseCase>();

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

  /// Начинаем рабочий день (запускаем трекинг)
  Future<bool> startWorkDay(WorkDay workDay) async {
    if (!workDay.canStart) return false;

    // Запускаем GPS трекинг
    final success = await _trackingService.startTracking(workDay.user);
    if (!success) return false;

    // Обновляем статус
    final updatedWorkDay = workDay.copyWith(
      status: WorkDayStatus.active,
      startTime: DateTime.now(), user: workDay.user,
    );

    _updateWorkDay(updatedWorkDay);
    
    // Подписываемся на активный трек
    _trackingService.trackUpdateStream.listen((track) {
      _activeTrack = track;
      
      // Обновляем actualTrack в текущем WorkDay
      if (_selectedWorkDay?.isToday == true) {
        final updated = _selectedWorkDay!.copyWith(track: track, user: workDay.user);
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
      track: _activeTrack, user: workDay.user,
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
    final session = AppSessionService.currentSession;
    if (session == null) {
      print('❌ WorkDayProvider: Нет активной сессии');
      _workDays = [];
      notifyListeners();
      return;
    }
    final user = session.appUser;
    print('📊 WorkDayProvider: Загружаем WorkDay для пользователя ${user.fullName}');
    try {
      final workDays = await _getWorkDaysForUser(user);
      _workDays = workDays;
      print('✅ WorkDayProvider: Загружено ${_workDays.length} рабочих дней');
    } catch (e) {
      print('❌ WorkDayProvider: Ошибка загрузки рабочих дней: $e');
      _workDays = [];
    }
    notifyListeners();
  }
}
