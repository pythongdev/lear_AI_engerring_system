-- Cái đã làm của một hàng ở các đơn đã khoá, lượt gọi sớm hơn trước (ADR-090 điểm 4 Sửa đổi).
-- name: ChonDaLam :many
WITH viec AS (
 -- khoá gom: đầu
 -- Định nghĩa DUY NHẤT của khoá gom (I-019 tầng 3, ADR-090 điểm 8): trạm + thành phần gốc đã chụp (null
 -- với nước chấm) + tập tuỳ chọn nhân đã chụp, sắp tăng, chỉ khi thành phần nhận nhân. Đoạn này nằm ở
 -- gom.sql và chon_da_lam.sql, giống từng byte; TestI019_KhoaGomMotDinhNghia đỏ khi hai bản lệch.
 SELECT j.id, j.sales_order_id, o.dining_table_id, j.station_code, j.status,
        o.status AS order_status, s.status AS session_status,
        c.menu_component_id, coalesce(c.component_name, 'nước chấm') AS component_name,
        CASE WHEN c.takes_filling THEN ARRAY(
          SELECT DISTINCT x.menu_option_id FROM order_line_option x
          WHERE x.order_line_id = j.order_line_id ORDER BY x.menu_option_id
        ) ELSE ARRAY[]::bigint[] END AS filling_option_ids
 FROM station_job j JOIN sales_order o ON o.id = j.sales_order_id
 LEFT JOIN table_session s ON s.id = o.table_session_id
 LEFT JOIN order_line_component c ON c.id = j.order_line_component_id
 -- khoá gom: cuối
 WHERE j.status = 'made' AND o.id = ANY($1::bigint[]))
SELECT id FROM viec WHERE station_code = $2
 -- $3 đúng ⇒ nước chấm (thành phần null); sai ⇒ thành phần $4. Thay IS NOT DISTINCT FROM vì sqlc không sinh
 -- tham số null được.
 AND CASE WHEN $3::boolean THEN menu_component_id IS NULL ELSE menu_component_id = $4::bigint END
 AND filling_option_ids = $5::bigint[] ORDER BY sales_order_id, id LIMIT $6::bigint;
