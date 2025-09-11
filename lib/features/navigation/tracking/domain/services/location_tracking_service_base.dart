import 'package:geolocator/geolocator.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'dart:async';

abstract class LocationTrackingServiceBase {
  Future<bool> startTracking(NavigationUser user);
  Future<bool> stopTracking();
  Future<bool> pauseTracking();
  Future<bool> resumeTracking();
  Future<bool> autoStartTracking({required NavigationUser user});
  bool get isTracking;
  UserTrack? get currentTrack;
  Stream<UserTrack> get trackUpdateStream;
  Stream<CompactTrack>? get liveBufferStream;
  Stream<Position>? get positionStream;
}
