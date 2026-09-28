# Quy ước dữ liệu — tiền, mốc, khoá, đặt tên, trạng thái, không xoá cứng, văn bản

Pha 2 · bước `P2-03` · viết 2026-09-26 (Claude Code). Đây là **file đầu tiên** của
`docs/product/2-db/`, và nó mở thư mục ấy (`docs/decisions.md` **ADR-035** luật 2).

**File này sở hữu:** *cất bằng gì* — mỗi quy ước là một mục `QD-XX` gồm bốn ô: quy ước · hậu quả
nếu làm khác · phép kiểm · nguồn. Năm lát lược đồ `P2-04`…`P2-08` chạy song song, và thứ duy nhất
bắt chúng cộng được tiền với nhau là **cùng một từ vựng** ở đây.

**File này KHÔNG sở hữu:**
- **tên bảng, tên cột cụ thể của một lát, kiểu, ràng buộc** — file migration thắng, file lát giữ ý
  định (**ADR-053** luật 2); lát đầu tiên là `P2-04`;
- **DBMS, phiên bản, tên kiểu cụ thể** — `P2-12` chốt (**ADR-053** luật 1), ở
  [`10-quy-uoc-code.md`](10-quy-uoc-code.md) `QC-01` · `QC-04`. Vì thế không mục nào ở đây chọn kiểu;
  từ 2026-09-27 các câu kiểm viết bằng cú pháp PostgreSQL, nghĩa giữ nguyên;
- **một con giá, một múi giờ, một mã kênh** — dữ kiện quán ở `master_plan/shop-facts.md`
  (**ADR-001**). Mục nào cần chúng thì **trỏ**, không chép (**F-001**);
- **luật nghiệp vụ và tầng bảo vệ** — `quality/invariants.md` và
  `docs/product/1-system-design/03-bao-ve-invariant.md`. Quy ước ở đây nói *cất thế nào để tầng ấy
  dựng được*, không đặt thêm luật (**ADR-050**).

---

## 0. Cách đọc — và cách chạy phép kiểm

**Mỗi mục có mã `QD-XX`.** Chữ số đầu là chủ đề (0 đặt tên · 1 khoá · 2 tiền · 3 mốc · 4 trạng thái ·
5 không xoá cứng · 6 văn bản và định danh). Mã không đánh lại khi thêm mục (`docs/product/00-index.md` →
*Luật ghi*); mục bỏ đi thì gạch ngang kèm ngày và lý do, không xoá — một mã đã có phép kiểm mang
tên nó ở `P2-11` thì không được biến mất.

**Nguồn** của một mục là một trong hai:
- **owner** — quy ước dịch thẳng một câu đã chốt ở pha 0 · pha 1 · `shop-facts.md`; đổi nó là đổi
  câu ở owner trước;
- **phiên chọn 2026-09-26** — lựa chọn thiết kế của lượt viết này, **chưa có lời chủ repo**
  (`CLAUDE.md` §7.2 — *cái được bảo ≠ cái mình suy*). Đổi được mà không cần hỏi chủ quán, nhưng
  phải sửa ở đây kèm hậu quả mới, trước khi lát nào làm khác.

**Phép kiểm** của mỗi mục là một câu truy vấn trên `information_schema` chuẩn SQL, hoặc một lệnh.
Nó ra **0 dòng** khi lược đồ đạt (**ADR-053** luật 3). **Cập nhật 2026-09-27 (`P2-12`):** DBMS là
PostgreSQL 17 (`10-quy-uoc-code.md` `QC-01`, **ADR-054**), và cả mười tám phép đã chạy trên một cơ sở
dữ liệu rỗng ⇒ 0 dòng. Máy chạy chúng là `scripts/db-check.sh`: nó đọc **thẳng** mọi khối `sql` dưới
tiêu đề `QD-XX` của file này — sửa một câu ở đây là sửa phép kiểm, không có bản chép thứ hai — còn
bốn phép dạng lệnh (`QD-02` · `QD-31` vế (b) · `QD-32` · `QD-40` vế (b)) là hàm cùng tên trong script
ấy. Ba bước sau nhận chúng:

| Bước | Làm gì với phép kiểm |
|---|---|
| `P2-12` | **xong 2026-09-27** — chạy từng phép trên PostgreSQL 17, cơ sở dữ liệu rỗng ⇒ 0 dòng; điền các tham số dưới đây |
| `P2-04`…`P2-08` | mỗi lát chạy lại cả bộ sau khi dựng, dán output vào khối *Bàn giao* |
| `P2-11` | gom thành **nhóm phép kiểm quy ước**, mang mã `QD-XX`, tách khỏi phép so mã `I-0xx`; chứng minh từng phép **biết kêu** bằng một lỗi cài sẵn (**ADR-050** luật 3) |

**Tham số** — các câu dưới đây dùng tên có dấu hai chấm đứng trước. Cột cuối là giá trị **đúng chữ
SQL** mà `scripts/db-check.sh` thay vào; đổi giá trị là đổi ở đây, script không giữ bản nào khác.
Mỗi dòng giữ đúng dạng `` | `:ten` | … | `giá trị` | `` — script đọc ô đầu và ô cuối.

| Tham số | Nghĩa | Ai điền | Giá trị (PostgreSQL 17) |
|---|---|---|---|
| `:schema` | schema chứa lược đồ của quán | `P2-12` | `'shop'` |
| `:kieu_moc` | danh sách tên kiểu (đúng chữ `information_schema.columns.data_type` in ra) được dùng cho mốc — thoả cả ba điều kiện của `QD-30` | `P2-12` | `'timestamp with time zone'` |
| `:collation_van_ban` | cách so cho văn bản người đọc (`QD-60`) | `P2-12` | `'vi-x-icu'` |
| `:collation_so_byte` | cách so cho định danh, chuỗi băm và mã trạng thái (`QD-61`) | `P2-12` | `'C'` |
| `:collation_mac_dinh` | cách so mặc định của cơ sở dữ liệu — PostgreSQL để trống `collation_name` khi cột dùng mặc định; `QC-02` giữ mặc định ấy là `C` | `P2-12` | `'C'` |
| `:vai_ung_dung` | vai database mà hệ thống dùng để ghi | `P2-12` | `'shop_app'` |
| `:bang_ky_thuat` | bảng **không** mang dữ liệu nghiệp vụ, được xoá (nếu có); mỗi tên phải có một dòng lý do ở file lát của nó. Chuỗi rỗng = chưa bảng nào — **đừng** thay bằng `NULL`: `NOT IN (NULL)` làm phép kiểm im lặng với mọi dòng | lát tạo bảng ấy | `''` |
| `:bang_khong_quan_he_so_hoc` | bảng có từ hai cột tiền trở lên mà các cột ấy **không** có quan hệ số học với nhau; mỗi tên một dòng lý do ở file lát. Chuỗi rỗng = chưa bảng nào, cùng lý do như trên | lát tạo bảng ấy | `''` |

Phép `LIKE` dùng `ESCAPE '!'` để dấu gạch dưới được đọc đúng chữ. PostgreSQL in tên cột của
`information_schema` bằng chữ thường, nên cách viết dưới đây giữ nguyên.

---

## 1. Đặt tên — `QD-01`…`QD-03`

Đặt tên đứng **đầu** vì mọi phép kiểm ở các mục sau nhận vai trò của một cột **qua tên nó**. Một
cột tiền mang sai hậu tố là một cột mà `QD-20` không bao giờ nhìn thấy.

### QD-01 — Tên bảng và tên cột: chữ thường ASCII, snake_case, tiếng Anh, tối đa 63 ký tự

- **Quy ước:** chỉ chữ thường `a`–`z`, chữ số và dấu gạch dưới; bắt đầu bằng chữ; không dấu tiếng
  Việt, không khoảng trắng, không gạch ngang. Tên cấu trúc (bảng, cột) viết **tiếng Anh**. Mã giá
  trị đã có owner thì theo `QD-02`, không theo mục này. 63 là giới hạn độ dài tên của ít nhất một
  DBMS phổ biến; `P2-12` hạ con số này nếu DBMS đã chọn chặt hơn, không bao giờ nâng.
- **Hậu quả nếu làm khác:** tên có hoa thường lẫn lộn phải đặt trong nháy ở mọi câu truy vấn, và
  quên nháy một lần là truy vấn sang một cột **khác**, hoặc không cột nào; tên có dấu tiếng Việt bị
  mỗi công cụ mã hoá một kiểu. Tên dài quá giới hạn bị cắt âm thầm, và hai tên dài giống nhau ở phần
  đầu thành **cùng một** tên.
- **Phép kiểm:**
  ```sql
  SELECT table_name, column_name
  FROM information_schema.columns
  WHERE table_schema = :schema
    AND (   table_name  <> LOWER(table_name)  OR column_name <> LOWER(column_name)
         OR CHAR_LENGTH(table_name) > 63     OR CHAR_LENGTH(column_name) > 63
         OR column_name LIKE '% %'           OR column_name LIKE '%-%'
         OR table_name  !~ '^[a-z][a-z0-9_]*$' OR column_name !~ '^[a-z][a-z0-9_]*$');
  ```
  Vế *chỉ ký tự ASCII* là hai biểu thức chính quy cuối, cú pháp PostgreSQL (`P2-12`, 2026-09-27).
  63 cũng là giới hạn của PostgreSQL, nên con số giữ nguyên.
- **Nguồn:** phiên chọn 2026-09-26. Lý do chọn tiếng Anh: mã kênh ở `master_plan/shop-facts.md` §2
  đã là tiếng Anh, và một lược đồ trộn hai thứ tiếng trong **tên cấu trúc** buộc người đọc đoán
  từng cột. Mã trạm tiếng Việt không dấu (§3) vẫn giữ nguyên — đó là **giá trị**, không phải tên.

### QD-02 — Mã giá trị đã có owner thì cất đúng chữ của owner, không dịch

- **Quy ước:** mã kênh bán (`master_plan/shop-facts.md` §2), mã trạm (§3) và mọi mã khác mà một
  owner đã viết ra bằng chữ máy đọc được thì vào database **đúng từng ký tự** ấy. Ràng buộc kiểm của
  cột mang mã liệt kê đúng tập mã của owner, không thêm, không bớt.
- **Hậu quả nếu làm khác:** một bản dịch là **bản thứ hai** của danh sách (**F-001**). Chủ quán đổi
  một mã ở owner thì bản dịch trôi, và một kênh hoặc một trạm biến khỏi báo cáo mà không lệnh nào kêu.
  Năm kênh là danh sách **đóng** (**ADR-015**): một mã thứ sáu lọt vào dữ liệu là đổi phạm vi bán.
- **Phép kiểm:** một lệnh. Lấy `check_clause` của ràng buộc kiểm trên cột mang mã kênh từ
  `information_schema.check_constraints`, tách các chuỗi trong nháy đơn, `sort -u`; so `comm -3`
  với danh sách mã tách từ bảng §2 của `shop-facts.md` bằng `grep -o` ⇒ **rỗng**. Làm y hệt cho mã
  trạm với bảng §3. Lệnh phải in **cả hai danh sách chưa lọc** cạnh kết quả `comm` (**F-017**).
  **Cách viết (`P2-12`, 2026-09-27):** lệnh là hàm `qd02` trong `scripts/db-check.sh`. Nó tìm cột
  bằng **tên**, nên cột mang mã kênh tên `channel_code`, cột mang mã trạm tên `station_code` (hậu tố
  `_code` của `QD-03`); một cột mang mã kênh dưới tên khác là cột lệnh này không thấy.
- **Nguồn:** owner — `shop-facts.md` §2 · §3, **ADR-001**, **ADR-015**.

### QD-03 — Vai trò của một cột đọc được từ hậu tố của nó

- **Quy ước:** mỗi vai trò dưới đây có **đúng một** cách gọi; không dùng từ đồng nghĩa.

  | Vai trò | Tên | Mục quy định vai trò ấy |
  |---|---|---|
  | khoá chính | `id` | `QD-10` |
  | khoá ngoại | tên bảng được trỏ, **số ít**, + `_id` | `QD-11` |
  | số tiền | hậu tố `_vnd` | `QD-20` |
  | mốc thời gian | hậu tố `_at` | `QD-30` |
  | ngày bán | `sale_date` | `QD-31` |
  | mốc tính tiền | `booked_at` | `QD-33` |
  | mốc hệ thống ghi | `created_at` | `QD-34` |
  | trạng thái | `status` | `QD-40` |
  | định danh máy đọc | `code` hoặc hậu tố `_code` | `QD-61` |
  | chuỗi băm | hậu tố `_hash` | `QD-61` |

  Cột trỏ tới bản ghi của **nhiều** bảng khác nhau (ví dụ một vết nói về nhiều loại bản ghi) **không**
  mang hậu tố `_id`, vì nó không có khoá ngoại được (`QD-11`); lát tạo nó đặt tên và ghi lý do.
- **Hậu quả nếu làm khác:** lát này gọi tiền là `_amount`, lát kia là `_price`, và phép kiểm của
  `QD-20` chỉ thấy một nửa số cột tiền — nửa còn lại có thể cất bằng số thực mà không ai biết.
  `I-014` cộng doanh thu ngang qua lát; một phép cộng phải đoán tên cột là một phép cộng sẽ sót.
- **Phép kiểm:**
  ```sql
  SELECT table_name, column_name
  FROM information_schema.columns
  WHERE table_schema = :schema
    AND (   column_name LIKE '%!_amount' ESCAPE '!' OR column_name LIKE '%!_price' ESCAPE '!'
         OR column_name LIKE '%!_money'  ESCAPE '!' OR column_name LIKE '%!_time'  ESCAPE '!'
         OR column_name LIKE '%!_ts'     ESCAPE '!' OR column_name LIKE '%!_on'    ESCAPE '!'
         OR (data_type IN (:kieu_moc) AND column_name NOT LIKE '%!_at' ESCAPE '!'));
  ```
- **Nguồn:** phiên chọn 2026-09-26.

---

## 2. Khoá — `QD-10`…`QD-11`

### QD-10 — Mỗi bảng có đúng một khoá chính tên `id`, tự sinh, không mang nghĩa nghiệp vụ

- **Quy ước:** khoá chính là một định danh do database sinh, không chứa số bàn, số điện thoại, mã
  QR hay bất cứ thứ gì con người đọc và có thể đổi. Thứ mang nghĩa (số bàn, mã hiển thị) là **cột
  riêng**, có khoá duy nhất riêng nếu owner đòi.
- **Hậu quả nếu làm khác:** khoá mang nghĩa thì phải đổi khi nghĩa đổi, và mọi khoá ngoại trỏ tới nó
  phải đổi theo, trên dữ liệu bán hàng thật. Ca đã có tên: mã QR của bàn **phải đổi được**
  (`work/findings.md` **F-042**, nay là `quality/invariants.md` **I-023**) — dùng nó làm khoá là biến mỗi lần đổi mã thành một lần sửa lịch
  sử của mọi phiên bàn.
- **Phép kiểm:**
  ```sql
  SELECT t.table_name
  FROM information_schema.tables t
  WHERE t.table_schema = :schema AND t.table_type = 'BASE TABLE'
    AND NOT EXISTS (
      SELECT 1
      FROM information_schema.table_constraints tc
      JOIN information_schema.key_column_usage k
        ON  k.constraint_schema = tc.constraint_schema
        AND k.constraint_name   = tc.constraint_name
        AND k.table_name        = tc.table_name
      WHERE tc.table_schema = t.table_schema AND tc.table_name = t.table_name
        AND tc.constraint_type = 'PRIMARY KEY' AND k.column_name = 'id');
  ```
- **Nguồn:** phiên chọn 2026-09-26.

### QD-11 — Mọi cột `_id` có một khoá ngoại thật

- **Quy ước:** cột nào mang hậu tố `_id` thì có một ràng buộc khoá ngoại tới bảng nó gọi tên. Không
  có "khoá ngoại bằng quy ước" mà database không biết.
- **Hậu quả nếu làm khác:** một dòng đơn trỏ tới một đơn không tồn tại vẫn được ghi, và nó cộng vào
  doanh thu mà không đơn vị tính tiền nào đứng tên. *Khoá ngoại bắt buộc* là một trong ba hình dạng
  của tầng 1 (**ADR-050** điểm 1); một cột `_id` không có khoá ngoại là một hàng tầng 1 tụt tầng
  trong im lặng.
- **Phép kiểm:**
  ```sql
  SELECT c.table_name, c.column_name
  FROM information_schema.columns c
  WHERE c.table_schema = :schema AND c.column_name LIKE '%!_id' ESCAPE '!'
    AND NOT EXISTS (
      SELECT 1
      FROM information_schema.key_column_usage k
      JOIN information_schema.table_constraints tc
        ON  tc.constraint_schema = k.constraint_schema
        AND tc.constraint_name   = k.constraint_name
        AND tc.table_name        = k.table_name
      WHERE tc.constraint_type = 'FOREIGN KEY'
        AND k.table_schema = c.table_schema AND k.table_name = c.table_name
        AND k.column_name  = c.column_name);
  ```
- **Nguồn:** owner — **ADR-050** điểm 1 (tầng 1 = khoá ngoại bắt buộc); tên do phiên chọn.

---

## 3. Tiền — `QD-20`…`QD-22`

### QD-20 — Mọi số tiền là số nguyên, đơn vị đồng, trong cột hậu tố `_vnd`

- **Quy ước:** số tiền cất bằng một kiểu **số nguyên** (hoặc kiểu thập phân với **0** chữ số sau
  dấu phẩy); không kiểu số thực dấu phẩy động, không phần lẻ, không cất tiền dưới dạng chuỗi. Đơn vị
  là **đồng**.
- **Hậu quả nếu làm khác:** số thực dấu phẩy động cộng dồn ra phần lẻ không ai nhập, và đối soát cuối
  ngày của quán là *lệch 1 đồng cũng phải tìm ra lý do* (`master_plan/shop-facts.md` §6.10): một
  phần lẻ sinh ra từ kiểu dữ liệu là một chỗ lệch **không có lý do nào để tìm**, và ngưỡng 0đ báo
  động giả mỗi tối, cho tới ngày có người tắt nó.
- **Phép kiểm:**
  ```sql
  SELECT table_name, column_name
  FROM information_schema.columns
  WHERE table_schema = :schema
    AND column_name LIKE '%!_vnd' ESCAPE '!'
    AND COALESCE(numeric_scale, -1) <> 0;
  ```
  Kiểu số thực và kiểu chuỗi đều để `numeric_scale` trống, nên cả hai rơi vào kết quả.
- **Nguồn:** owner — §6.10 (*đồng* là mức đối soát chủ quán đòi). **Cập nhật
  2026-09-27 (U-058):** chủ quán nhập số tiền giảm cả đơn, không phải phần trăm
  (`master_plan/shop-facts.md` §8.9). Lời này không phát sinh phép chia cần làm
  tròn. Nếu một nghiệp vụ sau này cần chia tiền, phải chốt luật làm tròn trước;
  không tự chọn luật ấy hoặc coi U-058 còn thiếu cách giảm tiền/phần trăm.

### QD-21 — Số tiền không âm; chiều đi của tiền nói bằng loại bản ghi, không bằng dấu trừ

- **Quy ước:** mọi cột `_vnd` có một ràng buộc kiểm giữ nó **≥ 0**. Tiền ra khỏi quán (hoàn tiền) và
  tiền về muộn (thu nợ cũ) là **bản ghi riêng** mang loại của nó, không phải một số âm trên bản ghi
  bán.
- **Hậu quả nếu làm khác:** một phép cộng thiếu một dấu trừ, hoặc thừa một dấu, lật một lần hoàn
  thành một lần bán — và cái sai ấy làm doanh thu trông **cao hơn** sự thật, đúng chiều không ai đi
  tìm (`docs/product/1-system-design/06-so-rui-ro.md` `RR-2` gặp đúng hình này cho nợ). Pha 1 đòi
  hoàn tiền mang **mốc riêng** và thu nợ **không** vào doanh thu
  (`docs/product/1-system-design/02-thoi-gian-ngay-ban.md` §2); cả hai chỉ đọc được khi chúng là bản
  ghi có loại, không phải một con số âm lẫn trong cột bán.
- **Phép kiểm:**
  ```sql
  SELECT c.table_name, c.column_name
  FROM information_schema.columns c
  WHERE c.table_schema = :schema AND c.column_name LIKE '%!_vnd' ESCAPE '!'
    AND NOT EXISTS (
      SELECT 1
      FROM information_schema.constraint_column_usage u
      JOIN information_schema.check_constraints k
        ON  k.constraint_schema = u.constraint_schema
        AND k.constraint_name   = u.constraint_name
      WHERE u.table_schema = c.table_schema AND u.table_name = c.table_name
        AND u.column_name  = c.column_name);
  ```
  Câu này chỉ chứng minh **có** một ràng buộc kiểm trên cột; nội dung *≥ 0* được `P2-11` chứng minh
  bằng cách cài một số âm ⇒ database từ chối.
- **Nguồn:** phiên chọn 2026-09-26, dựng để `02-thoi-gian-ngay-ban.md` §2 và `I-014` đọc được.

### QD-22 — Quan hệ số học giữa các cột tiền TRONG CÙNG MỘT bản ghi do database giữ

- **Quy ước:** khi hai cột tiền trở lên của cùng một bản ghi có quan hệ số học (ví dụ thành tiền của
  một dòng = đơn giá × số lượng), quan hệ ấy do **database** giữ — bằng một ràng buộc kiểm, hoặc bằng
  một **cột tự tính** không ghi tay được. Tổng đi **qua nhiều bản ghi** (tổng của một phiên bàn, doanh
  thu một ngày) **không** thuộc mục này: nó không đứng thành một ô ai cũng ghi được (**ADR-050**
  tầng 3), và nó là một câu đối chiếu của `P2-11` (tầng 5).
- **Hậu quả nếu làm khác:** một lỗi làm tròn, hay một lần quên cập nhật một cột, nằm im trong dữ liệu
  và được cộng vào doanh thu như tiền thật. Bằng chứng của dự án cũ, không phải dữ kiện quán này:
  `work/proposals/from_old_project/data_base/nghien-cuu.md` §2.7 — lược đồ ấy chặn số lượng âm
  nhưng không chặn một thành tiền sai.
- **Phép kiểm:**
  ```sql
  SELECT c.table_name
  FROM information_schema.columns c
  WHERE c.table_schema = :schema AND c.column_name LIKE '%!_vnd' ESCAPE '!'
    AND c.table_name NOT IN (:bang_khong_quan_he_so_hoc)
  GROUP BY c.table_schema, c.table_name
  HAVING COUNT(*) >= 2
     AND SUM(CASE WHEN c.is_generated = 'ALWAYS' THEN 1 ELSE 0 END) = 0
     AND NOT EXISTS (
       SELECT 1
       FROM information_schema.constraint_column_usage u
       JOIN information_schema.check_constraints k
         ON  k.constraint_schema = u.constraint_schema
         AND k.constraint_name   = u.constraint_name
       WHERE u.table_schema = c.table_schema AND u.table_name = c.table_name
         AND u.column_name LIKE '%!_vnd' ESCAPE '!'
       GROUP BY u.constraint_name
       HAVING COUNT(*) >= 2);
  ```
  Bảng nào ra ở đây thì hoặc thiếu ràng buộc, hoặc phải có tên trong `:bang_khong_quan_he_so_hoc`
  kèm lý do ở file lát.
- **Nguồn:** phiên chọn 2026-09-26 — bài học dự án cũ đưa vào ở T-097.

---

## 4. Mốc và múi giờ — `QD-30`…`QD-34`

Pha 1 đã chốt **mốc nào** tính tiền (`docs/product/1-system-design/02-thoi-gian-ngay-ban.md` §2),
**ai cấp** mốc (§3) và **một ngày bán** là gì (§1), rồi giao đúng một câu cho pha 2: *cất mốc thế
nào, kiểu gì* (§5). Năm mục dưới đây là câu trả lời.

### QD-30 — Mốc là một thời điểm tuyệt đối, không mang giới hạn năm 2038, cột hậu tố `_at`

- **Quy ước:** kiểu dùng cho mốc (`:kieu_moc`) phải thoả **cả ba**: (a) đọc lại ra **một** thời điểm
  không mơ hồ, dù phiên kết nối đang ở múi giờ nào — tức là mang múi giờ, hoặc cất theo một múi giờ
  cố định viết rõ ở quy ước code; (b) **không** có giới hạn năm 2038 mà một số kiểu mốc mang; (c) độ
  phân giải ít nhất là **giây**. `P2-12` chọn kiểu cụ thể và ghi vì sao nó thoả từng điều kiện —
  **đã chọn 2026-09-27**, kiểu và lý do từng điều kiện ở `10-quy-uoc-code.md` `QC-04`.
- **Hậu quả nếu làm khác:** mốc cất như *giờ đồng hồ trần* thì một tầng đọc nó bằng múi giờ khác sẽ
  cắt một ngày bán của quán thành hai (`02-thoi-gian-ngay-ban.md` §1), đúng ở những giờ quán đóng
  cửa — chỗ không ai nhìn. Kiểu có giới hạn năm 2038 thì hỏng **cùng lúc trên mọi bảng**, vào một
  ngày đã biết trước, trên dữ liệu thật. Bằng chứng của dự án cũ: `nghien-cuu.md` §1.7.
- **Phép kiểm:**
  ```sql
  SELECT table_name, column_name, data_type
  FROM information_schema.columns
  WHERE table_schema = :schema
    AND column_name LIKE '%!_at' ESCAPE '!'
    AND data_type NOT IN (:kieu_moc);
  ```
  Cùng với vế cuối của phép kiểm `QD-03` (cột có kiểu mốc mà không mang hậu tố `_at`), hai chiều
  đều được chấm.
- **Nguồn:** owner cho vế (a) — `02-thoi-gian-ngay-ban.md` §1 (*múi giờ của quán, ở mọi tầng*); vế
  (b) · (c) phiên chọn 2026-09-26, bài học dự án cũ đưa vào ở T-097.

### QD-31 — Ngày bán cất một lần, ở nơi ghi, trong cột `sale_date`, quy bằng múi giờ của quán

- **Quy ước:** mọi bảng có `booked_at` (`QD-33`) có thêm `sale_date` — ngày lịch chứa `booked_at`,
  quy bằng **múi giờ của quán** (`master_plan/shop-facts.md` §1), tính **một lần** lúc ghi. Mọi
  phép cộng tiền theo ngày (`I-014`, `I-021`) đọc `sale_date`, không tự quy mốc ra ngày.
- **Hậu quả nếu làm khác:** mỗi câu truy vấn tự quy mốc ra ngày thì mỗi câu là một chỗ có thể quên
  múi giờ — và câu quên là câu cắt đôi một ngày bán. Dự án cũ đúng *nhờ may*: giờ bán sáng nên quy
  sai múi giờ chưa từng đẩy một khoản nào sang ngày khác (`nghien-cuu.md` §3.2). Quán này có tiền đi
  **ngoài giờ bán** — thu nợ, hoàn, nhập bù (`02-thoi-gian-ngay-ban.md` §1) — nên không có sự may ấy.
- **Phép kiểm:** (a) cấu trúc —
  ```sql
  SELECT c.table_name
  FROM information_schema.columns c
  WHERE c.table_schema = :schema AND c.column_name = 'booked_at'
    AND NOT EXISTS (
      SELECT 1 FROM information_schema.columns d
      WHERE d.table_schema = c.table_schema AND d.table_name = c.table_name
        AND d.column_name = 'sale_date');
  ```
  (b) dữ liệu — một câu cho mỗi bảng có `booked_at`: dòng nào có `sale_date` khác ngày lịch của
  `booked_at` quy bằng múi giờ của quán ⇒ **0 dòng**. Cú pháp PostgreSQL (`P2-12`, 2026-09-27):
  `sale_date <> (booked_at AT TIME ZONE '<múi giờ ở shop-facts §1>')::date`; lệnh là hàm `qd31b`
  trong `scripts/db-check.sh`, đọc múi giờ thẳng từ `shop-facts.md` §1. `P2-11` gom vào bộ.
- **Nguồn:** owner cho nghĩa — `02-thoi-gian-ngay-ban.md` §1 · §2; cất thành cột riêng là phiên chọn
  2026-09-26.

### QD-32 — Mọi kết nối đọc mốc trong CÙNG một múi giờ, kể cả kết nối của môi trường test

- **Quy ước:** kết nối của môi trường chạy thật và kết nối của môi trường test đặt **cùng** một múi
  giờ phiên, viết tường minh ở cấu hình kết nối, không dựa vào mặc định của thư viện hay của máy.
- **Hậu quả nếu làm khác:** cùng một mốc, môi trường thật đọc ra một giờ, test đọc ra giờ khác. Dự án
  cũ lệch **7 tiếng chỉ trong test** (`nghien-cuu.md` §4.4), nên test đầu tiên của luật giờ bán sẽ đỏ
  mà không ai hiểu vì sao — hoặc tệ hơn, **xanh nhầm**.
- **Phép kiểm:** một lệnh in múi giờ của phiên kết nối ở **cả hai** môi trường ⇒ hai dòng giống hệt.
  **Cách viết (`P2-12`, 2026-09-27):** hàm `qd32` trong `scripts/db-check.sh` in múi giờ ở
  `shop-facts.md` §1 và múi giờ mà kết nối của bộ kiểm thật sự đọc ra. Múi giờ mặc định của server
  cố ý để **UTC**, nên một kết nối quên đặt múi giờ lộ ra ngay. Vế *môi trường chạy thật* chờ kết
  nối của backend — chỗ trống có tên ở `10-quy-uoc-code.md` `QC-06`.
- **Nguồn:** phiên chọn 2026-09-26, bài học dự án cũ đưa vào ở T-097.

### QD-33 — Mốc tính tiền có một tên duy nhất, `booked_at`, và không dời

- **Quy ước:** bản ghi của mỗi việc chạm tiền ở bảng §2 của `02-thoi-gian-ngay-ban.md` mang **đúng
  một** cột mốc tính tiền, tên `booked_at`, ở mọi lát. Không tên đồng nghĩa. Giá trị do **nơi ghi**
  cấp (§3), trừ đúng một ca: lượt **nhập bù** từ sổ giấy mang mốc **buổi bán trên giấy** (§2, **ADR-037**)
  — khi ấy `booked_at` là mốc người khai, còn `created_at` (`QD-34`) là mốc gõ vào máy, hai mốc đọc
  riêng được. Sửa một khoản đã ghi **không** đổi `booked_at` của nó: sửa là một việc mới, mang mốc
  của chính nó (§2.2, `YC-20`).
- **Hậu quả nếu làm khác:** mỗi lát đặt một tên, và `I-014` — phép cộng *doanh thu một ngày từ đủ hai
  nguồn* — phải đoán cột nào là mốc tính tiền ở từng lát. Một mốc tính tiền dời được là một thao tác
  hôm nay rút tiền ra khỏi ngày hôm qua, sau khi chủ quán đã ký đối soát.
- **Phép kiểm:**
  ```sql
  SELECT table_name, column_name
  FROM information_schema.columns
  WHERE table_schema = :schema
    AND column_name <> 'booked_at'
    AND (column_name LIKE '%book%' OR column_name LIKE '%account%' OR column_name LIKE '%post%');
  ```
  Vế *không dời* đọc bằng vết cập nhật (`YC-13`) và thuộc `P2-08` · `P2-11`: mọi lần cập nhật đổi
  `booked_at` của một bản ghi đã có ⇒ **0 dòng**.
- **Nguồn:** owner cho nghĩa — `02-thoi-gian-ngay-ban.md` §2 · §2.2 · §3, `04-yeu-cau-du-lieu.md`
  `YC-18` · `YC-20`; tên do phiên chọn 2026-09-26.

### QD-34 — Mọi bảng có `created_at`, do database cấp lúc ghi

- **Quy ước:** mỗi bảng có `created_at`, giá trị mặc định là đồng hồ của **database** lúc ghi; không
  nhận giá trị từ máy gửi yêu cầu tới.
- **Hậu quả nếu làm khác:** mốc lấy từ điện thoại của khách hay từ từng màn hình trong quán thì đồng
  hồ của máy ấy quyết định bản ghi thuộc lúc nào (`02-thoi-gian-ngay-ban.md` §3 hệ quả 1 · 2). Một
  bảng thiếu `created_at` là một bảng không dựng lại được *cái gì xảy ra trước cái gì* lúc đối soát.
- **Phép kiểm:**
  ```sql
  SELECT t.table_name
  FROM information_schema.tables t
  WHERE t.table_schema = :schema AND t.table_type = 'BASE TABLE'
    AND NOT EXISTS (
      SELECT 1 FROM information_schema.columns c
      WHERE c.table_schema = t.table_schema AND c.table_name = t.table_name
        AND c.column_name = 'created_at' AND c.column_default IS NOT NULL);
  ```
- **Nguồn:** owner — `02-thoi-gian-ngay-ban.md` §3 (*một nguồn, ở nơi ghi*); tên do phiên chọn.

---

## 5. Trạng thái — `QD-40`

### QD-40 — Trạng thái là một mã chữ ASCII trong cột `status`, giới hạn bằng ràng buộc kiểm, ánh xạ về đúng tên ở owner

- **Quy ước:** cột `status` cất một **mã chữ** (`QD-01`), không cất số thứ tự. Tập mã được phép liệt
  kê trong một ràng buộc kiểm. Mỗi mã ánh xạ về **đúng một** tên trạng thái ở bảng vòng đời của owner
  (`docs/product/0-ba/ban-hang/05-vong-doi.md` §5.2 · §5.3 · §5.4), và bảng ánh xạ ấy nằm ở file lát
  tạo cột. Chuyển trạng thái nào được phép là việc của owner và của `I-016`, không phải của mục này.
- **Hậu quả nếu làm khác:** trạng thái cất bằng số thì chen một trạng thái vào giữa làm đổi nghĩa mọi
  dòng cũ. Không có ràng buộc kiểm thì một trạng thái **không có** trong bảng vòng đời ghi được vào
  dữ liệu — đúng thứ `I-016` cấm. Mã không ánh xạ về owner thì mỗi lát tự đặt một tên cho cùng một
  trạng thái, và bảng quầy đếm sai.
- **Phép kiểm:** (a) —
  ```sql
  SELECT c.table_name
  FROM information_schema.columns c
  WHERE c.table_schema = :schema AND c.column_name = 'status'
    AND (   c.numeric_precision IS NOT NULL
         OR NOT EXISTS (
              SELECT 1
              FROM information_schema.constraint_column_usage u
              JOIN information_schema.check_constraints k
                ON  k.constraint_schema = u.constraint_schema
                AND k.constraint_name   = u.constraint_name
              WHERE u.table_schema = c.table_schema AND u.table_name = c.table_name
                AND u.column_name = 'status'));
  ```
  (b) một lệnh: tập mã tách từ `check_clause` của ràng buộc ấy, so `comm -3` với cột *mã* của bảng
  ánh xạ ở file lát ⇒ **rỗng**, in cả hai danh sách chưa lọc (**F-017**). **Cách viết (`P2-12`,
  2026-09-27):** hàm `qd40b` trong `scripts/db-check.sh`; mỗi dòng của bảng ánh xạ ở file lát viết
  đúng dạng `` | `<bảng>.status` | `<mã>` | <tên ở owner> | ``, vì lệnh tìm dòng bằng ô đầu. Bảng có
  cột `status` mà không có dòng ánh xạ nào ⇒ lệnh **đỏ**.
- **Nguồn:** owner cho tập trạng thái — `05-vong-doi.md` §5, `quality/invariants.md` `I-016`; mã
  chữ và bảng ánh xạ là phiên chọn 2026-09-26.

---

## 6. Không xoá cứng — `QD-50`…`QD-51`

### QD-50 — Không bản ghi nghiệp vụ nào bị xoá cứng; database từ chối lệnh xoá của hệ thống

- **Quy ước:** vai mà hệ thống dùng để ghi (`:vai_ung_dung`) **không có** quyền xoá trên bảng nghiệp
  vụ nào. Những gì nghiệp vụ gọi là *bỏ* — ngừng bán một món, huỷ một đơn, đóng một phiên, lùi một mẻ
  bấm nhầm — đều là một trạng thái hoặc một mốc; lát nào cất nó bằng cách nào là việc của lát ấy.
  Chỉ bảng trong `:bang_ky_thuat` (không mang dữ liệu nghiệp vụ, mỗi tên một dòng lý do) được xoá.
- **Hậu quả nếu làm khác:** ngừng bán bằng cách xoá thì đơn cũ mất tên món và giá đã bán — đúng thứ
  `I-009` và `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.3.4 cấm (*biến khỏi menu, không biến khỏi
  đơn cũ*). Quán **không có nút hoàn tác**; cách sửa cái sai là **cập nhật** giữ cả hai phía
  (`I-018`, `YC-14`), và một lệnh xoá là một đường sửa **không để lại phía nào**. Vết chết theo bản ghi
  nó nói về thì `YC-12` hỏng đúng ở chỗ nó sinh ra để giữ.
- **Phép kiểm:**
  ```sql
  SELECT table_name, privilege_type
  FROM information_schema.table_privileges
  WHERE table_schema = :schema
    AND grantee IN (:vai_ung_dung, 'PUBLIC')
    AND privilege_type IN ('DELETE', 'TRUNCATE')
    AND table_name NOT IN (:bang_ky_thuat);
  ```
  PostgreSQL **có** liệt kê quyền xoá toàn bảng (`TRUNCATE`) trong `table_privileges`, nên không cần
  câu bổ sung. Vế `'PUBLIC'` thêm 2026-09-27 (`P2-12`): quyền cấp cho mọi vai cũng là quyền của
  `:vai_ung_dung`. Mặc định cấp quyền nằm ở `db/init/` (`10-quy-uoc-code.md` `QC-03`).
- **Nguồn:** owner — `I-009`, `I-018`, `04-yeu-cau-du-lieu.md` `YC-12` · `YC-14`, `03-lat-cat.md`
  §3.3.4; giữ bằng **quyền của database** là phiên chọn 2026-09-26. **Không** trả lời
  `work/findings.md` **F-034**: *mất hẳn bản ghi* vì hỏng máy là chuyện sao lưu, không phải chuyện
  lệnh xoá, và nhà của nó vẫn chờ chủ repo.

### QD-51 — Không khoá ngoại nào xoá hay cập nhật dây chuyền

- **Quy ước:** mọi khoá ngoại giữ quy tắc mặc định *từ chối* cho cả xoá lẫn cập nhật bản ghi cha;
  không quy tắc dây chuyền.
- **Hậu quả nếu làm khác:** một lần xoá nhầm ở một bảng kỹ thuật, hay một lệnh chạy tay lúc sửa sự cố,
  kéo theo bản ghi con ở bảng nghiệp vụ mà **không lệnh nào báo** — `QD-50` chặn lệnh xoá của hệ thống,
  mục này chặn đường vòng qua khoá ngoại.
- **Phép kiểm:**
  ```sql
  SELECT constraint_name, delete_rule, update_rule
  FROM information_schema.referential_constraints
  WHERE constraint_schema = :schema
    AND (delete_rule = 'CASCADE' OR update_rule = 'CASCADE');
  ```
- **Nguồn:** phiên chọn 2026-09-26, dựng để `QD-50` không có đường vòng.

---

## 7. Văn bản và định danh — `QD-60`…`QD-61`

Cách so và sắp xếp chuỗi (collation) chọn **theo vai trò cột**, không một cách cho mọi cột. Đổi cách
so **sau khi đã có dữ liệu** là dựng lại cả bảng lẫn mọi chỉ mục của nó, trên dữ liệu bán hàng thật
— nên đây là lượt rẻ nhất để làm đúng. Bằng chứng của dự án cũ: `nghien-cuu.md` §2.2.

### QD-60 — Văn bản cho người đọc: Unicode đầy đủ, so và sắp xếp đúng tiếng Việt

- **Quy ước:** cột văn bản mà người đọc (tên món, tên người, ghi chú, lý do) dùng bộ ký tự Unicode
  **đầy đủ** và cách so `:collation_van_ban` — sắp xếp theo đúng thứ tự chữ cái tiếng Việt.
- **Hậu quả nếu làm khác:** bộ ký tự thiếu thì một tên có ký tự ngoài vùng cơ bản bị cắt hoặc bị từ
  chối lúc ghi; cách so không theo tiếng Việt thì danh sách món ở màn quản trị sắp sai thứ tự, vì
  *ă â đ ê ô ơ ư* là chữ cái riêng chứ không phải *"a có dấu"*.
- **Phép kiểm:**
  ```sql
  SELECT table_name, column_name, collation_name
  FROM information_schema.columns
  WHERE table_schema = :schema
    AND data_type IN ('text', 'character varying', 'character')
    AND column_name NOT LIKE '%code' AND column_name NOT LIKE '%!_hash' ESCAPE '!'
    AND column_name <> 'status'
    AND COALESCE(collation_name, :collation_mac_dinh) NOT IN (:collation_van_ban);
  ```
  Cột văn bản ngắn mà không phải văn bản cho người đọc (mã trạng thái `QD-40`, mã giá trị `QD-02`) là
  **mã**. **Quyết định `P2-12` (2026-09-27):** mã đi theo `QD-61` — mã giá trị đã mang hậu tố `_code`,
  và `status` được thêm vào cả hai câu. Vế lọc cột văn bản đổi từ *có độ dài tối đa* sang *kiểu văn
  bản*: ở PostgreSQL kiểu `text` không có độ dài tối đa, và câu cũ bỏ sót đúng kiểu hay dùng nhất.
- **Nguồn:** phiên chọn 2026-09-26, bài học dự án cũ đưa vào ở T-097.

### QD-61 — Định danh máy đọc và chuỗi băm: so từng byte, phân biệt hoa thường

- **Quy ước:** cột `code` / `_code` (định danh máy đọc: mã hiển thị, mã QR của bàn theo `I-023`,
  dựng ở `T-114`) và cột `_hash` (chuỗi băm) dùng cách so `:collation_so_byte` — so **từng byte**, **phân biệt
  hoa thường**, không coi hai chữ khác nhau là một.
- **Hậu quả nếu làm khác:** cách so *không phân biệt hoa thường, không phân biệt dấu* coi nhiều định
  danh khác nhau là **bằng nhau**, nên hai mã khác nhau va nhau ở một khoá duy nhất và một trong hai
  không ghi được. Một chuỗi băm so lỏng là một chuỗi băm yếu đi: phiên sau viết một phép so bằng
  truy vấn là mở cửa cho một chuỗi *gần đúng* đi qua.
- **Phép kiểm:**
  ```sql
  SELECT table_name, column_name, collation_name
  FROM information_schema.columns
  WHERE table_schema = :schema
    AND (column_name = 'code' OR column_name LIKE '%!_code' ESCAPE '!'
         OR column_name LIKE '%!_hash' ESCAPE '!' OR column_name = 'status')
    AND COALESCE(collation_name, :collation_mac_dinh) NOT IN (:collation_so_byte);
  ```
- **Nguồn:** phiên chọn 2026-09-26, bài học dự án cũ đưa vào ở T-097.

---

## 8. Chỗ trống có tên — cái file này cố ý không quyết

| Chỗ trống | Vì sao không quyết ở đây | Ai gỡ |
|---|---|---|
| Luật **làm tròn** nếu một nghiệp vụ sau này cần chia tiền | U-058 đã xác định giảm theo số tiền nhập tay (2026-09-27), không phát sinh phép chia từ giảm phần trăm | Chốt với chủ quán khi có nghiệp vụ cần chia tiền; `master_plan/shop-facts.md` §8.9 |
| ~~DBMS · phiên bản · tên kiểu · mọi tham số ở §0~~ — **đã gỡ 2026-09-27**: PostgreSQL 17, tham số ở §0, tên kiểu ở `10-quy-uoc-code.md` `QC-04` | **ADR-053** luật 1 | `P2-12` (**ADR-054**) |
| Tên bảng, tên cột của từng lát | file migration thắng (**ADR-053** luật 2) | `P2-04`…`P2-08` |
| Đơn vị **lượng** (nguyên liệu tính theo cân, theo cái…) | Mục này chỉ nói tiền; lượng thuộc lane admin, luật còn đang thu | lane admin — `work/backlog_AD.md` |
| ~~Cách sinh mã QR của bàn~~ — **đã gỡ 2026-09-28 (`T-114`)**: một cửa `qr_code_issue`, mã từ nguồn ngẫu nhiên mạnh — [`02-luoc-do-ban-hang.md`](02-luoc-do-ban-hang.md) §2 hàng `I-023` | Pha 1 có mệnh đề từ 2026-09-28 (`quality/invariants.md` **I-023**, **ADR-060**) | `T-114` — xong |
| Mất hẳn bản ghi vì hỏng máy | Chuyện sao lưu, không phải chuyện lệnh xoá (`QD-50`) | pha 5 — YC-21 ở `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §8; T-109 (`work/backlog.md`), ADR-057 |

---

## 9. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2-12` | **xong 2026-09-27** — §0 đã điền; `QD-30` · `QD-32` · `QD-60` · `QD-61` đã có lựa chọn cụ thể ở `10-quy-uoc-code.md` `QC-04` · `QC-06` |
| `P2-04`…`P2-08` | mọi mục; mỗi lát chạy lại cả bộ sau khi dựng, dán output vào *Bàn giao*; bảng ánh xạ trạng thái (`QD-40`) và danh sách `:bang_ky_thuat` · `:bang_khong_quan_he_so_hoc` nằm ở file lát |
| `P2-06` | `QD-20` · `QD-21` · `QD-22` · `QD-31` · `QD-33` — lát tiền là lát đọc mục này nhiều nhất |
| `P2-11` | gom mọi phép kiểm thành một nhóm mang mã `QD-XX`, chứng minh từng phép biết kêu |

**Mâu thuẫn với một mục pha 1 thì gửi ngược một `F-XXX`, không viết bản thứ hai ở đây**
(`master_plan/DB_master_plan_banh_cuon_ba_thanh.md` §5).
