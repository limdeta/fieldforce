import 'package:fieldforce/features/authentication/domain/entities/user.dart';
import 'package:fieldforce/features/authentication/domain/value_objects/phone_number.dart';
import 'package:fieldforce/features/authentication/domain/services/password_service.dart';
import 'package:fieldforce/features/shop/domain/entities/trading_point.dart';
import 'package:fieldforce/features/shop/domain/entities/employee.dart';

/// Test data factories for creating test entities on-demand
class TestFactories {
  static const _defaultPassword = 'password123';
  
  /// Creates admin user with specified phone or default
  static Future<User> createAdminUser({
    String? externalId,
    String phoneNumber = '+79990000001',
    String password = _defaultPassword,
    String firstName = 'Admin',
    String lastName = 'User',
  }) async {
    final hashedPassword = PasswordService.hashPassword(password);
    final phone = PhoneNumber.create(phoneNumber).fold(
      (failure) => throw Exception('Invalid phone: ${failure.message}'),
      (phone) => phone,
    );
    
    return User(
      externalId: externalId ?? 'test_admin_${DateTime.now().millisecondsSinceEpoch}',
      phoneNumber: phone,
      hashedPassword: hashedPassword,
      role: UserRole.admin,
    );
  }

  /// Creates manager user with specified phone or default
  static Future<User> createManagerUser({
    String? externalId,
    String phoneNumber = '+79990000002',
    String password = _defaultPassword,
    String firstName = 'Manager',
    String lastName = 'User',
  }) async {
    final hashedPassword = PasswordService.hashPassword(password);
    final phone = PhoneNumber.create(phoneNumber).fold(
      (failure) => throw Exception('Invalid phone: ${failure.message}'),
      (phone) => phone,
    );
    
    return User(
      externalId: externalId ?? 'test_manager_${DateTime.now().millisecondsSinceEpoch}',
      phoneNumber: phone,
      hashedPassword: hashedPassword,
      role: UserRole.manager,
    );
  }

  /// Creates sales rep user with specified phone or default
  static Future<User> createSalesRepUser({
    String? externalId,
    String phoneNumber = '+79990000003',
    String password = _defaultPassword,
    String firstName = 'Sales',
    String lastName = 'Rep',
  }) async {
    final hashedPassword = PasswordService.hashPassword(password);
    final phone = PhoneNumber.create(phoneNumber).fold(
      (failure) => throw Exception('Invalid phone: ${failure.message}'),
      (phone) => phone,
    );
    
    return User(
      externalId: externalId ?? 'test_sales_${DateTime.now().millisecondsSinceEpoch}',
      phoneNumber: phone,
      hashedPassword: hashedPassword,
      role: UserRole.user, // Assuming 'user' is the sales rep role
    );
  }

  /// Creates a batch of users for testing scenarios
  static Future<List<User>> createUserBatch({
    int adminCount = 1,
    int managerCount = 1,
    int salesRepCount = 3,
  }) async {
    final users = <User>[];
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    // Create admins
    for (int i = 0; i < adminCount; i++) {
      users.add(await createAdminUser(
        externalId: 'test_admin_${timestamp}_$i',
        phoneNumber: '+7999000100${i + 1}',
      ));
    }
    
    // Create managers
    for (int i = 0; i < managerCount; i++) {
      users.add(await createManagerUser(
        externalId: 'test_manager_${timestamp}_$i',
        phoneNumber: '+7999000200${i + 1}',
      ));
    }
    
    // Create sales reps
    for (int i = 0; i < salesRepCount; i++) {
      users.add(await createSalesRepUser(
        externalId: 'test_sales_${timestamp}_$i',
        phoneNumber: '+7999000300${i + 1}',
      ));
    }
    
    return users;
  }

  /// Создает торговую точку
  static TradingPoint createTradingPoint({
    String? externalId,
    String? name,
    String? inn,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return TradingPoint(
      externalId: externalId ?? 'tp_${timestamp}_${DateTime.now().microsecond}',
      name: name ?? 'Торговая точка ${DateTime.now().microsecond}',
      inn: inn ?? timestamp.toString().substring(0, 10),
    );
  }

  /// Создает набор торговых точек
  static List<TradingPoint> createTradingPointsBatch({
    int count = 5,
    String namePrefix = 'Магазин',
  }) {
    final tradingPoints = <TradingPoint>[];
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < count; i++) {
      tradingPoints.add(TradingPoint(
        externalId: 'tp_${timestamp}_$i',
        name: '$namePrefix №${i + 1}',
        inn: '${timestamp.toString().substring(0, 8)}${i.toString().padLeft(2, '0')}',
      ));
    }
    
    return tradingPoints;
  }

  /// Создает Employee с привязанными торговыми точками
  static Employee createEmployeeWithTradingPoints({
    String? lastName,
    String? firstName,
    String? middleName,
    EmployeeRole role = EmployeeRole.sales,
    List<TradingPoint>? tradingPoints,
    int tradingPointsCount = 3,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final assignedTradingPoints = tradingPoints ?? 
        createTradingPointsBatch(count: tradingPointsCount);
    
    return Employee(
      lastName: lastName ?? 'Сотрудник',
      firstName: firstName ?? 'Тест${timestamp.toString().substring(7, 10)}',
      middleName: middleName,
      role: role,
      assignedTradingPoints: assignedTradingPoints,
    );
  }

  /// Создает связку Employee с торговыми точками по маршрутам
  /// (логика: если у сотрудника есть маршруты, торговые точки берутся из них)
  static Employee createEmployeeFromRoutePoints({
    String? lastName,
    String? firstName,
    String? middleName,
    EmployeeRole role = EmployeeRole.sales,
    required List<String> routeTradingPointIds, // ID торговых точек из маршрутов
  }) {
    // Создаем торговые точки на основе ID из маршрутов
    final tradingPoints = routeTradingPointIds.map((id) => TradingPoint(
      externalId: id,
      name: 'ТТ по маршруту ${id.substring(id.length - 3)}',
    )).toList();
    
    return Employee(
      lastName: lastName ?? 'Сотрудник',
      firstName: firstName ?? 'Тест',
      middleName: middleName,
      role: role,
      assignedTradingPoints: tradingPoints,
    );
  }

  /// Создает полный сценарий: сотрудник + торговые точки + привязка для репозитория
  static Map<String, dynamic> createEmployeeWithTradingPointsScenario({
    String? employeeLastName,
    String? employeeFirstName,
    EmployeeRole employeeRole = EmployeeRole.sales,
    int tradingPointsCount = 5,
  }) {
    // Создаем торговые точки
    final tradingPoints = createTradingPointsBatch(count: tradingPointsCount);
    
    // Создаем сотрудника
    final employee = createEmployeeWithTradingPoints(
      lastName: employeeLastName,
      firstName: employeeFirstName,
      role: employeeRole,
      tradingPoints: tradingPoints,
    );
    
    // Подготавливаем данные для репозитория
    final employeeAssignments = <int, List<String>>{
      employee.id: tradingPoints.map((tp) => tp.externalId).toList(),
    };
    
    return {
      'employee': employee,
      'tradingPoints': tradingPoints,
      'employeeAssignments': employeeAssignments,
    };
  }
}

/// Common test phone numbers that are guaranteed to be unique per test run
class TestPhones {
  static String get admin => '+7999${DateTime.now().millisecondsSinceEpoch.toString().substring(7, 10)}0001';
  static String get manager => '+7999${DateTime.now().millisecondsSinceEpoch.toString().substring(7, 10)}0002';
  static String get salesRep => '+7999${DateTime.now().millisecondsSinceEpoch.toString().substring(7, 10)}0003';
  static String get nonExistent => '+7999${DateTime.now().millisecondsSinceEpoch.toString().substring(7, 10)}9999';
}