# 14 — Bước 4/5: `CLAUDE.md` trỏ owner mới (L1) · DOC-4

> Bộ năm bước của ADR-014: 11 → 12 → 13 → **14 (đây)** → 15(chưa chốt).
> Chạy sau bước 3. Nhỏ nhưng **không được bỏ**: `CLAUDE.md` là file mọi phiên đọc trước tiên, nên
> nó là chỗ cuối cùng còn có thể gửi cả repo về đọc bản lưu.

## Context

`CLAUDE.md` có **6 chỗ** nêu `docs/product.md` (đo 2026-09-02, `grep -n "docs/product" CLAUDE.md`):

| Dòng | Chỗ đó là gì |
|---|---|
| 29 | bảng §2 — hàng *Business rules, product behavior* |
| 30 | bảng §2 — hàng *Open business questions (unknowns)* |
| 135 | bảng §4 — chỗ ghi một câu hỏi nghiệp vụ mở |
| 149 | §4 — câu trỏ tới hợp đồng viết *Cách viết một câu ở đây* |
| 370 | §7.3 — **ví dụ** một dòng link trong report |
| 374 | §7.3 — câu liệt kê các loại "thứ còn treo" |

Ngoài ra §2 có **khối cây thư mục** (`docs/ product, architecture, decisions, prompt guideline`)
chưa nói tới folder mới.

## Goal

Một phiên mới đọc `CLAUDE.md` tìm ra owner của *hành vi nghiệp vụ* và của *câu hỏi mở* mà **không**
đi qua `docs/product.md`.

## Scope

Được sửa:
- `CLAUDE.md` — §2 (bảng owner + khối cây thư mục), §4 (bảng route + câu §149), §7.3 (dòng ví dụ)
- `docs/decisions.md` — **chỉ** ô *Trạng thái* của ADR-014
- `work/backlog.md` — **chỉ** mục DOC-4

Không được sửa:
- Mọi file khác. Bước 3 đã dọn xong phần còn lại; nếu còn sót thì đó là bug của bước 3, ghi lại,
  đừng vá ở đây.
- **Cấu trúc §2**: task này đổi **giá trị** trong ô owner, không thêm/bớt hàng. Một loại sự thật
  mới mới được thêm hàng (CLAUDE.md §7.2).

Dòng chép vào `work/scope.txt`:
```text
CLAUDE.md
docs/decisions.md
work/backlog.md
```

## Constraints

- **Hàng §2 *Business rules* trỏ `docs/product/`** (cả folder), không trỏ một file con — owner là
  folder, chọn file nào là việc của `00-index.md`.
- **Hàng §2 *Open business questions* và bảng §4 trỏ đúng file unknowns mới**, vì `scripts/brief.sh`
  đọc đúng file ấy (bước 2). Hai chỗ này lệch nhau là hỏng ADR-007.
- **Dòng 370 là *ví dụ*, không phải pointer thật.** Nó minh hoạ hình dạng một link trong report.
  Đổi cho khớp thực tế, nhưng đừng biến nó thành một link phải mở được — nó nằm trong khối ví dụ.
- **`docs/product.md` không được xuất hiện trong `CLAUDE.md` như một owner.** Nếu muốn nhắc rằng
  có một bản lưu, viết nó là *bản lưu*, đúng một câu, và không có link.
- Gate 1b **có** chấm `CLAUDE.md`: mọi đường dẫn mới phải mở được.

## Acceptance

- `grep -n "docs/product" CLAUDE.md` ⇒ không dòng nào còn là `docs/product.md` **trừ** dòng nói
  đích danh về bản lưu (nếu có, tối đa một). Dán kết quả grep ra Report.
- Bảng §2 nói `docs/product/`; khối cây thư mục §2 nói tới folder mới.
- Bảng §4 và câu §149 trỏ cùng một file unknowns, và đúng file mà `scripts/brief.sh` đang đọc —
  đối chiếu bằng `grep -n unknowns scripts/brief.sh`.
- `./scripts/gate.sh` xanh (Gate 1b chấm `CLAUDE.md`).
- ADR-014 ô *Trạng thái*: bốn lượt xong, còn lại lượt 5 chưa chốt.

## Verify

```bash
grep -n "docs/product" CLAUDE.md
grep -n "unknowns" scripts/brief.sh | head
./scripts/gate.sh; echo "exit=$?"
./scripts/brief.sh | sed -n '/OPEN UNKNOWNS/,/^$/p'
```

## Unknowns

- Không có câu hỏi nghiệp vụ.
- Việc **commit** do người dùng quyết (CLAUDE.md §6).

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
