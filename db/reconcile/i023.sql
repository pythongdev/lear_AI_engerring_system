-- I-023 — docs/product/1-system-design/03-bao-ve-invariant.md §1, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Vế "không đoán được" không có tập (pha 1 nói thẳng). Tập thứ bảy của pha 1 (lần đổi mã chạm phiên
-- bàn đang mở) KHÔNG có câu: phiên và lượt gọi không mang mốc đổi trạng thái nào để so với lần đổi
-- mã, và cửa đổi mã không chạm chúng — file 09 §2.

-- @@ I-023/1 — lượt gọi QR mà bàn của nó khác bàn mà mã nó mang chỉ tới
SELECT o.id AS don, o.dining_table_id AS ban_cua_don, q.dining_table_id AS ban_cua_ma
FROM sales_order o JOIN qr_code q ON q.id = o.qr_code_id
WHERE o.dining_table_id IS DISTINCT FROM q.dining_table_id

-- @@ I-023/2 — lượt gọi QR không đọc ra được nó đã mang mã nào
SELECT o.id AS don, o.qr_code_id AS ma
FROM sales_order o
WHERE o.channel_code = 'qr_table'
  AND NOT EXISTS (SELECT 1 FROM qr_code q WHERE q.id = o.qr_code_id)

-- @@ I-023/3 — lượt gọi QR tạo sau lúc mã nó mang bị thay
SELECT o.id AS don, o.created_at AS luc_tao, q.replaced_at AS luc_ma_bi_thay
FROM sales_order o JOIN qr_code q ON q.id = o.qr_code_id
WHERE o.channel_code = 'qr_table' AND o.created_at > q.replaced_at

-- @@ I-023/4 — bàn có hơn một mã hiện hành tại cùng một thời điểm
SELECT a.dining_table_id AS ban, a.id AS ma_a, b.id AS ma_b
FROM qr_code a
JOIN qr_code b ON b.dining_table_id = a.dining_table_id AND b.id > a.id
WHERE a.issued_at < coalesce(b.replaced_at, 'infinity')
  AND b.issued_at < coalesce(a.replaced_at, 'infinity')

-- @@ I-023/5 — mã từng chỉ tới hơn một bàn
SELECT q.code AS ma, count(DISTINCT q.dining_table_id) AS so_ban
FROM qr_code q
GROUP BY q.code
HAVING count(DISTINCT q.dining_table_id) > 1

-- @@ I-023/6 — lần cấp hay đổi mã không đọc ra bàn nào · lúc nào · ai đổi
SELECT q.id AS ma, q.dining_table_id AS ban, q.issued_at AS luc, q.person_id AS ai
FROM qr_code q
WHERE q.dining_table_id IS NULL OR q.issued_at IS NULL OR q.person_id IS NULL
