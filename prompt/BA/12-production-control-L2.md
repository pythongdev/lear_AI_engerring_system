# 12 — Sản xuất theo mẻ và bảng điều hành quầy (L2) · BA-12

> L2 vì nó quyết định **con số nào tồn tại** trong hệ thống. Sai ở đây thì bảng ở quầy báo một
> bàn đã đủ món trong khi khách vẫn ngồi chờ, hoặc bếp nhận việc lẻ từng suất — tức quán chạy
> chậm hơn cách đang làm bằng tay.

## Context

- Nguồn dữ kiện: `master_plan/shop-facts.md` **§5.4** (năng lực bếp, vì sao phải gom, danh sách thứ
  quầy phải nhìn), **§5.3** (một dòng đơn nổ ra thành phần nào), **§4.5** (thành phần một suất bán),
  **§3** (năm trạm), **§7.2** (**S-4** — chỗ suy ra chưa xác nhận).
- Quyết định nền: `docs/decisions.md` **ADR-009** — nhu cầu sản xuất là một trục riêng, không phải
  một trạng thái của đơn.
- Nguồn khung: `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md` §7 (ba vòng đời) — trục sản
  xuất **không** có trong khung gốc; nó đến từ lời chủ quán ngày 2026-08-31.
- Tài liệu tham khảo, **không phải nguồn sự thật**: `work/proposals/admin.admiadmin/admin1.md`.
  Nó có nhiều hình vẽ màn hình và một mô hình dữ liệu; **không** lấy tên trạng thái, tên bảng hay
  cây thư mục từ đó. Lấy được từ nó đúng một thứ: cách đặt câu hỏi.
- Đích: `docs/product/0-ba/ban-hang/03-lat-cat.md` **§3.4**, và đổi tiêu đề §3 từ *"Ba lát cắt nghiệp vụ"* thành **bốn**.
- Đã chốt trước đó: §3.1 (BA-03), §3.2 (BA-04), §5 (BA-07).

## Goal

`docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4 mô tả trọn một lát cắt **sản xuất**: từ lúc một đơn được duyệt, việc của nó
nhập vào tổng nhu cầu của quán, được gom thành mẻ, làm xong, rồi về đúng bàn đã gọi — đủ để người
đứng quầy đọc xong biết bảng trước mặt mình phải hiện những con số nào và con số nào tăng giảm khi
ai làm gì.

## Scope

Được sửa:
- `docs/product/0-ba/ban-hang/03-lat-cat.md` §3.4 (mới) và tiêu đề `## 3.` (đổi số đếm lát cắt)
- `quality/invariants.md` (chỉ **thêm**)
- `work/backlog.md` (đóng BA-12)

Không được sửa:
- §1, §2, §3.1–§3.3, §4–§8 của `docs/product/0-ba/ban-hang/` — kể cả khi thấy chỗ nên sửa; ghi vào Report
- `master_plan/shop-facts.md` — trừ **một** trường hợp: chủ quán trả lời S-4 hoặc U-008–U-011
  **trong lúc** chạy task này, thì ghi vào §5.4 + §7.1 trước, rồi mới viết §3.4
- `docs/decisions.md`, `docs/architecture.md`

Dòng chép vào `work/scope.txt`:
```text
docs/product/
quality/invariants.md
work/backlog.md
```

## Unknowns — trả lời TRƯỚC khi viết, đừng để AI tự quyết

Năm câu, tất cả đều hỏi được trong một lần gặp chủ quán. Bốn câu đầu ở
`docs/product/99-unknowns.md`, câu thứ năm ở `master_plan/shop-facts.md` §7.2:

| # | Câu | Không trả lời thì §3.4 hỏng ở đâu |
|---|---|---|
| **U-008** | Một nồi đang làm trứng còn tráng được bánh không? Một nồi tráng mấy cái bánh cùng lúc? | §3.4 nói được *còn phải làm bao nhiêu*, không nói được *bao giờ xong* |
| **U-009** | Ai bấm "đã làm xong" / "đã bưng ra bàn", theo từng cái hay theo mẻ? | không có ai làm cho con số thay đổi ⇒ bảng đứng yên |
| **U-010** | Đơn mang đi có gom chung bảng với bàn không? | cột "cho bàn nào" không biết ghi gì cho đơn giao tận nơi |
| **U-011** | Máy chỉ hiện tổng, hay được tự chia mẻ? | không biết ai chịu trách nhiệm khi mẻ chia sai |
| ~~**S-4**~~ | ~~"Đã làm xong, còn ở bếp" có phải một con số riêng?~~ | **đã đóng 2026-09-01: CÓ, bốn con số** — xem dưới |
| **U-017** | Quầy bấm "đã làm xong" theo **từng cái**, theo **cả mẻ**, hay theo **cả bàn**? | ba cách cho ra ba con số thứ tư khác nhau — quyết định cách đếm của §3.4 |

**Cập nhật 2026-09-01 (T-036) — bốn câu U-008–U-011 và S-4 đều đã có lời giải; đọc
`master_plan/shop-facts.md` §5.4 và §7.1, đừng hỏi lại.** S-4 trả lời là **có**: bánh gấp xong nằm
chờ (chờ đủ đĩa · chờ người rảnh tay bưng · chờ món khác của cùng bàn), và **người đứng quầy bấm**
nút "đã làm xong" — ba trạm bếp vẫn không bấm gì (U-009 nguyên vẹn). Câu duy nhất còn treo là
**U-017** ở dòng trên.

Câu nào còn treo thì chủ quán trả lời xong ⇒ ghi vào `master_plan/shop-facts.md` **trước** (§5.4
cho nội dung, §7.1 cho nhật ký), rồi mới viết §3.4.

Còn mở mà vẫn phải chạy ⇒ §3.4 viết theo phương án **hẹp nhất** và nói thẳng câu nào đang treo.
**Không** tự chọn phương án rộng rồi ghi là đã chốt. *Cập nhật 2026-09-01: "hẹp nhất" **không còn
là ba con số** — bốn con số nay là dữ kiện đã chốt. Chỗ hẹp nhất còn lại là **cách đếm** con số
thứ tư (U-017): viết bốn con số, và nói rõ chưa chốt bấm theo từng cái hay cả mẻ.*

## Constraints

- **Con số của chủ quán là 2 · 3 · 6** (`shop-facts.md` §5.4). Không chép chúng vào `docs/product/0-ba/ban-hang/03-lat-cat.md`
  — tra ở owner (`work/findings.md` F-001). §3.4 nói *"năng lực một mẻ trứng có giới hạn, tra
  shop-facts §5.4"*, không viết con số.
- **Nhu cầu cộng ngang qua nhiều bàn và nhiều đơn.** Sáu bàn mỗi bàn một combo là **một** dòng nhu
  cầu, không phải sáu. Viết câu này ra; đây là lý do trục tồn tại.
- **Gom nhưng không mất chủ sở hữu.** Mọi con số tổng phải tách ngược về được: bàn nào bao nhiêu.
  Một §3.4 chỉ có tổng là một §3.4 chưa đạt.
- **Gom theo đúng thứ khách chọn** (`shop-facts.md` §4.5): trứng tách theo chín / tái / vàng; bánh
  tách theo nhân và lượng nhân. Hai thành phần cùng tên khác lượng nhân là **hai** dòng.
- **"Đã làm xong" ≠ "đã bưng ra bàn"** — **đã được chủ quán xác nhận 2026-09-01** (S-4), nên §3.4
  dùng **bốn** con số. Cái chưa chốt là *cách đếm* con số thứ tư (U-017), không phải sự tồn tại
  của nó. Đừng viết ngược lại, và đừng quay về ba con số.
- **Trục sản xuất không thay thế trục đơn.** Đơn vẫn có vòng đời của nó (§5, BA-07); §3.4 nói hai
  trục gặp nhau ở đâu — đơn **đã duyệt** mới nhập vào nhu cầu (`shop-facts.md` §6.2), đơn **huỷ**
  rút khỏi nhu cầu.
- **Không có trạm thứ sáu** (`shop-facts.md` §3). Mẻ do trạm có sẵn làm; không đặt tên vai mới.
- Đây là lát cắt **nghiệp vụ**. Không tên trạng thái kiểu mã, không tên bảng dữ liệu, không route,
  không mô tả màn hình theo pixel. Mô tả *con số nào phải nhìn thấy được*, không mô tả *nó nằm ở
  góc nào*.
- **Không nhận cây thư mục hay mô hình dữ liệu của đề xuất.** `work/proposals/` không sở hữu gì
  (`CLAUDE.md` §2).

## Acceptance

1. §3.4 nêu bốn khái niệm của ADR-009 — nhu cầu · mẻ · đã làm xong · đã phục vụ — mỗi khái niệm
   có **đơn vị** của nó và **câu hỏi nó trả lời**.
2. Có câu khẳng định nhu cầu **cộng ngang qua nhiều bàn và nhiều đơn**, kèm ví dụ sáu bàn cùng gọi
   một suất giống nhau ra **một** dòng nhu cầu.
3. Có câu khẳng định mọi con số tổng **tách ngược về được từng bàn**, và ví dụ tách ngược đó.
4. Nêu đủ **mọi thứ** người đứng quầy phải nhìn được theo danh sách ở `shop-facts.md` §5.4 (đếm
   được sáu tính tới 2026-08-31 — đọc lại danh sách ấy, đừng tin con số này), mỗi thứ một dòng.
5. Nêu điểm gặp giữa trục đơn và trục sản xuất: đơn **đã duyệt** mới nhập nhu cầu; đơn **huỷ** rút
   khỏi nhu cầu; nói rõ chuyện gì xảy ra với phần đã làm xong của một đơn bị huỷ.
6. Trứng tách theo **ba loại**, bánh tách theo **nhân và lượng nhân** — có ví dụ cho thấy hai dòng
   không gộp được.
7. Nêu trạng thái của **S-4**: đã xác nhận **2026-09-01**, bốn con số, người đứng quầy bấm — và
   nêu **U-017** là câu còn treo về *cách đếm* con số thứ tư. Không được viết ba con số.
8. Mỗi câu trong U-008–U-011 hoặc đã có lời giải ghi kèm ngày, hoặc được nêu đích danh trong §3.4
   là **đang treo** và nói §3.4 đã chọn phương án hẹp nào thay cho nó.
9. `quality/invariants.md` có ít nhất hai invariant: (a) tổng nhu cầu của một thành phần luôn bằng
   tổng phần chia về từng bàn — gom không được làm mất hay đẻ ra số lượng; (b) số đã phục vụ của
   một bàn không bao giờ vượt số bàn đó đã gọi. Mục *Verification* của cả hai không được để trống.
10. §3.4 **không** chứa con số 2, 3 hay 6 lấy từ `shop-facts.md` §5.4 (F-001 — trỏ, đừng chép).
11. §3.4 không chứa tên trạng thái kiểu mã, tên bảng dữ liệu, route, hay tên thư mục.
12. Tiêu đề `## 3.` của `docs/product/0-ba/ban-hang/03-lat-cat.md` đã đổi sang **bốn** lát cắt, và mục lục/liên kết nội bộ
    (nếu có) đi theo.

## Verify

```bash
./scripts/gate.sh
sed -n '/^### 3.4/,$p' docs/product/0-ba/ban-hang/03-lat-cat.md | grep -nE '\b(2|3|6)\b'   # đọc tay: không phải số của §5.4
grep -n 'Ba lát cắt' docs/product/0-ba/ban-hang/03-lat-cat.md   # phải rỗng
grep -nE '[A-Z_]{4,}|status *=|/admin/|table[s]? *\(' docs/product/0-ba/ban-hang/03-lat-cat.md   # không có tên mã, route, bảng
grep -n 'S-4' docs/product/0-ba/ban-hang/03-lat-cat.md   # trạng thái S-4 có mặt
git status --porcelain
```

Gate 2: ánh xạ từng dòng Acceptance → bằng chứng.
Gate 5 (L2): tự tay dò một lượt — lấy ví dụ sáu bàn ở Acceptance 2, cộng xuôi ra tổng rồi tách
ngược về sáu bàn; hai chiều không khớp = chưa đạt.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- U-008–U-011 và S-4: câu nào đã có lời giải (kèm ngày, ai trả lời), câu nào còn treo, và §3.4 đã
  chọn phương án hẹp nào thay cho câu còn treo
- Đã verify bằng cách nào, kết quả ra sao
- Chỗ nào trong §3.1–§3.3 hoặc §5 mâu thuẫn với §3.4 mà task này **không** được sửa
