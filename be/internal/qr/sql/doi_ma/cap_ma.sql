-- Cửa qr/doi_ma (P3-05, lớp chu_quan — U-062). Không câu ghi thẳng vào qr_code: shop_app bị
-- REVOKE, ô ấy thuộc hàm qr_code_issue của migration (I-023 "không đoán được", tầng 3).
SELECT qr_code_issue($1)
