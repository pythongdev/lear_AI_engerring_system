# 03 — Hiện trạng Frontend (Next.js)

> Cập nhật **2026-08-12** · Lane sở hữu: **FE** · Dời từ `status/03-frontend.md` (`git log --follow`).
> Nguồn sự thật: **code trong `fe/`** — code thắng file này khi lệch ([CLAUDE.md §2](../../CLAUDE.md)).
> Hôm nay `fe/` rỗng, nên **cả file này là lời khai chưa có code đối chứng** — xem ngay mục dưới.
> Sự thật FE khác: [thiết kế](01-thiet-ke.md) · [luật](02-luat.md) · [yêu cầu khi làm việc](04-yeu-cau.md).

## Tình trạng: **0% code — `fe/` không còn file nào**

Đo lại ngay sau `T-76` (đợt dời hai file cuối ra khỏi `fe/`) — đừng tin con số, chạy lại lệnh:

```bash
git ls-files fe/ | wc -l    # → 0
find fe -type f | wc -l     # → 0
```

`fe/` nay là **thư mục rỗng trên đĩa và trống trơn trong git** — clone sạch không có nó. Không
`package.json`, không `node_modules`, không một file `.tsx` nào ([F-30](../../finding.md#f-30)).

**`fe/` biến mất là kết quả mong muốn của `T-76`, không phải mất file.** File luật duy nhất từng
nằm ở đó (`fe/AGENTS.md`) đã dọn về [04-yeu-cau.md](04-yeu-cau.md) cùng nhà với ba sự thật FE còn
lại — `git log --follow -M40% -- design/frontend/04-yeu-cau.md` ra nguyên lịch sử (**`--follow`
trần không đủ**: file bị viết lại quá nửa nên ngưỡng rename mặc định 50% không nhận). `T-23` sẽ
dựng lại `fe/` bằng `create-next-app`.

Luật viết trước code là cố ý: `create-next-app` sẽ đẻ ra hàng chục file, còn luật thì không tự
sinh ra — dựng app trước rồi mới viết luật là lúc đã có sẵn code sai để bảo vệ.

Những thứ *nhắc tới* frontend nhưng chưa có gì đằng sau:

| Nơi | Nhắc tới gì | Thực tế |
|---|---|---|
| [04-yeu-cau.md](04-yeu-cau.md) | luật lane FE, biên nhận `make test-fe` | luật đã có; `make test-fe` **chưa tồn tại**, gắn vào [Makefile](../../Makefile) ở `T-23` |
| [.env.example:29-31](../../.env.example#L29-L31) | `NEXT_PUBLIC_API_URL`, `NEXT_PUBLIC_SITE_NAME` | biến đã khai báo, chưa ai đọc |
| [.env.example:17](../../.env.example#L17) | `FE_HOST_PORT=3000` | **compose không có service `fe`** ([F-15](../../finding.md#f-15)) |
| [.gitignore](../../.gitignore) | `fe/.next/`, `fe/out/`, `node_modules/` | đã chuẩn bị sẵn |
| [01-thiet-ke.md §4](01-thiet-ke.md) | cấu trúc route đầy đủ + nguyên tắc UI | mới là kế hoạch |
| [02-luat.md](02-luat.md) | tsconfig strict, ESLint, E2E | mới là tiêu chuẩn |

## Phải xây những gì — 4 nhóm route ([01-thiet-ke.md §4.2](01-thiet-ke.md))

### 1. `(shop)/` — web khách ship & pickup
`page.tsx` · `menu/` · `menu/[slug]` · `cart/` · `checkout/` · `orders/[code]`

**Backend đã sẵn sàng phục vụ nhóm này một phần:** `/settings`, `/categories`, `/products`,
`/products/:slug`, `/orders/quote` đều chạy được rồi. Chỉ thiếu `POST /orders` ở bước
checkout và `GET /orders/:code` ở trang tra cứu.
→ **Đây là nhóm route duy nhất có thể bắt đầu ngay hôm nay** mà không bị backend chặn.

### 2. `t/[token]/` — QR tại bàn (không đăng nhập)
`page.tsx` (menu + món đã gọi) · `bill/page.tsx` (tạm tính + QR chuyển khoản)
→ Bị chặn: cần `GET /t/:token`, `POST /t/:token/orders`, `GET /t/:token/bill`.

### 3. `staff/` — nhân viên
`login/` (PIN 4 số) · `pos/` (sơ đồ bàn → mở phiên → đặt hộ → thu tiền) ·
`station/[code]/` (hàng đợi việc) · `cleaning/`
→ Bị chặn: cần toàn bộ auth + `/staff/*` + SSE.

### 4. `admin/` — chủ quán
`orders/` · `products/` · `tables/` · `staff/` · `reports/` · `settings/`
→ Bị chặn: cần toàn bộ `/admin/*`.

## Ràng buộc UI đã chốt — đọc trước khi viết dòng đầu tiên

Những điều này ở [01-thiet-ke.md §4.3](01-thiet-ke.md), là **yêu cầu nghiệp vụ chứ không phải gu thẩm mỹ**:

**Khách & QR bàn**
- Mobile-first, thiết kế ở khung **375px** trước.
- Món có nhân: **2 hàng nút bấm to** (Nhân / Lượng nhân), giá đổi ngay khi bấm. **Không dropdown.**
- Chọn **Chay** → hàng "Lượng nhân" **biến mất hẳn**, không phải làm mờ.
  (Khớp với backend: `groupApplicable` sẽ **từ chối** nếu FE vẫn gửi lên.)
- Giá luôn hiện trên nút: `Thêm vào giỏ · 5.000đ`.
- Tiền định dạng `Intl.NumberFormat('vi-VN')` → `34.000đ`.
- Món hết hàng: mờ + badge "Hết", không bấm được.

**Màn hình trạm** (nhân viên tay ướt, quán ồn, đang vội)
- Tên món **≥ 24px**, số lượng **≥ 40px**.
- Một task = một thẻ lớn, **chỉ 1 nút `Xong`**.
- Cũ nhất lên đầu.
- **Màu theo thời gian chờ:** trắng < 3 phút → vàng 3–7 → đỏ > 7 phút.
  Đây là thứ giúp không bỏ sót bàn.

## Tiêu chuẩn chất lượng phải dựng cùng lúc — [02-luat.md](02-luat.md)

| Việc | Trạng thái |
|---|---|
| `tsconfig.json` strict | ⬜ |
| `eslint.config.mjs` | ⬜ |
| **Type sinh từ OpenAPI, không gõ tay** | ⬜ — mà backend cũng **chưa có OpenAPI spec** |
| 3 luồng E2E (không nhiều hơn) | ⬜ |
| Test trên 3 cấu hình thiết bị thật của quán | ⬜ |
| Chống bấm đúp (quán mạng chậm, khách bấm 2 lần) | ⬜ |
| Giỏ hàng Zustand + localStorage | ⬜ |

## Đề xuất

**Đừng dựng cả 4 nhóm route song song.** Làm `(shop)/menu` + `menu/[slug]` trước —
nó chạy được ngay với backend hiện tại, và nó là nơi kiểm chứng phần khó nhất của UI
(2 hàng nút, ẩn "Lượng nhân" khi chọn Chay, giá cập nhật realtime qua `/orders/quote`).
Làm đúng chỗ đó thì các trang còn lại chỉ là lặp lại khuôn.

**Việc kỹ thuật cần làm trước tiên**, theo thứ tự:
1. `cd fe && npx create-next-app@latest . --typescript --tailwind --app --src-dir --eslint`
2. Thêm service `fe` vào [docker-compose.yml](../../deploy/docker-compose.yml) — hiện đang thiếu.
3. Viết API client + hàm format tiền VN dùng chung, trước khi viết trang đầu tiên.

> Ghi chú: trong máy có sẵn một project tham khảo tại
> `~/Desktop/code/claude restaurant/fe/src/app/(shop)/menu/product` — cấu trúc route
> giống hệt §4.2, có thể tham khảo nhưng **không copy giá/logic**: công thức giá của quán
> này nằm ở backend và chỉ ở backend.
