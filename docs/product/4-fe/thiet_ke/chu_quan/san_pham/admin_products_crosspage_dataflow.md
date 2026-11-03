# Admin Products — Cross-Page Data Flow (the catalog, after a write leaves `/admin/products`)
> Đường dẫn chữ thường trong file này là cấu trúc của dự án gốc, không có trong repo này (T-287, 2026-11-03).

> **TL;DR:** ✅ implemented.
> A product created, edited, or deleted on `/admin/products` is a **write that outlives the page**.
> There is no SSE/WS push, no localStorage handoff, and no shared FE store — the propagation
> mechanism is purely server-side: one MySQL `products` row + four Redis cache keys, and a
> cache-invalidation call attached to every write. Downstream pages pick up the change only on their
> **next fetch** (worst-case staleness = FE `staleTime` + 5-min Redis TTL). The sole exception is
> the price/name snapshot written into `order_items` at order-creation time — once snapshotted,
> existing orders are immune to future catalog edits.
>
> Sources traced on branch `experience_claude.md_system_1`:
> [`fe/src/app/(dashboard)/admin/products/page.tsx`](../../../../../fe/src/app/(dashboard)/admin/products/page.tsx) ·
> [`fe/src/app/(dashboard)/admin/products/_components/ProductFormModal.tsx`](../../../../../fe/src/app/(dashboard)/admin/products/_components/ProductFormModal.tsx) ·
> fe/src/features/admin/admin.api.ts (dự án gốc: fe/src/features/admin/admin.api.ts) ·
> be/internal/service/product_service.go (dự án gốc: be/internal/service/product_service.go) ·
> be/internal/db/products.sql.go (dự án gốc: be/internal/db/products.sql.go) ·
> [`fe/src/app/(shop)/menu/page.tsx`](../../../../../fe/src/app/(shop)/menu/page.tsx) ·
> [`fe/src/app/(dashboard)/pos/page.tsx`](../../../../../fe/src/app/(dashboard)/pos/page.tsx)
>
> On-page widget flow → [admin_products_crosscomponent_dataflow.md](admin_products_crosscomponent_dataflow.md) ·
> Page zones + object model → [admin_products.md](admin_products.md) ·
> BE endpoints, caching, errors → [admin_products_be.md](admin_products_be.md) ·
> Loading states → [admin_products_loading.md](admin_products_loading.md) ·
> Scenario → [SCENARIO_PRODUCT_CRUD.md](SCENARIO_PRODUCT_CRUD.md) ·
> **Availability toggle broken** → [PRODUCTS_BUGS.md](PRODUCTS_BUGS.md) #1

---

## 0. The whole picture on one diagram

This is not a realtime story — it is a cache invalidation story. Read it as:
*admin writes → MySQL updated + Redis evicted → downstream pages rebuild from MySQL on next fetch.*

```
   ┌───────────────────── ADMIN DEVICE ─────────────────────┐
   │                                                          │
   │  /admin/products                                         │
   │     POST/PATCH/DELETE  ──────────────────────────────▶  │
   │                                                   BE     │
   │  qc.invalidateQueries(['admin','products'])      ─────   │
   │  (TanStack Query — admin page only)               │      │
   └────────────────────────────────────────────────── │ ─────┘
                                                       │
   ═════════════════════════ THE WIRE ════════════════ │ ══════
                                                       │
                         ┌─────────────────────────────▼─────┐
                         │     MySQL: products (one row)      │
                         │     + product_toppings (join)      │
                         │     + categories, toppings         │
                         └──┬────────────────────────────┬───┘
                            │  invalidateProductCaches    │
                            │  Dels:                      │
                            │   products:list             │
                            │   categories:list           │
                            │   product:<id>              │
                            │  (+ toppings:list if        │
                            │    topping write)           │
                            │                             │
              ┌─────────────▼──────────┐   ┌─────────────▼──────────┐
              │  Redis cache evicted   │   │  Redis cache evicted   │
              │  (next read rebuilds)  │   │  (next read rebuilds)  │
              └─────────────┬──────────┘   └─────────────┬──────────┘
                            │                             │
   ┌────────────────────────▼───┐             ┌───────────▼──────────────┐
   │  Customer /menu            │             │  Staff /pos              │
   │  GET /products             │             │  GET /products           │
   │  (ListProductsAvailable    │             │  (same endpoint,         │
   │   — is_available=1 only)   │             │   no is_available filter)│
   │  staleTime: 5 min          │             │  staleTime: 5 min        │
   │  queryKey: ['products',…]  │             │  queryKey: ['products',…]│
   └────────────────────────────┘             └──────────────────────────┘
                            │
   ┌────────────────────────▼───┐
   │  (historical) order_items  │  ← snapshotted at order-create time;
   │  name · unit_price stored  │    immune to later catalog edits
   │  on the row itself         │    (durability boundary)
   └────────────────────────────┘
```

**Two things this diagram is NOT:**
- There is **no SSE/WS push** for catalog changes. Downstream pages do not get a live notification
  when a product is edited — they pick it up only when their TanStack Query cache expires and they
  refetch.
- There is **no localStorage / persisted-store handoff**. The admin page holds nothing in
  localStorage. `['admin','products']` lives only in the admin page's TanStack Query instance.

---

## 1. The moment of handoff — what a write leaves behind

Every CRUD write on this page ends with two parallel invalidation calls, one on the BE and one in
the FE, that together define exactly what outlives the page.

### BE-side: cache eviction (the durable handoff)

Every product write (create / update / delete) calls `invalidateProductCaches` immediately after the
MySQL mutation succeeds:

```
   ProductService.CreateProduct  (product_service.go:276)
   ProductService.UpdateProduct  (product_service.go:328)
   ProductService.DeleteProduct  (product_service.go:337)
        │
        └─▶ invalidateProductCaches(ctx, id)   (product_service.go:709-717)
                 rdb.Del(ctx, "products:list", "categories:list", "product:<id>")
```

A topping write (create / update / delete) calls `invalidateToppingCaches`:

```
   ProductService.CreateTopping / UpdateTopping / DeleteTopping
        │
        └─▶ invalidateToppingCaches(ctx)        (product_service.go:719-721)
                 rdb.Del(ctx, "toppings:list", "products:list")
                 (products:list must also be evicted because products embed their toppings)
```

The cache TTL when a key is **set** is `productCacheTTL = 5 * time.Minute`
(`product_service.go:21`). After a write the key is **deleted outright** — it is not reset to a new
value. The next read from any downstream page repopulates it lazily (cache-aside pattern, see
docs/system/03_be/REDIS_CACHE.md (dự án gốc: 03_be/REDIS_CACHE.md)).

**What is NOT evicted:** The admin table's own `GET /products/all` endpoint — `ListAllProducts`
(`product_service.go:194-209`) — is intentionally **uncached**. It goes to MySQL on every call,
which is why a manager sees their own writes immediately without waiting for TTL.

### FE-side: TanStack Query invalidation (the admin-only signal)

After each mutation succeeds, the page calls:

```javascript
// page.tsx:31 (deleteMut onSuccess)
qc.invalidateQueries({ queryKey: ['admin', 'products'] })

// page.tsx:47 (toggleMut onSuccess)
qc.invalidateQueries({ queryKey: ['admin', 'products'] })

// ProductFormModal.tsx:100 (saveMut onSuccess, via invalidate())
qc.invalidateQueries({ queryKey: ['admin', 'products'] })
```

This refetch only affects queries keyed `['admin','products']` — the admin table's own view. It
**does not** touch the customer or POS page caches, which use different TanStack Query keys
(`['products',…]`). Those pages are unaffected unless they also happen to refetch.

| Write type | BE keys evicted | FE queries invalidated |
|---|---|---|
| Create product | `products:list` · `categories:list` · `product:<id>` | `['admin','products']` only |
| Update product | same | same |
| Delete product (soft) | same | same |
| Topping write | `toppings:list` · `products:list` | `['admin','products']` only (seed button invalidates `['admin']` broadly — `page.tsx:106`) |
| Category write | `products:list` · `categories:list` | same |

---

## 2. `products:list` → Customer `/menu` (the main downstream surface)

The customer menu at `/menu` reads `GET /products` — **not** `GET /products/all`. The difference is
the query executed:

| Admin endpoint | SQL | Returns |
|---|---|---|
| `GET /products/all` (manager+) | `ListProducts` — `WHERE deleted_at IS NULL` (`products.sql.go:426-430`) | All rows incl. `is_available=false` |
| `GET /products` (public) | `ListProductsAvailable` — `WHERE is_available = 1 AND deleted_at IS NULL` (`products.sql.go:467-470`) | Available rows only |

The public endpoint is what fills the `products:list` Redis key. When a product is created or
edited, `invalidateProductCaches` evicts that key. The next customer `GET /products` is a cache
miss — MySQL is queried, the `is_available = 1` filter is re-applied, and the new result is cached
for another 5 minutes.

**Staleness model for the customer menu:**

```
   Admin saves product edit
         │
         ├─ (instant) MySQL updated
         ├─ (instant) Redis "products:list" deleted
         │
         ▼
   Next customer visit to /menu within ≈5 minutes:
         │
         ├─ TanStack Query still has its own in-memory cache (staleTime = 5 min, menu/page.tsx:55)
         │   → customer may still see stale data from their own last fetch
         │
         └─ TanStack Query cache expired or page re-mounted:
               → FE calls GET /products
               → Redis miss → MySQL read → is_available=1 filter → fresh data
               → Redis re-populated (new 5-min TTL)

   Worst-case staleness ≈ FE staleTime (5 min) + Redis TTL (5 min) = up to ~10 min
   (only if customer fetched just before admin wrote AND stays on the page for 5 min)
```

The menu page uses `staleTime: 5 * 60 * 1000` (5 min) for both the filtered and unfiltered product
queries (`menu/page.tsx:55, 63`). On the customer's next page reload or when the staleTime expires,
they get the fresh catalog.

**`product/<id>` — single-product detail cache:** When a customer navigates to a product detail
page, `GetProduct` (`product_service.go:212-233`) reads and caches `product:<id>` (5-min TTL). A
product edit evicts this key too (`invalidateProductCaches` with non-empty `id`), so the next detail
load rebuilds from MySQL.

**`categories:list`:** Category changes (create/update/delete, or any product write) evict
`categories:list`. The category tabs on the customer menu rebuild from MySQL on the next read.

**`toppings:list`:** A topping write evicts `toppings:list` **and** `products:list` (because product
responses embed their toppings). A customer loading `/menu` after a topping change gets the updated
topping prices and names.

---

## 3. `products:list` → Staff `/pos` (walk-in order build)

The POS page reads the same public `GET /products` endpoint (`pos/page.tsx:48`):

```javascript
// pos/page.tsx:45-51
const { data: products = [] } = useQuery<Product[]>({
  queryKey: ['products', selectedCategory],
  queryFn:  () =>
    api.get('/products', { params: selectedCategory ? { category_id: selectedCategory } : {} })
      .then(r => r.data?.data ?? r.data ?? []),
  staleTime: 5 * 60 * 1000,
})
```

Note: the POS does **not** pass `is_available: true` as a filter param (unlike `menu/page.tsx:73`
which explicitly adds it). The public `GET /products` route (`main.go:168`) maps to
`productH.ListProducts`, which calls `ListProducts` service — which in turn calls `repo.ListProductsAvailable`
(`product_service.go:173`). The `is_available = 1` filter is enforced at the SQL level, so the POS
also only sees available products, even without passing the param explicitly.

The staleness model is identical to the customer menu: a product edit on `/admin/products` evicts
`products:list`, and the POS picks it up on the next staleTime expiry or page reload (also 5 min).

The POS page uses a different TanStack Query key (`['products', selectedCategory]`) than the admin
page (`['admin','products']`), so admin-side `invalidateQueries` never reaches the POS cache.

---

## 4. The price/name snapshot — the durability boundary

When a customer or staff member places an order, the order-creation service writes each item's name
and price directly into `order_items`:

```sql
-- orders.sql.go:55-57
INSERT INTO order_items (id, order_id, product_id, combo_id, combo_ref_id,
                         name, unit_price, quantity, qty_served, toppings_snapshot, note)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?)
```

The `name` column (text) and `unit_price` column (decimal string) are snapshotted from the product
row **at order time** — they are not foreign keys that resolve later. A toppings JSON blob is also
stored as `toppings_snapshot`.

**Consequence:** if an admin edits a product's name or price after an order containing that product
has been placed, **the existing order is unaffected**. KDS, the admin overview waiting section, the
customer order detail, and any order history all read the snapshotted `name` + `unit_price` from
`order_items`, not the current `products` row. The catalog change takes effect only for orders
created **after** the edit.

> This is the intended behavior — see
> docs/system/02_spec/BUSINESS_RULES.md (dự án gốc: 02_spec/BUSINESS_RULES.md) and the order object
> model in docs/system/02_spec/object/OBJECT_MODELS.md (dự án gốc: 02_spec/object/OBJECT_MODELS.md).

---

## 5. `is_available` — the cross-page lever (and its broken toggle)

`is_available` is the single flag that controls whether a product appears on the customer menu and
staff POS. Flipping it to `false` removes the product from `ListProductsAvailable` (`products.sql.go:467-470`
— `WHERE is_available = 1`) and therefore from the `products:list` cache on the next customer/POS
fetch.

**However, the availability toggle on this page is currently broken:**

The FE calls `PATCH /products/:id/availability` with body `{ is_available }` (`admin.api.ts:51-52`).
The route at `main.go:176` points at the **same `productH.UpdateProduct` handler** used for `PATCH
/:id`. That handler's `updateProductRequest` struct requires `name`, `price`, and `category_id`
(`product_handler.go:124-127`). An `is_available`-only body fails `ShouldBindJSON` and returns
`400 INVALID_INPUT`. Even if the bind were to succeed, `UpdateProduct` service has no `is_available`
field in `UpdateProductInput` and the SQL `UpdateProduct` does not touch the column.

The `ToggleProductAvailability` sqlc query (`products.sql.go:667-676`) exists and is wired to a
repository method (`product_repo.go:82-84`), but **no service method calls it**. Clicking the
availability toggle always errors with FE toast "Không thể cập nhật trạng thái"
(`page.tsx:48`).

Full detail: **[PRODUCTS_BUGS.md](PRODUCTS_BUGS.md) #1**.

Until fixed, the `is_available` column can only be changed via the seed flow (new products always
get `is_available = 1`, `product_handler.go:108`) or direct DB edit.

---

## 6. Multi-page staleness — the worst case

Because there is no push mechanism, the worst-case window before a downstream page reflects a
catalog write is additive:

```
   Admin writes product at T=0
        │
        ├── MySQL updated (instant)
        ├── Redis "products:list" DEL'd (instant)
        │
        ▼
   Customer on /menu who fetched at T=-1min:
        TanStack Query staleTime = 5 min → their cache expires at T=4min
        Next refetch triggers at T=4min → Redis miss → MySQL read → fresh
        Worst case: customer sees old data until T≈4min (4 min window)

   Customer who navigates to /menu at T=1min (fresh mount):
        TanStack Query has no cache → fetches immediately → Redis miss → MySQL
        They see the new data within seconds.

   (staleTime + TTL = up to 10 min only if a customer fetched at T=-5min and the
    Redis key was somehow not yet evicted — that cannot happen after a write, since
    the write DELs the key synchronously before the response returns.)
```

In practice: after an admin write, the Redis key is gone instantly. Any page mounting fresh after
that write will hit MySQL and see the new data within milliseconds. Staleness only affects pages
that already have a warmed TanStack Query cache, bounded by their `staleTime` (5 minutes).

---

## 7. What does NOT flow across pages (no-handoff contract)

| What | Why it does not cross pages |
|---|---|
| Admin `['admin','products']` TanStack Query cache | Scoped to the admin page's React tree; customer and POS use different query keys |
| Selected product / open modal state | Local `useState` in `page.tsx:19` — evaporates on navigation |
| Any localStorage entry | This page writes nothing to localStorage |
| SSE/WS product-change notification | Not implemented — no pub/sub channel exists for catalog changes |
| `is_available` toggle (currently) | No-op at the BE — see §5 and [PRODUCTS_BUGS.md](PRODUCTS_BUGS.md) #1 |

---

## 8. Reload (F5) behavior per page

| Page | Cold-load behavior after admin product edit |
|---|---|
| `/admin/products` | Fetches `GET /products/all` (uncached) → always fresh from MySQL |
| Customer `/menu` | Fetches `GET /products` → Redis miss (key was evicted) → MySQL `is_available=1` → fresh |
| Staff `/pos` | Fetches `GET /products` → same as above |
| Admin `/admin/overview` (KDS / order rendering) | Reads `order_items.name` + `unit_price` from DB snapshot — **not** the current `products` row → unaffected by edits |

---

## 9. Durability matrix

| Datum | Lives in | Survives F5? | Survives new device / browser? | Who reads it |
|---|---|---|---|---|
| `products` MySQL row | BE MySQL (durable) | ✅ | ✅ | All pages, all devices — the single source of truth |
| `products:list` Redis cache | BE Redis (5-min TTL) | ✅ (until TTL or eviction) | ✅ | Customer `/menu` · Staff `/pos` · first GET after admin write |
| `product:<id>` Redis cache | BE Redis (5-min TTL) | ✅ (until TTL or eviction) | ✅ | Single-product detail (customer or admin) |
| `categories:list` / `toppings:list` | BE Redis (5-min TTL) | ✅ | ✅ | Customer menu category tabs · ProductFormModal dropdowns |
| `['admin','products']` TanStack cache | Admin browser memory | ❌ (dies on F5) | ❌ | Admin page table only |
| `order_items.name` + `unit_price` | BE MySQL (durable, snapshotted) | ✅ | ✅ | KDS · order history · customer order detail — **immutable post-order** |

> **The mental model in one line:** within the admin page, `['admin','products']` is the live
> view (always fresh — no Redis, no staleTime delay); across all other pages and devices, the
> **MySQL `products` row** is the single source of truth, propagated lazily through Redis cache
> eviction. There is no SSE/WS push, no localStorage bridge, and no cross-page store.

---

## 10. Source & rule map

| Topic | Source of truth |
|---|---|
| On-page (cross-component) widget flow | [admin_products_crosscomponent_dataflow.md](admin_products_crosscomponent_dataflow.md) |
| Page zones + wireframe + object model | [admin_products.md](admin_products.md) |
| BE endpoints, auth, caching, errors | [admin_products_be.md](admin_products_be.md) |
| Loading states | [admin_products_loading.md](admin_products_loading.md) |
| End-to-end CRUD narrative | [SCENARIO_PRODUCT_CRUD.md](SCENARIO_PRODUCT_CRUD.md) |
| Redis cache keys, TTL, invalidation patterns | docs/system/03_be/REDIS_CACHE.md (dự án gốc: 03_be/REDIS_CACHE.md) |
| Order object model / price-snapshot rule | docs/system/02_spec/BUSINESS_RULES.md (dự án gốc: 02_spec/BUSINESS_RULES.md) · docs/system/02_spec/object/OBJECT_MODELS.md (dự án gốc: 02_spec/object/OBJECT_MODELS.md) |
| Availability toggle bug (full detail) | [PRODUCTS_BUGS.md](PRODUCTS_BUGS.md) #1 |
| `invalidateProductCaches` · `invalidateToppingCaches` | `be/internal/service/product_service.go:709-721` |
| `ListProductsAvailable` (is_available=1 filter) | `be/internal/db/products.sql.go:467-470` |
| `ListProducts` (all rows, admin) | `be/internal/db/products.sql.go:426-430` |
| `order_items` name/price snapshot at order time | `be/internal/db/orders.sql.go:55-70` |
| Admin page write invalidations | `fe/src/app/(dashboard)/admin/products/page.tsx:31,47,106` |
| `toggleAvailability` FE call | `fe/src/features/admin/admin.api.ts:51-52` |
| Customer menu product fetch | `fe/src/app/(shop)/menu/page.tsx:59-76` |
| POS product fetch | `fe/src/app/(dashboard)/pos/page.tsx:45-51` |
