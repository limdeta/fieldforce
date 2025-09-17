import 'package:fieldforce/shared/either.dart';
import 'package:fieldforce/shared/failures.dart';
import '../entities/trading_point.dart';
import '../entities/employee.dart';

/// Репозиторий для работы с торговыми точками
abstract class TradingPointRepository {
  Future<Either<Failure, List<TradingPoint>>> getEmployeePoints(Employee employee);
  Future<Either<Failure, TradingPoint?>> getById(int id);
  Future<Either<Failure, TradingPoint?>> getByExternalId(String externalId);
  Future<Either<Failure, TradingPoint>> save(TradingPoint tradingPoint);
  Future<Either<Failure, void>> assignToEmployee(
    TradingPoint tradingPoint, 
    Employee employee
  );
  Future<Either<Failure, void>> unassignFromEmployee(
    TradingPoint tradingPoint, 
    Employee employee
  );
  Future<Either<Failure, List<TradingPoint>>> getAll();
  Future<Either<Failure, List<TradingPoint>>> searchByName(String query);
}
