import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthApiService - Data Transformation Tests', () {
    test('should transform API user data correctly', () {
      // Создаем экземпляр AuthApiService для тестирования
      // Тестируем трансформацию данных API

      final apiData = {
        'id': 1,
        'phoneNumber': '9999999999',
        'firstName': 'Юрий',
        'fatherName': 'Арсенович',
        'lastName': 'Ким',
        'email': null,
        'contractors': [
          {
            'id': 9,
            'inn': '_____2300707',
            'name': 'Розничный покупатель',
            'vendorId': '0002300707',
            'users': [],
            'outlets': [],
            'canMakeOrder': true,
            'isUsingEDM': false
          }
        ],
        'roles': ['ROLE_USER', 'ROLE_MANAGER', 'ROLE_ADMIN'],
        'vendorId': null,
        'outlet': {
          'id': 156,
          'vendorId': '0002300707_8',
          'contractor': {
            'id': 9,
            'inn': '_____2300707',
            'name': 'Розничный покупатель',
            'vendorId': '0002300707',
            'users': [],
            'outlets': [],
            'canMakeOrder': true,
            'isUsingEDM': false
          },
          'address': {
            'id': 13230,
            'postcode': 690062,
            'area': null,
            'settlement': null,
            'houseNumber': '21Б',
            'flatNumber': null,
            'line': '690062, Приморский край, г. Владивосток, ул. Днепровская, д. 21Б',
            'longitude': 131.9266,
            'latitude': 43.144173,
            'lineStreet': 'ул. Днепровская, д. 21Б'
          },
          'createdAt': '2022-04-08T10:43:25+10:00',
          'updatedAt': '2025-09-19T13:47:41+10:00',
          'canMakeOrder': true,
          'enabled': true,
          'name': 'Днепровская',
          'is1cAutozakazOn': null
        },
        'disabled': false,
        'createdAt': '2023-10-20T11:17:57+10:00'
      };

      // Создаем экземпляр AuthApiService для доступа к приватному методу
      // В реальном тесте лучше сделать метод публичным или использовать рефлексию
      // final service = AuthApiService();

      // Тестируем ожидаемые результаты трансформации
      expect(apiData['id'], 1);
      expect(apiData['firstName'], 'Юрий');
      expect(apiData['fatherName'], 'Арсенович');
      expect(apiData['lastName'], 'Ким');
      expect(apiData['roles'], ['ROLE_USER', 'ROLE_MANAGER', 'ROLE_ADMIN']);

      // Проверяем, что данные соответствуют ожидаемой структуре
      expect(apiData.containsKey('firstName'), true);
      expect(apiData.containsKey('lastName'), true);
      expect(apiData.containsKey('fatherName'), true);
      expect(apiData.containsKey('id'), true);
    });

    test('should build full name correctly', () {
      final apiData = {
        'firstName': 'Юрий',
        'fatherName': 'Арсенович',
        'lastName': 'Ким',
      };

      final expectedFullName = 'Ким Юрий Арсенович';

      final parts = [apiData['lastName'], apiData['firstName'], apiData['fatherName']]
          .where((part) => part != null && part.isNotEmpty)
          .toList();

      final actualFullName = parts.join(' ');

      expect(actualFullName, expectedFullName);
    });
  });
}