import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fieldforce/features/shop/domain/entities/category.dart';

/// Сервис для парсинга JSON категорий из файла
class CategoryParsingService {
  /// Парсит категории из JSON файла в fixtures
  Future<List<Category>> parseCategoriesFromJson(String filePath) async {
    try {
      final jsonString = await rootBundle.loadString(filePath);
      final jsonData = jsonDecode(jsonString) as List<dynamic>;

      return jsonData.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка парсинга категорий из $filePath: $e');
    }
  }

  /// Парсит категории из JSON строки (для тестирования)
  List<Category> parseCategoriesFromJsonString(String jsonString) {
    try {
      final jsonData = jsonDecode(jsonString) as List<dynamic>;
      return jsonData.map((item) => Category.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Ошибка парсинга JSON строки: $e');
    }
  }
}