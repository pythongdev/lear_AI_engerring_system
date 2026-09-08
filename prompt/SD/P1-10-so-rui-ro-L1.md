# P1-10 — Sổ rủi ro pha 1: mỗi rủi ro một cơ chế đã viết ra, một người chịu, một dấu hiệu (L1) · bước 10/14

> Bước **10/14** của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6. Mô tả dài ở
> `work/backlog_SD.md` → **P1-10**; trạng thái ở `work/backlog.md`.
> **Cần xong trước:** P1-04 · P1-05 · P1-06 · P1-13 · P1-14 — **cả năm đã xong** (bảng ba cột
> `docs/product/1-system-design/03-bao-ve-invariant.md` §1–§4 đã đủ hàng), cộng P1-02 · P1-03 ·
> P1-08 · P1-09 cho các mục mà cột *Cơ chế chặn* phải trỏ vào.
> **Mức L1, không phải L2:** bước này **không** quyết định một thiết kế nào — nó **nối** những cơ
> chế đã có vào những chỗ hỏng đã biết. Ceremony theo `CLAUDE.md` §3.

## Context

`master_plan/phase_1_system_design_banh_cuon_ba_thanh.md` §6 giữ năm rủi ro `R1`–`R5`, và file ấy
mang banner *"không sửa ở đây"*, **không sở hữu sự thật nào** (`docs/decisions.md` **ADR-014**).
Quan trọng hơn cái banner: bảng ấy viết **trước** ba luật đường tiền đã chốt từ đó —
**cho nợ** (`master_plan/shop-facts.md` §6.14, 2026-08-31) · **hoàn tiền tính ngày hoàn** (§6.4,
2026-09-01) · **đối soát ba nguồn ngưỡng 0đ** (§6.10, 2026-09-01). Một sổ rủi ro không có ba thứ ấy
là sổ của một hệ thống khác.

Bốn mục pha 1 đã viết sẵn phần việc của bước này, mỗi mục một hàng **P1-10 — sổ rủi ro** trong bảng
*Bước sau đọc gì*: `docs/product/1-system-design/03-bao-ve-invariant.md` §1.4 · §2.3 · §3.2 · §4.3
(các ô **máy không ngăn được** của bốn nhóm) · `01-ranh-gioi-he-thong.md` §5 (mỗi dòng §3 là một
rủi ro **đã có người chịu**) · `05-realtime-va-du-phong.md` §5 (`RB-1` · `RB-4` · §1.3). Sổ rủi ro
**trỏ** về chúng thay vì viết lại.

Đọc trước khi viết dòng đầu tiên: bản nháp §6 (**để biết cái cũ nói gì, không để chép**) ·
`03-bao-ve-invariant.md` §1 → §4 · `01-ranh-gioi-he-thong.md` §2 · §3 ·
`02-thoi-gian-ngay-ban.md` §2 · `05-realtime-va-du-phong.md` §1.2 · §1.3 · §2 · §3 ·
`docs/product/1-system-design/architecture.md` §3.4 · §4 · §6.3 · §6.4 · §7 ·
`master_plan/shop-facts.md` §6.4 · §6.10 · §6.11 · §6.14 · §8.5 · kế hoạch §9 (ô thứ sáu) · §10.

## Goal

Pha 1 có một sổ rủi ro trong đó **mỗi** rủi ro có: **cơ chế chặn đã tồn tại ở một mục pha 1** (hoặc
một dòng ⛔ *chưa có cơ chế* kèm mã của chỗ đang thiếu), **người chịu**, và **một dấu hiệu nó đang
xảy ra** đo được bằng thứ quán đã có.

## Scope

Được sửa:
- `docs/product/1-system-design/06-so-rui-ro.md` — **file mới**, một chủ.
- `docs/product/00-index.md` — **một dòng** vào bảng *Pha 1*, cùng thay đổi (kế hoạch §5, luật 2).
- `docs/product/99-unknowns.md` — thêm câu hỏi mở nếu bước này gặp một chỗ nghiệp vụ chưa có lời.
- `work/findings.md` — thêm một `F-XXX` nếu gặp một rủi ro **chưa có cơ chế**.
- `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` — §5 (dòng bản đồ file), §6 (hai ô của **hàng
  P1-10**), §8 (một hàng nếu mở câu hỏi mới), §9 (**ô thứ sáu**, bỏ số đếm cứng — cùng đường
  ADR-042 đã đi cho cổng invariant).
- `prompt/SD/` — thêm file prompt này; `prompt/SD/README.md` — hàng P1-10 của bảng bước.
- `work/backlog_SD.md` — dòng *Prompt:*, dòng *Xong ngày…* và ô Mục lục của **entry P1-10**.
- `work/backlog.md` — dòng và entry P1-10.
- `work/scope.txt` — **thêm** khối của mình (F-010 · F-014).

Không được sửa:
- **`master_plan/phase_1_system_design_banh_cuon_ba_thanh.md`** — bản nháp, banner *"không sửa ở
  đây"* (**ADR-014**). Đọc để biết cái cũ nói gì, không sửa một chữ.
- **Bốn mục của bảng ba cột** (`03-bao-ve-invariant.md` §1–§4) và **mọi mục pha 1 khác** — sổ rủi ro
  **trỏ** vào chúng, không viết lại, không sửa nhân tiện (**F-010** · **F-014**).
- `quality/invariants.md` — không đổi lời một mệnh đề nào. Thấy một mệnh đề sai ⇒ `F-XXX`.
- `master_plan/shop-facts.md` — dữ kiện quán có nhà riêng (**ADR-001**).
- Entry *Done* lịch sử của bất kỳ bước nào (sửa tiến, không sửa lùi — **ADR-008**).

## Constraints

- **Mỗi dòng chỉ tên đúng một cơ chế ĐÃ VIẾT RA ở một mục pha 1, kèm chỗ đọc.** Không tự phát minh
  một cơ chế chưa ai viết.
- **Rủi ro chưa có cơ chế ⇒ ghi thẳng *chưa có cơ chế* và mở một bước hoặc một `F-XXX`** — đừng để
  nó trông như đã được chặn.
- **Không rủi ro nào được chặn bằng *"cẩn thận hơn"*.** Đó là ranh giới giữa sổ thật và sổ trang trí.
- **Hậu quả viết bằng chuyện xảy ra ở quán** — khách, két, bàn, người bấm — không bằng thuật ngữ.
- **Dấu hiệu phải đo được bằng thứ quán ĐÃ CÓ** (bảng đối soát cuối ngày, bảng quầy, cái vết, dòng
  *còn N lượt bán trên giấy chưa nhập*). Một dấu hiệu phải dựng thêm phép đo mới đo được là một dấu
  hiệu không ai đo (**F-012**).
- **Người chịu là một vai đã có** — *người đứng quầy* (POS) · *chủ quán* · *POS hoặc chủ quán*.
  Đặt ra vai mới là đặt ra một dữ kiện quán (`CLAUDE.md` §3.5).
- **Đừng đếm *"đúng năm rủi ro"* như một quyết định.** Con số năm đến từ bản nháp, là **phép đếm của
  người viết**; thấy cái thứ sáu thì thêm (**F-003**). Và **không** để một con số đếm động đứng làm
  điều kiện nghiệm thu ở kế hoạch (**F-018** · **F-026**).
- **Đừng xếp *mất realtime* ngang hàng *thu sai tiền*.** Mất kết nối có đường kéo dự phòng và đường
  suy giảm viết ra; thu sai tiền không có đường lùi nào.
- **Đừng chép bảng `R1`–`R5`**, và không mục pha 1 nào được trỏ về bảng ấy như một **owner**.
- **Ranh giới pha (ADR-035):** không tên bảng, tên cột, tên ràng buộc, endpoint, route, component.
- **Không mở lại nghiệp vụ** (`CLAUDE.md` §3.5): chỗ nghiệp vụ chưa rõ ⇒ `U-XXX`, không suy hộ.

## Unknowns

Không câu nào **chặn** bước này. Bước này **mở** ra chỗ chưa có lời mà nó gặp — và một chỗ như thế
đi vào `docs/product/99-unknowns.md` dạng **một gạch đầu dòng** trong vùng đang mở (`CLAUDE.md` §4),
không đi vào sổ rủi ro dạng một dòng trông như đã chặn.

## Acceptance

1. `docs/product/1-system-design/06-so-rui-ro.md` tồn tại, một chủ (**P1-10**), có bảng rủi ro với
   **sáu** cột: mã · rủi ro · hậu quả ở quán · cơ chế chặn kèm chỗ đọc · người chịu · dấu hiệu.
2. **Không ô nào trống.** Dòng nào chưa có cơ chế thì cả ba ô *cơ chế · người chịu · dấu hiệu* nói
   thẳng là **chưa có / chưa đo được**, kèm mã của chỗ đang thiếu.
3. **Mỗi dòng đã-có-cơ-chế trỏ tới ít nhất một mục pha 1 có thật**, và đường dẫn ấy mở được
   (Gate 1b chấm).
4. Ba luật đường tiền chốt sau bản nháp — **nợ · hoàn tiền · đối soát ba nguồn** — đều có mặt trong
   bảng, mỗi thứ ít nhất một dòng.
5. Không dòng nào chứa *"cẩn thận hơn"*, *"chú ý hơn"*, *"nhớ kiểm tra"* làm cơ chế.
6. `docs/product/00-index.md` có **một** dòng mới cho file này, trong cùng thay đổi.
7. Kế hoạch §9 ô thứ sáu **không còn đếm một con số cứng**; §6 hàng P1-10 cũng vậy (**F-018**).
8. Không mục pha 1 nào trỏ về bảng `R1`–`R5` của bản nháp như một **owner**.
9. `quality/invariants.md` và `master_plan/shop-facts.md` không đổi một chữ.
10. Không dòng nào chứa tên bảng · tên cột · tên ràng buộc · endpoint · route · component.
11. Mọi mã mở ra trong lượt (`U-XXX`, `F-XXX`) có mặt ở đúng owner của nó và ở bảng tổng hợp của
    owner ấy.
12. `./scripts/gate.sh` xanh.

## Verify

```bash
# (1) file có mặt, sáu cột, và bảng rủi ro
grep -n '^| Mã | Rủi ro' docs/product/1-system-design/06-so-rui-ro.md
grep -c '^| \*\*RR-' docs/product/1-system-design/06-so-rui-ro.md   # số dòng rủi ro — ĐỌC, đừng chốt nó thành nghiệm thu (F-018)

# (2) không ô nào trống — bắt ô rỗng dạng "| |" hoặc "|  |"
grep -n '^| \*\*RR-' docs/product/1-system-design/06-so-rui-ro.md | grep -nE '\|\s*\|'   # rỗng

# (3) mỗi dòng có cơ chế phải trỏ một mục pha 1 — đọc TAY danh sách file được trỏ
grep -o '\](0[1-9]-[a-z-]*\.md)\|\](architecture\.md)' docs/product/1-system-design/06-so-rui-ro.md | sort | uniq -c

# (4) ba luật đường tiền chốt sau bản nháp đều có mặt
grep -n 'nợ\|hoàn tiền\|tin nhắn báo có' docs/product/1-system-design/06-so-rui-ro.md | head

# (5) không cơ chế nào là một lời khuyên — lọc TRÊN DÒNG RỦI RO, không trên cả file:
#     mục §0 luật 2 nêu đúng ba cụm ấy để CẤM chúng, và một bộ lọc cả file sẽ bắt chính câu cấm (F-018)
grep '^| \*\*RR-' docs/product/1-system-design/06-so-rui-ro.md \
  | grep -nEi 'cẩn thận hơn|chú ý hơn|nhớ kiểm tra'   # rỗng
grep -nEi 'cẩn thận hơn|chú ý hơn|nhớ kiểm tra' docs/product/1-system-design/06-so-rui-ro.md   # lệnh chưa lọc, in cạnh (F-017)

# (6) dòng chưa có cơ chế phải NÓI THẲNG
grep -n 'chưa có cơ chế' docs/product/1-system-design/06-so-rui-ro.md

# (7) kế hoạch không còn đếm cứng ở ô cổng thứ sáu và ở hàng P1-10
grep -n 'Năm rủi ro\|Năm dòng' master_plan/SD_master_plan_banh_cuon_ba_thanh.md   # rỗng

# (8) không mục pha 1 nào trỏ về bảng bản nháp như một owner
grep -rn 'R1\b' docs/product/1-system-design/ | grep -v 'RB-1\|RR-1'   # đọc từng dòng

# (9) hai owner không đổi một chữ
git diff --stat -- quality/invariants.md master_plan/shop-facts.md   # rỗng

# (10) ranh giới pha ADR-035 — in cả lệnh CHƯA lọc cạnh lệnh đã lọc (F-017)
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md | grep -c '^+'
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -E '^\+' \
  | grep -nEi 'CREATE TABLE|FOREIGN KEY|UNIQUE\(|CHECK \(|\bGET /|\bPOST /|/api/'   # rỗng

# (11) cổng của repo
./scripts/gate.sh
```

## Report (AI trả lời sau khi làm)

1. Danh sách rủi ro, mỗi cái một câu: cơ chế nào đang giữ nó và **ở mục nào** — và với dòng chưa có
   cơ chế: mã của chỗ đang thiếu, cùng ba đường ra đã ghi mà **không** chọn hộ.
2. Ba luật đường tiền chốt sau bản nháp đi vào những dòng nào.
3. Năm dòng `R1`–`R5` của bản nháp đi đâu — dòng nào lên sổ, dòng nào ở lại bảng bảo vệ, và vì sao.
4. Mọi mã mở ra trong lượt (`U-XXX` · `F-XXX`), kèm link tới đúng dòng nó được viết (`CLAUDE.md`
   §7.3).
5. Output thật của mục *Verify* và của `./scripts/gate.sh`.
6. Khối `git commit` dán được (`CLAUDE.md` §6.1) — **không** có `work/scope.txt` trong khối.
