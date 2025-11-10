import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/track_manager.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/shared/failures.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/device_orientation_service.dart';

class _FakeGpsDataManager {
  final StreamController<Position> controller = StreamController<Position>();

  Stream<Position> getPositionStream({required Object? settings}) => controller.stream;
  Future<bool> startGps() async => true;
  Future<bool> checkPermissions() async => true;
}

class _FakeRepo implements UserTrackRepository {
  UserTrack? lastSaved;

  @override
  Future<Either<Failure, UserTrack>> getUserTrackById(int id) async => Right(UserTrack.empty(id: id, user: _TestUser(id)));

  @override
  Future<Either<Failure, List<UserTrack>>> getUserTracks(NavigationUser user) async => Right([]);

  @override
  Future<Either<Failure, List<UserTrack>>> getUserTracksByDateRange(NavigationUser user, DateTime startDate, DateTime endDate) async => Right([]);

  @override
  Future<Either<Failure, UserTrack?>> getActiveUserTrack(NavigationUser user) async => Right(null);

  @override
  Future<Either<Failure, UserTrack>> saveUserTrack(UserTrack track) async {
    lastSaved = track;
    return Right(track);
  }

  @override
  Future<Either<Failure, UserTrack>> updateUserTrack(UserTrack track) async {
    lastSaved = track;
    return Right(track);
  }

  @override
  Future<Either<Failure, UserTrack>> saveOrUpdateUserTrack(UserTrack track) async {
    lastSaved = track;
    return Right(track);
  }

  @override
  Future<Either<Failure, void>> deleteUserTrack(UserTrack track) async => Right(null);
}

class _TestUser implements NavigationUser {
  @override
  final int id;
  @override
  String? get firstName => 'Bloc';
  @override
  String? get lastName => 'Lifecycle';

  _TestUser(this.id);

  @override
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}';
}

void main() {
  test('BLoC lifecycle: subscribe-unsubscribe-resubscribe receives last saved track', () async {
    final repo = _FakeRepo();
    final manager = TrackManager(repo);
    final fakeGps = _FakeGpsDataManager();

  final orientation = NoopDeviceOrientationService();
  final service = LocationTrackingService(GpsDataManager(), manager, orientation,
    positionStreamProvider: (settings) => fakeGps.controller.stream);

    final user = _TestUser(333);
    final started = await service.startTracking(user);
    expect(started, isTrue);

    // push a few positions and close stream -> service should flush and save
    for (int i = 0; i < 6; i++) {
      fakeGps.controller.add(Position(
        latitude: 60.0 + i * 0.0001,
        longitude: 10.0 + i * 0.0001,
        timestamp: DateTime.now(),
        accuracy: 5.0,
        altitude: 0.0,
        altitudeAccuracy: 10.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      ));
      await Future.delayed(const Duration(milliseconds: 5));
    }

    await fakeGps.controller.close();

    // subscribe then immediately cancel (simulating BLoC being disposed)
    final tmpEvents = <UserTrack>[];
    final tmpSub = service.trackUpdateStream.listen((t) => tmpEvents.add(t));
    await Future.delayed(const Duration(milliseconds: 100));
    await tmpSub.cancel();

    // Now re-subscribe (late subscriber)
    final events = <UserTrack>[];
    final sub = service.trackUpdateStream.listen((t) => events.add(t));

    await Future.delayed(const Duration(milliseconds: 200));

    expect(events.isNotEmpty, isTrue, reason: 'Late re-subscriber did not receive last saved track');

    await sub.cancel();
    manager.dispose();
    service.dispose();
    await orientation.dispose();
  });
}
