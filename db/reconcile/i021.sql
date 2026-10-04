-- I-021 — docs/product/1-system-design/03-bao-ve-invariant.md §1, cột phải. Mỗi khối `-- @@` là
-- MỘT tập "phải rỗng"; 0 dòng là đạt. Ánh xạ tập ↔ câu: docs/product/2-db/09-doi-chieu-bat-bien.md.
-- Phép trừ két (tập thứ nhất) đọc số đếm cuối ngày từ T-133 (cash_count, F-048) qua hàm
-- pg_temp.ket_ngay của prelude.sql. Ba tập đọc con số của báo cáo (4 · 5 · 6) và tập thứ hai (trừ vào
-- đúng một ngày bán, chờ luật chọn ngày U-072) KHÔNG có câu — file 09 §2.

-- @@ I-021/1 — ngày bán mà két đếm được − tiền đầu két khác vế phải của công thức
-- Ngưỡng 0đ, không dung sai. Chỉ ngày có CẢ số đếm lẫn tiền đầu két; ngày thiếu một trong hai là
-- "chưa đối soát xong", không phải lệch. Ngày có một khoản tạm ứng hay thưởng mà ngày khai khác ngày
-- ghi thì ngày két của khoản ấy chờ U-072 — câu không kết luận ngày ấy.
SELECT k.ngay, k.dem_duoc, k.dau_ket, k.dem_duoc - k.dau_ket AS ket_tru_dau_ket, k.ve_phai,
       k.dem_duoc - k.dau_ket - k.ve_phai AS lech
FROM pg_temp.ket_ngay(:mui_gio) k
WHERE NOT k.cho_u072 AND k.dem_duoc - k.dau_ket <> k.ve_phai

-- @@ I-021/3 — ngày bán mang hơn một con số tiền đầu két
-- Ngày CHƯA có con số tiền đầu két là "chưa đối soát xong", không phải lệch (tập thứ tư của pha 1,
-- ADR-037) — câu này không in nó.
SELECT f.sale_date AS ngay, count(*) AS so_con_so
FROM opening_float f
GROUP BY f.sale_date
HAVING count(*) > 1

-- @@ I-021/7 — lần sửa con số tiền đầu két không đọc ra ai bấm · lúc mấy giờ · từ bao nhiêu sang bao nhiêu
-- Hai hình: một xấp mệnh giá THÊM vào sau lúc khai — một dòng mới không mang người và không mang
-- bản trước; và một lần sửa xấp có vết mà vết thiếu người. Lần sửa không khai lý do không có vết
-- (F-046) và không câu nào thấy.
SELECT f.sale_date AS ngay, x.id AS dong_menh_gia, 'thêm sau lúc khai' AS kieu
FROM opening_float_line x JOIN opening_float f ON f.id = x.opening_float_id
WHERE x.created_at > f.created_at
UNION ALL
SELECT NULL, r.target_row, 'sửa, vết thiếu người'
FROM record_revision r
WHERE r.target_table_code IN ('opening_float', 'opening_float_line') AND r.person_id IS NULL
