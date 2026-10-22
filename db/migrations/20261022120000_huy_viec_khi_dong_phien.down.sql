-- Khoá chặn: hai trạng thái mới là dữ liệu nghiệp vụ, không tự đổi để lùi.
LOCK TABLE station_job IN ACCESS EXCLUSIVE MODE;
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM station_job WHERE status IN ('cancelled', 'discarded')) THEN
    RAISE EXCEPTION 'đường lùi từ chối: station_job đang giữ việc cancelled hoặc discarded';
  END IF;
END $$;
DROP TRIGGER production_batch_no_discarded_jobs_trg ON production_batch;
DROP FUNCTION production_batch_discarded_guard();
ALTER TABLE production_batch_item DROP CONSTRAINT production_batch_item_live_station_job_fkey;
ALTER TABLE wrong_make_note DROP CONSTRAINT wrong_make_note_live_station_job_fkey;
ALTER TABLE station_job DROP CONSTRAINT station_job_made_in_batch_fkey;
-- SET EXPRESSION (PostgreSQL 17) giữ vị trí cột, nên đường lùi dựng lại đúng lược đồ cũ.
ALTER TABLE station_job ALTER COLUMN id_if_made_or_served SET EXPRESSION AS
  (CASE WHEN status IN ('made', 'served') THEN id END);
ALTER TABLE production_batch_item ADD CONSTRAINT production_batch_item_live_station_job_fkey
  FOREIGN KEY (live_station_job_id) REFERENCES station_job (id_if_made_or_served) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE station_job ADD CONSTRAINT station_job_made_in_batch_fkey
  FOREIGN KEY (id_if_made_or_served) REFERENCES production_batch_item (live_station_job_id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE wrong_make_note ADD CONSTRAINT wrong_make_note_live_station_job_fkey
  FOREIGN KEY (live_station_job_id) REFERENCES station_job (id_if_made_or_served);
ALTER TABLE station_job DROP CONSTRAINT station_job_status_check;
ALTER TABLE station_job ADD CONSTRAINT station_job_status_check CHECK (status IN ('pending', 'made', 'served'));
