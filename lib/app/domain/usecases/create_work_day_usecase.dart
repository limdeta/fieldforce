import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/domain/entities/work_day.dart';
import 'package:fieldforce/app/domain/entities/route.dart' as shop;
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/app/database/repositories/work_day_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

class CreateWorkDayUseCase {
  final WorkDayRepository _workDayRepository;

  CreateWorkDayUseCase(this._workDayRepository);

  Future<Either<Failure, WorkDay>> call({
    required AppUser user,
    required shop.Route route,
    UserTrack? track,
    DateTime? date,
  }) async {
    final now = DateTime.now();
    final workDayDate = date ?? DateTime(now.year, now.month, now.day);
    final startTime = DateTime(workDayDate.year, workDayDate.month, workDayDate.day, 8, 0);
    final endTime = DateTime(workDayDate.year, workDayDate.month, workDayDate.day, 18, 0);

    final workDay = WorkDay(
      id: 0,
      user: user,
      date: workDayDate,
      route: route,
      track: track,
      status: WorkDayStatus.planned,
      startTime: startTime,
      endTime: endTime,
      metadata: null,
    );

    return await _workDayRepository.createWorkDay(workDay);
  }
}
