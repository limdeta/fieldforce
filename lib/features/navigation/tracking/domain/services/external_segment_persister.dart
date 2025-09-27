import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:logging/logging.dart';

/// Abstraction for persisting externally-provided CompactTrack segments.
///
/// Implementations should be side-effect free beyond appending segments to
/// the provided [currentTrack] and persisting via the repository. This allows
/// injecting a mock implementation in tests.
abstract class ExternalSegmentPersister {
  Future<bool> persistExternalSegments(UserTrack currentTrack, List<CompactTrack> segments, {int allowedBackfillSeconds = 30});
}

class DefaultExternalSegmentPersister implements ExternalSegmentPersister {
  static final Logger _logger = Logger('DefaultExternalSegmentPersister');
  final UserTrackRepository _repository;

  DefaultExternalSegmentPersister(this._repository);

  @override
  Future<bool> persistExternalSegments(UserTrack currentTrack, List<CompactTrack> segments, {int allowedBackfillSeconds = 30}) async {
    if (segments.isEmpty) return true;
    // Compute last saved timestamp for currentTrack
    int lastSavedMs = 0;
    try {
      if (currentTrack.endTime != null) {
        lastSavedMs = currentTrack.endTime!.millisecondsSinceEpoch;
      } else if (currentTrack.segments.isNotEmpty) {
        final lastSeg = currentTrack.segments.last;
        if (lastSeg.pointCount > 0) {
          lastSavedMs = lastSeg.getTimestamp(lastSeg.pointCount - 1).millisecondsSinceEpoch;
        }
      } else {
        lastSavedMs = currentTrack.startTime.millisecondsSinceEpoch;
      }
    } catch (e, st) {
      _logger.warning('Failed to compute lastSavedMs', e, st);
      lastSavedMs = currentTrack.startTime.millisecondsSinceEpoch;
    }

    try {
      for (final seg in segments) {
        if (seg.isEmpty) continue;

        final segStartMs = seg.getTimestamp(0).millisecondsSinceEpoch;
        if (segStartMs + (allowedBackfillSeconds * 1000) < lastSavedMs) {
          _logger.info('Dropping external segment starting at ${DateTime.fromMillisecondsSinceEpoch(segStartMs)} because it is older than lastSaved ($lastSavedMs)');
          continue;
        }

        // Append and persist
        currentTrack.segments.add(seg);
        final result = await _repository.saveOrUpdateUserTrack(currentTrack);
        if (result.isRight()) {
          _logger.info('Persisted external segment with ${seg.pointCount} points');
          lastSavedMs = currentTrack.endTime?.millisecondsSinceEpoch ?? lastSavedMs;
        } else {
          // Log failure reason for diagnostics
          final leftMsg = result.fold((l) => l.toString(), (r) => '');
          _logger.severe('Failed to persist external segment: $leftMsg');
          // Also print to stdout during tests for visibility
          return false;
        }
      }

      return true;
    } catch (e, st) {
      _logger.severe('Exception while persisting external segments', e, st);
      return false;
    }
  }
}
