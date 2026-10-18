# Lược đồ lát số tối thiểu của ngày

Pha 2 (bổ sung) · T-199 · 2026-10-18 · Codex thi công theo phiếu Claude,
ADR-118 điểm 1 do Claude cung cấp trong phiếu; ADR chưa có trong worktree.

**Bản nào thắng:** tên, kiểu và ràng buộc thuộc
[`db/migrations/20261018120000_so_toi_thieu.up.sql`](../../../db/migrations/20261018120000_so_toi_thieu.up.sql).
File này giữ ý định. Thứ tự và đường lùi ở [07-thu-tu-migration.md](07-thu-tu-migration.md).

## 1. Hai số cho đúng một ngày — `daily_minimum`

| Cột | Giữ gì |
|---|---|
| `daily_minimum.sale_date` | Ngày bán chủ quán chọn, duy nhất theo ngày; không kế thừa ngày trước |
| `daily_minimum.minimum_banh` · `minimum_workers` | Hai số nguyên dương, nhập cùng một lần |
| `daily_minimum.person_id` · `created_at` | Người tạo và lúc tạo; người sửa, lúc sửa nằm trong vết |

Bảng có khoá chính riêng để `record_revision_capture` ghi được dòng đích như các lát trước.
Vai ứng dụng chỉ sửa hai số, không sửa ngày, người tạo hay lúc tạo, không xoá.
Mỗi lần sửa thay giá trị để lại ảnh trước/sau qua trigger nghiêm (I-018, QD-52).
Cửa dùng lý do mã `tongquan/dat_toi_thieu`; gửi lại cùng hai số không sinh vết giả.

## 2. Phần cửa giữ

Cửa chủ quán ghi cả hai số nguyên tử cho ngày được chọn; hợp đồng và quyền do pha 3 sở hữu.
Chưa có dòng cho ngày đọc thì tiến độ trả `daily_minimum_missing`; thiếu số người thực tế
vẫn trả `workers_present_missing`, kèm `minimum_workers` nếu đã có dòng của ngày.
Không tự tạo giá trị mặc định và không triển khai chỗ cất số người của T-197.

## 3. Đường lùi và bằng chứng

Bước 31 đứng trên bước 8 và 20 (người và vết nghiêm). Chỉ lùi khi bảng rỗng;
có một dòng cũng từ chối trước khi gỡ trigger và bảng. Dữ liệu đã ghi phải đi bằng migration mới.
`db/tests/i018_daily_minimum_revision.sql` kiểm duy nhất theo ngày, hai số dương, sửa có vết,
không sửa ngày và không xoá bằng vai ứng dụng.
