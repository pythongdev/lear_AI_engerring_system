-- Nhóm phép kiểm quy ước — phần KHÔNG viết được thành một khối sql trong
-- docs/product/2-db/01-quy-uoc-du-lieu.md vì cần một danh sách đọc lúc chạy từ owner (bảng tạm của
-- prelude.sql) hay đọc dữ liệu qua nhiều bảng. Các khối sql dưới tiêu đề `### QD-XX` của file ấy
-- được scripts/reconcile.sh đọc THẲNG từ tài liệu, không chép ở đây. Mỗi khối `-- @@` mang mã quy
-- ước của nó; 0 dòng là đạt. Nhóm này KHÔNG vào phép so mã I-0xx (ADR-053 luật 3).

-- @@ QD-02 — cột mang mã kênh hay mã trạm có tập mã trong ràng buộc kiểm khác tập mã của owner
-- Owner: shop-facts.md §2 (channel_code) · §3 (station_code), nạp vào dc_owner_code lúc chạy. Cột
-- tìm bằng TÊN (QD-02 cách viết). Mọi ràng buộc kiểm trên cột ấy cùng góp chuỗi trong nháy đơn.
WITH cot AS (
  SELECT c.table_name, c.column_name
  FROM information_schema.columns c
  WHERE c.table_schema = :schema
    AND c.column_name IN (SELECT column_name FROM pg_temp.dc_owner_code)),
rb AS (
  SELECT DISTINCT u.table_name, u.column_name, m[1] AS code
  FROM information_schema.constraint_column_usage u
  JOIN information_schema.check_constraints k
    ON k.constraint_schema = u.constraint_schema AND k.constraint_name = u.constraint_name
  CROSS JOIN LATERAL regexp_matches(k.check_clause, '''([^'']*)''', 'g') m
  WHERE u.table_schema = :schema
    AND u.column_name IN (SELECT column_name FROM pg_temp.dc_owner_code)),
ow AS (
  SELECT cot.table_name, o.column_name, o.code
  FROM cot JOIN pg_temp.dc_owner_code o USING (column_name))
SELECT coalesce(ow.table_name, rb.table_name) AS bang, coalesce(ow.column_name, rb.column_name) AS cot,
       coalesce(ow.code, rb.code) AS ma,
       CASE WHEN rb.code IS NULL THEN 'owner có, ràng buộc không' ELSE 'ràng buộc có, owner không' END AS lech
FROM ow FULL JOIN rb
  ON rb.table_name = ow.table_name AND rb.column_name = ow.column_name AND rb.code = ow.code
WHERE ow.code IS NULL OR rb.code IS NULL

-- @@ QD-31/b — dòng có sale_date khác ngày lịch của booked_at quy bằng múi giờ của quán
-- Một câu cho mỗi bảng có cả hai cột, dựng lúc chạy.
SELECT bang, so_dong_lech
FROM (SELECT t.table_name AS bang,
             (xpath('/row/n/text()', query_to_xml(format(
                'SELECT count(*) AS n FROM %I.%I WHERE sale_date <> (booked_at AT TIME ZONE %L)::date',
                :schema, t.table_name, :mui_gio), false, true, '')))[1]::text::bigint AS so_dong_lech
      FROM (SELECT table_name FROM information_schema.columns
            WHERE table_schema = :schema AND column_name IN ('booked_at', 'sale_date')
            GROUP BY table_name HAVING count(*) = 2) t) x
WHERE so_dong_lech > 0

-- @@ QD-32 — kết nối này đọc mốc trong một múi giờ khác múi giờ của quán
SELECT current_setting('TimeZone') AS mui_gio_ket_noi, :mui_gio AS mui_gio_quan
WHERE current_setting('TimeZone') <> :mui_gio

-- @@ QD-33/b — mốc tính tiền bị dời: một lần cập nhật đổi booked_at của một bản ghi đã có
SELECT r.target_table_code AS bang, r.target_row AS dong,
       r.before_image ->> 'booked_at' AS truoc, r.after_image ->> 'booked_at' AS sau
FROM record_revision r
WHERE (r.before_image ->> 'booked_at') IS DISTINCT FROM (r.after_image ->> 'booked_at')

-- @@ QD-40/b — cột status có tập mã trong ràng buộc kiểm khác tập mã của bảng ánh xạ ở file lát
-- Bảng ánh xạ nạp vào dc_status_map lúc chạy (dòng `| `<bảng>.status` | `<mã>` | … |`). Bảng có cột
-- status mà không có dòng ánh xạ nào cũng là lệch.
WITH cot AS (
  SELECT table_name FROM information_schema.columns
  WHERE table_schema = :schema AND column_name = 'status'),
rb AS (
  SELECT DISTINCT u.table_name, m[1] AS code
  FROM information_schema.constraint_column_usage u
  JOIN information_schema.check_constraints k
    ON k.constraint_schema = u.constraint_schema AND k.constraint_name = u.constraint_name
  CROSS JOIN LATERAL regexp_matches(k.check_clause, '''([^'']*)''', 'g') m
  WHERE u.table_schema = :schema AND u.column_name = 'status'),
tl AS (SELECT m.table_name, m.code FROM pg_temp.dc_status_map m JOIN cot USING (table_name))
SELECT coalesce(tl.table_name, rb.table_name) AS bang, coalesce(tl.code, rb.code) AS ma,
       CASE WHEN rb.code IS NULL THEN 'file lát có, ràng buộc không' ELSE 'ràng buộc có, file lát không' END AS lech
FROM tl FULL JOIN rb ON rb.table_name = tl.table_name AND rb.code = tl.code
WHERE tl.code IS NULL OR rb.code IS NULL
UNION ALL
SELECT table_name, NULL, 'có cột status, chưa có bảng ánh xạ'
FROM cot WHERE table_name NOT IN (SELECT table_name FROM pg_temp.dc_status_map)
