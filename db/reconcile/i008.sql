-- I-008 — docs/product/1-system-design/03-bao-ve-invariant.md §3, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Bốn tập còn lại của pha 1 (khoảng tạm dừng · khoảng quán không nhìn thấy đơn · lần chặn nhầm ·
-- đơn cũ bị chạm vì điều kiện vừa đóng) KHÔNG có câu: lược đồ chưa cất khoảng tạm dừng, khoảng mất
-- kết nối hay lần từ chối nào — file 09 §2.

-- @@ I-008/1 — đơn có thời điểm tạo nằm ngoài giờ bán
-- Giờ bán :gio_mo – :gio_dong đọc lúc chạy từ shop-facts.md §1, hai đầu tính là trong giờ; múi giờ
-- :mui_gio cùng chỗ ấy. Đơn của một phiên hay đơn lẻ nhập bù từ sổ giấy mang lúc GÕ (ADR-037) —
-- đứng ngoài tập.
SELECT o.id AS don, o.channel_code AS kenh, (o.created_at AT TIME ZONE :mui_gio) AS luc_tao
FROM sales_order o
WHERE ((o.created_at AT TIME ZONE :mui_gio)::time < :gio_mo
       OR (o.created_at AT TIME ZONE :mui_gio)::time > :gio_dong)
  AND NOT EXISTS (SELECT 1 FROM bill b
                  WHERE b.paper_ledger_id IS NOT NULL
                    AND (b.sales_order_id = o.id OR b.table_session_id = o.table_session_id))
