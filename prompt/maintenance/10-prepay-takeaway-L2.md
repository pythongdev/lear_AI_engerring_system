# 10 — Đơn mang đi được trả trước; §6.3 còn viết "không bao giờ thu trước" (L2) · T-020

## Context

- Chủ quán chốt **2026-08-30**: **đơn mang đi có thể thanh toán trước**. Ba vế của lời chốt, hỏi
  và trả lời cùng ngày:
  1. Trả trước là **tuỳ chọn** — mặc định vẫn là thu lúc trao hàng.
  2. Áp cho **cả ba** kênh mang đi: `delivery` · `pickup` · `phone_preorder`.
  3. Huỷ một đơn **đã trả trước** ⇒ hoàn tiền **theo §6.4** — quầy quyết từng ca, phải ghi vết.
- Câu này **lật một luật đã chốt cùng ngày**, không phải điền vào chỗ trống.
  `master_plan/shop-facts.md` §6.3 đang viết *"Thu tiền lúc trao hàng, **không bao giờ thu
  trước**"*, và §5 nhắc lại nó như một trong hai luật chạy xuyên cả hai luồng. Nhật ký chốt §7.1
  có một dòng ngày 2026-08-30 ghi đúng câu đó.
- Luật cũ đang **đỡ một luật khác**, nên nó đổ theo. `shop-facts.md` §2 và `docs/product.md` §2.4
  đều viết: *"Tiền chưa bao giờ thu trước (§6.3) nên huỷ đơn đặt trước **không sinh việc hoàn
  tiền**."* Từ nay câu đó chỉ đúng cho đơn **chưa** trả tiền.

  | Chỗ | Đang viết | Vấn đề |
  |---|---|---|
  | `shop-facts.md` §6.3 (quy tắc 3) | "Thu tiền lúc trao hàng, **không bao giờ thu trước**" | **nặng nhất**: đây là nhà của luật, mọi chỗ khác trỏ về đây |
  | `shop-facts.md` §5, luật xuyên luồng | "Thu tiền lúc TRAO HÀNG, không bao giờ thu trước" | bản thứ hai của cùng câu, đọc trước cả sơ đồ |
  | `shop-facts.md` §5.2 điểm 6 | "Thu tiền lúc trao hàng, có thể ở ngoài quán" | kể điểm khác luồng tại bàn mà thiếu vế trả trước |
  | `shop-facts.md` §2, đoạn huỷ đơn hotline | "Tiền chưa bao giờ thu trước ⇒ huỷ **không sinh việc hoàn tiền**" | **sai từ hôm nay**: đơn đã trả trước mà huỷ thì có hoàn |
  | `shop-facts.md` §7.1 nhật ký chốt | một dòng 2026-08-30 "không thu trước" | nhật ký phải kể được cả hai lần chốt cùng ngày, không mâu thuẫn |
  | `docs/product.md` §1.1 (dòng khách trả tiền) | "trả **lúc nhận hàng**, không trả trước" | tài liệu tra cứu — loại file thứ nhất của F-005 |
  | `docs/product.md` §2.4 | "Tiền chưa bao giờ được thu trước ⇒ huỷ không sinh việc hoàn tiền" | cùng con bug với `shop-facts.md` §2 |
  | `prompt/BA/03-slice-ship-pickup-L2.md` Unknowns | *"Đơn mang đi có được thanh toán trước không?"* | câu hỏi nay đã có lời giải, để nguyên là mời BA-04 hỏi lại |

- **Một chỗ lệch cũ, cùng họ F-006, gặp trên đường**: `docs/product.md` → *Unknowns* viết *"chỉ
  Delivery và Pickup bắt buộc số điện thoại"*, sai với `shop-facts.md` §6.5 (bắt buộc cho **cả
  ba** kênh không gắn bàn). Đây là bản sinh đôi của chỗ T-012 đã sửa ở
  `prompt/BA/01-actors-channels-L1.md`, lần này ở **tài liệu tra cứu**. Sửa luôn, nối vào F-006.

## Goal

`master_plan/shop-facts.md` là nhà duy nhất của luật thu tiền, và luật đó nói đúng thứ chủ quán
chốt 2026-08-30: **mặc định thu lúc trao hàng, khách được chọn trả trước, đơn đã trả trước mà huỷ
thì hoàn theo §6.4**. Không còn chỗ nào trong repo nói "không bao giờ thu trước", và không còn chỗ
nào suy ra "huỷ đơn không bao giờ sinh việc hoàn tiền".

## Scope

Được sửa:
- `master_plan/shop-facts.md` (§2, §5, §5.2, §6.3, §7.1)
- `docs/product.md` (§1.1, §1.2, §2.4, *Unknowns*)
- `prompt/BA/03-slice-ship-pickup-L2.md` (chỉ mục *Unknowns*)
- `work/findings.md` (nối vào F-006)
- `work/backlog.md`

Không được sửa:
- `quality/invariants.md` — invariant về tiền là việc của **BA-06**, file này còn là khuôn rỗng
- `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`, `master_plan/prompt-fullstack.md`
- `prompt/BA/**` ngoài file 03 · `scripts/**` · `CLAUDE.md`

Dòng chép vào `work/scope.txt`:
```text
master_plan/shop-facts.md
docs/product.md
prompt/BA/03-slice-ship-pickup-L2.md
prompt/maintenance/10-prepay-takeaway-L2.md
work/findings.md
work/backlog.md
work/scope.txt
```

## Constraints

- **Trả trước là TUỲ CHỌN, không phải mặc định.** Viết sao cho người đọc thấy ngay đường mặc định
  vẫn là thu lúc trao hàng. Đổi thành "đơn mang đi thu tiền trước" là sai lời chốt.
- **Luồng ăn tại bàn không đổi một chữ** — vẫn thu ở quầy lúc đóng phiên (`shop-facts.md` §5.1).
  Lời chốt chỉ nói về đơn mang đi.
- **Không xoá dòng nhật ký §7.1 ngày 2026-08-30 về §6.3.** Hai lần chốt cùng một ngày là chuyện
  thật; nhật ký phải kể được cả hai mà không tự mâu thuẫn (CLAUDE.md §7.2 — có ngày, có người
  quyết). Sửa dòng cũ cho đúng phần nó vẫn đúng, rồi **thêm** dòng cho lần chốt mới.
- **Giữ đúng 13 quy tắc ở §6** — sửa nội dung quy tắc 3, không thêm quy tắc thứ 14.
- **Không đụng sơ đồ §5.2.** Sơ đồ vẽ đường **mặc định**; nhánh trả trước nói bằng chữ ở §6.3 và
  §5.2 điểm 6. Nhồi nhánh phụ vào sơ đồ ASCII là làm hỏng thứ đang dễ đọc.
- **Không tự quyết ai bấm xác nhận "đã nhận tiền" cho một đơn trả trước.** VietQR là **tĩnh**
  (`shop-facts.md` §1) nên hệ thống không tự biết tiền đã về; với đơn trả trước thì không có ai
  đứng đối diện khách lúc trả. Đây là câu hỏi **mới sinh ra từ chính lời chốt này** ⇒ ghi
  `U-005` ở `docs/product.md` → *Unknowns*, đừng suy ra (CLAUDE.md §3.5).
- **Không đụng câu hỏi "doanh thu tính theo ngày nào"** — nó đã mở sẵn ở bảng mười câu hỏi §10
  (câu 8, BA-06). Trả trước làm nó khó hơn nhưng không phải task này trả lời.
- Không chép giá, số hotline, hay sơ đồ sang file khác (ADR-001, F-001).

## Acceptance

1. `shop-facts.md` §6.3 quy tắc 3 nói đủ ba vế: **mặc định thu lúc trao hàng** · khách **được
   chọn trả trước**, cả ba kênh mang đi · **đơn đã trả trước mà huỷ thì hoàn theo §6.4**. Vẫn
   đúng **13** quy tắc ở §6.
2. `shop-facts.md` §5 (luật xuyên luồng) và §5.2 điểm 6 không còn câu tuyệt đối "không bao giờ
   thu trước", và cả hai trỏ về §6.3 cho nhánh trả trước.
3. `shop-facts.md` §2 (đoạn huỷ đơn hotline) phân biệt được hai ca: đơn **chưa** trả ⇒ huỷ không
   sinh hoàn tiền; đơn **đã** trả trước ⇒ hoàn theo §6.4.
4. `shop-facts.md` §7.1 có **cả hai** dòng 2026-08-30 và đọc liền nhau không mâu thuẫn.
5. `docs/product.md` §1.1 và §2.4 khớp với §6.3 mới; §1.2 nói được nhân viên xác nhận tiền cho
   đơn thu lúc trao hàng, và trỏ U-005 cho đơn trả trước.
6. `docs/product.md` → *Unknowns* có **U-005** đúng khuôn `U-XXX — câu hỏi, ai trả lời được, đang
   chặn gì`, và mục "Hiện không còn câu hỏi nào mở" được sửa cho đúng sự thật.
7. `docs/product.md` → *Unknowns* không còn câu "chỉ Delivery và Pickup bắt buộc số điện thoại".
8. `prompt/BA/03-slice-ship-pickup-L2.md` Unknowns: câu "thanh toán trước" được gạch ngang kèm
   lời giải, đúng cách file đó đang ghi ba câu đã đóng phía trên.
9. `work/findings.md` F-006 có một đoạn nối về chỗ lệch số điện thoại ở `docs/product.md`.
10. `grep -rn 'không bao giờ thu trước\|không trả trước\|chưa bao giờ thu trước'` toàn repo chỉ
    còn kết quả ở **hồ sơ của chính task này** — `work/backlog.md` (entry T-020) và file prompt
    này — nơi câu cũ được **trích lại** để kể task sửa gì. Không còn kết quả nào ở
    `master_plan/**`, `docs/**`, `prompt/BA/**`, tức không còn chỗ nào **khẳng định** luật cũ.
11. `./scripts/gate.sh` xanh; `git status --porcelain` chỉ liệt kê file trong Scope.

## Verify

```bash
./scripts/gate.sh
grep -rn 'không bao giờ thu trước\|không trả trước\|chưa bao giờ được thu trước\|chưa bao giờ thu trước' \
  --include='*.md' . | grep -v 'work/backlog.md\|prompt/maintenance/10-'   # phải rỗng
grep -rn 'trả trước\|thu trước' master_plan/shop-facts.md docs/product.md
grep -c '^[0-9]\{1,2\}\. \*\*' master_plan/shop-facts.md        # §6 vẫn 13 quy tắc
grep -n 'U-005' docs/product.md
grep -n 'chỉ Delivery và Pickup' docs/product.md               # rỗng
git status --porcelain
git diff --stat
```
Gate 2: mỗi dòng Acceptance trỏ tới một `file:dòng` cụ thể sau khi sửa.
Gate 5 (L2): `quality/invariants.md` còn là khuôn rỗng — chưa có invariant nào về tiền để chạy
hồi quy. Nói rõ điều đó trong report thay vì bịa một invariant; BA-06 là task sinh ra nó.

## Unknowns

- **U-005 sinh ra từ chính lời chốt này** (xem Constraints): đơn trả trước thì trả bằng gì, ai bấm
  xác nhận đã nhận tiền, và vào lúc nào? Ghi, không trả lời.
- Không có câu hỏi nghiệp vụ nào khác. Ba vế của lời chốt đã đủ để sửa toàn bộ Scope trên.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
