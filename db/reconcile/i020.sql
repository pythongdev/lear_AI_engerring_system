-- I-020 — docs/product/1-system-design/03-bao-ve-invariant.md §4, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Mỗi (bàn, thành phần, trạm): đã gọi = số suất × số thành phần của các dòng bàn ấy gọi; đã bưng ra
-- bàn và đã làm xong đếm trên các đơn vị của bàn ấy ở trạm ấy. Đơn đã huỷ đứng ngoài cả hai bên.

-- @@ I-020/1 — bàn và thành phần mà số đã bưng ra bàn vượt số đã gọi
WITH goi AS (
  SELECT o.dining_table_id AS ban, c.menu_component_id AS tp, sum(l.quantity * c.quantity) AS n
  FROM sales_order o JOIN order_line l ON l.sales_order_id = o.id
  JOIN order_line_component c ON c.order_line_id = l.id
  WHERE o.status <> 'cancelled' AND o.dining_table_id IS NOT NULL
  GROUP BY 1, 2),
ra AS (
  SELECT o.dining_table_id AS ban, c.menu_component_id AS tp, j.station_code AS tram, count(*) AS n
  FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
  JOIN order_line_component c ON c.id = j.order_line_component_id
  WHERE j.status = 'served' AND o.status <> 'cancelled' AND o.dining_table_id IS NOT NULL
  GROUP BY 1, 2, 3)
SELECT ra.ban, ra.tp AS thanh_phan, ra.tram, coalesce(goi.n, 0) AS da_goi, ra.n AS da_bung_ra
FROM ra LEFT JOIN goi USING (ban, tp)
WHERE ra.n > coalesce(goi.n, 0)

-- @@ I-020/2 — bàn và thành phần mà đã làm xong còn ở bếp cộng đã bưng ra bàn vượt số đã gọi
WITH goi AS (
  SELECT o.dining_table_id AS ban, c.menu_component_id AS tp, sum(l.quantity * c.quantity) AS n
  FROM sales_order o JOIN order_line l ON l.sales_order_id = o.id
  JOIN order_line_component c ON c.order_line_id = l.id
  WHERE o.status <> 'cancelled' AND o.dining_table_id IS NOT NULL
  GROUP BY 1, 2),
lam AS (
  SELECT o.dining_table_id AS ban, c.menu_component_id AS tp, j.station_code AS tram, count(*) AS n
  FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
  JOIN order_line_component c ON c.id = j.order_line_component_id
  WHERE j.status IN ('made', 'served') AND o.status <> 'cancelled' AND o.dining_table_id IS NOT NULL
  GROUP BY 1, 2, 3)
SELECT lam.ban, lam.tp AS thanh_phan, lam.tram, coalesce(goi.n, 0) AS da_goi, lam.n AS da_lam_hoac_ra
FROM lam LEFT JOIN goi USING (ban, tp)
WHERE lam.n > coalesce(goi.n, 0)
