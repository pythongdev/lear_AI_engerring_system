# Review Gate

Cách kiểm soát chất lượng kết quả sau khi LLM chạy xong một prompt.

Nguyên tắc gốc: **LLM nói "đã xong, đã test" không phải là bằng chứng. Chỉ output
của lệnh mới là bằng chứng.** Các cổng dưới đây tồn tại để LLM không đi qua được
bằng lời nói.

Prompt và acceptance viết theo `docs/prompt-guideline.md`.

---

## Gate 0 — Trước khi chạy prompt

Acceptance phải viết **trước**, không phải sau.

Nếu không viết nổi acceptance thì vấn đề không nằm ở LLM — mà là chưa biết mình
muốn gì, và sẽ không có cách nào chấm điểm kết quả. Đây là cổng rẻ nhất và chặn
được nhiều rác nhất.

Khai báo scope vào `work/scope.txt` cùng lúc, khớp với mục Scope trong prompt.

## Gate 1 — Máy chấm

```bash
./scripts/verify.sh
```

Build, test, lint, format. Deterministic, không phụ thuộc sự chú ý của người đọc.

Đỏ = chưa xong. Không có ngoại lệ, không có "chỉ là lint thôi".

## Gate 1b — Máy chấm tài liệu

```bash
./scripts/check-links.sh
```

Mọi đường dẫn mà một tài liệu **chỉ đường** nêu ra phải mở được. Chạy ở **mọi**
lượt, kể cả lượt chỉ đổi tài liệu — đó chính là lượt Gate 1 bỏ qua, và tài liệu
là thứ repo này sản xuất (ADR-005).

Không chấm `work/` và `prompt/maintenance/`: ở đó một đường đã chết là **bằng
chứng được trích dẫn**, không phải lỗi. Đường cố ý không tồn tại thì ghi vào
`scripts/check-links.ignore` kèm chủ — và ngoại lệ ở đó **có hạn**: dòng nào
không còn khớp lỗi nào thì gate đỏ cho tới khi gỡ.

Cổng này chỉ biết đường dẫn có mở được không, không biết nó trỏ **đúng chỗ**
không — việc đó vẫn là Gate 4.

## Gate 2 — Ánh xạ Acceptance → bằng chứng

Mỗi dòng Acceptance phải chỉ ra được **cái gì chứng minh nó**:

```text
- Đơn cũ giữ nguyên tổng tiền khi giá món đổi
  → TestOrderSnapshot_PriceChange (order/pricing_test.go)
```

Dòng nào không có test hoặc kịch bản thủ công kèm output thật → coi như **chưa đạt**.

Cổng này bắt lỗi kinh điển: LLM code đúng cái nó *tưởng* mình muốn, test xanh,
nhưng không phải cái viết trong Goal.

## Gate 3 — Scope drift

```bash
./scripts/check-scope.sh
```

So file đã đổi với scope khai trong `work/scope.txt`. File ngoài scope → hỏi lại
hoặc revert phần đó.

Chỉ file **git đang theo dõi** mới làm gate đỏ. File chưa track nằm ngoài scope
được in thành dòng `note:` và không chặn — git không biết nó có từ trước task hay
do task vừa tạo (ADR-003, 2026-08-30). Dòng `note:` vì thế phải **đọc**: nếu file
trong đó là do task này tạo ra thì đó vẫn là scope drift, chỉ khác là không ai
chặn bạn.

Scope drift là lỗi số 1 của LLM và nó **không** hiện ra trong test xanh.

## Gate 4 — Đọc diff săn red flag

Không đọc kiểu "xem có hợp lý không" — mắt sẽ trôi. Săn đúng danh sách này:

| Red flag | Nghĩa là gì |
|---|---|
| Test bị sửa cùng lúc với code nó test | Có thể LLM chỉnh test cho vừa code, không phải ngược lại |
| `skip`, test bị comment, assertion bị nới lỏng | Làm cho xanh, không làm cho đúng |
| Giá trị hardcode khớp đúng fixture | Code không tổng quát, chỉ pass test |
| Nuốt lỗi (`catch {}`, bỏ qua `err`) | Giấu lỗi để chạy trót lọt |
| Dependency mới xuất hiện | Ngoài scope, gần như luôn là thừa |
| Đổi chữ ký hàm public / shape API | Đổi contract mà không khai báo |
| Code/abstraction không ai gọi đến | Xây sẵn cho tương lai tưởng tượng |
| File `.md` tự sinh không ai yêu cầu | Ceremony rỗng — trái `CLAUDE.md` |

## Gate 5 — Review theo level

| Level | Bắt buộc |
|---|---|
| L0 | Gate 1 + liếc diff |
| L1 | Gate 1–4 |
| L2 | Gate 1–4, cộng: tự tay chạy lại invariant liên quan trong `quality/invariants.md`, và kiểm tra có **regression test** cho invariant đó |
| L3 | Duyệt thiết kế **trước** khi có dòng code nào; mỗi task con lại qua Gate 1–4 |

## Gate 6 — Không tự chấm bài của mình

Session vừa viết code có bias xác nhận rất nặng — nó đã "tin" là code đúng.

Chấm bằng context lạnh: `/code-review`, hoặc session mới, chỉ đưa diff +
acceptance, không đưa lý do LLM đã tự giải thích.

---

## Gate 7 — Bàn giao nội dung commit

Người bấm commit là người dùng; người **viết** commit là phiên vừa làm. Hết mỗi
task, và hết mỗi phiên cho phần còn chưa commit, báo cáo phải kết thúc bằng một
khối `git add` + `git commit` dán chạy được ngay — luật đầy đủ ở `CLAUDE.md` §6.1.

Cổng này tự động: `scripts/check-commit-block.sh` chặn kết thúc lượt khi cây còn
thay đổi **git đang theo dõi** mà lượt đó không đưa ra khối commit nào. File chưa
track và `work/scope.txt` không kích hoạt nó, và nó chỉ hỏi **một lần cho mỗi
trạng thái cây** — đỏ vì lý do sai còn hại hơn không đỏ (ADR-003, ADR-004).

---

## Gate 8 — Subject của commit phải nói được nó là gì

Gate 7 sống trong vòng đời **một lượt của phiên**. Người gõ `git commit -m` ở
terminal không đi qua lượt nào, và năm commit đã vào repo này theo đúng đường đó
(`work/findings.md` **F-011**). Gate 8 là hook của **git** —
`scripts/hooks/commit-msg` — nên nó chấm **mọi** commit trên bản clone này, ai gõ
cũng vậy.

Luật hẹp, cố ý: bỏ tiền tố `T-XXX: ` nếu có, phần mô tả còn lại phải có ≥ 2 từ và
≥ 8 ký tự. Subject > 72 ký tự chỉ bị **nhắc**, không chặn — đỏ vì lý do sai còn
hại hơn không đỏ (ADR-003). Đường thoát `git commit --no-verify` được in ngay
trong thông báo từ chối. Hook **không** tự soạn nội dung commit (ADR-004).

Cổng này **không tự cài theo bản clone**: `.git/` không đi theo `git clone`, nên
mỗi bản clone chạy `./scripts/install-hooks.sh` một lần. `scripts/brief.sh` kêu ở
mỗi phiên khi chưa cài. Luật đầy đủ: `CLAUDE.md` §6.2, `docs/decisions.md`
**ADR-010**.

## Tự động hoá

Gate 1, Gate 1b, Gate 3 và Gate 7 chạy tự động qua Stop hook trong
`.claude/settings.json`:

```text
Stop hook → scripts/gate.sh → check-scope.sh + check-links.sh + verify.sh
                              + check-commit-block.sh
```

Hook fail sẽ chặn kết thúc lượt và trả lỗi lại cho LLM tự sửa. `verify.sh` được
bỏ qua khi chỉ có tài liệu thay đổi, và chạy mọi `scripts/*.test.sh` khi không —
`check-links.sh` thì không bao giờ bị bỏ qua (ADR-005).
`check-commit-block.sh` chỉ chạy trong hook mode — chạy tay không có transcript
để đọc. Chạy tay: `./scripts/gate.sh`.

**Gate 8 không nằm trong chuỗi này.** Nó là hook của git, không phải của Claude
Code, và chạy ở một thời điểm khác: lúc `git commit`, chứ không phải lúc kết thúc
lượt. Bật nó bằng `./scripts/install-hooks.sh` (một lần cho mỗi bản clone);
`./scripts/install-hooks.sh --check` trả lời "đã cài chưa".

Xem hoặc tắt hook bằng `/hooks`.

## Vòng phản hồi

Sai lặp lại **2 lần** → biến thành cơ chế, không nhắc bằng miệng.

Ghi vào `work/findings.md`, rồi chuyển thành một trong ba thứ: một test, một dòng
trong `verify.sh`, hoặc một hook. Nhắc lại trong prompt là giải pháp không bền —
session sau là quên.
