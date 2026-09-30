-- I-022 — docs/product/1-system-design/03-bao-ve-invariant.md §2, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- "Thiếu" là không có HOẶC chỉ có khoảng trắng (02-luoc-do-ban-hang.md §2 hàng I-022). Vế ngược
-- (trường nên có không chặn tạo đơn) không có tập — pha 1 nói thẳng.

-- @@ I-022/1 — đơn của ba kênh không gắn bàn không có số điện thoại
SELECT o.id AS don, o.channel_code AS kenh
FROM sales_order o
WHERE o.channel_code IN ('delivery', 'pickup', 'phone_preorder')
  AND btrim(coalesce(o.customer_phone, '')) = ''

-- @@ I-022/2 — đơn giao tận nơi không có địa chỉ giao
SELECT o.id AS don, o.channel_code AS kenh
FROM sales_order o
WHERE o.handover_code = 'door_delivery' AND btrim(coalesce(o.delivery_address, '')) = ''

-- @@ I-022/3 — đơn Pickup hoặc hotline không có giờ khách cần hàng
SELECT o.id AS don, o.channel_code AS kenh
FROM sales_order o
WHERE o.channel_code IN ('pickup', 'phone_preorder') AND o.customer_needed_at IS NULL

-- @@ I-022/4 — đơn hotline không mang đúng một cách trao hàng
SELECT o.id AS don, o.handover_code AS cach_trao
FROM sales_order o
WHERE o.channel_code = 'phone_preorder'
  AND o.handover_code IS DISTINCT FROM 'door_delivery'
  AND o.handover_code IS DISTINCT FROM 'shop_pickup'

-- @@ I-022/5 — đơn Delivery mà cách trao hàng khác giao tận nơi, đơn Pickup mà khác tới lấy
SELECT o.id AS don, o.channel_code AS kenh, o.handover_code AS cach_trao
FROM sales_order o
WHERE (o.channel_code = 'delivery' AND o.handover_code IS DISTINCT FROM 'door_delivery')
   OR (o.channel_code = 'pickup'   AND o.handover_code IS DISTINCT FROM 'shop_pickup')
