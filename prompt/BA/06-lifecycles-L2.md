# 06 — Vòng đời đơn, phiên bàn, công việc trạm (L2) · BA-07

> L2 vì vòng đời quyết định chuyển trạng thái nào hợp lệ. Sai ở đây là đơn kẹt hoặc bàn kẹt
> giữa giờ cao điểm, và lỗi chỉ lộ ra khi đang phục vụ khách.

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §7 (ba vòng đời),
  §5 quy tắc 1, 4, 9, 12.
- Nguồn dữ kiện: `master_plan/shop-facts.md` §3 (5 trạm), §5.3 (một đơn nổ thành nhiều việc),
  **§6.1 (phiên ở "Chờ thanh toán" vẫn nhận đơn mới)**.
- Đích: `docs/product.md` §5.
- Đã chốt trước đó: §3.1–§3.3 (các luồng đã dùng một số tên trạng thái), §4 (thanh toán).

## Goal

`docs/product.md` §5 định nghĩa ba vòng đời nghiệp vụ — đơn, phiên bàn, công việc trạm — với đầy
đủ trạng thái, chuyển tiếp hợp lệ, ai kích hoạt mỗi chuyển tiếp, và trạng thái kết thúc.

## Scope

Được sửa:
- `docs/product.md` §5
- `docs/product.md` §3.1–§3.3 **chỉ khi** phải sửa tên trạng thái cho khớp §5 (đổi tên, không đổi nghĩa)
- `quality/invariants.md` (thêm invariant về chuyển trạng thái)

Không được sửa:
- §1, §2, §4, §6–§8 của `docs/product.md`
- Nội dung nghiệp vụ của §3 (chỉ được đồng bộ tên trạng thái)
- `docs/decisions.md`, `docs/architecture.md`

Dòng chép vào `work/scope.txt`:
```text
docs/product.md
quality/invariants.md
work/backlog.md
```

## Constraints

- Giữ đúng ba vòng đời gốc, không đổi số trạng thái nếu không có lý do ghi rõ:
  - Đơn: `Mới → Chờ xác nhận → Đã xác nhận → Đang thực hiện → Hoàn thành`, nhánh `→ Hủy`.
  - Phiên bàn: `Mở → Đang phục vụ → Chờ thanh toán → Đã đóng → Bàn cần dọn → Trống`.
  - Công việc trạm: `Chưa làm → Đang làm → Hoàn thành`.
- Mọi chuyển tiếp không có trong bảng phải bị coi là **không hợp lệ và bị từ chối** — viết
  câu này ra, đừng để ngầm hiểu.
- **`Chờ thanh toán` KHÔNG phải trạng thái khoá.** Phiên ở `Chờ thanh toán` vẫn nhận thêm đơn mới
  vào **cùng phiên** (`shop-facts.md` §6.1); bảng chuyển trạng thái phải có dòng
  `Chờ thanh toán → Đang phục vụ` (hoặc tương đương) cho tình huống khách gọi thêm.
  Thiếu dòng này là **thu thiếu tiền**, không phải thiếu tài liệu.
- Bàn chỉ rời khỏi "một phiên chưa thanh toán" khi phiên **Đã đóng**. `Chờ thanh toán` vẫn tính là
  phiên chưa thanh toán — nói rõ trong §5, vì đây là chỗ dễ hiểu nhầm nhất.
- **Một đơn sinh nhiều công việc trạm** (`shop-facts.md` §5.3), mỗi việc có vòng đời riêng và
  chạy song song. Nói rõ đơn vị của vòng đời "công việc trạm" là **một việc ở một trạm**,
  không phải cả đơn.
- Từ trạng thái nào được hủy đơn, và ai được hủy: nếu kế hoạch gốc chưa chốt → Unknowns,
  không tự gán.
- Đây là vòng đời **nghiệp vụ**. Không đặt tên trạng thái kiểu enum kỹ thuật, không mô tả
  state machine trong code.
- Nếu §3 đang dùng tên trạng thái khác §5, sửa §3 cho khớp và ghi rõ đã đổi những gì trong Report.

## Acceptance

- §5 có ba bảng chuyển trạng thái; mỗi dòng gồm: trạng thái nguồn, sự kiện, trạng thái đích,
  ai kích hoạt.
- Mỗi vòng đời nêu rõ trạng thái bắt đầu và (các) trạng thái kết thúc.
- Có câu khẳng định: chuyển tiếp không nằm trong bảng bị từ chối.
- Nêu rõ quan hệ giữa ba vòng đời: phiên bàn chỉ vào `Chờ thanh toán` khi các đơn của nó ở
  trạng thái nào; đơn chỉ `Hoàn thành` khi công việc trạm ở trạng thái nào.
- Mọi tên trạng thái xuất hiện trong §3.1–§3.3 đều có mặt trong §5 (không còn tên lạc).
- Có mô tả điều kiện chuyển `Bàn cần dọn → Trống` và ai xác nhận đã dọn (trạm `dọn bàn`).
- Bảng phiên bàn có đường quay lại từ `Chờ thanh toán` khi khách gọi thêm, và có câu khẳng định
  `Chờ thanh toán` vẫn là phiên **chưa thanh toán**.
- §5 nói rõ vòng đời "công việc trạm" áp cho **một việc ở một trạm**, và một đơn có nhiều việc
  chạy song song ở các trạm khác nhau.
- `quality/invariants.md` có invariant: chuyển trạng thái không hợp lệ bị từ chối;
  phiên bàn không thể `Đã đóng` khi còn đơn chưa hoàn thành hoặc chưa hủy.
- Không có tên trạng thái viết kiểu mã (`ORDER_PENDING`, `status=2`).

## Verify

```bash
./scripts/gate.sh
grep -nE '[A-Z_]{4,}|status *=' docs/product.md    # không có trạng thái kiểu mã
grep -n 'Chờ xác nhận\|Chờ thanh toán\|Bàn cần dọn' docs/product.md
grep -n 'Chờ thanh toán →' docs/product.md     # phải có đường quay lại khi khách gọi thêm
git status --porcelain
```
Gate 2: ánh xạ từng dòng Acceptance → bằng chứng.
Gate 5 (L2): tự tay dò một lượt — lấy từng tên trạng thái trong §3, tìm nó trong bảng §5;
không tìm thấy dòng nào = chưa đạt.

## Unknowns

- Đơn đã xác nhận có được sửa không, hay chỉ được hủy rồi tạo lại? (§10.2)
- Ai có quyền hủy đơn ở từng trạng thái? (§10.1)
- Có trạng thái "tạm dừng" cho công việc trạm khi hết nguyên liệu không?
- Một việc ở trạm có được **hoàn tác** sau khi bấm xong không, và trong bao lâu?
- Đơn đã hoàn thành nhưng cần điều chỉnh thì đi về trạng thái nào? (liên quan BA-08)

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì (ghi rõ nếu có đổi tên trạng thái ở §3)
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
