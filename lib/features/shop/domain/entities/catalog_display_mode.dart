enum CatalogDisplayMode {
  classic,
  split,
}

extension CatalogDisplayModeX on CatalogDisplayMode {
  String get storageValue => name;

  String get label {
    switch (this) {
      case CatalogDisplayMode.classic:
        return 'Классический';
      case CatalogDisplayMode.split:
        return 'Сплит';
    }
  }

  static CatalogDisplayMode fromStorage(String? value) {
    if (value == null) {
      return CatalogDisplayMode.classic;
    }
    return CatalogDisplayMode.values.firstWhere(
      (mode) => mode.storageValue == value,
      orElse: () => CatalogDisplayMode.classic,
    );
  }
}
