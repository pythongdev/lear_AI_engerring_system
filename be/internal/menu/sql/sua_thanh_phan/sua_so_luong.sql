-- Cửa menu/sua_thanh_phan (P3-06, lớp chu_quan); chỉ sửa đúng cặp món · thành phần.
UPDATE menu_item_component SET quantity = $3 WHERE menu_item_id = $1 AND menu_component_id = $2
RETURNING menu_item_id, menu_component_id, quantity
