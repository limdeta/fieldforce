// lib/features/shop/presentation/helpers/facet_key_parser.dart

/// Helper для парсинга ключей динамических фасетов
class FacetKeyParser {
  /// Проверяет, является ли ключ динамической характеристикой
  /// Динамические характеристики имеют формат: attr[123]
  static bool isDynamicCharacteristic(String key) {
    return key.startsWith('attr[') && key.endsWith(']');
  }
  
  /// Извлекает attributeId из ключа вида attr[123]
  /// Возвращает null если ключ не является динамической характеристикой
  static int? parseAttributeId(String key) {
    if (!isDynamicCharacteristic(key)) return null;
    final match = RegExp(r'attr\[(\d+)\]').firstMatch(key);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }
  
  /// Создаёт ключ для динамической характеристики
  static String createAttributeKey(int attributeId) {
    return 'attr[$attributeId]';
  }
}
