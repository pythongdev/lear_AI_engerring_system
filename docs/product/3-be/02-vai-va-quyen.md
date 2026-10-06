<a id="top"></a>
# Vai và quyền — mỗi cửa ghi một lớp quyền, đọc tại mốc bấm

Pha 3 · bước `P3-05` · viết 2026-10-06 (Claude Code). Vì sao thiết kế thế này và cái bị loại:
`docs/decisions.md` **ADR-085**.

**File này sở hữu:** luật đọc quyền của backend, danh sách lớp quyền, và **ma trận cửa × lớp** — mỗi
cửa ghi đúng một dòng. Cột *Lớp* ở đây và khai báo `authz.Door` trong code là hai bản của một sự thật;
**file này thắng** (cùng lý lẽ hợp đồng thắng code, **ADR-084**), Gate 1g so hai bản mọi lượt.

**File này KHÔNG sở hữu:**
- **luật nghiệp vụ** ai được làm gì — `master_plan/shop-facts.md` (§3 vai, §6 quy tắc) và
  `docs/product/1-system-design/architecture.md` §4. Mỗi dòng ma trận trỏ nguồn của nó; dòng không có
  nguồn là dòng bịa;
- **ai đứng quầy lúc nào** — dữ liệu ở bảng `counter_duty`
  ([`../2-db/06-luoc-do-nguoi-va-vet.md`](../2-db/06-luoc-do-nguoi-va-vet.md) §1); cửa mở · khép khoảng
  trực là của `P3-11`;
- **cách một người chứng minh mình là ai** — câu của chủ quán, **U-075**, chưa có lời
  ([`../99-unknowns.md`](../99-unknowns.md));
- **đường gọi, mã lỗi** — [`openapi.yaml`](openapi.yaml), khuôn ở [`01-hop-dong-api.md`](01-hop-dong-api.md).

---

## 1. Luật đọc — năm câu

1. **Quyền là của cửa, không của người.** Mỗi cửa ghi khai **đúng một** lớp. Người không mang vai nào
   mở được cửa: chức vụ trả lời *người này là ai*, còn quyền hỏi *người này đang đứng đâu, lúc này*
   (`architecture.md` §4).
2. **Mốc kiểm là mốc ghi.** Lớp được kiểm **trong giao dịch của chính cửa**, tại `now()` của giao dịch
   ấy — cùng mốc mà thao tác được ghi
   ([`../1-system-design/02-thoi-gian-ngay-ban.md`](../1-system-design/02-thoi-gian-ngay-ban.md)). Người
   vừa rời quầy trước mốc ấy không qua được lớp của quầy.
3. **Hai lớp đọc độc lập, nên cộng vào nhau.** Chủ quán đứng quầy qua được cả lớp của quầy lẫn lớp của
   chủ quán; chủ quán không đứng quầy **không** qua được lớp của quầy (`YC-16`, `shop-facts.md` §6.13).
4. **Người bấm là người đã được kiểm.** Cửa khai người thao tác của giao dịch bằng **chính** người vừa
   qua lớp, rồi mới chạy thân cửa — cột *ai bấm* của mọi thao tác chạm tiền lấy đúng người ấy (`I-012`
   tầng 1). Không xác định được người ⇒ `unauthenticated`, thân cửa không chạy.
5. **Khách QR không phải một người của quán.** Đường của khách mang **mã**, không mang bàn; bàn tra từ
   mã đang hiện hành (`I-023`). Khách gửi kèm một định danh bàn ⇒ `invalid_request`, không dùng.

Lời từ chối của quyền mang mã riêng (`01-hop-dong-api.md` §3): `unauthenticated` · `not_on_counter_duty` ·
`owner_only`; status ở hợp đồng.

## 2. Lớp quyền

| Lớp | Qua khi | Nguồn |
|---|---|---|
| `quay` | người bấm có một khoảng `counter_duty` chứa mốc giao dịch của cửa | `architecture.md` §4 điều 1; `shop-facts.md` §3 · §6.13 · §8.8 (`C36`) |
| `chu_quan` | người bấm mang cờ chủ quán (`person.is_owner`), đứng đâu cũng được | `shop-facts.md` §3 (chủ quán là vai riêng, ngoài năm trạm); `YC-16` |

**Lớp mới** — ví dụ *quầy hoặc chủ quán* cho người nhập lại sổ giấy (`shop-facts.md` §6.11) — do lát cần
nó thêm, **cùng lượt**: một dòng ở bảng này kèm nguồn, một hằng ở `be/internal/authz/`, test từ chối qua
`authz.Run`. Không thêm lớp *cho đủ* trước khi có cửa dùng nó.

## 3. Ma trận cửa × lớp

Mỗi cửa ghi của backend — thư mục `be/internal/<gói>/sql/<cửa>/` (`QC-13`) — có **đúng một** dòng, và
mỗi dòng là một cửa có thật. Gate 1g đọc khuôn dòng ``| `<gói>/<cửa>` | `<lớp>` | <nguồn> |``.

| Cửa | Lớp | Nguồn |
|---|---|---|
| `qr/doi_ma` | `chu_quan` | `shop-facts.md` §6 quy tắc 2 — **U-062** đã đóng: chỉ chủ quán đổi mã, đổi khi quán bị hack |

**Lát sau thêm dòng thế nào:** cùng lượt dựng cửa — thư mục cửa, khai báo `authz.Door{Code, Need}` ngoài
file test, và một dòng ở đây trỏ nguồn nghiệp vụ. Thiếu một trong ba thì Gate 1g đỏ.

## 4. Chỗ trống có tên

| Chỗ trống | Hôm nay | Ai gỡ |
|---|---|---|
| **Cách đăng nhập** của nhân viên và chủ quán | cửa nhận người qua giao diện `authz.Authenticator`; chưa có bản thật, chưa có chương trình chạy | chủ quán — **U-075** |
| **Cửa lớp `quay` đầu tiên** | lớp được chứng minh qua `authz.Run` trên PostgreSQL thật, chưa qua một cửa thật | `P3-07` |
| **Mở · khép khoảng trực quầy** | khoảng trực chỉ ghi được bằng tay ở database | `P3-11` |
| **Hai người dùng chung một danh tính** | máy không phân biệt được (`I-012` tầng 4) | không gỡ ở máy — đối chiếu `I-012/3` |

[↑ đầu file](#top)
