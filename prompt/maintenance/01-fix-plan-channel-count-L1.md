# 01 — Kế hoạch gốc còn nói "bốn kênh bán" (L1) · T-007

## Context

- `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` là **khung** giai đoạn BA (11 task, 3 lát
  cắt, 12 quy tắc, 14 ngoại lệ, 10 câu hỏi). Nó **không** sở hữu dữ kiện quán nào — nhà duy nhất
  là `master_plan/shop-facts.md` (ADR-001).
- Kế hoạch gốc viết **trước** ngày chủ quán chốt kênh thứ năm. `phone_preorder` được chốt
  2026-08-24 và sửa tên 2026-08-29 (`shop-facts.md` §2 và §7.1), nên kế hoạch gốc vẫn đang nói bốn.
- Ba chỗ lệch, tính tới 2026-08-30:

  | Dòng | Đang viết | Vấn đề |
  |---|---|---|
  | §2.2 dòng 42–45 | liệt kê 4 kênh, thiếu `phone_preorder` | người đọc tưởng quán bán qua 4 đường |
  | §11 dòng 260 | BA-02 "Chốt **bốn** kênh bán" | task nói sai việc phải làm |
  | §12 dòng 277 | cổng chất lượng "Có **4** kênh bán rõ ràng" | **nguy hiểm nhất** |

- Dòng 277 nguy hiểm nhất vì §12 là **cổng chất lượng của cả giai đoạn BA**: BA-11 (prompt
  `prompt/BA/10-acceptance-scenarios-L2.md`) tick theo danh sách đó. Tick "đủ 4 kênh" là đóng
  giai đoạn BA trong lúc một kênh thật chưa được nghiệm thu.
- `docs/product.md` §2 và `shop-facts.md` §2 **đã đúng** (năm kênh) — không đụng vào chúng.
- Đây là lần thứ hai một con số đếm trong tài liệu lệch với owner; lần đầu là
  `work/findings.md` F-003.

## Goal

Không còn chỗ nào trong kế hoạch gốc nói quán bán qua bốn kênh, và người đọc §12 nghiệm thu được
đúng năm kênh.

## Scope

Được sửa:
- `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`
- `work/findings.md` (thêm F-005)
- `work/backlog.md` (ô trạng thái T-007)

Không được sửa:
- `master_plan/shop-facts.md` (đang đúng, là nhà thật)
- `docs/product.md`, `docs/decisions.md`, `quality/invariants.md`
- `prompt/BA/*` (đã sửa xong ở T-004/T-005)

Dòng chép vào `work/scope.txt`:
```text
master_plan/BA_initial_plan_banh_cuon_ba_thanh.md
work/findings.md
work/backlog.md
work/scope.txt
```

## Constraints

- **Đừng chép bảng kênh vào kế hoạch gốc.** Nó là khung, không phải nhà. Chỗ cần danh sách kênh
  thì **trỏ** `master_plan/shop-facts.md` §2 (ADR-001, F-001: một bản chép có kèm cảnh báo vẫn là
  một bản chép).
- Viết "**năm** kênh" là được phép, vì đó là **quyết định của chủ quán** — "đúng năm, không có
  kênh thứ sáu" (`shop-facts.md` §2). Đây đúng loại đếm mà F-003 cho phép ghi là "đúng N".
- Không đổi ID `BA-01`–`BA-11`, không đổi cột "Cần xong trước" ở §11, không thêm/bớt dòng nào của
  bảng §11 và của checklist §12 ngoài dòng đang nói sai số kênh.
- Sửa xong phải để lại **vết ngày tháng** ngay tại chỗ sửa (một dòng ghi chú là đủ): phiên sau đọc
  §12 phải biết mục này từng nói 4 và được sửa 2026-08-30 theo `shop-facts.md` §2 — nếu không, lần
  đọc sau sẽ tưởng kế hoạch gốc xưa nay vẫn nói năm, và không hiểu vì sao có finding về nó.
- Kế hoạch gốc bị nhiều prompt khác ghi là "input, không được sửa"
  (`prompt/BA/00-master-L3.md` → Scope). **Prompt này là chỗ cho phép duy nhất**, và chỉ cho phép
  đúng việc sửa số kênh; đừng nhân tiện viết lại gì khác trong file đó.

## Acceptance

- `grep -nEi 'bốn kênh|4 kênh' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` **không ra kết
  quả**.
- §2.2 hoặc liệt kê đủ **năm** kênh đúng tên ở `shop-facts.md` §2, hoặc bỏ liệt kê và trỏ thẳng về
  `shop-facts.md` §2 — không được liệt kê nửa vời.
- Dòng BA-02 ở §11 nói **năm** kênh; các cột còn lại của dòng đó không đổi.
- Mục cổng chất lượng ở §12 nói **năm** kênh và trỏ được về nhà thật.
- Có đúng một dòng ghi chú nêu: đã sửa **2026-08-30**, vì kênh thứ năm được chủ quán chốt
  2026-08-24 (sửa tên 2026-08-29), nguồn `shop-facts.md` §2 · §7.1.
- Kế hoạch gốc **không** chứa bảng giá, bảng kênh chi tiết hay bất kỳ con số tiền nào.
- `work/findings.md` có **F-005** theo template sẵn có, nội dung là bài học *tổng quát hơn F-003*:
  khi một con số trong `shop-facts.md` đổi, phải `grep` cả **tài liệu khung** — không chỉ các file
  đang tra cứu số. Nêu đích danh ca này: kênh thứ năm chốt 2026-08-24 mà cổng chất lượng §12 vẫn
  nói 4 tới tận 2026-08-30, tức lệch **sáu ngày** mà không ai thấy.
- `./scripts/gate.sh` xanh.

## Verify

```bash
./scripts/gate.sh
grep -nEi 'bốn kênh|4 kênh' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md   # rỗng
grep -n 'năm kênh\|5 kênh' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md
grep -n 'phone_preorder\|hotline\|đặt trước' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md
grep -n '^### F-005' work/findings.md
grep -nE '[0-9]{1,3}\.000' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md    # rỗng: không chép giá
git status --porcelain                                                          # chỉ file trong Scope
```
Gate 2: với mỗi dòng Acceptance, trỏ tới dòng cụ thể trong file chứng minh nó.

## Unknowns

- Không có câu hỏi nghiệp vụ nào. Việc này là sửa pointer, không phải chốt luật.
- Nếu trong lúc sửa phát hiện **chỗ thứ tư** cũng lệch (ví dụ một câu ở §3, §4 mô tả luồng chỉ
  cho bốn kênh): sửa luôn trong cùng lần này và ghi vào F-005 — đừng để lại thành task riêng.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
