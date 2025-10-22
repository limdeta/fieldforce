import 'package:fieldforce/features/shop/domain/entities/catalog_display_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для управления пользовательскими настройками и состоянием UI
/// 
/// Сохраняет:
/// - Выбранный маршрут пользователем
/// - Настройки карты (zoom, центр)
/// - UI preferences (темная тема, размер шрифта и т.д.)
/// - Последние действия пользователя
class UserPreferencesService {
  static const String _selectedRouteIdKey = 'selected_route_id';
  static const String _mapCenterLatKey = 'map_center_lat';
  static const String _mapCenterLngKey = 'map_center_lng';
  static const String _mapZoomKey = 'map_zoom';
  static const String _isDarkThemeKey = 'is_dark_theme';
  static const String _fontSizeKey = 'font_size';
  static const String _lastViewedTabKey = 'last_viewed_tab';
  static const String _catalogDisplayModeKey = 'catalog_display_mode';
  static const String _catalogSplitStateKey = 'catalog_split_state';
  
  SharedPreferences? _prefs;
  
  /// Инициализация сервиса - должна быть вызвана при старте приложения
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  /// Проверка что сервис инициализирован
  void _ensureInitialized() {
    if (_prefs == null) {
      throw StateError('UserPreferencesService не инициализирован. Вызовите initialize() перед использованием.');
    }
  }

  // ============================================================================
  // МАРШРУТЫ
  // ============================================================================
  
  /// Сохраняет ID выбранного пользователем маршрута
  Future<void> setSelectedRouteId(int? routeId) async {
    _ensureInitialized();
    if (routeId != null) {
      await _prefs!.setInt(_selectedRouteIdKey, routeId);
    } else {
      await _prefs!.remove(_selectedRouteIdKey);
    }
  }
  
  /// Получает ID выбранного пользователем маршрута
  int? getSelectedRouteId() {
    _ensureInitialized();
    return _prefs!.getInt(_selectedRouteIdKey);
  }

  // ============================================================================
  // НАСТРОЙКИ КАРТЫ
  // ============================================================================
  
  /// Сохраняет последнее положение и зум карты
  Future<void> setMapState({
    required double centerLat,
    required double centerLng, 
    required double zoom,
  }) async {
    _ensureInitialized();
    await Future.wait([
      _prefs!.setDouble(_mapCenterLatKey, centerLat),
      _prefs!.setDouble(_mapCenterLngKey, centerLng),
      _prefs!.setDouble(_mapZoomKey, zoom),
    ]);
  }
  
  /// Получает сохраненное состояние карты
  MapState? getMapState() {
    _ensureInitialized();
    final lat = _prefs!.getDouble(_mapCenterLatKey);
    final lng = _prefs!.getDouble(_mapCenterLngKey);
    final zoom = _prefs!.getDouble(_mapZoomKey);
    
    if (lat != null && lng != null && zoom != null) {
      return MapState(
        centerLat: lat,
        centerLng: lng,
        zoom: zoom,
      );
    }
    return null;
  }

  // ============================================================================
  // UI НАСТРОЙКИ
  // ============================================================================
  
  /// Сохраняет настройку темной темы
  Future<void> setDarkTheme(bool isDark) async {
    _ensureInitialized();
    await _prefs!.setBool(_isDarkThemeKey, isDark);
  }
  
  /// Получает настройку темной темы
  bool getDarkTheme() {
    _ensureInitialized();
    return _prefs!.getBool(_isDarkThemeKey) ?? false; // По умолчанию светлая тема
  }
  
  /// Сохраняет размер шрифта
  Future<void> setFontSize(double fontSize) async {
    _ensureInitialized();
    await _prefs!.setDouble(_fontSizeKey, fontSize);
  }
  
  /// Получает размер шрифта
  double getFontSize() {
    _ensureInitialized();
    return _prefs!.getDouble(_fontSizeKey) ?? 14.0; // По умолчанию 14px
  }

  /// Сохраняет предпочтительный режим отображения каталога товаров
  Future<void> setCatalogDisplayMode(CatalogDisplayMode mode) async {
    _ensureInitialized();
    await _prefs!.setString(_catalogDisplayModeKey, mode.storageValue);
  }

  /// Получает предпочтительный режим отображения каталога товаров
  CatalogDisplayMode getCatalogDisplayMode() {
    _ensureInitialized();
    final stored = _prefs!.getString(_catalogDisplayModeKey);
    return CatalogDisplayModeX.fromStorage(stored);
  }

  /// Сохраняет сериализованное состояние сплит-каталога
  Future<void> setCatalogSplitStateJson(String? stateJson) async {
    _ensureInitialized();
    if (stateJson == null) {
      await _prefs!.remove(_catalogSplitStateKey);
      return;
    }
    await _prefs!.setString(_catalogSplitStateKey, stateJson);
  }

  /// Возвращает сериализованное состояние сплит-каталога
  String? getCatalogSplitStateJson() {
    _ensureInitialized();
    return _prefs!.getString(_catalogSplitStateKey);
  }

  // ============================================================================
  // НАВИГАЦИЯ И СОСТОЯНИЕ ЭКРАНОВ
  // ============================================================================
  
  /// Сохраняет последний просмотренный таб/экран
  Future<void> setLastViewedTab(String tabName) async {
    _ensureInitialized();
    await _prefs!.setString(_lastViewedTabKey, tabName);
  }
  
  /// Получает последний просмотренный таб/экран
  String? getLastViewedTab() {
    _ensureInitialized();
    return _prefs!.getString(_lastViewedTabKey);
  }

  // ============================================================================
  // УТИЛИТЫ
  // ============================================================================
  
  /// Очищает все пользовательские настройки (для выхода из аккаунта)
  Future<void> clearAllPreferences() async {
    _ensureInitialized();
    await _prefs!.clear();
  }
  
  /// Очищает только UI настройки, оставляя пользовательские данные
  Future<void> clearUIPreferences() async {
    _ensureInitialized();
    await Future.wait([
      _prefs!.remove(_isDarkThemeKey),
      _prefs!.remove(_fontSizeKey),
      _prefs!.remove(_lastViewedTabKey),
      _prefs!.remove(_catalogDisplayModeKey),
      _prefs!.remove(_catalogSplitStateKey),
    ]);
  }
}

/// Класс для хранения состояния карты
class MapState {
  final double centerLat;
  final double centerLng;
  final double zoom;
  
  const MapState({
    required this.centerLat,
    required this.centerLng,
    required this.zoom,
  });
  
  @override
  String toString() => 'MapState(lat: $centerLat, lng: $centerLng, zoom: $zoom)';
}
