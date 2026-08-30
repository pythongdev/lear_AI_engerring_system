# 09 — Quyết định và giả định BA (L2) · BA-10

> L2 vì đây là nơi biến câu hỏi mở thành business truth. Chốt sai một quyết định ở đây làm sai
> mọi task phía sau, và sai âm thầm — không có test nào bắt được một quyết định sai.

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §10 (10 câu hỏi phải chốt),
  cộng toàn bộ mục Unknowns còn treo từ các prompt 01–08.
- Nguồn số: `master_plan/shop-facts.md` — mọi câu hỏi về giá, phạm vi bán, kênh, thành phần suất
  bán **đã có câu trả lời ở đây**, và `shop-facts.md` §7.1 khẳng định file đó không còn câu hỏi treo.
- Nguồn giả định: `master_plan/shop-facts.md` §7.2 — **hiện rỗng**. S-1, S-2, S-3 (ba chỗ từng
  chỉ là suy ra từ luật đã chốt) **đã được chủ quán xác nhận ngày 2026-08-30** và chuyển lên nhật
  ký §7.1, cùng chỗ với U-1–U-4 và GD-01. Nguồn còn lại: các mục "Đã có lời giải" ở cuối phần
  Unknowns của prompt 01, 02, 03 —
  những câu đó **đã có câu trả lời từ người**, phải vào file dưới dạng **ADR có nguồn**, không
  phải `GIẢ ĐỊNH`.
- Đích: `docs/decisions.md`.
- Template ADR có sẵn trong `docs/decisions.md`.

## Goal

`docs/decisions.md` chứa toàn bộ quyết định BA đã chốt và toàn bộ giả định chưa chốt, mỗi giả
định có mức rủi ro và người cần trả lời — không còn câu hỏi nghiệp vụ nào nằm rải rác trong đầu.

## Scope

Được sửa:
- `docs/decisions.md`
- `docs/product.md` (chỉ thêm dòng tham chiếu `→ ADR-00N` tại chỗ quy tắc liên quan)

Không được sửa:
- Nội dung nghiệp vụ đã chốt ở §1–§8 `docs/product.md` (chỉ được thêm tham chiếu)
- `quality/invariants.md`, `docs/architecture.md`

Dòng chép vào `work/scope.txt`:
```text
docs/decisions.md
docs/product.md
work/backlog.md
```

## Constraints

- **AI không được trả lời thay chủ quán.** Với mỗi câu hỏi, chỉ có hai dạng mục hợp lệ:
  - `ADR-00N` — đã có câu trả lời từ người, ghi kèm Decision / Why / Rejected alternatives / Applies to.
  - `GIẢ ĐỊNH GD-00N` — chưa có câu trả lời, ghi kèm: nội dung giả định, mức rủi ro
    (cao/trung bình/thấp), hậu quả nếu giả định sai, ai cần trả lời.
- Không được nâng một `GIẢ ĐỊNH` thành `ADR` nếu không có câu trả lời thật từ người.
- Ngược lại cũng sai: câu **đã có** câu trả lời trong `shop-facts.md` thì
  **không được hạ xuống `GIẢ ĐỊNH`**. Ghi thành ADR, mục "Why" trỏ đích danh nguồn và mục số.
  Ít nhất sáu câu sau thuộc loại này: pickup **có** giờ hẹn (§10.6 · `shop-facts.md` §2) ·
  phí ship **0đ**, không đơn tối thiểu (`shop-facts.md` §2, §6.12) · khách QR **ẩn danh theo bàn** ·
  khách gọi thêm khi đang thu tiền vào **cùng hoá đơn** (`shop-facts.md` §6.1) ·
  **đơn đặt trước qua hotline là kênh thứ năm `phone_preorder`, không gắn bàn** (owner chốt
  2026-08-29, `shop-facts.md` §2) · **suất giò = 9.000 + tiền 4 cái bánh theo nhân** (owner chốt
  2026-08-29, `shop-facts.md` §4.2–§4.3).
- **S-1, S-2, S-3 nay là ADR, không phải GIẢ ĐỊNH** — chủ quán đã xác nhận cả ba ngày
  2026-08-30 (`shop-facts.md` §7.1, ba dòng *xác nhận S-*):
  - **S-1** — quả trứng **lên giá theo nhân** ⇒ phụ thu suất trứng **×5**, suất trứng nhân thường
    **25.000** (không phải 24.000). "Why" ghi rõ đây từng là suy luận và được hỏi bằng câu kiểm
    chứng nào, để phiên sau biết nó đã đi qua cửa nào;
  - **S-2** — số điện thoại và địa chỉ giao đúng là hai trường bắt buộc;
  - **S-3** — người đứng quầy vừa quyết định vừa ghi vết mỗi lần hoàn tiền.
  Bảng giá `shop-facts.md` §4.3 **không đổi một con số nào** khi S-1 được xác nhận.
- Giả định mức rủi ro **cao** phải chặn task System Design phụ thuộc nó — ghi rõ task nào bị chặn.
- Không ghi quyết định kỹ thuật (chọn ngôn ngữ, DB, framework) — giai đoạn này chưa tới đó.
- Mọi Unknowns của prompt 01–08 phải xuất hiện ở đây; không được im lặng bỏ qua.

## Acceptance

- 10 câu hỏi ở §10 kế hoạch gốc đều có mục tương ứng trong `docs/decisions.md`,
  dạng ADR hoặc GIẢ ĐỊNH, không câu nào thiếu.
- S-1, S-2, S-3 đều có mục tương ứng, ở dạng **ADR** (đã chốt 2026-08-30), không phải GIẢ ĐỊNH.
- ADR của S-1 ghi con số đã chốt (**25.000**, ×5) và nói rõ nó từng là suy luận tới 2026-08-30.
- Mọi mục Unknowns của prompt 01–08 đều xuất hiện trong file, không sót.
- Sáu câu đã có lời giải (giờ hẹn pickup · phí ship 0đ · khách QR ẩn danh · gọi thêm khi đang
  thu tiền · `phone_preorder` là kênh thứ năm · giá suất giò) nằm ở dạng **ADR**, không phải
  GIẢ ĐỊNH, và "Why" trỏ được về `shop-facts.md` kèm mục số và ngày chốt (nhật ký ở §7.1).
- **Không có mục nào về giá bị ghi là "chưa biết" hay "giả định"** — bảng giá
  `shop-facts.md` §4.2–§4.3 đã đầy và **cách tính phụ thu cũng đã chốt** từ 2026-08-30.
- Mỗi ADR có đủ 4 phần theo template: Decision, Why, Rejected alternatives, Applies to.
- Mỗi GIẢ ĐỊNH có đủ: nội dung, mức rủi ro, hậu quả nếu sai, người cần trả lời.
- Không có mục nào vừa là quyết định vừa không nói được ai đã quyết.
- Có một bảng tổng hợp ở đầu file: ID | Trạng thái (Đã chốt / Giả định) | Rủi ro | Chặn việc gì.
- Mỗi quy tắc trong `docs/product.md` bắt nguồn từ một quyết định đều có tham chiếu `→ ADR-00N`.
- Không có quyết định về công nghệ/kiến trúc.

## Verify

```bash
./scripts/gate.sh
grep -c '^### ADR-\|^### GD-' docs/decisions.md      # ≥ 13 (10 câu §10 + S-1..S-3)
grep -n 'Rủi ro' docs/decisions.md                   # mọi GD đều có mức rủi ro
grep -nEi 'postgres|mysql|react|next\.js|golang|framework' docs/decisions.md  # không có kết quả
grep -n 'shop-facts.md' docs/decisions.md               # S-1 ghi rõ sửa lại ở đâu sau khi xác nhận
git status --porcelain
```
Gate 2: mở §10 kế hoạch gốc, đánh dấu từng câu hỏi 1–10 với ID mục tương ứng.
Gate 5 (L2): với mỗi GIẢ ĐỊNH rủi ro cao, kiểm tra nó có được nhắc trong task bị chặn ở
`work/backlog.md`.

## Unknowns

- Người có thẩm quyền trả lời các câu hỏi này là ai (chủ quán trực tiếp, hay quản lý)?
  Cần biết để ghi vào ô "ai cần trả lời".
- ~~Sau khi chủ quán xác nhận S-1, ai sửa lại `shop-facts.md`~~ — **đã xảy ra 2026-08-30**
  (T-004): §4.3, §4.6, §7.1, §7.2 và toàn bộ pointer trong `prompt/BA/` đã được sửa trong cùng
  một lần thay đổi. Câu hỏi còn lại của mục này: ai là người sửa — và sửa
  trước hay sau khi cập nhật `docs/decisions.md`?

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết (liệt kê GIẢ ĐỊNH rủi ro cao đang chặn việc gì)
