# P1-09 — Viết lại §3: bảng quầy BỐN con số, và gỡ câu giao việc cho một task đã *Done* (L2) · bước 9/12

> Bước **9/12** của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6. Mô tả dài ở
> `work/backlog_SD.md` → **P1-09**; trạng thái ở `work/backlog.md`.
> **Cần xong trước:** **BA-12** — **đã xong 2026-09-04** (`31fb071`). **Độc lập với cả dãy P1 còn
> lại**: nó không chờ P1-01…P1-08 và không bước nào chờ nó.
> ⚠️ **Còn chờ `S-5`** (`master_plan/shop-facts.md` §7.2) và phải **đọc `U-033`** trước khi viết
> con số thứ tư. **Đây là con bug `F-024`** (`work/findings.md`).

## Context

**Chủ quán trả lời `S-4` ngày 2026-09-01:** bánh gấp xong **có nằm chờ** — chờ đủ đĩa · chờ người
rảnh tay bưng · chờ món khác của cùng bàn — và **người đứng quầy bấm** nút *"đã làm xong"*
(`master_plan/shop-facts.md` §5.4, §7.1). `U-017` chốt tiếp cùng ngày: bấm **theo MẺ**.

`docs/product/1-system-design/architecture.md` §11 ghi nhận cả hai và kết luận: *"**Phương án 'ba
con số' ở §3 hết đúng và phải viết lại.**"* Rồi nó khép lại bằng một câu **giao việc cho `T-036`**.
**`T-036` đã *Done* từ 2026-09-01 và không giao deliverable ấy.** Đo lại 2026-09-03: §3 không chứa
cụm *"đã làm xong"*, *"còn ở bếp"* hay *"đã ra bàn"* ở dòng nào; bảng quầy vẫn là *"CẦN LÀM
(tổng)"* + *"CẦN LÀM (cho bàn nào)"* — đúng phương án mà §11 của chính file ấy tuyên bố hết đúng.

**Vì sao vòng rà trước không bắt được:** T-036 sửa **sáu** pointer trong một lượt và §11 là một
trong sáu — nó được sửa đúng phần *nội dung đã cũ* và **giữ lại phần giao việc**. Câu hỏi không ai
đặt là *"cái tên trong câu này còn sống không"*. Luật rút ra, và nó là một phép so mà chưa cổng nào
có: **mọi câu giao việc cho một mã task phải được chấm lại khi mã ấy sang *Done***.

**BA-12 đã dựng xong nền nghiệp vụ cho bước này** (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4,
xong 2026-09-04): bốn con số bảng quầy ở §3.4.2, nhu cầu **cộng ngang** ở §3.4.3, **tách ngược** về
từng bàn ở §3.4.4, hai trục gặp nhau ở §3.4.5, khoá gom ở §3.4.6, ai bấm ở §3.4.8. Phát hiện đắt
nhất của nó nằm ở §3.4.2 và bước này phải giữ nguyên: **hai chữ *còn* khác nhau** — *còn thiếu*
(con số của **người bưng**) khác *nhu cầu* (con số của **bếp**), lệch nhau đúng bằng con số thứ hai
của bảng. Gộp hai cái là quay về bảng **ba** con số và giục bếp làm lại một cái bánh đang nằm chờ.

Đọc trước khi viết dòng đầu tiên: `docs/product/1-system-design/architecture.md` §3 · §11 ·
`master_plan/shop-facts.md` §5.4 · §7.2 (S-4, S-5) · `docs/decisions.md` **ADR-026** ·
`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4 · `quality/invariants.md` **I-019** · **I-020**,
và **`U-033`** ở `docs/product/99-unknowns.md`.

## Goal

Bảng ở quầy trong §3 có **bốn** con số đúng như lời chủ quán, và **không câu nào** trong tài liệu
còn giao việc cho một mã task đã đóng.

## Scope

Được sửa:
- `docs/product/1-system-design/architecture.md` — **chỉ §3** (khối bảng quầy + bốn luật của nó,
  §3.1–§3.3 chỉ sửa nếu chúng nói ngược §3 mới) và **câu giao việc ở §11**
- `work/findings.md` — **chỉ** mục **F-024** (→ *Fixed*, kèm ngày và mã bước đã sửa)
- `work/backlog.md` · `work/backlog_SD.md` — **chỉ** dòng và entry P1-09
- `work/scope.txt` — **thêm** khối của mình (**F-010** · **F-014**)

Không được sửa:
- **Số mục §1–§14 — không đánh lại.** `docs/decisions.md` **ADR-012** gọi mục *Nợ* = §12 và
  **ADR-013** gọi mục *admin* = §14 bằng đúng số ấy. Viết lại **nội dung** §3, không đụng **số**.
- `docs/product/0-ba/ban-hang/03-lat-cat.md` — §3.4 là nền nghiệp vụ đã chốt ở pha 0. Bước này
  **đọc** nó, không sửa nó. Thấy nó sai ⇒ ghi `F-XXX`, đừng sửa nhân tiện.
- `quality/invariants.md` — `I-019` và `I-020` không đổi lời
- `master_plan/shop-facts.md` — **trừ khi** chủ quán trả lời `S-5` trong lượt này; khi ấy lời chốt
  vào §5.4 + §7.1 và `S-5` rời §7.2, **trước** khi viết tiếp §3
- `master_plan/prompt-fullstack.md` — bản xuất khẩu không sở hữu gì (**ADR-035**)

## Constraints

- **Bốn con số, và con số thứ tư nhảy THEO BẬC MẺ**, không nhảy từng đơn vị. **Mẻ là đơn vị *bấm*,
  bàn là đơn vị *đếm*** (`master_plan/shop-facts.md` §5.3 · §5.4, `U-017` đóng 2026-09-01).
- **Đừng gộp *mẻ* và *bàn* thành một đơn vị.** Một mẻ phục vụ nhiều bàn; gộp là làm bánh nằm chờ
  trở thành vô hình lần nữa — đúng chỗ hỏng mà bước này tồn tại để sửa.
- **Đừng gộp *còn thiếu* với *nhu cầu***. Hai con số khác nhau, khác chủ, và lệch nhau đúng bằng
  con số *đã làm xong, còn ở bếp* (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4.2).
- **Đừng thêm nút nào cho bếp.** `U-009` vẫn nguyên vẹn: **ba trạm bếp không bấm gì**. Cả bốn con
  số đều do **quầy** bấm hoặc do hệ thống suy ra từ đơn đã duyệt. Luật ghi ở
  `docs/product/1-system-design/architecture.md` §1.1 và **ADR-011**.
- **Giữ `I-019`** — tổng nhu cầu một thành phần luôn bằng tổng phần chia về từng bàn, **cả hai
  chiều**; và **khoá gom là ranh giới của phép cộng**: hai thành phần khác loại nhân hoặc khác
  lượng nhân **không** cộng vào cùng một dòng.
- **Giữ `I-020`** — *đã phục vụ ≤ đã gọi* cho mỗi bàn và mỗi thành phần, kể cả khi **một mẻ phục vụ
  nhiều bàn** và kể cả trên **đường lùi** (quầy bấm nhầm rồi lùi lại).
- **Giữ luật §3 hiện có mà vẫn đúng:** ba kênh không gắn bàn **không** đổ vào bảng này (§3.2 có màn
  riêng), và suất *"đem về"* của khách đang ngồi bàn **vẫn nằm ở đây** kèm note đọc ra được ngay.
- **Ranh giới pha (ADR-035):** không tên bảng · tên cột · endpoint · route · component, và **không
  vẽ giao diện**. §3 nói *quầy phải thấy được gì*, không nói *nút nằm ở đâu, cỡ chữ bao nhiêu* —
  cái đó là pha 4.
- **Sửa TIẾN, không xoá dấu vết** (**ADR-008**). Câu §11 kể lại lịch sử S-4 và U-017 **ở lại**; chỉ
  câu **giao việc cho `T-036`** được thay bằng một câu nói việc ấy nay thuộc bước này.
- **Chưa có lời giải thì viết phương án HẸP NHẤT và nói thẳng là đang treo** (§11, câu cuối).

## Acceptance

1. §3 của `docs/product/1-system-design/architecture.md` nêu **đủ bốn** con số của bảng quầy, và
   mỗi con số nói rõ **ai làm nó đổi** (quầy bấm, hay hệ thống suy ra từ đơn đã duyệt).
2. §3 nói rõ con số thứ tư nhảy **theo bậc mẻ**, và rằng **mẻ là đơn vị bấm, bàn là đơn vị đếm**.
3. §3 phân biệt được **hai chữ *còn*** — *còn thiếu* (của người bưng) khác *nhu cầu* (của bếp) —
   và nói rõ chúng lệch nhau bằng con số nào.
4. §3 **không** thêm một nút bấm nào ở trạm bếp; câu *ba trạm bếp không bấm gì* vẫn đọc được.
5. §11 **không còn câu nào giao việc** cho `T-036`; câu kể lại lịch sử S-4 và U-017 thì **ở lại**
   nguyên văn (**ADR-008**).
6. Số mục §1–§14 **không đổi**: `git diff` không có dòng nào sửa một tiêu đề `## N.`.
7. Phần *"đã bưng ra bàn"* viết theo **phương án hẹp** (theo **bàn**) và **đánh dấu là chỗ suy ra**,
   đúng chỗ `master_plan/shop-facts.md` §7.2 đang giữ `S-5`. *(Chủ quán trả lời trong lượt này ⇒
   lời chốt vào `master_plan/shop-facts.md` trước, rồi mới viết đầy.)*
8. Ca **đơn huỷ sau khi bếp đã làm xong** (`U-033`) được nhắc tới ở chỗ nó chạm bảng quầy, kèm chữ
   *"đang chờ `U-033`"* — **không** tự quyết chỗ bánh ấy đi đâu.
9. `work/findings.md` **F-024** ở trạng thái **Fixed**, kèm ngày và mã bước đã sửa.
10. Không chỗ nào trong repo còn nói phương án **ba con số** như phương án đang hiệu lực; chỗ nào
    **kể lại** nó là lịch sử thì **ở lại** (**F-018**).
11. `quality/invariants.md` **không đổi một chữ nào** trong lượt này.
12. Không dòng nào chứa tên bảng · tên cột · endpoint · route · component, và không dòng nào mô tả
    giao diện.
13. `./scripts/gate.sh` xanh, **Gate 1c** gồm.

## Verify

```bash
# (1) bốn con số có mặt trong §3 — đọc TAY khối §3, đừng chỉ đếm (F-018).
#     Số dòng của §3 lấy từ chính lượt này, đừng chép từ trí nhớ.
grep -n '^## 3\.\|^## 4\.' docs/product/1-system-design/architecture.md
grep -n 'đã làm xong\|còn ở bếp\|đã ra bàn\|đã bưng ra bàn' \
  docs/product/1-system-design/architecture.md

# (2) §11 hết giao việc cho T-036, nhưng câu KỂ LẠI lịch sử ở lại. Đọc từng
#     dòng: một tài liệu kể lại một chỗ sai không phải là một chỗ sai (F-018).
grep -n 'T-036' docs/product/1-system-design/architecture.md

# (3) số mục §1–§14 KHÔNG đổi
git diff -- docs/product/1-system-design/architecture.md | grep -E '^[-+]## [0-9]+\.'  # rỗng

# (4) không nút nào cho bếp. In cả lệnh chưa lọc cạnh lệnh đã lọc — một bộ lọc
#     rỗng vì viết sai trông y hệt một bộ lọc rỗng vì không có lỗi (F-017).
git diff --unified=0 -- docs/product/1-system-design/architecture.md \
  | grep -c '^+'                                    # chưa lọc: > 0
git diff --unified=0 -- docs/product/1-system-design/architecture.md \
  | grep -E '^\+' | grep -nEi 'bếp bấm|trạm bấm|nút ở trạm'          # rỗng

# (5) hai chỗ đang treo phải nói ra mã của thứ chặn chúng
grep -n 'S-5\|U-033' docs/product/1-system-design/architecture.md

# (6) phương án BA con số còn sống ở đâu — đọc từng kết quả
grep -rn 'ba con số' --include='*.md' docs/ quality/ master_plan/

# (7) F-024 đã đóng. Đọc theo KHỐI, không theo dòng: dòng Status có thể cách
#     tiêu đề nhiều đoạn văn và mọi bộ lọc theo dòng đều mù với nó (F-015).
awk '/^### F-024/,/^### F-025/' work/findings.md | grep -n 'Status\|Fixed'

# (8) invariant KHÔNG bị sửa lời, ranh giới pha ADR-035
git diff --stat -- quality/invariants.md            # rỗng
git diff --unified=0 -- docs/product/1-system-design/architecture.md \
  | grep -E '^\+' \
  | grep -nEi 'CREATE TABLE|FOREIGN KEY|\bGET /|\bPOST /|/api/|<div|className'  # rỗng

# (9) Gate 1c — U-017 và S-4 đã ĐÓNG; một câu nói chúng còn mở làm gate đỏ
./scripts/check-doc-status.sh

# (10) cổng của repo
./scripts/gate.sh
```

## Unknowns

- **`S-5`** — bấm *"đã bưng ra bàn"* theo **đơn vị nào**. Đây là chỗ **suy ra, chưa hỏi**
  (`master_plan/shop-facts.md` §7.2), không phải một câu hỏi đã gửi. ⇒ viết theo **bàn** (phương án
  hẹp) và **giữ nguyên nhãn suy ra**. Đừng nâng nó thành lời chốt.
- **`U-033`** — một đơn bị **huỷ** sau khi bếp đã làm xong phần của nó: chỗ bánh ấy có được tính
  cho một bàn khác đang chờ không, hay bỏ và làm lại. Đang mở, chủ quán trả lời. Nó chạm bảng quầy
  vì cả **nhu cầu** lẫn **đã làm xong, còn ở bếp** đều phải đổi khi một đơn huỷ. ⇒ nhắc tới, ghi là
  đang treo, **không tự quyết**.

**Cách hỏi, nếu hỏi được — nó đã hỏng một lần và tốn một ngày.** Hỏi về **cái quán**, đừng hỏi về
cái bảng trong máy. `S-4` ngày 2026-08-31 hỏi *"bảng ở quầy hiện bàn 5 còn thiếu 3 hay đã đủ"* và
chủ quán trả lời **"tôi không hiểu"**; hỏi lại ngày 2026-09-01 về cái quán — *"từ lúc bánh tráng
xong đến lúc nó xuống bàn, có khi nào nó nằm chờ không"* — thì được trả lời ngay, kèm ba lý do
không ai gợi ý (`master_plan/shop-facts.md` §7.2). **Chính bước này sống nhờ câu trả lời ấy.**

## Report (AI trả lời sau khi làm)

1. Bốn con số của bảng quầy là gì, ai làm mỗi con số đổi, và con số thứ tư nhảy theo bậc gì.
2. Hai chữ *còn* được phân biệt ở câu nào, và chúng lệch nhau bằng con số nào.
3. Câu §11 nào bị thay, câu nào **ở lại nguyên văn** và vì sao (**ADR-008**).
4. `S-5` và `U-033`: phương án hẹp đã chọn, và câu nào trong §3 nói ra rằng chúng đang treo.
5. Kết quả `grep -rn "ba con số"` và `grep -n "T-036"`: chỗ nào phải sửa, chỗ nào **cố ý ở lại** vì
   nó **kể lại** một chỗ sai (**F-018**).
6. `F-024` đóng ở dòng nào, ngày nào.
7. Output thật của mục *Verify*, của `./scripts/check-doc-status.sh` và của `./scripts/gate.sh`.
8. Khối `git commit` dán được (`CLAUDE.md` §6.1) — **không** có `work/scope.txt` trong khối.
