-- Đường lùi của 20260928120000_duong_tien.up.sql (P2-06 — đường tiền).
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
    'opening_float_line', 'opening_float', 'prepayment_use', 'refund', 'prepayment',
    'debt_collection', 'bill'
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

-- Khoá ngoại từ bảng của lát trước sang hoá đơn: gỡ trước, rồi mới gỡ bảng.
ALTER TABLE sales_order DROP CONSTRAINT sales_order_bill_fkey;
ALTER TABLE table_session DROP CONSTRAINT table_session_bill_fkey;

DROP TABLE opening_float_line, opening_float, prepayment_use, refund, prepayment,
  debt_collection, bill;

ALTER TABLE sales_order
  DROP COLUMN id_if_completed_standalone,
  DROP COLUMN id_if_standalone;
ALTER TABLE table_session DROP COLUMN id_if_closed;
