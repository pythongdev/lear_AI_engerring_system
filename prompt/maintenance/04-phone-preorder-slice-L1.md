# 04 — Kênh `phone_preorder` không nằm trong lát cắt nào của kế hoạch gốc (L1) · T-011

## Context

- `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` là **khung** giai đoạn BA. Nó không sở hữu
  dữ kiện quán nào — nhà duy nhất là `master_plan/shop-facts.md` (ADR-001).
- `shop-facts.md` §5.2 đã gộp **ba kênh không gắn bàn** thành **một** luồng:
  *"Luồng mang đi — `delivery`, `pickup`, `phone_preorder`"*. Đó là nhà thật, và nó nói ba kênh này
  đi chung một lát cắt.
- `prompt/BA/03-slice-ship-pickup-L2.md` (prompt chạy BA-04) **cũng đã phủ đủ ba kênh** — nó nêu
  đích danh `phone_preorder`, viết thẳng *"Bỏ `phone_preorder` là bỏ một phần ba lát cắt"*, và có
  dòng acceptance *"§3.2 phủ đủ **ba** kênh không gắn bàn"*.
- Nghĩa là ý định của giai đoạn BA xưa nay là **ba kênh**; chỉ riêng **tài liệu khung** chưa nói.
  Bốn chỗ lệch, tính tới 2026-08-30 (sau T-007):

  | Chỗ | Đang viết | Vấn đề |
  |---|---|---|
  | §3 Epic B | "Một đơn ship/pickup" | tên lát cắt chỉ kể hai kênh |
  | §4.2 | tiêu đề "Ship / Pickup", 9 bước, bước 8–9 chỉ có `pickup` và `delivery` | luồng không có nhánh kết thúc của `phone_preorder` |
  | §11 dòng BA-04 | "Mô tả lát cắt một đơn ship/pickup" | task giao thiếu việc |
  | §12 scenario 2 | "Khách đặt ship/pickup → quán xác nhận → hoàn thành" | **nặng nhất**: nghiệm thu cả giai đoạn BA mà bỏ một kênh |

- T-007 (2026-08-30) sửa **con số** kênh trong file này, không sửa chỗ thiếu **luồng** — đây là
  phần còn lại. `work/findings.md` F-003 đã đặt tên bug: *"Kênh chỉ có trong bảng §2 mà không có
  trong luồng nào là bug"*; F-005 là lý do phải rà cả tài liệu khung chứ không chỉ tài liệu tra cứu.
- **Chạy trước T-008.** T-008 dựng BA-03–BA-11 vào backlog từ bảng §11; chạy sau task này thì
  backlog chép đúng dòng BA-04 còn thiếu rồi khoá lại.

## Goal

Mỗi kênh ở `shop-facts.md` §2 thuộc **đúng một** lát cắt trong kế hoạch gốc. Người đọc §3, §4.2,
§11 hay §12 không còn ai tưởng `phone_preorder` chưa có chủ.

## Scope

Được sửa:
- `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`
- `work/backlog.md` (ô trạng thái T-011)
- `work/findings.md` (chỉ khi phát hiện chỗ lệch thứ năm — xem *Unknowns*)

Không được sửa:
- `master_plan/shop-facts.md` (đang đúng, là nhà thật)
- `prompt/BA/*` (đã phủ đủ ba kênh — chính nó là bằng chứng cho thay đổi này)
- `docs/product.md`, `docs/decisions.md`, `quality/invariants.md`

Dòng chép vào `work/scope.txt`:
```text
master_plan/BA_initial_plan_banh_cuon_ba_thanh.md
work/backlog.md
work/findings.md
work/scope.txt
```

## Constraints

- **Vẫn đúng ba lát cắt — mở rộng Epic B, không thêm Epic D.** `shop-facts.md` §5.2 gộp ba kênh
  này thành một luồng; tách `phone_preorder` ra thành lát cắt riêng là tạo ra một lát cắt mà nhà
  thật không có, và kéo theo phải sửa "Ba lát cắt" ở §3, "Có 3 lát cắt" ở §12, ID bảng §11.
- **Đừng chép sơ đồ luồng §5.2 vào kế hoạch gốc.** Giữ đúng mức chi tiết mà §4.1/§4.2 đang có
  (các bước nghiệp vụ, một dòng một bước). Chỗ cần chi tiết hơn thì **trỏ** `shop-facts.md` §5.2
  (ADR-001, F-001).
- Không chép số hotline, không chép giá, không chép bảng kênh.
- Không đổi ID `BA-01`–`BA-11`, không đổi cột "Cần xong trước", không thêm/bớt dòng nào của bảng
  §11 và của checklist §12.
- **§12 đã có sẵn một dòng ghi chú ngày của T-007.** Bổ sung vào chính khối đó, đừng tạo khối ghi
  chú thứ hai — hai dòng ghi chú cạnh nhau là khởi đầu của một nhật ký không ai bảo trì.
- Kế hoạch gốc bị các prompt khác ghi là "input, không được sửa" (`prompt/BA/00-master-L3.md` →
  Scope). Prompt này là một trong hai chỗ cho phép (chỗ kia là prompt 01), và chỉ cho phép đúng
  việc đưa `phone_preorder` vào lát cắt; đừng nhân tiện viết lại gì khác.

## Acceptance

- §3 Epic B mang tên phủ cả ba kênh không gắn bàn (ví dụ *"Một đơn mang đi"*), câu mô tả nêu đích
  danh `phone_preorder`, và **Mục tiêu BA** của Epic B không đổi ý nghĩa.
- §4.2 nêu được nhánh của `phone_preorder`: nhân viên nhận điện thoại → nhập hộ → và **kết thúc cả
  hai kiểu** (khách tới lấy hoặc quán giao; nhân viên hỏi khách lúc nhận máy — `shop-facts.md`
  §5.2, chủ quán chốt 2026-08-30). Không chép cả sơ đồ; một tới ba bước là đủ, kèm một dòng trỏ.
- §11 dòng BA-04 nói đủ ba kênh; sáu cột còn lại của dòng đó không đổi một ký tự.
- §12 scenario thứ hai không còn chỉ nói ship/pickup.
- `grep -n 'phone_preorder' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` ra kết quả ở **cả
  bốn** chỗ: §3, §4.2, §11, §12.
- Số lát cắt không đổi: `grep -n 'Ba lát cắt\|3 lát cắt'` vẫn ra đúng hai dòng như trước, và không
  có Epic D.
- Khối ghi chú ở cuối §12 nhắc thêm lần sửa này kèm **ngày chạy thật** và nguồn `shop-facts.md`
  §5.2 — vẫn là **một** khối, không phải hai.
- `grep -nE '[0-9]{1,3}\.000|0382688666' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` rỗng.
- `./scripts/gate.sh` xanh.

## Verify

```bash
./scripts/gate.sh
grep -n 'phone_preorder' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md      # §3 · §4.2 · §11 · §12
grep -n 'ship/pickup' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md         # còn lại phải là chỗ nói đúng
grep -n 'Ba lát cắt\|3 lát cắt\|Epic ' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md
grep -c 'Ghi chú' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md             # vẫn 1 khối
grep -nE '[0-9]{1,3}\.000|0382688666' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md   # rỗng
git status --porcelain                                                          # chỉ file trong Scope
```
Gate 2: với mỗi dòng Acceptance, trỏ tới dòng cụ thể trong file chứng minh nó.

## Unknowns

- Không có câu hỏi nghiệp vụ. Luồng `phone_preorder` đã chốt đầy đủ ở `shop-facts.md` §5.2 và có
  trong nhật ký §7.1 (2026-08-30). Việc này là đưa một luồng đã chốt vào đúng chỗ của nó trong
  khung, không phải chốt luật mới.
- Nếu phát hiện **chỗ lệch thứ năm** (một câu ở §5–§8 mô tả luồng chỉ cho hai kênh mang đi, hoặc
  một dòng §9/§10 tương tự): sửa luôn trong cùng lần này và ghi **F-006** vào `work/findings.md` —
  đừng để lại thành task riêng. Đây sẽ là lần thứ ba tài liệu khung lệch với nhà thật (F-003,
  F-005), nên finding phải nói được vì sao hai lần sửa trước không chặn được lần này.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
