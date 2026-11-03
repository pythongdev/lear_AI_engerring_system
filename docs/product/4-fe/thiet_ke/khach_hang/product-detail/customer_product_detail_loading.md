# Customer Product Detail — Loading States
> Đường dẫn chữ thường trong file này là cấu trúc của dự án gốc, không có trong repo này (T-287, 2026-11-03).

> **TL;DR:** ✅ implemented · how `/menu/product/:id` behaves while data is in flight. Two layers:
> (1) a route-level spinner during navigation (shared `(shop)/loading.tsx`), (2) per-query state
> inside the page — `useProductDetail`'s `isLoading` drives `ProductDetailSkeleton`; `isError`
> drives a "not found" panel with a back link. There is **no** `loading.tsx` or `<Suspense>` specific
> to this route — it is a `'use client'` component that manages all states inline.
>
> Traced from source on branch `experience_claude.md_system_1` (NOT from docs).
> Sources:
> `fe/src/app/(shop)/loading.tsx` ·
> `fe/src/app/(shop)/menu/product/[id]/page.tsx` ·
> `fe/src/components/product-detail/ProductDetailSkeleton.tsx` ·
> fe/src/hooks/useProductDetail.ts ·
> `fe/src/components/product-detail/CTAFooter.tsx`
>
> Siblings:
> Page overview → [customer_product_detail.md](customer_product_detail.md) ·
> BE view → [customer_product_detail_be.md](customer_product_detail_be.md) ·
> Cross-page flow → customer_product_detail_crosspage_dataflow.md ·
> Scenario → SCENARIO_PRODUCT_ADD.md

---

## Loading Layers (outer → inner)

```
1. Route navigation  → ShopLoading  (centered orange spinner, entire (shop) shell)
2. No route-specific loading.tsx for /menu/product/[id]  — none exists
3. No <Suspense> in page.tsx  — 'use client' component, no useSearchParams
4. ProductDetailPage mounts  → useProductDetail fires; page branches on isLoading / isError / product
```

### Layer 1 — Route-level spinner · `fe/src/app/(shop)/loading.tsx:1-7`

Next.js App Router renders this file for **every `(shop)` route** during server-side navigation
(including `/menu/product/:id`). It is a single centered spinner — `h-64` flex container, `h-8 w-8`
ring, `animate-spin`, `border-t-orange-500` — shared by all shop pages.

- Not product-specific. No layout shell, no skeleton shapes.
- Source: `../../../../../fe/src/app/(shop)/loading.tsx`

### Layer 2 — No product-specific `loading.tsx`

The directory `fe/src/app/(shop)/menu/product/[id]/` contains **only `page.tsx`**. There is no
`loading.tsx` at the product route, no `layout.tsx`, and no `<Suspense>` wrapper inside `page.tsx`.
The route-level spinner (layer 1) is the only route-level loading signal.

### Layer 3 — Per-query states · `page.tsx:22, 57-104`

`ProductDetailPage` is a `'use client'` component (`page.tsx:1`). It calls one hook:

```ts
// page.tsx:22
const { data: product, isLoading, isError } = useProductDetail(id)
```

All loading UI is driven by this single destructure. The page renders exactly one of three mutually
exclusive branches in the body below `CustomerTopNav`:

| Priority | Condition | Renders | Source line |
|---|---|---|---|
| 1 | `isLoading` | `<ProductDetailSkeleton />` | `page.tsx:57` |
| 2 | `isError` | Error panel (see below) | `page.tsx:59-69` |
| 3 | `product` (truthy) | Hero / info / toppings / qty / CTA | `page.tsx:71-104` |

`CustomerTopNav` (title, back, cart count) is rendered **before** the branches and is always visible
regardless of loading state (`page.tsx:51-55`).

---

## Main Content Branch · `page.tsx:57-104`

### State 1 — Skeleton (`isLoading`) · `page.tsx:57`

```tsx
{isLoading && <ProductDetailSkeleton />}
```

Renders `ProductDetailSkeleton` — source:
`../../../../../fe/src/components/product-detail/ProductDetailSkeleton.tsx`.

The skeleton is a single `animate-pulse` wrapper containing four zones that mirror the real content
layout:

| Skeleton zone | What it mimics | Shape details | Source line |
|---|---|---|---|
| Zone A | Hero image | `w-full aspect-[390/220] bg-muted` | `ProductDetailSkeleton.tsx:5` |
| Zone B | Product name + badge + price + description | 4 `bg-muted` bars: 3/4-width title, 1/3-width price, 3 description lines (full / 5/6 / 4/6) | `ProductDetailSkeleton.tsx:8-19` |
| Zone C | Topping grid | label bar + 2×2 grid of `h-16 rounded-xl` cells (4 toppings) | `ProductDetailSkeleton.tsx:22-29` |
| Zone D | Quantity stepper | label bar + three `bg-muted` circles/bars (`w-9 h-9` minus, `w-6 h-5` count, `w-9 h-9` plus) + `pb-32` spacer for fixed footer | `ProductDetailSkeleton.tsx:32-39` |

Note: Zone C in the skeleton is **always rendered** (a 2×2 grid of 4 cards) even if the real
product has zero toppings (`product.toppings.length > 0` guard at `page.tsx:80` only applies once
`product` is loaded). There is no conditional logic in the skeleton.

### State 2 — Error panel (`isError`) · `page.tsx:59-69`

```tsx
{isError && (
  <div className="flex flex-col items-center justify-center min-h-[60vh] gap-4 px-6">
    <p className="text-muted-fg text-center">Không tìm thấy sản phẩm.</p>
    <button onClick={() => router.back()} className="text-primary text-sm underline">
      Quay lại menu
    </button>
  </div>
)}
```

- `min-[60vh]` vertical center, centered text.
- "Không tìm thấy sản phẩm." — generic message for **all** error types (404, 500, network).
- "Quay lại menu" button calls `router.back()` — same as the nav back button.
- No retry / refetch button. Source: `page.tsx:59-69`.

### State 3 — Success (`product` truthy) · `page.tsx:71-104`

All content zones render: `ProductHeroImage`, `ProductInfo`, optional `ToppingSelector` (guarded by
`product.toppings.length > 0`), `QuantityStepper`, `CTAFooter`. No transition animation between
skeleton and content — the skeleton is removed and content mounts synchronously.

---

## Hook Semantics · `useProductDetail.ts:1-12`

Source: ../../../../../fe/src/hooks/useProductDetail.ts

```ts
export function useProductDetail(id: string) {
  return useQuery<Product>({
    queryKey: ['products', id],
    queryFn: () => api.get(`/products/${id}`).then(r => r.data.data),
    staleTime: 5 * 60 * 1000,
    enabled: !!id,
  })
}
```

| Property | Value | Effect |
|---|---|---|
| `queryKey` | `['products', id]` | Scoped per product id; cached independently |
| `staleTime` | `5 * 60 * 1000` (5 min) | No re-fetch on revisit within 5 minutes; `isLoading` stays false on second visit |
| `enabled` | `!!id` | Disabled if `id` is falsy |

**`enabled: !!id` gating behaviour (TanStack Query v5):**
In TanStack Query v5, a query with `enabled: false` is in `status: 'pending'` but `isFetching` is
`false`. The compound flag `isLoading` is defined as `isPending && isFetching`, so for a disabled
query `isLoading === false`. This means if `id` is falsy (e.g. the route param is somehow absent),
the page will render **neither the skeleton nor the error panel** — the content area will be empty
below `CustomerTopNav`. In practice `useParams<{ id: string }>()` (`page.tsx:15`) always supplies a
non-empty string when the route matches, so this case is unreachable in normal navigation. The gating
is a defensive guard, not a visible loading state.

**Cache hit (revisit within 5 min):** `isLoading` is `false` on mount; `product` is immediately
defined; the skeleton is skipped entirely and the content zone renders synchronously.

---

## Search / Interaction Gating

This page fetches a single product with a fixed `id` from the route param — there is no search
input, no filter, and no user-driven `enabled` gate beyond `!!id`. The only interaction that could
affect loading is navigation: pressing back before the query settles unmounts the component and
cancels the in-flight request (TanStack Query behaviour).

---

## Flags / Known Gaps

| # | Gap | Detail |
|---|---|---|
| 1 | **Dead `loading?` prop on `CTAFooter`** | `CTAFooter` accepts a `loading?: boolean` prop (`CTAFooter.tsx:6`) that sets `aria-label="Đang thêm vào giỏ hàng"` and `disabled={!isAvailable \|\| loading}` (`CTAFooter.tsx:15-16`). The call site at `page.tsx:98-102` **never passes `loading`** — `handleAddToCart` is synchronous (local Zustand write + `router.back()`). The prop is dead code on this branch. |
| 2 | **No `loading.tsx` at product route level** | The `(shop)/loading.tsx` spinner appears during navigation to the page, but once the JS bundle is loaded and the client component mounts, there is no route-level fallback — all loading is handled inside `page.tsx`. If the bundle is slow (cold load), the user sees the shared orange spinner; once mounted they see either the skeleton or the error panel. |
| 3 | **Generic error message for all failure types** | `isError` shows "Không tìm thấy sản phẩm." regardless of whether the failure is a 404, a 500, or a network timeout. There is no retry button. Source: `page.tsx:61`. |
| 4 | **Skeleton always shows 4 topping cards** | `ProductDetailSkeleton` renders a fixed 2×2 topping grid (`ProductDetailSkeleton.tsx:24-28`). For products with zero toppings, the skeleton shows a topping section that will disappear on load — minor layout shift on transition. |
| 5 | **No `<Suspense>` / SSR note** | `page.tsx` is `'use client'`; it opts out of SSR. The route is never server-rendered. The `(shop)/loading.tsx` spinner is the only SSR-phase signal. |
