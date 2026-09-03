# 13a — DOC-3a: chuyển pointer nhóm A (tài liệu chỉ đường lõi) · L2

> Task con 1/3 của **DOC-3** (`prompt/maintenance/13-pointer-migration-L3.md`, lượt chia việc
> chạy 2026-09-02). Thứ tự chạy: **DOC-3b → DOC-3a → DOC-3c**. Xem *Context* để biết vì sao
> 3b đứng trước.

## Context

- ADR-014: `docs/product.md` là **bản lưu**, không gì được trỏ về nó. File cũ vẫn tồn tại nên
  **Gate 1b vẫn xanh** dù cả repo đang đọc bản lưu — không máy nào chấm hộ việc này.
- **Đo lại 2026-09-02 (sau DOC-2):** nhóm A có **114 dòng** trong **6 file**, và **0 dòng lệnh
  chạy được** — toàn bộ là văn xuôi chỉ đường, nên luật ánh xạ áp được thẳng.

  | File | Dòng | Ghi chú |
  |---|---:|---|
  | `docs/decisions.md` | 62 | trong đó **13 dòng Ở LẠI** — xem *Constraints* |
  | `quality/invariants.md` | 29 | owner của invariant, đây là chỗ rủi ro nhất |
  | `docs/architecture.md` | 14 | có 1 dòng bảng owner (dòng 533) |
  | `docs/prompt-guideline.md` | 3 | 2 dòng viết *"mục 4"* / *"mục X"*, không phải `§4` |
  | `master_plan/shop-facts.md` | 5 | 1 dòng Ở LẠI (dòng 791) · xem **F-016** |
  | `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` | 1 | |

  ⇒ **100 dòng phải chuyển, 14 dòng ở lại.**
- **113/114 dòng nằm NGOÀI khối ```** ⇒ Gate 1b **có** chấm chúng. Đây là nhóm duy nhất mà cổng
  máy thật sự đỡ được: gõ sai tên file con là gate đỏ ngay.

## Goal

Sáu file nhóm A không còn dòng nào trỏ về `docs/product.md`, trừ đúng 14 dòng cố ý nói về **bản
lưu**. Mọi câu chỉ đường dẫn thẳng tới file trong `docs/product/`, giữ nguyên `§N`.

## Scope

```text
docs/decisions.md
quality/invariants.md
docs/architecture.md
docs/prompt-guideline.md
master_plan/shop-facts.md
master_plan/BA_initial_plan_banh_cuon_ba_thanh.md
work/backlog.md
```

Ngoài phạm vi: `prompt/BA/**` (DOC-3b) · vùng *Ready* của `work/backlog.md` (DOC-3c) ·
`CLAUDE.md` (DOC-4) · `scripts/**` (DOC-2, đã xong) · `docs/product/**` và `docs/product.md`
(nội dung — bước này chỉ đụng thứ **trỏ tới** chúng) · **câu chữ quanh pointer**: chỉ đổi đường
dẫn, không viết lại câu.

## Constraints

- **Luật ánh xạ — dùng đúng một luật, đã xác nhận đủ phủ 2026-09-02:**

  | Câu cũ | Câu mới |
  |---|---|
  | `docs/product.md` §1 (trừ §1.6) | `docs/product/0-ba/ban-hang/01-actors-pham-vi.md` |
  | `docs/product.md` §1.6 | `docs/product/0-ba/admin/01-ranh-gioi.md` |
  | `docs/product.md` §2 | `docs/product/0-ba/ban-hang/02-kenh-ban.md` |
  | `docs/product.md` §3 | `docs/product/0-ba/ban-hang/03-lat-cat.md` |
  | `docs/product.md` §4 | `docs/product/0-ba/ban-hang/04-gia-thanh-toan.md` |
  | `docs/product.md` §5 | `docs/product/0-ba/ban-hang/05-vong-doi.md` |
  | `docs/product.md` §6 | `docs/product/0-ba/ban-hang/06-ngoai-le.md` |
  | `docs/product.md` §7 | `docs/product/0-ba/ban-hang/07-pham-vi-mvp.md` |
  | `docs/product.md` §8 | `docs/product/0-ba/ban-hang/08-scenario.md` |
  | `docs/product.md` → *Unknowns* | `docs/product/99-unknowns.md` |
  | không kèm số mục | đọc câu rồi mới quyết — **không** đoán |

  Số mục xác nhận khớp tiêu đề `# §N —` của từng file con, đo 2026-09-02.

- **`§N` giữ nguyên.** Câu mới vẫn đọc là *"file X §4.6"*. Bỏ số mục là làm hỏng khả năng tra
  ngược của ~100 câu — file con giữ nguyên đánh số mục cũ nên `§4.6` vẫn tra được.
- **Cạm bẫy 1 — `mục N` không phải `§N`.** `docs/prompt-guideline.md` dòng **52** viết
  *"`docs/product.md` mục 4"* và dòng **161** viết *"docs/product.md mục X"*. Luật ánh xạ khớp
  theo `§`, nên hai dòng này **lọt lưới grep**. Dòng 52 → §4. Dòng 161 là **khuôn mẫu**, `mục X`
  là chỗ giữ chỗ ⇒ trỏ tới thư mục `docs/product/`, đừng bịa ra một số mục.
- **Cạm bẫy 2 — 14 dòng Ở LẠI, không được đổi.** Chúng cố ý nói về **bản lưu**:

  | Chỗ | Vì sao ở lại |
  |---|---|
  | `docs/decisions.md` dòng **32** | ô bảng chỉ mục ghi **tên** ADR-014 (*"`docs/product.md` tách thành folder"*) |
  | `docs/decisions.md` dòng **899–1086** (12 dòng, thân ADR-014) | ADR-014 kể lại chính việc tách; đổi đi là làm hỏng bản ghi quyết định |
  | `master_plan/shop-facts.md` dòng **791** | câu lịch sử: *"chỗ `docs/product.md` §4.6 viết sai **trong ngày 2026-09-01**"* — đúng vào ngày ấy |

  Cùng lý lẽ CLAUDE.md §5 dùng cho `work/` và `prompt/maintenance/`: *một đường đã chết ở đó là
  bằng chứng, không phải bug*.
- **Cạm bẫy 3 — hai dòng TRÔNG như ADR-014 nhưng PHẢI chuyển.** `docs/decisions.md` dòng **1757**
  (*"không câu hỏi nào mang số U-028 hay U-029 trong `docs/product.md` hôm nay"*) và dòng **1775**
  (*"không vào mục Unknowns của `docs/product.md`"*) nói về **trạng thái hôm nay**, không kể lịch
  sử ⇒ cả hai → `docs/product/99-unknowns.md`.
- **Hợp đồng *Cách viết một câu ở đây* đã chuyển nhà.** `docs/decisions.md` dòng **425, 465, 469**
  (ADR-007) trỏ tới hợp đồng ấy; nay nó ở `docs/product/99-unknowns.md` **dòng 38** (xác nhận
  2026-09-02). Ba dòng này → `docs/product/99-unknowns.md`.
- **`docs/architecture.md` dòng 533 là một ô BẢNG OWNER** (`| Hành vi nghiệp vụ đã chốt | ... |`).
  Nó phải khớp với bảng owner ở `CLAUDE.md` §2 — mà `CLAUDE.md` là việc của **DOC-4**. Ghi
  `docs/product/` (thư mục) ở đây, và DOC-4 phải ghi **y hệt**. Hai bảng owner nói khác nhau là
  đúng con bug §2 tồn tại để chặn.
- **Không `sed -i` trên cả repo.** Đọc từng câu rồi đổi. Một lệnh máy móc sẽ nuốt cả 14 dòng ở lại.
- **Đừng chạy khi phiên khác đang giữ file nhóm A** — `./scripts/brief.sh`, mục *DECLARED SCOPE*
  và *UNCOMMITTED*. F-014 đã hỏng sáu lần.

## Invariants liên quan

`quality/invariants.md` là **owner của invariant nghiệp vụ** và chiếm 29/114 dòng. Task này
**không đổi một invariant nào** — chỉ đổi đường dẫn trong câu trích nguồn. Nếu thấy mình đang sửa
nội dung một `I-XXX`, dừng lại: đó là việc khác, ở level khác.

## Acceptance

1. `grep` chứng minh (dùng bản **portable** ở *Verify* — xem cạm bẫy `ugrep` trong **F-017**):
   nhóm A còn **đúng 14 dòng**, và liệt kê đích danh từng dòng kèm lý do ở lại.
2. Mỗi dòng đã chuyển giữ nguyên `§N` của nó. Không dòng nào mất số mục.
3. `./scripts/gate.sh` xanh — Gate 1b phải bắt được nếu gõ sai tên file con (113/114 dòng nằm
   ngoài khối ``` nên gate **có** chấm).
4. Không câu chữ nào quanh pointer bị viết lại: `git diff` chỉ thấy đường dẫn đổi.
5. `docs/prompt-guideline.md` dòng 52 và 161 đã xử lý (chúng không lọt qua grep theo `§`).

## Verify

```bash
# Bản portable — grep ở máy này là ugrep, KHÔNG in tiền tố "./" (F-017)
X() { grep -vE '^(\./)?(work/|prompt/maintenance/|docs/product\.md:|docs/product/)'; }

# nhóm A còn lại — phải đúng 14, và đúng 14 dòng đã liệt kê ở Constraints
grep -rn 'docs/product\.md' docs/decisions.md quality/invariants.md docs/architecture.md \
  docs/prompt-guideline.md master_plan/ | wc -l

# không dòng nào mất §N khi chuyển
grep -rn 'docs/product/0-ba' docs/decisions.md quality/invariants.md docs/architecture.md | grep -c '§'

# bẫy "mục N"
grep -rnE 'docs/product\.md[` ]* *mục' docs/ quality/ master_plan/     # phải rỗng

./scripts/gate.sh; echo "exit=$?"
```

## Phương án lùi

Task này chạm `quality/invariants.md` — file rủi ro nhất trong cả DOC-3. Vì nó là **một commit
riêng** (`DOC-3a: ...`), lùi bằng:

```bash
git revert <sha của commit DOC-3a>
```

Không cần lùi DOC-3b: hai task không dùng chung file nào.

## Unknowns

- Không có câu hỏi nghiệp vụ — task này không chạm nghiệp vụ, chỉ chạm đường dẫn.
- **Gate 1b không gác được luật "không trỏ về bản lưu"** (file cũ còn đó nên link cũ vẫn xanh).
  Đừng dựng gate mới ở đây: CLAUDE.md §3.8 bắt chờ tới lần hỏng thứ hai.
- Việc **commit** do người dùng quyết (CLAUDE.md §6) — giao một khối commit riêng.

## Report

- Đã thay đổi gì · đã verify thế nào, kết quả ra sao · còn vấn đề gì chưa giải quyết
- Liệt kê **đích danh 14 dòng ở lại** và vì sao từng dòng ở lại
