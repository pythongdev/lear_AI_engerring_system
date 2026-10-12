-- I-016 — docs/product/1-system-design/03-bao-ve-invariant.md §2, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.

-- @@ I-016/1 — lần chuyển trạng thái (dựng lại từ vết cập nhật) không có dòng trong bảng của đúng vòng đời ấy
-- Danh sách so sánh là dc_transition, điền lúc chạy từ 05-vong-doi.md §5.2 · §5.3 · §5.4 — không
-- chép ở đây, nên nó đổi theo mỗi lần §5 thêm hoặc bớt một dòng. So với bảng HÔM NAY, không với
-- bảng tại lúc chuyển: §5 chưa có lịch sử phiên bản đọc được bằng máy. Từ bước 20 (T-138) mọi lần
-- chuyển có vết, trừ lần khách QR gọi thêm kéo phiên Chờ thanh toán → Đang phục vụ (F-060).
-- ADR-095: soi thêm khoảng hở giữa hai vết liền nhau của phiên; chỉ tha khi có đơn QR trong khoảng.
-- id giữ thứ tự chụp vết; revised_at = now() có thể trùng trong cùng giao dịch.
WITH vet_phien AS (
  SELECT target_row, before_image, revised_at,
         lag(after_image) OVER w AS ban_sau_truoc,
         lag(revised_at) OVER w AS moc_truoc
  FROM record_revision WHERE target_table_code = 'table_session'
  WINDOW w AS (PARTITION BY target_row ORDER BY id)
)
SELECT r.target_table_code AS bang, r.target_row AS dong, r.before_image ->> 'status' AS tu,
       r.after_image ->> 'status' AS den, r.revised_at AS luc
FROM record_revision r
WHERE r.target_table_code IN (SELECT table_name FROM pg_temp.dc_transition)
  AND r.before_image ->> 'status' IS DISTINCT FROM r.after_image ->> 'status'
  AND NOT EXISTS (SELECT 1 FROM pg_temp.dc_transition t
                  WHERE t.table_name = r.target_table_code
                    AND t.from_code = r.before_image ->> 'status'
                    AND t.to_code = r.after_image ->> 'status')

UNION ALL
SELECT 'table_session' AS bang, v.target_row AS dong,
       v.ban_sau_truoc ->> 'status' AS tu, v.before_image ->> 'status' AS den,
       v.revised_at AS luc
FROM vet_phien v
WHERE v.moc_truoc IS NOT NULL
  AND v.ban_sau_truoc ->> 'status' IS DISTINCT FROM v.before_image ->> 'status'
  AND NOT (
    v.ban_sau_truoc ->> 'status' IS NOT DISTINCT FROM 'awaiting_payment'
    AND v.before_image ->> 'status' IS NOT DISTINCT FROM 'serving'
    AND EXISTS (SELECT 1 FROM sales_order o
                WHERE o.table_session_id = v.target_row AND o.channel_code = 'qr_table'
                  AND o.created_at >= v.moc_truoc AND o.created_at <= v.revised_at)
  )
