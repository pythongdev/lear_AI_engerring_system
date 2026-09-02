# 15 — Bước 5/5: `docs/architecture.md` dọn vào `docs/product/1-system-design/` (L3) · DOC-5

> ## ⛔ CHƯA ĐƯỢC CHẠY
>
> Chủ repo đã chốt **trục pha** (ADR-014, khối *SỬA ĐỔI 2026-09-02*). Chủ repo **chưa** chốt việc
> `docs/architecture.md` có dọn vào folder hay không. Prompt này viết sẵn để lúc chốt là chạy được
> ngay.
>
> **Điều kiện mở khoá — cả ba, không thiếu cái nào:**
> 1. Một câu chốt mới của **chủ repo**, có ngày, ghi vào `docs/decisions.md` (sửa đổi thứ hai của
>    ADR-014, hoặc một ADR mới).
> 2. **Bước 1–4 đã xong** và đã commit.
> 3. Pha 1 (system design) **đã có sản phẩm thật** để bỏ vào folder — nếu chưa, dọn vào chỉ là đổi
>    đường dẫn của 99 pointer để đổi lấy một folder vẫn chỉ có đúng một file.
>
> Ai chạy prompt này mà thiếu một trong ba điều kiện là làm sai ADR-014.

## Context

- `docs/architecture.md` (592 dòng, đo 2026-09-02) là owner của **Architecture** trong `CLAUDE.md`
  §2, và banner của nó tự mô tả đúng pha 1: *"đây là đặc tả, không phải mã… nó không nói tên hàm,
  tên file hay thư viện"*. Theo trục pha, chỗ đứng của nó là `docs/product/1-system-design/`.
- **99 dòng trong repo trỏ `docs/architecture.md`** (đo 2026-09-02:
  `grep -rn "docs/architecture.md" --include="*.md" --include="*.sh" . | wc -l`). Cộng thêm hàng
  §2 của `CLAUDE.md` và một hàng trong `docs/decisions.md` ADR-012 / ADR-013.
- **ADR-012** đặt mục *Nợ* ở `docs/architecture.md` §12; **ADR-013** đặt mục *admin* ở §14. Cả hai
  gọi tên mục theo **số §**, nên số mục phải giữ nguyên như bước 1 đã giữ §1–§8 của product.
- `master_plan/phase_1_system_design_banh_cuon_ba_thanh.md` (375 dòng) là **đầu ra pha 1 bản đầu**,
  đang nằm ở `master_plan/`. Nó là ứng viên thứ hai cho cùng folder — và là chỗ dễ sinh **hai
  owner cho một sự thật** nhất trong cả năm bước (F-001).

## Goal

Pha 1 có đúng một chỗ đứng trong `docs/product/`, và không sự thật nào của pha 1 có hai nhà.

## Scope

Hệ thống/thành phần bị ảnh hưởng:
- `docs/architecture.md` → `docs/product/1-system-design/`
- `CLAUDE.md` §2 hàng *Architecture*
- ~99 pointer trong `docs/**`, `quality/**`, `master_plan/**`, `prompt/BA/**`
- `scripts/brief.sh` — `docs/architecture.md` có trong danh sách *OWNER FILES*

Ngoài phạm vi:
- **Nội dung** của `docs/architecture.md`: lượt này chuyển chỗ, không biên tập
- `work/**` và `prompt/maintenance/**` — sổ ghi chép lịch sử, cùng lý do bước 3
- `master_plan/prompt-fullstack.md` — bản xuất khẩu, người đọc nó đứng **ngoài** repo; đổi nó là
  một task riêng có lý do riêng (bài học T-031)

## Constraints

- **Giữ nguyên số mục §1–§14.** ADR-012 và ADR-013 gọi tên mục bằng số; đánh số lại là làm sai hai
  ADR mà `grep` không bắt được.
- **Quyết dứt điểm chuyện `master_plan/phase_1_system_design_…md`** trong chính lượt này, và ghi
  quyết định ấy ra: hoặc nó dọn vào cùng folder, hoặc nó ở lại `master_plan/` và **được nói rõ là
  bản nháp pha 1 không sở hữu gì**. Để lửng là tạo owner thứ hai cho pha 1.
- **`CLAUDE.md` §2 đổi hàng, không thêm hàng.** *Architecture* vẫn là một loại sự thật, chỉ đổi
  chỗ ở.
- **Một task con = một nhóm file = một commit**, như bước 3. Không gộp 99 pointer vào một lượt.
- `scripts/brief.sh` phải in `docs/product/1-system-design/` trong *OWNER FILES* và
  `./scripts/brief.sh` vẫn `exit 0` khi folder ấy không tồn tại (CLAUDE.md §7.1).

## Deliverables (của lượt L3 đầu tiên)

1. Câu chốt của chủ repo, có ngày, ghi vào `docs/decisions.md`.
2. Đếm lại 99 pointer, chia nhóm như bước 3, kèm thứ tự và task con trong `work/backlog.md`.
3. Quyết định về `master_plan/phase_1_system_design_…md`, ghi vào ADR.
4. Phương án lùi: task con nào rủi ro nhất, lùi bằng `git revert` commit nào.

## Acceptance (của giai đoạn chia việc)

- Ba điều kiện mở khoá ở đầu file đều được dẫn chứng bằng một dòng thật (ngày chốt, mã commit).
- Mỗi task con revert được độc lập.
- Câu `grep` chứng minh xong:
  ```bash
  grep -rn "docs/architecture\.md" --include="*.md" --include="*.sh" . \
    | grep -v '^\./work/' | grep -v '^\./prompt/maintenance/'
  ```
  ⇒ chỉ còn những dòng cố ý nói về đường cũ; liệt kê đích danh từng dòng.
- `CLAUDE.md` §2 không còn hàng nào trỏ `docs/architecture.md`.
- `./scripts/gate.sh` xanh sau **mỗi** task con.

## Verify

```bash
grep -rn "docs/architecture\.md" --include="*.md" --include="*.sh" . | wc -l
./scripts/brief.sh | sed -n '/OWNER FILES/,$p'
./scripts/gate.sh; echo "exit=$?"
```

## Unknowns

- **Câu chưa ai trả lời, và nó chặn cả prompt này:** chủ repo có muốn `docs/architecture.md` vào
  folder không? Chưa có lời chốt tính tới 2026-09-02. Không đoán (CLAUDE.md §3.5).
- Việc **commit** do người dùng quyết (CLAUDE.md §6).

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
