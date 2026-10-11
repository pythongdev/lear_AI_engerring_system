-- kêu: I-011/1
-- Lúc 08:00 — giữa giờ bán — suất "Giò bán rời" được thêm một cái bánh cuốn: không vết, không người.
-- T-138: chế độ nghiêm từ chối lần thêm không lý do, nên lỗi cài tắt trigger vết của bảng (pg_temp.bc_vet).
DO $$ BEGIN PERFORM pg_temp.bc_vet('menu_item_component', false); END $$;
INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity, created_at)
VALUES ((SELECT id FROM menu_item WHERE name = 'Giò bán rời'),
        (SELECT id FROM menu_component WHERE name = 'Bánh cuốn'), 1, pg_temp.bc_luc('08:00'));
DO $$ BEGIN PERFORM pg_temp.bc_vet('menu_item_component', true); END $$;
