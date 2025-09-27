import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track_builder.dart';
import 'package:fieldforce/features/navigation/tracking/domain/services/track_manager.dart';
import 'package:fieldforce/app/fixtures/user_fixture.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import '../../helpers/global_test_manager.dart';

void main() {
  setUpAll(() async {
    await GlobalTestManager.initialize();
  });

  tearDownAll(() async {
    await GlobalTestManager.cleanup();
  });

  test('E2E: persistExternalSegments appends segments and repository reflects them', () async {
    final getIt = GetIt.instance;

    // Ensure a clean database for this E2E test (avoid leftover users from other tests)
    await GlobalTestManager.instance.clearDatabase();

    // Arrange: create a concrete Employee (NavigationUser) and start tracking using fixtures
    final trackManager = getIt<TrackManager>();
    final repo = getIt<UserTrackRepository>();

    final userFixture = getIt<UserFixture>();
    final appUser = await userFixture.getBasicUser(userData: userFixture.saddam);
    final user = appUser.employee;

    final started = await trackManager.startTracking(user: user);
    expect(started, true);

  // intentionally not using current here; kept for potential debug use

    // Build two small segments with CompactTrackBuilder
    final b1 = CompactTrackBuilder();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    b1.addPoint(latitude: 10.0, longitude: 20.0, timestamp: DateTime.fromMillisecondsSinceEpoch(nowMs - 5000));
    b1.addPoint(latitude: 10.1, longitude: 20.1, timestamp: DateTime.fromMillisecondsSinceEpoch(nowMs - 3000));

    final b2 = CompactTrackBuilder();
    b2.addPoint(latitude: 10.2, longitude: 20.2, timestamp: DateTime.fromMillisecondsSinceEpoch(nowMs - 1000));

    final success = await trackManager.persistExternalSegments([b1.build(), b2.build()], allowedBackfillSeconds: 60);
    if (!success) {
      if (trackManager.currentTrackForUI != null) {
        // Attempt to save directly for diagnostics (no prints)
        await repo.saveOrUpdateUserTrack(trackManager.currentTrackForUI!);
      }
    }
    expect(success, true);

    // Verify repository has one active track for the user and segments persisted
    final tracksRes = await repo.getUserTracks(user);
    expect(tracksRes.isRight(), true);
    final tracks = tracksRes.getOrElse(() => []);
    expect(tracks.length, greaterThanOrEqualTo(1));

    // Find today track and assert it has at least 2 segments
    final today = DateTime.now();
    final dayStart = DateTime(today.year, today.month, today.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final byDate = await repo.getUserTracksByDateRange(user, dayStart, dayEnd);
    expect(byDate.isRight(), true);
    final dayTracks = byDate.getOrElse(() => []);
    expect(dayTracks, isNotEmpty);
    final track = dayTracks.first;
    expect(track.segments.length, greaterThanOrEqualTo(2));
  });
}
