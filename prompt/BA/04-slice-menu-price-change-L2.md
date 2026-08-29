# 04 — Lát cắt "chủ quán đổi menu/giá" (L2) · BA-05

> L2 vì đây là lát cắt chạm trực tiếp vào tiền và dữ liệu lịch sử. Sai ở đây là sai đơn cũ,
> và sai âm thầm: không có lỗi nào nổ ra, chỉ có số tiền lịch sử bị đổi.

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §3 Epic C, §5 quy tắc 5, 6, 7,
  §6 (Giá).
- Nguồn dữ kiện: `master_plan/shop-facts.md` §4 (cấu trúc giá: giá gốc là **giá chay**, nhân là
  **phụ thu**), §4.1 (tổ hợp hợp lệ / không hợp lệ).
- Đích: `docs/product.md` §3.3.
- Đã chốt trước đó: §3.1, §3.2 — hai lát cắt tạo ra đơn mà lát cắt này không được phép đụng vào.

## Goal

`docs/product.md` §3.3 chốt nguyên tắc lịch sử đơn hàng: đơn mới dùng menu/giá mới, đơn cũ giữ
nguyên tên món và giá tại thời điểm đặt, kể cả khi món bị ngừng bán.

## Scope

Được sửa:
- `docs/product.md` §3.3
- `quality/invariants.md` (thêm invariant về bất biến lịch sử đơn)

Không được sửa:
- §3.1, §3.2, §4–§8 của `docs/product.md`
- `docs/decisions.md`, `docs/architecture.md`

Dòng chép vào `work/scope.txt`:
```text
docs/product.md
quality/invariants.md
work/backlog.md
```

## Constraints

- Giữ quy tắc §5.5 và §5.6: giá xác định tại thời điểm đặt hàng; thay đổi menu/giá không làm
  thay đổi đơn cũ.
- Giữ quy tắc §5.7: tổ hợp món/option không hợp lệ phải bị từ chối.
- **Giá một suất gồm hai phần** (`shop-facts.md` §4): giá gốc của món (= giá **chay**) và
  **phụ thu theo tuỳ chọn** (lượng nhân). ⇒ "đổi giá" có **hai chiều** phải phủ cả hai:
  đổi giá gốc của món, và đổi mức phụ thu của một tuỳ chọn. Bỏ chiều thứ hai là bỏ nửa lát cắt.
- Tổ hợp không hợp lệ đã có ví dụ chốt sẵn để bám: **Chay + Nhiều nhân phải bị TỪ CHỐI**, không
  âm thầm bỏ qua tuỳ chọn thừa — bếp nhận phiếu mâu thuẫn là hỏng món (`shop-facts.md` §4.1 ca 11).
  Nguyên nhân nghiệp vụ: nhóm "Lượng nhân" chỉ tồn tại khi nhân **khác Chay**.
- **Không viết con số giá nào vào §3.3.** Bảng giá thật chưa có (`shop-facts.md` §8 U-1);
  lát cắt này chốt **hành vi khi giá đổi**, không chốt giá.
- Không mô tả cách lưu trữ (snapshot, versioning, bảng lịch sử). Chỉ chốt **kết quả nghiệp vụ
  phải luôn đúng**; cách làm là việc của System Design.
- Phải xử lý cả hai chiều: đổi giá, và ngừng bán/xoá món.
- Phải nói rõ điều gì xảy ra với đơn **đang dở** (đã gửi, chưa hoàn thành) tại thời điểm đổi giá —
  nếu kế hoạch gốc không nói, ghi Unknowns, không tự chốt.

## Acceptance

- §3.3 mô tả luồng trước/sau khi chủ quán đổi giá, nêu rõ thời điểm giá mới bắt đầu có hiệu lực.
- Có câu khẳng định: đơn đã đặt trước thời điểm đổi giá giữ nguyên tổng tiền.
- Có câu khẳng định: món đã ngừng bán không xuất hiện trong menu mới nhưng vẫn hiển thị đúng
  tên và giá trong đơn cũ.
- Có mô tả hành vi khi tổ hợp món/option không hợp lệ: đơn bị từ chối, không tự sửa thành hợp lệ;
  có nêu đích danh ví dụ Chay + Nhiều nhân.
- §3.3 phủ **cả hai chiều đổi giá**: đổi giá gốc của món, và đổi mức phụ thu của một tuỳ chọn.
- Không có con số giá cụ thể nào trong §3.3.
- Có nêu rõ trạng thái của đơn đang dở khi giá đổi (hoặc ghi là Unknown nếu chưa chốt được).
- `quality/invariants.md` có invariant: đơn đã tạo không đổi giá và tên món khi menu đổi;
  và invariant: tổ hợp món/option không hợp lệ bị từ chối.
- Invariant về lịch sử đơn có mục Verification mô tả được kịch bản kiểm: đổi giá món → mở đơn cũ
  → tổng tiền không đổi.
- Không có nội dung mô tả cách lưu dữ liệu (bảng, cột, version, snapshot kỹ thuật).

## Verify

```bash
./scripts/gate.sh
grep -nEi 'bảng|cột|column|version|migration|schema' docs/product.md   # không có kết quả
grep -n '^### I-' quality/invariants.md
git status --porcelain
```
Gate 2: ánh xạ từng dòng Acceptance → bằng chứng.
Gate 5 (L2): kiểm tra invariant lịch sử đơn không mâu thuẫn với cách tính tiền theo phiên ở §3.1.

## Unknowns

- Chủ quán có được đổi giá ngay lập tức trong giờ bán không? (§10.9)
- Đơn đã xác nhận nhưng chưa hoàn thành: áp giá cũ hay phải xác nhận lại?
- Đổi **thành phần** của một suất bán (combo đang là 3 bánh + 1 trứng + 1 giò) có phải là "đổi
  menu" không, và đơn cũ hiển thị theo thành phần cũ hay mới? (`shop-facts.md` §4.2)
- Món hết sau khi khách đã chọn thì quán xử lý thay thế hay hủy? (§10.3 — sẽ chốt ở BA-08)

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
