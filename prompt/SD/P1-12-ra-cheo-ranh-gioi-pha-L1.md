# P1-12 — Rà chéo ranh giới pha: một PHÉP ĐO trên cả pha 1, không phải một lượt dọn (L1) · bước 12/14

> Bước **12/14** của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6. Mô tả dài ở
> `work/backlog_SD.md` → **P1-12**; trạng thái ở `work/backlog.md`.
> **Cần xong trước:** P1-11 — **đã xong 2026-09-08** (`docs/product/1-system-design/07-cong-chat-luong-pha-1.md`).
> **Mức L1, không phải L2:** bước này **không quyết định một thiết kế nào** — nó đo, rồi định
> tuyến cái đo được. Ceremony theo `CLAUDE.md` §3.

## Context

Ranh giới cứng của bảng sáu pha — *pha 0–1 **không** nhắc tên bảng; pha 2 **không** nhắc endpoint;
pha 3 **không** nhắc component* (`docs/decisions.md` **ADR-035**, kế hoạch §3) — là luật mà **không
cổng nào của repo chấm đủ**. `check-links.sh` chấm đường dẫn · `check-doc-status.sh` chấm một mã hai
trạng thái · `verify.sh` bị bỏ qua ở lượt chỉ-đổi-tài-liệu. `check-phase-boundary.sh` (Gate 1d,
**ADR-039**) chấm được một phần, nhưng nó **cố ý bảo thủ** và **chỉ quét file đã đổi trong lượt** —
chính header của nó viết *"Nó KHÔNG bắt hết. P1-12 và mắt người vẫn là lớp cuối."*

Có sẵn **một** chỗ dễ vấp: `architecture.md` **§12.3** cố ý vượt ranh giới (chủ repo yêu cầu thẳng
một mục DB cho phần nợ) và **tự khai** điều đó ngay trong mục. Bộ lọc phải kể nó ra như một **ngoại
lệ có tên**, không phải như một lỗi — và cũng **không** được im lặng bỏ qua.

Đọc trước khi chạy dòng đầu tiên: kế hoạch §3 (ba câu không được viết ra) · §9 (ô thứ mười) ·
`docs/product/1-system-design/architecture.md` §8 và §12.3 ·
`docs/product/1-system-design/07-cong-chat-luong-pha-1.md` §7 (chỗ ký) ·
`scripts/check-phase-boundary.sh` + `scripts/check-phase-boundary.ignore`.

## Goal

Ô **10** của cổng chất lượng pha 1 hết là *"chưa ai đo"* và trở thành *"đã đo, và đây là cái đo
được"*: một phép đo chạy trên **cả tám** file pha 1, dán **cả lệnh chưa lọc lẫn lệnh đã lọc**, mỗi
chỗ lọt ra hoặc là **ngoại lệ có tên**, hoặc có **một mã** và **một owner**.

## Scope

Được sửa:
- `docs/product/1-system-design/07-cong-chat-luong-pha-1.md` — §7 ô 10 (chỗ ký), và **chỉ** ô ấy.
- `prompt/SD/P1-12-ra-cheo-ranh-gioi-pha-L1.md` — file này; `prompt/SD/README.md` — hàng P1-12.
- `work/backlog.md` · `work/backlog_SD.md` — dòng và entry P1-12.
- `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` — §9 (câu *"ô thứ mười chờ P1-12"*), §6 (ô của
  hàng P1-12), §5 nếu bản đồ file đổi.
- `docs/product/99-unknowns.md` · `work/findings.md` — mã mở ra trong lượt.
- `docs/product/00-index.md` — **chỉ khi** pha 1 thật sự đóng (xem *Constraints*).
- `work/scope.txt` — **thêm** khối của mình (F-010 · F-014).

Không được sửa:
- **Bảy file nội dung của pha 1** (`01-…` → `06-…` và `architecture.md`) — bước này **đo**, không
  dọn. Chỗ lọt ra trả về **bước đã viết nó**, vì người viết mục ấy mới biết câu đúng phải là gì.
- **`scripts/`** — thấy cổng nào chấm hụt thì ghi `F-XXX`, **không** sửa cổng trong lượt đo, và
  **không** dựng cổng shell mới (`CLAUDE.md` §3.8 — luật chỉ dựng khi cùng một vấn đề đã tốn hai
  lần, đây mới là lần đo đầu tiên).
- `quality/invariants.md` · `master_plan/shop-facts.md` — hai owner có nhà riêng.
- Entry *Done* lịch sử của bất kỳ bước nào (sửa tiến, không sửa lùi — **ADR-008**).

## Constraints

- **In cả lệnh CHƯA lọc cạnh lệnh đã lọc, mọi lần.** Một bộ lọc rỗng vì viết sai trông **y hệt**
  một bộ lọc rỗng vì không có lỗi (`work/findings.md` **F-017**, đã xảy ra đúng thế ở prompt DOC-5).
- **Đừng đếm rộng hơn phạm vi.** Tập bị rà là `docs/product/1-system-design/*.md` và **chỉ** nó. Một
  con số đếm cả `work/` và `prompt/maintenance/` thì đo hoạt động viết lách, không đo việc còn lại
  (**F-018**).
- **Ngoại lệ phải CÓ TÊN.** §12.3 được kể ra kèm lý do và kèm ranh giới của chính nó — một ngoại lệ
  không có tên thì lần sau thành tiền lệ, và §12.3 sẽ được viện dẫn để đưa thêm lược đồ vào pha 1.
- **Đừng tick hộ ô 10.** Kế hoạch §9: *một ô không tick được thì để trống kèm lý do và mã của chỗ
  đang chặn*. Bài học `BA-11`: cổng 9/10 kèm lý do thì dùng được, cổng 10/10 bằng cảm giác thì không
  chặn được gì.
- **Pha 1 đóng là chữ ký của CHỦ REPO**, không phải hệ quả của một ô xanh (cổng chất lượng §8:
  *"Ai nói câu được, sang pha 2"*). Bảng *Sáu pha* ở `docs/product/00-index.md` chỉ đổi khi chữ ký
  ấy có thật.
- **Định danh nghiệp vụ KHÔNG phải tên bảng.** `qr_table` · `staff_pos` · `phone_preorder` ·
  `trang_banh` · `gap_banh` · `don_ban` là **kênh bán** và **trạm**, có nhà ở `master_plan/shop-facts.md`
  §5 · §3 — pha 0 sở hữu chúng. Một bộ lọc kêu chúng lên là bộ lọc đo sai thứ.

## Unknowns

Không câu nào **chặn** bước này. Bước này **mở** ra chỗ nó gặp — và một chỗ như thế đi vào
`docs/product/99-unknowns.md` dạng **một gạch đầu dòng** trong vùng đang mở (`CLAUDE.md` §4), hoặc
vào `work/findings.md` nếu nó là một chỗ hỏng chứ không phải một câu hỏi nghiệp vụ.

## Acceptance

1. Tập bị rà được **nêu đích danh**: tám file `docs/product/1-system-design/*.md`, kèm số dòng của
   từng file và tổng — đó là **lệnh chưa lọc** ở mức thô nhất.
2. Bộ lọc chạy **ít nhất** năm lượt, mỗi lượt một họ mẫu: pha 2 SQL/DDL · pha 2 định danh
   `snake_case` và `bảng.cột` · pha 3 động từ HTTP (**kể cả khi đường dẫn không mở đầu bằng `/`**) ·
   pha 4 route/component/đuôi file mã · ràng buộc SQL (`UNIQUE` · `CHECK` · …).
3. **Mỗi** lượt in kết quả kèm con số chưa lọc của chính lượt ấy (**F-017**).
4. Mọi chỗ khớp được **phân loại đủ ba nhóm**, không chỗ nào để lửng: *ngoại lệ có tên* · *định danh
   nghiệp vụ có owner ở pha 0* · *chỗ lọt ra thật*.
5. **Mỗi chỗ lọt ra thật** có: mục nó nằm trong · `git blame` ngày và commit sinh ra nó · một mã
   `F-XXX` ở `work/findings.md`. **Không lượt nào sửa nó ở đây.**
6. Pointer pha 1 rà lần cuối: `./scripts/check-links.sh` xanh, **cộng** hai phép kiểm bằng mắt mà nó
   không làm — pointer trỏ **thư mục** (kết thúc bằng `/`, **F-018**) và pointer **neo `#`**.
7. Ô **10** của `07-cong-chat-luong-pha-1.md` §7 mang kết quả đo, nêu tên §12.3 như ngoại lệ, và
   **hoặc** tick kèm lý do **hoặc** để trống kèm mã chỗ chặn — không tick trơn.
8. Bảy file nội dung pha 1 **không đổi một chữ**.
9. `scripts/` **không đổi một chữ**.
10. Mọi mã mở ra trong lượt có mặt ở đúng owner **và** ở bảng tổng hợp của owner ấy.
11. `./scripts/gate.sh` xanh.

## Verify

```bash
# (1) tập bị rà — lệnh chưa lọc ở mức thô nhất
wc -l docs/product/1-system-design/*.md

# (2) LƯỢT A — Gate 1d nguyên văn, nhưng chạy trên CẢ TÁM file
#     (Gate 1d thật chỉ quét file đã đổi trong lượt, nên nó chưa từng chạy trên cả tập)
PAT_DB='CREATE[[:space:]]+TABLE|ALTER[[:space:]]+TABLE|DROP[[:space:]]+TABLE|FOREIGN[[:space:]]+KEY|PRIMARY[[:space:]]+KEY|REFERENCES[[:space:]]+[a-z_]+[[:space:]]*\(|\b(VARCHAR|BIGINT|SERIAL|TIMESTAMPTZ|NOT[[:space:]]+NULL)\b'
PAT_API='\b(GET|POST|PUT|PATCH|DELETE)[[:space:]]+/|/api/|/v[0-9]+/'
PAT_FE='\.(jsx|tsx|vue)\b|<[A-Z][A-Za-z]+[[:space:]]*/?>'
grep -nEI "$PAT_DB|$PAT_API|$PAT_FE" docs/product/1-system-design/*.md

# (3) LƯỢT B — động từ HTTP + đường dẫn KHÔNG mở đầu bằng `/`: đúng chỗ PAT_API mù
grep -nEI '\b(GET|POST|PUT|PATCH|DELETE)[[:space:]]+[A-Za-z]' docs/product/1-system-design/*.md

# (4) LƯỢT C — từ khoá ràng buộc SQL
grep -nEIw 'UNIQUE|CHECK|INDEX|CASCADE|CONSTRAINT|JOIN|SELECT|INSERT' docs/product/1-system-design/*.md

# (5) LƯỢT D — định danh snake_case trong backtick (ứng viên tên bảng / tên cột)
#     PHẢI đọc tay: phần lớn là KÊNH BÁN và TRẠM, pha 0 sở hữu (shop-facts.md §5 · §3)
grep -oEI '`[a-z][a-z0-9]*_[a-z0-9_]+`' docs/product/1-system-design/*.md | sort | uniq -c | sort -rn

# (6) LƯỢT D2 — `bảng.cột`, trừ tên file .md
grep -nEI '`[a-z][a-z0-9_]*\.[a-z][a-z0-9_]*`' docs/product/1-system-design/*.md | grep -v '\.md`'

# (7) LƯỢT E — pha 4: route · component · đuôi file mã
#     lệnh này CỐ Ý không rỗng: nó bắt chính những câu TỰ KHAI "ở đây không có route"
grep -nEI '\.(jsx|tsx|vue|ts|js|css)\b|<[A-Z][A-Za-z]+[[:space:]]*/?>|\broute\b|\bcomponent\b|useState|className' docs/product/1-system-design/*.md
grep -nEI '(^|[^a-z.`])/[a-z][a-z0-9-]*/[a-z]' docs/product/1-system-design/*.md \
  | grep -v '\.md\|docs/\|work/\|scripts/\|quality/\|master_plan/\|prompt/'   # rỗng

# (8) pointer — số chưa lọc, rồi hai phép Gate 1b KHÔNG làm
grep -ohE '\]\([^)]+\)' docs/product/1-system-design/*.md | wc -l      # tổng pointer
grep -nE '\]\([^)]*/\)'   docs/product/1-system-design/*.md            # trỏ THƯ MỤC — F-018
grep -ohE '\]\([^)]*#[^)]+\)' docs/product/1-system-design/*.md | sort -u   # neo #
for f in docs/product/1-system-design/*.md; do
  u=$(grep -c ']( *#top)' $f); a=$(grep -c 'id="top"' $f)
  [ "$u" -gt 0 ] && [ "$a" -eq 0 ] && echo "⛔ neo chết: $f"
done
./scripts/check-links.sh

# (9) blame từng chỗ lọt ra — trả nó về bước đã viết nó
git blame -L <dòng>,<dòng> --date=short -- docs/product/1-system-design/architecture.md

# (10) bảy file nội dung và scripts/ không đổi một chữ
git diff --stat -- docs/product/1-system-design/0*.md \
                   docs/product/1-system-design/architecture.md scripts/   # rỗng

# (11) cổng của repo
./scripts/gate.sh
```

## Report (AI trả lời sau khi làm)

1. Tập bị rà, và **cả hai** con số của mỗi lượt lọc — chưa lọc và đã lọc.
2. Ba nhóm phân loại, mỗi nhóm liệt đủ: ngoại lệ có tên · định danh nghiệp vụ pha 0 · chỗ lọt ra.
3. Mỗi chỗ lọt ra: mục · dòng · commit sinh ra · mã `F-XXX` nhận nó — và **vì sao lượt này không
   sửa nó**.
4. Ô 10 ký thế nào, và nếu để trống thì mã nào đang chặn.
5. Câu trả lời thẳng cho *"pha 1 đóng chưa"*, kèm ai là người ký.
6. Mọi mã mở ra trong lượt, kèm link tới đúng **dòng** nó được viết (`CLAUDE.md` §7.3).
7. Output thật của mục *Verify* và của `./scripts/gate.sh`.
8. Khối `git commit` dán được (`CLAUDE.md` §6.1) — **không** có `work/scope.txt` trong khối.
