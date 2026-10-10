**1. File đã đổi / tạo trong worktree**

Không đổi file nào. Nhánh hiện tại là `codex/BE-STACK`, nền `880b741`.

Các lệnh sau đều không có output:

```text
git status --short
git diff --name-only HEAD
git ls-files --others --exclude-standard
git diff --cached --name-only
```

Không làm thử, không commit, không đưa gì về clone chính. Không có nội dung để lập khối commit.

**2. Output `./scripts/gate.sh` nếu có làm thử**

Không làm thử nên không chạy `./scripts/gate.sh`. Đã chạy riêng hai gate đọc file để lấy hiện trạng; đây **không phải** bằng chứng toàn bộ gate xanh:

```text
$ ./scripts/check-write-paths.sh --list
```

Dòng kết quả cuối:

```text
check-write-paths: PASS — 36 ô ghi, 35 cửa, 105 file đã soát
```

```text
$ ./scripts/check-api-contract.sh
```

Dòng kết quả cuối:

```text
check-api-contract: PASS — hợp đồng 0.7.0; 39 đường gọi ở hợp đồng, 39 ở code; 61 mã lỗi; 290 tên từ chối ở migration, 290 dòng ánh xạ (212 internal, 56 unreviewed, 22 dòng mang mã công khai); 35 cửa, 35 dòng ma trận, 35 khai báo authz.Door
```

**3. Bảng Acceptance → bằng chứng**

| Acceptance | Bằng chứng |
|---|---|
| Phiên bản mới nhất hoặc “chưa xác minh” | Mục 4a ghi riêng năm thành phần, lệnh và lỗi DNS thực tế. Không lấy số phiên bản từ dự án kia làm kết quả. |
| Bảng đối chiếu đủ sáu chỗ va | Mục 4b phân loại từng điểm; giữ PostgreSQL, cửa ghi, giao dịch chung, hợp đồng lỗi, test DB thật và mã test. |
| Cây đích và `sqlc.yaml` | Mục 4c–4d; mẫu chưa được chạy. |
| Đề xuất Gate 1f/1g đủ cụ thể | Mục 4e nêu khuôn được nhận, điều kiện đỏ, kiểm code sinh, cách chuẩn hoá route và ca hồi quy. |
| Kế hoạch từng lát, mức, luật/file, gate và lùi | Mục 4f. Các lát chỉ bắt đầu sau khi Claude duyệt ADR thay thế lựa chọn hiện hành. |
| Bằng chứng làm thử | Không áp dụng: không làm thử vì sandbox không truy cập được nguồn tải. Không có output `sqlc generate`. |

**4. Đề xuất**

Đề xuất là **nhận Gin và sqlc có điều kiện**, giữ các gói nghiệp vụ và danh tính cửa hiện tại; tách trách nhiệm bên trong từng gói. Không chuyển nguyên cây thư mục của dự án tham khảo.

ADR-082 đặt yêu cầu bảo vệ ô ghi; **ADR-083 mới là quyết định trực tiếp bác Gin và sqlc**. Lý do bác vẫn cần được trả lời trong ADR mới: Gin thêm phụ thuộc và kiểu context; sqlc thêm công cụ phải ghim và phép kiểm code sinh không lệch SQL. Mong muốn đổi stack không tự chứng minh hai chi phí này đã được giải quyết.

**4a. Phiên bản**

Đã chạy trong sandbox:

```sh
curl -fsS --connect-timeout 10 --max-time 20 'https://go.dev/dl/?mode=json'

for module in github.com/gin-gonic/gin github.com/sqlc-dev/sqlc github.com/jackc/pgx/v5 github.com/golang-migrate/migrate/v4; do
  echo "$module"
  curl -fsS --connect-timeout 10 --max-time 20 "https://proxy.golang.org/$module/@latest"
done
```

Output:

```text
curl: (6) Could not resolve host: go.dev
github.com/gin-gonic/gin
curl: (6) Could not resolve host: proxy.golang.org
github.com/sqlc-dev/sqlc
curl: (6) Could not resolve host: proxy.golang.org
github.com/jackc/pgx/v5
curl: (6) Could not resolve host: proxy.golang.org
github.com/golang-migrate/migrate/v4
curl: (6) Could not resolve host: proxy.golang.org
```

| Thành phần | Bản ổn định mới nhất | Nguồn/lệnh xác minh | Số đang có để đối chiếu, không phải kết quả xác minh |
|---|---|---|---|
| Go | **Chưa xác minh** | Lệnh `curl go.dev` trên; lỗi DNS | Repo ghim `go 1.27.1`; ví dụ dự án kia là `1.25.7`. |
| `github.com/gin-gonic/gin` | **Chưa xác minh** | Proxy `@latest`; lỗi DNS | Chưa có trong repo; ví dụ được nêu là `v1.12.0`. |
| `github.com/sqlc-dev/sqlc` | **Chưa xác minh** | Proxy `@latest`; lỗi DNS | Chưa có trong repo. |
| `github.com/jackc/pgx/v5` | **Chưa xác minh** | Proxy `@latest`; lỗi DNS | `be/go.mod` đang ghim `v5.11.0`. |
| `github.com/golang-migrate/migrate/v4` | **Chưa xác minh** | Proxy `@latest`; lỗi DNS | QC-05 quy định `v4.18.3`. |

Công cụ duyệt web đọc được tài liệu sqlc để đối chiếu cấu hình, nhưng tôi không dùng nhãn phiên bản tài liệu thay cho phép xác minh module theo yêu cầu.

Khi có mạng, cần lấy lại output và ghim bản cụ thể. Giữ module `banhcuon/be` tại `be/go.mod`; không chép module `banhcuon` từ dự án kia. Nâng golang-migrate không phải điều kiện để dùng Gin/sqlc, nên tách riêng nếu chủ repo muốn nâng.

**4b. Đối chiếu tài liệu tham khảo với luật hiện hành**

Dấu ✓ ở đúng một cột là phân loại đề xuất; “nhận” chưa có nghĩa đã được Claude chốt.

| Điểm tham khảo | Nhận | Nhận có sửa | Không nhận | Luật chạm và lý do |
|---|:---:|:---:|:---:|---|
| Handler → service → repository → code DB | | ✓ | | QC-14, ADR-082/085: tách trách nhiệm trong từng gói; service là nơi điều phối cửa, không đẩy ranh giới giao dịch xuống repository. |
| Service không import Gin | ✓ | | | QC-12, ADR-083: hạn chế ảnh hưởng của framework vào nghiệp vụ và test cửa. |
| Gom toàn bộ miền vào các package ngang `handler`, `service`, `repository` | | | ✓ | QC-14: giữ gói nghiệp vụ và mã cửa hiện hành, tránh phải đổi đồng loạt import và nơi tìm cửa. |
| `cmd/server` nối các thành phần bằng constructor | | ✓ | | QC-14, ADR-085: chỉ dựng khi có bộ xác thực thật được duyệt; route nằm tại từng gói, nơi lắp ghép gọi `Routes`. |
| Các CLI seed/demo/QR | | | ✓ | QC-08/14: chưa có yêu cầu; seed đã có owner ngoài backend. |
| Module tại gốc repo | | | ✓ | QC-11: giữ `be/go.mod`, module `banhcuon/be`. |
| Thư viện dùng chung trong `pkg/` | | | ✓ | QC-14: chưa có nhu cầu xuất thư viện; giữ `internal/db`, `apierr`, `authz`, `dbtest`. |
| MySQL, goose, `be/migrations/` | | | ✓ | QC-01/05/08: PostgreSQL 17 và golang-migrate tại `db/migrations/` tiếp tục là nền. |
| Không sửa migration đã chạy | ✓ | | | QC-05: phù hợp; không cần đổi migration cho lát chuyển khung. |
| `query/<domain>.sql` gom câu SQL | | ✓ | | QC-13, ADR-082/083: giữ mỗi câu một file dưới cửa; thêm `-- name:` ngay tại file đó. Không gom các cửa vào một file. |
| sqlc sinh code, không sửa tay | | ✓ | | QC-13/14, ADR-083: output riêng từng cửa; bổ sung kiểm sinh lại và đối chiếu nguồn. |
| `internal/db` chứa toàn bộ code sinh | | | ✓ | QC-13/15: thư mục này tiếp tục sở hữu kết nối và hàm mở giao dịch. |
| Repository tự `BeginTx`, commit | | | ✓ | QC-13, ADR-082/085: repository nhận `pgx.Tx` từ cửa, không mở hay kết thúc giao dịch. |
| Interface nhỏ tại bên sử dụng | ✓ | | | QC-14: dùng khi thực sự cần tách phụ thuộc; không tạo interface CRUD toàn miền chỉ để mock. |
| Raw SQL động khi sqlc không hỗ trợ | | | ✓ | QC-13: không dùng làm lối thoát cho câu ghi; gặp câu không hỗ trợ phải báo Claude. |
| Request DTO ở handler, response DTO tách khỏi model DB | | ✓ | | ADR-084: giữ hình hợp đồng; không trả trực tiếp model sqlc hoặc tự thêm lớp `{data: ...}`. |
| Gin binding/validation bằng tag | | ✓ | | ADR-084: phải giữ thứ tự kiểm, mã và `field` hiện có; không thay toàn bộ decoder bằng binding mặc định. |
| Lỗi `{error,message,details}` | | | ✓ | ADR-084, QC-14: giữ `{code,field?}`, bảng status và ánh xạ tên ràng buộc trong `apierr`. |
| JWT, refresh token, bcrypt | | | ✓ | ADR-085 và phạm vi phiếu: tiếp tục dùng giao diện `Authenticator`, không chọn cách đăng nhập trong lát này. |
| RBAC theo cấp số tại middleware | | | ✓ | ADR-085: quyền theo cửa và chỗ đứng tại mốc giao dịch; middleware không thay `authz.Run`. |
| Redis và rate limit fail-open | | | ✓ | Ngoài phạm vi; không tự thêm phụ thuộc hay đường suy giảm. |
| SSE/WebSocket, Pub/Sub | | | ✓ | QC-14 và phạm vi: chưa có lát này; không tạo thư mục chờ. |
| Jobs nền | | | ✓ | Ngoài đổi khung; không tự chuyển nghiệp vụ sang goroutine hoặc đổi mốc thực thi. |
| Adapter thanh toán/AI và tự tắt khi thiếu API key | | | ✓ | Ngoài phạm vi; không tự quyết hành vi khi dịch vụ ngoài lỗi. |
| Mock repository để chứng minh service/cửa đúng | | | ✓ | ADR-082/083, QC-16: không chứng minh được ràng buộc, rollback hoặc tranh chấp trên PostgreSQL. |
| Integration tự skip khi thiếu DB | | | ✓ | QC-16, ADR-083 điểm 5: tiếp tục đỏ; giữ lý do của lỗi lịch sử F-007 về test bị bỏ qua. |
| Testhelper dựng server thật | | ✓ | | QC-16: tái sử dụng `dbtest` và database riêng do `be-check.sh` dựng; không MySQL/Redis, không thêm cách dựng DB thứ hai. |
| Tên test theo tên service | | ✓ | | QC-17: đổi thành `TestIxxx_`, `TestYCxx_`, `TestQCxx_`; giữ dấu truy mệnh đề. |
| Dockerfile, entrypoint chạy goose, Air | | | ✓ | QC-05/14: không thêm vào lát đổi khung. Migration vẫn chạy qua cơ chế hiện có. |
| Quy ước UUID, collation, tên index của dự án kia | | | ✓ | QC-01/05, ADR-084: migration hiện tại thắng; không đổi schema theo mẫu ngoài. |
| Không tạo `model/` rỗng; migration chỉ có một đường chạy | ✓ | | | Phù hợp QC-05/14; tránh cấu trúc không có trách nhiệm thực tế. |

**4c. Cây đích và đường gọi**

```text
db/
└── migrations/                     # giữ nguyên; PostgreSQL + golang-migrate

be/
├── go.mod                          # module banhcuon/be
├── go.sum
├── sqlc.yaml
├── cmd/
│   └── server/main.go              # lát sau, khi xác thực thật được duyệt
└── internal/
    ├── db/                         # Open, InTx; không chứa code sinh
    ├── dbtest/
    ├── apierr/                     # giữ mã, status, FromDB, hình lỗi
    ├── authz/                      # giữ Run/RunAs, Door, Authenticator
    ├── qr/
    │   ├── handler.go              # Gin, đăng ký route, parse/response
    │   ├── service.go              # điều phối cửa và authz.Run
    │   ├── repository.go           # nhận tx, gọi code sinh
    │   ├── qr_test.go              # HTTP + PostgreSQL thật
    │   ├── sql/
    │   │   ├── doc_ma.sql          # câu đọc
    │   │   └── doi_ma/
    │   │       └── cap_ma.sql      # một câu, một annotation
    │   └── internal/
    │       └── sqlcgen/
    │           ├── read/          # code sinh cho câu đọc
    │           └── doi_ma/        # code sinh riêng cửa
    ├── don/
    │   ├── handler.go
    │   ├── service.go             # có thể chia file theo thao tác
    │   ├── repository.go
    │   ├── *_test.go
    │   ├── sql/
    │   │   ├── tao_luot_goi/*.sql
    │   │   ├── duyet/*.sql
    │   │   └── ...                # giữ nguyên các mã cửa
    │   └── internal/sqlcgen/
    │       ├── tao_luot_goi/
    │       ├── duyet/
    │       └── ...
    ├── gia/
    ├── menu/
    ├── vongdoi/
    ├── ban/
    ├── phien/
    ├── ngayban/
    ├── tratruoc/
    ├── hoadon/
    ├── ket/
    └── sanxuat/                    # áp cùng khuôn khi tới lát của gói
```

Đường thực thi đề xuất:

```text
Gin handler
  → service của cửa
    → authz.Run / RunAs
      → db.InTx
        → kiểm quyền và khai người thao tác
        → repository nhận chính pgx.Tx ấy
          → sqlcgen.New(tx).TênQuery(...)
```

Cửa con lớp `theo_cua_goi` tiếp tục nhận giao dịch từ cửa gọi. Không mở giao dịch thứ hai.

Thư mục `internal` lồng trong miền giúp ngăn miền khác import trực tiếp code sinh. Code ngoài miền phải gọi API cửa hiện hữu. Không sinh một `Queries` toàn backend để bất kỳ gói nào cũng có thể ghi mọi bảng.

**4d. `sqlc.yaml` mẫu**

Mẫu tối thiểu cho cửa đổi mã, đặt tại `sqlc.yaml` trong thư mục `be/`:

```yaml
version: "2"

sql:
  - name: qr_doi_ma
    engine: postgresql
    schema: "../db/migrations/*.up.sql"
    queries:
      - "internal/qr/sql/doi_ma/cap_ma.sql"
    gen:
      go:
        package: doima
        out: "internal/qr/internal/sqlcgen/doi_ma"
        sql_package: "pgx/v5"
        emit_interface: false
        emit_json_tags: false
        emit_prepared_queries: false
        omit_unused_structs: true
```

SQL dự kiến thêm annotation:

```sql
-- name: CapMa :one
SELECT qr_code_issue($1)
```

Mỗi cửa có một mục cấu hình riêng; các câu đọc dùng mục riêng và liệt kê file tường minh, tránh thư mục đọc bị hiểu thành cửa ghi. Code sinh không mang hợp đồng JSON; repository chuyển kiểu DB sang DTO hiện có.

Cấu hình v2, engine PostgreSQL, output Go và `sql_package: pgx/v5` được mô tả trong [tài liệu cấu hình sqlc](https://docs.sqlc.dev/en/v1.31.1/reference/config.html). sqlc có cơ chế đọc migration để dựng schema phục vụ phân tích, theo [tài liệu schema](https://docs.sqlc.dev/en/v1.31.1/howto/ddl.html).

**Mẫu chưa được chạy.** Cần chứng minh bản sqlc được ghim đọc được glob `.up.sql`, toàn bộ DDL hiện có, schema/search path `shop`, hàm `qr_code_issue` và kiểu trả về. Nếu thiếu thông tin kiểu, chỉ đề xuất ép kiểu rõ trong query sau khi đối chiếu chữ ký thật; không sửa migration hoặc lập một schema chép tay cho sqlc.

**4e. Sửa Gate 1f và Gate 1g**

**Gate 1f: giữ SQL nguồn làm nơi xác định ô và cửa.**

Không cần nhận cách gom nhiều câu vào một file. Khuôn mới vẫn là:

```text
internal/<gói>/sql/<cửa>/<câu>.sql
```

Thêm annotation sqlc không đổi quyền sở hữu. Gate tiếp tục in:

```text
bảng<TAB>loại<TAB>cột hoặc -<TAB>gói/cửa
```

Đề xuất phần sửa gồm:

1. Giữ mọi phép cấm hiện tại: câu ghi ngoài cửa, hai cửa cùng ô, bảng không nhận ra, cột SET không đọc ra, ghi ô thuộc migration, `DELETE/TRUNCATE/MERGE/COPY/CopyFrom`, mở giao dịch ngoài `internal/db`.
2. Với file đã chuyển sang sqlc, đòi đúng một annotation và một câu SQL; tên query duy nhất trong tập sinh. Dấu chấm phẩy trong chuỗi/comment không được tính thành câu.
3. Đọc khuôn cấu hình cố định: mỗi tập query ghi chỉ lấy nguồn từ **một cửa**, output đúng `internal/<gói>/internal/sqlcgen/<cửa>`. Không cho output ghi đè code tay, không cho đường dẫn thoát ra ngoài.
4. **Không bỏ qua toàn bộ file chỉ vì có nhãn “generated”.** Chỉ miễn phép báo “SQL trong Go ngoài cửa” cho hằng SQL sinh ở output hợp lệ, có nguồn tương ứng và nội dung khớp query nguồn sau chuẩn hoá annotation/comment. Phần Go còn lại vẫn được quét các cách ghi/mở giao dịch bị cấm.
5. Mọi lượt có thay đổi nguồn, cấu hình, phiên bản generator hoặc output phải chạy phép sinh lại bằng bản sqlc ghim, vào thư mục tạm, rồi so **cả tập file và nội dung**. File thiếu, dư hay sửa tay đều đỏ. Không chỉ dựa `git diff`, vì SQL và output sai có thể đã cùng được commit.
6. Phép sinh lại thuộc Gate 1/`verify.sh`; Gate 1f vẫn đọc file, không cần Go, sqlc hay database. Mỗi lần nâng sqlc phải cập nhật khuôn đọc output và test tương ứng.

Giới hạn phải ghi trong ADR: Gate 1f kiểm kê câu SQL và quyền sở hữu ô, không chứng minh toàn bộ luồng gọi Go. Test qua cửa, ranh giới `internal`, và kiểm sinh lại cùng tham gia bảo vệ; không tuyên bố riêng bộ đọc SQL chứng minh được mọi cách gọi tắt.

Các ca hồi quy bắt buộc: thêm cửa thứ hai cùng ô; giấu SQL ghi trong Go; sửa hằng SQL sinh; giả nhãn generated; cấu hình một output cho hai cửa; nguồn bị xoá nhưng output còn; generated thêm `Begin`; SQL cấm; annotation hợp lệ không làm đổi danh sách ô.

**Trường hợp `qr` cần ghi riêng:** `cap_ma.sql` hiện chỉ chứa `SELECT qr_code_issue($1)`. Vì vậy danh sách 36 ô ghi không có ô mang cửa `qr/doi_ma`; việc ghi `qr_code` thuộc hàm migration theo ADR-085 điểm 6. Chứng minh đúng khi chuyển `qr` là:

- Danh sách ô ghi trước/sau không đổi.
- Gate 1g vẫn thấy `qr/doi_ma` và lớp `chu_quan`.
- Test PostgreSQL thật chứng minh mã thay, mã cũ bị từ chối và người không có quyền không làm đổi DB.

Chỉ thử `qr` chưa chứng minh được xử lý generated SQL `INSERT/UPDATE`; phải có fixture Gate 1f và sau đó một gói có ghi trực tiếp.

**Gate 1g: đọc một khuôn đăng ký Gin hẹp.**

Đề xuất bắt đầu bằng route đầy đủ, không group:

```go
func Routes(r *gin.Engine, ...) {
    r.POST("/dining-tables/:dining_table_id/qr-code", h.doiMa)
}
```

Bộ đọc file nhận các method tường minh `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `HEAD`, `OPTIONS`; đối chiếu với tập method hợp đồng. Chuẩn hoá từng segment `:name` thành `{name}`, giữ nguyên tên:

```text
POST /dining-tables/:dining_table_id/qr-code
→ POST /dining-tables/{dining_table_id}/qr-code
```

Khuôn phải được ghi vào QC-12:

- Receiver đăng ký route được nhận diện từ chữ ký `*gin.Engine`; import alias nếu dùng phải được phân giải.
- Path là chuỗi literal tuyệt đối; hỗ trợ lời gọi xuống dòng.
- Bỏ comment và chuỗi không phải đối số route trước khi đọc; không lấy comment làm bằng chứng.
- Route động, nối chuỗi, `Group`, `Any`, `Match`, `Handle`, wildcard `*path`, receiver/alias không nhận diện được phải đỏ; không im lặng bỏ qua.
- Đếm trùng sau chuẩn hoá phải đỏ.
- Trong giai đoạn chuyển, đọc cả khuôn `ServeMux` hiện tại và Gin. Mỗi route chỉ có một nơi đăng ký, không giữ bản cũ và mới song song.
- Giữ nguyên toàn bộ phép so mã lỗi, status, tên ràng buộc, phiên bản hợp đồng và ba tập cửa–ma trận–`authz.Door`.

Test script cần có route đúng, sai method, sai tên param, route trùng, chuỗi động, group, wildcard, comment giả route, multiline, và mỗi kiểu router trong giai đoạn chuyển.

Gate tĩnh vẫn không chứng minh route được lắp vào server. Test HTTP phải dùng chính hàm lắp router; kiểm riêng redirect, dấu `/` cuối, 404/405, HEAD và body lỗi. Handler nên tiếp tục dùng decoder/`apierr` hiện có trong lát đầu để giữ thứ tự từ chối.

**4f. Kế hoạch chuyển và cách giữ gate xanh**

Trước các lát dưới, **Claude duyệt thiết kế L3 và viết ADR mới** thay lựa chọn Gin/sqlc của ADR-083; giữ nguyên yêu cầu ADR-082 và ADR-085. Không diễn giải việc chia nhỏ thành đã hạ rủi ro kiến trúc xuống L1.

Trong bảng, “bộ kiểm chung” nghĩa là: `./scripts/gate.sh` đạt, test thật qua `be-check.sh`, tên test QC-17 đạt, output sinh lại khớp, tập ô/cửa/route không đổi. Nếu DB thiếu thì lát chưa đạt, không đổi thành skip.

| Lát | Gói và mức đề xuất | File / QC / ADR chạm | Cách giữ gate xanh | Cách lùi |
|---|---|---|---|---|
| 1 | Công cụ và bộ đọc gate — **L2** | Hai script 1f/1g và `.test.sh`; `verify.sh`, `be-check.sh` nếu cần; QC-11–14,16–17; ADR mới về 083/084 | Bộ đọc nhận cả khuôn cũ/mới; fixture lỗi phải đỏ. Chưa chuyển cửa nào. | Lùi thay đổi script và cấu hình công cụ trước khi có gói phụ thuộc. |
| 2 | `db` — **L2** | `go.mod/sum`, `internal/db`; QC-11/13/15; ADR-083 | Nâng Go/pgx sau xác minh; giữ chữ ký `Open/InTx`; test vai, múi giờ và rollback. | Trả pin và code về bản nền; không đổi DB. |
| 3 | `apierr` — **L1** | `internal/apierr`; QC-14, ADR-084 | Giữ mã/status/ánh xạ; kiểm JSON không có trường mới; handler Gin dùng `c.Writer`. | Lùi adapter/helper, giữ API cũ. |
| 4 | `authz` — **L2** | `internal/authz`, query đọc/cấu hình sinh nếu chuyển; QC-13/15/16, ADR-085 | Giữ `Authenticator`, `Run/RunAs`, cùng tx và người thao tác. | Lùi nội bộ, giữ chữ ký cho bên gọi. |
| 5 | `qr` — **L2** | `internal/qr`, `sqlc.yaml`, module Gin; QC-12–14/16/17, ADR-083/085 | Hai route Gin; `TestI023_*`; đối chiếu ô ghi không đổi và sinh từ migration. | Trả đăng ký route và SQL adapter về bản cũ. |
| 6 | `menu` — **L2** | `internal/menu`, config sinh; QC-13/16/17, ADR-082/083 | Chứng minh lần đầu SQL ghi trực tiếp; so ô theo cột, test giá/menu hiện có. | Lùi gói và mục config tương ứng. |
| 7 | `gia` — **L2** | `internal/gia`, config sinh; QC-12–14/16/17 | Giữ API tính giá và DTO; chạy test giá và test ghi đơn phụ thuộc. | Lùi nội bộ và route; giữ chữ ký cũ. |
| 8 | `vongdoi` — **L2** | `internal/vongdoi`, config sinh; QC-13/16/17, ADR-082/085 | Cửa con vẫn nhận tx; chạy ca trạng thái, vết và rollback liên miền. | Lùi gói, giữ API nhận tx. |
| 9 | `ban` — **L2** | `internal/ban`, config sinh; QC-12–14/16/17 | Test dọn bàn, bàn ghép, quyền và danh sách ô. | Lùi gói và route tương ứng. |
| 10 | `phien` — **L2** | `internal/phien`, config sinh; QC-13/16/17 | Test chặn đóng phiên, cắt giữa giao dịch, đóng và gọi thêm chen nhau. | Lùi gói; không sửa các cửa gọi nó. |
| 11 | `ngayban` — **L2** | `internal/ngayban`, config sinh nếu có; QC-13/15/16/17 | Giữ nguồn thời gian và kết quả ngày bán; chạy ca tiền phụ thuộc. | Lùi nội bộ, giữ chữ ký. |
| 12 | `tratruoc` — **L2** | `internal/tratruoc`, config sinh; QC-13/16/17 | Test nhận/dùng/trả lại, số dư và rollback. | Lùi gói và config; không chạy down migration. |
| 13 | `hoadon` — **L2** | `internal/hoadon`, config sinh; QC-12–14/16/17 | Test hóa đơn, thu nợ, hoàn, dùng trả trước và ghi người thao tác. | Lùi cả gói ở mốc xanh trước lát. |
| 14 | `ket` — **L2** | `internal/ket`, config sinh; QC-12–14/16/17 | Test đầu két, đếm, đối soát; giữ nguyên mọi từ chối hiện tại. | Lùi gói và route, không chạm dữ liệu. |
| 15 | `sanxuat` — **L2** | `internal/sanxuat`, config sinh; QC-12–14/16/17 | Chạy test nổ đơn, mẻ, lùi, chuyển, ra bàn và tranh chấp từ bộ test `don`. | Lùi nội bộ, giữ API nhận tx cho `don`. |
| 16 | `don` — **L2** | `internal/don`, config sinh; QC-12–14/16/17 | Chạy toàn bộ test liên miền, idempotency, retry, rollback, HTTP. Không đổi thứ tự kiểm. | Lùi cả gói và config ở mốc xanh trước lát. |
| 17 | Lắp ứng dụng và bỏ hỗ trợ router cũ — **L2** | `cmd/server` nếu được duyệt, nơi lắp router, Gate 1g/test; QC-12/14/16, ADR-085 | Chỉ khi có xác thực thật; đủ 39 route hiện tại, không sót gói hay đăng ký hai lần. | Lùi lát lắp ghép; giữ bộ đọc song song cho tới khi ổn định. |

Mỗi hàng nghiệp vụ là một lát riêng, giữ API Go liên gói ổn định để không bắt các gói chưa chuyển phải đi theo. Test ở `don` hiện kiểm nhiều gói khác; khi đổi chữ ký đăng ký route, lát của gói được phép sửa **phần dựng router trong test bên gọi**, nhưng không sửa điều kiện nghiệp vụ để làm xanh.

Các script mới hoặc sửa `verify.sh`/`be-check.sh` trong kế hoạch **nằm ngoài scope lát 0**; Claude phải cấp scope cho lát tương ứng. QC-01/05/08 không cần đổi. Nếu nâng golang-migrate, mở lát L2 riêng sửa pin ở Compose, QC-05 và chạy bộ kiểm DB; không sửa nội dung migration.

Có một chỗ cần phối hợp trước lát 1: brief báo **F-061, phép kiểm tên test QC-17 chưa chạy khi chỉ đổi backend**, được ghi trong [backlog](/Users/monghoaivu/Desktop/code/lean_wt/BE-STACK/work/backlog.md:111). Claude cần giao xử lý hoặc xác nhận đã có lát khác xử lý; không tính quy ước tên test là đã được gate chấm chỉ vì tên đang đúng.

Rủi ro lớn nhất là parser sqlc không đọc đủ DDL/hàm, kiểu sinh làm đổi JSON/null/thời gian, router đổi cách phản hồi, và repository vô tình dùng pool ngoài tx. Chặn tương ứng bằng thử generate trên schema thật, giữ DTO/decoder hiện tại, test HTTP đối chiếu và test cắt giao dịch. Nếu một điều kiện không đạt, dừng tại mốc xanh trước gói đó; không sửa schema hay hành vi để hợp công cụ.

**5. Câu hỏi còn mở cho Claude / chủ repo**

Các điểm sau cần Claude chốt trong thiết kế, không phải xin phép tiếp tục khảo sát:

- Có duyệt cấu trúc theo miền với handler/service/repository bên trong từng miền, output sqlc riêng từng cửa như trên không?
- Có duyệt khuôn Gin ban đầu chỉ nhận path đầy đủ, không `Group`, để Gate 1g đọc chắc bằng file không?
- Có duyệt bổ sung phép sinh lại bắt buộc và khuôn kiểm generated SQL cho Gate 1f không? Đây là chi phí mà ADR-083 đã nêu khi bác sqlc.
- Giữ golang-migrate hiện tại trong đợt chuyển, hay mở lát nâng riêng sau xác minh?

**Không đề xuất mở lại luật test đỏ khi thiếu DB**; đó là luật đang có và cần giữ.

Phiếu nói cách đăng nhập còn chờ U-075, nhưng brief/backlog đã có **T-143 — triển khai đăng nhập bằng chọn tên**, tại [dòng giao việc hiện tại](/Users/monghoaivu/Desktop/code/lean_wt/BE-STACK/work/backlog.md:94). Claude cần đồng bộ lời giao cho lát dựng server; báo cáo này không kết luận thay về trạng thái U-075 và không thêm xác thực.

**6. Việc chưa xong**

Chưa xác minh được năm phiên bản qua nguồn tải; chưa tải Gin/sqlc, chưa chạy `sqlc generate`, chưa chuyển thử `qr`, chưa chạy toàn bộ gate hoặc test PostgreSQL.

Phần khảo sát và đề xuất đã có bằng chứng hiện trạng. Tính khả thi của mẫu sqlc trên toàn bộ migration và hiệu lực của hai gate sau sửa vẫn phải được chứng minh ở lát thử có mạng, sau khi Claude duyệt thiết kế.