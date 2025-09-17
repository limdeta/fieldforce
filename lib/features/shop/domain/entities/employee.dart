
import 'package:fieldforce/features/navigation/tracking/domain/entities/navigation_user.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';

enum EmployeeRole{
  sales,
  supervisor,
  manager,
}

class Employee implements NavigationUser {
  final int? _id;
  @override
  final String? lastName;
  @override
  final String? firstName;
  final String? middleName;
  final EmployeeRole role;
  final List<TradingPoint> assignedTradingPoints;

  const Employee({
    int? id,
    required this.lastName,
    required this.firstName,
    this.middleName,
    required this.role,
    List<TradingPoint>? assignedTradingPoints,
  }) : _id = id,
       assignedTradingPoints = assignedTradingPoints ?? const [];

  @override
  int get id {
    if (_id == null || _id <= 0) {
      throw StateError('КРИТИЧЕСКАЯ ОШИБКА: Employee.id не может быть null или <= 0. Employee: $firstName $lastName');
    }
    return _id;
  }

  @override
  String get fullName => middleName != null
      ? '$lastName $firstName $middleName'
      : '$lastName $firstName';

  String get shortName {
    final firstInitial = firstName?.isNotEmpty == true ? firstName![0] : '';
    final middleInitial = middleName?.isNotEmpty == true ? middleName![0] : '';
    return middleInitial.isNotEmpty
        ? '$lastName $firstInitial.$middleInitial.'
        : '$lastName $firstInitial.';
  }

  void assignTradingPoint(TradingPoint tradingPoint) {
    if (!assignedTradingPoints.any((tp) => tp.externalId == tradingPoint.externalId)) {
      assignedTradingPoints.add(tradingPoint);
    }
  }

  void unassignTradingPoint(TradingPoint tradingPoint) {
    assignedTradingPoints.removeWhere((tp) => tp.externalId == tradingPoint.externalId);
  }

  bool hasTradingPoint(TradingPoint tradingPoint) {
    return assignedTradingPoints.any((tp) => tp.externalId == tradingPoint.externalId);
  }

  Employee copyWithTradingPoints(List<TradingPoint> tradingPoints) {
    return Employee(
      id: _id,
      lastName: lastName,
      firstName: firstName,
      middleName: middleName,
      role: role,
      assignedTradingPoints: List.from(tradingPoints),
    );
  }
}
    
