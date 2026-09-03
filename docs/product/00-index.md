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
| 2 — Database | `2-db/` | **chưa mở** |
| 3 — Backend | `3-be/` | **chưa mở** |
| 4 — Frontend | `4-fe/` | **chưa mở** |
| 5 — Deploy | `5-deploy/` | **chưa mở** |

Thư mục của pha **2–5** chưa tồn tại và cố ý chưa tồn tại: nó ra đời cùng dòng nội dung đầu tiên
của pha ấy, không sớm hơn. Một file "chưa có gì" là tài liệu nghi lễ (`CLAUDE.md` §3.8), và một
thư mục rỗng không gỡ được dòng nào cho ai.

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

Đây là **đặc tả, không phải mã**: nó nói *cái gì phải đúng* và *ai được ghi cái gì*, không nói tên
hàm, tên file hay thư viện. **Số mục §1–§14 không đánh lại** — `docs/decisions.md` ADR-012 (mục
*Nợ* = §12) và ADR-013 (mục *admin* = §14) gọi tên mục bằng số ấy.

**Thứ tự việc còn lại của pha 1 ở `master_plan/SD_master_plan_banh_cuon_ba_thanh.md`** — kế hoạch
pha 1, viết 2026-09-03 (`docs/decisions.md` **ADR-033**). Nó giữ mười hai bước `P1-01`…`P1-12`,
chỗ đang bị chặn và cổng sang pha 2; nó **không sở hữu sự thật nào**, và trạng thái từng bước đọc ở
`work/backlog.md`. Đầu ra của mỗi bước vào một **file mới** trong thư mục này, một chủ đề một file,
kèm một dòng vào bảng trên trong cùng thay đổi (mục *Luật ghi* dưới đây).

`master_plan/phase_1_system_design_banh_cuon_ba_thanh.md` là **bản nháp pha 1 và không sở hữu gì**;
nó ở lại `master_plan/` (ADR-014, khối *SỬA ĐỔI 2026-09-03*). Đừng đọc nó như một owner. Nó dùng
`SD-01`…`SD-10` làm mã task **và** `SD-01`…`SD-07` làm mã quyết định, nên kế hoạch pha 1 cố ý dùng
tiền tố khác — `P1-XX` (ADR-033).

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
