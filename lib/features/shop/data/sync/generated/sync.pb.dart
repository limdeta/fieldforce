// This is a generated file - do not edit.
//
// Generated from sync.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'product.pb.dart' as $0;
import 'stockitem.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Запрос базового кеша региона
class RegionalCacheRequest extends $pb.GeneratedMessage {
  factory RegionalCacheRequest({
    $core.String? regionFiasId,
    $fixnum.Int64? lastSyncTimestamp,
    $core.int? limit,
    $core.int? offset,
    $core.bool? forceRefresh,
  }) {
    final result = create();
    if (regionFiasId != null) result.regionFiasId = regionFiasId;
    if (lastSyncTimestamp != null) result.lastSyncTimestamp = lastSyncTimestamp;
    if (limit != null) result.limit = limit;
    if (offset != null) result.offset = offset;
    if (forceRefresh != null) result.forceRefresh = forceRefresh;
    return result;
  }

  RegionalCacheRequest._();

  factory RegionalCacheRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegionalCacheRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegionalCacheRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'regionFiasId')
    ..aInt64(2, _omitFieldNames ? '' : 'lastSyncTimestamp')
    ..aI(3, _omitFieldNames ? '' : 'limit')
    ..aI(4, _omitFieldNames ? '' : 'offset')
    ..aOB(5, _omitFieldNames ? '' : 'forceRefresh')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegionalCacheRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegionalCacheRequest copyWith(void Function(RegionalCacheRequest) updates) =>
      super.copyWith((message) => updates(message as RegionalCacheRequest))
          as RegionalCacheRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegionalCacheRequest create() => RegionalCacheRequest._();
  @$core.override
  RegionalCacheRequest createEmptyInstance() => create();
  static $pb.PbList<RegionalCacheRequest> createRepeated() =>
      $pb.PbList<RegionalCacheRequest>();
  @$core.pragma('dart2js:noInline')
  static RegionalCacheRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegionalCacheRequest>(create);
  static RegionalCacheRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get regionFiasId => $_getSZ(0);
  @$pb.TagNumber(1)
  set regionFiasId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegionFiasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegionFiasId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get lastSyncTimestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set lastSyncTimestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastSyncTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastSyncTimestamp() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get limit => $_getIZ(2);
  @$pb.TagNumber(3)
  set limit($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLimit() => $_has(2);
  @$pb.TagNumber(3)
  void clearLimit() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get offset => $_getIZ(3);
  @$pb.TagNumber(4)
  set offset($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOffset() => $_has(3);
  @$pb.TagNumber(4)
  void clearOffset() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get forceRefresh => $_getBF(4);
  @$pb.TagNumber(5)
  set forceRefresh($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasForceRefresh() => $_has(4);
  @$pb.TagNumber(5)
  void clearForceRefresh() => $_clearField(5);
}

/// Ответ с базовыми данными региона (ТОЛЬКО продукты, БЕЗ остатков и цен)
class RegionalCacheResponse extends $pb.GeneratedMessage {
  factory RegionalCacheResponse({
    $core.Iterable<$0.Product>? products,
    $fixnum.Int64? syncTimestamp,
    CacheStats? stats,
    $core.bool? hasMore,
    $core.String? cacheVersion,
    $core.String? cacheType,
  }) {
    final result = create();
    if (products != null) result.products.addAll(products);
    if (syncTimestamp != null) result.syncTimestamp = syncTimestamp;
    if (stats != null) result.stats = stats;
    if (hasMore != null) result.hasMore = hasMore;
    if (cacheVersion != null) result.cacheVersion = cacheVersion;
    if (cacheType != null) result.cacheType = cacheType;
    return result;
  }

  RegionalCacheResponse._();

  factory RegionalCacheResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegionalCacheResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegionalCacheResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..pPM<$0.Product>(1, _omitFieldNames ? '' : 'products',
        subBuilder: $0.Product.create)
    ..aInt64(2, _omitFieldNames ? '' : 'syncTimestamp')
    ..aOM<CacheStats>(3, _omitFieldNames ? '' : 'stats',
        subBuilder: CacheStats.create)
    ..aOB(4, _omitFieldNames ? '' : 'hasMore')
    ..aOS(5, _omitFieldNames ? '' : 'cacheVersion')
    ..aOS(6, _omitFieldNames ? '' : 'cacheType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegionalCacheResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegionalCacheResponse copyWith(
          void Function(RegionalCacheResponse) updates) =>
      super.copyWith((message) => updates(message as RegionalCacheResponse))
          as RegionalCacheResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegionalCacheResponse create() => RegionalCacheResponse._();
  @$core.override
  RegionalCacheResponse createEmptyInstance() => create();
  static $pb.PbList<RegionalCacheResponse> createRepeated() =>
      $pb.PbList<RegionalCacheResponse>();
  @$core.pragma('dart2js:noInline')
  static RegionalCacheResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegionalCacheResponse>(create);
  static RegionalCacheResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$0.Product> get products => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get syncTimestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set syncTimestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSyncTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearSyncTimestamp() => $_clearField(2);

  @$pb.TagNumber(3)
  CacheStats get stats => $_getN(2);
  @$pb.TagNumber(3)
  set stats(CacheStats value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasStats() => $_has(2);
  @$pb.TagNumber(3)
  void clearStats() => $_clearField(3);
  @$pb.TagNumber(3)
  CacheStats ensureStats() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.bool get hasMore => $_getBF(3);
  @$pb.TagNumber(4)
  set hasMore($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHasMore() => $_has(3);
  @$pb.TagNumber(4)
  void clearHasMore() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cacheVersion => $_getSZ(4);
  @$pb.TagNumber(5)
  set cacheVersion($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCacheVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearCacheVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get cacheType => $_getSZ(5);
  @$pb.TagNumber(6)
  set cacheType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCacheType() => $_has(5);
  @$pb.TagNumber(6)
  void clearCacheType() => $_clearField(6);
}

/// Запрос индивидуальных данных торговой точки
class OutletSpecificRequest extends $pb.GeneratedMessage {
  factory OutletSpecificRequest({
    $core.String? outletVendorId,
    $fixnum.Int64? lastSyncTimestamp,
    $core.Iterable<$core.int>? productCodes,
    $core.bool? includePromotions,
  }) {
    final result = create();
    if (outletVendorId != null) result.outletVendorId = outletVendorId;
    if (lastSyncTimestamp != null) result.lastSyncTimestamp = lastSyncTimestamp;
    if (productCodes != null) result.productCodes.addAll(productCodes);
    if (includePromotions != null) result.includePromotions = includePromotions;
    return result;
  }

  OutletSpecificRequest._();

  factory OutletSpecificRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OutletSpecificRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OutletSpecificRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'outletVendorId')
    ..aInt64(2, _omitFieldNames ? '' : 'lastSyncTimestamp')
    ..p<$core.int>(3, _omitFieldNames ? '' : 'productCodes', $pb.PbFieldType.K3)
    ..aOB(4, _omitFieldNames ? '' : 'includePromotions')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutletSpecificRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutletSpecificRequest copyWith(
          void Function(OutletSpecificRequest) updates) =>
      super.copyWith((message) => updates(message as OutletSpecificRequest))
          as OutletSpecificRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OutletSpecificRequest create() => OutletSpecificRequest._();
  @$core.override
  OutletSpecificRequest createEmptyInstance() => create();
  static $pb.PbList<OutletSpecificRequest> createRepeated() =>
      $pb.PbList<OutletSpecificRequest>();
  @$core.pragma('dart2js:noInline')
  static OutletSpecificRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OutletSpecificRequest>(create);
  static OutletSpecificRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get outletVendorId => $_getSZ(0);
  @$pb.TagNumber(1)
  set outletVendorId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOutletVendorId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOutletVendorId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get lastSyncTimestamp => $_getI64(1);
  @$pb.TagNumber(2)
  set lastSyncTimestamp($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLastSyncTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastSyncTimestamp() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<$core.int> get productCodes => $_getList(2);

  @$pb.TagNumber(4)
  $core.bool get includePromotions => $_getBF(3);
  @$pb.TagNumber(4)
  set includePromotions($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIncludePromotions() => $_has(3);
  @$pb.TagNumber(4)
  void clearIncludePromotions() => $_clearField(4);
}

/// Ответ с индивидуальными данными точки (дифференциальный подход)
class OutletSpecificCacheResponse extends $pb.GeneratedMessage {
  factory OutletSpecificCacheResponse({
    OutletInfo? outletInfo,
    $core.Iterable<$1.OutletStockPricing>? outletPricing,
    $core.Iterable<$1.ActivePromotion>? activePromotions,
    $fixnum.Int64? syncTimestamp,
    $core.String? cacheType,
    CacheStats? stats,
  }) {
    final result = create();
    if (outletInfo != null) result.outletInfo = outletInfo;
    if (outletPricing != null) result.outletPricing.addAll(outletPricing);
    if (activePromotions != null)
      result.activePromotions.addAll(activePromotions);
    if (syncTimestamp != null) result.syncTimestamp = syncTimestamp;
    if (cacheType != null) result.cacheType = cacheType;
    if (stats != null) result.stats = stats;
    return result;
  }

  OutletSpecificCacheResponse._();

  factory OutletSpecificCacheResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OutletSpecificCacheResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OutletSpecificCacheResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aOM<OutletInfo>(1, _omitFieldNames ? '' : 'outletInfo',
        subBuilder: OutletInfo.create)
    ..pPM<$1.OutletStockPricing>(2, _omitFieldNames ? '' : 'outletPricing',
        subBuilder: $1.OutletStockPricing.create)
    ..pPM<$1.ActivePromotion>(3, _omitFieldNames ? '' : 'activePromotions',
        subBuilder: $1.ActivePromotion.create)
    ..aInt64(4, _omitFieldNames ? '' : 'syncTimestamp')
    ..aOS(5, _omitFieldNames ? '' : 'cacheType')
    ..aOM<CacheStats>(6, _omitFieldNames ? '' : 'stats',
        subBuilder: CacheStats.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutletSpecificCacheResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutletSpecificCacheResponse copyWith(
          void Function(OutletSpecificCacheResponse) updates) =>
      super.copyWith(
              (message) => updates(message as OutletSpecificCacheResponse))
          as OutletSpecificCacheResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OutletSpecificCacheResponse create() =>
      OutletSpecificCacheResponse._();
  @$core.override
  OutletSpecificCacheResponse createEmptyInstance() => create();
  static $pb.PbList<OutletSpecificCacheResponse> createRepeated() =>
      $pb.PbList<OutletSpecificCacheResponse>();
  @$core.pragma('dart2js:noInline')
  static OutletSpecificCacheResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OutletSpecificCacheResponse>(create);
  static OutletSpecificCacheResponse? _defaultInstance;

  @$pb.TagNumber(1)
  OutletInfo get outletInfo => $_getN(0);
  @$pb.TagNumber(1)
  set outletInfo(OutletInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasOutletInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearOutletInfo() => $_clearField(1);
  @$pb.TagNumber(1)
  OutletInfo ensureOutletInfo() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<$1.OutletStockPricing> get outletPricing => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<$1.ActivePromotion> get activePromotions => $_getList(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get syncTimestamp => $_getI64(3);
  @$pb.TagNumber(4)
  set syncTimestamp($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSyncTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearSyncTimestamp() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get cacheType => $_getSZ(4);
  @$pb.TagNumber(5)
  set cacheType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCacheType() => $_has(4);
  @$pb.TagNumber(5)
  void clearCacheType() => $_clearField(5);

  @$pb.TagNumber(6)
  CacheStats get stats => $_getN(5);
  @$pb.TagNumber(6)
  set stats(CacheStats value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasStats() => $_has(5);
  @$pb.TagNumber(6)
  void clearStats() => $_clearField(6);
  @$pb.TagNumber(6)
  CacheStats ensureStats() => $_ensure(5);
}

/// Информация о торговой точке
class OutletInfo extends $pb.GeneratedMessage {
  factory OutletInfo({
    $core.int? id,
    $core.String? vendorId,
    $core.String? title,
    $core.String? regionFiasId,
    $core.int? regionalUnitId,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (vendorId != null) result.vendorId = vendorId;
    if (title != null) result.title = title;
    if (regionFiasId != null) result.regionFiasId = regionFiasId;
    if (regionalUnitId != null) result.regionalUnitId = regionalUnitId;
    return result;
  }

  OutletInfo._();

  factory OutletInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OutletInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OutletInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'vendorId')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'regionFiasId')
    ..aI(5, _omitFieldNames ? '' : 'regionalUnitId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutletInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutletInfo copyWith(void Function(OutletInfo) updates) =>
      super.copyWith((message) => updates(message as OutletInfo)) as OutletInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OutletInfo create() => OutletInfo._();
  @$core.override
  OutletInfo createEmptyInstance() => create();
  static $pb.PbList<OutletInfo> createRepeated() => $pb.PbList<OutletInfo>();
  @$core.pragma('dart2js:noInline')
  static OutletInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OutletInfo>(create);
  static OutletInfo? _defaultInstance;

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
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get regionFiasId => $_getSZ(3);
  @$pb.TagNumber(4)
  set regionFiasId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRegionFiasId() => $_has(3);
  @$pb.TagNumber(4)
  void clearRegionFiasId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get regionalUnitId => $_getIZ(4);
  @$pb.TagNumber(5)
  set regionalUnitId($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasRegionalUnitId() => $_has(4);
  @$pb.TagNumber(5)
  void clearRegionalUnitId() => $_clearField(5);
}

/// Индивидуальные цены для торговой точки (legacy - для обратной совместимости)
class OutletPricing extends $pb.GeneratedMessage {
  factory OutletPricing({
    $core.int? productCode,
    $core.int? outletPrice,
    $core.int? regionalBasePrice,
    $core.int? discountAmount,
    $core.double? discountPercent,
    $core.bool? hasIndividualDiscount,
  }) {
    final result = create();
    if (productCode != null) result.productCode = productCode;
    if (outletPrice != null) result.outletPrice = outletPrice;
    if (regionalBasePrice != null) result.regionalBasePrice = regionalBasePrice;
    if (discountAmount != null) result.discountAmount = discountAmount;
    if (discountPercent != null) result.discountPercent = discountPercent;
    if (hasIndividualDiscount != null)
      result.hasIndividualDiscount = hasIndividualDiscount;
    return result;
  }

  OutletPricing._();

  factory OutletPricing.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory OutletPricing.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'OutletPricing',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'productCode')
    ..aI(2, _omitFieldNames ? '' : 'outletPrice')
    ..aI(3, _omitFieldNames ? '' : 'regionalBasePrice')
    ..aI(4, _omitFieldNames ? '' : 'discountAmount')
    ..aD(5, _omitFieldNames ? '' : 'discountPercent',
        fieldType: $pb.PbFieldType.OF)
    ..aOB(6, _omitFieldNames ? '' : 'hasIndividualDiscount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutletPricing clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OutletPricing copyWith(void Function(OutletPricing) updates) =>
      super.copyWith((message) => updates(message as OutletPricing))
          as OutletPricing;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OutletPricing create() => OutletPricing._();
  @$core.override
  OutletPricing createEmptyInstance() => create();
  static $pb.PbList<OutletPricing> createRepeated() =>
      $pb.PbList<OutletPricing>();
  @$core.pragma('dart2js:noInline')
  static OutletPricing getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<OutletPricing>(create);
  static OutletPricing? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get productCode => $_getIZ(0);
  @$pb.TagNumber(1)
  set productCode($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProductCode() => $_has(0);
  @$pb.TagNumber(1)
  void clearProductCode() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get outletPrice => $_getIZ(1);
  @$pb.TagNumber(2)
  set outletPrice($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOutletPrice() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutletPrice() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get regionalBasePrice => $_getIZ(2);
  @$pb.TagNumber(3)
  set regionalBasePrice($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRegionalBasePrice() => $_has(2);
  @$pb.TagNumber(3)
  void clearRegionalBasePrice() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get discountAmount => $_getIZ(3);
  @$pb.TagNumber(4)
  set discountAmount($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDiscountAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearDiscountAmount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get discountPercent => $_getN(4);
  @$pb.TagNumber(5)
  set discountPercent($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDiscountPercent() => $_has(4);
  @$pb.TagNumber(5)
  void clearDiscountPercent() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get hasIndividualDiscount => $_getBF(5);
  @$pb.TagNumber(6)
  set hasIndividualDiscount($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHasIndividualDiscount() => $_has(5);
  @$pb.TagNumber(6)
  void clearHasIndividualDiscount() => $_clearField(6);
}

/// Статистика кеша
class CacheStats extends $pb.GeneratedMessage {
  factory CacheStats({
    $core.String? regionFiasId,
    $core.int? productsCount,
    $core.int? stockItemsCount,
    $fixnum.Int64? cacheSizeBytes,
    $core.double? generationTimeSeconds,
    $fixnum.Int64? lastUpdated,
  }) {
    final result = create();
    if (regionFiasId != null) result.regionFiasId = regionFiasId;
    if (productsCount != null) result.productsCount = productsCount;
    if (stockItemsCount != null) result.stockItemsCount = stockItemsCount;
    if (cacheSizeBytes != null) result.cacheSizeBytes = cacheSizeBytes;
    if (generationTimeSeconds != null)
      result.generationTimeSeconds = generationTimeSeconds;
    if (lastUpdated != null) result.lastUpdated = lastUpdated;
    return result;
  }

  CacheStats._();

  factory CacheStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory CacheStats.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'CacheStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'regionFiasId')
    ..aI(2, _omitFieldNames ? '' : 'productsCount')
    ..aI(3, _omitFieldNames ? '' : 'stockItemsCount')
    ..aInt64(4, _omitFieldNames ? '' : 'cacheSizeBytes')
    ..aD(5, _omitFieldNames ? '' : 'generationTimeSeconds',
        fieldType: $pb.PbFieldType.OF)
    ..aInt64(6, _omitFieldNames ? '' : 'lastUpdated')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CacheStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CacheStats copyWith(void Function(CacheStats) updates) =>
      super.copyWith((message) => updates(message as CacheStats)) as CacheStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CacheStats create() => CacheStats._();
  @$core.override
  CacheStats createEmptyInstance() => create();
  static $pb.PbList<CacheStats> createRepeated() => $pb.PbList<CacheStats>();
  @$core.pragma('dart2js:noInline')
  static CacheStats getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CacheStats>(create);
  static CacheStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get regionFiasId => $_getSZ(0);
  @$pb.TagNumber(1)
  set regionFiasId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRegionFiasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegionFiasId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get productsCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set productsCount($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProductsCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearProductsCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get stockItemsCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set stockItemsCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStockItemsCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearStockItemsCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get cacheSizeBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set cacheSizeBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCacheSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearCacheSizeBytes() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get generationTimeSeconds => $_getN(4);
  @$pb.TagNumber(5)
  set generationTimeSeconds($core.double value) => $_setFloat(4, value);
  @$pb.TagNumber(5)
  $core.bool hasGenerationTimeSeconds() => $_has(4);
  @$pb.TagNumber(5)
  void clearGenerationTimeSeconds() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get lastUpdated => $_getI64(5);
  @$pb.TagNumber(6)
  set lastUpdated($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLastUpdated() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastUpdated() => $_clearField(6);
}

/// Ответ с остатками на складах в регионе (ТОЛЬКО остатки + базовые цены)
class RegionalStockResponse extends $pb.GeneratedMessage {
  factory RegionalStockResponse({
    RegionInfo? regionInfo,
    $core.Iterable<$1.RegionalStockItem>? stockItems,
    $fixnum.Int64? syncTimestamp,
    $core.String? cacheType,
    CacheStats? stats,
  }) {
    final result = create();
    if (regionInfo != null) result.regionInfo = regionInfo;
    if (stockItems != null) result.stockItems.addAll(stockItems);
    if (syncTimestamp != null) result.syncTimestamp = syncTimestamp;
    if (cacheType != null) result.cacheType = cacheType;
    if (stats != null) result.stats = stats;
    return result;
  }

  RegionalStockResponse._();

  factory RegionalStockResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegionalStockResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegionalStockResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aOM<RegionInfo>(1, _omitFieldNames ? '' : 'regionInfo',
        subBuilder: RegionInfo.create)
    ..pPM<$1.RegionalStockItem>(2, _omitFieldNames ? '' : 'stockItems',
        subBuilder: $1.RegionalStockItem.create)
    ..aInt64(3, _omitFieldNames ? '' : 'syncTimestamp')
    ..aOS(4, _omitFieldNames ? '' : 'cacheType')
    ..aOM<CacheStats>(5, _omitFieldNames ? '' : 'stats',
        subBuilder: CacheStats.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegionalStockResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegionalStockResponse copyWith(
          void Function(RegionalStockResponse) updates) =>
      super.copyWith((message) => updates(message as RegionalStockResponse))
          as RegionalStockResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegionalStockResponse create() => RegionalStockResponse._();
  @$core.override
  RegionalStockResponse createEmptyInstance() => create();
  static $pb.PbList<RegionalStockResponse> createRepeated() =>
      $pb.PbList<RegionalStockResponse>();
  @$core.pragma('dart2js:noInline')
  static RegionalStockResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegionalStockResponse>(create);
  static RegionalStockResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RegionInfo get regionInfo => $_getN(0);
  @$pb.TagNumber(1)
  set regionInfo(RegionInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRegionInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearRegionInfo() => $_clearField(1);
  @$pb.TagNumber(1)
  RegionInfo ensureRegionInfo() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<$1.RegionalStockItem> get stockItems => $_getList(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get syncTimestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set syncTimestamp($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSyncTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearSyncTimestamp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get cacheType => $_getSZ(3);
  @$pb.TagNumber(4)
  set cacheType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCacheType() => $_has(3);
  @$pb.TagNumber(4)
  void clearCacheType() => $_clearField(4);

  @$pb.TagNumber(5)
  CacheStats get stats => $_getN(4);
  @$pb.TagNumber(5)
  set stats(CacheStats value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStats() => $_has(4);
  @$pb.TagNumber(5)
  void clearStats() => $_clearField(5);
  @$pb.TagNumber(5)
  CacheStats ensureStats() => $_ensure(4);
}

/// Информация о регионе
class RegionInfo extends $pb.GeneratedMessage {
  factory RegionInfo({
    $core.int? id,
    $core.String? fiasId,
    $core.String? title,
  }) {
    final result = create();
    if (id != null) result.id = id;
    if (fiasId != null) result.fiasId = fiasId;
    if (title != null) result.title = title;
    return result;
  }

  RegionInfo._();

  factory RegionInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory RegionInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'RegionInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mobile_sync'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fiasId')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegionInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RegionInfo copyWith(void Function(RegionInfo) updates) =>
      super.copyWith((message) => updates(message as RegionInfo)) as RegionInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RegionInfo create() => RegionInfo._();
  @$core.override
  RegionInfo createEmptyInstance() => create();
  static $pb.PbList<RegionInfo> createRepeated() => $pb.PbList<RegionInfo>();
  @$core.pragma('dart2js:noInline')
  static RegionInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RegionInfo>(create);
  static RegionInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fiasId => $_getSZ(1);
  @$pb.TagNumber(2)
  set fiasId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFiasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearFiasId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => $_clearField(3);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
