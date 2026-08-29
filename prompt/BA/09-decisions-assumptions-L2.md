# 09 — Quyết định và giả định BA (L2) · BA-10

> L2 vì đây là nơi biến câu hỏi mở thành business truth. Chốt sai một quyết định ở đây làm sai
> mọi task phía sau, và sai âm thầm — không có test nào bắt được một quyết định sai.

## Context

- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §10 (10 câu hỏi phải chốt),
  cộng toàn bộ mục Unknowns còn treo từ các prompt 01–08.
- Nguồn số: `master_plan/00-scope.md` — mọi câu hỏi về giá, phạm vi bán, kênh, thành phần suất
  bán **đã có câu trả lời ở đây**, và `00-scope.md` §6 khẳng định file đó không còn giả định nào.
- Nguồn unknown: `master_plan/shop-facts.md` §8 (**U-1–U-4**) và `00-scope.md` §6 (**GD-01**,
  cùng một câu với U-1) và các mục "Đã có lời giải" ở cuối phần Unknowns của prompt 01, 02, 03 —
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
- Ngược lại cũng sai: câu **đã có** câu trả lời trong `00-scope.md` hoặc `shop-facts.md` thì
  **không được hạ xuống `GIẢ ĐỊNH`**. Ghi thành ADR, mục "Why" trỏ đích danh nguồn và mục số.
  Ít nhất sáu câu sau thuộc loại này: pickup **có** giờ hẹn (§10.6 · `00-scope.md` §2) ·
  phí ship **0đ**, không đơn tối thiểu (`00-scope.md` §2, §5) · khách QR **ẩn danh theo bàn** ·
  khách gọi thêm khi đang thu tiền vào **cùng hoá đơn** (`shop-facts.md` §6.1) ·
  **đơn đặt trước qua hotline là kênh thứ năm `phone_preorder`, không gắn bàn** (owner chốt
  2026-08-29, `00-scope.md` §2) · **suất giò = 9.000 + tiền 4 cái bánh theo nhân** (owner chốt
  2026-08-29, `00-scope.md` §4.2).
- **U-1 là câu chạm tiền, ghi là `GIẢ ĐỊNH` rủi ro cao**, không phải ADR:
  - **không** được chọn cách hiểu nghe hợp lý hơn rồi ghi thành ADR;
  - nêu **cả hai** cách hiểu kèm con số và hậu quả (lệch 12.000–20.000đ mỗi suất);
  - ghi rõ **sau khi chủ quán chọn phải sửa `00-scope.md` §4.2 và §6** — nếu không, lần đọc sau
    lại đẻ ra đúng câu hỏi này.
- Giả định mức rủi ro **cao** phải chặn task System Design phụ thuộc nó — ghi rõ task nào bị chặn.
- Không ghi quyết định kỹ thuật (chọn ngôn ngữ, DB, framework) — giai đoạn này chưa tới đó.
- Mọi Unknowns của prompt 01–08 phải xuất hiện ở đây; không được im lặng bỏ qua.

## Acceptance

- 10 câu hỏi ở §10 kế hoạch gốc đều có mục tương ứng trong `docs/decisions.md`,
  dạng ADR hoặc GIẢ ĐỊNH, không câu nào thiếu.
- 4 unknown U-1–U-4 ở `shop-facts.md` §8 đều có mục tương ứng.
- U-1 nêu đủ **cả hai** cách hiểu kèm con số, và có dòng "sau khi chốt phải sửa `00-scope.md`
  §4.2 và §6".
- Mọi mục Unknowns của prompt 01–08 đều xuất hiện trong file, không sót.
- Sáu câu đã có lời giải (giờ hẹn pickup · phí ship 0đ · khách QR ẩn danh · gọi thêm khi đang
  thu tiền · `phone_preorder` là kênh thứ năm · giá suất giò) nằm ở dạng **ADR**, không phải
  GIẢ ĐỊNH, và "Why" trỏ được về `00-scope.md` hoặc `shop-facts.md` kèm mục số và ngày chốt.
- U-1 nằm ở dạng GIẢ ĐỊNH rủi ro **cao**, ghi rõ chặn BA-06.
- Không có mục nào về giá bị ghi là "chưa biết" ngoài U-1 — phần còn lại đã có ở `00-scope.md` §4.2.
- Mỗi ADR có đủ 4 phần theo template: Decision, Why, Rejected alternatives, Applies to.
- Mỗi GIẢ ĐỊNH có đủ: nội dung, mức rủi ro, hậu quả nếu sai, người cần trả lời.
- Không có mục nào vừa là quyết định vừa không nói được ai đã quyết.
- Có một bảng tổng hợp ở đầu file: ID | Trạng thái (Đã chốt / Giả định) | Rủi ro | Chặn việc gì.
- Mỗi quy tắc trong `docs/product.md` bắt nguồn từ một quyết định đều có tham chiếu `→ ADR-00N`.
- Không có quyết định về công nghệ/kiến trúc.

## Verify

```bash
./scripts/gate.sh
grep -c '^### ADR-\|^### GD-' docs/decisions.md      # ≥ 14 (10 câu §10 + U-1..U-4)
grep -n 'Rủi ro' docs/decisions.md                   # mọi GD đều có mức rủi ro
grep -nEi 'postgres|mysql|react|next\.js|golang|framework' docs/decisions.md  # không có kết quả
grep -n '00-scope' docs/decisions.md               # U-1 ghi rõ sửa lại ở đâu sau khi chốt
git status --porcelain
```
Gate 2: mở §10 kế hoạch gốc, đánh dấu từng câu hỏi 1–10 với ID mục tương ứng.
Gate 5 (L2): với mỗi GIẢ ĐỊNH rủi ro cao, kiểm tra nó có được nhắc trong task bị chặn ở
`work/backlog.md`.

## Unknowns

- Người có thẩm quyền trả lời các câu hỏi này là ai (chủ quán trực tiếp, hay quản lý)?
  Cần biết để ghi vào ô "ai cần trả lời".
- Sau khi chủ quán gỡ U-1, ai là người sửa lại `00-scope.md` §4.2 và §6 — và sửa trước hay sau
  khi cập nhật `docs/decisions.md`?

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết (liệt kê GIẢ ĐỊNH rủi ro cao đang chặn việc gì)
