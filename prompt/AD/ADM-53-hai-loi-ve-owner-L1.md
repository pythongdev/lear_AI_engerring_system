# ADM-53 — Đưa **Đ-2** và **Đ-4** về owner, và hỏi `C36` nhân cùng lượt (L1) · lane admin

> Mô tả dài ở `work/backlog_AD.md` → **ADM-53**; trạng thái ở `work/backlog.md`.
> **Loại 3** — việc duy nhất của lane nhận được ngay, không chờ ai
> (`work/backlog_AD.md`, mục *Cổng của cả lane*).
> **Mở khoá:** cả nhánh C (ADM-20…ADM-24) và câu *lane admin chạy song song pha 1 hay chờ pha 1*.
>
> ⚠️ **Việc này có một bước mà AI không làm được một mình: bước hỏi.** Không có lời chủ quán thì
> prompt này dừng ở bước 4 và báo cáo là đã hỏi — chuyển hộ là vi phạm `CLAUDE.md` §3.5, luật
> **không có mức L0**.

## Context

Chủ quán chốt **bốn** câu trong phiên ngày **2026-09-01**. Hôm ấy không file nào ghi lại được, vì
`docs/product.md` đang có thay đổi chưa commit của phiên BA-07 — đúng cơ chế sự cố `work/findings.md`
**F-013** · **F-014**. Hai trong bốn lời đã đi qua đúng cửa *chủ quán xác nhận lại → chuyển về
owner*:

| Lời | Trạng thái | Nằm ở đâu hôm nay |
|---|---|---|
| **Đ-1** — mở cả ba mảng vào phạm vi | ✅ về owner 2026-09-02 (T-040) | `docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.4 · `docs/product/1-system-design/architecture.md` §10 · `master_plan/shop-facts.md` §7.1 |
| **Đ-3** — nguyên liệu ở mức *sổ ghi tay điện tử* | ✅ về owner 2026-09-04 (T-050) | `master_plan/shop-facts.md` §8.4 · `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 · mở `U-034` |
| **Đ-2** — thứ tự làm | ❌ **chưa** | chỉ `work/admin-questions.md` §1 |
| **Đ-4** — mảng con người làm **cả ba mức** | ❌ **chưa** | chỉ `work/admin-questions.md` §1 |

`work/admin-questions.md` **tự khai ở banner đầu trang rằng nó sẽ bị xoá** khi mọi câu đã chuyển đi.
Hai lời chưa về owner đang sống trong đúng file ấy, và cả nhánh C của `work/backlog_AD.md` lấy
*"cả ba mức"* làm tiền đề.

Điều kiện của **Đ-2** — *đóng nốt chuỗi BA trước* — **đã đủ**: BA-08 · BA-09 · BA-10 · BA-11 ·
BA-12 · BA-13 đều `Done` tính tới 2026-09-04 (`work/backlog.md`). Điều kiện đủ **không** thay được
lời xác nhận.

Đọc trước khi viết dòng đầu tiên: `work/admin-questions.md` §1 (bảng bốn lời) và §3 câu `C36` ·
`master_plan/shop-facts.md` §7.1 (nhật ký chốt) · §8.3 (cách đánh số tiếp) · §8.4 (bản mẫu T-050
đã làm) · `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 ·
`docs/product/1-system-design/architecture.md` §4 · §8 · §14 · `docs/decisions.md` **ADR-013** ·
**ADR-031** · **ADR-036** · `work/backlog_AD.md` mục *Ba lời đang treo* và *Ba mảng này chưa được
xếp lịch so với pha 1*.

## Goal

Bốn lời chốt ngày 2026-09-01 đều nằm ở owner của chúng, và câu *lane admin chạy **song song** pha 1
hay **chờ** pha 1 xong* có một lời viết ra ở một chỗ đọc được.

## Scope

Được sửa — **chỉ khi chủ quán đã trả lời trong lượt này**:
- `master_plan/shop-facts.md` — **Đ-4** vào một **mục con mới của §8**, cộng một dòng nhật ký §7.1
- `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 — mục admin, một khối có nhãn (**ADR-013**)
- `docs/product/1-system-design/architecture.md` §14 — mục admin, một khối có nhãn (**ADR-013**)
- `work/admin-questions.md` — §1: gạch hàng **Đ-2** · **Đ-4**, sửa banner trạng thái; §3: gạch
  `C36` nếu nó được trả lời trong lượt này
- `docs/product/99-unknowns.md` — **chỉ khi** lời chủ quán mở ra một câu mới chưa ai hỏi

Được sửa — **trong mọi trường hợp**:
- `work/backlog.md` — dòng trạng thái ADM-53, và **Đ-2** nếu có lời (nó là dữ kiện **xếp lịch của
  repo**)
- `work/backlog_AD.md` — dòng *Xong ngày…* ở entry ADM-53, mục *Ba lời đang treo*, mục *Ba mảng này
  chưa được xếp lịch so với pha 1*
- `prompt/AD/README.md` — cột *Prompt* và cột *Mở khoá bằng* của những việc mà lời vừa ghi mở khoá
- `work/scope.txt` — **thêm** khối của mình (**F-010** · **F-014**)

Không được sửa:
- **`master_plan/shop-facts.md` §1–§7** — Đ-4 là dữ kiện **admin**, và §8.3 nói rõ dữ kiện admin
  chỉ vào §8. Ngoại lệ duy nhất là **một dòng** nhật ký §7.1.
- **`work/backlog_AD.md` entry của bất kỳ việc nào khác ADM-53.** Lời Đ-4 mở khoá nhánh C, nhưng
  *mở khoá* không phải *viết hộ*: entry ADM-20…ADM-24 đổi hình dạng ở lượt nhận chúng, không ở đây.
- **`quality/invariants.md` · `docs/decisions.md`** — lượt này chuyển một lời đã chốt về owner, nó
  không quyết định gì mới. Cần một ADR nghĩa là bạn đang tự quyết (§3.5) — dừng lại.
- **`prompt/SD/` · `prompt/BA/` · `scripts/` · `docs/product/2-*` trở đi** — không thuộc việc này.
- **Mọi câu hỏi khác ở `work/admin-questions.md` §3** ngoài `C36`. Trả lời được nhóm nào thì đó là
  một task khác, không gộp vào đây (`docs/prompt-guideline.md` §4 — *nhiều goal trong một prompt*).

## Constraints

- **Không chuyển khi chưa hỏi được.** Lời chốt gốc ngày 2026-09-01 **không** đủ: T-040 và T-050 đều
  chờ chủ quán nhắc lại rồi mới chạy. `CLAUDE.md` §3.5 không có mức L0.
- **Đừng coi *điều kiện đã đủ* là *lời đã xác nhận*.** Chuỗi BA đóng rồi không có nghĩa chủ quán vẫn
  muốn thứ tự cũ. Hỏi mất một câu; đoán sai mất một nhánh.
- **Đ-2 KHÔNG vào `master_plan/shop-facts.md`.** Nó là thứ tự làm việc của **repo**, không phải dữ
  kiện của **quán**; `shop-facts.md` là nhà của dữ kiện quán (**ADR-001**) và §8.3 chỉ nhận dữ kiện
  admin. Nhà của Đ-2 là `work/backlog.md`.
- **Đ-4 vào MỤC RIÊNG CÓ NHÃN, không trộn vào mục của mảng bán hàng** (**ADR-013**). T-040 đã sai
  đúng chỗ này một lần và đó là lý do ADR-013 tồn tại.
- **Số mục con của §8 lấy theo §8.3 tại thời điểm chạy, đừng chép số từ entry.** Entry ADM-53 viết
  ngày 2026-09-04 nói *"§8.5"*; **§8.5 và §8.6 đã bị lấy trong cùng ngày** cho hai dữ kiện khác. Mở
  `master_plan/shop-facts.md` §8, đếm mục con cuối cùng, lấy số kế tiếp. Đây là lần thứ n của họ
  lỗi *"con số viết trong prompt đã hết hạn"* (**F-003** · **F-018**).
- **Ranh giới pha (ADR-035):** lời Đ-4 nói mảng con người làm tới **ba mức**, không nói nó lưu ở
  đâu. Viết ở tầng nghiệp vụ; không tên bảng · tên cột · endpoint · route · component.
- **`C36` hỏi nhân thể, nhưng KHÔNG gộp việc.** Có lời `C36` ⇒ ghi lời ấy vào
  `work/admin-questions.md` §3 dòng *Trả lời*, và dừng ở đó: chuyển `C36` về owner và thiết kế
  quyền theo nó là **ADM-21** · **P1-07**, không phải lượt này.
- **Hỏi về CÁI QUÁN, đừng hỏi về cái bảng trong máy.** Câu `S-4` ngày 2026-08-31 hỏi về một cái
  bảng và chủ quán trả lời *"tôi không hiểu"*; hỏi lại ngày 2026-09-01 về cái quán thì được trả lời
  ngay, kèm ba lý do không ai gợi ý (`master_plan/shop-facts.md` §7.2).
- **Ghi đúng loại: được nói ≠ tự suy ra.** Chủ quán nói gì thì vào nhật ký §7.1; chỗ bạn suy ra để
  lấp khoảng trống thì vào §7.2 và mang mã `S-X` riêng (`CLAUDE.md` §7.2, **F-004**).

## Acceptance

**Nhánh A — chủ quán KHÔNG trả lời được trong lượt này:**

1. `work/backlog_AD.md` entry ADM-53 và `work/backlog.md` ghi rõ **đã hỏi ngày nào, hỏi câu nào**,
   và ADM-53 vẫn ở *In Progress* — **không** tick *Done*.
2. **Không một dòng nào** của `master_plan/shop-facts.md`, `docs/product/0-ba/admin/01-ranh-gioi.md`
   hay `docs/product/1-system-design/architecture.md` bị đổi trong lượt này.
3. `work/admin-questions.md` §1 vẫn để **Đ-2** và **Đ-4** ở trạng thái *chưa về owner*.

**Nhánh B — chủ quán CÓ trả lời:**

4. **Đ-4** nằm ở **một** mục con mới của `master_plan/shop-facts.md` §8, số lấy theo §8.3, và có
   **đúng một** dòng mới ở nhật ký §7.1 trỏ về mục ấy — cùng một thay đổi.
5. **Đ-4** có một khối **có nhãn** ở `docs/product/0-ba/admin/01-ranh-gioi.md` §1.6 và ở
   `docs/product/1-system-design/architecture.md` §14, và **cả hai khối TRỎ về** mục §8 vừa viết,
   không nhắc lại lời chốt bằng lời của mình (**F-001**).
6. **Đ-2** — cộng vế mới *song song hay nối tiếp pha 1* — nằm ở `work/backlog.md`, và **không** có
   một chữ nào của nó trong `master_plan/shop-facts.md`.
7. `work/backlog_AD.md` mục *Ba mảng này chưa được xếp lịch so với pha 1* nay **có** lời, và mục
   *Ba lời đang treo* không còn kể tên Đ-2 · Đ-4 như đang treo.
8. `work/admin-questions.md`: §1 gạch **Đ-2** · **Đ-4** và banner trạng thái khớp; nếu cả bốn lời
   đã về owner thì §1 co lại còn **một dòng lịch sử trỏ tới owner**.
9. `prompt/AD/README.md`: mọi hàng mà lời vừa ghi mở khoá đã đổi cột *Mở khoá bằng*, trong **cùng**
   lượt (`CLAUDE.md` §7.2).
10. ADM-53 tick *Done* ở `work/backlog.md`; entry ở `work/backlog_AD.md` **ở lại** kèm dòng
    *Xong ngày…* (luật 3 đầu file ấy); khối pattern của mình đã xoá khỏi `work/scope.txt`.

**Cả hai nhánh:**

11. Không dòng nào viết trong lượt này chứa tên bảng · tên cột · endpoint · route · component.
12. `./scripts/gate.sh` xanh.

## Verify

```bash
# (1) Đ-4 có mặt ở owner, và số mục con là số CÒN TRỐNG chứ không phải số chép
#     từ entry. Đọc bằng mắt: mục con cuối cùng trước lượt này là mục nào.
grep -nE '^### 8\.[0-9]+ ' master_plan/shop-facts.md
grep -n 'Đ-4\|ba mức\|chấm công' master_plan/shop-facts.md

# (2) ĐÚNG MỘT chỗ ĐỊNH NGHĨA lời Đ-4, những chỗ khác chỉ TRỎ VỀ. Nhiều chỗ định
#     nghĩa là bản sao thứ hai (F-001); nhiều chỗ trỏ về thì đúng.
grep -rn 'cả ba mức' --include='*.md' docs/ master_plan/ work/

# (3) Đ-2 KHÔNG được có mặt trong nhà của dữ kiện quán — lệnh này phải RỖNG
grep -n 'Đ-2' master_plan/shop-facts.md

# (4) hai khối có nhãn ở hai tài liệu, và chúng TRỎ VỀ §8
grep -n -A3 'admin' docs/product/0-ba/admin/01-ranh-gioi.md | grep -n 'shop-facts'
grep -n 'shop-facts' docs/product/1-system-design/architecture.md

# (5) ranh giới pha ADR-035. In cả lệnh CHƯA lọc cạnh lệnh đã lọc — một bộ lọc
#     rỗng vì viết sai trông y hệt một bộ lọc rỗng vì không có lỗi (F-017).
git diff --unified=0 | grep -c '^+'                              # chưa lọc: > 0
git diff --unified=0 | grep -E '^\+' \
  | grep -nEi 'CREATE TABLE|FOREIGN KEY|\bGET /|\bPOST /|/api/|<[A-Z][A-Za-z]+ />'   # rỗng

# (6) nhánh A: ba tài liệu owner KHÔNG bị chạm — ba lệnh này phải rỗng
git diff --stat -- master_plan/shop-facts.md
git diff --stat -- docs/product/0-ba/admin/01-ranh-gioi.md
git diff --stat -- docs/product/1-system-design/architecture.md

# (7) pointer nói ngược lời vừa ghi là bug của LƯỢT NÀY, không phải task sau
grep -rn 'chưa được xác nhận lại\|chưa về owner\|Đ-2\|Đ-4\|ADM-53' \
  --include='*.md' docs/ master_plan/ work/ prompt/

# (8) Gate 1c đọc theo KHỐI, không theo dòng — một câu nói Đ-4 "chưa về owner"
#     có thể GÓI DÒNG và một grep theo dòng sẽ mù với nó (F-015). Chạy gate thật:
./scripts/check-doc-status.sh

# (9) cổng của repo
./scripts/gate.sh
```

## Unknowns

Ba câu, và **cả ba đều là câu của chủ quán** — không câu nào có phương án hẹp để tự chọn. Không có
lời thì dừng ở bước hỏi.

1. **Đ-4 — mảng con người có làm **cả ba mức** không** (trực trạm + chấm công + tính lương). Chủ
   quán chốt 2026-09-01; cần xác nhận lại. Nguyên văn ở `work/admin-questions.md` §1, hàng Đ-4.
2. **Đ-2 — thứ tự làm, và vế mới: lane admin chạy SONG SONG pha 1 hay CHỜ pha 1 xong.** Vế đầu chốt
   2026-09-01 và điều kiện của nó đã đủ; vế sau **chưa ai hỏi**. `docs/decisions.md` **ADR-031** chỉ
   nói *sau mảng bán hàng*, và mảng bán hàng đóng rồi — nên hôm nay mỗi phiên tự đoán một câu.
3. **`C36` — người đứng quầy đổi giữa buổi thì máy có ghi lại mốc đổi ấy không.** Nguyên văn ở
   `work/admin-questions.md` §3. Đây là câu **đòn bẩy lớn nhất của cả lane**:
   `docs/product/1-system-design/architecture.md` §4 chốt **quyền gắn chỗ đứng, không gắn chức vụ**,
   còn §8 đo rằng **không dữ liệu nào ghi ai đang đứng đâu**. Chừng nào `C36` chưa có lời, mọi thiết
   kế quyền của pha sau phải gán quyền theo chức vụ — tức **làm ngược một luật đã chốt** — hoặc dừng.

**Có lời thì thứ tự là:** ghi vào owner (`master_plan/shop-facts.md` cho Đ-4, `work/backlog.md` cho
Đ-2) → sửa mọi pointer đang nói ngược → rồi mới tick *Done*. Ngược thứ tự là tạo bản sao thứ hai
của một dữ kiện (**F-001**).

## Report (AI trả lời sau khi làm)

1. **Đã hỏi được hay chưa** — nhánh A hay nhánh B của *Acceptance*. Nhánh A thì nói rõ đã hỏi ngày
   nào, ba câu hỏi ở đâu, và ADM-53 đang ở trạng thái nào.
2. **Đ-4 ghi ở mục nào** của `master_plan/shop-facts.md` §8 — **số thật đã dùng**, và vì sao là số
   đó (mục con cuối cùng trước lượt này là gì).
3. **Đ-2 ghi ở đâu trong `work/backlog.md`**, và lời cho câu *song song hay nối tiếp* là gì.
4. **`C36`**: có lời hay không. Có ⇒ chép lời vào §3 và nói rõ nó mở khoá ADM-21 và vế *ai* của
   ADM-50 — **không** thiết kế gì trong lượt này.
5. Kết quả `grep -rn` ở mục *Verify* bước (2) và (7): chỗ nào **định nghĩa**, chỗ nào chỉ **trỏ
   về**, chỗ nào đã sửa trong cùng lượt.
6. Những hàng nào của `prompt/AD/README.md` đã đổi, và những việc nào của nhánh C nay **viết được
   prompt** (viết được ≠ viết luôn — mỗi việc một lượt).
7. Output thật của `./scripts/check-doc-status.sh` và `./scripts/gate.sh`.
8. Khối `git commit` dán được (`CLAUDE.md` §6.1) — liệt kê từng file, **không** có `work/scope.txt`.
