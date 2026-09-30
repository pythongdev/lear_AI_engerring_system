-- I-013 — docs/product/1-system-design/03-bao-ve-invariant.md §1, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Tập thứ ba của pha 1 (kênh không có lượt kiểm ra đúng giá §4.8) là một tính chất của BỘ TEST,
-- không đọc được trên dữ liệu — file 09 §2.

-- @@ I-013/1 — dòng đơn mà giá một suất khác tổng giá các thành phần theo mức có hiệu lực tại mốc khoá
-- Hai mức giá trên một hoá đơn vì chủ quán đổi giá giữa buổi là đúng: mỗi dòng so với mốc của nó.
SELECT l.id AS dong, l.item_name AS mon, l.priced_at AS moc_khoa, l.unit_price_vnd AS gia_da_khoa,
       pg_temp.gia_dong_tai(l.id) AS gia_tai_moc
FROM order_line l
WHERE l.unit_price_vnd IS DISTINCT FROM pg_temp.gia_dong_tai(l.id)

-- @@ I-013/2 — dòng đơn giá 0đ cho một suất không có giá 0đ
SELECT l.id AS dong, l.item_name AS mon, pg_temp.gia_dong_tai(l.id) AS gia_tai_moc
FROM order_line l
WHERE l.unit_price_vnd = 0 AND pg_temp.gia_dong_tai(l.id) > 0
