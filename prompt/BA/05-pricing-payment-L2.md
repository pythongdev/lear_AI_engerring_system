# 05 — Quy tắc giá và thanh toán (L2) · BA-06

> L2 vì đây là mục chạm tiền trực tiếp. Theo `docs/prompt-guideline.md` §1, chạm tiền là L2+
> kể cả khi "chỉ viết một dòng quy tắc".

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §6 (Giá, Thanh toán),
  §5 quy tắc 3, 5, 6, 12.
- Nguồn dữ kiện: `master_plan/shop-facts.md` §1 (2 phương thức, VietQR **tĩnh**),
  **§4 (cấu trúc giá) + §4.1 (11 tổ hợp bắt buộc phủ)**, §6.4 (doanh thu từ hai nguồn),
  §6.5 (đối soát cuối ngày), **§8 U-1/U-2 — chưa có bảng giá, đây là vật cản của chính task này**.
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
- **Cấu trúc giá đã chốt, dùng đúng** (`shop-facts.md` §4), không diễn giải lại:
  giá gốc của một món = **giá chay**; nhân là **phụ thu** nằm ở tuỳ chọn;
  **loại nhân không đổi giá**, chỉ **lượng nhân** mới đổi giá;
  **giò không nhận nhân**; combo tính **phụ thu ×4**;
  nhóm "Lượng nhân" chỉ tồn tại khi nhân ≠ Chay ⇒ **Chay + Nhiều nhân bị TỪ CHỐI**.
- **11 tổ hợp ở `shop-facts.md` §4.1 là hợp đồng với chủ quán.** Chép nguyên danh sách tổ hợp vào
  §4 làm bảng ca phải phủ. Đây là danh sách **tổ hợp đầu vào**, không phải bảng giá.
- ⚠️ **Chưa có bảng giá thật** (`shop-facts.md` §8 U-1, U-2). **Không bịa một con số nào.**
  §4 chốt **công thức và quy tắc**; ô giá để trống với dấu `⚠ chưa có — U-1`. Task này **không
  được đánh Done** khi U-1 còn treo — ghi rõ điều đó trong Report.
- Phương thức thanh toán ở MVP chỉ có: tiền mặt, VietQR tĩnh. Không thêm cổng thanh toán,
  ví điện tử, thẻ — kể cả dạng "chuẩn bị cho sau này".
- **Doanh thu một ngày phải cộng từ HAI nguồn**: phiên bàn (dine-in) và đơn lẻ (ship/pickup).
  Một khoản tiền thuộc **đúng một** trong hai, không bao giờ cả hai (`shop-facts.md` §6.4).
  Báo cáo bỏ sót một nguồn là báo cáo thiếu.
- **Đối soát cuối ngày đã chốt** (`shop-facts.md` §6.5): mỗi tối đối chiếu doanh thu hệ thống với
  **sổ giấy** và **tiền trong két**; **lệch 1 đồng cũng phải tìm ra lý do**. Viết ra như một quy
  trình của quán, không viết như một tính năng phần mềm.
- VietQR **tĩnh** nghĩa là hệ thống không tự biết tiền đã về. Phải chốt rõ ai xác nhận đã thu
  và tại thời điểm nào — nếu chưa chốt được, ghi Unknowns.
- Không mô tả cách tính toán trong code, cấu trúc dữ liệu, hay tích hợp ngân hàng.

## Acceptance

- §4 nêu rõ nguồn của giá và khẳng định khách không thể tự đặt giá.
- §4 nêu rõ thời điểm tổng tiền được xác định, và điều gì xảy ra nếu giá menu đổi sau thời điểm đó.
- §4 mô tả được cấu tạo giá một suất: giá gốc (chay) + phụ thu tuỳ chọn, và quy tắc combo ×4.
- §4 có bảng 11 tổ hợp bắt buộc phủ theo `shop-facts.md` §4.1, ca 11 ghi rõ kết quả là **bị từ chối**.
- Mọi ô giá chưa có số đều mang dấu `⚠ chưa có — U-1`; **không có con số giá nào tự bịa**.
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
grep -n 'U-1' docs/product.md                    # ô giá chưa có được đánh dấu, không bịa số
grep -n '^### I-' quality/invariants.md
git status --porcelain
```
Gate 2: ánh xạ từng dòng Acceptance → bằng chứng.
Gate 5 (L2): chạy lại bằng tay 3 câu hỏi — "một phiên hai lượt gọi thu mấy lần?",
"đổi giá xong đơn cũ bao nhiêu tiền?", "VietQR chưa thấy tiền thì bàn có trống không?" —
câu trả lời phải đọc thẳng ra được từ §4, không phải suy luận.

## Unknowns

- **U-1 · Bảng giá thật và danh sách món đầy đủ** (`shop-facts.md` §8). Rủi ro **cao**,
  **chặn task này và BA-11**. Không có số thì §4 chỉ là công thức rỗng.
- **U-2 · Mức phụ thu "Nhiều nhân"** và mức phụ thu combo tính trên con số nào.
- Ai được xác nhận "đã thu tiền" với VietQR tĩnh, và có cần hai người xác nhận không?
- Có cho phép hoàn tiền không, ai được phép? (§10.5)
- Có giảm giá / khuyến mãi / phụ thu ở MVP không? Nếu có thì ai quyết?
- Báo cáo doanh thu tính theo ngày nào, xử lý đơn hủy/hoàn tiền ra sao? (§10.8)
- Khách trả một phần tiền mặt, một phần chuyển khoản: có hỗ trợ ở MVP không?

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
