# §6 — Ngoại lệ

> Nguyên văn `docs/product.md` §6, tách 2026-09-02 · DOC-1 · ADR-014. **Owner của mục
> này** — bản lưu không sở hữu gì. Giữ nguyên số §6: ~180 câu trong repo trỏ theo số cũ.

<!-- ==== nguyên văn docs/product.md §6, tách 2026-09-02 ==== -->
## 6. Ngoại lệ

> **Quyết định gốc của mục này:** → **ADR-018** (dòng 5 — món hết) · **ADR-017** (dòng 13 — đơn
> đã hoàn thành cần điều chỉnh) · **ADR-016** (dòng 11–12 — sổ giấy) · **ADR-030** (dòng 9 — chưa
> thấy báo có) · **ADR-020** (đường tiền của mọi dòng huỷ). Dòng 4 và dòng 14 — hai dòng cuối
> cùng còn mang dấu ⚠ — đã chốt ngày 2026-09-02: `master_plan/shop-facts.md` **§6.22** và
> `quality/invariants.md` **I-018**. **Không dòng nào của bảng còn ⚠**, và **GĐ-01, GĐ-05** nay
> cũng đã bị thay như ba giả định trước.

Mục này chốt **cách quán xử lý**, không chốt cách máy làm. Mỗi dòng nói ba thứ: **ai xử lý**, đơn
hoặc phiên **về trạng thái nào** (tên trạng thái lấy nguyên ở §5), và **tiền** ra sao (luật ở §4).
Cách hệ thống kỹ thuật thực hiện — thử lại, hàng chờ, bộ nhớ đệm khi mất mạng — **không** thuộc mục
này và cũng không thuộc giai đoạn BA.

Danh sách mười bốn tình huống lấy nguyên của kế hoạch gốc §8, không bớt dòng nào. **Tính tới
2026-09-02 cả mười bốn dòng đều có lời chốt của chủ quán** — không dòng nào còn mang dấu
**⚠ Chưa chốt**, và mục *Unknowns* rỗng. Quy ước vẫn giữ nguyên cho lần sau: một dòng chưa chốt thì
mang dấu ⚠ và trỏ tới **GĐ-XXX** (`docs/decisions.md`) hoặc **U-XXX** (*Unknowns*) — không chỗ nào
để trống lặng lẽ.

**Mười một trong mười bốn dòng chốt trong lượt đầu.** Ngày 2026-09-02 chủ quán trả lời bốn câu cùng
lúc, và cả bốn cùng một hình dạng: **POS quyết theo tình hình thực tế, không có luật cứng** — đúng
họ với hoàn tiền (§4.8) và đường lùi một mẻ (§5.4). Đó là lời chốt về **cách quán vận hành**, không
phải chỗ tài liệu còn thiếu: sản phẩm không được dựng hàng rào ở những chỗ này.

### 6.1 Bảng mười bốn tình huống

| # | Tình huống | Ai xử lý | Kết quả với đơn / phiên | Kết quả với tiền |
|---|---|---|---|---|
| 1 | **Khách gửi nhầm đơn QR** | *Người đứng quầy*, trên POS — khách **không** có cửa tự huỷ (`shop-facts.md` §6.13) | Đơn đang ở `Chờ xác nhận` ⇒ `Huỷ`. Chưa duyệt thì **chưa việc trạm nào được sinh** (I-004), nên không có gì phải rút khỏi bếp. Phiên bàn của nó **giữ nguyên** trạng thái đang có | Chưa thu ⇒ **không sinh việc gì về tiền** (§4.7). Đơn mang đi **đã trả trước** ⇒ sinh việc hoàn, xử theo §4.8 |
| 2 | **Quầy từ chối đơn QR** | *Người đứng quầy* (`shop-facts.md` §6.2, §6.13) | `Chờ xác nhận` ⇒ `Huỷ` — dòng có sẵn ở bảng §5.2. Đơn bị từ chối **không** vào hoá đơn của phiên | Không có gì: đơn chưa duyệt chưa bao giờ chạm tiền |
| 3 | **Khách gọi thêm sau khi quầy đã bắt đầu thu tiền** | *Khách* (QR tại bàn) hoặc *người đứng quầy* (đặt hộ) | Phiên `Chờ thanh toán` ⇒ **quay lại** `Đang phục vụ` (§5.3). Đơn mới đi vòng đời đơn bình thường | Vào **cùng phiên, cùng một hoá đơn** (`shop-facts.md` §6.1). Mở hoá đơn thứ hai là **thu thiếu tiền** — lỗi tiền nguy hiểm nhất của luồng tại bàn. Lượt gọi mới tính **giá tại thời điểm tạo lượt gọi** (§4.4) |
| 4 | **Hai người cùng thao tác trên một bàn** | *Người đứng quầy* và *khách* (QR) đều ghi được; **người bấm sau thắng** (chủ quán chốt 2026-09-02, `shop-facts.md` §6.22) | Lần ghi sau **đè** lần ghi trước — không có khoá, không có cảnh báo. Nhưng lần đè ấy **phải giữ bản trước và tên người sửa** (§6.22, `quality/invariants.md` **I-018**) | **Đây là chỗ mất tiền nếu làm ẩu:** một lượt gọi bị đè mất mà không dựng lại được là **thu thiếu tiền** đúng nghĩa §4.5. Bản ghi phải dựng lại được lượt gọi đã bị đè |
| 5 | **Món hết sau khi khách đã chọn** | *Người đứng quầy*, trên POS — **bàn với khách**, không tự thay thế và không tự huỷ (`shop-facts.md` §6.20) | **Kết quả là cái hai bên thống nhất tại lúc đó**: đổi sang thứ khác · bỏ phần thiếu · hoặc cả đơn sang `Huỷ`. Không có luật cứng chọn sẵn — xem §6.3, ca này thường áp cho **nhiều bàn một lúc** | Bớt món ⇒ bớt số phải trả. Đơn **đã trả trước** mà huỷ ⇒ sinh việc hoàn, xử theo §4.8 (quầy quyết từng ca, trừ vào doanh thu **ngày hoàn**) |
| 6 | **Chủ quán tạm dừng nhận đơn** | *Chủ quán*, trên phần quản trị | Chặn đơn **mới**; nút này **thắng giờ mở cửa** (`shop-facts.md` §6.8, I-008). Đơn đang chạy **không** đổi trạng thái, việc đang làm ở bếp **không** dừng — không có trạng thái "tạm dừng" của việc trạm (§5.4) | Không đổi. Đơn đã nhận trước lúc bấm vẫn thu bình thường |
| 7 | **Khách huỷ đơn** | Khách **báo**, *người đứng quầy* bấm trên POS — quyền huỷ gắn với **chỗ đứng**, không gắn chức vụ (`shop-facts.md` §6.13) | `Chờ xác nhận`, `Đã xác nhận` hoặc `Đang thực hiện` ⇒ `Huỷ` (§5.2). Việc trạm chưa xong của đơn ấy **rời bảng bếp cùng lúc** (§5.4). **Ranh giới trên:** `Hoàn thành` ⇒ `Huỷ` cũng **hợp lệ** — quầy huỷ được cả đơn đã trao, POS quyết từng ca (chủ quán chốt 2026-09-02, đóng **U-027**; bảng §5.2 có đúng dòng ấy, và dòng 13 của bảng này) | Chưa trả ⇒ không gì. **Đã trả trước** ⇒ hoàn theo §4.8: quầy quyết từng ca, **mọi lần đều để lại vết**, và khoản hoàn trừ vào doanh thu **ngày hoàn** |
| 8 | **Nhân viên huỷ đơn** | **Chỉ** *người đứng quầy*, trên POS. Bốn trạm còn lại (`trang_banh`, `gap_banh`, `canh`, `don_ban`) **không** huỷ được, kể cả đơn của chính việc mình đang làm. Chủ quán **không** đứng quầy thì **nhờ quầy bấm** — chức vụ không mở thêm cửa nào (`shop-facts.md` §6.13) | Như dòng 7 | Như dòng 7. Mọi lần huỷ đi qua **đúng một cửa**, nên lần nào cũng có đúng một người đứng tên khi đối soát (§4.9) |
| 9 | **Thanh toán thất bại hoặc chưa xác nhận được** | *Người đứng quầy*, trên POS — **bàn với khách và quyết ngay lúc đó** (`shop-facts.md` §6.21). VietQR của quán là mã **tĩnh** nên máy **không bao giờ** tự biết tiền đã về; câu *"đã nhận tiền"* chỉ do người bấm ở POS tạo ra (§4.6) | **Hai đường ra, cả hai đã có sẵn:** quầy tin và cho khách đi ⇒ phiên `Chờ thanh toán` sang `Đã đóng` theo đường **nợ** (dòng 10), xoá nợ khi tin nhắn tới · hoặc quầy **chờ tin nhắn** rồi mới đóng phiên. Không đẻ trạng thái mới | Thu được **một phần** thì phần thiếu là **nợ** (§4.7). **Dù chọn đường nào cũng không ghi phần chuyển khoản thành tiền mặt** — §4.9 đối soát tiền mặt bằng **két**, chuyển khoản bằng **tin nhắn báo có**, cấm cộng gộp |
| 10 | **Khách rời bàn nhưng chưa thanh toán** | *Người đứng quầy*, trên POS (`shop-facts.md` §6.14) | Phiên `Chờ thanh toán` ⇒ `Đã đóng` — **tiền chưa thu không chặn phiên đóng** (§5.3, I-017). Bàn sang `Bàn cần dọn`, dọn xong về `Trống` | Quán **cho nợ**. Đóng phiên **bắt buộc ghi ai nợ và nợ bao nhiêu** — thiếu một trong hai thì khoản nợ vô chủ. Doanh thu tính vào **ngày ghi nợ**, không phải ngày thu được tiền; két thiếu đúng bằng tổng nợ ghi trong ngày (§4.7, §4.10) |
| 11 | **Mất mạng trong lúc quán đang phục vụ** | Cả quán chuyển cách làm; *người đứng quầy* giữ sổ (`shop-facts.md` §6.11) | **Không dừng bán.** Đơn và phiên vẫn chạy đúng các trạng thái §5, nhưng ghi **trên sổ giấy** thay vì trên máy | Thu bình thường, ghi sổ. Phần ghi tay phải nhập lại để đối soát cuối ngày còn đọc được (§4.9) |
| 12 | **Mất điện hoặc thiết bị POS gặp sự cố** | Như dòng 11 (`shop-facts.md` §6.11) | Như dòng 11 | Như dòng 11 |
| 13 | **Đơn đã hoàn thành nhưng cần điều chỉnh** | *Người đứng quầy*, trên POS — **sửa chính đơn ấy**, không huỷ rồi tạo lại (`shop-facts.md` §6.19) | **Sửa được, kể cả đơn đã `Hoàn thành`** (chủ quán chốt 2026-09-02: *bất kỳ trạng thái nào*, POS quyết theo tình hình thực tế). Sửa **không phải** một chuyển tiếp trạng thái — đơn đang ở đâu vẫn ở đó, cái đổi là món / số suất / tuỳ chọn (§5.2). **Huỷ cũng được, kể cả đơn đã `Hoàn thành`** (chủ quán chốt 2026-09-02, trả lời U-027) — bảng §5.2 nay có dòng ấy. ⇒ Quầy có **hai** đường cho ca này, sửa hoặc huỷ, và POS chọn theo ca thật | Chênh lệch sau khi sửa: thu thêm, hoặc **hoàn** theo §4.8 — khoản hoàn trừ vào doanh thu **ngày hoàn**. Mỗi lần sửa **để lại vết** (§4.9). **Dòng vừa sửa lấy giá đang hiệu lực LÚC SỬA** (chủ quán chốt 2026-09-02, U-026) — sửa một dòng là **đặt lại mốc khoá giá** của chính dòng ấy (§4.4). Vết phải ghi **cả giá cũ lẫn giá mới** |
| 14 | **Nhân viên thao tác nhầm trạng thái** | *Người đứng quầy*, trên POS | *Đã chốt cho ca hay xảy ra nhất:* bấm nhầm *"đã làm xong"* một **mẻ** ⇒ **lùi được**, `Đã làm xong, còn ở bếp` ⇒ `Chưa làm` (§5.4). **Không có mốc thời gian cứng** — quầy quyết từng ca. **Mọi thao tác nhầm khác** — duyệt nhầm, huỷ nhầm, đóng phiên nhầm — **không có nút hoàn tác**, nhưng **có nút cập nhật** (chủ quán chốt 2026-09-02, `shop-facts.md` §6.22). Mỗi lần cập nhật giữ **bản trước · bản sau · lý do · người sửa** (**I-018**) | Lùi một mẻ **phải để lại vết** — lùi mẻ nào, lúc mấy giờ, ai bấm: một mẻ lùi sai là một suất tính nhầm (I-012) |

### 6.2 Dòng nào đã chốt, và chốt từ đâu

**Ba dòng đã là quy tắc của quán trước khi §6 được viết:**

- **Gọi thêm khi quầy đang thu tiền** (dòng 3) — cùng phiên, cùng hoá đơn (`shop-facts.md` §6.1).
- **Tạm dừng nhận đơn** (dòng 6) — thắng giờ mở cửa, kể cả đang trong giờ bán (`shop-facts.md` §6.8).
- **Mất mạng / mất điện / POS hỏng** (dòng 11 và 12) — **sổ giấy, quán vẫn bán** (`shop-facts.md` §6.11).

**Bốn dòng chốt thêm ngày 2026-09-02**, cùng một lần trả lời:

- **Món hết sau khi khách đã chọn** (dòng 5) — POS **bàn với khách**, quyết tại lúc thoả thuận xong
  (`shop-facts.md` §6.20). Đóng **câu 3** của bảng mười câu hỏi trong `work/backlog.md`.
- **Khách nói đã chuyển khoản mà chưa thấy báo có** (dòng 9) — POS bàn với khách, quyết ngay lúc đó;
  hai đường ra là ghi **nợ** hoặc **chờ tin nhắn** (`shop-facts.md` §6.21).
- **Đơn đã hoàn thành cần điều chỉnh** (dòng 13) — **sửa được ở bất kỳ trạng thái nào**
  (`shop-facts.md` §6.19), và **huỷ cũng được** ở bất kỳ trạng thái nào: đường
  `Hoàn thành` ⇒ `Huỷ` **có**, nằm ở bảng §5.2 (chủ quán chốt 2026-09-02, đóng **U-027**).
  ⇒ Quầy **chọn** giữa sửa và huỷ theo từng ca; cả hai đường đều mở sẵn.
- **Sổ giấy lúc mất điện** (dòng 11 và 12) — **POS hoặc chủ quán** giữ sổ và nhập lại, **nhập ngay
  khi có thể** (`shop-facts.md` §6.11).

**Không còn chỗ nào ⚠ — cả mười bốn dòng đều có lời chốt** kể từ 2026-09-02. Hai dòng cuối cùng
(4 và 14) được chủ quán xác nhận đúng như hai giả định GĐ-01 và GĐ-05 đã đoán, **nhưng kèm một yêu
cầu không ai hỏi**: mỗi lần cập nhật phải giữ **bản trước, bản sau, lý do và người sửa** — nay là
`shop-facts.md` **§6.22** và `quality/invariants.md` **I-018**. ⇒ Đây là lần duy nhất trong năm
giả định mà chủ quán **thêm** vào thay vì lật ngược.

**Dòng 13 hết ⚠ ngày 2026-09-02:** vế cuối của nó — *giá của dòng vừa sửa* — đã có lời chốt
(**U-026**: lấy giá đang hiệu lực lúc sửa, `shop-facts.md` §6.19, chi tiết ở §4.4).

### 6.3 Hết một THÀNH PHẦN, không phải hết một dòng menu

Dòng 5 nay đã có lời chốt — POS bàn với khách — nhưng có một dữ kiện phải đọc kèm nó, nếu không cả
tình huống sẽ bị hiểu sai **cỡ**, và lời chốt ấy sẽ bị đọc thành chuyện của một cuộc gọi lẻ:

- **Mọi suất bán đều gồm nhiều thành phần** (`shop-facts.md` §4.5) — kể cả suất trứng và suất giò
  đều kèm bốn cái bánh. Nên "hết món" ở quán này gần như luôn là **hết một thành phần**, và câu hỏi
  thật là: hết một thành phần thì làm gì với **cả suất**.
- ⇒ **Hết bánh cuốn là hết gần như mọi món.** Đây không phải một dòng menu tắt đèn; nó là phần lớn
  thực đơn tắt cùng lúc. Ai đọc dòng 5 như chuyện của một món lẻ là đọc sai quy mô.
- Đường xử lý cho đơn **chưa vào** là chủ quán bấm **tạm dừng nhận đơn** (dòng 6) — nút ấy chặn đơn
  **mới**. Còn những đơn **đã nhận** rồi thì đi theo dòng 5: POS bàn với từng khách
  (`shop-facts.md` §6.20). **Phải làm cả hai**, chúng không thay được cho nhau.
- ⇒ **Lời chốt của dòng 5 áp cho NHIỀU BÀN một lúc.** Hết bánh giữa buổi không sinh một cuộc gọi mà
  sinh một loạt; sản phẩm phải làm được việc ấy hàng loạt, và người đứng quầy là người gánh nó
  — cùng đôi tay đã gánh sáu thao tác khác (`shop-facts.md` §5.4). Đây là chỗ **§7** (BA-09) phải
  cân nhắc khi chốt phạm vi MVP.

### 6.4 Bốn việc mục này cố ý không nói tới

- **Cách hệ thống kỹ thuật chịu lỗi.** Thử lại, hàng chờ, đồng bộ lại sau khi có mạng, lưu tạm dưới
  máy — §6 chốt **quán làm gì bằng tay**; phần máy là System Design, không phải BA.
- **Bất biến mới.** §6 mô tả cách xử lý, không thêm dòng nào vào `quality/invariants.md`. Cách xử lý
  ở đây phải **không phá** bất biến nào đang có — ba dòng chạm tiền nặng nhất (9, 10, 13) đã được
  đối chiếu với I-005, I-012, I-017.
- **Phạm vi MVP.** Ngoại lệ nào được làm ngay, ngoại lệ nào để sau: **§7** (BA-09).
- **Chốt luật thay chủ quán.** Không còn dòng nào ⚠, nhưng quy ước thì còn: một ngoại lệ mới mà
  chưa ai hỏi chủ quán là **câu hỏi**, không phải chỗ để việc thực hiện tự quyết (CLAUDE.md §3.5).
  Năm giả định từng đứng ở mục này đều bị chủ quán **thay hoặc bổ sung** trong hai ngày — bốn lần
  vì đoán **chặt hơn** quán thật, một lần vì đoán **thiếu** (GĐ-01, GĐ-05 — thiếu yêu cầu giữ bản
  trước và bản sau). Đó là lý do quy ước ấy phải sống tiếp.

