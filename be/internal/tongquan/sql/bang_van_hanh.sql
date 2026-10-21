-- ADR-124: ảnh phiên hiện tại và lịch sử đem ra trong ngày bán.
-- name: BangVanHanh :one
WITH viec AS MATERIALIZED (
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
), phien_mo AS (
 SELECT id, status FROM table_session WHERE status <> 'closed'
), don_nguon AS (
 SELECT o.id FROM sales_order o JOIN phien_mo s ON s.id = o.table_session_id
 WHERE o.status <> 'cancelled'
),
 -- tạm tính: đầu
don_vi AS (
 SELECT g.id, g.sales_order_id, sum(l.line_total_vnd) AS amount_vnd
 FROM order_line g JOIN don_nguon o ON o.id = g.sales_order_id
 JOIN order_line l ON l.id = g.id OR l.parent_order_line_id = g.id
 WHERE g.parent_order_line_id IS NULL
 GROUP BY g.id, g.sales_order_id
), da_ra AS (
 SELECT d.id, d.sales_order_id, d.amount_vnd FROM don_vi d
 WHERE EXISTS (SELECT 1 FROM station_job j JOIN order_line l ON l.id = j.order_line_id
               WHERE l.id = d.id OR l.parent_order_line_id = d.id)
 AND NOT EXISTS (SELECT 1 FROM station_job j JOIN order_line l ON l.id = j.order_line_id
                 WHERE (l.id = d.id OR l.parent_order_line_id = d.id) AND j.status <> 'served')
)
 -- tạm tính: cuối
, don_vi_ban AS (
 SELECT o.table_session_id, v.menu_component_id, v.filling_option_ids,
        min(v.component_name) AS component_name, min(j.order_line_id) AS order_line_id,
        bool_and(v.status = 'served') AS da_ra_het
 FROM viec v JOIN station_job j ON j.id = v.id
 JOIN sales_order o ON o.id = v.sales_order_id JOIN don_nguon n ON n.id = o.id
 GROUP BY o.table_session_id, v.menu_component_id, v.filling_option_ids,
          j.order_line_component_id, j.position,
          CASE WHEN j.order_line_component_id IS NULL THEN j.id END
), thu AS (
 SELECT table_session_id, menu_component_id, filling_option_ids,
        min(component_name) AS component_name,
        count(*) AS ordered, count(*) FILTER (WHERE da_ra_het) AS served,
        count(*) FILTER (WHERE NOT da_ra_het) AS missing,
        EXISTS (SELECT 1 FROM order_line_option x JOIN menu_option m ON m.id = x.menu_option_id
          WHERE x.order_line_id IN (SELECT u.order_line_id FROM don_vi_ban u
              WHERE u.table_session_id = d.table_session_id
                AND u.menu_component_id IS NOT DISTINCT FROM d.menu_component_id
                AND u.filling_option_ids = d.filling_option_ids)
            AND x.option_group_name = 'Lượng nhân' AND NOT m.is_default) AS extra_filling,
        coalesce((SELECT jsonb_agg(to_jsonb(opt) ORDER BY opt.option_group_name, opt.option_name)
          FROM (SELECT DISTINCT x.option_group_name, x.option_name
            FROM order_line_option x
            WHERE x.order_line_id IN (SELECT u.order_line_id FROM don_vi_ban u
                WHERE u.table_session_id = d.table_session_id
                  AND u.menu_component_id IS NOT DISTINCT FROM d.menu_component_id
                  AND u.filling_option_ids = d.filling_option_ids)) opt), '[]'::jsonb) AS options
 FROM don_vi_ban d GROUP BY table_session_id, menu_component_id, filling_option_ids
), phien AS (
 SELECT s.id AS table_session_id, s.status AS session_status,
   CASE WHEN EXISTS (SELECT 1 FROM don_vi_ban d WHERE d.table_session_id = s.id AND d.da_ra_het)
     THEN 'serving'
     WHEN EXISTS (SELECT 1 FROM sales_order o JOIN don_nguon n ON n.id = o.id WHERE o.table_session_id = s.id)
     THEN 'waiting' ELSE 'no_order' END AS service_group,
   coalesce((SELECT jsonb_agg(jsonb_build_object('dining_table_id', t.id, 'label', t.label) ORDER BY t.id)
     FROM table_session_member m JOIN dining_table t ON t.id = m.dining_table_id
     WHERE m.table_session_id = s.id), '[]'::jsonb) AS tables,
   coalesce((SELECT sum(d.amount_vnd) FROM da_ra d JOIN sales_order o ON o.id = d.sales_order_id
     WHERE o.table_session_id = s.id), 0) AS served_amount_vnd,
   coalesce((SELECT jsonb_agg(to_jsonb(t) - 'table_session_id' ORDER BY t.menu_component_id, t.filling_option_ids)
     FROM thu t WHERE t.table_session_id = s.id), '[]'::jsonb) AS items
 FROM phien_mo s
), lich_su AS (
 SELECT r.created_at AS served_at, r.person_id, p.display_name AS person_name,
        v.dining_table_id, t.label AS table_label, v.station_code,
        v.menu_component_id, min(v.component_name) AS component_name,
        v.filling_option_ids, count(*) AS quantity
 FROM record_revision r JOIN viec v ON v.id = r.target_row
 JOIN dining_table t ON t.id = v.dining_table_id JOIN person p ON p.id = r.person_id
 WHERE r.target_table_code = 'station_job'
   AND r.before_image->>'status' = 'made' AND r.after_image->>'status' = 'served'
   AND r.created_at::date = $1::text::date
 GROUP BY r.created_at, r.person_id, p.display_name, v.dining_table_id, t.label,
          v.station_code, v.menu_component_id, v.filling_option_ids
)
SELECT jsonb_build_object('sale_date', $1::text, 'read_at', now(),
 'sessions', coalesce((SELECT jsonb_agg(to_jsonb(s) ORDER BY table_session_id) FROM phien s), '[]'::jsonb),
 'empty_tables', coalesce((SELECT jsonb_agg(jsonb_build_object('dining_table_id', t.id, 'label', t.label) ORDER BY t.id)
   FROM dining_table t WHERE NOT EXISTS (SELECT 1 FROM table_session_member m
     WHERE m.dining_table_id = t.id AND NOT m.session_closed)), '[]'::jsonb),
 'serve_history', coalesce((SELECT jsonb_agg(to_jsonb(h) ORDER BY served_at DESC, dining_table_id,
   station_code, menu_component_id, filling_option_ids, person_id) FROM lich_su h), '[]'::jsonb)
)::jsonb AS result;
