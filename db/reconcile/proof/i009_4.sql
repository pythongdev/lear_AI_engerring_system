-- kêu: I-009/4
-- Suất giò ngừng bán từ 06:00, mà đơn tới lấy lúc 09:00 vẫn đặt được nó.
UPDATE menu_item SET discontinued_at = pg_temp.bc_luc('06:00') WHERE name = 'Suất giò';
