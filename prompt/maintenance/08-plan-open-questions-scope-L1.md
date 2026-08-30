# 08 — §10 kế hoạch gốc: hai câu đã có lời giải, một câu hỏi hẹp hơn thực tế (L1) · T-015

## Context

- `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §10 là danh sách **mười** câu "quyết định BA
  cần chốt trước khi sang System Design". Nó được viết trước khi chủ quán trả lời loạt câu ngày
  2026-08-30, và tới nay chưa được rà lại. Hai vấn đề khác nhau, đừng gộp:

  | §10 | Đang viết | Vấn đề | Loại |
  |---|---|---|---|
  | 6 | "Pickup có cần giờ hẹn bắt buộc không?" | **Đã có lời giải** — `shop-facts.md` §6.5 bảng thông tin liên hệ: *Giờ khách cần hàng* là **bắt buộc** với `pickup` (giờ hẹn lấy) **và** với `phone_preorder`. Câu hỏi vừa còn để mở một chuyện đã chốt, vừa hỏi **hẹp hơn** phạm vi thật | phạm vi **sai** |
  | 7 | "Delivery hiện chỉ cần ghi nhận đơn hay có quản lý trạng thái giao hàng?" | **Đã có lời giải** — `shop-facts.md` §6.7: quán **tự đi giao**, đơn giao tận nơi mang trạng thái "đang giao", giao xong bấm *đã giao + đã thu tiền* cùng lúc | phạm vi **đúng**, chỉ chưa đánh dấu đã chốt |

- Câu 7 **không** phải chỗ lệch ba-kênh: trạng thái "đang giao" theo `shop-facts.md` §5.2 điểm 7
  chỉ tồn tại ở đơn giao tận nơi. Đừng "mở rộng cho đủ ba kênh" — đó là bịa luật.
- Câu 5 (hoàn tiền → §6.4) cũng đã chốt. `work/backlog.md` mục *"Mười câu hỏi §10 kế hoạch gốc — ai
  trả lời câu nào"* đã đánh dấu bốn câu có lời giải; **kế hoạch gốc thì chưa**. Đây đúng kiểu lệch
  mà `work/findings.md` **F-005** mô tả: tài liệu tra cứu và backlog được cập nhật, tài liệu
  **khung** thì không, vì không ai tra cứu nó hằng ngày.
- Rủi ro nếu để nguyên: §10 kết thúc bằng câu *"Nếu chưa có câu trả lời, ghi thành `GIẢ ĐỊNH` và
  đánh dấu mức rủi ro"*. BA-04, BA-06 hoặc BA-10 đọc §10 rồi biến một luật **đã chốt** thành giả
  định — đúng thứ CLAUDE.md §3.5 cấm, và cũng là mất công hỏi lại chủ quán chuyện họ đã trả lời.
  Riêng câu 6 còn nguy hơn: trả lời nó chỉ cho `pickup` là bỏ mất mốc giờ bắt buộc của
  `phone_preorder` — quán làm hàng không kịp giờ khách hẹn.

## Goal

Người đọc §10 kế hoạch gốc biết câu nào đã có lời giải và lời giải nằm ở đâu, và câu 6 hỏi đúng
phạm vi thật của nó — mà **đánh số 1–10 không đổi**.

## Scope

Được sửa:
- `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` — **chỉ §10**
- `work/backlog.md` (ô trạng thái T-015)

Không được sửa:
- `master_plan/shop-facts.md` (nhà thật của mọi lời giải)
- `docs/product.md`, `docs/decisions.md`, `quality/invariants.md`
- Mục *"Mười câu hỏi §10"* trong `work/backlog.md` (đang đúng; sửa nó là tạo bản chép thứ hai)
- `prompt/**`, mọi mục khác của kế hoạch gốc

Dòng chép vào `work/scope.txt`:
```text
master_plan/BA_initial_plan_banh_cuon_ba_thanh.md
work/backlog.md
work/scope.txt
```

## Constraints

- **Giữ nguyên đánh số 1–10 và đủ mười câu.** `work/backlog.md` và
  `prompt/BA/09-decisions-assumptions-L2.md` trỏ theo **số thứ tự** (`§10.6`). Đổi số là gãy
  pointer — F-005 gọi đó là bug phải sửa trong cùng lần, không phải task sau.
- **Không xoá câu đã chốt.** Câu đã trả lời vẫn phải nhìn thấy được cùng lời giải của nó; xoá đi là
  mất dấu vết vì sao nó từng là câu hỏi.
- **Không chép lời giải vào §10.** Ghi ngắn *"đã chốt YYYY-MM-DD → `shop-facts.md` §6.X"* và dừng ở
  đó (ADR-001, F-001). Không chép bảng thông tin liên hệ, không chép giá, không chép hotline.
- **Chỉ sửa phạm vi của câu 6.** Câu 7 giữ nguyên phạm vi `delivery` — trạng thái "đang giao" chỉ
  có ở đơn giao tận nơi (`shop-facts.md` §5.2 điểm 7, §6.7). Mở rộng nó cho ba kênh là **bịa luật**.
- **Sáu câu còn mở giữ nguyên chữ.** Không tự trả lời, không đoán, không đổi cách hỏi. Câu nào
  `shop-facts.md` chưa có lời giải thì để nguyên là câu hỏi (CLAUDE.md §3.5).
- Câu kết của §10 (*"Nếu chưa có câu trả lời, ghi thành `GIẢ ĐỊNH`…"*) giữ nguyên — nó vẫn đúng cho
  sáu câu còn mở.
- **Rà cả mười câu, không chỉ hai câu ở bảng Context.** Câu 1 và câu 5 cũng đã có lời giải một phần
  hoặc toàn phần (`shop-facts.md` §6.2 · §6.13 · §6.4); đánh dấu chúng theo đúng mức đã chốt —
  câu 1 chỉ chốt phần *xác nhận* và *huỷ*, phần **sửa đơn vẫn còn mở**.

## Acceptance

- Câu 6 nêu được mốc giờ là bắt buộc với **cả `pickup` và `phone_preorder`**, và trỏ
  `shop-facts.md` §6.5.
- Câu 7 giữ nguyên phạm vi `delivery`, có dấu đã chốt trỏ `shop-facts.md` §6.7.
- Mỗi câu đã có lời giải trong `shop-facts.md` mang dấu *đã chốt + ngày + mục nguồn*; mỗi câu chưa
  có thì **không** mang dấu đó.
- Câu 1 ghi rõ chốt tới đâu và **phần "sửa đơn" còn mở**.
- Vẫn đúng **mười** câu, đánh số 1–10 liên tục, không đổi thứ tự.
- Sáu câu còn mở (2, 3, 4, 8, 9, 10) không đổi một ký tự.
- Không có dấu "đã chốt" nào mà `shop-facts.md` không đỡ được — mỗi dấu phải trỏ tới một mục §6.X
  hoặc §5.X có thật; mở từng mục ra kiểm và nói trong Report là đã kiểm.
- `grep -nE '[0-9]{1,3}\.000|0382688666' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` rỗng.
- `./scripts/gate.sh` xanh.

## Verify

```bash
./scripts/gate.sh
sed -n '/^## 10\./,/^# 11\./p' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md
sed -n '/^## 10\./,/^# 11\./p' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md | grep -cE '^[0-9]+\.'   # = 10
grep -rn '§10\.[0-9]' work/backlog.md prompt/BA/          # pointer theo số — phải vẫn trỏ đúng câu
git diff -- master_plan/BA_initial_plan_banh_cuon_ba_thanh.md    # chỉ chạm §10
grep -nE '[0-9]{1,3}\.000|0382688666' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md   # rỗng
git status --porcelain
```
Gate 2: với mỗi dòng Acceptance, trỏ tới dòng cụ thể trong file chứng minh nó.

## Unknowns

- **Không tự chốt câu nào.** Task này chỉ ghi lại lời giải **đã có** trong `shop-facts.md` và sửa
  phạm vi một câu hỏi. Nếu thấy một câu trông "gần như đã chốt" mà `shop-facts.md` không nói thẳng,
  đó là **suy luận** — để nguyên là câu hỏi và ghi vào `docs/product.md` → *Unknowns* dạng
  `U-XXX`, đừng viết vào §10 như thể đã chốt (F-004: phần chênh giữa lời chủ quán và quyết định
  cần có luôn là suy luận, phải ghi tách ra).
- Nếu phát hiện `work/backlog.md` mục *"Mười câu hỏi §10"* mâu thuẫn với `shop-facts.md`: **đừng
  sửa hai chỗ cho khớp nhau** — `shop-facts.md` thắng (CLAUDE.md §2), sửa backlog theo nó và ghi
  một dòng vào Report.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
