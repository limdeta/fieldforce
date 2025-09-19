// lib/features/shop/domain/entities/product.dart

class Product {
  final String title;
  final List<String> barcodes;
  final int code;
  final int bcode;
  final int catalogId;
  final bool novelty;
  final bool popular;
  final bool isMarked;
  final Brand? brand;
  final Manufacturer? manufacturer;
  final ImageData? colorImage;
  final ImageData? defaultImage;
  final List<ImageData> images;
  final String? description;
  final String? howToUse;
  final String? ingredients;
  final Series? series;
  final Category? category;
  final int? priceListCategoryId;
  final int? amountInPackage;
  final String? vendorCode;
  final ProductType? type;
  final List<Category> categoriesInstock;
  final List<Characteristic> numericCharacteristics;
  final List<Characteristic> stringCharacteristics;
  final List<Characteristic> boolCharacteristics;
  // TODO: Восстановить stockItems после рефакторинга
  // final List<StockItem> stockItems;
  final bool canBuy;

  Product({
    required this.title,
    required this.barcodes,
    required this.code,
    required this.bcode,
    required this.catalogId,
    required this.novelty,
    required this.popular,
    required this.isMarked,
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
    // required this.stockItems,
    required this.canBuy,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final product = Product(
      title: json['title'] as String? ?? 'Без названия',
      barcodes: json['barcodes'] != null ? (json['barcodes'] as List<dynamic>).map((e) => e as String).toList() : <String>[],
      code: json['code'] as int? ?? 0,
      bcode: json['bcode'] as int? ?? 0,
      catalogId: json['catalogId'] as int? ?? 0,
      novelty: json['novelty'] as bool? ?? false,
      popular: json['popular'] as bool? ?? false,
      isMarked: json['isMarked'] as bool? ?? false,
      brand: json['brand'] != null ? Brand.fromJson(json['brand']) : null,
      manufacturer: json['manufacturer'] != null ? Manufacturer.fromJson(json['manufacturer']) : null,
      colorImage: json['colorImage'] != null ? ImageData.fromJson(json['colorImage']) : null,
      defaultImage: json['defaultImage'] != null ? ImageData.fromJson(json['defaultImage']) : null,
      images: json['images'] != null ? (json['images'] as List<dynamic>).map((e) => ImageData.fromJson(e)).toList() : <ImageData>[],
      description: json['description'] as String?,
      howToUse: json['howToUse'] as String?,
      ingredients: json['ingredients'] as String?,
      series: json['series'] != null ? Series.fromJson(json['series']) : null,
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
      priceListCategoryId: json['priceListCategoryId'] as int?,
      amountInPackage: json['amountInPackage'] as int?,
      vendorCode: json['vendorCode'] as String?,
      type: json['type'] != null ? ProductType.fromJson(json['type']) : null,
      categoriesInstock: json['categoriesInstock'] != null ? (json['categoriesInstock'] as List<dynamic>).map((e) => Category.fromJson(e)).toList() : <Category>[],
      numericCharacteristics: json['numericCharacteristics'] != null ? (json['numericCharacteristics'] as List<dynamic>).map((e) => Characteristic.fromJson(e)).toList() : <Characteristic>[],
      stringCharacteristics: json['stringCharacteristics'] != null ? (json['stringCharacteristics'] as List<dynamic>).map((e) => Characteristic.fromJson(e)).toList() : <Characteristic>[],
      boolCharacteristics: json['boolCharacteristics'] != null ? (json['boolCharacteristics'] as List<dynamic>).map((e) => Characteristic.fromJson(e)).toList() : <Characteristic>[],
      // stockItems: [], // Временно отключено
      canBuy: json['canBuy'] as bool? ?? true,
    );

    // TODO: Создать StockItems через отдельный сервис
    // final stockItems = (json['stockItems'] as List<dynamic>)
    //     .map((e) => StockItem.fromJson(e, product))
    //     .toList();

    // Возвращаем product напрямую
    return product;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'barcodes': barcodes,
      'code': code,
      'bcode': bcode,
      'catalogId': catalogId,
      'novelty': novelty,
      'popular': popular,
      'isMarked': isMarked,
      'brand': brand?.toJson(),
      'manufacturer': manufacturer?.toJson(),
      'colorImage': colorImage?.toJson(),
      'defaultImage': defaultImage?.toJson(),
      'images': images.map((e) => e.toJson()).toList(),
      'description': description,
      'howToUse': howToUse,
      'ingredients': ingredients,
      'series': series?.toJson(),
      'category': category?.toJson(),
      'priceListCategoryId': priceListCategoryId,
      'amountInPackage': amountInPackage,
      'vendorCode': vendorCode,
      'type': type?.toJson(),
      'categoriesInstock': categoriesInstock.map((e) => e.toJson()).toList(),
      'numericCharacteristics': numericCharacteristics.map((e) => e.toJson()).toList(),
      'stringCharacteristics': stringCharacteristics.map((e) => e.toJson()).toList(),
      'boolCharacteristics': boolCharacteristics.map((e) => e.toJson()).toList(),
      // 'stockItems': stockItems.map((e) => e.toJson()).toList(), // TODO: Восстановить после рефакторинга
      'canBuy': canBuy,
    };
  }
}

class Brand {
  final int searchPriority;
  final int id;
  final String name;
  final String? adaptedName;

  Brand({
    required this.searchPriority,
    required this.id,
    required this.name,
    this.adaptedName,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      searchPriority: json['search_priority'] as int? ?? 0,
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Без названия',
      adaptedName: json['adaptedName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'search_priority': searchPriority,
      'id': id,
      'name': name,
      'adaptedName': adaptedName,
    };
  }
}

class Manufacturer {
  final int id;
  final String name;

  Manufacturer({
    required this.id,
    required this.name,
  });

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Без названия',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class ImageData {
  final int? id;
  final int height;
  final int width;
  final String uri;
  final String? webp;

  ImageData({
    this.id,
    required this.height,
    required this.width,
    required this.uri,
    this.webp,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      id: json['id'] as int?,
      height: json['height'] as int? ?? 0,
      width: json['width'] as int? ?? 0,
      uri: json['uri'] as String? ?? '',
      webp: json['webp'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'height': height,
      'width': width,
      'uri': uri,
      'webp': webp,
    };
  }
}

class Series {
  final int id;
  final String name;

  Series({
    required this.id,
    required this.name,
  });

  factory Series.fromJson(Map<String, dynamic> json) {
    return Series(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Без названия',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Category {
  final int id;
  final String name;
  final bool? isPublish;
  final String? description;
  final String? query;

  Category({
    required this.id,
    required this.name,
    this.isPublish,
    this.description,
    this.query,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Без названия',
      isPublish: json['isPublish'] as bool?,
      description: json['description'] as String?,
      query: json['query'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isPublish': isPublish,
      'description': description,
      'query': query,
    };
  }
}

class ProductType {
  final int id;
  final String name;

  ProductType({
    required this.id,
    required this.name,
  });

  factory ProductType.fromJson(Map<String, dynamic> json) {
    return ProductType(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Без названия',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Characteristic {
  final int attributeId;
  final String attributeName;
  final int id;
  final String type;
  final String? adaptValue;
  final dynamic value; // Может быть int, String или bool

  Characteristic({
    required this.attributeId,
    required this.attributeName,
    required this.id,
    required this.type,
    this.adaptValue,
    required this.value,
  });

  factory Characteristic.fromJson(Map<String, dynamic> json) {
    return Characteristic(
      attributeId: json['attributeId'] as int? ?? 0,
      attributeName: json['attributeName'] as String? ?? 'Неизвестная характеристика',
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? 'unknown',
      adaptValue: json['adaptValue'] as String?,
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attributeId': attributeId,
      'attributeName': attributeName,
      'id': id,
      'type': type,
      'adaptValue': adaptValue,
      'value': value,
    };
  }
}

class Warehouse {
  final int id;
  final String name;
  final String vendorId;
  final bool isPickUpPoint;

  Warehouse({
    required this.id,
    required this.name,
    required this.vendorId,
    required this.isPickUpPoint,
  });

  factory Warehouse.fromJson(Map<String, dynamic> json) {
    return Warehouse(
      id: json['id'] as int,
      name: json['name'] as String,
      vendorId: json['vendorId'] as String,
      isPickUpPoint: json['isPickUpPoint'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vendorId': vendorId,
      'isPickUpPoint': isPickUpPoint,
    };
  }
}

class Promotion {
  final int id;
  final String? bannerFull;
  final String? banner;
  final String shipmentStart;
  final String shipmentFinish;
  final String promotionConditionsDescription;
  final List<dynamic> promotionLimits;
  final String vendorId;
  final String vendorName;
  final String? title;
  final String? wobbler;
  final String? description;
  final String? caption;
  final String? backgroundColor;
  final String? url;
  final String start;
  final String finish;
  final PromoCondition promoCondition;
  final bool isPortalPromo;
  final String type;

  Promotion({
    required this.id,
    this.bannerFull,
    this.banner,
    required this.shipmentStart,
    required this.shipmentFinish,
    required this.promotionConditionsDescription,
    required this.promotionLimits,
    required this.vendorId,
    required this.vendorName,
    this.title,
    this.wobbler,
    this.description,
    this.caption,
    this.backgroundColor,
    this.url,
    required this.start,
    required this.finish,
    required this.promoCondition,
    required this.isPortalPromo,
    required this.type,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) {
    return Promotion(
      id: json['id'] as int,
      bannerFull: json['bannerFull'] as String?,
      banner: json['banner'] as String?,
      shipmentStart: json['shipmentStart'] as String,
      shipmentFinish: json['shipmentFinish'] as String,
      promotionConditionsDescription: json['promotionConditionsDescription'] as String,
      promotionLimits: json['promotionLimits'] as List<dynamic>,
      vendorId: json['vendorId'] as String,
      vendorName: json['vendorName'] as String,
      title: json['title'] as String?,
      wobbler: json['wobbler'] as String?,
      description: json['description'] as String?,
      caption: json['caption'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      url: json['url'] as String?,
      start: json['start'] as String,
      finish: json['finish'] as String,
      promoCondition: PromoCondition.fromJson(json['promoCondition']),
      isPortalPromo: json['isPortalPromo'] as bool,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bannerFull': bannerFull,
      'banner': banner,
      'shipmentStart': shipmentStart,
      'shipmentFinish': shipmentFinish,
      'promotionConditionsDescription': promotionConditionsDescription,
      'promotionLimits': promotionLimits,
      'vendorId': vendorId,
      'vendorName': vendorName,
      'title': title,
      'wobbler': wobbler,
      'description': description,
      'caption': caption,
      'backgroundColor': backgroundColor,
      'url': url,
      'start': start,
      'finish': finish,
      'promoCondition': promoCondition.toJson(),
      'isPortalPromo': isPortalPromo,
      'type': type,
    };
  }
}

class PromoCondition {
  final int id;
  final int typesCount;
  final int quantityByTypes;
  final int limitQuantity;
  final int limitQuantityForDocument;
  final int limitQuantityForEachGoods;
  final int limitQuantityForTradePoint;
  final int totalQuantity;
  final String type;

  PromoCondition({
    required this.id,
    required this.typesCount,
    required this.quantityByTypes,
    required this.limitQuantity,
    required this.limitQuantityForDocument,
    required this.limitQuantityForEachGoods,
    required this.limitQuantityForTradePoint,
    required this.totalQuantity,
    required this.type,
  });

  factory PromoCondition.fromJson(Map<String, dynamic> json) {
    return PromoCondition(
      id: json['id'] as int,
      typesCount: json['typesCount'] as int,
      quantityByTypes: json['quantityByTypes'] as int,
      limitQuantity: json['limitQuantity'] as int,
      limitQuantityForDocument: json['limitQuantityForDocument'] as int,
      limitQuantityForEachGoods: json['limitQuantityForEachGoods'] as int,
      limitQuantityForTradePoint: json['limitQuantityForTradePoint'] as int,
      totalQuantity: json['totalQuantity'] as int,
      type: json['type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typesCount': typesCount,
      'quantityByTypes': quantityByTypes,
      'limitQuantity': limitQuantity,
      'limitQuantityForDocument': limitQuantityForDocument,
      'limitQuantityForEachGoods': limitQuantityForEachGoods,
      'limitQuantityForTradePoint': limitQuantityForTradePoint,
      'totalQuantity': totalQuantity,
      'type': type,
    };
  }
}
