# Lược đồ lát bán hàng lõi — bàn, phiên bàn, đơn, dòng đơn, suất đem về

Pha 2 · bước `P2-04` · viết 2026-09-27 (Claude Code). Đây là **file lát đầu tiên** của
`docs/product/2-db/`, nên nó là file đổi hàng *Schema* của `CLAUDE.md` §2 từ *chưa có owner* sang có
owner (**ADR-035** luật 2).

**Bản nào thắng** (`docs/decisions.md` **ADR-053** luật 2): tên bảng · tên cột · kiểu · ràng buộc
thuộc file migration
[`db/migrations/20260927120000_ban_hang_loi.up.sql`](../../../db/migrations/20260927120000_ban_hang_loi.up.sql),
và — cho liên hệ của đơn mang đi, thêm ở `T-111` ngày 2026-09-28 —
[`db/migrations/20260928090000_lien_he_don_mang_di.up.sql`](../../../db/migrations/20260928090000_lien_he_don_mang_di.up.sql),
và — cho dấu lần gửi, thêm ở `T-116` cùng ngày —
[`db/migrations/20260928100000_dau_lan_gui.up.sql`](../../../db/migrations/20260928100000_dau_lan_gui.up.sql).
File này giữ **ý định, lý do và ánh xạ** sang `I-0xx` / `YC-xx`. Nó nhắc tên bảng và tên ràng buộc
để trỏ, **không** chép lại kiểu hay điều kiện thành bản thứ hai (**F-001**). Hai bản lệch nhau ⇒ một
dòng `F-XXX`, không lặng lẽ sửa bên nào.

**File này KHÔNG sở hữu:**
- **luật nghiệp vụ và tầng bảo vệ** — `quality/invariants.md` và
  `docs/product/1-system-design/03-bao-ve-invariant.md`. Lát này **thi hành** tầng đã chốt, không
  nâng, không hạ (**ADR-050** luật 1);
- **món, giá, tuỳ chọn** — `P2-05`; **tiền** (thu, nợ, hoàn, mốc tính tiền) — `P2-06`; **việc trạm** —
  `P2-07`; **người, chỗ đứng, vết cập nhật** — `P2-08`. Chỗ nối với từng lát ở §5;
- **cất bằng gì** (tiền, mốc, khoá, tên) — [`01-quy-uoc-du-lieu.md`](01-quy-uoc-du-lieu.md);
  **dựng và kiểm bằng gì** — [`10-quy-uoc-code.md`](10-quy-uoc-code.md).

---

## 0. Cách đọc

**Nguồn** của mỗi lựa chọn là một trong hai, cùng nghĩa với §0 của hai file quy ước:
**owner** (dịch một câu đã chốt ở pha 0 · pha 1 · `shop-facts.md`) · **phiên chọn 2026-09-27** (lựa
chọn thiết kế của lượt này, **chưa có lời chủ repo** — đổi được bằng một migration mới kèm lý do ở
đây, trước khi code pha 3 dựa vào nó).

**Bằng chứng** của mỗi hàng ở §2 là một file ở `db/tests/`, chạy trong `./scripts/db-check.sh`
(`10-quy-uoc-code.md` `QC-07`). Mỗi file cố tình dựng trạng thái sai và in **nguyên lời từ chối**
của database; không bị từ chối thì chính file ấy đỏ.

---

## 1. Năm bảng — mỗi bảng giữ gì, và vì sao có nó

| Bảng | Giữ gì | Vì sao là một bảng riêng · nguồn |
|---|---|---|
| `dining_table` | một cái bàn của quán và **số bàn** người đọc (không trùng) | khoá chính không mang nghĩa, số bàn là cột riêng (`QD-10`). **Không** có mã QR (`I-023`, §5) và **không** có cột trạng thái (§3, `I-003`) |
| `table_session` | một **phiên bàn** — đơn vị tính tiền của hai kênh gắn bàn — và trạng thái của nó | owner: `shop-facts.md` §2 hệ quả 1, `05-vong-doi.md` §5.3. Cờ *đã đóng chưa* là cột **tự tính** từ trạng thái, không ghi tay được |
| `table_session_member` | **bàn nào thuộc phiên nào**, mốc đã dọn của **từng** bàn, và một bản soi *phiên đã đóng chưa* | owner: ghép bàn = **một** phiên **nhiều** bàn (**ADR-027**, `shop-facts.md` §6.16); dọn tính **riêng từng bàn** (`05-vong-doi.md` §5.3). Quan hệ bàn ↔ phiên là nhiều-nhiều theo thời gian, nên nó phải là một bảng |
| `sales_order` | một **đơn** của bất kỳ kênh nào: kênh, trạng thái, và — chỉ khi kênh gắn bàn — phiên và bàn gửi đơn; với ba kênh không gắn bàn thêm **cách trao hàng** và **liên hệ** của khách (`T-111`, hàng `I-022` ở §2) | owner: năm kênh (`shop-facts.md` §2, danh sách đóng — **ADR-015**); vòng đời đơn (`05-vong-doi.md` §5.2). Một bảng cho cả năm kênh để ranh giới `I-006`/`I-007` là **một** điều kiện trên **một** bảng |
| `order_line` | một **dòng đơn**: số suất và dấu *đem về* | owner: `YC-05` — dấu đem về ở mức suất, không ở mức đơn. Món, giá khoá lúc đặt và ảnh chụp của dòng: [`03-luoc-do-menu-gia.md`](03-luoc-do-menu-gia.md) (`P2-05`) |

Tên bảng tiếng Anh, số ít (`QD-01`). Đơn tên `sales_order` vì `order` là từ khoá SQL — phiên chọn
2026-09-27.

---

## 2. Mệnh đề → cái giữ nó trong lược đồ → bằng chứng

Tầng ở cột thứ hai là tầng **pha 1 đã chốt** (`03-bao-ve-invariant.md` §1 · §2); lát này không đổi
nó. Tên ở cột thứ ba là tên ràng buộc trong migration (`QC-10`) — lời từ chối của database in đúng
tên ấy.

| Mệnh đề | Tầng | Lược đồ giữ bằng | Bằng chứng |
|---|:--:|---|---|
| **`I-001`** — một bàn ≤ một phiên chưa thanh toán | 1 | `table_session_member_one_unpaid_session_key` — khoá duy nhất theo **bàn**, chỉ áp cho dòng mà phiên **chưa đóng**. Điều kiện viết theo **nghĩa** *chưa đóng*, không theo một giá trị trạng thái, nên phủ cả *chờ thanh toán*. Buộc theo bàn chứ không theo phiên, nên một phiên nhiều bàn (ghép) không bị chặn, còn ghép một bàn đang có phiên sang phiên khác thì bị | `db/tests/i001_one_unpaid_session_per_table.sql` |
| **`I-002`** vế *một phiên một hoá đơn* | 1 | đơn vị tính tiền của một đơn kênh gắn bàn **là** phiên: `sales_order_session_iff_table_channel_check` buộc đơn `qr_table` · `staff_pos` có phiên, và `sales_order_session_table_fkey` buộc bàn gửi đơn là một bàn **của chính phiên ấy**. Lát này **không** có bản ghi hoá đơn riêng — không có chỗ thứ hai để một phiên có hai hoá đơn. Nếu `P2-06` thêm một bản ghi cho lần đóng/hoá đơn thì nó nợ một khoá duy nhất theo phiên (§5) | `db/tests/i002_table_order_belongs_to_session.sql` |
| **`I-002`** vế *tổng hoá đơn = tổng mọi lượt gọi* | 3 | không có cột tổng nào: tổng **cộng lại từ chi tiết** (đơn → dòng), nên không có ô thứ hai để ghi lệch (**ADR-050** tầng 3). Giá của dòng ở `P2-05` | câu đối chiếu thuộc `P2-11` |
| **`I-006`** · **`I-007`** — ranh giới phiên bàn ↔ ba kênh không gắn bàn | 1 | **một** cơ chế cho cả hai nửa (`03-bao-ve-invariant.md` §2 hàng `I-006`): `sales_order_session_iff_table_channel_check` — đơn có phiên **khi và chỉ khi** kênh gắn bàn. Tạo đơn `pickup` trong phiên, **nối** một đơn `phone_preorder` vào phiên sau khi tạo, hay đổi kênh để lách — cả ba bị từ chối | `db/tests/i007_takeaway_channels_outside_session.sql` |
| **`YC-05`** — dấu *đem về* ở mức suất | — | `order_line.is_takeaway` nằm trên **dòng**; dòng thuộc đơn bằng khoá ngoại bắt buộc, đơn thuộc phiên như hàng `I-006`. Dấu ấy không chạm tới dòng thuộc đơn nào, nên không có đường nào nó làm suất rời phiên. Một đơn mang cùng lúc dòng ăn tại chỗ và dòng đem về | `db/tests/yc05_takeaway_mark_per_line.sql` |
| **`I-022`** — đơn mang đi không tồn tại được khi thiếu trường liên hệ bắt buộc của kênh và cách trao hàng *(`T-111`, 2026-09-28)* | 1 | năm ràng buộc kiểm trên `sales_order`, giữ lúc tạo **lẫn** lúc sửa. Vế *số điện thoại*: `sales_order_takeaway_phone_check`. Vế *địa chỉ khi giao tận nơi*: `sales_order_door_delivery_address_check` — đọc **cách trao hàng**, không đọc kênh, nên phủ cả đơn hotline khách chọn giao. Vế *giờ khách cần hàng*: `sales_order_takeaway_needed_at_check`. Vế *cách trao hàng của đơn hotline* và vế *Delivery là giao, Pickup là tới lấy*: `sales_order_takeaway_handover_check`, trên tập mã của `sales_order_handover_code_check` (§4). *Thiếu* là không có **hoặc chỉ có khoảng trắng** — kịch bản *xoá trắng địa chỉ* của mệnh đề; **không** ràng buộc nào xét định dạng hay độ đúng. Tên và ghi chú có chỗ cất, không ràng buộc nào đòi (vế ngược, tầng 3). Năm tập đối chiếu của hàng `I-022` là năm câu cuối của file test | `db/tests/i022_takeaway_contact_minimum.sql` |
| **`I-024`** vế *một lần gửi, nhiều nhất một đơn* và vế *không đơn nào thiếu dấu* *(`T-116`, 2026-09-28)* | 1 | `sales_order.submission_code` — **dấu lần gửi** do phía gửi đặt. Một lượt gọi vào phiên bàn là một dòng `sales_order` (§1), nên một cột phủ cả năm kênh. `sales_order_submission_code_key` — khoá duy nhất trên **mọi** đơn, không hạn thời gian, chỉ trên dấu, **không** trên nội dung. `NOT NULL` + `sales_order_submission_code_not_blank_check` — không đơn nào thiếu dấu, kể cả lúc sửa. Cố ý **không** có giá trị mặc định: một mặc định tự sinh cấp dấu mới cho mỗi lần gửi lại. Hai lần gửi lại **song song thật** (hai kết nối): lần sau bị database giữ lại tới khi lần trước `COMMIT`, rồi bị từ chối — đúng ca *kiểm rồi mới ghi* thua | `db/tests/i024_one_submission_one_order.sql` |
| **`I-024`** ba vế tầng 3 — *gửi lại nhận lại đúng đơn* · *cùng dấu khác nội dung bị từ chối* · *giống hệt không phải là trùng* | 3 | lược đồ nợ đúng một điều: không có đường ghi nào gộp đơn theo nội dung — không khoá, không chỉ mục duy nhất nào trên món, bàn hay số điện thoại. **Pha 3 nợ:** cửa tạo đơn tra dấu **trước** mọi điều kiện khác, trả lại đơn đã có khi nội dung khớp, từ chối khi không khớp — kể cả kịch bản biên *gửi 10:59, gửi lại 11:00:30 nhận lại đơn, không phải câu ngoài giờ bán*, vì giờ bán là việc của cửa ấy (`I-008`), không của lược đồ | test dương trong cùng file: nội dung giống hệt, dấu khác ⇒ hai đơn |
| **`I-003`** — bàn trống ⟺ phiên đóng và bàn đã dọn | 3 | §3 | `db/tests/i003_clean_only_after_close.sql` |
| **`I-016`** — chuyển trạng thái ngoài §5 bị từ chối | 3 | §3 | `db/tests/i016_status_outside_lifecycle.sql` |
| **`I-017`** — phiên không đóng khi còn đơn chưa xong | 2 | §3 | `db/tests/i017_close_session_atomic.sql` |

**Vì sao `I-001` dựng bằng một bản soi, và cái gì đã bị loại** (phiên chọn 2026-09-27). Khoá duy nhất
chỉ áp cho vài dòng cần điều kiện nằm **trên chính dòng ấy**, mà *phiên đã đóng chưa* nằm ở bảng
phiên. Nên dòng `table_session_member` mang một bản soi của cờ ấy, và một **khoá ngoại hai cột**
(`table_session_member_session_fkey`, hoãn tới lúc `COMMIT`) buộc bản soi bằng bản gốc: đóng phiên mà
quên một bàn thì **cả giao dịch** bị từ chối — đúng ranh giới giao dịch mà `I-017` cần (§3). Bị loại:
- *khoá duy nhất với điều kiện `status = 'open'`* — đúng cái bẫy của entry: ràng buộc nhả ra lúc quầy
  bấm tính tiền (`03-bao-ve-invariant.md` §2 hàng `I-001`);
- *mỗi phiên đúng một bàn* — chặn nhầm ghép bàn, thứ chủ quán đã cho phép (**ADR-027**);
- *trigger đồng bộ bản soi* — là code, không phải một trong ba hình của tầng 1 (**ADR-050** điểm 1),
  và một trigger bị tắt thì không lời từ chối nào xuất hiện;
- *ràng buộc loại trừ theo khoảng thời gian* — cần cất khoảng mở/đóng của phiên, tức cần mốc đóng
  phiên, mà mốc ấy là mốc tính tiền của `P2-06` (§5).

**Vì sao liên hệ nằm trên `sales_order`, và cái gì đã bị loại** (phiên chọn 2026-09-28, `T-111`). Cả năm
vế tầng 1 của `I-022` là điều kiện đọc trên **chính một đơn**, và một ràng buộc kiểm không đọc được
bảng khác — nên các cột nằm trên đơn. Cách trao hàng cất cho **cả ba** kênh không gắn bàn, không chỉ
đơn hotline, để vế địa chỉ đọc **một** cột cho mọi đơn và để vế *Delivery là giao* có gì mà giữ.
Ràng buộc nào nhắc tới `channel_code` đọc cột tự tính `is_door_delivery` thay cho chuỗi mã cách trao
hàng, và viết *có mặt* bằng `length(...)` thay cho `<> ''`: phép kiểm `QD-02` gom **mọi** chuỗi trong
mọi ràng buộc trên `channel_code`, nên một chuỗi khác mã kênh ở đó bị đọc thành mã kênh thứ sáu.
Bị loại:
- *một bảng liên hệ riêng, một-một với đơn* — ràng buộc kiểm không buộc được *đơn Delivery phải có
  một dòng ở bảng kia*; giữ được bằng khoá ngoại hai chiều hoãn tới `COMMIT`, nhưng đó là hai đường
  ghi cho một đơn mà không lợi gì;
- *cách trao hàng chỉ cất cho đơn hotline, hai kênh kia đọc từ kênh* — vế địa chỉ phải viết hai
  nhánh, và tập đối chiếu thứ năm của hàng `I-022` không còn gì để đọc;
- *cấm cột liên hệ ở kênh gắn bàn* — mệnh đề **không áp** cho `qr_table` · `staff_pos`, không nói
  chúng cấm mang liên hệ; viết ràng buộc ấy là pha 2 tự thêm một luật (**ADR-035**).

---

## 3. Ba hàng không phải tầng 1 — lược đồ nợ gì, pha 3 nợ gì

Theo **ADR-050** điểm 1: tầng 3 nợ *không có đường ghi thứ hai*, tầng 2 nợ *một ranh giới giao dịch
viết ra*. Không hàng nào dưới đây được nâng thành ràng buộc thay cho tầng của nó.

- **`I-003` (tầng 3).** Trạng thái *Trống* của bàn **không cất thành cột** — một cột như thế là một
  đường ghi thứ hai tới đúng câu `I-003` giữ. Nó **đọc ra từ chi tiết**: bàn trống khi không có dòng
  `table_session_member` nào của bàn ấy mà phiên chưa đóng, **và** mọi dòng của bàn ấy có mốc đã dọn.
  Để phép đọc ấy đúng, `table_session_member_cleaned_after_close_check` chỉ cho ghi mốc đã dọn vào
  dòng mà phiên **đã đóng** — dọn khi phiên còn chờ thanh toán không làm bàn trống sớm hơn
  (`quality/invariants.md` `I-003` *Verification*). **Pha 3 nợ:** cửa ghi mốc đã dọn là trạm
  `don_ban` (`05-vong-doi.md` §5.3), và cửa mở phiên mới phải đọc đúng phép đọc trên.
- **`I-016` (tầng 3).** Lược đồ giữ **tập** trạng thái của từng vòng đời (`sales_order_status_check`,
  `table_session_status_check` — `QD-40`, ánh xạ ở §4) và **một** đường ghi tới *phiên đã đóng chưa*
  (cột tự tính, ghi tay bị từ chối). Lược đồ **cố ý không** mã hoá từng cặp chuyển tiếp: bảng §5 đã
  đổi ba lần, và `03-bao-ve-invariant.md` §2 hàng `I-016` chọn **một hàm xác thực** chính vì thế.
  **Pha 3 nợ:** hàm ấy. Hệ quả cần biết: *`delivering` chỉ có ở đơn giao tận nơi* cũng là việc của
  hàm ấy — lát này không có ràng buộc cho nó.
- **`I-017` (tầng 2).** **Ranh giới giao dịch viết ra:** đổi `table_session.status` sang `closed` và
  đánh dấu **mọi** dòng `table_session_member` của phiên ấy là đã đóng **cùng sống hoặc cùng chết** —
  khoá ngoại hai cột hoãn tới `COMMIT` cưỡng chế điều ấy; cắt giữa chừng thì không nửa nào sống sót
  (bằng chứng: `i017_close_session_atomic.sql`). **Pha 3 nợ:** trong **cùng** giao dịch ấy, đọc trạng
  thái của **mọi** đơn thuộc phiên — kể cả đơn của bàn ghép — và khoá chúng để không đơn nào đổi trạng
  thái giữa lúc đọc và lúc ghi. Lược đồ không tự làm được vế ấy; một ràng buộc kiểm không đọc được
  bảng khác. *Tiền chưa thu không chặn đóng phiên* (`I-005`) — lát này không có cột tiền nào để chặn
  nhầm.

---

## 4. Bảng ánh xạ trạng thái (`QD-40`)

Mã là chữ ASCII (`QD-40`); tên ở cột cuối là tên ở owner, viết đúng chữ của
`docs/product/0-ba/ban-hang/05-vong-doi.md`. Hàm `qd40b` của `scripts/db-check.sh` so tập mã ở đây với
tập mã trong ràng buộc kiểm — mỗi dòng giữ đúng dạng của nó.

| Cột | Mã | Tên ở owner |
|---|---|---|
| `sales_order.status` | `new` | Mới (§5.2) |
| `sales_order.status` | `pending_confirmation` | Chờ xác nhận (§5.2) |
| `sales_order.status` | `confirmed` | Đã xác nhận (§5.2) |
| `sales_order.status` | `in_progress` | Đang thực hiện (§5.2) |
| `sales_order.status` | `delivering` | Đang giao (§5.2) |
| `sales_order.status` | `completed` | Hoàn thành (§5.2) |
| `sales_order.status` | `cancelled` | Huỷ (§5.2) |
| `table_session.status` | `open` | Mở (§5.3) |
| `table_session.status` | `serving` | Đang phục vụ (§5.3) |
| `table_session.status` | `awaiting_payment` | Chờ thanh toán (§5.3) |
| `table_session.status` | `closed` | Đã đóng (§5.3) |

Hai trạng thái **của cái bàn** ở §5.3 — *Bàn cần dọn* và *Trống* — **không** có mã: chúng đọc ra từ
chi tiết (§3, `I-003`).

**Mã cách trao hàng** (`sales_order.handover_code`, `T-111`) — không phải trạng thái, nên không thuộc
`QD-40(b)`; hai nhánh của `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.2.2. Owner không đặt chữ máy
đọc cho hai nhánh (`master_plan/shop-facts.md` §5.2 chỉ có tên), nên hai mã là **phiên chọn
2026-09-28**; `QD-02` không áp.

| Mã | Tên ở owner |
|---|---|
| `door_delivery` | Giao tận nơi (§3.2.2) |
| `shop_pickup` | Khách tới lấy (§3.2.2) |

---

## 5. Chỗ trống có tên — cái lát này cố ý chưa giữ

| Chỗ trống | Lược đồ hôm nay đứng thế nào | Ai gỡ |
|---|---|---|
| ~~**`F-038`** — *thiếu một trường bắt buộc thì đơn không tạo được* (`03-lat-cat.md` §3.2.4)~~ — **gỡ 2026-09-28 (`T-111`)**. Pha 1 lấp trước (T-110, `docs/decisions.md` **ADR-058**: `I-022`, tầng 1, `YC-22`), rồi lược đồ dựng | chỗ cất và năm ràng buộc: §2 hàng `I-022`. Lý do nó từng là chỗ trống, giữ làm lịch sử: dựng ràng buộc trước khi có mệnh đề là pha 2 tự viết mệnh đề (**ADR-035**) | `T-111` — xong |
| ~~**`F-043`** — *một lần gửi đơn thành đúng một đơn*~~ — **gỡ 2026-09-28 (`T-116`)**. Pha 1 lấp trước (T-115, `docs/decisions.md` **ADR-061**: `I-024`, `YC-25`), rồi lược đồ dựng | chỗ cất dấu và hai ràng buộc tầng 1: §2 hàng `I-024` | `T-116` — xong |
| **Tập đối chiếu thứ ba của `I-024`** — đơn mà nội dung hiện tại khác nội dung lúc tạo **mà không** có một lần sửa mang vết `I-018` | chưa viết được: lát này không có vết sửa nào. Hai tập kia đã là câu truy vấn ở cuối `db/tests/i024_one_submission_one_order.sql` | `P2-08` (vết cập nhật), gom ở `P2-11` |
| **`F-042`** — mã QR của bàn — pha 1 **đã lấp 2026-09-28** (T-113, `docs/decisions.md` **ADR-060**): mệnh đề `quality/invariants.md` **`I-023`**, tầng ở [`../1-system-design/03-bao-ve-invariant.md`](../1-system-design/03-bao-ve-invariant.md) §1, yêu cầu **`YC-24`**; lược đồ **chưa** dựng | `dining_table` không có cột mã QR, không lịch sử mã, và lượt gọi không ghi mã đã mang — hôm nay kênh `qr_table` không có gì để tra bàn | `work/backlog.md` **T-114** — một migration **mới** (file của lát này không sửa, `QC-05`) |
| ~~**Món, giá khoá lúc đặt, tuỳ chọn đã chọn** trên dòng đơn~~ — **gỡ 2026-09-27 (`P2-05`)** | `P2-05` thêm vào `order_line` bằng migration **mới** (file của lát này không sửa, `QC-05`) và dựng chỗ cất tuỳ chọn đã chọn — [`03-luoc-do-menu-gia.md`](03-luoc-do-menu-gia.md) §1. Lý do giao sang, giữ làm lịch sử: mọi cột của tuỳ chọn đã chọn là ảnh chụp của một thứ trong menu, nên dựng nó ở đây là đặt hình dạng thay `P2-05` | `P2-05` — xong |
| **Mốc tính tiền** của lần đóng phiên và của đơn lẻ (`booked_at` · `sale_date`, `QD-31` · `QD-33`) | lát này không cất mốc đóng: mốc ấy **là** mốc tính tiền (`02-thoi-gian-ngay-ban.md` §2), và một mốc đóng thứ hai ở đây sẽ là mốc tính tiền thứ hai | `P2-06` |
| **Bản ghi hoá đơn / lần thu** của một đơn vị tính tiền | chưa có. Bản ghi nào `P2-06` thêm cho lần đóng một phiên nợ một **khoá duy nhất theo phiên** (`I-002` vế 1), và cho đơn lẻ nợ đúng một lần thu khi đóng (`I-007` phép đối chiếu) | `P2-06` |
| **Ai bấm** mỗi thao tác, **vết cập nhật** (`I-012` · `I-018`) | lát này không có cột người, không có vết | `P2-08` |
| **Dấu đem về đọc ở bảng bếp**, bàn nhận việc | lát này chỉ cất dấu trên dòng | `P2-07` (đơn vị bấm *đã bưng ra bàn* vẫn để trống — `S-5`) |

**Tham số của `01-quy-uoc-du-lieu.md` §0:** lát này **không** thêm bảng nào vào `:bang_ky_thuat`
(mọi bảng đều mang dữ liệu nghiệp vụ, không bảng nào được xoá) và không bảng nào vào
`:bang_khong_quan_he_so_hoc` (lát không có cột tiền).

---

## 6. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2-05` | §1 hàng `order_line` · §5 hàng *món, giá, tuỳ chọn* — thêm bằng migration **mới**, không sửa file của lát này (`QC-05`) |
| `P2-06` | §5 hàng *mốc tính tiền* và *bản ghi hoá đơn*; đơn vị tính tiền là `table_session` (kênh gắn bàn) hoặc `sales_order` (ba kênh kia) |
| `P2-07` | `order_line` và dấu đem về; bàn gửi đơn ở `sales_order` |
| `P2-09` | file migration của lát này là file đầu tiên của dãy; phép so tên bảng `.md` ↔ migration đọc §1 |
| `P2-11` | §2 cột *Bằng chứng* và §3 — mỗi mệnh đề vẫn cần câu đối chiếu của mình (**ADR-050** luật 2), kể cả những hàng đã có ràng buộc; hàng `I-022` đã có năm câu ở cuối file test của nó |
| pha 3 | §3 — ba chỗ *Pha 3 nợ* |
