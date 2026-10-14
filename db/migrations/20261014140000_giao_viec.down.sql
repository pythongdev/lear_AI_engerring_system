-- Đường lùi của 20261014140000_giao_viec.up.sql (P2A-11 — giao việc).
-- Thứ tự dựng và luật lùi: docs/product/2-db/07-thu-tu-migration.md · docs/decisions.md ADR-065.
--
-- KHOÁ CHẶN: đường lùi chỉ gỡ chỗ cất còn RỖNG. Bảng sắp gỡ có dòng ⇒ từ chối,
-- không gỡ gì (cả file là một giao dịch, QC-05). Lùi trên dữ liệu đã ghi bằng migration mới đi tới.
DO $$
DECLARE
  target text;
  n      bigint;
BEGIN
  FOREACH target IN ARRAY ARRAY['assigned_task_mark', 'assigned_task'] LOOP
    EXECUTE format('SELECT count(*) FROM %I', target) INTO n;
    IF n > 0 THEN
      RAISE EXCEPTION 'đường lùi từ chối: % đang giữ % giá trị đã ghi — gỡ nó là xoá dữ liệu', target, n
        USING HINT = 'lùi trên dữ liệu đã ghi bằng một migration mới đi tới (07-thu-tu-migration.md)';
    END IF;
  END LOOP;
END $$;

DROP TRIGGER assigned_task_mark_record_revision_trg ON assigned_task_mark;
DROP TABLE assigned_task_mark;
DROP TRIGGER assigned_task_record_revision_trg ON assigned_task;
DROP TABLE assigned_task;
