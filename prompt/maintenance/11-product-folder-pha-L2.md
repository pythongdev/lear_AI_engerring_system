# 11 — Bước 1/5: dựng `docs/product/` cắt theo PHA, `docs/product.md` thành bản lưu (L2) · DOC-1

> Bộ năm bước của ADR-014: **11 (đây)** → 12 → 13 → 14 → 15(chưa chốt).
> Đọc `docs/decisions.md` **ADR-014**, và đọc **khối *SỬA ĐỔI 2026-09-02* ở cuối mục ấy trước** —
> phần thân của ADR còn nói trục *mảng*, khối sửa đổi mới là bản có hiệu lực (trục **pha**).

## Context

- `docs/product.md` đo **2026-09-02: 1998 dòng**, và còn tăng mỗi ngày chuỗi BA còn chạy. Nó là
  owner của *hành vi nghiệp vụ* (CLAUDE.md §2) và là file mà **F-014 đã cho hai phiên đụng nhau
  sáu lần** — lần nào cũng đúng file này.
- Ranh giới mục **đo lúc viết prompt này** (`grep -n '^## ' docs/product.md`). **Không tin những
  con số này** — grep lại ngay trước khi cắt, chúng trôi mỗi lần một task BA ghi thêm:

  | Mục | Dòng (2026-09-02) |
  |---|---|
  | `## 1. Actor và phạm vi hệ thống` | 13 |
  | `### 1.6 Mảng QUẢN TRỊ (admin)` | 164 |
  | `## 2. Kênh bán` | 201 |
  | `## 3. Ba lát cắt nghiệp vụ` | 290 |
  | `## 4. Giá và thanh toán` | 889 |
  | `## 5. Vòng đời nghiệp vụ` | 1243 |
  | `## 6. Ngoại lệ` | 1529 |
  | `## 7. Phạm vi MVP` | 1633 |
  | `## 8. Scenario nghiệm thu BA` | 1830 |
  | `## Unknowns` | 1834 |

- **ADR-013** bắt nội dung mảng admin nằm ở mục riêng có nhãn — hôm nay là §1.6. Sau lượt này nó
  là **file riêng**, tên thư mục mang chữ `admin`.
- **`scripts/brief.sh` đang đọc thẳng `docs/product.md`** ở 5 chỗ, trong đó có parser mục
  *Unknowns* (ADR-007). Lượt này **không sửa script** — đó là bước 2 (`12-brief-unknowns-file-L2.md`).
  Hệ quả phải xử lý, xem *Constraints*.

## Goal

`docs/product/` giữ **toàn bộ** nội dung của `docs/product.md`, cắt theo **pha** ở tầng ngoài và
**mảng** ở tầng trong; `docs/product.md` ở lại làm **bản lưu có banner**, không sở hữu sự thật nào.

## Scope

Được sửa:
- `docs/product/**` (tạo mới)
- `docs/product.md` — **chỉ** thêm banner đầu file và đổi tiêu đề mục *Unknowns*; không đụng câu
  chữ nào khác
- `docs/decisions.md` — **chỉ** ô *Trạng thái* của ADR-014 (ghi lượt 1 đã xong)
- `work/backlog.md` — **chỉ** mục DOC-1

Không được sửa:
- `scripts/**` — bước 2
- `CLAUDE.md` — bước 4
- `quality/invariants.md`, `prompt/**`, `master_plan/**`, `docs/architecture.md` — bước 3
- **Câu chữ của bất kỳ mục nào trong `docs/product.md`.** Lượt này là *chuyển*, không phải *biên tập*.

Dòng chép vào `work/scope.txt` (thêm khối của mình, đừng ghi đè khối người khác — F-014):
```text
docs/product/
docs/product.md
docs/decisions.md
work/backlog.md
```

## Constraints

- **Cây thư mục đúng như khối *SỬA ĐỔI* của ADR-014**, không tự thêm bớt:

  ```text
  docs/product/
    00-index.md                    mục lục + luật ghi; không sở hữu sự thật nào
    0-ba/
      ban-hang/
        01-actors-pham-vi.md       §1 trừ §1.6
        02-kenh-ban.md             §2
        03-lat-cat.md              §3
        04-gia-thanh-toan.md       §4
        05-vong-doi.md             §5
        06-ngoai-le.md             §6
        07-pham-vi-mvp.md          §7
        08-scenario.md             §8
      admin/
        01-ranh-gioi.md            §1.6
    99-unknowns.md                 mục Unknowns
  ```

- **KHÔNG dựng folder cho pha 1–5.** `1-system-design/`, `2-db/`, `3-be/`, `4-fe/`, `5-deploy/`
  chỉ ra đời khi có dòng nội dung đầu tiên. `00-index.md` **kể tên đủ sáu pha** và nói pha nào chưa
  mở. Một file *"chưa có gì"* là tài liệu nghi lễ (CLAUDE.md §3.8), và folder rỗng không gỡ được
  dòng nào.
- **Giữ nguyên số mục §1–§8 trong tên file.** ~180 câu `docs/product.md §N` rải khắp repo; đánh số
  lại là làm sai nghĩa 180 câu mà `grep` không bắt được (ADR-014, *Rejected alternatives*).
- **Chuyển nguyên văn.** Mỗi file mới có hình dạng: **banner ≤ 6 dòng**, rồi đúng một dòng đánh dấu

  ```text
  <!-- ==== nguyên văn docs/product.md §N, tách 2026-09-02 ==== -->
  ```

  rồi phần nội dung **không sửa một ký tự nào**. Đây là điều kiện để Acceptance chấm được bằng
  `diff` chứ không bằng mắt.
- **`00-index.md` không được giữ sự thật nào.** Không giá, không luật, không tên trạng thái — chỉ
  mục lục, luật ghi, và câu "sự thật đọc ở file của nó". Nó chép một dòng nào là nó thành bản copy
  thứ hai, đúng F-001.
- **Banner của bản lưu `docs/product.md`** phải nói đủ ba câu: đây là **ảnh chụp ngày tách**, nó
  **không sở hữu sự thật nào**, **không sửa ở đây**. Và nó **được nhắc tới** như một bản lưu, không
  **được trỏ tới** như một owner (chủ repo 2026-09-02: *"tuyệt đối không trỏ về"*).
- **Mục *Unknowns* trong bản lưu phải đổi tiêu đề** (ví dụ `## Unknowns (BẢN LƯU — brief không đọc
  mục này)`). Nếu để nguyên `## Unknowns`, `brief.sh` **vẫn đọc bản lưu** cho tới hết bước 2 —
  gate xanh, brief xanh, mà cả repo đọc một câu hỏi đã chuyển nhà. Đó là kiểu hỏng im lặng tệ nhất.
- **Điều kiện dừng, kiểm TRƯỚC khi bắt đầu:** giữa bước 1 và bước 2, brief in *Open unknowns* rỗng.
  Điều đó chỉ **đúng** khi mục ấy đang rỗng thật (2026-09-02 nó rỗng). Chạy `./scripts/brief.sh`
  trước; **nếu Open unknowns KHÔNG rỗng thì dừng lượt này lại** và làm bước 2 trước, hoặc làm cả
  hai trong cùng một phiên.
- **Đừng làm khi có phiên khác đang giữ `docs/product.md`.** `./scripts/brief.sh` in mục
  *DECLARED SCOPE* và *UNCOMMITTED*; thấy file này trong đó là dừng (F-014 đã hỏng sáu lần).

## Acceptance

- Cây thư mục khớp đúng khối trong *Constraints*; **không có** folder nào cho pha 1–5.
- **Nội dung khớp từng dòng.** Với mỗi file mới: bỏ phần trên dòng đánh dấu, phần còn lại `diff`
  với đúng đoạn tương ứng của `git show HEAD:docs/product.md` ⇒ **rỗng**. Dán kết quả của cả 10 lần
  `diff` vào Report (`quality/review-gate.md` Gate 2).
- Không dòng nào của `docs/product.md` bị bỏ rơi: tổng số dòng nội dung của các file mới cộng lại
  = số dòng của bản cũ (trừ banner và dòng đánh dấu). Dán phép cộng ra Report.
- `docs/product/00-index.md` kể tên đủ **sáu** pha, nói rõ pha 1–5 chưa mở, và **không chứa** một
  con số hay một luật nghiệp vụ nào.
- `docs/product.md` có banner ba câu như *Constraints*, và tiêu đề `## Unknowns` đã đổi.
- `docs/product/99-unknowns.md` giữ nguyên nội dung mục Unknowns **kèm cả hợp đồng viết** (mục
  *Cách viết một câu ở đây*) — ADR-007 dựa vào nó.
- `./scripts/brief.sh` chạy được, exit 0, và mục *OPEN UNKNOWNS* in `(none)` — **và điều đó đúng**
  vì mục ấy đang rỗng. Dán output.
- `./scripts/gate.sh` xanh.
- `docs/decisions.md` ADR-014 ô *Trạng thái* ghi: lượt 1 xong ngày nào, còn lại lượt nào.

## Verify

```bash
./scripts/brief.sh                      # điều kiện dừng: Open unknowns phải rỗng
git show HEAD:docs/product.md > /tmp/product-old.md
wc -l /tmp/product-old.md

# với từng file mới — ví dụ §4
sed -n '889,1242p' /tmp/product-old.md > /tmp/s4-old.md
sed -e '1,/^<!-- ==== nguyên văn/d' docs/product/0-ba/ban-hang/04-gia-thanh-toan.md > /tmp/s4-new.md
diff /tmp/s4-old.md /tmp/s4-new.md && echo "§4 KHỚP"

# tổng dòng
for f in $(find docs/product -name '*.md' ! -name '00-index.md'); do
  sed -e '1,/^<!-- ==== nguyên văn/d' "$f" | wc -l
done | paste -sd+ - | bc

./scripts/gate.sh; echo "exit=$?"
```

## Unknowns

- Không có câu hỏi nghiệp vụ. Lượt này không đổi một luật nào của quán, chỉ đổi chỗ đứng của chữ.
- **Không sửa nội dung dù thấy sai.** Thấy một dòng sai trong lúc chuyển thì ghi vào
  `work/findings.md` hoặc mở task, đừng sửa trong lượt này — một dòng bị sửa là một dòng `diff`
  không còn chứng minh được gì.
- Việc **commit** do người dùng quyết (CLAUDE.md §6) — làm xong thì giao khối commit, đừng tự commit.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
