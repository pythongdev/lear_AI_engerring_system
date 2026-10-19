# Lược đồ lát số người đang làm

Pha 2 (bổ sung) · T-197 · 2026-10-19 · Claude Code, theo ADR-121; test database do Codex viết trước.

**Bản nào thắng:** tên, kiểu và ràng buộc thuộc
[`db/migrations/20261019120000_so_nguoi_dang_lam.up.sql`](../../../db/migrations/20261019120000_so_nguoi_dang_lam.up.sql).
File này giữ ý định. Thứ tự và đường lùi ở [07-thu-tu-migration.md](07-thu-tu-migration.md).

## 1. Mỗi lần POS khai một dòng — `workers_present_declaration`

| Cột | Giữ gì |
|---|---|
| `workers_present_declaration.sale_date` | Ngày bán của lần khai; không duy nhất, một ngày có nhiều lần khai |
| `workers_present_declaration.worker_count` | Số người thực tế đang làm POS khai, nguyên dương |
| `workers_present_declaration.person_id` · `created_at` | Người khai (mặc định `actor_person_id()`, thiếu thì bị từ chối) và lúc khai — mốc database (QD-34), hợp đồng gọi là `declared_at` |

Lời quán: con số là số người thực tế đang làm, POS khai và cập nhật, máy không tự tính
(`master_plan/shop-facts.md` §8.6 hàng 6). *Cập nhật* là thêm một lần khai mới; lịch sử các
lần khai nằm ngay trong bảng. Vai ứng dụng chỉ thêm, không sửa, không xoá; trigger vết vẫn
gắn như mọi bảng (QD-52) để chủ lược đồ có sửa thì để lại ảnh trước/sau.
Số nguyên dương là *suy ra* của phiên: người khai đang đứng quầy nên ít nhất có một người làm.

## 2. Phần cửa giữ

Con số hiện hành của một ngày là lần khai có `created_at` lớn nhất, bằng nhau thì `id` lớn nhất;
ngày chưa có lần khai thì *chưa có*, không lấy số của ngày trước (ADR-121 điểm 4).
Cửa ghi, đường đọc và phép so với `daily_minimum.minimum_workers` do pha 3 sở hữu.

## 3. Đường lùi và bằng chứng

Bước 32 đứng trên bước 8 và 20 (người và vết nghiêm). Chỉ lùi khi bảng rỗng;
có một dòng cũng từ chối trước khi gỡ trigger và bảng. Dữ liệu đã ghi phải đi bằng migration mới.
`db/tests/qd050_workers_present_declaration.sql` kiểm hai lần khai là hai dòng, số ≤ 0 bị từ chối,
thiếu người khai bị từ chối, vai ứng dụng không sửa không xoá, và trigger vết ghi lại một lần sửa.
