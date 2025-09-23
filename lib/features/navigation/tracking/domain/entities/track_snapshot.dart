import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:geolocator/geolocator.dart';

/// Aggregated snapshot of tracking state to allow UI to render a single
/// coherent picture immediately on subscribe.
class TrackSnapshot {
  final UserTrack? persistedTrack; // saved segments from DB
  final CompactTrack? liveBuffer; // in-memory live buffer segment
  final Position? lastPosition; // last known position for arrow

  TrackSnapshot({this.persistedTrack, this.liveBuffer, this.lastPosition});

  bool get isEmpty => persistedTrack == null && liveBuffer == null && lastPosition == null;
}
