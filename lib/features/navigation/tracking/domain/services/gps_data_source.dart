import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Абстракция источника GPS данных
/// 
/// Позволяет переключаться между реальным GPS (geolocator) и мок-данными
/// для тестирования трекинга в контролируемой среде
abstract class GpsDataSource {
  /// Стрим позиций GPS
  Stream<Position> getPositionStream({required LocationSettings settings});
  Future<bool> checkPermissions();
  Future<Position> getCurrentPosition({required LocationSettings settings});
  Future<void> dispose();
}

/// Реальный источник GPS данных через geolocator
class RealGpsDataSource implements GpsDataSource {
  @override
  Stream<Position> getPositionStream({required LocationSettings settings}) {
    return Geolocator.getPositionStream(locationSettings: settings);
  }
  
  @override
  Future<bool> checkPermissions() async {
    try {
      print('🔐 RealGpsDataSource: checkPermissions() start');
      // Protect against platform hangups with a short timeout
      LocationPermission permission = await Geolocator
          .checkPermission()
          .timeout(const Duration(seconds: 5));

      if (permission == LocationPermission.denied) {
        print('🔐 RealGpsDataSource: requesting permission...');
        permission = await Geolocator
            .requestPermission()
            .timeout(const Duration(seconds: 10));
        print('🔐 RealGpsDataSource: request result = $permission');
      }
      
      return permission == LocationPermission.whileInUse || 
             permission == LocationPermission.always;
    } catch (e) {
      return false;
    }
  }
  
  @override
  Future<Position> getCurrentPosition({required LocationSettings settings}) {
    return Geolocator.getCurrentPosition(
      desiredAccuracy: settings.accuracy,
    );
  }
  
  @override
  Future<void> dispose() async {
    // Реальный GPS не требует особого освобождения ресурсов
  }
}
