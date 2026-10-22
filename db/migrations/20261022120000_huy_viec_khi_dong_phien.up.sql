-- T-227, ADR-125: đã làm nhưng không bưng vẫn giữ mục mẻ; không xoá việc.
ALTER TABLE station_job DROP CONSTRAINT station_job_status_check;
ALTER TABLE station_job ADD CONSTRAINT station_job_status_check
  CHECK (status IN ('pending', 'made', 'served', 'cancelled', 'discarded'));
ALTER TABLE production_batch_item DROP CONSTRAINT production_batch_item_live_station_job_fkey;
ALTER TABLE wrong_make_note DROP CONSTRAINT wrong_make_note_live_station_job_fkey;
ALTER TABLE station_job DROP CONSTRAINT station_job_made_in_batch_fkey;
-- SET EXPRESSION (PostgreSQL 17) giữ vị trí cột, nên đường lùi dựng lại đúng lược đồ cũ.
ALTER TABLE station_job ALTER COLUMN id_if_made_or_served SET EXPRESSION AS
  (CASE WHEN status IN ('made', 'served', 'discarded') THEN id END);
ALTER TABLE production_batch_item ADD CONSTRAINT production_batch_item_live_station_job_fkey
  FOREIGN KEY (live_station_job_id) REFERENCES station_job (id_if_made_or_served) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE station_job ADD CONSTRAINT station_job_made_in_batch_fkey
  FOREIGN KEY (id_if_made_or_served) REFERENCES production_batch_item (live_station_job_id) DEFERRABLE INITIALLY DEFERRED;
ALTER TABLE wrong_make_note ADD CONSTRAINT wrong_make_note_live_station_job_fkey
  FOREIGN KEY (live_station_job_id) REFERENCES station_job (id_if_made_or_served);

-- Không thể lùi một mẻ chứa phần đã bỏ lúc đóng phiên.
CREATE FUNCTION production_batch_discarded_guard() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.is_rolled_back AND EXISTS (
    SELECT 1 FROM production_batch_item i JOIN station_job j ON j.id = i.station_job_id
    WHERE i.production_batch_id = NEW.id AND j.status = 'discarded'
  ) THEN
    RAISE EXCEPTION 'mẻ có phần đã bỏ lúc đóng phiên'
      USING ERRCODE = '23514', CONSTRAINT = 'production_batch_no_discarded_jobs_check';
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER production_batch_no_discarded_jobs_trg AFTER UPDATE ON production_batch
  FOR EACH ROW EXECUTE FUNCTION production_batch_discarded_guard();
