# 01 — Thiết kế Frontend (Next.js + App Router)

> Cập nhật **2026-08-19** · Lane sở hữu: **FE** · Dời từ `step.md` Bước 4 (mục 4.1–4.5, xem `git log`).
> Sự thật FE khác: [luật](02-luat.md) · [hiện trạng](03-hien-trang.md) · [yêu cầu khi làm việc](04-yeu-cau.md)
> — cả bốn file **đã có đủ**; sự thật mới thì ghi vào file nào, xem [README.md §1](README.md).

**Cảnh báo mạnh hơn bản DB/BE: `fe/` hiện có ĐÚNG 0 file code** ([F-30](../../finding.md#f-30)).
DB có `.sql` chạy được, BE có `code/be/internal/` chạy được — nên hai file `01-thiet-ke.md` kia còn
**lệch được với code**. File này thì không: **toàn bộ nội dung dưới đây là ý định, chưa một dòng
nào được code kiểm chứng.** Route, cấu trúc store, tên package — tất cả đều có thể sai ngay lần
`create-next-app` đầu tiên, và khi đó **code thắng** ([CLAUDE.md §2](../../CLAUDE.md)): mở finding,
đừng bẻ code cho khớp chữ ở đây.

Đo lại con số đó, đừng tin câu trên:

```bash
git ls-files fe/ | wc -l                        # hiện: 0 — `fe/` trống trơn trong git sau T-76
find fe \( -name '*.ts' -o -name '*.tsx' \) | wc -l   # hiện: 0
```

---

### 4.1 Khởi tạo

Dùng `@latest`, đừng ghim số ở đây — `package.json` do lệnh này đẻ ra mới là nhà của version
(§2 "one fact one home"). Tính tới **2026-08-11**, `@latest` cho ra Next 16.3 · React 19.2 ·
Tailwind 4.3 · TypeScript 7.0 — mốc mà mục 4 này được viết dựa trên. Chạy Node **24 LTS**
(dòng Current 26 chưa LTS tới 10/2026, đừng đưa lên máy thật).

```bash
cd fe
npx create-next-app@latest . --typescript --tailwind --app --src-dir --eslint
npm i zustand @tanstack/react-query axios zod react-hook-form @hookform/resolvers \
      sonner lucide-react @microsoft/fetch-event-source
```

### 4.2 Cấu trúc route

```
src/app/
├── (shop)/                       # Web khách — ship & pickup
│   ├── page.tsx                  # Trang chủ
│   ├── menu/page.tsx
│   ├── menu/[slug]/page.tsx      # Chọn nhân + lượng nhân
│   ├── cart/page.tsx
│   ├── checkout/page.tsx
│   └── orders/[code]/page.tsx
│
├── t/[token]/                    # QR tại bàn — KHÔNG cần đăng nhập
│   ├── page.tsx                  # Menu + món đã gọi của bàn
│   └── bill/page.tsx             # Tạm tính + QR chuyển khoản
│
├── staff/                        # Nhân viên
│   ├── login/page.tsx            # Đăng nhập PIN 4 số
│   ├── pos/page.tsx              # QUẦY: sơ đồ bàn → mở phiên → đặt hộ → thu tiền
│   ├── station/[code]/page.tsx   # TRÁNG / GẤP / CANH: hàng đợi việc
│   └── cleaning/page.tsx         # DỌN BÀN: danh sách bàn cần dọn
│
└── admin/                        # Chủ quán
    ├── orders/page.tsx
    ├── products/page.tsx
    ├── tables/page.tsx           # Quản lý bàn + tải QR để in
    ├── staff/page.tsx
    ├── reports/page.tsx
    └── settings/page.tsx         # ← trang điền thông tin quán (mục 4 của scope)
```

### 4.3 Nguyên tắc giao diện — theo từng loại người dùng

**Web khách & QR tại bàn** — khách chỉ dùng vài phút, phải hiểu ngay:

- Mobile-first, thiết kế ở khung 375px trước.
- Món có nhân: hiện **2 hàng nút bấm to** (Nhân / Lượng nhân), giá cập nhật ngay khi bấm. Không dùng dropdown.
- Khi chọn **Chay**, hàng "Lượng nhân" phải **biến mất**, không phải bị làm mờ.
- Giá luôn hiện ở nút: `Thêm vào giỏ · 5.000đ`.
- Combo: hiện rõ "3 bánh cuốn + 1 trứng tái + 1 giò" ngay dưới tên.
- Định dạng tiền `Intl.NumberFormat('vi-VN')` → `34.000đ`.
- Món hết hàng: làm mờ + badge "Hết", không bấm được.

**Màn hình trạm (tráng / gấp / canh)** — nhân viên tay ướt, quán ồn, đang vội:

- **Chữ rất to.** Tên món ≥ 24px, số lượng ≥ 40px.
- **Một task = một thẻ lớn**, chỉ 1 nút: `Xong`. Không menu, không dropdown.
- Sắp xếp theo thời gian đặt, cũ nhất lên đầu.
- **Màu theo thời gian chờ:** trắng (<3 phút) → vàng (3–7) → đỏ (>7). Đây là thứ giúp không bỏ sót bàn.
- Số bàn hiển thị **to nhất trên thẻ** — nhân viên tìm bằng số bàn, không phải bằng mã đơn.
- Không có xác nhận "Bạn chắc chứ?" — bấm nhầm thì bấm `Hoàn tác` trong 10 giây.

**POS đứng quầy** — dùng nhiều nhất, phải nhanh nhất:

- Màn hình chính là **sơ đồ bàn**: ô xanh = trống, cam = có khách, đỏ = cần dọn, kèm tổng tiền tạm tính.
- Bấm một bàn → mở phiên hoặc xem phiếu.
- Đặt hộ: lưới nút món, bấm món → popup chọn nhân → `+`/`−` số lượng. **Mục tiêu: gọi xong 1 suất trong 3 lần chạm.**
- Đơn QR chờ duyệt hiện **banner đỏ trên cùng** kèm chuông — đây là thứ không được bỏ sót.
- Thu tiền: hiện tổng, chọn `Tiền mặt` / `Chuyển khoản` (hiện QR VietQR), bấm xong → đóng phiên, bàn chuyển sang `cần dọn`.

### 4.4 Giỏ hàng (Zustand + localStorage)

```ts
// src/store/cart.ts
import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export type CartItem = {
  key: string           // hash(productId + optionIds đã sort)
  productId: number
  name: string
  optionIds: number[]
  optionLabels: string[]   // ['Thịt + mộc nhĩ', 'Nhiều nhân']
  unitPrice: number        // CHỈ để hiển thị — server luôn tính lại
  quantity: number
  note?: string
}

type CartState = {
  items: CartItem[]
  add: (item: CartItem) => void
  setQuantity: (key: string, qty: number) => void
  clear: () => void
}

export const makeKey = (productId: number, optionIds: number[]) =>
  `${productId}:${[...optionIds].sort((a, b) => a - b).join(',')}`

export const useCart = create<CartState>()(
  persist(
    (set) => ({
      items: [],
      add: (item) => set((s) => {
        const found = s.items.find((i) => i.key === item.key)
        return found
          ? { items: s.items.map((i) =>
              i.key === item.key ? { ...i, quantity: i.quantity + item.quantity } : i) }
          : { items: [...s.items, item] }
      }),
      setQuantity: (key, qty) => set((s) => ({
        items: qty <= 0 ? s.items.filter((i) => i.key !== key)
                        : s.items.map((i) => (i.key === key ? { ...i, quantity: qty } : i)),
      })),
      clear: () => set({ items: [] }),
    }),
    { name: 'banhcuon-cart' },
  ),
)
```

> **`makeKey` phải sort `optionIds`.** Bánh cuốn "Thịt, Nhiều" và "Nhiều, Thịt" là **cùng một món** — không sort thì giỏ hàng sẽ có 2 dòng trùng nhau.

### 4.5 SEO

Chỉ áp dụng cho nhóm `(shop)`; `t/`, `staff/`, `admin/` phải đặt `robots: { index: false }`.

- Title: `Bánh Cuốn [Tên quán] — Bánh cuốn nóng 6h–11h sáng tại [Quận]`
- JSON-LD `Restaurant` + `openingHours: "Mo-Su 06:00-11:00"` + `Menu`
- `sitemap.ts`, `robots.ts`
- **Google Business Profile** — với quán ăn sáng, thứ này mang lại nhiều khách hơn cả website.

