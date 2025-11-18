# Facets Phase 1 — Offline Static Filters

## 1. Scope & Goals
- Deliver offline-first facets for the catalog search/list that rely only on data already synchronized with the device.
- Cover "static" dimensions that do not require stock/promotion context: brands, manufacturers, series, product types, categories (instock tree leaves), novelty/popularity flags, and price-list categories.
- Provide a thin UI to surface facet chips/drawers and apply them to existing category/search flows.
- Keep the implementation easily extensible for Phase 2 (price/promo) and Phase 3 (dynamic characteristics).

## 2. High-Level Architecture
1. **Database layer (Drift)**
   - Reuse existing `products` table JSON payloads.
   - Add lightweight materialized tables for fast grouping (e.g., `product_facets_brand`, `product_facets_category`) populated during sync from `Product` entities.
   - Maintain triggers/DAO methods to sync facet tables alongside main product inserts/updates.
2. **Repository layer + query pipeline**
   - Introduce a unified `ProductQuery` (a superset of the current `FacetFilter`) describing all knobs that influence product retrieval: search text, base/scope categories, brand/manufacturer/type selections, novelty/popular switches, restricted product codes, promo/warehouse flags, etc.
   - Add a `ProductFilterBuilder` service (client-side analogue of backend `FilterService`) that normalizes UI input, merges facet selections, and produces a `ProductQuery` instance + its serialized form (URL/query params) for both Drift queries and remote API calls.
   - Extend `ProductRepository` (local + remote implementations) so every product-listing entry point goes through a single `getProducts(ProductQuery query)` pipeline. `FacetRepository` remains focused on bucket aggregation but now consumes the same `ProductQuery` for consistent scoping.
3. **Use cases**
   - `GetFacetsUseCase` still encapsulates intersection logic but now accepts a `ProductQuery` context rather than scattered params.
   - Introduce `BuildProductQueryUseCase` (or integrate into the filter builder) so catalog/search blocs request a normalized query after every user interaction.
   - Update `SearchProductsUseCase` / `GetCategoryProductsUseCase` to accept `ProductQuery` and delegate to the single repository pipeline (local/offline today, remote later via the same DTO serialization).
4. **Presentation/UI**
   - Add `FacetBloc` (or extend existing catalog bloc) to load facet buckets, handle selection, and emit filter state.
   - Implement drawer/bottom sheet for selecting filters + inline chips summary.

## 3. Implementation Steps

### 3.1 Data Layer
1. **Schema additions** (`lib/app/database/app_database.dart`):
   - Create tables:
     - `product_brands(code INTEGER PRIMARY KEY, brand_id INTEGER, brand_name TEXT, search_priority INTEGER)`.
     - `product_manufacturers`, `product_series`, `product_types`, `product_price_categories`.
     - `product_categories_instock` (many-to-one via `ROWID` autoincrement, fields: `product_code`, `category_id`, `category_name`).
   - Add indexes for `category_id`, `brand_id`, etc. to speed up grouping and filtering.
2. **DAOs/Repositories**:
   - Extend existing product DAO to populate facet tables during `saveProducts` using batch inserts.
   - Add queries to aggregate counts with optional filters:
     ```sql
     SELECT brand_id, brand_name, COUNT(*) AS count
     FROM product_brands pb
     JOIN filtered_products fp ON fp.code = pb.code
     GROUP BY brand_id, brand_name;
     ```
   - `filtered_products` should be a CTE translating `FacetFilter` into WHERE clauses (category scopes, novelty/popular, search query hits via temp table of codes, etc.).

### 3.2 Domain Layer
1. **Entities/value objects**
   - `ProductQuery` (new) living in `lib/features/shop/domain/entities/product_query.dart`: wraps search text, pagination, base/scope categories, facet selections, promo/warehouse/price flags, and `restrictedProductCodes`. Must support `copyWith`, `toJson`, `fromJson`, and `toUriParams()`.
   - `FacetFilter` now becomes a convenience view over `ProductQuery` (or is merged—depends on code reuse). `FacetGroup`, `FacetValue`, etc. stay in `facet.dart`.
2. **Repository contracts**
   - `FacetRepository`: `Future<Either<Failure, List<FacetGroup>>> getFacetGroups(ProductQuery query);` and `Future<Either<Failure, List<int>>> resolveProductCodes(ProductQuery query);` so facets always operate on the same scope.
   - `ProductRepository`: replace scattered category/search methods with a single `Future<Either<Failure, ProductPage>> getProducts(ProductQuery query);` plus optional `Stream` for live updates.
3. **Use cases/services**
   - `ProductFilterBuilder` service (domain or app layer) exposes methods like `ProductQuery build(ProductQuery base, FacetSelection selection)` and `ProductQuery fromRoute(Uri uri)`.
   - `ApplyFacetFilterUseCase` simply wraps the builder, requests `resolveProductCodes`, and emits the updated `ProductQuery` to whichever bloc owns the list.

### 3.3 Application Layer
1. **DI** (`lib/features/shop/di/shop_di.dart`): register new repository implementation + use cases.
2. **Bloc/State** (`lib/features/shop/presentation/bloc/*`):
   - Either enhance existing `CatalogSplitStateStore` or introduce `FacetCubit` managing:
     - Loading facet buckets for current scope (category/search query).
     - Persisting selections between sessions within same category.
3. **UI Components**:
   - `FacetSummaryChips` widget listing active filters with remove buttons.
   - `FacetDrawer` / `FacetBottomSheet` showing groups (brands, categories, types, manufacturers, series, novelty/popular toggles).
   - Integrate entry points in `CategoryProductsPage` and `SplitCategoryProductsPanel` (button near search field).
4. **Pagination/Search Coordination**:
   - Catalog/search blocs keep the latest `ProductQuery` in state. When facets/search text/category changes, they ask `ProductFilterBuilder` for an updated query, then call `SearchProductsUseCase.execute(ProductQuery)`.
   - `FacetFilterBloc` no longer emits raw code lists; it emits a partial `ProductQuery` (or `FacetSelectionPatch`). The consumer merges it and triggers a product reload.
   - Because `ProductQuery` can serialize to route parameters, shareable URLs and remote API calls reuse the same representation.

### 3.4 Testing & Fixtures
- Add fixture-driven unit tests for repository aggregations using sample JSON from `assets/fixtures/product_example*.json` imported into an in-memory DB.
- Widget tests for facet drawer interactions (selection, clearing filters, verifying callbacks).

## 4. Deliverables Checklist
- [ ] Drift schema + migrations for facet helper tables.
- [ ] Repository queries to aggregate facet counts by current `ProductQuery` scope.
- [ ] `ProductQuery` + serialization helpers + `ProductFilterBuilder`.
- [ ] Updated repository/use cases so every list/search call accepts the unified query object.
- [ ] Facet bloc/state emitting `ProductQuery` patches instead of bare code lists.
- [ ] UI components (drawer, chips) integrated into catalog + search + split view.
- [ ] Tests covering repository aggregation, query builder normalization, and basic UI flow.

## 5. Follow-Up (Phase 2+ Hooks)
- Keep `FacetFilter` extensible for stock-aware conditions (warehouse, promotion types, price ranges).
- Ensure schema allows joining future price/promotion tables without refactoring current code.
- Document extension steps once Phase 1 validated in production.
