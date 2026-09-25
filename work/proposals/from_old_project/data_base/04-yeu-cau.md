# 04 — Yêu cầu khi làm việc với Database (AGENTS.md của lane DB)

> Cập nhật **2026-08-19** · Lane sở hữu: **DB** · Dời từ `code/be/migrations/AGENTS.md` (`git log --follow`).
> Luật chung ở [/CLAUDE.md](../../CLAUDE.md) — không chép về đây.
> Sự thật DB khác: [thiết kế](01-thiet-ke.md) · [luật](02-luat.md) · [hiện trạng](03-hien-trang.md).

**Chạm bất kỳ file nào trong `code/be/migrations/` thì nạp file này trước.** Nó là gói bắt buộc của
lane DB ở [CLAUDE.md §1](../../CLAUDE.md).

## Biên nhận của lane này

```bash
make up                     # MySQL + migrate
make test-int TEST_DB_DSN='banhcuon:changeme_app@tcp(127.0.0.1:3306)/banhcuon?parseTime=true&charset=utf8mb4'
```

`make db-test` (vòng up → down -all → up → seed → assert) **chưa có** — nó là `T-05`, đóng `F-26`.
Tới lúc đó, vòng down/up phải chạy tay và **dán output** vào biên nhận.

## Luật riêng lane DB

1. **Migration chỉ thêm mới.** Đổi cột ⇒ tạo `0000NN_*.up.sql` mới. Tuyệt đối không sửa file
   đã chạy — kể cả khi nó sai (mẫu: `open_key` sai ở `000002`, vá bằng `000004`, để nguyên `000002`).
2. **Mỗi `.up.sql` phải có `.down.sql`**, và `.down` phải từng được chạy thử ít nhất một lần.
3. **Tiền là `INT`, đơn vị VND.** Không `FLOAT`, không `DECIMAL` cho tiền.
4. **Ràng buộc đặt ở DB trước**, không chỉ ở Go: `UNIQUE`, `FK`, `CHECK`, `NOT NULL`.
   Ràng buộc chỉ có trong code là ràng buộc sẽ bị lách bởi lệnh `UPDATE` tay.
5. **`utf8mb4_unicode_ci` + `InnoDB`** cho mọi bảng.
6. **Múi giờ `Asia/Ho_Chi_Minh`** ở cả MySQL và Go — quán bán 06:00–11:00, lệch múi giờ là hỏng
   toàn bộ logic mở/đóng cửa. Test biên `23:30 UTC` (`F-09`) phải giữ.
7. **Sửa `seed.sql` là sửa giá thật.** Đổi `base_price`/`price_delta` ⇒ cập nhật bảng test ở
   [code/be/internal/menu/pricing_test.go](../../code/be/internal/menu/pricing_test.go) trong cùng commit.
8. Migration trên DB thật: backup trước · chạy sau 11h · bảng lớn dùng `ALGORITHM=INPLACE`.

## Bẫy đã trả giá

- `open_key` phải là `IF(status IN ('open','billing'), table_id, NULL)`. Comment "ĐỪNG COPY" ở
  `000002` là cố ý, đừng dọn. Chi tiết: [F-01](../../finding.md#f-01), [F-10](../../finding.md#f-10).
- Soft delete làm `UNIQUE` và `RESTRICT` im lặng mất tác dụng — kiểm lại mỗi khi thêm cột `deleted_at`.
