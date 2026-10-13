# Cấu Trúc Backend Go — Hướng Dẫn Tái Sử Dụng

> Mô tả cấu trúc thư mục `be/` của dự án BanhCuon (Go + Gin + sqlc + MySQL + Redis) để dev khác có thể **đọc hiểu và áp dụng lại cho dự án mới**.
> Ví dụ trong tài liệu lấy từ code thật của dự án này; khi sang dự án khác chỉ cần đổi tên domain (orders, products…) là dùng được.

---

## 1. Tổng Quan Kiến Trúc

```
HTTP request
   │
   ▼
middleware   (auth JWT · RBAC · rate limit · metrics)
   │
   ▼
handler      ← chỉ làm việc với gin.Context: parse input, gọi service, trả JSON
   │
   ▼
service      ← business logic thuần, KHÔNG import gin → dễ unit test
   │
   ▼
repository   ← interface bọc truy cập DB (sqlc hoặc raw SQL), quản lý transaction
   │
   ▼
db           ← code do sqlc GENERATE từ query/*.sql + migrations/*.sql (không sửa tay)
   │
   ▼
MySQL
```

**Quy tắc vàng — dependency chỉ đi một chiều từ trên xuống, không nhảy tầng:**

| Tầng | Được phép import | KHÔNG được |
|---|---|---|
| `handler` | `service`, `middleware` (đọc claims) | gọi `db` trực tiếp, chứa business rule |
| `service` | `repository`, `db` (kiểu dữ liệu), `pkg/*` | import `gin`, viết SQL |
| `repository` | `db` | chứa business rule, biết về HTTP |
| `pkg/*` | thư viện ngoài | import bất kỳ thứ gì trong `internal/` |

---

## 2. Cây Thư Mục

```
repo-root/
├── go.mod                      ← module nằm ở ROOT (không phải trong be/) → import path "banhcuon/be/..."
└── be/
    ├── cmd/                    ← mỗi thư mục con = 1 binary (package main)
    │   ├── server/main.go      ← entry point chính: config → DB → repo → service → handler → router
    │   ├── seed/main.go        ← script 1 lần: tạo tài khoản demo cho mọi role
    │   ├── qr/main.go          ← tiện ích dev: in URL QR của các bàn
    │   └── demo_order/main.go  ← giả lập khách đặt món qua API thật (dùng để demo/test tay)
    │
    ├── internal/               ← code riêng của app (Go cấm package ngoài import)
    │   ├── handler/            ← HTTP layer — 1 file / domain: <domain>_handler.go
    │   │   └── respond.go      ← respondError() + handleServiceError() dùng chung
    │   ├── service/            ← business logic — 1 file / domain: <domain>_service.go
    │   │   ├── errors.go       ← AppError + các sentinel error (mã lỗi ↔ HTTP status)
    │   │   └── deps.go         ← interface liên-domain (service A cần gì từ service B)
    │   ├── repository/         ← data access — 1 file / domain: <domain>_repo.go
    │   ├── db/                 ← ⚙️ sqlc GENERATED — không sửa tay
    │   ├── middleware/         ← auth.go · rbac.go · ratelimit.go · metrics.go
    │   ├── sse/                ← Server-Sent Events (stream 1 chiều server → client)
    │   ├── websocket/          ← WebSocket hub (hub.go · client.go · handler.go)
    │   ├── jobs/               ← goroutine chạy nền (timeout, cleanup định kỳ)
    │   ├── payment/            ← adapter cổng thanh toán (VNPay/MoMo/ZaloPay): ký + verify HMAC
    │   ├── ai/                 ← adapter Anthropic API — nơi DUY NHẤT gọi SDK bên ngoài
    │   ├── testhelper/         ← dựng test server đầy đủ (DB + Redis thật) cho integration test
    │   └── model/              ← (đang trống — xem §6)
    │
    ├── pkg/                    ← thư viện nhỏ, tái sử dụng được, KHÔNG phụ thuộc internal/
    │   ├── jwt/                ← tạo/parse access token
    │   ├── bcrypt/             ← hash/verify mật khẩu
    │   └── redis/              ← tạo client + helper Publish/Subscribe
    │
    ├── migrations/             ← Goose migrations: NNN_<mô_tả>.sql (001_auth.sql, 002_products.sql…)
    ├── query/                  ← SQL có annotation sqlc: <domain>.sql
    ├── integration/            ← integration test gọi HTTP thật (dùng testhelper)
    │
    ├── sqlc.yaml               ← cấu hình sqlc: đọc query/ + migrations/ → sinh code vào internal/db
    ├── Dockerfile              ← multi-stage: build binary + cài goose CLI
    ├── entrypoint.sh           ← chạy goose up (có retry) rồi exec server
    ├── .air.toml               ← hot-reload khi dev local
    ├── .dockerignore
    └── CLAUDE.md               ← bản đồ ngắn cho AI agent (tuỳ chọn)
```

---

## 3. Chức Năng Từng Thư Mục / File

### 3.1 `cmd/` — Các binary

| File | Vai trò |
|---|---|
| `cmd/server/main.go` | **Composition root** — nơi DUY NHẤT khởi tạo và nối mọi thứ lại (Dependency Injection bằng tay). Đi theo thứ tự đánh số trong comment: `1. Config → 2. DB + Migrations → 3. Redis → 4. Repos → 5. Services → 6. WebSocket Hub → 7. Handlers → 8. Router → Background Jobs → Graceful Shutdown`. Toàn bộ route + middleware khai báo ở đây nên đọc 1 file là thấy toàn bộ API. |
| `cmd/seed/` | Seed dữ liệu demo. Chạy `go run ./be/cmd/seed/main.go`. |
| `cmd/qr/`, `cmd/demo_order/` | Tool cho dev — không deploy. |

> Muốn thêm tool CLI mới → tạo `cmd/<tên>/main.go`, không nhét vào server.

### 3.2 `internal/handler/` — Tầng HTTP

- Mỗi domain một struct `XxxHandler` + constructor `NewXxxHandler(svc)`.
- Một method = một endpoint, comment ghi rõ route + quyền: `// CreateTable handles POST /tables (Manager+)`.
- Request DTO khai báo ngay trong file handler, validate bằng tag `binding:"required,min=1"`.
- Việc của handler: `ShouldBindJSON` → lấy claims từ context → gọi service → `c.JSON(status, gin.H{"data": ...})`.
- **Lỗi:** luôn trả qua `handleServiceError(c, err)` hoặc `respondError(c, status, code, msg)` trong `respond.go`. Format chuẩn:
  ```json
  { "error": "ORDER_NOT_READY", "message": "Đơn hàng chưa sẵn sàng thanh toán", "details": {...} }
  ```
  Lỗi không xác định → 500 `COMMON_002`, **không bao giờ lộ chi tiết nội bộ**.

### 3.3 `internal/service/` — Business logic

- Struct `XxxService` nhận **interface** repository + client cần thiết (Redis…) qua constructor.
- Không import `gin` → test được bằng mock repo thuần Go (`*_service_test.go` cùng thư mục).
- Response DTO (struct có tag `json:`) khai báo trong file service của domain đó.
- **`errors.go`** — `AppError{Status, Code, Message, Details}` + danh sách sentinel (`ErrNotFound`, `ErrForbidden`, …). Service trả `AppError`, handler tự map sang HTTP. Mã lỗi phải khớp với tài liệu error contract.
- **`deps.go`** — khi service A cần gọi service B, A tự khai báo interface **nhỏ, chỉ gồm method nó cần** (Dependency Inversion). Ví dụ `OrderService` cần `ProductLookup`; `PaymentService` cần `OrderReader` + `OrderWriter`. Nhờ vậy không bị import vòng và dễ mock.

### 3.4 `internal/repository/` — Data access

- Mỗi domain: 1 interface `XxxRepository` (public) + 1 struct `xxxRepo` (private) + `NewXxxRepo(db) XxxRepository`.
- Bên trong dùng `db.Queries` do sqlc sinh ra; trường hợp query động / sqlc không hỗ trợ thì dùng raw SQL qua `db.DBTX`.
- **Transaction đặt ở đây** (vd `CreateOrderWithItems`: `BeginTx` → insert order + items → tính lại tổng → commit). Service gọi 1 method là đủ, không tự quản `*sql.Tx`.
- Trả về kiểu của `db` (vd `db.Order`) hoặc struct `XxxRow` nhẹ.

### 3.5 `internal/db/` — Code sinh tự động ⚙️

- Sinh bởi `sqlc generate` từ `query/*.sql` + `migrations/*.sql`. **Không sửa tay** — sửa SQL rồi generate lại.
- Gồm: `db.go` (`Queries`, `WithTx`), `models.go` (struct ứng với bảng), `querier.go` (interface `Querier`), `<domain>.sql.go`.

### 3.6 `migrations/` + `query/` — SQL là nguồn sự thật

| Thư mục | Quy ước |
|---|---|
| `migrations/NNN_<mô_tả>.sql` | Goose, đánh số tăng dần 3 chữ số. Mỗi file có `-- +goose Up` và `-- +goose Down`. **Không sửa migration đã chạy** — muốn đổi thì tạo file mới (vd `016_add_x.sql` rồi `017_drop_x.sql`). |
| `query/<domain>.sql` | Mỗi query có annotation `-- name: GetOrderByID :one` (`:one` / `:many` / `:exec`). |

Quy ước bảng dùng trong dự án: PK `CHAR(36)` UUID, `created_at` / `updated_at` / `deleted_at` (soft delete), `utf8mb4_unicode_ci`, index đặt tên `idx_<bảng>_<cột>`, unique `uq_<bảng>_<cột>`.

### 3.7 `internal/middleware/`

| File | Chức năng |
|---|---|
| `auth.go` | `AuthRequired()` — đọc Bearer JWT, kiểm tra tài khoản còn active, gắn claims vào context. Helper `ClaimsFromContext`, `StaffIDFromContext`, `RoleFromContext`, cookie refresh token. |
| `rbac.go` | Phân quyền theo cấp: `AtLeast("manager")`, `RequireRole("admin")`, `RequireOwner(...)`. Role có level số, so sánh `>=`. |
| `ratelimit.go` | Fixed-window bằng Redis `INCR + EXPIRE`, key theo IP hoặc token. Redis lỗi → **fail-open** (cho qua). Nhận interface `RateLimitStore` để test bằng fake. |
| `metrics.go` | Đo request cho Prometheus (`/metrics`). |

Cách gắn trong router:
```go
mgr := prodR.Group("")
mgr.Use(authMW, middleware.AtLeast("manager"))
mgr.POST("", productH.CreateProduct)
```

### 3.8 Realtime: `sse/` + `websocket/`

- **Redis Pub/Sub là xương sống**: service `Publish` sự kiện lên channel (vd `order/{id}`, `orders:admin`); SSE/WS handler `Subscribe` rồi đẩy xuống client. Nhờ vậy chạy được nhiều instance server.
- `sse/` — stream 1 chiều (theo dõi đơn, dashboard admin). Có heartbeat 15s để không bị proxy cắt; gửi **snapshot ngay khi connect** rồi mới nghe sự kiện.
- `websocket/` — mô hình Hub: `hub.go` giữ danh sách client, mọi thay đổi map đi qua goroutine `Run()` (tránh race); `client.go` có `readPump`/`writePump`; `handler.go` upgrade kết nối, auth qua `?token=` (browser WS không set header được).

### 3.9 `jobs/` — Tác vụ nền

- Mỗi job: `func StartXxx(ctx context.Context, ...)` chạy vòng lặp `ticker` cho tới khi `ctx` bị huỷ.
- Khởi động trong `main.go` bằng `go jobs.StartXxx(jobCtx, ...)`, huỷ khi shutdown.
- Ví dụ: hết hạn payment pending mỗi phút; dọn file mồ côi mỗi 6h.

### 3.10 Adapter bên ngoài: `payment/`, `ai/`

- Gom toàn bộ code nói chuyện với dịch vụ ngoài vào 1 package riêng; service chỉ phụ thuộc interface nhỏ.
- `ai.NewClientFromEnv()` trả `nil` khi thiếu API key → tính năng tự tắt thay vì crash.
- Webhook thanh toán là route public, **verify chữ ký HMAC bên trong handler**.

### 3.11 `pkg/` — Thư viện dùng chung

Code có thể copy nguyên sang dự án khác: `jwt` (luôn kiểm tra signing method để chống algorithm confusion), `bcrypt` (cost 12), `redis` (client + pubsub helper). Quy tắc: `pkg/` **không được import `internal/`**.

### 3.12 Test

| Loại | Vị trí | Cách chạy |
|---|---|---|
| Unit test service | `internal/service/*_test.go` (mock repo) | `go test ./be/internal/service/...` |
| Unit test middleware | `internal/middleware/*_test.go` (fake store) | `go test ./be/internal/middleware/...` |
| Integration | `be/integration/*_test.go` + `internal/testhelper` | đặt `TEST_DB_DSN`; thiếu biến → test tự skip |

`testhelper.NewTestServer(t)` dựng router đầy đủ với MySQL + Redis thật; có `SeedAdmin`, `SeedTable`, `TruncateAll`…

### 3.13 File cấu hình ở gốc `be/`

| File | Chức năng |
|---|---|
| `sqlc.yaml` | engine mysql, `queries: query/`, `schema: migrations/`, `out: internal/db`, bật `emit_interface`, `emit_json_tags`, `emit_empty_slices`; override kiểu cột đặc biệt (JSON → `json.RawMessage`). |
| `Dockerfile` | Stage build: `go mod download` (có retry) → build binary tĩnh `CGO_ENABLED=0` → cài `goose`. Stage runtime: binary + goose + `migrations/` + `entrypoint.sh`. |
| `entrypoint.sh` | Retry `goose up` tới khi DB sẵn sàng (tối đa 30 lần × 2s), rồi `exec` server. |
| `.air.toml` | Hot-reload: build `./cmd/server`, bỏ qua `migrations/`, `integration/`. |

---

## 4. Quy Trình Thêm Một Domain Mới (vd `reservation`)

1. **Migration** — `migrations/0NN_reservations.sql` (Up + Down).
2. **Query** — `query/reservations.sql` với annotation `-- name: ... :one|:many|:exec`.
3. **Generate** — `sqlc generate` (từ thư mục chứa `sqlc.yaml`) → kiểm tra `internal/db/reservations.sql.go`.
4. **Repository** — `internal/repository/reservation_repo.go`: interface `ReservationRepository` + `NewReservationRepo`.
5. **Service** — `internal/service/reservation_service.go`: logic + DTO; lỗi mới thêm vào `errors.go`; cần service khác → khai interface trong `deps.go`.
6. **Test service** — `reservation_service_test.go` với mock repo.
7. **Handler** — `internal/handler/reservation_handler.go`: bind request → gọi service → `handleServiceError`.
8. **Wire** — trong `cmd/server/main.go`: thêm repo (§4) → service (§5) → handler (§7) → route group + middleware (§8).
9. **Build & chạy** — `go build ./...` → `go test ./...` → `docker compose up -d --build be`.

---

## 5. Lệnh Thường Dùng

```bash
# từ repo root
go build ./...
go test ./be/internal/service/... -run TestLogin
cd be && sqlc generate                              # sau khi đổi query/ hoặc migrations/
goose -dir be/migrations mysql "$DB_DSN" up
goose -dir be/migrations mysql "$DB_DSN" create add_x sql
docker compose up -d --build be && docker compose logs -f be
```

Biến môi trường chính: `DB_DSN`, `REDIS_ADDR`, `PORT`, `CORS_ORIGINS`, `MIGRATIONS_DIR`, `STORAGE_BASE_PATH`, JWT secret, khoá cổng thanh toán, `ANTHROPIC_API_KEY` (tuỳ chọn).

---

## 6. Lưu Ý Khi Mang Sang Dự Án Mới

Dự án này có vài chỗ lệch khỏi quy tắc trên — **đừng copy các điểm này**, hãy làm đúng ngay từ đầu:

| Hiện trạng ở đây | Khuyến nghị cho dự án mới |
|---|---|
| `internal/model/` tồn tại nhưng trống; DTO nằm rải trong handler/service | Chọn 1 chỗ: DTO request ở handler, DTO response ở service (như hiện tại) **rồi xoá `model/`**, hoặc gom hết vào `model/`. Đừng để thư mục rỗng gây hiểu lầm. |
| `TableHandler`, `FileHandler` gọi thẳng repository, bỏ qua service | Luôn có service, kể cả mỏng — sau này thêm logic sẽ không phải refactor. |
| Một số repo dùng raw SQL thay vì sqlc | Ưu tiên sqlc; chỉ raw SQL khi query động thật sự. |
| Migration vừa chạy trong `main.go` (goose library) vừa trong `entrypoint.sh` (goose CLI) | Chọn **một** nơi chạy migration. |
| `pkg/redis.New()` có sẵn nhưng `main.go` tự tạo client | Dùng helper trong `pkg/` cho nhất quán. |
