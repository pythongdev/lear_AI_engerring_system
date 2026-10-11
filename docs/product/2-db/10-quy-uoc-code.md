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
  | bản chụp một dòng `_image` (`QD-03`) — *thêm 2026-09-28, `P2-08`* | `jsonb` | vết cập nhật (`I-018`) giữ bản trước và bản sau của **mọi** bảng trong một bảng vết: một kiểu mang được một dòng bất kỳ, so được bằng `=`, đọc từng ô bằng `->>`. Chỉ cột hậu tố `_image` được dùng nó |
  | lượng người gõ, có thể lẻ `_measure` (`QD-03`) — *thêm 2026-09-30, `P2A-02`* | `numeric` (không khai độ chính xác) | sổ nguyên liệu giữ **đúng con số người gõ** (`quality/invariants.md` `I-025` · `I-026`): hàng mua theo cân có số lẻ, và `integer` buộc người gõ tự đổi sang đơn vị nhỏ hơn — đúng phép quy đổi máy không được làm. Số thực dấu phẩy động cộng dồn ra phần lẻ không ai gõ; `numeric(p,s)` làm tròn im lặng con số vượt `s`. Không âm và hữu hạn là ràng buộc kiểm của lát. Chỉ cột hậu tố `_measure` được dùng nó; **tiền không bao giờ** (`QD-20`) |

  Kiểu khác (mảng, `varchar`, số thực…) chỉ vào lược đồ khi một dòng mới được thêm vào
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
                              'timestamp with time zone', 'jsonb', 'numeric')
         OR (data_type = 'jsonb') <> (column_name LIKE '%!_image' ESCAPE '!')
         OR (data_type = 'numeric') <> (column_name LIKE '%!_measure' ESCAPE '!')
         OR (column_name = 'id' AND (data_type <> 'bigint' OR is_identity <> 'YES'
                                     OR identity_generation <> 'ALWAYS'))
         OR (column_name LIKE '%!_id'  ESCAPE '!' AND data_type <> 'bigint')
         OR (column_name LIKE '%!_vnd' ESCAPE '!' AND data_type <> 'bigint'));
  ```
- **Nguồn:** owner cho điều kiện — `QD-10` · `QD-20` · `QD-30` · `QD-60` · `QD-61`; tên kiểu là phiên
  chọn 2026-09-27. Dòng `_measure` là phiên chọn 2026-09-30 (`P2A-02`, `docs/decisions.md`
  **ADR-071**) — chủ quán chưa nói con số gõ vào có lẻ hay không; kiểu này nhận cả hai.

---

## 3. Migration — `QC-05`

### QC-05 — Migration: golang-migrate, `db/migrations/`, tên theo mốc giờ, mỗi bước xuôi một bước lùi

- **Quy ước:**
  - **Công cụ:** golang-migrate **v4.20.1** (image `migrate/migrate`; chủ repo duyệt 2026-10-10, **ADR-093**
    điểm 1; `compose.yaml` lên bản này ở `T-150`, 2026-10-11), chạy bằng service `migrate` trong `compose.yaml`
    (`docker compose run --rm migrate`, thêm lệnh con như `down 1` · `version` · `force <số>`) —
    không cần cài gì lên máy ngoài Docker.
  - **Thư mục:** `db/migrations/`. Lược đồ vào schema `shop`; bảng ghi phiên bản của công cụ nằm ở
    `public.schema_migrations`, ngoài tầm các phép kiểm `QD-XX`.
  - **Tên file:** mốc giờ tạo file dạng `YYYYMMDDHHMMSS`, một dấu gạch dưới, mô tả snake_case ASCII,
    đuôi `.up.sql` — ví dụ `20260101000000_vi_du.up.sql`. Năm lát
    chạy **song song** (`P2-04`…`P2-08`): số thứ tự tăng dần sẽ va nhau, mốc giờ thì không.
  - **Mỗi `.up.sql` có đúng một `.down.sql`** cùng tên, gỡ **đúng** thứ bước xuôi dựng — không hơn,
    không kém. *(Đổi 2026-09-29 ở `P2-09`, **ADR-065**; trước đó mục này cấm file lùi.)* File lùi
    mở đầu bằng **khoá chặn**: bảng sắp gỡ có dòng, hay cột ghi sắp gỡ có giá trị ⇒ từ chối, không gỡ
    gì. Luật, thứ tự và cách gỡ một lệnh hỏng: [`07-thu-tu-migration.md`](07-thu-tu-migration.md).
  - **Sửa một lược đồ đã commit là một migration mới** — kể cả khi muốn *lùi* một bước đã có dữ liệu:
    file lùi chỉ gỡ chỗ còn rỗng. File migration đã vào `HEAD` thì không sửa, không xoá.
  - **Một file là một giao dịch:** không viết `BEGIN` · `COMMIT` trong file. Công cụ gửi cả file
    một lượt, PostgreSQL chạy nó trong một giao dịch ngầm — lỗi ở câu thứ năm thì bốn câu trước
    cũng không còn (thí nghiệm 2026-09-29: `07-thu-tu-migration.md` §3).
  - Ràng buộc đặt tên tường minh theo `QC-10`.
- **Hậu quả nếu làm khác:** hai lát cùng lấy số `000004` thì một trong hai **không bao giờ chạy**,
  và công cụ không báo. Một bước không có file lùi thì lần xuôi đầu tiên hỏng *về nghĩa* trên máy
  thật (chạy xong nhưng sai) không có đường về ngoài sửa tay. Một file lùi **không** có khoá chặn là
  một lệnh xoá bảng nằm sẵn cạnh dữ liệu bán hàng thật — đúng đường mà `QD-50` đóng. Sửa một
  migration đã chạy ở máy khác thì hai máy có hai lược đồ khác nhau dưới **cùng một** số phiên bản,
  và **ADR-053** luật 2 (*migration thắng*) không còn biết bản nào thắng.
- **Phép kiểm:**
  ```sh
  ls -A db/migrations | grep -Ev '^([0-9]{14}_[a-z0-9_]+\.(up|down)\.sql|\.gitkeep)$'
  for f in db/migrations/*.up.sql; do [ -f "${f%.up.sql}.down.sql" ] || echo "thiếu đường lùi: $f"; done
  for f in db/migrations/*.down.sql; do [ -f "${f%.down.sql}.up.sql" ] || echo "lùi mà không có xuôi: $f"; done
  grep -L 'đường lùi từ chối' db/migrations/*.down.sql
  git diff --name-only --diff-filter=MDR HEAD -- db/migrations
  grep -Eq '^[[:space:]]*image: migrate/migrate:v4\.20\.1$' compose.yaml || echo "compose.yaml không ghim image migrate/migrate:v4.20.1"
  ```
  Dòng đầu: tên sai khuôn. Hai dòng sau: một bước thiếu nửa kia. Dòng thứ tư: file lùi không có khoá
  chặn. Dòng cuối: file migration đã commit bị sửa, xoá hay đổi tên. File lùi gỡ **đúng** thứ bước
  xuôi dựng hay không thì một lệnh `sh` không chấm được: `scripts/db-check.sh` xuôi từng bước, lùi
  từng bước về số không, và so lược đồ sau mỗi lần lùi với ảnh chụp trước bước ấy. Dòng sau cùng: bản
ghim của công cụ.
- **Nguồn:** bản v4.20.1 chủ repo duyệt 2026-10-10 (**ADR-093**); công cụ theo `master_plan/prompt-fullstack.md` §3.4 (bản xuất khẩu, **không** sở hữu
  gì — **ADR-035** luật 3; đọc như đề xuất); thư mục, tên là phiên chọn 2026-09-27; mỗi bước một file
  lùi có khoá chặn là phiên chọn 2026-09-29 (**ADR-065**) theo yêu cầu của `P2-09`. Migration thắng
  tài liệu: **ADR-053** luật 2.

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
  Kết nối của backend (từ 2026-10-06, `P3-03`): test `TestQC15_` in `SHOW TimeZone` đọc qua
  **chính** hàm kết nối của backend cạnh múi giờ ở `shop-facts.md` §1, hai giá trị phải bằng nhau —
  `QC-15`, chạy bằng `scripts/be-check.sh` (`QC-16`).
- **Nguồn:** owner — `QD-32`; để server UTC là phiên chọn 2026-09-27.

---

## 5. Khung test — `QC-07`

### QC-07 — Khung test database: `scripts/db-check.sh` + `db/tests/*.sql`, Gate 1 gọi nó

- **Quy ước:**
  - `scripts/db-check.sh` là **một** lệnh chạy cả bộ: dựng một database riêng và rỗng (compose
    project `banhcuon_check_{PID}…` riêng mỗi lần, cổng ngẫu nhiên; chỉ gỡ của mình khi xong,
    rác của lần chạy đã chết được lần sau dọn), chạy mọi migration từ số 0, chạy
    mọi phép kiểm `QC-XX`, rồi từng file `db/tests/*.sql`, dữ liệu mồi, và bộ đối chiếu
    `scripts/reconcile.sh` — nhóm `I-0xx` cùng nhóm quy ước `QD-XX` — kèm phần chứng minh biết kêu
    ở `db/reconcile/proof/` (`P2-11`, **ADR-066**, 2026-09-30); cuối cùng ba scenario nghiệm thu ở
    `db/scenario/` diễn trên database ấy, mỗi bước một giao dịch COMMIT, đọc lại ở kết nối khác, bộ
    đối chiếu chạy lại trên ngày vừa diễn, và mỗi mã `YC` được chấm hai câu (`P2-13`, **ADR-067**,
    2026-09-30). Không có Docker, hay database không lên ⇒ **FAIL**, không bỏ qua.
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
    `compose.yaml`, `scripts/db-check.sh`, `scripts/reconcile.sh` hay `docs/product/2-db/`. Lượt **chỉ** đổi tài liệu thì
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
  | `db/reconcile/` | bộ đối chiếu chạy sau khi đóng quán — một file câu một mệnh đề, `qd.sql` cho nhóm quy ước, `prelude.sql` bảng và hàm tạm; `proof/` ngày bán mẫu và lỗi cài (`09-doi-chieu-bat-bien.md`) | `P2-11` |
  | `db/scenario/` | ba scenario nghiệm thu diễn qua lược đồ, phần đọc lại và phép chấm `YC` — chạy ở bước 7 của `scripts/db-check.sh` (`11-cong-chat-luong-pha-2.md`, **ADR-067**) | `P2-13` |
  | `db/seed/` | bộ dựng dữ liệu mồi — đọc `master_plan/shop-facts.md` lúc chạy, in SQL; không cất con số nào của quán (`08-du-lieu-moi.md`) | `P2-10` |
  | `Makefile` | lệnh tắt cho database làm việc trên máy phát triển — chỉ gọi lại `compose.yaml` và `db/seed/`, không mang cấu hình riêng; bộ kiểm không đi qua nó | chủ repo yêu cầu 2026-09-29 |
  | `be/` | backend — cấu trúc bên trong theo `QC-14` | `P3-03` |
  | `fe/` | frontend | pha 4 |

  Không đặt code ở chỗ khác mà không thêm một dòng vào bảng này trước.
- **Hậu quả nếu làm khác:** phiên đầu tiên của pha 3 đặt backend ở gốc repo, phiên của pha 4 đặt
  frontend trong một thư mục con của nó, và `scripts/verify.sh` — đang tìm `go.mod` · `package.json`
  **ở gốc** — gọi nhầm hoặc không gọi gì.
- **Phép kiểm:**
  ```sh
  for d in db/init db/migrations db/tests db/seed db/reconcile db/scenario; do [ -d "$d" ] || echo "thiếu thư mục $d"; done
  ```
- **Nguồn:** phiên chọn 2026-09-27; dòng `db/seed/` thêm 2026-09-28 (`P2-10`); dòng `db/reconcile/`
  thêm 2026-09-30 (`P2-11`); dòng `db/scenario/` thêm 2026-09-30 (`P2-13`).

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
  Từ 2026-10-06 (`P3-03`) `scripts/verify.sh` dựng và kiểm Go trong `be/`, không ở gốc; phiên bản Go,
  thư viện web, cách truy cập database và khung test backend là `QC-11`…`QC-17`. `verify.sh` vẫn
  chỉ gọi Node khi `package.json` nằm ở gốc — khung test frontend chốt ở pha 4, dòng mới vào file này.
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
  **Lời từ chối do hàm trigger phát ra cũng mang tên theo hình ấy** (2026-10-06, `P3-04`, **F-058**):
  mỗi `RAISE EXCEPTION` trong một hàm của schema viết `USING … CONSTRAINT = '<bảng>_<ý>_<loại>'` bằng
  **chuỗi trần**, `<bảng>` là bảng mà lời từ chối giữ, `<loại>` thường là `check`. Mọi tên — ràng buộc,
  chỉ mục duy nhất, lời từ chối của trigger — có một dòng trong bảng ánh xạ của hợp đồng API
  ([`../3-be/01-hop-dong-api.md`](../3-be/01-hop-dong-api.md) §4); Gate 1g đỏ khi thiếu.
- **Hậu quả nếu làm khác:** lời từ chối của database in **tên ràng buộc** — đó là thứ `P2-04` bước 6
  dán làm bằng chứng, và là thứ backend pha 3 đọc để biết luật nào vừa chặn. Tên tự sinh kiểu
  `x_y_check1` không nói luật nào, nên bằng chứng không đọc được và backend phải đoán. Lời từ chối của
  trigger không tên thì backend chỉ nhận ra luật bằng cách đọc chữ của câu báo lỗi — sửa một chữ trong
  migration là gãy ánh xạ mà không cổng nào đỏ (**F-058**).
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
  Câu dưới chấm lời từ chối của trigger trên thân hàm đang chạy trong database — file migration cũ
  không sửa được, nên đọc file không chấm được: hàm có `RAISE EXCEPTION` nhiều hơn số tên viết bằng
  chuỗi trần, hay một tên sai hình hoặc không mở đầu bằng tên một bảng của schema, ra một dòng.
  ```sql
  SELECT p.proname AS ham, 'RAISE EXCEPTION không mang tên' AS loi
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  WHERE n.nspname = :schema
    AND (SELECT count(*) FROM regexp_matches(p.prosrc, '\mRAISE\s+EXCEPTION\M', 'gi'))
     <> (SELECT count(*) FROM regexp_matches(p.prosrc, '\mCONSTRAINT\s*=\s*''[^'']+''', 'gi'))
  UNION ALL
  SELECT p.proname, m[1]
  FROM pg_proc p
  JOIN pg_namespace n ON n.oid = p.pronamespace
  CROSS JOIN LATERAL regexp_matches(p.prosrc, '\mCONSTRAINT\s*=\s*''([^'']+)''', 'gi') AS m
  WHERE n.nspname = :schema
    AND (   m[1] !~ '^[a-z][a-z0-9_]*_(pkey|key|fkey|check|excl)$'
         OR NOT EXISTS (SELECT 1 FROM pg_class r
                        WHERE r.relnamespace = n.oid AND r.relkind = 'r'
                          AND m[1] LIKE r.relname || '!_%' ESCAPE '!'));
  ```
- **Nguồn:** phiên chọn 2026-09-27; vế lời từ chối của trigger là owner — **ADR-082** điểm 5.4, sửa
  **F-058** ở migration bước 18 (`P3-04`, 2026-10-06).

---

## 8. Backend — `QC-11`…`QC-17`

Bảy mục dưới chốt ở `P3-03` (2026-10-06, Claude Code chọn, Codex thi công). Vì sao chọn thế và các
phương án bị loại: `docs/decisions.md` **ADR-083**. `QC-11`…`QC-14` sửa 2026-10-11 (`T-149`) theo stack chủ
repo duyệt 2026-10-10 — Gin, sqlc, cấu trúc kết hợp: **ADR-093**; các vế *chuyển tiếp* trong từng mục hết hạn
ở task được nêu. Hai chữ *ô ghi* · *cửa ghi*: **ADR-082** điểm 1. Hai chữ *ô ghi* · *cửa ghi*: **ADR-082** điểm 1.

### QC-11 — Go 1.27.2, một module ở `be/`, phụ thuộc ghim

- **Quy ước:** backend là **một** module Go ở `be/`, đường dẫn module `banhcuon/be`. Dòng `go` của
  `be/go.mod` ghim **`go 1.27.2`**, đúng bản dùng ở máy phát triển, bộ kiểm và máy chạy thật. Lệnh `go` cũ hơn
  tự tải đúng bản ấy (`GOTOOLCHAIN=auto`, mặc định). Không dòng `toolchain` riêng. Lên bản mới là sửa dòng `go`
  **và** mục này trong cùng một lượt. Bản ghim của phụ thuộc:

  | Module | Bản | Vai |
  |---|---|---|
  | `github.com/jackc/pgx/v5` | `v5.11.0` | phụ thuộc trực tiếp — driver (`QC-13`) |
  | `github.com/gin-gonic/gin` | `v1.12.0` | phụ thuộc trực tiếp — web (`QC-12`) |
  | `github.com/sqlc-dev/sqlc` | `v1.31.1` | **công cụ**, không phải thư viện: dòng `tool github.com/sqlc-dev/sqlc/cmd/sqlc`, chạy `go tool sqlc` (`QC-13`) |

  Thêm một phụ thuộc trực tiếp hay một công cụ nữa thì nói lý do ở mục dùng nó.
  `be/go.mod` lên các bản này ở `T-150` (2026-10-11). Gin mang `// indirect` tới khi `T-151` import nó lần đầu;
  phép kiểm không phân biệt hai trạng thái ấy.
- **Hậu quả nếu làm khác:** máy thật chạy một bản Go khác bộ kiểm thì `time`, `database` của thư viện chuẩn
  có thể khác đúng chỗ test đã chứng minh, cùng lý lẽ `QC-01` cho PostgreSQL. sqlc không ghim thì hai máy sinh
  hai bản code khác nhau từ cùng một file `.sql`, và phép so của `verify.sh` đỏ ở máy này, xanh ở máy kia.
- **Phép kiểm:**
  ```sh
  grep -Eqx 'go 1\.27\.2' be/go.mod 2>/dev/null || echo "be/go.mod không ghim dòng 'go 1.27.2'"
  grep -Eq '^(require )?[[:space:]]*github.com/jackc/pgx/v5 v5\.11\.0( |$)' be/go.mod 2>/dev/null || echo "be/go.mod không ghim github.com/jackc/pgx/v5 v5.11.0"
  grep -Eq '^(require )?[[:space:]]*github.com/gin-gonic/gin v1\.12\.0( |$)' be/go.mod 2>/dev/null || echo "be/go.mod không ghim github.com/gin-gonic/gin v1.12.0"
  grep -Eq '^[[:space:]]*(require[[:space:]]+)?github.com/sqlc-dev/sqlc v1\.31\.1( |$)' be/go.mod 2>/dev/null || echo "be/go.mod không ghim github.com/sqlc-dev/sqlc v1.31.1"
  grep -Eq '^(tool[[:space:]]+|[[:space:]]+)github.com/sqlc-dev/sqlc/cmd/sqlc$' be/go.mod 2>/dev/null || echo "be/go.mod thiếu dòng tool github.com/sqlc-dev/sqlc/cmd/sqlc"
  grep -q '^module banhcuon/be$' be/go.mod 2>/dev/null || echo "be/go.mod không khai module banhcuon/be"
  [ -f be/go.sum ] || echo "thiếu be/go.sum"
  ```
- **Nguồn:** ngôn ngữ — `QC-09`; module là phiên chọn 2026-10-06 (**ADR-083**); Go 1.27.2 và bản ghim của
  gin, sqlc, pgx là **chủ repo duyệt 2026-10-10** (**ADR-093** điểm 1; Claude tra `proxy.golang.org`, `go.dev/dl`
  cùng ngày).

### QC-12 — Web bằng Gin v1.12.0, chỉ ở tầng handler; mỗi đường gọi một dòng đăng ký viết liền

- **Quy ước:**
  - HTTP đi qua `github.com/gin-gonic/gin` (`QC-11`). Không framework hay bộ định tuyến thứ hai.
  - **Chỉ** `handler.go` của một miền, `be/cmd/server/`, `be/internal/middleware/` và file test được import
    Gin (kể cả gói con, kể cả import có bí danh). `service.go`, `repository.go`, `apierr`, `authz` và mọi
    file khác thì không: `apierr` ghi lỗi qua `http.ResponseWriter`, handler truyền `c.Writer`.
  - Mỗi miền đã chuyển khai một hàm đăng ký đường gọi trong `handler.go`; `be/cmd/server/` gọi hàm ấy của từng
    miền. Mỗi đường gọi là **một** lời gọi phương thức Gin (`GET` · `POST` · `PUT` · `PATCH` · `DELETE`) với
    đường dẫn **viết liền một chuỗi**, tham số dạng `:tên` mang **đúng tên** `{tên}` của `openapi.yaml`.
    Không `Group`, `Any`, `Handle`, không nối chuỗi đường dẫn, không wildcard — Gate 1g đọc được khuôn này và
    đỏ ở mọi hình khác (từ `T-150`).
  - Hai đường gọi cùng tiền tố, cùng vị trí thì cùng tên tham số: Gin từ chối đăng ký khi khác tên.
  - *Chuyển tiếp (2026-10-11, T-149):* miền chưa chuyển giữ `http.ServeMux` với mẫu có phương thức, nối vào
    router Gin qua `gin.WrapH` ở `be/cmd/server/` (từ `T-151`). `T-165` gỡ adapter, từ đó khuôn cũ là đỏ.
- **Hậu quả nếu làm khác:** service import Gin thì logic cửa dính vào kiểu ngữ cảnh của framework, test cửa
  phải dựng cả router, và tầng handler hết là ranh giới. Đường gọi ghép từ `Group` hay nối chuỗi thì Gate 1g
  không đọc ra đường đầy đủ, nên một đường gọi lệch hợp đồng trông như khớp.
- **Phép kiểm:**
  ```sh
  grep -Ei 'labstack/echo|go-chi/|gofiber|gorilla/mux|julienschmidt/httprouter|beego|go-kratos' be/go.mod 2>/dev/null
  grep -rlE '"github\.com/gin-gonic/' be --include='*.go' 2>/dev/null | grep -vE '(_test|/handler)\.go$' | grep -vE '^be/(cmd/server|internal/middleware)/'
  grep -rnE '\.(Group|Any|Handle)\(' be --include='*.go' 2>/dev/null | grep -v '_test\.go:'
  ./scripts/check-gin-imports.sh >/dev/null 2>&1 || ./scripts/check-gin-imports.sh 2>&1
  ```
  Dòng hai: file không được phép mà import Gin. Dòng ba: hình đăng ký Gate 1g không đọc được. Dòng cuối: Gate 1h
  (từ `T-150`) — cùng luật import như dòng hai nhưng đọc khối `import`, bỏ chú thích và chuỗi ngoài import. Luật
  đầy đủ về hình đường gọi (nối chuỗi, wildcard, `{tên}` trong đường Gin, tên tham số so với hợp đồng, đường gọi
  đăng ký hai lần) do Gate 1g chấm.
- **Nguồn:** **chủ repo duyệt 2026-10-10** (**ADR-093** điểm 4 · 6); luật import và khuôn đăng ký là phiên
  chọn (Claude, kế hoạch §2 và phiếu bước 02, 2026-10-10). Thay quy ước `net/http` của **ADR-083** điểm 6.

### QC-13 — Database bằng pgx v5 và code sqlc sinh từ file `.sql` của cửa; câu ghi chỉ ở thư mục của một cửa; một hàm mở giao dịch

- **Quy ước:**
  - **Driver:** `github.com/jackc/pgx/v5` (`pgxpool`). **Sinh code:** sqlc (`QC-11`), `sql_package: pgx/v5`.
    Không ORM, không công cụ sinh code nào khác.
  - **Câu ghi chỉ ở một chỗ.** Mỗi câu `INSERT` · `UPDATE` của backend là một file
    `be/internal/<miền>/sql/<cửa>/<câu>.sql` (mỗi tên `[a-z][a-z0-9_]*`). Thư mục `<cửa>` **là** cửa ghi
    của **ADR-082** điểm 1, mã của nó là `<miền>/<cửa>`. Câu **đọc** ở miền đã chuyển là file `.sql` ngay
    dưới `sql/`; miền chưa chuyển đặt ở đâu cũng được, như trước.
  - **Miền đã chuyển** là miền có mục trong `sqlc.yaml` ở gốc `be/`; danh sách đọc từ chính file ấy. Ở miền
    đã chuyển: mỗi file `.sql` có **đúng một** câu và **đúng một** dòng `-- name:`, tên duy nhất trong miền;
    code sinh ở `be/internal/<miền>/internal/sqlcgen/`, một gói mỗi miền, không sửa tay. Mỗi mục của
    `sqlc.yaml` đọc lược đồ thẳng từ `db/migrations/` — không chép lược đồ, không sửa migration cho sqlc.
    *Chuyển tiếp (2026-10-11, T-149):* miền chưa chuyển giữ hình cũ (Go nạp file bằng `embed`) tới task
    của nó; `T-165` áp luật cho mọi miền.
  - Code sinh được Gate 1f miễn luật *câu ghi trong chuỗi Go* **chỉ khi** khớp nguồn: `scripts/verify.sh`
    sinh lại vào thư mục tạm và so cả tập file với `internal/*/internal/sqlcgen/` (từ `T-150`). Chỉ
    `repository.go` của chính miền gọi `sqlcgen`; miền khác không import được, luật `internal` của Go chặn.
  - **Khuôn một mục của `sqlc.yaml`** là khuôn duy nhất Gate 1f nhận; nó nằm ở header của
    `scripts/check-write-paths.sh`. `queries:` liệt kê `internal/<miền>/sql` **và từng** `internal/<miền>/sql/<cửa>`,
    vì sqlc không đọc thư mục con. sqlc đòi mỗi câu kết bằng `;` (Claude thử 2026-10-11, `T-150`).
  - **Không** `DELETE` · `TRUNCATE` (`shop_app` không xoá được — `QC-03`), **không** `MERGE`, `COPY`,
    `CopyFrom` — hai thứ sau ghi theo cách lệnh liệt kê không đọc ra ô.
  - Bảng viết trần hoặc `shop.<bảng>`; `UPDATE` nêu cột ở `SET cột = …` hoặc `SET (a, b) = …`.
  - **Giao dịch mở bằng đúng một hàm.** Hôm nay là hàm ở `be/internal/db/`; từ `T-151` là `InTx` ở
    `be/internal/platform/postgres/` (**ADR-093** điểm 5). Không file `.go` nào khác (trừ file test) gọi
    `Begin` · `BeginTx` · `BeginFunc` · `BeginTxFunc`, `Commit` hay `Rollback`; nhãn *generated* không miễn.
    Service mở giao dịch qua `authz.Run` (ADR-085); repository **nhận** `pgx.Tx`.
  - **Lệnh liệt kê đường ghi** (**ADR-082** điểm 3) là `scripts/check-write-paths.sh` — Gate 1f, chạy
    mọi lượt; `--list` in bảng *ô ghi → cửa*. Nó đọc gì, đỏ khi nào: header của script.
- **Hậu quả nếu làm khác:** câu ghi rải trong chuỗi Go thì *mỗi ô đúng một cửa* chỉ còn là lời hứa — lệnh liệt
  kê phải phân tích mã Go, hoặc không dựng được. Code sinh sửa tay hay lệch file `.sql` thì câu chạy thật khác
  câu Gate 1f đọc. Mỗi lát một cách mở giao dịch thì ranh giới tầng 2 (**ADR-082** điểm 2) không chấm chung
  được, và một repository tự mở giao dịch con trông y như cửa đúng.
- **Phép kiểm:**
  ```sh
  ./scripts/check-write-paths.sh >/dev/null 2>&1 || ./scripts/check-write-paths.sh 2>&1
  grep -rnE '(\.|pgx\.)(Begin|BeginTx|BeginFunc|BeginTxFunc|Commit|Rollback)\(' be --include='*.go' 2>/dev/null | grep -v '_test\.go:' | grep -vE '^be/internal/(db|platform/postgres)/'
  [ -d be/internal/db ] && [ -d be/internal/platform/postgres ] && echo "hai chỗ giữ hàm mở giao dịch: be/internal/db và be/internal/platform/postgres"
  grep -Ei 'gorm\.io|entgo\.io|jmoiron/sqlx|upper/db|uptrace/bun|lib/pq|go-pg/' be/go.mod 2>/dev/null
  grep -rlE '/internal/sqlcgen"' be --include='*.go' 2>/dev/null | grep -vE '(/repository|_test)\.go$'
  ```
  Dòng ba: trong lúc chuyển không được có hai chỗ. Dòng cuối: chỉ repository gọi code sinh. Luật `-- name:`
  và phép so code sinh do Gate 1f và `verify.sh` chấm (từ `T-150`).
- **Nguồn:** phiên chọn 2026-10-06 (**ADR-083**), dựng để **ADR-082** điểm 3 chạy được không cần database;
  sqlc **chủ repo duyệt 2026-10-10** (**ADR-093** điểm 2); luật *miền đã chuyển* là Claude chốt 2026-10-10
  (**ADR-093** điểm 3).

### QC-14 — Cấu trúc trong `be/`: kết hợp — ba tầng trong từng miền

- **Quy ước:**

  | Đường dẫn | Chứa gì |
  |---|---|
  | `be/go.mod` · `be/go.sum` | module, bản ghim, dòng `tool` của sqlc (`QC-11`) |
  | `sqlc.yaml` ở gốc `be/` | một mục `sql:` mỗi miền đã chuyển (`QC-13`); sinh ở `T-150`, hoặc `T-152` nếu sqlc không nhận cấu hình rỗng |
  | `be/cmd/server/` | composition root: dựng router Gin, gắn `middleware/`, gọi hàm đăng ký của từng miền (`QC-12`); sinh ở `T-151` |
  | `be/internal/db/` → `be/internal/platform/postgres/` | hàm kết nối (`QC-15`), hàm mở giao dịch duy nhất (`QC-13`), test khói; đổi chỗ ở `T-151` |
  | `be/internal/dbtest/` → `be/internal/testhelper/` | đọc database kiểm từ môi trường cho test (`QC-16`); không câu ghi nào; đổi tên ở `T-151` |
  | `be/internal/apierr/` | hình lỗi chung, hằng mã lỗi và bảng *tên từ chối → mã* — bản code của hợp đồng ([`../3-be/01-hop-dong-api.md`](../3-be/01-hop-dong-api.md) §3–§4, `P3-04`); Gate 1g so hai bản; không import Gin |
  | `be/internal/authz/` | hàm chạy cửa có quyền (`authz.Run`), lớp quyền và khai báo cửa (`authz.Door`) — bản code của ma trận [`../3-be/02-vai-va-quyen.md`](../3-be/02-vai-va-quyen.md) (`P3-05`, **ADR-085**); không câu ghi nào |
  | `be/internal/middleware/` | gắn người vào `gin.Context`; không kiểm quyền, không thay `authz.Run`; sinh ở `T-151` |
  | `be/internal/<miền>/` | một miền nghiệp vụ. Đã chuyển: `handler.go` (Gin) → `service.go` (logic cửa, `authz.Door`, `authz.Run`; cửa lớp `theo_cua_goi` giữ API nhận `pgx.Tx`) → `repository.go` (nhận `pgx.Tx`, gọi `sqlcgen`). Chưa chuyển: hình cũ, cửa là hàm exported của gói |
  | `be/internal/<miền>/sql/<cửa>/` | câu ghi của cửa ấy (`QC-13`) |
  | `be/internal/<miền>/sql/` | câu đọc, file `.sql` ngay dưới thư mục |
  | `be/internal/<miền>/internal/sqlcgen/` | code sqlc sinh cho riêng miền; không sửa tay |

  Miền ngày 2026-10-11 (Claude đếm, mười ba; miền mới thêm dòng ở đây): `ban` · `don` · `gia` · `hoadon` · `ket` ·
  `menu` · `ngayban` · `nguoi` · `phien` · `qr` · `sanxuat` · `tratruoc` · `vongdoi`. Phụ thuộc đi một chiều:
  handler → service → repository → `sqlcgen`; service và repository không import Gin (`QC-12`), handler không
  gọi database. Không đặt file `.go` ngoài `be/internal/` · `be/cmd/`, không thư mục hay file khác ở gốc `be/`,
  mà không thêm một dòng vào bảng này trước. `T-165` cập nhật mục này lần cuối, bỏ các vế chuyển tiếp.
- **Hậu quả nếu làm khác:** chia ngang (`internal/handler/`, `internal/service/`) thì mọi service thấy mọi câu
  ghi, ranh giới chỉ còn một luật gate (**ADR-093** *Why*). Cửa đặt ngoài khuôn thì lệnh liệt kê không tìm
  thấy nó, và `P3-13` đi tìm test của một vế ở ba chỗ. Miền có code sinh mà thiếu một tầng thì câu ghi bị gọi
  từ chỗ không ai duyệt.
- **Phép kiểm:**
  ```sh
  [ -d be/internal/db ] || [ -d be/internal/platform/postgres ] || echo "thiếu be/internal/platform/postgres (trước T-151: be/internal/db)"
  find be -name '*.go' 2>/dev/null | grep -Ev '^be/(internal|cmd)/'
  find be -mindepth 1 -maxdepth 1 2>/dev/null | grep -Ev '^be/(go\.mod|go\.sum|sqlc\.yaml|internal|cmd)$'
  for d in be/internal/*/internal/sqlcgen; do [ -d "$d" ] || continue; m="${d%/internal/sqlcgen}"; for f in handler.go service.go repository.go; do [ -f "$m/$f" ] || echo "$m có sqlcgen mà thiếu $f"; done; done
  ```
- **Nguồn:** cấu trúc kết hợp **chủ repo chọn 2026-10-10** (**ADR-093** điểm 4, kế hoạch §2); bảng và phép kiểm
  là phiên chọn (Claude, T-149, 2026-10-11); vị trí `be/` — `QC-08`. Bản trước: phiên chọn 2026-10-06 (**ADR-083**).

### QC-15 — Backend kết nối bằng `shop_app`, đặt múi giờ quán, và từ chối khi sai một trong hai

- **Quy ước:** backend mở database bằng **đúng một** hàm ở `be/internal/db/`, nhận chuỗi kết nối và
  múi giờ của quán. Hàm đặt tham số kết nối `TimeZone` bằng múi giờ ấy (`QC-06`), và với mỗi kết nối
  mới đọc lại vai: khác `shop_app`, hay là superuser ⇒ trả lỗi, không trả kết nối. Múi giờ rỗng ⇒ trả
  lỗi trước khi kết nối. Giá trị múi giờ là cấu hình lúc chạy; ở bộ kiểm, `scripts/be-check.sh` đọc
  nó từ `master_plan/shop-facts.md` §1 như `db-check` (không chép); cách cấp cấu hình ở máy thật là
  của pha 5.
- **Hậu quả nếu làm khác:** chạy nhầm bằng `shop_owner` thì `QD-50` không giữ gì — chủ bảng xoá được
  mọi thứ — và không ai biết, vì mọi lệnh vẫn chạy. Quên đặt múi giờ thì mọi mốc lệch 7 tiếng ở đúng
  máy có server để UTC (`QC-06`).
- **Phép kiểm:** test `TestQC15_…` (chạy bằng `scripts/be-check.sh`, `QC-16`) qua chính hàm kết nối:
  vai đọc ra là `shop_app`, không superuser; `SHOW TimeZone` bằng múi giờ ở `shop-facts.md` §1 trong
  khi một kết nối không đặt múi giờ đọc ra UTC — in cả ba giá trị; kết nối bằng `shop_owner`, hay múi
  giờ rỗng ⇒ hàm trả lỗi. Test `TestQC03_…` cùng file: lệnh xoá qua kết nối ấy bị từ chối với mã
  `42501`, in lời từ chối nguyên văn, số dòng không đổi. Khối dưới chỉ giữ cho hai test không biến mất:
  ```sh
  grep -qs '^func TestQC15_' be/internal/db/*_test.go || echo "thiếu test TestQC15_ ở be/internal/db/"
  grep -qs '^func TestQC03_' be/internal/db/*_test.go || echo "thiếu test TestQC03_ ở be/internal/db/"
  ```
- **Nguồn:** owner — `QC-03` (vai), `QC-06` (múi giờ tường minh); từ chối ở hàm kết nối là phiên chọn
  2026-10-06 (**ADR-083**).

### QC-16 — Test backend: `go test` trên PostgreSQL thật, dựng bởi `scripts/be-check.sh`

- **Quy ước:**
  - Thư viện `testing` chuẩn. **Một** lệnh chạy cả bộ: `scripts/be-check.sh` — dựng database riêng
    và rỗng (compose project `banhcuon_check_{PID}_be_…`, cổng ngẫu nhiên — khuôn tên mà
    `db-check` cũng dọn khi tiến trình đã chết, **F-045**), chạy mọi migration từ số 0, xuất ra môi
    trường chuỗi kết nối `shop_app` · `shop_owner` và múi giờ quán, chạy `go test -count=1 -p 1 -v ./...`
    trong `be/`, rồi chỉ gỡ project của mình. Không Docker, hay database không lên ⇒ **FAIL**.
  - Test cần database lấy kết nối qua `be/internal/dbtest/`; thiếu biến môi trường ⇒ test **đỏ**
    với lời chỉ sang `scripts/be-check.sh`. Không `t.Skip`, không `testing.Short`, không database giả,
    không mock driver, không testcontainers (một cách dựng database kiểm, không hai).
  - **Gate 1:** `scripts/verify.sh` chạy gofmt · `go vet` · `go build` trong `be/`, và gọi
    `scripts/be-check.sh` khi lượt đổi gì dưới `be/`, `db/`, ở `compose.yaml` hay
    `scripts/be-check.sh`. Lượt chỉ đổi tài liệu thì không (`CLAUDE.md` §5).
- **Hậu quả nếu làm khác:** test tự bỏ qua khi thiếu database là test không ai biết đã không chạy
  (**F-007**). Test trên database giả xanh vì không có ai để từ chối — tầng 1 và tầng 2 không tồn
  tại ở đó (`P3-03` *Bẫy*). Hai lần chạy dùng chung một database kiểm thì gỡ của nhau (**F-045**).
- **Phép kiểm:**
  ```sh
  grep -q 'scripts/be-check.sh' scripts/verify.sh || echo "scripts/verify.sh không gọi scripts/be-check.sh"
  grep -rnE 't\.Skip|testing\.Short' be --include='*.go' 2>/dev/null
  grep -Ei 'sqlmock|pgxmock|sqlite|testcontainers' be/go.mod 2>/dev/null | grep -v '// indirect'
  grep -rnE '"[^"]*(sqlmock|pgxmock|sqlite|testcontainers)[^"]*"' be --include='*.go' 2>/dev/null
  ```
  Dòng ba chỉ chấm phụ thuộc trực tiếp: dòng `tool` của sqlc (`QC-11`) kéo `github.com/ncruces/go-sqlite3`
  vào `go.mod` dưới dạng `// indirect`, vì sqlc tự hỗ trợ engine sqlite; code của ta không dùng nó. Dòng bốn
  chặn code Go import một gói như thế dù `go.mod` còn ghi `// indirect` (Claude sửa 2026-10-11, `T-150`).
- **Nguồn:** owner — **ADR-082** điểm 2 · 7 (test qua cửa trên PostgreSQL thật), **F-045**, **F-007**;
  lệnh, tên project và biến môi trường là phiên chọn 2026-10-06 (**ADR-083**).

### QC-17 — Tên test mang mã mệnh đề nó chấm

- **Quy ước:** mỗi hàm test trong `be/` tên `Test<MÃ>_<MôTả>`, `<MÃ>` là `I` + ba số (mệnh đề ở
  `quality/invariants.md`), `YC` + hai số (`docs/product/1-system-design/04-yeu-cau-du-lieu.md`) hoặc
  `QC` + hai số (file này) — ví dụ `TestI017_HaiLoiGoiChenNhau`. Một hàm một mã; test chạm mệnh đề
  thứ hai thì viết hàm thứ hai. `TestMain` là ngoại lệ duy nhất. Đây là **dấu truy** của **ADR-082**
  điểm 4: `P3-13` đếm vế đã có test bằng `grep`, không bằng mắt.
- **Hậu quả nếu làm khác:** test đặt tên theo hàm được gọi (`TestCreateOrder`) thì `P3-13` phải đọc
  từng test mới biết nó chứng minh vế nào — đúng chỗ một vế thiếu test trông như đã có.
- **Phép kiểm:**
  ```sh
  grep -rhoE '^func Test[A-Za-z0-9_]*' be --include='*_test.go' 2>/dev/null | sed 's/^func //' | grep -Ev '^(Test(I[0-9]{3}|YC[0-9]{2}|QC[0-9]{2})_[A-Za-z0-9_]+|TestMain)$'
  for c in $(grep -rhoE '^func TestI[0-9]{3}_' be --include='*_test.go' 2>/dev/null | grep -oE 'I[0-9]{3}' | sort -u); do grep -q "^### I-${c#I} " quality/invariants.md || echo "test mang $c mà quality/invariants.md không có I-${c#I}"; done
  ```
- **Nguồn:** owner — **ADR-082** điểm 4 (*mỗi test truy được về một `I-0xx` bằng lệnh; hình của dấu truy
  chọn ở `P3-03`*); hình tên là phiên chọn 2026-10-06 (**ADR-083**).

---

## 9. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2-04`…`P2-08` | `QC-04` kiểu · `QC-05` tên và luật migration · `QC-07` khuôn test *từ chối* · `QC-10` tên ràng buộc; chạy `./scripts/db-check.sh`, dán output vào *Bàn giao* |
| `P2-09` | `QC-05` — thư mục và khuôn tên mà lệnh đối chiếu tên bảng `.md` ↔ migration đọc; đã đổi mục ấy thành *mỗi bước xuôi một bước lùi* (2026-09-29) |
| `P2-11` | **xong 2026-09-30** — `QC-07` bộ kiểm gọi bộ đối chiếu; `QC-08` dòng `db/reconcile/` |
| `P2-13` | **2026-09-30** — `QC-07` bước 7 của bộ kiểm diễn ba scenario; `QC-08` dòng `db/scenario/` |
| `P3-03` | **2026-10-06** — đóng chỗ trống của `QC-06` · `QC-09`; thêm `QC-11`…`QC-17` |
| `P3-04` | **2026-10-06** — `QC-10` thêm vế lời từ chối của trigger (**F-058**); `QC-14` thêm dòng `be/internal/apierr/` |
| `P3-05` | **2026-10-06** — `QC-14` thêm dòng `be/internal/authz/` |
| `T-149` | **2026-10-11** — `QC-05` migrate v4.20.1; `QC-11`…`QC-14` sửa theo **ADR-093** (Gin, sqlc, cấu trúc kết hợp), kèm vế chuyển tiếp; `T-150` · `T-151` · `T-165` siết phép kiểm |
| `T-150` | **2026-10-11** — siết phép kiểm `QC-05` (chỉ v4.20.1) · `QC-11` (chỉ `go 1.27.2`, gin · sqlc bắt buộc); `QC-12` thêm Gate 1h; `QC-13` khuôn `sqlc.yaml` và dấu `;`; `QC-16` chỉ chấm phụ thuộc trực tiếp và import Go |
| `P3-04`…`P3-14` | `QC-13` cửa ghi và Gate 1f · `QC-15` kết nối · `QC-16` chạy test bằng `scripts/be-check.sh` · `QC-17` tên test |
