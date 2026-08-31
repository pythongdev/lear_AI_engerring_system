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
