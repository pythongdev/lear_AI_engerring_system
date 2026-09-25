# 03 — Hiện trạng Backend (Go + Gin)

> Cập nhật **2026-08-19** · Lane sở hữu: **BE** · Dời từ `status/02-backend.md` (`git log --follow`).
> Nguồn sự thật: [code/be/](../../code/be/) — **code thắng file này khi lệch** ([CLAUDE.md §2](../../CLAUDE.md)).
> Sự thật BE khác: [thiết kế](01-thiet-ke.md) · [luật](02-luat.md) · [yêu cầu khi làm việc](04-yeu-cau.md).
> **Không ghi số ở đây** — phiên bản stack, số file, số hàm test đều derive được: `code/be/go.mod` là nhà,
> `make status` mục *BACKEND* in ra khi cần (§10, [F-40](../../finding.md#f-40) đã trả giá đúng chỗ này).

**Tóm tắt: ~20%.** Phần *khó nhất về nghiệp vụ* (công thức giá) đã xong và có test dày.
Phần *nhiều việc nhất* (đặt đơn, POS, auth, admin) chưa bắt đầu.

## Đã có

### Cấu trúc — file nào làm gì

Số file / số dòng đếm bằng lệnh, không chép vào đây ([F-13](../../finding.md#f-13)):
`make status` mục *BACKEND*, hoặc `git ls-files 'code/be/**/*.go' | xargs wc -l`.

```
code/be/
├── cmd/server/main.go              composition root: CORS, /healthz, wiring, graceful shutdown
├── internal/
│   ├── platform/config/config.go   đọc env, validate, ép múi giờ VN
│   ├── platform/db/db.go           mở MySQL + retry 15×2s
│   ├── platform/httpx/httpx.go     cách trả lỗi HTTP dùng chung
│   ├── platform/testdb/testdb.go   mở DB cho test tích hợp (tự skip khi thiếu TEST_DB_DSN)
│   ├── menu/{menu,pricing,store,service,http}.go   ★ CalcItemPrice + PriceRange
│   ├── shop/{shop,store,service,http}.go           thông tin quán, giờ mở, phí ship
│   └── order/{order,port,service,http}.go          mới có Quote; chưa có đặt đơn thật
└── test/integration/               test ràng buộc schema, không thuộc module nào
```

**Chia theo module từ 2026-08-18** ([01-thiet-ke.md §3.0](01-thiet-ke.md)) — trước đó là
`handler/` + `store/` toàn cục. `store` của cả ba module đều là kiểu **không xuất khẩu**, nên
biên giới có compiler đứng sau chứ không chỉ có lời hứa. Đồ thị module hiện tại (lệnh in ra nó ở §3.0):

```
menu -> platform      order -> menu      order -> platform      shop -> platform
```

`order -> menu` là cạnh nghiệp vụ **duy nhất**, một chiều. `order` không import `shop`: thứ nó cần
ở đó đã thu lại thành interface `order.Shop` trong [port.go](../../code/be/internal/order/port.go).

### Endpoint đang chạy — mỗi module tự đăng ký route của nó (`Register`)

Danh sách đăng ký thật: `make status` mục *BACKEND* (`endpoint đang đăng ký`). Bảng dưới giữ
**lý do** của từng cái, thứ lệnh không in ra được.

| Method | Path | Ghi chú |
|---|---|---|
| GET | `/healthz` | ping DB, trả `503 db_down` nếu MySQL chết |
| GET | `/api/v1/settings` | **cố ý không trả thông tin ngân hàng** ở endpoint công khai |
| GET | `/api/v1/categories` | kèm `product_count` |
| GET | `/api/v1/products` | lọc `?category=` và `?featured=1`, kèm `price_min`/`price_max` |
| GET | `/api/v1/products/:slug` | 404 tiếng Việt khi không thấy |
| POST | `/api/v1/orders/quote` | tính thử giá, dùng **chung** `CalcItemPrice` với lúc đặt thật |

### `CalcItemPrice` — trái tim hệ thống, đã hoàn chỉnh

[pricing.go:60](../../code/be/internal/menu/pricing.go#L60). Công thức `unit = base_price + Σ price_delta`.
Đã xử lý đúng các ca khó:

- **Nhóm "Lượng nhân" chỉ áp dụng khi nhân ≠ Chay** ([groupApplicable:171](../../code/be/internal/menu/pricing.go#L171)).
  Chọn "chay + nhiều nhân" bị **từ chối thẳng**, không âm thầm bỏ qua — đúng, vì bỏ qua
  sẽ đẩy phiếu mâu thuẫn xuống bếp.
- Option trùng lặp không cộng hai lần; option không thuộc món → 400.
- `min_select`/`max_select` kiểm ở cả hai chiều; `MaxQuantity = 99` chặn đơn ảo.
- Món/option hết hàng → lỗi nghiệp vụ có `code` máy đọc được + `Msg` tiếng Việt cho người dùng.
- Sinh sẵn `Label` cho phiếu bếp: `"Bánh cuốn × 3 — Thịt + mộc nhĩ, Nhiều nhân"`.
- `PriceRange` tính khoảng giá cho thẻ menu, **tính riêng theo từng nhân** để không ra
  mức giá không tồn tại trên thực đơn.

### Test + lint — đã chạy, pass

```
make check   → build → vet → lint → test, EXIT=0
```

Lint đã bật từ 2026-08-11 ([T-03](../../task.md), đóng [F-24](../../finding.md#f-24)):
[code/be/.golangci.yml](../../code/be/.golangci.yml) schema v2, `0 issues.`
Đếm test bằng lệnh, đừng chép số vào đây ([F-13](../../finding.md#f-13)):
`make status` mục *BACKEND* (`hàm test`), hoặc `cd code/be && go test ./... -v 2>&1 | grep -c '^=== RUN'`.

- [pricing_test.go](../../code/be/internal/menu/pricing_test.go) — phần lớn số case nằm ở đây,
  gồm `TestBangGiaChinhThuc` đối chiếu **bảng giá thật của quán**.
- Test tích hợp trong [menu/store_integration_test.go](../../code/be/internal/menu/store_integration_test.go):
  `TestBangGiaTuDatabase` đọc giá thẳng từ MySQL → bắt được cả lỗi ở tầng seed/nạp dữ liệu.
  Tự skip khi không có `TEST_DB_DSN`, nên `go test ./...` vẫn chạy offline.

### Chi tiết làm tốt, đáng giữ

- [platform/db](../../code/be/internal/platform/db/db.go) retry 15 lần × 2s — chịu được việc backend khởi động trước MySQL trong compose.
- Graceful shutdown 15s: đơn đang xử lý chạy xong mới thoát.
- [platform/config/config.go:50-58](../../code/be/internal/platform/config/config.go#L50-L58): ở `production` **bắt buộc**
  `JWT_SECRET ≥ 32 ký tự` và **cấm `CORS_ORIGINS = "*"`** — fail fast lúc khởi động.
- `time.Local = cfg.Location` set ngay đầu `run()`, mọi so sánh giờ chạy ở giờ VN.

## Chưa có

### API — còn thiếu phần lớn danh sách đã thiết kế ([01-thiet-ke.md §3.2](01-thiet-ke.md))

| Nhóm | Endpoint còn thiếu |
|---|---|
| **Khách** | `POST /orders` (đặt ship/pickup), `GET /orders/:code?phone=` |
| **QR bàn** | `GET /t/:token`, `POST /t/:token/orders`, `GET /t/:token/bill` |
| **Nhân viên** | `POST /staff/login`, `GET /staff/me`, `GET|PATCH /staff/tasks`, `GET /staff/tables`, `POST /staff/sessions`, `POST /staff/sessions/:id/orders`, `PATCH /staff/orders/:id/confirm|cancel`, `POST /staff/sessions/:id/checkout`, `PATCH /staff/tables/:id/cleaned`, `GET /staff/stream` (SSE) |
| **Chủ quán** | CRUD `products`/`categories`/`options`/`staff`/`tables`, `PATCH .../availability`, `GET /admin/tables/:id/qr.png`, `PUT /admin/settings`, `GET /admin/reports/daily` |

### Tầng và cơ chế còn thiếu

| Thiếu | Vì sao quan trọng |
|---|---|
| **`order.Service` mới có `Quote`** | Đặt đơn thật cần transaction nhiều bảng; khung module đã có, phần transaction chưa |
| **`internal/table/`, `internal/staff/`, `internal/report/`** — chưa tồn tại | Ba module còn thiếu của khuôn ở [§3.0](01-thiet-ke.md); QR bàn, đăng nhập, báo cáo đều đang nằm ở đó |
| **`internal/vision/` + `cmd/worker/`** — chưa tồn tại | Computer vision đã chốt thiết kế ở [§3.9](01-thiet-ke.md), chưa có dòng code nào |
| **Nổ combo thành `order_tasks`** ([01-thiet-ke.md §3.5](01-thiet-ke.md)) | Không có nó thì bếp không nhận được việc — combo "đầy đủ" phải tách thành việc cho 3 trạm |
| **Ghi snapshot vào `order_items`** | Cột DB đã có, code ghi chưa có. Đây là quy tắc #2 trong [README](../../README.md#quy-tắc-không-được-phá) |
| **Auth JWT + middleware phân quyền theo `role`** | `JWTSecret` đã đọc vào config nhưng **chưa có code nào dùng** |
| **Sinh `qr_token` cho bàn** | `QRSecret` cũng đã đọc vào config, chưa dùng |
| **SSE/WebSocket đẩy việc mới** | Màn hình trạm sẽ phải polling nếu không có |
| **Rate limit + `request_id` trong log** | [02-luat.md](02-luat.md) yêu cầu; logger hiện là plaintext, chưa có `request_id` |
| **Gửi Telegram khi có đơn ship** | `TELEGRAM_BOT_TOKEN` đã có trong config, chưa có code gửi |
| **Test đồng thời (concurrency)** | Ràng buộc "1 phiên mở/bàn" đã có ở DB — cần test 2 goroutine cùng mở phiên để chứng minh nó chặn thật |
| **OpenAPI spec** | [design/frontend/02-luat.md](../frontend/02-luat.md) muốn sinh type FE từ đây |

## Việc tiếp theo

Thứ tự này chọn theo *mảnh nào mở khoá nhiều thứ nhất*:

1. **`internal/order/service.go` + `POST /api/v1/orders`**
   Trong một transaction: đọc product từ DB → `CalcItemPrice` → ghi `orders` +
   `order_items` + `order_item_options` (snapshot) → nổ `order_tasks` theo
   `product_stations` + `product_components` → ghi `order_status_history`.
   Xong bước này thì QR bàn, POS và màn hình bếp đều dùng lại được cùng một service.
2. **Auth nhân viên** (`POST /staff/login`, middleware role) — chặn cửa trước khi mở POS.
3. **Luồng QR bàn** — dùng lại service ở bước 1, thêm luật *đơn QR phải được quầy duyệt*.
4. **SSE** — sau cùng, khi đã có việc thật để đẩy.

**Không nên làm trước:** admin CRUD và báo cáo. Chúng nhiều việc nhưng không chặn ai cả —
chủ quán vẫn sửa được menu bằng SQL trong lúc chờ.
