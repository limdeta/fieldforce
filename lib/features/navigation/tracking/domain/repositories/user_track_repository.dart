import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';

import '../../../../../shared/either.dart';
import '../../../../../shared/failures.dart';

abstract interface class UserTrackRepository {
  Future<Either<Failure, UserTrack>> getUserTrackById(int id);
  
  Future<Either<Failure, List<UserTrack>>> getUserTracks(NavigationUser user);
  
  Future<Either<Failure, List<UserTrack>>> getUserTracksByDateRange(
    NavigationUser user,
    DateTime startDate,
    DateTime endDate,
  );
  
  Future<Either<Failure, UserTrack?>> getActiveUserTrack(NavigationUser user);
  
  Future<Either<Failure, UserTrack>> saveUserTrack(UserTrack track);
  
  Future<Either<Failure, UserTrack>> updateUserTrack(UserTrack track);
  
  Future<Either<Failure, void>> deleteUserTrack(UserTrack track);
  
  // Future<Either<Failure, List<UserTrack>>> getTracksByRoute(Route route);
}
