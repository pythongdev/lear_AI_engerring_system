# P1-08 — Realtime, đường kéo dự phòng, và bốn ràng buộc ẩn có dấu hiệu đo được (L2) · pha 1, bước 8/14

> Bước **8/14** của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6. Mô tả dài ở
> `work/backlog_SD.md` → **P1-08**; trạng thái ở `work/backlog.md`.
> **Cần xong trước:** P1-02 — **đã xong 2026-09-04**
> (`docs/product/1-system-design/01-ranh-gioi-he-thong.md`).
> **Không chờ câu hỏi nghiệp vụ nào đang mở** — `U-035`, câu duy nhất từng chặn bước này, đã đóng
> 2026-09-04. Chạy song song được với mọi bước còn lại của pha 1.
> **Đọc `work/findings.md` F-027 và `docs/decisions.md` ADR-041 trước khi viết dòng đầu tiên.**

## Context

Bốn ràng buộc quyết định hình dạng của cả hệ thống này chỉ tồn tại ở **một chỗ**, và chỗ ấy tự khai
không sở hữu gì:

| Ràng buộc | Hôm nay nằm ở đâu | Ai sở hữu |
|---|---|---|
| BE chỉ chạy **một** tiến trình (đường đẩy giữ kết nối trong bộ nhớ tiến trình) | `master_plan/prompt-fullstack.md` §6.8 | **không ai** — bản xuất khẩu, `docs/decisions.md` **ADR-035** |
| **Không** hàng đợi (*"xem lại khi confirm đơn > 500ms"*) | §6.8 | **không ai** |
| **Không** cache (*"xem lại khi menu > 200 món"*) | §6.8 | **không ai** |
| Tất cả trên **một** VPS | §6.8 · **đã có nhà 2026-09-07**: `master_plan/shop-facts.md` §1 · `docs/decisions.md` **ADR-041** | chủ repo |

`docs/product/1-system-design/architecture.md` §5 có **đúng một** câu về realtime — *"màn trạm vẫn
phải tự lấy lại dữ liệu theo chu kỳ"* — và không mục nào giữ bốn ràng buộc, không dấu hiệu nào nói
lúc nào phải xem lại chúng.

Ba dữ kiện đã chốt mà bước này phải đứng lên, đọc trước:

- **Màn trạm không có nút nào** (`architecture.md` §1.1 · `docs/decisions.md` **ADR-011**, chủ quán
  chốt 2026-08-31): thẻ việc tự biến mất khi POS ghi *đã phục vụ*. Hệ quả cho bước này: mất đường
  đẩy thì màn trạm rỗng, và **rỗng-vì-hết-việc trông y hệt rỗng-vì-mất-kết-nối**.
- **`quality/invariants.md` I-008 có ba điều kiện**, và điều kiện thứ ba — *quán đang nhìn thấy
  được đơn mới* — là điều kiện **duy nhất không ai bấm được**. I-008 nói thẳng: *máy làm sao biết
  quán đang mất kết nối* là **cơ chế**, và cơ chế ấy là việc của bước này.
- **PT-2** và **PT-5** ở `docs/product/1-system-design/01-ranh-gioi-he-thong.md` §2 · §3 nói *mất
  nó thì **quán** làm gì*; bước này nói ***máy** làm gì*, và đặt dấu hiệu đo được.

## Goal

Có **một chỗ duy nhất** trả lời ba câu: việc xuống trạm đi đường nào và **đường dự phòng là gì khi
đường ấy chết** · **bốn** ràng buộc ẩn là gì, vì sao có, và **dấu hiệu đo được** nào bắt phải xem
lại từng cái · hệ thống dựa vào cái gì để nói *quán đang mất kết nối*.

## Scope

Được sửa:
- `docs/product/1-system-design/` — **một file mới**, tên `05-realtime-va-du-phong.md`
  (bản đồ file ở kế hoạch §5). File sinh ra **cùng** dòng nội dung đầu tiên của nó.
- `docs/product/00-index.md` — **một dòng** vào bảng *Pha 1*, trong **cùng** thay đổi
- `docs/product/1-system-design/architecture.md` — **chỉ hai chỗ**: §5 một dòng trỏ về file mới
  (câu realtime ở đó nay có owner), và §13 một hàng *Đọc gì tiếp*. Không chạm §1–§4, §6–§12, §14.
- `docs/product/1-system-design/01-ranh-gioi-he-thong.md` · `02-thoi-gian-ngay-ban.md` ·
  `03-bao-ve-invariant.md` — **chỉ** hàng **P1-08** của bảng *Bước sau đọc gì ở đây*: nó đang hứa
  một file chưa tồn tại, sau lượt này phải trỏ vào file thật
- `docs/decisions.md` — **một** ADR mới + **một** hàng bảng tổng hợp
- `docs/product/99-unknowns.md` — **một** gạch đầu dòng mới trong vùng đang mở, nếu bước này mở ra
  một câu hỏi cho chủ quán
- `work/findings.md` — **chỉ** khối đóng nốt **F-027**
- `work/backlog.md` (dòng trạng thái P1-08 + entry) · `work/backlog_SD.md` (dòng *Xong ngày…* +
  dòng *Prompt* + ô Mục lục) · `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §8 ·
  `prompt/SD/README.md` (hàng P1-08) · `work/scope.txt` (**thêm** khối của mình)

Không được sửa:
- `master_plan/prompt-fullstack.md` — bản xuất khẩu **không sở hữu gì** (ADR-035); pha 1 cũng
  **không được sửa hộ** nó, kể cả để "dọn" bốn ràng buộc khỏi đó
- `master_plan/shop-facts.md` — bước này không chốt một dữ kiện quán nào. Cần một con số của quán
  ⇒ **trỏ** về đó, hoặc hỏi chủ quán
- `quality/invariants.md` — **không một chữ**. `I-008` đã đủ; bước này cung cấp **đầu vào** cho
  điều kiện thứ ba của nó, không viết lại mệnh đề
- `docs/product/0-ba/**` — pha 0
- `docs/product/1-system-design/04-yeu-cau-du-lieu.md` — của P1-07

## Constraints

- **Ranh giới pha (ADR-035).** Không tên bảng · cột · khoá ngoại · endpoint · chữ ký hàm · route ·
  component, kể cả làm ví dụ. Và thêm một lớp riêng của bước này: **không tên công nghệ, không tên
  thư viện, không tên giao thức**. Pha 1 nói **tính chất** sinh ra ràng buộc (*đường đẩy giữ kết
  nối mở trong bộ nhớ của tiến trình đang phục vụ nó*), pha 3 chọn thứ có tính chất ấy.
- **Không chốt một con số chu kỳ nào.** *"Mỗi bao nhiêu giây"* là việc của pha 3. Pha 1 chỉ đòi:
  có chu kỳ · chu kỳ là một con số của **hệ thống** chứ không phải mỗi màn một kiểu · và đường kéo
  **tự chạy**.
- **Đường kéo không được là một cái nút.** Màn trạm là **chỉ đọc** và không có nút nào (ADR-011,
  `architecture.md` §1.1). Một câu *"trạm bấm tải lại"* là phá đúng lời chủ quán đã chốt.
- **Mỗi ràng buộc đúng một dấu hiệu ĐO ĐƯỢC** — một con số hoặc một sự kiện quan sát được, kèm
  **ai nhìn thấy nó bằng cái gì đã có**. Cấm chữ *"khi cần"*, *"nếu chậm"*, *"khi thấy chậm"*,
  *"nếu thấy cần thiết"*: ô thứ năm của cổng chất lượng §9 lọc đúng hai cụm đầu.
- **Không đặt ngưỡng mới cho quán.** Số món, số bàn, thời gian chờ của khách là dữ kiện quán
  (`master_plan/shop-facts.md`, **ADR-001**). Một dấu hiệu của bước này phải là **dấu hiệu kỹ thuật
  của hệ thống**; chạm dữ kiện quán ⇒ trỏ về `shop-facts.md`, đừng chép con số về.
- **"Không hàng đợi" không có nghĩa "không bao giờ có hàng đợi".** Bốn ràng buộc là *chưa cần, và
  đây là dấu hiệu để xem lại* — viết chúng thành giáo điều là hỏng đúng thứ bước này sinh ra để
  chặn.
- **Không thiết kế cơ chế.** Kể tên một cơ chế để **từ chối** nó thì được (**F-018**); vẽ ra cách
  nó chạy thì không.
- **Không viết câu chữ dòng thông báo cho khách** khi quán mất kết nối — chủ quán mới nói *có một
  dòng*, chưa đọc nội dung (`quality/invariants.md` **I-008**; hỏi khi dựng màn, pha 4).
- **Không chốt hộ chỗ nào cần chủ quán.** Chạm phải ⇒ `U-XXX` **dạng một gạch đầu dòng** trong
  vùng đang mở của `docs/product/99-unknowns.md` (`CLAUDE.md` §4 — viết thành văn xuôi là viết một
  câu hỏi không phiên nào thấy).

## Acceptance

1. Có **một** file mới trong `docs/product/1-system-design/`, và `docs/product/00-index.md` bảng
   *Pha 1* có **đúng một** dòng mới trỏ tới nó — cùng một thay đổi, không phải hai.
2. File mới nói ra **hai** đường xuống trạm: đường **đẩy** và đường **kéo dự phòng**, cộng luật
   *realtime không được là đường duy nhất* viết thành một câu đứng riêng.
3. Đường kéo **tự chạy**, và không dòng nào mô tả một nút bấm ở màn trạm.
4. **Bốn** ràng buộc, **bốn** dấu hiệu — mỗi ràng buộc có đúng một dòng dấu hiệu đo được, và mỗi
   dấu hiệu nói được **ai đo, bằng cái gì đã có**.
5. `grep` cụm *"khi cần"* và *"nếu chậm"* trong file mới ⇒ **rỗng**.
6. Có một mục trả lời *hệ thống dựa vào cái gì để nói **quán đang mất kết nối***, viết bằng ngôn
   ngữ **cái gì phải đúng**, không phải bằng một cơ chế; và nó **trỏ** về `I-008` thay vì chép
   mệnh đề.
7. Chỗ nào không tự quyết được thì để trống **có tên mã** — không suy hộ, không chốt lặng.
8. Không dòng nào chứa tên bảng · cột · endpoint · route · component · tên công nghệ · tên thư viện.
9. Không con số chu kỳ nào bị chốt trong file mới.
10. Một **ADR** ghi lại việc bốn ràng buộc nay có nhà, và **F-027** đóng nốt vế còn lại của nó.
11. `./scripts/gate.sh` xanh.

## Verify

```bash
# (1) file mới có mặt, và mục lục kể tên nó
ls docs/product/1-system-design/
grep -n '05-realtime' docs/product/00-index.md

# (2) bốn ràng buộc, bốn dấu hiệu — ĐỌC TAY hai danh sách rồi đối chiếu.
#     F-018: đây là phép đo của người viết, đừng biến số đếm thành điều kiện.
grep -n 'RB-[0-9]' docs/product/1-system-design/05-realtime-va-du-phong.md

# (3) ô thứ năm của cổng chất lượng pha 1 (kế hoạch §9)
grep -n 'khi cần\|nếu chậm' docs/product/1-system-design/05-realtime-va-du-phong.md   # rỗng

# (4) không nút ở màn trạm, không con số chu kỳ bị chốt
grep -n -i 'bấm tải lại\|nút tải lại\|mỗi [0-9]\+ giây\|[0-9]\+s một lần' \
  docs/product/1-system-design/05-realtime-va-du-phong.md                             # rỗng

# (5) ranh giới pha — in CẢ lệnh chưa lọc cạnh lệnh đã lọc (F-017): một bộ lọc
#     rỗng vì viết sai trông y hệt một bộ lọc rỗng vì không có lỗi.
wc -l docs/product/1-system-design/05-realtime-va-du-phong.md          # chưa lọc: > 0
grep -nEi 'CREATE TABLE|FOREIGN KEY|\bGET /|\bPOST /|/api/|\.tsx' \
  docs/product/1-system-design/05-realtime-va-du-phong.md                             # rỗng
grep -nEi 'SSE|WebSocket|Redis|nginx|Kubernetes|Docker|MySQL|Telegram|VPS' \
  docs/product/1-system-design/05-realtime-va-du-phong.md                             # rỗng

# (6) pointer nói ngược file mới là bug của LƯỢT NÀY (CLAUDE.md §7.2)
grep -rn 'P1-08' --include='*.md' docs/ master_plan/ quality/ prompt/

# (7) cổng của repo
./scripts/gate.sh
```

## Unknowns

**Không câu hỏi nghiệp vụ nào đang chặn bước này.** `U-035` đóng 2026-09-04.

Ba chỗ **được phép chạm tới nhưng không được quyết**:

- **`work/findings.md` F-027** — ba trong bốn ràng buộc ẩn (*một instance · không hàng đợi · không
  cache*) chưa có owner. `docs/decisions.md` **ADR-041** (điểm 3) giao thẳng: chúng mở cho tới khi
  **P1-08 tự chốt**. Nên bước này **được** chốt chúng — nhưng chốt bằng một **ADR** viết ra ba
  đường đã cân nhắc, không bằng một dòng lặng trong file mới.
- **Cửa sổ thời gian** để gọi là *quán đang mất kết nối*. Nó quyết định lúc nào web ngừng bán, nên
  nó là câu của **chủ quán**, không phải của pha 1 hay pha 3 — hỏi về **cái quán** (bài học `S-4`,
  `master_plan/shop-facts.md` §7.2), đừng hỏi về cái timeout.
- **Câu chữ dòng thông báo** cho khách khi ba kênh tự bấm dừng — chưa chốt, đừng viết.

## Report (AI trả lời sau khi làm)

1. Hai đường xuống trạm, mỗi đường một câu — và câu luật *realtime không được là đường duy nhất*
   nay nằm ở mục nào.
2. Bốn ràng buộc, bốn dấu hiệu: mỗi cái đo bằng gì và ai nhìn thấy nó.
3. Chỗ nào **cố ý để trống**, mã của thứ đang chặn nó, và tại sao không suy hộ.
4. Kết quả `grep` *P1-08*: pointer nào sửa trong cùng lượt, pointer nào **cố ý ở lại** và vì sao.
5. Output thật của mục *Verify* và của `./scripts/gate.sh`.
6. Khối `git commit` dán được (`CLAUDE.md` §6.1).
