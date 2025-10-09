// This is a generated file - do not edit.
//
// Generated from stockitem.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use promotionDetailsDescriptor instead')
const PromotionDetails$json = {
  '1': 'PromotionDetails',
  '2': [
    {'1': 'discount_percent', '3': 1, '4': 1, '5': 2, '10': 'discountPercent'},
    {'1': 'discount_amount', '3': 2, '4': 1, '5': 5, '10': 'discountAmount'},
    {'1': 'buy_quantity', '3': 3, '4': 1, '5': 5, '10': 'buyQuantity'},
    {'1': 'get_quantity', '3': 4, '4': 1, '5': 5, '10': 'getQuantity'},
    {'1': 'bundle_products', '3': 5, '4': 3, '5': 5, '10': 'bundleProducts'},
    {'1': 'bundle_price', '3': 6, '4': 1, '5': 5, '10': 'bundlePrice'},
    {'1': 'min_quantity', '3': 7, '4': 1, '5': 5, '10': 'minQuantity'},
    {'1': 'max_quantity', '3': 8, '4': 1, '5': 5, '10': 'maxQuantity'},
    {'1': 'min_amount', '3': 9, '4': 1, '5': 5, '10': 'minAmount'},
  ],
};

/// Descriptor for `PromotionDetails`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List promotionDetailsDescriptor = $convert.base64Decode(
    'ChBQcm9tb3Rpb25EZXRhaWxzEikKEGRpc2NvdW50X3BlcmNlbnQYASABKAJSD2Rpc2NvdW50UG'
    'VyY2VudBInCg9kaXNjb3VudF9hbW91bnQYAiABKAVSDmRpc2NvdW50QW1vdW50EiEKDGJ1eV9x'
    'dWFudGl0eRgDIAEoBVILYnV5UXVhbnRpdHkSIQoMZ2V0X3F1YW50aXR5GAQgASgFUgtnZXRRdW'
    'FudGl0eRInCg9idW5kbGVfcHJvZHVjdHMYBSADKAVSDmJ1bmRsZVByb2R1Y3RzEiEKDGJ1bmRs'
    'ZV9wcmljZRgGIAEoBVILYnVuZGxlUHJpY2USIQoMbWluX3F1YW50aXR5GAcgASgFUgttaW5RdW'
    'FudGl0eRIhCgxtYXhfcXVhbnRpdHkYCCABKAVSC21heFF1YW50aXR5Eh0KCm1pbl9hbW91bnQY'
    'CSABKAVSCW1pbkFtb3VudA==');

@$core.Deprecated('Use activePromotionDescriptor instead')
const ActivePromotion$json = {
  '1': 'ActivePromotion',
  '2': [
    {'1': 'promotion_id', '3': 1, '4': 1, '5': 5, '10': 'promotionId'},
    {'1': 'promotion_type', '3': 2, '4': 1, '5': 9, '10': 'promotionType'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'valid_from', '3': 5, '4': 1, '5': 3, '10': 'validFrom'},
    {'1': 'valid_to', '3': 6, '4': 1, '5': 3, '10': 'validTo'},
    {
      '1': 'applicable_products',
      '3': 7,
      '4': 3,
      '5': 5,
      '10': 'applicableProducts'
    },
    {
      '1': 'details',
      '3': 8,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.PromotionDetails',
      '10': 'details'
    },
  ],
};

/// Descriptor for `ActivePromotion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List activePromotionDescriptor = $convert.base64Decode(
    'Cg9BY3RpdmVQcm9tb3Rpb24SIQoMcHJvbW90aW9uX2lkGAEgASgFUgtwcm9tb3Rpb25JZBIlCg'
    '5wcm9tb3Rpb25fdHlwZRgCIAEoCVINcHJvbW90aW9uVHlwZRIUCgV0aXRsZRgDIAEoCVIFdGl0'
    'bGUSIAoLZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9uEh0KCnZhbGlkX2Zyb20YBSABKA'
    'NSCXZhbGlkRnJvbRIZCgh2YWxpZF90bxgGIAEoA1IHdmFsaWRUbxIvChNhcHBsaWNhYmxlX3By'
    'b2R1Y3RzGAcgAygFUhJhcHBsaWNhYmxlUHJvZHVjdHMSNwoHZGV0YWlscxgIIAEoCzIdLm1vYm'
    'lsZV9zeW5jLlByb21vdGlvbkRldGFpbHNSB2RldGFpbHM=');

@$core.Deprecated('Use promoConditionDescriptor instead')
const PromoCondition$json = {
  '1': 'PromoCondition',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'types_count', '3': 2, '4': 1, '5': 5, '10': 'typesCount'},
    {'1': 'quantity_by_types', '3': 3, '4': 1, '5': 5, '10': 'quantityByTypes'},
    {'1': 'limit_quantity', '3': 4, '4': 1, '5': 5, '10': 'limitQuantity'},
    {
      '1': 'limit_quantity_for_document',
      '3': 5,
      '4': 1,
      '5': 5,
      '10': 'limitQuantityForDocument'
    },
    {
      '1': 'limit_quantity_for_each_goods',
      '3': 6,
      '4': 1,
      '5': 5,
      '10': 'limitQuantityForEachGoods'
    },
    {
      '1': 'limit_quantity_for_trade_point',
      '3': 7,
      '4': 1,
      '5': 5,
      '10': 'limitQuantityForTradePoint'
    },
    {'1': 'total_quantity', '3': 8, '4': 1, '5': 5, '10': 'totalQuantity'},
    {'1': 'type', '3': 9, '4': 1, '5': 9, '10': 'type'},
  ],
};

/// Descriptor for `PromoCondition`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List promoConditionDescriptor = $convert.base64Decode(
    'Cg5Qcm9tb0NvbmRpdGlvbhIOCgJpZBgBIAEoBVICaWQSHwoLdHlwZXNfY291bnQYAiABKAVSCn'
    'R5cGVzQ291bnQSKgoRcXVhbnRpdHlfYnlfdHlwZXMYAyABKAVSD3F1YW50aXR5QnlUeXBlcxIl'
    'Cg5saW1pdF9xdWFudGl0eRgEIAEoBVINbGltaXRRdWFudGl0eRI9ChtsaW1pdF9xdWFudGl0eV'
    '9mb3JfZG9jdW1lbnQYBSABKAVSGGxpbWl0UXVhbnRpdHlGb3JEb2N1bWVudBJACh1saW1pdF9x'
    'dWFudGl0eV9mb3JfZWFjaF9nb29kcxgGIAEoBVIZbGltaXRRdWFudGl0eUZvckVhY2hHb29kcx'
    'JCCh5saW1pdF9xdWFudGl0eV9mb3JfdHJhZGVfcG9pbnQYByABKAVSGmxpbWl0UXVhbnRpdHlG'
    'b3JUcmFkZVBvaW50EiUKDnRvdGFsX3F1YW50aXR5GAggASgFUg10b3RhbFF1YW50aXR5EhIKBH'
    'R5cGUYCSABKAlSBHR5cGU=');

@$core.Deprecated('Use warehouseDescriptor instead')
const Warehouse$json = {
  '1': 'Warehouse',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'vendor_id', '3': 3, '4': 1, '5': 9, '10': 'vendorId'},
    {'1': 'is_pick_up_point', '3': 4, '4': 1, '5': 8, '10': 'isPickUpPoint'},
    {'1': 'region_fias_id', '3': 5, '4': 1, '5': 9, '10': 'regionFiasId'},
  ],
};

/// Descriptor for `Warehouse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List warehouseDescriptor = $convert.base64Decode(
    'CglXYXJlaG91c2USDgoCaWQYASABKAVSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWUSGwoJdmVuZG'
    '9yX2lkGAMgASgJUgh2ZW5kb3JJZBInChBpc19waWNrX3VwX3BvaW50GAQgASgIUg1pc1BpY2tV'
    'cFBvaW50EiQKDnJlZ2lvbl9maWFzX2lkGAUgASgJUgxyZWdpb25GaWFzSWQ=');

@$core.Deprecated('Use promotionDescriptor instead')
const Promotion$json = {
  '1': 'Promotion',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'vendor_id', '3': 2, '4': 1, '5': 9, '10': 'vendorId'},
    {'1': 'vendor_name', '3': 3, '4': 1, '5': 9, '10': 'vendorName'},
    {'1': 'title', '3': 4, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 5, '4': 1, '5': 9, '10': 'description'},
    {'1': 'caption', '3': 6, '4': 1, '5': 9, '10': 'caption'},
    {'1': 'background_color', '3': 7, '4': 1, '5': 9, '10': 'backgroundColor'},
    {'1': 'url', '3': 8, '4': 1, '5': 9, '10': 'url'},
    {'1': 'banner', '3': 9, '4': 1, '5': 9, '10': 'banner'},
    {'1': 'banner_full', '3': 10, '4': 1, '5': 9, '10': 'bannerFull'},
    {'1': 'wobbler', '3': 11, '4': 1, '5': 9, '10': 'wobbler'},
    {'1': 'start', '3': 12, '4': 1, '5': 9, '10': 'start'},
    {'1': 'finish', '3': 13, '4': 1, '5': 9, '10': 'finish'},
    {'1': 'shipment_start', '3': 14, '4': 1, '5': 9, '10': 'shipmentStart'},
    {'1': 'shipment_finish', '3': 15, '4': 1, '5': 9, '10': 'shipmentFinish'},
    {
      '1': 'promotion_conditions_description',
      '3': 16,
      '4': 1,
      '5': 9,
      '10': 'promotionConditionsDescription'
    },
    {
      '1': 'promo_condition',
      '3': 17,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.PromoCondition',
      '10': 'promoCondition'
    },
    {'1': 'promotion_limits', '3': 18, '4': 3, '5': 9, '10': 'promotionLimits'},
    {'1': 'is_portal_promo', '3': 19, '4': 1, '5': 8, '10': 'isPortalPromo'},
    {'1': 'type', '3': 20, '4': 1, '5': 9, '10': 'type'},
  ],
};

/// Descriptor for `Promotion`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List promotionDescriptor = $convert.base64Decode(
    'CglQcm9tb3Rpb24SDgoCaWQYASABKAVSAmlkEhsKCXZlbmRvcl9pZBgCIAEoCVIIdmVuZG9ySW'
    'QSHwoLdmVuZG9yX25hbWUYAyABKAlSCnZlbmRvck5hbWUSFAoFdGl0bGUYBCABKAlSBXRpdGxl'
    'EiAKC2Rlc2NyaXB0aW9uGAUgASgJUgtkZXNjcmlwdGlvbhIYCgdjYXB0aW9uGAYgASgJUgdjYX'
    'B0aW9uEikKEGJhY2tncm91bmRfY29sb3IYByABKAlSD2JhY2tncm91bmRDb2xvchIQCgN1cmwY'
    'CCABKAlSA3VybBIWCgZiYW5uZXIYCSABKAlSBmJhbm5lchIfCgtiYW5uZXJfZnVsbBgKIAEoCV'
    'IKYmFubmVyRnVsbBIYCgd3b2JibGVyGAsgASgJUgd3b2JibGVyEhQKBXN0YXJ0GAwgASgJUgVz'
    'dGFydBIWCgZmaW5pc2gYDSABKAlSBmZpbmlzaBIlCg5zaGlwbWVudF9zdGFydBgOIAEoCVINc2'
    'hpcG1lbnRTdGFydBInCg9zaGlwbWVudF9maW5pc2gYDyABKAlSDnNoaXBtZW50RmluaXNoEkgK'
    'IHByb21vdGlvbl9jb25kaXRpb25zX2Rlc2NyaXB0aW9uGBAgASgJUh5wcm9tb3Rpb25Db25kaX'
    'Rpb25zRGVzY3JpcHRpb24SRAoPcHJvbW9fY29uZGl0aW9uGBEgASgLMhsubW9iaWxlX3N5bmMu'
    'UHJvbW9Db25kaXRpb25SDnByb21vQ29uZGl0aW9uEikKEHByb21vdGlvbl9saW1pdHMYEiADKA'
    'lSD3Byb21vdGlvbkxpbWl0cxImCg9pc19wb3J0YWxfcHJvbW8YEyABKAhSDWlzUG9ydGFsUHJv'
    'bW8SEgoEdHlwZRgUIAEoCVIEdHlwZQ==');

@$core.Deprecated('Use stockItemDescriptor instead')
const StockItem$json = {
  '1': 'StockItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'product_code', '3': 2, '4': 1, '5': 5, '10': 'productCode'},
    {
      '1': 'warehouse',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.Warehouse',
      '10': 'warehouse'
    },
    {'1': 'public_stock', '3': 4, '4': 1, '5': 9, '10': 'publicStock'},
    {'1': 'multiplicity', '3': 5, '4': 1, '5': 5, '10': 'multiplicity'},
    {'1': 'default_price', '3': 6, '4': 1, '5': 5, '10': 'defaultPrice'},
    {'1': 'offer_price', '3': 7, '4': 1, '5': 5, '10': 'offerPrice'},
    {'1': 'available_price', '3': 8, '4': 1, '5': 5, '10': 'availablePrice'},
    {'1': 'discount_value', '3': 9, '4': 1, '5': 2, '10': 'discountValue'},
    {
      '1': 'promotion',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.Promotion',
      '10': 'promotion'
    },
  ],
};

/// Descriptor for `StockItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stockItemDescriptor = $convert.base64Decode(
    'CglTdG9ja0l0ZW0SDgoCaWQYASABKAVSAmlkEiEKDHByb2R1Y3RfY29kZRgCIAEoBVILcHJvZH'
    'VjdENvZGUSNAoJd2FyZWhvdXNlGAMgASgLMhYubW9iaWxlX3N5bmMuV2FyZWhvdXNlUgl3YXJl'
    'aG91c2USIQoMcHVibGljX3N0b2NrGAQgASgJUgtwdWJsaWNTdG9jaxIiCgxtdWx0aXBsaWNpdH'
    'kYBSABKAVSDG11bHRpcGxpY2l0eRIjCg1kZWZhdWx0X3ByaWNlGAYgASgFUgxkZWZhdWx0UHJp'
    'Y2USHwoLb2ZmZXJfcHJpY2UYByABKAVSCm9mZmVyUHJpY2USJwoPYXZhaWxhYmxlX3ByaWNlGA'
    'ggASgFUg5hdmFpbGFibGVQcmljZRIlCg5kaXNjb3VudF92YWx1ZRgJIAEoAlINZGlzY291bnRW'
    'YWx1ZRI0Cglwcm9tb3Rpb24YCiABKAsyFi5tb2JpbGVfc3luYy5Qcm9tb3Rpb25SCXByb21vdG'
    'lvbg==');

@$core.Deprecated('Use regionalStockItemDescriptor instead')
const RegionalStockItem$json = {
  '1': 'RegionalStockItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'product_code', '3': 2, '4': 1, '5': 5, '10': 'productCode'},
    {
      '1': 'warehouse',
      '3': 3,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.Warehouse',
      '10': 'warehouse'
    },
    {'1': 'public_stock', '3': 4, '4': 1, '5': 9, '10': 'publicStock'},
    {'1': 'multiplicity', '3': 5, '4': 1, '5': 5, '10': 'multiplicity'},
    {
      '1': 'regional_base_price',
      '3': 6,
      '4': 1,
      '5': 5,
      '10': 'regionalBasePrice'
    },
  ],
};

/// Descriptor for `RegionalStockItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List regionalStockItemDescriptor = $convert.base64Decode(
    'ChFSZWdpb25hbFN0b2NrSXRlbRIOCgJpZBgBIAEoBVICaWQSIQoMcHJvZHVjdF9jb2RlGAIgAS'
    'gFUgtwcm9kdWN0Q29kZRI0Cgl3YXJlaG91c2UYAyABKAsyFi5tb2JpbGVfc3luYy5XYXJlaG91'
    'c2VSCXdhcmVob3VzZRIhCgxwdWJsaWNfc3RvY2sYBCABKAlSC3B1YmxpY1N0b2NrEiIKDG11bH'
    'RpcGxpY2l0eRgFIAEoBVIMbXVsdGlwbGljaXR5Ei4KE3JlZ2lvbmFsX2Jhc2VfcHJpY2UYBiAB'
    'KAVSEXJlZ2lvbmFsQmFzZVByaWNl');

@$core.Deprecated('Use outletStockPricingDescriptor instead')
const OutletStockPricing$json = {
  '1': 'OutletStockPricing',
  '2': [
    {'1': 'stock_item_id', '3': 1, '4': 1, '5': 5, '10': 'stockItemId'},
    {'1': 'product_code', '3': 2, '4': 1, '5': 5, '10': 'productCode'},
    {'1': 'warehouse_id', '3': 3, '4': 1, '5': 5, '10': 'warehouseId'},
    {'1': 'outlet_vendor_id', '3': 4, '4': 1, '5': 9, '10': 'outletVendorId'},
    {'1': 'final_price', '3': 5, '4': 1, '5': 5, '10': 'finalPrice'},
    {'1': 'price_difference', '3': 6, '4': 1, '5': 5, '10': 'priceDifference'},
    {
      '1': 'price_difference_percent',
      '3': 7,
      '4': 1,
      '5': 2,
      '10': 'priceDifferencePercent'
    },
    {'1': 'price_type', '3': 8, '4': 1, '5': 9, '10': 'priceType'},
    {'1': 'discount_value', '3': 9, '4': 1, '5': 2, '10': 'discountValue'},
    {'1': 'has_promotion', '3': 10, '4': 1, '5': 8, '10': 'hasPromotion'},
    {
      '1': 'promotion',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.ActivePromotion',
      '10': 'promotion'
    },
  ],
};

/// Descriptor for `OutletStockPricing`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List outletStockPricingDescriptor = $convert.base64Decode(
    'ChJPdXRsZXRTdG9ja1ByaWNpbmcSIgoNc3RvY2tfaXRlbV9pZBgBIAEoBVILc3RvY2tJdGVtSW'
    'QSIQoMcHJvZHVjdF9jb2RlGAIgASgFUgtwcm9kdWN0Q29kZRIhCgx3YXJlaG91c2VfaWQYAyAB'
    'KAVSC3dhcmVob3VzZUlkEigKEG91dGxldF92ZW5kb3JfaWQYBCABKAlSDm91dGxldFZlbmRvck'
    'lkEh8KC2ZpbmFsX3ByaWNlGAUgASgFUgpmaW5hbFByaWNlEikKEHByaWNlX2RpZmZlcmVuY2UY'
    'BiABKAVSD3ByaWNlRGlmZmVyZW5jZRI4ChhwcmljZV9kaWZmZXJlbmNlX3BlcmNlbnQYByABKA'
    'JSFnByaWNlRGlmZmVyZW5jZVBlcmNlbnQSHQoKcHJpY2VfdHlwZRgIIAEoCVIJcHJpY2VUeXBl'
    'EiUKDmRpc2NvdW50X3ZhbHVlGAkgASgCUg1kaXNjb3VudFZhbHVlEiMKDWhhc19wcm9tb3Rpb2'
    '4YCiABKAhSDGhhc1Byb21vdGlvbhI6Cglwcm9tb3Rpb24YCyABKAsyHC5tb2JpbGVfc3luYy5B'
    'Y3RpdmVQcm9tb3Rpb25SCXByb21vdGlvbg==');
