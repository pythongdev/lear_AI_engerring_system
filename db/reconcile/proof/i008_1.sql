-- kêu: I-008/1
-- Một đơn tới lấy được tạo lúc 12:30 — sau giờ bán.
INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at,
                         submission_code, created_at)
VALUES ('pickup', 'new', 'shop_pickup', '0900000024', pg_temp.bc_luc('13:00'),
        gen_random_uuid()::text, pg_temp.bc_luc('12:30'));
