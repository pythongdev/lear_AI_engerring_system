# 10 — Scenario nghiệm thu và cổng chất lượng BA (L2) · BA-11

> L2 và là cổng cuối của giai đoạn BA. Prompt này không thêm nghiệp vụ mới — nó chứng minh
> nghiệp vụ đã chốt chạy được từ đầu đến cuối. Không qua được cổng này thì không sang System Design.

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §12 (cổng chất lượng BA),
  §3 (ba lát cắt).
- Nguồn số: `master_plan/00-scope.md` §4.2 (bảng giá — dùng để viết tổng tiền kiểm được),
  §4.4 (thành phần suất bán).
- Nguồn quy tắc: `master_plan/shop-facts.md` §5.1 (ví dụ nổ việc xuống bếp — số liệu cho
  scenario 1), §6.1, §8 (U-1).
- Đích: `docs/product.md` §8.
- Đầu vào: toàn bộ §1–§7 `docs/product.md`, `docs/decisions.md`, `quality/invariants.md`.

## Goal

`docs/product.md` §8 có ba scenario nghiệm thu BA diễn lại được bằng nghiệp vụ thuần, và kết quả
chạy thử ba scenario đó chứng minh tài liệu BA không còn lỗ hổng chặn System Design.

## Scope

Được sửa:
- `docs/product.md` §8
- `work/findings.md` (ghi lỗ hổng phát hiện khi diễn scenario)
- `work/backlog.md` (cập nhật trạng thái BA-01–BA-11)

Không được sửa:
- §1–§7 của `docs/product.md` — nếu diễn scenario mà thấy §1–§7 sai/thiếu, **không tự sửa**:
  ghi finding và mở lại task BA tương ứng.
- `docs/decisions.md`, `quality/invariants.md`

Dòng chép vào `work/scope.txt`:
```text
docs/product.md
work/findings.md
work/backlog.md
```

## Constraints

- Ba scenario bắt buộc, đúng §12 kế hoạch gốc:
  1. Khách QR tại bàn → gọi nhiều lần → thanh toán một lần.
  2. Khách đặt ship/pickup → quán xác nhận → hoàn thành.
  3. Chủ quán đổi giá → đơn mới dùng giá mới, đơn cũ không đổi.
- Mỗi bước của scenario phải trỏ được về một mục cụ thể trong §1–§7. Bước nào không trỏ được
  = lỗ hổng tài liệu → finding, không tự lấp bằng cách viết thêm nghiệp vụ.
- Scenario viết bằng ngôn ngữ nghiệp vụ, không có thuật ngữ kỹ thuật. Người không biết code
  phải diễn lại được.
- Mỗi scenario phải có kết quả mong đợi cụ thể, kiểm được đúng/sai (số lần thu tiền, tổng tiền
  đơn cũ, trạng thái cuối của bàn).
- **Scenario 1 dùng số liệu thật, không viết chung chung.** Bám ví dụ `shop-facts.md` §5.1:
  bàn 5 · gọi lần đầu **2 suất "Đầy đủ trứng tái", thịt + mộc nhĩ, nhiều nhân** · kết quả kiểm
  được ở bếp là **6 cái bánh cuốn, 2 quả trứng, 2 chiếc giò, 1 việc nước chấm cho bàn 5** —
  không phải "bếp nhận được việc".
- **Scenario 1 phải có lượt gọi thêm xảy ra SAU khi quầy đã bắt đầu thu tiền**, và kết quả mong
  đợi là **vẫn 1 lần thu tiền, 1 hoá đơn** (`shop-facts.md` §6.1). Đây là bước chứng minh chỗ
  hỏng-ra-tiền nguy hiểm nhất; scenario không có bước này thì chưa nghiệm thu được lát cắt A.
- **Tổng tiền phải là số cụ thể, tra `00-scope.md` §4.2.** Ví dụ scenario 1: 2 suất "Đầy đủ trứng
  tái", thịt + mộc nhĩ, nhiều nhân ⇒ **68.000đ**. Ghi rõ con số này là **bản chép** của
  `00-scope.md` §4.2 và §4.3; giá đổi thì phải sửa cả scenario.
- Scenario **3** (đổi giá) phải nêu đích danh món và mức giá trước/sau, tra từ `00-scope.md` §4.2 —
  "đơn cũ giữ nguyên tổng tiền" mà không có số thì không kiểm được đúng/sai.
- Không đóng giai đoạn BA khi còn `GIẢ ĐỊNH` rủi ro cao chặn scenario nào. **U-1 (giá một suất
  trứng) đang là một giả định như vậy** (`shop-facts.md` §8 · `00-scope.md` §6 GD-01) — mặc định
  kết luận của prompt này là "chưa đủ điều kiện sang System Design", trừ khi U-1 đã được gỡ.
  Nói rõ scenario nào bị chạm: bất kỳ scenario nào có **suất trứng đứng riêng**.
- **Scenario 2 phải dùng kênh `phone_preorder`** ít nhất một lần, vì đó là kênh mới nhất
  (owner chốt 2026-08-29) và chưa từng được diễn thử. Đơn `phone_preorder` **không thuộc phiên
  bàn nào** — kết quả mong đợi phải kiểm được điều đó.

## Acceptance

- §8 có đúng 3 scenario, mỗi scenario có: bối cảnh, các bước, kết quả mong đợi kiểm được đúng/sai.
- Scenario 1 nêu rõ số lần thanh toán = 1 dù có nhiều lượt gọi món, và trạng thái cuối của bàn là `Trống`.
- Scenario 1 có ít nhất một lượt gọi thêm **sau khi quầy bắt đầu thu tiền**, kết quả vẫn là 1 hoá đơn.
- Scenario 1 có bước kiểm số lượng bếp nhận được (6 bánh / 2 trứng / 2 giò / 1 nước chấm),
  khác số lượng trên hoá đơn (2 suất), và tổng tiền là **68.000đ** tra từ `00-scope.md` §4.2.
- Scenario 3 có món cụ thể, giá trước và giá sau, tra từ `00-scope.md` §4.2.
- Scenario 2 nêu rõ đơn không gắn phiên bàn và trạng thái cuối là `Hoàn thành`, và có ít nhất
  một lượt dùng kênh `phone_preorder`.
- Scenario 3 nêu rõ tổng tiền đơn cũ không đổi sau khi giá menu đổi.
- Mỗi bước trong cả 3 scenario có tham chiếu tới mục §1–§7 chứa quy tắc tương ứng.
- Có checklist cổng chất lượng BA (9 mục ở §12 kế hoạch gốc) với trạng thái tick thật,
  không tick mục chưa đạt. Mục "không còn business rule quan trọng bị suy đoán" **không được tick**
  khi U-1 còn treo.
- Mọi lỗ hổng phát hiện khi diễn scenario đều có finding trong `work/findings.md`, kèm task
  BA cần mở lại.
- `work/backlog.md`: task BA-01–BA-11 nào đã xong được đánh dấu Done; task phải mở lại
  quay về Ready kèm lý do.
- Không có bước nào trong scenario mô tả thao tác kỹ thuật.

## Verify

```bash
./scripts/gate.sh
grep -c '^### Scenario' docs/product.md      # = 3
grep -n '68.000\|68000' docs/product.md      # scenario 1 có tổng tiền kiểm được
grep -n '\[ \]\|\[x\]' docs/product.md       # checklist 9 mục cổng chất lượng
grep -nEi 'click|button|màn hình|api|endpoint' docs/product.md   # không có kết quả
git status --porcelain
```
Gate 2: diễn miệng từng scenario, mỗi bước chỉ tay vào mục §1–§7 chứng minh nó.
Gate 5 (L2): chạy scenario 3 đối chiếu trực tiếp với invariant lịch sử đơn trong
`quality/invariants.md`; hai chỗ mâu thuẫn nhau = chưa đạt.
Gate 6: nhờ một session mới (context sạch) đọc §1–§8 và tự diễn lại 3 scenario, không đưa
lý do đã giải thích trước đó.

## Unknowns

- Ai là người ký duyệt cổng chất lượng BA — ai nói "được, sang System Design"?
- Có được mở System Design **song song** phần không phụ thuộc U-1 (vòng đời, trạm, luồng tại
  bàn) trong lúc chờ chủ quán trả lời không, hay phải chờ hết?

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết (nêu rõ: BA đã đủ điều kiện sang System Design chưa,
  nếu chưa thì mục nào của cổng chất lượng chưa đạt)
