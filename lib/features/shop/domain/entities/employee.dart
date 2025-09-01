
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
  String? lastName;
  @override
  String? firstName;
  String? middleName;
  EmployeeRole role;
  List<TradingPoint> assignedTradingPoints;

  Employee({
    int? id,
    required this.lastName,
    required this.firstName,
    this.middleName,
    required this.role,
    List<TradingPoint>? assignedTradingPoints,
  }) : _id = id,
       assignedTradingPoints = assignedTradingPoints ?? [];

  @override
  int get id => _id ?? 0; // Возвращаем 0 если id еще не присвоен

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
    
