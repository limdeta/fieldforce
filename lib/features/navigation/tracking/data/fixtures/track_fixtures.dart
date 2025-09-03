import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/app/services/app_session_service.dart';
import '../../../../shop/domain/entities/route.dart';
import '../../domain/entities/user_track.dart';
import '../../domain/entities/compact_track_builder.dart';
import '../../domain/enums/track_status.dart';
import '../../domain/repositories/user_track_repository.dart';
import '../../../../../app/services/location_tracking_service.dart';

/// Простая конфигурация для GPS тестирования
class GpsTestConfig {
  final String mockDataPath;
  final double speedMultiplier;
  final bool addGpsNoise;
  final double baseAccuracy;
  final double startProgress;

  const GpsTestConfig({
    required this.mockDataPath,
    this.speedMultiplier = 1.0,
    this.addGpsNoise = true,
    this.baseAccuracy = 5.0,
    this.startProgress = 0.0,
  });
}

/// Фикстуры для создания тестовых GPS треков
/// 
/// Использует реальные GPS данные из current_day_track.json (OSRM маршрут)
/// для создания активного трека текущего дня, связанного с конкретным маршрутом.
/// 
/// Поддерживает:
/// - Историческое воспроизведение данных
/// - Активный трекинг с мок GPS данными
/// - Переключение между реальным и мок GPS
class TrackFixtures {
  static final UserTrackRepository _repository = GetIt.instance<UserTrackRepository>();
  static final LocationTrackingService _trackingService = GetIt.instance<LocationTrackingService>();
  
  // Кэш для GPS данных
  static Map<String, dynamic>? _cachedOsrmData;
  static String? _cachedDataKey;

  /// Создает активный трек для текущего дня из реального OSRM маршрута
  /// Связывает трек с конкретным маршрутом для полной интеграции данных
  static Future<UserTrack?> createCurrentDayTrack({
    required NavigationUser user,
    required Route route,
  }) async {
    try {
      // Кэширование GPS данных для избежания повторной загрузки
      const dataKey = 'current_day_track';
      Map<String, dynamic> osrmResponse;
      
      if (_cachedOsrmData != null && _cachedDataKey == dataKey) {
        osrmResponse = _cachedOsrmData!;
      } else {
        final jsonString = await rootBundle.loadString('assets/data/tracks/current_day_track.json');
        osrmResponse = jsonDecode(jsonString) as Map<String, dynamic>;
        
        _cachedOsrmData = osrmResponse;
        _cachedDataKey = dataKey;
      }

      final now = DateTime.now();
      final startTime = DateTime(now.year, now.month, now.day, 9, 0);

      // Обрабатываем данные асинхронно для лучшей производительности
      final compactTrack = CompactTrackFactory.fromOSRMResponse(
        osrmResponse,
        startTime: startTime,
        baseSpeed: 45.0, // Базовая скорость движения
        baseAccuracy: 4.0, // GPS точность
      );

      if (compactTrack.isEmpty) {
        print('❌ TrackFixtures: CompactTrack пустой после создания');
        return null;
      }

      final userTrack = UserTrack.fromSingleTrack(
        id: 0,
        user: user,
        track: compactTrack,
        status: TrackStatus.completed, // ИЗМЕНЕНО: пройденная часть помечается как завершенная
        metadata: {
          'type': 'completed_part_of_today_route', // ИЗМЕНЕНО: уточненный тип
          'created_at': startTime.toIso8601String(),
          'route_id': route.id?.toString() ?? 'unknown',
          'route_name': route.name,
          'data_source': 'osrm_real_route',
          'total_coordinates': compactTrack.pointCount.toString(),
          'distance_km': (compactTrack.getTotalDistance() / 1000).toStringAsFixed(2),
          'duration_minutes': compactTrack.getDuration().inMinutes.toString(),
          'current_status': 'completed_part', // ИЗМЕНЕНО: статус пройденной части
          'route_points_total': route.pointsOfInterest.length.toString(),
          'route_points_completed': route.pointsOfInterest.where((p) => p.status.name == 'completed').length.toString(),
          'estimated_completion': DateTime(now.year, now.month, now.day, 17, 30).toIso8601String(),
        },
      );

      final result = await _repository.saveUserTrack(userTrack);
      
      return result.fold(
        (failure) {
          print('❌ TrackFixtures: Ошибка сохранения трека: ${failure.message}');
          return null;
        },
        (savedTrack) {
          print('✅ TrackFixtures: Трек успешно сохранен с ID: ${savedTrack.id}');
          return savedTrack;
        },
      );

    } catch (e) {
      print('❌ TrackFixtures: Исключение при создании трека: $e');
      return null;
    }
  }

  /// Создает тестовые треки для пользователя
  /// Привязывает активный трек к сегодняшнему маршруту пользователя
  static Future<UserTrack?> createTestTracksForUser({
    required NavigationUser user,
    required List<Route> routes,
  }) async {
    if (routes.isEmpty) return null;

    // Ищем активный маршрут (сегодняшний)
    final todayRoute = routes.firstWhere(
      (route) => route.status.name == 'active',
      orElse: () => routes.first,
    );

    // Создаем активный трек для сегодняшнего маршрута с реальными GPS данными
    return await createCurrentDayTrack(
      user: user,
      route: todayRoute,
    );
  }

  // ============================================================================
  // МЕТОДЫ ДЛЯ АКТИВНОГО ТРЕКИНГА И ТЕСТИРОВАНИЯ
  // ============================================================================

  /// Запускает активный трекинг с использованием мок GPS данных
  /// 
  /// Эта функция:
  /// 1. Создает исторический трек
  /// 2. Переключает GPS на мок режим
  /// 3. Запускает активный трекинг, который будет продолжать движение
  static Future<UserTrack?> startActiveMockTracking({
    required NavigationUser user,
    required Route route,
    GpsTestConfig? config,
  }) async {
    try {
      // 1. Создаем базовый исторический трек
      final historicalTrack = await createCurrentDayTrack(
        user: user,
        route: route,
      );
      
      if (historicalTrack == null) {
        print('❌ TrackFixtures: Не удалось создать исторический трек');
        return null;
      }

      // 2. Настраиваем мок GPS с продолжением маршрута
      final testConfigMap = <String, dynamic>{
        'mockDataPath': config?.mockDataPath ?? 'assets/data/tracks/continuation_scenario.json',
        'speedMultiplier': config?.speedMultiplier ?? 1.5,
        'addGpsNoise': config?.addGpsNoise ?? true,
        'baseAccuracy': config?.baseAccuracy ?? 4.0,
        'startProgress': config?.startProgress ?? 0.7, // Начинаем с 70% маршрута
      };

      // 3. Переключаем трекинг сервис на мок режим
      await _trackingService.enableTestMode(config: testConfigMap);

      // 4. Запускаем активный трекинг
      final trackingStarted = await _trackingService.startTracking();

      if (!trackingStarted) {
        print('❌ TrackFixtures: Не удалось запустить активный трекинг');
        return historicalTrack;
      }

      print('✅ TrackFixtures: Активный мок трекинг запущен');
      print('📍 GPS режим: ${_trackingService.getGpsInfo()}');
      
      return historicalTrack;

    } catch (e) {
      print('❌ TrackFixtures: Ошибка запуска активного трекинга: $e');
      return null;
    }
  }

  /// Запускает демо режим (быстрое воспроизведение для презентации)
  static Future<bool> startDemoMode({
    required NavigationUser user,
    required Route route,
  }) async {
    try {
      // Переключаем на демо режим (быстрое воспроизведение)
      await _trackingService.enableDemoMode();

      // Запускаем трекинг
      final started = await _trackingService.startTracking();

      if (started) {
        print('🎬 TrackFixtures: Демо режим запущен');
        print('⚡ Быстрое воспроизведение GPS данных активно');
      }

      return started;
    } catch (e) {
      print('❌ TrackFixtures: Ошибка запуска демо режима: $e');
      return false;
    }
  }

  /// Продолжает существующий дневной трек или создает новый
  static Future<bool> continueOrStartTodaysTrack({required String routeId}) async {
    try {
      print('📅 TrackFixtures: Проверка дневного трека...');
      
      // ИСПРАВЛЕНИЕ 4: Сначала проверяем есть ли уже активный GPS трек
      if (_trackingService.isTracking) {
        print('✅ TrackFixtures: GPS трекинг уже активен - ничего не делаем');
        print('📊 Активный трек: ${_trackingService.currentTrack?.totalPoints ?? 0} точек');
        return true;
      }
      
      final user = await _getCurrentUser();
      if (user == null) {
        print('❌ TrackFixtures: Пользователь не найден');
        return false;
      }

      // 🎯 НОВАЯ ЛОГИКА: Используем autoStartTracking который сам найдет и продолжит трек
      print('🎯 TrackFixtures: Запускаем autoStartTracking для единого трека с route_id: $routeId');
      final success = await _trackingService.autoStartTracking(routeId: routeId);
      
      if (success) {
        print('✅ TrackFixtures: GPS трекинг запущен (единый трек)');
        print('� Активный трек ID: ${_trackingService.currentTrack?.id}');
        print('📊 Точек в треке: ${_trackingService.currentTrack?.totalPoints ?? 0}');
        return true;
      } else {
        print('❌ TrackFixtures: Не удалось запустить GPS трекинг');
        return false;
      }
      
    } catch (e) {
      print('❌ TrackFixtures: Ошибка продолжения дневного трека: $e');
      return false;
    }
  }

  /// Получает текущего пользователя из сессии
  static Future<NavigationUser?> _getCurrentUser() async {
    try {
      final sessionResult = await AppSessionService.getCurrentAppSession();
      return sessionResult.fold(
        (failure) {
          print('❌ TrackFixtures: Ошибка получения сессии: $failure');
          return null;
        },
        (session) => session?.appUser,
      );
    } catch (e) {
      print('❌ TrackFixtures: Ошибка получения пользователя: $e');
      return null;
    }
  }

  /// Останавливает активный трекинг и возвращает к реальному GPS
  static Future<void> stopMockTracking() async {
    try {
      // Останавливаем текущий трекинг
      await _trackingService.stopTracking();
      
      // Переключаемся обратно на реальный GPS
      await _trackingService.enableRealGps();
      
      print('🌍 TrackFixtures: Переключен обратно на реальный GPS');
    } catch (e) {
      print('❌ TrackFixtures: Ошибка остановки мок трекинга: $e');
    }
  }

  /// Получает информацию о текущем состоянии трекинга
  static Map<String, dynamic> getTrackingInfo() {
    final gpsInfo = _trackingService.getGpsInfo();
    final playbackInfo = _trackingService.getMockPlaybackInfo();
    
    return {
      'gps_info': gpsInfo,
      'playback_info': playbackInfo,
      'is_tracking': _trackingService.isTracking,
      'is_active': _trackingService.isActive,
      'current_track': _trackingService.currentTrack?.id,
    };
  }
}