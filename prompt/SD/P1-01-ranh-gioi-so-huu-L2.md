# P1-01 — Chốt ranh giới sở hữu: lược đồ · hợp đồng API · route (L2) · pha 1, bước 1/12

> Bước **1/12** của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6 (`docs/decisions.md`
> **ADR-033**). Mô tả dài của bước ở `work/backlog_SD.md` → **P1-01**; trạng thái ở `work/backlog.md`.
> Bước này **mở khoá** mười bước còn lại của pha 1 (§6: mười trong mười một bước ghi *Cần xong trước: P1-01*).
>
> **Đây là lane prompt đầu tiên của pha 1.** `prompt/BA/` là pha 0, `prompt/maintenance/` là việc
> sửa repo; `prompt/SD/` là pha 1, một file một bước `P1-XX`.

## Context

- **`work/findings.md` F-023** — gốc rễ của bước này. `docs/decisions.md` **ADR-014**, thân mục,
  viết: *"Tên bảng, tên cột, khoá ngoại, API, route vẫn thuộc `docs/product/1-system-design/architecture.md`
  và `master_plan/prompt-fullstack.md` §3.4–§3.7 (CLAUDE.md §2 không đổi một dòng nào)."* Đọc hai
  tài liệu ấy thì **cả hai từ chối**, và `CLAUDE.md` §2 thì **không có hàng nào** cho ba thứ ấy.
- **Ba chỗ nói ba câu khác nhau**, đọc đủ cả ba trước khi ghi một chữ:

  | Chỗ | Nó nói gì hôm nay |
  |---|---|
  | `docs/decisions.md` ADR-014 (thân mục) | giao lược đồ · API · route cho **hai** tài liệu |
  | `docs/product/1-system-design/architecture.md` §8, câu cuối | *"Điều tài liệu này **cố ý KHÔNG làm**: không đặt tên bảng, không đặt tên cột, không vẽ khoá ngoại. Chốt lược đồ là việc của **tầng System Design**"* |
  | `master_plan/prompt-fullstack.md` banner, đầu file | *"Schema · API · route · bất biến **CHƯA có nhà** — đừng đi tìm"* |

- **Trục pha đã có sẵn và đã kèm luật chống chép**: `master_plan/prompt-fullstack.md` §7, bảng sáu
  pha, dòng cuối — *"pha 0–1 **không** nhắc tên bảng; pha 2 **không** nhắc endpoint; pha 3 **không**
  nhắc component; pha 4 **không** đổi hợp đồng API"*. Bước này **không dựng trục mới**, nó ghi trục
  ấy vào owner.
- **Thư mục pha 2–5 cố ý chưa tồn tại**: `docs/product/00-index.md`, bảng *Sáu pha* + mục *Luật ghi*
  (*"tạo thư mục của pha cùng lúc với dòng nội dung đầu tiên, không sớm hơn"*), và ADR-014 khối
  *SỬA ĐỔI 2026-09-02* đã bác thẳng file giữ chỗ `00-chua-co-gi.md`.
- **Ranh giới pha 1 được viết gì thay vào**: `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §3,
  bảng ba dòng. Đọc nó, đừng chép nó.
- **`quality/invariants.md` đang giữ `I-001`…`I-020`** — nên vế *"bất biến chưa có nhà"* của banner
  đã sai từ lâu, không chỉ sai sau bước này.

## Goal

Câu hỏi *"ai sở hữu tên bảng · hợp đồng API · route"* có **đúng một** câu trả lời, đọc được ở
`CLAUDE.md` §2, và không tài liệu nào trong repo còn nói ngược nó — kể cả khi câu trả lời cho ba
thứ ấy là *"chưa có owner, sinh ra ở pha N"*.

## Scope

Được sửa:
- `docs/decisions.md` — **ADR-035** (mới) + một dòng bảng tổng hợp + một khối *SỬA ĐỔI 2026-09-04*
  cho ADR-014
- `CLAUDE.md` — **chỉ** bảng §2 và đoạn văn ngay dưới nó
- `work/findings.md` — **chỉ** mục F-023
- `work/backlog.md` — **chỉ** dòng P1-01 (*Ready* → *In Progress* → *Done*)
- `work/backlog_SD.md` — **chỉ** một dòng *Xong ngày…* ở đầu entry P1-01 (luật 3 của file ấy)
- `prompt/SD/` — file prompt này
- `scripts/check-links.sh` — **một** dòng: `prompt/SD/*` vào tập file Gate 1b chấm
- `docs/product/1-system-design/architecture.md` — **đúng một câu** ở cuối §8
- `master_plan/prompt-fullstack.md` — **đúng một câu** ở banner đầu file
- `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` — **chỉ** dòng F-023 ở §8

Không được sửa:
- `quality/invariants.md`, `master_plan/shop-facts.md`, `docs/product/0-ba/**`,
  `docs/product/99-unknowns.md` — bước này không chạm dữ kiện nghiệp vụ nào
- `master_plan/prompt-fullstack.md` §1–§11 — **đề xuất 16 bảng ở §3.5 để nguyên**, không sửa một
  dòng; bước này quyết *tư cách* của nó, không sửa *nội dung* của nó
- `docs/product/1-system-design/architecture.md` §1–§7, §9–§14
- câu chữ cũ trong thân ADR-014 — sửa **tiến** bằng khối sửa đổi (**ADR-008**)

## Constraints

- **Quyết AI ĐƯỢC ĐẶT TÊN, không đặt một cái tên nào.** Không một tên bảng, tên cột, khoá ngoại,
  endpoint, chữ ký hàm, route hay component được viết ra trong lượt này — kể cả làm ví dụ.
- **Không dựng thư mục pha 2–5, không tạo file giữ chỗ.** Hàng `CLAUDE.md` §2 ghi *chưa có owner,
  sinh ra ở pha N*; nó đổi thành tên file thật trong **cùng thay đổi** mở thư mục của pha ấy.
- **Không mở lại nghiệp vụ** (`CLAUDE.md` §3.5, kế hoạch §3). Bước này không có dữ kiện quán nào.
  Gặp chỗ phải chọn giữa **hai cách chia sở hữu** ⇒ đó là câu của **chủ repo**, hỏi trước khi ghi.
- **ADR-008 — sửa tiến.** Câu sai của ADR-014 ở lại nguyên văn; khối sửa đổi ghi ngày nói nó sai ở
  đâu và ai giữ câu ấy từ nay.
- **Đừng gộp với P1-04.** Bước này quyết *ai được đặt tên bảng*; bảng ba cột là việc của P1-04…P1-06.
- **Pointer lệch là bug của lượt này** (`CLAUDE.md` §7.2), không phải task sau.

## Acceptance

1. `docs/decisions.md` có **ADR-035**, và nó trả lời **bốn** thứ bằng bốn hàng: lược đồ → pha 2 ·
   hợp đồng API → pha 3 · route/component → pha 4 · **tầng bảo vệ của từng `I-0xx`** → pha 1.
2. ADR-035 nói rõ tư cách của `master_plan/prompt-fullstack.md` §3.4–§3.7: **đầu vào để đối chiếu**,
   không phải đầu ra đã chốt, và không owner của thứ gì.
3. ADR-035 có mục *Rejected alternatives* nêu **đủ bốn** đường bị bác, mỗi đường một lý do đứng được.
4. Bảng tổng hợp đầu `docs/decisions.md` có đúng một dòng `ADR-035`.
5. ADR-014 có khối **SỬA ĐỔI 2026-09-04**; câu cũ trong thân **không bị xoá và không bị viết lại**.
6. `CLAUDE.md` §2 có **bốn** hàng mới, và ba trong bốn hàng ấy ghi thẳng *chưa có owner — sinh ra ở
   pha N*.
7. `docs/product/1-system-design/architecture.md` §8 không còn câu nào **giao việc** chốt lược đồ
   cho *tầng System Design*; câu *"cố ý KHÔNG làm"* thì **ở lại** — nó đúng. Cụm *"tầng System
   Design"* vẫn xuất hiện một lần trong câu **kể lại** chỗ sai cũ, và đó không phải chỗ sai (F-018).
8. `master_plan/prompt-fullstack.md` banner không còn xếp **bất biến** vào loại *chưa có nhà*, và
   không còn nói schema · API · route *chưa có nhà* mà không nói pha nào sinh ra chúng.
9. `work/findings.md` **F-023** ở trạng thái **Fixed**, kèm ngày và mã bước đã sửa.
10. `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §8 không còn kể F-023 là *đang sai*.
11. Không file nào bước này sửa chứa một tên bảng · tên cột · endpoint · route mới.
12. `./scripts/gate.sh` xanh.

## Verify

```bash
# (1) ADR-035 có mặt, và bảng tổng hợp có đúng một dòng cho nó
grep -n '^### ADR-035' docs/decisions.md
grep -c '^| \*\*ADR-035\*\* \|^| ADR-035 ' docs/decisions.md          # 1

# (2) khối sửa đổi của ADR-014 có mặt; câu cũ VẪN còn nguyên văn.
#     Đọc theo KHỐI, không theo dòng: câu cũ GÓI DÒNG giữa "vẫn thuộc" và đường
#     dẫn, nên một `grep` theo dòng trả về 0 và trông y hệt "câu đã bị xoá"
#     (work/findings.md F-015 — đúng lỗi mà bản đầu của lệnh này mắc phải).
grep -n 'SỬA ĐỔI 2026-09-04 (P1-01)' docs/decisions.md
python3 -c "print(open('docs/decisions.md').read().count('Tên bảng, tên cột, khoá ngoại, API, route vẫn thuộc'))"   # 1

# (3) CLAUDE.md §2 trả lời được ba câu
grep -n 'pha 2\|pha 3\|pha 4' CLAUDE.md | sed -n '1,8p'

# (4) hai câu pointer đã sửa. Lọc CÂU GIAO VIỆC, không lọc một cụm từ: khối
#     sửa đổi phải nhắc lại cụm "tầng System Design" để kể được nó sai ở đâu,
#     nên lọc theo cụm sẽ đỏ vì đúng cái việc mình vừa làm (F-018).
grep -c 'Chốt lược đồ là việc của tầng System Design' docs/product/1-system-design/architecture.md   # 0
grep -n  'Chốt lược đồ là việc của' docs/product/1-system-design/architecture.md   # 1 dòng, và nó nói "pha 2 · DB"
grep -n  'CHƯA có nhà' master_plan/prompt-fullstack.md                             # rỗng

# (5) F-023 đã đóng
grep -n -A2 '^### F-023' work/findings.md | head -3
awk '/^### F-023/,/^### F-024/' work/findings.md | grep -n 'Fixed'

# (6) KHÔNG tên bảng/cột/endpoint/route lọt vào file lượt này sửa.
#     F-017: in cả lệnh CHƯA lọc cạnh lệnh đã lọc — một bộ lọc rỗng vì viết sai
#     trông y hệt một bộ lọc rỗng vì không có lỗi.
git diff --unified=0 -- docs/decisions.md CLAUDE.md \
  docs/product/1-system-design/architecture.md master_plan/prompt-fullstack.md \
  | grep -c '^+'                                   # chưa lọc: > 0, chứng minh có dòng để lọc
git diff --unified=0 -- docs/decisions.md CLAUDE.md \
  docs/product/1-system-design/architecture.md master_plan/prompt-fullstack.md \
  | grep -E '^\+' \
  | grep -nEi 'CREATE TABLE|FOREIGN KEY|\bGET /|\bPOST /|\bPUT /|\bDELETE /|/api/' # rỗng

# (7) Gate 1b nay chấm lane mới
grep -n 'prompt/SD' scripts/check-links.sh

# (8) cổng của repo
./scripts/gate.sh
```

## Unknowns

**Không có câu hỏi nghiệp vụ nào trong bước này** — nó không chạm một dữ kiện quán nào. Bốn chỗ
đang chặn pha 1 (`U-031` · `U-032` · `U-033` · `S-5`) chặn **P1-03 → P1-09**, không chặn bước này;
danh sách ở `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §8.

Chỗ **duy nhất** phải dừng và hỏi: nếu ranh giới sở hữu có **hai** cách chia cùng đứng được, đó là
câu của **chủ repo**, không phải của phiên. Cách chia trong ADR-035 không rơi vào ca ấy — nó là
trục pha **đã có** ở bảng sáu pha, chỉ đang được ghi vào owner lần đầu.

## Report (AI trả lời sau khi làm)

1. ADR-035 chốt gì, và bốn đường bị bác vì lý do gì.
2. Câu nào của ADR-014 sai, khối sửa đổi giữ lại phần nào của nó.
3. `grep` hai cụm *"chưa có nhà"* và *"cố ý KHÔNG làm"* sau khi ghi: chỗ nào sửa, chỗ nào **cố ý ở
   lại** và vì sao (một tài liệu **kể lại** một chỗ sai không phải là một chỗ sai — `work/findings.md` **F-018**).
4. Output thật của mục *Verify* và của `./scripts/gate.sh`.
5. Khối `git commit` dán được (`CLAUDE.md` §6.1).
