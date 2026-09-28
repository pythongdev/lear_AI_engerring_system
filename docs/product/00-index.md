# Product — mục lục

Hành vi nghiệp vụ của sản phẩm, cắt theo **pha** ở tầng ngoài và **mảng** ở tầng trong
(`docs/decisions.md` **ADR-014**).

> **File này không sở hữu sự thật nào.** Nó chỉ đường và ghi luật viết. Không một con số, một
> luật nghiệp vụ hay một tên trạng thái nào được chép về đây — chép là thành bản copy thứ hai,
> đúng `work/findings.md` **F-001**. **Sự thật đọc ở file của nó.**

## Sáu pha

| Pha | Thư mục | Tình trạng |
|---|---|---|
| 0 — BA (nghiệp vụ) | `0-ba/` | **đang mở** — xem bảng dưới |
| 1 — System design | [`1-system-design/`](1-system-design/architecture.md) | **đang mở** — xem bảng dưới |
| 2 — Database | [`2-db/`](2-db/01-quy-uoc-du-lieu.md) | **đang mở** — xem bảng dưới (mở 2026-09-26, `P2-03`) |
| 3 — Backend | `3-be/` | **chưa mở** |
| 4 — Frontend | `4-fe/` | **chưa mở** |
| 5 — Deploy | `5-deploy/` | **chưa mở** |

Thư mục của pha **3–5** chưa tồn tại và cố ý chưa tồn tại: nó ra đời cùng dòng nội dung đầu tiên
của pha ấy, không sớm hơn. Một file "chưa có gì" là tài liệu nghi lễ (`CLAUDE.md` §3.8), và một
thư mục rỗng không gỡ được dòng nào cho ai.

**Thứ tự việc của pha 2** — mười bốn bước `P2-01`…`P2-14`, mức của từng bước, đầu ra kiểm chứng
được và cổng sang pha 3 — ở `master_plan/DB_master_plan_banh_cuon_ba_thanh.md` (viết 2026-09-20,
`docs/decisions.md` **ADR-049**). Kế hoạch ấy **không sở hữu sự thật nào**; thư mục `2-db/` mở ở
bước `P2-03`, lượt viết dòng nội dung đầu tiên (2026-09-26).

## Pha 0 — BA

**Mảng bán hàng** — [`0-ba/ban-hang/`](0-ba/ban-hang/01-actors-pham-vi.md)

| Mục | File |
|---|---|
| §1 Actor và phạm vi hệ thống | [01-actors-pham-vi.md](0-ba/ban-hang/01-actors-pham-vi.md) |
| §2 Kênh bán | [02-kenh-ban.md](0-ba/ban-hang/02-kenh-ban.md) |
| §3 Bốn lát cắt nghiệp vụ | [03-lat-cat.md](0-ba/ban-hang/03-lat-cat.md) |
| §4 Giá và thanh toán | [04-gia-thanh-toan.md](0-ba/ban-hang/04-gia-thanh-toan.md) |
| §5 Vòng đời nghiệp vụ | [05-vong-doi.md](0-ba/ban-hang/05-vong-doi.md) |
| §6 Ngoại lệ | [06-ngoai-le.md](0-ba/ban-hang/06-ngoai-le.md) |
| §7 Phạm vi MVP | [07-pham-vi-mvp.md](0-ba/ban-hang/07-pham-vi-mvp.md) |
| §8 Scenario nghiệm thu BA | [08-scenario.md](0-ba/ban-hang/08-scenario.md) |

**Mảng quản trị (admin)** — [`0-ba/admin/`](0-ba/admin/01-ranh-gioi.md)

| Mục | File |
|---|---|
| §1.6 Ranh giới của mảng admin | [01-ranh-gioi.md](0-ba/admin/01-ranh-gioi.md) |

## Pha 1 — System design

| Nội dung | File |
|---|---|
| §1–§14 — cấu trúc hệ thống, ba mặt, quyền, tiền, nợ, mảng admin | [1-system-design/architecture.md](1-system-design/architecture.md) |
| Ranh giới hệ thống — actor (trỏ pha 0) · **phụ thuộc ngoài** · **đường suy giảm** của từng phụ thuộc | [1-system-design/01-ranh-gioi-he-thong.md](1-system-design/01-ranh-gioi-he-thong.md) |
| Thời gian — định nghĩa **một ngày bán** cho mọi phép cộng tiền · **mốc tính tiền** của từng việc · **nguồn thời gian** | [1-system-design/02-thoi-gian-ngay-ban.md](1-system-design/02-thoi-gian-ngay-ban.md) |
| Bảo vệ invariant — **tầng** giữ từng mệnh đề `I-0xx` và **phép đối chiếu** bắt nó khi hỏng (một file, năm chủ: P1-04 · P1-05 · P1-06 · P1-13 · P1-14) | [1-system-design/03-bao-ve-invariant.md](1-system-design/03-bao-ve-invariant.md) |
| Yêu cầu hình dạng dữ liệu — mỗi chỗ thiếu ở [`architecture.md`](1-system-design/architecture.md) §8 một câu *phải ghi lại được X* / *phải không thể xảy ra Y*, cộng nợ · vết · trực trạm · mốc tính tiền (P1-07) | [1-system-design/04-yeu-cau-du-lieu.md](1-system-design/04-yeu-cau-du-lieu.md) |
| Realtime và đường dự phòng — **đường đẩy** · **đường kéo** tự chạy · **bốn ràng buộc kiến trúc** `RB-1`…`RB-4` mỗi cái một **dấu hiệu đo được** · hệ thống dựa vào cái gì để nói *quán đang mất kết nối* (P1-08) | [1-system-design/05-realtime-va-du-phong.md](1-system-design/05-realtime-va-du-phong.md) |
| Sổ rủi ro — **chín rủi ro** `RR-1`…`RR-9`, mỗi rủi ro một **cơ chế chặn đã viết ra ở một mục pha 1** (hoặc một dòng ⛔ *chưa có cơ chế*), **người chịu** và **dấu hiệu nó đang xảy ra** (P1-10) | [1-system-design/06-so-rui-ro.md](1-system-design/06-so-rui-ro.md) |
| Cổng chất lượng pha 1 — **biên bản lượt diễn** ba scenario nghiệm thu BA qua thiết kế (mỗi bước trỏ vào cơ chế giữ nó, hoặc một mã `F-XXX`), tiền cộng lại từ nhà thật, và **mười ô cổng sang pha 2** đã ký kèm bằng chứng (P1-11) | [1-system-design/07-cong-chat-luong-pha-1.md](1-system-design/07-cong-chat-luong-pha-1.md) |

Đây là **đặc tả, không phải mã**: nó nói *cái gì phải đúng* và *ai được ghi cái gì*, không nói tên
hàm, tên file hay thư viện. **Số mục §1–§14 không đánh lại** — `docs/decisions.md` ADR-012 (mục
*Nợ* = §12) và ADR-013 (mục *admin* = §14) gọi tên mục bằng số ấy.

**Thứ tự việc còn lại của pha 1 ở `master_plan/SD_master_plan_banh_cuon_ba_thanh.md`** — kế hoạch
pha 1, viết 2026-09-03 (`docs/decisions.md` **ADR-033**). Nó giữ mười bốn bước `P1-01`…`P1-14`,
chỗ đang bị chặn và cổng sang pha 2; nó **không sở hữu sự thật nào**, và trạng thái từng bước đọc ở
`work/backlog.md`. Đầu ra của mỗi bước vào một **file mới** trong thư mục này, một chủ đề một file,
kèm một dòng vào bảng trên trong cùng thay đổi (mục *Luật ghi* dưới đây).

`master_plan/phase_1_system_design_banh_cuon_ba_thanh.md` là **bản nháp pha 1 và không sở hữu gì**;
nó ở lại `master_plan/` (ADR-014, khối *SỬA ĐỔI 2026-09-03*). Đừng đọc nó như một owner. Nó dùng
`SD-01`…`SD-10` làm mã task **và** `SD-01`…`SD-07` làm mã quyết định, nên kế hoạch pha 1 cố ý dùng
tiền tố khác — `P1-XX` (ADR-033).

## Pha 2 — Database

| Nội dung | File |
|---|---|
| Quy ước dữ liệu — **cất bằng gì**: đặt tên · khoá · tiền · mốc và múi giờ · trạng thái · không xoá cứng · văn bản và định danh; mỗi quy ước một mã `QD-XX`, một hậu quả nếu làm khác và một phép kiểm (P2-03) | [2-db/01-quy-uoc-du-lieu.md](2-db/01-quy-uoc-du-lieu.md) |
| Lược đồ lát bán hàng lõi — bàn · phiên bàn · bàn của phiên · đơn · dòng đơn · dấu *đem về*: ý định, lý do và ánh xạ `I-001` `I-002` `I-003` `I-006` `I-007` `I-016` `I-017` `YC-05`; tên · kiểu · ràng buộc ở file migration (P2-04, ADR-053 luật 2) | [2-db/02-luoc-do-ban-hang.md](2-db/02-luoc-do-ban-hang.md) |
| Lược đồ lát menu · giá · ảnh chụp giá lúc đặt — thành phần có giá · suất bán · nhóm tuỳ chọn dùng chung · luật *Lượng nhân* theo tập · ảnh chụp giá, tên, thành phần, tuỳ chọn trên dòng đơn: ý định, lý do và ánh xạ `I-009` `I-010` `I-011` `I-013`; tên · kiểu · ràng buộc ở file migration (P2-05, ADR-053 luật 2) | [2-db/03-luoc-do-menu-gia.md](2-db/03-luoc-do-menu-gia.md) |
| Lược đồ lát đường tiền — hoá đơn (lần đóng một đơn vị tính tiền) · thu chia phương thức · nợ và thu nợ · hoàn tiền · khoản trả trước và chuỗi số dư của nó · tiền đầu két: ý định, lý do và ánh xạ `I-005` `I-012` `I-014` `I-015` `I-021` `YC-01` `YC-02` `YC-09` `YC-10` `YC-11` `YC-19` `YC-23`; thay thế `1-system-design/architecture.md` §12.3; tên · kiểu · ràng buộc ở file migration (P2-06, ADR-053 luật 2) | [2-db/04-luoc-do-duong-tien.md](2-db/04-luoc-do-duong-tien.md) |
| Lược đồ lát sản xuất theo mẻ — trạm của thành phần · việc trạm một dòng một đơn vị · mẻ (một lần bấm *đã làm xong*) và lần lùi mẻ · thứ mẻ đã làm, phần của từng bàn · lần chuyển phần đã làm của đơn huỷ sang bàn khác; không ô tổng nào: ý định, lý do và ánh xạ `I-004` `I-019` `I-020` `YC-06` `YC-07`; `S-5` · `S-6` là ô trống có mã; tên · kiểu · ràng buộc ở file migration (P2-07, ADR-053 luật 2) | [2-db/05-luoc-do-san-xuat.md](2-db/05-luoc-do-san-xuat.md) |
| Quy ước code — **dựng và kiểm bằng gì**: DBMS + phiên bản · cách chạy database · vai · kiểu · migration · múi giờ kết nối · khung test · thư mục · stack · tên ràng buộc; mỗi quy ước một mã `QC-XX` và một phép kiểm (P2-12, ADR-055) | [2-db/10-quy-uoc-code.md](2-db/10-quy-uoc-code.md) |

Các lát lược đồ sau **thêm** dòng vào bảng này, không ghi đè dòng của lát trước (kế hoạch pha 2 §6).

**Câu hỏi chưa có lời giải** — [99-unknowns.md](99-unknowns.md), dùng chung cho mọi pha.

## Luật ghi

- **Một sự thật, một owner** (`CLAUDE.md` §2). Sửa ở file của mục, không sửa ở bản lưu.
- **Số mục không đánh lại.** Tên file giữ nguyên số cũ vì cả repo đã trỏ theo số ấy; đánh số lại
  là làm sai nghĩa hàng loạt câu mà `grep` không bắt được (**ADR-014**, *Rejected alternatives*).
- **Nội dung mảng admin đi vào file của mảng admin**, tên thư mục mang chữ `admin` — không trộn
  vào file của mảng bán hàng (`docs/decisions.md` **ADR-013**).
- **Câu hỏi chưa có lời giải đi vào `99-unknowns.md`**, đúng hình dạng mà mục ấy quy định —
  `scripts/brief.sh` đọc nó theo cấu trúc (**ADR-007**), nên viết sai hình dạng là viết một câu
  không phiên nào thấy.
- **Pha mới**: tạo thư mục của pha cùng lúc với dòng nội dung đầu tiên, rồi thêm dòng vào bảng
  *Sáu pha* ở trên trong cùng một thay đổi.
- **`docs/product.md` là bản lưu**, giữ lại làm ảnh chụp ngày tách. Nó không sở hữu gì và
  **không được trỏ về như một owner**.
