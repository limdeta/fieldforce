/// SQL-индексы для оптимизации StockItemTable
/// 
/// Эти индексы критически важны для производительности:
/// - Частые JOIN с ProductTable по product_code
/// - Региональная фильтрация по warehouse_vendor_id
/// - Поиск товаров в наличии (stock > 0)
/// - Ценовые запросы для каталогов
class StockItemIndexes {
  static const List<String> createIndexes = [
    /// Основной индекс для поиска по коду продукта
    'CREATE INDEX IF NOT EXISTS idx_stock_product_code ON stock_items(product_code)',
    
    /// Индекс для региональной фильтрации по продавцу/складу
    'CREATE INDEX IF NOT EXISTS idx_stock_warehouse_vendor ON stock_items(warehouse_vendor_id)',
    
    /// Композитный индекс для быстрых JOIN операций
    'CREATE INDEX IF NOT EXISTS idx_stock_product_warehouse ON stock_items(product_code, warehouse_id)',
    
    /// Частичный индекс для поиска товаров в наличии
    'CREATE INDEX IF NOT EXISTS idx_stock_availability ON stock_items(stock) WHERE stock > 0',
    
    /// Индекс для ценовых запросов в каталоге
    'CREATE INDEX IF NOT EXISTS idx_stock_prices ON stock_items(offer_price, default_price)',
  ];
}