-- I-008 — docs/product/1-system-design/03-bao-ve-invariant.md §3, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Tập 2 · 3 đọc hai khoảng ngừng nhận đơn (T-132, ADR-078). Hai tập còn lại KHÔNG có câu — file 09 §2:
-- tập 4 (lần chặn nhầm) cần lần từ chối để lại bản ghi; tập 5 (đơn cũ bị chạm vì điều kiện vừa đóng)
-- cần lý do huỷ đọc được bằng máy.

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

-- @@ I-008/2 — đơn có thời điểm tạo rơi vào một khoảng tạm dừng nhận đơn
-- Khoảng [bật, tắt): đúng lúc tắt thì nhận đơn lại được. Cả năm kênh (shop-facts.md §6.8). Đơn nhập
-- bù từ sổ giấy mang lúc GÕ (ADR-037) — đứng ngoài tập, như I-008/1.
SELECT o.id AS don, o.channel_code AS kenh, o.created_at AS luc_tao, p.id AS tam_dung
FROM sales_order o
JOIN order_intake_pause p ON tstzrange(p.started_at, p.ended_at, '[)') @> o.created_at
WHERE NOT EXISTS (SELECT 1 FROM bill b
                  WHERE b.paper_ledger_id IS NOT NULL
                    AND (b.sales_order_id = o.id OR b.table_session_id = o.table_session_id));

-- @@ I-008/3 — đơn ba kênh khách tự bấm có thời điểm tạo rơi vào một khoảng quán không nhìn thấy đơn mới
-- Khoảng tính từ lúc quán hết nhìn thấy, không từ lúc có người bấm tắt (U-061), tới lúc bấm mở lại.
-- Hai kênh người của quán nhập không dừng (shop-facts.md §6.11) — đứng ngoài tập.
SELECT o.id AS don, o.channel_code AS kenh, o.created_at AS luc_tao, s.id AS khoang_mu
FROM sales_order o
JOIN shop_blind_spell s ON tstzrange(s.started_at, s.ended_at, '[)') @> o.created_at
WHERE o.channel_code IN ('delivery', 'pickup', 'qr_table');
