-- Đường lùi của 20260928130000_san_xuat_theo_me.up.sql (P2-07 — sản xuất theo mẻ).
-- Thứ tự dựng và luật lùi: docs/product/2-db/07-thu-tu-migration.md · docs/decisions.md ADR-065.
--
-- KHOÁ CHẶN: đường lùi chỉ gỡ chỗ cất còn RỖNG. Một bảng sắp gỡ có dòng, hay một cột ghi sắp gỡ
-- có giá trị ⇒ từ chối, không gỡ gì (cả file là một giao dịch, QC-05). Lùi trên dữ liệu đã ghi
-- đi bằng một migration mới đi tới. Cột tự tính và ràng buộc không cất dữ liệu nên không cần chặn.
DO $$
DECLARE
  target text;
  n      bigint;
BEGIN
  FOREACH target IN ARRAY ARRAY[
    'station_job_transfer', 'production_batch_item', 'production_batch', 'station_job',
    'menu_component_station'
  ] LOOP
    IF position('.' IN target) = 0 THEN
      EXECUTE format('SELECT count(*) FROM %I', target) INTO n;
    ELSE
      EXECUTE format('SELECT count(%I) FROM %I', split_part(target, '.', 2),
                     split_part(target, '.', 1)) INTO n;
    END IF;
    IF n > 0 THEN
      RAISE EXCEPTION 'đường lùi từ chối: % đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', target, n
        USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
    END IF;
  END LOOP;
END $$;

-- Việc trạm và phần của mẻ trỏ vòng vào nhau: gỡ cùng một lệnh.
DROP TABLE station_job_transfer, production_batch_item, production_batch, station_job,
  menu_component_station;

ALTER TABLE order_line_component DROP CONSTRAINT order_line_component_id_line_quantity_key;
ALTER TABLE order_line DROP CONSTRAINT order_line_id_order_quantity_key;
ALTER TABLE sales_order DROP COLUMN id_if_approved;
