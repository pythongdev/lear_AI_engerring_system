# 13c — DOC-3c: chuyển pointer ở vùng *Ready* của `work/backlog.md` · L1

> Task con 3/3 của **DOC-3** (`prompt/maintenance/13-pointer-migration-L3.md`, lượt chia việc
> chạy 2026-09-02). Thứ tự: **DOC-3b → DOC-3a → DOC-3c**. Chạy **cuối** vì nó nhỏ nhất và vì
> DOC-3b có thể đổi chính hai dòng BA-11/BA-12 mà task này chạm.

## Context

- `work/backlog.md` có **220 dòng** trỏ `docs/product.md` — nhiều nhất repo. **Gần hết là sổ ghi
  chép lịch sử** và **KHÔNG được đụng**: một entry *Done* kể lại việc ngày 2026-08-31 đã sửa
  `docs/product.md` §4 là câu **đúng vào ngày ấy**; viết lại nó là làm hỏng lịch sử. CLAUDE.md §5
  nói thẳng vì sao Gate 1b không chấm `work/`: *một đường đã chết ở đó là bằng chứng, không phải bug*.
- Chỉ vùng ***Ready*** và ***In Progress*** là **lời hướng dẫn cho việc SẮP làm** — đó là câu mà
  phiên sau sẽ **làm theo**, nên nó phải trỏ đúng nhà mới.
- **Đo lại 2026-09-02 (sau lượt L3 chia việc, tức SAU khi DOC-3 ghi bảng dưới đây vào chính
  `work/backlog.md`):** *In Progress* **rỗng**. Vùng *Ready* có **9 dòng / 10 lần xuất hiện**
  (prompt DOC-3 gốc ghi 5 — con số đã trôi vì chuỗi BA chạy tiếp và vì lượt chia việc thêm một khối):

  | Dòng | Thuộc về | Xử lý |
  |---:|---|---|
  | 47 | khối văn về hợp đồng *Unknowns* (ADR-007) | → `docs/product/99-unknowns.md` |
  | 100, 102, 103 | khối văn giải thích BA-09 / BA-12 | → theo `§N` |
  | 108 | khối văn *"BA-07 chạy song song được"* | → theo `§N` |
  | **150** | **mục BA-11** — `docs/product.md` §8 | → `docs/product/0-ba/ban-hang/08-scenario.md` |
  | **151** | **mục BA-12** — §3.4 **và** §5.4 (**2 lần trên một dòng**) | → `docs/product/0-ba/ban-hang/03-lat-cat.md` + `docs/product/0-ba/ban-hang/05-vong-doi.md` |
  | **161** | khối *"DOC-3 chạy theo thứ tự 3b → 3a → 3c"* | **Ở LẠI** — xem *Constraints* |
  | 167 | khối văn cảnh báo DOC-1 và BA-11/BA-12 cùng chạm file | **đọc rồi quyết** — xem *Constraints* |

  ⇒ **7 dòng chắc chắn chuyển · 1 dòng ở lại (161) · 1 dòng phải tự quyết (167)**.
  Số dòng trôi mỗi ngày — **định vị bằng tiêu đề, đừng dùng lại các số này**.

## Goal

Vùng *Ready* và *In Progress* của `work/backlog.md` không còn trỏ về bản lưu; phần còn lại của
file — *Done*, *Chi tiết*, mọi khối lịch sử — **không đổi một ký tự**.

## Scope

```text
work/backlog.md
```

Ngoài phạm vi: mọi vùng khác của chính `work/backlog.md` · `work/findings.md` và phần còn lại của
`work/**` · `prompt/maintenance/**` · nhóm A (DOC-3a) · `prompt/BA/**` (DOC-3b) · `CLAUDE.md` (DOC-4).

## Constraints

- **Luật ánh xạ:** giống hệt bảng ở `prompt/maintenance/13a-pointer-nhom-A-L2.md` §*Constraints*.
- **Ranh giới vùng là RANH GIỚI CỦA TASK NÀY.** *Ready* bắt đầu ở `## Ready`, *In Progress* ở
  `## In Progress`, và **dừng ở `## Done`**. Số dòng trôi mỗi ngày — **định vị bằng tiêu đề, đừng
  dùng lại số dòng trong bảng trên**, chúng đo ngày 2026-09-02.
- **Dòng 161 Ở LẠI, không đổi.** Khối ấy do chính lượt chia việc DOC-3 viết, và câu của nó là
  *"khối `Scope` trong hai prompt của BA-11/BA-12 **đang ghi trần `docs/product.md`**"* — nó **mô tả
  cái sai đang tồn tại**, nên phải gọi đúng tên bản lưu. Đổi nó đi là làm câu ấy vô nghĩa. Sau khi
  **DOC-3b xong**, khối này nói về một chuyện đã sửa: lúc ấy cân nhắc **rút gọn cả khối**, nhưng đó
  là việc của DOC-4 hoặc một task dọn riêng, **không** phải việc của DOC-3c.
- **Dòng 167 có thể là ngoại lệ — đọc trước khi đổi.** Câu ấy cảnh báo *"DOC-1 và BA-11/BA-12 cùng
  chạm `docs/product.md`"*. DOC-1 **đã xong** (commit `bc5033c`), nên câu này đang kể một va chạm
  **đã qua**. Nếu đọc ra là lịch sử ⇒ để nguyên và **nói rõ trong report vì sao**. Nếu đọc ra là
  cảnh báo còn hiệu lực ⇒ chuyển, vì file hai bên tranh nhau bây giờ là `docs/product/`.
- **Dòng 151 có HAI lần xuất hiện** (`§3.4` và `§5.4`) ⇒ hai file đích khác nhau
  (`docs/product/0-ba/ban-hang/03-lat-cat.md` và `docs/product/0-ba/ban-hang/05-vong-doi.md`). Sửa một, sót một là ca dễ nhất để hỏng.
- **Đừng "tiện tay" dọn vùng *Done*.** Đó là toàn bộ lý do task này tồn tại tách khỏi phần còn lại.
- **Không `sed -i` trên cả file** — nó sẽ nuốt 212 dòng lịch sử.
- **Chạy sau DOC-3b.** DOC-3b có thể sửa mô tả BA-11/BA-12; hai task cùng chạm hai dòng 150–151.

## Acceptance

1. Vùng *Ready* + *In Progress* còn **đúng 1 dòng** trỏ `docs/product.md` (khối DOC-3,
   dòng 161) — hoặc 2 nếu dòng 167 được kết luận là lịch sử; kết luận ấy phải viết trong report.
2. Số dòng `docs/product.md` **ngoài** hai vùng đó **không đổi**: đo 2026-09-02 là **216**.
3. `git diff --stat work/backlog.md` cho thấy chỉ vùng *Ready*/*In Progress* bị chạm.
4. Dòng BA-12 đã đổi **cả hai** chỗ (§3.4 **và** §5.4).
5. `./scripts/gate.sh` xanh. Lưu ý Gate 1b **không** chấm `work/` — cổng máy không đỡ được task
   này chút nào; bằng chứng là `git diff` và hai lệnh đếm ở *Verify*.

## Verify

```bash
# ranh giới vùng — tính lại, đừng dùng số cũ
R=$(grep -n '^## Ready' work/backlog.md | cut -d: -f1)
D=$(grep -n '^## Done'  work/backlog.md | cut -d: -f1)

# 1 · trong vùng Ready+In Progress — còn đúng 1 dòng (khối DOC-3), hoặc 2 nếu giữ dòng 167
awk -v r="$R" -v d="$D" 'NR>r && NR<d && /docs\/product\.md/{print NR": "$0}' work/backlog.md

# 2 · ngoài vùng — phải KHÔNG đổi
awk -v r="$R" -v d="$D" '(NR<=r || NR>=d) && /docs\/product\.md/' work/backlog.md | wc -l   # = 216, không đổi

# 3 · BA-12 đã đổi cả hai chỗ
grep -n 'BA-12' work/backlog.md | grep -c 'docs/product/'

# 4 · chỉ một vùng bị chạm
git diff work/backlog.md | grep -c '^[-+][^-+]'

./scripts/gate.sh; echo "exit=$?"
```

## Phương án lùi

Một commit riêng (`DOC-3c: ...`) ⇒ `git revert <sha DOC-3c>`.

## Unknowns

- Không có câu hỏi nghiệp vụ.
- **Dòng 167 là câu hỏi biên tập, không phải câu hỏi nghiệp vụ** — người làm task đọc rồi quyết,
  và ghi lý do vào report. Không cần hỏi chủ repo.
- Gate 1b không chấm `work/` ⇒ task này **không có cổng máy nào**. Đọc diff là bắt buộc.

## Report

- Đã thay đổi gì · đã verify thế nào, kết quả ra sao · còn vấn đề gì chưa giải quyết
- **Nói rõ dòng 167 đã giữ hay đã chuyển, và vì sao** · xác nhận dòng 161 còn nguyên
