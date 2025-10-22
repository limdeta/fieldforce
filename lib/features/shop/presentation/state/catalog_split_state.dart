import 'dart:async';
import 'dart:convert';

import 'package:fieldforce/app/services/user_preferences_service.dart';
import 'package:fieldforce/features/shop/domain/entities/product_with_stock.dart';
import 'package:fieldforce/features/shop/domain/entities/stock_item.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

/// Кэш списка товаров для конкретной категории в сплит-каталоге.
class CatalogSplitCategoryProductsCache {
  final List<ProductWithStock> products;
  final bool hasMore;
  final int offset;
  final String? error;

  const CatalogSplitCategoryProductsCache({
    required this.products,
    required this.hasMore,
    required this.offset,
    this.error,
  });

  CatalogSplitCategoryProductsCache copyWith({
    List<ProductWithStock>? products,
    bool? hasMore,
    int? offset,
    String? error,
  }) {
    return CatalogSplitCategoryProductsCache(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      error: error ?? this.error,
    );
  }
}

/// Хранилище состояния сплит-каталога.
///
/// Держит выбранную категорию, развёрнутые ветки, пропорции панелей и
/// пользовательские выборы складов, чтобы при повторном открытии страницы
/// состояние сохранялось.
class CatalogSplitStateStore {
  CatalogSplitStateStore._internal()
      : _preferencesService = GetIt.instance.isRegistered<UserPreferencesService>()
            ? GetIt.instance<UserPreferencesService>()
            : null {
    _restoreFromPreferences();
  }

  static final CatalogSplitStateStore _instance = CatalogSplitStateStore._internal();

  static CatalogSplitStateStore get instance => _instance;

  static final Logger _logger = Logger('CatalogSplitStateStore');

  static const Duration _persistDebounce = Duration(milliseconds: 400);

  final UserPreferencesService? _preferencesService;

  double _horizontalSplitRatio = 0.35;
  double _verticalSplitRatio = 0.5;
  String _searchQuery = '';
  Set<int> _expandedCategoryIds = <int>{};
  int? _selectedCategoryId;
  double _categoryPanelScrollOffset = 0;
  final Map<int, double> _productsScrollOffsets = <int, double>{};
  Map<int, StockItem> _selectedStockItems = <int, StockItem>{};

  final Map<int, CatalogSplitCategoryProductsCache> categoryProductsCache =
      <int, CatalogSplitCategoryProductsCache>{};

  Timer? _persistTimer;

  double get horizontalSplitRatio => _horizontalSplitRatio;

  set horizontalSplitRatio(double value) {
    if (_horizontalSplitRatio == value) return;
    _horizontalSplitRatio = value;
    _schedulePersist();
  }

  double get verticalSplitRatio => _verticalSplitRatio;

  set verticalSplitRatio(double value) {
    if (_verticalSplitRatio == value) return;
    _verticalSplitRatio = value;
    _schedulePersist();
  }

  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    _schedulePersist();
  }

  Set<int> get expandedCategoryIds => Set<int>.from(_expandedCategoryIds);

  set expandedCategoryIds(Set<int> ids) {
    if (_expandedCategoryIds.length == ids.length && _expandedCategoryIds.containsAll(ids)) {
      return;
    }
    _expandedCategoryIds = Set<int>.from(ids);
    _schedulePersist();
  }

  int? get selectedCategoryId => _selectedCategoryId;

  set selectedCategoryId(int? value) {
    if (_selectedCategoryId == value) return;
    _selectedCategoryId = value;
    _schedulePersist();
  }

  double get categoryPanelScrollOffset => _categoryPanelScrollOffset;

  set categoryPanelScrollOffset(double value) {
    final normalized = value < 0 ? 0.0 : value;
    if (_categoryPanelScrollOffset == normalized) return;
    _categoryPanelScrollOffset = normalized;
    _schedulePersist();
  }

  Map<int, StockItem> get selectedStockItems => Map<int, StockItem>.from(_selectedStockItems);

  set selectedStockItems(Map<int, StockItem> items) {
    _selectedStockItems = Map<int, StockItem>.from(items);
  }

  double? getProductScrollOffset(int categoryId) => _productsScrollOffsets[categoryId];

  void setProductScrollOffset(int categoryId, double offset) {
    final normalized = offset < 0 ? 0.0 : offset;
    final previous = _productsScrollOffsets[categoryId];
    if (previous != null && (previous - normalized).abs() < 0.5) {
      return;
    }
    _productsScrollOffsets[categoryId] = normalized;
    _schedulePersist();
  }

  void removeProductScrollOffset(int categoryId) {
    final removed = _productsScrollOffsets.remove(categoryId);
    if (removed != null) {
      _schedulePersist();
    }
  }

  void pruneProductScrollOffsets(Set<int> validCategoryIds) {
    final keysToRemove = _productsScrollOffsets.keys
        .where((key) => !validCategoryIds.contains(key))
        .toList(growable: false);
    if (keysToRemove.isEmpty) {
      return;
    }
    for (final key in keysToRemove) {
      _productsScrollOffsets.remove(key);
    }
    _schedulePersist();
  }

  /// Очистка всех сохранённых данных (для отладки / тестов)
  void clear() {
    _persistTimer?.cancel();
    _persistTimer = null;
    _horizontalSplitRatio = 0.35;
    _verticalSplitRatio = 0.5;
    _searchQuery = '';
    _expandedCategoryIds = <int>{};
    _selectedCategoryId = null;
    _categoryPanelScrollOffset = 0;
    _productsScrollOffsets.clear();
    _selectedStockItems = <int, StockItem>{};
    categoryProductsCache.clear();

    final prefs = _preferencesService;
    if (prefs != null) {
      unawaited(prefs.setCatalogSplitStateJson(null));
    }
  }

  void _restoreFromPreferences() {
    final prefs = _preferencesService;
    if (prefs == null) {
      return;
    }

    try {
      final raw = prefs.getCatalogSplitStateJson();
      if (raw == null || raw.isEmpty) {
        return;
      }
      final stored = _CatalogSplitPersistedState.fromJson(raw);
      _horizontalSplitRatio = stored.horizontalSplitRatio ?? _horizontalSplitRatio;
      _verticalSplitRatio = stored.verticalSplitRatio ?? _verticalSplitRatio;
      _searchQuery = stored.searchQuery ?? _searchQuery;
      _expandedCategoryIds = Set<int>.from(stored.expandedCategoryIds);
      _selectedCategoryId = stored.selectedCategoryId ?? _selectedCategoryId;
      _categoryPanelScrollOffset = stored.categoryPanelScrollOffset ?? _categoryPanelScrollOffset;
      _productsScrollOffsets
        ..clear()
        ..addAll(stored.productsScrollOffsets);
    } on StateError catch (error, stackTrace) {
      _logger.warning('UserPreferencesService не инициализирован, пропускаем восстановление', error, stackTrace);
    } catch (error, stackTrace) {
      _logger.warning('Не удалось восстановить состояние сплит-каталога', error, stackTrace);
    }
  }

  void _schedulePersist() {
    final prefs = _preferencesService;
    if (prefs == null) {
      return;
    }

    _persistTimer?.cancel();
    _persistTimer = Timer(_persistDebounce, () {
      _persistTimer = null;
      unawaited(_persistState(prefs));
    });
  }

  Future<void> _persistState(UserPreferencesService prefs) async {
    try {
      final snapshot = _CatalogSplitPersistedState(
        horizontalSplitRatio: _horizontalSplitRatio,
        verticalSplitRatio: _verticalSplitRatio,
        searchQuery: _searchQuery,
        expandedCategoryIds: _expandedCategoryIds,
        selectedCategoryId: _selectedCategoryId,
        categoryPanelScrollOffset: _categoryPanelScrollOffset,
        productsScrollOffsets: _productsScrollOffsets,
      );
      await prefs.setCatalogSplitStateJson(snapshot.toJson());
    } on StateError catch (error, stackTrace) {
      _logger.warning('Не удалось сохранить состояние — сервис предпочтений не готов', error, stackTrace);
    } catch (error, stackTrace) {
      _logger.warning('Ошибка сохранения состояния сплит-каталога', error, stackTrace);
    }
  }
}

class _CatalogSplitPersistedState {
  final double? horizontalSplitRatio;
  final double? verticalSplitRatio;
  final String? searchQuery;
  final Set<int> expandedCategoryIds;
  final int? selectedCategoryId;
  final double? categoryPanelScrollOffset;
  final Map<int, double> productsScrollOffsets;

  const _CatalogSplitPersistedState({
    required this.horizontalSplitRatio,
    required this.verticalSplitRatio,
    required this.searchQuery,
    required this.expandedCategoryIds,
    required this.selectedCategoryId,
    required this.categoryPanelScrollOffset,
    required this.productsScrollOffsets,
  });

  factory _CatalogSplitPersistedState.fromJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString) as Map<String, dynamic>;

    final expanded = (data['expandedCategoryIds'] as List<dynamic>? ?? <dynamic>[])
        .map((value) => value is int ? value : int.tryParse(value.toString()))
        .whereType<int>()
        .toSet();

    final rawOffsets = data['productsScrollOffsets'] as Map<String, dynamic>?;
    final offsets = <int, double>{};
    if (rawOffsets != null) {
      for (final entry in rawOffsets.entries) {
        final key = int.tryParse(entry.key);
        final value = entry.value is num ? (entry.value as num).toDouble() : double.tryParse(entry.value.toString());
        if (key != null && value != null) {
          offsets[key] = value;
        }
      }
    }

    return _CatalogSplitPersistedState(
      horizontalSplitRatio: (data['horizontalSplitRatio'] as num?)?.toDouble(),
      verticalSplitRatio: (data['verticalSplitRatio'] as num?)?.toDouble(),
      searchQuery: data['searchQuery'] as String?,
      expandedCategoryIds: expanded,
      selectedCategoryId: data['selectedCategoryId'] as int?,
      categoryPanelScrollOffset: (data['categoryPanelScrollOffset'] as num?)?.toDouble(),
      productsScrollOffsets: offsets,
    );
  }

  String toJson() {
    final data = <String, dynamic>{
      'horizontalSplitRatio': horizontalSplitRatio,
      'verticalSplitRatio': verticalSplitRatio,
      'searchQuery': searchQuery,
      'expandedCategoryIds': expandedCategoryIds.toList(),
      'selectedCategoryId': selectedCategoryId,
      'categoryPanelScrollOffset': categoryPanelScrollOffset,
      'productsScrollOffsets': productsScrollOffsets.map((key, value) => MapEntry(key.toString(), value)),
    };

    return jsonEncode(data);
  }
}
