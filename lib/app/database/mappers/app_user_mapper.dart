import 'package:fieldforce/app/domain/entities/app_user.dart';
import 'package:fieldforce/app/database/app_database.dart' as db;
import 'package:fieldforce/features/shop/domain/entities/employee.dart';
import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:drift/drift.dart';

class AppUserMapper {
  static AppUser fromComponents({
    required Employee employee,
    required User authUser,
    TradingPoint? selectedTradingPoint,
  }) {
    return AppUser(
      employee: employee,
      authUser: authUser,
      selectedTradingPoint: selectedTradingPoint,
    );
  }

  static db.AppUsersCompanion toDb({
    required int employeeId,
    required int userId,
    int? selectedTradingPointId,
  }) {
    return db.AppUsersCompanion(
      employeeId: Value(employeeId),
      userId: Value(userId),
      selectedTradingPointId: selectedTradingPointId != null 
        ? Value(selectedTradingPointId) 
        : const Value.absent(),
    );
  }

  static AppUser fromDbWithComponents({
    required db.AppUserData appUserData,
    required Employee employee,
    required User authUser,
    TradingPoint? selectedTradingPoint,
  }) {
    return AppUser(
      employee: employee,
      authUser: authUser,
      selectedTradingPoint: selectedTradingPoint,
    );
  }
}
