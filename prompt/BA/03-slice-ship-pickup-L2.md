# 03 — Lát cắt "một đơn ship/pickup" (L2) · BA-04

> L2 vì đơn ship/pickup là đơn vị thu tiền độc lập; sai luồng là đơn khách không đi hết
> quy trình hoặc thu tiền sai kênh.

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §3 Epic B, §4.2,
  §5 quy tắc 5, 8, 10, 11, §6.
- Nguồn số: `master_plan/shop-facts.md` §1 (giờ bán), §2 (**phí ship 0đ, giờ hẹn pickup, kênh
  `phone_preorder`**), §5 (ranh giới: không có đơn tối thiểu, không có bậc phí ship).
- Nguồn quy tắc: `master_plan/shop-facts.md` §2, §5.2 (**luồng mang đi — sơ đồ đầy đủ**),
  §6.3 (thu tiền lúc trao hàng), §6.5 (thông tin liên hệ), §6.7 (quán tự giao), §6.8 (tạm dừng nhận đơn).
- Đích: `docs/product.md` §3.2.
- Đã chốt trước đó: §1 actor, §2 kênh bán; §3.1 lát cắt tại bàn (dùng để đối chiếu khác biệt).

## Goal

`docs/product.md` §3.2 mô tả trọn đường đi của một đơn ship và một đơn pickup — từ lúc khách
chọn món đến lúc đơn hoàn thành — và nêu rõ nó khác đơn tại bàn ở chỗ nào.

## Scope

Được sửa:
- `docs/product.md` §3.2
- `quality/invariants.md` (chỉ **thêm** invariant phát hiện từ lát cắt này)

Không được sửa:
- §3.1, §3.3, §4–§8 của `docs/product.md`
- `docs/decisions.md`, `docs/architecture.md`

Dòng chép vào `work/scope.txt`:
```text
docs/product.md
quality/invariants.md
work/backlog.md
```

## Constraints

- Giữ quy tắc §5: đơn ship/pickup **không** dùng phiên bàn; mỗi đơn là một đơn vị nghiệp vụ
  độc lập; ngoài giờ bán không nhận đơn; chủ quán có thể tạm dừng nhận đơn bất kể giờ bán.
- Tổng tiền phải được hệ thống xác định lại khi đơn được tạo; khách không tự quyết giá.
- Ship và pickup phải được tách rõ ở bước cuối: pickup chờ khách tới lấy, delivery đóng gói
  và hoàn thành đơn.
- Dữ kiện đã chốt, dùng đúng, **không** ghi lại thành câu hỏi (`shop-facts.md` §1, §2, §6.12):
  - Giờ bán **06:00–11:00, tất cả các ngày**, múi giờ `Asia/Ho_Chi_Minh`.
  - Phí ship **0đ**. Không có **đơn tối thiểu**. Không có bậc phí ship — đây là **chốt**,
    không phải chỗ trống chờ điền.
  - **Pickup có giờ hẹn tới lấy.**
- **Lát cắt này phủ BA kênh không gắn bàn**, không phải hai: `delivery` · `pickup` ·
  **`phone_preorder`** (đặt trước qua hotline `0382688666`, nhân viên nhập hộ — owner chốt
  2026-08-29, `shop-facts.md` §2). Cả ba **không thuộc phiên bàn nào** và mỗi đơn là một đơn vị
  thanh toán độc lập. Bỏ `phone_preorder` là bỏ một phần ba lát cắt.
- **"Tạm dừng nhận đơn" của chủ quán có ưu tiên CAO HƠN giờ mở cửa** (`shop-facts.md` §6.8):
  đang trong giờ bán mà bấm tạm dừng thì vẫn không nhận đơn. Viết rõ thứ tự ưu tiên này,
  đừng để hai quy tắc nằm cạnh nhau mà không nói cái nào thắng.
- Không thiết kế tích hợp đối tác giao hàng, bản đồ, tính phí ship theo khoảng cách nếu kế hoạch
  gốc chưa chốt — ghi Unknowns.
- Tên trạng thái phải trùng bộ tên dùng ở §3.1, sẽ được BA-07 đối chiếu.

## Acceptance

- §3.2 có luồng đủ 9 bước theo §4.2 kế hoạch gốc, mỗi bước ghi rõ actor.
- §3.2 phủ đủ **ba** kênh không gắn bàn, và nói rõ `phone_preorder` khác `staff_pos` ở chỗ nào.
- Có câu khẳng định đơn ship/pickup không gắn phiên bàn và được thanh toán độc lập.
- Nêu rõ thông tin liên hệ tối thiểu khách phải cung cấp cho từng kênh; pickup có thêm giờ hẹn
  tới lấy. Mức tối thiểu **đã chốt** (`shop-facts.md` §6.5): **số điện thoại bắt buộc cả ba kênh**,
  **địa chỉ bắt buộc khi giao tận nơi**, phần còn lại quầy điền theo tình huống thật.
- Có nêu giờ bán cụ thể (06:00–11:00) và phí ship (0đ, không đơn tối thiểu) — không viết chung
  chung kiểu "theo giờ mở cửa của quán".
- Có mô tả hành vi khi ngoài giờ bán: đơn bị từ chối, và khách nhìn thấy điều gì ở mức nghiệp vụ.
- Có mô tả hành vi khi chủ quán tạm dừng nhận đơn trong giờ bán, và câu khẳng định nút tạm dừng
  **thắng** giờ mở cửa.
- Có một đoạn "Khác gì so với đơn tại bàn" liệt kê ít nhất 3 khác biệt nghiệp vụ.
- Có mô tả đường đi của **đơn `phone_preorder`** từ lúc nhân viên nghe máy tới lúc đơn hoàn thành.
- `quality/invariants.md` có invariant: đơn ship/pickup không thuộc phiên bàn nào;
  không tạo được đơn ngoài giờ bán hoặc khi đang tạm dừng nhận đơn.
- Không có nội dung về nhà cung cấp vận chuyển, API bản đồ, hay cách tính phí ship
  (trừ khi đã được trả lời trong Unknowns).

## Verify

```bash
./scripts/gate.sh
grep -n 'pickup\|Pickup\|ship\|Delivery' docs/product.md
grep -nEi 'grab|ahamove|google maps|api|endpoint' docs/product.md   # không có kết quả
git status --porcelain
```
Gate 2: ánh xạ từng dòng Acceptance → bằng chứng trong file.
Gate 5 (L2): đọc lại invariant mới, xác nhận không mâu thuẫn invariant của §3.1.

## Unknowns

- ~~**U-4 · thông tin liên hệ tối thiểu** cho ba kênh không gắn bàn~~ → **đã gỡ 2026-08-30**
  (`shop-facts.md` §6.5). Còn lại là **S-2**: hai trường bắt buộc đó được *suy ra* từ luồng, chưa
  có câu xác nhận riêng của chủ quán (`shop-facts.md` §7.2).
- ~~Đơn `phone_preorder` có giờ hẹn như `pickup` không~~ → **có** (`shop-facts.md` §5.2): nhân
  viên hỏi khách giao tận nơi hay tới lấy, **và cần lúc mấy giờ**.
- ~~Delivery ở MVP chỉ ghi nhận đơn, hay quản lý trạng thái giao hàng~~ → **đã gỡ 2026-08-30**
  (`shop-facts.md` §6.7): quán **tự đi giao**, đơn giao mang trạng thái **"đang giao"**.
- Đơn ship/pickup có được thanh toán trước không, hay chỉ thu khi nhận hàng?
- Giờ hẹn pickup có khung tối thiểu không (đặt trước ít nhất bao lâu), và quá giờ hẹn thì sao?
- Ai giao hàng — nhân viên quán hay bên thứ ba?

Đã có lời giải, **không** ghi lại thành Unknown nữa:
- ~~Đơn đặt trước qua hotline đi kênh nào~~ → `shop-facts.md` §2: kênh riêng **`phone_preorder`**,
  không gắn bàn (owner chốt 2026-08-29).
- ~~Pickup có bắt buộc giờ hẹn không (§10.6)~~ → `shop-facts.md` §2: **có giờ hẹn**.
- ~~Có thu phí ship không, ai quyết mức phí~~ → `shop-facts.md` §2 và §6.12: **0đ**, không đơn tối
  thiểu, không bậc phí — và đây là ranh giới đã chốt, không phải chỗ trống.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
