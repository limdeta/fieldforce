// import 'package:flutter_test/flutter_test.dart';
// import 'package:get_it/get_it.dart';
// import 'package:fieldforce/features/authentication/domain/repositories/user_repository.dart';
// import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
// import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track_builder.dart';
// import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
// import 'package:fieldforce/features/authentication/domain/entities/user.dart' as domain;
// import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
// import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';

// void main() {
//   group('UserTrack + CompactTrack REAL Integration Tests', () {

//     test('should save UserTrack with embedded CompactTrack segments to real database', () async {
//       final phoneNumber = PhoneNumber.create('+79123456789').getOrElse(() => throw Exception());
//       final user = domain.User.create(
//         externalId: 'driver_001',
//         role: domain.UserRole.user,
//         phoneNumber: phoneNumber,
//         hashedPassword: 'secure_driver_password',
//       ).getOrElse(() => throw Exception());

//       final userRepo = GetIt.instance<UserRepository>();
//       final userResult = userRepo.createUser(user);
//       expect(userResult.isRight(), isTrue);
//       final createdUser = userResult.getOrElse(() => throw Exception());

//       final builder = CompactTrackBuilder();
      
//       final realRoute = [
//         (55.408611, 37.906111, 'Аэропорт Домодедово'),
//         (55.423056, 37.886667, 'Трасса М4'),
//         (55.447222, 37.850000, 'МКАД Южный'),
//         (55.482778, 37.816667, 'Варшавское шоссе'),
//         (55.517500, 37.783333, 'Серпуховская площадь'),
//         (55.545000, 37.750000, 'Павелецкая'),
//         (55.578333, 37.716667, 'Кремль'),
//         (55.595000, 37.700000, 'Красная площадь'),
//       ];

//       final startTime = DateTime.parse('2024-08-22 08:30:00');
      
//       for (int i = 0; i < realRoute.length; i++) {
//         final point = realRoute[i];
//         builder.addPoint(
//           latitude: point.$1,
//           longitude: point.$2,
//           timestamp: startTime.add(Duration(minutes: i * 15)), // 15 минут между точками
//           speedKmh: 45.0 + (i * 5), // Ускорение при выезде из аэропорта
//           accuracy: 3.0 + (i % 3),  // Меняющаяся точность GPS
//           bearing: (i * 22.5) % 360, // Постепенный поворот
//         );
//       }

//       final compactTrack = builder.build();

//       final userTrack = UserTrack.fromSingleTrack(
//         id: 0,
//         user: createdUser,
//         track: compactTrack,
//         metadata: {
//           'trip_type': 'airport_transfer',
//           'vehicle': 'Mercedes E-Class',
//           'driver_license': 'AB123456789',
//           'passengers': '2',
//           'route_name': 'Домодедово-Центр',
//         },
//       );

//       // UserTrackRepository должен сохранить и UserTrack и связанные CompactTrack сегменты
//       final saveResult = await GetIt.instance<UserTrackRepository>().saveUserTrack(userTrack);
      
//       expect(saveResult.isRight(), isTrue, reason: 'Сохранение должно быть успешным');
//       final savedUserTrack = saveResult.getOrElse(() => throw Exception());

//       // === ПРОВЕРКА ДАННЫХ В БД ===
//       await dbHelper.showTableStats();
      
//       final userTracksInDb = await dbHelper.database.select(dbHelper.database.userTracks).get();
//       expect(userTracksInDb.length, equals(1));
      
//       final savedUserTrackData = userTracksInDb.first;

//       final compactTracksInDb = await dbHelper.database.select(dbHelper.database.compactTracks).get();
//       expect(compactTracksInDb.length, equals(1));
      
//       final savedCompactTrackData = compactTracksInDb.first;

//       expect(savedCompactTrackData.userTrackId, equals(savedUserTrackData.id));

//       // Восстанавливаем UserTrack
//       final retrievedUserTrackResult = await dbHelper.userTrackRepository.getUserTrackById(savedUserTrackData.id);
//       expect(retrievedUserTrackResult.isRight(), isTrue);
//       final retrievedUserTrack = retrievedUserTrackResult.getOrElse(() => throw Exception());

//       // Восстанавливаем CompactTrack из бинарных данных
//       final restoredCompactTrack = CompactTrack.fromDatabase(
//         coordinatesBlob: savedCompactTrackData.coordinatesBlob,
//         timestampsBlob: savedCompactTrackData.timestampsBlob,
//         speedsBlob: savedCompactTrackData.speedsBlob,
//         accuraciesBlob: savedCompactTrackData.accuraciesBlob,
//         bearingsBlob: savedCompactTrackData.bearingsBlob,
//       );

//       // === ПРОВЕРКА ЦЕЛОСТНОСТИ ДАННЫХ ===
      
//       // Проверяем что все GPS точки восстановились корректно
//       for (int i = 0; i < realRoute.length; i++) {
//         final originalCoords = compactTrack.getCoordinates(i);
//         final restoredCoords = restoredCompactTrack.getCoordinates(i);
        
//         expect(restoredCoords.$1, closeTo(originalCoords.$1, 0.000001));
//         expect(restoredCoords.$2, closeTo(originalCoords.$2, 0.000001));
        
//         final originalTime = compactTrack.getTimestamp(i);
//         final restoredTime = restoredCompactTrack.getTimestamp(i);
//         expect(restoredTime.millisecondsSinceEpoch, equals(originalTime.millisecondsSinceEpoch));
//       }
   
//       expect(retrievedUserTrack.user.externalId, equals(createdUser.externalId));
//       expect(retrievedUserTrack.metadata?['trip_type'], equals('airport_transfer'));
//       expect(retrievedUserTrack.metadata?['vehicle'], equals('Mercedes E-Class'));
//     });

//     test('should handle multiple trips for multiple drivers in real database', () async {
      
//       final drivers = [
//         ('Петров', 'Алексей', '+79123456790', 'truck_driver'),
//         ('Сидоров', 'Михаил', '+79123456791', 'taxi_driver'),
//         ('Козлов', 'Дмитрий', '+79123456792', 'delivery_driver'),
//       ];

//       for (int driverIndex = 0; driverIndex < drivers.length; driverIndex++) {
//         final driverData = drivers[driverIndex];
        
//         // Создаем водителя
//         final phoneNumber = PhoneNumber.create(driverData.$3).getOrElse(() => throw Exception());
//         final user = domain.User.create(
//           externalId: 'driver_${driverIndex + 1}',
//           role: domain.UserRole.user,
//           phoneNumber: phoneNumber,
//           hashedPassword: 'driver_password_${driverIndex + 1}',
//         ).getOrElse(() => throw Exception());

//         final userResult = await dbHelper.userRepository.createUser(user);
//         expect(userResult.isRight(), isTrue);
//         final createdUser = userResult.getOrElse(() => throw Exception());

//         // Создаем 2 поездки для каждого водителя
//         for (int tripIndex = 0; tripIndex < 2; tripIndex++) {
//           final builder = CompactTrackBuilder();
//           final pointsCount = 30 + (driverIndex * 10) + (tripIndex * 5); // Разное количество точек
          
//           final startTime = DateTime.now().subtract(Duration(days: tripIndex + 1));
          
//           // Генерируем уникальный маршрут для каждой поездки
//           for (int i = 0; i < pointsCount; i++) {
//             builder.addPoint(
//               latitude: 55.7558 + (driverIndex * 0.01) + (tripIndex * 0.005) + (i * 0.0001),
//               longitude: 37.6173 + (driverIndex * 0.01) + (tripIndex * 0.005) + (i * 0.0001),
//               timestamp: startTime.add(Duration(minutes: i * 2)),
//               speedKmh: 25.0 + (driverIndex * 5) + (i % 25),
//               accuracy: 2.0 + (i % 4),
//               bearing: (i * 5.4) % 360,
//             );
//           }

//           final compactTrack = builder.build();
          
//           final userTrack = UserTrack.fromSingleTrack(
//             id: 0, // Будет присвоен при сохранении
//             user: createdUser,
//             track: compactTrack,
//             metadata: {
//               'driver_type': driverData.$4,
//               'trip_number': '${driverIndex + 1}_${tripIndex + 1}',
//               'vehicle_type': ['truck', 'sedan', 'van'][driverIndex],
//               'points_count': pointsCount.toString(),
//             },
//           );

//           final saveResult = await dbHelper.userTrackRepository.saveUserTrack(
//             userTrack,
//           );
          
//           expect(saveResult.isRight(), isTrue);
//         }
//       }

//       await dbHelper.showTableStats();
      
//       final totalUserTracks = await dbHelper.database.select(dbHelper.database.userTracks).get();
//       final totalCompactTracks = await dbHelper.database.select(dbHelper.database.compactTracks).get();
//       final totalUsers = await dbHelper.database.select(dbHelper.database.userEntries).get();
      
//       expect(totalUsers.length, equals(3), reason: '3 водителя');
//       expect(totalUserTracks.length, equals(6), reason: '3 водителя × 2 поездки = 6');
//       expect(totalCompactTracks.length, equals(6), reason: '6 поездок × 1 сегмент = 6');
//     });
//   });
// }
