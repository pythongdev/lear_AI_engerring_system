# 05 — Bộ prompt BA còn mô tả luồng mang đi bằng hai kênh (L1) · T-012

## Context

- T-011 (2026-08-30) đã sửa **tài liệu khung** `master_plan/BA_initial_plan_banh_cuon_ba_thanh.md`:
  §3 Epic B, §4.2, §5 quy tắc 8, §6 Thanh toán, §11 dòng BA-04, §12 scenario 2 nay đều nói luồng
  **mang đi** gồm ba kênh không gắn bàn. Nhà thật là `master_plan/shop-facts.md` §5.2.
- Còn lại **loại file thứ ba** trong `work/findings.md` F-005 — `prompt/**`, thứ phiên sau đọc rồi
  làm theo. `prompt/BA/03-slice-ship-pickup-L2.md` **đã** phủ đủ ba kênh (dòng 51: *"Lát cắt này
  phủ BA kênh không gắn bàn, không phải hai"*), nhưng các prompt khác thì chưa. Tính tới
  2026-08-30:

  | Chỗ | Đang viết | Vấn đề |
  |---|---|---|
  | `10-acceptance-scenarios-L2.md` dòng 45 | "2. Khách đặt ship/pickup → quán xác nhận → hoàn thành." | **nặng nhất**: BA-11 tick theo dòng này, tức đóng cả giai đoạn BA mà một kênh chưa ai nghiệm thu |
  | `05-pricing-payment-L2.md` dòng 17 · 49 · 74 · 98 · 104 | "đơn ship/pickup độc lập", "Ship/pickup: mỗi đơn là một đơn vị thanh toán", "cộng từ HAI nguồn: phiên bàn và đơn lẻ (ship/pickup)" | BA-06 chốt quy tắc tiền cho hai trong ba kênh |
  | `03-slice-ship-pickup-L2.md` dòng 1 · 3 · 19 · 41 · 44 · 66 · 77 | tiêu đề và các câu vẫn gọi lát cắt là "ship/pickup" | mâu thuẫn với chính dòng 51 của nó |
  | `README.md` dòng 54 | "`docs/product.md` §3.2 Luồng ship/pickup" | bảng tra của cả bộ prompt |

- `work/findings.md` **F-006** đã đặt tên đúng con bug này: chỗ lệch **không chứa con số nào** nên
  grep theo số không thấy; phải grep theo **định danh** kênh, và tài liệu phải **gọi tên luồng**
  thay vì liệt kê hai trong ba thành viên.
- **Chạy trước BA-04, BA-06 và BA-11.** Ba task đó đọc đúng các prompt trên.

## Goal

Không còn prompt nào trong `prompt/BA/` mô tả luồng mang đi bằng cách kể hai kênh. Một người nhận
bất kỳ prompt nào trong bộ đó đều thấy lát cắt mang đi là **ba** kênh: `delivery`, `pickup`,
`phone_preorder`.

## Scope

Được sửa:
- `prompt/BA/*.md` (gồm cả `README.md` của thư mục đó)
- `work/backlog.md` (ô trạng thái T-012)
- `work/findings.md` (chỉ khi phát hiện chỗ lệch mà bảng Context chưa kể — xem *Unknowns*)

Không được sửa:
- `master_plan/**` (T-011 đã sửa xong; `shop-facts.md` là nhà thật)
- `docs/**`, `quality/**`, `scripts/**`
- `prompt/maintenance/**`

Dòng chép vào `work/scope.txt`:
```text
prompt/BA/
work/backlog.md
work/findings.md
work/scope.txt
```

## Constraints

- **Không đổi tên file.** `03-slice-ship-pickup-L2.md` giữ nguyên tên dù nội dung nói ba kênh:
  `prompt/BA/README.md`, `work/backlog.md` và §11 kế hoạch gốc trỏ tới nó theo tên. Đổi tên là gãy
  pointer — thứ mà F-005 gọi là bug phải sửa trong cùng lần, không phải task sau. Sửa **tiêu đề bên
  trong** file thì được.
- **Không đổi ID `BA-01`–`BA-11`**, không thêm/bớt prompt, không đổi level (L1/L2/L3) của prompt nào.
- **Doanh thu vẫn cộng từ HAI nguồn, không phải ba.** `05-pricing-payment-L2.md` dòng 74 và 104 chia
  theo **đơn vị thanh toán** (phiên bàn ↔ đơn lẻ), không chia theo kênh — `shop-facts.md` §5 bảng
  đầu mục. Sửa chỗ "(ship/pickup)" thành đơn mang đi đủ ba kênh, **giữ nguyên con số hai nguồn**.
- **Đừng chép sơ đồ `shop-facts.md` §5.2 vào prompt.** Chỗ cần chi tiết thì trỏ (ADR-001, F-001).
  Không chép số hotline, không chép giá.
- **Không đụng vào các dòng Unknowns đã gạch ngang** (`~~...~~`) trong `03-slice-ship-pickup-L2.md`
  — chúng là nhật ký câu hỏi đã được trả lời, không phải chỗ lệch.
- Số bước, số dòng Acceptance và số scenario trong mỗi prompt **không đổi**. Đây là việc sửa chữ
  cho đúng phạm vi, không phải viết lại prompt.

## Acceptance

- `10-acceptance-scenarios-L2.md` scenario 2 nêu đủ ba kênh và nói được đơn `phone_preorder` **không
  qua bước quầy duyệt** (nhân viên nhập hộ — `shop-facts.md` §5.2). Vẫn đúng **ba** scenario.
- `05-pricing-payment-L2.md`: mọi chỗ nói đơn vị thanh toán của đơn không gắn bàn đều phủ ba kênh;
  câu doanh thu vẫn là **hai** nguồn.
- `03-slice-ship-pickup-L2.md` không còn câu nào tự mâu thuẫn với dòng 51 của chính nó.
- `prompt/BA/README.md` dòng của prompt 03 gọi lát cắt bằng tên phủ ba kênh, và **tên file trong ô
  đó không đổi một ký tự**.
- `grep -rn 'ship/pickup\|Ship / Pickup' prompt/BA/` — mọi kết quả còn lại phải là chỗ **cố ý** nói
  hai kênh (nếu không còn chỗ nào cố ý thì kết quả rỗng); không được còn chỗ nào mô tả cả luồng.
- `grep -rn 'phone_preorder' prompt/BA/` ra kết quả ở **ít nhất** năm file: `01`, `03`, `05`, `08`,
  `09`, `10`.
- `grep -rn '0382688666\|[0-9]\{1,3\}\.000' prompt/BA/` rỗng.
- `git status --porcelain` chỉ liệt kê file trong Scope; **không có file nào bị đổi tên**.
- `./scripts/gate.sh` xanh.

## Verify

```bash
./scripts/gate.sh
grep -rn 'ship/pickup\|Ship / Pickup' prompt/BA/          # còn lại phải là chỗ nói đúng
grep -rn 'phone_preorder' prompt/BA/                      # ≥ 5 file
grep -rn 'HAI nguồn\|hai nguồn' prompt/BA/05-pricing-payment-L2.md
grep -rnE '0382688666|[0-9]{1,3}\.000' prompt/BA/         # rỗng
git status --porcelain                                    # chỉ file trong Scope, không rename
git diff --stat -- prompt/BA/
```
Gate 2: với mỗi dòng Acceptance, trỏ tới dòng cụ thể trong file chứng minh nó.

## Unknowns

- Không có câu hỏi nghiệp vụ. Luồng ba kênh đã chốt ở `shop-facts.md` §5.2 (chủ quán chốt
  2026-08-30) và khung đã khớp từ T-011.
- Nếu tìm thấy chỗ lệch **ngoài bảng Context** (một prompt khác kể hai kênh, hoặc một dòng
  `prompt/BA/README.md` khác): sửa luôn trong cùng lần này và **nối thêm vào F-006**, đừng mở
  F-007 mới — cùng một con bug, cùng một luật, một finding là đủ.

## Report (AI trả lời sau khi làm)

- Đã thay đổi gì
- Đã verify bằng cách nào, kết quả ra sao
- Còn vấn đề gì chưa giải quyết
