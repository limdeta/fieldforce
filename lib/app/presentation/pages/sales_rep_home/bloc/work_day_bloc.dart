import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fieldforce/app/domain/entities/work_day.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import 'package:fieldforce/app/domain/usecases/get_work_days_for_user_usecase.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service_base.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

// EVENTS
abstract class WorkDayEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadWorkDaysEvent extends WorkDayEvent {
  final DateTime? targetDate; // Дата для автовыбора
  LoadWorkDaysEvent({this.targetDate});
  @override
  List<Object?> get props => [targetDate];
}
class SelectWorkDayEvent extends WorkDayEvent {
  final WorkDay workDay;
  SelectWorkDayEvent(this.workDay);
  @override
  List<Object?> get props => [workDay];
}
class SelectWorkDayByDateEvent extends WorkDayEvent {
  final DateTime date;
  SelectWorkDayByDateEvent(this.date);
  @override
  List<Object?> get props => [date];
}
class StartWorkDayEvent extends WorkDayEvent {
  final WorkDay workDay;
  StartWorkDayEvent(this.workDay);
  @override
  List<Object?> get props => [workDay];
}
class FinishWorkDayEvent extends WorkDayEvent {
  final WorkDay workDay;
  FinishWorkDayEvent(this.workDay);
  @override
  List<Object?> get props => [workDay];
}
class PauseTrackingEvent extends WorkDayEvent {}
class ResumeTrackingEvent extends WorkDayEvent {}
class UpdateActiveTrackEvent extends WorkDayEvent {
  final UserTrack track;
  UpdateActiveTrackEvent(this.track);
  @override
  List<Object?> get props => [track];
}

// STATES
abstract class WorkDayState extends Equatable {
  @override
  List<Object?> get props => [];
}
class WorkDayInitial extends WorkDayState {}
class WorkDayLoading extends WorkDayState {}
class WorkDayLoaded extends WorkDayState {
  final List<WorkDay> workDays;
  final WorkDay? selectedWorkDay;
  final UserTrack? activeTrack;
  WorkDayLoaded({required this.workDays, this.selectedWorkDay, this.activeTrack});
  @override
  List<Object?> get props => [workDays, selectedWorkDay, activeTrack];
}
class WorkDayError extends WorkDayState {
  final String error;
  WorkDayError(this.error);
  @override
  List<Object?> get props => [error];
}

// BLOC
class WorkDayBloc extends Bloc<WorkDayEvent, WorkDayState> {
  final GetWorkDaysForUserUseCase _getWorkDaysForUser = GetIt.instance<GetWorkDaysForUserUseCase>();
  final LocationTrackingServiceBase _trackingService = GetIt.instance<LocationTrackingServiceBase>();

  List<WorkDay> _workDays = [];
  WorkDay? _selectedWorkDay;
  UserTrack? _activeTrack;

  WorkDayBloc() : super(WorkDayInitial()) {
    on<LoadWorkDaysEvent>(_onLoadWorkDays);
    on<SelectWorkDayEvent>(_onSelectWorkDay);
    on<SelectWorkDayByDateEvent>(_onSelectWorkDayByDate);
    on<StartWorkDayEvent>(_onStartWorkDay);
    on<PauseTrackingEvent>(_onPauseTracking);
    on<ResumeTrackingEvent>(_onResumeTracking);
    on<UpdateActiveTrackEvent>(_onUpdateActiveTrack);
    _subscribeToTrackUpdates();
  }

  Future<void> _onLoadWorkDays(LoadWorkDaysEvent event, Emitter<WorkDayState> emit) async {
    emit(WorkDayLoading());
    final session = AppSessionService.currentSession;
    if (session == null) {
      emit(WorkDayError('Нет активной сессии'));
      return;
    }
    final user = session.appUser;
    try {
      final workDays = await _getWorkDaysForUser(user);
      _workDays = workDays;
      print('[WorkDayBloc] Loaded workDays: count=${_workDays.length}');
      
      // Auto-select workday based on target date or today
      final targetDate = event.targetDate ?? DateTime.now();
      if (_workDays.isNotEmpty) {
        // Ищем WorkDay для целевой даты
        final targetWorkDay = _workDays.cast<WorkDay?>().firstWhere(
          (wd) => wd != null && 
                  wd.date.year == targetDate.year && 
                  wd.date.month == targetDate.month && 
                  wd.date.day == targetDate.day,
          orElse: () => null,
        );
        
        if (targetWorkDay != null) {
          _selectedWorkDay = targetWorkDay;
          print('[WorkDayBloc] Found workday for target date: ${targetDate.year}-${targetDate.month}-${targetDate.day}');
        } else {
          _selectedWorkDay = null;
          print('[WorkDayBloc] No workday found for target date: ${targetDate.year}-${targetDate.month}-${targetDate.day}');
        }
      } else {
        _selectedWorkDay = null;
      }
      print('[WorkDayBloc] Selected workday: id=${_selectedWorkDay?.id}, date=${_selectedWorkDay?.date}');
      emit(WorkDayLoaded(workDays: _workDays, selectedWorkDay: _selectedWorkDay, activeTrack: _activeTrack));
    } catch (e) {
      emit(WorkDayError('Ошибка загрузки рабочих дней: $e'));
    }
  }

  void _onSelectWorkDay(SelectWorkDayEvent event, Emitter<WorkDayState> emit) {
    _selectedWorkDay = event.workDay;
    emit(WorkDayLoaded(workDays: _workDays, selectedWorkDay: _selectedWorkDay, activeTrack: _activeTrack));
  }

  void _onSelectWorkDayByDate(SelectWorkDayByDateEvent event, Emitter<WorkDayState> emit) {
    final workDay = _workDays.where((wd) =>
      wd.date.year == event.date.year &&
      wd.date.month == event.date.month &&
      wd.date.day == event.date.day
    ).firstOrNull;
    if (workDay != null) {
      _selectedWorkDay = workDay;
    }
    emit(WorkDayLoaded(workDays: _workDays, selectedWorkDay: _selectedWorkDay, activeTrack: _activeTrack));
  }

  Future<void> _onStartWorkDay(StartWorkDayEvent event, Emitter<WorkDayState> emit) async {
    // ...implement start logic (similar to provider)...
  }

  Future<void> _onPauseTracking(PauseTrackingEvent event, Emitter<WorkDayState> emit) async {
    await _trackingService.pauseTracking();
  }
  Future<void> _onResumeTracking(ResumeTrackingEvent event, Emitter<WorkDayState> emit) async {
    await _trackingService.resumeTracking();
  }

  void _onUpdateActiveTrack(UpdateActiveTrackEvent event, Emitter<WorkDayState> emit) {
    _activeTrack = event.track;
    // Обновляем только activeTrack в текущем состоянии без перезагрузки WorkDays
    if (state is WorkDayLoaded) {
      final currentState = state as WorkDayLoaded;
      emit(WorkDayLoaded(
        workDays: currentState.workDays, 
        selectedWorkDay: currentState.selectedWorkDay, 
        activeTrack: _activeTrack
      ));
    }
  }

  void _subscribeToTrackUpdates() {
    _trackingService.trackUpdateStream.listen((track) {
      // Отправляем событие вместо прямого вызова emit
      add(UpdateActiveTrackEvent(track));
    });
  }
}
