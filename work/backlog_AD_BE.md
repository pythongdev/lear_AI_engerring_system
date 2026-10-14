<a id="top"></a>
# Sổ mô tả — backend admin (`P3A-01`…`P3A-10`)

Thứ tự, mức và cổng: [`master_plan/AD_BE_master_plan_banh_cuon_ba_thanh.md`](../master_plan/AD_BE_master_plan_banh_cuon_ba_thanh.md).
Trạng thái: `work/backlog.md`. Mỗi entry giữ mô tả dài; *Nhận việc* điền khi bước được nhận. Viết 2026-10-14 (T-191,
Claude Code) — **ADR-110**.

**Chung cho mọi bước.** Danh tính là phiên cookie của `T-190`; mọi bước cần `T-190` đã đưa về. Khuôn domain như
`be/internal/nguoi` (handler · service · repository · `sql/<cửa>/` · sqlc). Claude viết test trước, Codex thi công,
Claude chạy `be-check` · `db-check` (sandbox Codex không tới Docker). Lớp của cửa đọc từ mệnh đề `I-0xx`; mệnh đề
không nói ⇒ `chu_quan` và một câu hỏi (kế hoạch §3).

---

<a id="p3a-01"></a>
### P3A-01 — Chủ quán ghi tiền điện vào máy rồi không có cửa nào nhận nó

**Goal:** ghi, sửa có lý do và đọc khoản chi theo khoảng ngày, theo loại, theo nguồn; thêm loại chi kèm nguồn. Trang
`P4A-10` là một bộ lọc *loại = marketing* của cùng cửa đọc.
**Đứng trên:** lát `P2A-05` (`docs/product/2-db/15-luoc-do-khoan-chi.md`), `I-029`.
**Bẫy:** nguồn tiền ở **loại**, không trên khoản; loại đã có không đổi nguồn được (database từ chối) — cửa không mở
đường ấy. Ai được ghi chưa có lời: lớp `chu_quan` tới khi `U-095` đóng.
**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p3a-02"></a>
### P3A-02 — Sổ nguyên liệu có chỗ cất mà không có cửa ghi

**Goal:** thêm thứ vào danh mục, đặt đơn vị cho thứ chưa có; ghi hai con số *mua vào · đã dùng* của một ngày; sửa có
lý do; đọc tổng và hiệu số của một thứ theo phép của `I-026`.
**Đứng trên:** lát `P2A-02` (`docs/product/2-db/12-luoc-do-nguyen-lieu.md`), `I-025` · `I-026`.
**Bẫy:** máy chép con số người ghi, không tự suy lượng dùng từ món bán (§8.4); thứ chưa có đơn vị đọc ra *trống*.
**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p3a-03"></a>
### P3A-03 — Việc giao có chỗ cất mà không ai tạo được

**Goal:** tạo · sửa · ẩn việc, đánh dấu xong và bỏ đánh dấu, đọc việc theo người nhận.
**Đứng trên:** lát `P2A-11` (`docs/product/2-db/16-luoc-do-giao-viec.md`), `I-030` — lớp `quay_hoac_chu_quan`.
**Bẫy:** mỗi lần đánh dấu là một dòng sự kiện, không đè cờ; người nhận tự đánh dấu — lời không nói, không mở.
**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p3a-04"></a>
### P3A-04 — Hướng dẫn và ghi nhận đào tạo chưa có cửa

**Goal:** hướng dẫn gắn một việc giao (chữ, tệp ảnh · video), ghi nhận *đạt · chưa* kèm nhận xét về một người.
**Đứng trên:** lát `P2A-12` (`docs/product/2-db/17-luoc-do-dao-tao.md`), `I-031` — lớp `quay_hoac_chu_quan`.
**Bẫy:** tệp không vào database; chỗ giữ tệp theo quyết định của lát `P2A-12`.
**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p3a-05"></a>
### P3A-05 — Chủ quán muốn tự đặt danh mục món

**Goal:** thêm · đổi tên · ẩn danh mục, xếp món vào danh mục, đọc menu theo danh mục.
**Đứng trên:** lát `P2A-13` (`docs/product/2-db/18-luoc-do-danh-muc-combo.md`), `I-032` — lớp `chu_quan`.
**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p3a-06"></a>
### P3A-06 — Combo có giá riêng nhưng hàm giá chưa biết combo

**Goal:** thêm · đổi giá · ẩn combo; combo đi qua **hàm giá duy nhất** với giá chủ quán đặt, ca test mới ở bảng ca của
`docs/product/3-be/03-ham-gia.md`.
**Bẫy:** giá combo **không** là tổng giá món (`I-032`, U-092); đổi giá trong giờ bán là câu `I-032/6`.
**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p3a-07"></a>
### P3A-07 — Chủ quán muốn tự thêm món

**Goal:** thêm món mới, sửa thông tin món (tên, danh mục); *xoá* là ngừng bán đã có ở pha 3. Sửa giá và thành phần đã
có cửa — không mở cửa thứ hai.
**Đứng trên:** lát menu `P2-05` (`docs/product/2-db/03-luoc-do-menu-gia.md`), §8.9.
**Bẫy:** cột món mới cần mà lược đồ chưa có ⇒ dừng, mở task lược đồ.
**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p3a-08"></a>
### P3A-08 — Kho phải nhắc POS mà không kết luận thiếu

**Goal:** đọc thời gian nhập, tổng đã dùng, số thiếu theo phép §8.4, và cờ *nhắc kiểm tra* khi phần còn lại dưới tỉ lệ
chủ quán đặt.
**Bị chặn bởi:** `T-186` (cột tỉ lệ nhắc).
**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p3a-09"></a>
### P3A-09 — Chủ quán không đứng quầy vẫn muốn một bảng

**Goal:** một cửa đọc gom bảy thứ của §8.6 cho lớp `chu_quan`; thứ nào đã có cửa đọc thì dùng lại truy vấn của nó.
**Bẫy:** *số tiền dự tính* là tạm tính, không bày như doanh thu đã đối soát.
**Nhận việc:** —

[↑ đầu file](#top)

---

<a id="p3a-10"></a>
### P3A-10 — Trang tổng kết đòi số theo ngày bán

**Goal:** doanh thu theo **ngày bán** (`02-thoi-gian-ngay-ban.md`), món bán chạy (`E48`), cảnh báo sắp hết từ
`P3A-08`; *hiệu suất nhân viên* trả *chưa có lời* — không chấm điểm người.
**Nhận việc:** —

[↑ đầu file](#top)
