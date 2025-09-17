import 'package:flutter/services.dart';
import 'package:fieldforce/features/shop/data/services/category_parsing_service.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';

/// Тип фикстуры для загрузки категорий
class CategoryFixtureService {
  final CategoryParsingService _parsingService;
  final CategoryRepository _repository;
  
  CategoryFixtureService(this._parsingService, this._repository);
  Future<void> loadCategories() async {
      String jsonString;
      jsonString = await rootBundle.loadString('assets/fixtures/categories.json');
      
      final categories = _parsingService.parseCategoriesFromJsonString(jsonString);
      final saveResult = await _repository.saveCategories(categories);
      saveResult.fold(
        (failure) {
          throw Exception('Ошибка сохранения категорий: ${failure.message}');
        },
        (_) {
          // Категории успешно сохранены
        },
      );
      return;
    }
}