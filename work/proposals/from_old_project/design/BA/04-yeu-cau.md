# 04 — Yêu cầu khi làm việc với BA (AGENTS.md của lane BA)

> Cập nhật **2026-08-19** · Lane sở hữu: **BA**.
> Luật chung ở [/CLAUDE.md](../../CLAUDE.md) — không chép về đây.
> Sự thật BA khác: [thiết kế](01-thiet-ke.md) · [luật/thước đo](02-luat.md) · [hiện trạng](03-hien-trang.md)
> — **cả ba chưa tạo**, xem mục 6. Nền lý thuyết: [nghien-cuu-vai-tro.md](nghien-cuu-vai-tro.md) ·
> lộ trình 13 bước: [ke-hoach.md](ke-hoach.md).
> **Hai sổ của lane** (mỗi lane một bộ riêng, [§2](../../CLAUDE.md)):
> việc *xong/chưa* → [task_BA.md](task_BA.md) · cái *đúng/sai* → [finding_BA.md](finding_BA.md).

**Chạm bất kỳ file nào trong `design/BA/` thì nạp file này trước.** Nó là gói bắt buộc của lane BA
ở [CLAUDE.md §1](../../CLAUDE.md). Mở lời bằng dòng khai lane, ví dụ:

```
Lane: BA · task T-xx · nạp: design/BA/04-yeu-cau.md + 01-thiet-ke.md · biên nhận: các lệnh đọc lại ở §4
```

## 1. Lane này là gì

Lane BA là **pha 0** trong sáu pha ở
[project_preparation/prompt-fullstack.md §7](../../project_preparation/prompt-fullstack.md):
`0·BA → 1·System design → 2·DB → 3·BE → 4·FE → 5·Deploy`. Nó trả lời **quán làm gì, ai thao tác,
tiền đi đường nào** — bằng ngôn ngữ quán, trước khi ai chạm tới bảng dữ liệu.

**Sở hữu:** `design/BA/**` — và chỉ chỗ đó.
**Không sở hữu, dù nội dung nghe rất BA:** phạm vi & bảng giá đã chốt · quy tắc trong `README.md` ·
`task.md` · `finding.md`. Chi tiết ở mục 3.

Lane này **không có compiler**, nên biên nhận của nó là **lệnh đọc lại** ([§8](../../CLAUDE.md)).
Đây cũng là điểm yếu chết người của nó: [quality/07 §1](../../quality/07-cau-truc-du-an.md) đã đo và
kết luận *"lane không có lệnh đỏ thì lane đó trôi"*. Vì thế mục 4 dưới đây không phải trang trí —
không chạy hết các lệnh ở đó thì session coi như chưa xong.

## 2. Một câu mới thì viết vào file nào

Bốn câu hỏi, hỏi **theo thứ tự**, dừng ở câu đầu tiên trả lời "có":

| # | Câu văn đang nói gì | Nhà | Ai thắng khi lệch |
|---|---------------------|-----|-------------------|
| 1 | Quán **đang** vận hành thế nào khi chưa có phần mềm — trình tự, chỗ chờ, số nền | [03-hien-trang.md](03-hien-trang.md) | quán thật ⇒ đi xem lại, đừng sửa chữ |
| 2 | Có phần mềm rồi thì luồng chạy ra sao, ai được làm gì, hỏng thì sao | [01-thiet-ke.md](01-thiet-ke.md) | 01, trừ khi code đã chạy khác ⇒ mở [finding](../../finding.md) |
| 3 | Quy tắc nghiệp vụ, tiêu chí chấp nhận, thước đo "chạy tốt" | [02-luat.md](02-luat.md) | 02 |
| 4 | Session BA phải biết gì **trước khi** chạm `design/BA/` | file này | 04 |

Hai loại câu **không** vào bốn nhà trên, vì chúng đo đại lượng khác: *việc nào làm tiếp, xong chưa*
⇒ [task_BA.md](task_BA.md) · *cái gì đang sai ngay bây giờ* ⇒ [finding_BA.md](finding_BA.md).
Trộn hai sổ là bệnh [F-65](../../finding.md#f-65) — sổ gánh hai việc thì mất khả năng báo động.

Hai câu cùng "có" ⇒ câu văn đang trộn hai sự thật: **chẻ ra**, đừng chép vào cả hai ([§2.1](../../CLAUDE.md)).

Ranh giới hay nhầm nhất là **1 ↔ 2**: *"người tráng bánh tráng theo mẻ 6–8 cái"* thuộc 03;
*"màn hình trạm gom việc theo mẻ"* thuộc 01. Trộn hai vế vào một file là cách **hiện trạng biến thành
thiết kế mà không ai để ý** — rồi cả hệ thống được xây trên một giả định chưa ai đi kiểm.

**Quy ước tên file:** số `01`–`04` **dành riêng** cho bốn nhà sự thật trên. File phụ trợ (bản tra cứu,
kế hoạch) **không đánh số** — đó là lý do `ke-hoach.md` và `nghien-cuu-vai-tro.md` không có tiền tố số.

## 3. Nghe như BA nhưng không phải nhà của nó

| Thứ đang định viết | Nhà thật | Lane sở hữu |
|--------------------|----------|-------------|
| Bảng giá, menu, 4 kênh bán, phạm vi MVP | [00-scope.md](../../project_preparation/00-scope.md) | NON-CODE |
| 6 quy tắc "không được phá" + cách chạy | [README.md](../../README.md) | NON-CODE ⇒ code thắng |
| Bảng, cột, ràng buộc, migration | [design/data_base/](../data_base/01-thiet-ke.md) | DB |
| Endpoint, phân quyền **đã hiện thực**, tính giá | [design/backend/](../backend/01-thiet-ke.md) | BE |
| Màn hình, route, component | [design/frontend/](../frontend/01-thiet-ke.md) | FE |
| Việc tiếp theo của lane **khác** | [/task.md](../../task.md) (lane chưa tách sổ) | theo lane của dòng task |
| Cái đang sai mà **lane khác phải sửa** | [/finding.md](../../finding.md) | lane sở hữu vùng phải sửa |

Chạm file của lane khác — kể cả một dòng — là việc của lane đó: mở finding + task, đừng tiện tay
([§2.4](../../CLAUDE.md)). Ngoại lệ **duy nhất** đã ghi sẵn trong kế hoạch: bước `B1.1` và `B1.2` sửa
[00-scope.md](../../project_preparation/00-scope.md) — vì đó là hai bước *trả lời câu hỏi owner*, và
nhà của câu trả lời ấy là scope. Hai bước đó khai lane **NON-CODE**, không phải BA.

## 4. Biên nhận của lane này — các lệnh đọc lại

Chạy từ gốc repo. Lệnh (b), (c), (c2), (d) phải ra **rỗng**:

```bash
# a. ngày trong header vs commit cuối của chính file — lệch ⇒ kiểm thực tế trước khi tin (§10)
for f in design/BA/*.md; do printf '%-34s doc=%s  git=%s\n' "$f" \
  "$(grep -m1 -oE 'Cập nhật \*\*[0-9-]+' "$f" | grep -oE '[0-9-]+$')" \
  "$(git log -1 --format=%ad --date=short -- "$f")"; done

# b. RANH GIỚI CỨNG: tên bảng không được lọt vào sản phẩm BA (mục 5.1)
grep -nE 'table_sessions|order_items|order_tasks|order_status_history|product_components|product_stations|open_key' \
  design/BA/01-thiet-ke.md design/BA/02-luat.md design/BA/03-hien-trang.md 2>/dev/null

# c. ID trùng trong hai sổ của lane — phải rỗng (mầm của F-64). Mỗi ID xuất hiện đúng 1 dòng
#    kể từ khi bảng task và mục giải thích gộp làm một bảng (xem ghi chú dưới).
grep -oE '^\| ~*\*\*T-BA-[0-9]+'  design/BA/task_BA.md    | grep -oE 'T-BA-[0-9]+' | sort | uniq -d
grep -oE '^\| \[F-BA-[0-9]+'      design/BA/finding_BA.md | grep -oE 'F-BA-[0-9]+' | sort | uniq -d

# c2. mọi dòng task phải đủ 9 cột — thiếu cột = task hụt phần owner nghiệm thu hoặc phần prompt.
#     Số 9 lấy từ chính dòng header, không viết cứng ⇒ thêm cột sau này không phải sửa lệnh này (§10):
awk -F'|' '/^\| ID \| Việc \|/{n=NF-2} /^\| ~*\*\*T-BA-/ && NF-2 != n {print FILENAME": "NR": "NF-2"/"n" cột"}' \
  design/BA/task_BA.md

# d. lời khai "chưa tạo" ở mục 6 phải khớp thực tế (bài học F-62)
for f in 01-thiet-ke 02-luat 03-hien-trang; do
  [ -e "design/BA/$f.md" ] && grep -qF "$f.md — **chưa tạo**" design/BA/04-yeu-cau.md \
    && echo "LỆCH: $f.md đã có mà 04 vẫn khai chưa tạo"; done
```

Lệnh (c) quét thẳng cả file được vì [task_BA.md](task_BA.md) chỉ còn **một bảng**: hai lớp — lớp agent (việc ·
thứ tự · biên nhận) và lớp owner (giải thích + cách kiểm bằng mắt) — nằm cùng một dòng, nên mỗi ID xuất hiện
đúng **một** lần. Trước đây chúng là hai bảng, mỗi ID lặp hai lần, nên (c) phải cắt lát bằng `sed` và cần thêm
một lệnh `diff` giữ cho hai bảng không lệch tập ID. Gộp bảng xoá luôn cả lớp lệch đó lẫn cái bẫy *lệnh luôn báo
trùng* ([F-60](../../finding.md#f-60)). Lệnh (c2) là cái gác thay thế: dòng task thiếu cột nghĩa là task ấy
hụt mất một lớp — phần owner nghiệm thu, hoặc phần nói cho owner biết **lúc nào mở session**. Lệnh **đọc số cột
từ dòng header** thay vì viết cứng con số, vì con số viết cứng trong tài liệu là thứ hỏng sớm nhất ([§10](../../CLAUDE.md),
`F-13`) — bảng vừa đi từ 6 sang 8 rồi sang 9 cột trong một ngày.

Lệnh (b) **cố ý liệt kê ba đường dẫn cụ thể**, không quét `design/BA/*.md`. Lý do: file này và
[ke-hoach.md](ke-hoach.md) chứa chính những chuỗi đang tìm (ngay trong lệnh trên), nên quét cả thư mục
là lệnh tự bắt mình và **luôn ra kết quả giả** — đúng cái bẫy [F-60](../../finding.md#f-60) đã trả giá.

## 5. Luật riêng lane BA

1. **Ngôn ngữ quán, không ngôn ngữ schema.** [prompt-fullstack §7](../../project_preparation/prompt-fullstack.md)
   ra luật cứng: *"pha 0–1 **không** nhắc tên bảng"*. Viết *"phiên bàn đang thu tiền"*, không viết
   `status='billing'`. Không phải hình thức: BA mà đã nghĩ bằng tên bảng thì nó **chép lại thiết kế DB
   có sẵn** thay vì kiểm xem thiết kế ấy có khớp quán thật không — mà bước kiểm đó là toàn bộ lý do lane này tồn tại.
2. **Đặt link, không chép.** Giá, menu, schema, endpoint đều đã có nhà. Chép sang đây = đẻ nhà thứ hai,
   và nhà thứ hai luôn trôi trong im lặng ([F-67](../../finding.md#f-67) là nạn nhân đang mở).
3. **Không đoán thay owner.** Thiếu dữ kiện ⇒ ghi **một dòng `GIẢ ĐỊNH:` + mức rủi ro** rồi làm tiếp
   ([prompt-fullstack §4.10](../../project_preparation/prompt-fullstack.md)), đừng đứng chờ mà cũng
   đừng đoán im lặng. **Ngoại lệ:** ba câu về thành phần một suất ([F-68](../../finding.md#f-68)) —
   chỗ đó cấm giả định, xem mục 7.
4. **Mỗi quy tắc nghiệp vụ phải chỉ ra được một lệnh giữ nó.** Không chỉ được thì ghi thẳng *chưa có
   chỗ giữ*, đừng để câu văn trông như đã xong. Đây là hình dạng BA của luật *"chất lượng chỉ tính khi
   máy kiểm tra được"* ở [quality/README](../../quality/README.md).
5. **Phân loại đúng cửa vào, rồi chọn đúng sổ.** Phép thử [§7](../../CLAUDE.md): *chạy hết kế hoạch y như
   nó viết, dòng này còn không?* Còn ⇒ finding, mất ⇒ task. Rồi hỏi tiếp **lane nào phải sửa**: BA ⇒
   [finding_BA.md](finding_BA.md)/[task_BA.md](task_BA.md); lane khác ⇒ sổ của lane đó, ở đây chỉ đặt link.
   Câu mở đầu bằng *"chưa có X"* gần như luôn là task — đổ hết vào sổ finding là tái phát [F-65](../../finding.md#f-65).
6. **Việc cần người ở quán thì phải ghi rõ là cần người.** Lane này khác mọi lane khác ở chỗ phần lớn
   đầu vào không nằm trong repo. Bước nào chờ owner mà session tự điền = đoán.

## 6. Trạng thái các nhà của lane — cập nhật khi tạo file

- 01-thiet-ke.md — **chưa tạo** (đẻ ra ở bước `B3.1`–`B3.4` của [ke-hoach.md](ke-hoach.md))
- 02-luat.md — **chưa tạo** (bước `B4.1`, `B4.2`, `B5.1`, `B5.2`)
- 03-hien-trang.md — **chưa tạo** (bước `B2.1`, `B2.2` — cần một ca sáng ở quán)

**Cố ý không tạo file rỗng giữ chỗ**: file rỗng là điều hướng, [§2.3](../../CLAUDE.md) cấm — đúng
quyết định `T-74` đã lấy cho lane FE. Link ở header là **link đặt trước**, sẽ sống khi file được tạo.

**Tạo file nào thì xoá dòng đó ở đây trong cùng commit.** Lệnh (d) ở mục 4 gác đúng chuyện này, vì
[F-62](../../finding.md#f-62) đã trả giá cho một lời khai *"chưa tạo"* sống sót sau khi file đã có:
`make status` không bắt được — link vẫn trỏ file có thật — nên session đọc header tin là chưa có, rồi
**bỏ qua đúng file trong gói nạp của lane mình**.

## 7. Bẫy đã trả giá

- **Đoán thành phần một suất.** [F-68](../../finding.md#f-68) 🟠: khách gọi suất trứng, hoá đơn 9.000đ
  **đúng**, khách trả **đúng**, nhưng phiếu bếp thiếu 4 bánh. Không test nào đỏ vì phần tiền không sai.
  Sai như vậy **mỗi đơn**, chỉ lộ khi có người đứng đếm bánh. Đây là lý do luật 3 có ngoại lệ.
- **Tưởng sơ đồ luồng đã có nhà.** [prompt-fullstack §3.3](../../project_preparation/prompt-fullstack.md)
  có sẵn sơ đồ luồng ăn tại bàn — nhưng file đó tự khai là **bản xuất khẩu, không phải nhà của sự thật
  nào**. Dùng nó làm nháp thì đúng; coi nó là nguồn thì rơi vào [F-67](../../finding.md#f-67).
- **Quét `design/BA/*.md` khi tìm chuỗi cấm.** Xem giải thích ở cuối mục 4 ([F-60](../../finding.md#f-60)).
- **Sửa `00-scope.md` rồi khai lane BA.** Scope thuộc NON-CODE. Bước `B1.1`/`B1.2` phải khai lane
  NON-CODE, dù nội dung là việc BA thuần tuý.
