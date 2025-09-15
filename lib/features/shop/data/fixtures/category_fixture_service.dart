import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fieldforce/features/shop/data/services/category_parsing_service.dart';
import 'package:fieldforce/features/shop/domain/repositories/category_repository.dart';
import 'package:fieldforce/shared/either.dart';
import 'package:get_it/get_it.dart';

/// Тип фикстуры для загрузки категорий
enum FixtureType {
  /// Сокращенная фикстура для тестов (4-5 основных категорий)
  compact,
  /// Полная фикстура из categories.json для dev режима
  full,
}

class CategoryFixtureService {
  final CategoryParsingService _parsingService;
  final CategoryRepository _repository;

  CategoryFixtureService(this._parsingService, this._repository);

  /// Сокращенная фикстура для тестов с 4-5 основными категориями разной вложенности
  static const String _compactCategoriesJson = '''
[
  {
    "id": 1,
    "name": "Продукты питания",
    "lft": 1,
    "rgt": 20,
    "lvl": 0,
    "description": "Основные продукты питания",
    "query": null,
    "count": 1500,
    "children": [
      {
        "id": 2,
        "name": "Молочные продукты",
        "lft": 2,
        "rgt": 9,
        "lvl": 1,
        "description": "Молоко, сыр, йогурт",
        "query": null,
        "count": 300,
        "children": [
          {
            "id": 3,
            "name": "Молоко",
            "lft": 3,
            "rgt": 6,
            "lvl": 2,
            "description": "Молоко различных видов",
            "query": null,
            "count": 150,
            "children": [
              {
                "id": 4,
                "name": "Коровье молоко",
                "lft": 4,
                "rgt": 5,
                "lvl": 3,
                "description": "Цельное коровье молоко",
                "query": null,
                "count": 75,
                "children": []
              }
            ]
          },
          {
            "id": 5,
            "name": "Сыр",
            "lft": 7,
            "rgt": 8,
            "lvl": 2,
            "description": "Различные виды сыра",
            "query": null,
            "count": 150,
            "children": []
          }
        ]
      },
      {
        "id": 6,
        "name": "Хлебобулочные изделия",
        "lft": 10,
        "rgt": 17,
        "lvl": 1,
        "description": "Хлеб, булочки, пироги",
        "query": null,
        "count": 400,
        "children": [
          {
            "id": 7,
            "name": "Хлеб",
            "lft": 11,
            "rgt": 14,
            "lvl": 2,
            "description": "Различные виды хлеба",
            "query": null,
            "count": 200,
            "children": [
              {
                "id": 8,
                "name": "Белый хлеб",
                "lft": 12,
                "rgt": 13,
                "lvl": 3,
                "description": "Пшеничный белый хлеб",
                "query": null,
                "count": 100,
                "children": []
              }
            ]
          },
          {
            "id": 9,
            "name": "Булочки",
            "lft": 15,
            "rgt": 16,
            "lvl": 2,
            "description": "Сладкие и соленые булочки",
            "query": null,
            "count": 200,
            "children": []
          }
        ]
      },
      {
        "id": 10,
        "name": "Кондитерские изделия",
        "lft": 18,
        "rgt": 19,
        "lvl": 1,
        "description": "Конфеты, шоколад, печенье",
        "query": null,
        "count": 800,
        "children": []
      }
    ]
  },
  {
    "id": 11,
    "name": "Напитки",
    "lft": 21,
    "rgt": 30,
    "lvl": 0,
    "description": "Горячие и холодные напитки",
    "query": null,
    "count": 600,
    "children": [
      {
        "id": 12,
        "name": "Газированные напитки",
        "lft": 22,
        "rgt": 25,
        "lvl": 1,
        "description": "Кола, спрайт и другие",
        "query": null,
        "count": 300,
        "children": [
          {
            "id": 13,
            "name": "Кола",
            "lft": 23,
            "rgt": 24,
            "lvl": 2,
            "description": "Классическая кола",
            "query": null,
            "count": 150,
            "children": []
          }
        ]
      },
      {
        "id": 14,
        "name": "Соки",
        "lft": 26,
        "rgt": 29,
        "lvl": 1,
        "description": "Фруктовые и овощные соки",
        "query": null,
        "count": 300,
        "children": [
          {
            "id": 15,
            "name": "Апельсиновый сок",
            "lft": 27,
            "rgt": 28,
            "lvl": 2,
            "description": "100% апельсиновый сок",
            "query": null,
            "count": 150,
            "children": []
          }
        ]
      }
    ]
  },
  {
    "id": 16,
    "name": "Бытовая химия",
    "lft": 31,
    "rgt": 34,
    "lvl": 0,
    "description": "Средства для уборки и чистки",
    "query": null,
    "count": 400,
    "children": [
      {
        "id": 17,
        "name": "Средства для мытья посуды",
        "lft": 32,
        "rgt": 33,
        "lvl": 1,
        "description": "Жидкости и таблетки для посуды",
        "query": null,
        "count": 200,
        "children": []
      }
    ]
  }
]
''';

  /// Загружает фиктивные категории в базу данных
  Future<void> loadCategories({FixtureType fixtureType = FixtureType.compact}) async {
    try {
      print('🎭 CategoryFixtureService: Начинаем загрузку категорий типа $fixtureType');
      String jsonString;

      if (fixtureType == FixtureType.full) {
        // Загружаем полный каталог из файла
        print('🎭 CategoryFixtureService: Загружаем полный каталог из categories.json');
        jsonString = await rootBundle.loadString('lib/features/shop/data/fixtures/categories.json');
      } else {
        // Используем сокращенную фикстуру для тестов
        print('🎭 CategoryFixtureService: Используем сокращенную фикстуру');
        jsonString = _compactCategoriesJson;
      }

      final categories = _parsingService.parseCategoriesFromJsonString(jsonString);
      print('🎭 CategoryFixtureService: Распарсено ${categories.length} категорий');

      final saveResult = await _repository.saveCategories(categories);
      saveResult.fold(
        (failure) {
          print('🎭 CategoryFixtureService: Ошибка сохранения категорий: ${failure.message}');
          throw Exception('Ошибка сохранения категорий: ${failure.message}');
        },
        (_) {
          print('🎭 CategoryFixtureService: Категории успешно сохранены');
        },
      );
    } catch (e) {
      print('🎭 CategoryFixtureService: Ошибка загрузки категорий: $e');
      throw Exception('Ошибка загрузки категорий: $e');
    }
  }
}