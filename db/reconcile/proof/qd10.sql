-- kêu: QD-10
-- Một bảng mới có khoá chính không tên id.
CREATE TABLE note_board (code_no bigint PRIMARY KEY, created_at timestamptz NOT NULL DEFAULT now());
CREATE TRIGGER note_board_record_revision_trg AFTER UPDATE ON note_board FOR EACH ROW
  EXECUTE FUNCTION record_revision_capture();
