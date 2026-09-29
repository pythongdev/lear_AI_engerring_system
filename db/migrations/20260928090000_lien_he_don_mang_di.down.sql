-- Đường lùi của 20260928090000_lien_he_don_mang_di.up.sql (T-111 — liên hệ của đơn mang đi).
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
    'sales_order.handover_code', 'sales_order.customer_phone', 'sales_order.delivery_address',
    'sales_order.customer_needed_at', 'sales_order.customer_name', 'sales_order.contact_note'
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

-- Năm ràng buộc kiểm của I-022 đứng trên các cột này, nên đi cùng cột.
ALTER TABLE sales_order
  DROP COLUMN is_door_delivery,
  DROP COLUMN handover_code,
  DROP COLUMN customer_phone,
  DROP COLUMN delivery_address,
  DROP COLUMN customer_needed_at,
  DROP COLUMN customer_name,
  DROP COLUMN contact_note;
