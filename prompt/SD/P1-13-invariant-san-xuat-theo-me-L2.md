# P1-13 — Bảng ba cột, nhóm SẢN XUẤT THEO MẺ: `I-019` `I-020` (L2) · bước 13/13

> Bước **13/13** của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6. Mô tả dài ở
> `work/backlog_SD.md` → **P1-13**; trạng thái ở `work/backlog.md`.
> **Cần xong trước:** P1-01 — **đã xong 2026-09-04** (`docs/decisions.md` **ADR-035**).
> **Mở ra vì:** `work/findings.md` **F-026** — `I-019`/`I-020` sinh ở BA-12, 2026-09-03, **sau**
> khi kế hoạch §6 đã chia ba nhóm ban đầu, nên không nhóm nào nhận chúng. Chủ repo chốt đường thứ
> hai trong ba đường F-026 liệt: mở bước này, nhóm riêng (`docs/decisions.md` **ADR-042**).
> Chạy song song được với P1-04, P1-05, P1-06: bốn nhóm **không dùng chung mệnh đề nào**.

## Context

`quality/invariants.md` đã có `I-019` và `I-020` với khối *Verification* viết bằng **kịch bản
nghiệp vụ**. Cái còn thiếu là cột giữa — **tầng nào giữ nó** — và cột thứ ba, **phép đối chiếu**,
giống hệt việc P1-04/05/06 đã làm cho mười tám mệnh đề kia.

**Từ vựng cột giữa là bắt buộc và chỉ có năm giá trị** — định nghĩa đầy đủ ở kế hoạch §7, đọc ở đó:
**1** cơ sở dữ liệu giữ · **2** một giao dịch giữ · **3** miền nghiệp vụ giữ · **4** người + thủ tục
giữ · **5** phép đối chiếu bắt sau khi hỏng.

Nhóm này đứng trên một trục khác hẳn ba nhóm kia: **sản xuất theo mẻ** — *mẻ là đơn vị bấm, bàn là
đơn vị đếm* (chủ quán chốt 2026-09-01, đóng `U-017`). Hai mệnh đề không độc lập với nhau: cơ chế
chia phần theo bàn của `I-020` (một mẻ phủ nhiều bàn) **dùng lại đúng** khoá gom mà `I-019` giữ
(thành phần + loại nhân + lượng nhân) — chia sai theo khoá gom tự động kéo `I-020` sai theo.

Đọc trước khi viết dòng đầu tiên: kế hoạch §7 · hai mục `I-019`/`I-020` ở `quality/invariants.md` ·
`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4 (lát cắt sản xuất theo mẻ, BA-12, khoá gom và ví
dụ cộng xuôi/tách ngược) · `docs/product/0-ba/ban-hang/05-vong-doi.md` §5.4 (ba trạng thái loại
trừ nhau của một việc trạm) · `work/findings.md` **F-026** nguyên văn (ba đường đã liệt, đường đã
chọn) · `docs/decisions.md` **ADR-042**.

## Goal

Hai mệnh đề trục sản xuất theo mẻ — `I-019` `I-020` — mỗi mệnh đề có **tầng giữ** và **phép đối
chiếu**, không ô nào trống, và không còn mồ côi khỏi mọi nhóm của pha 1.

## Scope

Được sửa:
- `docs/product/1-system-design/03-bao-ve-invariant.md` — **thêm** banner (bốn chủ, §4) và **§4
  mới**. File dùng chung bốn bước — không sửa §0, §1, §2, §3.
- `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` — §6 (tiêu đề, hàng P1-13, dòng song song,
  cột *Cần xong trước* của P1-07/P1-10) · §7 (tiêu đề) · §9 (câu đầu, bỏ số đếm cứng).
- `work/backlog_SD.md` — intro, luật 1/3, Mục lục, callout F-026, dòng cảnh báo entry P1-06, entry
  P1-13 mới. **Không** sửa nội dung entry của bước khác.
- `prompt/SD/README.md` — bảng bước, callout F-026, tiêu đề từ vựng năm tầng.
- `prompt/SD/` — **thêm** file prompt này.
- `docs/product/00-index.md` — **một dòng** (mười hai → mười ba bước).
- `docs/decisions.md` — **ADR-042** (mới) + một hàng bảng tổng hợp.
- `work/findings.md` — **chỉ** một khối *Đóng* thêm vào cuối mục F-026.
- `work/backlog.md` — chỉ dòng và entry P1-13.
- `work/scope.txt` — **thêm** khối của mình (F-010 · F-014).

Không được sửa:
- **Mục của ba nhóm kia (P1-04, P1-05, P1-06) trong cùng file bảng ba cột.**
- `quality/invariants.md` — **không đổi lời một mệnh đề nào**. Thấy một mệnh đề sai ⇒ `F-XXX`,
  đừng sửa nhân tiện.
- **`P1-01`…`P1-12` — không renumber ID, không đổi neo `#p1-0x`.** `P1-13` chỉ nối vào cuối.
- *Problem*/*Impact* đã viết của F-026 — chỉ **thêm** một khối *Đóng*, không viết lại (ADR-008).
- `docs/product/0-ba/ban-hang/03-lat-cat.md` · `05-vong-doi.md` — lát cắt và bảng chuyển trạng
  thái đã chốt ở pha 0, không vẽ lại.
- `master_plan/shop-facts.md` · `master_plan/prompt-fullstack.md`.

## Constraints

- **Ghi tầng CAO NHẤT thật sự đang giữ nó, không ghi tầng mình muốn nó ở** (kế hoạch §7, luật 1).
- **Mỗi mệnh đề vẫn phải có phép đối chiếu, kể cả khi cột giữa đã là tầng 1** (kế hoạch §7, luật 2).
- **Phép đối chiếu viết dạng *"tập này phải rỗng"*, bằng ngôn ngữ nghiệp vụ** (kế hoạch §7, luật 3).
- **Ô nào chỉ tới được tầng 4 hoặc 5 phải nói thẳng *"máy không ngăn được"*.**
- **`I-019` phải nói được cả hai chiều** — cộng xuôi (các phần → tổng) và tách ngược (tổng → đúng
  các phần đã ghi) — và phải nói rõ **khoá gom** (thành phần + loại nhân + lượng nhân) là ranh
  giới của phép cộng, không phải tên món.
- **`I-020` phải phủ cả trạng thái giữa** (*đã làm xong, còn ở bếp*), không chỉ *đã bưng ra bàn*,
  và phải nói được cơ chế cho **một mẻ phủ nhiều bàn, một lần bấm** cộng **đường lùi**.
- **Không renumber `P1-01`…`P1-12`.** Đổi mẫu số *"N/12"* → *"N/13"* ở các dòng đã có, giữ nguyên
  tử số và mọi neo.
- **Cổng §9 sau khi sửa không còn đếm một con số cứng** — đối chiếu danh sách mã giữa
  `quality/invariants.md` và bảng ba cột (đúng nguyên nhân F-026/F-018 đã chỉ ra).
- **Ranh giới pha (ADR-035):** không tên bảng, tên cột, tên ràng buộc, endpoint hay route.
- **Không mở lại nghiệp vụ** (`CLAUDE.md` §3.5). Không mã mới nào khác `P1-13`/`ADR-042` được mở
  trong lượt này (F cuối cùng có chủ là F-031 — không mở F mới, chỉ đóng F-026).

## Acceptance

1. `03-bao-ve-invariant.md` có **§4**, đúng **hai** hàng: `I-019` `I-020`, không ô nào trống.
2. Cột giữa chỉ nhận giá trị trong năm tầng của kế hoạch §7; hàng nào chạm tầng 4/5 có câu *"máy
   không ngăn được"* kèm cái máy **có** giữ thay vào.
3. Hàng `I-019` nói được cả hai chiều và nêu rõ khoá gom là ranh giới phép cộng.
4. Hàng `I-020` nói được cả bốn vế: trần trên (kể cả trạng thái giữa), mẻ nhiều bàn, đường lùi, ba
   trạng thái loại trừ nhau.
5. Kế hoạch §6 có hàng P1-13, tiêu đề "mười ba bước", dòng song song có P1-13; §7 tiêu đề "bốn
   bước"; §9 không còn số đếm cứng.
6. `work/backlog_SD.md`, `prompt/SD/README.md`, `docs/product/00-index.md` không còn chỗ nào viết
   "mười hai bước"/"P1-01…P1-12" như tổng số bước hiện tại của pha 1 ở các đoạn **sống** (không
   tính entry *Done* lịch sử).
7. `docs/decisions.md` có ADR-042 ghi đủ ba đường F-026 liệt và đường đã chọn.
8. `work/findings.md` F-026 có một khối *Đóng 2026-09-07*, không sửa *Problem*/*Impact* cũ.
9. `quality/invariants.md` không đổi một chữ nào trong lượt này.
10. `P1-01`…`P1-12` giữ nguyên ID và mọi neo `#p1-0x`.
11. Không dòng nào chứa tên bảng · tên cột · tên ràng buộc · endpoint · route · component.
12. `./scripts/gate.sh` xanh.

## Verify

```bash
# (1) hai hàng có mặt
grep -n 'I-019\|I-020' docs/product/1-system-design/03-bao-ve-invariant.md

# (2) cột giữa chỉ nhận năm tầng — đọc TAY, đừng đếm số (F-018)
grep -n -i 'tầng 1\|tầng 2\|tầng 3\|tầng 4\|tầng 5' docs/product/1-system-design/03-bao-ve-invariant.md

# (3) hàng tầng 4/5 phải NÓI THẲNG
grep -n 'máy không ngăn được' docs/product/1-system-design/03-bao-ve-invariant.md

# (4) không còn "mười hai bước" / "P1-01…P1-12" như tổng số hiện tại, ở các file sống
grep -rn 'mười hai bước\|P1-01.*P1-12' master_plan/SD_master_plan_banh_cuon_ba_thanh.md \
  work/backlog_SD.md prompt/SD/README.md docs/product/00-index.md

# (5) mệnh đề KHÔNG bị sửa lời ở lượt này
git diff --stat -- quality/invariants.md            # rỗng

# (6) P1-01…P1-12 không bị renumber — mọi neo cũ vẫn còn
grep -c '<a id="p1-0[1-9]"></a>\|<a id="p1-1[0-2]"></a>' work/backlog_SD.md   # bằng 12

# (7) ranh giới pha ADR-035 — in cả lệnh CHƯA lọc cạnh lệnh đã lọc (F-017)
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -c '^+'
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -E '^\+' \
  | grep -nEi 'CREATE TABLE|FOREIGN KEY|UNIQUE\(|CHECK \(|\bGET /|\bPOST /|/api/'  # rỗng

# (8) cổng của repo
./scripts/gate.sh
```

## Report (AI trả lời sau khi làm)

1. Hai hàng, mỗi hàng: tầng nào giữ nó và vì sao là tầng ấy chứ không phải tầng cao hơn.
2. Cách `I-020` dùng lại khoá gom của `I-019`, và vì sao hai mệnh đề đứng chung một nhóm thay vì
   tách mỗi mệnh đề vào nhóm nó "giống" nhất.
3. Danh sách đầy đủ các file/dòng đã sửa để hết câu "mười hai bước"/"P1-01…P1-12" như tổng số hiện
   tại, và xác nhận không đụng entry *Done* lịch sử nào.
4. Nội dung ADR-042 và khối đóng F-026.
5. Output thật của mục *Verify* và của `./scripts/gate.sh`.
6. Khối `git commit` dán được (`CLAUDE.md` §6.1) — **không** có `work/scope.txt` trong khối.
