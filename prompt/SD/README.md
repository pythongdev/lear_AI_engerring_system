# Prompt SD — pha 1 · System design · Bánh cuốn Bà Thanh Cao Bằng

Bộ prompt để chạy **pha 1** mô tả ở `master_plan/SD_master_plan_banh_cuon_ba_thanh.md`.
Một file một bước, mã bước là **`P1-XX`** — không phải `SD-XX` (`docs/decisions.md` **ADR-033**:
bản nháp cũ đã dùng `SD-01` cho hai nghĩa khác nhau, thêm nghĩa thứ ba là dựng lại bẫy
`work/findings.md` **F-015** · **F-021** · **F-022**).

Viết theo `docs/prompt-guideline.md`. Kiểm kết quả theo `quality/review-gate.md`.

## Ba lane prompt, đừng lẫn

| Lane | Pha | Nội dung |
|---|---|---|
| `prompt/BA/` | pha 0 · BA | hành vi nghiệp vụ — *quán làm gì, ai thao tác, tiền đi đường nào* |
| **`prompt/SD/`** | **pha 1 · System design** | **cái gì bảo vệ cái gì** |
| `prompt/maintenance/` | — | sửa chính cái repo này, không thuộc pha nào |

`prompt/BA/` và `prompt/SD/` **được Gate 1b chấm** (`scripts/check-links.sh`): mọi đường dẫn viết
trong một file ở đây phải mở được. `prompt/maintenance/` thì không — ở đó một đường đã chết được
trích dẫn làm bằng chứng.

⚠️ **Hệ quả khi viết prompt trong thư mục này:** đường dẫn của một file **đầu ra chưa tồn tại**
không được viết **đủ cả thư mục lẫn tên file trong một dấu nháy ngược** — Gate 1b sẽ đỏ ngay khi
file prompt được `git add`. Viết **tên file trần** (`01-ranh-gioi-he-thong.md`) cạnh thư mục chứa
nó (`docs/product/1-system-design/`), thành hai mẩu. Cả hai đều đọc được, và không mẩu nào là một
đường chết.

Chính dòng cảnh báo này từng vi phạm luật của nó: bản đầu nêu ví dụ sai bằng một đường dẫn thật có
đuôi `.md`, và Gate 1b in nó ra ngay lượt viết README. Ghi lại vì đó là bằng chứng rẻ nhất rằng
cổng chạy đúng — và vì một ví dụ về đường chết vẫn là một đường chết.

## Ba nguồn input, không phải một

| Nguồn | Cho cái gì | Ai là nhà thật |
|---|---|---|
| `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` | **thứ tự · mức · đầu ra kiểm chứng được** của mười hai bước, năm tầng bảo vệ (§7), cổng sang pha 2 (§9) | kế hoạch — **không sở hữu sự thật nào** |
| `work/backlog_SD.md` | **mô tả dài** của từng bước: vì sao có nó, hỏng thì mất gì, mười bước chạy | sổ task pha 1 — không giữ trạng thái |
| `work/backlog.md` | **trạng thái** *Ready* / *In Progress* / *Done* của mọi bước | owner của Tasks (`docs/decisions.md` **ADR-002** · **ADR-034**) |

Dữ kiện quán thì **không** nằm ở ba chỗ trên: `master_plan/shop-facts.md` là nhà duy nhất
(**ADR-001**). Kiến trúc đang có hiệu lực ở `docs/product/1-system-design/architecture.md` §1–§14.
Mệnh đề bất biến ở `quality/invariants.md`.

## Ranh giới cứng của pha 1 — ba câu không được xuất hiện trong đầu ra

`master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §3, và nay là quyết định có mã:
`docs/decisions.md` **ADR-035** (2026-09-04, bước P1-01).

| Không được viết ra ở pha 1 | Owner của nó | Pha 1 viết gì thay vào |
|---|---|---|
| tên bảng · tên cột · khoá ngoại | **pha 2 · DB** | *"trạng thái này phải do **cơ sở dữ liệu** giữ, không phải do màn hình kiểm"* |
| endpoint · tên hàm · chữ ký API | **pha 3 · BE** | *"chỉ **một** chỗ trong hệ thống được tính giá, và mọi đường đặt món đi qua nó"* |
| route · component · kích thước chữ | **pha 4 · FE** | *"màn trạm **không có nút nào** ghi ra tiến độ"* (**ADR-011**) |

⚠️ **Không cổng nào của repo đọc được ranh giới này.** Một tên bảng viết vào tài liệu pha 1 đi qua
cả năm cổng mà không cổng nào đỏ — rủi ro ấy được ghi thẳng trong ADR-035, và phép rà duy nhất là
**P1-12**, chạy một lần, cuối pha. Nên mỗi prompt ở đây tự mang bộ lọc của nó trong mục *Verify*,
và luôn in **cả lệnh chưa lọc** cạnh lệnh đã lọc (`work/findings.md` **F-017**).

**Pha 1 cũng không mở lại nghiệp vụ.** Gặp chỗ nghiệp vụ chưa rõ ⇒ hỏi chủ quán, hoặc ghi `U-XXX`
(`CLAUDE.md` §3.5 · §4). Luật này không có mức L0.

## Năm tầng bảo vệ — từ vựng bắt buộc của P1-04 · P1-05 · P1-06

Ba bước ấy viết ba mảnh của **một** bảng, nên cột giữa chỉ nhận đúng một trong năm giá trị, xếp
mạnh dần: **1** cơ sở dữ liệu giữ · **2** một giao dịch giữ · **3** miền nghiệp vụ giữ · **4**
người + thủ tục giữ (máy chỉ nhắc, để vết) · **5** phép đối chiếu bắt sau khi hỏng.

Định nghĩa đầy đủ và ba luật khi điền ở kế hoạch §7 — **đọc ở đó, đừng đọc bản tóm này**. Luật
đắt nhất: *ghi tầng CAO NHẤT thật sự đang giữ nó, không ghi tầng mình muốn nó ở*.

## Mười hai bước — bước nào đã có prompt

| Bước | Mức | Prompt | Cần xong trước |
|---|:--:|---|---|
| P1-01 | L2 | [`P1-01-ranh-gioi-so-huu-L2.md`](P1-01-ranh-gioi-so-huu-L2.md) — **đã chạy 2026-09-04** | — |
| P1-02 | L2 | [`P1-02-ranh-gioi-he-thong-L2.md`](P1-02-ranh-gioi-he-thong-L2.md) | P1-01 ✔ |
| P1-03 | L2 | [`P1-03-ngay-ban-L2.md`](P1-03-ngay-ban-L2.md) | P1-01 ✔ · ⛔ **U-032** |
| P1-04 | L2 | **chưa viết** — chờ P1-03 ra định nghĩa *ngày bán* | P1-01 ✔ · P1-03 |
| P1-05 | L2 | [`P1-05-invariant-vong-doi-L2.md`](P1-05-invariant-vong-doi-L2.md) | P1-01 ✔ |
| P1-06 | L2 | [`P1-06-invariant-menu-gia-vet-L2.md`](P1-06-invariant-menu-gia-vet-L2.md) | P1-01 ✔ |
| P1-07 | L2 | **chưa viết** — chờ ba bảng ba cột | P1-04 · P1-05 · P1-06 |
| P1-08 | L2 | **chưa viết** — chờ danh sách phụ thuộc ngoài của P1-02 | P1-02 |
| P1-09 | L2 | [`P1-09-bang-quay-bon-con-so-L2.md`](P1-09-bang-quay-bon-con-so-L2.md) | BA-12 ✔ · ⚠️ **S-5** |
| P1-10 | L1 | **chưa viết** — mỗi rủi ro phải chỉ tên một cơ chế đã viết ra | P1-04 · P1-05 · P1-06 |
| P1-11 | L2 | **chưa viết** | P1-02 → P1-10 |
| P1-12 | L1 | **chưa viết** | P1-11 |

**Vì sao sáu bước còn lại chưa có prompt, và đó không phải nợ.** Kế hoạch §6 cấm viết prompt hộ:
*"một prompt viết trước khi biết bước trước đã ra kết quả gì sẽ mang những câu Constraints đã chết"*
(`work/findings.md` **F-013** · **F-017**). Chủ repo chốt 2026-09-04 cách đọc luật ấy cho được:
**viết được prompt của một bước khi mọi bước ở cột *Cần xong trước* của nó đã *Done*** — đầu ra để
viết Constraints và Verify khi ấy đã có thật, không phải đoán. Năm prompt trên là đúng tập ấy tính
tới hôm nay; sáu bước còn lại viết khi tiền đề của chúng xong.

⚠️ **Một câu hỏi đang mở đè lên ba bước bảng ba cột:** `work/findings.md` **F-026** — `I-019` và
`I-020` sinh ra ở BA-12 ngày 2026-09-03, **sau** khi kế hoạch chia nhóm, nên chúng **không thuộc
nhóm nào** của P1-04 · P1-05 · P1-06, và cổng chất lượng §9 vẫn đếm *"mười tám"* trong khi
`quality/invariants.md` giữ **hai mươi**. Ai nhận P1-04 · P1-05 · P1-06 đọc F-026 trước.

## Cách dùng một prompt

1. **Gate 0** — mở prompt, đọc mục *Scope*, **thêm** khối scope của mình vào `work/scope.txt`.
   Có phiên khác đang chạy thì **thêm**, đừng ghi đè (**F-010** · **F-014**).
2. Tạo dòng trạng thái của bước ở `work/backlog.md` → *In Progress* (dòng ấy **chỉ** tạo lúc nhận
   việc — `brief.sh` cắt danh sách *Ready* ở sáu mục, **F-012**).
3. Dán toàn bộ nội dung prompt vào session mới (context sạch).
4. Mục *Unknowns* không rỗng ⇒ trả lời trước, hoặc viết phần liên quan theo **phương án hẹp nhất**
   và ghi thẳng là đang treo. Không tự chọn phương án rộng rồi ghi như đã chốt.
5. **Gate 1 + 1b + 1c + 3** — `./scripts/gate.sh` (chạy tự động qua Stop hook).
6. **Gate 2** — soi từng dòng *Acceptance*, chỉ ra bằng chứng.
7. Xong ⇒ tick *Done* ở `work/backlog.md`, thêm dòng *Xong ngày…* vào entry ở `work/backlog_SD.md`,
   dọn khối scope của mình, và giao khối `git commit` dán được (`CLAUDE.md` §6.1).

## Khi bạn viết prompt cho một bước còn lại

Sáu khối của `docs/prompt-guideline.md`, cộng *Unknowns* và *Report*. Bốn thứ mà năm prompt hiện có
đều làm, và làm vì một lý do đã tốn tiền:

- **Context dẫn bằng dòng thật**, có số mục, ở owner — không kể lại nội dung của nó (`CLAUDE.md`
  §7.1: pointer, không phải bản chép; **F-001**).
- **Scope có phần *Không được sửa* dài hơn phần *Được sửa*.**
- **Verify in cả lệnh chưa lọc cạnh lệnh đã lọc** — một bộ lọc rỗng vì viết sai trông y hệt một bộ
  lọc rỗng vì không có lỗi (**F-017**).
- **Không dùng một con số đếm động làm điều kiện nghiệm thu** (**F-018**), và lọc theo **khối** chứ
  không theo **dòng** khi câu cần lọc có thể gói dòng (**F-015**).
