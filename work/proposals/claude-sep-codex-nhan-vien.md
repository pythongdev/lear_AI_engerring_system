# Claude làm sếp, Codex làm nhân viên — cách phối hợp từng bước

> **ĐÃ ÁP DỤNG 2026-09-27 (T-100, ADR-054) — FILE NÀY KHÔNG SỞ HỮU GÌ.** Luật sống ở `CLAUDE.md`
> §7.4 *Roles* và `AGENTS.md`; quy trình, lệnh và mẫu phiếu ở `docs/prompt-guideline.md` §6.1.
> Hai bên lệch nhau thì owner thắng. Phần dưới là bản đề xuất gốc, giữ làm bằng chứng.
>
> - **Là gì:** đề xuất cách chia vai giữa Claude Code và Codex trong repo này, viết theo yêu cầu
>   của chủ repo ngày **2026-09-27** (*"claude sẽ là người làm những việc quan trọng là sếp và codex
>   sẽ là nhân viên … làm file .md để tôi đọc sau đó"*). Người viết: Claude Code (Opus 5.5).
> - **Đang có gì rồi:** `CLAUDE.md` §7.4 và `docs/decisions.md` ADR-052 đã chốt *hai công cụ dùng
>   chung luật, mỗi worktree một người sửa*, nhưng **chưa chia vai** — chưa nói ai quyết, ai làm,
>   ai duyệt. File này lấp đúng chỗ đó.
> - **Trái `CLAUDE.md` §2 ở chỗ nào:** không chỗ nào. Nó thêm luật, không đổi owner. Luật chung
>   vẫn ở `CLAUDE.md`; trạng thái task vẫn chỉ ở `work/backlog.md`.
> - **Muốn áp dụng:** mở một task trong `work/backlog.md`; task ấy sửa `CLAUDE.md` §7.4 và
>   `AGENTS.md`, và viết một ADR nối tiếp ADR-052. Đừng làm theo file này khi chưa có task đó.
>   Các lệnh `codex exec` bên dưới đã đối chiếu với `codex exec --help` của **codex-cli 0.157.0**
>   ngày 2026-09-27; bản khác có thể đổi cờ.

---

## 1. Ý tưởng trong một đoạn

Claude giữ mọi thứ mà **sai thì tốn tiền hoặc sai sự thật nghiệp vụ**: chọn việc, chấm mức rủi ro
(L0–L3), viết tiêu chí nghiệm thu, khoanh phạm vi, thiết kế, hỏi chủ quán, ghi ADR, duyệt kết quả,
và viết khối commit. Codex làm phần **thi công**: sửa file trong phạm vi đã khoanh, chạy gate, báo
cáo có bằng chứng. Codex không bao giờ tự quyết một câu hỏi nghiệp vụ, không tự sửa trạng thái task,
và không commit. Claude giao việc cho Codex bằng một **phiếu giao việc** và gọi Codex trực tiếp từ
terminal (`codex exec`), để Codex chạy trong một **worktree riêng** — nên hai bên không bao giờ sửa
chung một cây thư mục (đúng luật *một worktree một người sửa* của §7.4).

Lý do chia như vậy: repo này đã chứng minh nhiều lần rằng lỗi đắt nhất không phải code sai mà là
**sự thật bị bịa** (F-003, F-004) và **commit mang nhầm nội dung** (F-009, F-025, F-031). Hai loại
lỗi đó nằm ở khâu *quyết định* và *bàn giao*, nên người giữ khâu đó phải là một người duy nhất, có
đủ ngữ cảnh và có hook tự động (Claude có `SessionStart`/`Stop`, Codex thì không). Phần thi công
thì lỗi của nó bị gate và bước duyệt bắt được, nên giao đi được.

## 2. Bảng chia vai

| Việc | Claude (sếp) | Codex (nhân viên) |
|---|:--:|:--:|
| Đọc brief, chọn task, chuyển *In Progress* / *Done* trong `work/backlog.md` | ✓ | — |
| Chấm mức L0–L3, viết *Acceptance*, khai `work/scope.txt` | ✓ | — |
| Thiết kế (L2+), viết ADR, ghi `U-XXX`, sửa `shop-facts.md`, `invariants.md` | ✓ | — |
| Viết phiếu giao việc | ✓ | — |
| Sửa file trong phạm vi, viết test, chạy `./scripts/gate.sh` | khi cần | ✓ |
| Báo cáo: file đã đổi, output gate, Acceptance → bằng chứng, câu hỏi còn mở | — | ✓ |
| Duyệt diff theo `quality/review-gate.md`, **tự chạy lại gate** | ✓ | — |
| Đưa thay đổi về nhánh làm việc, ghi bàn giao vào entry task | ✓ | — |
| Viết khối commit (§6.1) | ✓ | — |
| `git commit` | chủ repo | chủ repo |

Hàng cuối không đổi so với hôm nay: commit vẫn là quyết định của chủ repo (§6, ADR-004).

## 3. Việc nào giao được, việc nào không

Chia theo mức rủi ro, vì đó là cách repo này đã chia mọi thứ khác (`README.md`, `CLAUDE.md` §3).

- **L0** (typo, đổi tên máy móc, format): giao thẳng cho Codex, Claude chỉ đọc diff.
- **L1** (đổi hành vi nhỏ, script, test): Claude viết Acceptance + scope, Codex làm, Claude duyệt.
- **L2** (chạm tiền, dữ liệu lưu, hợp đồng): Claude thiết kế và **viết test hồi quy cho invariant
  trước**, Codex làm cho test xanh, Claude duyệt và tự chạy test đó.
- **L3**: Claude duyệt thiết kế và tách thành các lát L1/L2; Codex nhận **từng lát**, không nhận
  cả task.
- **Không bao giờ giao:** bất cứ việc gì mà kết quả là *một sự thật nghiệp vụ* — trả lời hay đóng
  `U-XXX`, sửa `master_plan/shop-facts.md`, chốt ADR, viết nội dung `docs/product/` từ lời chủ quán.

Nói thẳng về hiện trạng: hôm nay repo phần lớn là **tài liệu** pha 1–2, nên phần giao được cho Codex
còn ít. Những việc hợp với Codex ngay bây giờ là việc có tính cơ học hoặc là script: T-084 (sửa chữ
gate in ra), T-086 (tách chi tiết việc đã xong khỏi `work/backlog.md`), các `scripts/*.test.sh`.
Từ `P2-04` trở đi, khi có file migration và code, tỉ lệ việc giao được sẽ tăng mạnh.

## 4. Chuẩn bị một lần

1. Trong clone chính: `./scripts/install-hooks.sh` (Gate 8, `CLAUDE.md` §6.2) nếu chưa chạy.
2. Kiểm Codex đã đăng nhập: `codex login status`.
3. Chọn một thư mục chứa worktree **bên ngoài** repo, ví dụ `../lean_wt/`, để các worktree không
   hiện thành file lạ trong `git status` của clone chính.
4. Không bao giờ chạy Codex với `--dangerously-bypass-approvals-and-sandbox`. Mức sandbox dùng là
   `workspace-write`: Codex chỉ ghi được trong worktree của nó.

## 5. Quy trình từng bước

### Bước 1 — Claude chọn việc và khoanh việc

Claude chạy brief (tự động bằng hook), lấy task đầu tiên ở *Ready*, chuyển sang *In Progress*, chấm
mức, viết Acceptance vào entry task, và soạn danh sách scope. Đây là toàn bộ phần *self-discipline*
của bảng §3 — chính là phần Claude giữ.

**Điều kiện trước khi giao:** worktree mới được tạo từ `HEAD`, nên nó **không thấy thay đổi chưa
commit** của clone chính. Nếu task dựa vào một thay đổi chưa commit, hãy nhờ chủ repo commit trước,
hoặc đừng giao task đó.

### Bước 2 — Claude tạo worktree cho Codex

```bash
git worktree add ../lean_wt/T-XXX -b codex/T-XXX
```

Rồi Claude ghi scope **vào worktree đó** (`../lean_wt/T-XXX/work/scope.txt`), vì Gate 3 của Codex
đọc scope trong cây của chính nó. Scope luôn kèm các dòng cấm để Gate 3 bắt nếu Codex lỡ tay:

```text
scripts/gate.sh
scripts/gate.test.sh
!work/backlog.md
!docs/decisions.md
!docs/product/99-unknowns.md
!master_plan/
!quality/invariants.md
!CLAUDE.md
```

### Bước 3 — Claude viết phiếu giao việc

Phiếu là một file tạm (trong scratchpad của phiên, **không** lưu vào repo — `CLAUDE.md` §3.8 cấm
tài liệu nghi thức). Mẫu ở §7 bên dưới. Phiếu phải tự đủ: Codex bắt đầu nguội, không biết gì ngoài
phiếu và repo.

### Bước 4 — Claude gọi Codex

```bash
codex exec \
  -C ../lean_wt/T-XXX \
  -s workspace-write \
  -o <scratchpad>/T-XXX-bao-cao.md \
  - < <scratchpad>/T-XXX-phieu.md
```

- `-C` đặt Codex vào worktree riêng; `-s workspace-write` giới hạn chỗ nó được ghi;
  `-o` ghi tin nhắn cuối (bản báo cáo) ra file để Claude đọc; `-` đọc phiếu từ stdin.
- Claude chạy lệnh này ở chế độ nền và được báo lại khi Codex xong, nên trong lúc đó chủ repo vẫn
  nói chuyện được với Claude.
- Chủ repo cũng có thể tự dán phiếu vào Codex (app hoặc `codex` tương tác) nếu muốn xem nó làm —
  quy trình phía sau giữ nguyên.

### Bước 5 — Codex làm

Codex đọc `AGENTS.md` → `CLAUDE.md`, chạy `./scripts/brief.sh`, đọc đúng những owner phiếu chỉ ra,
sửa trong phạm vi, chạy `./scripts/gate.sh` cho tới khi xanh, rồi viết báo cáo theo khuôn ở phiếu.
Gặp câu hỏi nghiệp vụ thì **dừng phần đó**, ghi câu hỏi vào báo cáo, và làm tiếp phần không phụ
thuộc vào nó. Codex không commit, không sửa backlog.

### Bước 6 — Claude duyệt

Báo cáo của Codex là lời khai, không phải bằng chứng (`CLAUDE.md` §5: *"I tested it" is not
evidence*). Claude làm bốn việc:

1. Đọc báo cáo, rồi đọc **diff thật**: `git -C ../lean_wt/T-XXX diff` và
   `git -C ../lean_wt/T-XXX status --short` (để thấy cả file mới).
2. **Tự chạy lại** `./scripts/gate.sh` trong worktree đó.
3. Đối chiếu từng dòng Acceptance với bằng chứng (Gate 2) và dò bảng red flag (Gate 4) trong
   `quality/review-gate.md`.
4. Kiểm Codex có tự quyết điều gì mà lẽ ra phải hỏi không — đây là lỗi mà gate không bắt được.

Nếu chưa đạt, Claude gửi lại **đúng từng lỗi, có vị trí và bằng chứng**:

```bash
codex exec resume --last -C ../lean_wt/T-XXX "Sửa 2 điểm: (1) scripts/gate.sh:41 ... (2) ..."
```

Tối đa **hai vòng sửa**. Sang vòng thứ ba thì vấn đề thường nằm ở phiếu, không ở Codex: Claude tự
sửa nốt, hoặc viết lại phiếu và giao lại từ đầu.

### Bước 7 — Claude đưa thay đổi về và bàn giao

```bash
git -C ../lean_wt/T-XXX add -N .          # để diff thấy cả file mới
git -C ../lean_wt/T-XXX diff > <scratchpad>/T-XXX.patch
git apply <scratchpad>/T-XXX.patch        # trong clone chính
./scripts/gate.sh                         # chạy lại ở clone chính
git worktree remove ../lean_wt/T-XXX && git branch -D codex/T-XXX
```

Sau đó Claude làm phần bàn giao của §7.3 và §7.4: ghi vào entry task *người thực hiện: Codex,
người duyệt: Claude*, file đã đổi, lệnh đã chạy và kết quả; chuyển task sang *Done*; xoá scope;
và viết khối commit §6.1 cho chủ repo dán. Gate 7/7b chạy ở đây vì đây là lượt của Claude — tức là
khâu bàn giao **có** kiểm tự động, dù Codex là người viết code.

### Bước 8 — Học từ lỗi

Codex mắc **cùng một lỗi hai lần** (ví dụ đọc thiếu owner, quên file mới) thì đó là finding
`F-XXX` trong `work/findings.md`, và cách chữa là thêm một dòng vào mẫu phiếu hoặc vào `AGENTS.md` —
đúng *Vòng phản hồi* của `quality/review-gate.md`. Lỗi một lần thì chỉ sửa, không ghi.

## 6. Chạy nhiều Codex song song

Được, nếu giữ ba điều: **mỗi Codex một task, một worktree, một nhánh**; các task không chạm chung
file (so hai danh sách scope trước khi giao); và **chỉ Claude** đưa thay đổi về clone chính, từng
task một, chạy gate sau mỗi lần. Đây chính là vai *integrator* mà §7.4 đòi phải có tên. F-025 (phiên
song song commit lẫn thay đổi của nhau) không xảy ra được ở đây vì Codex không commit và mỗi Codex
ngồi trong cây riêng.

## 7. Mẫu phiếu giao việc

```markdown
# Phiếu giao việc — T-XXX (mức L1)

Bạn là người thi công. Người quyết định là Claude; bạn không quyết thay.

## Bắt đầu
1. Đọc AGENTS.md rồi CLAUDE.md. Chạy ./scripts/brief.sh.
2. Chỉ đọc thêm: <danh sách owner/file cần đọc, có đường dẫn>.

## Việc cần làm
<mục tiêu trong 2–4 câu; vì sao cần>

## Acceptance (mỗi dòng phải có bằng chứng trong báo cáo)
- [ ] ...
- [ ] ./scripts/gate.sh xanh

## Phạm vi
Đã khai trong work/scope.txt. Chỉ sửa file khớp scope. Cần thêm file thì DỪNG và ghi vào báo cáo,
không tự mở rộng scope.

## Cấm
- Không commit, không sửa work/backlog.md, docs/decisions.md, docs/product/99-unknowns.md,
  master_plan/, quality/invariants.md, CLAUDE.md.
- Không bịa luật nghiệp vụ. Chỗ nào chưa rõ: để nguyên hành vi, ghi câu hỏi vào báo cáo.
- Không git add -A, không xoá file ngoài scope.

## Báo cáo (tin nhắn cuối cùng của bạn, đúng khuôn này)
1. File đã đổi / tạo (lấy từ `git status --short`, không nhớ lại).
2. Output cuối của ./scripts/gate.sh, dán nguyên.
3. Bảng Acceptance → bằng chứng (tên test hoặc lệnh + output).
4. Câu hỏi còn mở / điều bạn đã phải giả định.
5. Việc chưa xong.
```

## 8. Rủi ro và giới hạn

- **Codex không có hook.** Brief và gate phụ thuộc vào việc Codex làm đúng phiếu. Bù lại bằng
  Bước 6: Claude luôn tự chạy lại gate và đọc diff thật.
- **Phiếu dở thì việc dở.** Phần lớn lỗi của nhân viên sẽ truy về một phiếu thiếu ngữ cảnh. Viết
  phiếu là việc quan trọng nhất của sếp trong quy trình này.
- **Tốn hai lần đọc ngữ cảnh.** Với việc nhỏ hơn khoảng mười phút, Claude tự làm thường rẻ hơn
  viết phiếu. Giao việc có lời khi việc dài, lặp lại, hoặc chạy song song được.
- **Worktree không thấy thay đổi chưa commit** (Bước 1). Quên điều này, Codex sẽ làm trên một
  phiên bản cũ của repo.
- **Cờ CLI có thể đổi** giữa các bản Codex; kiểm lại bằng `codex exec --help` trước khi áp dụng.
