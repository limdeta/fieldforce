/// Simple Either implementation for error handling
/// Left represents failure, Right represents success
abstract class Either<L, R> {
  const Either();
  
  bool isLeft();
  bool isRight();
  
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn);
  
  R getOrElse(R Function() defaultValue);
}

class Left<L, R> extends Either<L, R> {
  final L value;
  
  const Left(this.value);
  
  @override
  bool isLeft() => true;
  
  @override
  bool isRight() => false;
  
  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    return leftFn(value);
  }
  
  @override
  R getOrElse(R Function() defaultValue) {
    return defaultValue();
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Left<L, R> && other.value == value;
  }
  
  @override
  int get hashCode => value.hashCode;
}

class Right<L, R> extends Either<L, R> {
  final R value;
  
  const Right(this.value);
  
  @override
  bool isLeft() => false;
  
  @override
  bool isRight() => true;
  
  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    return rightFn(value);
  }
  
  @override
  R getOrElse(R Function() defaultValue) {
    return value;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Right<L, R> && other.value == value;
  }
  
  @override
  int get hashCode => value.hashCode;
}

Future<T> unwrapOrThrow<T, F>(Future<Either<F, T>> future, String errorPrefix) async {
  final result = await future;
  return result.fold(
        (failure) => throw Exception('$errorPrefix: ${failure.toString()}'),
        (value) => value,
  );
}
