# P1-06 — Bảng ba cột, nhóm MENU · GIÁ · VẾT: `I-008` `I-009` `I-010` `I-011` `I-018` (L2) · bước 6/12

> Bước **6/12** của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6. Mô tả dài ở
> `work/backlog_SD.md` → **P1-06**; trạng thái ở `work/backlog.md`.
> **Cần xong trước:** P1-01 — **đã xong 2026-09-04** (`docs/decisions.md` **ADR-035**).
> **Không chờ câu hỏi nghiệp vụ nào đang mở.** Chạy song song được với P1-04 và P1-05: ba nhóm
> **không dùng chung mệnh đề nào**.

## Context

`quality/invariants.md` đã có mệnh đề và khối *Verification* cho từng mục, nhưng khối ấy viết bằng
**kịch bản nghiệp vụ** — cách **một người** kiểm. Cái còn thiếu là **cột giữa: tầng nào giữ nó**.
Bước này điền cột ấy cho năm mệnh đề menu · giá · vết, cộng cột thứ ba là **phép đối chiếu**.

**Từ vựng cột giữa là bắt buộc và chỉ có năm giá trị** — định nghĩa đầy đủ ở kế hoạch §7, đọc ở đó:
**1** cơ sở dữ liệu giữ · **2** một giao dịch giữ · **3** miền nghiệp vụ giữ · **4** người + thủ tục
giữ · **5** phép đối chiếu bắt sau khi hỏng.

**Nhóm này chứa ca dạy được nhiều nhất của cả pha.** `I-011` — *đổi thành phần suất trong giờ bán
không bao giờ xảy ra **ÂM THẦM*** — từng được viết là *"thành phần suất không đổi trong giờ bán"*,
và câu đó **sai** kể từ khi chủ quán trả lời `U-018` ngày 2026-09-01: máy **chỉ nhắc một câu rồi
vẫn cho lưu**, vì luật *"chờ hết buổi"* là luật cho **người** (`master_plan/shop-facts.md` §6.17).
Bài học đã ghi ở `docs/product/99-unknowns.md`: *một invariant hệ thống không giữ nổi thì không
phải invariant*. Thứ sản phẩm giữ được là chuyện đó không xảy ra **âm thầm**: nhắc trước, để vết
sau. ⇒ `I-011` là **tầng 4**. Ghi nó là tầng 1 cho đẹp bảng là **nói dối cả pha 2**, và pha 2 sẽ
dựng một ràng buộc chặn thật — quán mất khả năng sửa thành phần giữa buổi, đúng thứ chủ quán cố ý
giữ.

Bốn mệnh đề còn lại, mỗi cái một chỗ dễ sai riêng:

| Mệnh đề | Chỗ dễ sai | Đọc ở |
|---|---|---|
| `I-008` | có **hai** cửa và chúng có **thứ tự**: đang tạm dừng ⇒ chặn; **không** tạm dừng ⇒ mới xét giờ bán | `docs/product/1-system-design/architecture.md` §6.2 |
| `I-009` | là **snapshot**, thứ chỉ lộ ra sau vài tuần — và mốc khoá giá là **từng lượt gọi** (`docs/decisions.md` **ADR-023**), nên **một hoá đơn phiên bàn được phép mang hai mức giá**, và đó là kết quả **đúng** | `docs/product/1-system-design/architecture.md` §6.1 |
| `I-010` | là **TỪ CHỐI**, không bao giờ **sửa hộ**: tổ hợp không hợp lệ bị chặn, không được tự bỏ bớt tuỳ chọn cho hợp lệ | `quality/invariants.md` I-010 |
| `I-018` | mệnh đề đã **thay** cả `GĐ-01` lẫn `GĐ-05` ngày 2026-09-02; phạm vi lưu vết là **thao tác chạm tiền và chạm trạng thái** (**ADR-024**) | `docs/decisions.md` ADR-024 |

Đọc trước khi viết dòng đầu tiên: kế hoạch §7 · năm mục `I-0xx` ở `quality/invariants.md` ·
`docs/decisions.md` **ADR-023** · **ADR-024** · `docs/product/1-system-design/architecture.md`
§6.1 · §6.2, và mục **đã có lời giải** của `docs/product/99-unknowns.md` phần `U-018`.

## Goal

Năm mệnh đề — `I-008` `I-009` `I-010` `I-011` `I-018` — có **tầng giữ** và **phép đối chiếu**, và
`I-011` được ghi đúng là **tầng người**, không bị nâng lên tầng máy.

## Scope

Được sửa:
- `docs/product/1-system-design/` — file bảng ba cột, tên `03-bao-ve-invariant.md`
  (bản đồ file ở kế hoạch §5). File này do **ba** bước cùng viết: P1-04 · P1-05 · P1-06.
  **Chưa có ⇒ tạo, và tạo cùng dòng nội dung đầu tiên. Đã có ⇒ chỉ thêm mục của nhóm mình.**
- `docs/product/00-index.md` — **một dòng** vào bảng *Pha 1*, **chỉ khi** bước này là bước tạo file
- `work/backlog.md` · `work/backlog_SD.md` — **chỉ** dòng và entry P1-06
- `work/scope.txt` — **thêm** khối của mình (**F-010** · **F-014**)

Không được sửa:
- **Mục của nhóm TIỀN (P1-04) và nhóm VÒNG ĐỜI (P1-05) trong cùng file** — ba bước chạy song song
  được, nên file này là **một file, nhiều chủ**. Chỉ sửa năm hàng của mình.
- `quality/invariants.md` — **không đổi lời một mệnh đề nào**, `I-011` gồm. Bước này viết *ai giữ
  nó*, không viết lại *nó là gì*.
- `docs/product/1-system-design/architecture.md` §6.1 · §6.2 — không đổi một dòng
- `master_plan/shop-facts.md` · `master_plan/prompt-fullstack.md` · `docs/product/0-ba/**`

## Constraints

- **Không siết `I-011` thành *"máy chặn"*.** Chủ quán đã chốt ngược lại (`U-018`, 2026-09-01), và
  siết nó là **tự đặt luật nghiệp vụ** (`CLAUDE.md` §3.5). Muốn máy chặn ⇒ đó là **câu hỏi cho
  chủ quán**, ghi `U-XXX`, không phải một dòng trong bảng.
- **Ghi tầng CAO NHẤT thật sự đang giữ nó, không ghi tầng mình muốn nó ở** (kế hoạch §7, luật 1).
  `I-011` là **ca mẫu** của luật này, và nó là lý do rủi ro §10 của kế hoạch tồn tại.
- **Mỗi mệnh đề vẫn phải có phép đối chiếu (cột 3), kể cả khi cột 2 đã là tầng 1** (luật 2).
- **Phép đối chiếu viết dạng *"tập này phải rỗng"*, bằng ngôn ngữ nghiệp vụ** (luật 3). *"Mọi dòng
  đơn có giá khác giá tại lượt gọi — tập này phải rỗng"*. **Pha 1 không viết câu truy vấn.**
- **Ô nào chỉ tới được tầng 4 hoặc 5 phải nói thẳng *"máy không ngăn được"*** — ô thứ hai của cổng
  chất lượng pha 1 (kế hoạch §9). `I-011` chắc chắn rơi vào đây; nó phải kèm cái máy **có** giữ:
  **lời nhắc** và **cái vết**.
- **`I-008` phải nói được THỨ TỰ hai cửa**, không gộp thành một điều kiện.
- **`I-009` không phải "khoá giá theo phiên".** Mốc khoá là **từng lượt gọi** (**ADR-023**) ⇒ một
  hoá đơn phiên bàn mang hai mức giá là **đúng**, không phải lỗi cần chặn.
- **`I-010` là *từ chối*, không phải *sửa hộ*.** Không dòng nào được mô tả một cơ chế tự bỏ bớt
  tuỳ chọn để tổ hợp thành hợp lệ.
- **Ranh giới pha (ADR-035):** cột giữa viết bằng **ngôn ngữ tầng** — *"giá phải do **một** chỗ
  duy nhất trong hệ thống tính, và mọi đường đặt món đi qua chỗ ấy"* — **không** tên bảng, tên cột,
  tên ràng buộc, endpoint hay route. `master_plan/prompt-fullstack.md` §6.2 viết một **tên cột**
  vào cột *bảo vệ bằng*: đó là **đề xuất của pha 2**; đọc nó **sau** khi đã viết xong dòng của mình
  bằng ngôn ngữ tầng, và **không chép**.
- **Không mở lại nghiệp vụ** (`CLAUDE.md` §3.5).

## Acceptance

1. File bảng ba cột có **một mục riêng cho nhóm MENU · GIÁ · VẾT**, và mục ấy có **đúng năm** hàng:
   `I-008` `I-009` `I-010` `I-011` `I-018`.
2. **Không ô nào trống** trong năm hàng. Ba ô mỗi hàng: mệnh đề · bảo vệ bằng · phép đối chiếu.
3. **Mọi giá trị ở cột giữa là một trong năm tầng của kế hoạch §7** — không có giá trị thứ sáu,
   không có chữ như *"xử lý cẩn thận"*.
4. Hàng `I-011` có cột giữa là **tầng 4**, chứa câu *"máy không ngăn được"*, **và** nói ra hai thứ
   máy **có** giữ: lời **nhắc** trước, cái **vết** sau.
5. Không dòng nào của hàng `I-011` mô tả một cơ chế **chặn** việc lưu.
6. Hàng `I-008` nói được **thứ tự** hai cửa: tạm dừng xét trước, giờ bán xét sau.
7. Hàng `I-009` đọc ra được rằng mốc khoá giá là **từng lượt gọi**, và một hoá đơn phiên bàn mang
   **hai mức giá** là kết quả **đúng** — không phải một chỗ hỏng phải chặn.
8. Hàng `I-010` chứa từ **từ chối**, và **không** chứa mô tả nào về việc sửa hộ tổ hợp.
9. Hàng `I-018` nêu phạm vi lưu vết đúng **ADR-024** (thao tác chạm tiền và chạm trạng thái), không
   rộng hơn và không hẹp hơn.
10. Cột 3 của **cả năm** hàng viết dạng *"tập này phải rỗng"*, bằng ngôn ngữ nghiệp vụ.
11. `quality/invariants.md` **không đổi một chữ nào** trong lượt này.
12. Bản chữ cũ của `I-011` — *"thành phần suất không đổi trong giờ bán"* — không còn sống ở chỗ nào
    như một luật đang hiệu lực; chỗ nào **kể lại** nó là chỗ sai cũ thì **ở lại** (**F-018**).
13. Không dòng nào chứa tên bảng · tên cột · tên ràng buộc · endpoint · route · component.
14. `./scripts/gate.sh` xanh, **Gate 1c** gồm.

## Verify

```bash
# (1) năm hàng có mặt — thay <FILE> bằng tên file bảng ba cột
grep -n 'I-008\|I-009\|I-010\|I-011\|I-018' docs/product/1-system-design/<FILE>

# (2) I-011 là tầng 4 và nói thẳng. Đọc TAY, đừng đếm (F-018).
grep -n -A6 'I-011' docs/product/1-system-design/<FILE>
grep -n 'máy không ngăn được' docs/product/1-system-design/<FILE>

# (3) I-011 KHÔNG mô tả một cơ chế chặn. In cả lệnh chưa lọc cạnh lệnh đã lọc —
#     một bộ lọc rỗng vì viết sai trông y hệt một bộ lọc rỗng vì không có lỗi
#     (work/findings.md F-017).
grep -c '' docs/product/1-system-design/<FILE>                       # chưa lọc: > 0
grep -n -i 'chặn hẳn\|không cho lưu\|từ chối lưu' docs/product/1-system-design/<FILE>  # rỗng

# (4) bản chữ CŨ của I-011 còn sống ở đâu. Đọc từng kết quả: một tài liệu KỂ LẠI
#     một chỗ sai không phải là một chỗ sai (F-018).
grep -rn 'không đổi trong giờ bán' --include='*.md' docs/ quality/ master_plan/

# (5) mệnh đề KHÔNG bị sửa lời ở lượt này
git diff --stat -- quality/invariants.md            # rỗng

# (6) ranh giới pha ADR-035
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -c '^+'                                    # chưa lọc: > 0
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -E '^\+' \
  | grep -nEi 'CREATE TABLE|FOREIGN KEY|UNIQUE\(|CHECK \(|\bGET /|\bPOST /|/api/'  # rỗng

# (7) Gate 1c — U-018 đã ĐÓNG; một câu nói nó còn mở làm gate đỏ, và câu ấy có
#     thể GÓI DÒNG nên grep theo dòng mù với nó (F-015). Chạy gate thật:
./scripts/check-doc-status.sh

# (8) cổng của repo
./scripts/gate.sh
```

## Unknowns

**Không có câu hỏi nghiệp vụ nào chặn bước này.** `U-018` — máy chặn hẳn hay chỉ nhắc khi sửa thành
phần suất giữa giờ bán — **đã đóng 2026-09-01**: *chỉ nhắc một câu, rồi vẫn cho lưu*
(`master_plan/shop-facts.md` §6.17). Viết nó như một câu còn treo sẽ làm **Gate 1c đỏ**.

Chỗ **duy nhất** phải dừng và hỏi: nếu sau khi điền xong, bạn thấy một mệnh đề trong nhóm này
**chỉ giữ được ở tầng 4** trong khi nó chạm tiền — đó là một phát hiện, không phải một chỗ để tự
siết chặt. Ghi `F-XXX` vào `work/findings.md`, hoặc `U-XXX` nếu câu trả lời thuộc về chủ quán.

⚠️ **`F-026` — hai mệnh đề không thuộc nhóm nào.** `I-019` và `I-020` sinh ra ở BA-12 ngày
2026-09-03, **sau** khi kế hoạch §6 chia ba nhóm, nên chúng không nằm trong P1-04, P1-05 hay P1-06;
cổng chất lượng §9 vẫn đếm *"mười tám"* trong khi `quality/invariants.md` giữ **hai mươi**. Đọc
`work/findings.md` **F-026** trước khi bắt đầu. Xếp chúng vào nhóm nào là **quyết định của chủ
repo** — đừng lặng lẽ kéo chúng vào bảng của mình, và cũng đừng lặng lẽ bỏ chúng.

## Report (AI trả lời sau khi làm)

1. Năm hàng, mỗi hàng: tầng nào giữ nó và **vì sao là tầng ấy chứ không phải tầng cao hơn**.
2. `I-011`: câu *"máy không ngăn được"* viết ở đâu, và hai thứ máy **có** giữ được viết thế nào.
3. `I-009`: hàng ấy nói ra bằng cách nào rằng một hoá đơn phiên bàn mang hai mức giá là **đúng**.
4. Kết quả `grep` bản chữ cũ của `I-011`: chỗ nào phải sửa, chỗ nào **cố ý ở lại** vì nó **kể lại**
   một chỗ sai (**F-018**).
5. `F-026`: đã đọc chưa, và có đề xuất gì cho chủ repo — **đề xuất**, không phải quyết định.
6. Output thật của mục *Verify*, của `./scripts/check-doc-status.sh` và của `./scripts/gate.sh`.
7. Khối `git commit` dán được (`CLAUDE.md` §6.1) — **không** có `work/scope.txt` trong khối.
