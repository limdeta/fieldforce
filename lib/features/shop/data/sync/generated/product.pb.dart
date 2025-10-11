// This is a generated file - do not edit.
//
// Generated from product.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Основное сообщение продукта
class Product extends $pb.GeneratedMessage {
  factory Product({
    $core.int? code,
    $core.int? bcode,
    $core.String? title,
    $core.String? vendorCode,
    $core.Iterable<$core.String>? barcodes,
    $core.bool? isMarked,
    $core.bool? novelty,
    $core.bool? popular,
    $core.int? amountInPackage,
    Brand? brand,
    Manufacturer? manufacturer,
    ProductImage? defaultImage,
    $core.Iterable<ProductImage>? images,
    ProductImage? colorImage,
    $core.String? description,
    $core.String? howToUse,
    $core.String? ingredients,
    Category? category,
    $core.Iterable<Category>? categoriesInstock,
    ProductType? type,
    Series? series,
    $core.int? priceListCategoryId,
    $core.Iterable<NumericCharacteristic>? numericCharacteristics,
    $core.Iterable<StringCharacteristic>? stringCharacteristics,
    $core.Iterable<BoolCharacteristic>? boolCharacteristics,
    $core.bool? canBuy,
    $core.int? catalogId,
  }) {
    final result = create();
    if (code != null) result.code = code;
    if (bcode != null) result.bcode = bcode;
    if (title != null) result.title = title;
    if (vendorCode != null) result.vendorCode = vendorCode;
    if (barcodes != null) result.barcodes.addAll(barcodes);
    if (isMarked != null) result.isMarked = isMarked;
    if (novelty != null) result.novelty = novelty;
    if (popular != null) result.popular = popular;
    if (amountInPackage != null) result.amountInPackage = amountInPackage;
    if (brand != null) result.brand = brand;
    if (manufacturer != null) result.manufacturer = manufacturer;
    if (defaultImage != null) result.defaultImage = defaultImage;
    if (images != null) result.images.addAll(images);
    if (colorImage != null) result.colorImage = colorImage;
    if (description != null) result.description = description;
    if (howToUse != null) result.howToUse = howToUse;
    if (ingredients != null) result.ingredients = ingredients;
    if (category != null) result.category = category;
    if (categoriesInstock != null)
      result.categoriesInstock.addAll(categoriesInstock);
    if (type != null) result.type = type;
    if (series != null) result.series = series;
    if (priceListCategoryId != null)
      result.priceListCategoryId = priceListCategoryId;
    if (numericCharacteristics != null)
      result.numericCharacteristics.addAll(numericCharacteristics);
    if (stringCharacteristics != null)
      result.stringCharacteristics.addAll(stringCharacteristics);
    if (boolCharacteristics != null)
      result.boolCharacteristics.addAll(boolCharacteristics);
    if (canBuy != null) result.canBuy = canBuy;
    if (catalogId != null) result.catalogId = catalogId;
    return result;
  }

  Product._();

  factory Product.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Product.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Product',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'code')
    ..aI(2, _omitFieldNames ? '' : 'bcode')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'vendorCode')
    ..pPS(5, _omitFieldNames ? '' : 'barcodes')
    ..aOB(6, _omitFieldNames ? '' : 'isMarked')
    ..aOB(7, _omitFieldNames ? '' : 'novelty')
    ..aOB(8, _omitFieldNames ? '' : 'popular')
    ..aI(9, _omitFieldNames ? '' : 'amountInPackage')
    ..aOM<Brand>(10, _omitFieldNames ? '' : 'brand', subBuilder: Brand.create)
    ..aOM<Manufacturer>(11, _omitFieldNames ? '' : 'manufacturer',
        subBuilder: Manufacturer.create)
    ..aOM<ProductImage>(12, _omitFieldNames ? '' : 'defaultImage',
        subBuilder: ProductImage.create)
    ..pPM<ProductImage>(13, _omitFieldNames ? '' : 'images',
        subBuilder: ProductImage.create)
    ..aOM<ProductImage>(14, _omitFieldNames ? '' : 'colorImage',
        subBuilder: ProductImage.create)
    ..aOS(15, _omitFieldNames ? '' : 'description')
    ..aOS(16, _omitFieldNames ? '' : 'howToUse')
    ..aOS(17, _omitFieldNames ? '' : 'ingredients')
    ..aOM<Category>(18, _omitFieldNames ? '' : 'category',
        subBuilder: Category.create)
    ..pPM<Category>(19, _omitFieldNames ? '' : 'categoriesInstock',
        subBuilder: Category.create)
    ..aOM<ProductType>(20, _omitFieldNames ? '' : 'type',
        subBuilder: ProductType.create)
    ..aOM<Series>(21, _omitFieldNames ? '' : 'series',
        subBuilder: Series.create)
    ..aI(22, _omitFieldNames ? '' : 'priceListCategoryId')
    ..pPM<NumericCharacteristic>(
        23, _omitFieldNames ? '' : 'numericCharacteristics',
        subBuilder: NumericCharacteristic.create)
    ..pPM<StringCharacteristic>(
        24, _omitFieldNames ? '' : 'stringCharacteristics',
        subBuilder: StringCharacteristic.create)
    ..pPM<BoolCharacteristic>(25, _omitFieldNames ? '' : 'boolCharacteristics',
        subBuilder: BoolCharacteristic.create)
    ..aOB(26, _omitFieldNames ? '' : 'canBuy')
    ..aI(27, _omitFieldNames ? '' : 'catalogId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Product clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Product copyWith(void Function(Product) updates) =>
      super.copyWith((message) => updates(message as Product)) as Product;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Product create() => Product._();
  @$core.override
  Product createEmptyInstance() => create();
  static $pb.PbList<Product> createRepeated() => $pb.PbList<Product>();
  @$core.pragma('dart2js:noInline')
  static Product getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Product>(create);
  static Product? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get code => $_getIZ(0);
  @$pb.TagNumber(1)
  set code($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get bcode => $_getIZ(1);
  @$pb.TagNumber(2)
  set bcode($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBcode() => $_has(1);
  @$pb.TagNumber(2)
  void clearBcode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get vendorCode => $_getSZ(3);
  @$pb.TagNumber(4)
  set vendorCode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVendorCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearVendorCode() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get barcodes => $_getList(4);

  @$pb.TagNumber(6)
  $core.bool get isMarked => $_getBF(5);
  @$pb.TagNumber(6)
  set isMarked($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsMarked() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsMarked() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get novelty => $_getBF(6);
  @$pb.TagNumber(7)
  set novelty($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNovelty() => $_has(6);
  @$pb.TagNumber(7)
  void clearNovelty() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get popular => $_getBF(7);
  @$pb.TagNumber(8)
  set popular($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPopular() => $_has(7);
  @$pb.TagNumber(8)
  void clearPopular() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get amountInPackage => $_getIZ(8);
  @$pb.TagNumber(9)
  set amountInPackage($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasAmountInPackage() => $_has(8);
  @$pb.TagNumber(9)
  void clearAmountInPackage() => $_clearField(9);

  /// Бренд и производитель
  @$pb.TagNumber(10)
  Brand get brand => $_getN(9);
  @$pb.TagNumber(10)
  set brand(Brand value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasBrand() => $_has(9);
  @$pb.TagNumber(10)
  void clearBrand() => $_clearField(10);
  @$pb.TagNumber(10)
  Brand ensureBrand() => $_ensure(9);

  @$pb.TagNumber(11)
  Manufacturer get manufacturer => $_getN(10);
  @$pb.TagNumber(11)
  set manufacturer(Manufacturer value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasManufacturer() => $_has(10);
  @$pb.TagNumber(11)
  void clearManufacturer() => $_clearField(11);
  @$pb.TagNumber(11)
  Manufacturer ensureManufacturer() => $_ensure(10);

  /// Изображения
  @$pb.TagNumber(12)
  ProductImage get defaultImage => $_getN(11);
  @$pb.TagNumber(12)
  set defaultImage(ProductImage value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasDefaultImage() => $_has(11);
  @$pb.TagNumber(12)
  void clearDefaultImage() => $_clearField(12);
  @$pb.TagNumber(12)
  ProductImage ensureDefaultImage() => $_ensure(11);

  @$pb.TagNumber(13)
  $pb.PbList<ProductImage> get images => $_getList(12);

  @$pb.TagNumber(14)
  ProductImage get colorImage => $_getN(13);
  @$pb.TagNumber(14)
  set colorImage(ProductImage value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasColorImage() => $_has(13);
  @$pb.TagNumber(14)
  void clearColorImage() => $_clearField(14);
  @$pb.TagNumber(14)
  ProductImage ensureColorImage() => $_ensure(13);

  /// Описания
  @$pb.TagNumber(15)
  $core.String get description => $_getSZ(14);
  @$pb.TagNumber(15)
  set description($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasDescription() => $_has(14);
  @$pb.TagNumber(15)
  void clearDescription() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get howToUse => $_getSZ(15);
  @$pb.TagNumber(16)
  set howToUse($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasHowToUse() => $_has(15);
  @$pb.TagNumber(16)
  void clearHowToUse() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.String get ingredients => $_getSZ(16);
  @$pb.TagNumber(17)
  set ingredients($core.String value) => $_setString(16, value);
  @$pb.TagNumber(17)
  $core.bool hasIngredients() => $_has(16);
  @$pb.TagNumber(17)
  void clearIngredients() => $_clearField(17);

  /// Категории и классификация
  @$pb.TagNumber(18)
  Category get category => $_getN(17);
  @$pb.TagNumber(18)
  set category(Category value) => $_setField(18, value);
  @$pb.TagNumber(18)
  $core.bool hasCategory() => $_has(17);
  @$pb.TagNumber(18)
  void clearCategory() => $_clearField(18);
  @$pb.TagNumber(18)
  Category ensureCategory() => $_ensure(17);

  @$pb.TagNumber(19)
  $pb.PbList<Category> get categoriesInstock => $_getList(18);

  @$pb.TagNumber(20)
  ProductType get type => $_getN(19);
  @$pb.TagNumber(20)
  set type(ProductType value) => $_setField(20, value);
  @$pb.TagNumber(20)
  $core.bool hasType() => $_has(19);
  @$pb.TagNumber(20)
  void clearType() => $_clearField(20);
  @$pb.TagNumber(20)
  ProductType ensureType() => $_ensure(19);

  @$pb.TagNumber(21)
  Series get series => $_getN(20);
  @$pb.TagNumber(21)
  set series(Series value) => $_setField(21, value);
  @$pb.TagNumber(21)
  $core.bool hasSeries() => $_has(20);
  @$pb.TagNumber(21)
  void clearSeries() => $_clearField(21);
  @$pb.TagNumber(21)
  Series ensureSeries() => $_ensure(20);

  @$pb.TagNumber(22)
  $core.int get priceListCategoryId => $_getIZ(21);
  @$pb.TagNumber(22)
  set priceListCategoryId($core.int value) => $_setSignedInt32(21, value);
  @$pb.TagNumber(22)
  $core.bool hasPriceListCategoryId() => $_has(21);
  @$pb.TagNumber(22)
  void clearPriceListCategoryId() => $_clearField(22);

  /// Характеристики
  @$pb.TagNumber(23)
  $pb.PbList<NumericCharacteristic> get numericCharacteristics => $_getList(22);

  @$pb.TagNumber(24)
  $pb.PbList<StringCharacteristic> get stringCharacteristics => $_getList(23);

  @$pb.TagNumber(25)
  $pb.PbList<BoolCharacteristic> get boolCharacteristics => $_getList(24);

  /// Для мобильной синхронизации
  @$pb.TagNumber(26)
  $core.bool get canBuy => $_getBF(25);
  @$pb.TagNumber(26)
  set canBuy($core.bool value) => $_setBool(25, value);
  @$pb.TagNumber(26)
  $core.bool hasCanBuy() => $_has(25);
  @$pb.TagNumber(26)
  void clearCanBuy() => $_clearField(26);

  @$pb.TagNumber(27)
  $core.int get catalogId => $_getIZ(26);
  @$pb.TagNumber(27)
  set catalogId($core.int value) => $_setSignedInt32(26, value);
  @$pb.TagNumber(27)
  $core.bool hasCatalogId() => $_has(26);
  @$pb.TagNumber(27)
  void clearCatalogId() => $_clearField(27);
}

class Brand extends $pb.GeneratedMessage {
  factory Brand({
    $core.int? id,
    $core.String? name,
    $core.String? adaptedName,
    $core.int? searchPriority,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (adaptedName != null) result.adaptedName = adaptedName;
    if (searchPriority != null) result.searchPriority = searchPriority;
    return result;
  }

  Brand._();

  factory Brand.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Brand.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Brand',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'adaptedName')
    ..aI(4, _omitFieldNames ? '' : 'searchPriority')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Brand clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Brand copyWith(void Function(Brand) updates) =>
      super.copyWith((message) => updates(message as Brand)) as Brand;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Brand create() => Brand._();
  @$core.override
  Brand createEmptyInstance() => create();
  static $pb.PbList<Brand> createRepeated() => $pb.PbList<Brand>();
  @$core.pragma('dart2js:noInline')
  static Brand getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Brand>(create);
  static Brand? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get adaptedName => $_getSZ(2);
  @$pb.TagNumber(3)
  set adaptedName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAdaptedName() => $_has(2);
  @$pb.TagNumber(3)
  void clearAdaptedName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get searchPriority => $_getIZ(3);
  @$pb.TagNumber(4)
  set searchPriority($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSearchPriority() => $_has(3);
  @$pb.TagNumber(4)
  void clearSearchPriority() => $_clearField(4);
}

class Manufacturer extends $pb.GeneratedMessage {
  factory Manufacturer({
    $core.int? id,
    $core.String? name,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    return result;
  }

  Manufacturer._();

  factory Manufacturer.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Manufacturer.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Manufacturer',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Manufacturer clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Manufacturer copyWith(void Function(Manufacturer) updates) =>
      super.copyWith((message) => updates(message as Manufacturer))
          as Manufacturer;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Manufacturer create() => Manufacturer._();
  @$core.override
  Manufacturer createEmptyInstance() => create();
  static $pb.PbList<Manufacturer> createRepeated() =>
      $pb.PbList<Manufacturer>();
  @$core.pragma('dart2js:noInline')
  static Manufacturer getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<Manufacturer>(create);
  static Manufacturer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);
}

class ProductImage extends $pb.GeneratedMessage {
  factory ProductImage({
    $core.int? id,
    $core.String? uri,
    $core.String? webp,
    $core.int? width,
    $core.int? height,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (uri != null) result.uri = uri;
    if (webp != null) result.webp = webp;
    if (width != null) result.width = width;
    if (height != null) result.height = height;
    return result;
  }

  ProductImage._();

  factory ProductImage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProductImage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProductImage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'uri')
    ..aOS(3, _omitFieldNames ? '' : 'webp')
    ..aI(4, _omitFieldNames ? '' : 'width')
    ..aI(5, _omitFieldNames ? '' : 'height')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductImage clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductImage copyWith(void Function(ProductImage) updates) =>
      super.copyWith((message) => updates(message as ProductImage))
          as ProductImage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProductImage create() => ProductImage._();
  @$core.override
  ProductImage createEmptyInstance() => create();
  static $pb.PbList<ProductImage> createRepeated() =>
      $pb.PbList<ProductImage>();
  @$core.pragma('dart2js:noInline')
  static ProductImage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProductImage>(create);
  static ProductImage? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get uri => $_getSZ(1);
  @$pb.TagNumber(2)
  set uri($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUri() => $_has(1);
  @$pb.TagNumber(2)
  void clearUri() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get webp => $_getSZ(2);
  @$pb.TagNumber(3)
  set webp($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWebp() => $_has(2);
  @$pb.TagNumber(3)
  void clearWebp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get width => $_getIZ(3);
  @$pb.TagNumber(4)
  set width($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWidth() => $_has(3);
  @$pb.TagNumber(4)
  void clearWidth() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get height => $_getIZ(4);
  @$pb.TagNumber(5)
  set height($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeight() => $_clearField(5);
}

class Category extends $pb.GeneratedMessage {
  factory Category({
    $core.int? id,
    $core.String? name,
    $core.bool? isPublish,
    $core.String? description,
    $core.String? query,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (isPublish != null) result.isPublish = isPublish;
    if (description != null) result.description = description;
    if (query != null) result.query = query;
    return result;
  }

  Category._();

  factory Category.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Category.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Category',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOB(3, _omitFieldNames ? '' : 'isPublish')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aOS(5, _omitFieldNames ? '' : 'query')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Category clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Category copyWith(void Function(Category) updates) =>
      super.copyWith((message) => updates(message as Category)) as Category;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Category create() => Category._();
  @$core.override
  Category createEmptyInstance() => create();
  static $pb.PbList<Category> createRepeated() => $pb.PbList<Category>();
  @$core.pragma('dart2js:noInline')
  static Category getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Category>(create);
  static Category? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get isPublish => $_getBF(2);
  @$pb.TagNumber(3)
  set isPublish($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsPublish() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsPublish() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get query => $_getSZ(4);
  @$pb.TagNumber(5)
  set query($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasQuery() => $_has(4);
  @$pb.TagNumber(5)
  void clearQuery() => $_clearField(5);
}

class ProductType extends $pb.GeneratedMessage {
  factory ProductType({
    $core.int? id,
    $core.String? name,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    return result;
  }

  ProductType._();

  factory ProductType.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProductType.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProductType',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductType clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProductType copyWith(void Function(ProductType) updates) =>
      super.copyWith((message) => updates(message as ProductType))
          as ProductType;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProductType create() => ProductType._();
  @$core.override
  ProductType createEmptyInstance() => create();
  static $pb.PbList<ProductType> createRepeated() => $pb.PbList<ProductType>();
  @$core.pragma('dart2js:noInline')
  static ProductType getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProductType>(create);
  static ProductType? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);
}

class Series extends $pb.GeneratedMessage {
  factory Series({
    $core.int? id,
    $core.String? name,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    return result;
  }

  Series._();

  factory Series.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Series.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Series',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Series clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Series copyWith(void Function(Series) updates) =>
      super.copyWith((message) => updates(message as Series)) as Series;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Series create() => Series._();
  @$core.override
  Series createEmptyInstance() => create();
  static $pb.PbList<Series> createRepeated() => $pb.PbList<Series>();
  @$core.pragma('dart2js:noInline')
  static Series getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Series>(create);
  static Series? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);
}

class NumericCharacteristic extends $pb.GeneratedMessage {
  factory NumericCharacteristic({
    $core.int? attributeId,
    $core.String? attributeName,
    $core.int? id,
    $core.String? type,
    $core.String? adaptValue,
    $core.double? value,
  }) {
    final result = create();
    if (attributeId != null) result.attributeId = attributeId;
    if (attributeName != null) result.attributeName = attributeName;
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (adaptValue != null) result.adaptValue = adaptValue;
    if (value != null) result.value = value;
    return result;
  }

  NumericCharacteristic._();

  factory NumericCharacteristic.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory NumericCharacteristic.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'NumericCharacteristic',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'attributeId')
    ..aOS(2, _omitFieldNames ? '' : 'attributeName')
    ..aI(3, _omitFieldNames ? '' : 'id')
    ..aOS(4, _omitFieldNames ? '' : 'type')
    ..aOS(5, _omitFieldNames ? '' : 'adaptValue')
    ..aD(6, _omitFieldNames ? '' : 'value', fieldType: $pb.PbFieldType.OF)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NumericCharacteristic clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  NumericCharacteristic copyWith(
          void Function(NumericCharacteristic) updates) =>
      super.copyWith((message) => updates(message as NumericCharacteristic))
          as NumericCharacteristic;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static NumericCharacteristic create() => NumericCharacteristic._();
  @$core.override
  NumericCharacteristic createEmptyInstance() => create();
  static $pb.PbList<NumericCharacteristic> createRepeated() =>
      $pb.PbList<NumericCharacteristic>();
  @$core.pragma('dart2js:noInline')
  static NumericCharacteristic getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<NumericCharacteristic>(create);
  static NumericCharacteristic? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get attributeId => $_getIZ(0);
  @$pb.TagNumber(1)
  set attributeId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAttributeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAttributeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get attributeName => $_getSZ(1);
  @$pb.TagNumber(2)
  set attributeName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAttributeName() => $_has(1);
  @$pb.TagNumber(2)
  void clearAttributeName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get id => $_getIZ(2);
  @$pb.TagNumber(3)
  set id($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get type => $_getSZ(3);
  @$pb.TagNumber(4)
  set type($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get adaptValue => $_getSZ(4);
  @$pb.TagNumber(5)
  set adaptValue($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAdaptValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearAdaptValue() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.double get value => $_getN(5);
  @$pb.TagNumber(6)
  set value($core.double value) => $_setFloat(5, value);
  @$pb.TagNumber(6)
  $core.bool hasValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearValue() => $_clearField(6);
}

class StringCharacteristic extends $pb.GeneratedMessage {
  factory StringCharacteristic({
    $core.int? attributeId,
    $core.String? attributeName,
    $core.int? id,
    $core.String? type,
    $core.String? adaptValue,
    $core.int? value,
  }) {
    final result = create();
    if (attributeId != null) result.attributeId = attributeId;
    if (attributeName != null) result.attributeName = attributeName;
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (adaptValue != null) result.adaptValue = adaptValue;
    if (value != null) result.value = value;
    return result;
  }

  StringCharacteristic._();

  factory StringCharacteristic.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StringCharacteristic.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StringCharacteristic',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'attributeId')
    ..aOS(2, _omitFieldNames ? '' : 'attributeName')
    ..aI(3, _omitFieldNames ? '' : 'id')
    ..aOS(4, _omitFieldNames ? '' : 'type')
    ..aOS(5, _omitFieldNames ? '' : 'adaptValue')
    ..aI(6, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StringCharacteristic clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StringCharacteristic copyWith(void Function(StringCharacteristic) updates) =>
      super.copyWith((message) => updates(message as StringCharacteristic))
          as StringCharacteristic;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StringCharacteristic create() => StringCharacteristic._();
  @$core.override
  StringCharacteristic createEmptyInstance() => create();
  static $pb.PbList<StringCharacteristic> createRepeated() =>
      $pb.PbList<StringCharacteristic>();
  @$core.pragma('dart2js:noInline')
  static StringCharacteristic getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StringCharacteristic>(create);
  static StringCharacteristic? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get attributeId => $_getIZ(0);
  @$pb.TagNumber(1)
  set attributeId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAttributeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAttributeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get attributeName => $_getSZ(1);
  @$pb.TagNumber(2)
  set attributeName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAttributeName() => $_has(1);
  @$pb.TagNumber(2)
  void clearAttributeName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get id => $_getIZ(2);
  @$pb.TagNumber(3)
  set id($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get type => $_getSZ(3);
  @$pb.TagNumber(4)
  set type($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get adaptValue => $_getSZ(4);
  @$pb.TagNumber(5)
  set adaptValue($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAdaptValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearAdaptValue() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get value => $_getIZ(5);
  @$pb.TagNumber(6)
  set value($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasValue() => $_has(5);
  @$pb.TagNumber(6)
  void clearValue() => $_clearField(6);
}

class BoolCharacteristic extends $pb.GeneratedMessage {
  factory BoolCharacteristic({
    $core.int? attributeId,
    $core.String? attributeName,
    $core.int? id,
    $core.String? type,
    $core.bool? value,
  }) {
    final result = create();
    if (attributeId != null) result.attributeId = attributeId;
    if (attributeName != null) result.attributeName = attributeName;
    if (id != null) result.id = id;
    if (type != null) result.type = type;
    if (value != null) result.value = value;
    return result;
  }

  BoolCharacteristic._();

  factory BoolCharacteristic.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory BoolCharacteristic.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'BoolCharacteristic',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'attributeId')
    ..aOS(2, _omitFieldNames ? '' : 'attributeName')
    ..aI(3, _omitFieldNames ? '' : 'id')
    ..aOS(4, _omitFieldNames ? '' : 'type')
    ..aOB(5, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoolCharacteristic clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BoolCharacteristic copyWith(void Function(BoolCharacteristic) updates) =>
      super.copyWith((message) => updates(message as BoolCharacteristic))
          as BoolCharacteristic;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BoolCharacteristic create() => BoolCharacteristic._();
  @$core.override
  BoolCharacteristic createEmptyInstance() => create();
  static $pb.PbList<BoolCharacteristic> createRepeated() =>
      $pb.PbList<BoolCharacteristic>();
  @$core.pragma('dart2js:noInline')
  static BoolCharacteristic getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BoolCharacteristic>(create);
  static BoolCharacteristic? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get attributeId => $_getIZ(0);
  @$pb.TagNumber(1)
  set attributeId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAttributeId() => $_has(0);
  @$pb.TagNumber(1)
  void clearAttributeId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get attributeName => $_getSZ(1);
  @$pb.TagNumber(2)
  set attributeName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAttributeName() => $_has(1);
  @$pb.TagNumber(2)
  void clearAttributeName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get id => $_getIZ(2);
  @$pb.TagNumber(3)
  set id($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasId() => $_has(2);
  @$pb.TagNumber(3)
  void clearId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get type => $_getSZ(3);
  @$pb.TagNumber(4)
  set type($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasType() => $_has(3);
  @$pb.TagNumber(4)
  void clearType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get value => $_getBF(4);
  @$pb.TagNumber(5)
  set value($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasValue() => $_has(4);
  @$pb.TagNumber(5)
  void clearValue() => $_clearField(5);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
