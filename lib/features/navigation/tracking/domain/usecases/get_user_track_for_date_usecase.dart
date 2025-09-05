import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/navigation/tracking/domain/entities/user_track.dart';
import 'package:fieldforce/features/navigation/tracking/domain/repositories/user_track_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

class GetUserTrackForDateUseCase {
  final UserTrackRepository userTrackRepository;
  const GetUserTrackForDateUseCase({
    required this.userTrackRepository
  });

  /// Получает один трек пользователя за конкретную дату
  Future<Either<Failure, UserTrack?>> call(NavigationUser user, DateTime date) async {
    final result = await userTrackRepository.getUserTracks(user);
    return result.fold(
      (failure) => Left(failure),
      (tracks) {
        final targetDate = DateTime(date.year, date.month, date.day);
        final track = tracks.firstWhere(
          (track) {
            final trackDate = DateTime(
              track.startTime.year,
              track.startTime.month,
              track.startTime.day,
            );
            return trackDate.isAtSameMomentAs(targetDate);
          }
        );
        return Right(track);
      },
    );
  }
}

