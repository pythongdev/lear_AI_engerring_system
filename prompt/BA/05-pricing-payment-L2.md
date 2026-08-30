# 05 — Quy tắc giá và thanh toán (L2) · BA-06

> L2 vì đây là mục chạm tiền trực tiếp. Theo `docs/prompt-guideline.md` §1, chạm tiền là L2+
> kể cả khi "chỉ viết một dòng quy tắc".

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §6 (Giá, Thanh toán),
  §5 quy tắc 3, 5, 6, 12.
- Nguồn số: `master_plan/shop-facts.md` §1 (2 phương thức, VietQR **tĩnh**),
  **§4.1 công thức · §4.2 giá thành phần · §4.3 giá một suất · §4.4 phụ thu ·
  §4.5 thành phần suất bán** — bảng giá nay **đã đầy, không còn ô nào treo**.
- Nguồn quy tắc: `master_plan/shop-facts.md` §4.6 (chín quy tắc cấu tạo giá),
  **§4.7 (bằng chứng mô hình tổng thành phần)**, §4.8 (11 tổ hợp), §6.3 (thu tiền lúc trao hàng),
  §6.4 (hoàn tiền — quầy quyết từng ca), §6.9 (doanh thu hai nguồn), §6.10 (đối soát cuối ngày).
- Đích: `docs/product.md` §4.
- Đã chốt trước đó: §3.1 (tính tiền theo phiên bàn), §3.2 (đơn ship/pickup độc lập),
  §3.3 (bất biến lịch sử giá).

## Goal

`docs/product.md` §4 chốt được toàn bộ quy tắc nghiệp vụ về giá và thu tiền: giá từ đâu ra,
tổng tiền xác định lúc nào, thu bằng cách nào, và đối soát dựa trên cái gì.

## Scope

Được sửa:
- `docs/product.md` §4
- `quality/invariants.md` (thêm invariant về tiền)

Không được sửa:
- §1–§3, §5–§8 của `docs/product.md`
- `docs/decisions.md`, `docs/architecture.md`

Dòng chép vào `work/scope.txt`:
```text
docs/product.md
quality/invariants.md
work/backlog.md
```

## Constraints

- Giữ nguyên các quy tắc đã chốt, trích đích danh:
  - Giá bán xác định từ menu và lựa chọn của khách; khách không tự quyết định giá.
  - Tổng tiền được xác định lại khi đơn được tạo.
  - Đơn cũ giữ nguyên giá đã áp dụng (invariant từ BA-05).
  - Ăn tại bàn: nhiều đơn → một phiên → một lần thanh toán.
  - Ship/pickup: mỗi đơn là một đơn vị thanh toán độc lập.
  - Mọi thao tác ảnh hưởng đến tiền phải kiểm chứng lại được.
- **Luật gốc của giá là "giá một SUẤT = TỔNG giá các THÀNH PHẦN của suất"**
  (`shop-facts.md` §4.2–§4.3 + §4.5). Viết câu này ra đầu §4 — mọi luật khác là hệ quả của nó.
- ⚠️ **Phân biệt hai bảng ở `shop-facts.md` §4.2–§4.3**: bảng trên là giá **thành phần**
  (1 cái bánh · 1 quả trứng · 1 chiếc giò), bảng dưới là giá **một suất bán**. Đọc nhầm bảng
  thành phần thành bảng suất là **thu thiếu tiền** — ví dụ suất giò là **25.000**, không phải
  9.000. Nói rõ khác biệt này trong §4.
- Kèm các quy tắc ở `shop-facts.md` §4.6: giá gốc thành phần = **giá chay** · loại nhân **không**
  đổi giá · **phụ thu +1.000 cho MỖI phần nhận nhân** (suất bánh cuốn ×1, suất giò ×4, combo ×4 —
  là hệ quả, không phải ba con số rời) · **giò không nhận nhân nhưng 4 cái bánh trong suất giò thì
  có** · nhóm "Lượng nhân" chỉ tồn tại khi nhân ≠ Chay ⇒ **Chay + Nhiều nhân bị TỪ CHỐI** ·
  mặc định là **nhân Thịt, lượng Thường** · khách không bao giờ gửi giá lên.
- **Không chép bảng giá `shop-facts.md` §4.2–§4.3 vào `docs/product.md`.** §4 trỏ tới nó và chốt
  **quy tắc**; bảng giá có đúng một nhà. Chép là tạo chỗ sẽ trôi.
- **11 tổ hợp ở `shop-facts.md` §4.8 là hợp đồng với chủ quán.** Chép danh sách **tổ hợp đầu vào**
  vào §4 làm bảng ca phải phủ, cột giá kỳ vọng ghi "tra `shop-facts.md` §4.2–§4.3".
- ✅ **U-1 đã gỡ, task này không còn bị chặn** (`shop-facts.md` §4.3, chủ quán chốt 2026-08-30):
  suất trứng = giá trứng + tiền 4 cái bánh, phụ thu **×5**. Giá tra ở §4.3, không chép vào prompt.
  Giá suất trứng **và** cách tính phụ thu đều đã chốt: chủ quán xác nhận 2026-08-30 rằng quả
  trứng cũng lên giá theo nhân ⇒ **×5**, suất trứng nhân thường **25.000** (`shop-facts.md` §7.1,
  §4.3, §4.6 luật 5). Viết theo ×5 và **không** đánh dấu là suy luận nữa; câu hỏi kiểm chứng cũ
  Report: *"Suất trứng nhân thường là 25.000 hay 24.000?"*
- Phương thức thanh toán ở MVP chỉ có: tiền mặt, VietQR tĩnh. Không thêm cổng thanh toán,
  ví điện tử, thẻ — kể cả dạng "chuẩn bị cho sau này".
- **Doanh thu một ngày phải cộng từ HAI nguồn**: phiên bàn (dine-in) và đơn lẻ (ship/pickup).
  Một khoản tiền thuộc **đúng một** trong hai, không bao giờ cả hai (`shop-facts.md` §6.9).
  Báo cáo bỏ sót một nguồn là báo cáo thiếu.
- **Đối soát cuối ngày đã chốt** (`shop-facts.md` §6.10): mỗi tối đối chiếu doanh thu hệ thống với
  **sổ giấy** và **tiền trong két**; **lệch 1 đồng cũng phải tìm ra lý do**. Viết ra như một quy
  trình của quán, không viết như một tính năng phần mềm.
- VietQR **tĩnh** nghĩa là hệ thống không tự biết tiền đã về. Phải chốt rõ ai xác nhận đã thu
  và tại thời điểm nào — nếu chưa chốt được, ghi Unknowns.
- Không mô tả cách tính toán trong code, cấu trúc dữ liệu, hay tích hợp ngân hàng.

## Acceptance

- §4 nêu rõ nguồn của giá và khẳng định khách không thể tự đặt giá.
- §4 nêu rõ thời điểm tổng tiền được xác định, và điều gì xảy ra nếu giá menu đổi sau thời điểm đó.
- §4 mở đầu bằng luật "giá một suất = tổng giá thành phần", và phân biệt rõ **bảng giá thành phần**
  với **bảng giá một suất** ở `shop-facts.md` §4.3.
- §4 nêu quy tắc phụ thu là **+1.000 mỗi phần nhận nhân**, và nói rõ ×1 / ×4 / ×5 là hệ quả.
- §4 nói rõ mặc định khi khách không chọn gì là **nhân Thịt, lượng Thường**.
- §4 có bảng 11 tổ hợp bắt buộc phủ theo `shop-facts.md` §4.8; ca 11 ghi rõ **bị từ chối**.
- Có ba ca cho **suất trứng đứng riêng** (ca 5, 6, 7), giá tra `shop-facts.md` §4.3; phụ thu ×5
  là **đã chốt** (2026-08-30), không đánh dấu suy luận.
- §4 **không chép** bảng giá; chỗ cần số thì trỏ `shop-facts.md` §4.2–§4.3.
- Không có câu nào nói phụ thu "không nhân theo số phần bếp làm" — câu đó đã bị gỡ khỏi
  `shop-facts.md` ngày 2026-08-29, thấy nó quay lại là bug.
- Có bảng hoặc danh sách phân biệt đơn vị thanh toán theo kênh: tại bàn = phiên; ship/pickup = đơn.
- Liệt kê đúng 2 phương thức thanh toán, mỗi phương thức nói rõ ai xác nhận đã thu được tiền.
- Có mô tả trường hợp thanh toán chưa xác nhận được: phiên/đơn nằm ở trạng thái nào,
  bàn có được giải phóng không.
- Nêu được cơ sở đối soát cuối ngày ở mức nghiệp vụ: đối chiếu với **sổ giấy** và **tiền trong két**,
  ngưỡng chấp nhận lệch = **0đ**.
- Có câu khẳng định doanh thu một ngày = tiền thu từ phiên bàn **cộng** tiền thu từ đơn ship/pickup,
  và một khoản tiền chỉ thuộc một trong hai.
- `quality/invariants.md` có ít nhất: tổng tiền của một phiên bằng tổng tiền các đơn thuộc phiên đó;
  giá áp dụng cho một đơn không đổi sau khi đơn được tạo; không có thao tác đổi tiền nào
  không truy vết lại được.
- Không có tên cổng thanh toán, ngân hàng cụ thể, hay mô tả tích hợp kỹ thuật.

## Verify

```bash
./scripts/gate.sh
grep -nEi 'momo|zalopay|vnpay|stripe|thẻ tín dụng|webhook|api' docs/product.md  # không có kết quả
grep -n 'VietQR\|tiền mặt' docs/product.md
grep -c 'Chay\|Nhiều nhân' docs/product.md      # bảng 11 tổ hợp có mặt
grep -n '×5\|x5' docs/product.md                 # ca suất trứng ghi phụ thu ×5 (đã chốt 2026-08-30)
grep -n '25.000\|thành phần' docs/product.md     # phân biệt giá thành phần vs giá suất
grep -c '000' docs/product.md                    # rất ít: §4 không phải nơi chép bảng giá
grep -n '^### I-' quality/invariants.md
git status --porcelain
```
Gate 2: ánh xạ từng dòng Acceptance → bằng chứng.
Gate 5 (L2): chạy lại bằng tay 3 câu hỏi — "một phiên hai lượt gọi thu mấy lần?",
"đổi giá xong đơn cũ bao nhiêu tiền?", "VietQR chưa thấy tiền thì bàn có trống không?" —
câu trả lời phải đọc thẳng ra được từ §4, không phải suy luận.

## Unknowns

- ~~S-1 · Phụ thu một suất trứng là ×5 hay ×4?~~ — **đã đóng 2026-08-30**: chủ quán xác nhận quả
  trứng **có** lên giá theo nhân ⇒ **×5**, suất trứng nhân thường **25.000**
  (`shop-facts.md` §7.1, §4.3, §4.6 luật 5).
- Ai được xác nhận "đã thu tiền" với VietQR tĩnh, và có cần hai người xác nhận không?
- Có cho phép hoàn tiền không, ai được phép? (§10.5)
- Có giảm giá / khuyến mãi / phụ thu ở MVP không? Nếu có thì ai quyết?
- Báo cáo doanh thu tính theo ngày nào, xử lý đơn hủy/hoàn tiền ra sao? (§10.8)
- Khách trả một phần tiền mặt, một phần chuyển khoản: có hỗ trợ ở MVP không?

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
