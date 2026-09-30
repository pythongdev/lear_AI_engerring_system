-- kêu: I-011/1
-- Lúc 08:00 — giữa giờ bán — suất "Giò bán rời" được thêm một cái bánh cuốn: không vết, không người.
INSERT INTO menu_item_component (menu_item_id, menu_component_id, quantity, created_at)
VALUES ((SELECT id FROM menu_item WHERE name = 'Giò bán rời'),
        (SELECT id FROM menu_component WHERE name = 'Bánh cuốn'), 1, pg_temp.bc_luc('08:00'));
