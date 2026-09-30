-- I-019 — docs/product/1-system-design/03-bao-ve-invariant.md §4, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Lát sản xuất KHÔNG cất ô tổng nào (05-luoc-do-san-xuat.md §1): tổng của một dòng nhu cầu và
-- phần của từng bàn cùng cộng lại từ station_job, nên chiều xuôi (các phần → tổng) là một phép cộng
-- không có ô thứ hai để lệch. Chiều ngược — tổng tách về ĐÚNG các phần đã gọi — lệch được khi một
-- đơn vị đứng tên một đơn khác đơn của dòng nó làm cho. Tập thứ hai của pha 1 (hai dòng chung một
-- khoá gom · một khoá tách hai dòng) không có phần tử nào tồn tại được khi không có dòng nhu cầu
-- nào được cất — file 09 §2.

-- @@ I-019/1 — dòng nhu cầu mà phần chia về một bàn khác phần bàn ấy đã gọi
-- Bên chia: đơn vị đếm về bàn theo đơn nó đứng tên. Bên gọi: cùng đơn vị ấy đếm về bàn theo đơn của
-- DÒNG nó làm cho. Hai cách đếm của cùng một khoá gom phải cho cùng con số ở mỗi bàn.
WITH chia AS (
  SELECT pg_temp.khoa_gom(j.id) AS khoa, o.dining_table_id AS ban, count(*) AS n
  FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
  WHERE j.order_line_id IS NOT NULL AND o.status <> 'cancelled' AND o.dining_table_id IS NOT NULL
  GROUP BY 1, 2),
goi AS (
  SELECT pg_temp.khoa_gom(j.id) AS khoa, o.dining_table_id AS ban, count(*) AS n
  FROM station_job j
  JOIN order_line l  ON l.id = j.order_line_id
  JOIN sales_order o ON o.id = l.sales_order_id
  WHERE o.status <> 'cancelled' AND o.dining_table_id IS NOT NULL
  GROUP BY 1, 2)
SELECT coalesce(chia.khoa, goi.khoa) AS khoa, coalesce(chia.ban, goi.ban) AS ban,
       coalesce(chia.n, 0) AS phan_chia, coalesce(goi.n, 0) AS phan_da_goi
FROM chia FULL JOIN goi ON goi.khoa = chia.khoa AND goi.ban = chia.ban
WHERE coalesce(chia.n, 0) <> coalesce(goi.n, 0)
