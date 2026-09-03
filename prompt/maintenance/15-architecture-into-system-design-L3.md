# 15 — Bước 5/5: `docs/architecture.md` dọn vào `docs/product/1-system-design/` (L3) · DOC-5

> ## ✅ ĐÃ CHẠY XONG 2026-09-03 — commit `5ddd0e9`. ĐỪNG CHẠY LẠI.
>
> **Đọc file này từ trên xuống, và khối này thắng.** Chủ repo chốt **đồng ý** ngày 2026-09-03, nên
> điều kiện mở khoá 1 đã đủ và lượt 5 đã chạy. `docs/architecture.md` nay ở
> `docs/product/1-system-design/architecture.md`.
>
> Mọi câu bên dưới nói *"chưa được phép chạy"*, *"chưa có lời chốt"* hay *"chủ repo chốt HOÃN"*
> đều là **bản ghi của trạng thái trước lúc chốt**, giữ nguyên câu chữ vì chỗ nó **đoán lệch** là
> thứ đáng đọc — nhất là ĐK3, thứ hoá ra **không mỏng** như hai lượt trước tưởng.
>
> **Kết quả và lý lẽ đầy đủ ở `docs/decisions.md` ADR-014, khối *SỬA ĐỔI 2026-09-03*** — nơi ghi
> cả ba điều kiện kèm bằng chứng, luật chia 40 chuyển / 8 ở lại, vì sao chuyển trong **một** commit
> thay vì năm task con, và số phận của `master_plan/phase_1_system_design_banh_cuon_ba_thanh.md`.
> Dòng `- [x] DOC-5` trong `work/backlog.md` là bản tóm tắt.
>
> **Ba điều đã đúng khác với lúc viết prompt, đừng tin lại con số cũ:** ĐK3 thoả bằng chính luật
> *"tạo thư mục của pha cùng lúc với dòng nội dung đầu tiên"* (`docs/product/00-index.md`) · câu
> `grep` ở mục *Acceptance* sau khi dọn trả về **12** dòng chứ không phải 8, và cả 12 đều cố ý ·
> con số 48 là mốc **của ngày 2026-09-03**, không phải lời chốt.

> ## ⛔ CHƯA ĐƯỢC CHẠY — *(bản ghi trạng thái TRƯỚC 2026-09-03; khối ✅ ở trên thắng)*
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
>    đường dẫn của 48 dòng (đo 2026-09-03; bản gốc ghi 99, xem *Context*) để đổi lấy một folder
>    vẫn chỉ có đúng một file.
>
> Ai chạy prompt này mà thiếu một trong ba điều kiện là làm sai ADR-014.
>
> **Đo lại ba điều kiện, 2026-09-03 (T-046):** ĐK2 **đủ** — `bc5033c` · `83fe8ff` ·
> `dc53768`/`fd64862`/`1a56b8e` · `ddec2f0`. ĐK1 **chưa có** — `docs/decisions.md` dòng 1068 vẫn
> viết *"chưa chốt việc `docs/architecture.md` có dọn vào folder hay không"*. ĐK3 **mỏng** —
> `docs/product/00-index.md` dòng 15 ghi pha 1 *"chưa mở"*. Chủ repo được hỏi hôm ấy và **chốt là
> HOÃN**: chưa quyết dọn hay không. Nên **khoá vẫn đóng**; lượt T-046 chỉ vá hai con số hỏng bên
> dưới, không nới một chữ nào của ba điều kiện trên.

> ## 📕 Đọc ba finding này TRƯỚC khi tin bất cứ con số nào ở dưới
>
> Prompt này đếm bằng **cùng một lượt `grep` ngày 2026-09-02** đã sinh ra ba finding, và cả ba đều
> nhắc DOC-5 đích danh:
>
> - **F-017** — bộ lọc `grep` rỗng. Đã vá ở mục *Acceptance* dưới; F-017 dặn thẳng *"DOC-5 thì
>   phải sửa trước khi chạy"*, và T-046 là lượt sửa ấy.
> - **F-018** — tổng thì đúng, **chỗ cắt thì sai**, ba lần liền (DOC-3a 14→15, DOC-3b 10/20→8/22,
>   DOC-3c 8/1→7/2). Chỗ cắt ra từ **đọc thì của câu**, không từ đếm. Đừng ép con số về cho khớp.
> - **F-019** — lượt tách file đẻ ra một tiêu đề H1 mang cùng chữ với `## N.`, nên mọi câu nghiệm
>   thu **đếm chữ trong tiêu đề** đều hụt một đơn vị. Dòng `Done` của DOC-3b đã dự báo:
>   *"DOC-5 sẽ gặp lại y hệt."* Nếu lượt dọn có sinh `# §N — …` cho `docs/architecture.md`, **chạy
>   thử** mọi câu đếm tiêu đề, đừng chỉ đổi đường dẫn cho chúng.

## Context

- `docs/architecture.md` (592 dòng, đo 2026-09-02) là owner của **Architecture** trong `CLAUDE.md`
  §2, và banner của nó tự mô tả đúng pha 1: *"đây là đặc tả, không phải mã… nó không nói tên hàm,
  tên file hay thư viện"*. Theo trục pha, chỗ đứng của nó là `docs/product/1-system-design/`.
- **Số pointer — đo lại 2026-09-03 (T-046); con số `99` của bản 2026-09-02 đã sai cả hai chiều:**

  | Đo | 2026-09-02 | **2026-09-03** |
  |---|---:|---:|
  | tổng số dòng trỏ `docs/architecture.md` | 99 | **142** — *KHÔNG dùng làm mốc, xem dưới* |
  | sau bộ lọc portable (bỏ `work/`, `prompt/maintenance/`) | — | **48** |

  ⚠️ **Chỉ con số 48 là mốc dùng được; tổng chưa lọc thì KHÔNG.** Đo ba lần trong chính lượt vá
  này, cách nhau vài phút: **133 → 139 → 142**, mà **không một pointer nào đổi** — nó nhích chỉ vì
  lượt vá viết thêm mấy câu về task này vào `work/backlog.md`, `work/findings.md` và vào chính file
  prompt này. Cùng ba lần đo ấy, con số sau bộ lọc **đứng yên ở 48**. Tổng
  chưa lọc đếm cả hai thư mục *sổ ghi chép* mà đề bài đã loại khỏi phạm vi, nên nó **tăng mỗi lần
  có ai viết về task này**, kể cả khi không một pointer thật nào đổi. Dùng nó làm mốc là tự dựng
  một con số luôn lệch (F-018).

  **48 là số dòng phải ĐỌC, không phải số dòng phải chuyển** (F-018: ba lần trước tổng đúng mà chỗ
  cắt sai). Chia theo file, đếm lại 2026-09-03 và **cộng đúng bằng 48**: `docs/decisions.md` 22 ·
  `prompt/BA/**` 11 · `docs/product.md` 6 · `docs/product/0-ba/**` 6 · `CLAUDE.md` 1 ·
  `scripts/brief.sh` 1 · `docs/prompt-guideline.md` 1.

  *(Bảng này lần đầu ghi `prompt/BA/** 13` và `0-ba/** 5` — cộng ra 49, không phải 48. Sai do đếm
  mắt trên một danh sách bị cắt ngắn, sửa cùng ngày. Ghi lại vì nó là **F-018 lần thứ năm**, và
  lần này người mắc là chính lượt đi vá F-018: phép thử rẻ nhất vẫn là **cộng các nhóm lại xem có
  bằng tổng không**.)*

  **Vùng chắc chắn Ở LẠI, đã đọc và xác nhận:**
  - **6 dòng của `docs/product.md`** — bản lưu, banner của nó viết *"Không sửa ở đây"*; nó là ảnh
    chụp ngày 2026-09-02, đổi đường dẫn trong đó là khai rằng ảnh chụp mang một đường chưa tồn tại
    vào ngày ấy (đúng lý lẽ dòng 492 của F-018).
  - **`docs/decisions.md` dòng 1066 và 1068** — hai dòng ấy *nói về chính lượt 5 này*, và đường cũ
    ở đó là chủ ngữ của câu, không phải pointer.
  - Còn lại phải đọc từng dòng: `docs/decisions.md` có cả câu **lịch sử** (*Rejected alternatives*,
    số đo cũ) lẫn câu **đang có hiệu lực**. Thấy dòng thứ 49 thì ghi lại, **đừng ép về 48**.

  Cộng thêm hàng §2 của `CLAUDE.md` và một hàng trong `docs/decisions.md` ADR-012 / ADR-013.
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
- **48 dòng phải đọc** (đo 2026-09-03) trong `docs/**`, `prompt/BA/**`, `CLAUDE.md`,
  `scripts/brief.sh` — chia theo file ở mục *Context*
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
- **Một task con = một nhóm file = một commit**, như bước 3. Không gộp cả 48 dòng vào một lượt.
- `scripts/brief.sh` phải in `docs/product/1-system-design/` trong *OWNER FILES* và
  `./scripts/brief.sh` vẫn `exit 0` khi folder ấy không tồn tại (CLAUDE.md §7.1).

## Deliverables (của lượt L3 đầu tiên)

1. Câu chốt của chủ repo, có ngày, ghi vào `docs/decisions.md`.
2. **Đếm lại từ đầu** (số 133/48 ở trên là mốc ngày 2026-09-03, không phải lời chốt — F-018),
   chia nhóm như bước 3, kèm thứ tự và task con trong `work/backlog.md`.
3. Quyết định về `master_plan/phase_1_system_design_…md`, ghi vào ADR.
4. Phương án lùi: task con nào rủi ro nhất, lùi bằng `git revert` commit nào.

## Acceptance (của giai đoạn chia việc)

- Ba điều kiện mở khoá ở đầu file đều được dẫn chứng bằng một dòng thật (ngày chốt, mã commit).
- Mỗi task con revert được độc lập.
- Câu `grep` chứng minh xong — **bản portable của F-017**, khớp cả có lẫn không có tiền tố `./`
  (`grep` trên máy này là ugrep 7.8.4, nó in đường dẫn **không** có `./`, nên bản cũ ba bộ lọc
  `^\./…` lọc rỗng):
  ```bash
  grep -rn 'docs/architecture\.md' --include='*.md' --include='*.sh' . \
    | grep -vE '^(\./)?(work/|prompt/maintenance/)'
  ```
  **Đã chạy 2026-09-03, dán số làm mốc** (F-017: lệnh nghiệm thu phải được chạy một lần lúc viết
  prompt): **48** dòng, so với **142** dòng của lệnh chưa lọc. Hai số khác nhau ⇒ bộ lọc có tác
  dụng thật. **Cách đọc kết quả:** hai lệnh ra **bằng nhau** ⇒ bộ lọc lại rỗng, dừng và đọc F-017,
  đừng đi sửa `work/**`. Số bên phải lớn hơn 142 là bình thường và sẽ còn lớn thêm — nó đếm cả
  `work/` và `prompt/maintenance/`. **Chỉ số bên trái (48) mới là thứ đem ra so.**

  ⇒ Sau khi dọn, phần còn lại chỉ được là những dòng **cố ý** nói về đường cũ; liệt kê đích danh
  từng dòng và nói vì sao mỗi dòng ở lại.
- `CLAUDE.md` §2 không còn hàng nào trỏ `docs/architecture.md`.
- `./scripts/gate.sh` xanh sau **mỗi** task con.

## Verify

```bash
# tổng chưa lọc — 142 lúc 2026-09-03, và nó TĂNG mỗi lần có ai viết về task này. Không phải mốc.
grep -rn 'docs/architecture\.md' --include='*.md' --include='*.sh' . | wc -l
# phần phải đọc — mốc 2026-09-03: 48. Ra đúng bằng số trên ⇒ bộ lọc rỗng, đọc F-017.
grep -rn 'docs/architecture\.md' --include='*.md' --include='*.sh' . \
  | grep -vE '^(\./)?(work/|prompt/maintenance/)' | wc -l
./scripts/brief.sh | sed -n '/OWNER FILES/,$p'
./scripts/gate.sh; echo "exit=$?"
```

## Unknowns

- **Câu chưa ai trả lời, và nó chặn cả prompt này:** chủ repo có muốn `docs/architecture.md` vào
  folder không? **Đã hỏi 2026-09-03, chủ repo chốt là HOÃN** — chưa quyết dọn hay không, lượt ấy
  (T-046) chỉ vá hai con số hỏng của prompt này. Nên câu hỏi **vẫn mở** và ĐK1 **vẫn chưa đủ**:
  chưa có câu chốt nào trong `docs/decisions.md`. Không đoán (CLAUDE.md §3.5).
- Việc **commit** do người dùng quyết (CLAUDE.md §6).

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
