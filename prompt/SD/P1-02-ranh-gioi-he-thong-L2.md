# P1-02 — Ranh giới hệ thống: actor · phụ thuộc ngoài · đường suy giảm (L2) · pha 1, bước 2/12

> Bước **2/12** của pha 1 — `master_plan/SD_master_plan_banh_cuon_ba_thanh.md` §6. Mô tả dài ở
> `work/backlog_SD.md` → **P1-02**; trạng thái ở `work/backlog.md`.
> **Cần xong trước:** P1-01 — **đã xong 2026-09-04** (`docs/decisions.md` **ADR-035**).
> **Không chờ câu hỏi nghiệp vụ nào đang mở.** Chạy song song được với P1-03, P1-05, P1-06, P1-09.

## Context

Chủ quán đã chốt một câu mà phần lớn hệ thống POS không chốt: **mất điện thì quán không dừng bán**
(`master_plan/shop-facts.md` §6.11, chốt 2026-09-02). Hôm nay câu ấy chỉ sống ở tầng
nghiệp vụ; **không tài liệu kiến trúc nào kể tên những thứ nằm ngoài hệ thống mà hệ thống đang dựa
vào**, cũng không nói mất từng thứ thì quán làm gì.

Bốn dữ kiện đã chốt, nằm rải ở bốn chỗ, chưa chỗ nào gom lại thành *phụ thuộc ngoài*:

| Thứ nằm ngoài hệ thống | Đã chốt ở | Hôm nay ai giữ |
|---|---|---|
| **VietQR là mã TĨNH** ⇒ không có webhook báo tiền về | `docs/product/1-system-design/architecture.md` §7 · `master_plan/shop-facts.md` §1 | §7 viết *"Đừng thiết kế như thể có webhook"* — nhưng nó nằm trong một mục về **tiền**, nên người dựng tầng tích hợp không đọc tới |
| **Tin nhắn báo có** của ngân hàng — nguồn đối soát thứ ba | `master_plan/shop-facts.md` §6.10 (chủ quán chốt 2026-09-01) | một dòng trong luật đối soát |
| **Telegram** báo đơn web về quán | `master_plan/prompt-fullstack.md` §3.4 | một **bản xuất khẩu** — nó tự khai không sở hữu sự thật nào |
| **Sổ giấy** khi mất điện · mất mạng · hỏng máy | `master_plan/shop-facts.md` §6.11 (chủ quán chốt 2026-09-02) | luật nghiệp vụ; **hệ quả kiến trúc chưa ai viết** |

Đọc thêm trước khi viết dòng đầu tiên: `docs/product/1-system-design/architecture.md` §1 (ba mặt,
luật ghi) · §6.4 (đối soát cuối ngày, ngưỡng lệch **0đ**) · §7 (bốn đường tiền, và hai điều hệ
thống **không** làm), và `docs/product/0-ba/ban-hang/01-actors-pham-vi.md` §1.4 — actor đã có nhà
ở pha 0, bước này **trỏ**, không chép.

## Goal

Có **một chỗ duy nhất** trả lời: hệ thống này dựa vào những gì **nằm ngoài nó**, và mỗi thứ ấy chết
thì **quán làm gì · ai bù · bù lúc nào**. Người dựng pha 2–5 đọc một mục là biết mình không được
thiết kế như thể mọi thứ luôn sống.

## Scope

Được sửa:
- `docs/product/1-system-design/` — **một file mới**, tên `01-ranh-gioi-he-thong.md`
  (bản đồ file ở kế hoạch §5). File sinh ra **cùng** dòng nội dung đầu tiên của nó, không sớm hơn.
- `docs/product/00-index.md` — **một dòng** vào bảng *Pha 1*, trong **cùng** thay đổi
- `work/backlog.md` — **chỉ** dòng P1-02 (*In Progress* → *Done*) + entry nếu cần
- `work/backlog_SD.md` — **chỉ** một dòng *Xong ngày…* ở đầu entry P1-02
- `work/scope.txt` — **thêm** khối của mình, không ghi đè khối của phiên khác (**F-010** · **F-014**)

Không được sửa:
- `docs/product/1-system-design/architecture.md` — **không một dòng nào**. Bước này không sửa
  §7 và không viết lại §1. Thấy §7 nói ngược mục mới ⇒ đó là bug của lượt này, sửa **tại §7** và
  khai thêm scope, nói ra chứ đừng sửa lén.
- `master_plan/shop-facts.md` · `quality/invariants.md` · `docs/product/99-unknowns.md` — bước này
  không chạm một dữ kiện nghiệp vụ nào và không mở một invariant nào
- `master_plan/prompt-fullstack.md` — bản xuất khẩu **không sở hữu gì** (ADR-035); pha 1 cũng
  **không được sửa hộ** nó
- `docs/product/0-ba/**` — actor thuộc pha 0

## Constraints

- **Đây là mục *mất nó thì quán làm gì*, KHÔNG phải mục thiết kế dự phòng.** Không retry, không
  hàng đợi, không cache, không cơ chế đồng bộ — chúng là việc của pha 3 và của **P1-08**. Một dòng
  đường suy giảm nói **người** làm gì, không nói **máy** làm gì.
- **Ranh giới pha (ADR-035):** không một tên bảng · tên cột · khoá ngoại · endpoint · chữ ký hàm ·
  route · component nào được viết ra, kể cả làm ví dụ.
- **Không tự thêm một phụ thuộc chủ quán chưa nói tới** — máy in bill, tổng đài, cổng thanh toán,
  dịch vụ giao hàng ngoài. Thấy một thứ khả nghi ⇒ hỏi, hoặc ghi `U-XXX` vào
  `docs/product/99-unknowns.md` **dạng một gạch đầu dòng trong vùng đang mở** (`CLAUDE.md` §4 —
  viết thành văn xuôi là viết một câu hỏi không phiên nào thấy).
- **Không chép dữ kiện quán vào file mới**: giờ bán, số bàn, số tài khoản, bảng giá đều thuộc
  `master_plan/shop-facts.md` (**ADR-001**). Mục này chỉ nói *hệ thống dựa vào cái gì*.
- **Giữ `I-014`** (`quality/invariants.md` — doanh thu một ngày cộng từ đủ hai nguồn, không khoản
  nào đứng ở hai nguồn) và luật **ngưỡng lệch 0đ** (`docs/product/1-system-design/architecture.md`
  §6.4, **ADR-022**): một đường suy giảm không được mở đường cho nút *"đóng ca dù lệch"*.
- **Giữ `I-012`** (mọi thao tác chạm tiền để lại vết truy ngược được về một người và một thời
  điểm): lượt bán ghi trên giấy rồi nhập bù cũng phải để lại vết, và đường suy giảm phải nói ai
  chịu trách nhiệm vết ấy.
- **Sổ giấy không phải một tính năng.** Nó là **quy trình của người**. Thứ hệ thống nợ nó chỉ là
  chỗ nhập bù và một dòng *"còn N lượt bán trên giấy chưa nhập"* ở bảng đối soát — không phải một
  màn hình chép lại quyển sổ.
- **Không chốt hộ `U-032`** (`docs/product/99-unknowns.md` — lượt bán trên sổ giấy nhập bù tính
  doanh thu ngày nào). Nó chặn **P1-03**, không chặn bước này; chỗ nào chạm tới thì trỏ sang U-032
  và dừng.

## Acceptance

1. Có **một** file mới trong `docs/product/1-system-design/`, và `docs/product/00-index.md` bảng
   *Pha 1* có **đúng một** dòng mới trỏ tới nó — cùng một thay đổi, không phải hai.
2. File mới có ba mục đọc được riêng: **actor** · **phụ thuộc ngoài** · **đường suy giảm**.
3. Mục *actor* **trỏ** tới `docs/product/0-ba/ban-hang/01-actors-pham-vi.md`, và **không** chép lại
   danh sách actor.
4. **Mỗi** phụ thuộc ngoài có **đúng một** dòng đường suy giảm, và dòng ấy trả lời đủ ba vế:
   *quán làm gì · ai bù · bù lúc nào*. Số phụ thuộc và số dòng suy giảm **bằng nhau** — đây là ô
   thứ tư của cổng chất lượng pha 1 (kế hoạch §9).
5. **Mỗi** phụ thuộc trỏ được tới dòng đã chốt của nó ở `master_plan/shop-facts.md` hoặc ở
   `docs/product/1-system-design/architecture.md` — không phụ thuộc nào chỉ có ở bản xuất khẩu.
6. Mục nói thẳng rằng hệ thống **không tự biết tiền đã về tài khoản** (VietQR tĩnh), bằng ngôn ngữ
   tầng — **không** nhắc tên một cơ chế tích hợp nào.
7. Không dòng nào thiết kế một cơ chế dự phòng (retry · hàng đợi · cache · đồng bộ ngược).
8. Không dòng nào chứa tên bảng · tên cột · endpoint · route · component.
9. Không dữ kiện quán nào (giờ, giá, số bàn, số tài khoản) bị chép vào file mới.
10. `./scripts/gate.sh` xanh.

## Verify

```bash
# (1) file mới có mặt, và mục lục kể tên nó — thay <FILE> bằng tên thật đã đặt
ls docs/product/1-system-design/
grep -n '1-system-design/' docs/product/00-index.md

# (2) ba mục bắt buộc
grep -n -i 'actor\|phụ thuộc ngoài\|suy giảm' docs/product/1-system-design/<FILE>

# (3) đếm hai chiều — số phụ thuộc phải bằng số dòng suy giảm.
#     F-018: con số này là PHÉP ĐO của người viết, không phải một invariant.
#     Đọc TAY hai danh sách rồi đối chiếu; đừng biến số đếm thành điều kiện.
grep -n -c '' docs/product/1-system-design/<FILE>

# (4) actor là POINTER, không phải bản chép
grep -n '01-actors-pham-vi.md' docs/product/1-system-design/<FILE>

# (5) KHÔNG cơ chế dự phòng nào bị thiết kế ở bước này.
#     In cả lệnh CHƯA lọc cạnh lệnh đã lọc — một bộ lọc rỗng vì viết sai trông
#     y hệt một bộ lọc rỗng vì không có lỗi (work/findings.md F-017).
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -c '^+'                                    # chưa lọc: > 0, có dòng để lọc
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -E '^\+' \
  | grep -nEi 'retry|hàng đợi|queue|cache|đồng bộ ngược'          # rỗng

# (6) ranh giới pha ADR-035 — không tên bảng/cột/endpoint/route lọt vào
git diff --unified=0 -- docs/product/1-system-design/ docs/product/00-index.md \
  | grep -E '^\+' \
  | grep -nEi 'CREATE TABLE|FOREIGN KEY|UNIQUE\(|\bGET /|\bPOST /|\bPUT /|\bDELETE /|/api/' # rỗng

# (7) pointer nói ngược mục mới là bug của LƯỢT NÀY (CLAUDE.md §7.2), không phải
#     task sau. Đọc từng kết quả, đừng chỉ đếm.
grep -rn 'webhook' --include='*.md' docs/ master_plan/ quality/
grep -rn 'Telegram' --include='*.md' docs/ master_plan/ quality/

# (8) cổng của repo
./scripts/gate.sh
```

## Unknowns

**Không có câu hỏi nghiệp vụ nào chặn bước này.** Bốn dữ kiện phụ thuộc ngoài đều đã được chủ quán
chốt, ngày và chỗ ghi có đủ ở mục *Context*.

Hai chỗ **được phép chạm tới nhưng không được quyết**:

- **`U-032`** — lượt bán trên sổ giấy nhập bù tính doanh thu **ngày nào**. Bước này viết *"quán ghi
  giấy, nhập bù khi máy sống lại"*; **ngày nào** là câu của **P1-03**, và cả hai đường ra đều phá
  một thứ đang có. Chạm tới thì trỏ sang U-032, không viết một câu ngày nào cả.
- **Một phụ thuộc thứ năm** mà không tài liệu nào chốt (ví dụ: máy in, tổng đài, dịch vụ giao ngoài).
  Thấy ⇒ ghi `U-XXX` mới, **một gạch đầu dòng** trong vùng đang mở của
  `docs/product/99-unknowns.md`. Không tự thêm nó vào bảng như một dữ kiện.

## Report (AI trả lời sau khi làm)

1. Bao nhiêu phụ thuộc ngoài, và mỗi cái trỏ về dòng chốt nào (file + số mục).
2. Đường suy giảm của từng cái: quán làm gì · ai bù · bù lúc nào — một dòng mỗi cái.
3. Chỗ nào **cố ý để trống** và mã của thứ đang chặn nó.
4. Kết quả `grep` *webhook* và *Telegram*: chỗ nào phải sửa trong cùng lượt, chỗ nào **cố ý ở lại**
   và vì sao (một tài liệu **kể lại** một chỗ sai không phải là một chỗ sai — **F-018**).
5. Output thật của mục *Verify* và của `./scripts/gate.sh`.
6. Khối `git commit` dán được (`CLAUDE.md` §6.1) — **không** có `work/scope.txt` trong khối.
