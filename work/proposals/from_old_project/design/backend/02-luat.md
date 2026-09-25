# 02 — Luật Backend (Go + Gin + sqlc)

> Cập nhật **2026-08-19** · Lane sở hữu: **BE** · Dời từ `quality/02-backend.md` (`git log --follow`).
> Sự thật BE khác: [thiết kế](01-thiet-ke.md) · [hiện trạng](03-hien-trang.md) · [yêu cầu khi làm việc](04-yeu-cau.md).
> Ngoài thư mục này: [design/data_base/02-luat.md](../data_base/02-luat.md) · [quality/04-devops.md](../../quality/04-devops.md)

BE là nơi giữ tiền. Frontend có thể bị sửa, DB có thể bị query sai, nhưng **giá luôn phải tính lại ở BE từ dữ liệu trong DB**.

---

## 1. Lint — bắt lỗi trước khi chạy

Tạo `code/be/.golangci.yml`:

```yaml
run:
  timeout: 3m

linters:
  enable:
    - errcheck        # bỏ quên err — nguồn bug số 1 trong Go
    - govet
    - staticcheck
    - ineffassign
    - unused
    - gosec           # SQL injection, hardcoded credential
    - sqlclosecheck   # rows chưa Close → cạn connection pool
    - rowserrcheck    # bỏ quên rows.Err()
    - bodyclose       # HTTP response body chưa đóng
    - contextcheck    # context không truyền xuống

linters-settings:
  errcheck:
    check-type-assertions: true
    check-blank: true

issues:
  exclude-rules:
    - path: _test\.go
      linters: [gosec, errcheck]
```

Chạy:

```bash
cd code/be && golangci-lint run
```

`errcheck` một mình sẽ bắt hết chỗ bỏ quên `err` — trong hệ thống có transaction, một `err` bị bỏ quên nghĩa là commit một transaction đã hỏng.

---

## 2. Ba tầng test — không cần nhiều hơn

```
┌──────────────────────────────────────────────┐
│ Tầng 3 — API smoke (httptest)                │  ~10 test, nhanh
│   5 endpoint chính, assert status + shape    │
├──────────────────────────────────────────────┤
│ Tầng 2 — Integration (MySQL thật)            │  ~15 test, chậm
│   transaction, phiên bàn, nổ combo, đồng thời│
├──────────────────────────────────────────────┤
│ Tầng 1 — Unit (pricing_test.go)              │  ~20 test, rất nhanh
│   TRÁI TIM — sai là mất tiền thật            │
└──────────────────────────────────────────────┘
```

### Tầng 1 — Tính giá (`service/pricing_test.go`)

Đây là test quan trọng nhất trong toàn dự án. Bảng 11 case ở [01-thiet-ke.md §3.3](01-thiet-ke.md) viết thành table-driven test:

```go
func TestCalcItemPrice(t *testing.T) {
	cases := []struct {
		name      string
		product   string
		options   []string
		quantity  int
		wantPrice int64
		wantErr   bool
	}{
		{"bánh cuốn chay", "banh-cuon", []string{"chay"}, 1, 3000, false},
		{"bánh cuốn thịt thường", "banh-cuon", []string{"thit", "thuong"}, 1, 4000, false},
		{"bánh cuốn thịt nhiều", "banh-cuon", []string{"thit", "nhieu"}, 1, 5000, false},
		{"bánh cuốn thịt+mộc nhĩ nhiều", "banh-cuon", []string{"thit-moc-nhi", "nhieu"}, 1, 5000, false},
		{"trứng chín chay", "trung-chin", []string{"chay"}, 1, 8000, false},
		{"trứng tái thịt+mộc nhĩ thường", "trung-tai", []string{"thit-moc-nhi", "thuong"}, 1, 9000, false},
		{"trứng vàng thịt nhiều", "trung-vang", []string{"thit", "nhieu"}, 1, 10000, false},
		{"giò", "gio", nil, 1, 9000, false},
		{"đầy đủ chín thịt thường", "day-du-chin", []string{"thit", "thuong"}, 1, 30000, false},
		{"đầy đủ tái thịt+mộc nhĩ nhiều", "day-du-tai", []string{"thit-moc-nhi", "nhieu"}, 1, 34000, false},

		// case LỖI — tổ hợp không hợp lệ phải bị từ chối
		{"chay không được chọn lượng nhiều", "banh-cuon", []string{"chay", "nhieu"}, 1, 0, true},

		// biên
		{"số lượng 0", "banh-cuon", []string{"chay"}, 0, 0, true},
		{"số lượng âm", "banh-cuon", []string{"chay"}, -1, 0, true},
		{"số lượng lớn", "banh-cuon", []string{"chay"}, 3, 9000, false},
		{"món không tồn tại", "khong-co", nil, 1, 0, true},
		{"option không thuộc món", "gio", []string{"chay"}, 1, 0, true},
		{"thiếu option bắt buộc", "banh-cuon", nil, 1, 0, true},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) { /* ... */ })
	}
}
```

**Quy tắc:** mỗi lần chủ quán đổi giá → sửa bảng test trước, chạy đỏ, rồi mới sửa seed/DB. Test là nơi ghi lại "giá đúng là bao nhiêu".

### Tầng 2 — Integration với MySQL thật

sqlc sinh code từ SQL nên lỗi cú pháp query bị bắt lúc `sqlc generate`. Nhưng **logic transaction thì không** — phải test bằng DB thật.

Dùng `dockertest` (hoặc MySQL service container trong CI, xem [quality/04-devops.md](../../quality/04-devops.md)):

```go
func TestMain(m *testing.M) {
	// khởi container MySQL, chạy migrations + seed, gán testDB
	os.Exit(m.Run())
}
```

Các luồng bắt buộc test:

| # | Luồng | Assert |
|---|-------|--------|
| 1 | Mở phiên bàn → gọi món 3 lần → checkout | Tổng tiền = tổng 3 lượt, phiên `closed_at` khác NULL, bàn về `free` |
| 2 | Nổ combo thành `order_tasks` | "Đầy đủ" sinh đủ task cho trạm tráng + gấp + canh |
| 3 | Đơn QR `pending` → quầy confirm | Trước confirm: chưa có task. Sau confirm: có task |
| 4 | Quầy cancel đơn | `order_status_history` có dòng cancel, không sinh task |
| 5 | Checkout | `payments` khớp `orders.total`, số tiền bằng tổng `order_items` |
| 6 | Tăng giá món rồi xem đơn cũ | Đơn cũ giữ nguyên giá snapshot |
| 7 | Rollback khi lỗi giữa chừng | Đặt đơn lỗi ở item thứ 3 → không dòng nào được ghi |

Luồng 7 là chỗ hay bỏ sót: nếu `CreateOrder` không bọc transaction, đơn lỗi vẫn để lại `order_items` mồ côi.

### Tầng 3 — API smoke

```go
func TestAPI(t *testing.T) {
	// GET  /api/v1/products         → 200, có 8 món, mỗi món có option group
	// POST /api/v1/orders/quote     → 200, giá khớp CalcItemPrice
	// POST /api/v1/orders           → 201, trả về code
	// GET  /api/v1/orders/:code     → 200 khi đúng phone, 404 khi sai phone
	// GET  /api/v1/staff/tasks      → 401 khi không token
}
```

---

## 3. Test đồng thời — quán đông, nhiều người bấm cùng lúc

Đây là loại bug **chỉ xuất hiện ở quán thật vào giờ cao điểm**, không bao giờ thấy lúc dev. Bắt buộc test.

Luôn chạy test với `-race`:

```bash
go test ./... -race -cover
```

### a. Hai nhân viên cùng mở phiên cho một bàn

```go
func TestOpenSession_Concurrent(t *testing.T) {
	var wg sync.WaitGroup
	errs := make([]error, 10)
	for i := 0; i < 10; i++ {
		wg.Add(1)
		go func(i int) { defer wg.Done(); _, errs[i] = svc.OpenSession(ctx, tableID) }(i)
	}
	wg.Wait()

	// đúng 1 thành công, 9 lỗi
	// và DB chỉ có 1 phiên mở
}
```

Chống bằng `UNIQUE(open_key)` ở DB (xem [design/data_base/02-luat.md](../data_base/02-luat.md)) — BE bắt lỗi duplicate key và trả về phiên đang mở, không tạo mới.

### b. Hai trạm cùng cập nhật một task

`PATCH /api/v1/staff/tasks/:id` chuyển `todo → doing → done`. Hai người cùng bấm "xong" → phải chỉ một người thắng.

Dùng cập nhật có điều kiện, không đọc-rồi-ghi:

```sql
UPDATE order_tasks SET status = 'done', done_by = ?, done_at = NOW()
WHERE id = ? AND status = 'doing';
```

`RowsAffected() == 0` nghĩa là người khác đã làm rồi → trả 409, FE hiển thị "việc này đã xong".

### c. Bấm đúp nút "Đặt đơn"

Điện thoại lag, khách bấm hai lần → hai đơn giống hệt.

Chống bằng idempotency key: FE sinh UUID mỗi lần mở form checkout, gửi kèm header `Idempotency-Key`. BE lưu key + trả lại kết quả cũ nếu key đã thấy.

### d. Checkout hai lần

```sql
SELECT ... FROM table_sessions WHERE id = ? AND closed_at IS NULL FOR UPDATE;
```

Trong transaction. Người thứ hai chờ, rồi thấy `closed_at` đã có → trả lỗi "phiên đã đóng".

---

## 4. Quy tắc bảo mật bắt buộc

| Quy tắc | Vì sao | Cách kiểm tra |
|---------|--------|---------------|
| **Không bao giờ tin giá FE gửi** | Khách sửa giá thành 0đ | Test: POST order với `unit_price: 0` → BE vẫn tính đúng giá |
| Mật khẩu nhân viên: `bcrypt`, cost ≥ 10 | Lộ DB = lộ toàn bộ tài khoản | `gosec` + code review |
| PIN nhân viên cũng phải hash | PIN 4 số vẫn là credential | Test: `SELECT pin FROM staff` không đọc được PIN gốc |
| Token QR bàn phải random ≥ 16 byte | Đoán được token = gọi món hộ bàn khác | `crypto/rand`, không `math/rand` |
| Rate limit `/staff/login` và `/orders` | Brute force PIN, spam đơn | Test: gọi 20 lần liên tiếp → 429 |
| Endpoint `/staff/*` và `/admin/*` phải check role | Nhân viên trạm không được thu tiền | Test: token trạm gọi `/checkout` → 403 |
| Không log dữ liệu nhạy cảm | SĐT khách, token bàn vào log | Grep log không thấy `token=` |

Test bắt buộc cho quy tắc số 1:

```go
func TestCreateOrder_IgnoresClientPrice(t *testing.T) {
	body := `{"items":[{"product_slug":"day-du-chin","options":["thit","thuong"],
	           "quantity":1,"unit_price":1}]}`
	// → đơn tạo ra phải có total = 30000, không phải 1
}
```

---

## 5. Coverage — đặt ngưỡng đúng chỗ

Ép coverage toàn repo chỉ tạo test rác cho getter/setter. Đặt ngưỡng theo package:

| Package | Ngưỡng | Lý do |
|---------|--------|-------|
| `service/pricing.go` | **100%** | Mọi nhánh đều liên quan tới tiền |
| `service/` (còn lại) | ≥ 80% | Logic nghiệp vụ |
| `handler/` | ≥ 50% | API smoke là đủ |
| `db/` (sqlc sinh) | 0% | Code sinh tự động, không test |
| `main.go`, `config/` | 0% | Chạy được là biết đúng |

```bash
go test ./service/... -coverprofile=cover.out
go tool cover -func=cover.out | grep total
```

---

## 6. Hợp đồng API — nguồn sự thật cho FE

FE và BE lệch nhau là lỗi tích hợp phổ biến nhất. Chống bằng một file spec duy nhất:

```
code/be/api/openapi.yaml   ← nguồn sự thật
   ├─→ BE: test kiểm tra response khớp schema
   └─→ FE: sinh TypeScript types (xem ../frontend/02-luat.md)
```

Viết tay `openapi.yaml` (nhanh hơn `swaggo` cho ~25 endpoint) và đặt quy tắc:

> **Đổi shape response mà không sửa `openapi.yaml` = PR bị từ chối.**

Quy tắc tương thích ngược:

- Thêm field mới: **được** (FE cũ bỏ qua)
- Đổi tên field, đổi kiểu, xoá field: **breaking** — phải deploy BE + FE cùng lúc
- Đổi `total` từ `int` sang `string`: breaking, dù FE có thể vẫn chạy

---

## 7. Bẫy thường gặp

| Lỗi | Hậu quả | Cách tránh |
|-----|---------|------------|
| Tin giá FE gửi | Khách sửa giá thành 0đ | Luôn gọi `CalcItemPrice` từ DB |
| Tính giá ở 2 chỗ (quote và create khác nhau) | Giá hiển thị ≠ giá thu | Một hàm duy nhất `CalcItemPrice`, dùng chung |
| Bỏ quên `err` | Commit transaction đã hỏng | `errcheck` trong golangci-lint |
| Không bọc transaction khi đặt đơn | `order_items` mồ côi khi lỗi giữa chừng | Test luồng 7 ở tầng 2 |
| Đọc rồi ghi (`SELECT` rồi `UPDATE`) | Hai người cùng bấm → mất cập nhật | `UPDATE ... WHERE status = ?` + check `RowsAffected` |
| Không `FOR UPDATE` khi checkout | Thu tiền hai lần | `SELECT ... FOR UPDATE` trong transaction |
| Không test `-race` | Data race chỉ hiện ở quán giờ cao điểm | `go test -race` trong CI |
| Không có timeout cho DB query | Một query chậm treo cả server | `context.WithTimeout` ở middleware |
| SSE không dọn connection | Tablet mở cả buổi → cạn goroutine | Test: đóng client → goroutine giảm |

---

## Checklist BE — chạy trước mỗi lần merge

- [ ] `golangci-lint run` không lỗi
- [ ] `go test ./... -race` xanh
- [ ] Coverage `service/` ≥ 80%, `pricing.go` = 100%
- [ ] Endpoint mới đã thêm vào `openapi.yaml`
- [ ] Endpoint mới có check quyền (role) và có test 403
- [ ] Thao tác ghi nhiều bảng đã bọc transaction
- [ ] Thao tác có thể bị bấm hai lần đã chống trùng (idempotency hoặc `WHERE status`)
