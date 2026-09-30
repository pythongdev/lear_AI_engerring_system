-- kêu: QD-34
-- Một bảng mới không có created_at.
CREATE TABLE note_log (id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY);
CREATE TRIGGER note_log_record_revision_trg AFTER UPDATE ON note_log FOR EACH ROW
  EXECUTE FUNCTION record_revision_capture();
