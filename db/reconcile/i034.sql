-- I-034 — bán combo; ADR-117. Ý định và giới hạn: docs/product/2-db/20-luoc-do-ban-combo.md.
-- Vết sửa mức dùng I-018, đơn cũ giữ giá dùng I-009; các vế chưa có tập ghi ở file lát và file 09.

-- @@ I-034/1 — mức âm, hoặc lựa chọn không thuộc nhóm nào mà món của dòng combo mang
SELECT s.id AS muc FROM menu_combo_item_option_surcharge s
JOIN menu_combo_item ci ON ci.id = s.menu_combo_item_id
WHERE s.surcharge_vnd < 0
   OR NOT EXISTS (SELECT 1 FROM menu_item_option_group g JOIN menu_option o ON o.option_group_id = g.option_group_id
                  WHERE g.menu_item_id = ci.menu_item_id AND o.id = s.menu_option_id)

-- @@ I-034/2 — dòng combo không dòng con, có thành phần hoặc có lựa chọn
SELECT l.id AS dong_combo FROM order_line l
WHERE l.menu_combo_id IS NOT NULL
  AND (NOT EXISTS (SELECT 1 FROM order_line c WHERE c.parent_order_line_id = l.id)
       OR EXISTS (SELECT 1 FROM order_line_component x WHERE x.order_line_id = l.id)
       OR EXISTS (SELECT 1 FROM order_line_option x WHERE x.order_line_id = l.id))

-- @@ I-034/3 — dòng con trỏ sai: cha không phải dòng combo, khác đơn hoặc khác dấu đem về
SELECT c.id AS dong_con FROM order_line c
LEFT JOIN order_line p ON p.id = c.parent_order_line_id
WHERE c.parent_order_line_id IS NOT NULL
  AND (p.id IS NULL OR p.menu_combo_id IS NULL OR p.sales_order_id <> c.sales_order_id
       OR p.is_takeaway <> c.is_takeaway OR c.menu_item_id IS NULL)

-- @@ I-034/4 — combo thiếu hay thừa suất: số suất mỗi món khác số phần × số combo
-- Đọc thành phần combo hiện hành: số phần đổi sau khi đặt thì câu báo nhầm — xem giới hạn ở file 09.
WITH can AS (
  SELECT l.id AS dong_combo, ci.menu_item_id, ci.quantity * l.quantity AS so_suat
  FROM order_line l JOIN menu_combo_item ci ON ci.menu_combo_id = l.menu_combo_id
), co AS (
  SELECT c.parent_order_line_id AS dong_combo, c.menu_item_id, sum(c.quantity) AS so_suat
  FROM order_line c WHERE c.parent_order_line_id IS NOT NULL
  GROUP BY c.parent_order_line_id, c.menu_item_id
)
SELECT coalesce(can.dong_combo, co.dong_combo) AS dong_combo, coalesce(can.menu_item_id, co.menu_item_id) AS mon,
       can.so_suat AS can, co.so_suat AS co
FROM can FULL JOIN co ON co.dong_combo = can.dong_combo AND co.menu_item_id = can.menu_item_id
WHERE can.so_suat IS DISTINCT FROM co.so_suat

-- @@ I-034/5 — tiền một suất con khác tổng mức có hiệu lực tại mốc khoá, hay khác tổng mức đã chụp của nó
-- Mức tại mốc như I-013/1: vết sớm nhất sau mốc, cặp chưa đặt trước mốc là 0đ (lời đóng U-096).
SELECT c.id AS dong_con, c.priced_at AS moc_khoa, c.unit_price_vnd AS gia_da_khoa
FROM order_line c JOIN order_line p ON p.id = c.parent_order_line_id
WHERE c.unit_price_vnd <> (
        SELECT coalesce(sum(pg_temp.gia_tai('menu_combo_item_option_surcharge', s.id, 'surcharge_vnd',
                                            s.surcharge_vnd, c.priced_at)), 0)
        FROM order_line_option x
        JOIN menu_combo_item ci ON ci.menu_combo_id = p.menu_combo_id AND ci.menu_item_id = c.menu_item_id
        JOIN menu_combo_item_option_surcharge s
          ON s.menu_combo_item_id = ci.id AND s.menu_option_id = x.menu_option_id AND s.created_at <= c.priced_at
        WHERE x.order_line_id = c.id)
   OR c.unit_price_vnd <> (SELECT coalesce(sum(x.surcharge_vnd), 0) FROM order_line_option x WHERE x.order_line_id = c.id)

-- @@ I-034/6 — lần đổi mức phụ thu trong combo có lúc trong giờ bán
-- Cùng tham số giờ và múi giờ từ owner như I-011 · I-032/6, không đặt giờ riêng.
SELECT r.id AS vet, r.target_row AS muc, r.revised_at
FROM record_revision r
WHERE r.target_table_code = 'menu_combo_item_option_surcharge'
  AND r.before_image -> 'surcharge_vnd' IS DISTINCT FROM r.after_image -> 'surcharge_vnd'
  AND r.revised_at IS NOT NULL
  AND (r.revised_at AT TIME ZONE :mui_gio)::time BETWEEN :gio_mo AND :gio_dong

-- @@ I-034/7 — dòng combo mà giá khác giá combo có hiệu lực tại mốc khoá của nó
SELECT l.id AS dong_combo, l.priced_at AS moc_khoa, l.unit_price_vnd AS gia_da_khoa,
       pg_temp.gia_tai('menu_combo', m.id, 'price_vnd', m.price_vnd, l.priced_at) AS gia_tai_moc
FROM order_line l JOIN menu_combo m ON m.id = l.menu_combo_id
WHERE l.unit_price_vnd <> pg_temp.gia_tai('menu_combo', m.id, 'price_vnd', m.price_vnd, l.priced_at)
