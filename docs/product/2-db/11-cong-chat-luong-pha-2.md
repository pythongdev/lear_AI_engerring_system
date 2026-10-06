<a id="top"></a>
# Cổng chất lượng pha 2 — ba scenario nghiệm thu diễn qua lược đồ, và mười hai ô sang pha 3

Pha 2 · bước `P2-13` · viết 2026-09-30 (Claude Code). Đầu vào:
[`../0-ba/ban-hang/08-scenario.md`](../0-ba/ban-hang/08-scenario.md) §8 (ba scenario) ·
[`../1-system-design/04-yeu-cau-du-lieu.md`](../1-system-design/04-yeu-cau-du-lieu.md) (đề bài `YC`) ·
[`../../../master_plan/DB_master_plan_banh_cuon_ba_thanh.md`](../../../master_plan/DB_master_plan_banh_cuon_ba_thanh.md)
§9 (lời của mười hai ô) · mười file pha 2 đứng trước file này. Cách ký: `docs/decisions.md` **ADR-067**.

> **File này sở hữu đúng hai thứ:** **biên bản lượt diễn** ba scenario qua lược đồ và lượt chấm ngược
> các dòng `YC`, và **trạng thái đã ký của mười hai ô cổng sang pha 3**, mỗi ô kèm bằng chứng.
>
> **Nó không sở hữu một bước scenario nào** (nhà: `08-scenario.md` §8), **một dòng yêu cầu nào** (nhà:
> `04-yeu-cau-du-lieu.md`), **một ràng buộc nào** (nhà: file migration, **ADR-053** luật 2), **một dữ
> kiện quán nào** (nhà: `master_plan/shop-facts.md`, **ADR-001**), hay **lời của mười hai ô** (nhà: kế
> hoạch §9 — ở đây chép hình dạng và thêm bằng chứng, như cổng pha 1).
>
> **Bằng chứng không phải bản chụp dán tay.** Mọi dòng dưới đây in lại mỗi lần chạy
> `./scripts/db-check.sh` — **bước 7**, code ở [`db/scenario/`](../../../db/scenario/yc.sql). Một lát sau
> đổi lược đồ làm một ô sai thì bộ kiểm đỏ, không phải file này lặng lẽ cũ đi (**F-001** · **F-033**).
> Con số ở đây là bản đo **2026-09-30**; đọc số sống ở output của lệnh.

---

## 0. Cách đọc

**Diễn thế nào.** Ba scenario chạy trên database kiểm của `db-check` — lược đồ đủ tám bước migration,
dữ liệu mồi dựng từ `shop-facts.md` — trong một ngày bán giả định là *ngày mai*, giờ bán 06:00–11:00.
**Mỗi bước ở quán là một giao dịch được COMMIT**, như cửa ghi của pha 3 sẽ ghi, nên mọi ràng buộc hoãn
được chấm ở từng bước chứ không một lần ở cuối. Các hàm đứng thay cửa pha 3 (tạo lượt gọi, nổ đơn, bấm
mẻ, đóng phiên) nằm ở `db/scenario/prelude.sql`; chúng không quyết luật nào.

**Đọc lại thế nào.** Ở **một kết nối khác**, sau COMMIT, chỉ từ dữ liệu (`db/scenario/doc_lai.sql`):
mỗi dòng *Kết quả mong đợi* của `08-scenario.md` được kiểm bằng **quan hệ** — hoá đơn bằng tổng dòng,
dòng mới trừ dòng cũ bằng số bánh nhân phần tăng giá gốc đọc từ vết — không chép con giá nào.

**Chấm YC thế nào** (`db/scenario/yc.sql`). Mỗi mã một dòng **đọc** (in từ dữ liệu) và ít nhất một
dòng **sai** mang một trong năm kết cục có tên — vì `04-yeu-cau-du-lieu.md` §0 luật 2 nói *"không xảy ra
được" không có nghĩa là "database phải chặn"*:

| Kết cục | Nghĩa |
|---|---|
| **TỪ CHỐI** | database từ chối trạng thái sai — lời nguyên văn |
| **KHÔNG CHỖ** | lược đồ không có chỗ nào để trạng thái sai ấy đứng — in bằng chứng vắng mặt |
| **ĐI QUA** | cái sai là *chặn nhầm* một việc hợp lệ — việc ấy ghi được |
| **GỌI TÊN** | database không chặn (tầng 3–5 của `03-bao-ve-invariant.md`), một câu đối chiếu gọi tên nó — kèm file lỗi cài đã chứng minh câu ấy biết kêu |
| **DỰNG ĐƯỢC** · **CHƯA TRẢ LỜI ĐƯỢC** | chỗ hở — kèm mã |

Mỗi kết cục tự kiểm: một TỪ CHỐI không còn xảy ra, hay một chỗ hở đã được lấp mà dòng chấm chưa đổi ⇒
`db-check` FAIL.

---

## 1. Scenario 1 — khách QR tại bàn, ba lượt gọi, thu tiền một lần

Mười bảy bước, số bước là số của `08-scenario.md`. Cột phải là dòng `db-check` in ra (mã dòng lược đi).

| # | Bước ở quán | Ghi được · đọc lại được — output 2026-09-30 |
|:--:|---|---|
| 1–2 | QR gọi lượt đầu; phiên mở lúc lượt gọi tạo; giá do hệ thống tính | *phiên … mở cho bàn 5 lúc lượt 1 tạo · lượt 1 (qr_table) chờ duyệt · tiền lượt 1 = 68000 đ* |
| 3–4 | Quầy duyệt; trước duyệt 0 việc; nổ sáu việc trên ba trạm | *trước duyệt: 0 việc trạm · sau duyệt: 19 việc (đơn vị) trên 3 trạm*; đọc lại: *canh nước chấm×1 · gap_banh Bánh cuốn×6 · Giò×2 · Trứng tái×2 · trang_banh Bánh cuốn×6 · Trứng tái×2* — **sáu** việc, 19 đơn vị |
| 5–6 | Quầy bấm mẻ rồi *đã ra bàn*; lượt 1 Hoàn thành | *mẻ … · lượt 1: completed*. Đơn vị **bấm** của *đã ra bàn* còn là `S-5` — kịch bản bấm theo đơn chỉ để đi tiếp (§6) |
| 7–9 | Lượt 2 quầy đặt hộ, thẳng *Đã xác nhận*, vào **chính** phiên | *lượt 2 (staff_pos) vào phiên … · 25000 đ · số phiên chưa đóng của bàn 5: 1*; đường: *new→confirmed confirmed→in_progress in_progress→completed* |
| 10 | Tính tiền; phiên *Chờ thanh toán*; bàn 5 chưa trống | *tổng phiên 93000 đ · phiên awaiting_payment · bàn 5 còn thuộc phiên chưa đóng: t*; cái sai *bàn 5 coi như trống*: *phiên thứ hai … bị từ chối (I-001): … "table_session_member_one_unpaid_session_key"* |
| 11–12 | Lượt 3 gọi **sau** khi quầy đã bắt đầu thu; phiên quay về *Đang phục vụ*; làm, bưng | *lượt 3 (qr_table) vào phiên … · 3000 đ · phiên quay về serving*; đọc lại: *lượt 3 gửi 07:47 — sau lúc bắt đầu thu 07:45* |
| 13–15 | **Một** hoá đơn; hai phương thức; đóng phiên | *hoá đơn … · phải trả 96000 = tiền mặt 60000 + chuyển khoản 36000 · phiên closed*; cái sai đắt nhất: *hoá đơn thứ hai của phiên bị từ chối (I-002): … "bill_one_per_session_key"* |
| 16–17 | Dọn bàn; bàn 5 trống sau **hai** việc | *phiên đã đóng t, đã dọn lúc 08:05 ⇒ không thuộc phiên chưa đóng nào: t*; đường của phiên: *open→serving→awaiting_payment→serving→awaiting_payment→closed* |

**Đọc lại, cả mười dòng *Kết quả mong đợi* đúng:** *1 phiên · 1 hoá đơn 96000 đ = lượt 1 68000 + lượt 2
25000 + lượt 3 3000 · tiền mặt 60000 + chuyển khoản 36000 · ngày bán … lúc 08:00 · người thu Người đứng
quầy*.

---

## 2. Scenario 2 — ba đơn mang đi, ba kênh, không đơn nào gắn phiên bàn

| # | Bước ở quán | Ghi được · đọc lại được — output 2026-09-30 |
|:--:|---|---|
| 1 | Đơn A Delivery, số điện thoại + địa chỉ | *đơn A (delivery) … · 50000 đ · chờ duyệt* |
| 2 | Đơn B Pickup hẹn 8:30, chọn trả trước | *đơn B (pickup, hẹn 08:30) … · 30000 đ · chờ duyệt* |
| 3–4 | Đơn C hotline, tới lấy 9:00, không địa chỉ; thẳng *Đã xác nhận*; ba đơn lẻ | *đơn C (phone_preorder, tới lấy 09:00) … · 15000 đ · in_progress — không qua bước duyệt* · *ba đơn lẻ, số đơn gắn phiên bàn: 0*; đường C: *new→confirmed …* |
| 5 · 7 | Duyệt A, B; nổ; mỗi đơn **một** việc nước chấm | *việc nước chấm mỗi đơn: s2_a=1 s2_b=1 s2_c=1* |
| 6 | Nhận tiền trả trước B **rồi** mới bấm | *trả trước … của đơn B: 30000 đ chuyển khoản, nhận lúc 07:40 (đơn gửi lúc 07:32)* |
| 8 | Một mẻ, ba đơn | *mẻ … làm ra 38 đơn vị của 3 đơn · việc còn chờ của ba đơn: 0* |
| 9 | Đóng gói — không bản ghi nào, không bước bưng ra bàn | — (không có gì để ghi; không đơn nào có bàn) |
| 10 | A rời quán ⇒ *Đang giao* | *đơn A: delivering* |
| 11 | Người đi giao trao, thu tại chỗ khách ⇒ A Hoàn thành | *đơn A: completed · hoá đơn … tiền mặt 50000 đ, người thu: Người gấp bánh* (tên diễn — POS khai người đi giao, `U-057`). **Ai bấm và lúc nào** mốc *đã ra bàn* của đơn giao tận nơi là `S-6` (§6) |
| 12 | B trao lúc 8:30, **không thu lại** | *đơn B: completed · hoá đơn …: tiền mặt 0 · chuyển khoản 0 · từ trả trước 30000*; cái sai: *lần thu thứ hai của đơn B bị từ chối (I-007: …): … "bill_one_per_order_key"* |
| 13–14 | C tới lấy, thu tại quầy; không *Đang giao*; không dọn bàn | *đơn C: completed · hoá đơn … tiền mặt 15000 đ* |

**Đọc lại:** *3 đơn vị thanh toán · A 50000 đ (tiền mặt, người thu Người gấp bánh) · B 30000 đ (trả trước
chuyển khoản nhận 07:40 — hoá đơn lúc 08:30) · C 15000 đ (tiền mặt, Người đứng quầy) · tổng 95000 đ*;
đơn A và C cùng số điện thoại mà hai đơn vị thanh toán; **chỉ** A có *Đang giao*.

---

## 3. Scenario 3 — chủ quán đổi giá giữa buổi

| # | Bước ở quán | Ghi được · đọc lại được — output 2026-09-30 |
|:--:|---|---|
| 1 | 8:00 bàn 3 gọi suất giò; dòng khoá giá | *dòng … "Suất giò" khoá 25000 đ lúc 08:00* |
| 2–4 | 8:30 chủ quán nâng **giá gốc chay** một cái bánh; phụ thu không đổi; năm kênh cùng đọc | *giá gốc bánh cuốn 3000 → 4000 đ · phụ thu không đổi · cột giá theo kênh trong lược đồ: 0* — lần đổi là một lần sửa thật, có vết người và lý do |
| 5 | 9:00 gọi thêm đúng món ấy; dòng mới khoá giá mới | *dòng … "Suất giò" cùng tuỳ chọn khoá 29000 đ lúc 09:00* |
| 6 | Mở lại đơn 8:00 | *"Suất giò" · 25000 đ · 4 cái bánh · mốc khoá 08:00* |
| 7 | **Một** hoá đơn, **hai** mức giá | *hoá đơn … của phiên bàn 3: 54000 đ · các mức giá của "Suất giò" trên hoá đơn: 25000 · 29000* |
| 8 | 10:00 ngừng bán suất giò; đơn cũ vẫn đúng tên, giá | *"Suất giò" ngừng bán lúc 10:00 · dòng 8:00 vẫn đọc "Suất giò" · 25000 đ*. *Không kênh nào đặt mới được* là cửa của pha 3 (`I-009` vế ngừng bán, tầng 3): database không chặn, câu `I-009/4` gọi tên |
| 9 | Chủ quán sửa thành phần combo giữa buổi: máy vẫn cho lưu, để vết | *combo "Đầy đủ trứng tái": bánh cuốn 3 → 2 cái/suất · vết: Chủ quán sửa lúc 10:05, lý do "…"* (lời nhắc trước khi lưu là pha 4) |
| 10 | Mở lại đơn Scenario 1 sau khi thành phần đổi | *68000 đ · 6 cái bánh (menu hiện hành: 2 cái/suất)* |

**Đọc lại:** *dòng 8:00 25000 đ · dòng 9:00 29000 đ · chênh 4000 = 4 bánh × 1000 · hoá đơn bàn 3 54000
đ*; sau mọi lần đổi menu, mỗi hoá đơn của ngày vẫn bằng tổng dòng của nó.

**Và ngày ấy qua được bộ đối chiếu.** Chạy lại `scripts/reconcile.sh` trên database vừa diễn: *63 câu
I-0xx · 22 câu QD, mọi tập rỗng* — một buổi bán đủ ba scenario, kể cả lần đổi giá, lần ngừng bán và lần
đổi thành phần giữa buổi, không làm kêu câu đối chiếu nào.

---

## 4. Tiền — cộng tay từ `master_plan/shop-facts.md`, so với con số database in ra

Cộng từ §4.2 (giá thành phần, giá gốc là giá **chay**) và §4.4 (phụ thu mỗi phần nhận nhân), không đọc
con số của scenario. Cột phải là dòng *TIỀN* và các dòng đọc lại của `db-check`.

| Scenario | Dòng | Cộng từ `shop-facts.md` §4.2 · §4.4 | Tay | Database |
|---|---|---|--:|--:|
| 1 | 2 combo trứng tái, thịt + mộc nhĩ, nhiều nhân | (3 × 3.000 + 8.000 + 9.000) = 26.000; bốn phần nhận nhân × (1.000 + 1.000) = 8.000 ⇒ 34.000 × 2 | 68.000 | 68000 |
| 1 | 1 suất giò, thịt, thường | 9.000 + 4 × 3.000 + 4 × 1.000 | 25.000 | 25000 |
| 1 | 1 bánh cuốn chay | 3.000 | 3.000 | 3000 |
| 1 | **hoá đơn** | | **96.000** | **96000** |
| 2 | A — 2 suất trứng tái, thịt + mộc nhĩ, thường | (8.000 + 4 × 3.000) + năm phần × 1.000 = 25.000 × 2 | 50.000 | 50000 |
| 2 | B — combo trứng chín, thịt, thường | 26.000 + 4 × 1.000 | 30.000 | 30000 |
| 2 | C — 3 bánh cuốn, thịt, nhiều | (3.000 + 1.000 + 1.000) × 3 | 15.000 | 15000 |
| 2 | **ba hoá đơn** | | **95.000** | **95000** |
| 3 | dòng 8:00 — suất giò, thịt, thường | 9.000 + 4 × 3.000 + 4 × 1.000 | 25.000 | 25000 |
| 3 | dòng 9:00 — cùng món, giá gốc chay lên 4.000 | 9.000 + 4 × 4.000 + 4 × 1.000 | 29.000 | 29000 |
| 3 | **hoá đơn bàn 3** | | **54.000** | **54000** |
| | **cả ngày diễn** | 96.000 + 95.000 + 54.000 | **245.000** | **245000** |

**Mười hai dòng khớp từng đồng.** Hai con số phụ thu dễ sai nhất — combo **×4** vì giò không nhận nhân,
suất trứng **×5** vì quả trứng cũng nhận — ra đúng, và chúng ra từ dữ liệu mồi dựng lúc chạy từ chính
`shop-facts.md`, không từ một bảng giá thứ hai.

---

## 5. Chấm ngược hai mươi bốn dòng `YC`

Mã phải chấm đọc lúc chạy từ owner — các mã đứng trước §8 của `04-yeu-cau-du-lieu.md`: lệnh chưa lọc
thấy **25** mã (`YC-01`…`YC-25`), lệnh đã lọc giữ **24** (`YC-21` thuộc pha 5, **ADR-057**) — in cả hai
theo **F-017**. `db-check` 2026-09-30: *PASS chấm YC — 24 mã, mỗi mã đọc + sai; comm -3 … rỗng · 34 TỪ
CHỐI · 5 KHÔNG CHỖ · 2 ĐI QUA · 5 GỌI TÊN · 4 DỰNG ĐƯỢC · 2 CHƯA TRẢ LỜI ĐƯỢC*. Ba phép chứng minh
biết kêu, chạy tay lượt này: cài *dòng 8:00 bị tính lại theo giá mới* ⇒ phần đọc lại *SAI — S3 — dòng
9:00 đắt hơn dòng 8:00 đúng (…)*; bỏ dòng *sai* của `YC-25` ⇒ `comm -3` in `YC-25`; một `GỌI TÊN` trỏ
nhầm file lỗi cài ⇒ *kêu: I-012/3→proof/i012_1*.

| YC | Đọc ra được — đọc từ ngày diễn | Dựng được trạng thái sai không — kết cục |
|---|---|---|
| **01** hoàn tiền | 5 thứ: *hoàn 5000 đ · cho hoá đơn … · Người đứng quầy bấm · lúc 09:30 · lý do "…" · trả bằng cash* | TỪ CHỐI ×3: thiếu lý do `refund_reason_not_blank_check` · thiếu người `person_id` NOT NULL · không lượt bán `refund_one_target_check` |
| **02** khoản nợ | *ai nợ "…" · 8000 đ · phiên … (đã đóng) · ghi lúc 10:20 · thu lúc hôm sau 06:30 · đã thu* | TỪ CHỐI ×4: thu thiếu không ghi nợ `bill_parts_equal_due_check` · nợ không chủ `bill_debtor_iff_debt_check` · hai khoản nợ một phiên `bill_one_per_session_key` · nợ âm `bill_amounts_not_negative_check`. GỌI TÊN: nợ cộng vào tiền đã thu — `I-014/4` |
| **03** vết chạm tiền · vết sửa | *10 thao tác chạm tiền, 0 thiếu một trong bốn câu*; lần sửa giá: *trước 3000 → sau 4000 · lý do · người sửa Chủ quán* | **CHƯA TRẢ LỜI ĐƯỢC — `F-048`**: *chỗ lệch két không quy về một thao tác* — không có số tiền mặt đếm được để có chỗ lệch. *Cập nhật 2026-10-05 (`T-133`): nay **GỌI TÊN** `I-012/2` (`proof/i012_2`)* |
| **04** người đang trực | *hoàn: bấm A, đứng quầy A · ghi nợ · thu nợ hôm sau · huỷ: bấm Chủ quán, đứng quầy Chủ quán* | KHÔNG CHỖ: bảng người chỉ có *id, display_name, is_owner, created_at* — không chức vụ. **DỰNG ĐƯỢC — `F-046`**: huỷ không khai lý do ⇒ không đọc ra ai huỷ |
| **05** dấu đem về | *đơn …, phiên …: dòng … ăn tại chỗ · dòng … ĐEM VỀ* — một đơn, hai kiểu | TỪ CHỐI: suất rời phiên thành đơn lẻ `sales_order_session_iff_table_channel_check`. KHÔNG CHỖ: dấu chỉ ở `order_line.is_takeaway` |
| **06** đã gọi · đã phục vụ theo bàn | *bàn 3 Bánh cuốn: gọi 8, phục vụ 8 · bàn 5 Bánh cuốn: gọi 11, phục vụ 11 · …*; *mẻ Scenario 2: 38 = 21 + 10 + 7* | TỪ CHỐI: phục vụ vượt gọi `station_job_position_in_range_check`. KHÔNG CHỖ: không cột tổng nào |
| **07** mẻ · phần của bàn · lùi | *mẻ … (10:40, Người đứng quầy): bàn 10 ×21 · bàn 11 ×11*; *lùi mẻ …: bấm 10:35, lùi 10:36 bởi Người đứng quầy, đã phủ 32 thứ* · *chưa làm · đã làm xong còn ở bếp · đã ra bàn* ba con số riêng | TỪ CHỐI ×3: thứ của mẻ không bàn `station_job_id` NOT NULL · lùi một phần mẻ `station_job_made_in_batch_fkey` · đổi chủ không có lần chuyển `production_batch_item_transfer_fkey`. GỌI TÊN: đồ đã làm của đơn huỷ ở lại — `I-004/6` (ca **không** bàn chờ: `U-064`) |
| **08** nhập bù sổ giấy | *lượt 1/2 của sổ ngày …: ngày bán … lúc 06:45 · gõ vào máy … · người nhập bù · người đứng quầy lúc bán · còn 1 lượt* | TỪ CHỐI ×2: rơi vào ngày gõ `bill_paper_ledger_fkey` · quá số khai `bill_paper_position_in_range_check`. **CHƯA TRẢ LỜI ĐƯỢC — `F-048`**: không có dấu *đã đối soát xong*. *Cập nhật 2026-10-05 (`T-133`): nay **GỌI TÊN** `I-014/5` (`proof/i014_5`)* |
| **09** nợ sống lâu hơn phiên | *phiên … đóng · khoản nợ … sinh lúc đóng · thu ngày hôm sau* | TỪ CHỐI: hoá đơn nợ trên phiên chưa đóng `bill_table_session_fkey` |
| **10** hai mốc của nợ | *doanh thu đọc mốc ghi nợ: ngày D · đối soát tiền đọc mốc thu nợ: ngày D+1* | TỪ CHỐI ×2: trả nợ thành hoá đơn mới `bill_one_per_session_key` · thu nợ hai lần `debt_collection_one_per_debt_key` |
| **11** danh tính chỉ khi nợ | *1 / 7 hoá đơn mang tên, đều có nợ · cột danh tính ở bảng phiên: không có* | TỪ CHỐI: tên trên phiên không nợ `bill_debtor_iff_debt_check` |
| **12** vết chạm tiền, sống độc lập | chín thao tác ngày diễn, mỗi cái *cái gì · bao nhiêu · ai · lúc*; khoá ngoại của bảng vết chỉ tới *person* | GỌI TÊN: đường đổi tiền không qua chỗ bấm đã chốt — `I-012/3` |
| **13** vết một lần cập nhật | *sửa thành phần combo: trước 3 → sau 2 · lý do · người sửa Chủ quán · lúc 10:05* | TỪ CHỐI: sửa có lý do không người `record_revision.person_id` NOT NULL. **DỰNG ĐƯỢC — `F-046`**: sửa không khai lý do ⇒ không bản trước, không bản sau |
| **14** không hoàn tác | *phiên bàn 5: awaiting_payment → serving lúc 07:47 bởi Người đứng quầy, lý do "…"* | **DỰNG ĐƯỢC — `F-046`**: đơn vị đã ra bàn lùi về đã làm xong, không khai lý do, không hai phía |
| **15** trực quầy theo thời điểm | *07:00 A · 10:29 A · 10:30 Chủ quán · hôm sau 06:30 A · hôm sau 08:00 (không ai khai)* | TỪ CHỐI: hai người cùng lúc `counter_duty_one_at_a_time_excl` |
| **16** chủ quán đứng quầy | *10:45: đứng quầy Chủ quán · là chủ quán: t — cùng lúc* | KHÔNG CHỖ: không ô *vai hiện tại* nào để một vai thay vai kia |
| **17** năm trạm, bốn vai | *người của quán: bốn vai và chủ quán · bảng nối người với trạm: không có* | KHÔNG CHỖ: không gì đòi đủ người mỗi trạm (`U-055`) |
| **18** một việc một mốc | *sale_date bắt buộc ở bill · debt_collection · prepayment · refund* | TỪ CHỐI: hoàn không ngày `refund.sale_date` NOT NULL |
| **19** các phần chung một mốc | *hoá đơn …: tiền mặt 60000 + chuyển khoản 36000 trên MỘT dòng, một mốc 08:00* | TỪ CHỐI: phần thứ hai sang ngày khác `bill_one_per_session_key` |
| **20** mốc không dời âm thầm | *hoá đơn bàn 3: mốc 09:20 — số lần sửa mốc có vết: 0* | GỌI TÊN: dời mốc có lý do — `QD-33/b`. **DỰNG ĐƯỢC — `F-046`**: dời mốc không khai lý do, không vết |
| **22** liên hệ đơn mang đi | A: giao · sđt · địa chỉ; B, C: tới lấy · sđt · giờ cần; tên khách trống ở cả ba | TỪ CHỐI ×4: Delivery thiếu địa chỉ `sales_order_door_delivery_address_check` · hotline không cách trao · Delivery nhánh tới lấy `sales_order_takeaway_handover_check` · Pickup thiếu giờ `sales_order_takeaway_needed_at_check`. ĐI QUA: đơn không tên khách tạo được |
| **23** khoản trả trước | *đơn … · 30000 đ (tiền mặt 0 · chuyển khoản 30000) · nhận 07:40 · Người đứng quầy bấm · thành doanh thu ở hoá đơn ngày D*; *ngày D — nhận · thành doanh thu · trả lại: không* | TỪ CHỐI ×2: dùng quá số nhận `prepayment_use_balance_check` · trả lại trừ vào hoá đơn `refund_one_target_check`. GỌI TÊN: vào doanh thu ngày nhận — `I-014/7` |
| **24** mã QR | *bàn 5: mã hiện hành … · mã đã thay … hiện hành từ … tới … · đổi bởi Chủ quán · lượt 1 của Scenario 1 mang mã cũ*; đổi mã bàn 10 khi phiên đang mở: *phiên vẫn open, số bàn vẫn "10"* | TỪ CHỐI ×4: hai mã hiện hành `qr_code_one_current_per_table_key` · một mã hai bàn `qr_code_code_key` · lượt QR không mã `sales_order_qr_code_iff_qr_channel_check` · mã bàn khác `sales_order_qr_code_table_fkey` |
| **25** dấu lần gửi | *mọi đơn mang dấu, mọi dấu khác nhau · dấu … ⇒ đơn …* | TỪ CHỐI ×2: chung dấu `sales_order_submission_code_key` · thiếu dấu NOT NULL. ĐI QUA: khác dấu, nội dung giống hệt ⇒ hai đơn |

---

## 6. Chỗ hở và chỗ dừng — biên bản của lượt diễn

Lượt này **không sửa lược đồ** (`work/backlog_DB.md` → P2-13, *bẫy*: một lượt vừa chấm vừa sửa là một
lượt tự chấm mình).

**Một chỗ hở mới, có mã từ lượt này — `F-048`** (`work/findings.md`). *Số tiền mặt đếm được cuối ngày* và
*dấu ngày đã đối soát xong* không có chỗ cất và không bước nào nhận. Hai lát đã ghi chỗ trống ấy
([`04-luoc-do-duong-tien.md`](04-luoc-do-duong-tien.md) §5 · [`06-luoc-do-nguoi-va-vet.md`](06-luoc-do-nguoi-va-vet.md)
§5) nhưng không có mã, nên brief không in. Nó làm hai dòng `YC` ra **CHƯA TRẢ LỜI ĐƯỢC** (`YC-03`,
`YC-08`) và để ba tập đối chiếu không có câu. **Chạm tiền**: phép đối soát ngưỡng 0đ chạy được vế phải,
không có gì để so ở vế trái.

**Một chỗ hở đã có mã — `F-046`** (chế độ mềm của vết, chủ repo chọn 2026-09-28). Bốn dòng `DỰNG ĐƯỢC`
(`YC-04` vế *ai huỷ* · `YC-13` · `YC-14` · `YC-20`) đều là **một** nguyên nhân: lần sửa không khai lý do
không để vết. Lượt diễn khai lý do ở **mọi** bước — đó là việc pha 3 nợ, không phải thứ lược đồ giữ.

**Ba chỗ dừng đã có tên trước lượt này** — kịch bản đi qua mà không trả lời hộ:

- **`S-5`** — đơn vị **bấm** *đã ra bàn* (`master_plan/shop-facts.md` §7.2): kịch bản bấm theo đơn để
  đi tiếp; lược đồ cố ý không có bản ghi lần bấm ấy ([`05-luoc-do-san-xuat.md`](05-luoc-do-san-xuat.md) §5).
- **`S-6`** — ai bấm và lúc nào mốc *đã ra bàn* của đơn giao tận nơi: kịch bản đặt ở lúc trao.
- **`U-064`** — đồ đã làm của đơn huỷ khi không bàn nào chờ: không ca nào của ba scenario chạm; câu
  `I-004/6` in ca ấy như một ca chưa có luật.

**Hai câu hỏi mở chạm tiền, lược đồ không đoán thay:** **`U-063`** (trả nợ từng phần — lược đồ hôm nay
chỉ có *chưa thu · đã thu đủ*) và **`U-058`** (giảm giá cả đơn — hoá đơn không có cột giảm giá). Cả hai
là chỗ trống có tên ở [`04-luoc-do-duong-tien.md`](04-luoc-do-duong-tien.md) §5; cửa nợ và cửa giảm giá
của pha 3 cần lời chủ quán trước khi viết.

---

## 7. Cổng chất lượng pha 2 — mười hai ô

Mười hai ô dưới đây là **lời** của kế hoạch pha 2 §9; chỗ ký là đây. **Hôm nay 12/12 — mười hai ô tick
KÈM bằng chứng** (2026-09-30: mười một ô ở `P2-13`, ô 9 ở `P2-14`). Đủ các ô **không** phải câu *"được, sang pha 3"*: ký chuyển
pha là quyền **chủ repo** (kế hoạch §9), và bốn ô tick dưới đây mang một chỗ hở chạm tiền có mã.
**Chủ repo ký chuyển sang pha 3 ngày 2026-10-05** (T-136), nguyên văn *"đồng ý chuyển sang pha 3. xác nhận cách chia mười bốn bước pha 3"*.

- [x] **1. Mọi mã `I-0xx` của `quality/invariants.md` có câu truy vấn đối chiếu** — *PASS mã I-0xx —
  comm -3 rỗng: 24 mã ở quality/invariants.md, cùng từng ấy mã có câu*; trên dữ liệu mồi *reconcile:
  PASS — 63 câu I-0xx · 22 câu QD, mọi tập rỗng*. ⚠️ Tick kèm: đơn vị là **tập**, không phải mã
  (**ADR-066**) — 63 câu cho 24 mã; và **29 tập chưa có câu**, mỗi tập một lý do và một người nợ
  ([`09-doi-chieu-bat-bien.md`](09-doi-chieu-bat-bien.md) §2), ba trong số ấy chờ `F-048`.
- [x] **2. Mỗi câu truy vấn đã được chứng minh là biết kêu** — *PASS mọi câu có lỗi cài nhắm vào nó —
  comm -3 rỗng (85 câu, 85 file lỗi)*; ngày mẫu đúng *85 câu chạy, mọi tập rỗng*. Lượt này thêm một
  phép chống kêu oan: cả bộ chạy lại trên ngày ba scenario ⇒ *mọi tập rỗng* (§3).
- [x] **3. Mọi hàng tầng 1 của `03-bao-ve-invariant.md` có một ràng buộc thật mang nó** — **mười bảy**
  mã có vế tầng 1 (đếm 2026-09-30 trên cột giữa của file ấy — đếm lại ở đó, **F-003**), mỗi mã một file
  `db/tests/` in lời từ chối trong mỗi lần `db-check`; một lời mỗi mã, lần chạy 2026-09-30: `I-001`
  *"table_session_member_one_unpaid_session_key"* · `I-002` *"bill_one_per_session_key"* (Scenario 1
  bước 13) · `I-006` · `I-007` *"sales_order_session_iff_table_channel_check"* (một ràng buộc cho cả hai
  nửa của ranh giới) · `I-004` *"menu_component_station_once_key"* (và
  chín lời khác, gồm việc trạm của đơn chưa duyệt) · `I-005` *"bill_parts_equal_due_check"* · `I-009`
  *null value in column "unit_price_vnd"* · `I-012` *null value in column "person_id" of relation "bill"*
  · `I-014` *"bill_sales_order_fkey"* · `I-015` *"bill_parts_equal_due_check"* (thu vượt) · `I-018` *null
  value in column "person_id" of relation "record_revision"* · `I-019` *column "quantity" of relation
  "production_batch" does not exist* (không ô tổng nào để lệch) · `I-020`
  *"station_job_position_in_range_check"* · `I-021` *"opening_float_one_per_day_key"* · `I-022`
  *"sales_order_door_delivery_address_check"* · `I-023` *"sales_order_qr_code_table_fkey"* · `I-024`
  *"sales_order_submission_code_key"*. ⚠️ Tick kèm: `I-018` vế *mọi lần sửa đều có vết* đang **thấp
  hơn** tầng pha 1 chốt — `F-046`, chủ repo chọn có tên, không phải hạ tầng im lặng.
- [x] **4. Mọi dòng `YC-01`…`YC-20` · `YC-22`…`YC-25` được chấm bằng hai câu** — §5, hai mươi bốn mã mỗi
  mã một dòng *đọc* và một dòng *sai* chạy thật. ⚠️ Tick kèm: sáu kết cục chỉ ra **chỗ lược đồ còn
  thiếu**, đúng như `04-yeu-cau-du-lieu.md` §7 dặn — bốn `DỰNG ĐƯỢC` (`F-046`) và hai `CHƯA TRẢ LỜI ĐƯỢC`
  (`F-048`), tất cả chạm vết tiền hoặc đối soát.
- [x] **5. Mỗi migration có đường lùi đã chạy thật** — *PASS xuôi* × 8 · *PASS lùi … lược đồ giống hệt
  lúc trước bước ấy* × 8 · *PASS xuôi lại — 8 bước từ số không, lược đồ giống hệt lần xuôi đầu (1134
  dòng)*; trên dữ liệu mồi *PASS khoá chặn — lùi trên dữ liệu mồi bị từ chối, lược đồ không đổi*.
- [x] **6. Dữ liệu mồi dựng lại đúng menu thật** — *§4.8: 13 / 13 ca khớp từng đồng*. Kế hoạch viết
  *mười một ca*; bảng §4.8 hôm nay có mười ba dòng (ca 12 giò bán rời, ca 13 canh 0đ thêm 2026-09-08) —
  đếm ở danh sách, không ở lời (**F-018**).
- [x] **7. Ba scenario nghiệm thu đi hết được trên lược đồ** — §1–§3: *PASS ba scenario diễn qua lược đồ
  — 32 dòng bước, mỗi bước một giao dịch COMMIT* · *PASS đọc lại ba scenario ở kết nối khác — mọi dòng
  Kết quả mong đợi đúng*; tiền cộng tay từ `shop-facts.md` khớp từng đồng (§4).
- [x] **8. Mọi mốc tính tiền cất đúng một chỗ, và không phép cộng nào dựa vào giờ của máy khách** — năm
  hàng của [`../1-system-design/02-thoi-gian-ngay-ban.md`](../1-system-design/02-thoi-gian-ngay-ban.md)
  §2, mỗi hàng một chỗ: *bán* (kể cả ghi nợ) → `bill.booked_at` · `bill.sale_date`; *hoàn* →
  `refund.booked_at` · `refund.sale_date`; *thu nợ* → `debt_collection.booked_at` ·
  `debt_collection.sale_date`; *nhập bù* → `bill.sale_date`, bị `bill_paper_ledger_fkey` buộc bằng ngày
  của sổ; *trả trước* → hoá đơn của chính đơn ấy (`prepayment.sale_date` là ngày **nhận**, dòng đối soát
  riêng, **ADR-059**). `grep` các cột mốc ở `db/migrations/`: mặc định `now()` · `CURRENT_DATE` là đồng
  hồ **database** trên kết nối đặt múi giờ của quán (`QD-32`, *PASS* trong bộ đối chiếu); không cột mốc
  tiền nào nhận giờ từ phía khách. `YC-18` · `YC-19` · `YC-20` ở §5.
- [x] **9. Không endpoint · route · component nào lọt vào file pha 2** — ký 2026-09-30, `P2-14` (Claude
  Code). Đo trên **cả mười một** file `docs/product/2-db/*.md`, **2753 dòng chưa lọc**, mỗi lượt một
  cặp *chưa lọc · đã lọc* (**F-017**); lệnh nguyên văn và từng dòng trả về ở `work/backlog_DB.md` →
  P2-14 *Bàn giao* — không dán ở đây, vì chính file này nằm trong tập bị đo.

  | Lượt | Bắt cái gì | Chưa lọc | Đã lọc |
  |---|---|--:|--:|
  | **A1** | endpoint — mẫu **nguyên văn** của Gate 1d cho vùng pha 2 | 2753 | **0** |
  | **A2** | endpoint — mẫu rộng của vùng pha 1: động từ + chữ, **không** đòi dấu gạch chéo (chỗ `F-041` đã lọt) | 2753 | **0** |
  | **A3** | từ vựng của hợp đồng API | 2753 | **8** — không dòng nào là hợp đồng: lời khai *không sở hữu* của `10-quy-uoc-code.md`, tên file khai gói của `QC-09`, chữ *header* của một script, và chính ô này |
  | **B1** | route · file mã giao diện — mẫu **nguyên văn** của Gate 1d | 2753 | **0** |
  | **B2** | đường dẫn route viết trong backtick | 2753 | **0** |
  | **B3** | từ vựng pha 4 | 2753 | **11** — chữ *màn* trong câu hậu quả và câu giao việc cho pha sau, lời giải thích một tên bảng của lát menu, stack của `QC-09`, và chính ô này; không dòng nào đặt tên một route hay nói cái gì hiện ở màn nào |
  | **C1** | thẻ component, kể cả có thuộc tính và thẻ đóng | 2753 | **0** |
  | **C2** | tên `PascalCase` trong backtick | 2753 | **1** — tên một tham số kết nối của database (`QC-06`) |
  | **D** | tên hàm kiểu mã ứng dụng · hàm có ngoặc trong backtick | 2753 | **0 · 5** — cả năm là hàm và kiểu của database |

  **Bộ lọc biết kêu, đo trên chính tập này.** Cài sáu dòng vi phạm mẫu vào một **bản sao** của vùng pha
  2 (2759 dòng): A1 · A2 mỗi lượt trả về **3** dòng cài, B1 **2**, B2 **1**, C1 **2**, C2 **2** (một dòng
  cài, một dòng `QC-06`). Lần chạy đầu của lượt này đọc **không file nào** vì danh sách file không được
  tách từ trong shell đang dùng — chỉ con số *chưa lọc = 0* tố cáo nó; output rỗng thì không.

  **Phần mã pha 2** (`db/`, `compose.yaml`, `Makefile`, `scripts/db-check.sh`, `scripts/reconcile.sh` —
  170 file, 9482 dòng) qua cùng các mẫu: năm dòng khớp lượt endpoint là lệnh lấy chẩn đoán lỗi của
  PL/pgSQL, một dòng khớp lượt thẻ là chú thích định dạng bản ghi của `scripts/reconcile.sh`.

  **Hai thứ file quy ước code nói tới mà không phải vi phạm** — ghi ra để lượt sau không mở lại: `QC-08`
  đặt tên hai thư mục gốc cho backend và frontend, `QC-09` đặt tên ngôn ngữ và khung. Cả hai là *cấu
  trúc thư mục* và *stack*, thứ hàng *Quy ước code* của `CLAUDE.md` §2 giao cho file ấy; không dòng nào
  trong đó là endpoint, route hay component.

  **Gate 1d — lớp thứ hai:** `./scripts/gate.sh` 2026-09-30 ⇒ Gate 1d `PASS`. ⚠️ **Tick kèm `F-049`:**
  lượt cài cho thấy mẫu giao diện của Gate 1d **không** bắt thẻ component có thuộc tính, thẻ đóng, tên
  component và đường dẫn route trong backtick — hôm nay không có gì lọt (lượt C1 · C2 · B2 ở trên rộng
  hơn cổng và ra sạch), nhưng `P2-14` chỉ chạy một lần, còn pha 3 · pha 4 sẽ sửa file pha 2 với một cổng
  hẹp hơn thứ nó phải hiểu.

  **Pointer hai chiều** (nửa thứ hai của `P2-14`, không phải lời của ô này): pha 2 → pha 1, **59** dòng
  nhắc tên một file pha 1, **21** cặp *file · mục* khác nhau, **0** cặp trỏ vào mục không tồn tại, và
  mười chỗ gán lời cụ thể cho một mục — mở ra đọc — đều còn đúng. Pha 1 → pha 2, **70** dòng: bốn câu *"pha 2 chưa mở"* ·
  *"chỗ duy nhất trong repo hôm nay"* và hai hàng bàn giao thiếu đích đã nhận ghi chú có ngày ở
  `02-thoi-gian-ngay-ban.md` §5, `03-bao-ve-invariant.md` §0 luật 4 và `04-yeu-cau-du-lieu.md` (đầu file
  · §7). **Một lời giao không rơi vào dòng nào — `F-050`:** `05-realtime-va-du-phong.md` §3 luật 4 đòi
  vết của mỗi lần *quán đang mù*, không bước nào viết dòng `YC` cho nó, nên ô 4 ở trên tick mà không
  chạm tới nó.
  *Cập nhật 2026-10-01 (`T-132`), không đổi lần tick:* chủ repo chọn hướng (a) của `F-050` — dòng
  `YC-34` ở pha 1, chỗ cất ở migration bước 14, câu `I-008/2` · `I-008/3`; `F-050` đã đóng, và
  `db/scenario/yc.sql` chấm `YC-34` bằng đọc + sai như mọi mã khác.

  ⚠️ **Con số ở ô này là ảnh chụp tại mốc đo, và chính ô này làm chúng hết đúng** — nó thêm dòng vào
  một file của tập. Lượt đo sau đếm lại, đừng đọc con số ở đây như con số hôm ấy (**F-001** · **F-033**,
  cùng luật với ô 10 của cổng pha 1).
- [x] **10. Không câu hỏi nghiệp vụ nào đang mở mà một bước pha 2 phải đoán thay** — `./scripts/brief.sh`
  mục *OPEN UNKNOWNS* 2026-09-30: `U-064` · `U-063` · `U-058`. Hỏi từng câu: không bước nào phải đoán để
  viết được một dòng của mình — cả ba là chỗ trống có tên, không lấp bằng mặc định (§6). ⚠️ Tick kèm:
  `U-063` và `U-058` **chạm tiền**; pha 3 không viết được cửa nợ và cửa giảm giá khi chúng còn mở.
  *Cập nhật 2026-09-30 (T-124), không đổi lần tick:* `U-064` và `U-063` đã đóng bằng lời chủ quán cùng ngày
  (`docs/product/99-unknowns.md`, mục đã có lời giải); lược đồ chưa theo kịp hai lời ấy — task
  `T-126` (trả nợ từng phần) và `T-127` (ghi chú bánh làm sai) ở `work/backlog.md`. `U-058` ở lại.
- [x] **11. Bốn mã nợ của pha 1 đã được đọc** — `F-034` *Fixed* (yêu cầu `YC-21` có owner, cơ chế giao
  pha 5 — `T-109`; [`07-thu-tu-migration.md`](07-thu-tu-migration.md) nói rõ migration xuôi · lùi không
  chứng minh khôi phục) · `F-036` *Fixed — 2026-09-27 (T-103)* · `F-037` *Fixed — 2026-09-28 (T-112)* ·
  `F-038` *Fixed — 2026-09-28 (T-110)*. Đọc từ dòng `**Status:**` của `work/findings.md` lượt này.
- [x] **12. Ba hàng `CLAUDE.md` §2 hết nói *chưa có owner* cho thứ pha 2 sở hữu, và `00-index.md` kể tên
  mọi file pha 2** — *Quy ước dữ liệu* → `01-quy-uoc-du-lieu.md` · *Schema* → `db/migrations/` + năm
  file lát · *Quy ước code* → `10-quy-uoc-code.md`; hàng *chưa có owner* còn lại là của pha 3 và pha 4.
  [`../00-index.md`](../00-index.md) mục *Pha 2* kể mười một file `01`…`11`, gồm dòng của file này (thêm
  cùng lượt).

---

## 8. Cái mục này cố ý không nói · bước sau đọc gì

**Cố ý không nói:** cách lấp `F-048` và `F-046` (chủ repo chọn); câu *"được, sang pha 3"* (chủ repo);
một lời nào của ba scenario — chúng là đầu vào, sửa đầu vào cho qua được lược đồ là chạy phép thử
ngược; và **khôi phục dữ liệu** — `YC-21`, pha 5 (`T-109`).

| Bước / người | Lấy gì từ mục này |
|---|---|
| ~~`P2-14`~~ — **xong 2026-09-30** | ô **9** — đã chạy bộ lọc trên mọi file pha 2, gồm file này, và ký ô ấy ở §7 |
| chủ repo | §6 và ô 1 · 3 · 4 · 9 · 10 — `F-048` cần một nơi nhận (đóng ở `T-133` 2026-10-05); `F-046` chờ pha 3; `F-049` (Gate 1d hẹp hơn thứ nó phải bắt, đóng ở `T-131`) và `F-050` (vết *quán đang mù* chưa có dòng yêu cầu, đóng ở `T-132` 2026-10-01) cần người nhận; `U-063` · `U-058` chờ chủ quán; rồi câu sang pha 3 |
| pha 3 | §0 — mỗi bước ở quán một giao dịch, người thao tác và lý do khai ở **mọi** lần ghi; các hàm ở `db/scenario/prelude.sql` là **hình dạng** lần ghi mà cửa pha 3 thay thế, không phải cửa ấy |
| `P2A-09` | §9 — rà ranh giới các lát admin và ký ô 7 · 8; lát khoản chi còn vắng, rà lại khi P2A-05 xong |
| bước nào thêm vào `db-check` sau bước 7 | database kiểm lúc ấy có một ngày bán đã COMMIT (**ADR-067** *Hệ quả*) |

[↑ đầu file](#top)


## 9. Ngày quản trị — P2A-08

Biên bản 2026-10-01. **Codex** viết lượt diễn, phần đọc lại, phép chấm và bộ đọc danh sách trong
worktree không kết nối được Docker. **Claude Code** chạy `./scripts/db-check.sh` ở máy có Docker, sửa
một lỗi tên biến của phần đọc lại S4 (biến bản ghi trùng bí danh bảng) và ký ô 1–6 ở §9.4 bằng output
lượt chạy ấy. Không lấy output của lượt P2-13 làm bằng chứng cho phần admin mới.

### 9.1 Bước ở quán và nguồn đã chốt

File [`db/scenario/s4_ngay_quan_tri.sql`](../../../db/scenario/s4_ngay_quan_tri.sql)
chạy sau s1…s3 trong cùng phiên bước 7, mỗi DO một giao dịch tự COMMIT theo ADR-067.
Mỗi bước khai người qua hàm sc_buoc trong phiên tạm. Tên người, tên hàng mới, số lượng và tiền
là dữ liệu diễn; đơn vị chưa có lời để trống, không quy đổi lượng đã dùng.
D là ngày diễn; cặp số D-1 chỉ để kiểm đọc nhiều ngày, không quyết luật nhập bù.

| Bước | Việc diễn | Nguồn master_plan/shop-facts.md (dòng tại 2026-10-01) | Đọc lại viết tay trong doc_lai.sql |
|---|---|---|---|
| S4.1 | Thêm một thứ vào danh mục | §8.4 dòng 1552–1556, 1616–1617 | Đúng một tên, đơn vị trống |
| S4.2 | Gạo ngày D-1, mua 10 dùng 7 | §8.4 dòng 1525–1544, 1654–1657 | Cặp 10/7, Chủ quán nhập, có lúc ghi |
| S4.3 | Gạo ngày D, mua 2 dùng 6 | §8.4 dòng 1525–1544, 1654–1657 | Cặp 2/6; cộng cả hai ngày: mua 12, dùng 13, hiệu -1 |
| S4.4 | Thứ mới ngày D, mua 4 dùng 1 | §8.4 dòng 1525–1544 | Cặp 4/1, Chủ quán nhập, có lúc ghi |
| S4.5 | Chủ quán tick Người đứng quầy | §8.7 dòng 1866–1869, 1880–1882 | Một ô còn hiệu lực, người và lúc tick |
| S4.6 | Tick nhầm Người canh & dọn | §8.7 dòng 1866–1869, 1880–1882 | Ô còn lưu, người và lúc tick |
| S4.7 | Huỷ ô nhầm, ghi chú | §8.7 dòng 1870–1874 | Chủ quán huỷ, lúc huỷ, đúng ghi chú; không suy thành quyền huỷ độc quyền |
| S4.8 | Tạm ứng 100000 đ có người duyệt | §8.7 dòng 1835, 1858–1861 | Người nhận, tiền, ngày, lúc ghi, người ghi và Chủ quán duyệt |
| S4.9 | Thưởng lễ Tết 50000 đ | §8.7 dòng 1834, 1858–1861 | Người nhận, tiền, ngày, lúc ghi và người ghi |
| Vắng | Ghi khoản chi | P2A-05 chưa Done | **vắng, chờ ADR-074** |

Phần đọc lại ở kết nối khác so với các giá trị viết tay trên, sai thì RAISE EXCEPTION.
S4 so toàn bộ dòng của đường tiền trước/sau admin; đổi thì dừng, không sửa các
phép đọc hay dòng TIỀN của s1…s3. Đây chỉ chứng minh các khoản không đổi đường tiền
hiện có; chưa chứng minh công thức két mới đã trừ được khoản admin (U-072).

### 9.2 Chấm ngược yêu cầu quản trị

Nhà của yêu cầu: `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §9.
Bảng dưới là phép chấm trong [`db/scenario/yc.sql`](../../../db/scenario/yc.sql); mọi kết cục đã chạy thật
2026-10-01 (§9.4 ô 1). Mỗi mã có đọc và sai; một mã có nhiều vế sai thì giữ nhiều kết cục.

| Vế ↔ YC ↔ nguồn | Đọc | Sai / giới hạn phải báo |
|---|---|---|
| Danh mục thêm dần ↔ YC-26 ↔ §8.4 dòng 1552–1559, 1616–1617 | Tên mới, đơn vị trống | TỪ CHỐI tên trùng; ĐI QUA thiếu đơn vị; KHÔNG CHỖ ngưỡng/định lượng |
| Cặp số ngày ↔ YC-27 ↔ §8.4 dòng 1525–1547 | Cặp mua/dùng hai thứ, Gạo hai ngày | TỪ CHỐI cặp trùng; DỰNG ĐƯỢC sửa mất vết (F-046) và tên công tơ; GỌI TÊN chuỗi vết đứt I-025/2 (proof/i025_2) |
| Người nhập và hai mốc ↔ YC-28 ↔ §8.4 dòng 1519, 1640–1644 | Người, ngày hàng, lúc gõ riêng | TỪ CHỐI mất người; KHÔNG CHỖ gộp hai cột thành một |
| Cộng dồn và hiệu ↔ YC-29 ↔ §8.4 dòng 1645–1657 | Gạo 12 − 13 = -1 | KHÔNG CHỖ tổng/lô/kết luận; ĐI QUA hiệu âm |
| Tick và huỷ ↔ YC-30 ↔ §8.7 dòng 1866–1874 | Hai người, người tick, ô huỷ và người huỷ | TỪ CHỐI ô trùng và huỷ thiếu người; GỌI TÊN người tick không là chủ quán I-027/4 (proof/i027_4) |
| Tạm ứng ↔ YC-31 ↔ §8.7 dòng 1835, 1858–1861 | Khoản, người nhận, hai mốc, người ghi, người duyệt | TỪ CHỐI thiếu người duyệt; GỌI TÊN duyệt không là chủ quán I-028/3 (proof/i028_3); DỰNG ĐƯỢC sửa đè (F-046); CHƯA TRẢ LỜI ĐƯỢC ngày trừ két (U-072) |
| Thưởng lễ Tết ↔ YC-32 ↔ §8.7 dòng 1834, 1858–1861 | Khoản, người nhận, hai mốc, người ghi | TỪ CHỐI thiếu người/tiền; KHÔNG CHỖ loại thưởng ngày đông khách; DỰNG ĐƯỢC sửa đè (F-046); CHƯA TRẢ LỜI ĐƯỢC ngày trừ két (U-072) |
| Khoản chi ↔ YC-33 ↔ owner §9 | Vắng | **vắng, chờ ADR-074** — không dựng thay |

Phần trực quầy dùng YC-04 · YC-15 đã có; không tạo mã admin thứ hai.
Chỗ hở tên công tơ đã được lát nguyên liệu §5 nêu: máy nhận tên tự do, không thể coi
vế cấm nhận cặp số công tơ là đã chặn. Claude nhận để ghi finding nếu cần.
F-046 là nợ chung của vết sửa mềm; F-048 là chỗ chưa cất số két đếm và dấu đối soát,
không được lấp trong lượt này. U-071 chưa quyết người huỷ và tính bắt buộc của ghi chú.

### 9.3 YC chưa có lát

Danh sách máy đọc của bước 7 `scripts/db-check.sh`, cùng nguyên tắc tự hết hạn ADR-070
của `09-doi-chieu-bat-bien.md` §2.1. Mỗi dòng đúng dạng `- YC-xx — lý do, ai nợ`.
Mã nằm trong owner nhưng chưa có đủ đọc + sai được in NOTE; đã có cả hai hoặc không
có ở owner thì FAIL và phải gỡ dòng. YC-21 thuộc §8, pha vận hành, không thuộc tập
owner giao pha 2; script đọc phần trước §8 và cả §9, không bỏ mã admin bằng hằng số.

- YC-33 — chờ P2A-05 (ADR-074)

### 9.4 Cổng kế hoạch §7 — ô 1–6 ký 2026-10-01, mỗi ô một output thật

Lượt chạy: `./scripts/db-check.sh` trong worktree `P2A-08`, exit 0. Lát khoản chi (`P2A-05`, `YC-33`,
`I-029`) **vắng, chờ ADR-074** ở mọi ô — không ghi *đạt* cho nó.

| Ô | Output | Trạng thái |
|---|---|---|
| 1 | `PASS chấm YC — 31 mã, mỗi mã đọc + sai; đối chiếu docs/product/1-system-design/04-yeu-cau-du-lieu.md và danh sách chưa có lát khớp · 42 TỪ CHỐI · 9 KHÔNG CHỖ · 4 ĐI QUA · 8 GỌI TÊN · 8 DỰNG ĐƯỢC · 4 CHƯA TRẢ LỜI ĐƯỢC` · `NOTE YC-33 chưa có lát — chờ P2A-05 (ADR-074)`; bảng vế ↔ YC ↔ nguồn ở §9.2 không hàng trống | **ký** — `YC-26`…`YC-32`; `YC-33` vắng |
| 2 | `PASS db/tests/i025_supply_numbers_entered_by_a_person.sql` · `i026_…` · `i027_…` · `i028_…`; lời từ chối ở §9.2 (vd. `supply_day_entry_one_kind_per_item_day_key`, `attendance_day_one_live_per_worker_day_key`, `approver_person_id` not-null) | **ký** — `I-029` vắng |
| 3 | `PASS ngày bán mẫu đúng (db/reconcile/proof/baseline.sql) — 97 câu chạy, mọi tập rỗng` · `PASS kêu i025_1 — I-025/1` … `PASS kêu i028_4 — I-028/4` (mười hai dòng) · `PASS đối chiếu trên ngày vừa diễn — 75 câu I-0xx · 22 câu QD, mọi tập rỗng · 1 mệnh đề chưa có lát` | **ký** — `I-029` vắng |
| 4 | `PASS xuôi 20260930100000_so_nguyen_lieu` · `…110000_cham_cong` · `…120000_khoan_cua_nguoi`; `PASS lùi …` ba bước, *lược đồ giống hệt lúc trước bước ấy*; `PASS xuôi lại — 11 bước từ số không, lược đồ giống hệt lần xuôi đầu (1289 dòng)` | **ký** |
| 5 | `PASS  Gate 1e  check-schema-names — 36 bảng ở migration, 36 bảng tài liệu nhắc, comm -3 rỗng` | **ký** |
| 6 | `PASS ba scenario + ngày quản trị diễn qua lược đồ — 41 dòng bước, mỗi bước một giao dịch COMMIT` · `PASS đọc lại ba scenario + ngày quản trị ở kết nối khác — mọi dòng Kết quả mong đợi đúng` (S4.1…S4.9 đọc lại, *tổng Gạo: mua 12 · dùng 13 · hiệu số -1*) · `TIỀN ba scenario: S1 96000 · S2 95000 · S3 54000 · cộng 245000 đ` — không đổi so với §4 | **ký** — bước *ghi khoản chi* vắng |
| 7 | §9.6: lượt §6 chín nhóm — tài liệu 38 dòng · mã 11 dòng trúng, **0 dòng *cất***; bảng 5 bảng · 32 cột của ba migration admin đọc bằng mắt, không tên nào giữ thứ của §6; mỗi nhóm có dòng thử kêu đúng | **ký** 2026-10-01 — `P2A-05` vắng |
| 8 | §9.6: chín lượt A1…D của `P2-14` trên 18 file tài liệu · 1403 dòng và 36 file mã · 3868 dòng, **0** endpoint · route · component; dòng còn lại xếp loại từng dòng; hai dòng *quyền* loại 5 Claude xếp loại 3 + 2 (hợp lệ); `PASS  Gate 1d` | **ký** 2026-10-01 — `P2A-05` vắng |

⚠️ Ký kèm, không phải đạt trọn: trong các dòng admin, bốn kết cục `DỰNG ĐƯỢC` (vết mềm **F-046** ×3, tên
công tơ ở [`12-luoc-do-nguyen-lieu.md`](12-luoc-do-nguyen-lieu.md) §5) và hai `CHƯA TRẢ LỜI ĐƯỢC` (ngày trừ
két, **U-072**) — số còn lại trong tổng của ô 1 là của mảng bán hàng, §5 — là chỗ hở có tên, không phải lược đồ đã giữ. Bộ đối chiếu rỗng trên ngày có tạm ứng 100.000đ
và thưởng 50.000đ vì hạng tử *chi từ két* của `I-021` chưa có câu (**ADR-074** điểm 7) — không phải vì
két đã trừ đúng.

### 9.5 Danh sách *YC chưa có lát* biết kêu — chạy thật qua toàn bộ `db-check`

Ba lượt, mỗi lượt trả danh sách về đúng một dòng `YC-33` sau khi chạy. Lượt chính (danh sách như trên):
`NOTE YC-33 chưa có lát — chờ P2A-05 (ADR-074)`, `db-check: PASS`. Hai lượt thêm tạm một dòng (lệnh chèn
của lượt thử đặt mỗi dòng hai lần, nên nhánh *lặp* cũng kêu):

```text
FAIL chấm YC — YC-32 lặp trong danh sách ở docs/product/2-db/11-cong-chat-luong-pha-2.md §9.3
FAIL chấm YC — YC-32 đã có đọc + sai, dòng hết hạn — gỡ dòng ở docs/product/2-db/11-cong-chat-luong-pha-2.md §9.3
db-check: FAIL
FAIL chấm YC — YC-99 lặp trong danh sách ở docs/product/2-db/11-cong-chat-luong-pha-2.md §9.3
FAIL chấm YC — YC-99 không có ở owner — gỡ dòng ở docs/product/2-db/11-cong-chat-luong-pha-2.md §9.3
db-check: FAIL
```

### 9.6 Rà ranh giới pha của lát admin — P2A-09

Rà 2026-10-01: **Codex** chạy lọc trên ảnh `481d1ab` theo phiếu của Claude; **Claude Code** xếp hai dòng
loại 5, sửa con trỏ lệch và ký ô 7 · 8. Lệnh tái lập, phân loại từng dòng, bảng tên bảng · cột và output
dòng thử nằm ở `work/backlog_AD_DB.md` → P2A-09 *Bàn giao* — không dán ở đây, vì chính file này nằm trong
tập bị đo (cùng cách ô 9 §7). **`P2A-05` vắng, rà lại khi lát ấy xong.**

| Lượt | Chưa lọc (tài liệu / mã) | Đã lọc (tài liệu / mã) | Kết luận |
|---|---|---|---|
| A1 · B1 · B2 · C1 · C2 | 18 file · 1403 dòng / 36 file · 3868 dòng | 0 / 0 | không endpoint, route, thẻ hay tên component |
| A2 | như trên | 0 / 5 | lệnh `DELETE` SQL trong phép thử quyền database |
| A3 | như trên | 0 / 12 | biến Perl và biến của bộ kiểm, không phải HTTP |
| B3 | như trên | 1 / 15 | một câu giao việc cho pha 4 không đặt màn nào; tên cột thành phần món |
| D | như trên | 0 · 5 / 0 · 0 | kiểu và hàm của database |
| §6 chín nhóm | như trên | 38 / 11 | *khai không dựng* · *trỏ tới chỗ chặn* · quyền loại 1–3; **0 *cất*** |

**Mỗi lượt biết kêu:** một dòng cài vào bản sao của cả tập (tài liệu 1404 dòng, mã 3869 dòng) ⇒ cả hai
mươi lượt, gồm chín nhóm §6, trả đúng dòng cài.

**Hai dòng *quyền* loại 5 — Claude xếp, 2026-10-01:** [`13-luoc-do-cham-cong.md`](13-luoc-do-cham-cong.md) §3
*"Người tick là chủ quán là tầng 3 … cửa ghi phải … xét người ấy"* và
[`14-luoc-do-khoan-cua-nguoi.md`](14-luoc-do-khoan-cua-nguoi.md) §3 *"Người duyệt là chủ quán là tầng 3 … Cửa
ghi pha 3 phải xét người duyệt"*. Xếp **loại 3 + loại 2, hợp lệ**: nửa đầu trích mệnh đề đã có owner
(`I-027` · `I-028` ở `quality/invariants.md`, tầng 3 ở `03-bao-ve-invariant.md`), nửa sau giao việc cho cửa
pha 3 mà không đặt vai nào được làm gì ngoài lời mệnh đề. Đây là cách đọc của phiên, chủ repo đổi được.

**Con trỏ hai chiều:** 27 vùng mở được (10 chiều đi · 17 chiều về); **bảy chỗ lệch, Claude sửa cùng lượt**,
mỗi chỗ một ghi chú có ngày, không đổi lời nghiệp vụ: `14-luoc-do-khoan-cua-nguoi.md` hai chỗ (nối két đã
viết lại ở `T-125`), `13-luoc-do-cham-cong.md` (*ba* khoá về người, khớp test), `../00-index.md` (người
dựng ở `P2-08`), `../1-system-design/architecture.md` §14 (trực quầy đã có chỗ cất), `work/backlog_AD.md`
hai chỗ (Goal chấm công cũ hơn lời một ô mỗi ngày; lược đồ vết đã dựng).
