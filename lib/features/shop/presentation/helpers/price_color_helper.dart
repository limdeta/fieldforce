// lib/features/shop/presentation/helpers/price_color_helper.dart

import 'package:flutter/material.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';

/// Helper для определения цветового кодирования цен
/// 
/// Цвета зависят от типа цены (priceType):
/// - "promotion" → темно-зеленый (акционная цена)
/// - "differential_price" → темно-желтый (индивидуальная цена для торговой точки)
/// - "regional_base" или null → дефолтный цвет текста (базовая региональная цена)
class PriceColorHelper {
  // Темно-зеленый для акций (#1B5E20 - Material Green 900)
  static const Color promotionColor = Color(0xFF1B5E20);
  
  // Темно-желтый для индивидуальных цен (#F57F17 - Material Yellow 800)
  static const Color differentialColor = Color(0xFFF57F17);
  
  // Светло-зеленый фон для акций (полупрозрачный)
  static const Color promotionBackgroundColor = Color(0x33C8E6C9); // Light green with 20% opacity
  
  // Светло-желтый фон для индивидуальных цен (полупрозрачный)
  static const Color differentialBackgroundColor = Color(0x33FFF9C4); // Light yellow with 20% opacity
  
  /// Возвращает цвет цены на основе типа цены в StockItem
  /// 
  /// Возвращает null для дефолтного цвета текста (regional_base или не определен)
  static Color? getPriceColor(StockItem stockItem) {
    if (stockItem.priceType == null) return null;
    
    switch (stockItem.priceType) {
      case 'promotion':
        return promotionColor;
      case 'differential_price':
        return differentialColor;
      case 'regional_base':
      default:
        return null; // Дефолтный цвет текста
    }
  }
  
  /// Возвращает фоновый цвет для цены на основе типа цены в StockItem
  /// 
  /// Возвращает null для regional_base (без фона)
  static Color? getPriceBackgroundColor(StockItem stockItem) {
    if (stockItem.priceType == null) return null;
    
    switch (stockItem.priceType) {
      case 'promotion':
        return promotionBackgroundColor;
      case 'differential_price':
        return differentialBackgroundColor;
      case 'regional_base':
      default:
        return null; // Без фона
    }
  }
  
  /// Вспомогательный метод для получения TextStyle с цветом цены
  /// 
  /// Используйте этот метод для единообразного отображения цен:
  /// ```dart
  /// Text(
  ///   '${price} ₽',
  ///   style: PriceColorHelper.getPriceTextStyle(stockItem),
  /// )
  /// ```
  static TextStyle getPriceTextStyle(
    StockItem stockItem, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: getPriceColor(stockItem),
    );
  }
  
  /// Возвращает человекочитаемое описание типа цены
  /// 
  /// Полезно для отладки и отображения легенды пользователю
  static String getPriceTypeLabel(String? priceType) {
    if (priceType == null) return 'Региональная цена';
    
    switch (priceType) {
      case 'promotion':
        return 'Акционная цена';
      case 'differential_price':
        return 'Индивидуальная цена';
      case 'regional_base':
        return 'Региональная цена';
      default:
        return 'Неизвестный тип цены';
    }
  }
}
