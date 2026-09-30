# Lược đồ lát sổ nguyên liệu — danh mục và từng con số ngày do người nhập

Pha 2 · bước `P2A-02` · viết 2026-09-30 · thi công Codex, thiết kế Claude Code.
Quyết định: `docs/decisions.md` **ADR-071**. Lát này thêm một file, không ghi đè lát trước.

**Bản nào thắng** (`docs/decisions.md` **ADR-053** luật 2): tên bảng · tên cột · kiểu · ràng buộc
thuộc file migration
[`db/migrations/20260930100000_so_nguyen_lieu.up.sql`](../../../db/migrations/20260930100000_so_nguyen_lieu.up.sql).
File này giữ **ý định, lý do và ánh xạ** sang `I-0xx` / `YC-xx`; tên bảng và tên ràng buộc chỉ để
trỏ, không chép kiểu hay điều kiện thành bản thứ hai (**F-001**). Hai bản lệch ⇒ một dòng `F-XXX`.

**File này KHÔNG sở hữu:**
- **lời chủ quán** — `master_plan/shop-facts.md` §8.4; chỉ trỏ, không chép lời;
- **mệnh đề và tầng bảo vệ** — `quality/invariants.md` `I-025` · `I-026` và
  `docs/product/1-system-design/03-bao-ve-invariant.md` §5; yêu cầu dữ liệu ở
  `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §9 · §9.1;
- **người và cơ chế vết** — [`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md), dùng lại
  lát `P2-08`, kể cả chế độ mềm **F-046**: sửa không khai lý do chưa để lại vết;
- **quyền và cửa đọc tính tổng** — pha 3; **dữ liệu mồi** — `P2A-06`; **câu đối chiếu** — `P2A-07`;
- **quy ước cất và kiểm** — [`01-quy-uoc-du-lieu.md`](01-quy-uoc-du-lieu.md) ·
  [`10-quy-uoc-code.md`](10-quy-uoc-code.md); thứ tự và đường lùi ở
  [`07-thu-tu-migration.md`](07-thu-tu-migration.md).

---

## 0. Cách đọc

Hai nguồn: **owner** là mệnh đề, yêu cầu và lời chủ quán tại các con trỏ trên; **phiên chọn
2026-09-30 (ADR-071)** là lựa chọn thiết kế để thi hành chúng. Lựa chọn không thành lời chủ quán.
Các bằng chứng dưới đây là câu `NOTICE` của hai file trong `db/tests/`, chạy bằng
`./scripts/db-check.sh` (`QC-07`); chúng không thay câu đối chiếu của `P2A-07`.

---

## 1. Hai bảng — mỗi bảng giữ gì, và vì sao có nó

| Bảng | Giữ gì | Vì sao là một bảng riêng · nguồn |
|---|---|---|
| `supply_item` | một thứ trong danh mục hàng mua vào, tên và đơn vị mua khi đã biết | owner: `master_plan/shop-facts.md` §8.4 · `YC-26`; danh mục thêm dần, đứng độc lập với con số từng ngày |
| `supply_day_entry` | một con số của một thứ, một ngày, một loại; người nhập và lúc gõ của riêng con số ấy | owner: `I-025` · `YC-27` · `YC-28`; phiên chọn 2026-09-30: một dòng cho một con số để giữ riêng người và mốc |

**Một con số là MỘT dòng**, không phải một dòng một ngày mang hai cột. Hai con số của một ngày
có thể do hai người gõ ở hai lúc, và `I-025` đòi *ai · ngày nào · lúc nào* cho **từng** con số.

`entry_date` là ngày của con số, người ghi khai; `created_at` là lúc gõ, database cấp. Hai mốc đọc
riêng theo `YC-28`, cùng hình hai mốc của `YC-08`. Chữ *thời gian nhập* nghĩa nào vẫn là
**U-068** (`docs/product/99-unknowns.md`, còn mở); lát giữ cả hai, không chọn hộ nghĩa của lời ấy.

Người nhập là `person` của lát `P2-08`, lấy từ người thao tác của giao dịch qua
`actor_person_id()`. Không dựng danh sách người thứ hai. Cửa nhập khai người thao tác và lý do
sửa theo [`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md) §0.

Tên `supply_item`, không phải *ingredient* hay *stock*, là phiên chọn 2026-09-30: danh mục ở
`master_plan/shop-facts.md` §8.4 có cả túi, hộp, găng tay, dầu rửa bát; máy không giữ *tồn*.

---

## 2. Mệnh đề → cái giữ nó trong lược đồ → bằng chứng

Tầng theo `03-bao-ve-invariant.md` §5, không tự nâng hay hạ. Trong cột bằng chứng,
**test I-025** là `db/tests/i025_supply_numbers_entered_by_a_person.sql`, **test I-026** là
`db/tests/i026_supply_totals_from_day_entries.sql`; phần in nghiêng trỏ câu `NOTICE` của file ấy.

| Mệnh đề · vế | Tầng | Lược đồ giữ bằng | Bằng chứng |
|---|:--:|---|---|
| **`I-025`** — đủ ai · ngày · lúc gõ | 1 | các cột dấu người và hai mốc của `supply_day_entry`; `supply_day_entry_person_fkey`; người mặc định lấy từ giao dịch | test I-025 — *I-025 bị từ chối (không có người nhập)* · *(không có ngày của con số)* · *(người nhập không phải người của quán)*; *YC-28 con số* đọc riêng hai mốc |
| **`I-025`** — không thao tác bán hàng nào chạm | 3 | **không có gì nối** sổ với đơn · phiên · mẻ · tiền: không khoá ngoại, không hàm, không trigger dẫn từ bán hàng vào sổ. Giới hạn đã biết là sửa tay; buổi bán đủ năm kênh thuộc cổng `P2A-08` | test I-025 — *I-025 đọc lược đồ — 0 khoá ngoại sang đơn · phiên · mẻ · tiền, 0 hàm nhắc tới sổ, 0 trigger ngoài trigger vết*; *I-025 sau một đơn tạo · thu tiền · hoàn thành — sổ nguyên liệu không đổi* |
| **`I-025`** — máy không giữ thứ gì để tự tính | 3 | danh sách cột đóng của hai bảng; không chỗ cất ngưỡng, định lượng suất hay kết luận thiếu | test I-025 so danh sách cột từng chữ — *I-025 đọc lược đồ — supply_item* · *I-025 đọc lược đồ — supply_day_entry … không ngưỡng, không định lượng suất, không tổng cất sẵn* |
| **`I-025`** — sửa là cập nhật có vết | theo `I-018` | `supply_item_record_revision_trg` · `supply_day_entry_record_revision_trg` dùng `record_revision_capture()`; chế độ mềm **F-046**, §3 | test I-025 — *I-025 sửa con số — trước 7, sau 8*; *I-025 chế độ mềm — sửa không khai lý do: 0 vết mới (F-046)* |
| **`I-026`** — tổng là phép cộng, hiệu số là phép trừ | 1 | **không có chỗ cất tổng**; cùng hình bảng nhu cầu của `I-019` ở [`05-luoc-do-san-xuat.md`](05-luoc-do-san-xuat.md). Chỉ con số ngày được ghi; phép đọc hôm nay nằm trong test, §3 nói nợ cửa đọc | test I-025 — *I-025 đọc lược đồ — supply_day_entry*; test I-026 — *I-026 ba ngày — tổng đã nhập 15, tổng đã dùng 13, hiệu số 2*; *I-026 sau khi sửa một con số ngày — tổng đã nhập 15, tổng đã dùng 15, hiệu số 0* |
| **`I-026`** — cộng dồn, không đặt lại | 3 | không cột lô, không cột lần mua nào để lọc; một chỗ tính tổng của pha 3 còn nợ (§3) | test I-026 — *I-026 ba ngày … (ngày thứ ba mua thêm, tổng không đặt lại)*; test I-025 so danh sách cột |
| **`I-026`** — một thứ · một ngày · một đáp số | 1 | `supply_day_entry_one_kind_per_item_day_key` | test I-026 — *I-026 bị từ chối (hai con số mua vào cho một thứ, một ngày)* · *(hai con số đã dùng cho một thứ, một ngày)* |
| **`I-026`** — một thứ đứng một lần | 1 | `supply_item_name_key`; giới hạn so tên ở §5 | test I-026 — *I-026 bị từ chối (trùng tên trong danh mục)* |
| **`YC-26`** — đơn vị trống được; không ngưỡng, không định lượng | — | `supply_item`, `supply_item_name_not_blank_check` · `supply_item_purchase_unit_not_blank_check`; danh sách cột đóng | test I-025 — *YC-26 danh mục* có đơn vị *(trống)*; *YC-26 bị từ chối (tên chỉ có khoảng trắng)* · *(đơn vị mua chỉ có khoảng trắng — chưa có lời thì để TRỐNG)*; *I-025 đọc lược đồ* |
| **`YC-27`** — hai loại con số, không loại thứ ba | — | `supply_day_entry_kind_code_check` · `supply_day_entry_supply_item_fkey` · `supply_day_entry_measure_nonnegative_finite_check`; nhóm chỉ số công tơ đứng ngoài, giới hạn §5 | test I-025 — *YC-27 bị từ chối (loại con số thứ ba)* · *(thứ không có trong danh mục)* · *(con số âm)* · *(NaN)*; *I-025 bị từ chối (không có con số)* |
| **`YC-28`** — hai mốc và người nhập | 1 | ngày người khai và lúc gõ tách riêng; cùng các dấu của hàng `I-025` đầu bảng, không gộp hai nghĩa của thời gian nhập | test I-025 — *YC-28 con số* đọc tên người, ngày của con số và có lúc gõ |
| **`YC-29`** — hiệu số âm được nhận | — | hiệu số là kết quả đọc, không có chỗ cất hay ràng buộc bắt nó mang kết luận của máy | test I-026 — *I-026 đã dùng vượt tổng đã nhập — nhận, hiệu số -4* |

---

## 3. Cái không phải tầng 1 — lược đồ nợ gì, pha 3 nợ gì

- **Một chỗ tính tổng** là tầng 3 của `I-026`, thuộc cửa đọc pha 3: cộng mọi con số ngày của một
  thứ. Lát không dựng view hay hàm tổng. Bằng chứng hôm nay là phép cộng trong test I-026; chưa
  phải bằng chứng cửa đọc thật chỉ có một chỗ tính.
- **Cửa nhập khai người thao tác và lý do sửa.** Dấu người lấy từ giao dịch, vết sửa dùng lại cơ
  chế của `P2-08`; pha 3 phải khai đúng người thật và lý do, không suy người từ con số.
- **F-046 áp cả ở đây:** sửa không khai lý do vẫn đi qua mà không có vết. Đây là nợ chế độ mềm
  đã ghi ở `work/findings.md`, không phải đã thi hành đủ vế mọi lần sửa của `I-018`. Lát không
  đổi hàm vết hay tự dựng trigger nghiêm riêng; gỡ theo cùng lượt của lát người.

---

## 4. Mã trong lát này

Lát không có cột `status`. Mã của `kind_code` là **phiên chọn 2026-09-30 (ADR-071)**; owner chưa
viết mã máy đọc nào cho hai con số này nên `QD-02` không áp. Tên ở owner đọc tại
`master_plan/shop-facts.md` §8.4.

| Mã | Tên ở owner |
|---|---|
| `purchased` | mua vào |
| `used` | đã dùng |

---

## 5. Chỗ trống có tên — cái lát này cố ý chưa giữ

| Chỗ trống | Lược đồ hôm nay đứng thế nào | Ai gỡ |
|---|---|---|
| Đơn vị của các tên cũ, đơn vị ghi lượng đã dùng và quy đổi — `work/admin-questions.md` câu **B12** | `purchase_unit` trống được; cộng trừ đúng con số gõ. Nếu hai con số của một thứ ghi theo hai đơn vị thì vế hiệu số của `I-026` phải viết lại | chủ quán trả lời B12; Claude cập nhật owner |
| Hai tên chỉ khác hoa thường hay khoảng trắng, như *Gạo* · *gạo* | khoá duy nhất so đúng từng chữ, không bắt các biến thể ấy; cùng khuôn danh mục menu. Đây là phiên chọn 2026-09-30 | pha 3 chuẩn hoá ở cửa nhập nếu cần |
| Con số không âm và hữu hạn | **phiên chọn**, không phải lời chủ quán; theo khuôn `QC-04`: không âm là ràng buộc kiểm của lát. Sửa con số gõ nhầm bằng cập nhật có vết, không bằng số âm | thiết kế ADR-071; cửa nhập pha 3 dùng cùng vết |
| Ngừng dùng một thứ trong danh mục | chủ quán chưa nói; không cột trạng thái hay cờ nào, không xoá cứng (`QD-50`) | chủ quán; Claude ghi quyết định khi có lời |
| Chỉ số công tơ điện · nước (`YC-27`) | đứng ngoài cặp số này; không dựng chỗ cất riêng. Máy **không ngăn được** một người gõ một cái tên như thế vào danh mục | chỗ người giữ, không giả là ràng buộc đã có |
| Ai được nhập, ai được xem | lát cất người nhập, chưa quyết quyền | pha 3 |
| Lượng kiểm đếm cuối buổi, nợ nhà cung cấp, một thứ nhiều mối, giá vốn | không dựng; ranh giới ở `master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md` §6 | chủ quán và bước được kế hoạch giao |
| Dữ liệu mồi danh mục và câu đối chiếu `I-025` · `I-026` | lát đã có, dữ liệu mồi và câu cùng lỗi cài chưa có; [`09-doi-chieu-bat-bien.md`](09-doi-chieu-bat-bien.md) §2.1 giữ tên khoản nợ | `P2A-06` dựng mồi; `P2A-07` viết đối chiếu |

**Tham số của `01-quy-uoc-du-lieu.md` §0:** lát không thêm bảng nào vào `:bang_ky_thuat` hay
`:bang_khong_quan_he_so_hoc`.

---

## 6. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2A-06` | danh mục và đơn vị theo owner được trỏ ở §1 · §5; không tự điền đơn vị còn trống |
| `P2A-07` | §2 ánh xạ và giới hạn bằng chứng; viết câu đối chiếu cùng lỗi cài, sau dữ liệu mồi |
| `P2A-08` | §2: buổi bán đủ năm kênh không đổi sổ; đọc lược đồ để kiểm các chỗ máy không được giữ |
| pha 3 | §3 một chỗ tính tổng, khai người và lý do; §5 quyền, chuẩn hoá tên nếu cần, giới hạn đơn vị |
