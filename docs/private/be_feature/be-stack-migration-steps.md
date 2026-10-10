# Các bước đổi stack và cấu trúc backend — Gin + sqlc

**Ngày:** 2026-10-10 · **Người quyết stack:** chủ repo · **Người viết bước:** Claude Code.
*Sửa đổi 2026-10-10: đổi từ chia ngang sang kết hợp, chủ repo chọn*.

**Đầu vào:** cấu trúc mẫu `be-structure-guidline.md` (cùng thư mục), đề xuất của Codex
`BE-STACK-de-xuat-codex.md` (cùng thư mục, lát khảo sát 2026-10-09, không đổi file nào).

Tài liệu này là **kế hoạch**, không phải luật. Khi bắt đầu Bước 1, luật thật được viết vào owner của nó:
ADR mới ở `docs/decisions.md`, quy ước `QC-11`…`QC-17` ở `docs/product/2-db/10-quy-uoc-code.md`. Hai bản
lệch nhau thì owner thắng (`CLAUDE.md` §2).

---

## 0. Stack đã duyệt

Chủ repo duyệt 2026-10-10. Phiên bản do Claude tra trên `proxy.golang.org/<module>/@latest` và
`go.dev/dl/?mode=json` cùng ngày.

| Thành phần | Bản ghim | Hiện tại | Ghi chú |
|---|---|---|---|
| Go | `go 1.27.2` | `go 1.27.1` | dòng `go` của `be/go.mod` |
| `github.com/gin-gonic/gin` | `v1.12.0` | chưa có | thay `net/http` ServeMux (`QC-12`) |
| `github.com/sqlc-dev/sqlc` | `v1.31.1` | chưa có | công cụ sinh code, ghim bằng dòng `tool` của `be/go.mod`, chạy `go tool sqlc` |
| `github.com/jackc/pgx/v5` | `v5.11.0` | `v5.11.0` | giữ; sqlc sinh với `sql_package: pgx/v5` |
| `github.com/golang-migrate/migrate/v4` | `v4.20.1` | `v4.18.3` | image migrate ở `compose.yaml` (`QC-05`) |

## 1. Cái đổi, cái giữ

Cấu trúc đích **kết hợp**: lấy cách chia trách nhiệm handler → service → repository từ mẫu,
nhưng đặt cả ba tầng bên trong từng miền. Phụ thuộc đi một chiều: handler không gọi DB;
service và repository không import Gin. Mẫu đến từ dự án khác, nên năm điểm dưới đây **không đổi**.
Chúng giữ tiền và dữ liệu đúng, mỗi điểm đều có test hoặc gate chấm:

1. **PostgreSQL 17 + golang-migrate ở `db/migrations/`** (`QC-01`, `QC-05`). Không MySQL, không goose, không
   chuyển migration vào `be/`. sqlc đọc schema thẳng từ `db/migrations/*.up.sql`.
2. **Mỗi câu ghi là một file `.sql` nằm trong thư mục của đúng một cửa** (ADR-082, ADR-083, Gate 1f). Giữ nguyên
   vị trí `be/internal/<miền>/sql/<cửa>/<câu>.sql`, mỗi file một câu, thêm một dòng `-- name:` của sqlc.
3. **Giao dịch mở ở đúng một hàm, quyền kiểm trong cùng giao dịch** (`QC-13`, ADR-085). Mẫu để repository tự
   `BeginTx`. Ở đây service gọi `authz.Run(…, door, func(tx) …)`; repository **nhận** `pgx.Tx`, không bao giờ
   mở hay commit.
4. **Hình lỗi `{code, field?}` khớp `openapi.yaml`** (ADR-084, Gate 1g). Không dùng `{error, message, details}`
   của mẫu, không bọc `{data: …}`.
5. **Test trên PostgreSQL thật, thiếu database thì đỏ** (ADR-083 điểm 5, F-007). Không mock repository để
   chứng minh cửa, không skip. Tên test mang mã mệnh đề (`QC-17`).

Không đem sang: Redis, rate limit, JWT/bcrypt (cách đăng nhập là việc của **T-143**), SSE/WebSocket (pha sau),
jobs, adapter thanh toán/AI, Dockerfile/Air, `pkg/`, quy ước UUID/collation của mẫu.

### Vì sao kết hợp

1. Package là ranh giới thật của Go. Code sinh đặt trong `<miền>/internal/` thì Go tự chặn miền khác gọi câu ghi của miền này, giữ luật *mỗi ô ghi đúng một cửa* (ADR-082) mà không cần phép kiểm phân tích code Go.
2. Chia ngang thì cả `service/` là một package, mọi service thấy mọi query ghi, ranh giới chỉ còn một luật gate.
3. Một cửa sửa ở một thư mục, không phải ba.
4. Thư mục `sql/<cửa>/` **giữ nguyên tên và vị trí** như hiện tại, nên Gate 1f không đổi khuôn đường dẫn.

### Phương án bị loại

- Chia ngang đúng như mẫu: `internal/handler/`, `internal/service/`, `internal/repository/`, `be/query/`. Bị loại vì ranh giới package và quyền nhìn thấy query ghi nêu ở ý 1–2.
- Mỗi cửa một gói sinh như đề xuất lát 0: khoảng 35 gói khiến `sqlc.yaml` quá dài. Chọn mỗi miền một gói.

## 2. Cây thư mục đích

```text
be/
├── go.mod · go.sum            ← module banhcuon/be, go 1.27.2, tool sqlc
├── sqlc.yaml                  ← một mục sql: cho mỗi miền; schema ../db/migrations/*.up.sql
├── cmd/server/main.go         ← composition root: nối mọi thứ, dựng gin router, gọi Routes từng miền
└── internal/
    ├── platform/postgres/     ← Open (vai shop_app, múi giờ — QC-15), InTx (DUY NHẤT mở giao dịch)
    ├── apierr/ · authz/       ← giữ; Gate 1g đọc apierr; authz.Run kiểm quyền trong giao dịch
    ├── middleware/            ← gắn người vào gin.Context; không thay authz.Run
    ├── testhelper/            ← đổi tên từ dbtest
    └── <miền>/                ← don, sanxuat, vongdoi, phien, ban, qr, menu, gia, hoadon, tratruoc, ket, ngayban
        ├── handler.go         ← Gin: đọc request, gọi service, ghi JSON qua apierr; duy nhất file miền import gin
        ├── service.go         ← logic cửa, authz.Door, authz.Run; API Go nhận pgx.Tx cho theo_cua_goi
        ├── repository.go      ← nhận pgx.Tx, gọi sqlcgen; không Begin, không commit
        ├── sql/<cửa>/<câu>.sql ← mỗi file MỘT câu + một dòng -- name:; mã cửa <miền>/<cửa>
        ├── sql/*.sql          ← câu đọc
        └── internal/sqlcgen/  ← code sqlc sinh riêng miền; miền khác không import được theo luật internal của Go
```

Mã cửa giữ nguyên vì ma trận quyền và `openapi.yaml` dùng các mã đó. Ranh giới `internal` chặn import
liên miền; trong một miền, việc gọi đúng cửa vẫn phải được duyệt và kiểm qua test cửa theo ADR-082.

Việc đầu tiên của Bước 02 là chứng minh sqlc đọc toàn bộ migration, kể cả PL/pgSQL, trigger, schema
`shop` và tên bảng trần qua `search_path`. Không đọc được thì dừng báo Claude; không sửa migration.

## 3. Các bước

Prompt cho từng bước nằm ở [prompts/README.md](prompts/README.md).

Mỗi bước là một task trong `work/backlog.md`, Claude chấm mức và viết Acceptance trước khi giao. Codex thi
công trong worktree, Claude chạy `be-check` trên PostgreSQL thật (Codex không có Docker), rồi tích hợp. Sau mỗi
bước, `./scripts/gate.sh` phải xanh ở clone chính. **Không bước nào đổi hành vi của cửa**: mọi test hiện có giữ
nguyên điều kiện kiểm, chỉ phần dựng router trong test được đổi.

### Bước 00 — Điều kiện trước (L2 · Claude)

Đóng hoặc tạm dừng T-138, T-140, T-142, T-143, là các task đang sửa `be/`; ghi bàn giao để không
chồng người viết. Sửa F-061: phép kiểm tên test QC-17 phải chạy cả khi chỉ đổi `be/`.
Xử lý test chập chờn `TestI020_DaRaBanTheoSoCaiTungThuChoMotBan`: thấy đỏ một lần trong khoảng mười
lần ngày 2026-10-09, chưa rõ nguyên nhân. Muốn tìm phải chạy lặp `be-check` và giữ database lúc đỏ.
Hiện script dọn database cả khi lỗi; bước này thêm `BE_CHECK_KEEP_DB=1` để giữ database khi đỏ (Claude chốt 2026-10-10).
Không coi vài lượt xanh là đã tìm được nguyên nhân.

### Bước 01 — Ghi quyết định (L3 · Claude · không code)
- Số ADR kế tiếp (tra bằng `grep -o 'ADR-[0-9]*' docs/decisions.md | sort -u | tail -1`): thay điểm 1 và điểm 6 của **ADR-083** (Gin, sqlc, cấu trúc kết hợp), giữ nguyên ADR-082 ·
  ADR-084 · ADR-085. Ghi hai phương án bị loại ở §1 và lý do chủ repo chọn.
- Sửa `QC-11` (Go 1.27.2, phụ thuộc trực tiếp), `QC-12` (Gin, khuôn đăng ký route), `QC-13` (sqlc, SQL giữ tại từng cửa,
  một gói sinh riêng mỗi miền), `QC-14` (cây §2), `QC-05` (migrate v4.20.1). Mỗi QC giữ một phép kiểm chạy được.
- Mở task cho Bước 2…9 trong `work/backlog.md`.
- **Xong khi:** ADR và QC có ngày, có người quyết; gate xanh.

### Bước 02 — Công cụ và gate, chưa chuyển cửa nào (L2 · Codex làm, Claude duyệt)
- `be/go.mod`: `go 1.27.2`, `require github.com/gin-gonic/gin v1.12.0`, `tool github.com/sqlc-dev/sqlc/cmd/sqlc`
  ghim v1.31.1. `compose.yaml`: migrate v4.20.1; `./scripts/db-check.sh` xanh.
- File dự kiến tạo ở bước này: be/sqlc.yaml; chạy thử `go tool sqlc generate` trên **toàn bộ** `db/migrations/`. Phải đọc được hàm
  PL/pgSQL, trigger, schema `shop`. Không đọc được thì DỪNG, báo Claude. Không sửa migration, không chép tay
  schema cho sqlc.
- **Gate 1f** (`check-write-paths.sh`) giữ khuôn `internal/<miền>/sql/<cửa>/`. Mỗi file
  `sql/<cửa>/*.sql` có đúng một `-- name:` và một câu; tên query duy nhất trong miền. File Go dưới
  `internal/<miền>/internal/sqlcgen/` được miễn luật "SQL trong chuỗi Go" chỉ khi khớp nguồn.
  Mọi Go khác vẫn bị quét `Begin`; nhãn generated cũng không miễn phép quét mở giao dịch.
  Không thêm luật query ghi chỉ gọi từ repository của chính miền: luật `internal` của Go đã giữ.
  Claude phải làm rõ cách áp luật annotation trong giai đoạn chưa chuyển cửa nào mà gate vẫn xanh;
  không tự nới luật trong phiếu thi công. Đích cuối áp cho mọi file cửa; khuôn đường dẫn không đổi.
- Thêm phép kiểm đọc file: chỉ `handler.go` (và `cmd/server/`, `middleware/`, test) được import gin.
- **Gate 1g** (`check-api-contract.sh`) đọc cả `HandleFunc("POST /…")` lẫn `r.POST("/…/:id")`. Đổi `:id` thành
  `{id}`, giữ tên tham số. `Group`, `Any`, `Handle`, nối chuỗi, wildcard ⇒ **đỏ**, không bỏ qua im lặng.
- `scripts/verify.sh`: sinh lại vào thư mục tạm rồi so cả tập file với `internal/*/internal/sqlcgen/`. Lệch ⇒ đỏ.
- `.test.sh` của hai gate có ca đỏ cho từng luật mới (danh sách ca: báo cáo Codex mục 4e).
- **Xong khi:** gate xanh trên code cũ, mọi ca lỗi cài đỏ đúng chỗ, danh sách ô ghi (`--list`) không đổi.

### Bước 03 — Nền: kết nối, lỗi, quyền, server (L2)
- `internal/db/` → `internal/platform/postgres/` (`Open`, `InTx`); `dbtest` → `testhelper`. Test `QC-15`,
  `QC-03` vẫn xanh.
- `apierr`: phục vụ handler Gin, giữ `{code, field?}`, bảng status, `FromDB`.
- `authz`: giữ `Door`, `Run`, `RunAs`. `middleware/` chỉ gắn người vào context, quyền vẫn kiểm trong giao dịch.
- File dự kiến tạo cmd/server/main.go dựng gin router, gắn route của các miền **cũ** qua adapter (`gin.WrapH`) để mọi đường gọi
  vẫn chạy trong lúc chuyển dần.
- **Xong khi:** be-check xanh, tập đường gọi vẫn khớp hợp đồng tại mốc bắt đầu (không ghim số đếm lịch sử).
- Claude làm rõ trước thi công nếu helper apierr cần import Gin: luật import không cho ngoại lệ apierr; không tự nới luật.

### Bước 04 — Miền mẫu `menu` (L2)
Miền đầu tiên có câu `UPDATE` ghi thẳng, nên chứng minh được cả khuôn. (`qr` không đủ: cửa của nó ghi qua hàm
migration.) Các file đích sẽ tạo trong miền: internal/menu/handler.go, service.go, repository.go,
`internal/menu/internal/sqlcgen/`; SQL vẫn ở `internal/menu/sql/<cửa>/*.sql`. Giữ thư mục miền.
- **Xong khi:** `TestI012_ChiChuQuanSuaMenu`, `TestI018_*`, `TestI009_NgungBanHaiLan`, `TestI013_KhongCoDuongSuaGiaSuat`
  xanh mà không đổi điều kiện kiểm; `check-write-paths.sh --list` cho đúng các ô của `menu` như trước, chỉ đổi đường
  dẫn. Claude cài lỗi import `menu/internal/sqlcgen` từ miền khác ⇒ Go build đỏ vì luật internal.

### Bước 05 — Các miền nhỏ (L1–L2, mỗi miền một task)
`qr` → `gia` → `ngayban` → `ban` → `phien` → `vongdoi`. Cùng khuôn Bước 4: `internal/<miền>/{handler,service,repository}.go`,
SQL giữ tại `internal/<miền>/sql/`, code sinh tại `internal/<miền>/internal/sqlcgen/`. `vongdoi` giữ API nhận `pgx.Tx`
cho cửa gọi (lớp `theo_cua_goi`).

### Bước 06 — Đường tiền (L2, mỗi miền một task)
`tratruoc` → `hoadon` → `ket`. Mỗi miền giữ SQL tại `internal/<miền>/sql/`, chuyển sang
`handler.go`, `service.go`, `repository.go` và `internal/sqlcgen/` bên trong miền. Chạy lại toàn bộ test `I-005`, `I-015`, `I-021`, `YC-01`, `YC-10`, `YC-23`. Claude
cài một lỗi thu sai, đối soát phải kêu.

### Bước 07 — `sanxuat` rồi `don` (L2, hai task)
Dùng `internal/<miền>/{handler,service,repository}.go` và `internal/<miền>/internal/sqlcgen/`,
giữ `internal/<miền>/sql/`. Lớn nhất, nhiều test tranh chấp nhất. Chạy `be-check` ít nhất hai lần mỗi task. Test chập chờn
`TestI020_DaRaBanTheoSoCaiTungThuChoMotBan` (chưa tìm ra nguyên nhân 2026-10-10) phải được xử lý từ **Bước 00**. Nếu không, không phân biệt được lỗi cũ với lỗi do chuyển.

### Bước 08 — Dọn (L1)
Gỡ adapter `gin.WrapH`, gỡ khuôn route cũ khỏi Gate 1g (từ đây route cũ ⇒ đỏ).
Gate 1f giữ nguyên khuôn đường dẫn SQL; mọi miền đã dùng annotation và code sinh.
Cập nhật `QC-14` lần cuối.

### Bước 09 — Rà chéo (L1 · Claude)
Đối chiếu cây thật với §2, `--list` của hai gate với lần đầu Bước 2, số test trước và sau (không mất test nào).
Ghi vào `work/findings.md` những gì làm chậm quá trình chuyển, nếu nó lặp lại.

## 4. Cách lùi

Mỗi bước là một commit, xanh trước và xanh sau. Bước 4–7 hỏng thì `git revert` commit của miền ấy. Adapter của
Bước 3 giữ cho các miền chưa chuyển vẫn chạy. Không bước nào đổi migration hay dữ liệu, nên lùi không đụng
database.
