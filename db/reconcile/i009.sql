-- I-009 — docs/product/1-system-design/03-bao-ve-invariant.md §3, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Mốc khoá của một dòng là order_line.priced_at: lúc tạo lượt gọi, đặt lại khi người SỬA dòng
-- (U-026). Một lần sửa dòng đúng luật đổi giá/tên/món CÙNG với priced_at, và để lại vết (I-018).

-- @@ I-009/1 — dòng đơn có giá, tên món hoặc món đọc ra khác giá trị đã khoá mà không phải một lần sửa dòng
-- Vết cho thấy giá trị đã khoá của dòng đổi trong khi mốc khoá đứng yên: dòng bị ghi đè — kiểu đọc
-- lại theo menu hiện hành — chứ không phải người sửa dòng. Lần ghi đè không khai lý do không có vết
-- (F-046) và không câu nào thấy.
SELECT r.target_row AS dong, r.revised_at AS luc,
       r.before_image ->> 'unit_price_vnd' AS gia_truoc, r.after_image ->> 'unit_price_vnd' AS gia_sau,
       r.before_image ->> 'item_name' AS ten_truoc, r.after_image ->> 'item_name' AS ten_sau
FROM record_revision r
WHERE r.target_table_code = 'order_line'
  AND (   r.before_image -> 'unit_price_vnd' IS DISTINCT FROM r.after_image -> 'unit_price_vnd'
       OR r.before_image -> 'item_name'      IS DISTINCT FROM r.after_image -> 'item_name'
       OR r.before_image -> 'menu_item_id'   IS DISTINCT FROM r.after_image -> 'menu_item_id')
  AND r.before_image -> 'priced_at' IS NOT DISTINCT FROM r.after_image -> 'priced_at'

-- @@ I-009/2 — phiên bàn vắt qua một lần đổi giá mà chỉ mang một mức giá cho món đã đổi
-- Hai dòng cùng phiên, cùng món, cùng tập tuỳ chọn: giá có hiệu lực tại hai mốc khoá của chúng khác
-- nhau mà giá đã khoá lại bằng nhau. Hai mức giá trên một hoá đơn KHÔNG phải điều kiện lệch.
WITH d AS (
  SELECT l.id, o.table_session_id AS phien, l.menu_item_id, l.unit_price_vnd, l.priced_at,
         pg_temp.gia_dong_tai(l.id) AS gia_tai_moc,
         (SELECT coalesce(string_agg(x.menu_option_id::text, ',' ORDER BY x.menu_option_id), '')
          FROM order_line_option x WHERE x.order_line_id = l.id) AS tuy_chon
  FROM order_line l JOIN sales_order o ON o.id = l.sales_order_id
  WHERE o.table_session_id IS NOT NULL)
SELECT a.phien, a.id AS dong_truoc, b.id AS dong_sau, a.unit_price_vnd AS gia_da_khoa,
       a.gia_tai_moc AS gia_luc_truoc, b.gia_tai_moc AS gia_luc_sau
FROM d a JOIN d b
  ON b.phien = a.phien AND b.menu_item_id = a.menu_item_id AND b.tuy_chon = a.tuy_chon
 AND b.priced_at > a.priced_at
WHERE a.gia_tai_moc <> b.gia_tai_moc AND a.unit_price_vnd = b.unit_price_vnd

-- @@ I-009/3 — lần sửa một dòng không để lại vết giá cũ / giá mới
-- Dòng đã sửa = mốc khoá của nó muộn hơn lúc dòng được tạo. Vết phải có một bản trước mang mốc cũ.
SELECT l.id AS dong, l.created_at AS luc_tao, l.priced_at AS moc_khoa
FROM order_line l
WHERE l.priced_at > l.created_at
  AND NOT EXISTS (SELECT 1 FROM record_revision r
                  WHERE r.target_table_code = 'order_line' AND r.target_row = l.id
                    AND r.before_image -> 'priced_at' IS DISTINCT FROM r.after_image -> 'priced_at'
                    AND r.before_image ? 'unit_price_vnd' AND r.after_image ? 'unit_price_vnd')

-- @@ I-009/4 — dòng đơn mà tại mốc khoá của nó món đã ngừng bán
SELECT l.id AS dong, l.item_name AS mon, l.priced_at AS moc_khoa, m.discontinued_at AS luc_ngung
FROM order_line l JOIN menu_item m ON m.id = l.menu_item_id
WHERE m.discontinued_at IS NOT NULL AND m.discontinued_at <= l.priced_at
