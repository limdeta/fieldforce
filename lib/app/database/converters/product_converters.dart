// lib/app/database/converters/product_converters.dart

import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:fieldforce/features/shop/domain/entities/product.dart';

/// Конвертер для списка изображений
class ImageListConverter extends TypeConverter<List<ImageData>, String> {
  const ImageListConverter();

  @override
  List<ImageData> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(fromDb);
    return jsonList.map((json) => ImageData.fromJson(json)).toList();
  }

  @override
  String toSql(List<ImageData> value) {
    return jsonEncode(value.map((img) => img.toJson()).toList());
  }
}

class BrandConverter extends TypeConverter<Brand?, String?> {
  const BrandConverter();

  @override
  Brand? fromSql(String? fromDb) {
    if (fromDb == null || fromDb.isEmpty) return null;
    return Brand.fromJson(jsonDecode(fromDb));
  }

  @override
  String? toSql(Brand? value) {
    return value != null ? jsonEncode(value.toJson()) : null;
  }
}

class CategoryConverter extends TypeConverter<Category?, String?> {
  const CategoryConverter();

  @override
  Category? fromSql(String? fromDb) {
    if (fromDb == null || fromDb.isEmpty) return null;
    return Category.fromJson(jsonDecode(fromDb));
  }

  @override
  String? toSql(Category? value) {
    return value != null ? jsonEncode(value.toJson()) : null;
  }
}

class CategoryListConverter extends TypeConverter<List<Category>, String> {
  const CategoryListConverter();

  @override
  List<Category> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(fromDb);
    return jsonList.map((json) => Category.fromJson(json)).toList();
  }

  @override
  String toSql(List<Category> value) {
    return jsonEncode(value.map((cat) => cat.toJson()).toList());
  }
}

class CharacteristicListConverter extends TypeConverter<List<Characteristic>, String> {
  const CharacteristicListConverter();

  @override
  List<Characteristic> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(fromDb);
    return jsonList.map((json) => Characteristic.fromJson(json)).toList();
  }

  @override
  String toSql(List<Characteristic> value) {
    return jsonEncode(value.map((char) => char.toJson()).toList());
  }
}

class BarcodeListConverter extends TypeConverter<List<String>, String> {
  const BarcodeListConverter();

  @override
  List<String> fromSql(String fromDb) {
    if (fromDb.isEmpty) return [];
    final List<dynamic> jsonList = jsonDecode(fromDb);
    return jsonList.cast<String>();
  }

  @override
  String toSql(List<String> value) {
    return jsonEncode(value);
  }
}