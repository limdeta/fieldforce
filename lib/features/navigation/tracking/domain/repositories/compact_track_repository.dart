import 'package:fieldforce/features/navigation/tracking/domain/entities/compact_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

abstract interface class CompactTrackRepository {
  Future<Either<Failure, CompactTrack>> getCompactTrackById(int id);
  Future<Either<Failure, CompactTrack>> saveCompactTrack(CompactTrack track);
  Future<Either<Failure, CompactTrack>> updateCompactTrack(CompactTrack track);
  Future<Either<Failure, void>> deleteCompactTrack(CompactTrack track);
  Future<Either<Failure, List<CompactTrack>>> getCompactTracksByUser(NavigationUser user);
  Future<Either<Failure, List<CompactTrack>>> getCompactTracksByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
}
