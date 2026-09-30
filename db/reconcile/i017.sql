-- I-017 — docs/product/1-system-design/03-bao-ve-invariant.md §2, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Tập thứ ba của pha 1 (lần đóng phiên bị TỪ CHỐI vì tiền) KHÔNG có câu: lần từ chối không để lại
-- bản ghi — file 09 §2.

-- @@ I-017/1 — phiên đã đóng mà có một đơn thuộc phiên không ở Hoàn thành hay Huỷ
-- Sau lúc đóng, đơn chỉ còn đi được Hoàn thành → Huỷ (shop-facts §6.19), nên trạng thái hôm nay
-- ngoài hai trạng thái ấy là trạng thái đã sai từ lúc đóng. Đơn của mọi bàn trong nhóm ghép cùng
-- mang phiên ấy.
SELECT s.id AS phien, o.id AS don, o.dining_table_id AS ban, o.status
FROM table_session s JOIN sales_order o ON o.table_session_id = s.id
WHERE s.status = 'closed' AND o.status NOT IN ('completed', 'cancelled')

-- @@ I-017/2 — phiên đã đóng trước khi lượt gọi thêm lúc Chờ thanh toán tới Hoàn thành hay Huỷ
-- Lúc phiên sang Chờ thanh toán đọc từ vết cập nhật (I-018); lượt gọi tạo sau lúc ấy.
SELECT s.id AS phien, o.id AS don, o.status, r.revised_at AS luc_tinh_tien, o.created_at AS luc_goi
FROM table_session s
JOIN record_revision r
  ON r.target_table_code = 'table_session' AND r.target_row = s.id
 AND r.after_image ->> 'status' = 'awaiting_payment'
JOIN sales_order o ON o.table_session_id = s.id AND o.created_at > r.revised_at
WHERE s.status = 'closed' AND o.status NOT IN ('completed', 'cancelled')
