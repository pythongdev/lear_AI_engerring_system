-- I-016 — docs/product/1-system-design/03-bao-ve-invariant.md §2, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.

-- @@ I-016/1 — lần chuyển trạng thái (dựng lại từ vết cập nhật) không có dòng trong bảng của đúng vòng đời ấy
-- Danh sách so sánh là dc_transition, điền lúc chạy từ 05-vong-doi.md §5.2 · §5.3 · §5.4 — không
-- chép ở đây, nên nó đổi theo mỗi lần §5 thêm hoặc bớt một dòng. So với bảng HÔM NAY, không với
-- bảng tại lúc chuyển: §5 chưa có lịch sử phiên bản đọc được bằng máy. Lần chuyển không khai lý do
-- không có vết (F-046) và không câu nào thấy.
SELECT r.target_table_code AS bang, r.target_row AS dong, r.before_image ->> 'status' AS tu,
       r.after_image ->> 'status' AS den, r.revised_at AS luc
FROM record_revision r
WHERE r.target_table_code IN (SELECT table_name FROM pg_temp.dc_transition)
  AND r.before_image ->> 'status' IS DISTINCT FROM r.after_image ->> 'status'
  AND NOT EXISTS (SELECT 1 FROM pg_temp.dc_transition t
                  WHERE t.table_name = r.target_table_code
                    AND t.from_code = r.before_image ->> 'status'
                    AND t.to_code = r.after_image ->> 'status')
