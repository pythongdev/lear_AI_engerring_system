# Lược đồ lát người · chỗ đứng theo thời điểm · vết — ai đứng quầy lúc nào, ai bấm, bản trước và bản sau

Pha 2 · bước `P2-08` · viết 2026-09-28 (Claude Code). File này **thêm** một tên vào hàng *Schema* của
`CLAUDE.md` §2; nó không ghi đè lát nào trước nó (`master_plan/DB_master_plan_banh_cuon_ba_thanh.md`
§6, *Chạy song song được*).

**Bản nào thắng** (`docs/decisions.md` **ADR-053** luật 2): tên bảng · tên cột · kiểu · ràng buộc
thuộc file migration
[`db/migrations/20260928140000_nguoi_va_vet.up.sql`](../../../db/migrations/20260928140000_nguoi_va_vet.up.sql).
File này giữ **ý định, lý do và ánh xạ** sang `I-0xx` / `YC-xx`. Nó nhắc tên bảng và tên ràng buộc
để trỏ, **không** chép lại kiểu hay điều kiện thành bản thứ hai (**F-001**). Hai bản lệch nhau ⇒ một
dòng `F-XXX`, không lặng lẽ sửa bên nào.

**File này KHÔNG sở hữu:**
- **luật nghiệp vụ và tầng bảo vệ** — `quality/invariants.md` và
  `docs/product/1-system-design/03-bao-ve-invariant.md` hàng `I-012` · `I-018`. Lát này thi hành
  tầng đã chốt, không nâng, không hạ (**ADR-050** luật 1) — chỗ duy nhất chưa thi hành đủ có tên:
  **F-046** (§3);
- **mảng con người của quản trị** — chấm công, lương, vai thường lệ của từng người, ai được xem gì
  (`shop-facts.md` §8.7, `work/backlog_AD.md`). Lát này chỉ dựng **người** và **ai đứng quầy lúc
  nào** — chỗ giao nhau kế hoạch pha 2 §3 hẹn trước; lane admin dùng lại, không dựng lại;
- **quyền theo vai** — ai được huỷ, hoàn, đổi mã QR, đổi giá — pha 3 (**ADR-035**). Lát này để lại đủ
  dữ liệu để hỏi câu ấy: người bấm, và người đang đứng quầy lúc bấm;
- **câu truy vấn đối chiếu** chạy mỗi tối — `P2-11`, [`09-doi-chieu-bat-bien.md`](09-doi-chieu-bat-bien.md);
- **cất bằng gì** — [`01-quy-uoc-du-lieu.md`](01-quy-uoc-du-lieu.md) (lượt này thêm vai trò `_image`
  ở `QD-03` và phép kiểm **`QD-52`**); **dựng và kiểm bằng gì** —
  [`10-quy-uoc-code.md`](10-quy-uoc-code.md) (lượt này thêm kiểu `jsonb` ở `QC-04`).

---

## 0. Cách đọc

Cùng hai nguồn như §0 của [`02-luoc-do-ban-hang.md`](02-luoc-do-ban-hang.md): **owner** · **phiên chọn
2026-09-28** (lựa chọn thiết kế của lượt này, chưa có lời chủ repo — trừ chế độ của vết cập nhật, chủ
repo chọn trong phiên: **chế độ mềm + F-046**).

**Người thao tác của một giao dịch** — một ý xuyên cả lát. Mỗi giao dịch ghi khai *ai đang thao tác*
bằng cài đặt giao dịch `shop.actor_person_id` (`set_config(…, true)` — sống tới hết giao dịch).
Mọi cột **ai bấm** lấy mặc định từ đó; giao dịch không khai thì cột trống và `NOT NULL` từ chối lần
ghi — đó là tầng 1 của `I-012`. Ghi tường minh vẫn được: người đi giao thu tiền tại chỗ khách do POS
khai tên (`shop-facts.md` §8.8, `U-057`). Vết cập nhật đọc cùng cài đặt ấy cho **người sửa**, cộng
`shop.revision_reason` cho **lý do**. *Phiên chọn 2026-09-28*: một nguồn cho người thao tác, thay vì
mỗi lệnh ghi tự truyền — một lệnh quên truyền thì database từ chối, không ghi trống.

**Bằng chứng** của mỗi hàng ở §2 là một file ở `db/tests/`, chạy trong `./scripts/db-check.sh`
(`QC-07`). Mười lăm file test của các lát trước nay mở bằng một khối khai người thao tác — không có
nó, chúng không ghi được thao tác chạm tiền, mẻ hay mã QR nào.

---

## 1. Bốn bảng — mỗi bảng giữ gì, và vì sao có nó

| Bảng | Giữ gì | Vì sao là một bảng riêng · nguồn |
|---|---|---|
| `person` | **một người của quán** — tên hiển thị, và cờ **chủ quán** | owner: `shop-facts.md` §3 (bốn vai, cộng chủ quán là vai riêng ngoài năm trạm), §8.7 (*người mà ba mức đếm là người của §3*). Chủ quán là một **cờ trên người**, không phải một chỗ đứng: đứng quầy thì có thêm quyền của quầy, cờ vẫn nguyên (`YC-16`). **Không** có cột chức vụ nào khác — chức vụ không mở cửa nào (`YC-04`); vai thường lệ, lương, công là lane admin |
| `counter_duty` | **một khoảng một người đứng quầy** — ai, từ lúc nào, tới lúc nào (trống = đang đứng) | owner: `shop-facts.md` §8.8 (`C36`: *ghi cả mốc đổi, ai vào ai ra lúc mấy giờ*; `U-056`: POS khai), `YC-15`. Khoảng, không phải một ô *đang trực* bị ghi đè — ghi đè xoá đúng lịch sử `YC-15` đòi. **Chỉ trạm quầy**: bốn trạm còn lại **không** ghi mốc đổi (`U-055`, chủ quán chốt 2026-09-25) |
| `paper_ledger` | **sổ giấy của một ngày mất điện** — ngày bán, số lượt đã ghi trên giấy, người khai | owner: `shop-facts.md` §6.11 (người giữ sổ và người nhập lại: POS hoặc chủ quán; bảng đối soát phải đọc được *"còn N lượt bán trên giấy chưa nhập"*), **ADR-037**, `YC-08`. *Còn N* là một phép trừ cần **số đã ghi trên giấy** — con số ấy phải có chỗ cất, và chỉ người giữ sổ biết nó. Tên `ledger`, không `book`: `QD-33` cấm mọi tên đồng nghĩa với `booked_at` |
| `record_revision` | **vết một lần sửa** — bảng nào, dòng nào, **bản trước**, **bản sau**, **lý do**, **người sửa**, lúc nào | owner: `I-018` (*bản copy trước và sau*, chủ quán chốt 2026-09-02, `shop-facts.md` §6.22), `YC-13` · `YC-14`. **Một** bảng cho mọi bảng: bản chụp là `jsonb` của cả dòng (`QC-04`), nên bảng mới về sau có vết mà không cần bảng vết mới. Không khoá ngoại về bản ghi gốc — vết sống khi bản gốc mất (`YC-12`) |

**Cột thêm vào bảng của lát trước** (migration mới, file cũ không sửa — `QC-05`):

| Bảng · cột (của lát trước) | Nhận gì | Vì sao |
|---|---|---|
| `bill` · `debt_collection` · `prepayment` · `refund` · `opening_float` — cột thêm | `person_id` **bắt buộc**, mặc định người thao tác của giao dịch | `I-012` tầng 1 — *ai bấm* của lần thu · ghi nợ · thu nợ · nhận trả trước · hoàn · khai đầu két ([`04-luoc-do-duong-tien.md`](04-luoc-do-duong-tien.md) §5 hàng *ai bấm*) |
| `production_batch` — cột thêm | `made_by_person_id` bắt buộc; `rolled_back_by_person_id` có **khi và chỉ khi** mẻ đã lùi | `YC-07` — *lùi mẻ nào · mấy giờ · **ai*** ([`05-luoc-do-san-xuat.md`](05-luoc-do-san-xuat.md) §5) |
| `station_job_transfer` — cột thêm | `person_id` bắt buộc — người chọn bàn nhận | `I-004` tầng 4 — máy không ngăn quầy chọn nhầm, máy giữ vết **có tên** |
| `qr_code` — cột thêm | `person_id` bắt buộc — người cấp / đổi mã; cửa `qr_code_issue` **không đổi chữ ký**, nó ghi người của giao dịch | `I-023` · `YC-24` vế *ai đổi* ([`02-luoc-do-ban-hang.md`](02-luoc-do-ban-hang.md) §5) |
| `bill` — cột thêm | `paper_ledger_id` · `paper_entry_count` (bản soi) · `paper_position` — hoá đơn nhập bù là lượt thứ mấy của sổ nào | `YC-08` — §2 |

Tên tiếng Anh, số ít (`QD-01`). `person` chứ không `staff`: chủ quán và người nhà làm không lương
(`shop-facts.md` §8.7 `C24`) cũng là người của quán — phiên chọn 2026-09-28.

---

## 2. Mệnh đề → cái giữ nó trong lược đồ → bằng chứng

Tầng ở cột thứ hai là tầng **pha 1 đã chốt** (`03-bao-ve-invariant.md` hàng `I-012` · `I-018`); `YC-xx`
là yêu cầu hình dạng (`04-yeu-cau-du-lieu.md` §1 · §3 · §4). Tên ở cột thứ ba là tên ràng buộc
(`QC-10`).

| Mệnh đề · vế | Tầng | Lược đồ giữ bằng | Bằng chứng |
|---|:--:|---|---|
| **`YC-15`** — ai đứng quầy đọc được tại một thời điểm đã qua | — | `counter_duty`: khoảng `[vào, ra)`; một lần đổi là người ra khép khoảng và người vào mở khoảng ở **cùng một mốc**, nên đúng mốc đổi đọc ra người **vào**. `counter_duty_one_at_a_time_excl` — hai khoảng không chồng nhau: ở một thời điểm có **đúng một** câu trả lời (`shop-facts.md` §3 — trạm riêng, một người), kể cả ca người vào khi người trước quên khép. `counter_duty_ended_after_started_check` | `db/tests/yc15_counter_duty_by_time.sql` — `06:10 A` · `08:29 A` · `08:30 B` · `10:00 chủ quán` |
| **`YC-16`** — chủ quán đứng quầy thì hai vai cộng vào nhau | — | cờ `person.is_owner` không đổi theo chỗ đứng; một khoảng `counter_duty` của chủ quán **thêm** quyền của quầy. Không có ô *vai hiện tại* nào để vai này thay vai kia | cùng file — *chủ quán lúc 10:00: đang trực quầy t, quyền quản trị t* |
| **`YC-17`** — năm trạm, bốn vai; không đòi năm người | — | không bảng nào nối người với bốn trạm ngoài quầy, nên không gì đòi đủ người cho từng trạm; `canh` + `don_ban` chung một người là chuyện của lane admin khi nó ghi vai thường lệ. Không ghi mốc đổi ở bốn trạm ấy là **lời chủ quán** (`U-055`), không phải chỗ thiếu | cùng file — *bảng ghi mốc đổi người: counter_duty — chỉ trạm quầy* |
| **`YC-04`** — mỗi lần huỷ · hoàn · ghi nợ · thu nợ đọc ra **người đang trực lúc ấy** | — | thao tác mang **người bấm** và **mốc** (`booked_at`); người đang trực là phép tra `counter_duty` tại mốc ấy. Hai thứ đọc riêng, nên *chủ quán không đứng quầy mà tự bấm* hiện ra được | `db/tests/i012_money_operation_names_a_person.sql` — *refund … người bấm: chủ quán, đang đứng quầy: A* |
| **`I-012`** vế *hình dạng vết: thiếu ai bấm thì không tồn tại được* | 1 | `person_id` `NOT NULL` (khoá ngoại về `person`) trên `bill` · `debt_collection` · `prepayment` · `refund` · `opening_float` · `station_job_transfer` · `qr_code`; `made_by_person_id` trên `production_batch`; `production_batch_rolled_back_by_iff_rolled_back_check`. *Cái gì · bao nhiêu · lúc mấy giờ* đã là cột bắt buộc từ `P2-06` | cùng file — tám lời `null value in column "person_id" …` / `"made_by_person_id"` / check lùi mẻ; `i004_…` — lần chuyển không người chọn |
| **`I-012`** vế *cái tên trong vết là người thật đã bấm* | 4 | máy **không** ngăn hai người dùng chung một chỗ đứng (hàng pha 1). Cái máy giữ thay vào: người bấm và người đứng quầy lúc bấm cùng đọc được, nên câu đối chiếu *thao tác ở quầy mà người bấm không phải người đứng quầy lúc ấy* chỉ ra đúng một dòng. Hai ca không bấm ở quầy đứng ngoài tập: hoá đơn **đơn giao tận nơi** (người đi giao) và hoá đơn **nhập bù** (người nhập) | cùng file — tập rỗng trước khi cài lỗi; chủ quán tự hoàn khi không đứng quầy ⇒ *refund …: người bấm chủ quán, người đứng quầy lúc ấy A* |
| **`I-018`** vế *hình dạng vết: thiếu một trong bốn thứ thì không tồn tại được* | 1 | `record_revision`: `before_image` · `after_image` · `reason` · `person_id` `NOT NULL`; `record_revision_reason_not_blank_check`; `record_revision_images_of_target_check` (hai bản chụp là của đúng dòng ấy); `record_revision_changes_something_check`; `record_revision_target_table_code_check` | `db/tests/i018_revision_before_after.sql` — sáu lời từ chối |
| **`I-018`** vế *vết ghi cùng giao dịch với lần sửa* | 2 | trigger `record_revision_capture` (`AFTER UPDATE`, mọi bảng trừ bảng vết) chụp bản trước và bản sau **trong cùng câu lệnh** với lần sửa, khi giao dịch đã khai lý do — cắt giữa chừng thì không nửa nào sống; khai lý do mà không khai người sửa thì **lần sửa bị từ chối cùng vết**. `QD-52` kiểm mọi bảng mang trigger ấy và nó đang bật. **Chế độ mềm:** sửa không khai lý do thì đi qua mà không vết — **F-046**, §3 | cùng file — *cắt giữa chừng — số điện thoại 0922222222, số vết 2 (trước khi cắt 2)*; *sửa có lý do, không người sửa* bị từ chối; *chế độ mềm: 0 vết* |
| **`I-018`** vế *lần **thêm** một dòng con vào bản ghi đã có cũng giữ bản trước, bản sau, lý do, người* — món vào đơn đã tạo · thành phần vào suất đã có · xấp mệnh giá vào tiền đầu két đã khai (bổ sung 2026-10-05, `T-137`, **ADR-081**, gỡ **F-047**) | 2 | trigger `record_revision_capture_added_line` (`AFTER INSERT` trên `order_line` · `menu_item_component` · `opening_float_line`): dòng có mốc tạo **muộn hơn** bản ghi cha, trong giao dịch đã khai lý do, để lại một vết trên **bản ghi cha** — bản trước là cha cùng các dòng con có trước dòng ấy (khoá tên bảng con), bản sau thêm đúng dòng ấy. Dòng ghi cùng lúc với cha là nội dung lúc tạo, không vết. Cùng **chế độ mềm** với dòng trên: không khai lý do thì không vết, và ba câu `I-024/3` · `I-011/1` · `I-021/7` gọi tên lần thêm ấy. Bản thắng: [`db/migrations/20261005130000_vet_them_dong_con.up.sql`](../../../db/migrations/20261005130000_vet_them_dong_con.up.sql) (bước 17) | `db/tests/i018_added_line_leaves_trail.sql` — *thêm order_line vào sales_order — 1 dòng → 2 dòng*; *dòng ghi cùng lúc với cha: 0 vết*; *chế độ mềm: 0 vết*; *thêm có lý do, không người* bị từ chối |
| **`I-018`** · **`YC-13`** — dựng lại bản trước, bản sau; ca **hai người ghi đè** | 1 · 2 | bản chụp cả dòng; lần đè của người sau có bản trước **là** bản của người trước | cùng file — *trước 0900000009, sau 0911111111 … B* · *trước 0911111111, sau 0922222222 … C*; *bản của B dựng lại từ vết của C: 0911111111* |
| **`YC-12`** — vết sống độc lập với bản ghi nó nói về | — | không khoá ngoại từ vết về bản gốc (`QD-03`: cột trỏ nhiều bảng không mang `_id`); vai `shop_app` không xoá (`QD-50`), **không sửa** và **không chèn thẳng** được vết — vết chỉ sinh qua trigger, chạy bằng quyền chủ lược đồ (`SECURITY DEFINER`; review độc lập 2026-09-29 tìm ra một vết bịa chèn được trước khi sửa) | cùng file — *bàn … đã xoá — vết vẫn đọc: "test-9" → "test-9b"*; `permission denied for table record_revision` khi sửa và khi chèn thẳng; *shop_app sửa ⇒ vết qua trigger* |
| **`YC-14`** — không có nút hoàn tác; sửa là cập nhật giữ hai phía | 2 | cùng trigger: mọi lần cập nhật — kể cả lùi mẻ, đổi trạng thái đơn, đổi giá — có khai lý do thì giữ cả hai phía | cùng file — chủ quán *đổi giá — trước 900, sau 1000* |
| **`QD-33`** vế *mốc tính tiền không dời* (giao cho `P2-08` · `P2-11`; câu `QD-33/b`, 2026-09-30) | 5 | đọc từ vết: lần sửa có `booked_at` ở bản trước khác bản sau | cùng file — tập rỗng; một lần dời mốc có khai lý do ⇒ *bill …: mốc 2026-09-28… → 2026-09-27…* |
| **`YC-08`** — lượt nhập bù mang hai mốc đọc riêng, người nhập bù, *còn N lượt* | 1 | `booked_at` · `sale_date` là giờ bán trên giấy; `created_at` là lúc gõ; `person_id` là **người nhập bù**, còn **người bán** là người đứng quầy lúc `booked_at` — hai người đọc riêng. `bill_paper_ledger_fkey` (ba cột, hoãn) buộc ngày bán của hoá đơn **bằng** ngày của sổ — lượt nhập bù không rơi vào ngày gõ — và bản soi số lượt bằng sổ; `bill_paper_position_in_range_check` · `bill_paper_position_key` — không vượt, không nhập một lượt hai lần; `bill_paper_columns_check`. `paper_ledger_one_per_day_key` · `paper_ledger_entry_count_positive_check`. *Còn N* = số khai − số hoá đơn của sổ: một phép trừ, không ô ghi tay | `db/tests/yc08_paper_backfill_two_moments.sql` — *ngày bán 2026-09-27, gõ ngày 2026-09-28, người nhập bù B, người đứng quầy lúc bán A*; *sổ khai 3 lượt, còn 1*; bảy lời từ chối |

**Vì sao người thao tác là một cài đặt giao dịch, và cái gì đã bị loại** (phiên chọn 2026-09-28).
`I-012` tầng 1 đòi *thiếu ai bấm thì không tồn tại được* trên **mọi** bảng tiền; tầng 2 của `I-018`
đòi người sửa nằm trong **cùng** câu lệnh với lần sửa — một trigger không nhận tham số từ lệnh ghi.
Một cài đặt giao dịch trả lời cả hai: cột ai bấm mặc định đọc nó, trigger vết đọc nó, và cả hai
**trống** khi giao dịch không khai. Bị loại:
- *mỗi lệnh ghi tự truyền `person_id`* — vẫn đúng khi làm tường minh, nhưng trigger không có đường
  nhận người sửa;
- *cột `counter_duty_id` thay cho người* — đọc được chỗ đứng, nhưng người đi giao (`U-057`) và chủ
  quán ở mặt quản trị không đứng quầy; một thao tác có hai cách nói người bấm là một đường ghi thứ hai;
- *người thao tác mặc định là người đang đứng quầy* — đúng thứ tầng 4 của `I-012` nói máy không biết
  được (hai người chung một chỗ đứng); đoán thay là xoá dấu vết của ca sai.

**Vì sao một trigger cho vết cập nhật, và cái gì đã bị loại** (phiên chọn 2026-09-28; chế độ do chủ repo
chọn). Tầng 1 của `ADR-050` là ba hình — khoá duy nhất, điều kiện kiểm, khoá ngoại — và không hình nào
bắt được *"lệnh cập nhật này có kèm vết không"*: câu ấy hỏi về **một lệnh**, không về một trạng thái.
Trigger là hình duy nhất chụp được bản trước **đúng** như nó nằm trong database, trong cùng câu lệnh.
`ADR-050` loại trigger vì *"bị tắt thì không lời từ chối nào xuất hiện"*; `QD-52` trả lời đúng vế ấy —
mọi bảng phải mang trigger và trigger phải đang bật, nếu không cổng đỏ. Bị loại:
- *bảng vết riêng cho từng bảng* — mỗi bảng mới là một bảng vết mới, và một lát quên dựng thì im lặng;
- *số phiên bản trên mỗi dòng + khoá ngoại hoãn về vết* — giữ được *đã tăng phiên bản thì có vết*,
  nhưng không gì buộc một lần sửa phải tăng phiên bản; và nó thêm một cột vào mọi bảng;
- *chế độ nghiêm ngay* — từ chối mọi lần sửa không khai; chủ repo chọn hoãn (**F-046**): bật lúc này
  phải sửa mọi file test và dữ liệu mồi, gồm hai file đang mang thay đổi chưa commit của phiên khác.

---

## 3. Cái không phải tầng 1 — lược đồ nợ gì, pha 3 nợ gì

- **`I-018` — mọi lần sửa đều có vết (F-046, chế độ mềm).** Hôm nay một lần sửa **không** khai lý do
  đi qua mà không để lại vết. Vế ấy đang được giữ bởi cửa cập nhật của pha 3 (tầng 3) và một câu đối
  chiếu, **thấp hơn** tầng pha 1 đã chốt — chủ repo chọn có tên, không phải hạ tầng im lặng. **Gỡ:**
  một migration đổi `record_revision_capture` thành từ chối lần sửa không khai, cùng lượt mọi file
  test và dữ liệu mồi khai lý do — sau khi `i009` · `i013` của phiên khác đã commit và cửa pha 3 có.
- **Vết của đổi trạng thái — duyệt, huỷ, đóng phiên nhầm.** Chúng là lần cập nhật một dòng
  `sales_order` / `table_session`; khai lý do (*"duyệt"*, *"huỷ: khách đổi ý"*) thì vết giữ trạng
  thái trước, sau, người bấm. **Pha 3 nợ:** hàm xác thực chuyển trạng thái của `I-016` khai lý do mỗi
  lần — đây là chỗ phép đối chiếu của `I-016` (*dựng lại lịch sử chuyển trạng thái từ vết*) đọc.
- **Người bấm là người đang đứng quầy (`I-012` tầng 4).** **Pha 3 nợ:** cửa của POS khai người đang
  đăng nhập làm người thao tác. **`P2-11` (2026-09-30):** câu `I-012/3` *thao tác chạm tiền không
  đi qua một trong ba chỗ bấm có tên* ([`09-doi-chieu-bat-bien.md`](09-doi-chieu-bat-bien.md)).
- **Chỉ chủ quán đổi mã QR (`U-062`), chỉ người đứng quầy huỷ (§6.13).** Quyền theo vai — pha 3; lát
  này cất đủ để đối chiếu (`person.is_owner`, `counter_duty`).
- **Một ngày còn lượt trên giấy chưa nhập thì chưa đối soát xong (**ADR-037**).** *Còn N* đọc ra được
  (§2); **dấu *ngày đã đối soát xong*** có chỗ cất từ 2026-10-05 (`T-133`, `reconciled_day` ở
  [`04-luoc-do-duong-tien.md`](04-luoc-do-duong-tien.md) §7), và câu `I-014/5` gọi tên ngày đã bấm xong
  mà *còn N > 0* — phép trừ qua nhiều dòng, không ràng buộc nào giữ.

---

## 4. Mã trong lát này

Lát này **không** có cột `status` (không dòng ánh xạ `QD-40`) và không cột mã có owner (`QD-02`).
`record_revision.target_table_code` là **tên bảng** trong schema — mã máy đọc, cách so từng byte
(`QD-61`); chữ thường, số, gạch dưới (`record_revision_target_table_code_check`).

**Hai cài đặt giao dịch** — không phải cột, nên không thuộc `QD-03`; tên là phiên chọn 2026-09-28:

| Tên ở owner | Cài đặt |
|---|---|
| người thao tác của giao dịch | `shop.actor_person_id` |
| lý do của lần sửa | `shop.revision_reason` |

---

## 5. Chỗ trống có tên — cái lát này cố ý chưa giữ

| Chỗ trống | Lược đồ hôm nay đứng thế nào | Ai gỡ |
|---|---|---|
| **Chế độ nghiêm của vết cập nhật** | chế độ mềm — §3 | **F-046** (`work/findings.md`) |
| **Ai mở phiên, ai ghép bàn** (`I-012` liệt *ghép bàn* là thao tác chạm tiền) | `table_session_member` **chưa** có cột người: thêm cột bắt buộc vào nó là sửa gần hai mươi file test, gồm file của phiên khác. Lần ghép bàn **có** vết khi cửa ghép khai lý do (dòng phiên đổi) — nhưng dòng bàn mới gắn vào là một lần **thêm**, không phải sửa; trigger vết thêm dòng con của `T-137` (§2) **không** phủ bảng này (**ADR-081** *Không phủ*) | cùng lượt gỡ **F-046** |
| **Ai tạo đơn, ai sửa một dòng đơn** (`U-026`) | tạo đơn là thêm, không có vết sửa; sửa dòng có vết khi khai lý do. Người tạo đơn `staff_pos` chưa có cột | pha 3 quyết có cần; một migration mới |
| **Ai bấm *"đã ra bàn"*** | đơn vị bấm của mốc ấy là **số cái từng thứ, cho một bàn** (`S-5`, có lời 2026-10-09 — [`05-luoc-do-san-xuat.md`](05-luoc-do-san-xuat.md) §5) — không có bản ghi lần bấm nào để gắn người; lời không đòi vết từng lần bấm. Lần đổi trạng thái đơn vị có vết khi khai lý do | ~~chủ quán — `S-5`~~ có lời 2026-10-09 |
| **Người bán của một lượt nhập bù khi hôm ấy quầy không khai ai đứng** | người bán đọc từ `counter_duty` tại giờ bán trên giấy; hôm mất điện có thể không ai khai được mốc đổi | pha 3 · người giữ sổ khai bù khoảng trực nếu cần |
| ~~**Dấu *ngày đã đối soát xong*** và **số tiền mặt đếm được**~~ — **gỡ 2026-10-05 (`T-133`)** | [`04-luoc-do-duong-tien.md`](04-luoc-do-duong-tien.md) §7 (**ADR-079**) | `T-133` — xong |
| **Chấm công, lương, vai thường lệ, ai xem được bảng lương** | không dựng | lane admin (`work/backlog_AD.md`, `shop-facts.md` §8.7) |

**Tham số của `01-quy-uoc-du-lieu.md` §0:** lát này **không** thêm bảng nào vào `:bang_ky_thuat` (vết
không được xoá) và không bảng nào vào `:bang_khong_quan_he_so_hoc` — lát không có cột tiền.

---

## 6. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2-09` | file migration của lát này là file thứ tám của dãy; trigger vết gắn vào mọi bảng có mặt **lúc chạy** — bảng tạo sau phải tự gắn (`QD-52`) |
| `P2-10` | **xong 2026-09-28** — dữ liệu mồi thêm một người cho mỗi vai của `shop-facts.md` §3 và chủ quán, tên hiển thị là tên vai; chủ quán là người thao tác lúc cấp mã QR |
| `P2-11` | §2 cột *Bằng chứng*: câu *thao tác ở quầy mà người bấm không đứng quầy* (`i012_…`), câu *mốc tính tiền bị dời* (`i018_…`), *còn N lượt trên giấy* (`yc08_…`); phép đối chiếu của `I-016` đọc vết cập nhật |
| lane admin | `person` và `counter_duty` — dùng lại cho mảng con người, không dựng bảng người thứ hai |
| pha 3 | §0 người thao tác và lý do khai ở **mọi** giao dịch ghi; §3 ba chỗ *Pha 3 nợ*; gỡ **F-046** |
