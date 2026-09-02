# 13 — Bước 3/5: chuyển pointer `docs/product.md` sang file mới (L3 · chia việc) · DOC-3

> Bộ năm bước của ADR-014: 11 → 12 → **13 (đây)** → 14 → 15(chưa chốt).
> **Bước 2 phải xong trước bước này** (ADR-014): brief là thứ mọi phiên mới đọc đầu tiên.
>
> **Đây là prompt L3 — prompt CHIA VIỆC, không phải prompt làm việc** (`docs/prompt-guideline.md`
> §3). Lượt đầu tiên chạy nó chỉ giao **bảng nhóm + thứ tự + luật ánh xạ**, rồi mở từng task con
> L1/L2 trong `work/backlog.md`. Ai đọc file này rồi bắt đầu sửa 563 dòng trong một lượt là đang
> làm sai chính prompt này.

## Context

- Sau bước 1, `docs/product.md` là **bản lưu** và ADR-014 cấm mọi thứ trỏ về nó. Nhưng file cũ vẫn
  tồn tại ⇒ **mọi pointer cũ vẫn mở được** ⇒ **Gate 1b vẫn xanh trong khi cả repo đọc bản lưu**.
  Đây là lý do bước này là L3: không có cái máy nào chấm hộ, chỉ có mắt người và một cái `grep`.
- Đo **2026-09-02 sau BA-10**: `grep -rn "docs/product.md" --include="*.md" --include="*.sh" .`
  ⇒ **563 dòng trong 35 file**. Con số này **tăng mỗi ngày chuỗi BA còn chạy** — đếm lại ngay
  trước khi bắt đầu, và đếm lại sau mỗi task con.
- Phân bố (đo 2026-09-02), đã gộp thành **năm nhóm**:

  | Nhóm | File | Dòng | Xử lý |
  |---|---|---:|---|
  | **A · tài liệu chỉ đường đang sống** | `docs/decisions.md` 59 · `quality/invariants.md` 29 · `docs/architecture.md` 14 · `docs/prompt-guideline.md` 3 · `master_plan/shop-facts.md` 5 · `master_plan/BA_initial_plan_…md` 1 | ~111 | **phải chuyển** |
  | **B · bộ prompt BA** | `prompt/BA/**` (13 file) | ~114 | **phải chuyển** |
  | **C · `CLAUDE.md`** | 6 | 6 | **không làm ở đây** — bước 4 |
  | **D · `scripts/`** | `brief.sh` 5 · `brief.test.sh` 10 | 15 | **không làm ở đây** — bước 2 đã xong |
  | **E · sổ ghi chép lịch sử** | `work/**` (~251, riêng `work/backlog.md` 216) · `prompt/maintenance/**` (~36) | ~287 | **KHÔNG chuyển** — xem *Constraints* |

- Nhóm E là hơn một nửa con số 563, và nó **không phải việc phải làm**. CLAUDE.md §5 nói thẳng vì
  sao Gate 1b không chấm hai thư mục đó: *"một đường đã chết ở đó là bằng chứng, không phải bug"*.
  Một entry Done trong `work/backlog.md` kể lại việc ngày 2026-08-31 đã sửa `docs/product.md` §4 —
  câu ấy **đúng vào ngày ấy**; viết lại nó là làm hỏng lịch sử.
- **`master_plan/shop-facts.md` có 5 dòng trỏ đi, trong khi banner của nó nói *"file này không trỏ
  đi đâu — nó là điểm cuối"*.** Đó là một mâu thuẫn có sẵn, không do bước này sinh ra. Ghi thành
  finding, đừng lặng lẽ sửa banner cho khớp.

## Goal

Không tài liệu nào **đang sống** còn trỏ về `docs/product.md`; mọi câu chỉ đường dẫn thẳng tới file
mới trong `docs/product/`, giữ nguyên số mục §N.

## Scope

Hệ thống/thành phần bị ảnh hưởng: nhóm **A** và nhóm **B** ở bảng trên, cộng đúng **những dòng
thuộc *Ready* và *In Progress*** của `work/backlog.md` (đo 2026-09-02: **5 dòng**).

Ngoài phạm vi:
- Toàn bộ nhóm **E** trừ 5 dòng vừa nêu — `work/**` và `prompt/maintenance/**` giữ nguyên
- Nhóm **C** (`CLAUDE.md` — bước 4) và nhóm **D** (`scripts/` — bước 2)
- `docs/product/**` và `docs/product.md`: bước này **không** đụng nội dung, chỉ đụng thứ trỏ tới nó
- **Câu chữ quanh pointer.** Chỉ đổi đường dẫn; không viết lại câu, không "tiện tay" sửa nội dung.

## Constraints

- **Luật ánh xạ, dùng đúng một luật cho cả 225 dòng:**

  | Câu cũ | Câu mới |
  |---|---|
  | `docs/product.md` §1 (trừ §1.6) | `docs/product/0-ba/ban-hang/01-actors-pham-vi.md` |
  | `docs/product.md` §1.6 | `docs/product/0-ba/admin/01-ranh-gioi.md` |
  | `docs/product.md` §2 … §8 | `docs/product/0-ba/ban-hang/0N-….md` tương ứng |
  | `docs/product.md` → *Unknowns* | `docs/product/99-unknowns.md` |
  | `docs/product.md` không kèm số mục | đọc câu đó rồi mới quyết — **không** đoán, không thay máy móc |

- **Giữ nguyên `§N`.** Câu mới vẫn đọc là *"file X §4.6"*. Bỏ số mục đi là làm hỏng khả năng tra
  ngược của ~180 câu.
- **Một nhóm = một task con = một commit.** Mỗi task con revert được độc lập (`docs/prompt-guideline.md`
  §3 L3). Không gộp nhóm A và B vào một commit.
- **Sau mỗi task con: `./scripts/gate.sh` xanh**, và Gate 1b (`check-links.sh`) phải bắt được nếu
  ánh xạ trỏ sai tên file — đó là cái duy nhất máy chấm được ở bước này.
- **Không dùng `sed -i` trên cả repo.** Một lệnh thay máy móc sẽ đổi cả nhóm E và cả những câu cố ý
  nói về bản lưu. Sửa theo từng file, đọc câu trước khi đổi.
- **`prompt/BA/**` là tài liệu chỉ đường ĐANG SỐNG** (Gate 1b có chấm nó), khác `prompt/maintenance/**`.
  Đừng gộp hai thư mục prompt làm một.
- **Đừng chạy khi có phiên khác đang giữ file trong nhóm A hoặc B** — `./scripts/brief.sh` mục
  *DECLARED SCOPE* và *UNCOMMITTED*. F-014 đã hỏng sáu lần, và bước này chạm nhiều file nhất trong
  cả năm bước.

## Deliverables (của lượt L3 đầu tiên)

1. Bảng nhóm đã **đếm lại**, kèm ngày đếm — không dùng lại con số 563 nếu nó đã trôi.
2. Luật ánh xạ ở trên, xác nhận đủ phủ: liệt kê **mọi dòng không khớp luật nào** (dòng trỏ
  `docs/product.md` mà không kèm §N) và nói từng dòng sẽ thành gì.
3. Task con trong `work/backlog.md`, mỗi task có acceptance riêng và thứ tự:
   **DOC-3a** nhóm A (L2 — chạm `quality/invariants.md`, tài liệu chỉ đường lõi) ·
   **DOC-3b** nhóm B (L1 — `prompt/BA/**`) ·
   **DOC-3c** 5 dòng *Ready*/*In Progress* của `work/backlog.md` (L1).
4. Finding cho mâu thuẫn `master_plan/shop-facts.md` (banner nói không trỏ đi đâu, thực tế trỏ 5 chỗ).

## Acceptance (của giai đoạn chia việc)

- Mỗi task con revert được độc lập, và nói được nó chạm bao nhiêu dòng ở bao nhiêu file.
- Có câu `grep` **chứng minh xong**, chạy được bởi người khác:

  ```bash
  grep -rn "docs/product\.md" --include="*.md" --include="*.sh" . \
    | grep -v '^\./work/' | grep -v '^\./prompt/maintenance/' | grep -v '^\./docs/product\.md:'
  ```
  ⇒ khi cả ba task con xong, lệnh này chỉ còn những dòng **cố ý** nói về bản lưu (banner của chính
  nó, ADR-014, và mục nói về bước này) — liệt kê đích danh từng dòng còn lại và vì sao nó ở lại.
- Không còn unknown nghiệp vụ nào chặn task con đầu tiên (bước này không chạm nghiệp vụ).
- Có phương án lùi cho bước rủi ro nhất: nhóm A chạm `quality/invariants.md` — nói rõ lùi bằng
  `git revert` commit nào.

## Verify

```bash
grep -rn "docs/product\.md" --include="*.md" --include="*.sh" . | wc -l     # đếm lại trước khi bắt đầu
grep -rn "docs/product\.md" --include="*.md" --include="*.sh" . \
  | grep -v '^\./work/' | grep -v '^\./prompt/maintenance/' | wc -l          # phần thật sự phải chuyển
./scripts/gate.sh; echo "exit=$?"      # sau MỖI task con, không phải sau cùng
```

## Unknowns

- Không có câu hỏi nghiệp vụ.
- **Gate 1b không gác được luật "không trỏ về bản lưu"** — file cũ còn đó nên link cũ vẫn xanh.
  Đừng dựng gate mới cho việc này ở đây: CLAUDE.md §3.8 bắt chờ tới lần hỏng thứ hai.
- Việc **commit** do người dùng quyết (CLAUDE.md §6): mỗi task con giao một khối commit riêng.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
