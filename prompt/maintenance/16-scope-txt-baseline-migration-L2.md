# 16 — `work/scope.txt`: bản đã commit chỉ được chứa comment (L2) · T-047, đóng F-020

## Context

- `CLAUDE.md` §6 đã cấm bằng chữ: *"`work/scope.txt` is working state, not a deliverable — do not
  commit patterns."* Luật có, nhưng không cổng nào gác nó. Commit `12c77f8` (T-031, 2026-08-31) đưa
  **ba khối pattern** — của BA-04, T-027, T-031 — vào lịch sử git; ba task ấy đã Done từ hôm đó và
  chưa ai gỡ được, vì gỡ tạo ra một thay đổi *tracked* trên `work/scope.txt` — đúng cái §6 cấm và
  Gate 7b (`scripts/check-commit-block.sh`) bắt. Một phiên tuân thủ luật không có đường hợp lệ nào
  để dọn (`work/findings.md` **F-020**, đọc trọn — nhất là ba đường ở *Decision / Fix*).
- Đo lại 2026-09-07 trước khi sửa: `git show HEAD:work/scope.txt | grep -vcE '^\s*(#|$)'` → còn
  **57 dòng pattern** ở `HEAD` — nợ đã lớn hơn nhiều so với con số "13 dòng" đo lúc F-020 mở
  (2026-09-03): mọi task L1+ chạy sau đó **cũng** commit khối scope của mình mà không ai gỡ, đúng
  hình dạng F-020 mô tả, lặp lại đều đặn. Cây làm việc của phiên này đã dọn trước **mười bảy khối**
  trong số đó (`T-053` · `T-054` · `T-055` · `T-056` · hai khối trùng số `T-058` · `P1-04` · mười
  khối khác) — mỗi khối đối chiếu với `work/backlog.md` (`[x] <task>`, "Gate xanh") trước khi gỡ,
  **chưa commit**. Ba khối còn lại — BA-04, T-027, T-031 — là phần **F-020 chỉ đích danh**, cố ý
  chưa đụng: cả ba đã xác minh qua `git log -- <file>` và `work/backlog.md` (`[x] BA-04`, `[x]
  T-027`, `[x] T-031`, mỗi file có commit sau `12c77f8` mang đúng nội dung task, không còn gì treo).
  Task này gỡ nốt ba khối đó, và commit cuối cùng đưa `work/scope.txt` về **0 dòng pattern** —
  không chỉ đóng nợ của F-020 mà đóng luôn nợ đã phát sinh thêm từ 2026-09-03 tới nay, vì cùng một
  cơ chế gây ra cả hai.
- **Chủ repo đã chốt đường (2026-09-03): ĐƯỜNG 2.** `work/scope.txt` ở lại trong git như một file
  trạng-thái-làm-việc; bản **đã commit** chỉ được chứa comment; pattern là trạng thái phiên chạy,
  không bao giờ được commit; Gate 3 và Gate 7b cùng thi hành một hình bất biến duy nhất đó. Hai
  đường kia (dọn một lần / dựng `scope.txt.example`) đã bị loại — lý do đầy đủ ở F-020.

## Goal

Gate 3 chấm lại được. Sau task này, bản **đã commit** của `work/scope.txt` chỉ còn comment, và một
task xong mà quên dọn scope không còn im lặng đi qua Gate 3/Gate 7b được nữa.

## Scope

Được sửa:
- `scripts/check-scope.sh` (Gate 3) — **thêm** một phép chấm mới, không đổi cách đọc pattern hiện có
- `scripts/check-scope.test.sh` — **file mới**, chưa tồn tại
- `scripts/check-commit-block.sh` (Gate 7b) — đổi vị ngữ của luật 3
- `scripts/check-commit-block.test.sh` — thêm ca, không xoá ca cũ
- `CLAUDE.md` — §5 (mô tả Gate 3, Gate 7), §6, §6.1 (mọi câu về `work/scope.txt` đã bị đường 2 làm
  sai — grep `scope\.txt` rồi sửa từng chỗ, đừng sửa theo trí nhớ)
- `docs/decisions.md` — ADR mới (đường 2 là một quyết định thiết kế, §3 xếp L2 ⇒ phải có ADR)
- `work/backlog.md` — entry T-047 (chuyển Done) + dòng trạng thái
- `work/findings.md` — F-020 (đổi Status → Fixed, ghi lại đã đóng bằng gì)
- `work/scope.txt` — **buộc phải** nằm trong khối commit cuối cùng: xoá sạch mọi pattern (ba khối
  cũ + khối của chính T-047), đưa file về chỉ-comment. Xoá **sau khi** hai script đã sửa xong.
- `prompt/maintenance/16-scope-txt-baseline-migration-L2.md` — file này

Không được sửa:
- Cách `check-scope.sh` đọc/khớp pattern đang chạy (ADR-006: ngữ nghĩa pattern chỉ có một chủ) —
  chỉ **thêm** phép chấm baseline, không "siết" phép khớp
- `master_plan/**`, `docs/product/**`, `prompt/BA/**`, `prompt/SD/**`, `quality/invariants.md` —
  task này không đổi dữ kiện quán hay tài liệu sản phẩm
- `.claude/settings.json` — không thêm hook mới, hai cổng đã có sẵn chỗ chạy

## Constraints

Bảy điều dưới lấy nguyên từ `work/findings.md` **F-020** → *Decision / Fix*, đây là bản dịch thành
Acceptance/Constraints để làm — đọc lại F-020 nếu một câu chưa rõ.

1. **Hình bất biến duy nhất, viết thành luật chứ không phải dặn dò:** *"Bản đã commit của
   `work/scope.txt` chỉ chứa comment. Pattern là trạng thái của phiên đang chạy, không bao giờ đi
   vào git."*
2. **Trạng thái nền định nghĩa bằng PARSER của chính `check-scope.sh`, không bằng file mẫu thứ
   hai.** Một dòng là pattern ⟺ bỏ phần từ `#` trở đi, cắt khoảng trắng, còn khác rỗng. Đừng dựng
   `work/scope.baseline.txt` hay hằng số `EXPECTED=...` — đó là bản sao thứ hai của cùng nội dung
   (`work/findings.md` F-001).
3. **Vị ngữ đúng cho Gate 3:** ĐỎ khi `HEAD:work/scope.txt` mang pattern **mà cây làm việc VẪN còn
   giữ**. Dọn xong trong cây (dù chưa commit) ⇒ không đỏ, chỉ in `note:` nhắc đưa file vào khối
   commit của lượt này. `HEAD` sạch ⇒ im lặng, không có gì để chấm. Đừng chấm bằng `HEAD` thuần —
   khoá đúng lượt đi dọn.
4. **Vị ngữ đúng cho Gate 7b (luật 3 của `check-commit-block.sh`):** đổi câu hỏi từ *"`work/
   scope.txt` có nằm trong khối không"* sang *"nội dung `work/scope.txt` sẽ được `git add` có còn
   pattern không"* — áp cùng phép đếm ở điểm 2. Đừng cho nó một "ngoại lệ commit migration": một
   cổng không xác minh được loại commit, và một ngoại lệ dựa trên lời khai là đúng cái giá `work/
   findings.md` F-011 đã trả (chữ `ádg`).
5. **Pattern chết / pattern lặp không phải lỗi mới phải bắt.** Một task khai đường dẫn file **sắp**
   tạo ra là hợp lệ (khớp-không-cái-gì ở lượt trung gian, không phải "chết" theo nghĩa xấu — ADR-003
   cùng lý do file chưa track chỉ được `note:`). Đừng thêm logic phát hiện dead/duplicate pattern —
   phần đọc pattern không sai, đừng đổi nó (mục *Không được sửa* ở trên). `check-scope.test.sh` chỉ
   cần chứng minh hai ca này **không bị Gate 3 mới làm hỏng** (vẫn qua như trước).
6. **Thứ tự bắt buộc: sửa hai script TRƯỚC, dọn `work/scope.txt` SAU.** Hai cổng chạy từ cây làm
   việc nên bản sửa có hiệu lực ngay trong lượt này — đó là cách gỡ khoá hợp lệ duy nhất, không cần
   ai miễn trừ cho ai.
7. **Xoá khối của người khác (BA-04, T-027, T-031) chỉ sau khi xác minh bằng `git log`** rằng cả ba
   task đã commit xong (`work/findings.md` F-014 ghi giá của việc xoá hộ mà không kiểm).

## Acceptance

- `scripts/check-scope.sh`: FAIL khi `HEAD:work/scope.txt` còn pattern **và** cây làm việc vẫn giữ
  nguyên pattern đó; `note:` (không FAIL) khi `HEAD` còn nợ pattern nhưng cây làm việc đã sạch; im
  lặng khi `HEAD` đã sạch. Cách đọc/khớp pattern hiện có không đổi một dòng.
- `scripts/check-commit-block.sh`: khối commit liệt kê `work/scope.txt` **chỉ-comment** → im lặng
  (kể cả khi file có mặt trong khối — đây chính là bước dọn nợ mà CLAUDE.md §7.3 đòi). Khối commit
  liệt kê `work/scope.txt` **còn pattern** → vẫn kêu như hành vi cũ.
- `scripts/check-scope.test.sh` (file mới) có tối thiểu bốn ca: nền (HEAD sạch, scope hợp lệ) →
  PASS · `HEAD` có pattern còn nguyên trong cây → FAIL · pattern chết (khớp không file nào đang đổi)
  → không chặn, exit 0 · pattern lặp (cùng một dòng khai hai lần) → không chặn, exit 0. Cộng ca
  "`HEAD` nợ pattern, cây đã sạch" → `note:` + exit 0 (đúng điểm hở duy nhất ở Constraint 3).
- `scripts/check-commit-block.test.sh` có thêm hai ca: khối mang `work/scope.txt` chỉ-comment → im
  · khối mang `work/scope.txt` còn pattern → kêu (giữ nguyên các ca A1–A8 đã có).
- `./scripts/check-scope.sh` chạy với `SCOPE_FILE` trỏ vào một scope **chỉ có khối của T-047** cho
  kết quả khác với lúc `SCOPE_FILE` trỏ vào `work/scope.txt` đầy đủ (ba khối cũ + khối T-047) —
  bằng chứng cổng đã sống lại, không phải một dòng `OK` quen thuộc.
- `CLAUDE.md` hết mâu thuẫn: `grep -rn 'scope\.txt' CLAUDE.md` rồi đọc từng chỗ — §5 (mô tả Gate 3
  và Gate 7), §6, §6.1 (gạch đầu dòng *"never in the block"* sai, phải đổi thành nội dung-hoá) đều
  khớp với hành vi mới.
- `docs/decisions.md` có ADR mới ghi: ba đường, đường nào được chọn và vì sao, đường nào bị loại và
  vì sao — trỏ về `work/findings.md` F-020.
- `work/findings.md` F-020 → Status **Fixed**, kèm đoạn đóng ghi ngày và cách đóng (theo đúng khuôn
  các mục Fixed khác trong file, ví dụ F-018).
- `work/backlog.md`: T-047 chuyển sang *Done* kèm ngày; `work/scope.txt` hết sạch pattern (chỉ còn
  comment) ở cuối lượt.
- `./scripts/gate.sh` xanh, output thật dán vào report.

## Verify

```bash
# 0 — đo nợ trước khi sửa
git show HEAD:work/scope.txt | grep -vcE '^\s*(#|$)'

# 1 — sau khi sửa hai script: chứng minh Gate 3 sống lại (không phải OK quen thuộc)
SCOPE_FILE=<file scope chỉ có khối T-047> ./scripts/check-scope.sh; echo "exit=$?"
./scripts/check-scope.sh; echo "exit=$?"   # scope.txt thật, vẫn còn ba khối cũ ở HEAD lúc này

# 2 — test suite mới/đã thêm ca
./scripts/check-scope.test.sh
./scripts/check-commit-block.test.sh

# 3 — gate tổng
./scripts/gate.sh

# 4 — sau khi dọn work/scope.txt về chỉ-comment, xác nhận Gate 3 chỉ còn note (chưa commit)
git show HEAD:work/scope.txt | grep -vcE '^\s*(#|$)'   # vẫn 10 — chưa commit
./scripts/check-scope.sh; echo "exit=$?"                # note:, exit=0 — cây đã sạch
```

Dán **output thật** của mọi lệnh trên vào Report — `quality/review-gate.md` Gate 2: mỗi dòng
Acceptance phải map tới một lần chạy có output.

## Unknowns

- Không có câu hỏi nghiệp vụ. Câu chưa rõ duy nhất (chọn đường) thuộc chủ repo, đã chốt 2026-09-03
  (đường 2) — không phải `U-XXX`.
- **Không sửa lịch sử git.** `12c77f8` và các commit trước đó ở lại nguyên trạng — đây là bằng
  chứng của F-020, rewrite history để dọn ba dòng text là cái giá sai (cùng luật ADR-008 áp cho
  F-020's kiểu bug).
- Việc **commit** kết quả task này do người dùng quyết (CLAUDE.md §6) — làm xong thì báo, đừng tự
  chạy `git commit`.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì, đúng thứ tự nào
- Đã verify bằng cách nào, kết quả ra sao (dán output thật)
- Còn vấn đề gì chưa giải quyết
