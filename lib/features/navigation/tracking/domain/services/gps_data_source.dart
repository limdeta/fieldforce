import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Абстракция источника GPS данных
/// 
/// Позволяет переключаться между реальным GPS (geolocator) и мок-данными
/// для тестирования трекинга в контролируемой среде
abstract class GpsDataSource {
  /// Стрим позиций GPS
  Stream<Position> getPositionStream({required LocationSettings settings});
  
  /// Проверка разрешений
  Future<bool> checkPermissions();
  
  /// Получить текущую позицию
  Future<Position> getCurrentPosition({required LocationSettings settings});
  
  /// Освобождение ресурсов
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
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
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
