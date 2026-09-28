# Lược đồ lát bán hàng lõi — bàn, phiên bàn, đơn, dòng đơn, suất đem về

Pha 2 · bước `P2-04` · viết 2026-09-27 (Claude Code). Đây là **file lát đầu tiên** của
`docs/product/2-db/`, nên nó là file đổi hàng *Schema* của `CLAUDE.md` §2 từ *chưa có owner* sang có
owner (**ADR-035** luật 2).

**Bản nào thắng** (`docs/decisions.md` **ADR-053** luật 2): tên bảng · tên cột · kiểu · ràng buộc
thuộc file migration
[`db/migrations/20260927120000_ban_hang_loi.up.sql`](../../../db/migrations/20260927120000_ban_hang_loi.up.sql).
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
| `sales_order` | một **đơn** của bất kỳ kênh nào: kênh, trạng thái, và — chỉ khi kênh gắn bàn — phiên và bàn gửi đơn | owner: năm kênh (`shop-facts.md` §2, danh sách đóng — **ADR-015**); vòng đời đơn (`05-vong-doi.md` §5.2). Một bảng cho cả năm kênh để ranh giới `I-006`/`I-007` là **một** điều kiện trên **một** bảng |
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

---

## 5. Chỗ trống có tên — cái lát này cố ý chưa giữ

| Chỗ trống | Lược đồ hôm nay đứng thế nào | Ai gỡ |
|---|---|---|
| **`F-038`** — *thiếu một trường bắt buộc thì đơn không tạo được* (`03-lat-cat.md` §3.2.4) — pha 1 **đã lấp 2026-09-28** (T-110, `docs/decisions.md` **ADR-058**): mệnh đề `quality/invariants.md` **`I-022`**, tầng 1 ở [`../1-system-design/03-bao-ve-invariant.md`](../1-system-design/03-bao-ve-invariant.md) §2, yêu cầu **`YC-22`**; lược đồ **chưa** dựng | lát này **không có cột liên hệ nào** — số điện thoại, địa chỉ giao, giờ khách cần hàng — và **không** ràng buộc nào cho vế ấy. Một đơn `delivery` tạo được mà không có địa chỉ, vì chưa có chỗ nào để cất địa chỉ. Dựng ràng buộc trước khi có mệnh đề là pha 2 tự viết mệnh đề (**ADR-035**) | `work/backlog.md` **T-111** — một migration **mới** thêm chỗ cất + ràng buộc (file của lát này không sửa, `QC-05`) |
| **`F-043`** — *một lần gửi đơn thành đúng một đơn* — pha 1 **đã lấp 2026-09-28** (T-115, `docs/decisions.md` **ADR-061**): mệnh đề `quality/invariants.md` **`I-024`**, tầng ở [`../1-system-design/03-bao-ve-invariant.md`](../1-system-design/03-bao-ve-invariant.md) §1, yêu cầu **`YC-25`**; lược đồ **chưa** dựng | lát này **không có chỗ cất dấu lần gửi** nào: một lần gửi lại thành đơn **thứ hai**, và database không chặn. Khoá phải đặt trên **dấu**, không trên nội dung — hai đơn giống hệt mang hai dấu là hai đơn thật (`I-024`) | `work/backlog.md` **T-116** — một migration **mới** (file của lát này không sửa, `QC-05`) |
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
| `P2-11` | §2 cột *Bằng chứng* và §3 — mỗi mệnh đề vẫn cần câu đối chiếu của mình (**ADR-050** luật 2), kể cả bốn hàng đã có ràng buộc |
| pha 3 | §3 — ba chỗ *Pha 3 nợ* |
