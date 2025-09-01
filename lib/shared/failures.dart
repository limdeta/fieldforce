/// Base class for all failures in the domain layer
abstract class Failure {
  final String message;
  final Object? details; // Additional details about the failure

  const Failure(this.message, {this.details});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.details == details;
  }

  @override
  int get hashCode => Object.hash(message, details);

  @override
  String toString() => 'Failure(message: $message, details: $details)';
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.details});
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.details});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.details});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.details});
}

class EntityCreationFailure extends Failure {
  const EntityCreationFailure(super.message, {super.details});
}

class EntityUpdateFailure extends Failure {
  const EntityUpdateFailure(super.message, {super.details});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.details});
}

class GeneralFailure extends Failure {
  const GeneralFailure(super.message, {super.details});
}

