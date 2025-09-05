import 'dart:convert';
import 'package:fieldforce/app/domain/entities/route.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track_builder.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/enums/track_status.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';

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

class TrackFixtures {
  static final UserTrackRepository _repository = GetIt.instance<UserTrackRepository>();
  // static final LocationTrackingServiceMock _trackingService = GetIt.instance<LocationTrackingServiceMock>();

  static Future<UserTrack> createTodayTrack({
    required NavigationUser user,
    required Route route,
  }) async {
      Map<String, dynamic> osrmResponse;

      final jsonString = await rootBundle.loadString('assets/data/tracks/current_day_track.json');
      osrmResponse = jsonDecode(jsonString) as Map<String, dynamic>;

      final now = DateTime.now();
      final startTime = DateTime(now.year, now.month, now.day, 9, 0);

      // Обрабатываем данные асинхронно для лучшей производительности
      final compactTrack = CompactTrackFactory.fromOSRMResponse(
        osrmResponse,
        startTime: startTime,
        baseSpeed: 45.0,
        baseAccuracy: 4.0,
      );

      final userTrack = UserTrack.fromSingleTrack(
        id: 0,
        user: user,
        track: compactTrack,
        status: TrackStatus.active
      );

      final result = await _repository.saveUserTrack(userTrack);
      
      return result.fold(
        (failure) {
          throw('❌ TrackFixtures: Ошибка сохранения трека: ${failure.message}');
        },
        (savedTrack) {
          return savedTrack;
        },
      );
  }
}