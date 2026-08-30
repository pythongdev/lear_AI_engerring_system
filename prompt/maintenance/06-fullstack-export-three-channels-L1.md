# 06 — `prompt-fullstack.md` vẫn nói "4 kênh" và "luồng ship/pickup khác 3 điểm" (L1) · T-013

## Context

- `master_plan/prompt-fullstack.md` là **bản xuất khẩu** cho agent **ngoài** repo: nó tự khai ở đầu
  file *"File này là bản xuất khẩu, không phải nhà của sự thật nào… Là bản chép nên nó **sẽ trôi**"*.
  Nhà thật của mọi dữ kiện quán vẫn là `master_plan/shop-facts.md` (ADR-001).
- Nó đã có sẵn một khối cảnh báo ở §3.1: *"⚠️ Hai chỗ file này từng chép sai, đã gỡ: 'bốn kênh bán'
  (đúng là **năm**…). **Thấy chúng quay lại là bug.**"* — và ngay trong cùng file, con số bốn vẫn
  còn sống. Tính tới 2026-08-30:

  | Dòng | Đang viết | Vấn đề |
  |---|---|---|
  | 301 (§7 bảng sáu pha, hàng **0 · BA**) | "**4 kênh bán** · **2 sơ đồ luồng** (tại bàn, ship)" | **nặng nhất**: đây là đầu ra bắt buộc của pha BA. Agent ngoài repo giao đúng bốn kênh rồi coi pha BA là xong |
  | 97 | "Luồng ship/pickup khác **3 điểm**: cần SĐT, không có phiên bàn, có bước đóng gói" | hai kênh thay vì ba, và **ba điểm** thay vì bảy (`shop-facts.md` §5.2) |
  | 200 | "**B. Một đơn ship** | khách web đặt → Telegram báo → quầy duyệt → hoàn thành" | lát cắt B kể một kênh; `phone_preorder` không qua "khách web đặt" và không qua "quầy duyệt" |
  | 37 | "Web đặt hàng | Khách ship / đặt trước tới lấy" | bảng kênh vào hệ thống, thiếu đường điện thoại |

- Đúng hai finding đã ghi: **F-003** (một con số đếm là *tóm tắt của người viết* thì không được viết
  như thể đã đủ — "khác 3 điểm" là loại đó; `shop-facts.md` §5.2 nay ghi **bảy** điểm kèm mốc thời
  gian và lời mời bổ sung) và **F-006** (chỗ lệch không chứa con số thì grep theo số không thấy).
- Chỗ này còn chứng minh thêm một điều F-001 đã nói: dòng 301 sống sót **ngay dưới** khối cảnh báo
  viết ở cùng file. Cảnh báo không cứu được bản chép.

## Goal

`master_plan/prompt-fullstack.md` không còn chỗ nào nói quán bán bốn kênh, và mọi chỗ mô tả luồng
mang đi đều phủ ba kênh không gắn bàn — để một agent **ngoài** repo nhận file này không dựng thiếu
một kênh.

## Scope

Được sửa:
- `master_plan/prompt-fullstack.md`
- `work/backlog.md` (ô trạng thái T-013)
- `work/findings.md` (F-007 — xem *Unknowns*)

Không được sửa:
- `master_plan/shop-facts.md` (nhà thật, đang đúng)
- `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` (T-011 đã sửa xong)
- `prompt/**`, `docs/**`, `quality/**`, `scripts/**`

Dòng chép vào `work/scope.txt`:
```text
master_plan/prompt-fullstack.md
work/backlog.md
work/findings.md
work/scope.txt
```

## Constraints

- **File này không được chứa dữ kiện quán.** Nó tự đặt luật đó ở §3.1: *"Không có con số nào ở
  đây."* Nên chỗ cần danh sách kênh thì **trỏ** `shop-facts.md` §2, chỗ cần luồng thì trỏ §5.2 —
  đừng chép bảng kênh, đừng chép bảy điểm khác biệt, đừng chép giá, đừng chép hotline.
- **Bỏ con số "3 điểm" ở dòng 97, đừng thay bằng "7 điểm".** F-003: đếm là tóm tắt của người viết
  thì không được viết như một khẳng định đã đủ, và bản xuất khẩu lại càng không nên giữ một con số
  sẽ trôi. Viết một câu nêu **khác biệt cốt lõi** rồi trỏ `shop-facts.md` §5.2 cho danh sách đầy đủ.
- **Giữ nguyên số lát cắt ở §5** — vẫn ba lát cắt A/B/C như kế hoạch gốc; mở rộng B, không thêm D.
- **Không đổi stack, version, cổng, sơ đồ 16 bảng ở §3.5, hay bất kỳ hàng nào khác của bảng sáu pha
  §7.** Chỉ ô "Đầu ra bắt buộc" của hàng **0 · BA** được sửa.
- Không đổi cấu trúc §1 → §10, không thêm mục mới, không đổi cách dùng file ghi ở đầu.
- Sửa xong thì **cập nhật khối ⚠️ ở §3.1** để nó ghi đúng: lần này con số bốn được tìm thấy ở đâu và
  ngày nào — vẫn **một** khối, đừng tạo khối cảnh báo thứ hai.

## Acceptance

- `grep -n '4 kênh\|bốn kênh' master_plan/prompt-fullstack.md` — không còn chỗ nào **khẳng định**
  quán có bốn kênh; kết quả duy nhất được phép còn lại là khối ⚠️ §3.1 kể lại lỗi cũ.
- Ô "Đầu ra bắt buộc" của hàng **0 · BA** ở §7 nói **năm** kênh (hoặc trỏ `shop-facts.md` §2) và
  **hai** sơ đồ luồng đúng tên: tại bàn và **mang đi** — không phải "ship".
- Dòng 97 không còn con số "3 điểm" và không còn gọi luồng bằng hai kênh; có một dòng trỏ
  `shop-facts.md` §5.2.
- Lát cắt **B** ở §5 mang tên phủ ba kênh, và câu mô tả nói được `phone_preorder` vào hệ thống bằng
  đường nhân viên nhập hộ, **không** qua bước quầy duyệt (`shop-facts.md` §5.2).
- Bảng đường vào hệ thống (dòng 37) có đường đặt qua điện thoại.
- `grep -nE '[0-9]{1,3}\.000|0382688666' master_plan/prompt-fullstack.md` rỗng.
- `grep -c '⚠️' master_plan/prompt-fullstack.md` — vẫn đúng **một** khối cảnh báo ở §3.1.
- `./scripts/gate.sh` xanh.

## Verify

```bash
./scripts/gate.sh
grep -n '4 kênh\|bốn kênh\|Năm\|năm kênh' master_plan/prompt-fullstack.md
grep -n -i 'ship\|pickup\|mang đi\|phone_preorder' master_plan/prompt-fullstack.md
grep -n '3 điểm\|ba điểm\|7 điểm\|bảy điểm' master_plan/prompt-fullstack.md   # rỗng
grep -nE '[0-9]{1,3}\.000|0382688666' master_plan/prompt-fullstack.md          # rỗng
git status --porcelain
```
Gate 2: với mỗi dòng Acceptance, trỏ tới dòng cụ thể trong file chứng minh nó.

## Unknowns

- Không có câu hỏi nghiệp vụ.
- **Có một vấn đề lớn hơn trong cùng file, và task này KHÔNG sửa nó.** Phần đầu
  `prompt-fullstack.md` trỏ tới bốn đường **không tồn tại** trong repo này:
  `design/data_base/01-thiet-ke.md`, `design/backend/01-thiet-ke.md`,
  `design/frontend/01-thiet-ke.md`, `design/system_design/01-thiet-ke.md`, cùng với
  `quality/05-checklist.md`, `quality/prompt_guiline.md` và `finding.md#f-67`. Kiểm chứng bằng
  `ls design quality/05-checklist.md finding.md quality/prompt_guiline.md`.
  - Đây **không** phải lỗi chữ mà là câu hỏi *file này còn thuộc dự án nào* — sửa từng link là đoán
    hộ. Ghi thành **F-007** trong `work/findings.md` (pointer trỏ vào hư không ở một bản xuất khẩu
    còn nguy hơn ở tài liệu nội bộ: người đọc nó **ở ngoài repo**, không có cách nào biết link
    hỏng), rồi thêm **một dòng Ready** trong `work/backlog.md` cho task sau. Không sửa link trong
    lần này.
  - Nếu `ls` cho thấy các đường đó **có** tồn tại, thì không có F-007 — ghi lại kết quả `ls` trong
    Report và bỏ qua mục này.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
