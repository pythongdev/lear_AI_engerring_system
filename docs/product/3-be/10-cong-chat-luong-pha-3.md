<a id="top"></a>
# Cổng chất lượng pha 3 — ba scenario nghiệm thu diễn qua API, và mười hai ô sang pha 4

Pha 3 · bước `P3-13` · viết 2026-10-13 (Claude Code). Đầu vào:
[`../0-ba/ban-hang/08-scenario.md`](../0-ba/ban-hang/08-scenario.md) §8 (ba scenario) ·
[`../../../master_plan/BE_master_plan_banh_cuon_ba_thanh.md`](../../../master_plan/BE_master_plan_banh_cuon_ba_thanh.md)
§9 (lời của mười hai ô) · chín file pha 3 đứng trước file này. Cách ký theo tiền lệ cổng pha 2
([`../2-db/11-cong-chat-luong-pha-2.md`](../2-db/11-cong-chat-luong-pha-2.md) §7).

> **File này sở hữu đúng hai thứ:** **biên bản lượt diễn** ba scenario qua API, và **trạng thái đã ký của mười
> hai ô cổng sang pha 4**, mỗi ô kèm bằng chứng hoặc để trống kèm lý do và mã.
>
> **Nó không sở hữu** một bước scenario nào (nhà: `08-scenario.md` §8), một đường gọi hay mã lỗi nào (nhà:
> [`openapi.yaml`](openapi.yaml), **ADR-084**), một tầng bảo vệ nào (nhà:
> [`../1-system-design/03-bao-ve-invariant.md`](../1-system-design/03-bao-ve-invariant.md)), một dữ kiện quán
> nào (nhà: `master_plan/shop-facts.md`, **ADR-001**), hay **lời** của mười hai ô (nhà: kế hoạch pha 3 §9 — ở
> đây chép hình dạng và thêm bằng chứng).
>
> **Bằng chứng in lại mỗi lần chạy** `./scripts/be-check.sh` (Gate 1): bộ diễn ở
> [`be/internal/don/scenario_test.go`](../../../be/internal/don/scenario_test.go), mỗi bước một dòng
> `t.Logf`. Con số dưới đây là bản đo **2026-10-13**; đọc số sống ở output của lệnh (**F-001** · **F-033**).
> **Ký chuyển sang pha 4 là quyền chủ repo** — file này chỉ nói ô nào đã ký.

---

## 0. Cách đọc

**Diễn thế nào.** Bốn test Go trên PostgreSQL thật (database rỗng của `be-check`, migrate từ số không, menu
nạp từ `shop-facts.md` qua `seed.pl`), **router thật** của `be/cmd/server`. Mỗi bước ở quán là **một lời gọi
HTTP** theo hợp đồng; SQL chỉ dùng để dựng người · quầy · bàn · món riêng của test, như mọi test cửa khác.
Ngày bán là một ngày giả của tháng 7/2031 (đồng hồ của cửa đặt về ngày ấy), không chạm ngày của test khác.

**Đọc lại thế nào.** Sau từng bước, test đọc lại bằng chính đường đọc của hợp đồng (`GET`) hoặc bằng kết nối
chủ lược đồ, và khẳng định từng dòng *Kết quả mong đợi* của `08-scenario.md`. Giá đọc lúc chạy từ menu đã nạp
(bảng ca §4.8), không gõ lại con số.

---

## 1. Ba scenario qua API — biên bản lượt diễn

Số bước là số của `08-scenario.md` §8; một bước ở quán có thể là vài lời gọi (duyệt · bấm mẻ · bưng). Cột phải là
lời gọi thật lấy từ dòng `t.Logf` của lần chạy **2026-10-13 11:03** (`id` và mã QR lược đi). Một lời gọi `200` lặp lại
đúng thân của lời gọi tạo là **đọc lại bằng cách gửi lại cùng dấu** (`I-024`): cửa trả đúng đơn đã ghi, không ghi thêm.

### 1.1 Scenario 1 — `TestI002_Scenario1_QRTaiBanBaLuotMotHoaDon`

| # | Lời gọi | Khẳng định |
|:--:|---|---|
| 1–2 | `POST /qr-codes/{code}/orders` 201 · gửi lại 200 | phiên mở ở lượt đầu, đơn `pending_confirmation`, 0 việc trạm; tiền lượt 1 = ca 10 × 2 |
| 3–4 | `POST /orders/{id}/approval` 200 · `GET /production-board` 200 | duyệt ⇒ `in_progress`; **sáu** nhóm việc trên ba trạm: tráng {6 bánh, 2 trứng} · gấp {6 bánh, 2 trứng, 2 giò} · canh {1} |
| 5–6 | `POST /production-batches` 201 · `POST /served-marks` 200 | mọi việc `served` ⇒ lượt 1 `completed` |
| 7–9 | `POST /table-orders` 201 · gửi lại 200 · mẻ · bưng | lượt 2 đặt hộ vào thẳng `in_progress`, **cùng phiên** |
| 10 | `POST /table-sessions/{id}/bill-request` 200 · `GET /dining-tables` | tổng = lượt 1 + lượt 2; phiên `awaiting_payment`; bàn **chưa** trống (`in_session`) |
| 11–12 | `POST /qr-codes/{code}/orders` 201 · duyệt · mẻ · bưng | lượt 3 sau tính tiền vào **cùng phiên**, phiên về `serving` |
| 13 | `POST /table-sessions/{id}/bill-request` 200 | **due_vnd 96000** — cùng một phiên, chưa hoá đơn nào |
| 14 | `POST /table-sessions/{id}/closing` 201 | một hoá đơn: 96.000 = 60.000 tiền mặt + 36.000 chuyển khoản (tỷ lệ của ví dụ BA, số đọc lúc chạy) |
| 15–17 | `GET /dining-tables` · `POST /dining-tables/{id}/cleaning` 200 · `GET /dining-tables` | `needs_cleaning` ⇒ dọn ⇒ `empty`; **một** phiên suốt scenario; ba đơn `completed` |

### 1.2 Scenario 2 — `TestI007_Scenario2_BaDonMangDiBaKenh`

| # | Lời gọi | Khẳng định |
|:--:|---|---|
| 1–4 | `POST /online-orders` 201 × 2 · `POST /phone-orders` 201 · gửi lại 200 | ba đơn lẻ không phiên, không bàn, kể cả A và C cùng một khách; A · B `pending_confirmation`, **C `confirmed`** |
| 5–6 | `POST /orders/{id}/approval` × 2 · `POST /orders/{id}/prepayment` 201 | duyệt A · B; trả trước của B ghi lúc quầy nhận tiền, không lúc khách chọn |
| 7–9 | `POST /preorder-releases` 200 · `GET /production-board` · `POST /production-batches` 201 | C nổ ở mốc nhắc; **mỗi đơn đúng một việc nước chấm**; đóng gói chưa làm đơn nào `completed` |
| 10 | `POST /orders/{id}/departure` **409 `delivery_served_mark_undecided`** · `POST /served-marks` · `departure` 200 | **S-6** chưa có lời: cửa rời quán **từ chối** khi việc chưa `served` (ADR-088), không đoán; bài diễn bưng qua cửa công khai rồi rời quán ⇒ A `delivering` |
| 11 | `POST /orders/{id}/delivered` 201 | người đi giao thu tại chỗ khách: hoá đơn A 50.000 tiền mặt, người là người giao |
| 12–13 | `POST /served-marks` · `POST /orders/{id}/handover` 201 × 2 | B dùng trả trước, **không thu lại** (30.000 chuyển khoản trả trước); C thu 15.000 tại quầy |
| 14 | gửi lại 200 | ba đơn `completed`; ba hoá đơn, một lần trả trước; chỉ A từng `delivering` |

### 1.3 Scenario 3 — `TestI009_Scenario3_DoiGiaGiuaBuoi`

Chạy Scenario 1 trước (đơn combo để bước 10 đọc lại), rồi:

| # | Lời gọi | Khẳng định |
|:--:|---|---|
| 1 | `POST /table-orders` 201 | 8:00 suất giò nhân thường khoá giá cũ (25.000) |
| 2–4 | `PUT /menu-components/{id}/base-price` 200 · `GET /menu` × 2 | 8:30 nâng giá chay một thành phần riêng của test; menu chung năm kênh báo giá mới |
| 5–6 | `POST /table-orders` 201 · gửi lại lượt 8:00 200 | 9:00 cùng món, **cùng phiên**, giá mới (29.000); lượt 8:00 đọc lại y nguyên |
| 7 | mẻ · bưng · `bill-request` · `closing` 201 | **một** hoá đơn **54.000** mang hai mức giá cho một món |
| 8 | `POST /menu-items/{id}/discontinuation` 200 · năm đường đặt **409 `menu_item_discontinued`** | không kênh nào đặt mới; đơn 8:00 vẫn đọc đúng tên và giá |
| 9 | `PUT /menu-items/{id}/components/{id}` 200 | sửa thành phần combo 3 → 2 **vẫn cho lưu**, vết mang trước/sau, lý do, người. *Lời nhắc trước khi lưu* là việc của pha 4 ([`03-ham-gia.md`](03-ham-gia.md) §4) |
| 10 | gửi lại đơn combo của Scenario 1 · dọn bàn | đơn cũ giữ tổng và **6 cái bánh** ở trạm tráng |

### 1.4 Một ngày bán giả qua cửa — `TestI021_MotNgayDienQuaCuaRa0dLech`

Cả ba scenario trên **một** ngày sạch (`2031-07-04`): `POST /opening-floats` 201 → ba scenario → `POST /cash-counts`
201 → `GET /sale-days/{d}/cash-reconciliation` *counted_vnd 1379000 · opening_float_vnd 1200000 · expected_vnd 179000 ·
gap_vnd 0 · paper_entries_pending 0* → `POST /sale-days/{d}/reconciliation` 201 *gap_vnd 0*. Tiền mặt 179.000 = 60.000
(S1) + 50.000 · 15.000 (S2 A · C) + 54.000 (S3). Doanh thu cả ngày bằng tổng ba scenario; đổi giá menu **sau** khi ký
không đổi tiền ngày đã ký. Bộ đối chiếu `scripts/reconcile.sh` (prelude + mọi tập `I-0xx`, lọc theo ngày · hoá đơn ·
đơn · phiên của bài diễn): **77 tập rỗng**, `pg_temp.ket_ngay` khớp ba con số. Ba tập `I-008/1…3` **bỏ qua có ghi
lý do**: chúng đọc `sales_order.created_at` do database ghi theo giờ thật, còn đồng hồ của cửa trong test là đồng hồ
giả — chạy lúc 11:01 (ngoài giờ bán) thì `I-008/1` có 8 dòng của bài diễn; ở production hai đồng hồ là một. Vế `I-008`
có test qua cửa riêng (`TestI008_*`).

**Lỗi cài** (worktree tách rời, đã gỡ): câu cộng tiền phiên `be/internal/phien/sql/tong_tien.sql` bỏ lượt QR gọi sau
tính tiền ⇒ *scenario_test.go: tổng phiên: có 93000 muốn 96000* — đỏ ở cả `TestI002_Scenario1…`, `TestI009_Scenario3…`
và `TestI021_MotNgayDien…`.

---

## 2. Mười hai ô cổng — kế hoạch pha 3 §9

Mười hai ô dưới đây là **lời** của kế hoạch pha 3 §9; chỗ ký là đây. Một ô tick khi **cách chứng minh viết kèm
ô ấy** chạy đủ; thiếu một phần thì để trống kèm lý do và mã — không ô nào tick vì *nhìn chung đạt*.

Hôm nay **10/12 ô tick**, hai ô trống có mã (2026-10-13, Claude Code: chín ô ở `P3-13`, ô 10 ở `P3-14`). Đủ các ô **không** phải câu *"được, sang pha
4"*: ký chuyển pha là quyền **chủ repo** (kế hoạch §9).

- [ ] **1. Mọi vế tầng 3 của `03-bao-ve-invariant.md` §1–§4 có một test từ chối qua cửa** — **TRỐNG, `F-068`.**
  Ở mức hàng (ADR-082 điểm 4) lệnh chạy đủ: 18 hàng có vế tầng 3 (`I-002 I-003 I-004 I-006 I-007 I-008 I-009 I-010
  I-012 I-013 I-014 I-016 I-019 I-020 I-021 I-022 I-023 I-024`), tập `TestI0xx` phủ 23 mã, `comm -23` **rỗng**. Mười
  sáu hàng có lời từ chối qua cửa, ví dụ `I-002` *table_session_has_open_orders* · `I-003` *dining_table_needs_cleaning*
  · `I-008` *outside_selling_hours* · `I-013` *option_combination_invalid* · `I-014` *paper_entries_pending* · `I-016`
  *order_transition_not_allowed* · `I-021` *gap_explanation_required* · `I-024` *submission_code_conflict*. Hai hàng
  **không**: `TestI006_SuatDemVeThuocPhienBan` và `TestI019_*` chỉ chứng minh đường đúng — vế tầng 3 của chúng là
  *không có đường thứ hai*, chưa test nào dựng trạng thái sai qua cửa để in lời từ chối.
- [ ] **2. Mọi vế tầng 2 có ranh giới giao dịch đã bị cắt thử** — **TRỐNG, `F-068`.** Bảy hàng có vế tầng 2 (`I-004
  I-009 I-015 I-017 I-018 I-019 I-020`). Đã cắt qua cửa: `TestI004_CatGiuaLanNoKhongNuaNaoSong` (*cắt giữa lần nổ ⇒ 500,
  đơn còn pending_confirmation, 0 việc*) và `TestI017_CatGiuaLucDongKhongNuaNaoSong` (*cắt giữa lúc đóng ⇒ 500
  internal_error, database y như trước* — cắt **sau** lần ghi hoá đơn, nên phủ cả vế tầng 2 của `I-015`). `I-019`: vế
  có điều kiện không phát sinh — lược đồ sản xuất không cột tổng lưu riêng (đọc `20260928130000_san_xuat_theo_me.up.sql`).
  Chưa cắt: hai vế của `I-020` (bấm mẻ phủ nhiều bàn · đường lùi); vế *đồng thời* của `I-018` (và `I-009` dựa vào nó)
  chỉ có bằng chứng tầng database (trigger vết cùng câu lệnh, `db/tests/i018_*`).
- [x] **3. Mỗi ô ghi có đúng một cửa** — *check-write-paths: PASS — 47 ô ghi, 48 cửa, 340 file đã soát*; trên
  `--list`, số ô (bảng × loại × cột) lặp **0**.
- [x] **4. Một hàm tính giá** — qua cửa ghi đơn, `TestI013_BangCaGiaQuaCuaGhiDon` chạy đủ **13 ca** §4.8, mỗi ca *đơn
  giá … (tính thử …), thành tiền …, tổng … (§4.8 đòi …)* khớp từng đồng (ca 11 *TỪ CHỐI ở cả hai đường*); cùng bảng
  qua tính thử `TestI013_BangCaGiaQuaTinhThu`. `grep 'gia.Tinh('` ngoài test: `be/internal/don/service.go` (cửa tạo
  lượt gọi) · `be/internal/hoadon/nhap_bu.go` (nhập bù, ở mốc `sold_at`) · trong `be/internal/gia/` (tính thử · menu);
  không chỗ nào ngoài `gia` cộng giá gốc hay phụ thu (hai dòng ở `be/internal/don/repository.go` chỉ chép ảnh chụp đã tính).
- [x] **5. Hợp đồng khớp code** — *check-api-contract: PASS — hợp đồng 0.18.0; 55 đường gọi ở hợp đồng, 55 ở code; 68
  mã lỗi; 308 tên từ chối ở migration, 308 dòng ánh xạ*; biết đỏ: `scripts/check-api-contract.test.sh` *OK*, gồm *3
  đường gọi chỉ ở code ⇒ đỏ (exit 1)* · *4 đường gọi chỉ ở hợp đồng ⇒ đỏ (exit 1)*.
- [x] **6. Mọi thao tác ghi có dòng trong ma trận vai × thao tác** — 48 `authz.Door` khai trong code (ngoài file test)
  và 48 dòng ma trận ở [`02-vai-va-quyen.md`](02-vai-va-quyen.md), `comm -3` **rỗng**; Gate 1g in *48 cửa, 48 dòng
  ma trận, 48 khai báo authz.Door*.
- [x] **7. Không mốc tính tiền nào lấy giờ của máy khách** — mọi cửa tiền lấy mốc từ `ngayban.DongHo` (database).
  Trường thời gian duy nhất nhận từ client mà chạm tiền là `sold_at` của cửa nhập bù — đúng hàng *nhập bù một lượt bán
  từ sổ giấy* ở [`02-thoi-gian-ngay-ban.md`](../1-system-design/02-thoi-gian-ngay-ban.md) §2 (mốc quán bán thật, ADR-037);
  cửa buộc nó thuộc ngày của sổ và trước giờ hệ thống (`TestYC08_NhapBuTuChoi`). `customer_needed_at` là giờ hẹn, không
  phải mốc tính tiền.
- [x] **8. Ba scenario đi hết qua API** — §1: bốn test PASS, mỗi bước một lời gọi thật; một ngày bán giả ⇒ *gap_vnd 0*,
  77 tập đối chiếu rỗng; lỗi cài tách hoá đơn bị bắt. ⚠️ Tick kèm: bước 10 Scenario 2 dừng ở **S-6** (từ chối có mã,
  xem ô 11); ba tập `I-008` bỏ qua có lý do (§1.4).
- [x] **9. Mỗi phụ thuộc ngoài đã bị cắt thử** — sáu dòng PT ở [`09-realtime-du-phong.md`](09-realtime-du-phong.md),
  lần chạy 2026-10-13: PT-1 `TestI008_KhongLuongQuayThiBaKenhTuBamBiTuChoi` · `TestI008_CoLuongQuayThiNhanDon` ·
  `TestI008_NhieuLuongQuayVaTuChoiSaiLop` PASS; PT-2 `TestI008_PT2_DatabaseMatVaNoiLai` PASS; PT-3 `TestI012_CuaTienCanNguoiCoTen`
  PASS (và không route ngân hàng tự ghi tiền); PT-4 `TestI021_MotNgayBanGiaQuaCuaRa0dLech` · `TestI021_CaiMotLanThuSaiDoiSoatKeu`
  PASS; PT-5 `TestI008_MatDayVanDocDuocDonDaNhan` PASS; PT-6 `TestYC08_KhaiSoGiayQuaCua` · `TestI014_KyNgayConLuotGiayBiTuChoi`
  · `TestI014_KhaiSoChenLucKyNgay` PASS, và từ `T-174` đường bù trọn vẹn `TestI021_NgayGiayNhapDuRa0dLech` PASS.
- [x] **10. Không component · route màn hình nào trong file pha 3** — ký ở `P3-14` (2026-10-13). Bộ mẫu pha 3 của Gate 1d
  (`PATTERN3`, đọc lúc chạy từ `scripts/check-phase-boundary.sh`) chạy trên **mọi** file của `docs/product/3-be/` kể cả
  `openapi.yaml`, không chỉ file đổi: **chưa lọc 0 dòng**, `check-phase-boundary.ignore` không có dòng nào của `3-be` ⇒
  **đã lọc 0 dòng**; dòng mồi chứng minh mẫu khớp được trên máy này (một thẻ JSX tên viết hoa và một lời gọi điều hướng của router khớp; một kiểu generic `Map` hai tham số không khớp — **F-017**). Lưới rộng thêm bằng mắt (`component|màn hình|screen|button|modal|
  react|giao diện`, và chữ *màn*): chỉ còn *interface* Go `Authenticator` và các câu nói **bên đọc** của một hành vi API
  (*màn đọc lại*, *màn tự kéo — pha 4*) — không tên component, không route.
- [x] **11. Không câu nghiệp vụ nào đang mở mà một cửa phải đoán thay** — `docs/product/99-unknowns.md` không còn câu
  nào dưới *Đang mở* (brief 2026-10-13). Bảng §4 của kế hoạch: bấm *đã ra bàn* theo đơn vị nào có lời 2026-10-09; giảm
  giá cả đơn có lời 2026-10-12 và cửa ở `T-175`; chỉ **S-6** chưa có lời ⇒ cửa rời quán **từ chối** kèm
  `delivery_served_mark_undecided` (Scenario 2 bước 10 in đúng lời ấy).
- [x] **12. Hàng `CLAUDE.md` §2 *Hợp đồng API* hết nói *chưa có owner*** — hàng trỏ `docs/product/3-be/openapi.yaml`
  và `01-hop-dong-api.md`; [`../00-index.md`](../00-index.md) kể tên cả mười một file của `3-be/`, kể cả file này.

---

## 3. Chỗ hụt lộ ra khi chấm

- **`F-068`** — ô 1 · ô 2 (`work/findings.md`): test từ chối cho vế tầng 3 của `I-006` · `I-019`; test cắt cho hai vế
  tầng 2 của `I-020` và cắt qua cửa cho vế đồng thời của `I-018`. Lượt chấm không sửa code.
- **S-6** — đơn giao tận nơi, quầy bấm *đã ra bàn* lúc nào: chủ quán, `master_plan/shop-facts.md` §7.2. Không chặn ô
  nào (cửa từ chối kèm mã), nhưng Scenario 2 chưa diễn được đúng trình tự BA *trao tại chỗ khách*.
- **`F-069`** — lượt rà `P3-14`: `master_plan/prompt-fullstack.md` §3.6 giữ một bề mặt API cũ khác hẳn hợp đồng.
- **`F-070`** — lượt rà `P3-14`: bốn lời hứa *việc của pha 3* chưa có dòng nào nhận — đứng đầu là **Telegram báo đơn web về
  quầy** (`master_plan/shop-facts.md` §1), pha 3 chỉ dựng SSE; nên thành một câu hỏi cho chủ repo trước khi ký chuyển pha 4.
