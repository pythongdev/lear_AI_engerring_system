# Lược đồ lát đường tiền — hoá đơn, thu chia phương thức, nợ, hoàn tiền, trả trước, tiền đầu két

Pha 2 · bước `P2-06` · viết 2026-09-28 (Claude Code). File này **thêm** một tên vào hàng *Schema* của
`CLAUDE.md` §2; nó không ghi đè lát nào trước nó (`master_plan/DB_master_plan_banh_cuon_ba_thanh.md`
§6, *Chạy song song được*).

**Bản nào thắng** (`docs/decisions.md` **ADR-053** luật 2): tên bảng · tên cột · kiểu · ràng buộc
thuộc file migration
[`db/migrations/20260928120000_duong_tien.up.sql`](../../../db/migrations/20260928120000_duong_tien.up.sql).
File này giữ **ý định, lý do và ánh xạ** sang `I-0xx` / `YC-xx`. Nó nhắc tên bảng và tên ràng buộc
để trỏ, **không** chép lại kiểu hay điều kiện thành bản thứ hai (**F-001**). Hai bản lệch nhau ⇒ một
dòng `F-XXX`, không lặng lẽ sửa bên nào.

**File này thay thế** [`architecture.md`](../1-system-design/architecture.md) **§12.3** — mục pha 1
tự khai là *đề xuất gửi sang pha 2* cho phần nợ. Sáu thứ phải cất và ba ràng buộc của §12.3 có chỗ ở
§2 dưới đây; hình dạng thì **khác** (§1, lý do ở hàng `bill`), đúng quyền §12.3 để lại cho pha 2.

**File này KHÔNG sở hữu:**
- **luật nghiệp vụ và tầng bảo vệ** — `quality/invariants.md` và
  `docs/product/1-system-design/03-bao-ve-invariant.md`. Lát này **thi hành** tầng đã chốt, không
  nâng, không hạ (**ADR-050** luật 1);
- **ai bấm, chỗ đứng lúc bấm, vết của một lần sửa** — `P2-08` (§5);
- **quyền theo vai** — ai được hoàn, ai được ghi nợ — pha 3 (**ADR-035**); lát này chỉ để lại đủ vết
  để hỏi câu ấy sau;
- **câu truy vấn đối chiếu** chạy mỗi tối — `P2-11`. Các câu ở cuối file test là bằng chứng lát này
  đọc ra được, không phải bộ đối chiếu;
- **cất bằng gì** — [`01-quy-uoc-du-lieu.md`](01-quy-uoc-du-lieu.md); **dựng và kiểm bằng gì** —
  [`10-quy-uoc-code.md`](10-quy-uoc-code.md).

---

## 0. Cách đọc

Cùng hai nguồn như §0 của [`02-luoc-do-ban-hang.md`](02-luoc-do-ban-hang.md): **owner** (dịch một câu
đã chốt) · **phiên chọn 2026-09-28** (lựa chọn thiết kế của lượt này, **chưa có lời chủ repo** — đổi
được bằng một migration mới kèm lý do ở đây, trước khi code pha 3 dựa vào nó).

**Bằng chứng** của mỗi hàng ở §2 là một file ở `db/tests/`, chạy trong `./scripts/db-check.sh`
(`QC-07`). Vì bộ kiểm bọc mỗi file trong `ROLLBACK`, ràng buộc **hoãn tới `COMMIT`** không bao giờ tự
chạy trong test — nên mọi test của lát này ép chúng bằng `SET CONSTRAINTS … IMMEDIATE`, và mỗi kịch
bản đúng kết thúc bằng `SET CONSTRAINTS ALL IMMEDIATE`.

**Một ý xuyên cả lát — mỗi lần tiền đổi tay là một dòng, và mỗi phương thức là một cột.** Quán có
đúng hai phương thức (`master_plan/shop-facts.md` §1). Một lần thu cất hai phần của nó thành **hai
cột trên cùng một dòng**, không thành hai dòng: nhờ thế *tổng khớp* là một điều kiện kiểm trên một
dòng (tầng 1), *mọi phần chung một mốc* (`YC-19`) đúng theo cấu tạo, và *các phần cùng sống hoặc cùng
chết* (`I-015` tầng 2) là chuyện của một lệnh ghi. Phương thức thứ ba là một migration, không phải
một giá trị mới — đúng với một danh sách mà owner giữ đóng. Cái giá: lần **hoàn** — chỉ có một số tiền
— mang phương thức bằng mã (`method_code`), nên một lần hoàn trả bằng hai phương thức là hai dòng.
*Phiên chọn 2026-09-28.*

---

## 1. Bảy bảng — mỗi bảng giữ gì, và vì sao có nó

| Bảng | Giữ gì | Vì sao là một bảng riêng · nguồn |
|---|---|---|
| `bill` | **hoá đơn** — lần đóng **một** đơn vị tính tiền (một phiên bàn **hoặc** một đơn lẻ) và lần thu của lần đóng ấy: số phải trả, phần tiền mặt, phần chuyển khoản, phần trả trước thành doanh thu (theo phương thức đã nhận), phần **nợ** và **ai nợ**, mốc tính tiền | owner: `02-thoi-gian-ngay-ban.md` §2 (*bán = đóng đơn vị tính tiền, kể cả hoá đơn ghi nợ*), `I-002` · `I-005` · `I-014` · `I-015`. **Nợ nằm ở đây, không ở một bảng nợ riêng** — phiên chọn 2026-09-28: *thu thiếu thì phần thiếu là nợ* là một phép cộng **trên cùng một lần đóng**, và chỉ một điều kiện kiểm trên một dòng giữ được nó ở tầng 1. Khoản nợ vẫn có vòng đời riêng (`YC-09`): hoá đơn sống sau khi phiên đóng, và lần thu nợ là một dòng khác |
| `debt_collection` | **lần thu nợ** — thu khoản nợ của hoá đơn nào, tiền mặt bao nhiêu, chuyển khoản bao nhiêu, lúc nào | owner: `shop-facts.md` §6.14, `YC-02` · `YC-10`. Không phải một hoá đơn: doanh thu của bữa ăn đã nằm ở hoá đơn ghi nợ; *đã thu hay chưa* là **có dòng này hay không** — không có cột trạng thái thứ hai |
| `prepayment` | **khoản trả trước** — cho đơn lẻ nào, tiền mặt bao nhiêu, chuyển khoản bao nhiêu, **lúc quán nhận tiền** | owner: `shop-facts.md` §6.3 · §6.26, `YC-23`. Mốc của nó đặt khoản này vào dòng *trả trước nhận trong ngày* của đối soát, **không** vào doanh thu (§3) |
| `prepayment_use` | **mỗi lần dùng một khoản trả trước** — vào hoá đơn của đơn, hoặc trả lại — như một **mắt chuỗi số dư** theo từng phương thức đã nhận | owner: `YC-23` vế *không vượt số đã nhận*, `03-bao-ve-invariant.md` §1 hàng `I-014` (tầng 1). Chuỗi là cách duy nhất biến một bất đẳng thức **qua nhiều dòng** thành ràng buộc thật mà không cần trigger (**ADR-050** điểm 1) — §2 hàng `YC-23` |
| `refund` | **vết hoàn tiền** — bao nhiêu · cho lượt bán nào · lúc nào · lý do · trả lại bằng gì; và với lần hoàn cho lần bán đã đóng, khoản ấy **đã thu bằng gì** | owner: `YC-01`, `shop-facts.md` §6.4, `architecture.md` §3.3. **Hai loại trong một bảng**, đọc từ cột nào có mặt: hoàn cho **hoá đơn** (trừ doanh thu ngày hoàn) · trả lại **khoản trả trước** chưa thành doanh thu (không trừ doanh thu ngày nào — **ADR-059** điểm 5, *suy ra*). Chung một bảng vì chung **vết** (`architecture.md` §6.4: *nó vẫn là một lần hoàn theo nghĩa vết*); khác dòng đối soát vì khác cột |
| `opening_float` | **tiền đầu két của một ngày bán** — đúng một cho mỗi ngày | owner: `I-021`, `shop-facts.md` §8.5. Bảng riêng để con số ấy **không bao giờ** nằm trong tập tiền đã thu |
| `opening_float_line` | một dòng **mệnh giá** của tiền đầu két và số tiền của mệnh giá ấy | owner: `shop-facts.md` §8.5 (trả lời `U-038`: *máy giữ bảng mệnh giá và hiện tổng*). Con số của ngày là **tổng các dòng** — cộng từ chi tiết, không có ô tổng thứ hai (**ADR-050** tầng 3) |

Hai bảng của lát bán hàng lõi nhận **cột tự tính** (không ghi tay được), không nhận cột ghi:
`table_session.id_if_closed` và `sales_order.id_if_standalone` · `sales_order.id_if_completed_standalone`
— chúng là đích và nguồn của khoá ngoại hai chiều ở §2 hàng `I-005` · `I-014`. File migration của
`P2-04` không bị sửa (`QC-05`).

---

## 2. Mệnh đề → cái giữ nó trong lược đồ → bằng chứng

Tầng ở cột thứ hai là tầng **pha 1 đã chốt** (`03-bao-ve-invariant.md` §1); lát này không đổi nó. Tên
ở cột thứ ba là tên ràng buộc trong migration (`QC-10`) — lời từ chối của database in đúng tên ấy.

| Mệnh đề | Tầng | Lược đồ giữ bằng | Bằng chứng |
|---|:--:|---|---|
| **`I-005`** vế *phiên đóng thu thiếu thì phải có khoản nợ đứng tên với đúng phần thiếu* | 1 | `bill_parts_equal_due_check` — tiền mặt + chuyển khoản + trả trước + **nợ** = số phải trả, trên **một** dòng. `bill_debtor_iff_debt_check` · `bill_debtor_name_not_blank_check` — có nợ **khi và chỉ khi** có tên người nợ, tên trắng là thiếu. `bill_amounts_not_negative_check` — không phần nào âm. Và **phiên đã đóng không thiếu hoá đơn được**: `table_session_bill_fkey` (phiên → hoá đơn) cùng `bill_table_session_fkey` (hoá đơn → phiên **đã đóng**), hai khoá ngoại hoãn tới `COMMIT` trên cột tự tính `id_if_closed` — đóng phiên mà không ghi hoá đơn, hay ghi hoá đơn cho phiên chưa đóng, thì giao dịch không `COMMIT` được | `db/tests/i005_debt_has_owner.sql` |
| **`I-005`** vế *khoản nợ không nằm trong tập tiền đã thu* | 1 | nợ là **cột riêng** (`debt_vnd`); tiền đã thu là `cash_vnd` + `transfer_vnd`. Không có đường ghi nào đặt một con số vào cả hai | cùng file |
| **`YC-11`** — ghi nợ là chỗ **duy nhất** phiên bàn hỏi danh tính | — | `bill_debtor_iff_debt_check` giữ cả chiều ngược: **không** nợ thì **không** được mang tên. Không bảng nào khác của lát bán hàng có cột tên cho phiên bàn | cùng file |
| **`I-002`** vế *một phiên một hoá đơn* · **`I-007`** vế *một đơn lẻ đúng một lần thu khi đóng* | 1 | `bill_one_per_session_key` · `bill_one_per_order_key`. Đây là khoá mà `02-luoc-do-ban-hang.md` §5 để lại cho lát này | `i015_split_payment.sql` · `yc02_debt_outlives_session.sql` |
| **`I-014`** vế *không khoản nào đứng ở hai nguồn* | 1 | `bill_one_unit_check` — một hoá đơn gắn **đúng một** đơn vị tính tiền. `bill_sales_order_fkey` trỏ tới `sales_order.id_if_standalone`: chỉ **đơn lẻ** có hoá đơn riêng — lượt gọi của phiên bàn tính vào hoá đơn của phiên, không có đường thứ hai. `sales_order_bill_fkey` (hoãn): đơn lẻ **Hoàn thành** mà không có hoá đơn ⇒ doanh thu của nó không đứng ở nguồn nào ⇒ không `COMMIT` được | `i014_one_unit_and_prepayment.sql` · `i015_split_payment.sql` |
| **`I-014`** vế *một lần trả nợ không là một lần bán mới* · **`YC-10`** | 1 · 3 | lần thu nợ là `debt_collection`, **không** phải `bill`; ghi nó thành hoá đơn thứ hai của cùng phiên bị `bill_one_per_session_key` từ chối. Hai mốc của khoản nợ đọc riêng: mốc **ghi** là `bill.booked_at`, mốc **thu** là `debt_collection.booked_at` | `yc02_debt_outlives_session.sql` — doanh thu thứ Hai `200000`, thứ Năm `0`, hai ngày cộng lại `200000` |
| **`I-015`** vế *tổng khớp* và *mỗi phần đúng một phương thức, ghi riêng* | 1 | `bill_parts_equal_due_check` chặn thu **vượt** (và thu thiếu mà không nợ); mỗi phương thức một cột nên một phần không mang phương thức nào, hay mang phương thức thứ ba, không có chỗ ghi (§0) | `i015_split_payment.sql` |
| **`I-015`** vế *các phần cùng sống hoặc cùng chết* · **`YC-19`** *mọi phần chung một mốc* | 2 | theo cấu tạo: mọi phần nằm trên **một** dòng, **một** `booked_at`. Không có lệnh ghi nào mang một phần mà thiếu phần kia; bỏ một phần của lần thu đã ghi làm tổng lệch ⇒ bị từ chối | cùng file |
| **`YC-02`** · **`YC-09`** — khoản nợ đứng được sau khi phiên đóng, qua nhiều ngày | — | sáu thứ: **ai nợ** `bill.debtor_name` · **bao nhiêu** `bill.debt_vnd` · **một phiên** `bill.table_session_id` + `bill_one_per_session_key` · **lúc ghi** `bill.booked_at` · **lúc thu** `debt_collection.booked_at` · **đã thu hay chưa** = có dòng thu hay không. *Một phiên hai khoản nợ chưa thu*: không dựng được — một phiên một hoá đơn, một hoá đơn một cột nợ. Thu nợ **đúng một lần, đủ số**: `debt_collection_one_per_debt_key` · `debt_collection_bill_fkey` (khoá ngoại hai cột buộc số nợ trên dòng thu bằng số trên hoá đơn) · `debt_collection_amounts_check` | `yc02_debt_outlives_session.sql` |
| **`YC-01`** · **`I-012`** vết hoàn tiền | 1 (hình dạng vết) | bốn trong năm thứ là `NOT NULL` hoặc điều kiện kiểm: **bao nhiêu** `refund_amount_positive_check` · **lượt bán nào** `refund_one_target_check` · **lúc** `booked_at` · **lý do** `NOT NULL` + `refund_reason_not_blank_check` — cộng **trả lại bằng gì** (`method_code`, `refund_method_code_check`). **Ai bấm: chỗ trống có tên** (§5). Vết sống độc lập với bản ghi nó nói về: vai `shop_app` không xoá được (`QD-50`), và lần bán mà vết trỏ tới cũng không xoá được (`QD-51`) | `yc01_refund_trace.sql` |
| **`I-021`** vế *mỗi ngày bán đúng MỘT con số tiền đầu két, và nó không phải doanh thu* | 1 | `opening_float_one_per_day_key`; bảng riêng, không cột nào của nó nằm trong một lần thu. `opening_float_line_one_per_denomination_key` · `opening_float_line_amount_check` (một dòng là một xấp cùng mệnh giá) | `i021_opening_float_and_cash_formula.sql` |
| **`I-021`** — hai vế của phép trừ két **dựng lại được từ chi tiết** | 5 (câu thuộc `P2-11`) | mỗi hạng tử là một phép cộng trên đúng một cột — §3 bảng *Hạng tử đọc ở đâu*. Hoàn **chéo** đọc được vì lần hoàn cho hoá đơn mang cả phương thức trả lại lẫn phương thức đã thu (`refund_source_iff_bill_check`) | cùng file — kịch bản trả trước B · E, trả nợ, hoàn chéo của `I-021`: lệch `0` cả ba ngày; bỏ một hạng tử ⇒ lệch đúng bằng nó |
| **`YC-23`** vế *không vượt số đã nhận* · **`I-014`** hàng pha 1 cùng vế | 1 | **chuỗi số dư** `prepayment_use`: mắt 1 bắt đầu đúng bằng số đã nhận (`prepayment_use_first_fkey`), mắt *n* bắt đầu đúng bằng số dư sau mắt *n−1* (`prepayment_use_previous_fkey` trên `prepayment_use_chain_key`), số dư không âm (`prepayment_use_balance_check`), không hai mắt cùng số (`prepayment_use_no_key`). Mỗi mắt thuộc **đúng một** hoá đơn hoặc **đúng một** lần trả lại (`prepayment_use_one_target_check`), khớp **đúng số** và **đúng đơn** (`prepayment_use_bill_fkey` · `prepayment_use_refund_fkey`); hoá đơn ghi trả trước, hay lần trả lại trả trước, mà không có mắt nào ⇒ không `COMMIT` được (`bill_prepayment_use_fkey` · `refund_prepayment_use_fkey`, hoãn) | `i014_one_unit_and_prepayment.sql` |
| **`YC-23`** vế *không vào doanh thu ngày nhận tiền* · vế *trả lại không trừ doanh thu* (**suy ra**, ADR-059 điểm 5) | 3 | doanh thu = hoá đơn đóng trong ngày − hoàn **cho hoá đơn** trong ngày. Khoản trả trước chỉ vào doanh thu **qua** cột trả trước của hoá đơn của chính đơn nó (`prepayment_use_bill_fkey`); lần trả lại là `refund` **không** có hoá đơn, nên không phép cộng doanh thu nào chạm nó. Luồng ăn tại bàn không trả trước được: `prepayment_sales_order_fkey` · `bill_prepaid_only_standalone_check` | `i021_opening_float_and_cash_formula.sql` — doanh thu thứ Hai `860000` (không có 50.000 của B), thứ Ba `850000` (có B, không bị trừ 40.000 của E) |

**Vì sao khoá ngoại hai chiều, và cái gì đã bị loại** (phiên chọn 2026-09-28). `I-005` là câu về
**trạng thái cuối**: *phiên đã đóng* mà *không có hoá đơn* là tổng đã thu 0 < số phải trả, không nợ
nào — tức là đúng trạng thái sai. Muốn database từ chối nó thì phiên phải **trỏ** được tới hoá đơn
của nó khi (và chỉ khi) đã đóng: cột tự tính `id_if_closed` là `id` lúc phiên đóng, trống lúc chưa
đóng, và khoá ngoại hoãn từ nó sang `bill.table_session_id` bắt hoá đơn phải có mặt lúc `COMMIT`.
Chiều ngược — `bill.table_session_id` trỏ vào chính `id_if_closed` — bắt hoá đơn chỉ đứng tên phiên
**đã đóng**. Đơn lẻ dùng cùng hình, với một khác biệt: `Hoàn thành → Huỷ` là đường hợp lệ
(`shop-facts.md` §6.19), nên chiều *có hoá đơn ⇒ đã hoàn thành* **không** dựng được (đơn huỷ sau khi
xong giữ hoá đơn của nó; tiền đi đường hoàn) — chiều ấy là tầng 3 (§3). Bị loại:
- *một cột `bill_id` ghi tay trên phiên và trên đơn* — đường ghi thứ hai tới *phiên đã đóng chưa*,
  đúng thứ `02-luoc-do-ban-hang.md` §3 hàng `I-016` tránh;
- *trigger kiểm tổng lúc đóng* — code, không phải một trong ba hình của tầng 1 (**ADR-050** điểm 1);
- *để chiều "đã đóng ⇒ có hoá đơn" cho pha 3* — là hạ `I-005` từ tầng 1 xuống tầng 3 trong im lặng
  (**ADR-050** luật 1).

**Vì sao chuỗi số dư cho khoản trả trước, và cái gì đã bị loại** (phiên chọn 2026-09-28). Vế tầng 1
là một bất đẳng thức **qua nhiều dòng** — đã dùng + đã trả lại ≤ đã nhận — mà một điều kiện kiểm chỉ
đọc một dòng. Chuỗi biến nó thành **ba** điều trên từng dòng: mắt đầu bằng số đã nhận, mắt sau bằng
số dư của mắt trước, số dư không âm. Số dư đi **theo từng phương thức đã nhận**, vì `I-021` cần *phần
**tiền mặt** của trả trước đã thành doanh thu*. Cùng khuôn *mắt trước* với
`order_line_component_previous_position_fkey` của [`03-luoc-do-menu-gia.md`](03-luoc-do-menu-gia.md).
Bị loại:
- *một dòng "quyết toán" duy nhất cho mỗi khoản trả trước* — trả lại (đơn bớt món, trước khi đóng) và
  thành doanh thu (lúc đóng) xảy ra ở **hai lúc**, có khi **hai ngày**; một dòng không mang được hai
  mốc;
- *chỉ cho trả lại nhiều nhất một lần* — một giới hạn owner không nói, dựng ra chỉ để dễ ràng buộc.

---

## 3. Cái không phải tầng 1 — lược đồ nợ gì, pha 3 nợ gì

- **Số phải trả của hoá đơn bằng tổng các dòng đơn (`I-002` tầng 3).** `bill.due_vnd` là con số của
  **lần đóng**, ghi **một lần** bởi đường đóng duy nhất; một điều kiện kiểm không đọc được các dòng
  đơn. Nó là **ô duy nhất** mang tổng hoá đơn — lát bán hàng lõi không có cột tổng nào
  (`02-luoc-do-ban-hang.md` §2 hàng `I-002`) — và tập đối chiếu *phiên đã đóng mà tổng hoá đơn khác
  tổng mọi lượt gọi* của `I-002` so đúng ô này với chi tiết. **Pha 3 nợ:** tính nó từ dòng đơn trong
  cùng giao dịch đóng. **`P2-11` nợ:** câu đối chiếu ấy.
- **Hoá đơn của đơn lẻ chỉ sinh khi đơn Hoàn thành (tầng 3).** Lược đồ buộc chiều *Hoàn thành ⇒ có
  hoá đơn*; chiều ngược không dựng được (§2, đoạn khoá ngoại hai chiều). *"Đơn lẻ đóng"* đọc là **Hoàn
  thành** — `05-vong-doi.md` §5.2: người đi giao bấm *đã giao* **và** *đã thu tiền* cùng lúc; khách tới
  lấy nhận hàng ở quầy. *Cách đọc của phiên, 2026-09-28.*
- **Khoản trả trước chỉ vào doanh thu qua hoá đơn của chính đơn nó (`I-014` hàng pha 1, tầng 3).**
  Phép cộng doanh thu đọc `bill` và `refund` có `bill_id`; nó không đọc `prepayment`, `debt_collection`
  hay `refund` có `prepayment_id`. **`P2-11` nợ:** câu doanh thu viết đúng như thế — và ba tập đối chiếu
  *trả trước* của hàng `I-014`.
- **Số tiền hoàn không bị chặn trên (không tầng).** Quán **cố ý** không có luật cứng về hoàn tiền
  (`shop-facts.md` §6.4); lược đồ chỉ giữ *có đủ vết*, không giữ *hoàn bao nhiêu là quá*.

**Hạng tử đọc ở đâu** — mỗi dòng của công thức đối soát (`architecture.md` §6.4) và mỗi hạng tử của
`I-021` là **một** phép cộng trên cột nào, lọc theo `sale_date` của dòng ấy (`QD-31`). Đây là bảng
ánh xạ để `P2-11` viết câu; bằng chứng nó đọc đúng là kịch bản của `i021_…`.

| Hạng tử | Cộng cột nào | Điều kiện |
|---|---|---|
| doanh thu trong ngày | `bill.due_vnd` − `refund.amount_vnd` | refund: có `bill_id` |
| doanh thu **tiền mặt** (`I-021`) | `bill.cash_vnd` + `bill.prepaid_cash_vnd` − `refund.amount_vnd` | refund: có `bill_id`, `source_method_code` là tiền mặt |
| nợ ghi trong ngày | `bill.debt_vnd` | — |
| nợ cũ thu được hôm nay (tiền mặt, cho `I-021`) | `debt_collection.cash_vnd` (+ `transfer_vnd` cho dòng tổng) | — |
| trả trước nhận trong ngày | `prepayment.cash_vnd` · `prepayment.transfer_vnd` | — |
| trả trước thành doanh thu | `bill.prepaid_cash_vnd` · `bill.prepaid_transfer_vnd` | — |
| trả lại trả trước trong ngày | `refund.amount_vnd` | có `prepayment_id`; tách theo `method_code` |
| hoàn tiền trong ngày · hoàn **chéo** | `refund.amount_vnd` | có `bill_id`; chéo khi `method_code` ≠ `source_method_code` |
| tiền đầu két | tổng `opening_float_line.amount_vnd` | của `opening_float` ngày ấy |

**Phần chuyển khoản so theo lúc tiền tới** (**ADR-059** điểm 4): cả ba bảng mang tiền chuyển
khoản vào (`bill`, `debt_collection`, `prepayment`) có `booked_at` là lúc quán **nhận** tiền, và cột
trả trước **thành doanh thu** của `bill` không phải tiền tới — nên *tiền chuyển khoản tới trong ngày*
là `bill.transfer_vnd` + `debt_collection.transfer_vnd` + `prepayment.transfer_vnd`, không cộng
`bill.prepaid_transfer_vnd`.

---

## 4. Mã trong lát này (`QD-02` không áp)

Lát này **không** có cột `status`, nên không có dòng ánh xạ `QD-40`. *Đã thu hay chưa* của một khoản
nợ đọc từ việc có dòng `debt_collection` hay không — một cột trạng thái ở đây là một đường ghi thứ hai.

**Mã phương thức** (`refund.method_code`, `refund.source_method_code`) — hai phương thức của
`shop-facts.md` §1. Owner không đặt chữ máy đọc cho chúng, nên mã là **phiên chọn 2026-09-28**. Cột
tên đứng trước để dòng không trông như một dòng tên bảng ở §1.

| Tên ở owner | Mã |
|---|---|
| Tiền mặt (§1) | `cash` |
| Chuyển khoản VietQR tĩnh (§1) | `transfer` |

---

## 5. Chỗ trống có tên — cái lát này cố ý chưa giữ

| Chỗ trống | Lược đồ hôm nay đứng thế nào | Ai gỡ |
|---|---|---|
| ~~**Ai bấm** — vế thứ năm của `YC-01`, người trực quầy lúc ghi nợ và thu nợ, người nhận trả trước, người khai tiền đầu két~~ — **gỡ 2026-09-28 (`P2-08`)** | `person_id` bắt buộc trên `bill` · `debt_collection` · `prepayment` · `refund` · `opening_float`, mặc định người thao tác của giao dịch; *người đang trực lúc ấy* đọc từ `counter_duty` — [`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md) §1 · §2 | `P2-08` — xong |
| **Trả một phần khoản nợ** | lần thu nợ phải thu **đủ** số nợ, đúng một lần — hai trạng thái *chưa thu · đã thu* của `YC-02` và `architecture.md` §12.3. Owner chưa nói ca khách trả dần | chủ quán — **U-063** (`docs/product/99-unknowns.md`) |
| **Giảm giá cả đơn** (`shop-facts.md` §8.9) | hoá đơn **không** có cột giảm giá; `due_vnd` là số phải trả sau cùng | chủ quán — **U-058** (phạm vi bản đầu, giới hạn, lý do); lát nào dựng nó thêm cột bằng migration mới |
| **Số tiền mặt đếm được cuối ngày**, và dấu *ngày đã đối soát xong* | chưa có chỗ cất: vế trái của `I-021` và tập *ngày đã qua mà con số dựng lại khác con số đã đối soát* của `I-014` cần nó. Test `i021_…` đưa số đếm vào như hằng số. Kế hoạch pha 2 §6 **không giao** việc này cho bước nào | chủ repo — quyết bước nào nhận (`P2-11` hay một bước lane admin) |
| **Con số tiền đầu két mặc định** (*cố định, sửa được* — `shop-facts.md` §8.5) | lát chỉ cất con số **của từng ngày**; con số mặc định là cấu hình của mảng tài chính | lane admin (`work/backlog_AD.md` ADM-01); dữ liệu mồi `P2-10` |
| **Một đơn nhiều khoản trả trước** | `prepayment_one_per_order_key` — một đơn, nhiều nhất một khoản. Owner chỉ tả **một** lần trả trước lúc đặt (`shop-facts.md` §6.3) | phiên chọn 2026-09-28 — gỡ bằng migration mới nếu quán cần |
| **Vết của một lần sửa** một dòng tiền đã ghi (bản trước, bản sau — `YC-13`), vế *mốc không dời* của `QD-33` | **từ `P2-08`**: vết cập nhật chụp bản trước và bản sau khi giao dịch khai lý do; câu *mốc tính tiền bị dời* đọc từ vết ([`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md) §2). Chế độ mềm — một lần sửa không khai lý do không có vết | **F-046** |
| ~~**Nhập bù từ sổ giấy** (`YC-08`)~~ — **gỡ 2026-09-28 (`P2-08`)** | sổ giấy `paper_ledger` khai số lượt; hoá đơn nhập bù trỏ về lượt thứ mấy của sổ, ngày bán bằng ngày của sổ; *còn N lượt* là một phép trừ; người nhập bù là `bill.person_id` — [`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md) §2 hàng `YC-08` | `P2-08` — xong |

**Tham số của `01-quy-uoc-du-lieu.md` §0:** lát này **không** thêm bảng nào vào `:bang_ky_thuat` (mọi
bảng mang dữ liệu tiền, không bảng nào được xoá) và không bảng nào vào `:bang_khong_quan_he_so_hoc` —
mỗi bảng có từ hai cột tiền trở lên đều có một điều kiện kiểm hay một cột tự tính nối chúng (`QD-22`).

---

## 6. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2-07` | không gì — lát sản xuất không chạm tiền |
| `P2-08` | **xong 2026-09-28** — §5 ba hàng *ai bấm* · *vết của một lần sửa* · *nhập bù*; [`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md) |
| `P2-09` | file migration của lát này là file thứ sáu của dãy; phép so tên bảng `.md` ↔ migration đọc §1 |
| `P2-10` | con số tiền đầu két mặc định (§5) nếu dữ liệu mồi cần một ngày mẫu |
| `P2-11` | §2 cột *Bằng chứng* · §3 bảng *Hạng tử đọc ở đâu* — mỗi mệnh đề cần câu đối chiếu của mình (**ADR-050** luật 2); các câu ở cuối file test là điểm bắt đầu |
| `P2-13` | chấm lại `YC-01` · `YC-02` · `YC-09` · `YC-10` · `YC-11` · `YC-19` · `YC-23` bằng §2 |
| pha 3 | §3 — đường đóng tính `due_vnd` từ dòng đơn; phép cộng doanh thu; quyền ai được hoàn · ghi nợ |
