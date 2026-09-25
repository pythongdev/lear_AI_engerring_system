# 04 — Yêu cầu khi làm việc với Frontend (AGENTS.md của lane FE)

> Cập nhật **2026-08-12** · Lane sở hữu: **FE** · Dời từ `fe/AGENTS.md`
> (`git log --follow -M40% -- design/frontend/04-yeu-cau.md` — `--follow` trần **không** ra, file bị
> viết lại quá nửa nên ngưỡng rename mặc định 50% không nhận).
> Luật chung ở [/CLAUDE.md](../../CLAUDE.md) — không chép về đây.
> Sự thật FE khác: [thiết kế](01-thiet-ke.md) · [luật/thước](02-luat.md) · [hiện trạng](03-hien-trang.md).
>
> **`fe/` hiện không còn file nào** — `T-76` dời file luật cuối cùng về đây, và đó là kết quả mong
> muốn, không phải mất file ([03-hien-trang.md](03-hien-trang.md) đo bằng lệnh). Chưa một dòng code
> FE nào ([F-30](../../finding.md#f-30)). Task dựng app là `T-23` (`create-next-app` + service `fe`
> trong compose + `tsconfig` strict). Luật viết trước code là cố ý: `create-next-app` sẽ đẻ file,
> luật thì không tự sinh ra.

**Chạm bất kỳ file nào trong `fe/` thì nạp file này trước.** Nó là gói bắt buộc của lane FE
ở [CLAUDE.md §1](../../CLAUDE.md) — §1 còn khai lối vào cũ `fe/AGENTS.md`, xem [F-60](../../finding.md#f-60).

## Biên nhận của lane này — **hôm nay không chạy được, đang vay của lane NON-CODE**

`make test-fe` (typecheck + lint + test) **chưa tồn tại** — nó gắn vào `Makefile` ở `T-23`.
[CLAUDE.md §1](../../CLAUDE.md) khai biên nhận FE là `npm run build` + `tsc --noEmit`, nhưng **không
lệnh nào trong hai lệnh đó chạy được**: `fe/` không có `package.json`, không có `node_modules`,
không có `tsconfig.json` ([F-30](../../finding.md#f-30)).

⇒ Tới khi `T-23` dựng xong `fe/`, mọi task lane FE **vay biên nhận của lane NON-CODE**: **lệnh đọc
lại** ([CLAUDE.md §8](../../CLAUDE.md)) — `grep` ra đúng số hit đã khai, `git log --follow`, hoặc
`make status`. **Phải ghi rõ là vay** ở dòng task; đánh ✅ mà lặng lẽ dùng biên nhận vay là khai
sai biên nhận. Chi tiết + cách đóng: [F-59](../../finding.md#f-59).

## Luật riêng lane FE

1. **FE không tính giá.** Mọi con số tiền đến từ `/orders/quote` hoặc từ đơn đã tạo.
   Nhân giá ở client = hai công thức giá, và cái ở client sẽ sai.
2. **Type sinh từ `openapi.yaml`** (`npm run gen:api`), **cấm `any`**, cấm gõ tay type response.
3. **Không tin giá trong `localStorage`.** Giỏ hàng lưu `product_id` + `option_ids` + `quantity`;
   trước checkout luôn gọi `/orders/quote` lại. Món `is_available = false` bị loại khỏi giỏ **có thông báo**.
4. **Chống bấm đúp**: disable nút khi đang gửi, và khoá theo khoá đơn — bấm đúp không được tạo 2 đơn.
5. **Ràng buộc UI đã chốt là nghiệp vụ, không phải gu thẩm mỹ** ([F-31](../../finding.md#f-31)):
   chọn Chay ⇒ hàng "Lượng nhân" **biến mất hẳn**, không phải làm mờ.
6. **Màn hình trạm đọc từ 1 mét**: tên món ≥ 24px, số lượng ≥ 40px; màu theo thời gian chờ tính
   **từ lúc lên `todo`**. Bếp thiếu sáng ⇒ không được phân biệt trạng thái **chỉ** bằng màu.
7. **Ba luồng E2E, không nhiều hơn** (`T-30`). Selector dùng `getByRole`/`getByText`;
   `data-testid` chỉ cho số tiền. Cấm bám class Tailwind.
8. Máy khách là **điện thoại + wifi quán**: mọi màn hình phải thử ở 360px và ở mạng chậm.
