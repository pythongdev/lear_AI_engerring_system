# Các bước đổi stack và cấu trúc backend — Gin + sqlc

**Ngày:** 2026-10-10 · **Người quyết stack:** chủ repo · **Người viết bước:** Claude Code.
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
| `github.com/sqlc-dev/sqlc` | `v1.31.1` | chưa có | công cụ sinh code, ghim bằng `go tool` (Go ≥ 1.24) |
| `github.com/jackc/pgx/v5` | `v5.11.0` | `v5.11.0` | giữ; sqlc sinh với `sql_package: pgx/v5` |
| `github.com/golang-migrate/migrate/v4` | `v4.20.1` | `v4.18.3` | image migrate ở `compose.yaml` (`QC-05`) |

## 1. Cái đổi, cái giữ

Cấu trúc đích **theo mẫu**: các tầng ngang `handler → service → repository → db (sinh)`, một
`cmd/server`. Mẫu này lấy từ một dự án khác (MySQL, goose, Redis, JWT), nên năm điểm dưới đây **không đổi**.
Chúng là thứ đang giữ tiền và dữ liệu đúng, và mỗi điểm đều có test hoặc gate chấm:

1. **PostgreSQL 17 + golang-migrate ở `db/migrations/`** (`QC-01`, `QC-05`). Không MySQL, không goose, không
   chuyển migration vào `be/`. sqlc đọc schema thẳng từ `db/migrations/*.up.sql`.
2. **Mỗi câu ghi là một file `.sql` nằm trong thư mục của đúng một cửa** (ADR-082, ADR-083, Gate 1f). Mẫu
   gom mọi câu của một miền vào `query/<domain>.sql`. Ở đây chỉ đổi vị trí: `be/query/<miền>/<cửa>/<câu>.sql`,
   mỗi file một câu, thêm dòng `-- name:` của sqlc.
3. **Giao dịch mở ở đúng một hàm, quyền kiểm trong cùng giao dịch** (`QC-13`, ADR-085). Mẫu để repository tự
   `BeginTx`. Ở đây service gọi `authz.Run(…, door, func(tx) …)`; repository **nhận** `pgx.Tx`, không bao giờ
   mở hay commit.
4. **Hình lỗi `{code, field?}` khớp `openapi.yaml`** (ADR-084, Gate 1g). Không dùng `{error, message, details}`
   của mẫu, không bọc `{data: …}`.
5. **Test trên PostgreSQL thật, thiếu database thì đỏ** (ADR-083 điểm 5, F-007). Không mock repository để
   chứng minh cửa, không skip. Tên test mang mã mệnh đề (`QC-17`).

Không đem sang: Redis, rate limit, JWT/bcrypt (cách đăng nhập là việc của **T-143**), SSE/WebSocket (pha sau),
jobs, adapter thanh toán/AI, Dockerfile/Air, `pkg/`, quy ước UUID/collation của mẫu.

## 2. Cây thư mục đích

```text
db/migrations/                  ← giữ nguyên (golang-migrate, PostgreSQL)
be/
├── go.mod · go.sum             ← module banhcuon/be, go 1.27.2, tool sqlc
├── sqlc.yaml                   ← schema: ../db/migrations/*.up.sql → internal/db/sqlc
├── cmd/server/main.go          ← composition root: config → pool → repo → service → handler → gin router
├── query/                      ← SQL là nguồn sự thật
│   └── <miền>/
│       ├── doc_*.sql           ← câu đọc (đặt đâu trong miền cũng được)
│       └── <cửa>/<câu>.sql     ← câu ghi: thư mục = cửa ghi, mã cửa <miền>/<cửa>
└── internal/
    ├── platform/postgres/      ← Open (vai shop_app, múi giờ — QC-15), InTx (hàm DUY NHẤT mở giao dịch)
    ├── db/sqlc/                ← ⚙️ code sqlc sinh — không sửa tay
    ├── handler/                ← <miền>_handler.go: Gin, đọc request, gọi service, ghi JSON
    ├── service/                ← <miền>_service.go: logic của cửa, khai authz.Door, gọi authz.Run
    ├── repository/             ← <miền>_repo.go: nhận pgx.Tx, gọi db/sqlc
    ├── apierr/                 ← giữ: mã, status, ánh xạ tên ràng buộc → mã (Gate 1g đọc ở đây)
    ├── authz/                  ← giữ: Door, Run, RunAs, Authenticator
    ├── middleware/             ← gắn danh tính người (Authenticator) vào gin.Context — không thay authz.Run
    └── testhelper/             ← đổi tên từ dbtest: đọc DSN, dựng router đầy đủ cho test
```

Các miền: `don`, `sanxuat`, `vongdoi`, `phien`, `ban`, `qr`, `menu`, `gia`, `hoadon`, `tratruoc`, `ket`,
`ngayban`. Mã cửa (`don/tao_luot_goi`, `sanxuat/ra_ban`…) **giữ nguyên tên**, vì ma trận quyền
(`02-vai-va-quyen.md`) và `openapi.yaml` gọi cửa bằng mã ấy.

**Đổi so với đề xuất của Codex.** Codex đề xuất chia tầng **bên trong từng miền**, mỗi cửa một gói code sinh.
Chủ repo chọn tầng ngang theo mẫu. Cái giá: mọi service đều import được mọi query trong `db/sqlc`, tức một service
có thể gọi câu ghi của cửa khác. Bước 2 bù lại bằng một luật Gate 1f mới: một query ghi chỉ được gọi từ
`repository/<miền>_repo.go` của chính miền ấy.

**Một điều phải chứng minh trước khi làm gì khác.** Bảng nằm ở schema `shop`, còn câu SQL hiện viết tên bảng
trần và dựa vào `search_path`. sqlc cần phân giải được tên bảng. Nếu không được, mọi câu phải viết `shop.<bảng>`.
Bước 2 trả lời câu này.

## 3. Các bước

Mỗi bước là một task trong `work/backlog.md`, Claude chấm mức và viết Acceptance trước khi giao. Codex thi
công trong worktree, Claude chạy `be-check` trên PostgreSQL thật (Codex không có Docker), rồi tích hợp. Sau mỗi
bước, `./scripts/gate.sh` phải xanh ở clone chính. **Không bước nào đổi hành vi của cửa**: mọi test hiện có giữ
nguyên điều kiện kiểm, chỉ phần dựng router trong test được đổi.

**Trước Bước 1:** đóng hoặc tạm dừng các task đang sửa `be/` (T-138, T-140, T-142, T-143). Đổi cấu trúc
giữa lúc bốn task kia còn mở thì chắc chắn xung đột. Xử lý **F-061** (phép kiểm tên test `QC-17` không chạy khi
chỉ đổi `be/`), vì từ đây mọi bước đều chỉ đổi `be/`.

### Bước 1 — Ghi quyết định (L3 · Claude · không code)
- ADR-092: thay điểm 1 và điểm 6 của **ADR-083** (Gin, sqlc, tầng ngang, `be/query/`), giữ nguyên ADR-082 ·
  ADR-084 · ADR-085. Ghi cái bị loại (tầng trong từng miền của Codex) và lý do chủ repo chọn.
- Sửa `QC-11` (Go 1.27.2, phụ thuộc trực tiếp), `QC-12` (Gin, khuôn đăng ký route), `QC-13` (sqlc, `be/query/`,
  luật gọi query), `QC-14` (cây §2), `QC-05` (migrate v4.20.1). Mỗi QC giữ một phép kiểm chạy được.
- Mở task cho Bước 2…9 trong `work/backlog.md`.
- **Xong khi:** ADR và QC có ngày, có người quyết; gate xanh.

### Bước 2 — Công cụ và gate, chưa chuyển cửa nào (L2 · Codex làm, Claude duyệt)
- `be/go.mod`: `go 1.27.2`, `require github.com/gin-gonic/gin v1.12.0`, `tool github.com/sqlc-dev/sqlc/cmd/sqlc`
  ghim v1.31.1. `compose.yaml`: migrate v4.20.1; `./scripts/db-check.sh` xanh.
- `be/sqlc.yaml` + chạy thử `go tool sqlc generate` trên **toàn bộ** `db/migrations/`. Phải đọc được hàm
  PL/pgSQL, trigger, schema `shop`. Không đọc được thì DỪNG, báo Claude. Không sửa migration, không chép tay
  schema cho sqlc.
- **Gate 1f** (`check-write-paths.sh`) đọc cả hai khuôn, cũ `internal/<gói>/sql/<cửa>/` và mới
  `query/<miền>/<cửa>/`. Thêm ba luật: mỗi file ghi có đúng một `-- name:` và một câu; tên query duy nhất; query
  ghi chỉ được gọi từ `internal/repository/<miền>_repo.go` của chính miền ấy. File Go sinh ở `internal/db/sqlc/`
  được miễn luật "SQL trong chuỗi Go" chỉ khi nội dung khớp file nguồn.
- **Gate 1g** (`check-api-contract.sh`) đọc cả `HandleFunc("POST /…")` lẫn `r.POST("/…/:id")`. Đổi `:id` thành
  `{id}`, giữ tên tham số. `Group`, `Any`, `Handle`, nối chuỗi, wildcard ⇒ **đỏ**, không bỏ qua im lặng.
- `scripts/verify.sh`: sinh lại vào thư mục tạm rồi so cả tập file với `internal/db/sqlc/`. Lệch ⇒ đỏ.
- `.test.sh` của hai gate có ca đỏ cho từng luật mới (danh sách ca: báo cáo Codex mục 4e).
- **Xong khi:** gate xanh trên code cũ, mọi ca lỗi cài đỏ đúng chỗ, danh sách ô ghi (`--list`) không đổi.

### Bước 3 — Nền: kết nối, lỗi, quyền, server (L2)
- `internal/db/` → `internal/platform/postgres/` (`Open`, `InTx`); `dbtest` → `testhelper`. Test `QC-15`,
  `QC-03` vẫn xanh.
- `apierr`: thêm helper ghi lỗi qua `*gin.Context`, giữ `{code, field?}`, bảng status, `FromDB`.
- `authz`: giữ `Door`, `Run`, `RunAs`. `middleware/` chỉ gắn người vào context, quyền vẫn kiểm trong giao dịch.
- `cmd/server/main.go` dựng gin router, gắn route của các miền **cũ** qua adapter (`gin.WrapH`) để mọi đường gọi
  vẫn chạy trong lúc chuyển dần.
- **Xong khi:** be-check xanh, 39 đường gọi vẫn khớp hợp đồng.

### Bước 4 — Miền mẫu `menu` (L2)
Miền đầu tiên có câu `UPDATE` ghi thẳng, nên chứng minh được cả khuôn. (`qr` không đủ: cửa của nó ghi qua hàm
migration.) Chuyển `menu` thành `handler/menu_handler.go` · `service/menu_service.go` ·
`repository/menu_repo.go` · `query/menu/<cửa>/*.sql`, rồi xoá `internal/menu/`.
- **Xong khi:** `TestI012_ChiChuQuanSuaMenu`, `TestI018_*`, `TestI009_NgungBanHaiLan`, `TestI013_KhongCoDuongSuaGiaSuat`
  xanh mà không đổi điều kiện kiểm; `check-write-paths.sh --list` cho đúng các ô của `menu` như trước, chỉ đổi đường
  dẫn. Claude cài lỗi (gọi query ghi của `menu` từ repo miền khác) ⇒ Gate 1f đỏ.

### Bước 5 — Các miền nhỏ (L1–L2, mỗi miền một task)
`qr` → `gia` → `ngayban` → `ban` → `phien` → `vongdoi`. Cùng khuôn Bước 4. `vongdoi` giữ API nhận `pgx.Tx`
cho cửa gọi (lớp `theo_cua_goi`).

### Bước 6 — Đường tiền (L2, mỗi miền một task)
`tratruoc` → `hoadon` → `ket`. Chạy lại toàn bộ test `I-005`, `I-015`, `I-021`, `YC-01`, `YC-10`, `YC-23`. Claude
cài một lỗi thu sai, đối soát phải kêu.

### Bước 7 — `sanxuat` rồi `don` (L2, hai task)
Lớn nhất, nhiều test tranh chấp nhất. Chạy `be-check` ít nhất hai lần mỗi task. Test chập chờn
`TestI020_DaRaBanTheoSoCaiTungThuChoMotBan` (chưa tìm ra nguyên nhân 2026-10-10) phải được xử lý **trước**
bước này. Nếu không, không phân biệt được lỗi cũ với lỗi do chuyển.

### Bước 8 — Dọn (L1)
Gỡ adapter `gin.WrapH`, gỡ khuôn cũ khỏi Gate 1f và 1g (từ đây khuôn cũ ⇒ đỏ), xoá `internal/<miền>/` rỗng.
Cập nhật `QC-14` lần cuối.

### Bước 9 — Rà chéo (L1 · Claude)
Đối chiếu cây thật với §2, `--list` của hai gate với lần đầu Bước 2, số test trước và sau (không mất test nào).
Ghi vào `work/findings.md` những gì làm chậm quá trình chuyển, nếu nó lặp lại.

## 4. Cách lùi

Mỗi bước là một commit, xanh trước và xanh sau. Bước 4–7 hỏng thì `git revert` commit của miền ấy. Adapter của
Bước 3 giữ cho các miền chưa chuyển vẫn chạy. Không bước nào đổi migration hay dữ liệu, nên lùi không đụng
database.
