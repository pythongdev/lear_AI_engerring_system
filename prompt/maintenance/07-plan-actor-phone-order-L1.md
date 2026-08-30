# 07 — §2.1 kế hoạch gốc: khách gọi điện đặt trước không có trong danh sách việc khách làm (L1) · T-014

## Context

- `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §2.1 *Người dùng chính* liệt kê việc từng
  nhóm actor làm. Tính tới 2026-08-30, hai chỗ còn thiếu đúng kênh `phone_preorder`:

  | Chỗ | Đang viết | Thiếu |
  |---|---|---|
  | §2.1 · **Khách hàng** | "Đặt ship. · Đặt trước để tới lấy. · Quét QR tại bàn." | khách **gọi điện** đặt trước |
  | §2.1 · **Nhân viên quán** | "Nhận/xác nhận đơn. · Đặt món hộ khách. · …" | "Đặt món hộ khách" là đặt hộ **tại quầy** (`staff_pos`); nhập hộ đơn **qua điện thoại** là việc khác, có thêm nghĩa vụ hỏi giao-hay-lấy và mấy giờ |

- **Cả nhà thật lẫn tài liệu tra cứu đều đã đúng**, chỉ khung là thiếu:
  - `master_plan/shop-facts.md` §5.2 — `phone_preorder`: *"khách gọi 0382688666, nhân viên nhập hộ
    ⇒ không cần duyệt; nhân viên PHẢI hỏi: giao tận nơi hay tới lấy, và cần lúc mấy giờ"* (chủ quán
    chốt 2026-08-30).
  - `docs/product.md` §1.1 đã có *"**Gọi hotline để đặt trước**; khách nói, nhân viên nhập hộ vào
    hệ thống"*, và §1.2 đã có *"**Nhập hộ đơn đặt trước qua điện thoại**, và khi nhận điện thoại
    **phải hỏi**…"* (BA-01, chốt 2026-08-30).
- Nghĩa là §2.1 đang mâu thuẫn với chính tài liệu mà nó là nguồn khung — `docs/product.md` §1 ghi
  nguồn là *"kế hoạch gốc §2.1 (khung actor) + `shop-facts.md`"*. Phần `shop-facts.md` cứu được
  BA-01; lần sau ai đọc §2.1 mà không đọc `shop-facts.md` thì không có gì cứu.
- **Đây là chỗ lệch thứ bảy** của cùng một kênh trong cùng một file. T-011 cố ý không sửa: vòng rà
  của nó giới hạn ở §3, §4.2, §5–§8, §9/§10, §11, §12 — §2.1 nằm ngoài. Lý do và luật chung ở
  `work/findings.md` **F-006** (grep theo **định danh** kênh, không theo con số).

## Goal

§2.1 kế hoạch gốc liệt kê đủ việc khách và nhân viên làm với kênh `phone_preorder`, và không còn
mâu thuẫn với `docs/product.md` §1.1 · §1.2.

## Scope

Được sửa:
- `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` — **chỉ §2.1**
- `work/backlog.md` (ô trạng thái T-014)

Không được sửa:
- `master_plan/shop-facts.md` (nhà thật, đang đúng)
- `docs/product.md` (BA-01 đã chốt, đang đúng — task này đi theo nó, không sửa nó)
- §2.2 và mọi mục khác của kế hoạch gốc (T-007 và T-011 đã sửa xong)
- `prompt/**`, `quality/**`, `docs/decisions.md`

Dòng chép vào `work/scope.txt`:
```text
master_plan/BA_initial_plan_banh_cuon_ba_thanh.md
work/backlog.md
work/scope.txt
```

## Constraints

- **§2.1 là danh sách "ai làm gì", không phải bảng kênh.** Đừng chép bảng kênh vào đây — §2.2 đã là
  một câu trỏ về `shop-facts.md` §2 kể từ T-007, và phải giữ nguyên như vậy (ADR-001, F-001).
- **Vẫn đúng ba nhóm actor** — Khách hàng, Nhân viên quán, Chủ quán. Không thêm nhóm thứ tư (người
  gọi điện vẫn là *khách hàng*), không đổi thứ tự đánh số 1–2–3.
- **Không chép số hotline**, không chép giá, không chép giờ bán.
- Giữ đúng mức chi tiết đang có: mỗi dòng là một gạch đầu dòng ngắn, một việc. §2.1 không phải chỗ
  mô tả luồng — luồng ở §4.2, chi tiết ở `shop-facts.md` §5.2.
- **Đừng viết lại §2.1 cho "gọn hơn".** Chỉ thêm việc còn thiếu; các dòng đang có giữ nguyên chữ.
- Nghĩa vụ *"nhân viên phải hỏi giao tận nơi hay tới lấy, và mấy giờ"* được nêu ở mức một dòng và
  **trỏ** `shop-facts.md` §5.2; không chép cả sơ đồ.

## Acceptance

- §2.1 nhóm **Khách hàng** có một dòng nói khách gọi điện đặt trước, và nói rõ khách **không tự
  bấm** — nhân viên nhập hộ.
- §2.1 nhóm **Nhân viên quán** có một dòng phân biệt nhập hộ đơn **qua điện thoại** với đặt hộ
  **tại quầy**, kèm nghĩa vụ hỏi giao-hay-lấy và mấy giờ, kèm một dòng trỏ `shop-facts.md` §5.2.
- Ba dòng cũ của nhóm Khách hàng ("Đặt ship", "Đặt trước để tới lấy", "Quét QR tại bàn") **còn
  nguyên**, không bị gộp hay viết lại.
- Vẫn đúng ba nhóm actor, đánh số 1–2–3 không đổi.
- §2.2 **không đổi một ký tự** — vẫn là câu trỏ về `shop-facts.md` §2.
- Không có câu nào ở §2.1 mâu thuẫn với `docs/product.md` §1.1 · §1.2; đọc chéo hai chỗ và nói
  trong Report là đã đọc.
- `grep -nE '[0-9]{1,3}\.000|0382688666' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` rỗng.
- `./scripts/gate.sh` xanh.

## Verify

```bash
./scripts/gate.sh
sed -n '/^### 2.1/,/^### 2.2/p' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md
sed -n '/^### 2.2/,/^## 3\./p'  master_plan/BA_initial_plan_banh_cuon_ba_thanh.md   # phải không đổi
git diff -- master_plan/BA_initial_plan_banh_cuon_ba_thanh.md                       # chỉ chạm §2.1
grep -nE '[0-9]{1,3}\.000|0382688666' master_plan/BA_initial_plan_banh_cuon_ba_thanh.md   # rỗng
git status --porcelain
```
Gate 2: với mỗi dòng Acceptance, trỏ tới dòng cụ thể trong file chứng minh nó.

## Unknowns

- Không có câu hỏi nghiệp vụ. Việc khách gọi điện và nghĩa vụ của nhân viên lúc nhận máy đã chốt
  đầy đủ ở `shop-facts.md` §5.2 và có trong nhật ký §7.1 (2026-08-30). Task này chép một việc **đã
  chốt** vào đúng chỗ của nó trong khung, không chốt luật mới.
- Nếu tìm thấy chỗ lệch **thứ tám** trong cùng file (một mục nào đó ở §1 hoặc §13–§14 kể việc của
  khách/nhân viên mà bỏ đường điện thoại): sửa luôn trong cùng lần này và **nối thêm vào F-006** —
  cùng một con bug, đừng mở finding mới.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
