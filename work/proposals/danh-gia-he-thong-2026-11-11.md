# Đánh giá hệ thống và đề xuất theo bước — 2026-11-11

> **ĐỀ XUẤT — CHƯA ÁP DỤNG. FILE NÀY KHÔNG SỞ HỮU GÌ.**
>
> - **Là gì:** bản đánh giá cách repo này vận hành (luật, brief, gate, backlog, git) và chín bước
>   đề xuất để nó chạy hiệu quả hơn. Viết theo yêu cầu của chủ repo ngày **2026-11-11**. Người
>   viết: Claude Code (Fable 5.2).
> - **Đánh giá cái gì, không đánh giá cái gì:** chỉ đánh giá *hệ điều hành làm việc* — không xét
>   chất lượng code `be/` · `fe/`, không xét quyết định nghiệp vụ nào.
> - **Số trong file này là số đo ngày 2026-11-11** trên nhánh `P4A-01` ở `4797b23`, bằng lệnh ghi
>   ở §7. Chúng sẽ cũ đi; đo lại trước khi dùng. Chỗ nào là suy luận của người viết thì ghi rõ
>   là suy luận.
> - **Trái `CLAUDE.md` ở chỗ nào:** chỉ **Bước 7** đụng tới `CLAUDE.md` §6 (*never commit directly
>   to `main`*). Các bước còn lại sửa script hoặc dọn dẹp, không đổi owner nào của §2.
> - **Muốn áp dụng:** mỗi bước là một task riêng trong `work/backlog.md`. Đừng làm theo file này
>   khi chưa có task đó. Lệnh xoá ở Bước 1 do **chủ repo** chạy (`CLAUDE.md` §6, *Quyền chạy lệnh*).

---

## 1. Kết luận trong một đoạn

Phần **chặn lỗi** của hệ thống rất mạnh: mười cổng có test riêng, mỗi dữ kiện một chủ, findings
được đóng thật. Phần **dọn dẹp** thì gần như không có: thứ gì cần *xoá* hay *chuyển chỗ* sau khi
một task xong đều tồn lại, vì bước dọn rơi vào lúc sau commit — lúc không phiên nào đang chạy —
và từ 2026-10-26 các phiên còn không được phép xoá. Sau hai tháng rưỡi, lớp tồn đọng ấy đã làm
hỏng ngược lại ba cơ chế chính: **Gate 3 gần như không còn chặn gì**, **brief không còn tới được
phiên Claude**, và **mục In Progress không còn nói việc nào đang làm**. Việc đáng làm nhất không
phải thêm luật, mà là dọn một lần rồi cho máy tự dọn về sau.

## 2. Điểm mạnh nên giữ nguyên

Bảng owner ở `CLAUDE.md` §2 làm đúng việc của nó: lượt đo này không thấy hai file nào cùng nhận
một dữ kiện. Các cổng chỉ đọc file (1b–1h) chạy nhanh và nói bằng số — 70 bảng khớp 70 bảng,
149 đường gọi khớp 149, 123 cửa ghi khớp 123 dòng ma trận quyền. Mỗi cổng có file test riêng
(18 file `scripts/*.test.sh`). Vòng findings chạy thật: 79 mục, chỉ 3 còn mở. Câu hỏi nghiệp vụ
được giữ gọn: 7 câu đang mở. Chia vai Claude dẫn, Codex thi công trong worktree riêng, và hai
hook git (subject, scope của index) là đúng chỗ để đặt kỷ luật. Không bước nào dưới đây đổi
những thứ này.

## 3. Số đo

| Thứ được đo | Số đo 2026-11-11 | Luật nói gì |
|---|---|---|
| File scope trong `work/scope/` | 244, trong đó **221** không thuộc việc nào còn mở | xoá sau khi task commit (§3.4) |
| Gate 3 với 13 đường dẫn giả | **12/13 được cho qua** — chỉ `README.md` bị coi là ngoài scope | chặn file task không được phép sửa |
| Kích thước brief | 141 011 byte, 2 892 dòng; **93 %** là mục scope | "points, never copies" (§7.1) |
| Phần brief tới được phiên Claude | **khoảng 2 KB đầu** (hook cắt, phần còn lại ghi ra file) | đẩy trạng thái hôm nay vào mọi phiên (ADR-002) |
| ADR mới nhất theo brief | ADR-126 — thật ra là **ADR-142** | — |
| Mục In Progress | 37 dòng: 14 đã xong và đã commit, **23 còn mở** | một việc một lúc (§3.2) |
| Việc mở chưa có commit nào mang mã | 12/23; việc mở lâu nhất từ 2026-10-21 | — |
| Mô tả dài còn trong `work/backlog.md` | 110, chỉ 23 của việc còn mở | xong thì chuyển sang archive |
| `work/backlog.md` | 685 KB, 4 357 dòng | — |
| Gate cho một lượt chỉ đổi `fe/` | **231 giây** (be, db được bỏ qua) | Stop hook đặt hạn **180 giây** |
| Nhánh `main` | đứng ở 2026-08-30; nhánh đang làm đi trước **516 commit** | làm trên nhánh tách từ `main` (§6) |
| Worktree phụ | 116 (113 đã nằm trong nhánh hiện tại); `../lean_wt` chiếm **26 GB** | — |
| Nhánh local | 102, trong đó 98 đã gộp vào nhánh hiện tại | — |

## 4. Các vấn đề, xếp theo mức ảnh hưởng

### 4.1 Gate 3 không còn chặn phạm vi

Gate 3 coi một file là trong phạm vi khi **bất kỳ** file scope nào cho phép nó. Thiết kế này
đúng khi thư mục chỉ chứa scope của việc đang chạy. Nhưng 221 file cũ vẫn nằm đó, và mười sáu
file trong số ấy khai cả thư mục (`be/`, `be/internal/`, `db/`, `fe/`, `fe/src/`), còn
`docs/decisions.md`, `master_plan/shop-facts.md`, `quality/invariants.md`, `CLAUDE.md` thì có
mặt trong hàng chục file. Kết quả đo: đưa cho cổng mười ba đường dẫn bịa ra — một file Go bất
kỳ, một migration `9999`, `scripts/gate.sh`, `Makefile`, `fe/package.json` — nó cho qua mười
hai. Ảnh hưởng: cổng vẫn in `PASS … (244 scope file(s))` mỗi lượt, nên trông như đang canh,
trong khi một task L1 sửa nhầm vào migration hay vào `quality/invariants.md` sẽ không bị báo.
Gate 7b và Gate 9 chấm theo scope của **một** task nên vẫn còn tác dụng ở lúc commit, nhưng đó
là lớp cuối, sau khi việc đã làm xong.

### 4.2 Brief không tới được phiên

Mục *DECLARED SCOPE* của `scripts/brief.sh` cố ý không cắt (dòng 91: scope bị ẩn là scope không
ai tuân), và in bốn dòng cảnh báo cho mỗi file scope không thuộc In Progress. Với 244 file, mục
này dài 131 KB. Claude Code không nạp một output hook lớn cỡ đó: phiên này chỉ nhận khoảng 2 KB
đầu — tức năm dòng In Progress — còn Ready, findings mở, unknowns mở, ADR mới và việc chưa
commit thì nằm trong một file mà phiên không tự mở. Codex chạy brief trực tiếp nên nhận đủ,
nhưng phải trả cho nó 141 KB ngữ cảnh mỗi lần — *suy luận của người viết:* cỡ vài chục nghìn
token, phần lớn là cảnh báo lặp. Ảnh hưởng: cơ chế trung tâm của §7 (phiên nào cũng được trao
trạng thái hôm nay) đang không chạy với Claude, và không có gì báo điều đó.

### 4.3 Brief báo sai ADR mới nhất

Dòng 202 của `scripts/brief.sh` tìm `^### ADR-`. Từ ADR-127 các ADR được viết với `## ADR-`
(16 mục), nên brief vẫn in ADR-124…126 là mới nhất trong khi file đã tới ADR-142. Ảnh hưởng:
một phiên mới tin brief sẽ không biết mười sáu quyết định gần nhất tồn tại, kể cả ADR-142 của
việc đang làm.

### 4.4 In Progress không còn nghĩa là đang làm

Mục này có 37 dòng. Mười bốn dòng là việc đã xong **và đã commit** nhưng chưa được chuyển sang
Done. Trong 23 dòng còn mở, mười hai việc chưa có commit nào mang mã của nó, và nhiều việc được
giao từ 24–31 tháng 10. Trong khi đó mục Ready chỉ có một dòng, và dòng ấy ghi *đang chờ, không
nhặt*. Nghĩa là In Progress đang được dùng làm hàng đợi. Ảnh hưởng: luật *một việc một lúc*
không kiểm được, brief lúc nào cũng in "a task is open" nên câu ấy thành tiếng ồn, và không ai
— kể cả chủ repo — nhìn vào mà biết việc nào thật sự đang dở.

### 4.5 Gate chậm hơn hạn của hook

Chạy tay `./scripts/gate.sh` trên cây hiện tại (chỉ có thay đổi ở `fe/` và tài liệu) mất 231
giây, trong khi Stop hook đặt hạn 180 giây. *Suy luận của người viết, chưa kiểm trong repo
này:* hook quá hạn thì bị cắt và lượt kết thúc mà không có phán quyết của gate. Nếu đúng, mọi
lượt đổi `fe/` đang kết thúc không qua gate, và lượt đổi `be/` hay database còn dài hơn. Gate
cũng không in thời gian từng cổng, nên chưa biết 231 giây nằm ở `next build`, ở 784 test FE,
hay ở 18 file test của chính các script (vốn chạy lại mỗi lượt dù không script nào đổi).

### 4.6 `main` đã chết, nhánh `P4A-01` là thân cây

`main` dừng ở 2026-08-30. Toàn bộ 516 commit sau đó nằm trên một nhánh mang tên một task FE
admin, và chủ repo commit thẳng lên nhánh ấy. Luật *không commit thẳng lên `main`* vì thế đúng
trên giấy mà không bảo vệ gì. Ảnh hưởng thật là ở chỗ khác: nhánh và worktree của từng task
không bao giờ được gộp-rồi-xoá theo một nhịp nào, nên còn 116 worktree và 26 GB trên đĩa; ai
clone repo sẽ nhận một `main` cũ hai tháng rưỡi.

### 4.7 Tài liệu chung quá nặng và là điểm nghẽn

`work/backlog.md` nằm trong 191 trên 244 file scope — gần như task nào cũng sửa nó — và nặng
685 KB vì 87 mô tả dài của việc đã xong chưa được chuyển đi (37 mô tả còn nằm lạc dưới mục
*Task Detail Template*). Đây là file mà hai phiên song song dễ giẫm lên nhau nhất, và là lý do
§6.1 phải có thủ tục tách file theo blob. Cùng họ: bảng mục lục viết tay của `work/findings.md`
tự ghi là thiếu từ F-060; `README.md` vẫn vẽ cây thư mục cũ, có `docs/architecture.md` không
tồn tại; `docs/decisions.md` nặng 862 KB, trung bình 5,6 KB mỗi ADR, có mục 26 KB.

### 4.8 Test chập chờn lặp lại

Sáu finding (F-045, F-051, F-063, F-072, F-076, F-078) cùng một hình: gate đỏ rồi chạy lại thì
xanh, vì hai phiên dùng chung database hoặc chung cây làm việc, vì thứ tự gói test, hoặc vì giờ
trong ngày. F-078 còn mở. Mỗi lần như vậy dạy người và máy rằng "đỏ thì chạy lại", đúng thói
quen làm một cổng mất giá trị. *Người viết chưa đọc code test, chỉ đọc tiêu đề finding.*

## 5. Nguyên nhân gốc chung

Ba điều, theo thứ tự quan trọng. **Một:** hệ thống có nhiều cơ chế để *thêm* (luật, cổng, ADR,
scope, worktree) và không có cơ chế nào để *bớt*; mọi việc dọn đều là *self-discipline*, đúng
loại mà `CLAUDE.md` §3 tự nói là bị bỏ đầu tiên. **Hai:** việc dọn được hẹn vào "sau khi
commit", nhưng commit do chủ repo gõ ngoài mọi phiên, nên không phiên nào đứng ở đó để dọn; từ
2026-10-26 phiên còn bị cấm `rm`, nên dù nhớ cũng không làm được. **Ba:** các danh sách không
có trần — không trần số việc In Progress, không trần kích thước brief — nên chúng lớn dần cho
tới khi vượt giới hạn của công cụ đọc chúng.

## 6. Đề xuất theo bước

Thứ tự dưới đây là thứ tự nên làm: bước trước làm cho bước sau rẻ hơn. Ba bước đầu trả lại
ngay các cơ chế đang hỏng; các bước sau giữ cho chúng không hỏng lại.

### Bước 1 — Dọn tồn đọng một lần (chủ repo, khoảng 30 phút, L0)

Xoá 221 file scope cũ, gỡ worktree và nhánh đã gộp, xoá file rác (`work/backlog.md.bak`,
thư mục rỗng `work/work/`, `master_plan/to_do_list.md` rỗng). Chỉ riêng việc xoá scope đã trả
lại Gate 3 và đưa brief về vài KB. Lệnh liệt kê trước, xoá sau:

```bash
# 1a. File scope không thuộc việc nào còn mở ở In Progress — CHỈ IN
open=$(awk '/^## In Progress/{f=1;next} /^## /{f=0} f && /^- \[ \]/{print $4}' work/backlog.md)
for f in work/scope/*.txt; do
  id=$(basename "$f" .txt); echo "$open" | grep -qx "$id" || echo "$f"
done > /tmp/scope-cu.txt
wc -l /tmp/scope-cu.txt            # lượt đo 2026-11-11: 221
# đọc danh sách; việc nào đã Done mà CHƯA commit thì bỏ dòng của nó ra, rồi:
xargs rm < /tmp/scope-cu.txt

# 1b. Worktree: gỡ mục đã mất thư mục, rồi xem cái nào đã nằm trong nhánh hiện tại
git worktree prune -v
git worktree list
git branch --merged HEAD           # nhánh đã gộp, xoá được bằng git branch -d
```

Lưu ý cho 1b: Codex không commit, nên worktree của nó thường còn thay đổi chưa commit (88 trên
113 cái ở lượt đo) dù nội dung đã được tích hợp sang cây chính. `git worktree remove` sẽ từ
chối những cái ấy; chỉ thêm `--force` cho worktree của task đã Done và đã commit. Giữ lại
worktree của việc đang mở (hiện là `T-315` và `T-315-tich-hop`).

**Biết đã xong khi:** `./scripts/brief.sh | wc -c` dưới 10 000, và phép thử ở §7 dòng Gate 3
báo phần lớn đường dẫn giả là ngoài scope.

### Bước 2 — Sửa ba lỗi của brief (L1, sửa `scripts/brief.sh` và test của nó)

Thứ nhất, mục scope chỉ in pattern của việc đang mở; scope mồ côi gộp thành **một** dòng gồm
số lượng và danh sách mã. Thứ hai, tìm ADR bằng `^#{2,3} ADR-` và lấy theo số lớn nhất. Thứ
ba, thêm một trần tổng: `scripts/brief.test.sh` đỏ khi brief dài quá ngưỡng mà hook còn nạp
được, để lần sau brief phình thì máy báo chứ không im lặng mất. Nên in việc còn mở trước việc
đã tick trong In Progress.

**Biết đã xong khi:** phiên Claude mới thấy đủ các mục tới *UNCOMMITTED* ngay trong ngữ cảnh,
và *LATEST DECISIONS* in đúng ba ADR có số lớn nhất.

### Bước 3 — Cho Gate 3 chỉ đọc scope của việc đang mở (L1, `scripts/check-scope.sh`)

Hợp các scope chỉ lấy từ file có mã đang nằm ở In Progress; file scope khác bị bỏ qua và được
đếm trong một dòng `NOTE`. Như vậy dù việc dọn có trễ, cổng vẫn không bị pha loãng. Bước này
cần Bước 5 đi kèm, nếu không 23 việc mở vẫn là một hợp quá rộng.

**Biết đã xong khi:** có test trong `scripts/check-scope.test.sh` dựng một scope mồ côi khai
`be/` và chứng minh nó không cứu được một file `be/` ngoài scope của việc đang mở.

### Bước 4 — Để git tự dọn sau commit (L1, thêm `scripts/hooks/post-commit`)

Hook chạy trong lệnh `git commit` của chủ repo, nên việc xoá do chủ repo làm, không trái luật
quyền chạy lệnh. Khi subject mở đầu bằng một mã và dòng của mã ấy trong `work/backlog.md` đã
tick `[x]`, hook xoá `work/scope/<MÃ>.txt` và in một dòng báo. Điều kiện `[x]` là để task nhiều
commit (ví dụ CHAT-17, hai lát) không mất scope giữa chừng. Kèm theo là một script
`scripts/archive-done.sh` làm phép chuyển cơ học mà hiện giờ phải làm tay trên file 685 KB:
dòng đã tick và đã có commit rời In Progress sang Done, mô tả dài chuyển nguyên khối sang
`work/backlog_archive.md`. Brief in một dòng khi có việc chờ script này.

**Biết đã xong khi:** sau một commit thử, file scope của task biến mất mà không phiên nào phải
nhớ; chạy script một lần đưa `work/backlog.md` từ 685 KB xuống khoảng 300 KB
(ước lượng của người viết: 23 mô tả còn mở cộng danh sách Done 149 KB).

### Bước 5 — Đặt trần cho việc dở dang (chủ repo quyết, rồi L1)

Trước hết chủ repo đi một lượt 23 việc còn mở và xếp mỗi việc vào một trong ba ô: xong rồi
(tick), chưa bắt đầu (về Ready), bỏ (ghi lý do). Đây là quyết định của chủ repo, phiên không
đoán được — nhất là mười hai việc chưa có commit. Sau đó thêm hai luật nhỏ: việc đã giao nhưng
chưa bắt đầu nằm ở Ready, không ở In Progress; và brief cảnh báo khi In Progress có quá ba
việc mở (mỗi worktree đang chạy một việc). Việc *đang chờ* như T-109 nên có một tiêu đề riêng
để *NEXT READY* thật sự là việc nhặt được.

**Biết đã xong khi:** In Progress còn không quá ba dòng mở và mỗi dòng có người đang làm.

### Bước 6 — Đo rồi mới cắt thời gian gate (L1)

Trước hết xác nhận điều suy luận ở §4.5: xem một lượt đổi `fe/` có thật sự kết thúc mà không
có phán quyết của gate hay không. Rồi cho `scripts/gate.sh` in số giây của từng cổng. Có số
rồi mới chọn: chỉ chạy các `scripts/*.test.sh` khi `scripts/` đổi; tách `next build` khỏi lượt
thường nếu nó chiếm phần lớn; hoặc nâng hạn hook. Mục tiêu là lượt thường gặp nhất xong trong
hạn hook với khoảng dư, vì cổng bị cắt giữa chừng tệ hơn cổng chậm.

**Biết đã xong khi:** gate in thời gian từng cổng, và một lượt chỉ đổi `fe/` xong trong hạn.

### Bước 7 — Cho `main` sống lại (chủ repo quyết; trái `CLAUDE.md` §6 nên cần ADR)

Đề xuất: đưa `main` lên đúng commit hiện tại và coi nó là thân cây; nhánh `codex/<MÃ>` trong
worktree là nơi thi công; chủ repo commit phần tích hợp lên `main`. Câu *never commit directly
to `main`* khi đó cần viết lại cho khớp với cách làm thật — hiện giờ nó đúng chỉ vì thân cây
mang tên khác. Kèm một nhịp dọn: task commit xong thì worktree và nhánh của nó được gỡ (có thể
để hook ở Bước 4 in sẵn lệnh).

**Biết đã xong khi:** `git log main -1` là commit của hôm đó, và số worktree xấp xỉ số việc
đang mở.

### Bước 8 — Giảm trọng lượng tài liệu chung (L0/L1, làm dần)

Sau Bước 4, chuyển tiếp danh sách Done (404 dòng, 149 KB) sang archive, giữ lại khoảng hai
chục dòng gần nhất. Bỏ bảng mục lục viết tay ở đầu `work/findings.md` — nó chép lại trạng thái
mà dòng `**Status:**` đã giữ, và đã lệch từ F-060. Sửa cây thư mục trong `README.md`. Đổi tên
hai mục gõ nhầm trong `work/proposals/` (`admin.admiadmin`, `updatee_sýstem.md`). Với ADR và
mô tả task, đề nghị một ngân sách độ dài và để gate in `NOTE` khi vượt, không chặn — chỉ thêm
khi chủ repo thấy đáng, vì §3.8 yêu cầu một vấn đề phải tốn hai lần mới thành luật.

### Bước 9 — Xử lý họ test chập chờn (L2, sau khi F-078 được đọc kỹ)

Gom sáu finding ở §4.8 thành một việc: mỗi lượt chạy test có database riêng (hoặc schema
riêng) theo worktree, và test không phụ thuộc thứ tự gói hay giờ trong ngày. Bước này cần một
phiên đọc code test trước khi viết Acceptance; bản đánh giá này chưa làm việc đó.

## 7. Cách đo lại

```bash
ls work/scope/*.txt | wc -l                                   # số file scope
./scripts/brief.sh | wc -c                                    # kích thước brief
./scripts/check-scope.sh --match be/internal/bat_ky/x.go \
  db/migrations/9999_x.sql scripts/gate.sh Makefile README.md # in ra = NGOÀI scope
grep -c '^## ADR-' docs/decisions.md                          # ADR mà brief không thấy
awk '/^## In Progress/{f=1;next} /^## /{f=0} f && /^- \[ \]/' work/backlog.md | wc -l
time ./scripts/gate.sh                                        # so với timeout ở .claude/settings.json
git rev-list --count main..HEAD; git worktree list | wc -l; git branch --merged HEAD | wc -l
```

## 8. Giới hạn của bản đánh giá này

Người viết đọc luật, script, backlog, tiêu đề findings và lịch sử git trong một phiên; không
đọc code ứng dụng, không đọc thân của từng finding hay ADR, và không phỏng vấn ai. Hai điều
ghi là suy luận (§4.2 về số token, §4.5 về hành vi khi hook quá hạn) cần kiểm trước khi dựa
vào. Con số "12 việc chưa có commit" đếm theo subject mở đầu bằng mã; việc được commit dưới
subject khác sẽ bị đếm sót.
