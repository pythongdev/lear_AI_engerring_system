# Kế hoạch — backend của mảng QUẢN TRỊ (admin) · Bánh cuốn Bà Thanh Cao Bằng

> **File này là KẾ HOẠCH, không sở hữu sự thật nào.** Nó giữ *thứ tự · mức · đầu ra kiểm chứng được* của các
> bước `P3A-XX`. Dữ kiện quán ở `master_plan/shop-facts.md` §8; trạng thái từng bước ở `work/backlog.md`; mô tả dài
> ở `work/backlog_AD_BE.md`; hợp đồng thật ở `docs/product/3-be/openapi.yaml`; lược đồ ở `db/migrations/`
> (`CLAUDE.md` §2).
>
> Viết **2026-10-14** (T-191) theo lời chủ repo cùng ngày: *"mở một task lập kế hoạch backend admin rồi làm các
> cửa API mà từng trang cần"*. Lời ấy mở cổng thi công backend admin mà vế 2026-10-14 của **Đ-2** còn để ngỏ
> (`work/backlog.md` mục *Thứ tự làm*) — ghi ở `docs/decisions.md` **ADR-110**. Con số đếm trong file đo ngày
> 2026-10-14: **đếm lại ở owner** (`work/findings.md` **F-003**).

---

## 1. Câu hỏi kế hoạch này trả lời — một dòng

Mỗi trang admin `P4A-01`…`P4A-11` (`work/backlog_FE_AD.md`) cần **những cửa nào** ở backend, cửa ấy đứng trên lát
lược đồ nào đã dựng, và làm theo thứ tự nào để trang nào cũng có cửa trước khi pha 4 dựng nó.

## 2. Trang → cửa → lát lược đồ — đo 2026-10-14

| Trang | Cần cửa | Đứng trên | Bước |
|---|---|---|---|
| `P4A-01` vỏ admin | đọc *tôi là ai, có cờ chủ quán không* | `GET /sessions/current` của `T-190` | — (T-190) |
| `P4A-06` nhân viên | danh sách · duyệt · từ chối · khoá · mở lại tài khoản | lát `P2A-14` | — (T-190) |
| `P4A-10` marketing | loại chi · khoản chi: ghi, sửa có lý do, đọc theo khoảng ngày và loại | lát `P2A-05` | `P3A-01` |
| `P4A-08` nguyên liệu | danh mục nguyên liệu: thêm, đặt đơn vị · dòng ngày *mua vào · đã dùng*: ghi, sửa có lý do · đọc tổng và hiệu số | lát `P2A-02` | `P3A-02` |
| `P4A-07` giao việc | việc: tạo · sửa · ẩn · đánh dấu xong / bỏ đánh dấu · đọc theo người | lát `P2A-11` | `P3A-03` |
| `P4A-11` đào tạo | hướng dẫn gắn việc: ghi · sửa · ẩn · tệp ảnh/video · ghi nhận về người: ghi · sửa · ẩn · đọc | lát `P2A-12` | `P3A-04` |
| `P4A-05` danh mục · combo | danh mục: thêm · đổi tên · ẩn · xếp món · combo: thêm · đổi giá · ẩn · đọc | lát `P2A-13` | `P3A-05` (danh mục) · `P3A-06` (combo vào hàm giá) |
| `P4A-04` sản phẩm | thêm món · sửa thông tin món (sửa giá, thành phần, ngừng bán đã có ở pha 3) | lát menu `P2-05` | `P3A-07` |
| `P4A-09` kho | tổng mua · tổng dùng · hiệu số · nhắc POS khi dưới tỉ lệ | `P2A-02` + `T-186` | `P3A-08` |
| `P4A-02` tổng quan | bảy thứ §8.6 — phần lớn đọc từ cửa đã có; một cửa đọc gom cho chủ quán | mọi lát bán hàng | `P3A-09` |
| `P4A-03` tổng kết | doanh thu theo ngày bán · món bán chạy · cảnh báo sắp hết | mọi lát + `P3A-08` | `P3A-10` |

**Lát đã dựng mà chưa trang nào cần:** chấm công (`P2A-03`), tạm ứng và thưởng (`P2A-04`). Không bước nào ở đây
cho chúng — trang của chúng là việc của sổ FE admin, không phải câu hỏi chủ quán (`work/backlog_FE_AD.md`).

## 3. Ranh giới — kế hoạch này KHÔNG làm gì

- **Không sửa lược đồ.** Cửa cần một cột chưa có ⇒ dừng bước, mở task lược đồ riêng.
- **Không đổi lớp quyền ngoài lời.** Lớp của mỗi cửa đọc từ mệnh đề `I-025`…`I-033` (ai được ghi). Mệnh đề không
  nói ⇒ cửa lấy lớp **hẹp nhất** (`chu_quan`) và một `U-XXX` hỏi chủ quán — hẹp là đường lùi an toàn, không phải
  luật mới.
- **Không làm phần bị chặn** của `master_plan/AD_DB_master_plan_banh_cuon_ba_thanh.md` §6 (lương, nợ nhà cung cấp,
  lãi/lỗ, thuế, tiền mang về, hiệu suất nhân viên chấm điểm).
- **Frontend không cộng tiền** (**ADR-086**): mọi tổng, hiệu số, giá combo là số backend trả.

## 4. Mười bước

| ID | Việc | Cần xong trước | Đầu ra kiểm chứng được | Mức |
|---|---|---|---|:--:|
| **P3A-01** | **Cửa khoản chi** | `T-190` · `U-095` (lớp tạm `chu_quan` tới khi có lời) | ghi · sửa có lý do · đọc theo khoảng ngày, loại, nguồn; test qua PostgreSQL thật; tổng là phép cộng của backend | L2 |
| **P3A-02** | **Cửa sổ nguyên liệu** | `T-190` | ghi dòng ngày, sửa có vết, đọc tổng và hiệu số đúng phép của `I-026`; lớp `chu_quan` (§8.4: chủ quán nhập tay) | L2 |
| **P3A-03** | **Cửa giao việc** | `T-190` | lớp `quay_hoac_chu_quan` (`I-030`); mỗi lần đánh dấu là một sự kiện; ẩn có vết | L2 |
| **P3A-04** | **Cửa đào tạo** | `P3A-03` | lớp `quay_hoac_chu_quan` (`I-031`); tệp đi theo chỗ giữ tệp mà lát `P2A-12` đã chọn | L2 |
| **P3A-05** | **Cửa danh mục món** | `T-190` | lớp `chu_quan` (`I-032`); ẩn chứ không xoá | L1 |
| **P3A-06** | **Combo vào hàm giá** | `P3A-05` | combo một giá chủ quán đặt, đi qua hàm giá duy nhất (`docs/product/3-be/03-ham-gia.md`), ca test mới ở bảng ca | L2 |
| **P3A-07** | **Thêm và sửa thông tin món** | `P3A-05` | món mới vào menu đọc được ở mọi kênh; không trang thứ hai sửa giá | L2 |
| **P3A-08** | **Đọc kho và nhắc POS** | `P3A-02` · `T-186` | tổng · hiệu số · nhắc khi dưới tỉ lệ, số do backend tính | L2 |
| **P3A-09** | **Đọc tổng quan cho chủ quán** | `T-190` | một cửa đọc bảy thứ §8.6; *tạm tính* tách khỏi doanh thu đã đối soát | L2 |
| **P3A-10** | **Đọc tổng kết** | `P3A-08` | doanh thu theo **ngày bán**, món bán chạy (`E48`); vế *hiệu suất nhân viên* ghi *chưa có lời* | L2 |

**Song song:** mọi bước chạm `docs/product/3-be/openapi.yaml`, `02-vai-va-quyen.md` và `apierr` — hai Codex không
chạy hai bước cùng lúc (`docs/prompt-guideline.md` §6.1: scope không chạm chung file). Mỗi bước đưa về clone chính,
chạy gate, rồi bước sau mới dựng worktree.

## 5. Cổng của mỗi bước

1. Test viết trước, đỏ trước code, qua PostgreSQL thật (`scripts/be-check.sh`); tên test mang mã mệnh đề (QC-17).
2. Gate 1f: mỗi cửa ghi đúng một ô; Gate 1g: mỗi cửa một dòng ma trận, một `authz.Door`, hợp đồng tăng phiên bản phụ.
3. Mỗi cửa có ở hợp đồng thì dòng của trang ở §2 thêm tên đường — trang `P4A-XX` mở được khi đủ ba điều của
   `work/backlog_FE_AD.md` *Chung cho cả mười một bước*.
