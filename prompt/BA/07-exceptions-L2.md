# 07 — Ngoại lệ nghiệp vụ (L2) · BA-08

> L2 vì phần lớn ngoại lệ trong danh sách đều chạm tiền hoặc trạng thái đơn. Đây cũng là phần
> dễ bị AI tự chế cách xử lý nhất — mỗi cách xử lý là một quyết định kinh doanh của chủ quán.

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §8 (14 tình huống),
  §5 quy tắc 4, 7, 10, 11, 12.
- Nguồn dữ kiện: `master_plan/shop-facts.md` §6.1 (gọi thêm khi đang thu tiền),
  §6.3 (tạm dừng nhận đơn thắng giờ bán), **§6.6 (sổ giấy là phương án dự phòng bắt buộc)**.
- Đích: `docs/product.md` §6.
- Đã chốt trước đó: §3 các luồng, §4 tiền, §5 vòng đời — cách xử lý ngoại lệ phải trỏ về
  trạng thái có thật trong §5.

## Goal

`docs/product.md` §6 chốt cách quán xử lý từng tình huống ngoại lệ quan trọng, ở mức nghiệp vụ,
đủ để nhân viên biết phải làm gì mà không cần hỏi chủ quán.

## Scope

Được sửa:
- `docs/product.md` §6
- `docs/decisions.md` (ghi `GIẢ ĐỊNH` cho ngoại lệ chưa có lời giải)
- `work/findings.md` (nếu phát hiện mâu thuẫn giữa các quy tắc đã chốt)

Không được sửa:
- §1–§5, §7–§8 của `docs/product.md`
- `quality/invariants.md` (BA-08 chỉ mô tả cách xử lý, không thêm bất biến mới)
- `docs/architecture.md`

Dòng chép vào `work/scope.txt`:
```text
docs/product.md
docs/decisions.md
work/findings.md
work/backlog.md
```

## Constraints

- **Không tự quyết định cách quán xử lý.** Mỗi tình huống chỉ có hai kết cục hợp lệ:
  (a) cách xử lý đã có trong nguồn hoặc do người trả lời → ghi thành quy tắc;
  (b) chưa có → ghi `GIẢ ĐỊNH` + mức rủi ro (cao/trung bình/thấp) vào `docs/decisions.md`
  và đánh dấu trong §6 là chưa chốt.
- Mỗi cách xử lý phải nói được: ai xử lý, đơn/phiên chuyển sang trạng thái nào trong §5,
  tiền được xử lý ra sao.
- Trạng thái nhắc tới phải tồn tại trong §5. Không đẻ trạng thái mới ở đây; nếu thật sự cần
  trạng thái mới → ghi finding, quay lại BA-07.
- Nhóm "mất mạng / mất điện / POS hỏng" chỉ chốt **quán làm gì bằng tay**, không thiết kế
  cơ chế dự phòng kỹ thuật. Câu trả lời đã chốt: **chuyển sang ghi sổ giấy, không dừng bán**
  (`shop-facts.md` §6.11). Phần còn phải chốt là *ai giữ sổ, ghi những gì, nhập lại vào hệ thống
  lúc nào* — cái này chưa có, ghi Unknowns.
- Ba tình huống đã có lời giải, **dùng luôn, không ghi thành `Chưa chốt`**:
  - *Khách gọi thêm sau khi quầy bắt đầu thu tiền* → vào **cùng phiên, cùng hoá đơn**
    (`shop-facts.md` §6.1, đã chốt ở BA-03).
  - *Chủ quán tạm dừng nhận đơn* → **thắng giờ mở cửa**, kể cả đang trong giờ bán (§6.3).
  - *Mất mạng / mất điện / POS hỏng* → **sổ giấy**, quán vẫn bán (§6.6).
- Tình huống *"món hết sau khi khách đã chọn"* phải nói rõ nó xảy ra ở **mức thành phần**:
  **mọi suất bán đều gồm nhiều thành phần** (`shop-facts.md` §4.5 — kể cả suất trứng và suất giò
  đều kèm 4 cái bánh), hết **một** thành phần thì xử lý thế nào với cả suất — nếu chưa có lời giải
  thì đây là `GIẢ ĐỊNH`, không tự chốt.
- **Hết bánh cuốn là hết gần như mọi món**, vì mọi suất đều kèm bánh. Ghi rõ hệ quả này, đừng để
  "món hết" trông như chuyện của một dòng menu.
- Không bỏ sót tình huống nào trong danh sách 14 mục.

## Acceptance

- §6 có bảng phủ đủ 14 tình huống ở §8 kế hoạch gốc, không thiếu dòng nào.
- Mỗi dòng có đủ 4 cột: tình huống, ai xử lý, kết quả với đơn/phiên (trạng thái trong §5),
  kết quả với tiền.
- Mọi tên trạng thái trong §6 đều tìm được trong §5.
- Tình huống chưa chốt được đánh dấu rõ ràng (ví dụ `⚠ Chưa chốt — xem docs/decisions.md`),
  không có dòng nào bị bỏ trống lặng lẽ.
- Ba tình huống có lời giải sẵn (gọi thêm khi đang thu tiền · tạm dừng nhận đơn ·
  mất mạng/mất điện/POS hỏng) **không** bị đánh dấu `Chưa chốt`.
- Mỗi tình huống chưa chốt có một mục tương ứng trong `docs/decisions.md` với mức rủi ro.
- Không có dòng nào mô tả cách hệ thống kỹ thuật xử lý (retry, hàng đợi, offline cache).
- Nếu phát hiện hai quy tắc đã chốt mâu thuẫn nhau, có finding trong `work/findings.md`.

## Verify

```bash
./scripts/gate.sh
awk '/^## §6/,/^## §7/' docs/product.md | grep -c '^|'   # bảng §6: 14 dòng dữ liệu + 2 dòng đầu bảng
grep -n 'Chưa chốt' docs/product.md docs/decisions.md
grep -nEi 'retry|cache|offline sync|hàng đợi|queue' docs/product.md   # không có kết quả
git status --porcelain
```
Gate 2: đếm tay 14 tình huống, đối chiếu từng dòng với §8 kế hoạch gốc.
Gate 5 (L2): với 3 tình huống chạm tiền nhất (thanh toán thất bại, khách rời bàn chưa trả,
đơn hoàn thành cần điều chỉnh), kiểm tra cách xử lý không phá invariant nào trong
`quality/invariants.md`.

## Unknowns

Đây là prompt có nhiều unknown nhất. Hỏi người trước, đừng đoán:
- Món hết sau khi khách đã đặt: thay thế, hủy phần đó, hay hủy cả đơn? (§10.3)
  Và nếu chỉ hết **một thành phần** của combo thì sao?
- Mất điện: ai giữ sổ giấy, ghi những trường gì, nhập lại vào hệ thống lúc nào và ai nhập?
- Khách không thanh toán được thì phiên bàn giữ ở trạng thái nào? (§10.4)
- Đơn đã hoàn thành cần điều chỉnh: sửa đơn hay tạo đơn bù?
- Hai người cùng thao tác trên một bàn: ai thắng?

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết (liệt kê rõ các tình huống còn `Chưa chốt`)
