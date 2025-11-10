import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/track_manager.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/device_orientation_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/shared/failures.dart';

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
  String? get firstName => 'Late';
  @override
  String? get lastName => 'Subscriber';

  _TestUser(this.id);

  @override
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}';
}

void main() {
  test('late subscriber should receive last saved track immediately (TDD red -> green)', () async {
    final repo = _FakeRepo();
    final manager = TrackManager(repo);
    final fakeGps = _FakeGpsDataManager();

  final realGps = GpsDataManager();
  final orientation = NoopDeviceOrientationService();
  final service = LocationTrackingService(realGps, manager, orientation,
    positionStreamProvider: (settings) => fakeGps.controller.stream);

    final user = _TestUser(999);
    final started = await service.startTracking(user);
    expect(started, isTrue);

    // push points and end stream so the service flushes and track is saved/emitted
    for (int i = 0; i < 6; i++) {
      fakeGps.controller.add(Position(
        latitude: 50.0 + i * 0.0001,
        longitude: 30.0 + i * 0.0001,
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

    // close stream to trigger onDone which should flush
    await fakeGps.controller.close();

    // Wait a short time to allow flush/save to occur
    await Future.delayed(const Duration(milliseconds: 200));

    // Now create a late subscriber: it subscribes AFTER the track was emitted
    final events = <UserTrack>[];
    final sub = service.trackUpdateStream.listen((t) {
      events.add(t);
    });

    // Expectation: late subscriber should receive the last saved track immediately.
    // Current implementation uses a bare broadcast stream so this will likely be empty -> test should fail (red)
    await Future.delayed(const Duration(milliseconds: 200));

    expect(events.isNotEmpty, true, reason: 'Late subscriber did not receive last saved track');

    await sub.cancel();
    manager.dispose();
    service.dispose();
    await orientation.dispose();
  });
}
