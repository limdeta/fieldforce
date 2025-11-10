// lib/app/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // Основные цвета
  // static const Color primary = Color(0xFFF59E0B); // yellow-500 (аналог bg-yellow-400)
  // static const Color primaryHover = Color(0xFFD97706); // yellow-600 (аналог hover:bg-yellow-500)
  // static const Color primaryLight = Color(0xFFFEF3C7); // yellow-100
  
  static const Color primary = Color.fromARGB(255, 47, 49, 49); // yellow-500 (аналог bg-yellow-400)
  static const Color primaryHover = Color.fromARGB(255, 165, 165, 165); // yellow-600 (аналог hover:bg-yellow-500)
  static const Color primaryLight = Color.fromARGB(255, 179, 179, 179); // yellow-100
  

  // Нейтральные цвета (slate palette из Tailwind)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B); // accents-6
  static const Color slate600 = Color(0xFF475569); // text-accents-7, slate-600
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  
  // Семантические цвета
  static const Color success = Color(0xFF10B981); // green-500
  static const Color successLight = Color(0xFFD1FAE5); // green-100
  static const Color warning = Color(0xFFEAB308); // yellow-500
  static const Color warningLight = Color(0xFFFEF3C7); // yellow-100
  static const Color error = Color(0xFFEF4444); // red-500
  static const Color errorLight = Color(0xFFFECACA); // red-100
  static const Color info = Color(0xFF3B82F6); // blue-500
  static const Color infoLight = Color(0xFFDBEAFE); // blue-100
  
  // Цвета для статусов заказов
  static const Color draftStatus = Color(0xFF92400E); // yellow-800
  static const Color draftStatusBg = Color(0xFFFEF3C7); // yellow-100
  static const Color pendingStatus = Color(0xFF1E40AF); // blue-800
  static const Color pendingStatusBg = Color(0xFFDBEAFE); // blue-100
  static const Color completedStatus = Color(0xFF166534); // green-800
  static const Color completedStatusBg = Color(0xFFDCFCE7); // green-100
  static const Color failedStatus = Color(0xFFB91C1C); // red-700
  static const Color failedStatusBg = Color(0xFFFECACA); // red-100
  
  // Цвета для остатков товаров
  static const Color stockGreen = Color(0xFF059669); // emerald-600
  static const Color stockYellow = Color(0xFFEAB308); // yellow-500
  static const Color stockRed = Color(0xFFDC2626); // red-600
  
  // Фоновые цвета
  static const Color background = Color(0xFFFFFFFF); // white
  static const Color backgroundSecondary = Color(0xFFF8FAFC); // slate-50
  static const Color surface = Color(0xFFFFFFFF); // white
  static const Color surfaceHover = Color(0xFFF1F5F9); // slate-100
  
  // Текстовые цвета
  static const Color textPrimary = Color(0xFF334155); // slate-700
  static const Color textSecondary = Color(0xFF64748B); // slate-500
  static const Color textMuted = Color(0xFF94A3B8); // slate-400
  static const Color textOnPrimary = Color(0xFFFFFFFF); // БЕЛЫЙ текст для темных кнопок/фонов
  
  // Границы
  static const Color border = Color(0xFFE2E8F0); // slate-200
  static const Color borderLight = Color(0xFFF1F5F9); // slate-100
  
  // Дополнительные цвета для контраста
  static const Color onDark = Color(0xFFFFFFFF); // Белый текст на темном фоне
  static const Color onLight = Color(0xFF334155); // Темный текст на светлом фоне
}

/// Генератор MaterialColor для использования в ThemeData
class AppColorScheme {
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = (color.r * 255.0).round() & 0xff;
    final int g = (color.g * 255.0).round() & 0xff;
    final int b = (color.b * 255.0).round() & 0xff;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (double strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.toARGB32(), swatch);
  }

  /// Основная цветовая схема в стиле фронтенда
  static ColorScheme get lightColorScheme {
    return ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary, // Темно-серый
      onPrimary: Colors.white, // БЕЛЫЙ текст на темном фоне для контраста
      secondary: AppColors.slate600,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: Colors.white,
    );
  }
  
  /// MaterialColor для совместимости с старыми виджетами
  static MaterialColor get primarySwatch {
    return createMaterialColor(const Color.fromARGB(255, 110, 105, 117));
  }
}