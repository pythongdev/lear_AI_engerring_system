-- kêu: I-008/3
-- Một đơn tới lấy được tạo lúc 07:08 — trong khoảng quán mù 07:05–07:15 mà máy đã phát hiện, trước
-- lúc có người bấm mở lại (U-061: khoảng tính từ lúc quán hết nhìn thấy).
INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                         submission_code, created_at)
VALUES ('pickup', 'new', 'shop_pickup', '0900000083', pg_temp.bc_luc('07:30'),
        gen_random_uuid()::text, pg_temp.bc_luc('07:08'));
