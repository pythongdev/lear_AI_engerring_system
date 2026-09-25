# 04 — Yêu cầu khi làm việc với Backend (AGENTS.md của lane BE)

> Cập nhật **2026-08-19** · Lane sở hữu: **BE** · Dời từ `code/be/AGENTS.md` (`git log --follow`).
> Luật chung ở [/CLAUDE.md](../../CLAUDE.md) — không chép về đây.
> Sự thật BE khác: [thiết kế](01-thiet-ke.md) · [luật/thước](02-luat.md) · [hiện trạng](03-hien-trang.md).
> Lane DB có file riêng: [design/data_base/04-yeu-cau.md](../data_base/04-yeu-cau.md).

**Chạm bất kỳ file nào trong `code/be/` thì nạp file này trước.** Nó là gói bắt buộc của lane BE
ở [CLAUDE.md §1](../../CLAUDE.md).

## Biên nhận của lane này

```bash
make check                  # build → vet → lint → test -race, chạy từ gốc repo
make test-int TEST_DB_DSN='...'   # thêm test tích hợp, cần make up trước
```

Nội dung thật của hai target nằm ở [Makefile](../../Makefile) — đừng chép sang đây, và đừng tự sửa
nó khi đang làm task khác: `Makefile` thuộc lane DevOps ([CLAUDE.md §2.4](../../CLAUDE.md)).

**Năm luật biên giới module + lệnh kiểm từng luật** ở [01-thiet-ke.md §3.0](01-thiet-ke.md). Chúng
chưa nằm trong `make check` (target đó thuộc lane DevOps) — chạy tay trước khi commit.

## Luật riêng lane BE

1. **Giá luôn tính ở BE** qua `menu.CalcItemPrice`. Client gửi `product_id`, `option_ids`,
   `quantity` — **không bao giờ** gửi giá. Nhận giá từ client = lỗi mất tiền.
2. **Snapshot tên + giá** vào `order_items` / `order_item_options` khi tạo đơn, trong cùng transaction.
3. **Chia theo module nghiệp vụ, không theo tầng kỹ thuật** ([01-thiet-ke.md §3.0](01-thiet-ke.md), chốt
   2026-08-18). Ba tầng `http → service → store` **vẫn** đi một chiều — http không viết SQL, store không
   biết HTTP — nhưng chúng nằm **trong mỗi module** (`internal/order/service.go`), không phải ba package
   toàn cục (`internal/service/order.go`). Khác nhau một dấu gạch chéo, khác nhau chi phí của mọi domain
   thêm vào sau. Muốn dữ liệu của module khác thì gọi `Service` của nó: `store` của module nào cũng là
   kiểu **không xuất khẩu**, chạm vào là không compile được.
4. **Mọi mutation nhiều bảng nằm trong một transaction**, và ghi `order_status_history`.
5. **Tổng tiền phiên tính lại từ dòng món**, không cộng dồn tay — một hàm duy nhất (`RecalcSession`, `T-37`).
6. **Lỗi trả cho người dùng bằng tiếng Việt**, kèm mã lỗi ổn định cho FE.
7. **Test đồng thời chạy `-race`** cho mọi thứ hai người có thể bấm cùng lúc: mở phiên bàn,
   xong task ở trạm, bấm đúp đặt đơn, checkout hai lần.
8. Thêm/đổi endpoint ⇒ cập nhật `code/be/api/openapi.yaml` cùng commit (file sinh ở `T-13`) — FE sinh type từ đó.
9. **`code/be/` không import thư viện computer vision nào** ([01-thiet-ke.md §3.9](01-thiet-ke.md)): CV chạy ở
   server Python riêng, monolith chỉ biết một interface. Kiểm: `grep -rn 'gocv\|opencv\|onnxruntime' code/be/` rỗng.

## Bẫy đã trả giá

- `is_active` và blacklist token: Redis chết **không được** thành fail-open.
- Env đã đọc vào config nhưng chưa code nào dùng (`JWT_SECRET`, `QR_SECRET`, `TELEGRAM_*`,
  [F-19](../../finding.md#f-19)) — đừng coi "có trong config" là "đã có tính năng".
