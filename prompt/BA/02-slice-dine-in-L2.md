# 02 — Lát cắt "một suất tại bàn" (L2) · BA-03

> L2 vì lát cắt này quyết định cách tính tiền một phiên bàn và cách bàn được giải phóng.
> Sai ở đây là thu thiếu tiền hoặc bàn kẹt — sai âm thầm, phát hiện muộn.

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §3 Epic A, §4.1 (15 bước),
  §4.3 (đặt hộ tại quầy), §5 quy tắc 1, 2, 3, 4, 9.
- Nguồn số: `master_plan/shop-facts.md` §4.5 (**thành phần một suất bán** — cơ sở của việc nổ),
  §2 (chỉ `qr_table` và `staff_pos` gắn phiên bàn).
- Nguồn quy tắc: `master_plan/shop-facts.md` §3 (5 trạm), §5.1 (sơ đồ luồng tại bàn),
  **§5.1 (nổ việc xuống bếp)**, **§6.1 (gọi thêm khi đang thu tiền)**.
- Đích: `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.1.
- Đã chốt trước đó: §1 actor, §2 kênh bán (BA-01, BA-02).

## Goal

`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.1 mô tả trọn vòng đời một khách ăn tại quán — từ lúc bàn được mở đến lúc
bàn trở lại trạng thái trống — đủ để một người không biết code diễn lại được bằng nghiệp vụ.

## Scope

Được sửa:
- `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.1
- `quality/invariants.md` (chỉ **thêm** invariant phát hiện từ lát cắt này)

Không được sửa:
- §3.2, §3.3, §4–§8 của `docs/product/0-ba/ban-hang/`
- `docs/decisions.md`, `docs/product/1-system-design/architecture.md`
- Invariant đã tồn tại của người khác trong `quality/invariants.md`

Dòng chép vào `work/scope.txt`:
```text
docs/product/
quality/invariants.md
work/backlog.md
```

## Constraints

- Giữ đúng các quy tắc §5 kế hoạch gốc, không diễn giải lại thành quy tắc khác:
  - Một bàn chỉ có một phiên chưa thanh toán.
  - Nhiều lần gọi món tại cùng bàn thuộc cùng một phiên.
  - Tính tiền trên toàn bộ phiên bàn, không tách nhiều hóa đơn.
  - Đơn QR phải được quầy xác nhận trước khi thực hiện.
  - Bàn chỉ trở thành trống sau khi phiên đóng **và** bàn được dọn.
- **Khách gọi thêm sau khi quầy đã bắt đầu thu tiền vẫn thuộc CÙNG phiên, CÙNG một hoá đơn**
  (`shop-facts.md` §6.1). Phiên đang "chờ thanh toán" **chưa** giải phóng bàn. Đây là quy tắc đã
  chốt, **không** phải câu hỏi mở — tách thành hoá đơn thứ hai là **thu thiếu tiền**.
- Một đơn được quầy duyệt sẽ sinh việc ở **nhiều trạm cùng lúc** (tráng bánh · gấp bánh · lấy canh),
  không phải một hàng đợi tuần tự. Dùng đúng tên trạm ở `shop-facts.md` §3.
- **Việc xuống bếp phải nổ ra thành phần**, không được là một dòng "Combo ×2" mơ hồ
  (`shop-facts.md` §5.3). Bốn hệ quả nghiệp vụ phải viết ra:
  số lượng thành phần = số suất × số thành phần trong suất (`shop-facts.md` §4.5);
  **mọi suất bán đều kèm bánh cuốn**, không riêng combo — một suất trứng là 1 trứng + 4 bánh,
  một suất giò là 1 giò + 4 bánh, nên "gọi 1 suất trứng" bếp làm **5 thứ**;
  thành phần **không nhận nhân** (giò) thì không kèm mô tả nhân;
  **nước chấm là việc cấp ĐƠN**, mọi đơn tại bàn đều có một việc cho trạm lấy canh.
- Khách nhìn hoá đơn theo **suất bán**, bếp nhìn theo **thành phần**. Hai cách nhìn cùng một đơn —
  nói rõ điều này, đừng để người đọc tự suy.
- Mỗi bước phải ghi rõ **ai** thực hiện (dùng đúng actor ở §1).
- Tên trạng thái dùng trong luồng phải nhất quán, sẽ được BA-07 đối chiếu với vòng đời §5.
  Không đặt hai tên khác nhau cho cùng một trạng thái.
- Không mô tả cách hệ thống hiện thực (realtime, socket, hàng đợi, bảng dữ liệu).
- Invariant thêm mới phải viết theo template `quality/invariants.md`: Invariant / Why / Verification.

## Acceptance

- §3.1 có luồng chính đủ 15 bước theo §4.1 kế hoạch gốc, mỗi bước ghi rõ actor thực hiện.
- Có mô tả nhánh "đặt hộ tại quầy" (§4.3) và nói rõ nó nhập vào cùng phiên bàn nào.
- Có câu khẳng định: nhiều lượt gọi món tại một bàn tạo **một** lần thanh toán, không phải nhiều.
- Có câu khẳng định điều kiện để bàn trở lại trạng thái trống, và điều kiện đó gồm cả bước dọn bàn.
- Có nêu điểm mà đơn QR bị chặn nếu quầy chưa xác nhận.
- Có câu khẳng định: khách gọi thêm khi phiên đang chờ thanh toán vẫn vào **cùng một hoá đơn**,
  và nói rõ bàn chưa được coi là trống ở thời điểm đó.
- Có mô tả một đơn duyệt xong sinh việc ở những trạm nào, dùng đúng 5 tên trạm.
- Có ví dụ nổ thành phần (dùng lại ví dụ 2 suất "Đầy đủ" ở `shop-facts.md` §5.3), cho thấy
  số lượng bếp thấy khác số lượng trên hoá đơn.
- Có câu khẳng định **mọi suất bán đều kèm bánh cuốn**, không chỉ combo — nếu §3.1 chỉ nói tới
  combo thì chưa đạt.
- `quality/invariants.md` có ít nhất các invariant: một bàn một phiên chưa thanh toán
  (**tính cả lúc đang chờ thanh toán**); tính tiền theo phiên chứ không theo từng lượt gọi;
  bàn trống chỉ sau khi đóng phiên và dọn bàn; đơn đã duyệt sinh **đủ** việc cho mọi trạm liên quan.
- Mỗi invariant mới có mục Verification viết được cách kiểm, không để trống.
- Không có từ ngữ kỹ thuật hiện thực (websocket, queue, bảng, endpoint) trong §3.1.

## Verify

```bash
./scripts/gate.sh
grep -nEi 'websocket|socket|queue|endpoint|schema|table' docs/product.md   # không có kết quả
grep -n '^### I-' quality/invariants.md                                    # invariant mới có ID
git status --porcelain
```
Gate 2: ánh xạ từng dòng Acceptance → đoạn văn/ID invariant chứng minh nó.
Gate 5 (L2): đọc lại toàn bộ `quality/invariants.md`, xác nhận invariant mới không mâu thuẫn cái cũ.

## Unknowns

Chưa có lời giải thì ghi `GIẢ ĐỊNH` + rủi ro, hỏi người trước khi chốt:
- Có cho phép tách/gộp bàn không? (Nếu không, ghi rõ là ngoài MVP.)
- Ai được đóng phiên bàn khi khách đã rời đi mà chưa thanh toán?
- Một nhân viên có làm được nhiều trạm cùng lúc không, hay mỗi người một trạm?

Đã có lời giải, **không** ghi lại thành Unknown nữa:
- ~~Khách gọi thêm sau khi quầy bắt đầu thu tiền~~ → `shop-facts.md` §6.1: **cùng phiên, cùng hoá
  đơn**. Đã chuyển thành Constraint ở trên.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
