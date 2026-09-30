-- I-018 — docs/product/1-system-design/03-bao-ve-invariant.md §3, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Vết đang ở CHẾ ĐỘ MỀM (work/findings.md F-046): lần sửa không khai lý do không để lại vết nào, và
-- không câu nào ở đây thấy nó — hai câu dưới chỉ đọc được vết ĐÃ có. Tập thứ hai của pha 1 (lần ghi
-- đè của hai người cùng thao tác một bàn) KHÔNG có câu — file 09 §2.

-- @@ I-018/1 — lần cập nhật mà vết thiếu một trong bốn thứ: bản trước, bản sau, lý do, người sửa
SELECT r.id AS vet, r.target_table_code AS bang, r.target_row AS dong
FROM record_revision r
WHERE r.before_image IS NULL OR r.after_image IS NULL
   OR btrim(coalesce(r.reason, '')) = '' OR r.person_id IS NULL

-- @@ I-018/3 — dòng đơn sửa sau một lần đổi giá giữa buổi mà không đọc ra giá trị trước và sau của đúng dòng ấy
-- Dòng đã sửa = mốc khoá muộn hơn lúc tạo dòng; giữa hai mốc ấy có một lần đổi giá của thành phần
-- hay tuỳ chọn trên chính dòng; và không vết nào của dòng mang cả hai bản.
SELECT l.id AS dong, l.created_at AS luc_tao, l.priced_at AS moc_khoa
FROM order_line l
WHERE l.priced_at > l.created_at
  AND EXISTS (SELECT 1 FROM record_revision m
              WHERE m.revised_at > l.created_at AND m.revised_at <= l.priced_at
                AND (   (m.target_table_code = 'menu_component'
                         AND m.before_image -> 'base_price_vnd' IS DISTINCT FROM m.after_image -> 'base_price_vnd'
                         AND m.target_row IN (SELECT menu_component_id FROM order_line_component
                                              WHERE order_line_id = l.id))
                     OR (m.target_table_code = 'menu_option'
                         AND m.before_image -> 'surcharge_vnd' IS DISTINCT FROM m.after_image -> 'surcharge_vnd'
                         AND m.target_row IN (SELECT menu_option_id FROM order_line_option
                                              WHERE order_line_id = l.id))))
  AND NOT EXISTS (SELECT 1 FROM record_revision r
                  WHERE r.target_table_code = 'order_line' AND r.target_row = l.id
                    AND r.before_image ? 'unit_price_vnd' AND r.after_image ? 'unit_price_vnd')
