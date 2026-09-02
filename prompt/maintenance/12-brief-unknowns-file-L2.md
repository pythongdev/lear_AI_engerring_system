# 12 — Bước 2/5: `scripts/brief.sh` đọc mục Unknowns ở file mới (L2) · DOC-2

> Bộ năm bước của ADR-014: 11 → **12 (đây)** → 13 → 14 → 15(chưa chốt).
> **Bước 1 phải xong trước.** Bước 2 phải xong **trước bước 3** — brief là thứ mọi phiên mới đọc
> đầu tiên, hỏng nó là hỏng mọi phiên sau (ADR-002).

## Context

- Sau bước 1, mục *Unknowns* sống ở `docs/product/99-unknowns.md`. `scripts/brief.sh` vẫn đọc
  `docs/product.md` ở **5 chỗ** (đo 2026-09-02, `grep -n product scripts/brief.sh`):

  | Dòng | Chỗ đó làm gì |
  |---|---|
  | 140 | tiêu đề mục `OPEN UNKNOWNS (docs/product.md → Unknowns)` |
  | 145–151 | khối chú thích *hợp đồng đọc* (ADR-007) + `block docs/product.md '## Unknowns'` |
  | 187 | nhãn chỗ đọc đủ, truyền cho `emit` |
  | 206 | danh sách *OWNER FILES* — lấy ngày sửa cuối bằng `git log` |

- `scripts/brief.test.sh` có **10 chỗ** dựng `docs/product.md` giả để test parser (dòng 43, 134,
  221, 226, 229–230, 295, 389). Sửa `brief.sh` mà không sửa test là làm đỏ Gate 1.
- **Hợp đồng đọc mục Unknowns là ADR-007, không được đổi**: vùng đang mở = đầu mục + mọi khối dưới
  `### Đang mở`; trong vùng đó **một gạch đầu dòng = một câu hỏi**; `U-XXX` nằm đâu trong gạch đầu
  dòng cũng được. `work/findings.md` **F-008** và **F-012** là hai lần mục này đã hỏng.

## Goal

Danh sách *Open unknowns* trong session brief đọc từ `docs/product/99-unknowns.md`, và in ra đúng
cái nó in trước khi tách.

## Scope

Được sửa:
- `scripts/brief.sh`
- `scripts/brief.test.sh`
- `docs/decisions.md` — **chỉ** ô *Trạng thái* của ADR-014
- `work/backlog.md` — **chỉ** mục DOC-2

Không được sửa:
- `docs/product/**` và `docs/product.md` — bước 1 đã chốt hình dạng của chúng
- `CLAUDE.md` — bước 4
- `.claude/settings.json` — brief đã là `SessionStart` hook, không thêm hook thứ hai (CLAUDE.md §3.8)
- Mọi script khác trong `scripts/`

Dòng chép vào `work/scope.txt`:
```text
scripts/brief.sh
scripts/brief.test.sh
docs/decisions.md
work/backlog.md
```

## Constraints

- **Không đổi parser, chỉ đổi đường dẫn.** Thuật toán đọc cấu trúc (ADR-007) giữ nguyên từng dòng
  `awk`. Lượt này mà "tiện tay dọn" parser là gộp hai việc vào một lượt và mất khả năng revert.
- **Brief không bao giờ chặn** (CLAUDE.md §7.1). Mọi đường thoát vẫn `exit 0`, kể cả khi
  `docs/product/99-unknowns.md` **không tồn tại** — lúc đó in `(none)`, không in lỗi, không dừng.
- **Bộ cắt phải giữ nguyên**: `MAX_UNKNOWNS=12`, và khi cắt thì **nói ra là đã cắt** (`→ ĐÃ CẮT`).
  Đây là thứ `work/findings.md` **F-012** đã trả giá — im lặng phải luôn có nghĩa "danh sách hết".
- **Nhãn chỗ đọc đủ phải đổi theo**: `docs/product.md → Unknowns → Đang mở` thành đường dẫn mới.
  Nhãn sai là chỉ người ta tới bản lưu — đúng cái ADR-014 cấm.
- **Dòng 206, `OWNER FILES`**: `docs/product.md` được thay bằng `docs/product/`. Vòng lặp hiện dùng
  `[ -f "$f" ]` — với một thư mục thì điều kiện ấy **false** và dòng biến mất im lặng. Đổi sang
  kiểm tra tồn tại theo kiểu chấp nhận cả thư mục, và `git log -1 -- docs/product/` vẫn cho đúng
  ngày sửa cuối.
- **Bản lưu không được xuất hiện trong `OWNER FILES`.** Nó không còn là owner nào.

## Acceptance

- `./scripts/brief.test.sh` xanh, **không sửa một ca test cũ nào theo hướng nới lỏng**: ca nào đổi
  đường dẫn thì chỉ đổi đường dẫn.
- Ca mới, phải có đủ ba:
  1. `docs/product/99-unknowns.md` có 3 câu dưới `### Đang mở` ⇒ brief in đủ 3.
  2. File ấy **không tồn tại** ⇒ brief in `(none)` và `exit 0`.
  3. Bản lưu `docs/product.md` **vẫn còn** một mục Unknowns cũ ⇒ brief **không** đọc nó.
- 14 câu (2 file × chỗ đọc đủ) `grep -n 'docs/product\.md' scripts/brief.sh scripts/brief.test.sh`
  ⇒ chỉ còn những chỗ **cố ý** nói về bản lưu (ca test số 3); dán kết quả grep ra Report.
- Mục *OWNER FILES* in `docs/product/` kèm một ngày thật, không phải `uncommitted` sai.
- `./scripts/brief.sh` exit 0 khi xoá tạm `docs/product/` — dán output.
- `./scripts/gate.sh` xanh.

## Verify

```bash
./scripts/brief.test.sh; echo "exit=$?"

# brief không bao giờ chặn
mv docs/product /tmp/p && ./scripts/brief.sh; echo "exit=$?"; mv /tmp/p docs/product

grep -n 'docs/product\.md' scripts/brief.sh scripts/brief.test.sh
./scripts/brief.sh | sed -n '/OPEN UNKNOWNS/,/^$/p'
./scripts/gate.sh; echo "exit=$?"
git status --porcelain      # cây làm việc trở lại đúng như trước khi thử
```
Dán **output thật** của từng lệnh vào Report — "tôi đã chạy rồi" không phải bằng chứng
(`quality/review-gate.md` Gate 2).

## Unknowns

- Không có câu hỏi nghiệp vụ.
- Nếu phát hiện parser ADR-007 có lỗi trong lúc làm: **ghi finding, đừng sửa ở đây.** Sửa parser là
  một task khác, có acceptance khác.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
