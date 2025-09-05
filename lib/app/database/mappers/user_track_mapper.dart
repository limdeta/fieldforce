import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/enums/track_status.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/app/database/app_database.dart';

class UserTrackMapper {
  /// Преобразует UserTrack из базы данных в доменную модель
  static UserTrack fromDb({
    required UserTrackData userTrackData,
    required NavigationUser user,
    required List<CompactTrack> segments,
  }) {
    return UserTrack(
      id: userTrackData.id,
      user: user,
      status: _parseTrackStatus(userTrackData.status),
      startTime: userTrackData.startTime,
      endTime: userTrackData.endTime,
      segments: segments,
      totalPoints: userTrackData.totalPoints,
      totalDistanceKm: userTrackData.totalDistanceKm,
      totalDuration: Duration(seconds: userTrackData.totalDurationSeconds),
      metadata: _parseMetadata(userTrackData.metadata),
    );
  }

  /// Преобразует UserTrack в Companion для вставки/обновления в базе
  static UserTracksCompanion toCompanion(UserTrack userTrack, int userId) {
    return UserTracksCompanion.insert(
      userId: userId,
      startTime: userTrack.startTime,
      status: userTrack.status.name,
      totalPoints: Value(userTrack.totalPoints),
      totalDistanceKm: Value(userTrack.totalDistanceKm),
      totalDurationSeconds: Value(userTrack.totalDuration.inSeconds),
      endTime: Value(userTrack.endTime),
      metadata: Value(_encodeMetadata(userTrack.metadata)),
    );
  }

  /// Преобразует CompactTrack в Companion для вставки
  static CompactTracksCompanion compactTrackToCompanion(
    CompactTrack compactTrack,
    int userTrackId,
    int segmentOrder,
  ) {
    return CompactTracksCompanion.insert(
      userTrackId: userTrackId,
      segmentOrder: segmentOrder,
      coordinatesBlob: compactTrack.serializeCoordinates(),
      timestampsBlob: compactTrack.serializeTimestamps(),
      speedsBlob: compactTrack.serializeSpeeds(),
      accuraciesBlob: compactTrack.serializeAccuracies(),
      bearingsBlob: compactTrack.serializeBearings(),
    );
  }

  /// Преобразует данные CompactTrack из базы в доменную модель
  static CompactTrack compactTrackFromDb(CompactTrackData data) {
    return CompactTrack.fromDatabase(
      coordinatesBlob: data.coordinatesBlob,
      timestampsBlob: data.timestampsBlob,
      speedsBlob: data.speedsBlob,
      accuraciesBlob: data.accuraciesBlob,
      bearingsBlob: data.bearingsBlob,
    );
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================

  static TrackStatus _parseTrackStatus(String status) {
    return TrackStatus.values.firstWhere(
      (s) => s.name == status,
      orElse: () => TrackStatus.completed,
    );
  }

  static Map<String, dynamic>? _parseMetadata(String? metadata) {
    if (metadata == null || metadata.isEmpty) return null;
    try {
      return jsonDecode(metadata) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static String? _encodeMetadata(Map<String, dynamic>? metadata) {
    if (metadata == null || metadata.isEmpty) return null;
    try {
      return jsonEncode(metadata);
    } catch (e) {
      return null;
    }
  }
}
