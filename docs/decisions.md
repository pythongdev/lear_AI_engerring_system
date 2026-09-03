# Architecture Decisions

Record decisions that future engineers or AI sessions need to understand.

<a id="bang-tong-hop"></a>
## Bảng tổng hợp — mọi quyết định và giả định của repo này

Một dòng cho mỗi mục của file. **Đây là bảng tra, không phải nơi giữ sự thật:** lý do, cái bị bác
và phạm vi áp dụng nằm ở chính mục ấy bên dưới. Cột *Rủi ro* chỉ có nghĩa với một `GĐ` — một
quyết định đã chốt thì không mang mức rủi ro, nó mang một cái ngày và một cái tên.

Hai loại mục, và ranh giới giữa chúng là luật cứng (CLAUDE.md §3.5): **ADR** = có lời người thật ·
**GĐ** = chưa ai trả lời, đang tạm chấp nhận. Không phiên nào được đổi loại của một mục mà không
có câu trả lời mới từ người.

| ID | Nội dung một dòng | Trạng thái | Rủi ro | Chặn việc gì |
|---|---|---|:--:|---|
| **Quyết định về CÁCH VẬN HÀNH REPO** ||||
| ADR-001 | `master_plan/shop-facts.md` là nhà duy nhất của mọi dữ kiện quán | Đã chốt | — | — |
| ADR-002 | Trạng thái hệ thống được **đẩy** vào mỗi phiên (brief) | Đã chốt | — | — |
| ADR-003 | Gate 3 chỉ chặn file git đang theo dõi | Đã chốt | — | — |
| ADR-004 | Nội dung commit do phiên viết; Gate 7 chặn khi quên | Đã chốt | — | — |
| ADR-005 | Tài liệu cũng bị máy chấm: mọi pointer phải mở được | Đã chốt | — | — |
| ADR-006 | Scope chấm ở hai chỗ: brief kêu khi quên dọn, Gate 7b đọc khối commit | Đã chốt | — | — |
| ADR-007 | Mục *Unknowns* có hình dạng máy đọc được | Đã chốt | — | — |
| ADR-008 | Lịch sử git đã chia sẻ thì sửa **tiến**, không viết lại | Đã chốt | — | — |
| ADR-009 | Nhu cầu sản xuất là một **trục riêng**, không phải trạng thái của đơn | Đã chốt | — | — |
| ADR-010 | Gate 8 là hook của **git**, cài bằng `core.hooksPath` | Đã chốt | — | — |
| ADR-011 | Ba mặt dùng chung một miền, và **chỉ POS được ghi** tiến độ | Đã chốt | — | — |
| ADR-012 | Nợ là một **phần riêng** có mục ở cả ba tầng | Đã chốt | — | — |
| ADR-013 | Nội dung mảng ADMIN đi vào **mục riêng có nhãn** | Đã chốt | — | — |
| ADR-014 | `docs/product.md` tách thành folder `docs/product/` | **Đang thi hành** — lượt 4/5 xong 2026-09-03 | — | chỉ còn lượt 5, **chưa chốt** |
| **Quyết định NGHIỆP VỤ — BA-10** ||||
| ADR-015 | Năm kênh bán là danh sách **đóng**; định danh khách khác nhau theo kênh | Đã chốt 2026-08-24→30 | — | — |
| ADR-016 | **POS ở quầy là cửa ghi duy nhất**; quyền gắn với chỗ đứng | Đã chốt 2026-08-30→09-02 | — | — |
| ADR-017 | Sửa và huỷ đơn **không** bị chặn bởi trạng thái; POS quyết từng ca | Đã chốt 2026-09-02 | — | — |
| ADR-018 | Món hết sau khi khách chọn: **POS bàn với khách** | Đã chốt 2026-09-02 | — | thay **GĐ-02** |
| ADR-019 | Không trả được thì **cho nợ**; doanh thu tính **ngày ghi nợ** | Đã chốt 2026-08-31 | — | — |
| ADR-020 | Hoàn tiền: quầy quyết + ghi vết; tính **ngày hoàn** | Đã chốt 2026-08-30 · 09-01 | — | — |
| ADR-021 | Giờ hẹn bắt buộc cả `pickup` **và** `phone_preorder`; `delivery` có `Đang giao` | Đã chốt 2026-08-30 · 09-01 | — | — |
| ADR-022 | Doanh thu **hai nguồn**; đối soát **ba nguồn**, ngưỡng **0đ** | Đã chốt 2026-09-01 | — | — |
| ADR-023 | Đổi giá được giữa buổi; mốc khoá giá là **từng dòng**; thành phần suất chờ hết buổi | Đã chốt 2026-09-01 · 09-02 | — | — |
| ADR-024 | MVP **có** lưu vết, phạm vi = thao tác chạm tiền và chạm trạng thái | Đã chốt 2026-08-30 · 09-01 | — | — |
| ADR-025 | Phụ thu suất trứng **×5** — suất trứng nhân thường **25.000** (S-1) | Đã chốt 2026-08-30 | — | — |
| ADR-026 | Vòng đời việc trạm **bỏ `Đang làm`**, giữ `Đã làm xong, còn ở bếp` | Đã chốt 2026-08-31 · 09-01 | — | **BA-12** đọc trước khi dựng bảng quầy (kèm **S-5**) |
| ADR-027 | Ghép bàn = **một phiên, một hoá đơn**, chỉ ghép sang bàn **trống** | Đã chốt 2026-08-31 | — | — |
| ADR-028 | **Năm trạm**; chủ quán đứng quầy vẫn giữ vai chủ quán | Đã chốt 2026-08-30 | — | — |
| ADR-029 | Suất *đem về* của khách ngồi bàn thuộc **phiên bàn** | Đã chốt 2026-08-31 | — | — |
| ADR-030 | Trả trước: **tiền mặt hoặc VietQR**, POS xác nhận lúc **nhận tiền** | Đã chốt 2026-08-31 | — | — |
| ADR-031 | Ba mảng quản trị **được phép**, nhưng đi **sau** bán hàng | Đã chốt 2026-09-02 | — | mốc xếp lịch cho ADM-01…ADM-52 |
| **Giả định — chưa có lời chốt** ||||
| GĐ-01 | Hai người cùng thao tác một bàn: **người bấm sau thắng** | **Giả định** | TRUNG BÌNH | không chặn task nào; chặn *ca khách quét QR trong lúc quầy đang bấm* |
| GĐ-02 | ~~Món hết sau khi khách đã chọn~~ | **Đã thay** 2026-09-02 → ADR-018 | — | — |
| GĐ-03 | ~~Khách nói đã chuyển khoản mà quầy chưa thấy báo có~~ | **Đã thay** 2026-09-02 | — | — |
| GĐ-04 | ~~Đơn đã hoàn thành cần điều chỉnh~~ | **Đã thay** 2026-09-02 → ADR-017 | — | — |
| GĐ-05 | Thao tác nhầm **ngoài** ca *bấm nhầm một mẻ*: không có nút hoàn tác | **Giả định** | TRUNG BÌNH | không chặn task nào; ca đắt nhất là **đóng phiên nhầm** |

**Không có giả định nào ở mức rủi ro CAO tính tới 2026-09-02**, nên không task System Design nào
đang bị một `GĐ` chặn. Hai giả định còn lại đều **TRUNG BÌNH** và cả hai chờ *ai đó gặp ca thật*
chứ không chờ một câu trả lời — vì thế chúng **không** nằm ở `docs/product/99-unknowns.md`.

Hai mục CAO từng có (**GĐ-02**, **GĐ-03**) đã được **thay bằng quy tắc thật** ngày 2026-09-02, chứ
không phải bị hạ mức.

---

## Template

### ADR-001 — Title

**Decision:**  
What was decided.

**Why:**  
Why this decision was made.

**Rejected alternatives:**  
What was considered and rejected.

**Applies to:**  
Which parts of the system this affects.

---

### ADR-001 — `master_plan/shop-facts.md` là nhà duy nhất của mọi dữ kiện quán

**Decision:**
Từ 2026-08-30, `master_plan/shop-facts.md` sở hữu **toàn bộ** dữ kiện quán: phạm vi bán, 5 kênh,
bảng giá thành phần, giá một suất bán, phụ thu, thành phần suất bán, 5 trạm, hai luồng bán, 12 quy
tắc nghiệp vụ, nhật ký chốt. Nó **tự đứng một mình và không chứa liên kết nào** — là điểm cuối,
mọi tài liệu khác trỏ về nó.

`master_plan/00-scope.md` rút thành **file trỏ**, không sở hữu gì, giữ lại chỉ để ~70 liên kết cũ
không gãy; nó mang bảng ánh xạ số mục cũ → mới. Chép bảng giá về đó là bug.

**Why:**
Chủ quán yêu cầu một file giới thiệu quán đọc được độc lập, không phải mở tài liệu khác (2026-08-30).
Đáp ứng yêu cầu đó bằng cách **chép** số vào `shop-facts.md` đã tạo ra hai bản của cùng một con số —
và hai bản lệch nhau **trong vòng một ngày**: giá suất trứng được chốt và ghi vào `shop-facts.md`
trong khi `00-scope.md` vẫn ghi "⚠ chưa chốt" (`work/findings.md` F-001).

Có hai cách thoát: bỏ tính độc lập, hoặc bỏ bản trùng. Tính độc lập là yêu cầu của chủ quán, nên
bỏ bản trùng — tức đảo chiều quyền sở hữu về đúng file đang giữ số.

**Rejected alternatives:**
- *Giữ hai bản, thêm cảnh báo bảo trì.* Đã thử — cảnh báo viết ngày 2026-08-30, lệch xảy ra cùng
  ngày. Trí nhớ con người không phải cơ chế.
- *Giữ hai bản, viết script so khớp.* Giải quyết triệu chứng chứ không phải nguyên nhân, và vẫn
  phải bảo trì hai bảng.
- *Xoá hẳn `00-scope.md`.* ~70 liên kết trong 14 file sẽ gãy im lặng; session cầm prompt BA cũ mở
  phải file không tồn tại mà không có manh mối đi đâu.
- *Để `00-scope.md` giữ số, hạ cấp bằng một dòng ghi chú.* Vẫn là hai bản — đúng cái vừa hỏng.

**Applies to:**
`CLAUDE.md` §2 · `master_plan/shop-facts.md` · `master_plan/00-scope.md` ·
`master_plan/prompt-fullstack.md` §3.1 · toàn bộ `prompt/BA/` (12 file).

---

### ADR-002 — Trạng thái hệ thống được **đẩy** vào mỗi phiên, không phải chờ phiên tự đọc

**Decision:**
Từ 2026-08-30, `scripts/brief.sh` chạy như hook `SessionStart` trong
`.claude/settings.json` và in trạng thái sống của repo — task In Progress, scope đang khai báo,
task Ready kế tiếp, finding Open, unknown Open, ADR mới nhất, commit gần đây, ngày sửa cuối của
từng file owner ở `CLAUDE.md` §2, và phần chưa commit — vào context **trước** chỉ thị đầu tiên
của phiên. `CLAUDE.md` §7 mô tả vòng đầy đủ: đầu phiên (brief tự đến) → trong phiên (ghi ngay,
kèm ngày, tách suy luận, rà pointer) → cuối phiên (bàn giao).

Hai ràng buộc cứng lên `brief.sh`:
1. **Chỉ trỏ, không chép.** Được in tên file, mã số, ngày, tiêu đề. Không được in một con số giá,
   một câu quy tắc, một danh sách kênh. Chép dữ kiện vào brief là tái phạm F-001.
2. **Không bao giờ chặn.** Mọi nhánh lỗi vẫn `exit 0`. Brief hỏng không được làm mất một phiên.

**Why:**
Dự án lớn dần, còn trí nhớ của một phiên thì không sống qua phiên sau. Phiên mới luôn bắt đầu
lạnh và sẽ hành động theo đúng thứ nó được đưa — nên thứ nó được đưa phải là trạng thái **hôm nay**,
không phải trạng thái của ngày tài liệu được viết.

`CLAUDE.md` §3.1 vốn đã bảo "chỉ nạp thứ task cần" — đúng về chi phí, nhưng không nói được **cái gì
vừa đổi**. Một phiên đọc `shop-facts.md` hôm qua và một phiên đọc hôm nay không có cách nào biết
mình đang cầm bản nào. Đó chính là hình dạng của F-001: hai chỗ nói hai điều, lệch trong vòng một
ngày, và cảnh báo viết cùng ngày không cứu được gì.

Bài học F-001 áp dụng nguyên vẹn ở đây: **cảnh báo dựa vào việc người ta nhớ đọc; hook thì không.**
Nên phần đắt nhất của vòng cập nhật — biết trạng thái hiện tại — được làm thành cơ chế. Phần còn
lại (ghi lúc phát hiện) vẫn là kỷ luật, vì không script nào biết bạn vừa học được gì.

**Rejected alternatives:**
- *Chỉ thêm một mục vào `CLAUDE.md` bảo "đầu phiên nhớ đọc trạng thái".* Đúng cái đã hỏng ở F-001 —
  một luật dựa vào trí nhớ. Không có gì chạy nó.
- *Tạo `work/journal.md` — nhật ký phiên viết tay.* Thêm một file phải bảo trì tay, và nó sẽ trở
  thành bản chép thứ hai của backlog + findings. Vi phạm §3.8 và F-001. Git log đã là nhật ký, chỉ
  cần đọc hộ.
- *Để brief in luôn vài dữ kiện hay dùng (giá, kênh) cho tiện.* Đó là bản chép thứ hai — đúng thứ
  ADR-001 vừa xoá. Brief trỏ, owner giữ.
- *Thêm dòng `Cập nhật lần cuối: YYYY-MM-DD` viết tay ở đầu mỗi file owner.* Người sửa file quên
  sửa dòng đó là chuyện thường, và một dòng ngày sai còn tệ hơn không có ngày. Ngày lấy từ
  `git log -1` không phụ thuộc ai nhớ gì.
- *Chạy brief ở hook `UserPromptSubmit`.* Trạng thái sẽ được bơm lại mỗi lượt, phình context mà
  hầu như không đổi. `SessionStart` (kèm resume/clear/compact) là đúng nhịp nó thay đổi.

**Applies to:**
`CLAUDE.md` §1 · §2 (cây thư mục) · §3.1 · §3.7 · §7 (mới) · §8 · `scripts/brief.sh` ·
`.claude/settings.json` · `README.md`.

---

### ADR-003 — Gate 3 chỉ chặn file git đang theo dõi; file chưa track chỉ được ghi chú

**Decision:**
Từ 2026-08-30, `scripts/check-scope.sh` tách hai loại thay đổi ngoài scope:

- file **git đang theo dõi** → `FAIL`, exit 1, gate đỏ như cũ;
- file **chưa track** (`??`) → một dòng `check-scope: note —` liệt kê tên file, exit 0.

Hành vi với file đã track không đổi một chút nào. `CLAUDE.md` §5 và
`quality/review-gate.md` Gate 3 mô tả đúng luật này.

**Why:**
`git status` nói một file **chưa được track**, không nói nó **có từ bao giờ**. Với một file đã
track, git có bản gốc để so, nên "file này vừa bị đổi trong lúc task chạy" là sự thật kiểm được.
Với file chưa track thì không có gì để so — script chỉ đoán, và nó đoán rằng mọi file chưa track
đều do task đang chạy tạo ra.

Ngày 2026-08-30, T-007 chạy prompt `prompt/maintenance/01-...md`. Ba file prompt trong thư mục đó
đã nằm sẵn trong cây **trước khi task bắt đầu** (brief đầu phiên liệt kê chúng ở mục UNCOMMITTED).
Gate đỏ, và cách duy nhất để xanh là nới `work/scope.txt` cho một thư mục mà task **không** sửa
file nào trong đó — tức khai một scope sai để làm hài lòng cái máy kiểm scope.

Đó là hỏng kiểu nguy hiểm nhất của một gate: **đỏ vì lý do sai**. Người dùng học được rằng gate
đỏ đôi khi vô nghĩa, và cách qua nó là nới scope. Sau vài lần, `work/scope.txt` biến thành thủ tục
và Gate 3 không còn bắt được thứ nó sinh ra để bắt — scope drift thật.

**Rejected alternatives:**
- *Giữ nguyên, ai gặp thì tự nới scope.* Đã thử đúng một lần và nó đẻ ra ngay một dòng scope sai
  sự thật. Luật dựa vào việc người ta chịu khó nới đúng chỗ là luật dựa vào trí nhớ (F-001).
- *Bỏ hẳn `--untracked-files=all`, không in gì.* Rẻ hơn, nhưng khi đó file mới do task tạo ra
  ngoài scope biến mất hoàn toàn khỏi output — kể cả một file `.md` nghi lễ mà `CLAUDE.md` §3.8
  cấm. Ghi chú giữ được cái nhìn thấy mà không phải trả giá bằng gate đỏ sai.
- *Commit các file prompt trước khi chạy chúng.* Chữa đúng ca này, không chữa loại lỗi: output
  tạm, file nháp, thư mục build đều rơi vào cùng bẫy, và không phải file nào cũng đáng commit.
- *Ghi mốc thời gian lúc khai scope rồi chỉ tính file mới hơn mốc đó.* Cần thêm trạng thái phải
  bảo trì (một file mốc, ai xoá, khi nào reset) cho một suy đoán vẫn không chắc. Máy móc nhiều hơn
  giá trị nó mang lại.

**Rủi ro đã chấp nhận:**
Một task tạo **file mới** ngoài scope nay không bị chặn, chỉ bị ghi chú. Ca cụ thể đáng lo là file
`.md` nghi lễ mà `CLAUDE.md` §3.8 cấm tạo. Bù lại: dòng `note:` luôn in ra và nói thẳng *"nếu file
này do chính task vừa tạo: đưa vào scope, hoặc xoá đi"*, và Gate 4 (đọc diff) vẫn phải đi qua.
Nếu có lần thứ hai một file mới lọt ra ngoài scope mà không ai thấy, ghi finding và siết lại — đúng
vòng phản hồi ở `quality/review-gate.md`.

**Applies to:**
`scripts/check-scope.sh` · `CLAUDE.md` §5 · `quality/review-gate.md` Gate 3 · `work/backlog.md`
T-010.

---

### ADR-004 — Nội dung commit do phiên viết, và có cơ chế chặn khi quên

**Decision:**
Từ 2026-08-30, `CLAUDE.md` §6.1 bắt mỗi turn kết thúc bằng một khối `git add` + `git commit` dán
chạy được ngay, và `scripts/check-commit-block.sh` thi hành luật đó: gọi từ `gate.sh --hook` sau
khi gate đã xanh, exit 2 (chặn kết thúc lượt) khi cây còn thay đổi git theo dõi mà lượt đó không
đưa ra khối commit nào. Ba giới hạn đi kèm là một phần của quyết định:

- **Chỉ nhắc, không tự commit.** Hook không chạy `git add`, không chạy `git commit`.
- **Chỉ file tracked kích hoạt.** File chưa track không, `work/scope.txt` không.
- **Một lần cho mỗi trạng thái cây.** Dấu vết ở `.git/lean-ai-commit-block`.

**Why:**
T-017 viết luật §6.1 và không có gì thi hành nó — đúng loại hỏng `work/findings.md` F-001 nói tới.
Bằng chứng có sẵn trong git log của chính repo này ngay hôm đó: `202e8c4 ádg`, `2692178 sdgf`,
`25f0f88 sdfg` — ba commit không có nội dung, vì việc soạn nội dung rơi vào lúc phiên đã kết thúc
và người còn lại không còn biết task nào, file nào, bằng chứng nào.

Chủ repo yêu cầu thêm hook ngày 2026-08-30, dù `CLAUDE.md` §3.8 nói chỉ dựng cơ chế sau lần sai
thứ hai. Ở đây lần sai không phải một lần: nó là ba commit liên tiếp, và cái mất đi — lý do của
một thay đổi — không lấy lại được sau khi phiên kết thúc.

Ba giới hạn trên đều để tránh **đỏ vì lý do sai** (bài học ADR-003):
- Tự commit sẽ lấy mất quyền quyết định cuối của người dùng (`CLAUDE.md` §6).
- File chưa track không nói được nó có từ bao giờ, đúng lý lẽ ADR-003.
- Không có luật "một lần cho mỗi trạng thái", một cây đang dở sẽ nhắc lại ở **mọi** lượt sau, kể
  cả lượt chỉ trả lời một câu hỏi. Nhắc thừa vài lần là cách nhanh nhất dạy người ta bỏ qua hook.

**Rejected alternatives:**
- *Thêm hook Stop thứ hai trong `.claude/settings.json`.* Thứ tự giữa hai hook không đảm bảo, mà
  thứ tự ở đây có nghĩa: gate đỏ thì đừng đòi commit message cho một thay đổi còn hỏng. Gắn vào
  cuối `gate.sh` là chỗ duy nhất nói được "sau khi xanh".
- *Hook tự tạo commit.* Nhanh hơn cho người dùng, nhưng §6 nói commit là quyết định của người
  dùng, và một commit tự động sinh ra từ máy sẽ có đúng chất lượng của `ádg`.
- *Chặn theo mọi thay đổi kể cả file chưa track.* Mọi file nháp, output tạm, prompt chưa commit
  sẽ đòi một khối commit — lặp lại đúng cái bẫy ADR-003 đã gỡ.
- *Không có dấu vết trạng thái, nhắc mỗi lượt.* Ít máy móc hơn một chút, đổi lại là nhắc lại vô
  ích ở mọi lượt sau khi người dùng chưa commit ngay. Dấu vết đặt trong `.git/` nên không phải
  bảo trì gì: không cần `.gitignore`, không bao giờ bị commit, mất theo bản clone.

**Rủi ro đã chấp nhận:**
Vì chỉ nhắc một lần cho mỗi trạng thái, một phiên cố tình bỏ qua lời nhắc sẽ không bị nhắc lại cho
tới khi cây đổi tiếp. Đổi lại là hook không bao giờ trở thành tiếng ồn. Nếu có lần thứ hai một
thay đổi đi vào git mà không có nội dung commit, ghi finding và siết lại.

**Applies to:**
`scripts/check-commit-block.sh` (mới) · `scripts/check-commit-block.test.sh` (mới) ·
`scripts/gate.sh` · `scripts/verify.sh` · `CLAUDE.md` §2 (cây thư mục) · §5 · §6.1 · §7.3 · §8 ·
`quality/review-gate.md` Gate 7 · `README.md` · `work/backlog.md` T-017, T-018.

---

### ADR-005 — Tài liệu cũng bị máy chấm: mọi pointer phải mở được, và lượt chỉ-đổi-tài-liệu không còn là lượt trống

**Decision:**
Từ 2026-08-30, `scripts/check-links.sh` (Gate 1b) chạy trong `gate.sh` ở **mọi** lượt, kể cả lượt
chỉ đổi tài liệu — chỗ mà `verify.sh` cố ý bỏ qua. Nó đọc mọi file `.md` thuộc nhóm **tài liệu chỉ
đường** và bắt đỏ khi một đường dẫn nêu trong đó không mở được. Bốn ranh giới là một phần của
quyết định:

- **Chấm tài liệu chỉ đường, không chấm sổ ghi chép.** Chấm: `CLAUDE.md` · `README.md` · `docs/` ·
  `quality/` · `master_plan/` · `prompt/BA/` · `.claude/`. Không chấm: `work/` và
  `prompt/maintenance/` — ở đó một đường đã chết được **trích dẫn làm bằng chứng** (F-007 kể đích
  danh bảy đường không tồn tại), nên chấm chúng là đánh thuế lên đúng việc ta muốn người ta làm.
- **Chỉ file git đang theo dõi mới làm đỏ.** File `.md` chưa track chỉ được in một dòng `note:` —
  cùng lý lẽ ADR-003.
- **Nội dung trong khối ``` không phải pointer.** Ở đó là ví dụ (`order/pricing.go`, `docs/x.md`).
- **Ngoại lệ có hạn.** `scripts/check-links.ignore` giữ những đường cố ý không tồn tại, mỗi dòng
  kèm chủ (số task, số ADR, hoặc "ví dụ"). Dòng nào **không còn khớp lỗi nào** thì gate đỏ: ignore
  hết hạn phải bị gỡ, để danh sách này không trở thành chỗ chôn nợ vô hình.

**Why:**
Repo này sản xuất **tài liệu**, không sản xuất code — và cho tới hôm nay, cổng máy chấm duy nhất
(`verify.sh`) in đúng một dòng cho mọi thay đổi tài liệu: *"verify: skipped — only documentation
changed."* Nghĩa là loại thay đổi chiếm gần như toàn bộ lịch sử repo không có gì chấm ngoài mắt
người. Bảy trong chín finding đang có (`work/findings.md` F-001, F-005, F-006, F-007, F-009…) đều
là lỗi **tài liệu**.

Ngưỡng §3.8 (hai lần) đã vượt cho đúng họ lỗi này: F-005 và F-006 rà **dữ kiện** đã đổi; F-007 là
lần thứ ba, và là loại khác — **pointer chết**. `master_plan/prompt-fullstack.md` khẳng định "nhà
thật của schema là `design/data_base/01`" trong khi `design/` chưa bao giờ tồn tại. Nặng hơn link
hỏng thường, vì file đó được dán vào prompt của agent **ngoài** repo: người đọc không có repo để
`ls`, nên hoặc dừng vì thiếu đầu vào, hoặc tự bịa nội dung bảy file rồi coi là đã có nguồn.

Bằng chứng script này chạy đúng: lần chạy đầu tiên, chưa có dòng ignore nào, nó dựng lại **đúng
bảy đường** F-007 tìm ra bằng tay — cộng hai đường cố ý không tồn tại, không hơn.

**Rejected alternatives:**
- *Chấm cả `work/`.* Cần khoảng mười dòng ignore vĩnh viễn ngay hôm nay, và mỗi finding viết ra sau
  này lại xin thêm một dòng. Cổng nào phạt người ghi lại lỗi thì sẽ được đổi lấy việc không ghi nữa.
- *Sửa bảy đường của `prompt-fullstack.md` cho gate xanh tự nhiên.* F-007 nói rõ: sửa được thì phải
  biết trước file đó **còn thuộc dự án nào và xuất cho ai** — ba khả năng (repo khác · tài liệu sẽ
  sinh ở pha sau · tàn dư) dẫn tới ba cách sửa khác nhau. Chọn bừa một cách là đoán hộ chủ repo,
  đúng thứ `CLAUDE.md` §3.5 cấm. Nợ đó nằm ở `check-links.ignore` mang tên T-019, và ngày T-019
  xong thì bảy dòng ignore hết hạn sẽ tự bắt đỏ cho tới khi bị gỡ.
- *Chạy như một `scripts/*.test.sh` bên trong `verify.sh`.* Rẻ hơn một dòng trong `gate.sh`, nhưng
  `verify.sh` bị bỏ qua đúng ở lượt chỉ đổi tài liệu — tức cổng sẽ ngủ đúng lúc cần nó nhất.
- *Kiểm cả URL ngoài (http).* Cần mạng, chậm, và đỏ vì một trang ngoài chết là đỏ vì lý do không ai
  sửa được trong repo (ADR-003).

**Rủi ro đã chấp nhận:**
Cổng chỉ biết đường dẫn **có mở được không**, không biết nó có trỏ đúng chỗ không: một link đổi từ
file đúng sang file sai mà cả hai đều tồn tại thì cổng vẫn xanh. Đó vẫn là việc của Gate 4 (đọc
diff) và §7.2 (đổi một dữ kiện thì `grep -rn` những gì trỏ vào nó).

**Applies to:**
`scripts/check-links.sh` (mới) · `scripts/check-links.ignore` (mới) · `scripts/check-links.test.sh`
(mới) · `scripts/gate.sh` · `CLAUDE.md` §2 (cây thư mục) · §5 · `quality/review-gate.md` Gate 1b ·
`README.md` · `work/findings.md` F-005, F-006, F-007 · `work/backlog.md` T-019.

---

### ADR-006 — Scope được chấm ở hai chỗ mới: brief kêu khi quên dọn, Gate 7 đọc nội dung khối commit

**Decision:**
Từ **2026-08-31** (T-016), hai cơ chế được dựng, cộng một chế độ phụ để chúng không sinh ra bản
sao thứ hai của ngữ nghĩa pattern:

- **`scripts/brief.sh` — cảnh báo "scope chưa dọn".** Khi `work/scope.txt` còn pattern **mà**
  `work/backlog.md` không có task nào ở *In Progress*, brief in một khối cảnh báo nêu đích danh
  `work/scope.txt` và **số pattern còn lại**. Có task *In Progress* thì brief giữ nguyên dòng cũ
  (*"a task is open…"*) — hai trạng thái phân biệt được, nên cảnh báo không thành tiếng ồn.
  Brief vẫn **không bao giờ đổi mã thoát** (CLAUDE.md §7.1).
- **`scripts/check-commit-block.sh` — Gate 7b, "trong khối commit có gì".** Gate 7 vốn chỉ hỏi
  *turn này có giao khối commit không*; nay nó đọc luôn các dòng `git add …` của khối (cộng index
  thật nếu có ai đã `git add` trong phiên) và nêu tên ba thứ: file **ngoài scope**, dạng
  `git add -A` / `git add .` mà §6.1 cấm, và `work/scope.txt` nằm trong khối.
- **`scripts/check-scope.sh --match <path>…`** — chế độ phụ: in ra những path nằm ngoài scope, rồi
  exit 0. Không đọc `git status`, không kết luận gì về trạng thái track. Có nó để Gate 7b hỏi được
  câu "file này có thuộc scope không" mà **không chép lại** cách so khớp pattern. Cách đọc pattern
  của Gate 3 không đổi một dòng.

**Why:**
Cùng một họ lỗi đã trả giá **bốn** lần (`work/findings.md` F-009, F-010) — ngưỡng §3.8 vượt gấp
đôi. Nhưng hai triệu chứng cần hai chỗ chấm khác nhau, vì chúng nổ ở hai thời điểm khác nhau:
scope quên dọn làm hại **phiên sau**, còn khối commit nhặt nhầm làm hại **ngay lúc dán**.

Chọn `brief.sh` cho triệu chứng thứ nhất vì ba lý do, theo thứ tự quan trọng:

1. **Nó là chỗ duy nhất trong ba ứng viên mà đầu ra chắc chắn tới được người đọc.** `brief.sh` là
   hook `SessionStart`, stdout của nó vào thẳng context trước câu lệnh đầu tiên (ADR-002). Đầu ra
   của `check-scope.sh`/`gate.sh` ở nhánh xanh chỉ đi ra stdout của một hook `Stop` exit 0 — nơi
   không quay lại phiên. Một cảnh báo không ai đọc là ceremony, đúng thứ §3.8 cấm.
2. **Đó là chỗ lời nói dối đang được in ra.** Dòng *"→ a task is open"* hôm nay khẳng định sai cho
   mọi phiên mới; sửa nó là xoá lỗi, không phải thêm cổng.
3. **Cả hai đầu vào đã nằm sẵn trong tay nó** — nó vốn đọc `## In Progress` và `work/scope.txt` để
   in hai mục ngay cạnh nhau. Không parse thêm, không file mới.

**Cảnh báo chứ không chặn, và chỗ đi chệch F-009 — nói thẳng ra:**
F-009 yêu cầu phần kiểm mới *"cảnh báo, không chặn"*. Ở `brief.sh` điều đó là miễn phí và được
giữ nguyên. Ở Gate 7b thì **không**: một hook `Stop` exit 0 không có kênh nào về tới phiên, nên
"cảnh báo" ở đó có nghĩa là in vào hư không. Gate 7b vì thế dùng **exit 2 — đúng mã thoát Gate 7
đã dùng sẵn** khi khối commit còn thiếu. Ba ranh giới giữ nó khỏi thành ADR-003 lần hai:

- Nó **không chấm thay đổi**. Gate 1, 1b, 3 đã xanh trước khi nó chạy; thứ bị trả lại là **đoạn
  văn bản bàn giao**, sửa trong một turn, không đụng một file nào.
- Nó nêu **đích danh** file hoặc dạng lệnh sai. Đỏ vì lý do người dùng thấy là đúng thì không dạy
  ai bỏ qua gate — đó mới là điều ADR-003 sợ.
- Nó nhắc **nhiều nhất một lần cho mỗi trạng thái cây** (luật 3 của Gate 7), nên không khoá được
  phiên. Ca A6 trong `check-commit-block.test.sh` giữ tính chất này.

**ADR-003 không bị lật.** Gate 3 vẫn không đỏ vì file chưa track — không một dòng nào của nó đổi.
Gate 7b chấm **danh sách file người ta vừa cố ý chọn**, không chấm cây làm việc: trạng thái track
không tham gia vào kết luận, nên một file chưa track nằm trong scope thì vẫn im (ca A8).

**Rejected alternatives:**
- *Đặt cảnh báo "scope chưa dọn" vào `check-scope.sh` hoặc `gate.sh`.* Bắt sớm hơn một phiên —
  đúng ngay cuối turn làm hỏng — nhưng chỉ nhìn thấy được khi ai đó chạy `./scripts/gate.sh` bằng
  tay. Muốn nó tới được phiên thì phải exit khác 0, tức là chặn, thứ Constraints cấm.
- *Chép lại cách so khớp pattern vào `check-commit-block.sh`.* Rẻ hơn `--match` chừng hai chục
  dòng, và hai bản sẽ trôi khỏi nhau đúng như hai bảng giá của F-001.
- *Chặn ngay ở `git add` bằng git hook.* Không đi theo bản clone, và §3.8 gọi chỗ chạy thứ ba là
  ceremony khi `SessionStart` và `Stop` đã có.
- *Bắt Gate 7b đọc index thay vì khối commit.* Phiên không chạy `git commit`; `git add` xảy ra ở
  terminal của người dùng **sau** khi hook đã chạy xong, nên index gần như luôn rỗng lúc đó. Khối
  commit là hình dạng duy nhất của "tập file vừa được cố ý chọn" mà hook nhìn thấy được. Index vẫn
  được chấm khi nó không rỗng — thêm nó không tốn gì (ca A7).

**Rủi ro đã chấp nhận:**
- Gate 7b đọc `git add` bằng **văn bản trong transcript**, nên một khối viết theo kiểu lạ (biến
  shell, `xargs`, xuống dòng giữa danh sách file) sẽ lọt. Nó bắt được đúng dạng §6.1 mô tả — và
  đó cũng là dạng cả bốn lần hỏng đã dùng.
- Cảnh báo "scope chưa dọn" chỉ đọc được *In Progress* của `work/backlog.md`. Task quên chuyển
  sang *In Progress* sẽ bị kêu oan; giá phải trả là một dòng, và lời kêu nói thẳng lối ra
  (*"mở lại nó ở In Progress, đừng xoá scope"*).

**Applies to:**
`scripts/brief.sh` · `scripts/brief.test.sh` (mới) · `scripts/check-scope.sh` (chế độ `--match`) ·
`scripts/check-commit-block.sh` · `scripts/check-commit-block.test.sh` · `CLAUDE.md` §5 · §7.1 ·
`work/findings.md` F-009, F-010 · `work/backlog.md` T-016 · ADR-002 · ADR-003.

---

### ADR-007 — Mục *Unknowns* có hình dạng máy đọc được, và brief đọc cấu trúc đó thay vì hình dạng dòng

**Decision:**
Từ **2026-08-31** (T-021), `docs/product/99-unknowns.md` có một hợp đồng, và
`scripts/brief.sh` đọc đúng hợp đồng đó:

- **Vùng đang mở** = phần đầu mục (trước tiêu đề `###` đầu tiên) **cộng** mọi khối nằm dưới một
  tiêu đề `### Đang mở`. Mọi thứ dưới một tiêu đề `###` khác không được đọc.
- **Trong vùng đang mở, một gạch đầu dòng là một unknown đang mở.** Định danh `U-XXX` được tìm ở
  **bất cứ đâu** trong gạch đầu dòng ấy, nên in đậm ở đâu cũng được.
- **Văn xuôi trong vùng đang mở không sinh ra unknown**, và các dòng vắt của một gạch đầu dòng
  được **nối lại** thành một mục trước khi cắt ngắn để in.
- Hợp đồng được viết ở chính `docs/product/99-unknowns.md`, dưới tiêu đề `### Cách viết một câu ở đây` — tức
  là nằm trong vùng brief **không** đọc, nên ví dụ trong đó viết `U-` thoải mái.

**Why:**
`work/findings.md` **F-008**: bản cũ `grep -E '^\s*[-*]?\s*U-[0-9]'` chấm **hình dạng dòng**, nên
ngày 2026-08-30 nó hỏng cả hai chiều cùng lúc — giấu U-005 (một dấu `*` chen vào trước định danh)
và in U-004 đã đóng (một dòng văn xuôi tình cờ bắt đầu bằng `U-004`).

Đây là hỏng ở **đúng cơ chế ADR-002 dựa vào**: brief đẩy trạng thái vào mỗi phiên và cố ý `exit 0`
ở mọi đường lỗi, nên khi nó đọc sai thì **không có gì kêu lên** — phiên sau chỉ đơn giản tin bản
sai, và một câu hỏi nghiệp vụ bị giấu là một chỗ CLAUDE.md §3.5 bị vô hiệu.

T-020 đã vá **phía dữ liệu** (viết lại U-005, vắt lại câu văn) và để lại một luật *"viết `U-XXX`
sao cho `grep` bắt được"*. Luật đó dựa vào trí nhớ — đúng loại hỏng F-001 nói tới, và hình dạng
thứ ba sẽ lại trượt. Nới regex cho khớp thêm vài hình dạng cũng chỉ là bản nới của cùng luật đó.
Chỗ chữa tận gốc là **cho tài liệu một hình dạng, rồi chấm hình dạng ấy** — đúng cách mục
OPEN FINDINGS đã làm với `^### F-` + `**Status:**`, và mục đó chưa hỏng lần nào.

**Vì sao không bắt chước findings từng chữ:**
Mỗi finding là một mục `###` có `**Status:**` riêng, hợp lý vì một finding dài vài chục dòng. Một
unknown là **một gạch đầu dòng**; cho mỗi câu một tiêu đề `###` cộng một dòng `**Status:**` sẽ
biến một danh sách năm dòng thành năm mục, và phần *đã có lời giải* — nay là một bảng bảy dòng
gạch ngang — thành bảy mục nữa. Đó là ceremony §3.8 cấm. Lấy **nguyên tắc** của findings (cấu trúc
quyết định, trang trí không tham gia) mà không lấy **hình dạng** của nó.

**Rejected alternatives:**
- *Nới regex cho khớp cả `- **U-005`.* Rẻ nhất, và là thứ Goal của T-021 cấm thẳng: nó chỉ đóng
  hình dạng đã gặp, không đóng hình dạng thứ ba. Nó cũng không chữa được chiều thứ hai —
  một dòng văn xuôi bắt đầu bằng `U-004` vẫn khớp mọi regex đủ rộng để bắt được chiều thứ nhất.
- *Cho mỗi `U-XXX` một tiêu đề `###` + `**Status:**` như findings.* Đúng chữ của prompt T-021,
  nhưng xem đoạn trên — giá là biến một danh sách thành mười hai mục.
- *Tách unknown ra một file riêng, máy đọc được (YAML/JSON).* Bản sao thứ hai của cùng một tập
  dữ kiện, đúng thứ F-001 và ADR-001 cấm; và câu hỏi nghiệp vụ phải nằm cạnh tài liệu nghiệp vụ
  thì người mới đọc mới thấy.
- *Cho brief kêu lên khi mục Unknowns sai hình dạng.* Trái CLAUDE.md §7.1 — brief không bao giờ
  chặn — và §3.8: chưa trả giá hai lần cho **hình dạng sai**, mới trả giá cho **cách đọc sai**.

**Rủi ro đã chấp nhận:**
- **Một tiêu đề `###` mới chen vào giữa mục sẽ giấu các gạch đầu dòng dưới nó.** Đây là mặt trái
  trực tiếp của việc lấy tiêu đề làm ranh giới. Giá đã hạ xuống một mức: hợp đồng viết ngay trong
  `docs/product/99-unknowns.md` nên người sửa nhìn thấy, và `scripts/brief.test.sh` giữ ca U3b.
- **Brief vẫn im khi đọc ra rỗng.** `(none)` có thể nghĩa là "không còn câu nào" hoặc "hình dạng
  hỏng". Giữ nguyên vì §7.1 cấm brief chặn; ca U5 và U7 khoá hành vi `(none)` + `exit 0`.
- **Tiêu đề dài bị cắt ở 96 ký tự.** Brief là con trỏ, không phải bản sao (§7.1) — muốn đọc đủ
  thì mở `docs/product/99-unknowns.md`.

**Applies to:**
`scripts/brief.sh` · `scripts/brief.test.sh` · `docs/product/99-unknowns.md` · `CLAUDE.md` §4 ·
`work/findings.md` F-008 · `work/backlog.md` T-021 · ADR-002.

---

### ADR-008 — Lịch sử git đã chia sẻ thì sửa **tiến**, không viết lại; bản đồ hash sống trong `work/findings.md`

**Decision:**
Từ **2026-08-31**, một commit đã có mặt trên `origin` không được sửa lại — không `rebase`, không
`--amend`, không `filter-branch`, không `push --force` — kể cả khi subject của nó nói sai về chính
nó. Cách sửa là **sửa tiến**:

1. Ghi **bản đồ `hash → nội dung thật`** vào `work/findings.md`, trong finding sở hữu sự cố đó,
   dưới dạng bảng nêu đích danh hash, subject ghi trong log, nội dung thật, và *revert cái này thì
   mất gì*.
2. Commit tiếp theo dọn hậu quả **nêu đích danh hash sai** trong phần thân của nó.
3. Không xoá, không sửa dòng log nào.

Ngoại lệ duy nhất: chủ repo ra lệnh viết lại, rõ ràng, cho đúng commit đó. Phiên không tự quyết.

Với commit **chưa** push, luật này không áp dụng — `--amend` là cách đúng và rẻ hơn nhiều.

**Why:**
Hai sự cố buộc phải trả lời cùng một câu hỏi trong cùng một ngày:

- `0b3a337` (`work/findings.md` **F-009**) mang subject *"T-020: đơn mang đi được trả trước…"*
  nhưng nội dung là 1096 dòng của ba file `docs/` chưa track; T-020 thật là `1b1d5f5`. Hai commit
  trùng subject từng chữ.
- `0704139` (`work/findings.md` **F-011**) mang subject `dsfg` và gộp ba task T-016, T-021, T-009.

Cả hai đã nằm trên `origin/merge_first_time` khi được phát hiện. Viết lại chúng nghĩa là force-push
một nhánh người khác có thể đã fetch: người đó sẽ có hai lịch sử không hoà được, và thứ mất đi
(một `git pull` hỏng ở máy khác) đắt hơn hẳn thứ được (một dòng log đẹp hơn).

Điểm thứ hai, và là điểm quyết định: **thứ hỏng ở đây không phải log, mà là tri thức**. Người đọc
`0b3a337` cần biết nó thật ra chứa gì — đổi subject cũng không nói được điều đó, chỉ có bảng ở
finding mới nói được. Sửa lịch sử là giải pháp đắt hơn mà giải quyết ít hơn.

Chọn `work/findings.md` làm nhà của bản đồ vì ba lý do: nó đã là chủ của *"vấn đề lặp lại, bài học"*
(CLAUDE.md §2); nó không bị Gate 1b chấm link nên chép được cả đường đã chết làm bằng chứng (§5);
và `scripts/brief.sh` in Open findings cho mọi phiên mới (ADR-002), nên bản đồ tự đi tới người cần.

**Rejected alternatives:**
- *`git rebase -i` đổi subject rồi force-push.* Làm log sạch nhất, và là thứ bị loại thẳng: nhánh
  đã ở trên `origin`. Còn một điểm nữa — sau khi rebase, mọi hash dẫn trong `work/findings.md`,
  `work/backlog.md`, `docs/decisions.md` đều chết cùng lúc, nên "sửa lịch sử" kéo theo một lượt rà
  toàn repo. Chi phí thật lớn hơn nhiều so với vẻ ngoài.
- *`git revert 0b3a337` cho một dòng "Revert…" trong log.* Đúng ngữ nghĩa git và không viết lại
  lịch sử, nhưng ở đây nó gỡ luôn hai file mà chủ repo đã quyết **giữ** (F-009). Revert là công cụ
  gỡ **thay đổi**, còn thứ hỏng ở đây là **nhãn**.
- *`git notes` gắn ghi chú vào từng commit sai.* Đúng chỗ nhất về mặt kỹ thuật, và bị loại vì
  `git notes` không đi theo `git clone` hay `git push` mặc định. Một bản đồ mà bản clone sau không
  thấy thì đúng bằng không có — cùng lý lẽ với `git` hook ở F-011.
- *Không ghi gì, coi như log tự nói.* Đây chính là trạng thái đã tạo ra F-009: phiên sau đọc
  RECENT COMMITS thấy hai dòng "T-020" và tin cả hai.

**Rủi ro đã chấp nhận:**
- **Log vẫn hiển thị subject sai, vĩnh viễn.** `brief.sh` in RECENT COMMITS nên phiên nào cũng
  nhìn thấy nó trước khi nhìn thấy bản đồ. Bù lại: bản đồ nằm trong finding, và finding cũng được
  brief in ra; F-009 và F-011 đều nêu đích danh hash ngay dòng tiêu đề.
- **Bản đồ dựa vào việc người ta viết nó.** Không có cổng nào ép. Đây là giới hạn thật, và nó là
  lý do `work/findings.md` **F-011** mở **T-025** cho một `commit-msg` hook chặn ngay từ đầu vào —
  rẻ hơn nhiều so với việc dọn sau.

**Applies to:**
`work/findings.md` F-009, F-011 · `work/backlog.md` T-023, T-025 · `CLAUDE.md` §6, §6.1 ·
ADR-002 (brief in RECENT COMMITS) · ADR-004 (nội dung commit do phiên viết).

---

### ADR-009 — Nhu cầu sản xuất là một **trục riêng**, không phải một trạng thái của đơn

**Decision:**
Từ **2026-08-31**, sản phẩm mô tả *thứ bếp phải làm* bằng một trục riêng, đặt cạnh trục đơn hàng
chứ không nằm trong nó. Trục ấy có bốn khái niệm, và chúng không thay thế được cho nhau:

| Khái niệm | Đơn vị | Câu nó trả lời |
|---|---|---|
| **Nhu cầu** | một thành phần + nhân + lượng nhân | quán còn phải làm tổng cộng bao nhiêu |
| **Mẻ** | một lần bếp làm | lần này làm mấy cái, bằng thiết bị nào |
| **Đã làm xong** | một thành phần | bếp đã làm ra bao nhiêu |
| **Đã phục vụ** | một thành phần, gắn một bàn | khách đã nhận bao nhiêu |

Nhu cầu **cộng ngang qua nhiều bàn và nhiều đơn**: sáu bàn mỗi bàn một combo là *một* dòng nhu cầu
sáu quả trứng, không phải sáu dòng. Mẻ trả kết quả **về lại đúng bàn đã gọi**. Và *đã làm xong* ≠
*đã phục vụ* — nhưng con số "đã làm xong" hiện là **suy luận chưa xác nhận**, giữ ở
`master_plan/shop-facts.md` §7.2 (S-4), không được ghi như lời chủ quán.

*Cập nhật 2026-09-01 (T-036): **S-4 đã có lời giải và câu trên hết là suy luận.** Chủ quán xác
nhận bánh gấp xong **có nằm chờ**, nên "đã làm xong" là một con số thật, và **người đứng quầy bấm**
nó (`master_plan/shop-facts.md` §5.4, §7.1; §7.2 rỗng trở lại — **tới 2026-09-01, khi T-039 mở
**S-5** ở đúng chỗ ấy**). Từ nay được ghi như lời chủ quán,
kèm ngày. Chỗ **chưa** chốt đã dời sang một câu hẹp hơn — bấm theo từng cái hay cả mẻ,
`docs/product/99-unknowns.md` **U-017** — và chính nó là thứ phải nêu đích danh khi viết §3.4.*
*Cập nhật 2026-09-01 (T-037): **U-017 cũng đã đóng — bấm theo MẺ** (`shop-facts.md` §5.4). §3.4
nay không còn câu nào phải nêu là chưa chốt.*

Chỗ ở của từng phần: dữ kiện quán ở `master_plan/shop-facts.md` §5.4 (ADR-001 không đổi); hành vi
sản phẩm ở `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4, do **BA-12** viết; câu hỏi chưa ai trả lời ở *Unknowns*
U-008–U-011.

ADR này **không** quyết định màn hình, route, bảng dữ liệu hay tên trạng thái kỹ thuật. Đề xuất
`work/proposals/admin.admiadmin/admin1.md` có đủ cả bốn thứ đó; không thứ nào được nhận.

**Why:**
Chủ quán nói ngày **2026-08-31**: hai nồi tráng bánh, mỗi nồi ba quả trứng, nên sáu khách vào cùng
lúc thì làm **sáu quả một mẻ**; làm lần lượt từng suất là *mất thời gian và mất nhiệt*. Kèm theo
đó là danh sách những thứ người đứng quầy phải nhìn thấy cùng lúc — đếm được sáu tính tới
2026-08-31, và sáu là phép đếm của người viết, không phải ranh giới chủ quán chốt
(`master_plan/shop-facts.md` §5.4).

Điểm quyết định nằm ở một chỗ: **con số chủ quán cần không tồn tại trong mô hình lấy đơn làm gốc.**
"Tổng còn phải làm 14 cái bánh" không phải thuộc tính của đơn nào cả — nó là tổng cắt ngang mọi đơn
đang mở. Gắn trạng thái *đang làm / xong* vào từng dòng đơn thì diễn được *"dòng này xong"*, nhưng
con số quán thật sự dùng để chạy bếp thì không có chỗ nào ghi.

Điểm thứ hai: quán **đang** làm theo mẻ, bằng tay, hôm nay. Một thiết kế bắt bếp nhận việc theo
từng suất không phải là thiếu tính năng — nó bắt quán chạy chậm hơn hiện tại. Đây là lý do trục
này được ghi là **dữ kiện quán**, không phải một đề xuất cải tiến.

**Rejected alternatives:**
- *Thêm trạng thái "đang làm / đã xong" vào từng dòng đơn, rồi cộng lại khi cần vẽ màn hình.*
  Rẻ nhất, và hỏng đúng chỗ vừa nói. Cộng lại được, nhưng con số cộng ra **không có chỗ nào ghi
  ai đang làm nó** — mẻ trứng sáu quả không thuộc dòng đơn nào, nên nó không tồn tại trong mô
  hình. Chỉ diễn được kết quả, không diễn được việc.
- *Nhận nguyên khối cấu trúc `admin/live/`, `admin/production/`, cây trạng thái và mô hình dữ
  liệu của đề xuất.* Đó là tầng thiết kế. Repo này chưa chốt xong lát cắt nghiệp vụ (§3.2–§3.3,
  §4–§8 của `docs/product/0-ba/ban-hang/` còn trống). Nhận cấu trúc trước là để tầng dưới quyết thay tầng
  trên — đúng thứ chính đề xuất ấy cảnh báo ở mục 27 của nó.
- *Đợi BA-03…BA-09 xong rồi mới ghi.* Loại vì lời chủ quán không đợi được: nói ngày 2026-08-31,
  không ghi ngay là mất (`CLAUDE.md` §7.2). Trục ghi hôm nay, hành vi viết sau, hai việc khác nhau.
- *Ghi luôn "đã làm xong ≠ đã phục vụ" như lời chủ quán.* Chủ quán **không** nói câu đó; người tư
  vấn suy ra. Trộn nó vào §7.1 là đúng lỗi `work/findings.md` **F-004**, nên nó xuống §7.2 làm
  S-4 kèm câu kiểm chứng.
- *Mở một owner mới cho dữ kiện sản xuất.* Trái ADR-001 và `CLAUDE.md` §3.8: đây là dữ kiện quán,
  nhà của nó đã có.

**Rủi ro đã chấp nhận:**
- **Bốn câu hỏi mở cùng một lúc (U-008–U-011) cộng một chỗ suy ra (S-4).** BA-12 không tick hết
  được cho tới khi chủ quán trả lời. Chấp nhận: bốn câu hỏi có tên rẻ hơn bốn chỗ tự suy
  (`CLAUDE.md` §3.5), và cả năm đều hỏi được trong một lần gặp.
  *Cập nhật 2026-09-01 (T-036): cả năm đã đóng — U-008–U-011 ngày 2026-08-31, S-4 ngày 2026-09-01.
  Rủi ro này đã tiêu, và nó đúng như dự đoán: cả năm được hỏi trong hai lần gặp, không phải năm.
  Đổi lại, lời giải S-4 đẻ ra **U-017** (bấm theo từng cái hay cả mẻ) — BA-12 vẫn không tick hết
  được, chỉ khác là nay treo ở một câu chứ không phải năm.*
  *Cập nhật 2026-09-01 (T-037): **U-017 đóng nốt trong ngày — theo MẺ.** BA-12 hết bị chặn.*
- **Trục này làm nặng thêm mọi lát cắt viết sau nó.** BA-07 (vòng đời) và BA-09 (MVP) đều phải trả
  lời thêm một câu. Chấp nhận vì đây là thứ quán đang làm bằng tay mỗi sáng, không phải tính năng
  thêm vào.
- **Ghi trục trước khi biết ai bấm nút nào.** U-009 chưa có lời giải, nên §3.4 sẽ mô tả được *cái
  gì phải đếm được* mà chưa mô tả được *ai đếm*. Chấp nhận: thứ tự ngược lại đòi tự đặt luật.

**Applies to:**
`master_plan/shop-facts.md` §5.4, §7.1, §7.2 (S-4) · `docs/product/` §3.4 và *Unknowns*
U-008–U-011 · `work/backlog.md` BA-12, T-026 · `prompt/BA/12-production-control-L2.md` ·
`work/proposals/admin.admiadmin/admin1.md` · ADR-001 (nhà của dữ kiện quán, không đổi).

---

### ADR-010 — Gate 8 là hook của **git**, cài bằng `core.hooksPath`, và chỉ chặn cái rỗng nghĩa

**Decision:**
Từ **2026-08-31** (T-025), repo có một cổng thứ tám: `scripts/hooks/commit-msg`, hook của **git**
chứ không phải của Claude Code. Nó từ chối một commit khi subject không nói gì về chính nó, và bốn
giới hạn dưới đây là một phần của quyết định, không phải chi tiết cài đặt:

- **Hook nằm trong repo, bật bằng `core.hooksPath`.** `./scripts/install-hooks.sh` đặt
  `core.hooksPath = scripts/hooks` cho bản clone hiện tại. Không dùng `.git/hooks/`.
- **Luật hẹp, một câu:** bỏ tiền tố `T-XXX: ` nếu có (CLAUDE.md §6 cho phép L0 không mang mã task),
  phần mô tả còn lại phải có **≥ 2 từ và ≥ 8 ký tự**. `Fix typo` qua, `adg` chết.
- **Subject > 72 ký tự chỉ bị NHẮC.** CLAUDE.md §6 nói ≤ 72, nhưng một subject 75 ký tự vẫn nói
  được nó là gì; chặn nó là *đỏ vì lý do sai* (ADR-003).
- **Đường thoát `--no-verify` được in ra ngay trong thông báo từ chối.**

Nội dung commit do git tự sinh — `Merge …`, `Revert …`, `fixup!`, `squash!`, `amend!` — không bị
chấm: chấm chúng là chặn một câu mà người dùng không hề viết ra.

**Why:**
ADR-004 mục *Rủi ro đã chấp nhận* đặt sẵn điều kiện kích hoạt: *"Nếu có lần thứ hai một thay đổi đi
vào git mà không có nội dung commit, ghi finding và siết lại."* Điều kiện đó đã chạm tới **năm**
lần (`202e8c4 ádg`, `2692178 sdgf`, `25f0f88 sdfg`, `0704139 dsfg`, `03ffda3 adg`), hai lần cuối
trong cùng ngày 2026-08-31 và đã push nên không sửa lại được (ADR-008). `work/findings.md` F-011 là
vế *ghi*; ADR này là vế *siết lại*.

Chỗ siết phải là **git**, không phải Claude Code. Gate 7 (`check-commit-block.sh`, ADR-004) đã chạy
đúng phần việc của nó và vẫn không cứu được: nó sống trong vòng đời **một lượt của phiên**, còn
người gõ `git commit -m dsfg` ở terminal không đi qua lượt nào. Bằng chứng mạnh nhất là `03ffda3`:
nó nuốt chính T-023 — task đang đi dọn hậu quả của cơ chế này — trong lúc T-023 đang chạy.

Luật giữ hẹp có lý do. Một hook chấm văn phong sẽ đỏ ở những commit thật sự nói được điều gì đó, và
bài học ADR-003 nói cái giá của *đỏ vì lý do sai*: người ta gỡ cổng chứ không sửa cái sai. Ngưỡng
2 từ / 8 ký tự là mức thấp nhất còn giết được cả năm subject đã có thật, mà `Fix typo` — một L0
hợp lệ đúng CLAUDE.md §6 — vẫn đi qua.

**Rejected alternatives:**
- *Đặt hook thẳng vào `.git/hooks/commit-msg`.* Đơn giản nhất, và sai đúng cái sai T-025 nêu tên:
  `.git/` không đi theo `git clone`, nên nó bảo vệ đúng một máy và biến mất ở mọi bản clone sau.
- *`pre-commit` thay vì `commit-msg`.* `pre-commit` chạy **trước** khi có nội dung commit, nên nó
  không đọc được subject — đúng thứ duy nhất cần chấm ở đây.
- *Hook tự soạn hoặc tự sửa nội dung commit.* ADR-004 đã loại một lần: §6 nói commit là quyết định
  của người dùng, và một subject máy sinh ra sẽ có đúng chất lượng của `ádg`.
- *Bắt buộc mọi commit phải có `T-XXX:`.* Lật CLAUDE.md §6, vốn cho phép L0 không mang mã task. Nó
  sẽ dạy người ta gõ một mã task bịa ra — tệ hơn không có mã.
- *Chặn cả subject > 72 ký tự.* Xem trên: đỏ vì lý do sai.
- *Không cài gì, chỉ viết luật vào CLAUDE.md §6.* Đó chính là trạng thái đã sinh ra năm commit kia,
  và là đúng loại hỏng `work/findings.md` F-001 nói tới: một luật dựa vào việc người ta nhớ.
- *Cho `gate.sh` gọi hook.* `gate.sh` cũng chỉ chạy trong vòng đời một lượt của phiên — lặp lại y
  nguyên lỗ hổng của Gate 7.

**Rủi ro đã chấp nhận:**
- **`core.hooksPath` là config local ⇒ mỗi bản clone vẫn phải chạy `install-hooks.sh` một lần.**
  Git không có cách nào bắt buộc điều đó, và một hook tự bật theo `git clone` sẽ là lỗ hổng bảo mật
  chứ không phải tính năng. Giảm nhẹ: `scripts/brief.sh` chấm `install-hooks.sh --check` và **kêu ở
  mỗi phiên** khi chưa cài (ADR-002 — trạng thái được **đẩy** vào phiên, không chờ ai đọc), và
  CLAUDE.md §6.2 viết ra lệnh cài. Cảnh báo, không chặn: brief không bao giờ đổi mã thoát (§7.1).
- **`core.hooksPath` THAY THẾ `.git/hooks/`, không cộng thêm.** Ai đang có hook riêng ở đó sẽ mất
  nó. `install-hooks.sh` nêu đích danh những hook sẽ ngừng chạy trước khi đổi.
- **`--no-verify` vẫn đi qua được.** Cố ý. Một cổng không có đường thoát sẽ bị gỡ khỏi máy chứ
  không được sửa (ADR-003). Nếu `--no-verify` thành thói quen thì đó là finding tiếp theo, không
  phải lý do bỏ đường thoát.
- **Ngưỡng 2 từ / 8 ký tự không chặn được một subject sai nhưng đủ dài** (`T-025: fix stuff`).
  Cổng này chặn *rỗng nghĩa*, không chấm *đúng sai* — chấm đúng sai là việc của Gate 7b và của
  người đọc diff.

**Applies to:**
`scripts/hooks/commit-msg` · `scripts/install-hooks.sh` · `scripts/commit-msg.test.sh` ·
`scripts/brief.sh` · `CLAUDE.md` §2, §6.2 · `work/findings.md` F-011 · `work/backlog.md` T-025 ·
ADR-002 (brief đẩy trạng thái) · ADR-003 (đừng đỏ vì lý do sai) · ADR-004 (nội dung commit do phiên
viết — ADR này là vế *siết lại* mà nó đặt sẵn điều kiện) · ADR-008 (sửa tiến, không viết lại).

---

### ADR-011 — Ba mặt dùng chung một miền nghiệp vụ, và **chỉ POS được ghi** tiến độ

**Decision:**
Từ **2026-08-31**, mặt quản trị của sản phẩm là **một** miền nghiệp vụ nhìn từ ba chỗ đứng — POS
(quầy) · bếp (năm màn trạm) · chủ quán (quản trị) — chứ không phải ba sản phẩm. Luật nghiệp vụ
sống ở miền, không sống trong màn hình: cùng một quy tắc *"chỉ người đứng quầy được huỷ đơn"* phải
chặn được lời gọi đến từ bất kỳ mặt nào.

Kèm theo, và đây là nửa quan trọng hơn: **POS là nơi duy nhất ghi ra tiến độ sản xuất và phục vụ;
màn hình trạm chỉ đọc.** Ba trạm `trang_banh`, `gap_banh`, `canh` **không có nút báo xong**. Ngoại
lệ duy nhất ở bếp là `don_ban` — bấm *đã dọn*, vì đó là bước cuối của một cái bàn, không phải bước
giữa của một món.

Hệ quả thứ ba, rút ra từ §6.13: **quyền gắn chỗ đứng, không gắn chức vụ**, nên hệ thống cần biết
*ai đang trực trạm nào, lúc này* — một cột `role` cố định trên bảng nhân viên **không** diễn được
luật ấy. Chủ quán đứng quầy thì có quyền của trạm `quay` **cộng thêm** quyền quản trị; chủ quán rời
quầy thì mất vế thứ nhất.

Đặc tả đầy đủ ở `docs/product/1-system-design/architecture.md`. ADR này **không** chốt tên bảng, tên cột hay endpoint.

**Why:**
Chủ quán chốt ngày **2026-08-31** (`master_plan/shop-facts.md` §5.4): *"bỏ qua bước này, POS sẽ tự
cập nhật được bao nhiêu cái cho từng bàn"* — trả lời cho câu *ai bấm "đã làm xong"*. Lý do là ba
đôi tay ở bếp đang bận; thêm một nút là thêm việc cho đúng người không rảnh. Câu trả lời ấy không
phải một tuỳ chọn giao diện: nó quyết định **ai được ghi vào đâu**, tức là một quyết định kiến trúc.

Vì sao một miền chứ không ba: bốn luật đắt nhất của quán — gộp phiên bàn (§6.1), duyệt trước khi
xuống bếp (§6.2), quyền huỷ (§6.13), hoàn tiền có vết (§6.4) — đều **cắt ngang** cả ba mặt. Tách
làm ba sản phẩm là chép bốn luật ấy làm ba bản, và ba bản sẽ lệch nhau (`work/findings.md` F-001,
đúng họ lỗi đã tốn hai lần trong repo này).

Vì sao `role` không đủ: `role` trả lời *người này là ai*; §6.13 hỏi *người này đang đứng đâu, lúc
này* — và câu thứ hai đổi nhiều lần trong một buổi sáng.

**Rejected alternatives:**
- *Giữ nút `Xong` ở màn trạm như `master_plan/prompt-fullstack.md` §3.6, §3.7 **từng** viết.* Đây
  là thiết kế đã có sẵn trong repo lúc ADR này được viết, và bị loại vì chủ quán đã bỏ nó ngày
  2026-08-31. Giữ lại nghĩa là làm ra một nút không ai bấm, rồi mọi con số phía sau nó đứng im.
  Mâu thuẫn ghi ở `work/findings.md` **F-013**; **T-031 đã sửa bản xuất khẩu ngày 2026-08-31**,
  nên §3.6 và §3.7 nay nói đúng luật này chứ không còn nói ngược.
- *Cho bếp bấm, nhưng "không bắt buộc".* Tệ hơn cả hai đường: con số vừa có vừa không, và không ai
  biết một bàn chưa có món là do bếp chưa làm hay do bếp quên bấm.
- *Ba ứng dụng riêng, mỗi mặt một cơ sở dữ liệu, đồng bộ với nhau.* Bốn luật cắt ngang ở trên biến
  thành bốn bài toán đồng bộ — cho một quán một địa điểm, chỉ vài bàn (số bàn ở
  `master_plan/shop-facts.md` §1, đừng chép về đây).
- *Gán quyền huỷ theo `role=quay`.* Rẻ nhất và sai luật: chủ quán có `role=owner` sẽ huỷ được từ
  bất kỳ đâu, đúng thứ §6.13 cấm — *"chức vụ không mở thêm cửa nào"*.
- *Chờ BA-12 xong rồi mới viết `docs/product/1-system-design/architecture.md`.* Loại vì chủ repo yêu cầu mặt admin ngay
  (2026-08-31), và phần lớn đặc tả **derive được** từ dữ kiện đã chốt. Chỗ nào chưa chốt thì tài
  liệu nêu đích danh là đang treo (§11 của nó) thay vì tự quyết.

**Rủi ro đã chấp nhận:**
- **`docs/product/1-system-design/architecture.md` viết trước khi `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4 (BA-12) tồn tại.** Nếu BA-12 mô
  tả trục sản xuất khác đi, tài liệu kiến trúc phải sửa theo — nghiệp vụ vẫn là tầng trên. Đã hạ
  giá bằng cách không chốt lược đồ dữ liệu: §8 của nó chỉ **kể tên chỗ thiếu**, không đặt tên bảng.
- **"Chỉ POS ghi" dồn việc vào một người.** Người đứng quầy vừa duyệt, vừa thu tiền, vừa cập nhật
  đã phục vụ. Đó là lựa chọn của chủ quán, và nó đúng với chỗ đứng: quầy là nơi nhìn thấy cả bàn
  lẫn bếp. Rủi ro thật là lúc đông khách; chưa có dữ liệu thật để nói nó nặng tới đâu.
- **Khái niệm "đang trực trạm nào" chưa có trong 16 bảng.** Ghi ở `docs/product/1-system-design/architecture.md` §8 làm
  chỗ thiếu đã biết, không tự thiết kế quanh nó.
- **Ba câu còn mở (U-006, U-012, S-4) chạm thẳng vào mặt admin.** Tài liệu nêu đích danh và viết
  phần liên quan theo phương án hẹp nhất.
  *Cập nhật 2026-08-31 (T-033): U-006 và U-012 đã đóng, S-4 đã hỏi một lần và hỏng — chủ quán trả
  lời "tôi không hiểu", câu kiểm chứng mới ở `master_plan/shop-facts.md` §7.2. Rủi ro này giảm
  xuống còn một mục, và cách xử vẫn nguyên: phần liên quan viết theo phương án hẹp nhất.*
  *Cập nhật 2026-09-01 (T-036): **S-4 đóng nốt** — bảng quầy có **bốn** con số và **người đứng quầy
  bấm** "đã làm xong" (`master_plan/shop-facts.md` §5.4). Mặt admin/POS vì thế gánh thêm một thao
  tác, đúng chiều rủi ro "dồn việc vào quầy" ghi ở gạch đầu dòng đầu mục này. Chỗ hẹp còn lại là
  **U-017** (bấm theo từng cái hay cả mẻ); `docs/product/1-system-design/architecture.md` §3 phải viết bốn con số kèm câu
  "cách đếm chưa chốt", không được quay lại phương án ba con số.*
  *Cập nhật 2026-09-01 (T-037): **U-017 đóng — theo MẺ.** §3 bỏ được câu "cách đếm chưa chốt": bốn
  con số, con số thứ tư nhảy theo bậc mẻ. Vẫn không được quay lại phương án ba con số.*

**Applies to:**
`docs/product/1-system-design/architecture.md` (toàn bộ) · `master_plan/shop-facts.md` §5.4, §6.13, §6.14, §6.15 ·
`master_plan/prompt-fullstack.md` §3.5, §3.6, §3.7 (T-031 đã sửa §3.6 và §3.7 ngày 2026-08-31;
§3.5 không phải sửa — 16 bảng không chốt trạng thái nào của `order_tasks`) ·
`work/findings.md` F-013 · `work/backlog.md` T-029, T-031, BA-12 · ADR-009 (hai trục) ·
ADR-001 (nhà của dữ kiện quán, không đổi).

---

### ADR-012 — Nợ là một **phần riêng** có mục ở cả ba tầng, không phải hai ô trên phiên bàn

**Ngày:** 2026-08-31 · **Trạng thái:** Accepted · **Người quyết:** chủ repo (yêu cầu thẳng),
trên nền lời chủ quán *"khách không trả tiền cho nợ, POS đóng ghi ai nợ nợ bao nhiêu"*
(`master_plan/shop-facts.md` §6.14).

**Bối cảnh.**
Chủ quán chốt 2026-08-31 là **cho nợ**: khách rời quán chưa trả thì quầy vẫn đóng phiên, và lúc
đóng phải ghi **ai nợ** và **nợ bao nhiêu**. Câu ấy nói đủ về *lúc sinh ra* của khoản nợ, và
không nói gì về phần đời sau của nó. `docs/product/1-system-design/architecture.md` khi viết xong (T-029) rải nợ ở sáu
chỗ — §1.1, §4, §6.4, §7, §8, §11 — nhưng không có mục nào của riêng nó.

**Quyết định.**
Nợ được đối xử như một **phần riêng của hệ thống**, có mục riêng ở **FE**, **BE** và **DB**, đặc
tả ở `docs/product/1-system-design/architecture.md` §12. Không thêm hai ô *"ai nợ / bao nhiêu"* vào phiên bàn rồi coi là
xong.

**Vì sao.**
- **Hai vòng đời khác nhau.** Phiên bàn đóng xong là hết; khoản nợ sinh ra **lúc** phiên đóng rồi
  sống tiếp qua nhiều ngày cho tới khi có người trả. Nhét vòng đời dài vào bản ghi có vòng đời
  ngắn thì khoản nợ chết ngay tại chỗ nó sinh ra.
- **Không có mục riêng thì không thu lại được.** Không ai tra được *"hôm nay còn những ai nợ"*,
  nên tiền đã cho nợ trên thực tế là tiền mất.
- **Đối soát ngưỡng 0đ đòi hai con số.** `shop-facts.md` §6.10 bắt *lệch một đồng cũng phải tìm ra
  lý do*; muốn giải thích chỗ lệch thì phải có **nợ ghi trong ngày** và **nợ thu trong ngày** —
  hai con số chỉ tồn tại nếu nợ là một thứ đứng riêng.
- **Nợ là đường tiền thứ tư** (`docs/product/1-system-design/architecture.md` §7), cùng họ với duyệt · huỷ · hoàn. Ba việc
  kia đều có vết và có người đứng tên; nợ không có lý do gì được kém hơn.

**Phương án đã loại.**
- *Hai cột trên `table_sessions`.* Loại: không tra được danh sách nợ, không có chỗ ghi vết lúc thu,
  và sửa số nợ sẽ đè lên bản ghi của một phiên đã đóng.
- *Coi khoản nợ là một dòng thanh toán âm.* Loại: nó sẽ chảy vào báo cáo doanh thu như tiền đã
  chạm tay, đúng thứ `shop-facts.md` §6.14 cấm — nợ **không** phải tiền đã thu.
- *Chờ chủ quán trả lời nốt U-012 rồi mới làm.* Loại: vế còn treo là **kế toán** (doanh thu tính
  ngày nào), không phải **hình dạng**. Cất cả hai mốc thời gian — lúc ghi nợ và lúc thu nợ — thì
  chốt kiểu nào cũng dựng lại được báo cáo mà không sửa dữ liệu quá khứ.

**Hệ quả.**
- `docs/product/1-system-design/architecture.md` có **§12** mới; mục *Đọc gì tiếp* dời thành §13.
- §12.3 **cố ý vượt ranh giới §8** (*không đặt tên bảng, tên cột*) cho riêng phần nợ, theo yêu cầu
  thẳng của chủ repo. Nó là **đề xuất gửi sang pha 2**, không phải lược đồ đã chốt.
- Một chỗ **suy ra, chưa phải lời chủ quán**: người bấm *thu nợ* là người đang trực `quay`, suy từ
  §4 và §3.3. Chủ quán nói khác thì sửa §12.2 và §12.4 trước tiên.
- **U-012 chưa đóng.** Vế *"ghi ở đâu"* xong; *"ai ghi nhận"* và *"doanh thu ngày nào"* còn mở.

*Cập nhật 2026-08-31 (T-033) — sửa tiến, không viết lại hai dòng trên (ADR-008):* chủ quán đã đóng
nốt **U-012** trong cùng ngày. **Ai ghi nhận: POS** — trùng đúng chỗ suy ra ở dòng trước, nên §12.2
không phải sửa và chỗ ấy hết là suy luận. **Doanh thu tính ngày GHI NỢ**, không phải ngày thu tiền;
hệ quả là đối soát lệch ở **hai** ngày ngược chiều nhau và `docs/product/1-system-design/architecture.md` §6.4 nay mang
công thức đủ bốn dòng. Chi tiết ở `master_plan/shop-facts.md` §6.14.

**Ảnh hưởng tới:** `docs/product/1-system-design/architecture.md` §8, §11, §12, §13 · `docs/product/` §3.1.6 và
*Unknowns* U-012 · `quality/invariants.md` I-005 · `master_plan/shop-facts.md` §6.14 (chỉ đọc).


### ADR-013 — Nội dung mảng ADMIN đi vào **mục riêng có nhãn**, không chen vào mục của mảng bán hàng

**Decision:**
Từ 2026-09-02, mọi nội dung thuộc **mảng admin** — nguyên liệu · con người · tài chính — cập nhật
vào tài liệu nào cũng phải nằm ở **một mục riêng**, và **tên mục mang chữ `admin`**. Mục cũ của
mảng bán hàng chỉ được để lại **một dòng trỏ**, không giữ nội dung admin.

Ba mục ấy, tính tới hôm nay:

| Tài liệu | Mục admin | Mục ấy giữ gì |
|---|---|---|
| `docs/product/0-ba/admin/01-ranh-gioi.md` | **§1.6** | ranh giới nghiệp vụ của ba mảng |
| `docs/product/1-system-design/architecture.md` | **§14** | mặt kiến trúc, và bốn chỗ chạm với mảng bán hàng |
| `master_plan/shop-facts.md` | **§8** | dữ kiện quán của ba mảng |

Ba luật đi kèm:

- **Nhật ký không tách.** `master_plan/shop-facts.md` §7.1 vẫn là nhật ký chốt **đầy đủ** của cả
  hai mảng; dòng chốt admin ở lại đó, chỉ có cột *Ghi ở* trỏ về §8.
- **Đánh số tiếp, không chèn vào giữa.** Mục admin mới lấy số cuối của tài liệu
  (`docs/product/1-system-design/architecture.md` §14 đứng sau §13 vì `prompt/BA/08-mvp-scope-L1.md` đang trỏ §13).
- **`master_plan/shop-facts.md` §8 không được trỏ ra file nào** — ADR-001 giữ nguyên: tài liệu đó
  là điểm cuối, không có liên kết.

**Why:**
Chủ repo yêu cầu thẳng trong phiên 2026-09-02: *"khi cập nhật phần admin vào bất cứ tài liệu nào
hãy làm thêm 1 mục cho admin tách riêng ra, tôi cần biết mục này là thuộc phần nào"*.

Yêu cầu ấy có gốc kỹ thuật, không chỉ là sở thích. Cùng ngày, T-040 ghi lời chốt Đ-1 bằng cách viết
chen một khối dài về nguyên liệu và chấm công vào giữa `docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.4 — mục vốn tả ranh
giới của **mảng bán hàng**. Kết quả là một mục phục vụ hai lý do thay đổi: sửa nó vì lý do bán hàng
thì đụng phần admin, và ngược lại. Đó đúng là hình dạng lỗi `work/findings.md` **F-001** đã ghi cho
trường hợp hai bản của một sự thật — ở đây là hai sự thật trong một chỗ, hỏng theo cùng một cách.

Cái giá của việc không tách tăng theo thời gian: `work/admin-questions.md` §2 đang chờ **52 việc**
ADM. Mỗi việc viết chen vào một mục bán hàng là một chỗ nữa không tách lại được; tách bây giờ tốn
một lượt, tách sau tốn một lượt cho mỗi mục.

**Rejected alternatives:**
- *Gắn nhãn `[ADMIN]` trước từng đoạn, giữ nguyên chỗ.* Nhãn nằm trong lòng mục thì mục lục không
  thấy; người đọc vẫn phải quét cả mục mới biết đoạn nào của mảng nào — đúng cái đang hỏng.
- *Tách hẳn thành một file riêng dưới `docs/` chỉ dành cho mảng admin.* Vi phạm CLAUDE.md §2 (một sự thật một owner): ranh
  giới hệ thống đã có owner là `docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.4, kiến trúc đã có owner là
  `docs/product/1-system-design/architecture.md`. Thêm file thứ ba là tạo owner thứ hai cho cùng loại sự thật, và
  CLAUDE.md §3.8 cấm dựng tài liệu không ai yêu cầu.
- *Chờ tới khi có luật nghiệp vụ thật rồi mới tách.* Lúc ấy đã có nhiều mục phải tách, và mỗi lần
  tách muộn là một lần phải đọc lại xem câu nào thuộc mảng nào — thứ hôm nay còn biết chắc.
- *Đổi số mục để mục admin đứng cạnh mục liên quan.* Làm gãy pointer đang trỏ tới số cũ; ADR-008
  đã chốt hướng "sửa tiến, không viết lại".

**Applies to:**
`docs/product/0-ba/` §1.4 và **§1.6** · `docs/product/1-system-design/architecture.md` §10, §13 và **§14** ·
`master_plan/shop-facts.md` §7.1, §7.3 và **§8** · `work/admin-questions.md` §4 · mọi task
**ADM-01…ADM-52** sẽ mở sau này.

---

### ADR-014 — `docs/product.md` tách thành folder `docs/product/`, cắt theo **pha**, file cũ ở lại làm **lưu trữ không ai trỏ về**

**Trạng thái:** thiết kế đã chốt 2026-09-02, **đang thi hành**. **Lượt 1/5 xong 2026-09-02**
(DOC-1): `docs/product/` đã dựng theo pha, mười mục chuyển nguyên văn, `docs/product.md` thành bản
lưu có banner. **Lượt 2/5 xong 2026-09-02** (DOC-2): `scripts/brief.sh` đọc mục *Unknowns* ở
`docs/product/99-unknowns.md` — tiêu đề mục, chỗ đọc, nhãn *chỗ đọc đủ* và dòng *OWNER FILES* đều
đã sang nhà thật; bản lưu không còn xuất hiện ở chỗ nào trong `scripts/brief.sh`. **Lượt 3/5 xong
2026-09-03** (DOC-3, chia làm ba lượt con chạy theo thứ tự DOC-3b → DOC-3a → DOC-3c): pointer của
nhóm B (`prompt/BA/**`), nhóm A (tài liệu chỉ đường lõi) và vùng *Ready*/*In Progress* của
`work/backlog.md` đều đã sang nhà thật. **Lượt 4/5 xong 2026-09-03** (DOC-4): `CLAUDE.md` §2, §4
và §7.3 trỏ owner mới — bảng §2 ghi `docs/product/`, hai chỗ nói về câu hỏi mở ghi
`docs/product/99-unknowns.md` đúng file mà `scripts/brief.sh` đang đọc, và bản lưu chỉ còn được
nhắc **một câu, không link**, đúng là bản lưu. **Còn lại:** lượt 5 **vẫn chưa được phép chạy**.
Bảng đầy đủ ở *Bảng thi hành sau sửa đổi* cuối mục.

> **Đọc mục này từ dưới lên.** Trục cắt ban đầu là **mảng**; chủ repo đổi sang **pha** cùng
> ngày — khối *SỬA ĐỔI 2026-09-02* ở cuối mục là bản đang có hiệu lực. Phần thân dưới đây giữ
> nguyên câu chữ cũ vì chỗ nó **đoán lệch** là thứ đáng đọc; chỗ nào hai bên nói khác nhau,
> **khối sửa đổi thắng**.

**Decision:**
`docs/product.md` (1940 dòng) tách thành folder `docs/product/`. Trục cắt do chủ repo chọn
(2026-09-02) là **mảng**: bán hàng · admin · db · be · system design · fe.

Trục ấy **một mình chưa đủ**, vì hôm nay 1900 trong 1940 dòng đều là *bán hàng* (đo 2026-09-02:
admin 34 dòng ở §1.6; db · be · system design · fe **0 dòng**). Cắt đúng theo nó cho ra một file
1900 dòng và năm file rỗng — không gỡ được gì. Nên cấu trúc là **hai tầng**: tầng ngoài là mảng
(trục chủ repo chọn), tầng trong của mảng *bán hàng* là các mục §1–§8 đang có.

```text
docs/product/
  00-index.md              mục lục + luật ghi; không sở hữu sự thật nào
  ban-hang/
    01-actors-pham-vi.md   §1 trừ §1.6      (~160 dòng)
    02-kenh-ban.md         §2                (85)
    03-lat-cat.md          §3               (594)  ← vẫn to nhất, cắt tiếp khi §3.4 xong
    04-gia-thanh-toan.md   §4               (333)
    05-vong-doi.md         §5               (269)
    06-ngoai-le.md         §6                (90)
    07-pham-vi-mvp.md      §7               (184)
    08-scenario.md         §8
  admin/
    01-ranh-gioi.md        §1.6              (34) — mục admin của ADR-013 chuyển về đây
  system-design/  be/  db/  fe/
    00-chua-co-gi.md       nhà chờ sẵn, xem luật dưới
  99-unknowns.md           mục Unknowns — scripts/brief.sh đọc ĐÚNG file này
```

**Bốn file kỹ thuật giữ *yêu cầu sản phẩm* cho tầng đó, KHÔNG giữ thiết kế.** `db/`, `be/`,
`fe/`, `system-design/` nói *cái gì bắt buộc phải đúng ở tầng ấy* — ví dụ *"mọi thao tác chạm tiền
phải để lại vết đủ để đối soát truy ngược"*. Tên bảng, tên cột, khoá ngoại, API, route vẫn thuộc
`docs/product/1-system-design/architecture.md` và `master_plan/prompt-fullstack.md` §3.4–§3.7 (CLAUDE.md §2 không đổi một
dòng nào). Không có luật này thì folder mới thành owner thứ hai của kiến trúc — đúng F-001.

**`docs/product.md` ở lại làm LƯU TRỮ, và không gì được trỏ về nó** (chủ repo, 2026-09-02:
*"giữ lại trong trường hợp cần thì có thể xem lại, tuy nhiên không trỏ về, tuyệt đối không trỏ về,
chỉ refer thôi"*). Cụ thể:

- File cũ giữ nguyên nội dung, thêm banner đầu file: **ảnh chụp ngày tách, không sở hữu sự thật
  nào, không sửa ở đây**. Nó được **nhắc tới** như một bản lưu, không được **trỏ tới** như một owner.
- **464 chỗ đang trỏ `docs/product.md`** trong 33 file phải chuyển sang file mới trong cùng đợt thi
  hành. Đây là phần nặng nhất và là lý do việc này là **L3**.
- ⚠️ **Gate 1b không bảo vệ được luật này.** File cũ vẫn tồn tại nên mọi pointer cũ vẫn *mở được*
  ⇒ gate vẫn xanh trong khi cả repo đọc bản lưu. Cái chấm duy nhất là mắt người, cho tới khi việc
  này hỏng lần thứ hai (CLAUDE.md §3.8 mới cho dựng luật mới).

**Why:**
Chủ repo yêu cầu 2026-09-02: *"có lẽ chúng ta cần làm folder product và chia làm các file nhỏ liên
quan đến từng domain, như thế tôi cảm thấy dễ quản lý hơn"*. 1940 dòng trong một file là chỗ mà mỗi
task BA phải cuộn qua bảy mục không liên quan để tới mục của mình, và là chỗ hai phiên chạy song
song **chắc chắn** đụng nhau — F-014 đã xảy ra **năm** lần, lần nào cũng trên đúng file này.

Tách theo mảng còn trả trước một món nợ đang tới: chủ quán vừa mở ba mảng admin vào phạm vi
(ADR-013). 52 việc ADM sẽ đổ vào tài liệu; đổ vào một file 1940 dòng thì nó thành 3000 dòng và
không ai tách lại được nữa.

**Rejected alternatives:**
- *Giữ `docs/product.md` làm **file trỏ** như `master_plan/00-scope.md` (ADR-001).* Rẻ nhất — 464
  liên kết cũ không gãy — nhưng chủ repo bác thẳng: *"tuyệt đối không trỏ về"*. Lý do đứng được:
  file trỏ khiến hai cửa cùng dẫn tới một sự thật tồn tại lâu dài, và cửa cũ thì không bao giờ chết.
- *Cắt đúng một tầng theo mảng, không cắt tiếp mảng bán hàng.* Cho ra một file 1900 dòng — đo rồi,
  không gỡ được gì.
- *Cắt theo domain nghiệp vụ và đánh số mục lại từ đầu.* ~180 câu `docs/product.md §N` trong repo
  thành sai nghĩa mà `grep` không bắt được; giữ số §1–§8 làm tên file thì chúng vẫn đọc đúng.
- *Xoá hẳn file cũ.* Chủ repo muốn xem lại được.
- *Làm ngay trong phiên 2026-09-02.* Một phiên song song đang chạy **T-043** trên đúng
  `docs/product.md` (sửa lần cuối 13 giây trước lúc quyết định này được ghi). Tách file lúc ấy là
  xoá việc của họ.

**Applies to:**
`docs/product.md` → `docs/product/` · `scripts/brief.sh` (4 chỗ đọc thẳng đường dẫn, trong đó có
parser cấu trúc mục *Unknowns* — ADR-007) và `scripts/brief.test.sh` · `CLAUDE.md` §2 và §4 ·
`quality/invariants.md` (27 chỗ) · `work/backlog.md` (99 chỗ) · `docs/product/1-system-design/architecture.md` (14) ·
`docs/decisions.md` (17) · toàn bộ `prompt/BA/` và `prompt/maintenance/`.

**Thi hành — chia thành bốn lượt, không làm trong một lượt:**

| # | Mức | Việc | Xong là thế nào |
|---|:--:|---|---|
| 1 | L2 | Dựng `docs/product/`, chuyển nội dung sang, banner hoá file cũ | nội dung khớp từng dòng với bản cũ; gate xanh |
| 2 | **L2** | `scripts/brief.sh` đọc `99-unknowns.md`; sửa `brief.test.sh` | `./scripts/brief.sh` in đúng danh sách Open unknowns như trước khi tách |
| 3 | **L3** | Chuyển 464 pointer sang file mới, theo từng nhóm file | không file nào ngoài bản lưu còn trỏ `docs/product.md` |
| 4 | L1 | `CLAUDE.md` §2 và §4 trỏ owner mới | bảng §2 nói `docs/product/`, không nói file cũ |

Lượt 2 phải xong **trước** lượt 3: brief là thứ mọi phiên mới đọc đầu tiên, hỏng nó là hỏng mọi
phiên sau (ADR-002).

**SỬA ĐỔI 2026-09-02 — trục ngoài đổi từ MẢNG sang PHA (chủ repo quyết)**

Cùng ngày, sau khi đọc lại ADR này, chủ repo chốt: trục ngoài của folder là **pha**, không phải
mảng. **Mảng không bị bỏ** — nó tụt xuống làm tầng trong, đúng ADR-013.

Ba lý do, xếp theo sức nặng:

1. **Repo đã cắt theo pha từ đầu, chỉ là cắt bằng file chứ chưa bằng folder.** Bốn owner hiện tại
   xếp đúng theo pha, đọc banner đầu mỗi file là thấy: `master_plan/shop-facts.md` (dữ kiện thô,
   trước mọi pha) → `docs/product.md` (*"mỗi mục do một task BA chốt"* — pha 0) →
   `docs/product/1-system-design/architecture.md` (*"đặc tả, không phải mã… không nói tên hàm"* — pha 1) →
   `master_plan/prompt-fullstack.md` (kế hoạch pha 2–5). Danh sách **sáu pha** là luật đã có ở
   `master_plan/prompt-fullstack.md` §7, và nó **đã kèm sẵn luật chống chép** mà trục pha bắt buộc
   phải có: *"pha 0–1 không nhắc tên bảng; pha 2 không nhắc endpoint; pha 3 không nhắc component;
   pha 4 không đổi hợp đồng API"*. Chọn mảng là bắt cả repo học một trục thứ hai trong khi trục
   thứ nhất đang chạy đúng.
2. **Danh sách "mảng" ở bản gốc trên kia trộn hai loại.** *bán hàng · admin* là mảng; *db · be ·
   system design · fe* là **pha**. Một trục trộn hai loại thì câu hỏi *"dòng này viết vào folder
   nào"* không có câu trả lời máy móc, và mỗi phiên sẽ đoán một kiểu.
3. **ADR-013 vừa đặt mảng ở tầng trong đúng một ngày trước.** Admin là *một mục có nhãn trong mỗi
   tài liệu*, không phải một tài liệu riêng. Đưa mảng ra tầng ngoài là viết lại ADR-013 ngay sau
   khi ghi nó.

**Cây thư mục sau sửa đổi** (thay cây ở trên):

```text
docs/product/
  00-index.md                    mục lục + luật ghi; không sở hữu sự thật nào
  0-ba/                          pha 0 — BA
    ban-hang/
      01-actors-pham-vi.md       §1 trừ §1.6
      02-kenh-ban.md             §2
      03-lat-cat.md              §3        ← to nhất, cắt tiếp khi §3.4 xong
      04-gia-thanh-toan.md       §4
      05-vong-doi.md             §5
      06-ngoai-le.md             §6
      07-pham-vi-mvp.md          §7
      08-scenario.md             §8
    admin/
      01-ranh-gioi.md            §1.6 — mục admin của ADR-013 chuyển về đây
  99-unknowns.md                 mục Unknowns — scripts/brief.sh đọc ĐÚNG file này
```

**Không dựng folder rỗng** — điểm này *đổi* so với bản gốc, chỗ nói `00-chua-co-gi.md` làm nhà chờ.
Pha 1–5 chưa có nội dung thì chưa có folder; `00-index.md` liệt kê đủ sáu pha và nói pha nào chưa
mở. Một file tên *"chưa có gì"* là tài liệu nghi lễ, đúng thứ CLAUDE.md §3.8 cấm; và folder rỗng
không gỡ được dòng nào.

**Bốn thứ của bản gốc KHÔNG đổi:** file cũ ở lại làm lưu trữ và không ai được trỏ về · giữ số
§1–§8 làm tên file để ~180 câu `docs/product.md §N` vẫn đọc đúng · lượt 2 phải xong trước lượt 3 ·
Gate 1b vẫn không gác được luật "không trỏ về bản lưu", mắt người là cái chấm duy nhất.

**Bảng thi hành sau sửa đổi** — bốn lượt cũ giữ nguyên việc, đổi tên folder đích; thêm lượt 5:

| # | Mức | Việc | Prompt |
|---|:--:|---|---|
| 1 | L2 | Dựng `docs/product/` theo pha, chuyển nội dung, banner hoá file cũ | `prompt/maintenance/11-product-folder-pha-L2.md` |
| 2 | **L2** | `scripts/brief.sh` đọc file unknowns mới; sửa `scripts/brief.test.sh` | `prompt/maintenance/12-brief-unknowns-file-L2.md` |
| 3 | **L3** | Chuyển pointer sang file mới, theo từng nhóm file | `prompt/maintenance/13-pointer-migration-L3.md` |
| 4 | L1 | `CLAUDE.md` §2 và §4 trỏ owner mới | `prompt/maintenance/14-claude-md-owner-L1.md` |
| 5 | **L3 · ĐÃ CHỐT VÀ ĐÃ XONG 2026-09-03** | `docs/architecture.md` dọn vào `1-system-design/` | `prompt/maintenance/15-architecture-into-system-design-L3.md` |

Lượt 5 **chưa được phép chạy**: chủ repo mới chốt trục, chưa chốt việc `docs/architecture.md` có
dọn vào folder hay không. Prompt viết sẵn để lúc chốt là chạy được ngay; ai chạy nó mà không có
một câu chốt mới của chủ repo là làm sai ADR này.

**Số pointer phải đo lại, đừng tin con số 464 ở trên.** Đo 2026-09-02 sau BA-10: **491 dòng trong
35 file**, và nó còn tăng mỗi ngày chuỗi BA còn chạy. Lượt 3 phải đếm lại ngay trước khi bắt đầu.

**SỬA ĐỔI 2026-09-03 — chủ repo CHỐT ĐỒNG Ý dọn `docs/architecture.md` vào pha 1 (lượt 5 xong)**

Hai đoạn ngay trên nói lượt 5 *"chưa được phép chạy"* và bảng ghi *"CHƯA CHỐT"*. **Hôm nay điều
kiện ấy đã đủ.** Chủ repo được hỏi thẳng 2026-09-03 và trả lời **đồng ý**. Đây là câu chốt mà ba
điều kiện mở khoá của `prompt/maintenance/15-architecture-into-system-design-L3.md` đòi, và nó
được ghi ở đây đúng như điều kiện 1 yêu cầu.

**Decision:**
`docs/architecture.md` → **`docs/product/1-system-design/architecture.md`**, chuyển bằng `git mv`
để lịch sử file đi theo. Giữ nguyên **tên file** và nguyên **số mục §1–§14**.

- **Giữ tên file** vì nó biến cả lượt chuyển thành một phép đổi *tiền tố đường dẫn* thuần tuý —
  `git diff` chứng minh được bằng mắt, và mọi câu `… §N` quanh pointer vẫn đọc đúng.
- **Không thêm tiền tố số** (`01-architecture.md`) như `0-ba/ban-hang/`. Ở đó `01-`…`08-` khớp
  §1–§8 vì mỗi file giữ **một** mục; file này giữ **cả** §1–§14, nên một con số đằng trước sẽ nói dối.
- **Giữ số mục** vì ADR-012 (*Nợ* = §12) và ADR-013 (*admin* = §14) gọi tên mục bằng số; đánh số
  lại là làm sai hai ADR mà `grep` không bắt được.

**Ba điều kiện mở khoá — dẫn chứng bằng dòng thật, đo 2026-09-03:**

| ĐK | Bằng chứng |
|:--:|---|
| 1 — câu chốt của chủ repo | chính khối này; chủ repo trả lời **đồng ý** 2026-09-03 |
| 2 — bước 1–4 xong và đã commit | `bc5033c` (DOC-1) · `83fe8ff` (DOC-2) · `dc53768`/`fd64862`/`1a56b8e` (DOC-3a/b/c) · `ddec2f0` (DOC-4) |
| 3 — pha 1 có sản phẩm thật | file 592 dòng dọn vào **chính là** dòng nội dung đầu tiên của pha 1, đúng luật *"tạo thư mục của pha cùng lúc với dòng nội dung đầu tiên"* (`docs/product/00-index.md`, mục *Luật ghi*). Thư mục sinh ra có ruột, không phải nhà chờ rỗng mà bản sửa đổi trước đã cấm |

**Chuyển trong MỘT commit, không chia năm lượt như bảng thi hành dự tính — chủ repo chọn
2026-09-03.** Lý do là một điểm mà bảng thi hành không lường: lượt 3 dễ chia vì bản lưu **ở lại**
nên pointer cũ vẫn mở được và Gate 1b xanh suốt. Lượt này file **rời khỏi đường cũ**, nên mọi
pointer chưa chuyển đều chết ngay khi `git mv` chạy. Ba phương án và vì sao chọn phương án này:

- *Chia năm task con + `check-links.ignore` tạm.* Đúng chữ *"một task con = một commit"*, nhưng
  **hỏng đúng câu Acceptance quan trọng nhất của prompt — "mỗi task con revert được độc lập"**:
  lùi một task con giữa chừng thì pointer cũ quay lại trong khi dòng ignore đã gỡ ⇒ gate đỏ.
- *Để một file trỏ ở đường cũ* (kiểu `master_plan/00-scope.md`, ADR-001). Chạy được, nhưng dựng
  đúng thứ chủ repo đã bác cho bản lưu: *"tuyệt đối không trỏ về"* — hai cửa cùng dẫn tới một sự
  thật, và cửa cũ không bao giờ chết.
- ✅ **Một commit.** Gate xanh trước và sau, không lúc nào đỏ, không stub, không ignore tạm. Lùi là
  `git revert` đúng một commit. Ràng buộc *"đừng gộp"* viết cho lượt 3 với **464 pointer / 33 file**;
  ở đây là **40 dòng / 20 file** và là đổi tiền tố thuần tuý.

**Số đo 2026-09-03 — 48 dòng nêu `docs/architecture.md`, chia 40 chuyển / 8 ở lại:**

| Nhóm | Dòng | Xử lý |
|---|---:|---|
| `docs/decisions.md` | 22 | **20 chuyển**, 2 ở lại (xem dưới) |
| `prompt/BA/**` (11 file) | 11 | chuyển — đều là dòng khai nguồn đọc |
| `docs/product/0-ba/**` (5 file) | 6 | chuyển |
| `docs/product.md` (bản lưu) | 6 | **ở lại** |
| `CLAUDE.md` §2 · `scripts/brief.sh` · `docs/prompt-guideline.md` | 3 | chuyển |

**Tám dòng ở lại, và vì sao — đây là chỗ `grep` không quyết được, phải đọc thì của câu** (`work/findings.md` F-015, F-018):

1. **6 dòng bản lưu `docs/product.md`.** Banner của chính nó viết *"Không sửa ở đây"*; nó là ảnh
   chụp ngày 2026-09-02. Đổi đường dẫn trong một ảnh chụp là khai rằng ảnh ấy mang một đường
   **chưa tồn tại** vào ngày chụp — đúng lý lẽ đã dùng cho dòng 492 của `quality/invariants.md`.
2. **Hai dòng của chính ADR này** (bảng thi hành ô *lượt 5*, và đoạn *"lượt 5 chưa được phép
   chạy"*). Ở đó đường cũ là **chủ ngữ của câu** — nó nói *"`docs/architecture.md` dọn vào
   `1-system-design/`"*. Đổi nó thì câu thành *"`docs/product/1-system-design/architecture.md` dọn
   vào `1-system-design/`"*, vô nghĩa.

Cả tám dòng nay được `scripts/check-links.ignore` phủ bằng **hai dòng ngoại lệ có ghi lý do**, và
cái giá của chúng ghi ngay tại đó: dòng ngoại lệ phủ **mọi** lần đường cũ xuất hiện trong file ấy,
nên một pointer **mới** viết nhầm về đường cũ trong hai file đó sẽ không bị Gate 1b bắt.

**Chạy `grep` sau lượt này ra 12, không phải 8 — và cả 12 đều cố ý.** Tám dòng ở trên, cộng **bốn
dòng do chính khối sửa đổi này viết ra**: nó buộc phải nhắc tên đường cũ để kể được rằng cái gì đã
dọn đi đâu. Ghi ra để phiên sau đừng đi "sửa nốt cho sạch": một tài liệu kể lại một lượt chuyển
**luôn** làm số đếm lớn hơn số pointer còn sót, và chênh lệch ấy là bằng chứng chứ không phải nợ
(`work/findings.md` F-018 — đếm rộng hơn phạm vi thì con số đo hoạt động viết lách, không đo việc
còn lại). Thấy dòng thứ 13 thì **đọc thì của câu trước khi sửa**.

**`CLAUDE.md` §2 trỏ FILE, `scripts/brief.sh` in THƯ MỤC — cố ý, không phải lệch.** §2 trỏ thẳng
`docs/product/1-system-design/architecture.md` để **Gate 1b còn chấm được**: một đường kết thúc
bằng `/` bị `scripts/check-links.sh` bỏ qua hẳn (`work/findings.md` F-018, mục *Giá phải trả*).
Brief in thư mục vì mục *OWNER FILES* ở đó đo **ngày đổi gần nhất của cả pha**, và pha 1 sẽ có
thêm file. Hai bên cùng chỉ về một owner, chỉ khác độ mịn.

**`master_plan/phase_1_system_design_banh_cuon_ba_thanh.md` Ở LẠI `master_plan/` và KHÔNG sở hữu
gì.** Prompt bắt quyết dứt điểm chuyện này trong chính lượt này, vì để lửng là tạo owner thứ hai
cho pha 1 (`work/findings.md` F-001). Đã đọc và quyết:

- File ấy chứa **I1–I8**, mà owner của *Business invariants* theo `CLAUDE.md` §2 là
  `quality/invariants.md` — nơi đang giữ **I-001…I-018**. I1–I8 là **bản đầu, đã bị thay**:
  I1≈I-001, I2≈I-002, I3≈I-013, I4≈I-004, I7≈I-009, I8≈I-003. Dọn nó vào
  `docs/product/1-system-design/` là đặt một bản sao **cũ hơn** nằm cạnh owner thật — đúng F-001,
  và là kết cục tệ nhất trong mọi lựa chọn.
- Nó cũng chứa **SD-01…SD-07** ở dạng nháp; phần đã chín của cùng nội dung nằm trong
  `docs/product/1-system-design/architecture.md`.
- Nó ở lại đúng chỗ của nó: `CLAUDE.md` §2 nói *"Domain material for the current project lives in
  `master_plan/`"*. Nó là **đầu vào thô của pha 1**, không phải đầu ra.
- Banner nói rõ điều đó được thêm vào đầu file trong cùng đợt này, và
  `docs/product/00-index.md` mục *Pha 1* nhắc lại một câu để không ai đọc nhầm nó thành owner.

**Phương án lùi:** cả lượt là **một commit**, nên lùi là `git revert <mã commit của DOC-5>` — nó
trả `git mv` về chỗ cũ, trả 40 pointer về đường cũ, và gỡ hai dòng `check-links.ignore` cùng lúc,
nên gate xanh ngay sau khi revert mà không phải dọn tay. Đây chính là thứ mà phương án
*"chia năm task con"* không cho.

**Rủi ro còn lại, ghi ra để phiên sau khỏi dò:** Gate 1b **không** chấm đường dẫn kết thúc bằng
`/`, nên dòng `docs/product/1-system-design/` trong `scripts/brief.sh` và mọi câu trỏ thư mục là
vùng mù — bằng chứng duy nhất cho chúng là **chạy thử**, đã chạy trong lượt này.

---

## Quyết định NGHIỆP VỤ — BA-10

ADR-001 tới ADR-014 đều là quyết định **về cách vận hành repo này**. Mục dưới đây là loại thứ hai:
**quyết định về cái quán**. Chúng do **chủ quán** chốt, không do phiên nào suy ra, và mỗi mục ghi
đích danh ngày chốt cùng chỗ giữ dữ kiện gốc (`master_plan/shop-facts.md` — CLAUDE.md §2).

**Luật đọc mục này, và nó là luật cứng:** một mục ở đây là **ADR** khi có lời người thật; là
**GĐ** (mục *Giả định BA* bên dưới) khi chưa ai trả lời. Không phiên nào được nâng một `GĐ` thành
`ADR` mà không có câu trả lời thật, và cũng không được hạ một câu **đã có lời chốt** xuống `GĐ` —
cả hai chiều đều là tự trả lời thay chủ quán (CLAUDE.md §3.5, `work/findings.md` F-004).

Bản đồ chứng minh không câu hỏi nào bị bỏ sót ở [§ Bản đồ](#ban-do) ngay dưới các ADR.

---

### ADR-015 — Năm kênh bán là danh sách ĐÓNG, và định danh khách khác nhau theo kênh

**Decision:**
Quán bán qua **đúng năm** kênh — `delivery` · `pickup` · `qr_table` · `staff_pos` ·
`phone_preorder` — và không có kênh thứ sáu. `phone_preorder` (đặt trước qua hotline) là **kênh
thứ năm riêng**, chốt 2026-08-24 và sửa tên 2026-08-29; nó **không gắn bàn**.

Định danh khách chia theo kênh:

- `qr_table` — khách **ẩn danh theo số bàn**: không khai tên, không khai số điện thoại.
- `delivery`, `pickup`, `phone_preorder` — **bắt buộc số điện thoại**; riêng `delivery` bắt buộc
  thêm **địa chỉ giao**. Hai trường ấy là bắt buộc thật, chủ quán xác nhận 2026-08-30 (**S-2**).

Khách đã đặt qua hotline rồi đổi ý tới ăn tại quán ⇒ **huỷ đơn đặt trước, khách quét QR gọi lại**
(**U-003**, chốt 2026-08-30). Không có đường "chuyển kênh" cho một đơn đang sống.

**Why:**
`master_plan/shop-facts.md` §2 và §6.5; nhật ký chốt §7.1 (2026-08-24, 2026-08-29, 2026-08-30).
Ẩn danh theo bàn đứng được vì **cái bàn đã là định danh đủ** để bưng đồ ra và để thu tiền — quán
không cần biết tên khách ngồi đó. Ba kênh không gắn bàn thì mất cái bàn, nên phải có một thứ khác
gọi được khách, và thứ ấy là số điện thoại.

**Rejected alternatives:**
- *`phone_preorder` chỉ là một đơn `staff_pos` không gắn bàn.* Bác 2026-08-29: nó có **giờ hẹn**
  bắt buộc (§6.5) và một đường tiếp nhận riêng, nên nó là kênh riêng. `work/findings.md` **F-005**
  là cái giá của việc bốn tài liệu còn nói *"bốn kênh"* sau ngày ấy.
- *Bắt khách `qr_table` khai số điện thoại.* Bác — quán không cần, và một ô bắt buộc không ai
  dùng là một ô khách bỏ dở giữa chừng.
- *Cho ca U-003 một đường "chuyển kênh" thay vì huỷ rồi gọi lại.* Bác — nó sinh ra một đơn thuộc
  **hai** kênh, và đối soát cuối ngày (§4.9) không cộng nổi một đơn như thế vào nguồn nào.

**Applies to:**
`docs/product/0-ba/ban-hang/02-kenh-ban.md` §2, §2.1–§2.4 · `quality/invariants.md` I-007, I-008 ·
`master_plan/shop-facts.md` §2, §6.5 · `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.2 dòng 2.

---

### ADR-016 — Máy POS ở quầy là CỬA GHI DUY NHẤT, và quyền gắn với CHỖ ĐỨNG chứ không gắn chức vụ

**Decision:**
Mọi thao tác làm đổi **tiền** hoặc đổi **trạng thái** đi qua đúng **một** cửa: máy POS đặt ở quầy.
Người đứng quầy là người bấm: **duyệt** đơn khách tự gửi (§6.2) · **huỷ** đơn (§6.13, **U-004**) ·
**hoàn tiền** (§6.4, **S-3**) · **ghi nợ** lúc đóng phiên và **thu nợ** về sau (§6.14, **U-012**) ·
**ghép bàn** (§6.16, **U-013**) · bấm *"đã làm xong"* và *"đã bưng ra bàn"* cho bảng bếp (§5.4 —
**U-009**, **U-017**, **U-021**) · bấm cho đơn giao sang `Đang giao` lúc đơn **rời quán**
(**U-023**) · giữ và nhập lại **sổ giấy** sau khi mất điện (§6.11, **U-025**).

**Hai ngoại lệ đã chốt đích danh tên người khác**, và chỉ hai: **người đi giao** bấm *đã giao + đã
thu tiền* tại chỗ khách (§6.7); **chủ quán** bấm đổi giá hoặc đổi thành phần suất trên mặt quản
trị (§6.17).

**Quyền gắn với chỗ đứng, không gắn chức vụ.** Chủ quán không đứng quầy thì **nhờ người đứng quầy
bấm** (**U-004**, chốt 2026-08-30); chủ quán đang đứng quầy thì bấm được, vì lúc ấy họ *là* người
đứng quầy (ADR-028).

**Why:**
Đây là câu trả lời lặp lại **năm lần cho năm câu hỏi khác nhau**, trong bốn ngày khác nhau
(2026-08-30 → 2026-09-02, `docs/product/99-unknowns.md` → *Đã có lời giải*). Một câu trả lời lặp
lại năm lần là một **luật về cách quán vận hành**, không phải năm lời chốt rời rạc. Nó có nền vật
lý: quán chỉ có **một** máy POS, đặt ở quầy (§6.13).

Nó cũng là điều kiện để **I-012** có nghĩa. Một cái vết chỉ truy ngược được về *một người* khi số
cửa ghi là hữu hạn và đã biết tên; hai cửa ghi không ràng buộc nhau thì "ai bấm" thành câu hỏi
không ai trả lời được sau ba ngày.

**Rejected alternatives:**
- *Gắn quyền vào **chức vụ** (chủ quán / nhân viên).* Bác 2026-08-30 (`work/backlog.md` T-006):
  chủ quán ngồi ở nhà thì không còn ai huỷ được đơn, trong khi người đang đứng quầy nhìn thấy
  khách ngay trước mặt.
- *Đặt nút bấm ở ba trạm bếp.* Bác 2026-08-31 (**U-009**): *"bỏ bước ấy đi"*. Bếp đang tráng bánh
  không rảnh tay bấm máy. `work/findings.md` **F-013** là cái giá của việc bản xuất khẩu còn giữ
  nút ấy sau khi chủ quán đã bỏ.
- *Cho mặt quản trị ghi tiến độ.* Bác — ADR-011: ba mặt dùng chung một miền nghiệp vụ, và **chỉ
  POS được ghi**.

**Applies to:**
`docs/product/0-ba/ban-hang/` §1.5, §2.4, §4.6, §4.8, §5.4 · `quality/invariants.md` I-012 · ADR-011 ·
`master_plan/shop-facts.md` §6.2, §6.4, §6.7, §6.13, §6.14, §6.16, §6.17.

---

### ADR-017 — Sửa và huỷ một đơn KHÔNG bị chặn bởi trạng thái; POS quyết từng ca

**Decision:**
Một đơn **sửa được ở bất kỳ trạng thái nào** (**U-022**, chốt 2026-09-02) và **huỷ được kể cả khi
đã `Hoàn thành`** (**U-027**, chốt 2026-09-02). Không có mốc trạng thái nào chặn; **POS quyết theo
tình hình thực tế**, từng ca một.

Ba hệ quả đi kèm, và chúng là phần dễ đọc sai nhất:

- **Sửa KHÔNG phải một chuyển tiếp trạng thái.** Đơn đang ở đâu vẫn ở đó; cái đổi là món, số suất,
  tuỳ chọn. Vì thế sửa không nằm dưới **I-016** và không cần một dòng nào trong bảng §5.2.
- **Huỷ thì LÀ một chuyển tiếp**, nên bảng §5.2 có thêm dòng `Hoàn thành → Huỷ`, và §5.6 mất ca
  thứ hai trong danh sách bị từ chối.
- **Huỷ một đơn đã `Hoàn thành` gần như luôn kéo theo tiền.** Hàng đã tới tay khách và tiền có thể
  đã thu ⇒ lần huỷ ấy đi kèm **hoàn tiền** theo ADR-020, rơi vào **ngày hoàn**. Huỷ không phải
  đường vòng tránh luật hoàn tiền.

Mọi lần sửa và mọi lần huỷ **để lại vết** (ADR-024).

**Why:**
Chủ quán được hỏi **hai lần, hai ngày, hai câu tách nhau** — *sửa tới trạng thái nào* (2026-09-02,
lượt một) rồi *huỷ tới trạng thái nào* (2026-09-02, lượt hai) — và trả lời cùng một câu. Đó là
luật, không phải hai lời chốt rời (`master_plan/shop-facts.md` §6.19).

Phải hỏi **hai lần** vì lượt một chỉ nói chữ *sửa*. Đọc chữ *sửa* thành *huỷ* là đúng thứ
`work/findings.md` **F-004** cấm, nên vế huỷ ở lại thành **U-027** và mất thêm một lượt. Ghi lại ở
đây vì cái giá ấy đáng nhớ hơn lời chốt.

**Rejected alternatives:**
- *"Đơn đã xác nhận thì chỉ được huỷ rồi tạo lại, không được sửa."* Bác 2026-09-02: §6.19 nói
  **sửa chính đơn ấy**. Huỷ-rồi-tạo-lại làm mất lịch sử của đơn và sinh ra hai bản ghi cho một
  việc, nên đối soát cuối ngày đếm đôi.
- *Chặn cứng ở `Hoàn thành` cho cả sửa lẫn huỷ.* Bác — chủ quán cố ý **không** dựng hàng rào ở
  đây, và sản phẩm không được tự dựng hộ.
- *Suy vế huỷ ra từ lời chốt về sửa, ngay trong lượt một.* Bác vì lý do quy trình (F-004), và đó
  là quyết định đúng: lời chốt thật hoá ra **rộng hơn** cái suy ra sẽ viết.

**Applies to:**
`docs/product/0-ba/ban-hang/` §5.2, §5.6, §6 dòng 13 · `quality/invariants.md` I-016 ·
`master_plan/shop-facts.md` §6.19 · thay **GĐ-04**.

---

### ADR-018 — Món hết sau khi khách đã chọn: POS bàn với khách, không có luật tự động

**Decision:**
Khi một món hết sau lúc khách đã chọn, hệ thống **không tự thay thế** bằng món khác và **không tự
huỷ** dòng ấy. **Người đứng quầy nói chuyện với khách**, và quyết định ra **tại lúc thoả thuận
xong** (chủ quán chốt 2026-09-02, `master_plan/shop-facts.md` §6.20).

**Why:**
Đây là câu **3** của bảng mười câu §10 kế hoạch gốc, và nó từng là **GĐ-02** — một giả định đoán
rằng quán có một luật xử lý cứng. Lời chủ quán cho thấy giả định ấy đoán quán **chặt hơn quán
thật**: chủ quán cố ý để chỗ này cho con người, vì món hết là chuyện thương lượng, không phải
chuyện tra bảng.

**Rejected alternatives:**
- *Tự động thay bằng món tương đương.* Bác — máy không biết khách chịu đổi sang cái gì, và một
  suất bị đổi ngầm là một suất khách không gọi.
- *Tự động huỷ dòng ấy rồi báo khách.* Bác — khách có thể muốn đổi chứ không muốn bỏ, và huỷ ngầm
  làm hoá đơn hụt đi so với thứ khách nhớ mình đã gọi.

**Applies to:**
`docs/product/0-ba/ban-hang/06-ngoai-le.md` §6 dòng 5, §6.3 · `master_plan/shop-facts.md` §6.20 · thay **GĐ-02**.

---

### ADR-019 — Khách không trả được thì quán CHO NỢ, phiên vẫn đóng, và doanh thu tính NGÀY GHI NỢ

**Decision:**
Khách rời quán mà chưa trả tiền thì **quán cho nợ** (**U-007**, chốt 2026-08-31). Quầy **vẫn đóng
phiên**, và lúc đóng POS **bắt buộc ghi ai nợ và nợ bao nhiêu**. Doanh thu tính vào **ngày ghi
nợ**, không phải ngày thu được tiền (**U-012**, chốt 2026-08-31); **thu nợ cũ** về sau làm két
thừa nhưng **không** làm tăng doanh thu ngày thu.

**Why:**
`master_plan/shop-facts.md` §6.14. Cho nợ là chuyện có thật ở quán quen, nên chặn nó bằng phần mềm
là chặn một việc quán vẫn làm. Tính doanh thu vào **ngày ghi nợ** giữ được luật lớn hơn: **doanh
thu một ngày đã đối soát không bao giờ đổi về sau** (ADR-022).

⚠️ **Luật này NGƯỢC CHIỀU với hoàn tiền** (ADR-020: tính vào **ngày hoàn**, không phải ngày bán
gốc). Hai luật ngược chiều nhau nhưng cùng phục vụ một mục đích — không bao giờ phải sửa lại con
số của một ngày đã chốt sổ. Gộp chúng thành một câu là làm sai một trong hai.

**Rejected alternatives:**
- *Giữ phiên mở tới lúc khách trả.* Bác — cái bàn kẹt lại và không ai ngồi được (**I-003**), trong
  khi khách đã về từ lâu.
- *Tính doanh thu vào ngày thu được tiền.* Bác — doanh thu của một ngày đã đối soát sẽ đổi về sau,
  và ngưỡng lệch **0đ** của §4.9 mất nghĩa ngay hôm đó.
- *Không cho nợ.* Bác 2026-08-31 — quán vẫn cho nợ dù phần mềm nói gì.

**Applies to:**
`docs/product/0-ba/ban-hang/` §3.1.6, §4.7, §4.9, §4.10 · `quality/invariants.md` I-005, I-014 · ADR-012 ·
`master_plan/shop-facts.md` §6.14.

---

### ADR-020 — Hoàn tiền: CÓ, người đứng quầy vừa quyết vừa ghi vết, và tính vào NGÀY HOÀN

**Decision:**
Quán **có** hoàn tiền, và **không có luật cứng** về khi nào được hoàn — **người đứng quầy quyết
từng ca** theo tình hình thật (`master_plan/shop-facts.md` §6.4, chốt 2026-08-30). Cùng người ấy
**ghi vết**, không tách thành hai vai (**S-3**, chủ quán xác nhận 2026-08-30).

Mỗi lần hoàn để lại vết trả lời đủ **bốn** câu: hoàn **bao nhiêu** · cho **đơn nào** · **ai** bấm ·
**lý do** gì. Khoản hoàn trừ vào doanh thu **ngày hoàn**, không phải ngày bán gốc (**U-019** vế 2,
chốt 2026-09-01).

**Why:**
Chính vì **không có luật cứng** nên cái vết là thứ **duy nhất** giữ chỗ này khỏi thành lỗ thủng:
không có bảng điều kiện để đối chiếu thì phải có người đứng tên (**I-012**). Ô *lý do* bắt buộc ở
đây mà không bắt buộc ở thao tác khác cũng vì lẽ ấy.

Tính vào **ngày hoàn** cho ra hệ quả đáng giữ nhất của cả §4: **doanh thu một ngày đã đối soát
không bao giờ đổi về sau.** Đối soát ngưỡng 0đ (ADR-022) chỉ đứng được khi con số của hôm qua là
con số cuối cùng.

**Rejected alternatives:**
- *Trừ khoản hoàn vào **ngày bán gốc**.* Bác 2026-09-01 — nó viết lại doanh thu một ngày đã chốt
  sổ, nên mỗi lần hoàn là một lần phải đối soát lại quá khứ.
- *Dựng một bảng điều kiện "được hoàn khi…".* Bác — chủ quán cố ý không đặt luật ấy; tài liệu nào
  biến lời chốt này thành bảng điều kiện là hiểu ngược nó.
- *Tách người quyết và người ghi vết làm hai vai.* Bác 2026-08-30 (S-3) — quán không có đủ người,
  và tách ra thì cái vết chậm hơn cái quyết định.

**Applies to:**
`docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.8, §4.9, §4.10 · `quality/invariants.md` I-012, I-014 ·
`master_plan/shop-facts.md` §6.4 · ADR-017 (huỷ đơn đã `Hoàn thành` đi qua đây).

---

### ADR-021 — Giờ hẹn bắt buộc với `pickup` VÀ `phone_preorder`; `delivery` có quản lý trạng thái giao

**Decision:**
**Giờ khách cần hàng là bắt buộc**, và bắt buộc với **cả hai** kênh có hẹn — `pickup` **và**
`phone_preorder`, không riêng `pickup` (`master_plan/shop-facts.md` §6.5, chốt 2026-08-30).

`delivery` **có** quản lý trạng thái giao, không chỉ ghi nhận đơn (§6.7, chốt 2026-08-30): trạng
thái `Đang giao` **chỉ tồn tại ở đơn giao tận nơi**, không có ở kênh khác. **POS bấm `Đang giao`
lúc đơn RỜI QUÁN**; mốc kết thúc do **người đi giao** bấm tại chỗ khách, cùng lúc với *đã thu
tiền* (**U-023**, chốt 2026-09-01).

**Phí ship 0đ và không có đơn tối thiểu** (§6.12) — đây là một trong bốn ranh giới đã chốt của
§6.12, không phải một con số chờ điền.

**Rejected alternatives:**
- *Giờ hẹn chỉ bắt buộc với `pickup`.* Bác — kế hoạch gốc §10 câu 6 viết như vậy vì viết trước
  ngày `phone_preorder` thành kênh riêng; `shop-facts.md` §6.5 nói **cả hai**, và §2 của
  `CLAUDE.md` cho `shop-facts.md` thắng.
- *`delivery` chỉ ghi nhận đơn, không có trạng thái giao.* Bác 2026-08-30 — quán cần biết đơn nào
  đang trên đường, vì tiền của đơn ấy chưa về két mà vẫn là doanh thu (ADR-022).
- *Cho `Đang giao` xuất hiện ở mọi kênh mang đi.* Bác — `pickup` và `phone_preorder` khách tự tới
  lấy, không có ai đi giao để bấm.

**Applies to:**
`docs/product/0-ba/ban-hang/` §2.1, §3.2.1, §5.2 · `quality/invariants.md` I-007 ·
`master_plan/shop-facts.md` §6.5, §6.7, §6.12.

---

### ADR-022 — Doanh thu một ngày cộng từ ĐỦ hai nguồn; đối soát BA nguồn, ngưỡng lệch 0đ

**Decision:**
Doanh thu một ngày cộng từ **đủ hai** nguồn bán — bán **tại bàn** và bán **mang đi** — và không
khoản nào đứng ở cả hai (**I-014**).

Đối soát cuối ngày dùng **ba** nguồn, chia theo **phương thức**, không cộng gộp:

| Nguồn | Đối chiếu phần nào |
|---|---|
| Sổ giấy | toàn bộ — bản ghi tay độc lập của cả ngày |
| Tiền trong két | phần khách trả **tiền mặt** |
| **Tin nhắn báo có** | phần khách **chuyển khoản** (**U-019**, chốt 2026-09-01) |

**Ngưỡng lệch là 0đ** — lệch một đồng cũng phải tìm ra lý do. Một lần thu **chia được nhiều phương
thức**, và POS ghi rõ bao nhiêu tiền mặt, bao nhiêu chuyển khoản (**U-020**, chốt 2026-09-01,
`shop-facts.md` §6.18, **I-015**).

Hai mốc ngày, ngược chiều nhau và cả hai đã chốt: **nợ** tính ngày **ghi nợ** (ADR-019) · **hoàn
tiền** tính ngày **hoàn** (ADR-020).

**Why:**
Nguồn thứ ba tồn tại vì **két không giữ tiền chuyển khoản**. Quán có hai phương thức mà chỉ một đi
qua két; so doanh thu với mỗi *sổ giấy + két* thì phần VietQR không có gì để đối chiếu.

Chia theo phương thức chứ không cộng gộp là phần đắt nhất của quyết định này: một chỗ **thiếu** ở
két có thể bị một chỗ **thừa** ở ngân hàng che mất, và lúc đó ngưỡng 0đ không còn nghĩa gì.

**Rejected alternatives:**
- *Đối soát bằng hai nguồn (sổ giấy + két).* Bác 2026-09-01 — phần VietQR không có gì đối chiếu.
- *Cộng gộp ba nguồn rồi so đúng một con số.* Bác — lệch bù trừ nhau, ngưỡng 0đ thành hình thức.
- *Ngưỡng chấp nhận vài nghìn cho "sai số đếm tiền".* Bác — đây là cổng chất lượng mạnh nhất của
  cả dự án; một ngưỡng dương biến mọi lỗi nhỏ thành vô hình.
- *Bắt khách chọn đúng một phương thức cho một lần thu.* Bác 2026-09-01 (U-020) — chữ *"hoặc"* ở
  `shop-facts.md` §1 là lựa chọn của khách, không phải luật loại trừ.

**Applies to:**
`docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.6, §4.9, §4.10 · `quality/invariants.md` I-014, I-015 ·
`master_plan/shop-facts.md` §6.10, §6.18 · `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.2 dòng 12.

---

### ADR-023 — Chủ quán đổi giá được NGAY giữa giờ bán; mốc khoá giá là TỪNG DÒNG; thành phần suất phải chờ hết buổi

**Decision:**
Bốn chiều đổi menu **không** cùng một luật, và ranh giới đi giữa **tiền** và **thành phần**:

- **Ba chiều TIỀN** — sửa giá, sửa phụ thu, bật/tắt món — sửa được **ngay giữa giờ bán**, hiệu lực
  **từ lúc lưu**, không phải chờ hết buổi (**U-014**, chốt 2026-09-01).
- **Chiều THÀNH PHẦN SUẤT** — phải **chờ hết buổi bán** (**U-016**, chốt 2026-09-01). Nhưng máy
  **chỉ nhắc một câu rồi vẫn cho lưu** (**U-018**, chốt 2026-09-01): luật *chờ hết buổi* là luật
  cho **người**, không phải hàng rào của máy.

**Mốc khoá giá là TỪNG LƯỢT GỌI, và sau 2026-09-02 là TỪNG DÒNG.** Lượt gọi trước mốc đổi giá giữ
giá cũ, lượt gọi sau mốc áp giá mới ⇒ **một hoá đơn phiên bàn được phép mang HAI mức giá** cho
cùng một món, và đó là kết quả **đúng** (**U-015**, chủ quán chấp nhận 2026-09-01).

**Sửa một dòng thì ĐẶT LẠI mốc khoá giá của chính dòng ấy**: dòng vừa sửa lấy **giá đang hiệu lực
lúc sửa** (**U-026**, chốt 2026-09-02). Hai điều đọc kèm: (1) luật gốc không đổi — một lần **đổi
giá** không bao giờ tự với ngược vào dòng đã tạo; cái đặt lại mốc là **thao tác cố ý của người
đứng quầy** trên đúng dòng đó. (2) Vết của lần sửa phải ghi **cả giá cũ lẫn giá mới**, nếu không
thì đối soát §4.9 không giải thích được chỗ lệch.

**Why:**
`master_plan/shop-facts.md` §6.17, §4.5, §6.19. Ba chiều tiền chỉ chạm **đơn mới**, nên đổi giữa
buổi không hại ai; đổi **thành phần suất** thì chạm việc **đang nằm ở bếp** — một suất đang tráng
dở bỗng đổi công thức là một suất không ai biết nó gồm gì.

**Rejected alternatives:**
- *Bắt cả bốn chiều chờ hết buổi.* Bác 2026-09-01 — *"không phải chờ đến hết buổi"*; nhớ bốn chiều
  thành một mốc duy nhất là làm sai đúng chiều đắt nhất.
- *Máy CHẶN hẳn việc sửa thành phần suất giữa giờ bán.* Bác 2026-09-01 (U-018) — máy chỉ nhắc.
  `quality/invariants.md` **I-011** bản đầu viết theo giả định "máy chặn" và đã phải **viết lại**
  ngay hôm sau; đó là bằng chứng vì sao câu này phải hỏi chứ không được suy.
- *Khoá giá theo lúc **mở phiên**.* Bác — nó xoá mất ca hai mức giá mà chủ quán vừa nói là đúng.
- *Dòng vừa sửa **giữ** giá cũ của lượt gọi.* Bác 2026-09-02 (U-026).

**Applies to:**
`docs/product/0-ba/ban-hang/` §3.3.1–§3.3.6, §4.4 · `quality/invariants.md` I-009, I-010, I-011, I-013 ·
`master_plan/shop-facts.md` §4.5, §6.17, §6.19.

---

### ADR-024 — Vết thao tác trong MVP là BẮT BUỘC, và phạm vi của nó là thao tác chạm TIỀN và chạm TRẠNG THÁI

**Decision:**
Câu **10** của §10 kế hoạch gốc — *"có cần lưu lịch sử thao tác của nhân viên ở MVP không?"* — trả
lời là **CÓ**, với một phạm vi đã khoanh:

- **Bắt buộc lưu vết:** mọi thao tác **chạm tiền** (danh sách tám thao tác ở **I-012**) và mọi lần
  **đổi trạng thái** một đơn, một phiên bàn, hay một việc trạm — kể cả lần **lùi** một mẻ (§5.4).
- **Mỗi vết trả lời bốn câu:** cái gì đổi · bao nhiêu · **ai** bấm · lúc **mấy giờ**. Hai chỗ đòi
  thêm: **hoàn tiền** phải có **lý do** (ADR-020), **sửa giá một dòng** phải có **cả giá cũ lẫn
  giá mới** (ADR-023).
- **KHÔNG thuộc MVP:** một nhật ký ghi **mọi** thao tác của nhân viên — mở màn hình, xem báo cáo,
  tìm kiếm. Nó không nằm trong mười bốn năng lực của §7.2, và đối soát cuối ngày không cần nó.

**Ai đã quyết, và ADR này gộp lời của ai.** Không có một câu trả lời duy nhất mang tên *"câu 10"*;
lời chốt nằm ở **ba** chỗ, cả ba đều là lời **chủ quán**: **S-3** (2026-08-30 — người đứng quầy vừa
quyết vừa **ghi vết** mỗi lần hoàn tiền) · **§6.10** (2026-08-30 — đối soát cuối ngày, ngưỡng lệch
**0đ**) · **U-019** (2026-09-01 — nguồn thứ ba của đối soát). BA-10 **gộp** ba lời ấy thành một
phạm vi và **không thêm gì**: phần *KHÔNG thuộc MVP* dưới đây là chỗ chưa ai hỏi, và nó được ghi ra
đúng như thế chứ không được chốt hộ.

**Why:**
Cái vết là **điều kiện tồn tại** của ngưỡng lệch 0đ (ADR-022). *"Lệch một đồng cũng phải tìm ra lý
do"* chỉ là một câu chữ nếu thao tác gây ra chỗ lệch không có tên người và không có giờ.

Phạm vi dừng ở *chạm tiền và chạm trạng thái* vì đó đúng là tập thao tác làm hai con số của buổi
tối lệch nhau. Mở rộng ra *mọi* thao tác thì thêm khối lượng mà không thêm một câu trả lời nào cho
buổi đối soát.

**Rejected alternatives:**
- *Không lưu vết gì ở MVP, để pha sau làm.* Bác — ngưỡng 0đ của §4.9 sập ngay ngày đầu chạy thật,
  và hai tuần đối soát đầu tiên là thứ không chạy lại được.
- *Lưu nhật ký toàn bộ thao tác của nhân viên.* **Không bác — chỉ là chưa ai chốt.** Ghi rõ ở đây
  để phiên sau không đọc ADR này thành *"đã quyết định là không bao giờ làm"*: nó nằm ở
  `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.5 (*chưa ai cần tới*), và muốn đưa vào thì đi đường §7.8, không phải sửa
  ADR này.

**Applies to:**
`docs/product/0-ba/ban-hang/` §4.8, §4.9, §5.4, §7.2 dòng 12 · `quality/invariants.md` I-012 · ADR-016
(một cửa ghi là điều kiện để "ai bấm" trả lời được).

---
### ADR-025 — Phụ thu suất trứng là ×5, vì quả trứng LÊN GIÁ THEO NHÂN (S-1)

**Decision:**
Phụ thu của một suất trứng là **×5**, không phải ×4 ⇒ **suất trứng nhân thường = 25.000**, không
phải 24.000 (**S-1**, chủ quán xác nhận **2026-08-30**). Lý do là quả trứng **cũng lên giá theo
nhân**, đúng như bốn cái bánh của suất.

Cùng họ và cùng ngày chốt: **giá một suất giò = 9.000 + tiền 4 cái bánh theo nhân** (chủ quán chốt
2026-08-29). Cả hai đều là *giá tính từ thành phần*, đúng quy tắc gốc **giá một suất = tổng giá
các thành phần** (`master_plan/shop-facts.md` §4.6 quy tắc 1).

**Bảng giá `shop-facts.md` §4.3 KHÔNG đổi một con số nào** khi S-1 được xác nhận — nó đã viết theo
×5 từ đầu. Cái đổi là **tư cách** của con số ấy: từ *suy ra* thành *đã chốt*.

**Why:**
S-1 nằm ở `master_plan/shop-facts.md` §7.2 (*chỗ suy ra chưa xác nhận*) cho tới 2026-08-30, tức nó
là **suy luận của phiên**, không phải lời chủ quán nói thẳng. Một con số tiền đứng ở tư cách suy ra
là chỗ nguy hiểm nhất trong cả tài liệu: nó **đúng hình dạng** một dữ kiện đã chốt và không có gì
phân biệt được, cho tới lúc thu sai tiền của khách.

Câu kiểm chứng hỏi được vì nó hỏi **về cái quán**: *"một suất trứng nhân thường bán 25.000 hay
24.000?"* — không hỏi *"phụ thu nhân với mấy?"*. Bài học ấy về sau thành luật chung ở §7.2 sau khi
**S-4** phải hỏi lại lần hai (`work/findings.md` F-004).

**Rejected alternatives:**
- *Phụ thu ×4 — quả trứng là một thành phần giá cố định.* Bác 2026-08-30 bởi chính chủ quán.
- *Để con số ở tư cách "suy ra" và đi tiếp.* Bác — mọi bảng giá và mọi ca kiểm ở §4.8 đứng trên
  nó; một con số tiền không được phép đứng ở tư cách suy ra.

**Applies to:**
`master_plan/shop-facts.md` §4.2, §4.3, §4.6, §7.1, §7.2 · `docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` §4.1–§4.3 ·
`quality/invariants.md` I-013 · toàn bộ `prompt/BA/` (pointer đã sửa cùng ngày, T-004).

---

### ADR-026 — Vòng đời công việc trạm BỎ `Đang làm` và giữ `Đã làm xong, còn ở bếp` thay vào

**Decision:**
Vòng đời **công việc trạm** (`docs/product/0-ba/ban-hang/05-vong-doi.md` §5.4) **không có** trạng thái `Đang làm`. Trạng thái
giữa của nó là **`Đã làm xong, còn ở bếp`** — bếp làm ra rồi nhưng chưa bưng ra bàn.

⇒ Bảng ở quầy có **BỐN** con số cho một bàn, không phải ba: cần · chưa làm · **đã làm xong còn ở
bếp** · đã bưng ra bàn. Cả **hai** mốc — *đã làm xong* và *đã bưng ra bàn* — do **người đứng quầy
bấm trên POS** (ADR-016, U-009 + U-017 + U-021); ba trạm bếp không bấm gì.

Bấm nhầm *"đã làm xong"* một mẻ thì **lùi được**: `Đã làm xong, còn ở bếp` ⇒ `Chưa làm`, và
**không có mốc thời gian cứng** nào chặn (**U-024**, chốt 2026-09-01). Mỗi lần lùi để lại vết
(ADR-024).

**Why:**
Hai lời chốt cộng lại, và một mình lời nào cũng chưa đủ:

1. **U-009 (2026-08-31): chủ quán bỏ mọi nút bấm ở ba trạm bếp** — *"bỏ bước ấy đi"*. Sau lời ấy
   **không còn nguồn nào** nói được cho máy biết bếp *bắt đầu* làm lúc nào. Một trạng thái không ai
   cập nhật được thì **hại hơn là không có**: nó luôn sai và không ai biết nó sai.
2. **S-4 (2026-09-01): bánh gấp xong CÓ nằm chờ thật** — chờ đủ đĩa, chờ người rảnh tay bưng, chờ
   món khác của cùng bàn. Ba lý do ấy do **chủ quán tự kể ra**, không ai gợi ý. ⇒ *làm xong* và
   *ra bàn* là **hai** việc khác nhau, nên cái chỗ trống mà `Đang làm` bỏ lại **có một trạng thái
   thật để điền vào**.

Nói cách khác: `Đang làm` bị bỏ vì **không ai bấm được nó**, còn `Đã làm xong, còn ở bếp` được
giữ vì **nó có thật trong bếp**. Đây là quyết định BA-07 để lại và BA-10 ghi thành ADR.

**Rejected alternatives:**
- *Giữ `Đang làm` và để POS suy ra.* Bác — quầy không nhìn thấy bếp bắt đầu lúc nào, và §7.2 của
  `shop-facts.md` ghi rõ bài học: hỏi về **cái quán** thì được trả lời, hỏi về **cái bảng trong
  máy** thì không.
- *Gộp *làm xong* và *ra bàn* thành một mốc.* Bác 2026-09-01 bởi chính lời chủ quán (S-4 vế 1) —
  gộp lại thì bảng quầy còn ba con số và bánh nằm chờ trở thành vô hình.
- *Để ba trạm bếp tự bấm.* Bác 2026-08-31 (U-009). `work/findings.md` **F-013** là cái giá của
  việc `master_plan/prompt-fullstack.md` còn thiết kế nút ấy sau khi chủ quán đã bỏ.
- *Không cho lùi một mẻ đã bấm nhầm.* Bác 2026-09-01 (U-024) — *"tuỳ theo thực tế để POS quyết
  định"*. **I-016** không phải sửa một chữ khi §5.4 thêm dòng ấy: nó khoá luật *chỉ đi theo bảng*,
  không khoá một danh sách ca cố định.

**Applies to:**
`docs/product/0-ba/ban-hang/05-vong-doi.md` §5.4, §5.6 · `master_plan/shop-facts.md` §5.4 · `quality/invariants.md` I-016 ·
**BA-12** (`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4 dựng bảng quầy — đọc **S-5** ở `shop-facts.md` §7.2 trước, vì
*bấm "đã bưng ra bàn" theo đơn vị nào* mới chỉ là chỗ **suy ra**).

---

### ADR-027 — Ghép bàn là MỘT phiên và MỘT hoá đơn, và chỉ ghép được sang bàn TRỐNG

**Decision:**
Ghép bàn là chuyện có thật ở quán, và hệ thống làm nó bằng **một phiên gắn nhiều bàn**, ra **một**
hoá đơn (**U-006**, chốt 2026-08-31). Câu *"một bàn một phiên"* đọc lại thành *"một bàn thuộc
**nhiều nhất một** phiên chưa thanh toán"* (**I-001**).

**Người đứng quầy bấm ghép, trên POS**, và **chỉ ghép được khi bàn kia còn TRỐNG** (**U-013**,
chốt 2026-08-31).

**Why:**
`master_plan/shop-facts.md` §6.16. Vế thứ hai đóng luôn ca đáng sợ nhất mà câu hỏi này mở ra:
**không bao giờ có việc gộp hai hoá đơn đã có tiền trong đó.** Ca ấy bị đóng bằng một **quyết định
nghiệp vụ**, không phải bằng một thiết kế khéo — và đó là cách rẻ nhất để đóng nó.

**Rejected alternatives:**
- *Cho ghép hai bàn đều đang có phiên, rồi gộp hai hoá đơn.* Bác 2026-08-31 — gộp hai hoá đơn đã
  có lượt gọi và có thể đã thu một phần là chỗ **thu thiếu tiền** dễ xảy ra nhất trong cả sản phẩm.
- *Mỗi bàn giữ một hoá đơn riêng rồi cộng tay lúc thu.* Bác — **I-002** tính tiền theo **phiên**,
  không theo bàn và không theo lượt gọi.

**Applies to:**
`docs/product/0-ba/ban-hang/` §3.1.7, §5.3 · `quality/invariants.md` I-001, I-002 ·
`master_plan/shop-facts.md` §6.16 · `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.2 dòng 4.

---

### ADR-028 — Năm trạm làm việc; chủ quán đứng quầy vẫn giữ vai chủ quán

**Decision:**
Nhân viên **có** phân vai theo trạm (**U-001**, chốt 2026-08-30). **Năm** trạm: **quầy** · **tráng
bánh** · **gấp bánh** · **lấy canh** và **dọn bàn** — hai trạm cuối do **chung một người** làm
(`master_plan/shop-facts.md` §3).

**Chủ quán thỉnh thoảng đứng quầy, và vẫn giữ vai chủ quán** (**U-002**, chốt 2026-08-30). Hai
quyền đi theo hai thứ khác nhau, và không được trộn:

- Quyền của **người đứng quầy** (duyệt, huỷ, hoàn tiền, ghi nợ, ghép bàn, bấm bảng bếp) đi theo
  **chỗ đứng** — ai đang ở quầy thì có, kể cả chủ quán (ADR-016).
- Quyền của **chủ quán** (đổi giá, đổi thành phần suất trên mặt quản trị) đi theo **con người** —
  đứng ở đâu cũng có, và người đứng quầy **không** tự có nó (ADR-023).

**Why:**
`master_plan/shop-facts.md` §3, nhật ký §7.1 ngày 2026-08-30. Phân biệt hai chiều gắn quyền là thứ
giữ cho **U-004** (*chủ quán không đứng quầy thì nhờ người đứng quầy bấm huỷ*) và **§6.17** (*chỉ
chủ quán đổi giá*) cùng đúng một lúc mà không mâu thuẫn.

**Rejected alternatives:**
- *Nhân viên không phân vai — ai cũng làm mọi việc.* Bác 2026-08-30 (U-001).
- *Coi chủ quán là "một nhân viên nữa có thêm quyền".* Bác — mặt quản trị biến mất và ADR-011 mất
  chỗ đứng: ba mặt của sản phẩm phân biệt nhau đúng bằng vai này.
- *Tách "lấy canh" và "dọn bàn" thành hai người.* Bác — quán không có đủ người; đây là dữ kiện,
  không phải lựa chọn thiết kế.

**Applies to:**
`docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.3, §1.5 · `master_plan/shop-facts.md` §3 · ADR-011, ADR-016 ·
`docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.2 dòng 6 (nổ việc cho **đúng năm trạm**).

---

### ADR-029 — Suất "đem về" của khách ĐANG NGỒI BÀN thuộc phiên bàn, không sinh đơn mang đi

**Decision:**
Đơn mang đi **không** dùng chung bảng gom việc với bàn (**U-010**, chốt 2026-08-31). Nhưng khách
**đang ngồi bàn** gọi thêm một suất **đem về** thì suất ấy thuộc **phiên bàn** đang mở, kèm note
**"đem về"** phải rõ ràng — nó **không** sinh ra một đơn mang đi riêng.

**Why:**
`master_plan/shop-facts.md` §6.15. Người khách ấy trả tiền **một lần**, cho **một** hoá đơn, đúng
lúc đóng phiên. Tách suất đem về ra thành đơn `pickup` riêng là tạo **hai đơn vị thanh toán cho
một người đang ngồi trước mặt** — và quầy sẽ quên một trong hai.

Note *"đem về"* phải rõ vì nó đổi **việc của bếp** (gói mang đi thay vì bày đĩa), dù không đổi gì
ở phần tiền.

**Rejected alternatives:**
- *Sinh một đơn `pickup` riêng cho suất đem về.* Bác 2026-08-31 — **I-006** và **I-002** cùng cấm:
  tính tiền theo phiên bàn, và suất đem về của khách ngồi bàn không phải một đơn vị thanh toán độc
  lập.
- *Cho đơn mang đi dùng chung bảng gom việc với bàn.* Bác — bảng bàn gom theo **bàn**, đơn mang đi
  không có bàn để gom vào.

**Applies to:**
`docs/product/0-ba/ban-hang/` §2.1, §3.1.4 · `quality/invariants.md` I-006, I-007 ·
`master_plan/shop-facts.md` §6.15.

---

### ADR-030 — Đơn trả trước nhận TIỀN MẶT hoặc VietQR, và POS xác nhận vào lúc NHẬN TIỀN

**Decision:**
Đơn trả trước nhận đúng **hai** phương thức — **tiền mặt** hoặc **VietQR** — không có phương thức
thứ ba (**U-005**, chốt 2026-08-31). **POS xác nhận vào lúc NHẬN TIỀN**, không phải lúc khách bấm
chọn *"trả trước"*.

**Người đứng quầy là người duy nhất nói được câu *"đã nhận tiền"***, vì mã **VietQR là mã TĨNH**:
không có báo có tự động chạy về máy, nên máy không tự biết tiền đã về.

**Why:**
`master_plan/shop-facts.md` §6.3. Khoảng cách giữa *khách bấm chọn trả trước* và *tiền thật sự về*
là chỗ đơn được đẩy xuống bếp trong khi chưa ai trả đồng nào. Mã tĩnh làm khoảng cách ấy không tự
đóng lại được, nên nó phải đóng bằng **một người**.

Đây cũng là gốc của lời chốt sau này ở **GĐ-03** (khách nói đã chuyển khoản mà quầy chưa thấy báo
có): quầy bàn với khách và chọn một trong hai đường đã có — ghi **nợ** (ADR-019) hoặc **chờ tin
nhắn** (ADR-022).

**Rejected alternatives:**
- *Coi "khách bấm trả trước" là đã trả.* Bác — mã tĩnh, không có báo có tự động; đây là ca thu
  thiếu tiền rẻ nhất để tạo ra và đắt nhất để phát hiện.
- *Dùng cổng thanh toán online có webhook báo có.* Bác — ngoài phạm vi (`docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.4),
  và nó đổi cách quán nhận tiền chứ không chỉ đổi phần mềm.

**Applies to:**
`docs/product/0-ba/ban-hang/` §4.6, §4.7, §6.3 · `quality/invariants.md` I-012, I-015 ·
`master_plan/shop-facts.md` §6.3 · GĐ-03 (đã thay bằng quy tắc, §6.21).

---

### ADR-031 — Ba mảng quản trị được PHÉP làm, nhưng đi SAU luồng bán hàng

**Decision:**
**Không** mảng nào trong ba mảng quản trị — **nguyên liệu · con người · tài chính** — phải chạy
cùng **bản bán hàng đầu tiên** (**U-030**, chủ quán chốt 2026-09-02). Nguyên văn: *"không mảng nào
cần chạy với bán hàng. Bán hàng xong chạy được thì để chạy trước."*

Đây là một quyết định về **THỨ TỰ**, không phải một lần loại bỏ. Ranh giới §1.6 vẫn **mở**: ba mảng
ấy vẫn *được phép làm* (chủ quán chốt 2026-09-01, xác nhận lại 2026-09-02).

**Phân vai với ADR-013, vì hai mục dễ bị đọc chồng lên nhau:** ADR-013 nói **viết** nội dung admin
**vào đâu** (mục riêng có nhãn ở mỗi tài liệu). ADR này nói ba mảng ấy **đứng đâu trong thời gian**.

**Why:**
Hai lý do độc lập cùng chỉ một hướng, và trước 2026-09-02 chỉ có lý do thứ nhất:

1. **Lý do của tài liệu:** `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.2 có một điều kiện vào cửa — *§1–§6 đã mô tả nó* —
   mà §2 tới §6 **chưa có một quy tắc nghiệp vụ nào** cho ba mảng ấy. Một hạng mục MVP không trỏ
   được về mô tả nào là một hạng mục không ai làm được.
2. **Lý do của chủ quán:** họ vừa nói thẳng là **không cần** chúng ở bản chạy đầu.

⇒ **Hệ quả cho việc xếp lịch:** ADM-01…ADM-52 ở `work/admin-questions.md` §2 nay có một mốc để xếp
quanh — không phải *"chưa biết bao giờ"* mà là *"sau khi luồng bán hàng chạy được"*.

**Rejected alternatives:**
- *Xếp ba mảng vào `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` §7.4 (**đã quyết định không làm**).* Bác — chủ quán vừa mở
  ranh giới cho chúng **hai lần**; §7.4 sẽ nói ngược lại lời họ.
- *Xếp vào §7.5 (**chưa ai cần tới**).* Bác — **có** người cần, chỉ là cần **sau**.
- *Mở ADM-01…ADM-52 thành task ngay bây giờ.* Bác — một task mở trước khi có luật nghiệp vụ là
  một task sẽ phải viết lại; điều kiện vào cửa §7.2 **không đổi** vì lời chốt này.

**Applies to:**
`docs/product/0-ba/` §1.6, §7.6 · `docs/product/1-system-design/architecture.md` §14 · `master_plan/shop-facts.md` §8 ·
`work/admin-questions.md` §2 · ADR-013.

---

<a id="ban-do"></a>
## Bản đồ — mọi câu hỏi BA nằm ở quyết định nào

Mục này tồn tại để trả lời đúng một câu: **có câu hỏi nghiệp vụ nào bị bỏ sót không.** Nó không giữ
sự thật nào của riêng nó; mọi ô đều trỏ về một mục ở trên hoặc một `GĐ` ở dưới.

### Mười câu của §10 kế hoạch gốc

`master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §10 liệt kê mười câu **phải chốt trước khi sang
System Design**. Tính tới **2026-09-02**, cả mười đều đã chốt.

| # | Câu hỏi | Đã chốt ở | Trạng thái |
|:--:|---|---|---|
| 1 | Ai xác nhận, huỷ và chỉnh sửa đơn? | **ADR-016** (xác nhận, huỷ) · **ADR-017** (sửa) | ✅ đủ ba vế |
| 2 | Đơn đã xác nhận được sửa hay chỉ huỷ/tạo lại? | **ADR-017** | ✅ |
| 3 | Món hết sau khi khách đặt thì xử lý thế nào? | **ADR-018** | ✅ (thay GĐ-02) |
| 4 | Khách không thanh toán được thì phiên bàn ở trạng thái nào? | **ADR-019** | ✅ |
| 5 | Có hoàn tiền không, ai được phép? | **ADR-020** | ✅ |
| 6 | Giờ khách cần hàng có bắt buộc không, với kênh nào? | **ADR-021** | ✅ cả `pickup` **và** `phone_preorder` |
| 7 | `delivery` chỉ ghi nhận đơn hay quản lý trạng thái giao? | **ADR-021** | ✅ có `Đang giao` |
| 8 | Doanh thu tính theo ngày nào, đơn huỷ/hoàn ra sao? | **ADR-022** (+ ADR-019, ADR-020 cho hai mốc ngày) | ✅ |
| 9 | Chủ quán đổi giá đang bán ngay được không? | **ADR-023** | ✅ |
| 10 | Có cần lưu lịch sử thao tác nhân viên ở MVP không? | **ADR-024** | ✅ có, phạm vi đã khoanh |

### Mọi Unknown đã mở từ BA-01 tới BA-09

Ba mươi câu, **U-001 → U-030**, mở bởi các prompt 01–08 cộng BA-09. Không câu nào còn mở
(`docs/product/99-unknowns.md`, mục *Đang mở* rỗng tính tới 2026-09-02).

| U | Câu hỏi (rút gọn) | Nằm ở |
|---|---|---|
| U-001 | Nhân viên có phân vai theo trạm không | **ADR-028** |
| U-002 | Chủ quán có phải là nhân viên không | **ADR-028** |
| U-003 | Đơn hotline rồi khách tới ăn tại quán | **ADR-015** |
| U-004 | Ai được bấm huỷ một đơn | **ADR-016** |
| U-005 | Đơn trả trước trả bằng gì, ai xác nhận, lúc nào | **ADR-030** |
| U-006 | Ghép bàn thì hệ thống phải làm gì | **ADR-027** |
| U-007 | Khách rời quán chưa trả tiền thì ai đóng phiên | **ADR-019** |
| U-008 | Một nồi làm được bao nhiêu; trứng và bánh tranh nồi | **ADR-009** *(dữ kiện năng lực nồi: `shop-facts.md` §5.4)* |
| U-009 | Ai bấm *đã làm xong* / *đã bưng ra bàn* | **ADR-026** · **ADR-016** |
| U-010 | Đơn mang đi có chung bảng gom việc với bàn không | **ADR-029** |
| U-011 | Máy có được tự chia mẻ không | **ADR-009** *(máy chỉ hiện tổng nhu cầu, người tự gom)* |
| U-012 | Nợ: ai ghi nhận, doanh thu tính ngày nào | **ADR-019** |
| U-013 | Ai bấm ghép bàn, ghép được khi bàn kia đang mở không | **ADR-027** |
| U-014 | Đổi giá ngay giữa giờ bán được không | **ADR-023** |
| U-015 | Phiên vắt qua mốc đổi giá thì hoá đơn ra sao | **ADR-023** |
| U-016 | Đổi thành phần suất giữa giờ bán được không | **ADR-023** |
| U-017 | Bấm *đã làm xong* theo từng cái, cả mẻ, hay cả bàn | **ADR-026** |
| U-018 | Máy chặn hẳn hay chỉ nhắc khi sửa thành phần suất | **ADR-023** |
| U-019 | Đối chiếu phần chuyển khoản bằng gì · hoàn tiền trừ ngày nào | **ADR-022** · **ADR-020** |
| U-020 | Khách trả một phần tiền mặt, một phần chuyển khoản | **ADR-022** |
| U-021 | Ai bấm *đã bưng ra bàn* | **ADR-026** · **ADR-016** |
| U-022 | Sửa một đơn được phép tới trạng thái nào | **ADR-017** |
| U-023 | Ai bấm cho đơn sang `Đang giao`, lúc nào | **ADR-021** |
| U-024 | Bấm nhầm một mẻ thì có đường lùi không | **ADR-026** |
| U-025 | Sổ giấy: ai giữ, ghi gì, nhập lại lúc nào | **ADR-016** |
| U-026 | Một dòng vừa sửa thì tính giá lúc nào | **ADR-023** |
| U-027 | Đơn đã `Hoàn thành` có huỷ được không | **ADR-017** |
| U-028 | *(hai phiên song song cùng lấy số này 2026-09-02; không câu hỏi nào mang số ấy hôm nay)* | — |
| U-029 | *(chưa bao giờ được cấp — dãy số nhảy vì cùng sự cố trên)* | — |
| U-030 | Mảng quản trị nào phải có ở bản chạy đầu tiên | **ADR-031** |

> **U-028 và U-029 là hai chỗ trống có thật trong dãy số, không phải hai câu hỏi bị mất.** Ngày
> 2026-09-02 hai phiên chạy song song **cùng lấy số U-028** — sự cố ghi trong `work/backlog.md`
> entry **T-042** (*"lần thứ sáu, và lần này CÓ thiệt hại"*) cùng với hai va chạm khác của cùng
> ngày, và ở `work/findings.md` **F-014**. Không câu hỏi nào mang số U-028 hay U-029 trong
> `docs/product/99-unknowns.md` hôm nay. Phiên sau **không** tái sử dụng hai số này: câu hỏi mới lấy **U-031**.

### Năm chỗ SUY RA — S-1 tới S-5

`master_plan/shop-facts.md` §7.2 giữ những chỗ được **suy ra** từ luật đã chốt chứ không phải lời
chủ quán nói thẳng. Bốn chỗ đã được xác nhận và lên §7.1; **S-5** vẫn còn là chỗ suy ra.

| S | Chỗ suy ra | Hỏi ngày | Nằm ở |
|---|---|---|---|
| S-1 | Phụ thu suất trứng ×5 hay ×4 | 2026-08-30 ✅ | **ADR-025** |
| S-2 | Số điện thoại và địa chỉ giao là hai trường bắt buộc | 2026-08-30 ✅ | **ADR-015** |
| S-3 | Ai ghi vết mỗi lần hoàn tiền | 2026-08-30 ✅ | **ADR-020** |
| S-4 | *"Đã làm xong, còn ở bếp"* có phải một con số riêng | 2026-08-31 (hỏng) → 2026-09-01 ✅ | **ADR-026** |
| S-5 | Bấm *"đã bưng ra bàn"* theo **đơn vị nào** | **chưa hỏi** | ⚠️ vẫn là chỗ **suy ra** — `shop-facts.md` §7.2, **BA-12** phải đọc trước khi dựng bảng quầy |

**S-5 không phải một `GĐ` và không phải một `U`.** Nó là chỗ *suy ra* — có một câu trả lời tạm
(theo **bàn**, vì một mẻ phục vụ nhiều bàn còn bưng thì bưng tới một bàn) nhưng chưa ai hỏi chủ
quán. Chỗ của nó là `master_plan/shop-facts.md` §7.2, và nó **không** vào mục *Unknowns* của
`docs/product/99-unknowns.md` (`work/findings.md` F-004: chỗ suy ra phải tách khỏi chỗ đã chốt).

---
## Giả định BA — ngoại lệ chưa có lời chốt

Mục này giữ **giả định tạm thời** cho những dòng mang dấu ⚠ trong `docs/product/0-ba/ban-hang/06-ngoai-le.md` §6. Một `GĐ`
**không phải** một quyết định: nó là chỗ ghi lại *nếu không ai trả lời thì hôm nay quán đang ngầm
làm thế nào*, kèm **mức rủi ro** nếu giả định ấy sai. Có lời chủ quán thì `GĐ` bị **thay** bằng
quy tắc trong owner của nó (`master_plan/shop-facts.md`), không phải sửa tại chỗ.

Mọi `GĐ` dưới đây mở ngày **2026-09-02**, do **BA-08** (`docs/product/0-ba/ban-hang/06-ngoai-le.md` §6).

**CẢ NĂM mục đã bị thay trong ngày 2026-09-02, và mục này nay không giữ giả định nào còn hiệu
lực.** Ba mục đầu bị thay ở lượt một (T-042 — GĐ-02, GĐ-03, GĐ-04), hai mục cuối ở lượt cuối
(T-045 — GĐ-01, GĐ-05). Tất cả giữ lại **có gạch ngang**, kèm lời chốt thật ở đầu, vì chỗ chúng
đoán **lệch** là thứ đáng đọc.

**Năm lần đoán, hai kiểu lệch — và kiểu thứ hai mới là kiểu nguy hiểm.**

- **Bốn lần đoán CHẶT HƠN quán thật** (GĐ-02, GĐ-03, GĐ-04, và một nửa GĐ-05): dựng ra một luật
  cứng ở nơi chủ quán cố ý **không** đặt luật nào. Kiểu này lộ ra ngay khi hỏi, vì câu trả lời
  mâu thuẫn thẳng với giả định.
- **Một lần đoán THIẾU** (GĐ-01, và nửa còn lại của GĐ-05): đoán **đúng** phần cơ chế — người bấm
  sau thắng, không có nút hoàn tác — nhưng bỏ mất thứ chủ quán coi là điều kiện đi kèm: **bản copy
  trước và sau, lý do, người sửa**. Kiểu này **không** lộ ra khi hỏi câu đã viết: hỏi *"ai thắng?"*
  thì được xác nhận là đoán đúng, và yêu cầu kia chỉ xuất hiện vì chủ quán tự nói thêm. ⇒ Một giả
  định được xác nhận **không** có nghĩa là đã đủ; nó chỉ có nghĩa là phần **đã hỏi** thì đúng.

⇒ Yêu cầu ấy nay là `master_plan/shop-facts.md` **§6.22** và `quality/invariants.md` **I-018**.

### GĐ-01 — ~~Hai người cùng thao tác trên một bàn~~ · **ĐÃ THAY bằng quy tắc, 2026-09-02**

**Dòng §6:** 4 · ~~**Rủi ro: TRUNG BÌNH**~~ · **Trạng thái: Superseded** —
`master_plan/shop-facts.md` §6.22, `quality/invariants.md` I-018

> **Chủ quán chốt 2026-09-02:** *"đồng ý, nhưng cần note ai là người sửa. Hệ thống cần record sửa
> cái gì, có bản copy trước khi sửa là thế nào, sau khi sửa là thế nào, ai sửa — để đối chiếu."*
> Giả định bên dưới đoán **đúng cơ chế** (người bấm sau thắng) nhưng **thiếu điều kiện đi kèm**:
> lần ghi đè phải giữ **bản trước, bản sau và tên người sửa**. Đó không phải chi tiết kỹ thuật —
> không có bản trước thì một lượt gọi bị đè mất sẽ không ai truy ra, và đó là **thu thiếu tiền**.
> Đọc quy tắc ở `shop-facts.md` §6.22, đừng đọc phần dưới.

**Giả định.** Hai người cùng sửa một phiên bàn thì thao tác **tới POS sau** là thao tác có hiệu
lực; không có khoá, không có cảnh báo.

**Vì sao tạm chấp nhận được.** POS là **cửa duy nhất được ghi** (`docs/decisions.md` ADR-011) và
quán chỉ có **một** máy POS đặt ở quầy (`shop-facts.md` §6.13), nên hai lượt ghi thật sự đồng thời
là hiếm. Ca có thật là **khách quét QR trong lúc quầy đang bấm** cho cùng bàn ấy.

**Rủi ro nếu sai.** Một lượt gọi bị đè mất ⇒ **thu thiếu tiền** đúng kiểu `shop-facts.md` §6.1
cấm. Xếp TRUNG BÌNH chứ không CAO vì lượt gọi của khách và thao tác của quầy ghi vào **hai chỗ khác
nhau** của cùng một phiên, không đè lên nhau ở phần lớn ca.

**Câu phải hỏi chủ quán.** *"Khách đang quét QR gọi thêm đúng lúc quầy bấm tính tiền cho bàn ấy thì
ở quán xử lý thế nào?"*

### GĐ-02 — ~~Món hết sau khi khách đã chọn~~ · **ĐÃ THAY bằng quy tắc, 2026-09-02**

**Dòng §6:** 5 · ~~**Rủi ro: CAO**~~ · **Trạng thái: Superseded** — `master_plan/shop-facts.md` §6.20

> **Chủ quán chốt 2026-09-02:** *POS sẽ làm việc với khách và quyết định được đưa ra tại thời điểm
> thảo luận xong với khách hàng.* Giả định bên dưới **đoán gần đúng** (quầy gọi khách, khách quyết)
> nhưng đoán thiếu một nửa: nó viết như thể quán chọn sẵn một trong ba đường, còn lời chốt nói
> **không có đường chọn sẵn nào** — kết quả là cái hai bên thống nhất tại ca đó. Đọc quy tắc ở
> `shop-facts.md` §6.20, đừng đọc phần dưới. Giữ lại để thấy chỗ đoán lệch.

**Giả định.** Quầy **liên hệ khách** rồi làm theo ý khách: đổi sang thành phần khác, bỏ phần thiếu,
hoặc huỷ cả đơn. Máy không tự chọn giúp.

**Vì sao tạm chấp nhận được.** Không có quy tắc nào của quán cho phép **đổi ruột một suất** mà
không hỏi — đổi thành phần là quyền chủ quán và còn phải **chờ hết buổi** (`shop-facts.md` §6.17).
Nên "hỏi khách" là giả định hẹp nhất, không tự chế luật mới.

**Rủi ro nếu sai.** Xếp **CAO** vì quy mô: mọi suất đều kèm bánh (`shop-facts.md` §4.5), nên **hết
bánh cuốn là hết gần như mọi món** — giả định này không áp cho một đơn lẻ mà có thể áp cho **cả
buổi bán**. Chọn sai đường ở đây là chọn sai cho hàng chục đơn cùng lúc.

**Câu phải hỏi chủ quán.** *"Đang bán mà hết bánh, những bàn đã gọi rồi thì quán làm thế nào — báo
từng bàn, đổi món khác, hay trả tiền lại?"*

### GĐ-03 — ~~Khách nói đã chuyển khoản mà quầy chưa thấy báo có~~ · **ĐÃ THAY bằng quy tắc, 2026-09-02**

**Dòng §6:** 9 · ~~**Rủi ro: CAO**~~ · **Trạng thái: Superseded** — `master_plan/shop-facts.md` §6.21

> **Chủ quán chốt 2026-09-02:** *POS sẽ thảo luận với khách và đưa ra quyết định tại lúc đó.* Giả
> định bên dưới đoán **sai chiều**: nó chốt sẵn *"không giữ khách, ghi nợ"*, còn lời chốt để **cả
> hai** đường mở — ghi nợ, **hoặc** chờ tin nhắn — và giao việc chọn cho người đứng quầy. Đây đúng
> là chỗ một giả định nghe hợp lý đã suýt thành luật cứng. Đọc `shop-facts.md` §6.21.

**Giả định.** Quầy **không** giữ khách lại chờ tin nhắn. Phiên đóng theo đường **nợ** của
`shop-facts.md` §6.14 — ghi ai nợ, nợ bao nhiêu — và xoá khoản nợ khi tin nhắn báo có tới.

**Vì sao tạm chấp nhận được.** VietQR ở quán là mã **tĩnh**, máy không bao giờ tự biết tiền đã về;
câu *"đã nhận tiền"* chỉ do người bấm ở POS tạo ra (`shop-facts.md` §6.3). Quán **đã có** đúng một
đường cho *"tiền chưa vào tay mà khách phải đi"*, và đó là nợ — giả định này dùng lại đường có sẵn
thay vì đẻ trạng thái mới.

**Rủi ro nếu sai.** Xếp **CAO** vì nó chạm thẳng cổng chất lượng mạnh nhất của dự án: đối soát cuối
ngày ngưỡng **0đ** (`shop-facts.md` §6.10). Ghi nhầm một lần chuyển khoản thành nợ làm **hai** con
số sai cùng lúc — phần chuyển khoản so với tin nhắn, và tổng nợ ghi trong ngày.

**Câu phải hỏi chủ quán.** *"Khách bảo chuyển rồi mà điện thoại chưa có tin nhắn báo có thì quán
cho khách đi hay giữ lại chờ?"*

### GĐ-04 — ~~Đơn đã hoàn thành cần điều chỉnh~~ · **ĐÃ THAY bằng quy tắc, 2026-09-02**

**Dòng §6:** 13 · ~~**Rủi ro: TRUNG BÌNH**~~ · **Trạng thái: Superseded** — `master_plan/shop-facts.md` §6.19

> **Chủ quán chốt 2026-09-02:** *quán đang ở trạng thái nào cũng sửa được, POS sẽ quyết định dựa
> trên tình hình thực tế.* Giả định bên dưới đoán **ngược hẳn** — nó viết *"đơn đã `Hoàn thành` thì
> không sửa nữa, xử bằng hoàn tiền"*, và rủi ro nó tự nêu (*"nếu quán thật vẫn sửa đơn đã xong"*)
> đúng là điều đã xảy ra. **Đây là giả định sai nhiều nhất trong năm mục**, và nó sai theo hướng
> chặt hơn quán thật — đúng thứ CLAUDE.md §3.5 cảnh báo. Đọc `shop-facts.md` §6.19.

**Giả định.** Đơn đã `Hoàn thành` thì **không sửa nội dung nữa**; sai sót xử bằng đường **hoàn
tiền** của §4.8 — quầy quyết từng ca, ghi vết, trừ vào doanh thu **ngày hoàn**.

**Vì sao tạm chấp nhận được.** Chủ quán mới chốt **sửa được** và **sửa trên POS**, chưa chốt **tới
trạng thái nào** (`shop-facts.md` §6.19, nửa còn mở của **U-022**). Bảng §5.2 hôm nay **không có**
dòng `Hoàn thành → Huỷ`, nên giả định này là đọc đúng chữ của tài liệu chứ không nới rộng lời chủ
quán (`work/findings.md` F-004).

**Rủi ro nếu sai.** Nếu quán thật vẫn sửa đơn đã xong, thì mọi lần sửa ấy hôm nay đi vòng qua hoàn
tiền — doanh thu rơi vào **ngày hoàn** thay vì ngày bán, và `shop-facts.md` §6.4 nói thẳng luật ấy
**ngược chiều** luật nợ. Sai ở đây làm lệch sổ **giữa hai ngày**, không mất tiền.

**Câu phải hỏi chủ quán.** *"Đơn đã làm xong đưa cho khách rồi mà phát hiện nhầm thì quán sửa lại
đơn ấy hay trả tiền lại cho khách?"*

### GĐ-05 — ~~Thao tác nhầm ngoài ca "bấm nhầm một mẻ"~~ · **ĐÃ THAY bằng quy tắc, 2026-09-02**

**Dòng §6:** 14 · ~~**Rủi ro: TRUNG BÌNH**~~ · **Trạng thái: Superseded** —
`master_plan/shop-facts.md` §6.22, `quality/invariants.md` I-018

> **Chủ quán chốt 2026-09-02:** *"mọi thao tác nhầm khác — duyệt nhầm một đơn, huỷ nhầm, đóng phiên
> nhầm — không có nút hoàn tác, nhưng có nút cập nhật, và có bản copy trước cập nhật / sau cập nhật
> / lý do / ai là người sửa."* Giả định bên dưới đoán **đúng** vế *không có hoàn tác*, nhưng sai ở
> vế sau: nó viết *"cách xử là quầy làm bù bằng thao tác hợp lệ đang có"*, tức **không có gì mới**.
> Thật ra quán muốn một **nút cập nhật** kèm bản ghi bốn phần. Đọc `shop-facts.md` §6.22.

**Giả định.** Chỉ ca **bấm nhầm *"đã làm xong"* một mẻ** có đường lùi (chủ quán chốt 2026-09-01,
U-024). Mọi thao tác nhầm khác — duyệt nhầm một đơn, huỷ nhầm, đóng phiên nhầm — **không** có nút
hoàn tác; cách xử là quầy làm bù bằng thao tác hợp lệ đang có.

**Vì sao tạm chấp nhận được.** §5.1 nói **mọi chuyển tiếp ngoài bảng đều bị từ chối**, và chủ quán
mới mở đúng **một** đường lùi. Suy đường lùi ấy ra cho các thao tác khác là nới lời chủ quán rộng
hơn chữ của nó.

**Rủi ro nếu sai.** Ca đắt nhất là **đóng phiên nhầm**: phiên `Đã đóng` **không** quay lại
`Đang phục vụ` (§5.6, ca đã chốt), nên khách còn ngồi đó sẽ phải mở **phiên mới, hoá đơn mới** —
đúng thứ `shop-facts.md` §6.1 gọi là thu thiếu tiền, chỉ khác nguyên nhân.

**Câu phải hỏi chủ quán.** *"Quầy lỡ bấm đóng phiên một bàn khách vẫn đang ăn thì lúc đó làm thế
nào?"*
