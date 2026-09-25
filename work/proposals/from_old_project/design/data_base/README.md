# design/data_base — nhà của bốn sự thật DB

> Cập nhật **2026-08-19** · Lane sở hữu: **DB** ([CLAUDE.md §1](../../CLAUDE.md)).
>
> **File này không giữ sự thật DB nào.** Thiết kế, thước, hiện trạng, luật lane đều có nhà riêng ở
> bốn file cạnh đây, và mỗi file đã tự link sang ba file kia — chép lại ở đây là đẻ nhà thứ hai
> ([CLAUDE.md §2.1](../../CLAUDE.md)). Nó giữ đúng ba thứ chưa có nhà ở đâu khác: **một câu mới thì
> viết vào file nào** (§1), **lệch nhau thì ai thắng** (§2), **lệnh chứng minh bốn file còn khớp
> `code/be/migrations/`** (§3).
>
> Muốn bắt tay vào việc thì đừng đọc file này — gói nạp bắt buộc của lane DB là
> [04-yeu-cau.md](04-yeu-cau.md) ([CLAUDE.md §1](../../CLAUDE.md)).

---

## 1. Một câu mới thì viết vào file nào

Hỏi **"đây là loại sự thật gì"**, không hỏi "nó nói về bảng nào". Cùng một bảng đẻ ra sự thật thuộc
cả bốn nhà: *`orders` sẽ có cột `channel`* (01) · *`channel` phải là `ENUM`, không phải `VARCHAR`*
(02) · *`channel` đã có trong `000003`* (03) · *đổi `channel` thì viết migration mới, đừng sửa
`000003`* (04).

| # | Câu văn đang nói gì | Nhà | Dấu nhận biết |
|---|---------------------|-----|---------------|
| 1 | **Sẽ** có bảng/cột/quan hệ nào, vì sao mô hình như vậy | [01-thiet-ke.md](01-thiet-ke.md) | Câu mở đầu bằng *"sẽ có…"* / *"gồm…"*, giải thích **ý định** |
| 2 | Thế nào là **đúng** ở tầng DB, quy được về một ràng buộc hoặc một lệnh | [02-luat.md](02-luat.md) | Có **ngưỡng**, kiểu dữ liệu bắt buộc, hoặc tên ràng buộc |
| 3 | **Đang** có gì trong `code/be/migrations/`, đang thiếu gì | [03-hien-trang.md](03-hien-trang.md) | Kiểm được bằng lệnh chạy trên repo **hôm nay** |
| 4 | Session DB phải biết gì **trước khi** chạm `.sql` | [04-yeu-cau.md](04-yeu-cau.md) | Nói với **agent**, không nói về schema |

Hai dòng cùng "có" ⇒ câu văn đang trộn hai sự thật: **chẻ ra**, đừng chép vào cả hai
([§2.1](../../CLAUDE.md)). Ranh giới hay nhầm nhất là **1 ↔ 3**: *"sẽ tách bảng `payments`"* thuộc
01, *"`payments` đã có từ `000003`"* thuộc 03. Viết cả hai vế vào một file là cách ý định và hiện
trạng dính vào nhau, rồi không ai biết dòng đó đang mô tả schema hay mô tả dự định.

Không dòng nào "có" ⇒ nó không phải sự thật của thư mục này:

| Thứ đang định viết | Nhà thật | Lane sở hữu |
|--------------------|----------|-------------|
| Query, transaction, struct Go đọc/ghi bảng | [design/backend/](../backend/01-thiet-ke.md) + `code/be/` | BE |
| Lệnh chạy MySQL, `test-int`, backup, cổng | [Makefile](../../Makefile) + [deploy/](../../deploy/) | DEVOPS |
| Giá món, menu, phạm vi đã chốt | [00-scope.md](../../project_preparation/00-scope.md) | NON-CODE |
| Cái đang **sai ngay bây giờ** | [finding.md](../../finding.md) — phép thử finding↔task ở [§7](../../CLAUDE.md) | lane ghi ở cột *Lane* |
| Việc **chưa tới lượt** xây | [task.md](../../task.md) + [step.md](../../step.md) | theo lane dòng task |
| **Con số** — số bảng, số migration, số index | lệnh ở §3 dưới đây | derive được ⇒ cấm chép ([§10](../../CLAUDE.md)) |

Chạm file của lane khác — kể cả một dòng — là việc của lane đó: mở finding + task, đừng tiện tay
([§2.4](../../CLAUDE.md)).

## 2. Lệch nhau thì ai thắng

Thư mục này khác `design/backend/` và `design/frontend/` ở một điểm quyết định: **sự thật của nó đã
chạy thật**. `code/be/migrations/` không phải kế hoạch, nó là schema đang sống trong MySQL. Nên ở đây
[CLAUDE.md §2](../../CLAUDE.md) (*code thắng tài liệu*) không phải luật dự phòng — nó là luật thường trực.

| Cặp lệch | Ai thắng | Vì sao |
|---|---|---|
| Bất kỳ file nào ở đây **vs** `code/be/migrations/` | **migration** | Schema đang chạy. Sửa `.sql` cho khớp chữ ở đây là **cấm** — mở [finding](../../finding.md) |
| **01 vs migration** | migration, **trừ chỗ 01 cố ý khác** | 01 viết gọn cho người đọc lần đầu; chỗ cố ý khác được khai ngay trong header của nó (rõ nhất `open_key`, mục 2.3). **Lệch cố ý không phải bug** — "dọn cho khớp" là cách `F-01`/`F-10` quay lại |
| **02 vs migration** | **cả hai, ở hai câu hỏi khác nhau** | 02 nói *phải thế nào*, migration nói *đang thế nào*. Chúng lệch ⇒ đó là **finding**, không phải chỗ để chọn bên (mẫu: [F-11](../../finding.md#f-11), [F-45](../../finding.md#f-45)) |
| **03 vs migration** | **migration** | 03 là ảnh chụp; ảnh cũ đi trong im lặng, `.sql` thì không |
| **04 vs 01/02/03** | **04** | 04 nói agent phải làm gì, ba file kia nói schema phải thế nào. Nhầm hướng là nguồn của [F-60](../../finding.md#f-60) |
| **04 vs [CLAUDE.md §1](../../CLAUDE.md)** | **CLAUDE.md** về định tuyến, **04** về nội dung luật lane | Lệch ⇒ finding, không tự sửa một bên cho khớp |

## 3. Biên nhận đọc lại — chạy trước khi tin bất kỳ dòng nào

Biên nhận thật của lane DB là `make test-int` ([04-yeu-cau.md](04-yeu-cau.md)) và nó cần MySQL đang
chạy. Bốn lệnh dưới đây **không thay thế** nó — chúng bắt loại lỗi mà `test-int` không bao giờ đỏ:
**chữ trong bốn file trôi khỏi `.sql`**. Chạy từ gốc repo:

```bash
# A. Ngày trong header vs commit cuối của chính file — lệch ⇒ kiểm bằng code trước khi tin (§10)
for f in design/data_base/0*.md; do
  printf '%-38s doc=%s  git=%s\n' "$f" \
    "$(grep -m1 -oE 'Cập nhật \*\*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$f" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')" \
    "$(git log -1 --format=%ad --date=short -- "$f")"
done

# B. Mọi link trỏ vào hư không — phải rỗng
grep -ohE '\]\([^)]+\)' design/data_base/0*.md | sed -E 's/^\]\(//; s/\)$//; s/#.*$//' |
  grep -v '^http' | grep -v '^$' | sort -u |
  while read -r l; do [ -e "design/data_base/$l" ] || echo "CHET: $l"; done

# C. Số viết tay — mỗi hit phải **kèm sẵn lệnh sinh ra nó**, hit trần trụi là nợ ⇒ mở finding (§10, F-13)
grep -nE '~?[0-9] ?%|[0-9]+ (bảng|migration|index|cột|test)' design/data_base/0*.md

# D. Chốt chặn — danh sách bảng thật, nguồn thắng mọi dòng trong thư mục này
grep -hoiE 'CREATE TABLE( IF NOT EXISTS)? `?[a-z_]+`?' code/be/migrations/*.up.sql |
  awk '{print $NF}' | tr -d '`' | sort
```

Cả bốn đều quét `0*.md`, **không** quét `*.md`: file này chứa chính những chuỗi đang tìm, để `*.md`
là lệnh tự bắt mình và luôn ra kết quả giả — đúng cái bẫy [F-60](../../finding.md#f-60) đã trả giá.

**Vì sao bốn phép này, không phải bốn phép khác.** Bốn file ở đây được viết khi schema đã chạy, nên
chúng không hỏng vì "chưa có code" — chúng hỏng vì **migration thứ N+1 ra đời mà chữ không biết**.
Phép **D** là thứ duy nhất đọc thẳng `.sql`; ngày nó ra tên bảng mà [03-hien-trang.md](03-hien-trang.md)
không nhắc, **03 mất quyền được tin sẵn** và phải viết lại từ `code/be/migrations/`.
