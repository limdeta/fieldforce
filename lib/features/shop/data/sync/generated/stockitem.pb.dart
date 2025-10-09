// This is a generated file - do not edit.
//
// Generated from stockitem.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Детали акции
class PromotionDetails extends $pb.GeneratedMessage {
  factory PromotionDetails({
    $core.double? discountPercent,
    $core.int? discountAmount,
    $core.int? buyQuantity,
    $core.int? getQuantity,
    $core.Iterable<$core.int>? bundleProducts,
    $core.int? bundlePrice,
    $core.int? minQuantity,
    $core.int? maxQuantity,
    $core.int? minAmount,
  }) {
    final result = create();
    if (discountPercent != null) result.discountPercent = discountPercent;
    if (discountAmount != null) result.discountAmount = discountAmount;
    if (buyQuantity != null) result.buyQuantity = buyQuantity;
    if (getQuantity != null) result.getQuantity = getQuantity;
    if (bundleProducts != null) result.bundleProducts.addAll(bundleProducts);
    if (bundlePrice != null) result.bundlePrice = bundlePrice;
    if (minQuantity != null) result.minQuantity = minQuantity;
    if (maxQuantity != null) result.maxQuantity = maxQuantity;
    if (minAmount != null) result.minAmount = minAmount;
    return result;
  }

  PromotionDetails._();

  factory PromotionDetails.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PromotionDetails.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PromotionDetails',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'discountPercent',
        fieldType: $pb.PbFieldType.OF)
    ..aI(2, _omitFieldNames ? '' : 'discountAmount')
    ..aI(3, _omitFieldNames ? '' : 'buyQuantity')
    ..aI(4, _omitFieldNames ? '' : 'getQuantity')
    ..p<$core.int>(
        5, _omitFieldNames ? '' : 'bundleProducts', $pb.PbFieldType.K3)
    ..aI(6, _omitFieldNames ? '' : 'bundlePrice')
    ..aI(7, _omitFieldNames ? '' : 'minQuantity')
    ..aI(8, _omitFieldNames ? '' : 'maxQuantity')
    ..aI(9, _omitFieldNames ? '' : 'minAmount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromotionDetails clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromotionDetails copyWith(void Function(PromotionDetails) updates) =>
      super.copyWith((message) => updates(message as PromotionDetails))
          as PromotionDetails;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PromotionDetails create() => PromotionDetails._();
  @$core.override
  PromotionDetails createEmptyInstance() => create();
  static $pb.PbList<PromotionDetails> createRepeated() =>
      $pb.PbList<PromotionDetails>();
  @$core.pragma('dart2js:noInline')
  static PromotionDetails getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PromotionDetails>(create);
  static PromotionDetails? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get discountPercent => $_getN(0);
  @$pb.TagNumber(1)
  set discountPercent($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDiscountPercent() => $_has(0);
  @$pb.TagNumber(1)
  void clearDiscountPercent() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get discountAmount => $_getIZ(1);
  @$pb.TagNumber(2)
  set discountAmount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDiscountAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearDiscountAmount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get buyQuantity => $_getIZ(2);
  @$pb.TagNumber(3)
  set buyQuantity($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBuyQuantity() => $_has(2);
  @$pb.TagNumber(3)
  void clearBuyQuantity() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get getQuantity => $_getIZ(3);
  @$pb.TagNumber(4)
  set getQuantity($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGetQuantity() => $_has(3);
  @$pb.TagNumber(4)
  void clearGetQuantity() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.int> get bundleProducts => $_getList(4);

  @$pb.TagNumber(6)
  $core.int get bundlePrice => $_getIZ(5);
  @$pb.TagNumber(6)
  set bundlePrice($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBundlePrice() => $_has(5);
  @$pb.TagNumber(6)
  void clearBundlePrice() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get minQuantity => $_getIZ(6);
  @$pb.TagNumber(7)
  set minQuantity($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMinQuantity() => $_has(6);
  @$pb.TagNumber(7)
  void clearMinQuantity() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get maxQuantity => $_getIZ(7);
  @$pb.TagNumber(8)
  set maxQuantity($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMaxQuantity() => $_has(7);
  @$pb.TagNumber(8)
  void clearMaxQuantity() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get minAmount => $_getIZ(8);
  @$pb.TagNumber(9)
  set minAmount($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasMinAmount() => $_has(8);
  @$pb.TagNumber(9)
  void clearMinAmount() => $_clearField(9);
}

/// Активные акции для торговой точки
class ActivePromotion extends $pb.GeneratedMessage {
  factory ActivePromotion({
    $core.int? promotionId,
    $core.String? promotionType,
    $core.String? title,
    $core.String? description,
    $fixnum.Int64? validFrom,
    $fixnum.Int64? validTo,
    $core.Iterable<$core.int>? applicableProducts,
    PromotionDetails? details,
  }) {
    final result = create();
    if (promotionId != null) result.promotionId = promotionId;
    if (promotionType != null) result.promotionType = promotionType;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (validFrom != null) result.validFrom = validFrom;
    if (validTo != null) result.validTo = validTo;
    if (applicableProducts != null)
      result.applicableProducts.addAll(applicableProducts);
    if (details != null) result.details = details;
    return result;
  }

  ActivePromotion._();

  factory ActivePromotion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ActivePromotion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ActivePromotion',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'promotionId')
    ..aOS(2, _omitFieldNames ? '' : 'promotionType')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'description')
    ..aInt64(5, _omitFieldNames ? '' : 'validFrom')
    ..aInt64(6, _omitFieldNames ? '' : 'validTo')
    ..p<$core.int>(
        7, _omitFieldNames ? '' : 'applicableProducts', $pb.PbFieldType.K3)
    ..aOM<PromotionDetails>(8, _omitFieldNames ? '' : 'details',
        subBuilder: PromotionDetails.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivePromotion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ActivePromotion copyWith(void Function(ActivePromotion) updates) =>
      super.copyWith((message) => updates(message as ActivePromotion))
          as ActivePromotion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ActivePromotion create() => ActivePromotion._();
  @$core.override
  ActivePromotion createEmptyInstance() => create();
  static $pb.PbList<ActivePromotion> createRepeated() =>
      $pb.PbList<ActivePromotion>();
  @$core.pragma('dart2js:noInline')
  static ActivePromotion getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ActivePromotion>(create);
  static ActivePromotion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get promotionId => $_getIZ(0);
  @$pb.TagNumber(1)
  set promotionId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPromotionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPromotionId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get promotionType => $_getSZ(1);
  @$pb.TagNumber(2)
  set promotionType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPromotionType() => $_has(1);
  @$pb.TagNumber(2)
  void clearPromotionType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get description => $_getSZ(3);
  @$pb.TagNumber(4)
  set description($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescription() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescription() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get validFrom => $_getI64(4);
  @$pb.TagNumber(5)
  set validFrom($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasValidFrom() => $_has(4);
  @$pb.TagNumber(5)
  void clearValidFrom() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get validTo => $_getI64(5);
  @$pb.TagNumber(6)
  set validTo($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasValidTo() => $_has(5);
  @$pb.TagNumber(6)
  void clearValidTo() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<$core.int> get applicableProducts => $_getList(6);

  @$pb.TagNumber(8)
  PromotionDetails get details => $_getN(7);
  @$pb.TagNumber(8)
  set details(PromotionDetails value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasDetails() => $_has(7);
  @$pb.TagNumber(8)
  void clearDetails() => $_clearField(8);
  @$pb.TagNumber(8)
  PromotionDetails ensureDetails() => $_ensure(7);
}

/// Условия акции
class PromoCondition extends $pb.GeneratedMessage {
  factory PromoCondition({
    $core.int? id,
    $core.int? typesCount,
    $core.int? quantityByTypes,
    $core.int? limitQuantity,
    $core.int? limitQuantityForDocument,
    $core.int? limitQuantityForEachGoods,
    $core.int? limitQuantityForTradePoint,
    $core.int? totalQuantity,
    $core.String? type,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (typesCount != null) result.typesCount = typesCount;
    if (quantityByTypes != null) result.quantityByTypes = quantityByTypes;
    if (limitQuantity != null) result.limitQuantity = limitQuantity;
    if (limitQuantityForDocument != null)
      result.limitQuantityForDocument = limitQuantityForDocument;
    if (limitQuantityForEachGoods != null)
      result.limitQuantityForEachGoods = limitQuantityForEachGoods;
    if (limitQuantityForTradePoint != null)
      result.limitQuantityForTradePoint = limitQuantityForTradePoint;
    if (totalQuantity != null) result.totalQuantity = totalQuantity;
    if (type != null) result.type = type;
    return result;
  }

  PromoCondition._();

  factory PromoCondition.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory PromoCondition.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'PromoCondition',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'typesCount')
    ..aI(3, _omitFieldNames ? '' : 'quantityByTypes')
    ..aI(4, _omitFieldNames ? '' : 'limitQuantity')
    ..aI(5, _omitFieldNames ? '' : 'limitQuantityForDocument')
    ..aI(6, _omitFieldNames ? '' : 'limitQuantityForEachGoods')
    ..aI(7, _omitFieldNames ? '' : 'limitQuantityForTradePoint')
    ..aI(8, _omitFieldNames ? '' : 'totalQuantity')
    ..aOS(9, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromoCondition clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromoCondition copyWith(void Function(PromoCondition) updates) =>
      super.copyWith((message) => updates(message as PromoCondition))
          as PromoCondition;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PromoCondition create() => PromoCondition._();
  @$core.override
  PromoCondition createEmptyInstance() => create();
  static $pb.PbList<PromoCondition> createRepeated() =>
      $pb.PbList<PromoCondition>();
  @$core.pragma('dart2js:noInline')
  static PromoCondition getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PromoCondition>(create);
  static PromoCondition? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get typesCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set typesCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTypesCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTypesCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get quantityByTypes => $_getIZ(2);
  @$pb.TagNumber(3)
  set quantityByTypes($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasQuantityByTypes() => $_has(2);
  @$pb.TagNumber(3)
  void clearQuantityByTypes() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get limitQuantity => $_getIZ(3);
  @$pb.TagNumber(4)
  set limitQuantity($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLimitQuantity() => $_has(3);
  @$pb.TagNumber(4)
  void clearLimitQuantity() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get limitQuantityForDocument => $_getIZ(4);
  @$pb.TagNumber(5)
  set limitQuantityForDocument($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasLimitQuantityForDocument() => $_has(4);
  @$pb.TagNumber(5)
  void clearLimitQuantityForDocument() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get limitQuantityForEachGoods => $_getIZ(5);
  @$pb.TagNumber(6)
  set limitQuantityForEachGoods($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLimitQuantityForEachGoods() => $_has(5);
  @$pb.TagNumber(6)
  void clearLimitQuantityForEachGoods() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get limitQuantityForTradePoint => $_getIZ(6);
  @$pb.TagNumber(7)
  set limitQuantityForTradePoint($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLimitQuantityForTradePoint() => $_has(6);
  @$pb.TagNumber(7)
  void clearLimitQuantityForTradePoint() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get totalQuantity => $_getIZ(7);
  @$pb.TagNumber(8)
  set totalQuantity($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTotalQuantity() => $_has(7);
  @$pb.TagNumber(8)
  void clearTotalQuantity() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get type => $_getSZ(8);
  @$pb.TagNumber(9)
  set type($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasType() => $_has(8);
  @$pb.TagNumber(9)
  void clearType() => $_clearField(9);
}

/// Склад
class Warehouse extends $pb.GeneratedMessage {
  factory Warehouse({
    $core.int? id,
    $core.String? name,
    $core.String? vendorId,
    $core.bool? isPickUpPoint,
    $core.String? regionFiasId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (vendorId != null) result.vendorId = vendorId;
    if (isPickUpPoint != null) result.isPickUpPoint = isPickUpPoint;
    if (regionFiasId != null) result.regionFiasId = regionFiasId;
    return result;
  }

  Warehouse._();

  factory Warehouse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Warehouse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Warehouse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'vendorId')
    ..aOB(4, _omitFieldNames ? '' : 'isPickUpPoint')
    ..aOS(5, _omitFieldNames ? '' : 'regionFiasId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Warehouse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Warehouse copyWith(void Function(Warehouse) updates) =>
      super.copyWith((message) => updates(message as Warehouse)) as Warehouse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Warehouse create() => Warehouse._();
  @$core.override
  Warehouse createEmptyInstance() => create();
  static $pb.PbList<Warehouse> createRepeated() => $pb.PbList<Warehouse>();
  @$core.pragma('dart2js:noInline')
  static Warehouse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Warehouse>(create);
  static Warehouse? _defaultInstance;

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
  $core.String get vendorId => $_getSZ(2);
  @$pb.TagNumber(3)
  set vendorId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVendorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearVendorId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isPickUpPoint => $_getBF(3);
  @$pb.TagNumber(4)
  set isPickUpPoint($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsPickUpPoint() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsPickUpPoint() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get regionFiasId => $_getSZ(4);
  @$pb.TagNumber(5)
  set regionFiasId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRegionFiasId() => $_has(4);
  @$pb.TagNumber(5)
  void clearRegionFiasId() => $_clearField(5);
}

/// Акция (полная структура для legacy StockItem)
class Promotion extends $pb.GeneratedMessage {
  factory Promotion({
    $core.int? id,
    $core.String? vendorId,
    $core.String? vendorName,
    $core.String? title,
    $core.String? description,
    $core.String? caption,
    $core.String? backgroundColor,
    $core.String? url,
    $core.String? banner,
    $core.String? bannerFull,
    $core.String? wobbler,
    $core.String? start,
    $core.String? finish,
    $core.String? shipmentStart,
    $core.String? shipmentFinish,
    $core.String? promotionConditionsDescription,
    PromoCondition? promoCondition,
    $core.Iterable<$core.String>? promotionLimits,
    $core.bool? isPortalPromo,
    $core.String? type,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (vendorId != null) result.vendorId = vendorId;
    if (vendorName != null) result.vendorName = vendorName;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (caption != null) result.caption = caption;
    if (backgroundColor != null) result.backgroundColor = backgroundColor;
    if (url != null) result.url = url;
    if (banner != null) result.banner = banner;
    if (bannerFull != null) result.bannerFull = bannerFull;
    if (wobbler != null) result.wobbler = wobbler;
    if (start != null) result.start = start;
    if (finish != null) result.finish = finish;
    if (shipmentStart != null) result.shipmentStart = shipmentStart;
    if (shipmentFinish != null) result.shipmentFinish = shipmentFinish;
    if (promotionConditionsDescription != null)
      result.promotionConditionsDescription = promotionConditionsDescription;
    if (promoCondition != null) result.promoCondition = promoCondition;
    if (promotionLimits != null) result.promotionLimits.addAll(promotionLimits);
    if (isPortalPromo != null) result.isPortalPromo = isPortalPromo;
    if (type != null) result.type = type;
    return result;
  }

  Promotion._();

  factory Promotion.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Promotion.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Promotion',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'vendorId')
    ..aOS(3, _omitFieldNames ? '' : 'vendorName')
    ..aOS(4, _omitFieldNames ? '' : 'title')
    ..aOS(5, _omitFieldNames ? '' : 'description')
    ..aOS(6, _omitFieldNames ? '' : 'caption')
    ..aOS(7, _omitFieldNames ? '' : 'backgroundColor')
    ..aOS(8, _omitFieldNames ? '' : 'url')
    ..aOS(9, _omitFieldNames ? '' : 'banner')
    ..aOS(10, _omitFieldNames ? '' : 'bannerFull')
    ..aOS(11, _omitFieldNames ? '' : 'wobbler')
    ..aOS(12, _omitFieldNames ? '' : 'start')
    ..aOS(13, _omitFieldNames ? '' : 'finish')
    ..aOS(14, _omitFieldNames ? '' : 'shipmentStart')
    ..aOS(15, _omitFieldNames ? '' : 'shipmentFinish')
    ..aOS(16, _omitFieldNames ? '' : 'promotionConditionsDescription')
    ..aOM<PromoCondition>(17, _omitFieldNames ? '' : 'promoCondition',
        subBuilder: PromoCondition.create)
    ..pPS(18, _omitFieldNames ? '' : 'promotionLimits')
    ..aOB(19, _omitFieldNames ? '' : 'isPortalPromo')
    ..aOS(20, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Promotion clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Promotion copyWith(void Function(Promotion) updates) =>
      super.copyWith((message) => updates(message as Promotion)) as Promotion;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Promotion create() => Promotion._();
  @$core.override
  Promotion createEmptyInstance() => create();
  static $pb.PbList<Promotion> createRepeated() => $pb.PbList<Promotion>();
  @$core.pragma('dart2js:noInline')
  static Promotion getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Promotion>(create);
  static Promotion? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get vendorId => $_getSZ(1);
  @$pb.TagNumber(2)
  set vendorId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVendorId() => $_has(1);
  @$pb.TagNumber(2)
  void clearVendorId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get vendorName => $_getSZ(2);
  @$pb.TagNumber(3)
  set vendorName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVendorName() => $_has(2);
  @$pb.TagNumber(3)
  void clearVendorName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get title => $_getSZ(3);
  @$pb.TagNumber(4)
  set title($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearTitle() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get description => $_getSZ(4);
  @$pb.TagNumber(5)
  set description($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDescription() => $_has(4);
  @$pb.TagNumber(5)
  void clearDescription() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get caption => $_getSZ(5);
  @$pb.TagNumber(6)
  set caption($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCaption() => $_has(5);
  @$pb.TagNumber(6)
  void clearCaption() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get backgroundColor => $_getSZ(6);
  @$pb.TagNumber(7)
  set backgroundColor($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBackgroundColor() => $_has(6);
  @$pb.TagNumber(7)
  void clearBackgroundColor() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get url => $_getSZ(7);
  @$pb.TagNumber(8)
  set url($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasUrl() => $_has(7);
  @$pb.TagNumber(8)
  void clearUrl() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get banner => $_getSZ(8);
  @$pb.TagNumber(9)
  set banner($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasBanner() => $_has(8);
  @$pb.TagNumber(9)
  void clearBanner() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get bannerFull => $_getSZ(9);
  @$pb.TagNumber(10)
  set bannerFull($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasBannerFull() => $_has(9);
  @$pb.TagNumber(10)
  void clearBannerFull() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get wobbler => $_getSZ(10);
  @$pb.TagNumber(11)
  set wobbler($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasWobbler() => $_has(10);
  @$pb.TagNumber(11)
  void clearWobbler() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get start => $_getSZ(11);
  @$pb.TagNumber(12)
  set start($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasStart() => $_has(11);
  @$pb.TagNumber(12)
  void clearStart() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get finish => $_getSZ(12);
  @$pb.TagNumber(13)
  set finish($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasFinish() => $_has(12);
  @$pb.TagNumber(13)
  void clearFinish() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.String get shipmentStart => $_getSZ(13);
  @$pb.TagNumber(14)
  set shipmentStart($core.String value) => $_setString(13, value);
  @$pb.TagNumber(14)
  $core.bool hasShipmentStart() => $_has(13);
  @$pb.TagNumber(14)
  void clearShipmentStart() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.String get shipmentFinish => $_getSZ(14);
  @$pb.TagNumber(15)
  set shipmentFinish($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasShipmentFinish() => $_has(14);
  @$pb.TagNumber(15)
  void clearShipmentFinish() => $_clearField(15);

  @$pb.TagNumber(16)
  $core.String get promotionConditionsDescription => $_getSZ(15);
  @$pb.TagNumber(16)
  set promotionConditionsDescription($core.String value) =>
      $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasPromotionConditionsDescription() => $_has(15);
  @$pb.TagNumber(16)
  void clearPromotionConditionsDescription() => $_clearField(16);

  @$pb.TagNumber(17)
  PromoCondition get promoCondition => $_getN(16);
  @$pb.TagNumber(17)
  set promoCondition(PromoCondition value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasPromoCondition() => $_has(16);
  @$pb.TagNumber(17)
  void clearPromoCondition() => $_clearField(17);
  @$pb.TagNumber(17)
  PromoCondition ensurePromoCondition() => $_ensure(16);

  @$pb.TagNumber(18)
  $pb.PbList<$core.String> get promotionLimits => $_getList(17);

  @$pb.TagNumber(19)
  $core.bool get isPortalPromo => $_getBF(18);
  @$pb.TagNumber(19)
  set isPortalPromo($core.bool value) => $_setBool(18, value);
  @$pb.TagNumber(19)
  $core.bool hasIsPortalPromo() => $_has(18);
  @$pb.TagNumber(19)
  void clearIsPortalPromo() => $_clearField(19);

  @$pb.TagNumber(20)
  $core.String get type => $_getSZ(19);
  @$pb.TagNumber(20)
  set type($core.String value) => $_setString(19, value);
  @$pb.TagNumber(20)
  $core.bool hasType() => $_has(19);
  @$pb.TagNumber(20)
  void clearType() => $_clearField(20);
}

/// Остатки товара с ценами и акциями (legacy)
class StockItem extends $pb.GeneratedMessage {
  factory StockItem({
    $core.int? id,
    $core.int? productCode,
    Warehouse? warehouse,
    $core.String? publicStock,
    $core.int? multiplicity,
    $core.int? defaultPrice,
    $core.int? offerPrice,
    $core.int? availablePrice,
    $core.double? discountValue,
    Promotion? promotion,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (productCode != null) result.productCode = productCode;
    if (warehouse != null) result.warehouse = warehouse;
    if (publicStock != null) result.publicStock = publicStock;
    if (multiplicity != null) result.multiplicity = multiplicity;
    if (defaultPrice != null) result.defaultPrice = defaultPrice;
    if (offerPrice != null) result.offerPrice = offerPrice;
    if (availablePrice != null) result.availablePrice = availablePrice;
    if (discountValue != null) result.discountValue = discountValue;
    if (promotion != null) result.promotion = promotion;
    return result;
  }

  StockItem._();

  factory StockItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory StockItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'StockItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'productCode')
    ..aOM<Warehouse>(3, _omitFieldNames ? '' : 'warehouse',
        subBuilder: Warehouse.create)
    ..aOS(4, _omitFieldNames ? '' : 'publicStock')
    ..aI(5, _omitFieldNames ? '' : 'multiplicity')
    ..aI(6, _omitFieldNames ? '' : 'defaultPrice')
    ..aI(7, _omitFieldNames ? '' : 'offerPrice')
    ..aI(8, _omitFieldNames ? '' : 'availablePrice')
    ..aD(9, _omitFieldNames ? '' : 'discountValue',
        fieldType: $pb.PbFieldType.OF)
    ..aOM<Promotion>(10, _omitFieldNames ? '' : 'promotion',
        subBuilder: Promotion.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StockItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StockItem copyWith(void Function(StockItem) updates) =>
      super.copyWith((message) => updates(message as StockItem)) as StockItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StockItem create() => StockItem._();
  @$core.override
  StockItem createEmptyInstance() => create();
  static $pb.PbList<StockItem> createRepeated() => $pb.PbList<StockItem>();
  @$core.pragma('dart2js:noInline')
  static StockItem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StockItem>(create);
  static StockItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get productCode => $_getIZ(1);
  @$pb.TagNumber(2)
  set productCode($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductCode() => $_clearField(2);

  @$pb.TagNumber(3)
  Warehouse get warehouse => $_getN(2);
  @$pb.TagNumber(3)
  set warehouse(Warehouse value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasWarehouse() => $_has(2);
  @$pb.TagNumber(3)
  void clearWarehouse() => $_clearField(3);
  @$pb.TagNumber(3)
  Warehouse ensureWarehouse() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get publicStock => $_getSZ(3);
  @$pb.TagNumber(4)
  set publicStock($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPublicStock() => $_has(3);
  @$pb.TagNumber(4)
  void clearPublicStock() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get multiplicity => $_getIZ(4);
  @$pb.TagNumber(5)
  set multiplicity($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMultiplicity() => $_has(4);
  @$pb.TagNumber(5)
  void clearMultiplicity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get defaultPrice => $_getIZ(5);
  @$pb.TagNumber(6)
  set defaultPrice($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDefaultPrice() => $_has(5);
  @$pb.TagNumber(6)
  void clearDefaultPrice() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get offerPrice => $_getIZ(6);
  @$pb.TagNumber(7)
  set offerPrice($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasOfferPrice() => $_has(6);
  @$pb.TagNumber(7)
  void clearOfferPrice() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get availablePrice => $_getIZ(7);
  @$pb.TagNumber(8)
  set availablePrice($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasAvailablePrice() => $_has(7);
  @$pb.TagNumber(8)
  void clearAvailablePrice() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get discountValue => $_getN(8);
  @$pb.TagNumber(9)
  set discountValue($core.double value) => $_setFloat(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDiscountValue() => $_has(8);
  @$pb.TagNumber(9)
  void clearDiscountValue() => $_clearField(9);

  @$pb.TagNumber(10)
  Promotion get promotion => $_getN(9);
  @$pb.TagNumber(10)
  set promotion(Promotion value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasPromotion() => $_has(9);
  @$pb.TagNumber(10)
  void clearPromotion() => $_clearField(10);
  @$pb.TagNumber(10)
  Promotion ensurePromotion() => $_ensure(9);
}

/// Региональные остатки (БЕЗ индивидуальных цен торговых точек)
class RegionalStockItem extends $pb.GeneratedMessage {
  factory RegionalStockItem({
    $core.int? id,
    $core.int? productCode,
    Warehouse? warehouse,
    $core.String? publicStock,
    $core.int? multiplicity,
    $core.int? regionalBasePrice,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (productCode != null) result.productCode = productCode;
    if (warehouse != null) result.warehouse = warehouse;
    if (publicStock != null) result.publicStock = publicStock;
    if (multiplicity != null) result.multiplicity = multiplicity;
    if (regionalBasePrice != null) result.regionalBasePrice = regionalBasePrice;
    return result;
  }

  RegionalStockItem._();

  factory RegionalStockItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegionalStockItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegionalStockItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'productCode')
    ..aOM<Warehouse>(3, _omitFieldNames ? '' : 'warehouse',
        subBuilder: Warehouse.create)
    ..aOS(4, _omitFieldNames ? '' : 'publicStock')
    ..aI(5, _omitFieldNames ? '' : 'multiplicity')
    ..aI(6, _omitFieldNames ? '' : 'regionalBasePrice')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegionalStockItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegionalStockItem copyWith(void Function(RegionalStockItem) updates) =>
      super.copyWith((message) => updates(message as RegionalStockItem))
          as RegionalStockItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegionalStockItem create() => RegionalStockItem._();
  @$core.override
  RegionalStockItem createEmptyInstance() => create();
  static $pb.PbList<RegionalStockItem> createRepeated() =>
      $pb.PbList<RegionalStockItem>();
  @$core.pragma('dart2js:noInline')
  static RegionalStockItem getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegionalStockItem>(create);
  static RegionalStockItem? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get productCode => $_getIZ(1);
  @$pb.TagNumber(2)
  set productCode($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductCode() => $_clearField(2);

  @$pb.TagNumber(3)
  Warehouse get warehouse => $_getN(2);
  @$pb.TagNumber(3)
  set warehouse(Warehouse value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasWarehouse() => $_has(2);
  @$pb.TagNumber(3)
  void clearWarehouse() => $_clearField(3);
  @$pb.TagNumber(3)
  Warehouse ensureWarehouse() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get publicStock => $_getSZ(3);
  @$pb.TagNumber(4)
  set publicStock($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPublicStock() => $_has(3);
  @$pb.TagNumber(4)
  void clearPublicStock() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get multiplicity => $_getIZ(4);
  @$pb.TagNumber(5)
  set multiplicity($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMultiplicity() => $_has(4);
  @$pb.TagNumber(5)
  void clearMultiplicity() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get regionalBasePrice => $_getIZ(5);
  @$pb.TagNumber(6)
  set regionalBasePrice($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRegionalBasePrice() => $_has(5);
  @$pb.TagNumber(6)
  void clearRegionalBasePrice() => $_clearField(6);
}

/// Цены для конкретной торговой точки (дифференциальные данные)
class OutletStockPricing extends $pb.GeneratedMessage {
  factory OutletStockPricing({
    $core.int? stockItemId,
    $core.int? productCode,
    $core.int? warehouseId,
    $core.String? outletVendorId,
    $core.int? finalPrice,
    $core.int? priceDifference,
    $core.double? priceDifferencePercent,
    $core.String? priceType,
    $core.double? discountValue,
    $core.bool? hasPromotion,
    ActivePromotion? promotion_11,
  }) {
    final result = create();
    if (stockItemId != null) result.stockItemId = stockItemId;
    if (productCode != null) result.productCode = productCode;
    if (warehouseId != null) result.warehouseId = warehouseId;
    if (outletVendorId != null) result.outletVendorId = outletVendorId;
    if (finalPrice != null) result.finalPrice = finalPrice;
    if (priceDifference != null) result.priceDifference = priceDifference;
    if (priceDifferencePercent != null)
      result.priceDifferencePercent = priceDifferencePercent;
    if (priceType != null) result.priceType = priceType;
    if (discountValue != null) result.discountValue = discountValue;
    if (hasPromotion != null) result.hasPromotion = hasPromotion;
    if (promotion_11 != null) result.promotion_11 = promotion_11;
    return result;
  }

  OutletStockPricing._();

  factory OutletStockPricing.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OutletStockPricing.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OutletStockPricing',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'stockItemId')
    ..aI(2, _omitFieldNames ? '' : 'productCode')
    ..aI(3, _omitFieldNames ? '' : 'warehouseId')
    ..aOS(4, _omitFieldNames ? '' : 'outletVendorId')
    ..aI(5, _omitFieldNames ? '' : 'finalPrice')
    ..aI(6, _omitFieldNames ? '' : 'priceDifference')
    ..aD(7, _omitFieldNames ? '' : 'priceDifferencePercent',
        fieldType: $pb.PbFieldType.OF)
    ..aOS(8, _omitFieldNames ? '' : 'priceType')
    ..aD(9, _omitFieldNames ? '' : 'discountValue',
        fieldType: $pb.PbFieldType.OF)
    ..aOB(10, _omitFieldNames ? '' : 'hasPromotion')
    ..aOM<ActivePromotion>(11, _omitFieldNames ? '' : 'promotion',
        subBuilder: ActivePromotion.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutletStockPricing clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutletStockPricing copyWith(void Function(OutletStockPricing) updates) =>
      super.copyWith((message) => updates(message as OutletStockPricing))
          as OutletStockPricing;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OutletStockPricing create() => OutletStockPricing._();
  @$core.override
  OutletStockPricing createEmptyInstance() => create();
  static $pb.PbList<OutletStockPricing> createRepeated() =>
      $pb.PbList<OutletStockPricing>();
  @$core.pragma('dart2js:noInline')
  static OutletStockPricing getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OutletStockPricing>(create);
  static OutletStockPricing? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get stockItemId => $_getIZ(0);
  @$pb.TagNumber(1)
  set stockItemId($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStockItemId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStockItemId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get productCode => $_getIZ(1);
  @$pb.TagNumber(2)
  set productCode($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductCode() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get warehouseId => $_getIZ(2);
  @$pb.TagNumber(3)
  set warehouseId($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWarehouseId() => $_has(2);
  @$pb.TagNumber(3)
  void clearWarehouseId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get outletVendorId => $_getSZ(3);
  @$pb.TagNumber(4)
  set outletVendorId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOutletVendorId() => $_has(3);
  @$pb.TagNumber(4)
  void clearOutletVendorId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get finalPrice => $_getIZ(4);
  @$pb.TagNumber(5)
  set finalPrice($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFinalPrice() => $_has(4);
  @$pb.TagNumber(5)
  void clearFinalPrice() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get priceDifference => $_getIZ(5);
  @$pb.TagNumber(6)
  set priceDifference($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPriceDifference() => $_has(5);
  @$pb.TagNumber(6)
  void clearPriceDifference() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get priceDifferencePercent => $_getN(6);
  @$pb.TagNumber(7)
  set priceDifferencePercent($core.double value) => $_setFloat(6, value);
  @$pb.TagNumber(7)
  $core.bool hasPriceDifferencePercent() => $_has(6);
  @$pb.TagNumber(7)
  void clearPriceDifferencePercent() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get priceType => $_getSZ(7);
  @$pb.TagNumber(8)
  set priceType($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPriceType() => $_has(7);
  @$pb.TagNumber(8)
  void clearPriceType() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.double get discountValue => $_getN(8);
  @$pb.TagNumber(9)
  set discountValue($core.double value) => $_setFloat(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDiscountValue() => $_has(8);
  @$pb.TagNumber(9)
  void clearDiscountValue() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get hasPromotion => $_getBF(9);
  @$pb.TagNumber(10)
  set hasPromotion($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHasPromotion() => $_has(9);
  @$pb.TagNumber(10)
  void clearHasPromotion() => $_clearField(10);

  @$pb.TagNumber(11)
  ActivePromotion get promotion_11 => $_getN(10);
  @$pb.TagNumber(11)
  set promotion_11(ActivePromotion value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasPromotion_11() => $_has(10);
  @$pb.TagNumber(11)
  void clearPromotion_11() => $_clearField(11);
  @$pb.TagNumber(11)
  ActivePromotion ensurePromotion_11() => $_ensure(10);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
