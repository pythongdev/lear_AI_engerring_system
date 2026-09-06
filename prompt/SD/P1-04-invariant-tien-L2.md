# P1-04 — Bảng ba cột, nhóm TIỀN: `I-002` `I-005` `I-007` `I-012` `I-013` `I-014` `I-015` (L2) · bước 4/12

> Bước **4/12** của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6. Mô tả dài ở
> `work/backlog_SD.md` → **P1-04**; trạng thái ở `work/backlog.md`.
> **Cần xong trước:** P1-01 — **đã xong 2026-09-04** (`docs/decisions.md` **ADR-035**) · **P1-03** —
> **đã xong 2026-09-04**, định nghĩa *một ngày bán* ở
> `docs/product/1-system-design/02-thoi-gian-ngay-ban.md`.
> ⚠️ **Hai mã đang mở cùng chạm ĐÚNG MỘT ô — ô `I-014`:** **`U-036`** (khoản **trả trước** nhận
> ngày này cho đơn giao ngày khác tính doanh thu ngày nào) và **`U-037`** (nhập bù xong thì **ai**
> chấm lại ngày ấy, **lúc nào**). Viết ô ấy theo **phương án hẹp nhất** và ghi thẳng là đang treo.
> Chạy song song được với P1-05 và P1-06: ba nhóm **không dùng chung mệnh đề nào**.

## Context

`quality/invariants.md` đã có mệnh đề và khối *Verification* cho từng mục, nhưng khối ấy viết bằng
**kịch bản nghiệp vụ** — cách **một người** kiểm. Cái còn thiếu là **cột giữa: tầng nào giữ nó**.
Bước này điền cột ấy cho bảy mệnh đề chạm tiền, cộng cột thứ ba là **phép đối chiếu**.

**Từ vựng cột giữa là bắt buộc và chỉ có năm giá trị** — định nghĩa đầy đủ ở kế hoạch §7, đọc ở đó:
**1** cơ sở dữ liệu giữ · **2** một giao dịch giữ · **3** miền nghiệp vụ giữ · **4** người + thủ tục
giữ · **5** phép đối chiếu bắt sau khi hỏng.

**Nhóm này đi trước hai nhóm kia vì nó là nhóm mất tiền, và nó là chỗ rủi ro lớn nhất của cả pha
đang nằm** (kế hoạch §10): *một bảng ba cột trông đã đủ, trong khi cột giữa của mấy mệnh đề chạm
tiền chỉ là tầng 4 — người và thủ tục — mà không ai nói ra*. Năm ca dưới đây là năm chỗ cái rủi ro
ấy sẽ hiện ra nếu bảng được điền cho đẹp:

- **VietQR ở quán là mã TĨNH, không có webhook** (`docs/product/1-system-design/architecture.md` §7
  · `master_plan/shop-facts.md` §1 · §6.3). Hệ thống **không tự biết tiền đã về tài khoản**; câu
  *"đã nhận tiền"* do **người đứng quầy** nhìn tin nhắn báo có rồi bấm. ⇒ Phần *"tiền đã thật sự
  vào"* của `I-015` **không có tầng máy nào giữ được** — đừng thiết kế một cơ chế để nâng nó lên,
  và cũng đừng viết nó như đã có bảo vệ. Vế **máy giữ được** của `I-015` là vế khác: *tổng các
  phần = số phải trả* và *từng phần ghi riêng theo phương thức*.
- **`I-005` (nợ) rất dễ ghi nhầm là "đã có ràng buộc".** `docs/product/1-system-design/architecture.md`
  §12.3 có ba câu *"để database giữ, không để mã ứng dụng giữ"* — nhưng chính mục ấy tự khai là
  **đề xuất gửi sang pha 2**, không phải lược đồ đã chốt, và nó viết bằng **ngôn ngữ pha 2** (tên
  bảng, tên ràng buộc).
  Đọc nó **sau** khi đã viết xong dòng của mình bằng ngôn ngữ tầng, và **không chép** (**ADR-035**).
- **`I-014` có hai vế, và hai vế ở hai tầng khác nhau.** Vế *"không khoản nào đứng ở cả hai nguồn"*
  là vế máy giữ được. Vế *"cộng đủ hai nguồn"* là một **phép cộng**: không ràng buộc nào ngăn được
  một báo cáo quên một nguồn, chỗ bắt nó là đối soát cuối ngày. Và cả hai vế chỉ đọc được khi *một
  ngày* đã có nghĩa — **P1-03 đã cấp nghĩa ấy**:
  `docs/product/1-system-design/02-thoi-gian-ngay-ban.md` §1 (một ngày dài từ đâu tới đâu) và §2
  (mốc tính tiền của từng việc). **Hàng cuối bảng §2 còn để trống**
  (`U-036`), và `U-037` hỏi ai chấm lại một ngày sau khi nhập bù ⇒ ô `I-014` mang **hai** mã ấy.
- **`I-012` (vết) là chỗ dễ ghi tầng cao hơn sự thật nhất.** *"Mọi thao tác chạm tiền đi qua đúng
  một cửa: máy POS ở quầy"* là một câu **tầng 3** — nhưng nó có **hai ngoại lệ đã chốt**: người đi
  giao bấm *đã giao + đã thu tiền* tại chỗ khách (`shop-facts.md` §6.7) và chủ quán đổi giá / đổi
  thành phần suất trên mặt quản trị (§6.17). Ngoại lệ đã chốt **không phải lỗ thủng**, nhưng một
  hàng quên chúng mô tả một hệ thống không tồn tại. Vế *"đọc được sau nhiều ngày"* thì là **yêu
  cầu hình dạng dữ liệu** — đó là **P1-07**, bước này không thiết kế chỗ cất vết.
- **`I-013` (giá do hệ thống tính lại) là hàng mà tầng 3 thật sự cắn.** Một chỗ tính giá duy nhất,
  mọi đường đặt món đi qua nó, cho **cả năm** kênh — và **bước quầy duyệt không đỡ được** (`I-013`
  → *Why*: quầy chặn đơn ảo, không ai đứng đó cộng lại tiền từng dòng). Viết bằng ngôn ngữ tầng:
  *"chỉ một chỗ trong hệ thống được tính giá"*, **không** tên hàm, **không** endpoint.

Đọc trước khi viết dòng đầu tiên: kế hoạch §7 (năm tầng) · bảy mục `I-0xx` ở `quality/invariants.md`
· `docs/product/1-system-design/architecture.md` §6.3 · §6.4 (công thức đối soát năm dòng) · §7
(bốn đường tiền) · §12.2 · §12.3 · `docs/product/1-system-design/02-thoi-gian-ngay-ban.md` §1 ·
§2 · §2.1 · §2.2 · §5 (hàng **P1-04**) · `master_plan/shop-facts.md` §6.9 · §6.10 · §6.11 · §6.14 ·
§6.18 · hai câu đang mở `U-036` · `U-037` ở `docs/product/99-unknowns.md`, và `work/findings.md`
**F-026**.

## Goal

Bảy mệnh đề chạm tiền — `I-002` `I-005` `I-007` `I-012` `I-013` `I-014` `I-015` — mỗi mệnh đề có
**tầng giữ nó** và **một phép đối chiếu ra rỗng**, và **chỗ nào chỉ có người giữ thì nói thẳng ra
như thế**. Pha 2 đọc bảng ấy phải biết ngay **cái gì bắt buộc do cơ sở dữ liệu giữ** và **cái gì
không cơ chế nào giữ được**.

## Scope

Được sửa:
- `docs/product/1-system-design/` — file bảng ba cột, tên `03-bao-ve-invariant.md`
  (bản đồ file ở kế hoạch §5). File này do **ba** bước cùng viết: P1-04 · P1-05 · P1-06.
  **Chưa có ⇒ tạo, và tạo cùng dòng nội dung đầu tiên. Đã có ⇒ chỉ thêm mục của nhóm mình.**
- `docs/product/00-index.md` — **một dòng** vào bảng *Pha 1*, **chỉ khi** bước này là bước tạo file
- `work/backlog.md` · `work/backlog_SD.md` — **chỉ** dòng và entry P1-04
- `work/findings.md` — **chỉ** một mục `F-XXX` mới, **nếu** gặp một mệnh đề sai (xem *Constraints*)
- `work/scope.txt` — **thêm** khối của mình (**F-010** · **F-014**)

Không được sửa:
- **Mục của nhóm VÒNG ĐỜI (P1-05) và nhóm MENU·GIÁ·VẾT (P1-06) trong cùng file** — ba bước chạy
  song song được, nên file này là **một file, nhiều chủ**. Chỉ sửa bảy hàng của mình.
- `quality/invariants.md` — **không đổi lời một mệnh đề nào**, kể cả `I-014` mới sửa 2026-09-04.
  Bước này viết *ai giữ nó*, không viết lại *nó là gì*.
- `docs/product/1-system-design/architecture.md` — §6.3, §6.4, §7, §12.2, §12.3 **không đổi một
  dòng**. Công thức đối soát năm dòng ở §6.4 là thứ bước này **trỏ vào**, không phải thứ nó viết lại.
- `docs/product/1-system-design/02-thoi-gian-ngay-ban.md` — định nghĩa *ngày bán* và bảng *mốc
  tính tiền* đã chốt ở P1-03; hàng ⛔ để trống của nó **không được lấp** ở bước này (đó là `U-036`,
  câu của chủ quán).
- `master_plan/shop-facts.md` · `master_plan/prompt-fullstack.md` ·
  `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` — kể cả **không tick** ô nào của cổng §9.
- `docs/product/99-unknowns.md` — **không đóng** `U-036` hay `U-037`, và không suy hộ lời giải.

## Constraints

- **Ghi tầng CAO NHẤT thật sự đang giữ nó, không ghi tầng mình muốn nó ở** (kế hoạch §7, luật 1).
  Đây là rủi ro lớn nhất của cả pha (kế hoạch §10), và nhóm này là đúng nhóm nó nói tới.
- **Mỗi mệnh đề vẫn phải có phép đối chiếu (cột 3), kể cả khi cột 2 đã là tầng 1** (kế hoạch §7,
  luật 2). Ràng buộc cũng bị người ta gỡ; phép đối chiếu là thứ phát hiện ra điều đó.
- **Phép đối chiếu viết dạng *"tập này phải rỗng"*, bằng ngôn ngữ nghiệp vụ** (kế hoạch §7,
  luật 3). *"Mọi phiên đã đóng mà tổng các phần đã thu khác tổng hoá đơn và không có khoản nợ nào
  đứng tên — tập này phải rỗng"*. Pha 2 dịch nó thành câu truy vấn; **pha 1 không viết câu truy vấn**.
- **Ô nào chỉ tới được tầng 4 hoặc 5 phải nói thẳng *"máy không ngăn được"*** — đây là ô thứ hai
  của cổng chất lượng pha 1 (kế hoạch §9), tồn tại riêng để bắt ca bảng nói dối. Và nói kèm **cái
  máy CÓ giữ thay vào** (thường là cái vết — `I-012`).
- **Tầng 5 ở cột 2 không được là bản sao của cột 3.** Cả bảy hàng đều đối soát được ở cuối ngày;
  nếu cột 2 chép lại đúng câu của cột 3 thì hàng ấy nói **một** điều chứ không phải hai. Cột 2 trả
  lời *cái gì ngăn nó xảy ra*, cột 3 trả lời *cái gì bắt được nó khi đã xảy ra*.
- **Đừng tự thêm một luật mới để nâng một hàng lên tầng cao hơn.** Thêm luật là việc của **chủ
  quán** (`CLAUDE.md` §3.5, không có mức L0). Ca mẫu đã có sẵn ở kế hoạch §7 luật 1: `I-011`.
- **`I-005`: `architecture.md` §12.3 là ĐỀ XUẤT gửi pha 2, không phải ràng buộc đã có.** Ba câu
  *"để database giữ"* ở đó là **đầu vào**; hàng `I-005` viết bằng ngôn ngữ tầng của mình, và nếu
  đồng ý với đề xuất thì nói *"phải do cơ sở dữ liệu giữ"*, không chép hình dạng của nó.
- **`I-014` phải nói được HAI vế, không gộp làm một** — *cộng đủ hai nguồn* và *không khoản nào
  đứng ở cả hai*. Hai vế hỏng khác nhau và hai vế ở hai tầng khác nhau.
- **`I-015` đừng gộp với `I-002`.** `I-002` nói *tổng mọi đơn của một phiên = một hoá đơn duy
  nhất*; `I-015` nói *tổng các phần đã thu = số phải trả, từng phần ghi riêng theo phương thức*.
  Hai phép cộng khác nhau, và đối soát chia theo **phương thức** (`shop-facts.md` §6.10 — tiền mặt
  so với két, chuyển khoản so với tin nhắn báo có) chỉ đọc được cái thứ hai.
- **`I-007` là một nửa của một ranh giới; nửa kia là `I-006`, và `I-006` thuộc P1-05.** Hàng
  `I-007` **trỏ** sang nửa kia, **không** viết hộ hàng ấy và không mô tả lại nó.
- **Không thiết kế cơ chế, không vẽ màn hình.** Không nút *"khoá sổ"*, không webhook cho VietQR,
  không lịch chạy đối soát. Bước này nói **cái gì phải đúng và ai giữ cho nó đúng** — *khoá bằng
  gì* là pha 2 và pha 3.
- **Ranh giới pha (ADR-035):** cột giữa viết bằng **ngôn ngữ tầng** — *"trạng thái sai này phải
  **không tồn tại được** ở tầng cơ sở dữ liệu"* — **không** tên bảng, tên cột, tên ràng buộc,
  endpoint, route hay component. Hai chỗ trong repo tự phá luật này có chủ ý và cả hai đều là **đề
  xuất của pha 2**: `architecture.md` §12.3 và `master_plan/prompt-fullstack.md` §3.5 · §6.2. Đọc
  **sau**, không chép.
- **Thấy một mệnh đề ở `quality/invariants.md` sai hoặc thiếu vế ⇒ ghi `F-XXX` vào
  `work/findings.md`, KHÔNG sửa mệnh đề trong lượt này** (sửa invariant là task riêng, và nó chạm
  nghiệp vụ — `CLAUDE.md` §3 *scope trôi giữa chừng*).
- **Không mở lại nghiệp vụ** (`CLAUDE.md` §3.5). Gặp chỗ nghiệp vụ chưa rõ ⇒ `U-XXX`, một gạch đầu
  dòng trong vùng đang mở của `docs/product/99-unknowns.md`.

## Acceptance

1. File bảng ba cột có **một mục riêng cho nhóm TIỀN**, và mục ấy có **đúng bảy** hàng: `I-002`
   `I-005` `I-007` `I-012` `I-013` `I-014` `I-015`.
2. **Không ô nào trống** trong bảy hàng. Ba ô mỗi hàng: mệnh đề · bảo vệ bằng · phép đối chiếu.
3. Cột 1 **trỏ** `I-0xx`, **không chép** câu mệnh đề (`CLAUDE.md` §7.1 — pointer, không phải bản
   sao; **F-001**).
4. **Mọi giá trị ở cột giữa là một trong năm tầng của kế hoạch §7** — không có giá trị thứ sáu,
   không có chữ như *"xử lý cẩn thận"*.
5. Hàng nào có cột giữa là **tầng 4 hoặc 5** đều chứa câu *"máy không ngăn được"* (hoặc câu tương
   đương nói thẳng cùng nội dung), và nói cái máy **có** giữ thay vào.
6. Cột 3 của **cả bảy** hàng viết dạng *"tập này phải rỗng"*, bằng ngôn ngữ nghiệp vụ, không câu
   truy vấn nào, và **không hàng nào có cột 3 trùng nguyên văn cột 2**.
7. Hàng `I-015` nói được ca **VietQR tĩnh**: vế *"tiền đã thật sự vào tài khoản"* **không có tầng
   máy nào giữ**, người đứng quầy xác nhận (`architecture.md` §7), và nói ra cái máy giữ thay vào —
   *tổng các phần = số phải trả* và *từng phần ghi riêng theo phương thức*.
8. Hàng `I-005` **không** đọc `architecture.md` §12.3 thành ràng buộc đã có: nếu hàng ấy ghi tầng 1
   thì kèm chữ **phải do** cơ sở dữ liệu giữ (yêu cầu gửi pha 2), không phải *đã do*.
9. Hàng `I-014` có **cả hai** vế, mỗi vế có tầng của nó, và ô ấy mang **cả hai** mã `U-036` ·
   `U-037` kèm câu nói thẳng phần nào đang treo. **Không tick trơn.**
10. Hàng `I-012` kể **hai ngoại lệ đã chốt** của câu *"đi qua đúng một cửa POS"* — người đi giao
    (`shop-facts.md` §6.7) và chủ quán (§6.17) — và **không** thiết kế chỗ cất vết (đó là P1-07).
11. Hàng `I-013` viết cửa tính giá bằng **ngôn ngữ tầng**, phủ **cả năm** kênh, và nói rõ **bước
    quầy duyệt không phải cơ chế giữ nó**.
12. Hàng `I-007` **trỏ** `I-006` như nửa kia của cùng một ranh giới, và **không** mô tả lại `I-006`.
13. `quality/invariants.md` **không đổi một chữ nào** trong lượt này.
14. Không dòng nào chứa tên bảng · tên cột · tên ràng buộc · endpoint · route · component.
15. Nếu bước này là bước **tạo** file bảng ba cột: `docs/product/00-index.md` có thêm **đúng một**
    dòng ở bảng *Pha 1*, trong **cùng** thay đổi (kế hoạch §5, luật 2).
16. `./scripts/gate.sh` xanh, **Gate 1c** gồm.

## Verify

```bash
# (0) file bảng ba cột đang ở đâu, và nó đã có mục của nhóm nào — chạy TRƯỚC khi
#     viết: P1-05 hoặc P1-06 có thể đã tạo file này trong một phiên song song
ls -1 docs/product/1-system-design/
grep -n 'VÒNG ĐỜI\|MENU\|TIỀN' docs/product/1-system-design/03-*.md 2>/dev/null

# (1) bảy hàng có mặt — thay <FILE> bằng tên file bảng ba cột
grep -n 'I-002\|I-005\|I-007\|I-012\|I-013\|I-014\|I-015' docs/product/1-system-design/<FILE>

# (2) cột giữa chỉ nhận năm tầng. Đọc TAY bảy hàng và đối chiếu với kế hoạch §7;
#     đừng đếm số (F-018 — số đếm động không phải điều kiện nghiệm thu).
grep -n -i 'tầng 1\|tầng 2\|tầng 3\|tầng 4\|tầng 5' docs/product/1-system-design/<FILE>

# (3) hàng tầng 4/5 phải NÓI THẲNG. In cả hai vế rồi đối chiếu bằng mắt:
grep -n -i 'tầng 4\|tầng 5'        docs/product/1-system-design/<FILE>
grep -n    'máy không ngăn được'   docs/product/1-system-design/<FILE>

# (4) ô I-014 phải mang CẢ HAI mã đang mở
grep -n 'U-036\|U-037' docs/product/1-system-design/<FILE>

# (5) mệnh đề KHÔNG bị sửa lời ở lượt này
git diff --stat -- quality/invariants.md            # rỗng

# (6) công thức đối soát và mục nợ của architecture.md KHÔNG bị viết lại
git diff --stat -- docs/product/1-system-design/architecture.md   # rỗng
git diff --stat -- docs/product/1-system-design/02-thoi-gian-ngay-ban.md  # rỗng

# (7) "một khoản tiền một nguồn" viết tắt ở đâu cũng phải khớp I-006/I-007 —
#     đọc từng kết quả, sửa chỗ lệch trong CÙNG lượt (CLAUDE.md §7.2)
grep -rn 'đúng một đơn vị tính tiền' --include='*.md' docs/ quality/ master_plan/

# (8) ranh giới pha ADR-035. In cả lệnh CHƯA lọc cạnh lệnh đã lọc — một bộ lọc
#     rỗng vì viết sai trông y hệt một bộ lọc rỗng vì không có lỗi (F-017).
#     ⚠️ File MỚI chưa được git track thì `git diff` KHÔNG đọc nó: `git add -N`
#     trước, nếu không lệnh dưới chạy trên 0 dòng và vẫn báo xanh (bài học P1-03).
git add -N docs/product/1-system-design/
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -c '^+'                                    # chưa lọc: > 0
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -E '^\+' \
  | grep -nEi 'CREATE TABLE|FOREIGN KEY|UNIQUE\(|CHECK \(|\bGET /|\bPOST /|/api/|\bcomponent\b'  # rỗng

# (9) Gate 1c — một mã đã đóng bị trích dẫn như còn mở, và ngược lại
./scripts/check-doc-status.sh

# (10) cổng của repo
./scripts/gate.sh
```

## Unknowns

Hai câu đang mở chạm vào nhóm này, và **cả hai chạm đúng một ô: `I-014`**. **Không câu nào được tự
quyết** (`CLAUDE.md` §3.5); đọc nguyên văn ở `docs/product/99-unknowns.md` vùng *Đang mở*, đừng đọc
bản tóm này thay cho nó.

- **`U-036`** — một khoản khách **trả trước** mà quán nhận hôm nay, cho đơn giao vào một ngày khác,
  tính doanh thu **ngày nhận tiền** hay **ngày giao hàng**. Đây là **chiều ngược của §6.14**: luật
  nợ chốt ca tiền về **sau** một lần bán đã xong; ca tiền về **trước** một lần bán chưa xong thì
  chưa ai chốt. Nó chặn hàng cuối bảng §2 của
  `docs/product/1-system-design/02-thoi-gian-ngay-ban.md`, và
  qua đó chặn cột *phép đối chiếu* của `I-014`. ⇒ viết phương án hẹp nhất, ghi thẳng là đang treo.
- **`U-037`** — hôm sau nhập bù xong chỗ bán trên **sổ giấy**, **ai** ngồi lại đối soát ngày ấy
  một lần nữa, và **lúc nào**. Mở 2026-09-04 bởi chính lời chốt của `U-032` (`U-032` **đã đóng**
  cùng ngày: lượt nhập bù tính doanh thu **ngày quán bán** — `docs/decisions.md` **ADR-037**). Hệ
  quả đã ghi thành ADR: **một ngày còn lượt chưa nhập là một ngày chưa đối soát xong** — nên phép
  đối chiếu của `I-014` phải nói được điều kiện ấy, mà **ai** chạy nó thì chưa có lời. ⇒ viết
  phương án hẹp nhất, ghi thẳng là đang treo.

⚠️ **`F-026` — hai mệnh đề không thuộc nhóm nào.** `I-019` và `I-020` sinh ra ở BA-12 ngày
2026-09-03, **sau** khi kế hoạch §6 chia ba nhóm, nên chúng không nằm trong P1-04, P1-05 hay P1-06;
cổng chất lượng §9 vẫn đếm *"mười tám"* trong khi `quality/invariants.md` giữ **hai mươi**. Cả hai
là trục **sản xuất theo mẻ**, xa nhóm tiền nhất trong ba nhóm — nhưng **xếp chúng vào nhóm nào là
quyết định của chủ repo, không phải của phiên này**. Đọc `work/findings.md` **F-026** trước khi bắt
đầu; đừng lặng lẽ kéo chúng vào bảng của mình, và cũng đừng lặng lẽ bỏ chúng.

**Cách hỏi chủ quán, nếu hỏi được:** hỏi về **cái quán**, đừng hỏi về cái bảng trong máy — bài học
`S-4` ở `master_plan/shop-facts.md` §7.2. Cả hai câu trên đã có sẵn một câu hỏi soạn theo bài học ấy
ở `docs/product/99-unknowns.md`; dùng nguyên văn, đừng viết lại. Có lời giải ⇒ ghi vào
`master_plan/shop-facts.md` **trước**, đóng `U-XXX`, rồi mới viết tiếp ô của mình.

## Report (AI trả lời sau khi làm)

1. Bảy hàng, mỗi hàng: tầng nào giữ nó và **vì sao là tầng ấy chứ không phải tầng cao hơn**.
2. Hàng nào rơi vào tầng 4 hoặc 5, câu *"máy không ngăn được"* viết ở đâu, và cái máy **có** giữ
   thay vào là gì.
3. `I-015`: vế VietQR tĩnh viết thế nào, và có chỗ nào trong bảng vô tình nói như thể hệ thống tự
   biết tiền đã về không.
4. `I-005`: hàng ấy đọc `architecture.md` §12.3 là **đề xuất** hay **ràng buộc đã có** — trích đúng
   câu đã viết.
5. `I-014`: hai vế ở hai tầng nào, hai mã `U-036` · `U-037` nằm ở đâu trong ô, và phương án hẹp đã
   chọn là gì.
6. `F-026`: đã đọc chưa, và `I-019` · `I-020` được để nguyên ngoài bảng hay có **đề xuất** gì cho
   chủ repo — đề xuất, không phải quyết định.
7. Có mở `F-XXX` nào không (một mệnh đề sai hoặc thiếu vế phát hiện lúc điền), và vì sao **không**
   sửa nó trong lượt này.
8. Output thật của mục *Verify*, của `./scripts/check-doc-status.sh` và của `./scripts/gate.sh`.
9. Khối `git commit` dán được (`CLAUDE.md` §6.1) — **không** có `work/scope.txt` trong khối.
