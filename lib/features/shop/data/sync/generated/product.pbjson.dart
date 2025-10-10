// This is a generated file - do not edit.
//
// Generated from product.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use productDescriptor instead')
const Product$json = {
  '1': 'Product',
  '2': [
    {'1': 'code', '3': 1, '4': 1, '5': 5, '10': 'code'},
    {'1': 'bcode', '3': 2, '4': 1, '5': 5, '10': 'bcode'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'vendor_code', '3': 4, '4': 1, '5': 9, '10': 'vendorCode'},
    {'1': 'barcodes', '3': 5, '4': 3, '5': 9, '10': 'barcodes'},
    {'1': 'is_marked', '3': 6, '4': 1, '5': 8, '10': 'isMarked'},
    {'1': 'novelty', '3': 7, '4': 1, '5': 8, '10': 'novelty'},
    {'1': 'popular', '3': 8, '4': 1, '5': 8, '10': 'popular'},
    {'1': 'amount_in_package', '3': 9, '4': 1, '5': 5, '10': 'amountInPackage'},
    {
      '1': 'brand',
      '3': 10,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.Brand',
      '10': 'brand'
    },
    {
      '1': 'manufacturer',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.Manufacturer',
      '10': 'manufacturer'
    },
    {
      '1': 'default_image',
      '3': 12,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.ProductImage',
      '10': 'defaultImage'
    },
    {
      '1': 'images',
      '3': 13,
      '4': 3,
      '5': 11,
      '6': '.mobile_sync.ProductImage',
      '10': 'images'
    },
    {
      '1': 'color_image',
      '3': 14,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.ProductImage',
      '10': 'colorImage'
    },
    {'1': 'description', '3': 15, '4': 1, '5': 9, '10': 'description'},
    {'1': 'how_to_use', '3': 16, '4': 1, '5': 9, '10': 'howToUse'},
    {'1': 'ingredients', '3': 17, '4': 1, '5': 9, '10': 'ingredients'},
    {
      '1': 'category',
      '3': 18,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.Category',
      '10': 'category'
    },
    {
      '1': 'categories_instock',
      '3': 19,
      '4': 3,
      '5': 11,
      '6': '.mobile_sync.Category',
      '10': 'categoriesInstock'
    },
    {
      '1': 'type',
      '3': 20,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.ProductType',
      '10': 'type'
    },
    {
      '1': 'series',
      '3': 21,
      '4': 1,
      '5': 11,
      '6': '.mobile_sync.Series',
      '10': 'series'
    },
    {
      '1': 'price_list_category_id',
      '3': 22,
      '4': 1,
      '5': 5,
      '10': 'priceListCategoryId'
    },
    {
      '1': 'numeric_characteristics',
      '3': 23,
      '4': 3,
      '5': 11,
      '6': '.mobile_sync.NumericCharacteristic',
      '10': 'numericCharacteristics'
    },
    {
      '1': 'string_characteristics',
      '3': 24,
      '4': 3,
      '5': 11,
      '6': '.mobile_sync.StringCharacteristic',
      '10': 'stringCharacteristics'
    },
    {
      '1': 'bool_characteristics',
      '3': 25,
      '4': 3,
      '5': 11,
      '6': '.mobile_sync.BoolCharacteristic',
      '10': 'boolCharacteristics'
    },
    {'1': 'can_buy', '3': 26, '4': 1, '5': 8, '10': 'canBuy'},
    {'1': 'catalog_id', '3': 27, '4': 1, '5': 5, '10': 'catalogId'},
  ],
};

/// Descriptor for `Product`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productDescriptor = $convert.base64Decode(
    'CgdQcm9kdWN0EhIKBGNvZGUYASABKAVSBGNvZGUSFAoFYmNvZGUYAiABKAVSBWJjb2RlEhQKBX'
    'RpdGxlGAMgASgJUgV0aXRsZRIfCgt2ZW5kb3JfY29kZRgEIAEoCVIKdmVuZG9yQ29kZRIaCghi'
    'YXJjb2RlcxgFIAMoCVIIYmFyY29kZXMSGwoJaXNfbWFya2VkGAYgASgIUghpc01hcmtlZBIYCg'
    'dub3ZlbHR5GAcgASgIUgdub3ZlbHR5EhgKB3BvcHVsYXIYCCABKAhSB3BvcHVsYXISKgoRYW1v'
    'dW50X2luX3BhY2thZ2UYCSABKAVSD2Ftb3VudEluUGFja2FnZRIoCgVicmFuZBgKIAEoCzISLm'
    '1vYmlsZV9zeW5jLkJyYW5kUgVicmFuZBI9CgxtYW51ZmFjdHVyZXIYCyABKAsyGS5tb2JpbGVf'
    'c3luYy5NYW51ZmFjdHVyZXJSDG1hbnVmYWN0dXJlchI+Cg1kZWZhdWx0X2ltYWdlGAwgASgLMh'
    'kubW9iaWxlX3N5bmMuUHJvZHVjdEltYWdlUgxkZWZhdWx0SW1hZ2USMQoGaW1hZ2VzGA0gAygL'
    'MhkubW9iaWxlX3N5bmMuUHJvZHVjdEltYWdlUgZpbWFnZXMSOgoLY29sb3JfaW1hZ2UYDiABKA'
    'syGS5tb2JpbGVfc3luYy5Qcm9kdWN0SW1hZ2VSCmNvbG9ySW1hZ2USIAoLZGVzY3JpcHRpb24Y'
    'DyABKAlSC2Rlc2NyaXB0aW9uEhwKCmhvd190b191c2UYECABKAlSCGhvd1RvVXNlEiAKC2luZ3'
    'JlZGllbnRzGBEgASgJUgtpbmdyZWRpZW50cxIxCghjYXRlZ29yeRgSIAEoCzIVLm1vYmlsZV9z'
    'eW5jLkNhdGVnb3J5UghjYXRlZ29yeRJEChJjYXRlZ29yaWVzX2luc3RvY2sYEyADKAsyFS5tb2'
    'JpbGVfc3luYy5DYXRlZ29yeVIRY2F0ZWdvcmllc0luc3RvY2sSLAoEdHlwZRgUIAEoCzIYLm1v'
    'YmlsZV9zeW5jLlByb2R1Y3RUeXBlUgR0eXBlEisKBnNlcmllcxgVIAEoCzITLm1vYmlsZV9zeW'
    '5jLlNlcmllc1IGc2VyaWVzEjMKFnByaWNlX2xpc3RfY2F0ZWdvcnlfaWQYFiABKAVSE3ByaWNl'
    'TGlzdENhdGVnb3J5SWQSWwoXbnVtZXJpY19jaGFyYWN0ZXJpc3RpY3MYFyADKAsyIi5tb2JpbG'
    'Vfc3luYy5OdW1lcmljQ2hhcmFjdGVyaXN0aWNSFm51bWVyaWNDaGFyYWN0ZXJpc3RpY3MSWAoW'
    'c3RyaW5nX2NoYXJhY3RlcmlzdGljcxgYIAMoCzIhLm1vYmlsZV9zeW5jLlN0cmluZ0NoYXJhY3'
    'RlcmlzdGljUhVzdHJpbmdDaGFyYWN0ZXJpc3RpY3MSUgoUYm9vbF9jaGFyYWN0ZXJpc3RpY3MY'
    'GSADKAsyHy5tb2JpbGVfc3luYy5Cb29sQ2hhcmFjdGVyaXN0aWNSE2Jvb2xDaGFyYWN0ZXJpc3'
    'RpY3MSFwoHY2FuX2J1eRgaIAEoCFIGY2FuQnV5Eh0KCmNhdGFsb2dfaWQYGyABKAVSCWNhdGFs'
    'b2dJZA==');

@$core.Deprecated('Use brandDescriptor instead')
const Brand$json = {
  '1': 'Brand',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'adapted_name', '3': 3, '4': 1, '5': 9, '10': 'adaptedName'},
    {'1': 'search_priority', '3': 4, '4': 1, '5': 5, '10': 'searchPriority'},
  ],
};

/// Descriptor for `Brand`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List brandDescriptor = $convert.base64Decode(
    'CgVCcmFuZBIOCgJpZBgBIAEoBVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIhCgxhZGFwdGVkX2'
    '5hbWUYAyABKAlSC2FkYXB0ZWROYW1lEicKD3NlYXJjaF9wcmlvcml0eRgEIAEoBVIOc2VhcmNo'
    'UHJpb3JpdHk=');

@$core.Deprecated('Use manufacturerDescriptor instead')
const Manufacturer$json = {
  '1': 'Manufacturer',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Manufacturer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List manufacturerDescriptor = $convert.base64Decode(
    'CgxNYW51ZmFjdHVyZXISDgoCaWQYASABKAVSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWU=');

@$core.Deprecated('Use productImageDescriptor instead')
const ProductImage$json = {
  '1': 'ProductImage',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'uri', '3': 2, '4': 1, '5': 9, '10': 'uri'},
    {'1': 'webp', '3': 3, '4': 1, '5': 9, '10': 'webp'},
    {'1': 'width', '3': 4, '4': 1, '5': 5, '10': 'width'},
    {'1': 'height', '3': 5, '4': 1, '5': 5, '10': 'height'},
  ],
};

/// Descriptor for `ProductImage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productImageDescriptor = $convert.base64Decode(
    'CgxQcm9kdWN0SW1hZ2USDgoCaWQYASABKAVSAmlkEhAKA3VyaRgCIAEoCVIDdXJpEhIKBHdlYn'
    'AYAyABKAlSBHdlYnASFAoFd2lkdGgYBCABKAVSBXdpZHRoEhYKBmhlaWdodBgFIAEoBVIGaGVp'
    'Z2h0');

@$core.Deprecated('Use categoryDescriptor instead')
const Category$json = {
  '1': 'Category',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'is_publish', '3': 3, '4': 1, '5': 8, '10': 'isPublish'},
    {'1': 'description', '3': 4, '4': 1, '5': 9, '10': 'description'},
    {'1': 'query', '3': 5, '4': 1, '5': 9, '10': 'query'},
  ],
};

/// Descriptor for `Category`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List categoryDescriptor = $convert.base64Decode(
    'CghDYXRlZ29yeRIOCgJpZBgBIAEoBVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZRIdCgppc19wdW'
    'JsaXNoGAMgASgIUglpc1B1Ymxpc2gSIAoLZGVzY3JpcHRpb24YBCABKAlSC2Rlc2NyaXB0aW9u'
    'EhQKBXF1ZXJ5GAUgASgJUgVxdWVyeQ==');

@$core.Deprecated('Use productTypeDescriptor instead')
const ProductType$json = {
  '1': 'ProductType',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `ProductType`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List productTypeDescriptor = $convert.base64Decode(
    'CgtQcm9kdWN0VHlwZRIOCgJpZBgBIAEoBVICaWQSEgoEbmFtZRgCIAEoCVIEbmFtZQ==');

@$core.Deprecated('Use seriesDescriptor instead')
const Series$json = {
  '1': 'Series',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 5, '10': 'id'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
  ],
};

/// Descriptor for `Series`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List seriesDescriptor = $convert.base64Decode(
    'CgZTZXJpZXMSDgoCaWQYASABKAVSAmlkEhIKBG5hbWUYAiABKAlSBG5hbWU=');

@$core.Deprecated('Use numericCharacteristicDescriptor instead')
const NumericCharacteristic$json = {
  '1': 'NumericCharacteristic',
  '2': [
    {'1': 'attribute_id', '3': 1, '4': 1, '5': 5, '10': 'attributeId'},
    {'1': 'attribute_name', '3': 2, '4': 1, '5': 9, '10': 'attributeName'},
    {'1': 'id', '3': 3, '4': 1, '5': 5, '10': 'id'},
    {'1': 'type', '3': 4, '4': 1, '5': 9, '10': 'type'},
    {'1': 'adapt_value', '3': 5, '4': 1, '5': 9, '10': 'adaptValue'},
    {'1': 'value', '3': 6, '4': 1, '5': 2, '10': 'value'},
  ],
};

/// Descriptor for `NumericCharacteristic`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List numericCharacteristicDescriptor = $convert.base64Decode(
    'ChVOdW1lcmljQ2hhcmFjdGVyaXN0aWMSIQoMYXR0cmlidXRlX2lkGAEgASgFUgthdHRyaWJ1dG'
    'VJZBIlCg5hdHRyaWJ1dGVfbmFtZRgCIAEoCVINYXR0cmlidXRlTmFtZRIOCgJpZBgDIAEoBVIC'
    'aWQSEgoEdHlwZRgEIAEoCVIEdHlwZRIfCgthZGFwdF92YWx1ZRgFIAEoCVIKYWRhcHRWYWx1ZR'
    'IUCgV2YWx1ZRgGIAEoAlIFdmFsdWU=');

@$core.Deprecated('Use stringCharacteristicDescriptor instead')
const StringCharacteristic$json = {
  '1': 'StringCharacteristic',
  '2': [
    {'1': 'attribute_id', '3': 1, '4': 1, '5': 5, '10': 'attributeId'},
    {'1': 'attribute_name', '3': 2, '4': 1, '5': 9, '10': 'attributeName'},
    {'1': 'id', '3': 3, '4': 1, '5': 5, '10': 'id'},
    {'1': 'type', '3': 4, '4': 1, '5': 9, '10': 'type'},
    {'1': 'adapt_value', '3': 5, '4': 1, '5': 9, '10': 'adaptValue'},
    {'1': 'value', '3': 6, '4': 1, '5': 5, '10': 'value'},
  ],
};

/// Descriptor for `StringCharacteristic`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List stringCharacteristicDescriptor = $convert.base64Decode(
    'ChRTdHJpbmdDaGFyYWN0ZXJpc3RpYxIhCgxhdHRyaWJ1dGVfaWQYASABKAVSC2F0dHJpYnV0ZU'
    'lkEiUKDmF0dHJpYnV0ZV9uYW1lGAIgASgJUg1hdHRyaWJ1dGVOYW1lEg4KAmlkGAMgASgFUgJp'
    'ZBISCgR0eXBlGAQgASgJUgR0eXBlEh8KC2FkYXB0X3ZhbHVlGAUgASgJUgphZGFwdFZhbHVlEh'
    'QKBXZhbHVlGAYgASgFUgV2YWx1ZQ==');

@$core.Deprecated('Use boolCharacteristicDescriptor instead')
const BoolCharacteristic$json = {
  '1': 'BoolCharacteristic',
  '2': [
    {'1': 'attribute_id', '3': 1, '4': 1, '5': 5, '10': 'attributeId'},
    {'1': 'attribute_name', '3': 2, '4': 1, '5': 9, '10': 'attributeName'},
    {'1': 'id', '3': 3, '4': 1, '5': 5, '10': 'id'},
    {'1': 'type', '3': 4, '4': 1, '5': 9, '10': 'type'},
    {'1': 'value', '3': 5, '4': 1, '5': 8, '10': 'value'},
  ],
};

/// Descriptor for `BoolCharacteristic`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List boolCharacteristicDescriptor = $convert.base64Decode(
    'ChJCb29sQ2hhcmFjdGVyaXN0aWMSIQoMYXR0cmlidXRlX2lkGAEgASgFUgthdHRyaWJ1dGVJZB'
    'IlCg5hdHRyaWJ1dGVfbmFtZRgCIAEoCVINYXR0cmlidXRlTmFtZRIOCgJpZBgDIAEoBVICaWQS'
    'EgoEdHlwZRgEIAEoCVIEdHlwZRIUCgV2YWx1ZRgFIAEoCFIFdmFsdWU=');
