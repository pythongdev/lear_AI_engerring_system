# P1-11 — Diễn ba scenario nghiệm thu BA qua thiết kế, và ký cổng sang pha 2 (L2) · bước 11/14

> Bước **11/14** của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6. Mô tả dài ở
> `work/backlog_SD.md` → **P1-11**; trạng thái ở `work/backlog.md`.
> **Cần xong trước:** P1-02 → P1-10 — **cả chín đã `Done`** (đo ở `work/backlog.md`, không đo ở
> kế hoạch §2: bảng ấy là ảnh chụp 2026-09-03, `work/findings.md` **F-033**).
> **Mức L2, không phải L1:** bước này là **cổng** của cả pha — nó quyết định *pha 1 đã đủ để mở
> pha 2 chưa*, và một ô tick sai ở đây đẩy một chỗ trống chạm tiền sang pha 2, nơi sửa là sửa
> `migration` chứ không sửa chữ. Ceremony theo `CLAUDE.md` §3.

## Context

**Bài học đắt nhất của pha 0, và nó lặp lại được.** `BA-11` diễn ba scenario qua tài liệu BA và
tick cổng **6/9 kèm lý do cho ba ô còn lại**; hai lượt đọc *context sạch* của nó tìm ra ba chỗ
**trong §8** rồi ba chỗ nữa **trong §1–§7** — thành `work/findings.md` **F-022**, và một trong ba
chỗ ấy thành `U-031`. **Không lượt diễn nào thì không chỗ nào trong sáu chỗ ấy lộ ra**, và
`docs/decisions.md` **ADR-032** nói thẳng rằng không cổng máy nào bắt được loại lỗi ấy: nó chỉ lộ
ra khi có người **cộng lại tiền** và **diễn từng bước**.

Ba scenario ở `docs/product/0-ba/ban-hang/08-scenario.md` §8 — Scenario 1 (QR tại bàn, ba lượt
gọi, thu một lần) · Scenario 2 (ba đơn mang đi, ba kênh) · Scenario 3 (chủ quán đổi giá giữa
buổi). Mỗi bước của chúng có cột *Luật ở đâu* trỏ về **pha 0**; bước này thêm chiều thứ hai:
**cơ chế nào của pha 1 giữ cho bước ấy đúng**.

Cổng sang pha 2 đã viết sẵn ở kế hoạch §9 — **mười ô, mỗi ô kèm cách chứng minh**. Bước này là
lượt chạy nó. Hình dạng của cổng chép từ **cổng chất lượng BA**
(`docs/product/0-ba/ban-hang/08-scenario.md` → *Cổng chất lượng BA — chín mục*): ô nào không tick
được thì **để trống kèm mã của chỗ đang chặn**, và một cổng tick 6/9 kèm lý do thì **dùng được**,
còn một cổng 10/10 bằng cảm giác thì không chặn được gì.

Đọc trước khi viết dòng đầu tiên — **toàn bộ**, không đọc bản tóm nào:
`docs/product/0-ba/ban-hang/08-scenario.md` §8 (ba scenario + cổng BA + biên bản lỗ hổng của
BA-11) · sáu file pha 1 do P1-02 → P1-10 sinh ra
(`docs/product/1-system-design/01-ranh-gioi-he-thong.md` · `02-thoi-gian-ngay-ban.md` ·
`03-bao-ve-invariant.md` · `04-yeu-cau-du-lieu.md` · `05-realtime-va-du-phong.md` ·
`06-so-rui-ro.md`) · `docs/product/1-system-design/architecture.md` §1.1 · §3.4 · §5 · §6.3 ·
§6.4 · §7 · §8 · `quality/invariants.md` (**lời** của từng `I-0xx` — bảng ba cột cố ý không chép
nó) · kế hoạch §7 (năm tầng) · §8 (chỗ đang chặn) · §9 (mười ô) · §10 (rủi ro lớn nhất của pha).

Bốn mục pha 1 đã đặt sẵn việc cho bước này, mỗi mục một hàng **P1-11** trong bảng *Bước sau đọc
gì*: `01-ranh-gioi-he-thong.md` §5 (*ba scenario phải đi qua được **PT-1** và **PT-6**, tức đi qua
được một buổi mất điện*) · `02-thoi-gian-ngay-ban.md` §5 · `03-bao-ve-invariant.md` §2.3 (*chỗ phải
dừng là `I-004` vế tầng 4 và `I-017` với `S-6`*) · §3.2 · §4.3 ·
`05-realtime-va-du-phong.md` §5 · `06-so-rui-ro.md` §2 (*`RR-9` là dòng làm ô cổng thứ sáu không
tick trơn được*).

## Goal

Mỗi **bước** của ba scenario trỏ được tới một **cơ chế bảo vệ đã viết ra ở một mục pha 1**, chỗ
nào không trỏ được thì có một `F-XXX`/`U-XXX` mang tên nó, và cổng sang pha 2 có **mười ô với
bằng chứng thật** — ô nào không tick được thì để trống kèm mã của chỗ đang chặn.

## Scope

Được sửa:
- `docs/product/1-system-design/07-cong-chat-luong-pha-1.md` — **file mới**, một chủ (kế hoạch §5,
  bản đồ file đã đặt sẵn tên này).
- `docs/product/00-index.md` — **một dòng** vào bảng *Pha 1*, cùng thay đổi (kế hoạch §5, luật 2).
- `work/findings.md` — một `F-XXX` cho **mỗi** chỗ không trỏ được, cộng bảng *Mục lục*.
- `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` — §9: **một** câu trỏ tới chỗ cổng được ký.
- `prompt/SD/` — thêm file prompt này; `prompt/SD/README.md` — hàng P1-11 của bảng bước.
- `work/backlog_SD.md` — dòng *Prompt:*, dòng *Xong ngày…* và ô Mục lục của **entry P1-11**.
- `work/backlog.md` — dòng và entry P1-11.
- `work/scope.txt` — **thêm** khối của mình (**F-010** · **F-014**).

Không được sửa:
- **`docs/product/0-ba/ban-hang/08-scenario.md` và mọi file pha 0.** Ba scenario là **đầu vào**;
  sửa chúng để chúng đi qua được thiết kế là làm ngược đúng phép nghiệm thu này.
- **Sáu file pha 1 do P1-02 → P1-10 sinh ra**, và `architecture.md`. Gặp chỗ hụt ⇒ **ghi**
  `F-XXX`, **không thiết kế bù ngay trong lượt này** — đúng cách BA-11 đã làm khi nó tìm ra năm
  chỗ nói lệch nhau. Sửa nhân tiện mục của bước khác là **F-010** · **F-014**.
- `quality/invariants.md` — không đổi lời một mệnh đề nào, kể cả khi lượt diễn cho thấy một vế
  của nó chưa có tầng nào giữ. Thấy vậy ⇒ `F-XXX`.
- `master_plan/shop-facts.md` — dữ kiện quán có nhà riêng (**ADR-001**).
- `docs/decisions.md` — bước này **không** sinh ADR: nó không chọn giữa hai thiết kế, nó **đo**.
- **Bốn ô còn lại của `work/findings.md` F-033** (kế hoạch §2 hàng 1 · 3 · 5 và §4 câu 1) — chúng
  là ô của những bước do phiên khác chạy; F-033 đã chốt đường xử: **ghi lại, không sửa hộ**
  (tiền lệ **F-032**).
- Entry *Done* lịch sử của bất kỳ bước nào (sửa tiến, không sửa lùi — **ADR-008**).

## Constraints

- **Diễn qua thiết kế, không diễn bằng trí nhớ.** Mỗi bước phải mở đúng file pha 1 và trỏ vào
  **một ô cụ thể** — mã `I-0xx` + số mục, hoặc `PT-x` / `RB-x` / `RR-x` / `YC-XX`. Một câu
  *"chỗ này `03-bao-ve-invariant.md` có nói"* không phải một pointer.
- **Chỗ hụt thì GHI, đừng lấp.** `F-XXX` nếu là chỗ tài liệu thiếu/nói lệch, `U-XXX` nếu là câu
  của chủ quán (`CLAUDE.md` §3.5 · §4). **Không** viết thêm một tầng, một phép đối chiếu, một dòng
  công thức nào trong lượt này.
- **Đừng tick 10/10 cho tròn.** Ô nào tick được **kèm lý do** thì viết lý do ra; ô nào không tick
  được thì **để trống kèm mã**. Không tick hộ, không xoá ô (kế hoạch §9, câu cuối).
- **Mỗi ô của cổng phải dán bằng chứng CHẠY ĐƯỢC**, đúng cách chứng minh mà chính ô ấy ghi — và
  in **cả lệnh chưa lọc** cạnh lệnh đã lọc (**F-017**).
- **Không dùng một con số đếm động làm điều kiện nghiệm thu** (**F-018** · **F-003**): ô thứ nhất
  và ô thứ sáu của cổng đã tự ghi luật ấy — đối chiếu **danh sách mã**, không đếm số lượng.
- **Ba scenario phải đi qua được một buổi mất điện** (`01-ranh-gioi-he-thong.md` §5): **PT-1** ·
  **PT-6** · `I-008` điều kiện thứ ba · `05-realtime-va-du-phong.md` §3.
- **Tiền phải cộng lại được từ `master_plan/shop-facts.md`**, không đọc con số trong scenario rồi
  tin. Đây là phép duy nhất bắt được loại lỗi F-022 (một câu tiếng Việt cho hai số tiền).
- **Ranh giới pha (ADR-035):** không tên bảng, tên cột, tên ràng buộc, endpoint, route, component.
- **Không mở lại nghiệp vụ** (`CLAUDE.md` §3.5). Luật này không có mức L0.

## Unknowns

Không câu nào **chặn** bước này — `U-043` và `U-044` đều tự khai không chặn bước nào của pha 1
(kế hoạch §8), `S-6` là chỗ *suy ra* mà `03-bao-ve-invariant.md` §2.2 đã gọi tên là **chỗ phải
dừng** của chính lượt diễn này, chứ không phải chỗ phải quyết.

Bước này **mở** ra chỗ chưa có lời mà nó gặp. Một chỗ như thế đi vào owner của nó
(`docs/product/99-unknowns.md` cho câu của chủ quán, `work/findings.md` cho chỗ tài liệu hụt) —
**không** đi vào file mới dạng một dòng trông như đã có cơ chế.

## Acceptance

1. `docs/product/1-system-design/07-cong-chat-luong-pha-1.md` tồn tại, một chủ (**P1-11**), và
   diễn **cả ba** scenario, **từng bước một**, không nhảy bước và không gộp bước.
2. **Mỗi bước có một ô *Cơ chế pha 1 giữ nó* không trống**, và ô ấy chỉ tên được ít nhất một mã
   (`I-0xx` · `PT-x` · `RB-x` · `RR-x` · `YC-XX`) **cộng** số mục để đọc.
3. Bước nào **không** trỏ được thì ô ấy nói thẳng **không trỏ được**, kèm mã `F-XXX`/`U-XXX` vừa
   mở — và mã ấy có mặt ở đúng owner của nó, brief in ra được.
4. Có một mục diễn **một buổi mất kết nối** đi qua **PT-1** · **PT-6** · `I-008` điều kiện thứ ba.
5. Tổng tiền của cả ba scenario được **cộng lại từ `master_plan/shop-facts.md`** §4.2 · §4.3 ·
   §4.4, không chép con số của scenario — và kết quả khớp từng đồng, hoặc chỗ lệch thành `F-XXX`.
6. **Mười ô** của kế hoạch §9 có mặt **nguyên văn**, mỗi ô kèm bằng chứng thật; ô không tick được
   để trống kèm mã chỗ chặn. Ô thứ mười (**P1-12**) để trống — nó là bước sau.
7. `docs/product/00-index.md` có **một** dòng mới cho file này, trong cùng thay đổi.
8. Kế hoạch §9 có **một** câu trỏ tới chỗ cổng được ký, và **không** mọc thêm một bản tick thứ hai
   ở đó (**F-001**).
9. `quality/invariants.md`, `master_plan/shop-facts.md`, `docs/product/0-ba/` và sáu file pha 1 của
   các bước trước **không đổi một chữ**.
10. Không dòng nào của file mới chứa tên bảng · tên cột · endpoint · route · component.
11. Mọi mã mở ra trong lượt có mặt ở owner của nó **và** ở bảng tổng hợp của owner ấy.
12. `./scripts/gate.sh` xanh.

## Verify

```bash
# (1) file có mặt, ba scenario, và mọi bước có ô cơ chế
grep -n '^## ' docs/product/1-system-design/07-cong-chat-luong-pha-1.md
grep -c '^| [0-9]' docs/product/1-system-design/07-cong-chat-luong-pha-1.md   # số bước đã diễn — ĐỌC, đừng chốt thành nghiệm thu (F-018)

# (2) không ô nào trống trong ba bảng diễn
grep '^| [0-9]' docs/product/1-system-design/07-cong-chat-luong-pha-1.md | grep -nE '\|\s*\|' || echo "RỖNG — không ô trống"

# (3) mỗi bước trỏ được một mã, hoặc nói thẳng không trỏ được
grep '^| [0-9]' docs/product/1-system-design/07-cong-chat-luong-pha-1.md \
  | grep -cE 'I-0[0-9][0-9]|PT-[0-9]|RB-[0-9]|RR-[0-9]|YC-[0-9][0-9]|KHÔNG TRỎ ĐƯỢC'
grep -c '^| [0-9]' docs/product/1-system-design/07-cong-chat-luong-pha-1.md   # hai số phải bằng nhau

# (4) ô cổng thứ nhất — đối chiếu DANH SÁCH MÃ, không đếm (F-026 · F-018)
grep -o '^### I-0[0-9][0-9]' quality/invariants.md | sed 's/^### //' | sort > /tmp/inv.txt
grep -o '^| \*\*`I-0[0-9][0-9]`\*\*' docs/product/1-system-design/03-bao-ve-invariant.md \
  | grep -o 'I-0[0-9][0-9]' | sort -u > /tmp/bv.txt
comm -3 /tmp/inv.txt /tmp/bv.txt   # rỗng = không mã nào vắng, không mã nào thừa

# (5) ô cổng thứ hai — mọi hàng chỉ tới tầng 4/5 phải nói thẳng
grep '^| \*\*`I-0' docs/product/1-system-design/03-bao-ve-invariant.md | while IFS= read -r l; do
  printf '%s  tầng4/5=%s  nói-thẳng=%s\n' \
    "$(printf '%s' "$l" | grep -o 'I-0[0-9][0-9]' | head -1)" \
    "$(printf '%s' "$l" | grep -oc 'ầng 4\|ầng 5')" \
    "$(printf '%s' "$l" | grep -oc 'máy không ngăn được')"
done

# (6) ô cổng thứ ba — định nghĩa ngày bán có ĐÚNG MỘT chỗ
grep -rn 'Một ngày bán là\|một ngày bán là' docs/product/ quality/ master_plan/shop-facts.md

# (7) ô cổng thứ tư — số phụ thuộc = số dòng suy giảm
awk '/^## 2\. Phụ thuộc ngoài/,/^\*\*PT-1 và PT-2/' docs/product/1-system-design/01-ranh-gioi-he-thong.md | grep -c '^| \*\*PT-[0-9]\*\*'
awk '/^## 3\. Đường suy giảm/,/^\*\*Sáu dòng trên/'  docs/product/1-system-design/01-ranh-gioi-he-thong.md | grep -c '^| \*\*PT-[0-9]\*\*'

# (8) ô cổng thứ năm — dấu hiệu đo được
grep -nEi 'khi cần|nếu chậm' docs/product/1-system-design/05-realtime-va-du-phong.md   # rỗng
wc -l < docs/product/1-system-design/05-realtime-va-du-phong.md                        # lệnh CHƯA lọc (F-017)

# (9) ô cổng thứ sáu — từng dòng RR-x, không đếm
grep '^| \*\*RR-' docs/product/1-system-design/06-so-rui-ro.md | grep -o '^| \*\*RR-[0-9]\*\*'
grep '^| \*\*RR-' docs/product/1-system-design/06-so-rui-ro.md | grep -nEi 'cẩn thận hơn|chú ý hơn|nhớ kiểm tra' || echo "RỖNG"

# (10) ô cổng thứ chín — mọi câu đang mở, đối chiếu §8 kế hoạch
./scripts/brief.sh | sed -n '/OPEN UNKNOWNS/,/LATEST DECISIONS/p'
grep -n '^| \*\*U-04\|^| \*\*S-5' master_plan/SD_master_plan_banh_cuon_ba_thanh.md

# (11) sáu file của bước trước + hai owner + pha 0 KHÔNG đổi một chữ
git diff --stat -- quality/invariants.md master_plan/shop-facts.md docs/product/0-ba/ \
  docs/product/1-system-design/0{1,2,3,4,5,6}-*.md docs/product/1-system-design/architecture.md   # rỗng

# (12) ranh giới pha ADR-035 — in cả lệnh CHƯA lọc cạnh lệnh đã lọc (F-017)
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md | grep -c '^+'
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -E '^\+' \
  | grep -nEi 'CREATE TABLE|FOREIGN KEY|UNIQUE\(|CHECK \(|\bGET /|\bPOST /|/api/|<[A-Z][A-Za-z]+ ?/?>'   # rỗng

# (13) mọi mã mở trong lượt nằm đúng owner và brief thấy được
grep -n 'F-036\|F-037\|F-038' work/findings.md | head
./scripts/brief.sh | sed -n '/OPEN FINDINGS/,/OPEN UNKNOWNS/p'

# (14) cổng của repo
./scripts/gate.sh
```

## Report (AI trả lời sau khi làm)

1. Ba scenario, mỗi scenario một câu: bao nhiêu bước, bước nào **không** trỏ được và mã của nó.
2. Mười ô cổng: ô nào xanh trơn, ô nào xanh **kèm lý do**, ô nào **để trống** và mã chỗ chặn.
3. Tiền cộng lại từ `shop-facts.md` cho cả ba scenario — khớp hay lệch, và lệch ở đâu.
4. Mọi mã mở ra trong lượt (`F-XXX` · `U-XXX`), kèm link tới **đúng dòng** nó được viết
   (`CLAUDE.md` §7.3).
5. Output thật của mục *Verify* và của `./scripts/gate.sh`.
6. Khối `git commit` dán được (`CLAUDE.md` §6.1) — **không** có `work/scope.txt` trong khối, và
   **không** nhặt thay đổi chưa commit của phiên khác (**F-025**).
