# P1-03 — Nguồn thời gian và định nghĩa NGÀY BÁN cho mọi phép cộng tiền (L2) · pha 1, bước 3/12

> Bước **3/12** của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6. Mô tả dài ở
> `work/backlog_SD.md` → **P1-03**; trạng thái ở `work/backlog.md`.
> **Cần xong trước:** P1-01 — **đã xong 2026-09-04** (`docs/decisions.md` **ADR-035**).
> ⛔ **Đang bị chặn một phần: `U-032`** (`docs/product/99-unknowns.md`). Mục *nhập bù từ sổ giấy*
> **để trống có chủ ý** cho tới khi chủ quán trả lời — đọc mục *Unknowns* dưới đây trước khi viết.
> Bước này **mở khoá P1-04**: cột *phép đối chiếu* của `I-014` rỗng nghĩa cho tới khi nó xong.

## Context

**Múi giờ và giờ bán đã là dữ kiện** (`master_plan/shop-facts.md` §1) — đây **không** phải chỗ
thiếu. Chỗ thiếu là **ranh giới của một ngày cho phép cộng tiền**, và ba luật đã chốt cùng chạm vào
nó theo ba chiều khác nhau:

| Luật | Tính vào ngày | Chốt ở |
|---|---|---|
| Bán, kể cả khoản khách **nợ** | **ngày ghi nợ** | `master_plan/shop-facts.md` §6.14 (2026-08-31) |
| **Hoàn tiền** | **ngày hoàn**, không phải ngày bán gốc | §6.4 (2026-09-01) |
| Lượt bán trên **sổ giấy** | *"nhập ngay khi có thể, không có mốc giờ cứng"* | §6.11 (2026-09-02) |

Hai luật đầu đứng vững vì `I-014` (`quality/invariants.md`) giữ câu *doanh thu một ngày cộng từ đủ
hai nguồn, và không khoản tiền nào đứng ở hai nguồn* — cùng với luật *đã đối soát thì không đổi về
sau*. Luật thứ ba **không nói ngày nào**, và đó chính là **`U-032`**, mở 2026-09-03 (T-048).

`docs/product/1-system-design/architecture.md` §6.4 đã bày công thức đối soát cuối ngày với ngưỡng
lệch **0đ**, và §6.3 cộng doanh thu từ **hai** nguồn; §12 (nợ) đặt hai ngày ngược chiều nhau cho
một khoản nợ. **Cả ba công thức chỉ đọc được khi *một ngày* đã có nghĩa** — hôm nay chưa có tài
liệu nào định nghĩa nó.

Đọc trước khi viết dòng đầu tiên: `master_plan/shop-facts.md` §1 · §6.4 · §6.10 · §6.11 · §6.14 ·
`quality/invariants.md` **I-014** · **I-015** · `docs/product/1-system-design/architecture.md`
§6.3 · §6.4 · §12, và **U-032** ở `docs/product/99-unknowns.md`.

## Goal

Mọi phép cộng tiền trong hệ thống — doanh thu · nợ · hoàn · đối soát — dùng **cùng một** định nghĩa
*một ngày bán*, và định nghĩa ấy có **đúng một chỗ** để đọc.

## Scope

Được sửa:
- `docs/product/1-system-design/` — **một file mới**, tên `02-thoi-gian-ngay-ban.md`
  (bản đồ file ở kế hoạch §5). File sinh ra **cùng** dòng nội dung đầu tiên của nó.
- `docs/product/00-index.md` — **một dòng** vào bảng *Pha 1*, trong **cùng** thay đổi
- `master_plan/shop-facts.md` — **chỉ khi** chủ quán trả lời `U-032` trong lượt này: lời chốt vào
  §6 + một dòng nhật ký §7.1, **trước** khi viết tiếp mục mới
- `docs/product/99-unknowns.md` — **chỉ** mục `U-032`, và chỉ khi nó có lời giải
- `work/backlog.md` · `work/backlog_SD.md` — **chỉ** dòng và entry P1-03
- `work/scope.txt` — **thêm** khối của mình (**F-010** · **F-014**)

Không được sửa:
- `docs/product/1-system-design/architecture.md` §6.3 · §6.4 · §12 — **không viết lại công thức**.
  Bước này cấp cho chúng một định nghĩa, không sửa chúng. Thấy một công thức nói ngược định nghĩa
  mới ⇒ đó là bug của lượt này, sửa **tại chỗ** và khai thêm scope, nói ra chứ đừng sửa lén.
- `quality/invariants.md` — `I-014` và `I-015` **không đổi lời**. Bước này làm cột *phép đối chiếu*
  của chúng đọc được, không sửa mệnh đề.
- `master_plan/prompt-fullstack.md` — bản xuất khẩu không sở hữu gì (**ADR-035**)
- `docs/product/0-ba/**` — pha 1 không mở lại nghiệp vụ

## Constraints

- **Đây là định nghĩa cho PHÉP CỘNG TIỀN, không phải giờ mở cửa.** 6h–11h là giờ **bán**
  (`master_plan/shop-facts.md` §1), còn tiền thì đi cả sau đó: một lần **thu nợ** hay **hoàn tiền**
  rơi vào 14h vẫn phải có ngày. Định nghĩa phải phủ cả những giờ ấy.
- **Giữ `I-014`.** *Doanh thu một ngày **đã đối soát** không bao giờ đổi về sau* — mọi đường ra
  của bước này phải giữ được câu ấy, hoặc nói thẳng nó đang bị đe doạ và mã của chỗ chặn.
- **Giữ luật ngưỡng lệch 0đ** (`docs/product/1-system-design/architecture.md` §6.4, **ADR-022** —
  *"cổng chất lượng mạnh nhất của cả dự án"*). Một định nghĩa ngày làm ngưỡng ấy không đo được nữa
  là một định nghĩa sai, kể cả khi nó gọn hơn.
- **Giữ `I-015`** (một lần thu chia được nhiều phương thức, tổng luôn khớp, từng phần ghi riêng):
  một lần thu **không** được rơi vào hai ngày khác nhau theo hai phương thức.
- **Không tự quyết `U-032` bằng câu *"cứ tính ngày gõ cho tiện"*.** Đó là quyết định **tiền**, và
  cả hai đường ra đều phá một thứ đang có — lý lẽ đầy đủ trong chính U-032 (`CLAUDE.md` §3.5).
- **Ranh giới pha (ADR-035):** không tên bảng · tên cột · kiểu dữ liệu thời gian · endpoint ·
  route. Viết *"mốc này phải do **một** nguồn thời gian duy nhất cấp, không do máy khách gửi lên"*,
  đừng viết tên một cột hay một kiểu.
- **Một định nghĩa, một chỗ.** Ba luật **trỏ** về nó; không luật nào được nhắc lại định nghĩa bằng
  lời của mình — bản thứ hai luôn trôi (`work/findings.md` **F-001**).
- **Chưa có lời giải thì viết phương án HẸP NHẤT và nói thẳng là đang treo**
  (`docs/product/1-system-design/architecture.md` §11, câu cuối). Không tự chọn phương án rộng rồi
  ghi như đã chốt.

## Acceptance

1. Có **một** file mới trong `docs/product/1-system-design/`, và `docs/product/00-index.md` bảng
   *Pha 1* có **đúng một** dòng mới trỏ tới nó — cùng một thay đổi.
2. File mới có **đúng một** mục định nghĩa *một ngày bán* cho phép cộng tiền, và định nghĩa ấy nói
   rõ **mốc bắt đầu** và **mốc kết thúc**.
3. Định nghĩa phủ cả tiền đi **ngoài giờ bán**: thu nợ và hoàn tiền lúc 14h vẫn có ngày.
4. Ba luật đã chốt — **bán/nợ** · **hoàn** · **sổ giấy** — mỗi luật có một dòng **trỏ về** định
   nghĩa ấy, và không dòng nào nhắc lại định nghĩa bằng lời của mình.
5. Có một mục nói **nguồn thời gian**: mốc tiền do **một** nguồn duy nhất cấp, không do máy khách
   gửi lên — viết bằng ngôn ngữ tầng, không tên cột, không kiểu dữ liệu.
6. Ca **nhập bù từ sổ giấy** **để trống có chủ ý**, ghi thẳng *"đang chờ `U-032`"* **ngay tại chỗ**
   — đúng luật kế hoạch §9 (một ô không tick được thì để trống kèm mã của chỗ đang chặn).
   *(Nếu chủ quán đã trả lời trong lượt này: lời chốt vào `master_plan/shop-facts.md` **trước**,
   `U-032` chuyển sang vùng đã đóng, rồi mục mới mới được viết đầy — theo thứ tự ấy, không ngược.)*
7. `I-014` và `I-015` ở `quality/invariants.md` **không đổi một chữ nào** trong lượt này.
8. Không dòng nào trong file mới chứa tên bảng · tên cột · kiểu dữ liệu · endpoint · route.
9. Mọi chỗ khác trong repo đang dùng cụm *"ngày bán"* hoặc *"một ngày"* cho phép cộng tiền **khớp**
   định nghĩa mới, hoặc được sửa trong **cùng** lượt (`CLAUDE.md` §7.2).
10. `./scripts/gate.sh` xanh — kể cả **Gate 1c**, thứ sẽ đỏ nếu `U-032` được nhắc bằng ngôn ngữ
    còn-mở sau khi nó đã đóng, hoặc ngược lại.

## Verify

```bash
# (1) file mới có mặt, mục lục kể tên nó — thay <FILE> bằng tên thật đã đặt
ls docs/product/1-system-design/
grep -n '1-system-design/' docs/product/00-index.md

# (2) ĐÚNG MỘT chỗ định nghĩa. Đọc kết quả bằng mắt: nhiều hơn một chỗ ĐỊNH
#     NGHĨA là bản sao thứ hai (F-001); nhiều chỗ TRỎ VỀ thì đúng.
grep -rn 'ngày bán' --include='*.md' docs/ quality/ master_plan/

# (3) ba luật đều trỏ về một chỗ — đọc tay ba dòng, đối chiếu chúng trỏ cùng mục
grep -n -i 'nợ\|hoàn\|sổ giấy' docs/product/1-system-design/<FILE>

# (4) U-032 còn treo thì mục nhập bù phải NÓI RA điều đó
grep -n 'U-032' docs/product/1-system-design/<FILE>

# (5) hai invariant KHÔNG bị sửa lời trong lượt này
git diff --stat -- quality/invariants.md            # rỗng

# (6) ranh giới pha ADR-035. In cả lệnh CHƯA lọc cạnh lệnh đã lọc — một bộ lọc
#     rỗng vì viết sai trông y hệt một bộ lọc rỗng vì không có lỗi (F-017).
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -c '^+'                                    # chưa lọc: > 0
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -E '^\+' \
  | grep -nEi 'CREATE TABLE|FOREIGN KEY|timestamptz|DATE\b|\bGET /|\bPOST /|/api/'  # rỗng

# (7) Gate 1c đọc theo KHỐI, không theo dòng — một câu nói U-032 "chưa có lời"
#     có thể GÓI DÒNG và một grep theo dòng sẽ mù với nó (F-015). Chạy gate thật:
./scripts/check-doc-status.sh

# (8) cổng của repo
./scripts/gate.sh
```

## Unknowns

**`U-032` — một lượt bán ghi trên SỔ GIẤY hôm mất điện, hôm sau mới nhập vào máy, thì doanh thu
tính ngày nào.** Đang mở, chủ quán trả lời. Đọc nguyên văn ở `docs/product/99-unknowns.md`, vùng
*Đang mở* — **đừng đọc bản tóm này thay cho nó**.

Vì sao không được tự quyết: **hai đường ra đều phá một thứ đang có.** Tính về *ngày bán thật* thì
một ngày **đã đối soát** đổi số về sau ⇒ phá `I-014`. Tính về *ngày gõ vào máy* thì bảng đối soát
của ngày mất điện chạy với dữ liệu thiếu ⇒ ngưỡng lệch 0đ (**ADR-022**) báo lệch mà lý do chỉ là
*"chưa gõ xong"*, và hệ quả ấy `master_plan/shop-facts.md` §6.11 đã suy ra trước.

**Cách hỏi — không phải chuyện lễ nghi, nó đã hỏng một lần và tốn một ngày.** Hỏi về **cái quán**,
đừng hỏi về cái bảng trong máy. Câu `S-4` ngày 2026-08-31 hỏi về một cái bảng và chủ quán trả lời
*"tôi không hiểu"*; hỏi lại ngày 2026-09-01 về cái quán thì được trả lời ngay, kèm ba lý do không
ai gợi ý (`master_plan/shop-facts.md` §7.2). Câu hỏi đã soạn sẵn nằm trong chính gạch đầu dòng
U-032 — dùng nó, đừng viết lại.

**Có lời giải thì thứ tự là:** ghi vào `master_plan/shop-facts.md` (nhà duy nhất của dữ kiện quán,
**ADR-001**) → chuyển `U-032` sang vùng đã đóng ở `docs/product/99-unknowns.md` → rồi mới viết mục
mới. Ngược thứ tự là tạo bản sao thứ hai của một dữ kiện (**F-001**).

## Report (AI trả lời sau khi làm)

1. Định nghĩa *một ngày bán* viết ra là gì, mốc đầu và mốc cuối, và nó phủ giờ nào ngoài giờ bán.
2. Ba luật trỏ về nó ở đâu — ba dòng, mỗi dòng một file + số mục.
3. `U-032`: còn treo hay đã đóng. Còn treo ⇒ chỉ đúng chỗ trong file mới đang để trống và câu ghi
   ở đó. Đã đóng ⇒ lời chốt vào `master_plan/shop-facts.md` mục nào, ngày nào, ai chốt.
4. Kết quả `grep -rn "ngày bán"`: chỗ nào **định nghĩa**, chỗ nào chỉ **trỏ về**, chỗ nào phải sửa
   trong cùng lượt.
5. Output thật của mục *Verify*, của `./scripts/check-doc-status.sh` và của `./scripts/gate.sh`.
6. Khối `git commit` dán được (`CLAUDE.md` §6.1) — **không** có `work/scope.txt` trong khối.
