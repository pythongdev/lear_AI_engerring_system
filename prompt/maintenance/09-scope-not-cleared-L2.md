# 09 — `work/scope.txt` được commit kèm pattern, hai lần (L2) · T-016

## Context

- CLAUDE.md §6: *"`work/scope.txt` là working state, không phải deliverable — đừng commit
  pattern."* CLAUDE.md §7.3 bắt xoá pattern khi task xong. Cả hai đều dựa vào việc **ai đó nhớ**.
- Đã hỏng **hai lần**, đếm bằng lịch sử git tính tới 2026-08-30:

  | Commit | Ngày | Pattern bị commit |
  |---|---|---|
  | `5c41f65` "udpate shop fact" | 2026-08-30 | 6 dòng (`master_plan/shop-facts.md`, `work/findings.md`, `CLAUDE.md`, `work/scope.txt`, `master_plan/to_do_list.md`, `master_plan/00-scope.md`) |
  | `25f0f88` "sdfg" | 2026-08-30 | 8 dòng (scope của T-010, còn kèm hai dòng của T-007) |

  Kiểm chứng: `for c in $(git log --format=%H -- work/scope.txt); do git show $c:work/scope.txt |
  grep -vcE '^\s*(#|$)'; done`. Lần thứ ba được T-011 chặn lại bằng tay khi dọn cuối task
  (`2692178`), nên **HEAD hiện sạch** — sạch nhờ một người nhớ, không nhờ cơ chế nào.
- Hai chỗ hỏng khi scope cũ đi vào commit:
  - `scripts/check-scope.sh` coi **bất kỳ** pattern nào là "scope đã khai báo". Phiên sau clone về
    và sửa một file khác ⇒ Gate 3 **đỏ vì lý do sai** — đúng cái mà ADR-003 nói là *"dạy người ta
    bỏ qua gate"*. Hoặc tệ hơn: danh sách cũ tình cờ đủ rộng ⇒ gate **xanh** cho một thay đổi
    chưa ai cho phép.
  - `scripts/brief.sh` (dòng 52–59) in nguyên khối *DECLARED SCOPE* rồi kết luận
    *"→ a task is open. Finish or hand it off before starting another."* Mọi phiên mới bắt đầu
    bằng một lời nói dối về trạng thái — trong khi §7 CLAUDE.md dựng cả brief lên để chống đúng
    chuyện đó.
- **CLAUDE.md §3.8:** *"Thêm một rule, một hook, hay một test chỉ sau khi cùng một vấn đề đã tốn
  công hai lần."* Bảng trên là bằng chứng lần thứ hai. Ngưỡng đã đạt — task này **được phép** dựng
  cơ chế, và đó là lý do nó là L2 chứ không phải L1: nó đổi hành vi của thứ mọi phiên đều chạy.

## Goal

Một task kết thúc mà `work/scope.txt` còn pattern thì bị **nhìn thấy ngay**, không phụ thuộc vào
việc ai nhớ dọn.

## Scope

Được sửa:
- `scripts/gate.sh` **hoặc** `scripts/check-scope.sh` **hoặc** `scripts/brief.sh` — chọn **một**,
  và ghi lý do chọn vào ADR
- `docs/decisions.md` (ADR-004)
- `work/findings.md` (F-007)
- `work/backlog.md` (ô trạng thái T-016)
- `CLAUDE.md` §5 hoặc §7.1 — **chỉ** khi hành vi mới cần một dòng mô tả ở đó

Không được sửa:
- `.claude/settings.json` — xem *Constraints*
- `work/scope.txt` (nội dung là working state của task đang chạy)
- `master_plan/**`, `docs/product.md`, `prompt/**`, `quality/invariants.md`

Dòng chép vào `work/scope.txt`:
```text
scripts/
docs/decisions.md
work/findings.md
work/backlog.md
CLAUDE.md
work/scope.txt
```

## Constraints

- **Cảnh báo, đừng chặn.** ADR-003 đã trả giá cho bài học này: gate đỏ vì một lý do mà người dùng
  thấy là sai thì người ta học cách bỏ qua gate, và mất nhiều hơn thứ nó bắt được. Scope còn
  pattern **có thể** là task đang dở giữa chừng — hoàn toàn hợp lệ. Nên đầu ra là một dòng nhìn
  thấy được, **không** phải `exit 1`.
- **Phân biệt được hai trạng thái, nếu không thì đừng làm.** "Scope đã khai báo + có task ở *In
  Progress* trong `work/backlog.md`" là **bình thường**. "Scope đã khai báo + **không** có task nào
  ở *In Progress*" mới là chỗ hỏng. Một cảnh báo nổ ở cả hai trạng thái là tiếng ồn, và tiếng ồn
  bị lờ đi trong đúng hai ngày.
- **Không thêm git hook, không sửa `.claude/settings.json`.** `SessionStart` → `brief.sh` và
  `Stop` → `gate.sh` đã là hai chỗ mọi phiên đều chạy; thêm chỗ thứ ba là ceremony (CLAUDE.md §3.8)
  và một git hook thì không đi theo repo cho người clone.
- **Không tạo file mới.** Cơ chế phải nằm trong một script đã có. Một `.md` mới hay một script mới
  cho việc này là đúng thứ CLAUDE.md §3.8 cấm.
- **Mọi đường thoát vẫn exit 0 ở `brief.sh`** (CLAUDE.md §7.1: *"It never blocks"*). Nếu chọn
  `check-scope.sh`/`gate.sh` thì phần thêm vào không được đổi mã thoát của các nhánh đang có.
- **Không đổi định dạng `work/scope.txt`** và không đổi cách `check-scope.sh` đọc pattern — Gate 3
  đang đúng, task này không sửa nó.
- `quality/invariants.md` hiện **chưa có invariant nghiệp vụ nào** (mới có template). Nên Constraints
  ở đây trích ADR thay cho invariant: **ADR-003** (chỉ chặn cái đáng chặn) và **ADR-002** (trạng
  thái được **đẩy** vào mỗi phiên, không chờ phiên tự đọc).

## Acceptance

- Dựng lại được lần hỏng cũ: đặt vài pattern vào `work/scope.txt` **trong khi** `work/backlog.md`
  không có task nào ở *In Progress*, chạy cơ chế ⇒ có một dòng cảnh báo nêu đích danh
  `work/scope.txt` và số pattern còn lại.
- Trạng thái hợp lệ **không** kêu: cũng scope đó, nhưng `work/backlog.md` có một task ở
  *In Progress* ⇒ không có dòng cảnh báo nào.
- Scope rỗng (chỉ comment) ⇒ không có dòng cảnh báo nào, ở cả hai trạng thái backlog.
- Mã thoát: cảnh báo **không** làm gate đỏ. `./scripts/gate.sh` vẫn xanh trong cả ba ca trên khi
  không có vi phạm scope thật. `./scripts/brief.sh` vẫn exit 0 kể cả khi `work/backlog.md` bị xoá.
- `docs/decisions.md` có **ADR-004** ghi: chọn script nào, hai phương án bị loại và lý do, và vì
  sao cảnh báo chứ không chặn (dẫn ADR-003).
- `work/findings.md` có **F-007** ghi hai lần hỏng kèm mã commit và ngày, hậu quả ở
  `check-scope.sh` **và** ở `brief.sh`, và câu chốt: luật viết trong CLAUDE.md §6/§7.3 không tự thi
  hành được — đây là lần thứ hai nên mới dựng cơ chế, đúng ngưỡng §3.8.
- Nếu hành vi mới có mô tả trong `CLAUDE.md`, mô tả đó khớp với script; nếu không sửa `CLAUDE.md`
  thì nói rõ trong Report là đã cân nhắc và vì sao không cần.
- `./scripts/gate.sh` xanh.

## Verify

```bash
# ca 1 — scope còn pattern, không có task In Progress ⇒ phải kêu
printf 'docs/x.md\n' >> work/scope.txt
./scripts/brief.sh; ./scripts/gate.sh; echo "exit=$?"

# ca 2 — cũng scope đó, có task In Progress ⇒ không được kêu
#   (thêm tạm một dòng dưới '## In Progress' trong work/backlog.md, rồi hoàn nguyên)
./scripts/brief.sh

# ca 3 — scope rỗng ⇒ không được kêu
#   (xoá dòng vừa thêm khỏi work/scope.txt)
./scripts/brief.sh; ./scripts/gate.sh; echo "exit=$?"

# brief không bao giờ chặn
mv work/backlog.md /tmp/b.md && ./scripts/brief.sh; echo "exit=$?"; mv /tmp/b.md work/backlog.md

git status --porcelain    # cây làm việc trở lại đúng như trước khi thử
```
Dán **output thật** của cả ba ca vào Report — `quality/review-gate.md` Gate 2: mỗi dòng Acceptance
phải map tới một lần chạy có output, "tôi đã thử rồi" không phải bằng chứng.

## Unknowns

- Không có câu hỏi nghiệp vụ. Đây là việc của hệ thống làm việc, không chạm dữ kiện quán.
- **Không sửa lịch sử git.** Hai commit trong bảng Context ở lại nguyên trạng: chúng là bằng chứng
  đếm được của F-007, và rewrite history để dọn hai dòng text là cái giá sai.
- Việc **commit** kết quả task này do người dùng quyết (CLAUDE.md §6) — làm xong thì báo, đừng tự
  commit.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
