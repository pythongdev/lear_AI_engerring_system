-- kêu: I-012/3
-- Chủ quán không đứng quầy mà tự bấm lần hoàn của đơn tới lấy (shop-facts §6.13: phải nhờ quầy).
UPDATE refund SET person_id = pg_temp.bc_nguoi('Chủ quán')
WHERE id = (SELECT id FROM bc WHERE ten = 'hoan_lay');
