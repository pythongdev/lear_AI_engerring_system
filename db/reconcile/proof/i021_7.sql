-- kêu: I-021/7 I-021/1
-- T-133: ngày mẫu đã đếm két; lỗi này đổi tiền mặt, tiền đầu két hay khoản chi của ngày ấy mà
-- số đếm đứng yên, nên phép trừ két lệch (I-021/1) — và I-012/2 khi chỗ lệch không khớp đúng một thao tác.
-- Một phút sau khi khai, một xấp 2.000đ được thêm vào tiền đầu két — con số của ngày đổi mà không
-- đọc ra ai thêm, từ bao nhiêu sang bao nhiêu.
INSERT INTO opening_float_line (opening_float_id, denomination_vnd, amount_vnd, created_at)
SELECT id, 2000, 20000, created_at + interval '1 minute' FROM opening_float WHERE sale_date = pg_temp.bc_ngay();
