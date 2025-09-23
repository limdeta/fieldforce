import 'dart:async';

import 'package:fieldforce/features/navigation/tracking/domain/services/gps_data_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/location_tracking_service.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/track_manager.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/shared/failures.dart';

// Minimal fake GpsDataManager for tests
class _FakeGpsDataManager {
  final StreamController<Position> controller = StreamController<Position>();

  Stream<Position> getPositionStream({required settings}) => controller.stream;
  Future<bool> startGps() async => true;
  Future<bool> checkPermissions() async => true;
  void dispose() => controller.close();
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
  String? get firstName => 'Test';
  @override
  String? get lastName => 'User';

  _TestUser(this.id);

  @override
  String get fullName => '${firstName ?? ''} ${lastName ?? ''}';
}

void main() {
  test('LocationTrackingService flushes buffer on gps stream done', () async {
    final repo = _FakeRepo();
    final manager = TrackManager(repo);
    final fakeGps = _FakeGpsDataManager();

  // Inject the fake GPS stream via the optional positionStreamProvider
  // Pass the real GpsDataManager singleton but inject our fake stream
  final realGps = GpsDataManager();
  final service = LocationTrackingService(realGps, manager,
    positionStreamProvider: (settings) => fakeGps.controller.stream);

    final user = _TestUser(77);
    final started = await service.startTracking(user);
    expect(started, isTrue);

    // push a few positions
    for (int i = 0; i < 6; i++) {
      fakeGps.controller.add(Position(
        latitude: 10.0 + i * 0.0001,
        longitude: 20.0 + i * 0.0001,
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

    final completer = Completer<UserTrack>();
    final sub = manager.trackUpdateStream.listen((t) {
      if (!completer.isCompleted) completer.complete(t);
    });

    // close the gps stream to trigger onDone
    await fakeGps.controller.close();

    final emitted = await completer.future.timeout(const Duration(seconds: 2));
    expect(emitted, isNotNull);
    expect(repo.lastSaved, isNotNull);
    expect(repo.lastSaved!.segments.isNotEmpty, isTrue);

    await sub.cancel();
    manager.dispose();
    service.dispose();
  });
}
