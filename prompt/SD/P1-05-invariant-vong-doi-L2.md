# P1-05 — Bảng ba cột, nhóm VÒNG ĐỜI: `I-001` `I-003` `I-004` `I-006` `I-016` `I-017` (L2) · bước 5/12

> Bước **5/12** của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6. Mô tả dài ở
> `work/backlog_SD.md` → **P1-05**; trạng thái ở `work/backlog.md`.
> **Cần xong trước:** P1-01 — **đã xong 2026-09-04** (`docs/decisions.md` **ADR-035**).
> ⚠️ **`U-031` chạm `I-017`** (đơn giao tận nơi) và **`U-033` chạm `I-004`** (đơn huỷ sau khi bếp
> đã làm xong) — viết hai chỗ ấy theo **phương án hẹp nhất** và ghi thẳng là đang treo.
> Chạy song song được với P1-04 và P1-06: ba nhóm **không dùng chung mệnh đề nào**.

## Context

`quality/invariants.md` đã có mệnh đề và khối *Verification* cho từng mục, nhưng khối ấy viết bằng
**kịch bản nghiệp vụ** — cách **một người** kiểm. Cái còn thiếu là **cột giữa: tầng nào giữ nó**.
Bước này điền cột ấy cho sáu mệnh đề vòng đời, cộng cột thứ ba là **phép đối chiếu**.

**Từ vựng cột giữa là bắt buộc và chỉ có năm giá trị** — định nghĩa đầy đủ ở kế hoạch §7, đọc ở đó:
**1** cơ sở dữ liệu giữ · **2** một giao dịch giữ · **3** miền nghiệp vụ giữ · **4** người + thủ tục
giữ · **5** phép đối chiếu bắt sau khi hỏng.

Nhóm này là chỗ **bàn kẹt** và **đơn kẹt**, và nó có hai ca mà một bảng viết ẩu sẽ bỏ sót:

- **`I-001` không đối xứng.** Một bàn nằm trong nhiều nhất **một** phiên chưa thanh toán, nhưng
  **một phiên gắn được nhiều bàn** khi khách ghép bàn (`docs/decisions.md` **ADR-027**, chủ quán
  chốt 2026-08-31, `master_plan/shop-facts.md` §6.16). Một cơ chế chỉ đọc theo chiều *bàn → phiên*
  sẽ chặn nhầm đúng ca ghép bàn. `docs/product/1-system-design/architecture.md` §3.1 còn nói thêm
  một vế dễ mất: ràng buộc phải phủ **cả trạng thái chờ thanh toán** — nếu chỉ tính phiên đang mở,
  lúc quầy bấm thu tiền ràng buộc nhả ra và lượt gọi thêm rơi vào **hoá đơn thứ hai**.
- **`I-004` là chỗ hai trục gặp nhau.** `docs/decisions.md` **ADR-009**: nhu cầu sản xuất là một
  trục riêng; hai trục gặp nhau đúng **một** chỗ — đơn **đã duyệt** thì nhập nhu cầu, đơn **huỷ**
  thì rút ra (`docs/product/1-system-design/architecture.md` §2). Cơ chế giữ `I-004` phải giữ đúng
  một chỗ ấy, không phải hai.

Đọc trước khi viết dòng đầu tiên: kế hoạch §7 · sáu mục `I-0xx` ở `quality/invariants.md` ·
`docs/product/0-ba/ban-hang/05-vong-doi.md` §5 (bảng chuyển trạng thái — **đã chốt, không vẽ lại**) ·
`docs/product/1-system-design/architecture.md` §2 · §3.1, và hai câu đang mở `U-031` · `U-033` ở
`docs/product/99-unknowns.md`.

## Goal

Sáu mệnh đề vòng đời — `I-001` `I-003` `I-004` `I-006` `I-016` `I-017` — mỗi mệnh đề có **tầng
giữ** và **phép đối chiếu**, và không ô nào trống — kể cả ca **ghép bàn** và ca **suất đem về**.

## Scope

Được sửa:
- `docs/product/1-system-design/` — file bảng ba cột, tên `03-bao-ve-invariant.md`
  (bản đồ file ở kế hoạch §5). File này do **ba** bước cùng viết: P1-04 · P1-05 · P1-06.
  **Chưa có ⇒ tạo, và tạo cùng dòng nội dung đầu tiên. Đã có ⇒ chỉ thêm mục của nhóm mình.**
- `docs/product/00-index.md` — **một dòng** vào bảng *Pha 1*, **chỉ khi** bước này là bước tạo file
- `work/backlog.md` · `work/backlog_SD.md` — **chỉ** dòng và entry P1-05
- `work/scope.txt` — **thêm** khối của mình (**F-010** · **F-014**)

Không được sửa:
- **Mục của nhóm TIỀN (P1-04) và nhóm MENU·GIÁ·VẾT (P1-06) trong cùng file** — ba bước chạy song
  song được, nên file này là **một file, nhiều chủ**. Chỉ sửa sáu hàng của mình.
- `quality/invariants.md` — **không đổi lời một mệnh đề nào**. Bước này viết *ai giữ nó*, không
  viết lại *nó là gì*. Thấy một mệnh đề sai ⇒ ghi `F-XXX` vào `work/findings.md`, đừng sửa nhân
  tiện (`CLAUDE.md` §3 — *scope trôi giữa chừng*).
- `docs/product/0-ba/ban-hang/05-vong-doi.md` — bảng chuyển trạng thái §5 đã chốt ở pha 0
- `docs/product/1-system-design/architecture.md` — §2 và §3.1 không đổi một dòng
- `master_plan/shop-facts.md` · `master_plan/prompt-fullstack.md`

## Constraints

- **Ghi tầng CAO NHẤT thật sự đang giữ nó, không ghi tầng mình muốn nó ở** (kế hoạch §7, luật 1).
  Đây là rủi ro lớn nhất của cả pha (kế hoạch §10): một bảng trông đã đủ trong khi cột giữa của
  mấy mệnh đề chạm tiền chỉ là tầng 4.
- **Mỗi mệnh đề vẫn phải có phép đối chiếu (cột 3), kể cả khi cột 2 đã là tầng 1** (kế hoạch §7,
  luật 2). Ràng buộc cũng bị người ta gỡ; phép đối chiếu là thứ phát hiện ra điều đó.
- **Phép đối chiếu viết dạng *"tập này phải rỗng"*, bằng ngôn ngữ nghiệp vụ** (kế hoạch §7,
  luật 3). *"Mọi bàn đang nằm trong hai phiên chưa thanh toán — tập này phải rỗng"*. Pha 2 dịch nó
  thành câu truy vấn; **pha 1 không viết câu truy vấn**.
- **Ô nào chỉ tới được tầng 4 hoặc 5 phải nói thẳng *"máy không ngăn được"*** — đây là ô thứ hai
  của cổng chất lượng pha 1 (kế hoạch §9), tồn tại riêng để bắt ca bảng nói dối.
- **Đừng vẽ máy trạng thái mới.** Bảng chuyển trạng thái đã chốt ở
  `docs/product/0-ba/ban-hang/05-vong-doi.md` §5; bước này chỉ nói **ai giữ** cho nó đúng.
  ⚠️ **Gate 1c phép C** sẽ đỏ nếu một chuyển tiếp mà §5 ghi là **hợp lệ** bị phủ định ngay cạnh nó.
- **`I-001` phải nói được ca ghép bàn** (một phiên, nhiều bàn — **ADR-027**) **và** ca *chờ thanh
  toán chưa giải phóng bàn* (`master_plan/shop-facts.md` §6.1 — lỗi tiền nguy hiểm nhất của luồng
  tại bàn).
- **`I-016` phải nói rõ tầng nào giữ câu *"chuyển trạng thái ngoài bảng §5 bị TỪ CHỐI"***, và từ
  chối **không bao giờ** được biến thành làm ngầm.
- **Đừng để `I-017` mâu thuẫn `ADR-017`.** Đơn đã `Hoàn thành` **vẫn huỷ được** (chủ quán chốt
  2026-09-02); ràng buộc *"phiên không đóng khi còn đơn chưa xong"* **không** được biến thành
  *"trạng thái cuối là bất biến"*.
- **Ranh giới pha (ADR-035):** cột giữa viết bằng **ngôn ngữ tầng** — *"trạng thái sai này phải
  **không tồn tại được** ở tầng cơ sở dữ liệu"* — **không** viết tên bảng, tên cột, tên ràng buộc,
  endpoint hay route. `master_plan/prompt-fullstack.md` §6.2 tự phá luật này ở đúng một chỗ (nó
  viết một **tên cột** vào cột *bảo vệ bằng*): đó là **đề xuất của pha 2**, đọc nó **sau** khi đã
  viết xong dòng của mình bằng ngôn ngữ tầng, và **không chép**.
- **Không mở lại nghiệp vụ** (`CLAUDE.md` §3.5). Gặp chỗ nghiệp vụ chưa rõ ⇒ `U-XXX`, một gạch đầu
  dòng trong vùng đang mở.

## Acceptance

1. File bảng ba cột có **một mục riêng cho nhóm VÒNG ĐỜI**, và mục ấy có **đúng sáu** hàng:
   `I-001` `I-003` `I-004` `I-006` `I-016` `I-017`.
2. **Không ô nào trống** trong sáu hàng. Ba ô mỗi hàng: mệnh đề · bảo vệ bằng · phép đối chiếu.
3. **Mọi giá trị ở cột giữa là một trong năm tầng của kế hoạch §7** — không có giá trị thứ sáu,
   không có chữ như *"xử lý cẩn thận"*.
4. Hàng nào có cột giữa là **tầng 4 hoặc 5** đều chứa câu *"máy không ngăn được"* (hoặc câu tương
   đương nói thẳng cùng nội dung), và nói cái máy **có** giữ thay vào.
5. Cột 3 của **cả sáu** hàng viết dạng *"tập này phải rỗng"*, bằng ngôn ngữ nghiệp vụ, không câu
   truy vấn nào.
6. Hàng `I-001` nói được **cả hai chiều**: một bàn ≤ một phiên chưa thanh toán, **và** một phiên
   gắn nhiều bàn khi ghép bàn — cộng vế *chờ thanh toán vẫn giữ ràng buộc*.
7. Hàng `I-004` chỉ ra **đúng một** chỗ hai trục gặp nhau (duyệt ⇒ nhập nhu cầu, huỷ ⇒ rút ra).
8. Hàng `I-006` xếp suất *"đem về"* của khách ngồi bàn vào **phiên bàn**, không vào nhóm đơn mang
   đi (**ADR-029**).
9. Hàng `I-017` **không** chứa câu nào nói trạng thái cuối là bất biến; ca *đơn đã `Hoàn thành` vẫn
   huỷ được* (**ADR-017**) đọc được từ hàng ấy.
10. Phần `I-017` liên quan **đơn giao tận nơi** viết theo **phương án hẹp nhất** và ghi thẳng
    *"đang chờ `U-031`"*; phần `I-004` liên quan **đơn huỷ sau khi bếp đã làm xong** ghi thẳng
    *"đang chờ `U-033`"*.
11. `quality/invariants.md` **không đổi một chữ nào** trong lượt này.
12. Không dòng nào chứa tên bảng · tên cột · tên ràng buộc · endpoint · route · component.
13. `./scripts/gate.sh` xanh, **Gate 1c** gồm.

## Verify

```bash
# (1) sáu hàng có mặt — thay <FILE> bằng tên file bảng ba cột
grep -n 'I-001\|I-003\|I-004\|I-006\|I-016\|I-017' docs/product/1-system-design/<FILE>

# (2) cột giữa chỉ nhận năm tầng. Đọc TAY sáu hàng và đối chiếu với kế hoạch §7;
#     đừng đếm số (F-018 — số đếm động không phải điều kiện nghiệm thu).
grep -n -i 'tầng 1\|tầng 2\|tầng 3\|tầng 4\|tầng 5' docs/product/1-system-design/<FILE>

# (3) hàng tầng 4/5 phải NÓI THẲNG. In cả hai vế rồi đối chiếu bằng mắt:
grep -n -i 'tầng 4\|tầng 5'        docs/product/1-system-design/<FILE>
grep -n    'máy không ngăn được'   docs/product/1-system-design/<FILE>

# (4) hai chỗ đang treo phải nói ra mã của thứ chặn chúng
grep -n 'U-031\|U-033' docs/product/1-system-design/<FILE>

# (5) mệnh đề KHÔNG bị sửa lời ở lượt này
git diff --stat -- quality/invariants.md            # rỗng

# (6) "một bàn một phiên" viết tắt ở đâu cũng phải khớp bản KHÔNG đối xứng của
#     I-001 — đọc từng kết quả, sửa chỗ lệch trong CÙNG lượt (CLAUDE.md §7.2)
grep -rn 'một bàn một phiên' --include='*.md' docs/ quality/ master_plan/

# (7) ranh giới pha ADR-035. In cả lệnh CHƯA lọc cạnh lệnh đã lọc — một bộ lọc
#     rỗng vì viết sai trông y hệt một bộ lọc rỗng vì không có lỗi (F-017).
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -c '^+'                                    # chưa lọc: > 0
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -E '^\+' \
  | grep -nEi 'CREATE TABLE|FOREIGN KEY|UNIQUE\(|CHECK \(|\bGET /|\bPOST /|/api/'  # rỗng

# (8) Gate 1c phép C — một chuyển tiếp §5 ghi là HỢP LỆ mà bị phủ định ngay cạnh
./scripts/check-doc-status.sh

# (9) cổng của repo
./scripts/gate.sh
```

## Unknowns

Hai câu đang mở chạm vào nhóm này. **Không câu nào được tự quyết** (`CLAUDE.md` §3.5); đọc nguyên
văn ở `docs/product/99-unknowns.md` vùng *Đang mở*, đừng đọc bản tóm này thay cho nó.

- **`U-031`** — với một đơn **giao tận nơi**, ai bấm mốc *"đã ra bàn"* của từng việc trạm, và vào
  lúc nào. Chạm `I-017`. Hai đường ra đều xấu và cả hai đều chạm mốc thu tiền: đơn giao tận nơi
  **không bao giờ `Hoàn thành` được**, hoặc quầy **bấm khống** một mốc cho suất đang ở nhà khách.
  ⇒ viết phương án hẹp nhất, ghi thẳng là đang treo.
- **`U-033`** — một đơn bị **huỷ** sau khi bếp đã làm xong phần của nó: chỗ bánh ấy có được tính
  cho một bàn khác đang chờ không, hay bỏ và làm lại. Mở 2026-09-03 bởi chính BA-12. Chạm `I-004`
  ở đúng chỗ hai trục gặp nhau. ⇒ viết phương án hẹp nhất, ghi thẳng là đang treo.

⚠️ **`F-026` — hai mệnh đề không thuộc nhóm nào.** `I-019` và `I-020` sinh ra ở BA-12 ngày
2026-09-03, **sau** khi kế hoạch §6 chia ba nhóm, nên chúng không nằm trong P1-04, P1-05 hay P1-06;
cổng chất lượng §9 vẫn đếm *"mười tám"* trong khi `quality/invariants.md` giữ **hai mươi**. Cả hai
là trục **sản xuất theo mẻ**, gần nhóm vòng đời nhất — nhưng **xếp chúng vào nhóm nào là quyết định
của chủ repo, không phải của phiên này**. Đọc `work/findings.md` **F-026** trước khi bắt đầu; đừng
lặng lẽ kéo chúng vào bảng của mình, và cũng đừng lặng lẽ bỏ chúng.

**Cách hỏi chủ quán, nếu hỏi được:** hỏi về **cái quán**, đừng hỏi về cái bảng trong máy — bài học
`S-4` ở `master_plan/shop-facts.md` §7.2. Có lời giải ⇒ ghi vào `master_plan/shop-facts.md`
**trước**, đóng `U-XXX`, rồi mới viết tiếp hàng của mình.

## Report (AI trả lời sau khi làm)

1. Sáu hàng, mỗi hàng: tầng nào giữ nó và **vì sao là tầng ấy chứ không phải tầng cao hơn**.
2. Hàng nào rơi vào tầng 4 hoặc 5, và câu *"máy không ngăn được"* viết ở đâu.
3. `I-001`: cơ chế viết ra có chặn nhầm ca ghép bàn không, và nó phủ trạng thái *chờ thanh toán*
   bằng cách nào.
4. Hai chỗ đang treo (`U-031` · `U-033`): phương án hẹp đã chọn là gì, và câu nào trong file nói
   ra rằng nó đang treo.
5. `F-026`: đã đọc chưa, và `I-019` · `I-020` được để nguyên ngoài bảng hay có đề xuất gì cho chủ
   repo — **đề xuất**, không phải quyết định.
6. Output thật của mục *Verify*, của `./scripts/check-doc-status.sh` và của `./scripts/gate.sh`.
7. Khối `git commit` dán được (`CLAUDE.md` §6.1) — **không** có `work/scope.txt` trong khối.
