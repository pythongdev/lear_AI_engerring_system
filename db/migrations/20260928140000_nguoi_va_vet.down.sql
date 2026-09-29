-- Đường lùi của 20260928140000_nguoi_va_vet.up.sql (P2-08 — người · chỗ đứng theo thời điểm · vết).
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
    'record_revision', 'paper_ledger', 'counter_duty', 'person', 'bill.person_id',
    'debt_collection.person_id', 'prepayment.person_id', 'refund.person_id',
    'opening_float.person_id', 'station_job_transfer.person_id', 'qr_code.person_id',
    'production_batch.made_by_person_id', 'production_batch.rolled_back_by_person_id',
    'bill.paper_ledger_id', 'bill.paper_entry_count', 'bill.paper_position'
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

-- Trigger vết trên mọi bảng, đúng tên bước xuôi đã đặt.
DO $$
DECLARE t text;
BEGIN
  FOR t IN
    SELECT DISTINCT event_object_table FROM information_schema.triggers
    WHERE trigger_schema = 'shop' AND trigger_name = event_object_table || '_record_revision_trg'
  LOOP
    EXECUTE format('DROP TRIGGER %I ON %I', t || '_record_revision_trg', t);
  END LOOP;
END $$;
DROP FUNCTION record_revision_capture();
DROP TABLE record_revision;

-- Sổ giấy: khoá ngoại ba cột và ba ràng buộc kiểm đi cùng cột của hoá đơn.
ALTER TABLE bill
  DROP COLUMN paper_ledger_id,
  DROP COLUMN paper_entry_count,
  DROP COLUMN paper_position;
DROP TABLE paper_ledger;

-- "Ai bấm": khoá ngoại và ràng buộc kiểm đi cùng cột; cột phải đi trước hàm mặc định của nó.
ALTER TABLE production_batch
  DROP COLUMN made_by_person_id,
  DROP COLUMN rolled_back_by_person_id;
ALTER TABLE qr_code DROP COLUMN person_id;
ALTER TABLE station_job_transfer DROP COLUMN person_id;
ALTER TABLE opening_float DROP COLUMN person_id;
ALTER TABLE refund DROP COLUMN person_id;
ALTER TABLE prepayment DROP COLUMN person_id;
ALTER TABLE debt_collection DROP COLUMN person_id;
ALTER TABLE bill DROP COLUMN person_id;

DROP TABLE counter_duty;
DROP FUNCTION actor_person_id();
DROP TABLE person;
