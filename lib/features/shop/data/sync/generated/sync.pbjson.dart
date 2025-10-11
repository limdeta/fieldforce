// This is a generated file - do not edit.
//
// Generated from sync.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use regionalCacheRequestDescriptor instead')
const RegionalCacheRequest$json = {
  '1': 'RegionalCacheRequest',
  '2': [
    {'1': 'region_fias_id', '3': 1, '4': 1, '5': 9, '10': 'regionFiasId'},
    {
      '1': 'last_sync_timestamp',
      '3': 2,
      '4': 1,
      '5': 3,
      '10': 'lastSyncTimestamp'
    },
    {'1': 'limit', '3': 3, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'offset', '3': 4, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'force_refresh', '3': 5, '4': 1, '5': 8, '10': 'forceRefresh'},
  ],
};

/// Descriptor for `RegionalCacheRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List regionalCacheRequestDescriptor = $convert.base64Decode(
    'ChRSZWdpb25hbENhY2hlUmVxdWVzdBIkCg5yZWdpb25fZmlhc19pZBgBIAEoCVIMcmVnaW9uRm'
    'lhc0lkEi4KE2xhc3Rfc3luY190aW1lc3RhbXAYAiABKANSEWxhc3RTeW5jVGltZXN0YW1wEhQK'
    'BWxpbWl0GAMgASgFUgVsaW1pdBIWCgZvZmZzZXQYBCABKAVSBm9mZnNldBIjCg1mb3JjZV9yZW'
    'ZyZXNoGAUgASgIUgxmb3JjZVJlZnJlc2g=');

@$core.Deprecated('Use regionalCacheResponseDescriptor instead')
const RegionalCacheResponse$json = {
  '1': 'RegionalCacheResponse',
  '2': [
    {
      '1': 'products',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.mobile_sync.Product',
      '10': 'products'
    },
    {'1': 'sync_timestamp', '3': 2, '4': 1, '5': 3, '10': 'syncTimestamp'},
    {
      '1': 'stats',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.CacheStats',
      '10': 'stats'
    },
    {'1': 'has_more', '3': 4, '4': 1, '5': 8, '10': 'hasMore'},
    {'1': 'cache_version', '3': 5, '4': 1, '5': 9, '10': 'cacheVersion'},
    {'1': 'cache_type', '3': 6, '4': 1, '5': 9, '10': 'cacheType'},
  ],
};

/// Descriptor for `RegionalCacheResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List regionalCacheResponseDescriptor = $convert.base64Decode(
    'ChVSZWdpb25hbENhY2hlUmVzcG9uc2USMAoIcHJvZHVjdHMYASADKAsyFC5tb2JpbGVfc3luYy'
    '5Qcm9kdWN0Ughwcm9kdWN0cxIlCg5zeW5jX3RpbWVzdGFtcBgCIAEoA1INc3luY1RpbWVzdGFt'
    'cBItCgVzdGF0cxgDIAEoCzIXLm1vYmlsZV9zeW5jLkNhY2hlU3RhdHNSBXN0YXRzEhkKCGhhc1'
    '9tb3JlGAQgASgIUgdoYXNNb3JlEiMKDWNhY2hlX3ZlcnNpb24YBSABKAlSDGNhY2hlVmVyc2lv'
    'bhIdCgpjYWNoZV90eXBlGAYgASgJUgljYWNoZVR5cGU=');

@$core.Deprecated('Use outletSpecificRequestDescriptor instead')
const OutletSpecificRequest$json = {
  '1': 'OutletSpecificRequest',
  '2': [
    {'1': 'outlet_vendor_id', '3': 1, '4': 1, '5': 9, '10': 'outletVendorId'},
    {
      '1': 'last_sync_timestamp',
      '3': 2,
      '4': 1,
      '5': 3,
      '10': 'lastSyncTimestamp'
    },
    {'1': 'product_codes', '3': 3, '4': 3, '5': 5, '10': 'productCodes'},
    {
      '1': 'include_promotions',
      '3': 4,
      '4': 1,
      '5': 8,
      '10': 'includePromotions'
    },
  ],
};

/// Descriptor for `OutletSpecificRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outletSpecificRequestDescriptor = $convert.base64Decode(
    'ChVPdXRsZXRTcGVjaWZpY1JlcXVlc3QSKAoQb3V0bGV0X3ZlbmRvcl9pZBgBIAEoCVIOb3V0bG'
    'V0VmVuZG9ySWQSLgoTbGFzdF9zeW5jX3RpbWVzdGFtcBgCIAEoA1IRbGFzdFN5bmNUaW1lc3Rh'
    'bXASIwoNcHJvZHVjdF9jb2RlcxgDIAMoBVIMcHJvZHVjdENvZGVzEi0KEmluY2x1ZGVfcHJvbW'
    '90aW9ucxgEIAEoCFIRaW5jbHVkZVByb21vdGlvbnM=');

@$core.Deprecated('Use outletSpecificCacheResponseDescriptor instead')
const OutletSpecificCacheResponse$json = {
  '1': 'OutletSpecificCacheResponse',
  '2': [
    {
      '1': 'outlet_info',
      '3': 1,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.OutletInfo',
      '10': 'outletInfo'
    },
    {
      '1': 'outlet_pricing',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.mobile_sync.OutletStockPricing',
      '10': 'outletPricing'
    },
    {
      '1': 'active_promotions',
      '3': 3,
      '4': 3,
      '5': 11,
      '6': '.mobile_sync.ActivePromotion',
      '10': 'activePromotions'
    },
    {'1': 'sync_timestamp', '3': 4, '4': 1, '5': 3, '10': 'syncTimestamp'},
    {'1': 'cache_type', '3': 5, '4': 1, '5': 9, '10': 'cacheType'},
    {
      '1': 'stats',
      '3': 6,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.CacheStats',
      '10': 'stats'
    },
  ],
};

/// Descriptor for `OutletSpecificCacheResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outletSpecificCacheResponseDescriptor = $convert.base64Decode(
    'ChtPdXRsZXRTcGVjaWZpY0NhY2hlUmVzcG9uc2USOAoLb3V0bGV0X2luZm8YASABKAsyFy5tb2'
    'JpbGVfc3luYy5PdXRsZXRJbmZvUgpvdXRsZXRJbmZvEkYKDm91dGxldF9wcmljaW5nGAIgAygL'
    'Mh8ubW9iaWxlX3N5bmMuT3V0bGV0U3RvY2tQcmljaW5nUg1vdXRsZXRQcmljaW5nEkkKEWFjdG'
    'l2ZV9wcm9tb3Rpb25zGAMgAygLMhwubW9iaWxlX3N5bmMuQWN0aXZlUHJvbW90aW9uUhBhY3Rp'
    'dmVQcm9tb3Rpb25zEiUKDnN5bmNfdGltZXN0YW1wGAQgASgDUg1zeW5jVGltZXN0YW1wEh0KCm'
    'NhY2hlX3R5cGUYBSABKAlSCWNhY2hlVHlwZRItCgVzdGF0cxgGIAEoCzIXLm1vYmlsZV9zeW5j'
    'LkNhY2hlU3RhdHNSBXN0YXRz');

@$core.Deprecated('Use outletInfoDescriptor instead')
const OutletInfo$json = {
  '1': 'OutletInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'vendor_id', '3': 2, '4': 1, '5': 9, '10': 'vendorId'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'region_fias_id', '3': 4, '4': 1, '5': 9, '10': 'regionFiasId'},
    {'1': 'regional_unit_id', '3': 5, '4': 1, '5': 5, '10': 'regionalUnitId'},
  ],
};

/// Descriptor for `OutletInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outletInfoDescriptor = $convert.base64Decode(
    'CgpPdXRsZXRJbmZvEg4KAmlkGAEgASgFUgJpZBIbCgl2ZW5kb3JfaWQYAiABKAlSCHZlbmRvck'
    'lkEhQKBXRpdGxlGAMgASgJUgV0aXRsZRIkCg5yZWdpb25fZmlhc19pZBgEIAEoCVIMcmVnaW9u'
    'Rmlhc0lkEigKEHJlZ2lvbmFsX3VuaXRfaWQYBSABKAVSDnJlZ2lvbmFsVW5pdElk');

@$core.Deprecated('Use outletPricingDescriptor instead')
const OutletPricing$json = {
  '1': 'OutletPricing',
  '2': [
    {'1': 'product_code', '3': 1, '4': 1, '5': 5, '10': 'productCode'},
    {'1': 'outlet_price', '3': 2, '4': 1, '5': 5, '10': 'outletPrice'},
    {
      '1': 'regional_base_price',
      '3': 3,
      '4': 1,
      '5': 5,
      '10': 'regionalBasePrice'
    },
    {'1': 'discount_amount', '3': 4, '4': 1, '5': 5, '10': 'discountAmount'},
    {'1': 'discount_percent', '3': 5, '4': 1, '5': 2, '10': 'discountPercent'},
    {
      '1': 'has_individual_discount',
      '3': 6,
      '4': 1,
      '5': 8,
      '10': 'hasIndividualDiscount'
    },
  ],
};

/// Descriptor for `OutletPricing`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outletPricingDescriptor = $convert.base64Decode(
    'Cg1PdXRsZXRQcmljaW5nEiEKDHByb2R1Y3RfY29kZRgBIAEoBVILcHJvZHVjdENvZGUSIQoMb3'
    'V0bGV0X3ByaWNlGAIgASgFUgtvdXRsZXRQcmljZRIuChNyZWdpb25hbF9iYXNlX3ByaWNlGAMg'
    'ASgFUhFyZWdpb25hbEJhc2VQcmljZRInCg9kaXNjb3VudF9hbW91bnQYBCABKAVSDmRpc2NvdW'
    '50QW1vdW50EikKEGRpc2NvdW50X3BlcmNlbnQYBSABKAJSD2Rpc2NvdW50UGVyY2VudBI2Chdo'
    'YXNfaW5kaXZpZHVhbF9kaXNjb3VudBgGIAEoCFIVaGFzSW5kaXZpZHVhbERpc2NvdW50');

@$core.Deprecated('Use cacheStatsDescriptor instead')
const CacheStats$json = {
  '1': 'CacheStats',
  '2': [
    {'1': 'region_fias_id', '3': 1, '4': 1, '5': 9, '10': 'regionFiasId'},
    {'1': 'products_count', '3': 2, '4': 1, '5': 5, '10': 'productsCount'},
    {'1': 'stock_items_count', '3': 3, '4': 1, '5': 5, '10': 'stockItemsCount'},
    {'1': 'cache_size_bytes', '3': 4, '4': 1, '5': 3, '10': 'cacheSizeBytes'},
    {
      '1': 'generation_time_seconds',
      '3': 5,
      '4': 1,
      '5': 2,
      '10': 'generationTimeSeconds'
    },
    {'1': 'last_updated', '3': 6, '4': 1, '5': 3, '10': 'lastUpdated'},
  ],
};

/// Descriptor for `CacheStats`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cacheStatsDescriptor = $convert.base64Decode(
    'CgpDYWNoZVN0YXRzEiQKDnJlZ2lvbl9maWFzX2lkGAEgASgJUgxyZWdpb25GaWFzSWQSJQoOcH'
    'JvZHVjdHNfY291bnQYAiABKAVSDXByb2R1Y3RzQ291bnQSKgoRc3RvY2tfaXRlbXNfY291bnQY'
    'AyABKAVSD3N0b2NrSXRlbXNDb3VudBIoChBjYWNoZV9zaXplX2J5dGVzGAQgASgDUg5jYWNoZV'
    'NpemVCeXRlcxI2ChdnZW5lcmF0aW9uX3RpbWVfc2Vjb25kcxgFIAEoAlIVZ2VuZXJhdGlvblRp'
    'bWVTZWNvbmRzEiEKDGxhc3RfdXBkYXRlZBgGIAEoA1ILbGFzdFVwZGF0ZWQ=');

@$core.Deprecated('Use regionalStockResponseDescriptor instead')
const RegionalStockResponse$json = {
  '1': 'RegionalStockResponse',
  '2': [
    {
      '1': 'stock_items',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.mobile_sync.RegionalStockItem',
      '10': 'stockItems'
    },
    {'1': 'sync_timestamp', '3': 3, '4': 1, '5': 3, '10': 'syncTimestamp'},
    {'1': 'cache_type', '3': 4, '4': 1, '5': 9, '10': 'cacheType'},
    {
      '1': 'stats',
      '3': 5,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.CacheStats',
      '10': 'stats'
    },
  ],
};

/// Descriptor for `RegionalStockResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List regionalStockResponseDescriptor = $convert.base64Decode(
    'ChVSZWdpb25hbFN0b2NrUmVzcG9uc2USPwoLc3RvY2tfaXRlbXMYAiADKAsyHi5tb2JpbGVfc3'
    'luYy5SZWdpb25hbFN0b2NrSXRlbVIKc3RvY2tJdGVtcxIlCg5zeW5jX3RpbWVzdGFtcBgDIAEo'
    'A1INc3luY1RpbWVzdGFtcBIdCgpjYWNoZV90eXBlGAQgASgJUgljYWNoZVR5cGUSLQoFc3RhdH'
    'MYBSABKAsyFy5tb2JpbGVfc3luYy5DYWNoZVN0YXRzUgVzdGF0cw==');

@$core.Deprecated('Use warehouseSyncRequestDescriptor instead')
const WarehouseSyncRequest$json = {
  '1': 'WarehouseSyncRequest',
  '2': [
    {'1': 'region_vendor_id', '3': 1, '4': 1, '5': 9, '10': 'regionVendorId'},
    {
      '1': 'last_sync_timestamp',
      '3': 2,
      '4': 1,
      '5': 3,
      '10': 'lastSyncTimestamp'
    },
    {'1': 'limit', '3': 3, '4': 1, '5': 5, '10': 'limit'},
    {'1': 'offset', '3': 4, '4': 1, '5': 5, '10': 'offset'},
    {'1': 'force_refresh', '3': 5, '4': 1, '5': 8, '10': 'forceRefresh'},
  ],
};

/// Descriptor for `WarehouseSyncRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List warehouseSyncRequestDescriptor = $convert.base64Decode(
    'ChRXYXJlaG91c2VTeW5jUmVxdWVzdBIoChByZWdpb25fdmVuZG9yX2lkGAEgASgJUg5yZWdpb2'
    '5WZW5kb3JJZBIuChNsYXN0X3N5bmNfdGltZXN0YW1wGAIgASgDUhFsYXN0U3luY1RpbWVzdGFt'
    'cBIUCgVsaW1pdBgDIAEoBVIFbGltaXQSFgoGb2Zmc2V0GAQgASgFUgZvZmZzZXQSIwoNZm9yY2'
    'VfcmVmcmVzaBgFIAEoCFIMZm9yY2VSZWZyZXNo');

@$core.Deprecated('Use warehouseSyncResponseDescriptor instead')
const WarehouseSyncResponse$json = {
  '1': 'WarehouseSyncResponse',
  '2': [
    {
      '1': 'warehouses',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.mobile_sync.WarehouseInfo',
      '10': 'warehouses'
    },
    {'1': 'sync_timestamp', '3': 2, '4': 1, '5': 3, '10': 'syncTimestamp'},
    {
      '1': 'stats',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.CacheStats',
      '10': 'stats'
    },
  ],
};

/// Descriptor for `WarehouseSyncResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List warehouseSyncResponseDescriptor = $convert.base64Decode(
    'ChVXYXJlaG91c2VTeW5jUmVzcG9uc2USOgoKd2FyZWhvdXNlcxgBIAMoCzIaLm1vYmlsZV9zeW'
    '5jLldhcmVob3VzZUluZm9SCndhcmVob3VzZXMSJQoOc3luY190aW1lc3RhbXAYAiABKANSDXN5'
    'bmNUaW1lc3RhbXASLQoFc3RhdHMYAyABKAsyFy5tb2JpbGVfc3luYy5DYWNoZVN0YXRzUgVzdG'
    'F0cw==');

@$core.Deprecated('Use warehouseInfoDescriptor instead')
const WarehouseInfo$json = {
  '1': 'WarehouseInfo',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'vendor_id', '3': 3, '4': 1, '5': 9, '10': 'vendorId'},
    {'1': 'region', '3': 4, '4': 1, '5': 9, '10': 'region'},
  ],
};

/// Descriptor for `WarehouseInfo`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List warehouseInfoDescriptor = $convert.base64Decode(
    'Cg1XYXJlaG91c2VJbmZvEg4KAmlkGAEgASgFUgJpZBISCgRuYW1lGAIgASgJUgRuYW1lEhsKCX'
    'ZlbmRvcl9pZBgDIAEoCVIIdmVuZG9ySWQSFgoGcmVnaW9uGAQgASgJUgZyZWdpb24=');
