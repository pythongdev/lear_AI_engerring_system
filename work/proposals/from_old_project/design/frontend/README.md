# design/frontend — nhà của bốn sự thật FE

> Cập nhật **2026-08-19** · Lane sở hữu: **FE**
>
> **File này không giữ sự thật FE nào.** Route, thước, hiện trạng, luật lane đều có nhà riêng ở
> bốn file cạnh đây, và mỗi file đã tự link sang ba file kia — chép lại ở đây là đẻ nhà thứ hai
> ([CLAUDE.md §2.1](../../CLAUDE.md)). Nó chỉ giữ đúng hai thứ chưa có nhà: **sự thật FE mới ghi
> vào đâu** (§1) và **lệnh chứng minh bốn file còn khớp nhau** (§3).
>
> Muốn bắt tay vào việc thì đừng đọc file này — gói nạp bắt buộc của lane FE là
> [04-yeu-cau.md](04-yeu-cau.md) ([CLAUDE.md §1](../../CLAUDE.md)).

---

## 1. Sự thật FE mới thì ghi vào file nào

Hỏi **"đây là loại sự thật gì"**, không hỏi "nó nói về màn hình nào". Cùng một màn hình đẻ ra sự
thật thuộc cả bốn nhà.

| Loại sự thật | Nhà | Dấu nhận biết |
|---|---|---|
| Trang/route nào tồn tại, dựng bằng gì, cấu trúc dữ liệu ở client | [01-thiet-ke.md](01-thiet-ke.md) | Câu mở đầu bằng *"sẽ có…"* / *"gồm…"* |
| Ngưỡng đo được, thứ CI phải chặn, bẫy đã biết | [02-luat.md](02-luat.md) | Có **con số ngưỡng** hoặc quy về một lệnh |
| Cái đang **thật sự** có trong `fe/`, cái gì đang bị chặn bởi ai | [03-hien-trang.md](03-hien-trang.md) | Kiểm được bằng lệnh chạy trên repo **hôm nay** |
| Session sau phải nạp gì, tuân gì, biên nhận là lệnh nào | [04-yeu-cau.md](04-yeu-cau.md) | Nói với **agent**, không nói về sản phẩm |

Bốn dòng dưới đây **không thuộc thư mục này**, đừng viết vào đây cho tiện:

| Loại | Nhà thật |
|---|---|
| Đang có cái **sai ngay bây giờ** | [finding.md](../../finding.md) — phép thử finding↔task ở [§7](../../CLAUDE.md) |
| Việc **chưa tới lượt xây** | [task.md](../../task.md) + [step.md](../../step.md) |
| Luật áp cho **mọi lane** | [CLAUDE.md](../../CLAUDE.md) — không chép mảnh về đây |
| Hợp đồng FE↔BE, FE↔DEVOPS | [Makefile](../../Makefile) và `code/be/api/openapi.yaml` (**chưa tồn tại** — `T-13` sinh ra nó) — **file của lane khác**, thấy sai thì mở finding, đừng tiện tay sửa, [§2.4](../../CLAUDE.md) |

## 2. Bốn file lệch nhau thì file nào thắng

[CLAUDE.md §2](../../CLAUDE.md) đã chốt **code thắng tài liệu**. Trong thư mục này `fe/` còn rỗng
nên luật đó chưa nổ lần nào — thứ nổ trước là **bốn file lệch lẫn nhau**, và §2 không xử ca đó:

| Cặp lệch | Ai thắng | Vì sao |
|---|---|---|
| **03 vs 01** | không ai — **lệch là trạng thái bình thường** | 01 là ý định, 03 là hiện trạng; `fe/` rỗng nên chúng *phải* khác nhau. Chỉ thành lỗi khi `fe/` đã có code mà 03 vẫn khai 0 |
| **01 vs 02** | **02** | 01 có đoạn code mẫu; mẫu vi phạm thước ở 02 ⇒ sửa mẫu, đừng nới thước |
| **04 vs 01/02/03** | **04** | 04 nói agent phải làm gì; ba file kia nói sản phẩm phải thế nào. Nhầm hướng là nguồn của [F-60](../../finding.md#f-60) |
| **04 vs [CLAUDE.md §1](../../CLAUDE.md)** | **CLAUDE.md** về định tuyến, **04** về nội dung luật lane | Lệch ⇒ finding, không tự sửa một bên cho khớp |

## 3. Biên nhận của thư mục — chạy trước khi tin bất kỳ dòng nào

Lane FE **chưa có compiler** (`npm run build`/`tsc --noEmit` không chạy được, [F-59](../../finding.md#f-59)),
nên biên nhận ở đây là **lệnh đọc lại** ([CLAUDE.md §8](../../CLAUDE.md)). Ba phép, chạy từ gốc repo:

```bash
# A. Ngày trong file vs ngày commit cuối — lệch ⇒ kiểm bằng code trước khi tin (§10)
for f in design/frontend/*.md; do
  printf '%-32s file=%s  git=%s\n' "$f" \
    "$(grep -m1 -oE 'Cập nhật \*\*[0-9]{4}-[0-9]{2}-[0-9]{2}' "$f" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')" \
    "$(git log -1 --format=%ad --date=short -- "$f")"
done

# B. Lời khai "chưa tạo" về file đã tồn tại — phải rỗng.
#    Chỉ quét 0*.md: README là cái đi kiểm, không phải cái bị kiểm.
grep -n 'chưa tạo' design/frontend/0*.md

# C. Mọi link trỏ vào hư không (kể cả ra ngoài thư mục) — phải rỗng
grep -ohE '\]\([^)]+\)' design/frontend/*.md | sed -E 's/^\]\(//; s/\)$//; s/#.*$//' |
  grep -v '^http' | grep -v '^$' | sort -u |
  while read -r l; do [ -e "design/frontend/$l" ] || echo "CHET: $l"; done

# D. Con số duy nhất cả thư mục này dựa vào — mọi file đều viết trên giả định nó bằng 0
git ls-files fe/ | wc -l
```

**Vì sao ba phép này, không phải ba phép khác:** cả bốn file đều được viết **trước** khi có code, nên
chúng không cũ đi vì code đổi — chúng cũ đi vì **file thứ năm ra đời mà file thứ nhất không biết**.
Phép **B** bắt đúng ca đó và đã bắt thật ngày **2026-08-14**: 01 và 02 còn khai *"03 và 04 chưa tạo"*
sau khi 03 và 04 đã có, và 01 còn khai `fe/` có 1 file `AGENTS.md` sau khi `T-76` đã dọn `fe/` về 0.
Ba dòng sửa trong cùng commit với file này.

Phép **D** là chốt chặn: ngày nó ra khác `0`, **mọi khẳng định trong thư mục này mất quyền được tin
sẵn** — [03-hien-trang.md](03-hien-trang.md) phải viết lại từ code, và `fe/` bắt đầu thắng cả bốn file.
