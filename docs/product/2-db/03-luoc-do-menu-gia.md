# Lược đồ lát menu · giá · ảnh chụp giá lúc đặt

Pha 2 · bước `P2-05` · viết 2026-09-27 (Claude Code). File lát thứ hai của `docs/product/2-db/`; hàng
*Schema* của `CLAUDE.md` §2 **thêm** tên file này cạnh file của `P2-04`, không ghi đè.

**Bản nào thắng** (`docs/decisions.md` **ADR-053** luật 2): tên bảng · tên cột · kiểu · ràng buộc
thuộc file migration
[`db/migrations/20260927140000_menu_gia.up.sql`](../../../db/migrations/20260927140000_menu_gia.up.sql).
File này giữ **ý định, lý do và ánh xạ** sang `I-0xx`. Nó nhắc tên bảng và tên ràng buộc để trỏ,
**không** chép kiểu hay điều kiện thành bản thứ hai (**F-001**). Hai bản lệch nhau ⇒ một dòng
`F-XXX`, không lặng lẽ sửa bên nào.

**File này KHÔNG sở hữu:**
- **giá, thành phần, danh sách món** — `master_plan/shop-facts.md` §4.2–§4.9 (**ADR-001**). Lược đồ
  là **chỗ cất**; không một con giá nào của quán nằm ở đây hay ở `db/`. Menu thật do `P2-10` dựng,
  bằng cách **tra** owner;
- **luật nghiệp vụ và tầng bảo vệ** — `quality/invariants.md` và
  `docs/product/1-system-design/03-bao-ve-invariant.md` §3. Lát này thi hành tầng đã chốt, không
  nâng, không hạ (**ADR-050** luật 1);
- **hàm tính giá** — *một hàm tính giá duy nhất* là đầu ra của **pha 3** (kế hoạch pha 2 §11). Phép
  cộng trong test ở §2 chỉ để chứng minh dữ liệu **đủ** cho hàm ấy, không phải hàm ấy;
- **vết** của lần sửa menu (`I-011` · `I-018`) — `P2-08`; **việc trạm** nổ ra từ thành phần — `P2-07`;
- **cất bằng gì** — [`01-quy-uoc-du-lieu.md`](01-quy-uoc-du-lieu.md); **dựng và kiểm bằng gì** —
  [`10-quy-uoc-code.md`](10-quy-uoc-code.md). Lát bán hàng mà lát này thêm vào:
  [`02-luoc-do-ban-hang.md`](02-luoc-do-ban-hang.md).

---

## 0. Cách đọc

Cùng hai nguồn như §0 của `02-luoc-do-ban-hang.md`: **owner** (dịch một câu đã chốt) · **phiên chọn
2026-09-27** (lựa chọn thiết kế của lượt này, **chưa có lời chủ repo** — đổi được bằng một migration
mới kèm lý do ở đây, trước khi code pha 3 dựa vào nó).

**Bằng chứng** của mỗi hàng ở §2 là một file ở `db/tests/`, chạy trong `./scripts/db-check.sh`
(`QC-07`). Số và tên trong các test là **giả** (`test-…`), vì một con giá thật trong file pha 2 là
bản chép thứ hai của `shop-facts.md`.

---

## 1. Mười bảng — bảy bảng menu hiện hành, ba chỗ cất ảnh chụp

**Menu hiện hành** — cái chủ quán sửa, và cái cửa tạo lượt gọi ở pha 3 đọc:

| Bảng | Giữ gì | Vì sao · nguồn |
|---|---|---|
| `menu_component` | một **thành phần có giá** — giá gốc và cờ *có nhận nhân không* | owner: giá một suất là **tổng giá thành phần** (`shop-facts.md` §4.6 luật 1), giá gốc là giá **chay** (luật 2); *nhận nhân* là của thành phần, không của suất (§4.5 cột cuối, luật 6 — giò không nhận ở suất nào) |
| `menu_item` | một **dòng menu** (suất bán) và **mốc ngừng bán** | owner: §4.9. Ngừng bán là một **mốc**, không phải lệnh xoá (`QD-50`; `03-lat-cat.md` §3.3.4 *biến khỏi menu, không biến khỏi đơn cũ*). Mốc thay vì một `status`: owner không có vòng đời nào cho món ở `05-vong-doi.md` §5 để ánh xạ (`QD-40`) — phiên chọn |
| `menu_item_component` | **thành phần của một suất**: thành phần nào, bao nhiêu | owner: §4.5. **Giá suất không cất**: một ô giá suất là đường ghi thứ hai tới một con số vốn là tổng (§4.6 luật 1, **ADR-050** tầng 3) |
| `option_group` | một **nhóm tuỳ chọn**, dùng chung cho nhiều suất | owner: §4.4. Nhóm độc lập với suất, nối bằng bảng dưới — một nhóm khai **một** lần (bài học dự án cũ `nghien-cuu.md` §2.4) |
| `menu_option` | một **lựa chọn** trong nhóm và **phụ thu cho mỗi phần nhận nhân** | owner: §4.6 luật 5 — hệ số ×1 · ×4 · ×5 là **hệ quả**, không cất ở đâu; đổi phụ thu là sửa **một** dòng |
| `menu_item_option_group` | suất nào mang nhóm nào | owner: §4.8 ca 12 — món không nhận nhân **không** hiện nhóm nhân; suất không có dòng nào ở đây thì không mang nhóm nào |
| `option_group_prerequisite` | **tập** lựa chọn mà một nhóm cần: nhóm có mặt khi **ít nhất một** lựa chọn trong tập được chọn; không dòng nào = luôn có mặt | owner: §4.6 luật 3 — *Lượng nhân chỉ có khi nhân ≠ Chay* là **hai** dòng (Thịt, Thịt + mộc nhĩ). Một tham chiếu tới **một** lựa chọn chỉ giữ nửa luật, nửa kia rơi xuống code (`nghien-cuu.md` §2.5). Loại nhân thứ tư = thêm một dòng |

**Ảnh chụp lúc đặt** — cái đơn cũ đọc lại, **không chạm** menu hiện hành:

| Bảng · cột | Giữ gì | Vì sao · nguồn |
|---|---|---|
| `order_line` (của `P2-04`) — cột thêm | **mã gốc** của món, **tên món** đã chụp, **giá dòng** đã khoá, **thành tiền** tự tính, **mốc khoá giá** của riêng dòng, và **số** ảnh chụp thành phần dòng phải có | owner: `I-009` (giá · tên · thành phần) và `03-lat-cat.md` §3.3.3. Thành tiền là cột tự tính (`QD-22`). Mốc khoá giá tách khỏi `created_at` vì mốc ấy **đặt lại** khi người sửa dòng (`U-026`, `shop-facts.md` §6.19) — phiên chọn |
| `order_line_component` | ảnh chụp **từng thành phần** của suất trên dòng: mã gốc, tên, số lượng, có nhận nhân không, **giá gốc đã áp** | owner: `03-lat-cat.md` §3.3.2 cột *Đơn cũ phải giữ nguyên* — *"giá từng thành phần đã áp"* và *"suất đó gồm những gì, và bao nhiêu phần nhận nhân"*; §3.3.1 bước 7 — việc bếp không bị viết lại |
| `order_line_option` | ảnh chụp **từng tuỳ chọn đã chọn**: **mã gốc** (khoá ngoại về lựa chọn), tên nhóm, tên lựa chọn, **phụ thu đã áp** | owner: §3.3.2 — *"mức phụ thu đã áp"*. Mã gốc cạnh tên: đổi tên hiển thị không làm phép đếm theo tuỳ chọn gãy đôi (`nghien-cuu.md` §2.6). Đây là **tuỳ chọn đã chọn** mà `P2-04` giao sang (`02-luoc-do-ban-hang.md` §5) |

Tên tiếng Anh, số ít (`QD-01`). Thành phần tên `menu_component` chứ không `component` để đọc được
nó thuộc menu — phiên chọn 2026-09-27.

---

## 2. Mệnh đề → cái giữ nó trong lược đồ → bằng chứng

Tầng ở cột thứ hai là tầng **pha 1 đã chốt** (`03-bao-ve-invariant.md` §3); lát này không đổi nó.

| Mệnh đề | Tầng | Lược đồ giữ bằng | Bằng chứng |
|---|:--:|---|---|
| **`I-009`** vế *lưu bản sao* — dòng đơn thiếu giá, tên món hoặc thành phần đã chụp thì không tồn tại được | 1 | giá và tên món là cột **bắt buộc** trên dòng; ảnh chụp thành phần giữ bằng **ba khoá ngoại hoãn tới `COMMIT`**: dòng khai *n* thành phần ⇒ `order_line_last_component_fkey` đòi vị trí *n* có mặt, `order_line_component_previous_position_fkey` đòi mỗi vị trí *p* > 1 có vị trí *p − 1*, `order_line_component_line_fkey` + `order_line_component_position_in_range_check` cấm vị trí vượt *n*. Ba cái cùng nhau: **đúng** *n* dòng, liền từ 1 — thiếu một dòng là cả giao dịch bị từ chối. Ảnh chụp **không trỏ** vào giá hiện hành: mọi giá, tên, số lượng đọc từ chính nó | `db/tests/i009_snapshot_survives_menu_change.sql` — đổi giá thành phần · phụ thu · thành phần suất · tên món · tên tuỳ chọn · ngừng bán, đơn cũ đọc lại nguyên; một đơn mang hai mức giá cho cùng món |
| **`I-009`** vế *mốc khoá là từng lượt gọi* | 3 | mốc khoá nằm **trên dòng** (`priced_at`), không trên phiên: lát này không có ô giá nào ở mức phiên hay đơn để khoá nhầm | cửa tạo lượt gọi — pha 3 |
| **`I-010`** — tổ hợp không hợp lệ bị **từ chối**, không sửa hộ | 3 | **§3** — database **không** từ chối *Chay + Nhiều nhân* | `db/tests/i010_filling_rule_as_set.sql` |
| **`I-013`** — giá do hệ thống tính lại | 3 | §3 | `db/tests/i013_surcharge_changes_in_one_place.sql` |
| **`I-011`** — đổi thành phần suất trong giờ bán không âm thầm | 4 | §3 | — (chỗ cất vết thuộc `P2-08`) |
| **§4.6 luật 5** — phụ thu +1 bậc cho **mỗi** phần nhận nhân | — | phụ thu cất **một** lần trên `menu_option`; số phần nhận nhân đọc ra từ `menu_item_component` × `menu_component.takes_filling` — không ô nào cất hệ số | `db/tests/i013_surcharge_changes_in_one_place.sql` — đổi phụ thu **một lệnh, một dòng** ⇒ năm hình suất đổi đúng Δ × 1 · 4 · 4 · 5 · 0 |

**Vì sao ảnh chụp thành phần dựng bằng chuỗi vị trí, và cái gì đã bị loại** (phiên chọn 2026-09-27).
*"Phải có ít nhất một dòng con"* không viết được bằng khoá duy nhất, điều kiện kiểm hay một khoá
ngoại thường — ba hình của tầng 1 (**ADR-050** điểm 1) đều nhìn từ dòng con lên. Dòng đơn vì thế
**khai số** ảnh chụp của nó, và khoá ngoại từ dòng đơn **xuống** vị trí cuối, cộng khoá ngoại từ mỗi
vị trí xuống vị trí trước, biến *"đủ n dòng"* thành ba khoá ngoại. Cùng họ với bản soi + khoá ngoại
hai cột của `I-001` (`02-luoc-do-ban-hang.md` §2). Bị loại:
- *chỉ cột `NOT NULL` trên dòng đơn, ảnh chụp thành phần tuỳ ý* — một dòng không có thành phần nào
  vẫn ghi được, tức vế thứ tư của `I-009` tụt tầng trong im lặng (**ADR-050** luật 1);
- *trigger đếm dòng con lúc `COMMIT`* — là code, không phải một hình của tầng 1, và bị tắt thì không
  lời từ chối nào xuất hiện;
- *cất thành phần thành một cột mảng hay `jsonb` trên dòng đơn* — `QC-04` chưa có dòng cho hai kiểu
  ấy, và mảng không mang được khoá ngoại về thành phần gốc cho `P2-07` đọc.

---

## 3. Bốn hàng không phải tầng 1 — lược đồ nợ gì, pha 3 nợ gì

- **`I-010` (tầng 3).** `03-bao-ve-invariant.md` §3 chốt: danh sách tổ hợp không hợp lệ **tra theo
  luật**, ở **một cửa** trước khi tạo dòng — vì chủ quán sửa menu thì danh sách đổi mà mệnh đề không
  đổi chữ nào. Nên database **không** từ chối *Chay + Nhiều nhân*; dựng một ràng buộc cho nó là nâng
  tầng, việc của pha 1. **Lược đồ nợ, và đã giữ:** luật nằm **trọn trong dữ liệu, một chỗ**
  (`option_group_prerequisite`, theo tập), nên cửa ở pha 3 đọc luật chứ không mang một nửa của nó
  trong code; và ảnh chụp tuỳ chọn không mở đường ghi một lựa chọn **không có gốc** (khoá ngoại). Test
  in: *Chay + Nhiều nhân ⇒ KHÔNG hợp lệ*, *Thịt + Nhiều nhân* và *Thịt + mộc nhĩ + Nhiều nhân ⇒ hợp
  lệ* — đọc chỉ trên dữ liệu. **Pha 3 nợ:** cửa ấy, từ chối **toàn bộ** yêu cầu, áp cho cả năm kênh;
  và vế *"tổ hợp khác tổ hợp khách gửi"* của phép đối chiếu cần giữ **yêu cầu gốc** — chỗ trống §5.
- **`I-013` (tầng 3).** Database không biết một con số **đến từ đâu** (`03-bao-ve-invariant.md` §1).
  **Lược đồ nợ, và đã giữ:** không cột nào mang *giá khách gửi*; mỗi dòng có **một** cột giá ghi được
  (`unit_price_vnd`), thành tiền tự tính; hai cột tiền của ảnh chụp là **giá đã áp** của thành phần
  và tuỳ chọn, ghi cùng lúc bởi cùng cửa — test liệt kê đủ bốn cột tiền của dòng đơn và ảnh chụp, và
  **đỏ** khi họ `order_line` có một cột tiền thứ năm (2026-09-28, P2-05 phần *test biết kêu*): ai thêm
  cột ấy phải nói nó không phải giá khách gửi rồi mới sửa danh sách trong test.
  **Pha 3 nợ:** một hàm tính giá duy nhất, mọi đường đặt món của năm kênh đi qua nó.
- **`I-011` (tầng 4).** Máy **không** ngăn được việc đổi thành phần giữa giờ bán (chủ quán giữ quyền ấy,
  `U-018`), và lát này **không** dựng gì chặn: không cột khoá, không điều kiện giờ. Cái máy giữ thay
  vào là **vết** — *đổi cái gì, lúc mấy giờ, ai bấm* — và chỗ cất vết là của `P2-08` (**ADR-050**
  tầng 4: vết sống độc lập với bản ghi). Hôm nay sửa `menu_item_component` là một lần cập nhật **không
  để lại vết nào** — chỗ trống §5. Lời nhắc trước khi lưu là của pha 3/4.
- **`I-009` vế *mốc khoá* (tầng 3)** — §2. Ngoại lệ *sửa một dòng* (`U-026`, tầng 4 + vết tầng 2) cần
  vết giá cũ/giá mới trong cùng giao dịch — `P2-08`.

---

## 4. Tham số của `01-quy-uoc-du-lieu.md` §0

Lát này **không** thêm bảng nào vào `:bang_ky_thuat` — mọi bảng mang dữ liệu nghiệp vụ; bảng menu
không xoá, ngừng bán là mốc (`QD-50`). **Không** bảng nào vào `:bang_khong_quan_he_so_hoc`: bảng duy
nhất có hai cột tiền là `order_line`, và quan hệ của nó (thành tiền = giá × số suất) là cột tự tính
(`QD-22`). Quan hệ **giữa** giá dòng và ảnh chụp của nó đi qua nhiều bản ghi — §5.

Lát này **không** thêm cột `status` nào, nên không có bảng ánh xạ `QD-40`.

---

## 5. Chỗ trống có tên — cái lát này cố ý chưa giữ

| Chỗ trống | Lược đồ hôm nay đứng thế nào | Ai gỡ |
|---|---|---|
| **Vế *ngừng bán hẳn* của `I-009`** — *món đã ngừng thì không kênh nào đặt mới được* | lược đồ **cất** mốc ngừng bán (`menu_item.discontinued_at`) vì `QD-50` cấm xoá, và **cố ý không** có ràng buộc nào chặn một dòng đơn mới trỏ vào món đã ngừng — test `i009` in đúng câu ấy. Pha 1 chọn **tầng 3** cho vế này ngày 2026-09-27 (**ADR-056**, đóng `work/findings.md` **F-036**): cửa tạo lượt gọi từ chối, không phải database. Mốc đã cất là thứ tập đối chiếu của hàng `I-009` cần | `P2-11` — tập đối chiếu tầng 5; cửa từ chối ở pha 3 |
| **Giá dòng = tổng ảnh chụp của nó** — `unit_price_vnd` = Σ số lượng × giá gốc đã áp + Σ phụ thu đã áp × số phần nhận nhân | quan hệ đi qua nhiều bản ghi, không điều kiện kiểm nào viết được (`QD-22` loại trừ tổng qua bản ghi). Dữ liệu **đủ** để câu đối chiếu cộng lại | `P2-11` — một câu truy vấn tầng 5 |
| **Giá đang hiệu lực tại một mốc đã qua** (phép đối chiếu `I-013` · `I-010` so với *luật tại đúng mốc*) | menu cất giá **hiện hành**, sửa tại chỗ; giá cũ không còn trên menu. Lịch sử đọc lại từ **vết cập nhật** — `I-018` liệt kê *chủ quán đổi giá hoặc thành phần suất* là một lần cập nhật phải giữ bản trước/bản sau | `P2-08` |
| **Vết của lần sửa menu** (`I-011` · `I-018`) | không có | `P2-08` |
| **Yêu cầu gốc của khách** (vế *"tổ hợp khác tổ hợp khách gửi"* của đối chiếu `I-010`) | ảnh chụp giữ tổ hợp **đã ghi**, không giữ yêu cầu gửi lên | pha 3 quyết có cất hay không; nếu cất thì một migration mới |
| **Sửa một dòng đã đặt** (`U-026`) khi món đổi | shop_app không xoá được (`QD-50`), nên ảnh chụp thành phần không bỏ được dòng; sửa đổi món sẽ cần một đường *thay dòng* thay vì sửa tại chỗ | pha 3 · `P2-08` (vết giá cũ/giá mới) |
| **Số lựa chọn mỗi nhóm** (*nhân bắt buộc chọn 1*, §4.4) và **mặc định** *Thịt · Thường* (§4.6 luật 7 · 8) | chưa cất; cửa ở pha 3 giữ. Cất thành dữ liệu thì một migration mới | pha 3 |
| **Trứng chín / tái / vàng** là ba thành phần hay một thành phần trong ba suất | lược đồ cho cả hai. Dữ liệu mồi đã chọn **ba thành phần** — [`08-du-lieu-moi.md`](08-du-lieu-moi.md) §2, chủ repo xác nhận 2026-09-30; trạm nào cần đọc độ chín là việc trạm | `P2-10` (đã chọn, đã xác nhận) · `P2-07` |
| **Hết giữa buổi** | cố ý **không** có cờ *tạm hết* trên món: owner tách *ngừng bán* (đổi menu) khỏi *hết giữa buổi* (**tạm dừng nhận đơn**, `shop-facts.md` §6.8 · §6.20) | — cần thì hỏi chủ quán |
| **Ai đổi menu** (chỉ chủ quán — `03-lat-cat.md` §3.3.1 bước 1) | không có cột người | `P2-08` · pha 3 |

---

## 6. Bước sau đọc gì ở đây

| Bước | Lấy gì |
|---|---|
| `P2-07` | `order_line_component` — thành phần đã chụp là thứ việc trạm nổ ra từ đó (`shop-facts.md` §5.3); §5 hàng *trứng chín/tái/vàng* |
| `P2-08` | §3 `I-011` · §5 ba hàng vết — sửa menu và sửa dòng đơn là hai lần cập nhật phải giữ bản trước/bản sau |
| `P2-10` | §1 — menu thật dựng vào bảy bảng menu, **tra** `shop-facts.md` §4.2–§4.5; mười ba ca của §4.8 tính lại từ dữ liệu ra đúng từng đồng |
| `P2-11` | §5 hàng *giá dòng = tổng ảnh chụp*; §2 cột *Bằng chứng* — mỗi mệnh đề vẫn cần câu đối chiếu của mình (**ADR-050** luật 2) |
| pha 3 | §3 — ba chỗ *Pha 3 nợ*; hàm tính giá đọc **đúng** các bảng §1, không cất giá suất ở chỗ thứ hai |
