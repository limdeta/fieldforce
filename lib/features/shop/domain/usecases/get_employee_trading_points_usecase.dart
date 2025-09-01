import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import '../entities/trading_point.dart';
import '../entities/employee.dart';
import '../repositories/trading_point_repository.dart';

class GetEmployeeTradingPointsUseCase {
  final TradingPointRepository _repository;

  GetEmployeeTradingPointsUseCase(this._repository);

  Future<Either<Failure, List<TradingPoint>>> call(Employee employee) async {
    try {
      return await _repository.getEmployeePoints(employee);
    } catch (e) {
      return Left(DatabaseFailure('Ошибка получения торговых точек: $e'));
    }
  }

  Future<Either<Failure, List<TradingPoint>>> callWithFilter(
    Employee employee, {
    String? nameFilter,
  }) async {
    final result = await call(employee);
    
    return result.fold(
      (failure) => Left(failure),
      (tradingPoints) {
        if (nameFilter == null || nameFilter.isEmpty) {
          return Right(tradingPoints);
        }
        
        final filtered = tradingPoints.where((tp) =>
          tp.name.toLowerCase().contains(nameFilter.toLowerCase())
        ).toList();
        
        return Right(filtered);
      },
    );
  }
}
