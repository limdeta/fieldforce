import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fieldforce/app/domain/entities/work_day.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as domain;
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/app/services/app_session_service.dart';

/// Режимы работы экрана
enum WorkingDayMode {
  /// Активный режим - текущий рабочий день с живым трекингом
  active,
  /// Просмотровый режим - исторические или будущие данные
  viewing,
  /// Режим выбора - выбор рабочего дня для перехода в активный режим
  selection,
}

// EVENTS
abstract class WorkingDayModeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Переключиться в активный режим (текущий рабочий день)
class SwitchToActiveModeEvent extends WorkingDayModeEvent {}

/// Переключиться в просмотровый режим для конкретного дня
class SwitchToViewingModeEvent extends WorkingDayModeEvent {
  final WorkDay workDay;
  SwitchToViewingModeEvent(this.workDay);
  @override
  List<Object?> get props => [workDay];
}

/// Начать новый рабочий день (станет активным)
class StartNewWorkingDayEvent extends WorkingDayModeEvent {
  final domain.Route route;
  StartNewWorkingDayEvent(this.route);
  @override
  List<Object?> get props => [route];
}

/// Завершить текущий рабочий день
class FinishActiveWorkingDayEvent extends WorkingDayModeEvent {}

/// Переключиться в режим выбора дня
class SwitchToSelectionModeEvent extends WorkingDayModeEvent {}

// STATES
abstract class WorkingDayModeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class WorkingDayModeInitial extends WorkingDayModeState {}

/// Активный режим - текущий рабочий день
class ActiveWorkingDayState extends WorkingDayModeState {
  final WorkDay currentWorkDay;
  final UserTrack? activeTrack;
  final bool isTrackingActive;
  final DateTime lastUpdate;

  ActiveWorkingDayState({
    required this.currentWorkDay,
    this.activeTrack,
    required this.isTrackingActive,
    required this.lastUpdate,
  });

  @override
  List<Object?> get props => [currentWorkDay, activeTrack, isTrackingActive, lastUpdate];

  ActiveWorkingDayState copyWith({
    WorkDay? currentWorkDay,
    UserTrack? activeTrack,
    bool? isTrackingActive,
    DateTime? lastUpdate,
  }) {
    return ActiveWorkingDayState(
      currentWorkDay: currentWorkDay ?? this.currentWorkDay,
      activeTrack: activeTrack ?? this.activeTrack,
      isTrackingActive: isTrackingActive ?? this.isTrackingActive,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

/// Просмотровый режим - исторические данные
class ViewingWorkingDayState extends WorkingDayModeState {
  final WorkDay viewingWorkDay;
  final UserTrack? historicalTrack;
  final bool canSwitchToActive;

  ViewingWorkingDayState({
    required this.viewingWorkDay,
    this.historicalTrack,
    required this.canSwitchToActive,
  });

  @override
  List<Object?> get props => [viewingWorkDay, historicalTrack, canSwitchToActive];
}

/// Режим выбора рабочего дня
class SelectionModeState extends WorkingDayModeState {
  final List<WorkDay> availableWorkDays;
  final WorkDay? suggestedWorkDay;

  SelectionModeState({
    required this.availableWorkDays,
    this.suggestedWorkDay,
  });

  @override
  List<Object?> get props => [availableWorkDays, suggestedWorkDay];
}

class WorkingDayModeError extends WorkingDayModeState {
  final String error;
  WorkingDayModeError(this.error);
  @override
  List<Object?> get props => [error];
}

// BLOC
class WorkingDayModeBloc extends Bloc<WorkingDayModeEvent, WorkingDayModeState> {
  WorkingDayMode _currentMode = WorkingDayMode.selection;
  WorkDay? _activeWorkDay;
  WorkDay? _viewingWorkDay;

  WorkingDayModeBloc() : super(WorkingDayModeInitial()) {
    on<SwitchToActiveModeEvent>(_onSwitchToActiveMode);
    on<SwitchToViewingModeEvent>(_onSwitchToViewingMode);
    on<StartNewWorkingDayEvent>(_onStartNewWorkingDay);
    on<FinishActiveWorkingDayEvent>(_onFinishActiveWorkingDay);
    on<SwitchToSelectionModeEvent>(_onSwitchToSelectionMode);
  }

  Future<void> _onSwitchToActiveMode(SwitchToActiveModeEvent event, Emitter<WorkingDayModeState> emit) async {
    print('[WorkingDayModeBloc] Switching to ACTIVE mode');
    _currentMode = WorkingDayMode.active;

    if (_activeWorkDay != null) {
      emit(ActiveWorkingDayState(
        currentWorkDay: _activeWorkDay!,
        isTrackingActive: true,
        lastUpdate: DateTime.now(),
      ));
    } else {
      // Нет активного рабочего дня - переходим в режим выбора
      add(SwitchToSelectionModeEvent());
    }
  }

  void _onSwitchToViewingMode(SwitchToViewingModeEvent event, Emitter<WorkingDayModeState> emit) {
    print('[WorkingDayModeBloc] Switching to VIEWING mode for WorkDay: ${event.workDay.id}');
    _currentMode = WorkingDayMode.viewing;
    _viewingWorkDay = event.workDay;

    final isToday = _isSameDay(event.workDay.date, DateTime.now());
    final canSwitchToActive = isToday && _activeWorkDay?.id != event.workDay.id;

    emit(ViewingWorkingDayState(
      viewingWorkDay: event.workDay,
      canSwitchToActive: canSwitchToActive,
    ));
  }

  Future<void> _onStartNewWorkingDay(StartNewWorkingDayEvent event, Emitter<WorkingDayModeState> emit) async {
    print('[WorkingDayModeBloc] Starting new working day for route: ${event.route.name}');

    // Здесь должна быть логика создания нового WorkDay
    // Пока заглушка - нужно получить текущего пользователя из сессии
    try {
      // Получаем текущего пользователя из AppSessionService
      final sessionResult = await AppSessionService.getCurrentAppSession();
      final session = sessionResult.fold((l) => null, (r) => r);

      if (session?.appUser == null) {
        emit(WorkingDayModeError('Не удалось получить данные пользователя'));
        return;
      }

      final newWorkDay = WorkDay(
        id: DateTime.now().millisecondsSinceEpoch,
        user: session!.appUser, // Используем пользователя из сессии
        date: DateTime.now(),
        route: event.route,
        status: WorkDayStatus.active, // Предполагаем, что есть такой статус
      );

      _activeWorkDay = newWorkDay;
      _currentMode = WorkingDayMode.active;

      emit(ActiveWorkingDayState(
        currentWorkDay: newWorkDay,
        isTrackingActive: true,
        lastUpdate: DateTime.now(),
      ));
    } catch (e) {
      emit(WorkingDayModeError('Ошибка создания рабочего дня: $e'));
    }
  }

  void _onFinishActiveWorkingDay(FinishActiveWorkingDayEvent event, Emitter<WorkingDayModeState> emit) {
    print('[WorkingDayModeBloc] Finishing active working day');

    if (_activeWorkDay != null && state is ActiveWorkingDayState) {
      // Переводим активный день в просмотровый режим
      _viewingWorkDay = _activeWorkDay;
      _activeWorkDay = null;
      _currentMode = WorkingDayMode.viewing;

      emit(ViewingWorkingDayState(
        viewingWorkDay: _viewingWorkDay!,
        canSwitchToActive: false, // День завершен, нельзя вернуться в активный режим
      ));
    }
  }

  void _onSwitchToSelectionMode(SwitchToSelectionModeEvent event, Emitter<WorkingDayModeState> emit) {
    print('[WorkingDayModeBloc] Switching to SELECTION mode');
    _currentMode = WorkingDayMode.selection;

    // Здесь должна быть логика загрузки доступных рабочих дней
    emit(SelectionModeState(
      availableWorkDays: [], // Загрузим из блока или репозитория
      suggestedWorkDay: null,
    ));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Геттеры для удобства
  WorkingDayMode get currentMode => _currentMode;
  WorkDay? get activeWorkDay => _activeWorkDay;
  WorkDay? get viewingWorkDay => _viewingWorkDay;
  bool get isActiveMode => _currentMode == WorkingDayMode.active;
  bool get isViewingMode => _currentMode == WorkingDayMode.viewing;
  bool get isSelectionMode => _currentMode == WorkingDayMode.selection;
}
