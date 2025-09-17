import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/repositories/trading_point_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';

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
