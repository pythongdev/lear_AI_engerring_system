# 01 — Thiết kế Backend (Go + Gin)

> Cập nhật **2026-08-19** · Lane sở hữu: **BE** · Dời từ `step.md` Bước 3 (mục 3.1–3.8, xem `git log`).
> Sự thật BE khác: [luật](02-luat.md) · [hiện trạng](03-hien-trang.md) · [yêu cầu khi làm việc](04-yeu-cau.md).

**File này giữ *ý định thiết kế*, không giữ code đang chạy.** Code thật ở [code/be/](../../code/be/) —
mô tả dưới đây có chỗ đi trước code (rõ nhất: module `order` mới có `Quote`, chưa có `POST /orders`).
**Lệch ⇒ code trong `code/be/` thắng** ([CLAUDE.md §2](../../CLAUDE.md)): mở finding, đừng sửa code cho khớp chữ ở đây.

Đọc code thật:

```bash
ls code/be/internal/                              # các module đang có thật
grep -rn 'func ' code/be/internal/menu/pricing.go # hàm tính giá đang chạy
grep -rn 'r\.\(GET\|POST\|PATCH\|PUT\)' code/be/  # route đã đăng ký thật
```

---

### 3.0 Cấu trúc thư mục — chia theo **module**, không theo **tầng**

Chốt 2026-08-18 (owner). **Bằng chứng ngoài repo + 4 phương án đã cân nhắc rồi loại:
[nghien-cuu-cau-truc.md](nghien-cuu-cau-truc.md)** — mục này chỉ giữ luật, không giữ lý lẽ. Trước đó `code/be/internal/` chia theo tầng kỹ thuật
(`handler/`, `store/`, và sắp có `service/`); nay chia theo **module nghiệp vụ**.
Lý do là chi phí của mỗi cách khi thêm domain thứ n:

| | Chia theo tầng | Chia theo module (chốt) |
|---|---|---|
| Thêm 1 domain | sửa 3 package, mỗi package phình thêm | thêm 1 thư mục, không ai phải đụng |
| Biên giới | không có — mọi handler thấy mọi store | Go tự cưỡng chế (kiểu không xuất khẩu) |
| Thêm computer vision (§3.9) | `store/` phải biết cả đơn hàng lẫn suy luận ảnh | `vision/` là một thư mục nữa, cùng khuôn |

```
code/be/
├── cmd/
│   ├── server/main.go        composition root — nơi DUY NHẤT biết đủ mọi module
│   └── worker/main.go        (chưa có) tiến trình nền: job CV, Telegram, cron
├── internal/
│   ├── platform/             hạ tầng, KHÔNG chứa nghiệp vụ
│   │   ├── config/           đọc env, validate, ép múi giờ VN
│   │   ├── db/               mở MySQL + retry
│   │   ├── httpx/            cách trả lỗi HTTP dùng chung
│   │   └── testdb/           mở DB cho test tích hợp của mọi module
│   ├── menu/                 món, danh mục, tuỳ chọn, CÔNG THỨC GIÁ
│   ├── order/                báo giá, đặt đơn, nổ combo thành order_tasks
│   ├── shop/                 thông tin quán, giờ mở, phí ship
│   ├── table/                (chưa có) bàn, phiên bàn, QR
│   ├── staff/                (chưa có) đăng nhập, phân quyền, trạm
│   ├── report/               (chưa có) doanh thu, món bán chạy
│   └── vision/               (chưa có) job computer vision — xem §3.9
├── test/integration/         test ràng buộc schema, không thuộc module nào
├── api/openapi.yaml          (chưa có, `T-13`)
└── migrations/               lane DB, không phải lane BE
```

**Mỗi module có đúng bốn loại file** (chỉ tạo file khi có nội dung thật, đừng tạo cho đủ bộ):

| File | Chứa gì | Xuất khẩu? |
|---|---|---|
| `<module>.go` | kiểu dữ liệu của domain + hằng số | có |
| `store.go` | SQL của **riêng** module này | **không** — `type store struct` viết thường |
| `service.go` | nghiệp vụ, transaction; mặt tiền công khai `type Service` | có |
| `http.go` | `type API` + `Register(*gin.RouterGroup)` | có |
| `port.go` | interface về thứ module này **cần** từ module khác | có |

**Năm luật, mỗi luật có một lệnh đứng sau:**

1. **`store` của module nào cũng không xuất khẩu.** Đây là luật duy nhất có *compiler* cưỡng chế:
   module khác không thể viết SQL vào bảng của module này kể cả khi muốn. Muốn dữ liệu ⇒ gọi `Service`.
2. **Đồ thị import giữa module không được có chu trình.** Cạnh một chiều thì được phép và bình thường —
   `order → menu` tồn tại vì món ăn là ngôn ngữ chung của đơn hàng, giả vờ không biết chỉ đẻ ra một tầng dịch vô ích.
3. **Cần chiều ngược lại ⇒ khai `port.go`, đừng import.** Module bên dưới khai interface về *thứ nó cần*
   (mẫu: `order.Shop` chỉ có `ShippingFee` + `IsOpenNow`, không phải cả `shop.Settings`), `main.go` nối hai đầu.
   Phần thưởng đi kèm: test của `order` chạy được mà không cần database.
4. **`internal/platform/**` không được import module nghiệp vụ nào.** Hạ tầng biết nghiệp vụ là lúc nó
   thôi làm hạ tầng.
5. **Wiring chỉ ở `cmd/*/main.go`.** Không module nào tự dựng dependency của mình từ env hay biến toàn cục.

```bash
# 1 + 4 + 5 — cả ba phải RỖNG
grep -rn 'type Store struct\|func NewStore' code/be/internal/                       # luật 1
cd code/be && go list -deps ./internal/platform/... | grep 'banhcuon/internal/' | grep -v '/platform/'   # luật 4
grep -rn 'sql.Open\|os.Getenv' code/be/internal/                                     # luật 5

# 2 + 3 — in ra đồ thị module; mỗi cạnh phải giải thích được, và không được có chu trình
cd code/be && go list -f '{{$p := .ImportPath}}{{range .Imports}}{{$p}} {{.}}
{{end}}' ./internal/... | grep -E '^banhcuon/internal/\S+ banhcuon/internal/\S+$' \
 | sed -E 's#banhcuon/internal/##g' \
 | awk '{split($1,a,"/"); split($2,b,"/"); if (a[1]!=b[1]) print a[1]" -> "b[1]}' | sort -u
```

**Cái KHÔNG làm**, vì mỗi cái đều là một bẫy đã có người trả giá:

- **Không có `pkg/`.** Go team không khuyến nghị nó; stdlib bỏ từ Go 1.4. `internal/` là biên giới
  *duy nhất* mà toolchain thật sự cưỡng chế.
- **Không tạo module trước khi có domain thật.** `vision/`, `table/`, `staff/` ở cây trên là *chỗ trống
  đã đặt tên*, không phải thư mục rỗng phải tạo ngay.
- **Không tạo interface khi mới có một implementation.** `port.go` chỉ ra đời khi có hai module thật cần nối.
- **Không gọi HTTP/gRPC giữa hai package trong cùng binary.** Trong monolith thì đó là lời gọi hàm.

### 3.1 Khởi tạo

```bash
cd code/be
go mod init banhcuon
go get github.com/gin-gonic/gin github.com/go-sql-driver/mysql \
       github.com/golang-jwt/jwt/v5 golang.org/x/crypto/bcrypt \
       github.com/gin-contrib/cors github.com/joho/godotenv \
       github.com/gorilla/websocket github.com/skip2/go-qrcode
```

### 3.2 Danh sách API

**Public — khách hàng (không cần đăng nhập):**

| Method | Path | Mô tả |
|--------|------|-------|
| GET | `/api/v1/settings` | Tên quán, giờ mở, đang nhận đơn hay không |
| GET | `/api/v1/categories` | Danh mục |
| GET | `/api/v1/products` | Menu đầy đủ kèm option group + option |
| GET | `/api/v1/products/:slug` | Chi tiết 1 món |
| POST | `/api/v1/orders/quote` | **Tính thử giá** trước khi đặt (FE gọi mỗi lần đổi option) |
| POST | `/api/v1/orders` | Đặt đơn ship/pickup |
| GET | `/api/v1/orders/:code?phone=` | Tra cứu đơn |

**QR tại bàn (xác thực bằng `qr_token` trong URL):**

| Method | Path | Mô tả |
|--------|------|-------|
| GET | `/api/v1/t/:token` | Thông tin bàn + phiên đang mở + món đã gọi |
| POST | `/api/v1/t/:token/orders` | Khách gọi món tại bàn → đơn `pending`, chờ quầy duyệt |
| GET | `/api/v1/t/:token/bill` | Xem tạm tính của bàn |

**Nhân viên (JWT, phân quyền theo `role`):**

| Method | Path | Quyền |
|--------|------|-------|
| POST | `/api/v1/staff/login` | tất cả (username+password hoặc PIN) |
| GET | `/api/v1/staff/me` | tất cả |
| GET | `/api/v1/staff/tasks?station=` | trạm tương ứng |
| PATCH | `/api/v1/staff/tasks/:id` | trạm tương ứng — `todo → doing → done` |
| GET | `/api/v1/staff/tables` | quầy, dọn bàn |
| POST | `/api/v1/staff/sessions` | quầy — mở phiên bàn |
| POST | `/api/v1/staff/sessions/:id/orders` | quầy — **đặt hộ khách** |
| PATCH | `/api/v1/staff/orders/:id/confirm` | quầy — duyệt đơn QR, đẩy xuống bếp |
| PATCH | `/api/v1/staff/orders/:id/cancel` | quầy |
| POST | `/api/v1/staff/sessions/:id/checkout` | quầy — thu tiền, đóng phiên |
| PATCH | `/api/v1/staff/tables/:id/cleaned` | dọn bàn — đặt lại bàn về `free` |
| GET | `/api/v1/staff/stream` | tất cả — SSE/WebSocket đẩy việc mới |

**Chủ quán (`role = owner`):**

| Method | Path |
|--------|------|
| CRUD | `/api/v1/admin/products`, `/categories`, `/options` |
| PATCH | `/api/v1/admin/products/:id/availability` — tắt món hết hàng |
| CRUD | `/api/v1/admin/staff`, `/tables` |
| GET | `/api/v1/admin/tables/:id/qr.png` — tải QR để in |
| PUT | `/api/v1/admin/settings` — **trang điền thông tin quán** |
| GET | `/api/v1/admin/reports/daily?date=` — doanh thu, món bán chạy |

### 3.3 Tính giá — trái tim hệ thống

Toàn bộ logic giá nằm ở **một hàm duy nhất** trong `menu/pricing.go`, dùng chung cho cả `quote` và `create order`. Nếu tách làm hai chỗ, giá hiển thị và giá thu tiền sẽ lệch nhau.

```
CalcItemPrice(productID, optionIDs[], quantity) → (unitPrice, breakdown, error)

  1. Nạp product từ DB   → nếu is_available = FALSE, trả lỗi "món đã hết"
  2. Nạp toàn bộ option group của product
  3. Với mỗi group, lọc ra các option được chọn thuộc group đó:
       - Số lượng chọn phải nằm trong [min_select, max_select]
       - Option phải is_available = TRUE
       - Nếu group có depends_on_option_id mà option đó KHÔNG được chọn
         → group này không áp dụng, và nếu khách vẫn gửi option của nó → LỖI
  4. unitPrice = product.base_price + Σ option.price_delta
  5. lineTotal = unitPrice × quantity
```

**Luật riêng của quán — "Lượng nhân" chỉ áp dụng khi có nhân:**

Cột `depends_on_option_id` chỉ trỏ được tới **một** option, nhưng "Lượng nhân" phải hiện với **cả** `Thịt` lẫn `Thịt + mộc nhĩ`. Xử lý bằng luật trong module `menu`:

```go
// Nhóm 'luong_nhan' chỉ áp dụng khi option nhóm 'nhan' KHÁC 'chay'.
func isGroupApplicable(g OptionGroup, selected map[string]string) bool {
    if g.Code == "luong_nhan" {
        return selected["nhan"] != "chay"
    }
    return g.DependsOnOptionID == nil || selectedIDs.Has(*g.DependsOnOptionID)
}
```

Chọn `Chay` + `Nhiều nhân` phải bị **từ chối**, không phải âm thầm bỏ qua — nếu bỏ qua thì bếp sẽ nhận phiếu mâu thuẫn.

**Bảng test bắt buộc viết** cho `pricing_test.go`:

| Món | Nhân | Lượng | Giá kỳ vọng |
|-----|------|-------|-------------|
| Bánh cuốn | Chay | — | 3.000 |
| Bánh cuốn | Thịt | Thường | 4.000 |
| Bánh cuốn | Thịt | Nhiều | 5.000 |
| Bánh cuốn | Thịt+mộc nhĩ | Nhiều | 5.000 |
| Trứng chín | Chay | — | 8.000 |
| Trứng tái | Thịt+mộc nhĩ | Thường | 9.000 |
| Trứng vàng | Thịt | Nhiều | 10.000 |
| Giò | — | — | 9.000 |
| Đầy đủ chín | Thịt | Thường | 30.000 |
| Đầy đủ tái | Thịt+mộc nhĩ | Nhiều | 34.000 |
| Bánh cuốn | Chay | Nhiều | **LỖI** |

### 3.4 Luồng đặt món — `order/service.go`

```
1. Kiểm tra quán có nhận đơn không:
     store_settings.is_accepting_orders == TRUE
     AND NOW() nằm trong [open_time, close_time]  (giờ Asia/Ho_Chi_Minh)
   → sai thì trả 503 kèm giờ mở cửa
2. Xác định kênh:
     - qr_table : tra bàn theo qr_token → lấy/mở table_session
     - staff_pos: kiểm tra JWT có role 'quay' hoặc 'owner' → session_id từ body
     - web      : validate tên + SĐT (^0[35789]\d{8}$) + địa chỉ (nếu delivery)
                  hoặc pickup_at nằm trong 06:00–11:00
3. MỞ TRANSACTION
4. Với mỗi item → gọi CalcItemPrice() (KHÔNG tin giá do FE gửi)
5. subtotal = Σ line_total
6. shipping_fee = 0 nếu dine_in hoặc pickup;
                  ngược lại default_ship_fee (hiện = 0, quán đang miễn phí ship)
   → vẫn giữ cột này để sau này chủ quán bật phí ship ở Admin mà không phải sửa code
7. total = subtotal + shipping_fee - discount
8. Sinh code đơn: 'BC' + YYMMDD + số thứ tự trong ngày
9. INSERT orders → order_items → order_item_options (kèm SNAPSHOT)
10. Nếu dine_in: cập nhật lại table_sessions.subtotal/total (SELECT ... FOR UPDATE)
11. Sinh order_tasks:
      - Với item thường : theo product_stations của product
      - Với item combo  : NỔ theo product_components rồi mới theo product_stations
                          (khách gọi 1 "Đầy đủ chín" → bếp thấy 3 bánh cuốn,
                           1 trứng chín, 1 giò — chứ không phải 1 dòng mơ hồ)
      - Task 'canh' : 1 task cấp đơn cho mọi đơn dine_in
    Đơn kênh 'qr_table' → tasks tạo ở trạng thái CHỜ, chỉ hiện ở bếp
    sau khi quầy bấm confirm.
12. COMMIT
13. Ngoài transaction: đẩy sự kiện realtime xuống màn hình trạm
    + gửi Telegram (chỉ với đơn web). Lỗi ở đây chỉ log, KHÔNG làm hỏng đơn.
```

### 3.5 Nổ combo thành việc cho bếp

Đây là điểm dễ làm sai nhất. Khách gọi **2 suất "Đầy đủ trứng tái", thịt + mộc nhĩ, nhiều nhân**:

```
order_items:  [Đầy đủ trứng tái ×2 — Thịt+mộc nhĩ, Nhiều nhân — 34.000 × 2 = 68.000]

order_tasks sinh ra:
  trang_banh  │ Bánh cuốn ×6  — thịt+mộc nhĩ, nhiều nhân
  trang_banh  │ Trứng tái ×2  — thịt+mộc nhĩ, nhiều nhân
  gap_banh    │ Bánh cuốn ×6  — thịt+mộc nhĩ, nhiều nhân
  gap_banh    │ Trứng tái ×2
  gap_banh    │ Giò ×2
  canh        │ Nước chấm — bàn 5, 2 suất
```

Số lượng = `combo_quantity × component_quantity`. Thành phần có `inherits_options = FALSE` (giò) **không** kèm mô tả nhân.

### 3.6 Sinh QR cho bàn

```go
// GET /api/v1/admin/tables/:id/qr.png
url := fmt.Sprintf("%s/t/%s", cfg.PublicSiteURL, table.QRToken)
png, _ := qrcode.Encode(url, qrcode.Medium, 512)
c.Data(200, "image/png", png)
```

Quy tắc:
- `qr_token` phải **random 32 ký tự**, không phải số bàn. Nếu dùng `/t/5` thì ai cũng đoán được URL của mọi bàn.
- In QR ra giấy, ép plastic, dán/để trên bàn.
- Có lệnh CLI đổi token khi QR bị chụp lại phát tán: `./server rotate-qr --table 5`.

### 3.7 Realtime cho màn hình trạm

Dùng **SSE** (`text/event-stream`), không cần WebSocket — luồng dữ liệu chỉ đi một chiều từ server xuống trạm.

```
GET /api/v1/staff/stream?station=trang_banh
  → event: task.created  { id, label, quantity, order_code, table_name }
  → event: task.updated  { id, status }
  → event: task.cancelled{ id }
```

Frontend dùng `@microsoft/fetch-event-source` (đã có sẵn trong project trước của bạn) để gửi kèm header `Authorization`.

**Dự phòng:** màn hình trạm vẫn phải `refetch` mỗi 20 giây. Wifi quán ăn hay rớt, và một cái tablet đứng hình nghĩa là khách ngồi chờ món không bao giờ tới.

### 3.8 Middleware bắt buộc

- **CORS** — chỉ cho đúng domain FE, không dùng `*` ở production.
- **Auth JWT** — cho `/staff/*` và `/admin/*`, kiểm tra cả `role`.
- **Rate limit** — `POST /t/:token/orders` giới hạn theo token bàn (vd 5 đơn / 5 phút / bàn) để chống spam.
- **Recovery + Logger** JSON kèm `request_id`.

### 3.9 Computer vision — **server riêng, viết bằng Python**

Chốt 2026-08-18 (owner): CV **không** chạy trong binary Go. Bốn phương án đã cân nhắc và lý do loại
ba cái còn lại: [nghien-cuu-cau-truc.md §6](nghien-cuu-cau-truc.md). Nó là một tiến trình riêng, ngôn ngữ
Python, và monolith nói chuyện với nó qua **một interface duy nhất**.

**Vì sao không nhúng thẳng vào Go.** `gocv` là binding cgo của OpenCV, và cái giá là thật:
`import "C"` giết cross-compile và bắt mọi máy build phải có C toolchain + cờ `CGO_CFLAGS`/`CGO_LDFLAGS`;
image Docker phồng lên cỡ GB vì không tách được OpenCV contrib khỏi phần còn lại; và một crash ở tầng C
**giết cả tiến trình** — nghĩa là màn hình bếp và luồng đặt đơn chết theo con detector. Đổi lại chẳng
được gì, vì hệ sinh thái model vẫn nằm ở Python.

**Ranh giới.** Monolith giữ **trạng thái + nghiệp vụ**; server CV **không giữ sự thật nào** —
nó nhận ảnh, trả kết quả, và có thể bị xoá đi dựng lại bất cứ lúc nào mà không mất dữ liệu.
Đó là thứ phân biệt *"monolith có worker"* với *microservices*: không phải số container, mà là
**số nơi giữ sự thật**.

```
code/be/internal/vision/              module trong monolith — job, kết quả, chính sách nghiệp vụ
  vision.go     Job, Result, Detection
  service.go    tạo job, nhận kết quả, phát sự kiện xuống SSE (§3.7)
  store.go      bảng job + kết quả (kiểu store KHÔNG xuất khẩu, như mọi module)
  http.go       POST /api/v1/vision/jobs · GET /api/v1/vision/jobs/:id
  port.go       type Inferencer interface { Infer(ctx, ImageRef) (Result, error) }

code/be/internal/platform/inference/  adapter — thứ DUY NHẤT biết server CV tồn tại
  client.go     gọi cv-service qua HTTP/gRPC
  fake.go       adapter giả: test chạy được mà không cần model, không cần GPU

code/be/cmd/worker/main.go            tiến trình nền: lấy job pending → Infer → ghi kết quả

cv/                              THƯ MỤC RIÊNG, Python, Dockerfile riêng, không nằm trong go.mod
  server.py, models/*.onnx, requirements.txt
```

**Luật cứng: `code/be/` không bao giờ import thư viện computer vision nào.** Module `vision` chỉ biết
`Inferencer`. Sau này muốn đổi từ Python service sang chạy thẳng trong Go = thay **một adapter**,
không chạm dòng nghiệp vụ nào. Kiểm: `grep -rn 'gocv\|opencv\|onnxruntime' code/be/` phải rỗng.

**Bốn quyết định đi kèm:**

| Quyết định | Vì sao |
|---|---|
| **Job bất đồng bộ, không request đồng bộ** | Suy luận mất giây đến chục giây, vượt timeout của gateway. API nhận ảnh → trả `job_id` ngay → FE nghe kênh SSE đã có ở §3.7 |
| **Ghi job trong **cùng transaction** với nghiệp vụ** (outbox) | Ảnh đã nhận mà job mất, hoặc job có mà nghiệp vụ rollback — cả hai đều hỏng im lặng. Bảng job + worker poll là bản outbox rẻ nhất; chưa cần Kafka/RabbitMQ ở quy mô một quán |
| **Ảnh KHÔNG nằm trong DB** | Object storage hoặc thư mục + volume giữ file; DB chỉ giữ đường dẫn + hash + metadata |
| **Model xuất ra ONNX** | Train ở Python, chạy ở đâu cũng được — không khoá vào một runtime, và giữ mở đường "sau này chạy thẳng trong Go" |

**Việc phải mở trước khi viết dòng code CV nào** (mỗi việc một lane, [CLAUDE.md §8](../../CLAUDE.md)):
bảng `vision_jobs` + `vision_results` là **lane DB** ([design/data_base/](../data_base/01-thiet-ke.md)) —
file này không được đặt tên cột; container `cv-service` + volume ảnh là **lane DEVOPS**
([deploy/](../../deploy/AGENTS.md)); `internal/vision/` + `cmd/worker/` là lane BE.
