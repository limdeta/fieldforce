import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

abstract interface class UserRepository {
  Future<Either<Failure, User>> getUserByPhoneNumber(PhoneNumber phoneNumber);
  Future<Either<Failure, User>> createUser(User user);
  Future<Either<Failure, User>> saveUser(User user);
  Future<Either<Failure, User>> getUserByExternalId(String externalId);
  Future<Either<Failure, User>> getUserByInternalId(int internalId);
  Future<Either<Failure, List<User>>> getAllUsers();
  Future<Either<Failure, void>> deleteUser(String externalId);
  Future<Either<Failure, bool>> userExists(String externalId);
}
