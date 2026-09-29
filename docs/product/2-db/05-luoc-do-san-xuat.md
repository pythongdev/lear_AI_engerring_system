# Lược đồ lát sản xuất theo mẻ — việc trạm, mẻ, phần chia về từng bàn, phần đã làm của đơn huỷ

Pha 2 · bước `P2-07` · viết 2026-09-28 (Claude Code). File này **thêm** một tên vào hàng *Schema* của
`CLAUDE.md` §2; nó không ghi đè lát nào trước nó (`master_plan/DB_master_plan_banh_cuon_ba_thanh.md`
§6, *Chạy song song được*).

**Bản nào thắng** (`docs/decisions.md` **ADR-053** luật 2): tên bảng · tên cột · kiểu · ràng buộc
thuộc file migration
[`db/migrations/20260928130000_san_xuat_theo_me.up.sql`](../../../db/migrations/20260928130000_san_xuat_theo_me.up.sql).
File này giữ **ý định, lý do và ánh xạ** sang `I-0xx` / `YC-xx`. Nó nhắc tên bảng và tên ràng buộc
để trỏ, **không** chép lại kiểu hay điều kiện thành bản thứ hai (**F-001**). Hai bản lệch nhau ⇒ một
dòng `F-XXX`, không lặng lẽ sửa bên nào.

**File này KHÔNG sở hữu:**
- **luật nghiệp vụ và tầng bảo vệ** — `quality/invariants.md` và
  `docs/product/1-system-design/03-bao-ve-invariant.md` §2 hàng `I-004` · §4. Lát này **thi hành** tầng
  đã chốt, không nâng, không hạ (**ADR-050** luật 1);
- **trạm nào làm thành phần nào, và năng lực hai cái nồi** — `master_plan/shop-facts.md` §3 · §5.3 ·
  §5.4. Lược đồ là **chỗ cất** bảng trạm của thành phần; dữ liệu thật do `P2-10` dựng bằng cách tra
  owner. Nồi **không** có chỗ cất nào — máy không xếp nồi
  ([`04-yeu-cau-du-lieu.md`](../1-system-design/04-yeu-cau-du-lieu.md) §7);
- **ai bấm, chỗ đứng lúc bấm, vết của một lần sửa** — `P2-08` (§5);
- **cửa nổ đơn, cửa bấm mẻ, cửa chọn bàn nhận, hàm xác thực chuyển trạng thái** — pha 3
  (**ADR-035**, **ADR-050** điểm 3). Lát này chỉ đảm bảo mỗi cửa ấy có **một** đường ghi và để lại đủ
  dữ liệu để đối chiếu;
- **câu truy vấn đối chiếu** chạy mỗi tối — `P2-11`. Các câu ở cuối file test là bằng chứng lát này
  đọc ra được, không phải bộ đối chiếu;
- **cất bằng gì** — [`01-quy-uoc-du-lieu.md`](01-quy-uoc-du-lieu.md); **dựng và kiểm bằng gì** —
  [`10-quy-uoc-code.md`](10-quy-uoc-code.md). Lát bán hàng và lát menu mà lát này đứng lên:
  [`02-luoc-do-ban-hang.md`](02-luoc-do-ban-hang.md) · [`03-luoc-do-menu-gia.md`](03-luoc-do-menu-gia.md).

---

## 0. Cách đọc

Cùng hai nguồn như §0 của [`02-luoc-do-ban-hang.md`](02-luoc-do-ban-hang.md): **owner** (dịch một câu
đã chốt) · **phiên chọn 2026-09-28** (lựa chọn thiết kế của lượt này, **chưa có lời chủ repo** — đổi
được bằng một migration mới kèm lý do ở đây, trước khi code pha 3 dựa vào nó).

**Bằng chứng** của mỗi hàng ở §2 là một file ở `db/tests/`, chạy trong `./scripts/db-check.sh`
(`QC-07`). Ba file test của lát này cùng mở bằng một phần dựng chung — menu giả, và bốn hàm tạm
**đứng thay** cửa tạo lượt gọi, cửa nổ đơn và nút *"đã làm xong"* của pha 3 — để mỗi file tự đứng
được. Ràng buộc hoãn tới `COMMIT` được ép bằng `SET CONSTRAINTS … IMMEDIATE`, như ở
[`04-luoc-do-duong-tien.md`](04-luoc-do-duong-tien.md) §0.

**Một ý xuyên cả lát — mỗi dòng việc trạm là MỘT ĐƠN VỊ, và không có ô tổng nào.** Một cái bánh ở
một trạm, một quả trứng, một chiếc giò, một bát canh, phần nước chấm của một đơn: mỗi thứ một dòng
`station_job`. Việc *"Bánh cuốn ×6"* mà bảng bếp in ra là sáu dòng cùng thành phần đã chụp và cùng
trạm. Nhờ thế:
- mọi con số của bảng ở quầy — *đã gọi* · *còn phải làm* · *đã làm xong, còn ở bếp* · *đã bưng ra
  bàn* · *còn thiếu* (`03-lat-cat.md` §3.4.2) — của một bàn, một mẻ hay cả quán là **một phép đếm**
  trên các dòng ấy. Không bảng nào cất một con số tổng, nên không có hai con số để lệch nhau
  (`I-019` tầng 1, và `03-bao-ve-invariant.md` §4.3 đòi pha 2 **chọn** giữa *suy ra* và *lưu đệm
  cùng giao dịch*: lát này chọn **suy ra**);
- một mẻ làm **một phần** của một việc — bốn trong sáu cái bánh của một bàn, vì hai nồi chỉ tráng
  được bốn bánh một lần (`shop-facts.md` §5.4) — là chuyện thường, không phải ca đặc biệt: mẻ nhận
  bốn dòng, hai dòng còn lại vẫn *chưa làm*;
- *đã phục vụ ≤ đã gọi* thành **số dòng có được**: một (thành phần đã chụp, trạm) có nhiều nhất
  *số suất × số thành phần trong suất* dòng (`I-020` tầng 1, §2).

Cái giá: số dòng nhân lên theo số đơn vị. Một buổi sáng của một quán đơn lẻ là vài nghìn dòng, không
phải con số cần lo. *Phiên chọn 2026-09-28.*

---

## 1. Năm bảng — mỗi bảng giữ gì, và vì sao có nó

| Bảng | Giữ gì | Vì sao là một bảng riêng · nguồn |
|---|---|---|
| `menu_component_station` | **việc của một thành phần xuống trạm nào** — bánh cuốn và trứng xuống cả tráng lẫn gấp, giò chỉ xuống gấp, bát canh xuống trạm `canh` | owner: `shop-facts.md` §5.3 (ví dụ nổ đơn) · §3 (năm trạm). Là **dữ liệu menu**, nên đổi được mà không cần migration; lần nổ đơn đọc nó lúc duyệt. Mã trạm đúng từng chữ của §3 (`QD-02`). Nước chấm **không** có dòng ở đây: nó không phải thành phần của suất nào (§4.5), nó là việc **cấp đơn** |
| `station_job` | **việc trạm, một dòng một đơn vị** — của đơn nào, thành phần đã chụp nào của dòng đơn nào (hoặc là phần nước chấm của đơn), ở trạm nào, vị trí thứ mấy, và **trạng thái** (§4) | owner: `05-vong-doi.md` §5.4 (vòng đời việc trạm, ba trạng thái), `I-004` · `I-019` · `I-020`, `YC-06`. **Khoá gom không cất ở đây**: thành phần + loại nhân + lượng nhân đọc từ ảnh chụp của dòng đơn (`order_line_component`, `order_line_option` của `P2-05`) — một nguồn, không cột thứ hai để lệch. Chủ của đơn vị là **đơn**; bàn của nó là bàn gửi đơn — ghép bàn không đổi gì (`03-lat-cat.md` §3.4.4) |
| `production_batch` | **mẻ** — một lần quầy bấm *"đã làm xong"*: lúc bấm, và — nếu bấm nhầm — **lúc lùi** | owner: chủ quán chốt 2026-09-01 (`U-017`: *bấm theo mẻ*; `U-024`: *có đường lùi, không mốc thời gian cứng*), `YC-07`. Mẻ **không mang con số nào**: nó làm ra đúng những đơn vị có dòng ở bảng dưới. Lùi là một **mốc** trên chính mẻ, không phải lệnh xoá (`QD-50`) — mẻ nào · lúc nào đọc lại được sau nhiều ngày |
| `production_batch_item` | **một thứ một mẻ đã làm ra** — mẻ nào, **làm cho** đơn vị nào lúc bấm (không đổi), **chủ hiện tại** là đơn vị nào, và bản soi *mẻ đã lùi chưa* | owner: `YC-07` — *một lần bấm đọc ra được phần của từng bàn*; `I-020` tầng 2. Tách khỏi `station_job` vì một đơn vị có thể được làm **nhiều lần** (mẻ đầu bị lùi, mẻ sau làm lại) và một thứ đã làm có thể **đổi chủ** (đơn huỷ) — cả hai phải còn đọc được. Hai khoá ngoại hai chiều với `station_job` ở §2 |
| `station_job_transfer` | **lần chuyển** thứ đã làm xong của một đơn bị huỷ sang một đơn vị đang chờ của bàn khác — thứ nào, chủ cũ, chủ mới, lúc nào | owner: chủ quán chốt 2026-09-06 (`U-033`: *"tính vào bàn khác, pos sẽ cập nhật bánh này đem ra cho bàn nào"*), `I-004` vế tầng 4, `YC-07` vế *không biến mất mà không có lần cập nhật*. Là **vết**: bản trước (chủ cũ) và bản sau (chủ mới) trên một dòng |

Ba bảng của hai lát trước nhận **ràng buộc hoặc cột tự tính**, không nhận cột ghi — file migration của
chúng không bị sửa (`QC-05`):

| Bảng · cột (của lát trước) | Nhận gì | Vì sao |
|---|---|---|
| `sales_order` — cột thêm | `id_if_approved` — cột **tự tính**, là `id` khi đơn đã qua *Chờ xác nhận*, trống khi đơn ở *Mới* hay *Chờ xác nhận* | đích của khoá ngoại `station_job_sales_order_fkey` — §2 hàng `I-004` vế tầng 1 |
| `order_line` — ràng buộc thêm | khoá duy nhất (mã, đơn, số suất) | đích của khoá ngoại ba cột buộc bản soi *số suất* trên `station_job` bằng dòng đơn thật |
| `order_line_component` — ràng buộc thêm | khoá duy nhất (mã, dòng đơn, số lượng trong suất) | cùng lý do, cho *số thành phần trong một suất* |

Tên tiếng Anh, số ít (`QD-01`). *Mẻ* tên `production_batch` để đọc được nó là mẻ **làm ra**, không phải
một lô hàng nhập — phiên chọn 2026-09-28.

---

## 2. Mệnh đề → cái giữ nó trong lược đồ → bằng chứng

Tầng ở cột thứ hai là tầng **pha 1 đã chốt** (`03-bao-ve-invariant.md` §2 hàng `I-004` · §4); lát này
không đổi nó. Tên ở cột thứ ba là tên ràng buộc trong migration (`QC-10`) — lời từ chối của database
in đúng tên ấy. Đơn vị của bảng là **vế** (luật đọc 5 của file ấy).

| Mệnh đề · vế | Tầng | Lược đồ giữ bằng | Bằng chứng |
|---|:--:|---|---|
| **`I-004`** vế *đơn chưa duyệt sinh không việc nào* | 1 | `station_job_sales_order_fkey` trỏ tới cột tự tính `sales_order.id_if_approved`: việc trạm cho một đơn *Mới* hay *Chờ xác nhận* không ghi được; và vì đó là khoá ngoại **từ chối cập nhật**, một đơn đã có việc cũng không lùi về hai trạng thái ấy được | `db/tests/i004_station_jobs_follow_approval.sql` — đơn QR chưa duyệt: `0 việc` ở cả năm trạm |
| **`I-004`** vế *đơn đã duyệt sinh đủ việc, đúng số lượng* | 2 | ranh giới giao dịch: đổi đơn sang *Đang thực hiện* và ghi **mọi** dòng `station_job` của đơn là **một** giao dịch. Lược đồ giữ được **trần** của vế ấy (không đơn vị nào vượt số, hàng `I-020` dưới) nhưng **không** giữ được *đủ* — §3. Test cắt giữa chừng lần nổ: đơn còn *Đã xác nhận*, `0 việc` | cùng file — đơn hai suất nổ thành đúng hình `shop-facts.md` §5.3: bánh ×6 ở mỗi trạm tráng · gấp, trứng ×2, giò ×2, nước chấm ×1, canh ×2 |
| **`I-004`** vế *trạm `canh` không đi theo phép nhân* (**ADR-056**) | 2 | cùng giao dịch nổ đơn. **Nước chấm**: dòng cấp đơn (không dòng đơn, không thành phần); `station_job_one_sauce_per_order_key` giữ nửa **thừa** — nhiều nhất một phần mỗi đơn; nửa **thiếu** là cửa nổ đơn (§3). **Canh**: bát canh là thành phần của dòng *canh bánh cuốn*, nên số bát **bằng đúng** con số khách chọn qua cùng phép *số suất × số thành phần* (×1) — không suất nào mang sẵn bát canh (`shop-facts.md` §4.5, `U-048`) | cùng file — đơn không chọn canh: không việc canh nào, nước chấm vẫn ×1; đơn mang đi: nước chấm ×1 |
| **`I-004`** vế *đơn huỷ rút nhu cầu, việc CHƯA XONG* | 3 | không cột nào đánh dấu việc *rời bảng*: bảng nhu cầu **đọc** từ việc trạm của đơn **chưa huỷ**, nên đơn sang *Huỷ* là mọi việc chưa làm của nó rời bảng cùng lúc, qua **một** đường ghi (trạng thái đơn). Đơn vị ấy không bị xoá (`QD-50`) — hệ quả cho tập đối chiếu của pha 1: §5 hàng **F-044** | cùng file — sau khi huỷ, *còn phải làm* của bàn 5 trên bảng: `0`; đơn vị *chưa làm* của đơn đã huỷ còn trong lược đồ: `19` |
| **`I-004`** vế *đơn huỷ SAU KHI đã làm xong* — quầy chọn bàn nhận | 4 · 2 | **Tầng 4:** máy không ngăn quầy chọn nhầm bàn — không ràng buộc nào so khoá gom hai bên; cái máy giữ thay vào là **vết** `station_job_transfer`, và thứ đã làm chỉ đổi chủ được **kèm** một dòng vết ghi đúng thứ ấy và đúng chủ mới (`production_batch_item_transfer_fkey`, hoãn). **Tầng 2:** đổi chủ, bàn cũ nhả phần ấy, bàn nhận giảm nhu cầu — cùng sống hoặc cùng chết: `station_job_made_in_batch_fkey` từ chối bàn cũ còn giữ, `production_batch_item_live_station_job_fkey` từ chối bàn nhận chưa giảm | cùng file — ba lời từ chối; vết đọc lại: *trứng tái của mẻ … từ bàn 5 sang bàn 9*; bàn 9: *còn phải làm 0, đã làm xong còn ở bếp 1*; câu đối chiếu bắt lần chuyển sang bàn chờ **khác nhân** |
| **`I-019`** vế *tổng luôn khớp tổng phần chia*, cả hai chiều | 1 | **không có ô tổng nào** — mẻ và việc trạm không mang con số tổng; mỗi dòng nhu cầu và mỗi phần chia là **một phép đếm** trên cùng các đơn vị (§0). Không có trạng thái *tổng lệch phần chia* nào ghi được, vì không có con số thứ hai để ghi. *Mọi đơn vị có chủ*: `station_job.sales_order_id` `NOT NULL` | `db/tests/i019_demand_splits_back_to_tables.sql` — sáu bàn của `03-lat-cat.md` §3.4.3 ra đúng **sáu** dòng (bánh 18 · trứng 6 · bánh 18 · giò 6 · trứng 6 · nước chấm 6), tách ngược mỗi bàn đúng phần đã gọi; *sửa tay một dòng tổng*: `column "quantity" of relation "production_batch" does not exist` |
| **`I-019`** vế *khoá gom là ranh giới phép cộng* | 3 | khoá gom đọc từ **một** nguồn — ảnh chụp của dòng đơn, theo **mã gốc** của thành phần và tuỳ chọn (không theo tên hiển thị, `03-luoc-do-menu-gia.md` §1), và chỉ gộp tuỳ chọn nhân khi thành phần **nhận** nhân. Lược đồ không có cột khoá gom thứ hai nào để một đường tắt tự gộp hay tự tách. **Pha 3 nợ:** đúng **một** hàm gom | cùng file — thêm bàn 10 (§3.4.6): **mười** dòng; hai dòng bánh không gộp, giò **7**, nước chấm **7**; huỷ đơn bàn 9 ⇒ dòng bánh 18 → **15**, bàn 9 rời phần chia, hai chiều vẫn khớp |
| **`I-020`** vế *trần trên, kể cả trạng thái giữa* | 1 | đơn vị thứ *p* của một (thành phần đã chụp, trạm) chỉ có khi *p* ≤ số suất × số thành phần: `station_job_position_in_range_check` trên cột tự tính `unit_limit`, `station_job_position_key` (không vị trí nào hai lần). Hai bản soi số suất và số thành phần bị buộc bằng dòng đơn thật bởi `station_job_order_line_fkey` · `station_job_order_line_component_fkey` (hoãn) — khai sai để có chỗ cho đơn vị thừa thì không `COMMIT` được. Nước chấm: `station_job_one_sauce_per_order_key`. Vì *đã làm xong* và *đã bưng ra bàn* là **trạng thái của chính các đơn vị ấy**, cả *đã bưng ≤ đã gọi* lẫn *đã làm xong + đã bưng ≤ đã gọi* đúng theo cấu tạo | `db/tests/i020_served_never_exceeds_ordered.sql` — bánh thứ 4 của bàn gọi 3 · một đơn vị ghi hai lần · nước chấm thứ hai · bản soi khai 2 suất: bốn lời từ chối; gỡ trần trong một khối thử ⇒ câu đối chiếu in *gọi 3, đã làm 4* |
| **`I-020`** vế *một mẻ phủ nhiều bàn, một lần bấm* · **`YC-07`** *một lần bấm đọc ra phần của từng bàn* | 2 | **khoá ngoại hai chiều**, hoãn: `station_job_made_in_batch_fkey` — đơn vị *đã làm xong* hay *đã ra bàn* phải giữ **đúng một** thứ đã làm còn hiệu lực; `production_batch_item_live_station_job_fkey` — thứ đã làm còn hiệu lực phải nằm ở một đơn vị *đã làm xong* hay *đã ra bàn*. Một lần bấm cộng cho bàn này mà sót bàn kia không `COMMIT` được. `production_batch_item_live_key` — một đơn vị không do hai mẻ còn hiệu lực làm ra. Phần của từng bàn trong mẻ = đếm thứ đã làm của mẻ theo bàn | cùng file — mẻ A (một lần bấm): *bàn 5: 1 · bàn 7: 2 quả trứng tái*; hai lời từ chối cho mẻ ghi thiếu |
| **`I-020`** vế *đường lùi* · **`YC-07`** *lùi để lại vết* | 2 · 4 | **Tầng 2:** lùi = mẻ nhận mốc lùi, **mọi** thứ của mẻ đổi bản soi (`production_batch_item_batch_fkey`, khoá ngoại hai cột hoãn — lùi một phần của mẻ không `COMMIT` được), và mọi đơn vị giữ chúng về *chưa làm* (khoá hai chiều ở hàng trên — lùi mẻ mà con số của bàn không lùi theo thì không `COMMIT` được). **Tầng 4, phần máy giữ:** mẻ nào (dòng mẻ), lúc nào (`rolled_back_at`), đã phủ bàn nào (thứ đã làm ở lại, không xoá). **Ai lùi** — §5 | cùng file — trước lúc bấm và sau lúc lùi, con số của **cả hai** bàn giống hệt từng chữ; *vết lần lùi — mẻ …, bấm lúc …, lùi lúc …, đã phủ [bàn 5 ×3, bàn 7 ×1]*; bấm lại sau lùi được |
| **`I-020`** vế *ba trạng thái loại trừ nhau* | 3 | một cột `status`, ba mã (§4) — một đơn vị ở đúng một trạng thái. Cặp chuyển nào hợp lệ là **hàm xác thực** của `I-016` (pha 3), không phải lược đồ. Một hệ quả của hàng trên cần biết: *đã ra bàn* cũng phải giữ một thứ đã làm, nên *chưa làm → đã ra bàn* thẳng không ghi được — không phải một luật mới (§5.4 của `05-vong-doi.md` không có dòng ấy), mà là giá của việc giữ phần mỗi bàn của mẻ đọc được **sau khi** đã bưng | — |
| **`YC-06`** — đã gọi, đã phục vụ của từng thành phần của từng bàn; tổng tách ngược về bàn | — | *đã gọi* đọc từ dòng đơn (số suất × số thành phần), *đã phục vụ* đếm trên đơn vị *đã ra bàn*; đơn đã huỷ không tính ở cả hai phía. Tách ngược: hàng `I-019` | `i020_…` — *bàn 5 trứng tái: đã gọi 1 · … · đã bưng ra bàn 1 · còn thiếu 0*; sau khi huỷ đơn bàn 7 đã bưng một trứng: *đã gọi 0 · … · đã bưng ra bàn 0* |
| **`YC-07`** — *còn thiếu* của người bưng và *còn phải làm* của bếp không gộp | — | hai phép đếm khác nhau trên cùng đơn vị: *còn phải làm* = *chưa làm*; *còn thiếu* = *đã gọi* − *đã ra bàn*. Chúng lệch nhau đúng bằng *đã làm xong, còn ở bếp* — trạng thái riêng, không gộp vào *đã ra bàn* | `i020_…` — *bàn 7 trứng tái: đã gọi 2 · còn phải làm 0 · đã làm xong còn ở bếp 2 · đã bưng ra bàn 0 · còn thiếu 2* |

**Vì sao một dòng một đơn vị, và cái gì đã bị loại** (phiên chọn 2026-09-28). Vế tầng 1 của `I-020`
là một bất đẳng thức giữa **số đơn vị** và **số đã gọi**. Nếu một việc là một dòng có cột số lượng,
thì *đã làm xong* và *đã ra bàn* thành những phần của con số ấy nằm ở các dòng khác (mẻ, lần bưng), và
*tổng các phần ≤ số đã gọi* là một bất đẳng thức **qua nhiều dòng** — chỉ giữ được bằng một chuỗi số
dư như khoản trả trước của [`04-luoc-do-duong-tien.md`](04-luoc-do-duong-tien.md) §2, cho **hai** con
số một lúc. Một dòng một đơn vị biến nó thành **số dòng có được**: vị trí 1…*n* với *n* là tích hai
bản soi. Bị loại:
- *một dòng một việc, cột số lượng, và bảng mẻ mang số lượng chia cho từng việc* — hai bất đẳng thức
  qua nhiều dòng, và một con số của mẻ là đúng thứ `I-019` không cho có (*hai con số ghi độc lập*);
- *lưu con số tổng của mỗi dòng nhu cầu, cộng trừ cùng giao dịch* — đường *lưu đệm* mà
  `03-bao-ve-invariant.md` §4 cho phép, bị loại vì không cần: phép đếm trên vài nghìn dòng không phải
  chỗ chậm của quán, và một ô đệm là một ô ai đó sẽ sửa tay;
- *trigger giữ trần* — code, không phải một trong ba hình của tầng 1 (**ADR-050** điểm 1).

**Vì sao khoá ngoại hai chiều giữa đơn vị và thứ mẻ đã làm, và cái gì đã bị loại** (phiên chọn
2026-09-28). `I-020` tầng 2 đòi hai điều: một lần bấm cộng cho **mọi** bàn cùng lúc, và một lần lùi
trả **mọi** bàn cùng lúc. Cả hai là câu về trạng thái **cuối** của giao dịch: *đơn vị đã làm xong ⇔
có thứ đã làm còn hiệu lực*. Cột tự tính `station_job.id_if_made_or_served` và
`production_batch_item.live_station_job_id` là hai nửa của câu *⇔*, và hai khoá ngoại hoãn tới
`COMMIT` giữa chúng bắt giao dịch kết thúc ở trạng thái khớp — cùng khuôn *cột tự tính + khoá ngoại
hai chiều* của `table_session_bill_fkey` ở [`04-luoc-do-duong-tien.md`](04-luoc-do-duong-tien.md) §2.
Bản soi *mẻ đã lùi* trên mỗi thứ đã làm, cùng khoá ngoại hai cột về mẻ, là khuôn bản soi của `I-001`
([`02-luoc-do-ban-hang.md`](02-luoc-do-ban-hang.md) §2): lùi mẻ mà quên một thứ ⇒ không `COMMIT` được.
Bị loại:
- *cột `production_batch_id` trên `station_job`, xoá trắng khi lùi* — lần lùi xoá luôn câu trả lời
  *mẻ ấy đã phủ bàn nào*, đúng vết `YC-07` đòi giữ;
- *trạng thái *đã lùi* trên đơn vị* — một trạng thái thứ tư không có ở `05-vong-doi.md` §5.4 (`QD-40`
  chỉ ánh xạ về tên của owner).

**Vì sao đổi chủ bằng cách trỏ lại thứ đã làm, và cái gì đã bị loại** (phiên chọn 2026-09-28). Thứ đã
làm của một đơn huỷ là một vật có thật ở bếp (`03-lat-cat.md` §3.4.5); cái đổi là **chủ** của nó. Nên
dòng `production_batch_item` giữ nguyên *mẻ nào làm ra, làm cho ai lúc bấm*, và chỉ cột *chủ hiện tại*
đổi: phần của từng bàn trong mẻ ấy đọc ra đúng nơi vật ấy sẽ tới, và nếu mẻ ấy về sau bị lùi thì bàn
nhận lùi theo. Đơn vị cũ về *chưa làm* — đơn của nó đã huỷ, nên nó nằm ngoài mọi phép đếm; đơn vị của
bàn nhận sang *đã làm xong*. Bị loại:
- *đơn vị của bàn nhận sang "đã làm xong" không cần mẻ, chỉ cần lần chuyển* — khoá hai chiều phải chấp
  nhận **hai** lý do, và phần mỗi bàn của mẻ không còn cộng ra vật thật;
- *bàn cũ giữ nguyên "đã làm xong"* — một vật tính cho hai bàn, đúng ca `I-019` gọi là *đẻ ra số
  lượng*.

---

## 3. Cái không phải tầng 1 — lược đồ nợ gì, pha 3 nợ gì

- **`I-004` vế *đủ việc* (tầng 2).** Lược đồ giữ **trần** (không đơn vị nào vượt số, không nước chấm
  thứ hai) nhưng **không** giữ *đủ*: *mọi* (thành phần, trạm mà nó chạm tới) phải có đủ *n* đơn vị,
  và *mọi* đơn đã nổ phải có phần nước chấm — hai câu đọc bảng trạm của thành phần và số suất ở hai
  bảng khác. Một phần của nó dựng được bằng khoá ngoại hoãn (ví dụ *đơn Đang thực hiện ⇒ có nước
  chấm*); bị loại vì chỉ giữ một trong nhiều mảnh của cùng một vế, đúng lý do **ADR-056** bác khoá
  duy nhất cho nước chấm: hai cơ chế cho một vế thì câu đối chiếu vẫn phải đọc cả hai chiều. **Pha 3
  nợ:** cửa nổ đơn ghi trạng thái và mọi đơn vị trong **một** giao dịch. **`P2-11` nợ:** ba tập *thiếu
  hoặc thừa việc* · *nước chấm khác một* · *việc của đơn chưa duyệt* — viết sẵn ở cuối `i004_…`, và
  đã đỏ trên một đơn *Đang thực hiện* mà không nổ.
- **`I-004` vế *đơn huỷ rút nhu cầu* (tầng 3)** — §2. **Pha 3 nợ:** mọi phép đọc bảng nhu cầu lọc đơn
  đã huỷ; không đường nào đánh dấu từng việc *rời bảng*.
- **`I-004` vế *chọn bàn nhận* (tầng 4).** **Pha 3 nợ:** bày ra những đơn vị đang chờ **đúng** khoá gom
  của thứ đã làm (`shop-facts.md` §5.4: *máy chỉ bày ra ai đang chờ đúng thứ đã làm*), rồi ghi bốn lệnh
  của một lần chuyển trong một giao dịch. **`P2-11` nợ:** tập *đã làm của đơn huỷ, chưa chuyển* và tập
  *chuyển khác khoá gom* — ở cuối `i004_…`.
- **`I-019` vế *khoá gom* (tầng 3)** — §2. **Pha 3 nợ:** đúng một hàm gom, đọc khoá từ ảnh chụp theo mã
  gốc.
- **`I-020` vế *ba trạng thái* (tầng 3).** **Pha 3 nợ:** hàm xác thực của `I-016` cho vòng đời việc
  trạm — *chưa làm → đã làm xong* chỉ qua một mẻ, *đã làm xong → đã ra bàn*, *đã làm xong → chưa làm*
  chỉ qua một lần lùi cả mẻ. Lược đồ **không** chặn *đã ra bàn → chưa làm* khi mẻ bị lùi — cặp ấy
  không có trong bảng §5.4, nên hàm xác thực từ chối lùi một mẻ đã có đơn vị được bưng.
- **Đơn chỉ *Hoàn thành* khi mọi việc trạm của nó đã ra bàn** (`05-vong-doi.md` §5.5). Pha 1 không có
  hàng tầng riêng cho câu này; lát này **không** dựng ràng buộc cho nó (không nâng). **Pha 3 nợ:** cửa
  chuyển đơn sang *Hoàn thành* đọc việc trạm của đơn. Với đơn giao tận nơi nó chạm **`S-6`** (§5).

---

## 4. Bảng ánh xạ trạng thái (`QD-40`)

Mã là chữ ASCII (`QD-40`); tên ở cột cuối là tên ở owner, viết đúng chữ của
`docs/product/0-ba/ban-hang/05-vong-doi.md` §5.4. Hàm `qd40b` của `scripts/db-check.sh` so tập mã ở đây
với tập mã trong ràng buộc kiểm — mỗi dòng giữ đúng dạng của nó.

| Cột | Mã | Tên ở owner |
|---|---|---|
| `station_job.status` | `pending` | Chưa làm (§5.4) |
| `station_job.status` | `made` | Đã làm xong, còn ở bếp (§5.4) |
| `station_job.status` | `served` | Đã ra bàn (§5.4) |

`served` là tên của **trạng thái** *Đã ra bàn* — với đơn mang đi, owner đọc nó là *đóng gói và trao*
(§5.4 dòng thứ ba của bảng). Mã không nói **ai** bấm, **theo đơn vị nào**, hay **lúc nào** với đơn
giao — ba câu ấy là của owner, hai câu sau còn trống (§5).

**Mã trạm** (`menu_component_station.station_code`, `station_job.station_code`) là mã của owner, đúng
từng chữ của `shop-facts.md` §3 (`QD-02`) — không có bảng ánh xạ, vì không có gì để dịch. Hàm `qd02`
so cả hai cột với bảng ấy.

---

## 5. Chỗ trống có tên — cái lát này cố ý chưa giữ

| Chỗ trống | Lược đồ hôm nay đứng thế nào | Ai gỡ |
|---|---|---|
| **`S-5`** — bấm *"đã bưng ra bàn"* theo **đơn vị nào** (`shop-facts.md` §7.2, *chưa hỏi*) | **ô trống có mã.** Lược đồ **không có bản ghi nào** cho một lần bấm *"đã ra bàn"* — chỉ có trạng thái `served` trên từng đơn vị. Một lần bấm là một lệnh cập nhật trên **một tập** đơn vị mà cửa của pha 3 chọn: tập *mọi đơn vị đã làm xong của một bàn* và tập *mọi đơn vị của một mẻ* đều ghi được, không cần migration. Lát này **không** chọn tập nào, **không** có cột mặc định nào, và **không** đọc *"đơn vị đếm là bàn"* thành *"đơn vị bấm là bàn"* (`04-yeu-cau-du-lieu.md` §6). Nếu lời chủ quán cần vết của từng lần bấm ấy, đó là một bảng mới bằng migration mới | chủ quán — câu hỏi ở `shop-facts.md` §7.2, cần trước khi pha 4 dựng bảng quầy |
| **`S-6`** — với đơn **giao tận nơi**, quầy bấm *"đã ra bàn"* **lúc nào** (§7.2, *chưa hỏi*) | **ô trống có mã.** Không ràng buộc nào nối trạng thái `served` của đơn vị với trạng thái *Đang giao* hay *Hoàn thành* của đơn, và đơn vị không mang mốc bưng nào — cả *lúc đơn rời quán* (chỗ suy ra) lẫn *lúc tới tay khách* đều ghi được như nhau | chủ quán — §7.2; chạm câu *đơn Hoàn thành khi mọi việc đã ra bàn* (§3) |
| **Thứ đã làm của một đơn huỷ khi KHÔNG bàn nào đang chờ đúng thứ ấy** | lược đồ để đơn vị ấy ở *đã làm xong* với đơn đã huỷ — **không** chuyển, **không** bỏ, **không** đổi trạng thái; tập *đã làm của đơn huỷ, chưa chuyển* liệt kê nó, và chưa phân biệt được nó với một lần quên chuyển | chủ quán — **U-064** (`docs/product/99-unknowns.md`) |
| **Tập đối chiếu *việc Chưa làm của đơn đã Huỷ*** (`03-bao-ve-invariant.md` §2 hàng `I-004`, tập thứ năm) | tập ấy **không bao giờ rỗng** trong lược đồ này: việc trạm không có trạng thái huỷ (`05-vong-doi.md` §5.4) và không dòng nào bị xoá (`QD-50`), nên mọi đơn vị chưa làm của một đơn huỷ còn nguyên ở *chưa làm*. Lát này đọc vế tầng 3 là *bảng nhu cầu không còn thấy chúng* (§2) — một cách đọc, không phải lời của pha 1 | pha 1 viết lại tập ấy — **F-044** (`work/findings.md`) |
| ~~**Ai bấm** — người bấm mẻ, người lùi mẻ, người chọn bàn nhận~~ — **gỡ 2026-09-28 (`P2-08`)**; người bấm *"đã ra bàn"* còn chờ `S-5` | `production_batch.made_by_person_id` · `rolled_back_by_person_id` (có **khi và chỉ khi** mẻ đã lùi), `station_job_transfer.person_id` — [`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md) §1. Lần bấm *"đã ra bàn"* không có bản ghi nào để gắn người (`S-5`) | `P2-08` — xong; *đã ra bàn* theo `S-5` |
| **Vết của một lần sửa** — một mẻ đã lùi được *bỏ lùi* (mốc lùi xoá trắng), mốc bấm bị sửa | **từ `P2-08`**: lần sửa có khai lý do giữ mốc lùi cũ và người lùi ở bản trước ([`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md) §2); lược đồ vẫn không cấm *bỏ lùi*. Chế độ mềm — sửa không khai lý do không có vết | **F-046** |
| **Giảm số suất của một dòng đã nổ** (sửa dòng, `U-026`) | bị **từ chối**: đơn vị không xoá được, nên đơn vị thứ *n* cũ vượt số mới (`station_job_position_in_range_check`) — test `i020_…` in đúng lời ấy. Tăng số suất ghi được, kèm đơn vị mới và bản soi mới trong cùng giao dịch. Cùng hình với *sửa đổi món* ở [`03-luoc-do-menu-gia.md`](03-luoc-do-menu-gia.md) §5: cần một đường *thay dòng* | pha 3 · `P2-08` |
| **Trạm của một thành phần tại một mốc đã qua** | `menu_component_station` cất bảng **hiện hành**; việc đã nổ mang trạm của chính nó nên đơn cũ không đổi, nhưng tập *thiếu hoặc thừa việc* so với bảng hiện hành — đổi bảng trạm sẽ làm đơn cũ trông như nổ sai. Owner chỉ cho sửa thành phần suất **sau** buổi bán (`shop-facts.md` §6.17), nên ca này hẹp | `P2-08` (vết cập nhật menu) · `P2-11` so trong ngày |
| **Nồi, tổ hợp nồi, thứ tự làm** | không cất gì: máy không gom, không xếp nồi, không đề xuất mẻ (`shop-facts.md` §5.4, ranh giới đã chốt). Mẻ chỉ ghi **cái quầy đã bấm** | — cần thì hỏi chủ quán; cho máy chia mẻ là đổi phạm vi |

**Tham số của `01-quy-uoc-du-lieu.md` §0:** lát này **không** thêm bảng nào vào `:bang_ky_thuat` (mẻ và
thứ đã làm là vết, không bảng nào được xoá) và không bảng nào vào `:bang_khong_quan_he_so_hoc` — lát
không có cột tiền.

---

## 6. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2-08` | **xong 2026-09-28** — §5 hàng *ai bấm* · *vết của một lần sửa*; [`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md) |
| `P2-09` | file migration của lát này là file thứ bảy của dãy; phép so tên bảng `.md` ↔ migration đọc §1 |
| `P2-10` | §1 hàng `menu_component_station` — trạm của từng thành phần thật, **tra** `shop-facts.md` §5.3 · §3; ba loại trứng là ba thành phần hay một thì khoá gom vẫn tách đúng, vì nó gồm cả thành phần lẫn tuỳ chọn |
| `P2-11` | §2 cột *Bằng chứng* · §3 — năm tập của hàng `I-004` mà lát này đọc ra được (pha 1 liệt bảy; tập thứ năm là **F-044**, tập thứ tư gộp vào tập *thiếu hoặc thừa việc*), hai tập của hàng `I-020`, hai chiều của `I-019`; các hàm đối chiếu trong ba file test là điểm bắt đầu, và mỗi hàm đã **đỏ** một lần trên dữ liệu cài lỗi |
| `P2-13` | chấm lại `YC-06` · `YC-07` bằng §2 |
| pha 3 | §3 — cửa nổ đơn · một hàm gom · cửa bấm và lùi mẻ · cửa chuyển · hàm xác thực việc trạm; §5 `S-5` · `S-6` trước khi dựng bảng quầy |
