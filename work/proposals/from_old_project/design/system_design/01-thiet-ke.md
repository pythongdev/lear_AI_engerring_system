# 01 — Chất lượng Thiết kế hệ thống

> Cập nhật **2026-08-19** · Lane sở hữu: **NON-CODE** · Dời khỏi `quality/` 2026-08-19 về nhà của pha 1 (`git log --follow`).
> Liên quan: [step.md — Bước 0, 2.1](../../step.md), [00-scope.md](../../project_preparation/00-scope.md)

Bốn file kia nói về **chất lượng khi thi công**. File này nói về chất lượng của **quyết định** — thứ mà lint và test không bao giờ bắt được.

Lỗi thiết kế đắt hơn lỗi code khoảng 100 lần: lỗi code sửa bằng một commit, lỗi thiết kế sửa bằng một migration trên dữ liệu thật đang chạy.

---

## 1. Bất biến — thứ phải luôn đúng, không có ngoại lệ

Bất biến (invariant) là mệnh đề đúng ở **mọi thời điểm**, kể cả giữa hai transaction, kể cả khi mất điện. Thiết kế tốt = mỗi bất biến được **một cơ chế cụ thể** bảo vệ, không phải "nhớ code cẩn thận".

| # | Bất biến | Bảo vệ bằng | Trạng thái |
|---|----------|-------------|-----------|
| I1 | Mỗi bàn tối đa **1 phiên chưa thanh toán** | `UNIQUE(open_key)` với `status IN ('open','billing')` | ✅ *(migration 000004, có test — xem 4.1)* |
| I2 | `session.total` = tổng `order_items` của mọi order trong phiên | *(chưa có)* | ⚠️ **xem 4.2** |
| I3 | Giá thu tiền = giá `CalcItemPrice` tính từ DB, không phải giá FE gửi | Kiến trúc: FE không được tin | ✅ |
| I4 | Mọi order đã confirm đều sinh đủ `order_tasks` cho các trạm | Transaction khi confirm | ✅ |
| I5 | Đơn `qr_table` chưa quầy duyệt thì **không** xuống bếp | `status = pending` + bước confirm | ✅ |
| I6 | Mọi khoản tiền thu được gắn với **đúng một** đơn vị tính tiền — phiên bàn *hoặc* order | `CHECK chk_pay_target` trên `payments` | ✅ |
| I7 | Đơn cũ giữ nguyên giá dù menu đổi giá | Snapshot vào `order_items` | ✅ |
| I8 | Bàn `free` ⟺ không có phiên nào chưa đóng trên bàn đó | *(chưa có)* | ⚠️ hai nguồn sự thật |

**Quy tắc:** thêm bất biến mới vào bảng này *trước* khi code. Bất biến không có cột "bảo vệ bằng" thì nó chỉ là lời hứa.

### Query đối chiếu bất biến — chạy hàng ngày sau khi đóng quán

```sql
-- I2: phiên nào có total lệch với tổng item?
SELECT s.id, s.code, s.total AS total_luu,
       COALESCE(SUM(oi.unit_price * oi.quantity), 0) AS total_tinh_lai
FROM table_sessions s
LEFT JOIN orders o       ON o.table_session_id = s.id AND o.status <> 'cancelled'
LEFT JOIN order_items oi ON oi.order_id = o.id
WHERE DATE(s.opened_at) = CURDATE()
GROUP BY s.id
HAVING total_luu <> total_tinh_lai;

-- I8: bàn nào đang 'free' mà vẫn còn phiên chưa đóng?
SELECT t.id, t.name, s.id AS session_id, s.status
FROM tables t JOIN table_sessions s ON s.table_id = t.id
WHERE t.status = 'free' AND s.status IN ('open', 'billing');

-- I6: phiên đã đóng mà số tiền thu được không khớp tổng phiên?
SELECT s.id, s.code, s.total, COALESCE(SUM(p.amount), 0) AS da_thu
FROM table_sessions s
LEFT JOIN payments p ON p.table_session_id = s.id AND p.status = 'paid'
WHERE s.status = 'closed' AND DATE(s.opened_at) = CURDATE()
GROUP BY s.id HAVING da_thu <> s.total;

-- Doanh thu ngày: PHẢI cộng cả hai nguồn, không chỉ phiên bàn
SELECT
  SUM(CASE WHEN p.table_session_id IS NOT NULL THEN p.amount ELSE 0 END) AS tai_ban,
  SUM(CASE WHEN p.order_id         IS NOT NULL THEN p.amount ELSE 0 END) AS ship_pickup,
  SUM(p.amount) AS tong
FROM payments p
WHERE p.status = 'paid' AND DATE(p.paid_at) = CURDATE();
```

Cả ba query này phải trả về **0 dòng**. Gộp vào một script `make invariants` và chạy mỗi tối trong 2 tuần đầu chạy thật.

---

## 2. Ràng buộc kiến trúc — ghi ra để không vô tình phá

Những quyết định này đúng cho quy mô hiện tại (11 bàn, 5 trạm, 1 VPS). Vấn đề là **chúng ẩn**, và ai đó sẽ vô tình phá bằng một thay đổi tưởng vô hại.

| Ràng buộc | Vì sao chấp nhận được | Phá khi nào | Dấu hiệu phải xem lại |
|-----------|----------------------|-------------|----------------------|
| **BE chỉ chạy đúng 1 instance** | SSE giữ kết nối trong bộ nhớ process. 2 replica → trạm nối vào replica A không nhận được event sinh ở replica B | Thêm replica, hoặc dùng load balancer | Muốn scale ngang → cần Redis pub/sub |
| **Không có hàng đợi** | Confirm đơn → sinh task đồng bộ trong 1 transaction. Đơn giản và đúng | Thêm bước chậm (in bếp, gọi API ngoài) vào luồng confirm | Confirm đơn > 500ms |
| **Polling 20s làm dự phòng cho SSE** | 5 tablet × 3 req/phút = không đáng kể | Thêm nhiều màn hình, hoặc giảm chu kỳ xuống 2s | CPU VPS > 50% giờ cao điểm |
| **Không có cache** | 8 món, 11 bàn. MySQL thừa sức | — | Menu > 200 món |
| **Một DB, không read replica** | Ghi và đọc đều nhỏ | — | — |
| **Tất cả trên 1 VPS** | VPS chết = mất tất cả, nhưng có sổ giấy dự phòng | — | Doanh thu đủ lớn để 30 phút downtime là đau |

> **Ràng buộc số 1 là nghiêm trọng nhất.** Nếu sau này bạn thêm `deploy: replicas: 2` vào compose để "chạy nhanh hơn", màn hình trạm sẽ mất việc một cách ngẫu nhiên và cực khó debug. Ghi comment cảnh báo ngay trong `docker-compose.prod.yml`.

---

## 3. Múi giờ — thiết kế phải chọn một nguồn thời gian

Quán mở **06:00–11:00 giờ Việt Nam**. Container Docker mặc định chạy **UTC**. 6h sáng VN = 23h UTC hôm trước.

Nếu không xử lý: logic "ngoài giờ mở cửa" sai 7 tiếng, báo cáo doanh thu ngày cắt sai mốc, `pickup` cho chọn giờ hẹn sai.

**Quy tắc chốt:**

1. Lưu mọi mốc thời gian ở **UTC** trong DB (`TIMESTAMP` của MySQL đã làm vậy).
2. Mọi so sánh nghiệp vụ (giờ mở cửa, giờ hẹn pickup, cắt ngày báo cáo) đổi sang `Asia/Ho_Chi_Minh` **ở tầng service**, không ở FE.
3. Set rõ trong compose cho cả 3 container:
   ```yaml
   environment:
     TZ: Asia/Ho_Chi_Minh
   ```
4. "Ngày bán" là **06:00–11:00 giờ VN**, không phải 00:00–23:59. Báo cáo ngày phải cắt theo ngày VN.

**Test bắt buộc:**

```go
func TestIsOpen(t *testing.T) {
	// 05:59 VN → đóng | 06:00 VN → mở | 10:59 VN → mở | 11:00 VN → đóng
	// và: 23:30 UTC (= 06:30 VN hôm sau) → MỞ   ← case bắt lỗi múi giờ
}
```

Case cuối là case duy nhất quan trọng — nó đỏ nếu ai đó dùng `time.Now()` thay vì giờ VN.

---

## 4. Rà soát thiết kế hiện tại — 4 lỗ hổng tìm được

### 4.1 `open_key` không chặn được phiên trùng khi bàn đang thanh toán 🔴 — ĐÃ SỬA

`table_sessions.status` có 4 giá trị: `open`, `billing`, `closed`, `cancelled`. Nhưng cột sinh chỉ nhìn `open`:

```sql
GENERATED ALWAYS AS (IF(status = 'open', table_id, NULL)) STORED
```

Khi quầy bấm thu tiền, phiên chuyển `open → billing` → `open_key` thành `NULL` → **ràng buộc UNIQUE nhả ra** → một nhân viên khác mở được phiên thứ hai trên đúng bàn đó.

Kịch bản thật: 7h30, quầy đang tính tiền bàn 5. Khách bàn 5 quét QR gọi thêm một suất. Hệ thống mở phiên mới. Suất đó rơi vào hoá đơn thứ hai mà không ai để ý → **thu thiếu tiền**, đúng lỗi mà `open_key` sinh ra để chống.

**Đã vá trong code (2026-08-10)** — [000004_fix_open_key.up.sql](../../code/be/migrations/000004_fix_open_key.up.sql)
bỏ index + cột sinh cũ và tạo lại:

```sql
GENERATED ALWAYS AS (IF(status IN ('open','billing'), table_id, NULL)) STORED
```

Trước đó bản vá này mới chỉ nằm ở [step.md](../../step.md) mục 2.3 — tài liệu ghi đã sửa
trong khi migration thật vẫn là bản cũ, nên finding bị mở lại. Nghiệm thu bằng test
`TestOpenKeyChanPhienThuHaiKhiBanDangBilling` ([code/be/internal/store](../../code/be/internal/store/session_openkey_integration_test.go)),
không phải bằng dòng chữ này.

Kèm quyết định nghiệp vụ đã ghi vào `step.md`: **bàn đang `billing` thì khoá gọi thêm món.** FE bàn hiện *"Quầy đang tính tiền — muốn gọi thêm xin báo nhân viên"*. Muốn gọi tiếp thì quầy đưa phiên `billing → open` trở lại.

Test bắt buộc: mở phiên → chuyển `billing` → thử mở phiên thứ hai trên cùng bàn → phải lỗi duplicate key.

> Nếu sau này thêm giá trị mới vào `ENUM status` (ví dụ `on_hold`), phải hỏi lại: giá trị đó có nghĩa là "bàn còn nợ tiền" không? Nếu có, thêm vào danh sách `IN (...)`. Đây là chỗ dễ tái phát lỗi nhất.

### 4.2 `session.total` là cache, chưa có gì đảm bảo nó đúng 🟠

Schema ghi rõ `subtotal INT UNSIGNED ... -- cache, tính lại mỗi lần thêm đơn`. Đây là hai nguồn sự thật cho cùng một con số tiền.

Cache lệch khi: huỷ món sau khi đã cộng, sửa số lượng, transaction lỗi giữa chừng, hoặc đơn giản là quên gọi hàm tính lại ở một nhánh code mới.

**Ba lớp bảo vệ, làm cả ba:**

1. Chỉ **một hàm duy nhất** được ghi vào `subtotal/discount/total` — `RecalcSession(ctx, tx, sessionID)`. Mọi thao tác thêm/sửa/huỷ món đều gọi nó ở cuối transaction. Giống nguyên tắc "một `CalcItemPrice` duy nhất" của `step.md`.
2. **Lúc checkout, tính lại từ đầu**, không tin cache. Cache chỉ để hiển thị nhanh trên POS.
3. Query đối chiếu I2 ở mục 1, chạy mỗi tối.

### 4.3 Sơ đồ ER vẽ thiếu đường `payments → orders` 🟡 — ĐÃ SỬA

*(Ban đầu ghi nhận nhầm thành lỗi schema. Schema vốn đã đúng — chỉ có sơ đồ vẽ thiếu.)*

Bảng `payments` ở `step.md` mục 2.4 đã có sẵn **cả hai** khoá, đều `NULL` được, kèm ràng buộc bắt buộc đúng một cột khác `NULL`:

```sql
order_id          BIGINT UNSIGNED NULL,   -- thanh toán cho đơn ship/pickup
table_session_id  BIGINT UNSIGNED NULL,   -- thanh toán cho phiên bàn
CONSTRAINT chk_pay_target CHECK (
  (order_id IS NOT NULL) + (table_session_id IS NOT NULL) = 1
),
```

Đây đúng là phương án tốt cho bài toán này: đơn `delivery`/`pickup` không có `table_session`, nên `payments` phải gắn thẳng vào `orders`. Phương án thay thế — tạo `table_session` giả với `table_id = NULL` cho đơn ship — sẽ phá được ràng buộc `open_key` và phức tạp hơn hẳn.

Vấn đề chỉ là **sơ đồ ER mục 2.1 vẽ `payments` treo dưới mỗi `table_sessions`**, khiến người đọc (kể cả người rà soát thiết kế) tưởng đơn ship không có chỗ ghi tiền. Đã sửa sơ đồ + thêm ghi chú trong `step.md`.

**Bài học giữ lại:** sơ đồ và schema lệch nhau thì sơ đồ là thứ người ta đọc và tin. Khi sửa schema, sửa cả sơ đồ trong cùng một commit.

**Hệ quả còn phải nhớ:** báo cáo doanh thu ngày phải cộng **cả hai nguồn** — `payments` theo `table_session_id` và `payments` theo `order_id`. Query chỉ `JOIN table_sessions` sẽ báo thiếu toàn bộ doanh thu ship/pickup.

### 4.4 Ba việc trong scope chưa có thiết kế 🟡

[00-scope.md](../../project_preparation/00-scope.md) hứa nhưng `step.md` chưa thiết kế:

| Việc trong scope | Thiếu gì | Đề xuất |
|------------------|----------|---------|
| Luồng ship có bước **"đóng gói"** (0.2) | Danh sách trạm chỉ có `quay`, `trang_banh`, `gap_banh`, `canh`, `don_ban` — không có trạm đóng gói | Không thêm trạm mới. Cho `gap_banh` nhận task đóng gói, phân biệt bằng `order.channel` hiển thị nhãn "MANG ĐI" nền khác màu |
| Quầy được **"sửa / huỷ món"** | Task đã sinh, thậm chí trạm đã làm xong. Huỷ món thì task xử lý sao? | Task đã `done` → **không cho huỷ món**, chỉ cho giảm giá trên phiên. Task `todo`/`doing` → huỷ task + ghi `order_status_history` |
| Quầy được **"gộp & tách phiếu bàn"** | `orders.session_id` là khoá cứng, không có đường chuyển order sang phiên khác | Thiết kế thành thao tác đổi `session_id` trong transaction + `RecalcSession` cả hai phiên + ghi log. **Việc này nên đẩy sang v2** — MVP chưa cần |

Khuyến nghị: chốt hai dòng đầu ngay (rẻ), đẩy "gộp/tách phiếu" sang roadmap v2.

---

## 5. Ghi lại quyết định thiết kế (ADR)

Sáu tháng sau bạn sẽ không nhớ vì sao chọn SSE thay vì WebSocket, hay vì sao tính tiền theo phiên chứ không theo đơn. Ghi lại — mỗi quyết định **10 dòng**, thêm vào cuối file này:

```
### QĐ-005 — Bàn đang `billing` thì khoá gọi thêm món (2026-08-10)
Bối cảnh: open_key chỉ tính status='open' nên bàn đang thu tiền mở được phiên 2 → thu thiếu.
Chọn:     open_key tính IN ('open','billing'); FE bàn khoá nút gọi món khi phiên billing.
Loại bỏ:  cho gọi thêm vào phiên đang billing — quầy đã chốt số tiền, thêm món là sai hoá đơn.
Đánh đổi: khách muốn gọi tiếp phải nhờ quầy đưa phiên về 'open'. Chấp nhận được: quán 11 bàn,
          quầy luôn đứng cạnh.
Xem lại khi: thêm giá trị mới vào ENUM status — hỏi "giá trị này có nghĩa bàn còn nợ tiền?"
```

Các quyết định đã có, chép về đây cho đủ bộ:

- **QĐ-001** — Phiên bàn là đơn vị tính tiền, không phải đơn hàng *(step.md 0.1)*
- **QĐ-002** — Đơn QR phải qua quầy duyệt mới xuống bếp *(step.md 0.1)*
- **QĐ-003** — SSE một chiều thay vì WebSocket, kèm polling 20s dự phòng *(step.md 3.7)*
- **QĐ-004** — `payments` gắn vào **một trong hai**: `table_session_id` (ăn tại bàn) hoặc `order_id` (ship/pickup), ràng buộc bằng `CHECK`. Loại bỏ phương án tạo session giả cho đơn ship vì nó phá `open_key`. Đánh đổi: báo cáo doanh thu phải cộng cả hai nguồn *(step.md 2.4)*
- **QĐ-005** — *(ở trên)*

---

## 6. Checklist review thiết kế — trước khi viết migration

Chạy checklist này **mỗi khi thêm bảng mới hoặc thêm luồng nghiệp vụ mới**:

- [ ] Tính năng này đụng vào bất biến nào ở mục 1? Bất biến đó còn được bảo vệ không?
- [ ] Có sinh ra **nguồn sự thật thứ hai** cho một con số tiền không? Nếu có: ai là nguồn chính, đối chiếu thế nào?
- [ ] Hai người bấm cùng lúc thì sao? (xem [design/backend/02-luat.md](../../design/backend/02-luat.md) mục 3)
- [ ] Mất mạng giữa chừng thì dữ liệu ở trạng thái nào? Có transaction chưa?
- [ ] Có phá ràng buộc kiến trúc nào ở mục 2 không? (nhất là "BE 1 instance")
- [ ] Có so sánh thời gian không? Đã dùng giờ VN chưa? (mục 3)
- [ ] Áp dụng được cho **cả 4 kênh** `delivery` / `pickup` / `qr_table` / `staff_pos` chưa, hay chỉ nghĩ cho luồng tại bàn?
- [ ] Nhân viên làm sai thao tác thì sửa được không, hay phải vào DB sửa tay?
- [ ] Nếu hệ thống sập giữa chừng, quán chuyển sổ giấy rồi nhập bù được không?

Câu hỏi thứ 7 là câu hay bắt lỗi nhất — phần lớn thiết kế ở đây được nghĩ cho luồng tại bàn, rồi mới nhớ ra đơn ship (đúng như lỗ hổng 4.3).
