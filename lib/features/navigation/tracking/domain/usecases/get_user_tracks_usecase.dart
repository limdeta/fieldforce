import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';

import '../../domain/entities/user_track.dart';
import '../../domain/repositories/user_track_repository.dart';
import '../../../../../shared/either.dart';
import '../../../../../shared/failures.dart';

/// Use case для получения и фильтрации треков пользователя
class GetUserTracksUseCase {
  final UserTrackRepository _repository;
  
  const GetUserTracksUseCase(this._repository);
  
  /// Получает все треки пользователя
  Future<Either<Failure, List<UserTrack>>> call(NavigationUser user) async {
    return await _repository.getUserTracks(user);
  }
  
  /// TODO вынести Получает треки для конкретного маршрута
  // Future<Either<Failure, List<UserTrack>>> getTracksForRoute(NavigationUser user, int routeId) async {
  //   final result = await _repository.getUserTracks(user);
    
  //   return result.fold(
  //     (failure) => Left(failure),
  //     (tracks) => Right(tracks.where((track) => track.route?.id == routeId).toList())
  //   );
  // }
  
  /// Получает только активный трек пользователя
  Future<Either<Failure, UserTrack?>> getActiveTrack(NavigationUser user) async {
    final result = await _repository.getUserTracks(user);
    
    return result.fold(
      (failure) => Left(failure),
      (tracks) => Right(tracks.where((track) => track.status.isActive).firstOrNull)
    );
  }
}
