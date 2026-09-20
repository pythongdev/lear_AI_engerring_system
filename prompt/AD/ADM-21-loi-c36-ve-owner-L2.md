# ADM-21 — Đưa lời `C36` về owner: **mốc đổi người ở quầy** (L2) · lane admin

> Mô tả dài ở `work/backlog_AD.md` → **ADM-21**; trạng thái ở `work/backlog.md`.
> **Loại 3** — việc duy nhất của lane nhận được ngay kể từ 2026-09-20, khi `ADM-53` `Done`
> (`work/backlog_AD.md`, mục *Cổng của cả lane*).
> **Mở khoá:** chỗ chạm thứ hai giữa hai mảng ở `docs/product/1-system-design/architecture.md`
> §14.3, và vế *ai* của **ADM-50**.
>
> ⚠️ **Việc này KHÔNG có bước hỏi.** Chủ quán đã trả lời `C36` ngày 2026-09-20 (ADM-53 hỏi nhân
> thể). Việc còn lại là **chuyển lời ấy về owner** — không hỏi lại, và cũng **không** suy thêm một
> chữ nào ngoài lời đã có (`CLAUDE.md` §3.5, luật **không có mức L0**).

## Context

`docs/product/1-system-design/architecture.md` §4 chốt từ **2026-08-30** rằng quyền gắn **chỗ
đứng**, không gắn chức vụ (`docs/decisions.md` **ADR-016**, xác nhận lại 2026-09-02). §8 của cùng
tài liệu đo rằng **không dữ liệu nào ghi ai đang đứng đâu**, và §14.3 gọi đó là chỗ chạm thứ hai
giữa mảng admin và mảng bán hàng. Ba chỗ cùng chỉ vào một chỗ trống, và chỗ trống ấy đứng đó **từ
ngày luật quyền ra đời**.

Đúng **một** câu chặn nó: `C36`. Chủ quán trả lời ngày **2026-09-20** qua `ADM-53`:

| Câu | Lời chủ quán | Hôm nay nằm ở đâu |
|---|---|---|
| **`C36`** — người đứng quầy đổi giữa buổi thì máy có ghi lại mốc đổi ấy không | **"Có — ghi cả mốc đổi, ai vào ai ra lúc mấy giờ"** | ❌ **chỉ** `work/admin-questions.md` §3 |

`work/admin-questions.md` **tự khai ở banner đầu trang rằng nó sẽ bị xoá** khi mọi câu đã chuyển
đi. Lời `C36` đang sống trong đúng file ấy, và nó là **tiền đề duy nhất** của mức 1 (*ai đang trực
trạm nào*) mà `master_plan/shop-facts.md` §8.7 vừa chốt ngày 2026-09-20.

Đọc trước khi viết dòng đầu tiên: `work/admin-questions.md` §3 câu `C36` (nguyên văn lời đáp) ·
`master_plan/shop-facts.md` §3 (năm trạm, bốn vai) · §7.1 (nhật ký chốt) · §7.2 (chỗ **suy ra**, mã
`S-X`) · §8.3 (cách đánh số tiếp) · §8.6 (hàng 6 và hàng 7) · §8.7 (mức sâu mảng con người) ·
`docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 · `docs/product/1-system-design/architecture.md` §4
· §8 · §14.3 · §14.4 · `docs/product/1-system-design/04-yeu-cau-du-lieu.md` §4 (`YC-15`…`YC-17`) ·
`quality/invariants.md` **I-012** · `docs/decisions.md` **ADR-013** · **ADR-016** · **ADR-035**.

## Goal

Lời `C36` nằm ở owner của nó, `work/admin-questions.md` §3 hết là chỗ duy nhất giữ nó, và luật
quyền chốt từ 2026-08-30 lần đầu tiên đứng được trên một dữ kiện thật — **cho trạm `quay`**, đúng
phạm vi lời chủ quán nói, không rộng hơn một chữ.

## Scope

Được sửa:
- `master_plan/shop-facts.md` — lời `C36` vào một **mục con mới của §8** (số lấy theo §8.3 tại thời
  điểm chạy), cộng **một** dòng nhật ký §7.1; sửa §8.6 hàng 6 · hàng 7 và §8.7 (mức 1) ở chỗ chúng
  đang nói *"chưa về owner"*
- `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 — khối admin **có nhãn** (**ADR-013**)
- `docs/product/1-system-design/architecture.md` — §14 khối **có nhãn**, cộng hàng *Ai đang trực
  trạm nào* của bảng §14.3 và câu cuối §14.4
- `docs/product/99-unknowns.md` — **những vế chủ quán KHÔNG chạm tới**, mỗi vế một `U-XXX` (tiền lệ:
  bốn vế của nhóm `A`, `work/admin-questions.md` §3)
- `work/admin-questions.md` — §3: gạch `C36`, trỏ về owner; banner đầu file
- `work/backlog.md` · `work/backlog_AD.md` · `prompt/AD/README.md` — trạng thái, entry, mọi pointer
  nói *"`C36` chưa về owner"*
- `docs/work-flow-session/tom_tat_du_an.md` — mục *Công việc sẵn sàng tiếp theo* và danh sách câu
  mở (bản tóm tắt, không sở hữu gì — sửa cho khỏi nói ngược owner)
- `work/scope.txt` — **thêm** khối của mình (**F-010** · **F-014**)

Không được sửa:
- **`quality/invariants.md`** — lượt này chuyển một lời đã chốt về owner, nó không quyết định gì
  mới. **I-012** đã đòi *ai bấm* từ 2026-09-01 và câu ấy không đổi; thấy cần viết một invariant mới
  nghĩa là bạn đang tự thiết kế (§3.5) — dừng lại.
- **`docs/decisions.md`** — cùng lý do. Không có lựa chọn thiết kế nào trong lượt này.
- **`docs/product/1-system-design/04-yeu-cau-du-lieu.md`** — `YC-15` (*trực trạm đọc được theo thời
  điểm*) đã viết từ **P1-07**, 2026-09-07, và lời `C36` **xác nhận** nó chứ không thêm yêu cầu nào.
  Thêm một `YC` mới sẽ phá phép chấm một-đối-một giữa §1 của file ấy và bảng §8 của
  `architecture.md`.
- **`docs/product/1-system-design/architecture.md` §8** — bảng chỗ thiếu **không** mất hàng nào:
  lời `C36` là **luật**, không phải hình dạng dữ liệu. Chỗ cất vẫn là pha 2 (**ADR-035**).
- **`master_plan/shop-facts.md` §1–§7** trừ đúng **một** dòng nhật ký §7.1 — dữ kiện admin chỉ vào
  §8 (§8.3).
- **Mọi câu hỏi khác ở `work/admin-questions.md` §3** ngoài `C36`.
- **`work/backlog_AD.md` entry của việc khác ADM-21** — trừ dòng *chặn bởi* ở bảng mục lục, thứ
  buộc phải khớp trong cùng lượt (`CLAUDE.md` §7.2).

## Constraints

- **Ghi đúng phạm vi lời chủ quán: câu hỏi hỏi về TRẠM QUẦY, và lời đáp nói về trạm quầy.** Viết nó
  thành luật cho *cả năm trạm* là suy hộ — đúng họ lỗi **F-004**. Bốn trạm còn lại chưa có lời, và
  chỗ hở ấy phải mang một mã `U-XXX`, không được thành một câu văn êm tai.
- **Vế chủ quán không chạm tới thành CÂU HỎI CÓ MÃ, không thành suy luận.** Tiền lệ đứng sẵn ở
  `work/admin-questions.md` §3: bốn vế của nhóm `A` thành `U-038`…`U-041`. Mã mới lấy số tiếp theo
  trong `docs/product/99-unknowns.md`, viết đúng hợp đồng hình dạng *Cách viết một câu ở đây* — một
  **gạch đầu dòng** trong vùng đang mở, nếu không `scripts/brief.sh` sẽ không thấy nó (**F-008** ·
  **F-012**).
- **Số mục con của §8 lấy theo §8.3 TẠI THỜI ĐIỂM CHẠY, đừng chép số từ entry hay từ prompt này.**
  ADM-53 vừa lấy **§8.7** ngày 2026-09-20; đếm lại mục con cuối cùng rồi lấy số kế tiếp. Đây là họ
  lỗi *"con số viết trong prompt đã hết hạn"* (**F-003** · **F-018**).
- **Ranh giới pha (ADR-035):** lời `C36` nói quán muốn máy **ghi** cái gì, không nói **cất** ở đâu.
  Không tên bảng · tên cột · endpoint · route · component trong bất kỳ đầu ra nào.
- **Được nói ≠ tự suy ra.** Lời chủ quán vào §8 và nhật ký §7.1; chỗ bạn suy ra để lấp khoảng trống
  vào §7.2 với mã `S-X` riêng (`CLAUDE.md` §7.2, **F-004**).
- **Một chỗ ĐỊNH NGHĨA, nhiều chỗ TRỎ VỀ.** Hai khối có nhãn ở `01-ranh-gioi.md` và
  `architecture.md` **trỏ** về mục §8 vừa viết, không kể lại lời chốt bằng lời của mình (**F-001**).
- **Đừng tuyên bố vế *ai* của ADM-50 đã xong.** **I-012** chốt hai cửa ghi **ngoài** quầy — người đi
  giao bấm *đã giao + đã thu tiền* (`shop-facts.md` §6.7) và chủ quán đổi giá / đổi thành phần
  (§6.17). Lời `C36` không phủ hai cửa ấy.

## Acceptance

1. Lời `C36` nằm ở **một** mục con mới của `master_plan/shop-facts.md` §8, số lấy theo §8.3, và có
   **đúng một** dòng mới ở nhật ký §7.1 trỏ về mục ấy — trong cùng một thay đổi.
2. Mục ấy ghi **nguyên văn** lời đáp, ngày **2026-09-20**, và tên việc đã hỏi (`ADM-53`) cùng việc
   đã chuyển (`ADM-21`) — đủ để một phiên lạ biết ai quyết và quyết hôm nào (`CLAUDE.md` §7.2).
3. Mục ấy nói rõ phạm vi là **trạm `quay`**, và nói ra những vế lời chốt **không** nói, mỗi vế trỏ
   về một mã `U-XXX` — **không** vế nào bị lấp bằng suy luận.
4. Có **khối có nhãn** ở `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 và ở
   `docs/product/1-system-design/architecture.md` §14, cả hai **trỏ về** mục §8 vừa viết
   (**ADR-013** · **F-001**).
5. Mọi vế chủ quán không chạm tới có mã riêng ở `docs/product/99-unknowns.md`, mỗi mã là **một gạch
   đầu dòng** trong vùng *Đang mở*, có đủ *vì sao không được suy hộ* · *ai trả lời được* · *đang
   chặn gì* · *cách hỏi*, và mục lục đầu file có dòng tương ứng.
6. `work/admin-questions.md` §3: `C36` bị **gạch** và trỏ về owner; banner đầu file hết nói *"`C36`
   chưa về owner"*; con số câu để trống đo lại trong lượt này bằng lệnh, không chép
   (**F-003**).
7. **Không một pointer nào trong repo còn nói `C36` chưa về owner.** Lệnh grep ở *Verify* bước (4)
   là bằng chứng, và mọi chỗ nó in ra đã được sửa trong **cùng** lượt (`CLAUDE.md` §7.2).
8. `master_plan/shop-facts.md` §8.6 hàng 6 và hàng 7 nói đúng trạng thái mới: chặn **chuyển chủ**
   từ `C36` sang mã `U-XXX` mới, **không** biến mất.
9. Không dòng nào viết trong lượt này chứa tên bảng · tên cột · endpoint · route · component; bảng
   §8 của `architecture.md` **không** mất hàng nào.
10. ADM-21 tick *Done* ở `work/backlog.md`; entry ở `work/backlog_AD.md` **ở lại** kèm dòng *Xong
    ngày…* (luật 3 đầu file ấy); `prompt/AD/README.md` đổi hàng ADM-21 · ADM-50 và bảng ba loại;
    khối pattern của mình đã xoá khỏi `work/scope.txt`.
11. `./scripts/gate.sh` xanh — kể cả Gate 1c (một mã đóng bị nhắc như còn mở) và Gate 1d (ranh giới
    pha trong `docs/product/1-system-design/`).

## Verify

```bash
# (1) mục con mới của §8 — số là số CÒN TRỐNG, không phải số chép từ prompt
grep -nE '^### 8\.[0-9]+ ' master_plan/shop-facts.md

# (2) ĐÚNG MỘT chỗ định nghĩa lời C36, những chỗ khác chỉ TRỎ VỀ (F-001)
grep -rn 'ai vào ai ra' --include='*.md' docs/ master_plan/ work/ prompt/

# (3) một dòng nhật ký §7.1, không phải hai
grep -c '2026-09-20' master_plan/shop-facts.md   # đọc bằng mắt các dòng in ra

# (4) pointer nói ngược lời vừa ghi là bug của LƯỢT NÀY, không phải task sau.
#     In cả lệnh CHƯA lọc cạnh lệnh đã lọc — một kết quả rỗng vì viết sai trông
#     y hệt một kết quả rỗng vì không có lỗi (F-017).
grep -rn 'C36' --include='*.md' docs/ master_plan/ work/ prompt/ | wc -l   # > 0
grep -rn 'C36' --include='*.md' docs/ master_plan/ work/ prompt/ \
  | grep -i 'chưa về owner\|chưa có lời\|chờ chuyển'                       # rỗng

# (5) unknown mới ĐƯỢC brief nhìn thấy — đây là phép chấm thật, không phải grep
./scripts/brief.sh | sed -n '/OPEN UNKNOWNS/,/LATEST DECISIONS/p'

# (6) ranh giới pha ADR-035
git diff --unified=0 | grep -c '^+'                              # chưa lọc: > 0
git diff --unified=0 | grep -E '^\+' \
  | grep -nEi 'CREATE TABLE|FOREIGN KEY|\bGET /|\bPOST /|/api/|<[A-Z][A-Za-z]+ />'   # rỗng

# (7) bảng §8 của architecture.md KHÔNG mất hàng nào
git diff -- docs/product/1-system-design/architecture.md | grep '^-' | grep '|'

# (8) Gate 1c đọc theo KHỐI, không theo dòng (F-015) — chạy gate thật
./scripts/check-doc-status.sh

# (9) cổng của repo
./scripts/gate.sh
```

## Unknowns

**Không câu nào chặn việc này** — `C36` đã có lời, và lượt này chỉ chuyển lời ấy đi. Nhưng lời đáp
hẹp hơn chỗ trống mà ba tài liệu gọi tên, nên lượt này **sẽ mở** câu mới. Ba vế đã thấy trước khi
bắt đầu; đọc lại nguyên văn lời đáp rồi tự đếm, đừng tin danh sách này (**F-003**):

1. **Bốn trạm còn lại** — `trang_banh` · `gap_banh` · `canh`+`don_ban`. Câu hỏi chỉ hỏi về quầy.
   Không có lời thì số **6** của §8.6 (*bao nhiêu người đang làm*) vẫn không có nguồn.
2. **Ai tạo cái mốc ấy** — người vào tự bấm, người ra bấm, hay POS bấm hộ. Lời đáp nói máy **ghi**,
   không nói ai khai.
3. **Hai cửa ghi ngoài quầy** — người đi giao (`shop-facts.md` §6.7) và chủ quán đổi giá (§6.17).
   **I-012** đòi *ai bấm* cho cả hai, và lời `C36` không phủ chúng.

Cả ba là **câu của chủ quán**, không phải câu kỹ thuật: không có lời thì không có phương án hẹp nào
để chọn, chỉ có đoán (`CLAUDE.md` §3.5). Chúng **không** chặn lượt này; chúng là đầu ra của nó.

## Report (AI trả lời sau khi làm)

1. **Mục §8 nào** đã dùng — số thật, và vì sao là số đó (mục con cuối cùng trước lượt này).
2. **Nguyên văn lời `C36`** đã đi vào owner nào, và chỗ nào chỉ **trỏ về**.
3. **Mã `U-XXX` mới** — bao nhiêu, mỗi mã một câu, và mỗi mã đang chặn gì. Kèm output thật của
   `./scripts/brief.sh` chứng minh brief **nhìn thấy** chúng.
4. Kết quả grep bước (2) và (4) của *Verify*: chỗ nào định nghĩa, chỗ nào trỏ về, chỗ nào đã sửa.
5. **Cái gì vẫn CHƯA xong sau lượt này** — phạm vi bốn trạm còn lại, vế *ai* của **ADM-50**, và
   hình dạng dữ liệu (pha 2). Mỗi thứ kèm link tới đúng dòng nó được viết (`CLAUDE.md` §7.3).
6. Output thật của `./scripts/check-doc-status.sh` và `./scripts/gate.sh`.
7. Khối `git commit` dán được (`CLAUDE.md` §6.1) — liệt kê từng file, **không** có `work/scope.txt`.
