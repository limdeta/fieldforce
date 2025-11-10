import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/domain/entities/work_day.dart';
import 'package:fieldforce/app/database/repositories/work_day_repository.dart';
import 'package:get_it/get_it.dart';

/// UseCase для получения рабочих дней пользователя
class GetWorkDaysForUserUseCase {
  final WorkDayRepository _workDayRepository = GetIt.instance<WorkDayRepository>();

  /// Получить рабочие дни пользователя
  Future<List<WorkDay>> call(AppUser user) async {
    final result = await _workDayRepository.getWorkDaysForUserWithFullData(user.id);
    return result.fold(
      (failure) {
        // Можно обработать failure, например, логировать или выбросить
        // ignore: avoid_print
        print('Ошибка получения рабочих дней: ${failure.message}');
        return [];
      },
      (workDays) => workDays,
    );
  }
}

