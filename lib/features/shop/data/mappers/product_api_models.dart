import 'package:equatable/equatable.dart';

/// Ответ API с продуктами
class ProductApiResponse extends Equatable {
  /// Список продуктов
  final List<ProductApiItem> products;

  /// Общее количество продуктов
  final int totalCount;

  /// Текущая страница
  final int currentPage;

  /// Размер страницы
  final int pageSize;

  /// Всего страниц
  final int totalPages;

  const ProductApiResponse({
    required this.products,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
  });

  /// Создает ответ из JSON
  factory ProductApiResponse.fromJson(Map<String, dynamic> json) {
    // API возвращает продукты в поле 'data', а не 'products'
    final productsData = json['data'] as List<dynamic>? ?? json['products'] as List<dynamic>? ?? [];
    
    return ProductApiResponse(
      products: productsData
          .map((item) => ProductApiItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int? ?? json['total'] as int? ?? productsData.length,
      currentPage: json['currentPage'] as int? ?? json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? json['limit'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? json['pages'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [
        products,
        totalCount,
        currentPage,
        pageSize,
        totalPages,
      ];
}

/// Продукт в формате API
class ProductApiItem extends Equatable {
  /// Уникальный код продукта
  final int code;

  /// Название продукта
  final String title;

  /// Штрихкоды
  final List<String> barcodes;

  /// B-код (внутренний код)
  final int bcode;

  /// ID каталога
  final int catalogId;

  /// Новинка
  final bool novelty;

  /// Популярный
  final bool popular;

  /// Отмеченный
  final bool isMarked;

  /// Можно купить
  final bool canBuy;

  /// Бренд
  final BrandApi? brand;

  /// Производитель
  final ManufacturerApi? manufacturer;

  /// Цветное изображение
  final ImageDataApi? colorImage;

  /// Изображение по умолчанию
  final ImageDataApi? defaultImage;

  /// Все изображения
  final List<ImageDataApi> images;

  /// Описание
  final String? description;

  /// Как использовать
  final String? howToUse;

  /// Состав
  final String? ingredients;

  /// Серия
  final SeriesApi? series;

  /// Категория
  final CategoryApi? category;

  /// ID категории прайс-листа
  final int? priceListCategoryId;

  /// Количество в упаковке
  final int? amountInPackage;

  /// Артикул
  final String? vendorCode;

  /// Тип продукта
  final ProductTypeApi? type;

  /// Категории в Instock
  final List<CategoryApi> categoriesInstock;

  /// Числовые характеристики
  final List<CharacteristicApi> numericCharacteristics;

  /// Строковые характеристики
  final List<CharacteristicApi> stringCharacteristics;

  /// Булевы характеристики
  final List<CharacteristicApi> boolCharacteristics;

  /// StockItems (остатки по складам)
  final List<StockItemApi> stockItems;

  const ProductApiItem({
    required this.code,
    required this.title,
    required this.barcodes,
    required this.bcode,
    required this.catalogId,
    required this.novelty,
    required this.popular,
    required this.isMarked,
    required this.canBuy,
    this.brand,
    this.manufacturer,
    this.colorImage,
    this.defaultImage,
    required this.images,
    this.description,
    this.howToUse,
    this.ingredients,
    this.series,
    this.category,
    this.priceListCategoryId,
    this.amountInPackage,
    this.vendorCode,
    this.type,
    required this.categoriesInstock,
    required this.numericCharacteristics,
    required this.stringCharacteristics,
    required this.boolCharacteristics,
    required this.stockItems,
  });

  /// Создает продукт из JSON
  factory ProductApiItem.fromJson(Map<String, dynamic> json) {
    return ProductApiItem(
      code: json['code'] as int? ?? 0,
      title: json['title'] as String? ?? 'Без названия',
      barcodes: (json['barcodes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      bcode: json['bcode'] as int? ?? 0,
      catalogId: json['catalogId'] as int? ?? 0,
      novelty: json['novelty'] as bool? ?? false,
      popular: json['popular'] as bool? ?? false,
      isMarked: json['isMarked'] as bool? ?? false,
      canBuy: json['canBuy'] as bool? ?? true,
      brand: json['brand'] != null
          ? BrandApi.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      manufacturer: json['manufacturer'] != null
          ? ManufacturerApi.fromJson(json['manufacturer'] as Map<String, dynamic>)
          : null,
      colorImage: json['colorImage'] != null
          ? ImageDataApi.fromJson(json['colorImage'] as Map<String, dynamic>)
          : null,
      defaultImage: json['defaultImage'] != null
          ? ImageDataApi.fromJson(json['defaultImage'] as Map<String, dynamic>)
          : null,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ImageDataApi.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      description: json['description'] as String?,
      howToUse: json['howToUse'] as String?,
      ingredients: json['ingredients'] as String?,
      series: json['series'] != null
          ? SeriesApi.fromJson(json['series'] as Map<String, dynamic>)
          : null,
      category: json['category'] != null
          ? CategoryApi.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      priceListCategoryId: json['priceListCategoryId'] as int?,
      amountInPackage: json['amountInPackage'] as int?,
      vendorCode: json['vendorCode'] as String?,
      type: json['type'] != null
          ? ProductTypeApi.fromJson(json['type'] as Map<String, dynamic>)
          : null,
      categoriesInstock: (json['categoriesInstock'] as List<dynamic>?)
          ?.map((e) => CategoryApi.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      numericCharacteristics: (json['numericCharacteristics'] as List<dynamic>?)
          ?.map((e) => CharacteristicApi.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      stringCharacteristics: (json['stringCharacteristics'] as List<dynamic>?)
          ?.map((e) => CharacteristicApi.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      boolCharacteristics: (json['boolCharacteristics'] as List<dynamic>?)
          ?.map((e) => CharacteristicApi.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      stockItems: (json['stockItems'] as List<dynamic>?)
          ?.map((e) => StockItemApi.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [
        code,
        title,
        barcodes,
        bcode,
        catalogId,
        novelty,
        popular,
        isMarked,
        canBuy,
        brand,
        manufacturer,
        colorImage,
        defaultImage,
        images,
        description,
        howToUse,
        ingredients,
        series,
        category,
        priceListCategoryId,
        amountInPackage,
        vendorCode,
        type,
        categoriesInstock,
        numericCharacteristics,
        stringCharacteristics,
        boolCharacteristics,
        stockItems,
      ];
}

/// Бренд в формате API
class BrandApi extends Equatable {
  final int id;
  final String name;

  const BrandApi({
    required this.id,
    required this.name,
  });

  factory BrandApi.fromJson(Map<String, dynamic> json) {
    return BrandApi(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Неизвестный бренд',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Производитель в формате API
class ManufacturerApi extends Equatable {
  final int id;
  final String name;

  const ManufacturerApi({
    required this.id,
    required this.name,
  });

  factory ManufacturerApi.fromJson(Map<String, dynamic> json) {
    return ManufacturerApi(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Неизвестный производитель',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Изображение в формате API
class ImageDataApi extends Equatable {
  final String url;
  final String? alt;

  const ImageDataApi({
    required this.url,
    this.alt,
  });

  factory ImageDataApi.fromJson(Map<String, dynamic> json) {
    return ImageDataApi(
      url: json['url'] as String? ?? '',
      alt: json['alt'] as String?,
    );
  }

  @override
  List<Object?> get props => [url, alt];
}

/// Серия в формате API
class SeriesApi extends Equatable {
  final int id;
  final String name;

  const SeriesApi({
    required this.id,
    required this.name,
  });

  factory SeriesApi.fromJson(Map<String, dynamic> json) {
    return SeriesApi(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Неизвестная серия',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Категория в формате API
class CategoryApi extends Equatable {
  final int id;
  final String name;

  const CategoryApi({
    required this.id,
    required this.name,
  });

  factory CategoryApi.fromJson(Map<String, dynamic> json) {
    return CategoryApi(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Неизвестная категория',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Тип продукта в формате API
class ProductTypeApi extends Equatable {
  final int id;
  final String name;

  const ProductTypeApi({
    required this.id,
    required this.name,
  });

  factory ProductTypeApi.fromJson(Map<String, dynamic> json) {
    return ProductTypeApi(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

/// Характеристика в формате API
class CharacteristicApi extends Equatable {
  final String name;
  final dynamic value;

  const CharacteristicApi({
    required this.name,
    required this.value,
  });

  factory CharacteristicApi.fromJson(Map<String, dynamic> json) {
    return CharacteristicApi(
      name: json['name'] as String? ?? 'Неизвестная характеристика',
      value: json['value'],
    );
  }

  @override
  List<Object?> get props => [name, value];
}

/// StockItem в формате API
class StockItemApi extends Equatable {
  final int warehouseId;
  final String warehouseName;
  final double price;
  final int stock;
  final int reserved;

  const StockItemApi({
    required this.warehouseId,
    required this.warehouseName,
    required this.price,
    required this.stock,
    required this.reserved,
  });

  factory StockItemApi.fromJson(Map<String, dynamic> json) {
    // Парсим stock - может быть int или строка типа "1666 шт."
    int parseStock(dynamic stockValue) {
      if (stockValue is int) return stockValue;
      if (stockValue is String) {
        final match = RegExp(r'(\d+)').firstMatch(stockValue);
        return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
      }
      return 0;
    }

    return StockItemApi(
      warehouseId: json['warehouse']?['id'] as int? ?? json['warehouseId'] as int? ?? 0,
      warehouseName: json['warehouse']?['name'] as String? ?? json['warehouseName'] as String? ?? 'Неизвестный склад',
      price: (json['price'] as num?)?.toDouble() ?? (json['defaultPrice'] as num?)?.toDouble() ?? 0.0,
      stock: parseStock(json['stock'] ?? json['publicStock']),
      reserved: json['reserved'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        warehouseId,
        warehouseName,
        price,
        stock,
        reserved,
      ];
}