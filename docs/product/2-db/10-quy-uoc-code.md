# Quy ước code — DBMS, cách chạy database, migration, khung test, thư mục, stack

Pha 2 · bước `P2-12` · viết 2026-09-27 (Claude Code). Owner của hàng *Quy ước code* ở `CLAUDE.md`
§2 (**ADR-035**, **ADR-039**). Lựa chọn DBMS: **ADR-055**.

**File này sở hữu:** *dựng và kiểm bằng gì* — mỗi quy ước là một mục `QC-XX` gồm bốn ô: quy ước ·
hậu quả nếu làm khác · phép kiểm · nguồn. Mục đầu tiên là DBMS + phiên bản, vì năm lát lược đồ
`P2-04`…`P2-08` chờ đúng mục ấy (**ADR-053** luật 1).

**File này KHÔNG sở hữu:**
- **cất bằng gì** — tiền, mốc, khoá, đặt tên cột, trạng thái, không xoá cứng, văn bản:
  [`01-quy-uoc-du-lieu.md`](01-quy-uoc-du-lieu.md). File này chỉ đặt **tên kiểu** PostgreSQL cho
  các quy ước ấy (`QC-04`);
- **tên bảng, tên cột, ràng buộc của một lát** — file migration thắng, file lát giữ ý định
  (**ADR-053** luật 2);
- **hợp đồng API, route, component** — pha 3, pha 4 (**ADR-035**);
- **cách triển khai lên máy chạy thật** (máy chủ, sao lưu, HTTPS) — chưa có owner; yêu cầu khôi phục ở
  `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §8 (YC-21, ADR-057), cơ chế giao pha 5
  qua T-109 (`work/backlog.md`).

---

## 0. Cách đọc — và cách chạy phép kiểm

**Mỗi mục có mã `QC-XX`**, không đánh lại khi thêm mục. **Nguồn** của một mục là một trong ba:
**owner** (dịch một câu đã chốt ở chỗ khác) · **giao cho phiên 2026-09-27** (chủ repo giao việc chọn,
chưa đọc lại lựa chọn — chỉ `QC-01`) · **phiên chọn 2026-09-27** (lựa chọn thiết kế của lượt này,
chưa có lời chủ repo — đổi được, nhưng sửa ở đây kèm hậu quả mới trước khi code làm khác).

**Phép kiểm** của một mục là một khối `sql` (ra **0 dòng** khi đạt) hoặc một khối `sh` (in **rỗng**
khi đạt), hoặc một hàm có tên trong `scripts/db-check.sh`. Script ấy đọc **thẳng** mọi khối `sql` ·
`sh` nằm dưới một tiêu đề `QC-XX` ở đây và `QD-XX` ở `01-quy-uoc-du-lieu.md`, thay tham số từ bảng
§0 của file ấy, rồi chạy trên một cơ sở dữ liệu **riêng và rỗng** dựng từ số 0 (`QC-07`). Vì thế:
khối nào không phải phép kiểm thì **không** được rào bằng `sql` hay `sh` — ví dụ dùng rào `text`.

---

## 1. Database — `QC-01`…`QC-03`

### QC-01 — DBMS là PostgreSQL, phiên bản chính 17

- **Quy ước:** mọi môi trường — máy phát triển, bộ kiểm, máy chạy thật — dùng PostgreSQL **17**
  (phiên bản chính; bản vá mới nhất của 17). Lên phiên bản chính khác là một ADR mới, không phải một
  dòng sửa image.
- **Hậu quả nếu làm khác:** cách dựng một khoá duy nhất chỉ áp cho vài trạng thái, việc ràng buộc
  kiểm có được thực thi hay không, và giới hạn của kiểu mốc **đổi theo DBMS và phiên bản** (bằng
  chứng dự án cũ: `work/proposals/from_old_project/data_base/nghien-cuu.md` §1.3 · §2.7). Môi
  trường test chạy một phiên bản, máy thật chạy phiên bản khác ⇒ một ràng buộc đã chứng minh
  *từ chối* ở test có thể không tồn tại ở máy thật.
- **Phép kiểm:**
  ```sql
  SELECT current_setting('server_version') AS phien_ban_sai
  WHERE current_setting('server_version_num')::int / 10000 <> 17;
  ```
- **Nguồn:** giao cho phiên 2026-09-27 — chủ repo: *"DBMS cho P2-12: làm theo đề xuất của bạn"*.
  Lý do chọn và các phương án bị loại (gồm MySQL 8.4 của `master_plan/prompt-fullstack.md` §3.4):
  **ADR-055**.

### QC-02 — Cơ sở dữ liệu: UTF8, cách so mặc định `C`, có cách so tiếng Việt; chạy bằng `compose.yaml`

- **Quy ước:** cơ sở dữ liệu `banhcuon` mã hoá **UTF8**, cách so mặc định **`C`** (so từng byte).
  Văn bản cho người đọc khai cách so tiếng Việt **tường minh** ở từng cột (`QD-60`), nên collation
  `vi-x-icu` phải có. Database của máy phát triển và của bộ kiểm chạy bằng service `db` trong
  `compose.yaml` ở gốc repo, image ghim `postgres:17`, cổng máy `127.0.0.1:5433` (đổi bằng biến
  `DB_PORT`). Múi giờ mặc định của server **để nguyên UTC** — lý do ở `QC-06`.
- **Hậu quả nếu làm khác:** mặc định là một cách so theo ngôn ngữ thì mọi cột mã và chuỗi băm quên
  khai `C` sẽ so theo ngôn ngữ (`QD-61`); mặc định `C` thì cột văn bản quên khai chỉ **sắp sai thứ
  tự** — thấy được trên màn hình, không làm hai mã va nhau. Thiếu `vi-x-icu` thì migration đầu tiên
  khai cột tên món hỏng. Cổng máy `5432` hay đã có một PostgreSQL khác giữ (máy phát triển hôm nay
  đúng như vậy).
- **Phép kiểm:**
  ```sql
  SELECT datname, pg_encoding_to_char(encoding) AS ma_hoa, datcollate
  FROM pg_database
  WHERE datname = current_database()
    AND (pg_encoding_to_char(encoding) <> 'UTF8' OR datcollate <> 'C'
         OR NOT EXISTS (SELECT 1 FROM pg_collation WHERE collname = 'vi-x-icu'));
  ```
  ```sh
  grep -qx '    image: postgres:17' compose.yaml || echo "compose.yaml không ghim image postgres:17"
  ```
- **Nguồn:** phiên chọn 2026-09-27, dựng để `QD-60` · `QD-61` và tham số `:collation_mac_dinh`
  đúng.

### QC-03 — Hai vai: `shop_owner` dựng lược đồ, `shop_app` ghi dữ liệu và không xoá được

- **Quy ước:** schema `shop` (tham số `:schema`) thuộc vai `shop_owner`; mọi migration chạy dưới vai
  ấy. Hệ thống ghi bằng vai `shop_app` (tham số `:vai_ung_dung`), **không** phải chủ bảng, **không**
  phải superuser. Mỗi bảng `shop_owner` tạo trong `shop` **tự** cấp cho `shop_app` đúng ba quyền đọc
  · thêm · sửa — không xoá, không xoá toàn bảng (`QD-50`). Vai, schema và mặc định cấp quyền dựng một
  lần ở `db/init/001-vai-va-schema.sql`. Bảng kỹ thuật cần xoá (`:bang_ky_thuat`) thì migration của
  nó cấp thêm, kèm lý do ở file lát.
- **Hậu quả nếu làm khác:** hệ thống ghi bằng vai chủ bảng thì `QD-50` không giữ gì — chủ bảng xoá
  được mọi thứ dù không ai cấp. Cấp quyền bằng tay ở từng migration thì lát nào quên là lát ấy **không
  ghi được**, hoặc tệ hơn, lát nào chép nhầm là lát ấy **xoá được**.
- **Phép kiểm:**
  ```sql
  SELECT 'schema ' || :schema || ' phải thuộc shop_owner' AS loi
  WHERE NOT EXISTS (SELECT 1 FROM pg_namespace n JOIN pg_roles r ON r.oid = n.nspowner
                    WHERE n.nspname = :schema AND r.rolname = 'shop_owner')
  UNION ALL
  SELECT :vai_ung_dung || ' không được là superuser'
  FROM pg_roles WHERE rolname = :vai_ung_dung AND rolsuper
  UNION ALL
  SELECT 'bảng ' || tablename || ' phải thuộc shop_owner'
  FROM pg_tables WHERE schemaname = :schema AND tableowner <> 'shop_owner'
  UNION ALL
  SELECT 'bảng mới trong schema phải tự cấp đúng đọc · thêm · sửa cho ' || :vai_ung_dung
  WHERE NOT EXISTS (SELECT 1 FROM pg_default_acl d JOIN pg_namespace n ON n.oid = d.defaclnamespace
                    WHERE n.nspname = :schema AND d.defaclobjtype = 'r'
                      AND (:vai_ung_dung || '=arw/shop_owner') = ANY (d.defaclacl::text[]));
  ```
  Vế *không xoá* trên từng bảng đã có là phép kiểm của `QD-50`.
- **Nguồn:** owner cho vế *không xoá* — `QD-50`; hai vai và mặc định cấp quyền là phiên chọn
  2026-09-27.

---

## 2. Kiểu — `QC-04`

### QC-04 — Mỗi vai trò cột của `01-quy-uoc-du-lieu.md` có đúng một kiểu PostgreSQL

- **Quy ước:**

  | Vai trò (mục quy ước dữ liệu) | Kiểu | Vì sao kiểu này |
  |---|---|---|
  | khoá chính `id` (`QD-10`) | `bigint GENERATED ALWAYS AS IDENTITY` | database sinh; ghi tay giá trị bị từ chối, nên không ai đặt khoá có nghĩa |
  | khoá ngoại `_id` (`QD-11`) | `bigint` | cùng kiểu với khoá nó trỏ tới |
  | tiền `_vnd` (`QD-20`) | `bigint` | số nguyên, `numeric_scale` = 0; không kiểu số thực, không `money` (kiểu `money` đổi cách in theo cấu hình máy) |
  | mốc `_at` (`QD-30`) | `timestamptz` | (a) cất **một thời điểm tuyệt đối**, in ra theo múi giờ của phiên — không mơ hồ; (b) phạm vi tới năm 294276, **không** có giới hạn 2038; (c) độ phân giải micro giây |
  | ngày bán `sale_date` (`QD-31`) | `date` | ngày lịch, không giờ |
  | văn bản cho người đọc (`QD-60`) | `text COLLATE "vi-x-icu"` | không giới hạn độ dài giả; giới hạn thật (nếu owner có) là một ràng buộc kiểm có tên |
  | mã `code` · `_code` · `status` · `_hash` (`QD-61`, `QD-40`) | `text` (cách so mặc định `C`) | so từng byte, phân biệt hoa thường |
  | số lượng, số đếm | `integer` | số nguyên; không âm là ràng buộc kiểm của lát |
  | cờ có/không | `boolean` | — |

  Kiểu khác (`numeric`, `jsonb`, mảng, `varchar`…) chỉ vào lược đồ khi một dòng mới được thêm vào
  bảng trên **trước**, kèm lý do.
- **Hậu quả nếu làm khác:** lát này cất tiền bằng `integer`, lát kia bằng `bigint`, và phép cộng
  doanh thu qua lát (`I-014`) đổi kiểu ngầm ở giữa. Một cột mốc bằng `timestamp` (không múi giờ) là
  *giờ đồng hồ trần* mà `QD-30` cấm. `varchar(n)` đặt một giới hạn không ai chốt, và cắt tên món
  bằng một lời từ chối không ai hiểu.
- **Phép kiểm:**
  ```sql
  SELECT table_name, column_name, data_type
  FROM information_schema.columns
  WHERE table_schema = :schema
    AND (   data_type NOT IN ('bigint', 'integer', 'boolean', 'date', 'text',
                              'timestamp with time zone')
         OR (column_name = 'id' AND (data_type <> 'bigint' OR is_identity <> 'YES'
                                     OR identity_generation <> 'ALWAYS'))
         OR (column_name LIKE '%!_id'  ESCAPE '!' AND data_type <> 'bigint')
         OR (column_name LIKE '%!_vnd' ESCAPE '!' AND data_type <> 'bigint'));
  ```
- **Nguồn:** owner cho điều kiện — `QD-10` · `QD-20` · `QD-30` · `QD-60` · `QD-61`; tên kiểu là phiên
  chọn 2026-09-27.

---

## 3. Migration — `QC-05`

### QC-05 — Migration: golang-migrate, `db/migrations/`, tên theo mốc giờ, chỉ đi tới

- **Quy ước:**
  - **Công cụ:** golang-migrate **v4.18.3**, chạy bằng service `migrate` trong `compose.yaml`
    (`docker compose run --rm migrate`) — không cần cài gì lên máy ngoài Docker.
  - **Thư mục:** `db/migrations/`. Lược đồ vào schema `shop`; bảng ghi phiên bản của công cụ nằm ở
    `public.schema_migrations`, ngoài tầm các phép kiểm `QD-XX`.
  - **Tên file:** mốc giờ tạo file dạng `YYYYMMDDHHMMSS`, một dấu gạch dưới, mô tả snake_case ASCII,
    đuôi `.up.sql` — ví dụ `20260101000000_vi_du.up.sql`. Năm lát
    chạy **song song** (`P2-04`…`P2-08`): số thứ tự tăng dần sẽ va nhau, mốc giờ thì không.
  - **Chỉ đi tới:** không file `.down.sql`. Sửa một lược đồ đã commit là **một migration mới**;
    file migration đã vào `HEAD` thì không sửa, không xoá.
  - **Một file là một giao dịch:** không viết `BEGIN` · `COMMIT` trong file. Công cụ gửi cả file
    một lượt, PostgreSQL chạy nó trong một giao dịch ngầm — lỗi ở câu thứ năm thì bốn câu trước
    cũng không còn.
  - Ràng buộc đặt tên tường minh theo `QC-10`.
- **Hậu quả nếu làm khác:** hai lát cùng lấy số `000004` thì một trong hai **không bao giờ chạy**,
  và công cụ không báo. File `.down.sql` của một lát lược đồ là một lệnh xoá bảng nằm sẵn cạnh dữ
  liệu bán hàng thật — đúng đường mà `QD-50` đóng. Sửa một migration đã chạy ở máy khác thì hai máy
  có hai lược đồ khác nhau dưới **cùng một** số phiên bản, và **ADR-053** luật 2 (*migration thắng*)
  không còn biết bản nào thắng.
- **Phép kiểm:**
  ```sh
  ls -A db/migrations | grep -Ev '^([0-9]{14}_[a-z0-9_]+\.up\.sql|\.gitkeep)$'
  git diff --name-only --diff-filter=MDR HEAD -- db/migrations
  ```
  Dòng đầu: tên sai khuôn, hoặc có file `.down.sql`. Dòng sau: file migration đã commit bị sửa,
  xoá hay đổi tên.
- **Nguồn:** công cụ theo `master_plan/prompt-fullstack.md` §3.4 (bản xuất khẩu, **không** sở hữu
  gì — **ADR-035** luật 3; đọc như đề xuất); thư mục, tên và luật chỉ đi tới là phiên chọn
  2026-09-27. Migration thắng tài liệu: **ADR-053** luật 2.

---

## 4. Múi giờ kết nối — `QC-06`

### QC-06 — Mọi kết nối đặt múi giờ của quán tường minh; server để UTC

- **Quy ước:** mọi kết nối — bộ kiểm, test, backend chạy thật — đặt múi giờ phiên bằng **đúng** giá
  trị ở `master_plan/shop-facts.md` §1, **tường minh** ở cấu hình kết nối: bộ kiểm dùng biến môi
  trường `PGTZ` (đọc từ `shop-facts.md`, không chép); backend đặt tham số kết nối `TimeZone`. Múi giờ
  mặc định của server **cố ý để UTC**.
- **Hậu quả nếu làm khác:** server đặt sẵn múi giờ của quán thì một kết nối **quên** đặt vẫn đúng
  — cho tới ngày ai đó dựng lại server bằng mặc định, và mọi mốc lệch 7 tiếng cùng lúc
  (`QD-32`; dự án cũ lệch đúng như vậy chỉ trong test, `nghien-cuu.md` §4.4). Để server UTC thì kết
  nối quên đặt lộ ra ngay ở lần chạy bộ kiểm đầu tiên.
- **Phép kiểm:** hàm `qd32` trong `scripts/db-check.sh` — in múi giờ ở `shop-facts.md` §1 cạnh múi
  giờ kết nối thật sự đọc ra, hai dòng phải giống hệt.
  **Chỗ trống có tên:** kết nối của backend chạy thật chưa có. Lượt pha 3 tạo kết nối ấy thêm một
  lệnh in `SHOW TimeZone` qua **chính** kết nối đó vào bộ kiểm.
- **Nguồn:** owner — `QD-32`; để server UTC là phiên chọn 2026-09-27.

---

## 5. Khung test — `QC-07`

### QC-07 — Khung test database: `scripts/db-check.sh` + `db/tests/*.sql`, Gate 1 gọi nó

- **Quy ước:**
  - `scripts/db-check.sh` là **một** lệnh chạy cả bộ: dựng một database riêng và rỗng (compose
    project `banhcuon_check`, cổng ngẫu nhiên, gỡ sạch khi xong), chạy mọi migration từ số 0, chạy
    mọi phép kiểm `QD-XX` · `QC-XX`, rồi chạy từng file `db/tests/*.sql`. Không có Docker, hay
    database không lên ⇒ **FAIL**, không bỏ qua.
  - **File test:** `db/tests/<mã>_<mô tả snake_case>.sql`, `<mã>` là mã mệnh đề viết thường liền —
    `i001`, `yc05`, `qd50`. Script bọc mỗi file trong `BEGIN` … `ROLLBACK`. Một test *từ chối* dựng
    trạng thái sai trong một khối `DO`, bắt **đúng** lỗi mong đợi và in lời từ chối nguyên văn; không
    bị từ chối thì tự ném lỗi:

    ```text
    DO $$
    BEGIN
      -- dựng trạng thái sai của I-0xx ở đây
      RAISE EXCEPTION 'I-0xx: database KHÔNG từ chối';
    EXCEPTION WHEN unique_violation THEN
      RAISE NOTICE 'I-0xx bị từ chối: %', SQLERRM;
    END $$;
    ```

    Dòng `NOTICE` là **lời từ chối nguyên văn** mà `P2-04`…`P2-08` dán vào *Bàn giao*.
  - **Gate 1:** `scripts/verify.sh` gọi `scripts/db-check.sh` khi có thay đổi dưới `db/`, ở
    `compose.yaml`, `scripts/db-check.sh` hay `docs/product/2-db/`. Lượt **chỉ** đổi tài liệu thì
    `verify.sh` không chạy (`CLAUDE.md` §5), nên lượt chỉ sửa một câu kiểm trong `.md` phải tự chạy
    `./scripts/db-check.sh`.
- **Hậu quả nếu làm khác:** một bộ kiểm cần ai đó nhớ gọi là một bộ kiểm không cổng nào đọc
  (`work/findings.md` **F-007**). Chạy trên database làm việc thay vì database rỗng thì một ràng
  buộc chỉ đúng vì dữ liệu cũ tình cờ đạt sẽ xanh nhầm; và migration không bao giờ được chứng minh
  là dựng nổi lược đồ **từ số 0**.
- **Phép kiểm:**
  ```sh
  grep -q 'scripts/db-check.sh' scripts/verify.sh || echo "scripts/verify.sh không gọi scripts/db-check.sh"
  ls -A db/tests | grep -Ev '^([a-z]+[0-9]{2,3}_[a-z0-9_]+\.sql|\.gitkeep)$'
  ```
- **Nguồn:** owner cho việc Gate 1 phải gọi — `P2-12` bước 6, **F-007**; bộ kiểm dựng database rỗng
  là **ADR-053** luật 3; tên file và khuôn `DO` là phiên chọn 2026-09-27.

---

## 6. Thư mục và stack ngoài database — `QC-08`…`QC-09`

### QC-08 — Cấu trúc thư mục code ở gốc repo

- **Quy ước:**

  | Đường dẫn | Chứa gì | Ai tạo |
  |---|---|---|
  | `compose.yaml` | database + công cụ migration cho máy phát triển và bộ kiểm | `P2-12` |
  | `db/init/` | dựng vai, schema, mặc định cấp quyền — chạy một lần khi database khởi tạo | `P2-12` |
  | `db/migrations/` | lược đồ, theo `QC-05` | `P2-04`…`P2-08` |
  | `db/tests/` | test database, theo `QC-07` | `P2-04`…`P2-08` · `P2-11` |
  | `be/` | backend | pha 3 |
  | `fe/` | frontend | pha 4 |

  Không đặt code ở chỗ khác mà không thêm một dòng vào bảng này trước.
- **Hậu quả nếu làm khác:** phiên đầu tiên của pha 3 đặt backend ở gốc repo, phiên của pha 4 đặt
  frontend trong một thư mục con của nó, và `scripts/verify.sh` — đang tìm `go.mod` · `package.json`
  **ở gốc** — gọi nhầm hoặc không gọi gì.
- **Phép kiểm:**
  ```sh
  for d in db/init db/migrations db/tests; do [ -d "$d" ] || echo "thiếu thư mục $d"; done
  ```
- **Nguồn:** phiên chọn 2026-09-27.

### QC-09 — Stack ngoài database: Go ở `be/`, Next.js + TypeScript ở `fe/`

- **Quy ước:** backend viết bằng **Go**, frontend bằng **Next.js** + **TypeScript** trên Node **24
  LTS** — theo `master_plan/prompt-fullstack.md` §3.4 (chủ repo viết 2026-08-31). Phiên bản ghim ở
  `be/go.mod` và `fe/package.json` **lúc pha 3 · pha 4 tạo chúng**, không ở đây — chưa có dòng code
  nào để ghim.
- **Hậu quả nếu làm khác:** pha 3 mở ra không có ngôn ngữ nào đã nói, và phiên đầu tiên chọn theo
  sở thích của nó (**ADR-039**, lý do hàng *Quy ước code* tồn tại).
- **Phép kiểm:**
  ```sh
  [ ! -e be ] || [ -f be/go.mod ] || echo "be/ có mà không có be/go.mod"
  [ ! -e fe ] || [ -f fe/package.json ] || echo "fe/ có mà không có fe/package.json"
  ```
  **Chỗ trống có tên:** `scripts/verify.sh` hôm nay chỉ gọi Go và Node khi `go.mod` ·
  `package.json` nằm **ở gốc**. Lượt pha 3 tạo `be/go.mod` sửa `verify.sh` trong **cùng** lượt;
  thư viện web, cách truy cập database từ Go và khung test frontend chốt ở pha 3 · pha 4, dòng mới
  vào file này.
- **Nguồn:** owner — `master_plan/prompt-fullstack.md` §3.4 cho ngôn ngữ; §3.4 là bản xuất khẩu
  (**ADR-035** luật 3), và câu *"MySQL 8.4"* của chính khối ấy đã bị thay bởi `QC-01` — nên các phần
  còn lại của §3.4 **chưa** được chủ repo đọc lại sau ngày ấy.

---

## 7. Đặt tên trong database — `QC-10`

Tên bảng, tên cột và hậu tố vai trò thuộc `01-quy-uoc-du-lieu.md` `QD-01`…`QD-03`. Mục này chỉ thêm
tên **ràng buộc** và **chỉ mục**.

### QC-10 — Ràng buộc và chỉ mục mang tên đọc được: `<bảng>_<ý>_<loại>`

- **Quy ước:** mỗi ràng buộc đặt tên tường minh, bắt đầu bằng tên bảng, kết thúc bằng loại: `pkey`
  (khoá chính) · `key` (khoá duy nhất, kể cả khoá duy nhất chỉ áp cho vài trạng thái) · `fkey` (khoá
  ngoại) · `check` (điều kiện kiểm) · `excl` (loại trừ). Chỉ mục không duy nhất kết thúc bằng `idx`.
  Phần giữa nói **ý** bằng tiếng Anh snake_case — ví dụ `_one_unpaid_session_` thay vì tên cột.
- **Hậu quả nếu làm khác:** lời từ chối của database in **tên ràng buộc** — đó là thứ `P2-04` bước 6
  dán làm bằng chứng, và là thứ backend pha 3 đọc để biết luật nào vừa chặn. Tên tự sinh kiểu
  `x_y_check1` không nói luật nào, nên bằng chứng không đọc được và backend phải đoán.
- **Phép kiểm:**
  ```sql
  SELECT r.relname AS bang, c.conname AS rang_buoc
  FROM pg_constraint c
  JOIN pg_class r     ON r.oid = c.conrelid
  JOIN pg_namespace n ON n.oid = c.connamespace
  WHERE n.nspname = :schema AND c.contype IN ('p', 'u', 'f', 'c', 'x')
    AND (   c.conname NOT LIKE r.relname || '!_%' ESCAPE '!'
         OR c.conname !~ '^[a-z][a-z0-9_]*_(pkey|key|fkey|check|excl)$')
  UNION ALL
  SELECT tablename, indexname
  FROM pg_indexes
  WHERE schemaname = :schema
    AND (   indexname NOT LIKE tablename || '!_%' ESCAPE '!'
         OR indexname !~ '^[a-z][a-z0-9_]*_(pkey|key|excl|idx)$');
  ```
- **Nguồn:** phiên chọn 2026-09-27.

---

## 8. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2-04`…`P2-08` | `QC-04` kiểu · `QC-05` tên và luật migration · `QC-07` khuôn test *từ chối* · `QC-10` tên ràng buộc; chạy `./scripts/db-check.sh`, dán output vào *Bàn giao* |
| `P2-09` | `QC-05` — thư mục và khuôn tên mà lệnh đối chiếu tên bảng `.md` ↔ migration đọc |
| `P2-11` | `QC-07` — bộ kiểm để gom phép so `I-0xx` và chứng minh từng phép `QD-XX` biết kêu |
| pha 3 | `QC-06` chỗ trống kết nối backend · `QC-09` chỗ trống `verify.sh` và thư viện |
