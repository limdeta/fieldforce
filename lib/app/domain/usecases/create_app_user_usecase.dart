import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/app/domain/repositories/app_user_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

class CreateAppUserUseCase {
  final AppUserRepository _repository;

  CreateAppUserUseCase(this._repository);

  Future<Either<Failure, AppUser>> call({
    required Employee employee,
    required User user,
  }) async {
    final existsResult = await _repository.appUserExists(employee.id);
    final exists = existsResult.fold((l) => false, (r) => r);
    if (exists) {
      return Left(EntityCreationFailure('AppUser для сотрудника уже существует'));
    }
    return await _repository.createAppUser(employee, user);
  }
}

