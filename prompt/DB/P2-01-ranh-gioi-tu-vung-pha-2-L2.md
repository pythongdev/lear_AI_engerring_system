# P2-01 — Ranh giới và từ vựng của cả pha 2 (L2) · pha 2, bước 1/14

> Bước **1/14** của pha 2 — `master_plan/DB_master_plan_banh_cuon_ba_thanh.md` §6
> (`docs/decisions.md` **ADR-049**). Mô tả dài ở `work/backlog_DB.md` → **P2-01**; trạng thái ở
> `work/backlog.md`. Bước này **mở khoá** mười ba bước còn lại: `P2-02` và `P2-03` ghi thẳng
> *Cần xong trước: P2-01*, và mọi bước sau đứng trên hai bước ấy.
>
> **Đây là lane prompt đầu tiên của pha 2.** Luật của lane ở `prompt/DB/` → `README.md`.

## Context

- **`master_plan/DB_master_plan_banh_cuon_ba_thanh.md` §7** — bảng năm tầng và **ba luật khi
  dịch**. Đây là đầu vào chính của bước; bước này **ghi nó vào owner**, không dựng nó mới.
- **`master_plan/DB_master_plan_banh_cuon_ba_thanh.md` §3** — ba câu pha 2 **không** được viết ra,
  và hai thứ pha 2 **không** mở lại (nghiệp vụ · tầng bảo vệ).
- **`docs/product/1-system-design/03-bao-ve-invariant.md`** — mục §0 giữ *cách đọc ba cột*, và luật
  đọc thứ **4** của nó là câu bước này phải mang sang pha 2 nguyên vẹn:

  > *"Mọi câu **"tầng 1"** ở đây là YÊU CẦU gửi pha 2, không phải một ràng buộc đã có."*

  §1 · §2 · §3 · §4 là bốn nhóm mệnh đề. Đọc **danh sách mã**, đừng đọc một con số đếm
  (`work/findings.md` **F-026** · **F-018**).
- **`quality/invariants.md`** — nhà của lời từng mệnh đề `I-0xx`. Bước này **không** đọc để dựng
  gì; nó đọc để biết tập mã mà từ vựng phải phủ.
- **`docs/decisions.md` ADR-035** — ranh giới sở hữu chạy theo pha: lược đồ ở pha 2 · hợp đồng API
  ở pha 3 · route ở pha 4 · **tầng bảo vệ ở pha 1**.
- **`docs/decisions.md` ADR-049 điểm 4** — đã nêu **tên** năm thứ pha 2 phải dựng (ràng buộc · ranh
  giới giao dịch · một đường ghi duy nhất · chỗ cất vết · một câu truy vấn ra 0 dòng) và luật
  *không tự hạ tầng*. Bước này **không lật** điểm ấy: nó viết **nghĩa đầy đủ** và **phép chấm** của
  từng thứ, thứ ADR-049 cố ý để lại.
- **`docs/decisions.md` ADR-039** — Gate 1d. Vùng pha 2 hôm nay chưa được chấm; việc dạy cổng ấy là
  **`P2-02`**, không phải bước này.
- **`docs/product/1-system-design/architecture.md` §12.3** — chỗ duy nhất trong repo hôm nay
  **trông** như đã có ràng buộc. Nó **tự khai là đề xuất gửi sang pha 2**. Đọc đúng như thế.

## Goal

Câu *"hàng **tầng 1** này phải thành cái gì trong lược đồ, và chấm bằng gì"* có **đúng một** câu
trả lời, đọc được ở một ADR trong `docs/decisions.md`, và mười ba bước sau trích được từ nó thay vì
tự định nghĩa lại chữ *ràng buộc*. Cổng chất lượng §9 của kế hoạch pha 2 có một **thước** để chấm,
thay vì một cảm giác.

## Scope

Được sửa:
- `docs/decisions.md` — **ADR-050** (mới) + một dòng ở bảng tổng hợp đầu file
- `prompt/DB/` — `README.md` (mới, dựng lane) và file prompt này
- `scripts/check-links.sh` — thêm `prompt/DB/*` vào danh sách Gate 1b chấm
- `work/backlog.md` — chuyển `P2-01` sang *In Progress* rồi sang *Done*, thêm dòng *Ready* cho
  `P2-02` và `P2-03`
- `work/backlog_DB.md` — dòng *✅ Xong ngày…* ở đầu entry `P2-01` + cột *Trạng thái* ở *Mục lục*

Không được sửa:
- `quality/invariants.md` — lời mệnh đề có nhà ở đó (**ADR-035** · **F-001**)
- `docs/product/1-system-design/` — pha 1 sở hữu **tầng**; bước này thi hành, không sửa
- `master_plan/shop-facts.md` — dữ kiện quán (**ADR-001**)
- `docs/product/` — **không** mở `2-db/` ở lượt này; thư mục ấy ra đời ở `P2-03`
- `scripts/check-phase-boundary.sh` — việc của `P2-02`

## Constraints

- **Không một dòng lược đồ nào.** Không tên bảng, không tên cột, không khoá ngoại, không câu
  `CREATE TABLE` làm ví dụ. Một ví dụ ở đây sẽ được mười ba bước sau đọc như lược đồ đã chốt — đúng
  cách đề xuất 16 bảng ngày 2026-08-31 suýt trở thành lược đồ thật (kế hoạch §10).
- **Không mở `docs/product/2-db/`.** File rỗng có tên sẵn là tài liệu nghi lễ (`CLAUDE.md` §3.8);
  kế hoạch §5 chốt thư mục ra đời ở `P2-03`, cùng dòng nội dung đầu tiên.
- **Giữ nguyên nghĩa của năm tầng.** Tầng là của pha 1 (**ADR-035**); bước này **dịch**, không
  **định lại**. Thấy một hàng tầng ở pha 1 sai ⇒ một `F-XXX` gửi ngược, không sửa tại chỗ.
- **Invariant liên quan:** cả tập `I-001`…`I-021` — bước này không chạm một mệnh đề nào, nhưng từ
  vựng nó chốt sẽ quyết định cách **cả tập** được thi hành ở `P2-04`…`P2-08` và `P2-11`.
- **Gặp chỗ phải chọn giữa hai cách dịch ⇒ hỏi chủ repo trước khi ghi.** Gặp chỗ nghiệp vụ chưa rõ
  ⇒ `U-XXX` (`CLAUDE.md` §3.5 — luật này **không có mức L0**).
- **Lane mới phải vào Gate 1b trong cùng thay đổi** (**F-007**).

## Acceptance

- `docs/decisions.md` có **ADR-050**, và với **mỗi** tầng trong năm tầng nó nói đủ **ba** ô: pha 2
  **nợ cái gì** · chấm **bằng gì** · **cái gì KHÔNG phải** biên nhận của tầng ấy.
- ADR-050 kể tên **ba câu pha 2 không được viết ra** (endpoint/chữ ký · route/component · cơ chế
  vận hành) và với mỗi câu nói **pha 2 được viết gì thay vào**.
- ADR-050 chốt **ba luật khi dịch** thành lời có thể chấm: không tự hạ tầng · mỗi mệnh đề vẫn có
  câu truy vấn của nó kể cả khi ràng buộc đã ở tầng 1 · một câu truy vấn chưa bao giờ ra khác 0 là
  một câu chưa được chứng minh.
- Bảng tổng hợp đầu `docs/decisions.md` có **một** dòng cho ADR-050, và dòng ấy không nói ngược
  thân mục (Gate 1c chấm đúng chuyện này).
- `prompt/DB/README.md` tồn tại, và `scripts/check-links.sh` chấm `prompt/DB/*` — chứng minh bằng
  một đường dẫn **cố tình sai** trong một file của lane ⇒ Gate 1b **đỏ**, rồi sửa lại ⇒ **xanh**.
- **Không** file nào dưới `docs/product/2-db/` tồn tại sau lượt này. Chứng minh: `ls docs/product/`.
- `grep -rn 'tầng 1'` không ra một chỗ nào nói ngược ADR-050.

## Verify

```bash
./scripts/gate.sh
ls docs/product/                 # KHÔNG được có 2-db/
bash scripts/check-links.test.sh # bộ ca cũ vẫn xanh sau khi thêm lane
grep -rn 'prompt/DB' scripts/check-links.sh
```

Gate 1b · 1c · 1d chạy ở mọi lượt; `verify.sh` chạy ở lượt này vì `scripts/` có đổi — dán output
của cả hai.

## Unknowns

Không có câu hỏi **nghiệp vụ** nào trong bước này: nó không chạm một dữ kiện quán nào.

Ba chỗ **ADR-049 cố ý để lại cho chủ repo** vẫn để nguyên, bước này **không** trả lời hộ: lược đồ
admin đi cùng pha 2 hay theo lane của nó · ba hàng `CLAUDE.md` §2 đổi ở ba bước khác nhau hay đổi
hết ở lượt mở thư mục · nhà cho `work/findings.md` **F-034**.
