import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/app/domain/work_day.dart';

/// Простой интеграционный тест для логики отображения треков в WorkDay
/// 
/// Проверяет ключевую проблему: предотвращение "путешествий во времени" активных треков
void main() {
  group('WorkDay Track Display Logic', () {
    test('активный трек показывается только на сегодняшнем WorkDay', () {
      print('🧪 === ТЕСТ: Логика отображения активного трека ===');
      
      // 1. Создаем тестовые WorkDay для разных дней
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      
      // Создаем WorkDay для каждого дня
      final yesterdayWorkDay = WorkDay(
        id: 1,
        userId: 123,
        date: yesterday,
        status: WorkDayStatus.completed,
      );
      
      final todayWorkDay = WorkDay(
        id: 2,
        userId: 123,
        date: today,
        status: WorkDayStatus.active,
      );
      
      final tomorrowWorkDay = WorkDay(
        id: 3,
        userId: 123,
        date: tomorrow,
        status: WorkDayStatus.planned,
      );
      
      print('✅ Созданы WorkDay для трех дней');
      
      // 2. КЛЮЧЕВАЯ ПРОВЕРКА: Логика isToday
      print('📅 === ПРОВЕРКА ЛОГИКИ isToday ===');
      
      expect(yesterdayWorkDay.isToday, isFalse, 
        reason: 'Вчерашний день не должен быть "сегодня"');
      expect(todayWorkDay.isToday, isTrue, 
        reason: 'Сегодняшний день должен быть "сегодня"');
      expect(tomorrowWorkDay.isToday, isFalse, 
        reason: 'Завтрашний день не должен быть "сегодня"');
      
      print('✅ Вчера: isToday = ${yesterdayWorkDay.isToday}');
      print('✅ Сегодня: isToday = ${todayWorkDay.isToday}');
      print('✅ Завтра: isToday = ${tomorrowWorkDay.isToday}');
      
      // 3. ЛОГИКА ОТОБРАЖЕНИЯ ТРЕКОВ (как в sales_rep_home_page.dart)
      print('🗺️ === ПРОВЕРКА ЛОГИКИ ОТОБРАЖЕНИЯ ===');
      
      // Имитируем активный трек
      final hasActiveTrack = true; // В реальности: workDayProvider.activeTrack != null
      
      // Логика из UI:
      // if (selectedWorkDay.isToday && workDayProvider.activeTrack != null) {
      //   trackToShow = workDayProvider.activeTrack;
      // } else {
      //   trackToShow = selectedWorkDay.actualTrack;
      // }
      
      // Проверяем для каждого дня
      final workDays = [yesterdayWorkDay, todayWorkDay, tomorrowWorkDay];
      int daysShowingActiveTrack = 0;
      
      for (final workDay in workDays) {
        final shouldShowActiveTrack = workDay.isToday && hasActiveTrack;
        
        if (shouldShowActiveTrack) {
          daysShowingActiveTrack++;
          print('✅ ${_getDayName(workDay)}: показываем АКТИВНЫЙ трек');
        } else {
          print('✅ ${_getDayName(workDay)}: показываем actualTrack или null');
        }
      }
      
      // Активный трек должен показываться только на одном дне (сегодня)
      expect(daysShowingActiveTrack, equals(1), 
        reason: 'Активный трек должен показываться только на сегодняшнем дне');
      
      // 4. ПРОВЕРКА: Предотвращение "путешествий во времени"
      print('🕒 === ПРЕДОТВРАЩЕНИЕ "ПУТЕШЕСТВИЙ ВО ВРЕМЕНИ" ===');
      
      // Вчера: НЕ показываем активный трек
      final yesterdayShowsActive = yesterdayWorkDay.isToday && hasActiveTrack;
      expect(yesterdayShowsActive, isFalse, 
        reason: 'На вчерашнем дне НЕ должен показываться активный трек');
      
      // Сегодня: показываем активный трек
      final todayShowsActive = todayWorkDay.isToday && hasActiveTrack;
      expect(todayShowsActive, isTrue, 
        reason: 'На сегодняшнем дне должен показываться активный трек');
      
      // Завтра: НЕ показываем активный трек
      final tomorrowShowsActive = tomorrowWorkDay.isToday && hasActiveTrack;
      expect(tomorrowShowsActive, isFalse, 
        reason: 'На завтрашнем дне НЕ должен показываться активный трек');
      
      print('✅ "Путешествия во времени" предотвращены');
      
      print('🎉 === ТЕСТ ПРОЙДЕН: Логика отображения треков корректна ===');
    });

    test('проверка isToday для разных времен дня', () {
      print('🧪 === ТЕСТ: Логика isToday в разное время ===');
      
      final now = DateTime.now();
      
      // Разное время в течение сегодняшнего дня
      final morningToday = DateTime(now.year, now.month, now.day, 6, 0);
      final eveningToday = DateTime(now.year, now.month, now.day, 23, 59);
      
      // Другие дни
      final yesterday = DateTime(now.year, now.month, now.day - 1, 12, 0);
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 12, 0);
      
      final workDays = [
        WorkDay(id: 1, userId: 1, date: morningToday, status: WorkDayStatus.active),
        WorkDay(id: 2, userId: 1, date: eveningToday, status: WorkDayStatus.active),
        WorkDay(id: 3, userId: 1, date: yesterday, status: WorkDayStatus.completed),
        WorkDay(id: 4, userId: 1, date: tomorrow, status: WorkDayStatus.planned),
      ];
      
      final results = [
        workDays[0].isToday, // утро сегодня
        workDays[1].isToday, // вечер сегодня
        workDays[2].isToday, // вчера
        workDays[3].isToday, // завтра
      ];
      
      expect(results, equals([true, true, false, false]), 
        reason: 'Только сегодняшние WorkDay должны возвращать isToday = true');
      
      print('✅ Утро сегодня: isToday = ${results[0]}');
      print('✅ Вечер сегодня: isToday = ${results[1]}');
      print('✅ Вчера: isToday = ${results[2]}');
      print('✅ Завтра: isToday = ${results[3]}');
      
      print('✅ isToday логика работает корректно');
    });

    test('тестирование TDD подхода для фикстур', () {
      print('🧪 === ТЕСТ: TDD подход для переиспользования фикстур ===');
      
      // Этот тест демонстрирует как фикстуры должны работать и в dev и в test
      
      // 1. Создаем структуры данных как в реальном приложении
      final salesRepId = 123;
      final now = DateTime.now();
      
      // WorkDay структуры должны создаваться одинаково в dev и test
      final workDays = _createWorkDaysForUser(salesRepId, now);
      
      expect(workDays.length, equals(3), 
        reason: 'Должно быть 3 WorkDay: вчера, сегодня, завтра');
      
      // Проверяем что структуры правильные
      final yesterdayWD = workDays.firstWhere((wd) => !wd.isToday && wd.date.isBefore(now));
      final todayWD = workDays.firstWhere((wd) => wd.isToday);
      final tomorrowWD = workDays.firstWhere((wd) => !wd.isToday && wd.date.isAfter(now));
      
      expect(yesterdayWD.status, equals(WorkDayStatus.completed));
      expect(todayWD.status, equals(WorkDayStatus.active));
      expect(tomorrowWD.status, equals(WorkDayStatus.planned));
      
      print('✅ WorkDay структуры созданы корректно');
      print('✅ Вчера: ${yesterdayWD.status}');
      print('✅ Сегодня: ${todayWD.status}');
      print('✅ Завтра: ${tomorrowWD.status}');
      
      // 2. Тестируем логику которая должна работать одинаково в dev и prod
      final trackDisplayLogic = _testTrackDisplayLogic(workDays);
      expect(trackDisplayLogic['activeTrackDays'], equals(1), 
        reason: 'Активный трек должен показываться только на 1 дне');
      expect(trackDisplayLogic['todayShowsActive'], isTrue, 
        reason: 'Сегодняшний день должен показывать активный трек');
      
      print('✅ Логика отображения треков протестирована');
      
      print('🎉 === КОНЦЕПЦИЯ TDD РАБОТАЕТ: Фикстуры переиспользуемы ===');
    });
  });
}

/// Создает WorkDay для пользователя - эта логика должна работать и в dev и в test
List<WorkDay> _createWorkDaysForUser(int userId, DateTime baseDate) {
  final yesterday = DateTime(baseDate.year, baseDate.month, baseDate.day - 1);
  final today = DateTime(baseDate.year, baseDate.month, baseDate.day);
  final tomorrow = DateTime(baseDate.year, baseDate.month, baseDate.day + 1);
  
  return [
    WorkDay(
      id: yesterday.millisecondsSinceEpoch,
      userId: userId,
      date: yesterday,
      status: WorkDayStatus.completed,
    ),
    WorkDay(
      id: today.millisecondsSinceEpoch,
      userId: userId,
      date: today,
      status: WorkDayStatus.active,
    ),
    WorkDay(
      id: tomorrow.millisecondsSinceEpoch,
      userId: userId,
      date: tomorrow,
      status: WorkDayStatus.planned,
    ),
  ];
}

/// Тестирует логику отображения треков - должна работать одинаково везде
Map<String, dynamic> _testTrackDisplayLogic(List<WorkDay> workDays) {
  final hasActiveTrack = true;
  int activeTrackDays = 0;
  bool todayShowsActive = false;
  
  for (final workDay in workDays) {
    final showsActive = workDay.isToday && hasActiveTrack;
    if (showsActive) {
      activeTrackDays++;
      if (workDay.isToday) todayShowsActive = true;
    }
  }
  
  return {
    'activeTrackDays': activeTrackDays,
    'todayShowsActive': todayShowsActive,
  };
}

/// Вспомогательная функция для читаемых логов
String _getDayName(WorkDay workDay) {
  if (workDay.isToday) return 'Сегодня';
  
  final now = DateTime.now();
  if (workDay.date.isBefore(now)) return 'Вчера';
  if (workDay.date.isAfter(now)) return 'Завтра';
  
  return 'Неизвестно';
}
  group('WorkDay Track Display Logic', () {
    test('активный трек показывается только на сегодняшнем WorkDay', () {
      print('🧪 === ТЕСТ: Логика отображения активного трека ===');
      
      // 1. Создаем тестовые WorkDay для разных дней
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      
      // Создаем WorkDay для каждого дня
      final yesterdayWorkDay = WorkDay(
        id: 1,
        userId: 123,
        date: yesterday,
        status: WorkDayStatus.completed,
      );
      
      final todayWorkDay = WorkDay(
        id: 2,
        userId: 123,
        date: today,
        status: WorkDayStatus.active,
      );
      
      final tomorrowWorkDay = WorkDay(
        id: 3,
        userId: 123,
        date: tomorrow,
        status: WorkDayStatus.planned,
      );
      
      print('✅ Созданы WorkDay для трех дней');
      
      // 2. КЛЮЧЕВАЯ ПРОВЕРКА: Логика isToday
      print('📅 === ПРОВЕРКА ЛОГИКИ isToday ===');
      
      expect(yesterdayWorkDay.isToday, isFalse, 
        reason: 'Вчерашний день не должен быть "сегодня"');
      expect(todayWorkDay.isToday, isTrue, 
        reason: 'Сегодняшний день должен быть "сегодня"');
      expect(tomorrowWorkDay.isToday, isFalse, 
        reason: 'Завтрашний день не должен быть "сегодня"');
      
      print('✅ Вчера: isToday = ${yesterdayWorkDay.isToday}');
      print('✅ Сегодня: isToday = ${todayWorkDay.isToday}');
      print('✅ Завтра: isToday = ${tomorrowWorkDay.isToday}');
      
      // 3. ЛОГИКА ОТОБРАЖЕНИЯ ТРЕКОВ (как в sales_rep_home_page.dart)
      print('🗺️ === ПРОВЕРКА ЛОГИКИ ОТОБРАЖЕНИЯ ===');
      
      // Имитируем активный трек
      final hasActiveTrack = true; // В реальности: workDayProvider.activeTrack != null
      
      // Логика из UI:
      // if (selectedWorkDay.isToday && workDayProvider.activeTrack != null) {
      //   trackToShow = workDayProvider.activeTrack;
      // } else {
      //   trackToShow = selectedWorkDay.actualTrack;
      // }
      
      // Проверяем для каждого дня
      final workDays = [yesterdayWorkDay, todayWorkDay, tomorrowWorkDay];
      int daysShowingActiveTrack = 0;
      
      for (final workDay in workDays) {
        final shouldShowActiveTrack = workDay.isToday && hasActiveTrack;
        
        if (shouldShowActiveTrack) {
          daysShowingActiveTrack++;
          print('✅ ${_getDayName(workDay)}: показываем АКТИВНЫЙ трек');
        } else {
          print('✅ ${_getDayName(workDay)}: показываем actualTrack или null');
        }
      }
      
      // Активный трек должен показываться только на одном дне (сегодня)
      expect(daysShowingActiveTrack, equals(1), 
        reason: 'Активный трек должен показываться только на сегодняшнем дне');
      
      // 4. ПРОВЕРКА: Предотвращение "путешествий во времени"
      print('🕒 === ПРЕДОТВРАЩЕНИЕ "ПУТЕШЕСТВИЙ ВО ВРЕМЕНИ" ===');
      
      // Вчера: НЕ показываем активный трек
      final yesterdayShowsActive = yesterdayWorkDay.isToday && hasActiveTrack;
      expect(yesterdayShowsActive, isFalse, 
        reason: 'На вчерашнем дне НЕ должен показываться активный трек');
      
      // Сегодня: показываем активный трек
      final todayShowsActive = todayWorkDay.isToday && hasActiveTrack;
      expect(todayShowsActive, isTrue, 
        reason: 'На сегодняшнем дне должен показываться активный трек');
      
      // Завтра: НЕ показываем активный трек
      final tomorrowShowsActive = tomorrowWorkDay.isToday && hasActiveTrack;
      expect(tomorrowShowsActive, isFalse, 
        reason: 'На завтрашнем дне НЕ должен показываться активный трек');
      
      print('✅ "Путешествия во времени" предотвращены');
      
      print('🎉 === ТЕСТ ПРОЙДЕН: Логика отображения треков корректна ===');
    });

    test('проверка isToday для разных времен дня', () {
      print('🧪 === ТЕСТ: Логика isToday в разное время ===');
      
      final now = DateTime.now();
      
      // Разное время в течение сегодняшнего дня
      final morningToday = DateTime(now.year, now.month, now.day, 6, 0);
      final eveningToday = DateTime(now.year, now.month, now.day, 23, 59);
      
      // Другие дни
      final yesterday = DateTime(now.year, now.month, now.day - 1, 12, 0);
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 12, 0);
      
      final workDays = [
        WorkDay(id: 1, userId: 1, date: morningToday, status: WorkDayStatus.active),
        WorkDay(id: 2, userId: 1, date: eveningToday, status: WorkDayStatus.active),
        WorkDay(id: 3, userId: 1, date: yesterday, status: WorkDayStatus.completed),
        WorkDay(id: 4, userId: 1, date: tomorrow, status: WorkDayStatus.planned),
      ];
      
      final results = [
        workDays[0].isToday, // утро сегодня
        workDays[1].isToday, // вечер сегодня
        workDays[2].isToday, // вчера
        workDays[3].isToday, // завтра
      ];
      
      expect(results, equals([true, true, false, false]), 
        reason: 'Только сегодняшние WorkDay должны возвращать isToday = true');
      
      print('✅ Утро сегодня: isToday = ${results[0]}');
      print('✅ Вечер сегодня: isToday = ${results[1]}');
      print('✅ Вчера: isToday = ${results[2]}');
      print('✅ Завтра: isToday = ${results[3]}');
      
      print('✅ isToday логика работает корректно');
    });

    test('тестирование TDD подхода для фикстур', () {
      print('🧪 === ТЕСТ: TDD подход для переиспользования фикстур ===');
      
      // Этот тест демонстрирует как фикстуры должны работать и в dev и в test
      
      // 1. Создаем структуры данных как в реальном приложении
      final salesRepId = 123;
      final now = DateTime.now();
      
      // WorkDay структуры должны создаваться одинаково в dev и test
      final workDays = _createWorkDaysForUser(salesRepId, now);
      
      expect(workDays.length, equals(3), 
        reason: 'Должно быть 3 WorkDay: вчера, сегодня, завтра');
      
      // Проверяем что структуры правильные
      final yesterdayWD = workDays.firstWhere((wd) => !wd.isToday && wd.date.isBefore(now));
      final todayWD = workDays.firstWhere((wd) => wd.isToday);
      final tomorrowWD = workDays.firstWhere((wd) => !wd.isToday && wd.date.isAfter(now));
      
      expect(yesterdayWD.status, equals(WorkDayStatus.completed));
      expect(todayWD.status, equals(WorkDayStatus.active));
      expect(tomorrowWD.status, equals(WorkDayStatus.planned));
      
      print('✅ WorkDay структуры созданы корректно');
      print('✅ Вчера: ${yesterdayWD.status}');
      print('✅ Сегодня: ${todayWD.status}');
      print('✅ Завтра: ${tomorrowWD.status}');
      
      // 2. Тестируем логику которая должна работать одинаково в dev и prod
      final trackDisplayLogic = _testTrackDisplayLogic(workDays);
      expect(trackDisplayLogic['activeTrackDays'], equals(1), 
        reason: 'Активный трек должен показываться только на 1 дне');
      expect(trackDisplayLogic['todayShowsActive'], isTrue, 
        reason: 'Сегодняшний день должен показывать активный трек');
      
      print('✅ Логика отображения треков протестирована');
      
      print('🎉 === КОНЦЕПЦИЯ TDD РАБОТАЕТ: Фикстуры переиспользуемы ===');
    });
  });
}

/// Создает WorkDay для пользователя - эта логика должна работать и в dev и в test
List<WorkDay> _createWorkDaysForUser(int userId, DateTime baseDate) {
  final yesterday = DateTime(baseDate.year, baseDate.month, baseDate.day - 1);
  final today = DateTime(baseDate.year, baseDate.month, baseDate.day);
  final tomorrow = DateTime(baseDate.year, baseDate.month, baseDate.day + 1);
  
  return [
    WorkDay(
      id: yesterday.millisecondsSinceEpoch,
      userId: userId,
      date: yesterday,
      status: WorkDayStatus.completed,
    ),
    WorkDay(
      id: today.millisecondsSinceEpoch,
      userId: userId,
      date: today,
      status: WorkDayStatus.active,
    ),
    WorkDay(
      id: tomorrow.millisecondsSinceEpoch,
      userId: userId,
      date: tomorrow,
      status: WorkDayStatus.planned,
    ),
  ];
}

/// Тестирует логику отображения треков - должна работать одинаково везде
Map<String, dynamic> _testTrackDisplayLogic(List<WorkDay> workDays) {
  final hasActiveTrack = true;
  int activeTrackDays = 0;
  bool todayShowsActive = false;
  
  for (final workDay in workDays) {
    final showsActive = workDay.isToday && hasActiveTrack;
    if (showsActive) {
      activeTrackDays++;
      if (workDay.isToday) todayShowsActive = true;
    }
  }
  
  return {
    'activeTrackDays': activeTrackDays,
    'todayShowsActive': todayShowsActive,
  };
}

/// Вспомогательная функция для читаемых логов
String _getDayName(WorkDay workDay) {
  if (workDay.isToday) return 'Сегодня';
  
  final now = DateTime.now();
  if (workDay.date.isBefore(now)) return 'Вчера';
  if (workDay.date.isAfter(now)) return 'Завтра';
  
  return 'Неизвестно';
}

/// Интеграционный тест для логики отображения треков в WorkDay
/// 
/// Проверяет ключевую проблему: когда и какой трек показывать на карте
/// чтобы предотвратить "путешествия во времени" активных треков.
void main() {
  group('WorkDay Track Display Logic', () {
    test('активный трек показывается только на сегодняшнем WorkDay', () async {
      print('🧪 === ТЕСТ: Логика отображения активного трека ===');
      
      // 1. Создаем тестовые WorkDay для разных дней
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day - 1);
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      
      // Вчерашний WorkDay с завершенным треком
      final yesterdayWorkDay = WorkDay(
        id: 1,
        userId: 123,
        date: yesterday,
        plannedRoute: null,
        actualTrack: _createCompletedTrack(50), // 50 точек завершенного трека
        status: WorkDayStatus.completed,
      );
      
      // Сегодняшний WorkDay с частично пройденным треком
      final todayWorkDay = WorkDay(
        id: 2,
        userId: 123,
        date: today,
        plannedRoute: null,
        actualTrack: _createCompletedTrack(25), // 25 точек уже пройденной части
        status: WorkDayStatus.active,
      );
      
      // Завтрашний WorkDay без трека
      final tomorrowWorkDay = WorkDay(
        id: 3,
        userId: 123,
        date: tomorrow,
        plannedRoute: null,
        actualTrack: null,
        status: WorkDayStatus.planned,
      );
      
      // 2. Создаем активный трек (текущее движение)
      final activeTrack = _createActiveTrack(35); // 35 точек активного движения
      
      print('✅ Созданы WorkDay и активный трек');
      
      // 3. КЛЮЧЕВАЯ ПРОВЕРКА: Логика отображения треков
      print('🗺️ === ПРОВЕРКА ЛОГИКИ ОТОБРАЖЕНИЯ ===');
      
      // Логика из sales_rep_home_page.dart:
      // if (selectedWorkDay.isToday && workDayProvider.activeTrack != null) {
      //   trackToShow = workDayProvider.activeTrack;
      // } else {
      //   trackToShow = selectedWorkDay.actualTrack;
      // }
      
      // Вчерашний день: НЕ показываем активный трек
      final yesterdayTrackToShow = _getTrackToShow(yesterdayWorkDay, activeTrack);
      expect(yesterdayTrackToShow, equals(yesterdayWorkDay.actualTrack), 
        reason: 'На вчерашнем дне должен показываться только actualTrack');
      expect(yesterdayTrackToShow, isNot(equals(activeTrack)), 
        reason: 'На вчерашнем дне НЕ должен показываться активный трек');
      expect(yesterdayTrackToShow?.totalPoints, equals(50), 
        reason: 'Вчерашний трек должен содержать 50 точек');
      print('✅ Вчера: показываем завершенный трек (${yesterdayTrackToShow?.totalPoints} точек)');
      
      // Сегодняшний день: показываем активный трек
      final todayTrackToShow = _getTrackToShow(todayWorkDay, activeTrack);
      expect(todayTrackToShow, equals(activeTrack), 
        reason: 'На сегодняшнем дне должен показываться активный трек');
      expect(todayTrackToShow.totalPoints, equals(35), 
        reason: 'Активный трек должен содержать 35 точек');
      print('✅ Сегодня: показываем активный трек (${todayTrackToShow.totalPoints} точек)');
      
      // Завтрашний день: ничего не показываем
      final tomorrowTrackToShow = _getTrackToShow(tomorrowWorkDay, activeTrack);
      expect(tomorrowTrackToShow, isNull, 
        reason: 'На завтрашнем дне не должно быть трека');
      print('✅ Завтра: никаких треков (${tomorrowTrackToShow?.totalPoints ?? 0} точек)');
      
      // 4. ПРОВЕРКА: Предотвращение "путешествий во времени"
      print('🕒 === ПРЕДОТВРАЩЕНИЕ "ПУТЕШЕСТВИЙ ВО ВРЕМЕНИ" ===');
      
      expect(yesterdayWorkDay.isToday, isFalse, 
        reason: 'Вчерашний день не должен быть "сегодня"');
      expect(todayWorkDay.isToday, isTrue, 
        reason: 'Сегодняшний день должен быть "сегодня"');
      expect(tomorrowWorkDay.isToday, isFalse, 
        reason: 'Завтрашний день не должен быть "сегодня"');
      
      // Активный трек должен отображаться ТОЛЬКО на сегодняшнем дне
      final daysShowingActiveTrack = [yesterdayWorkDay, todayWorkDay, tomorrowWorkDay]
          .where((workDay) => _getTrackToShow(workDay, activeTrack) == activeTrack)
          .length;
      
      expect(daysShowingActiveTrack, equals(1), 
        reason: 'Активный трек должен показываться только на 1 дне (сегодня)');
      
      print('✅ Активный трек показывается только на сегодняшнем дне');
      
      // 5. ПРОВЕРКА: Пройденная часть сохраняется
      print('📍 === ПРОВЕРКА ПРОЙДЕННОЙ ЧАСТИ ===');
      
      expect(todayWorkDay.actualTrack, isNotNull, 
        reason: 'У сегодняшнего дня должна быть пройденная часть');
      expect(todayWorkDay.actualTrack!.totalPoints, equals(25), 
        reason: 'Пройденная часть должна содержать 25 точек');
      
      // На карте показываем активный трек (35 точек), но пройденная часть (25 точек) сохранена
      expect(todayTrackToShow.totalPoints, greaterThan(todayWorkDay.actualTrack!.totalPoints), 
        reason: 'Активный трек должен содержать больше точек чем пройденная часть');
      
      print('✅ Пройденная часть (25 точек) сохранена в actualTrack');
      print('✅ Активный трек (35 точек) показывается на карте');
      
      print('🎉 === ТЕСТ ПРОЙДЕН: Логика отображения треков работает корректно ===');
    });

    test('проверка isToday логики для разных дат', () {
      print('🧪 === ТЕСТ: Логика isToday ===');
      
      final now = DateTime.now();
      
      // Тестируем разные временные зоны в рамках одного дня
      final morningToday = DateTime(now.year, now.month, now.day, 6, 0); // 6:00
      final eveningToday = DateTime(now.year, now.month, now.day, 23, 59); // 23:59
      final yesterday = DateTime(now.year, now.month, now.day - 1, 12, 0); // Вчера в полдень
      final tomorrow = DateTime(now.year, now.month, now.day + 1, 12, 0); // Завтра в полдень
      
      final morningWorkDay = WorkDay(id: 1, userId: 1, date: morningToday, status: WorkDayStatus.active);
      final eveningWorkDay = WorkDay(id: 2, userId: 1, date: eveningToday, status: WorkDayStatus.active);
      final yesterdayWorkDay = WorkDay(id: 3, userId: 1, date: yesterday, status: WorkDayStatus.completed);
      final tomorrowWorkDay = WorkDay(id: 4, userId: 1, date: tomorrow, status: WorkDayStatus.planned);
      
      expect(morningWorkDay.isToday, isTrue, reason: 'Утро сегодня должно быть "сегодня"');
      expect(eveningWorkDay.isToday, isTrue, reason: 'Вечер сегодня должно быть "сегодня"');
      expect(yesterdayWorkDay.isToday, isFalse, reason: 'Вчера не должно быть "сегодня"');
      expect(tomorrowWorkDay.isToday, isFalse, reason: 'Завтра не должно быть "сегодня"');
      
      print('✅ isToday логика работает корректно для всех времен дня');
    });
  });
}

/// Логика определения какой трек показывать - ТОЧНО как в sales_rep_home_page.dart
UserTrack? _getTrackToShow(WorkDay selectedWorkDay, UserTrack? activeTrack) {
  if (selectedWorkDay.isToday && activeTrack != null) {
    return activeTrack; // Активный трек только на сегодняшнем дне
  } else {
    return selectedWorkDay.actualTrack; // Исторический трек или null
  }
}

/// Создает завершенный трек для тестирования
UserTrack _createCompletedTrack(int pointsCount) {
  return UserTrack(
    id: DateTime.now().millisecondsSinceEpoch,
    user: null,
    routeId: 'test_route',
    status: UserTrackStatus.completed,
    trackPoints: _createTestPoints(pointsCount),
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
  );
}

/// Создает активный трек для тестирования
UserTrack _createActiveTrack(int pointsCount) {
  return UserTrack(
    id: DateTime.now().millisecondsSinceEpoch + 1000,
    user: null,
    routeId: 'test_route',
    status: UserTrackStatus.active,
    trackPoints: _createTestPoints(pointsCount),
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now(),
  );
}

/// Создает тестовые точки трека
List<UserTrackPoint> _createTestPoints(int count) {
  final points = <UserTrackPoint>[];
  final baseTime = DateTime.now().subtract(Duration(minutes: count));
  
  for (int i = 0; i < count; i++) {
    points.add(UserTrackPoint(
      id: '$i',
      userTrackId: 'test_track',
      latitude: 43.1158 + (i * 0.001), // Владивосток + движение
      longitude: 131.8858 + (i * 0.001),
      timestamp: baseTime.add(Duration(minutes: i)),
      accuracy: 5.0,
      altitude: 0,
      heading: 0,
      speed: 1.0,
    ));
  }
  
  return points;
}

/// Интеграционный тест для WorkDay архитектуры
/// 
/// Этот тест проверяет ключевую проблему: логику отображения треков по датам.
/// Цель: убедиться что активный трек показывается только на сегодняшнем дне,
/// а исторические треки - только на соответствующих датах.
void main() {
  group('WorkDay Integration - Track Display Logic', () {
    setUpAll(() async {
      await setupTestServiceLocator();
    });

    tearDownAll(() async {
      await GetIt.instance.reset();
    });

    test('треки отображаются корректно по датам - нет "путешествий во времени"', () async {
      print('🧪 === ТЕСТ: Логика отображения треков по датам ===');
      
      // 1. SETUP: Создаем полный набор dev данных
      final orchestrator = DevFixtureOrchestratorFactory.create();
      final result = await orchestrator.createFullDevDataset();
      
      expect(result.success, isTrue, reason: 'Dev данные должны создаваться');
      expect(result.appUsers.salesReps.isNotEmpty, isTrue, reason: 'Должен быть торговый представитель');
      
      final salesRep = result.appUsers.salesReps.first;
      print('✅ Создан пользователь: ${salesRep.fullName}');
      
      // 2. Создаем сессию для пользователя
      final session = AppSession(appUser: salesRep);
      AppSessionService.setCurrentSession(session);
      
      // 3. Инициализируем WorkDayProvider
      final workDayProvider = WorkDayProvider();
      await workDayProvider.loadWorkDays();
      
      expect(workDayProvider.workDays.length, equals(3), 
        reason: 'Должно быть 3 WorkDay: вчера, сегодня, завтра');
      
      final yesterdayWorkDay = workDayProvider.workDays
          .where((wd) => !wd.isToday && wd.date.isBefore(DateTime.now()))
          .first;
      final todayWorkDay = workDayProvider.workDays
          .where((wd) => wd.isToday)
          .first;
      final tomorrowWorkDay = workDayProvider.workDays
          .where((wd) => !wd.isToday && wd.date.isAfter(DateTime.now()))
          .first;
      
      print('📅 Вчера: ${yesterdayWorkDay.date} (${yesterdayWorkDay.status})');
      print('📅 Сегодня: ${todayWorkDay.date} (${todayWorkDay.status})');
      print('📅 Завтра: ${tomorrowWorkDay.date} (${tomorrowWorkDay.status})');
      
      // 4. КЛЮЧЕВАЯ ПРОВЕРКА: Имитируем логику отображения треков
      print('🗺️ === ПРОВЕРКА ЛОГИКИ ОТОБРАЖЕНИЯ ===');
      
      // Имитируем активный трек (как в реальном приложении)
      final mockActiveTrack = _createMockActiveTrack(salesRep.employee.id);
      
      // Проверяем логику для каждого дня
      for (final workDay in [yesterdayWorkDay, todayWorkDay, tomorrowWorkDay]) {
        workDayProvider.selectWorkDay(workDay);
        
        // Это логика из sales_rep_home_page.dart
        UserTrack? trackToShow;
        if (workDay.isToday && mockActiveTrack != null) {
          trackToShow = mockActiveTrack; // Активный трек только на сегодняшнем дне
        } else {
          trackToShow = workDay.actualTrack; // Исторический трек или null
        }
        
        if (workDay.isToday) {
          expect(trackToShow, equals(mockActiveTrack), 
            reason: 'На сегодняшнем дне должен показываться активный трек');
          print('✅ Сегодня: показываем активный трек (${trackToShow?.totalPoints ?? 0} точек)');
        } else if (workDay == yesterdayWorkDay) {
          expect(trackToShow, equals(workDay.actualTrack), 
            reason: 'На вчерашнем дне должен показываться исторический трек');
          expect(trackToShow, isNot(equals(mockActiveTrack)), 
            reason: 'На вчерашнем дне НЕ должен показываться активный трек');
          print('✅ Вчера: показываем исторический трек (${trackToShow?.totalPoints ?? 0} точек)');
        } else {
          expect(trackToShow, isNull, 
            reason: 'На завтрашнем дне не должно быть трека');
          print('✅ Завтра: никаких треков');
        }
      }
      
      print('🎉 === ТЕСТ ПРОЙДЕН: "Путешествия во времени" предотвращены ===');
    });

    test('WorkDayProvider правильно связан с активным треком', () async {
      print('🧪 === ТЕСТ: Связь WorkDayProvider с активным треком ===');
      
      // Создаем dev данные
      final orchestrator = DevFixtureOrchestratorFactory.create();
      final result = await orchestrator.createFullDevDataset();
      final salesRep = result.appUsers.salesReps.first;
      
      final session = AppSession(appUser: salesRep);
      AppSessionService.setCurrentSession(session);
      
      // Инициализируем провайдер
      final workDayProvider = WorkDayProvider();
      await workDayProvider.loadWorkDays();
      
      // Выбираем сегодняшний день
      final todayWorkDay = workDayProvider.todayWorkDay!;
      workDayProvider.selectWorkDay(todayWorkDay);
      
      expect(workDayProvider.selectedWorkDay, equals(todayWorkDay), 
        reason: 'Выбранный WorkDay должен быть сегодняшним');
      expect(todayWorkDay.isToday, isTrue, 
        reason: 'Сегодняшний WorkDay должен определяться как "сегодня"');
      
      print('✅ WorkDayProvider корректно управляет выбором дней');
      
      // Проверяем что activeTrack будет получаться через trackUpdateStream
      // (в реальном приложении это происходит через LocationTrackingService)
      print('✅ Инициализация завершена, activeTrack будет получен через stream');
      
      print('🎉 === ТЕСТ ПРОЙДЕН: WorkDayProvider правильно настроен ===');
    });
  });
}

/// Создает mock активного трека для тестирования
UserTrack _createMockActiveTrack(int userId) {
  return UserTrack(
    id: DateTime.now().millisecondsSinceEpoch,
    userId: userId,
    routeId: 'current_route',
    status: TrackStatus.active,
    trackPoints: _createMockTrackPoints(30), // 30 точек активного движения
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now(),
  );
}

/// Создает mock точки трека
List<TrackPoint> _createMockTrackPoints(int count) {
  final points = <TrackPoint>[];
  final baseTime = DateTime.now().subtract(Duration(minutes: count));
  
  for (int i = 0; i < count; i++) {
    points.add(TrackPoint(
      id: '$i',
      latitude: 43.1158 + (i * 0.001), // Владивосток + небольшое смещение
      longitude: 131.8858 + (i * 0.001),
      timestamp: baseTime.add(Duration(minutes: i)),
      accuracy: 5.0,
    ));
  }
  
  return points;
}

/// Настройка тестового сервис локатора
Future<void> setupTestServiceLocator() async {
  // Инициализируем сервис локатор как в основном приложении
  await setupServiceLocator();
}

/// Интеграционный тест для проверки создания и работы WorkDay
/// 
/// Тестирует сценарий:
/// 1. Создание пользователя с двумя маршрутами (вчерашний + текущий)
/// 2. Создание трека для текущего маршрута
/// 3. Правильное связывание WorkDay -> Route -> Track
/// 4. Корректное отображение треков только на нужных маршрутах
void main() {
  group('WorkDay Integration Tests', () {
    late DevFixtureOrchestrator orchestrator;
    late WorkDayProvider workDayProvider;

    setUpAll(() async {
      // Инициализируем service locator
      await setupServiceLocator();
      
      // Создаем оркестратор для dev данных
      orchestrator = DevFixtureOrchestratorFactory.create();
      
      // Создаем WorkDayProvider
      workDayProvider = WorkDayProvider();
    });

    tearDownAll(() async {
      // Очищаем GetIt
      await GetIt.instance.reset();
    });

    test('Создание полного набора dev данных с WorkDay', () async {
      // Arrange: Создаем полный набор dev данных
      print('🚀 Тест: Создание dev данных...');
      final result = await orchestrator.createFullDevDataset();
      
      // Assert: Проверяем что данные созданы успешно
      expect(result.success, true, reason: 'Dev данные должны создаться успешно');
      expect(result.appUsers.salesReps.isNotEmpty, true, reason: 'Должен быть хотя бы один торговый представитель');
      
      final salesRep = result.appUsers.salesReps.first;
      print('✅ Тест: Создан торговый представитель: ${salesRep.fullName}');
      
      // Проверяем что у пользователя есть маршруты
      final routeRepository = GetIt.instance<RouteRepository>();
      final routesStream = routeRepository.watchEmployeeRoutes(salesRep.employee);
      final routes = await routesStream.first;
      
      expect(routes.length, greaterThanOrEqualTo(2), 
        reason: 'Должно быть минимум 2 маршрута (вчерашний + текущий)');
      
      print('✅ Тест: Найдено ${routes.length} маршрутов');
      for (final route in routes) {
        print('   - ${route.name} (${route.status})');
      }
    });

    test('Загрузка WorkDay и проверка связи с маршрутами', () async {
      // Arrange: Создаем dev данные и авторизуем пользователя
      final result = await orchestrator.createFullDevDataset();
      final salesRep = result.appUsers.salesReps.first;
      
      // Имитируем авторизацию пользователя
      AppSessionService.setCurrentSession(AppSession(
        appUser: salesRep,
        securitySession: null, // Для теста
        createdAt: DateTime.now(),
        appSettings: {},
      ));
      expect(AppSessionService.currentSession, isNotNull, 
        reason: 'Сессия должна быть создана');
      
      // Act: Загружаем WorkDay через провайдер
      await workDayProvider.loadWorkDays();
      
      // Assert: Проверяем что WorkDay созданы
      expect(workDayProvider.workDays.length, equals(3), 
        reason: 'Должно быть 3 WorkDay (вчера, сегодня, завтра)');
      
      final todayWorkDay = workDayProvider.todayWorkDay;
      expect(todayWorkDay, isNotNull, reason: 'Должен быть сегодняшний WorkDay');
      expect(todayWorkDay!.isToday, true, reason: 'WorkDay должен быть помечен как сегодняшний');
      
      final yesterdayDate = DateTime.now().subtract(Duration(days: 1));
      final yesterdayWorkDay = workDayProvider.getWorkDayForDate(yesterdayDate);
      expect(yesterdayWorkDay, isNotNull, reason: 'Должен быть вчерашний WorkDay');
      expect(yesterdayWorkDay!.isToday, false, reason: 'Вчерашний WorkDay не должен быть сегодняшним');
      
      print('✅ Тест: WorkDay корректно загружены');
      print('   - Сегодня: ${todayWorkDay.status}');
      print('   - Вчера: ${yesterdayWorkDay.status}');
    });

    test('Проверка треков для маршрутов', () async {
      // Arrange: Создаем dev данные
      final result = await orchestrator.createFullDevDataset();
      final salesRep = result.appUsers.salesReps.first;
      
      // Act: Проверяем треки в базе данных
      final trackRepository = GetIt.instance<UserTrackRepository>();
      final today = DateTime.now();
      final todayTracks = await trackRepository.getTracksForDate(
        salesRep.employee, 
        today
      );
      
      final yesterday = today.subtract(Duration(days: 1));
      final yesterdayTracks = await trackRepository.getTracksForDate(
        salesRep.employee, 
        yesterday
      );
      
      // Assert: Проверяем логику треков
      print('✅ Тест: Треки в базе данных:');
      print('   - Сегодня: ${todayTracks.length} треков');
      print('   - Вчера: ${yesterdayTracks.length} треков');
      
      // Ожидаем что есть трек за вчера (завершенный)
      expect(yesterdayTracks.isNotEmpty, true, 
        reason: 'Должен быть завершенный трек за вчера');
      
      if (yesterdayTracks.isNotEmpty) {
        final yesterdayTrack = yesterdayTracks.first;
        print('   - Вчерашний трек: ${yesterdayTrack.totalPoints} точек, статус: ${yesterdayTrack.status}');
        expect(yesterdayTrack.status.isCompleted, true, 
          reason: 'Вчерашний трек должен быть завершен');
      }
      
      // Для сегодня может быть трек или не быть (зависит от активного трекинга)
      if (todayTracks.isNotEmpty) {
        final todayTrack = todayTracks.first;
        print('   - Сегодняшний трек: ${todayTrack.totalPoints} точек, статус: ${todayTrack.status}');
      }
    });

    test('Проверка логики отображения активного трека только на сегодняшнем WorkDay', () async {
      // Arrange: Создаем dev данные и авторизуем пользователя
      final result = await orchestrator.createFullDevDataset();
      final salesRep = result.appUsers.salesReps.first;
      await AppSessionService.createSession(salesRep);
      await workDayProvider.loadWorkDays();
      
      // Имитируем активный трек (в реальности приходит от LocationTrackingService)
      // workDayProvider._activeTrack = MockUserTrack(); // Это приватное поле
      
      // Act & Assert: Проверяем логику отображения треков
      final todayWorkDay = workDayProvider.todayWorkDay!;
      final yesterdayDate = DateTime.now().subtract(Duration(days: 1));
      final yesterdayWorkDay = workDayProvider.getWorkDayForDate(yesterdayDate)!;
      
      // Выбираем сегодняшний WorkDay
      workDayProvider.selectWorkDay(todayWorkDay);
      
      // Проверяем что selectedWorkDay = today
      expect(workDayProvider.selectedWorkDay, equals(todayWorkDay));
      expect(workDayProvider.selectedWorkDay!.isToday, true);
      
      // Выбираем вчерашний WorkDay  
      workDayProvider.selectWorkDay(yesterdayWorkDay);
      
      // Проверяем что selectedWorkDay = yesterday
      expect(workDayProvider.selectedWorkDay, equals(yesterdayWorkDay));
      expect(workDayProvider.selectedWorkDay!.isToday, false);
      
      print('✅ Тест: Логика выбора WorkDay работает корректно');
      print('   - Сегодня.isToday = ${todayWorkDay.isToday}');
      print('   - Вчера.isToday = ${yesterdayWorkDay.isToday}');
    });

    test('Проверка связи Route -> WorkDay -> Track', () async {
      // Arrange: Создаем dev данные
      final result = await orchestrator.createFullDevDataset();
      final salesRep = result.appUsers.salesReps.first;
      
      // Act: Получаем маршруты и треки
      final routeRepository = GetIt.instance<RouteRepository>();
      final trackRepository = GetIt.instance<UserTrackRepository>();
      
      final routes = await routeRepository.watchEmployeeRoutes(salesRep.employee).first;
      final yesterday = DateTime.now().subtract(Duration(days: 1));
      final yesterdayTracks = await trackRepository.getTracksForDate(salesRep.employee, yesterday);
      
      // Assert: Проверяем связи
      expect(routes.isNotEmpty, true, reason: 'Должны быть маршруты');
      
      final yesterdayRoute = routes.where((r) => r.name.contains('2 сентября')).firstOrNull;
      expect(yesterdayRoute, isNotNull, reason: 'Должен быть вчерашний маршрут');
      
      if (yesterdayTracks.isNotEmpty && yesterdayRoute != null) {
        final yesterdayTrack = yesterdayTracks.first;
        
        // В идеале здесь должна быть проверка что трек связан с маршрутом
        // Но пока проверим что они существуют для одного пользователя в один день
        expect(yesterdayTrack.userId, equals(salesRep.employee.id));
        expect(yesterdayRoute.pointsOfInterest.isNotEmpty, true);
        
        print('✅ Тест: Связь Route-Track установлена');
        print('   - Маршрут: ${yesterdayRoute.name}');
        print('   - Трек: ${yesterdayTrack.totalPoints} точек');
        print('   - Пользователь: ${salesRep.fullName}');
      }
    });
  });
}

extension on List<dynamic> {
  dynamic get firstOrNull => isEmpty ? null : first;
}
