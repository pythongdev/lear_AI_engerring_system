-- I-004 — docs/product/1-system-design/03-bao-ve-invariant.md §2, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Đơn "đã nổ" = Đang thực hiện · Đang giao · Hoàn thành. Việc trạm là MỘT DÒNG MỘT ĐƠN VỊ
-- (05-luoc-do-san-xuat.md §1), nên "số lượng việc" là số dòng. Tập thứ năm của pha 1 (việc Chưa
-- làm của đơn đã Huỷ) KHÔNG có câu: work/findings.md F-044.

-- @@ I-004/1 — việc trạm của một đơn còn Mới hoặc Chờ xác nhận
SELECT j.id AS viec, o.id AS don, o.status
FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
WHERE o.status IN ('new', 'pending_confirmation')

-- @@ I-004/2 — đơn đã nổ mà một (thành phần, trạm) — trừ trạm canh — có số việc khác số suất × số thành phần
WITH can AS (
  SELECT o.id AS don, c.id AS tp, c.component_name AS ten, s.station_code AS tram,
         l.quantity * c.quantity AS can
  FROM sales_order o
  JOIN order_line l           ON l.sales_order_id = o.id
  JOIN order_line_component c ON c.order_line_id = l.id
  JOIN menu_component_station s
    ON s.menu_component_id = c.menu_component_id AND s.created_at <= pg_temp.luc_no(o.id)
  WHERE o.status IN ('in_progress', 'delivering', 'completed') AND s.station_code <> 'canh'),
co AS (
  SELECT j.sales_order_id AS don, j.order_line_component_id AS tp, j.station_code AS tram,
         count(*) AS co
  FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
  WHERE o.status IN ('in_progress', 'delivering', 'completed')
    AND j.order_line_component_id IS NOT NULL AND j.station_code <> 'canh'
  GROUP BY 1, 2, 3)
SELECT coalesce(can.don, co.don) AS don, coalesce(can.tram, co.tram) AS tram, can.ten,
       coalesce(can.can, 0) AS can, coalesce(co.co, 0) AS co
FROM can FULL JOIN co ON co.don = can.don AND co.tp = can.tp AND co.tram = can.tram
WHERE coalesce(can.can, 0) <> coalesce(co.co, 0)

-- @@ I-004/3 — đơn đã nổ mà số việc nước chấm khác một
SELECT o.id AS don, count(j.id) AS so_nuoc_cham
FROM sales_order o
LEFT JOIN station_job j ON j.sales_order_id = o.id AND j.order_line_component_id IS NULL
WHERE o.status IN ('in_progress', 'delivering', 'completed')
GROUP BY o.id
HAVING count(j.id) <> 1

-- @@ I-004/4 — đơn đã nổ mà số bát trên các việc canh khác con số trên dòng canh của đơn
-- Bát canh là thành phần của dòng "canh bánh cuốn" xuống trạm canh; đơn không có dòng ấy ⇒ 0.
WITH can AS (
  SELECT o.id AS don, sum(l.quantity * c.quantity) AS can
  FROM sales_order o
  JOIN order_line l           ON l.sales_order_id = o.id
  JOIN order_line_component c ON c.order_line_id = l.id
  JOIN menu_component_station s
    ON s.menu_component_id = c.menu_component_id AND s.station_code = 'canh'
   AND s.created_at <= pg_temp.luc_no(o.id)
  GROUP BY 1),
co AS (
  SELECT sales_order_id AS don, count(*) AS co FROM station_job
  WHERE station_code = 'canh' AND order_line_component_id IS NOT NULL
  GROUP BY 1)
SELECT o.id AS don, coalesce(can.can, 0) AS bat_da_goi, coalesce(co.co, 0) AS bat_trong_viec
FROM sales_order o LEFT JOIN can ON can.don = o.id LEFT JOIN co ON co.don = o.id
WHERE o.status IN ('in_progress', 'delivering', 'completed')
  AND coalesce(can.can, 0) <> coalesce(co.co, 0)

-- @@ I-004/6 — thứ đã làm xong / đã ra bàn của một đơn đã Huỷ mà chưa chuyển sang bàn khác
-- Thứ đã chuyển thì đơn vị cũ nhả nó và về Chưa làm (05-luoc-do-san-xuat.md §2), nên đơn vị còn
-- ở made/served của đơn huỷ là thứ chưa ai chuyển. Ca không bàn nào chờ đúng thứ ấy chưa có luật
-- (U-064) — câu vẫn in nó: chưa có luật là chưa đối soát xong, không phải xanh.
SELECT j.id AS viec, o.id AS don, j.station_code AS tram, j.status
FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
WHERE o.status = 'cancelled' AND j.status IN ('made', 'served')

-- @@ I-004/7 — lần chuyển mà phần bàn nhận nhận được không phải đúng phần bàn cũ chuyển đi
-- Một lần chuyển là một đơn vị; hai bên khớp khi và chỉ khi cùng khoá gom.
SELECT t.id AS lan_chuyen, pg_temp.khoa_gom(t.from_station_job_id) AS khoa_chuyen_di,
       pg_temp.khoa_gom(t.to_station_job_id) AS khoa_nhan
FROM station_job_transfer t
WHERE pg_temp.khoa_gom(t.from_station_job_id) IS DISTINCT FROM pg_temp.khoa_gom(t.to_station_job_id)
