-- kêu: I-008/2
-- Một đơn tới lấy được tạo lúc 06:15 — giữa khoảng tạm dừng 06:10–06:25 của ngày mẫu.
INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                         submission_code, created_at)
VALUES ('pickup', 'new', 'shop_pickup', '0900000082', pg_temp.bc_luc('07:00'),
        gen_random_uuid()::text, pg_temp.bc_luc('06:15'));
