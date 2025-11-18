# Catalog Performance Optimization Plan

This document outlines incremental improvements for the offline catalog stack. Items are grouped by impact vs. implementation effort so we can tackle fast gains first and phase in deeper architectural work afterward.

## Tier 1 — High impact, low disruption

1. **Add a warehouse-centric stock index** *(COMPLETE — migration v6)*
   - Implemented via `idx_stock_warehouse_stock` (see `MigrationV6StockIndexes`); removes full scans in the `stock_items` subquery used by both product paging and facet resolution. Result: "first page" delay shrank dramatically for large categories.
2. **Cache warehouse filter decisions per session** *(COMPLETE — `WarehouseFilterService` cache)*
   - The session-level cache now keeps the last `WarehouseFilterResult` (invalidated on logout/region change), eliminating redundant DB/DI hops every time `_loadProducts` or the facet sheet runs.
3. **Log/monitor query plans in dev builds** *(COMPLETE — `CATALOG_LOG_PLAN` flag & instrumentation)*
   - Added `EXPLAIN QUERY PLAN` logging to `_ProductQuerySqlBuilder`, gated by `--dart-define=CATALOG_LOG_PLAN` (works in prod) so we can verify indexes and catch regressions quickly.
4. **Cover ORDER BY with a products index** *(COMPLETE — migration v7)*
   - Introduced `idx_products_title_nocase (title COLLATE NOCASE, code)` and rewrote the catalog paging SQL to stream directly from `products`. This removed the temp B-tree sort that caused 10–15 s stalls.

## Tier 2 — Medium effort, clear payoff

4. **Stop materializing `allowedProductCodes` lists**
   - Change `FacetFilterBloc` → `ProductQueryBuilder` flow to pass the filter itself, not a 2 000-item `IN (...)` clause.
   - Reuse `_ProductQuerySqlBuilder`’s WHERE construction and eliminate redundant DISTINCT queries.
5. **Add sortable keys to facet rows**
   - When upserting facets, store `title_sort_key` (lowercased title) and maybe `vendor_code` in `product_facets`.
   - Lets catalog sorting happen entirely inside the facet table, avoiding a join back to `products` for every page.
6. **Keyset pagination**
   - Replace `LIMIT/OFFSET` with `(title_sort_key, product_code) > (?, ?)` paging tokens. Requires exposing the last item’s sort key to the UI but prevents SQLite from reprocessing already-fetched rows.

## Tier 3 — Larger architectural improvements

7. **Category membership materialization**
   - Maintain a `category_products` helper during sync (columns: `root_category_id`, `product_code`, `has_stock`, `title_sort_key`).
   - Catalog queries become simple index lookups per root category; facets reuse the same table for aggregations.
8. **Incremental facet/cache refresh**
   - After sync deltas, update only affected facet/category rows instead of full rebuilds to keep startup migrations instant.
9. **Background decoding / structured columns**
   - Move critical fields out of `products.raw_json` into dedicated columns or decode via isolates.
   - Reduces UI-thread JSON work when binding `ProductWithStock`.
10. **UX mitigations**
    - Show skeleton tiles immediately, stream results as soon as codes resolve, and surface a "loading large catalog" hint for 2k+ segments.

## Implementation order suggestion

1. Tier 1 (index + caching + plan tooling).
2. Tier 2 items in order (drop allowed codes → sort key → keyset paging).
3. Tier 3 as separate spikes once the quick wins are verified.

Each change should ship with targeted metrics (wall-clock timings before/after) so we can confirm the theoretical gains on real devices.
