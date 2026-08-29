# 01 — Actor và kênh bán (L1) · BA-01, BA-02

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §2.1 (người dùng chính), §2.2 (kênh bán).
- Nguồn dữ kiện: `master_plan/shop-facts.md` §2 (bảng 4 kênh), §3 (**5 trạm làm việc có tên**).
- Đích: `docs/product.md` §1 và §2, hiện là chỗ giữ do BA-00 dựng.
- Task: `work/backlog.md` BA-01, BA-02.

## Goal

`docs/product.md` §1 và §2 mô tả được: hệ thống phục vụ những ai, mỗi actor được làm gì,
quán bán qua kênh nào và mỗi kênh khác nhau ở điểm nghiệp vụ nào.

## Scope

Được sửa:
- `docs/product.md` (chỉ §1 và §2)

Không được sửa:
- §3–§8 của `docs/product.md`
- `docs/decisions.md`, `quality/invariants.md`, `docs/architecture.md`
- `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`, `master_plan/shop-facts.md`
- `work/backlog.md` (trừ ô trạng thái của BA-01, BA-02)

Dòng chép vào `work/scope.txt`:
```text
docs/product.md
work/backlog.md
```

## Constraints

- Chỉ mô tả **quyền và trách nhiệm nghiệp vụ**. Không nhắc tới màn hình, role table,
  permission model, hay cách đăng nhập — đó là System Design.
- Bốn kênh bán là Delivery, Pickup, QR tại bàn, Staff POS. Không thêm kênh mới.
- Mỗi kênh phải nói rõ ba điều: có gắn với phiên bàn hay không, ai xác nhận đơn, và khách phải
  cung cấp thông tin định danh gì. Lấy đúng bảng `shop-facts.md` §2:
  delivery/pickup **bắt buộc số điện thoại và không gắn phiên bàn**; qr_table/staff_pos
  **ẩn danh theo bàn và cùng gộp vào một phiên bàn**.
- Nhân viên quán làm việc theo **5 trạm có tên** (`shop-facts.md` §3): quầy · tráng bánh ·
  gấp bánh · lấy canh · dọn bàn. Dùng đúng năm tên này, không tự đặt tên khác, không gộp.
  Chủ quán là vai riêng, ngoài năm trạm.
- Mô tả trạm ở mức **việc quán làm** ("gấp bánh, xếp đĩa, cắt giò"), không phải màn hình hay quyền
  đăng nhập của trạm đó.
- Actor nào cần quyền chưa được kế hoạch gốc nói rõ (ví dụ: ai được hủy đơn) → ghi vào
  Unknowns, **không** tự gán quyền.

## Acceptance

- §1 liệt kê đúng 3 nhóm actor: Khách hàng, Nhân viên quán, Chủ quán; mỗi nhóm có danh sách
  việc họ làm, mỗi việc là một hành động nghiệp vụ quan sát được.
- §1 nêu rõ ranh giới hệ thống: cái gì hệ thống chịu trách nhiệm, cái gì không.
- §1 liệt kê đúng 5 trạm làm việc theo tên ở `shop-facts.md` §3, mỗi trạm có một câu nói trạm đó
  làm gì; không có trạm thứ 6, không thiếu trạm nào.
- §2 có bảng 4 kênh bán; mỗi dòng có: tên kênh, ai khởi tạo đơn, có dùng phiên bàn không,
  ai xác nhận, thông tin định danh khách bắt buộc.
- Đọc §2 biết ngay: hai kênh nào cần số điện thoại, hai kênh nào ẩn danh theo bàn.
- Với mỗi kênh, đọc bảng là biết được đơn từ kênh đó có cần quầy xác nhận trước khi làm hay không.
- Không có câu nào gán quyền mà kế hoạch gốc không nói (mọi quyền suy đoán phải nằm ở Unknowns).
- Người không biết code đọc §1–§2 giải thích được ai dùng hệ thống và bán qua đường nào.

## Verify

```bash
./scripts/gate.sh
grep -n 'Delivery\|Pickup\|QR\|POS' docs/product.md   # đủ 4 kênh
grep -nc 'tráng bánh\|gấp bánh\|lấy canh\|dọn bàn\|quầy' docs/product.md   # đủ 5 trạm
git status --porcelain                                # chỉ file trong Scope
```
Gate 2: với mỗi dòng Acceptance, trỏ tới đoạn văn trong `docs/product.md` chứng minh nó.

## Unknowns

Nếu chưa có câu trả lời, ghi `GIẢ ĐỊNH` + mức rủi ro vào `docs/decisions.md` ở BA-10 (prompt 09),
đừng chốt tại đây:
- Nhân viên có phân vai trong MVP (một người cố định một trạm, hay ai cũng làm được mọi trạm)?
  `shop-facts.md` §3 chỉ nói **có 5 trạm**, không nói ai được làm trạm nào.
- Chủ quán có đồng thời là nhân viên trên hệ thống không?

Đã có lời giải, **không** ghi lại thành Unknown nữa:
- ~~Khách QR có cần định danh không~~ → `shop-facts.md` §2: **ẩn danh theo bàn**; chỉ delivery và
  pickup mới bắt buộc số điện thoại.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
