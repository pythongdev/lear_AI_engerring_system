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
