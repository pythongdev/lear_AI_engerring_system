# Backend — luật phân định trong lane BE

> Cập nhật **2026-08-19** · Lane sở hữu: **BE** ([CLAUDE.md §1](../../CLAUDE.md)).
> **File này không giữ sự thật nào về backend** — sự thật nằm ở bốn file `01`–`04` cạnh đây (cộng
> [nghien-cuu-cau-truc.md](nghien-cuu-cau-truc.md), file *giải thích*, không phải file luật), và
> **lệch ⇒ code trong [code/be/](../../code/be/) thắng** ([CLAUDE.md §2](../../CLAUDE.md)).
> Nó giữ đúng một thứ chưa có nhà ở đâu khác: **một câu mới thì viết vào file nào ở thư mục
> này, và cái gì nghe như BE nhưng là nhà của lane khác.**
> Gói nạp + biên nhận của lane BE ở [04-yeu-cau.md](04-yeu-cau.md) — không chép về đây.

## 1. Một câu mới thì viết vào file nào

Bốn câu hỏi, hỏi **theo thứ tự**, dừng ở câu đầu tiên trả lời "có":

| # | Câu văn đang nói gì | Nhà | Ai thắng khi lệch |
|---|---------------------|-----|-------------------|
| 1 | **Sẽ** xây thế nào — ý định, chưa chắc đã có code | [01-thiet-ke.md](01-thiet-ke.md) | 01, trừ khi `code/be/` đã chạy khác ⇒ mở [finding](../../finding.md) |
| 2 | Thế nào là **đúng / xong**, quy được về một lệnh | [02-luat.md](02-luat.md) | 02 |
| 3 | **Đang** có gì, đang thiếu gì, ngay lúc này | [03-hien-trang.md](03-hien-trang.md) | code trong [code/be/](../../code/be/) |
| 4 | Session BE phải biết gì **trước khi** chạm `code/be/` | [04-yeu-cau.md](04-yeu-cau.md) | 04 |
| 5 | **Vì sao** đã chốt như thế: bằng chứng ngoài repo + phương án đã loại | [nghien-cuu-cau-truc.md](nghien-cuu-cau-truc.md) | 01 và 04 — file 5 chỉ giải thích, không ra luật |

Hai câu cùng "có" ⇒ câu văn đang trộn hai sự thật: **chẻ ra**, đừng chép vào cả hai
([§2.1](../../CLAUDE.md)). Không câu nào "có" ⇒ nó không phải sự thật của lane này — xem mục 2.

Ranh giới hay bị nhầm nhất là **1 ↔ 3**: *"sẽ có module `internal/vision/`"* thuộc 01, *"hiện chưa
có module đó"* thuộc 03. Viết cả hai vế vào một file là cách thiết kế và hiện trạng dính vào nhau,
rồi không ai biết dòng đó đang mô tả code hay mô tả dự định.

Ranh giới **1 ↔ 5** ngắn hơn nhưng dễ trượt: 01 nói ***làm gì***, file 5 nói ***vì sao không làm cách
kia***. *"`store` của module là kiểu không xuất khẩu"* thuộc 01; *"đã cân nhắc `gocv` rồi loại vì
crash tầng C giết cả luồng đặt đơn"* thuộc file 5. Nhét vế thứ hai vào 01 là cách 01 phình lên gấp
đôi trong một năm, và mọi session BE sau đều phải nạp nó.

## 2. Nghe như BE nhưng không phải nhà của nó

| Thứ đang định viết | Nhà thật | Lane sở hữu |
|--------------------|----------|-------------|
| Bảng, cột, index, ràng buộc, migration | [design/data_base/](../data_base/01-thiet-ke.md) + `code/be/migrations/` | DB |
| Lệnh kiểm tra (`check`, `test-int`) | [Makefile](../../Makefile) | DEVOPS |
| Hợp đồng đường dẫn + kiểu dữ liệu cho FE | `code/be/api/openapi.yaml` — quy tắc ở [02-luat.md §6](02-luat.md) | BE viết, FE sinh type ([§8](../../CLAUDE.md)) |
| Màn hình gọi API, giỏ hàng, QR bàn | [design/frontend/](../frontend/01-thiet-ke.md) | FE |
| Việc tiếp theo, thứ tự làm | [task.md](../../task.md) | theo lane của dòng task |
| Cái đang sai ngay bây giờ | [finding.md](../../finding.md) | lane ghi ở cột *Lane* |
| **Con số** — số file, số test, phiên bản Go | `make status` mục *BACKEND* | derive được ⇒ cấm chép ([§10](../../CLAUDE.md)) |

Chạm file của lane khác — kể cả một dòng — là việc của lane đó: mở finding + task, đừng tiện tay
([§2.4](../../CLAUDE.md)).

## 3. Biên nhận đọc lại — soi lệch giữa bốn file

`make status` chỉ kiểm **đích của link**, không kiểm **câu văn quanh link**: một header khai sai về
file *có thật* thì nó im lặng (hình dạng [F-62](../../finding.md#f-62)). Ba lệnh dưới bù đúng chỗ
đó, chạy từ gốc repo:

```bash
# a. ngày trong header vs commit cuối của chính file — lệch ⇒ kiểm bằng code trước khi tin (§10)
for f in design/backend/0*.md; do printf '%-34s doc=%s  git=%s\n' "$f" \
  "$(grep -m1 -oE 'Cập nhật \*\*[0-9-]+' "$f" | grep -oE '[0-9-]+$')" \
  "$(git log -1 --format=%ad --date=short -- "$f")"; done

# b. lời khai về sự tồn tại của ba file anh em — phải rỗng, còn hit ⇒ đọc finding của lane BE
grep -n 'chưa tạo\|đặt trước' design/backend/0*.md

# c. 03 là ảnh chụp, không phải bảng số — phải rỗng (§10, F-13, F-40)
grep -nE '[0-9]+ (test|file|bảng|endpoint|hàm)|Go 1\.' design/backend/03-hien-trang.md
```

Cả ba đều quét `0*.md` hoặc một file cụ thể, **không** quét `*.md`: file này chứa chính những
chuỗi đang tìm, để `*.md` là lệnh tự bắt mình và luôn ra kết quả giả — đúng cái bẫy
[F-60](../../finding.md#f-60) đã trả giá.
