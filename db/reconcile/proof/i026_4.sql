-- kêu: I-026/4
-- Gỡ khoá tên; chèn tên bằng đúng tên đã có theo phép bằng của cột.
ALTER TABLE supply_item DROP CONSTRAINT supply_item_name_key;
INSERT INTO supply_item (name, purchase_unit)
SELECT name, purchase_unit FROM supply_item ORDER BY id LIMIT 1;
