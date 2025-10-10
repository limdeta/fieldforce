import '../generated/product.pb.dart' as pb;
import '../../../domain/entities/product.dart';
import 'package:logging/logging.dart';

/// Конвертор для преобразования protobuf Product в domain Product
class ProductProtobufConverter {
  static final Logger _logger = Logger('ProductProtobufConverter');
  
  /// Конвертирует protobuf Product в domain Product
  /// Структуры уже совпадают, поэтому преобразование простое
  static Product fromProtobuf(pb.Product pbProduct) {
    // 🔍 ДИАГНОСТИКА КОНВЕРТАЦИИ ПРОБЛЕМНЫХ ПРОДУКТОВ
    if (pbProduct.code == 187621 || pbProduct.bcode == 114626 || pbProduct.code == 170094) {
      _logger.info('🔍 КОНВЕРТАЦИЯ ПРОДУКТА:');
      _logger.info('   pbProduct.code: ${pbProduct.code}');
      _logger.info('   pbProduct.bcode: ${pbProduct.bcode}');
      _logger.info('   pbProduct.hasCatalogId(): ${pbProduct.hasCatalogId()}');
      _logger.info('   pbProduct.catalogId: ${pbProduct.catalogId}');
      _logger.info('   pbProduct.title: ${pbProduct.title}');
    }
    
    final catalogId = pbProduct.hasCatalogId() ? pbProduct.catalogId : 0;
    
    return Product(
      title: pbProduct.title,
      barcodes: pbProduct.barcodes.isNotEmpty ? pbProduct.barcodes : [],
      code: pbProduct.code,
      bcode: pbProduct.bcode,
      catalogId: catalogId, // Используем новое поле catalog_id
      novelty: pbProduct.novelty,
      popular: pbProduct.popular,
      isMarked: pbProduct.isMarked,
      brand: pbProduct.hasBrand() ? _convertBrand(pbProduct.brand) : null,
      manufacturer: pbProduct.hasManufacturer() ? _convertManufacturer(pbProduct.manufacturer) : null,
      colorImage: pbProduct.hasColorImage() ? _convertImage(pbProduct.colorImage) : null,
      defaultImage: pbProduct.hasDefaultImage() ? _convertImage(pbProduct.defaultImage) : null,
      images: pbProduct.images.map(_convertImage).toList(),
      description: pbProduct.description.isNotEmpty ? pbProduct.description : null,
      howToUse: pbProduct.howToUse.isNotEmpty ? pbProduct.howToUse : null,
      ingredients: pbProduct.ingredients.isNotEmpty ? pbProduct.ingredients : null,
      series: pbProduct.hasSeries() ? _convertSeries(pbProduct.series) : null,
      category: pbProduct.hasCategory() ? _convertCategory(pbProduct.category) : null,
      priceListCategoryId: pbProduct.priceListCategoryId,
      amountInPackage: pbProduct.amountInPackage,
      vendorCode: pbProduct.vendorCode.isNotEmpty ? pbProduct.vendorCode : null,
      type: pbProduct.hasType() ? _convertProductType(pbProduct.type) : null,
      categoriesInstock: pbProduct.categoriesInstock.map(_convertCategory).toList(),
      numericCharacteristics: pbProduct.numericCharacteristics.map(_convertNumericCharacteristic).toList(),
      stringCharacteristics: pbProduct.stringCharacteristics.map(_convertStringCharacteristic).toList(),
      boolCharacteristics: pbProduct.boolCharacteristics.map(_convertBoolCharacteristic).toList(),
      canBuy: pbProduct.canBuy,
    );
  }

  /// Конвертирует список protobuf Products в domain Products
  static List<Product> fromProtobufList(List<pb.Product> pbProducts) {
    return pbProducts.map(fromProtobuf).toList();
  }

  // Вспомогательные методы конвертации
  static Brand _convertBrand(pb.Brand pbBrand) {
    return Brand(
      id: pbBrand.id,
      name: pbBrand.name,
      searchPriority: 0, // Protobuf не содержит этого поля
      adaptedName: null, // Protobuf не содержит этого поля
    );
  }

  static Manufacturer _convertManufacturer(pb.Manufacturer pbManufacturer) {
    return Manufacturer(
      id: pbManufacturer.id,
      name: pbManufacturer.name,
    );
  }

  static ImageData _convertImage(pb.ProductImage pbImage) {
    return ImageData(
      id: pbImage.id,
      height: pbImage.height,
      width: pbImage.width,
      uri: pbImage.uri,
      webp: pbImage.webp.isNotEmpty ? pbImage.webp : null,
    );
  }

  static Series _convertSeries(pb.Series pbSeries) {
    return Series(
      id: pbSeries.id,
      name: pbSeries.name,
    );
  }

  static Category _convertCategory(pb.Category pbCategory) {
    return Category(
      id: pbCategory.id,
      name: pbCategory.name,
      isPublish: null, // Protobuf не содержит этого поля
      description: pbCategory.description.isNotEmpty ? pbCategory.description : null,
      query: null, // Protobuf не содержит этого поля
    );
  }

  static ProductType _convertProductType(pb.ProductType pbType) {
    return ProductType(
      id: pbType.id,
      name: pbType.name,
    );
  }

  static Characteristic _convertNumericCharacteristic(pb.NumericCharacteristic pbChar) {
    return Characteristic(
      attributeId: pbChar.attributeId,
      attributeName: pbChar.attributeName,
      id: pbChar.id,
      type: 'numeric',
      value: pbChar.value,
      adaptValue: null,
    );
  }

  static Characteristic _convertStringCharacteristic(pb.StringCharacteristic pbChar) {
    return Characteristic(
      attributeId: pbChar.attributeId,
      attributeName: pbChar.attributeName,
      id: pbChar.id,
      type: 'string',
      value: pbChar.value,
      adaptValue: null,
    );
  }

  static Characteristic _convertBoolCharacteristic(pb.BoolCharacteristic pbChar) {
    return Characteristic(
      attributeId: pbChar.attributeId,
      attributeName: pbChar.attributeName,
      id: pbChar.id,
      type: 'bool',
      value: pbChar.value,
      adaptValue: null,
    );
  }
}