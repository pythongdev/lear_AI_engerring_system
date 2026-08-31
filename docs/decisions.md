# Architecture Decisions

Record decisions that future engineers or AI sessions need to understand.

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
Từ **2026-08-31** (T-021), `docs/product.md` → *Unknowns* có một hợp đồng, và
`scripts/brief.sh` đọc đúng hợp đồng đó:

- **Vùng đang mở** = phần đầu mục (trước tiêu đề `###` đầu tiên) **cộng** mọi khối nằm dưới một
  tiêu đề `### Đang mở`. Mọi thứ dưới một tiêu đề `###` khác không được đọc.
- **Trong vùng đang mở, một gạch đầu dòng là một unknown đang mở.** Định danh `U-XXX` được tìm ở
  **bất cứ đâu** trong gạch đầu dòng ấy, nên in đậm ở đâu cũng được.
- **Văn xuôi trong vùng đang mở không sinh ra unknown**, và các dòng vắt của một gạch đầu dòng
  được **nối lại** thành một mục trước khi cắt ngắn để in.
- Hợp đồng được viết ở chính `docs/product.md`, dưới tiêu đề `### Cách viết một câu ở đây` — tức
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
  `docs/product.md` nên người sửa nhìn thấy, và `scripts/brief.test.sh` giữ ca U3b.
- **Brief vẫn im khi đọc ra rỗng.** `(none)` có thể nghĩa là "không còn câu nào" hoặc "hình dạng
  hỏng". Giữ nguyên vì §7.1 cấm brief chặn; ca U5 và U7 khoá hành vi `(none)` + `exit 0`.
- **Tiêu đề dài bị cắt ở 96 ký tự.** Brief là con trỏ, không phải bản sao (§7.1) — muốn đọc đủ
  thì mở `docs/product.md`.

**Applies to:**
`scripts/brief.sh` · `scripts/brief.test.sh` · `docs/product.md` → *Unknowns* · `CLAUDE.md` §4 ·
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

Chỗ ở của từng phần: dữ kiện quán ở `master_plan/shop-facts.md` §5.4 (ADR-001 không đổi); hành vi
sản phẩm ở `docs/product.md` §3.4, do **BA-12** viết; câu hỏi chưa ai trả lời ở *Unknowns*
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
  §4–§8 của `docs/product.md` còn trống). Nhận cấu trúc trước là để tầng dưới quyết thay tầng
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
- **Trục này làm nặng thêm mọi lát cắt viết sau nó.** BA-07 (vòng đời) và BA-09 (MVP) đều phải trả
  lời thêm một câu. Chấp nhận vì đây là thứ quán đang làm bằng tay mỗi sáng, không phải tính năng
  thêm vào.
- **Ghi trục trước khi biết ai bấm nút nào.** U-009 chưa có lời giải, nên §3.4 sẽ mô tả được *cái
  gì phải đếm được* mà chưa mô tả được *ai đếm*. Chấp nhận: thứ tự ngược lại đòi tự đặt luật.

**Applies to:**
`master_plan/shop-facts.md` §5.4, §7.1, §7.2 (S-4) · `docs/product.md` §3.4 và *Unknowns*
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

Đặc tả đầy đủ ở `docs/architecture.md`. ADR này **không** chốt tên bảng, tên cột hay endpoint.

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
- *Giữ nút `Xong` ở màn trạm như `master_plan/prompt-fullstack.md` §3.6, §3.7 đang viết.* Đây là
  thiết kế **đang có** trong repo, và bị loại vì chủ quán đã bỏ nó ngày 2026-08-31. Giữ lại nghĩa
  là làm ra một nút không ai bấm, rồi mọi con số phía sau nó đứng im. Mâu thuẫn ghi ở
  `work/findings.md` **F-013**, việc sửa là **T-031**.
- *Cho bếp bấm, nhưng "không bắt buộc".* Tệ hơn cả hai đường: con số vừa có vừa không, và không ai
  biết một bàn chưa có món là do bếp chưa làm hay do bếp quên bấm.
- *Ba ứng dụng riêng, mỗi mặt một cơ sở dữ liệu, đồng bộ với nhau.* Bốn luật cắt ngang ở trên biến
  thành bốn bài toán đồng bộ — cho một quán một địa điểm, chỉ vài bàn (số bàn ở
  `master_plan/shop-facts.md` §1, đừng chép về đây).
- *Gán quyền huỷ theo `role=quay`.* Rẻ nhất và sai luật: chủ quán có `role=owner` sẽ huỷ được từ
  bất kỳ đâu, đúng thứ §6.13 cấm — *"chức vụ không mở thêm cửa nào"*.
- *Chờ BA-12 xong rồi mới viết `docs/architecture.md`.* Loại vì chủ repo yêu cầu mặt admin ngay
  (2026-08-31), và phần lớn đặc tả **derive được** từ dữ kiện đã chốt. Chỗ nào chưa chốt thì tài
  liệu nêu đích danh là đang treo (§11 của nó) thay vì tự quyết.

**Rủi ro đã chấp nhận:**
- **`docs/architecture.md` viết trước khi `docs/product.md` §3.4 (BA-12) tồn tại.** Nếu BA-12 mô
  tả trục sản xuất khác đi, tài liệu kiến trúc phải sửa theo — nghiệp vụ vẫn là tầng trên. Đã hạ
  giá bằng cách không chốt lược đồ dữ liệu: §8 của nó chỉ **kể tên chỗ thiếu**, không đặt tên bảng.
- **"Chỉ POS ghi" dồn việc vào một người.** Người đứng quầy vừa duyệt, vừa thu tiền, vừa cập nhật
  đã phục vụ. Đó là lựa chọn của chủ quán, và nó đúng với chỗ đứng: quầy là nơi nhìn thấy cả bàn
  lẫn bếp. Rủi ro thật là lúc đông khách; chưa có dữ liệu thật để nói nó nặng tới đâu.
- **Khái niệm "đang trực trạm nào" chưa có trong 16 bảng.** Ghi ở `docs/architecture.md` §8 làm
  chỗ thiếu đã biết, không tự thiết kế quanh nó.
- **Ba câu còn mở (U-006, U-012, S-4) chạm thẳng vào mặt admin.** Tài liệu nêu đích danh và viết
  phần liên quan theo phương án hẹp nhất.
  *Cập nhật 2026-08-31 (T-033): U-006 và U-012 đã đóng, S-4 đã hỏi một lần và hỏng — chủ quán trả
  lời "tôi không hiểu", câu kiểm chứng mới ở `master_plan/shop-facts.md` §7.2. Rủi ro này giảm
  xuống còn một mục, và cách xử vẫn nguyên: phần liên quan viết theo phương án hẹp nhất.*

**Applies to:**
`docs/architecture.md` (toàn bộ) · `master_plan/shop-facts.md` §5.4, §6.13, §6.14, §6.15 ·
`master_plan/prompt-fullstack.md` §3.5, §3.6, §3.7 (ba chỗ phải sửa — T-031) ·
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
không nói gì về phần đời sau của nó. `docs/architecture.md` khi viết xong (T-029) rải nợ ở sáu
chỗ — §1.1, §4, §6.4, §7, §8, §11 — nhưng không có mục nào của riêng nó.

**Quyết định.**
Nợ được đối xử như một **phần riêng của hệ thống**, có mục riêng ở **FE**, **BE** và **DB**, đặc
tả ở `docs/architecture.md` §12. Không thêm hai ô *"ai nợ / bao nhiêu"* vào phiên bàn rồi coi là
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
- **Nợ là đường tiền thứ tư** (`docs/architecture.md` §7), cùng họ với duyệt · huỷ · hoàn. Ba việc
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
- `docs/architecture.md` có **§12** mới; mục *Đọc gì tiếp* dời thành §13.
- §12.3 **cố ý vượt ranh giới §8** (*không đặt tên bảng, tên cột*) cho riêng phần nợ, theo yêu cầu
  thẳng của chủ repo. Nó là **đề xuất gửi sang pha 2**, không phải lược đồ đã chốt.
- Một chỗ **suy ra, chưa phải lời chủ quán**: người bấm *thu nợ* là người đang trực `quay`, suy từ
  §4 và §3.3. Chủ quán nói khác thì sửa §12.2 và §12.4 trước tiên.
- **U-012 chưa đóng.** Vế *"ghi ở đâu"* xong; *"ai ghi nhận"* và *"doanh thu ngày nào"* còn mở.

*Cập nhật 2026-08-31 (T-033) — sửa tiến, không viết lại hai dòng trên (ADR-008):* chủ quán đã đóng
nốt **U-012** trong cùng ngày. **Ai ghi nhận: POS** — trùng đúng chỗ suy ra ở dòng trước, nên §12.2
không phải sửa và chỗ ấy hết là suy luận. **Doanh thu tính ngày GHI NỢ**, không phải ngày thu tiền;
hệ quả là đối soát lệch ở **hai** ngày ngược chiều nhau và `docs/architecture.md` §6.4 nay mang
công thức đủ bốn dòng. Chi tiết ở `master_plan/shop-facts.md` §6.14.

**Ảnh hưởng tới:** `docs/architecture.md` §8, §11, §12, §13 · `docs/product.md` §3.1.6 và
*Unknowns* U-012 · `quality/invariants.md` I-005 · `master_plan/shop-facts.md` §6.14 (chỉ đọc).

