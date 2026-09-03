# Prompt BA — Bánh cuốn Bà Thanh Cao Bằng

Bộ prompt để hoàn thành giai đoạn BA mô tả trong `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`.

Viết theo `docs/prompt-guideline.md`. Kiểm kết quả theo `quality/review-gate.md`.

## Hai nguồn input, không phải một

| Nguồn | Cho cái gì | Ai là nhà thật |
|---|---|---|
| `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` | **Khung** nghiệp vụ: 11 task, 3 lát cắt, 12 quy tắc, 14 ngoại lệ, 10 câu hỏi | — |
| `master_plan/shop-facts.md` | **Mọi dữ kiện quán**: phạm vi bán, **5 kênh**, bảng giá thành phần, giá một suất, phụ thu, thành phần một suất bán, 5 trạm, hai luồng bán, nổ việc xuống bếp, 16 quy tắc nghiệp vụ, đối soát, sổ giấy | **Nhà duy nhất, từ 2026-08-30.** Chỗ khác nói khác ⇒ file này thắng |

Kế hoạch gốc không chứa một con số nào của quán này. Chạy bộ prompt mà bỏ `shop-facts.md` sẽ ra một
`docs/product/` đúng khuôn nhưng áp cho quán ăn nào cũng được — tức là chưa chốt gì.

⚠️ **Cần bất kỳ dữ kiện nào của quán ⇒ tra `shop-facts.md`, và chỉ tra ở đó.** Từ 2026-08-30 nó là
nhà duy nhất; không còn bản chép thứ hai của bất kỳ con số nào. `master_plan/00-scope.md` chỉ còn
là file trỏ, **không sở hữu gì** — thấy ai chép bảng giá về đó là bug.

⚠️ **Cấm đưa vào tài liệu BA**: stack công nghệ, tên bảng dữ liệu và cột, endpoint, cây route,
quy tắc kích thước chữ và màu. Những thứ đó thuộc System Design trở đi. `shop-facts.md` cố ý
không chứa chúng, nên nếu chúng xuất hiện trong đầu ra BA thì chúng đến từ `prompt-fullstack.md`
§3.4–§3.7 — đó là dán nhầm.

⚠️ **Mô hình giá là "giá một suất = TỔNG giá các thành phần"** (`shop-facts.md` §4.6 quy tắc 1).
Bảng §4.2 là giá **thành phần**, bảng §4.3 là giá **một suất bán** — đọc nhầm hai cái này là thu
sai tiền. Bằng chứng của mô hình ở §4.7, mười một ca giá bắt buộc phủ ở §4.8.

✅ **Bảng giá đã đầy, không còn unknown nào** (`shop-facts.md` §7.1). U-1–U-4 và GD-01 đã được chủ
quán trả lời hết ngày 2026-08-30; ô cuối cùng — giá suất trứng — nay có số ở §4.3.

✅ **Ba chỗ suy luận S-1–S-3 đã được chủ quán xác nhận ngày 2026-08-30** (`shop-facts.md` §7.1,
ba dòng *xác nhận S-*). S-1 — chỗ chạm tiền — trả lời là **×5**: quả trứng cũng lên giá theo nhân,
suất trứng nhân thường = **25.000**. Viết theo ×5 và **không** còn phải đánh dấu là suy luận.
Prompt nào còn bảo "ghi S-1 là giả định" là pointer cũ.

✅ **S-4 đã có lời giải ngày 2026-09-01.** *(§7.2 rỗng trở lại trong ngày, rồi có lại **một** dòng
— **S-5**, cùng ngày, T-039: bấm "đã bưng ra bàn" theo **đơn vị nào**. Prompt nào còn nói "§7.2
rỗng" là pointer cũ.)* Câu hỏi
(*"đã làm xong, còn ở bếp" có phải một con số riêng không*) được trả lời là **có**: bánh gấp xong
nằm chờ thật, và **người đứng quầy bấm** nút "đã làm xong" — ba trạm bếp vẫn không bấm gì
(§5.4, §7.1). Prompt nào còn bảo "ghi S-4 là suy luận" là **pointer cũ**.

⚠️ **Nhưng lời giải ấy mở ra `docs/product/99-unknowns.md` U-017**: quầy bấm theo **từng cái**,
theo **cả mẻ**, hay theo **cả bàn**? Chưa ai trả lời. Prompt nào chạm trục sản xuất phải ghi
**bốn** con số và nói rõ **cách đếm con số thứ tư chưa chốt** — không tự chọn hộ
(`work/findings.md` F-004, CLAUDE.md §3.5).

## Nguyên tắc của bộ prompt này

- BA là **L3** ở cấp giai đoạn: nó quyết định phạm vi và hành vi nghiệp vụ toàn hệ thống.
  Vì vậy `00-master-L3.md` là prompt **thiết kế và chia việc**, không phải prompt viết tài liệu.
- Việc viết tài liệu thật nằm ở các prompt L1/L2 bên dưới, mỗi prompt **một** kết quả.
- Không prompt nào được phép để AI tự đặt luật nghiệp vụ. Câu hỏi chưa có lời giải →
  ghi `GIẢ ĐỊNH` + mức rủi ro vào `docs/decisions.md`, hỏi người, rồi mới chốt.
- Giai đoạn BA **không** tạo tài liệu BE/FE/DB/API. Đó là scope của System Design.

## Thứ tự chạy

| # | Prompt | Level | Task gốc | Đầu ra chính |
|---|---|---|---|---|
| 00 | `00-master-L3.md` | L3 | BA-01–BA-11 | Kế hoạch BA + backlog + khung tài liệu |
| 01 | `01-actors-channels-L1.md` | L1 | BA-01, BA-02 | `docs/product/0-ba/ban-hang/` §1 Actor, §2 Kênh bán |
| 02 | `02-slice-dine-in-L2.md` | L2 | BA-03 | `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.1 Luồng ăn tại bàn |
| 03 | `03-slice-ship-pickup-L2.md` | L2 | BA-04 | `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.2 Luồng mang đi (ba kênh) |
| 04 | `04-slice-menu-price-change-L2.md` | L2 | BA-05 | `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.3 Đổi menu/giá |
| 05 | `05-pricing-payment-L2.md` | L2 | BA-06 | `docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4 Giá & thanh toán + invariants |
| 06 | `06-lifecycles-L2.md` | L2 | BA-07 | `docs/product/0-ba/ban-hang/05-vong-doi.md` §5 Vòng đời + invariants |
| 07 | `07-exceptions-L2.md` | L2 | BA-08 | `docs/product/0-ba/ban-hang/06-ngoai-le.md` §6 Ngoại lệ |
| 08 | `08-mvp-scope-L1.md` | L1 | BA-09 | `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7 Phạm vi MVP |
| 09 | `09-decisions-assumptions-L2.md` | L2 | BA-10 | `docs/decisions.md` ADR + giả định |
| 10 | `10-acceptance-scenarios-L2.md` | L2 | BA-11 | `docs/product/0-ba/ban-hang/08-scenario.md` §8 + cổng chất lượng BA |
| 12 | `12-production-control-L2.md` | L2 | BA-12 | `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4 Sản xuất theo mẻ + invariants |

Chạy tuần tự 00–10. 02–04 phụ thuộc 01; 05–07 phụ thuộc 02–04; 10 là cổng cuối.

**Số 12 đứng ngoài dãy 00–10 có chủ đích.** Nó sinh ngày 2026-08-31 (`work/backlog.md` T-026) từ
lời chủ quán về cách bếp gom việc, **sau** khi dãy 00–10 đã được chốt và đánh số; chen nó vào giữa
sẽ đẩy số của mọi prompt sau nó và làm chết mọi pointer đang trỏ tới chúng. Nó chạy **sau BA-03 và
BA-07**, trước BA-09 — thứ tự phụ thuộc ở `work/backlog.md`, không đọc theo số. Không có `11`;
BA-11 dùng prompt số 10.

## Cách dùng một prompt

1. **Gate 0** — mở prompt, đọc mục Scope, chép đúng các dòng scope vào `work/scope.txt`.
2. Dán toàn bộ nội dung prompt vào session mới (context sạch).
3. Nếu prompt có mục Unknowns không rỗng → trả lời trước, đừng để AI tự quyết.
4. **Gate 1 + 3** — `./scripts/gate.sh` (chạy tự động qua Stop hook).
5. **Gate 2** — soi từng dòng Acceptance, chỉ ra bằng chứng.
6. Xong task → xoá pattern trong `work/scope.txt`, tick trạng thái trong `work/backlog.md`.
