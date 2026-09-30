-- kêu: QD-22
-- Một bảng hai cột tiền mà không ràng buộc nào nói quan hệ giữa chúng.
CREATE TABLE surcharge_note (
  id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  price_vnd  bigint CONSTRAINT surcharge_note_price_check CHECK (price_vnd >= 0),
  tax_vnd    bigint CONSTRAINT surcharge_note_tax_check CHECK (tax_vnd >= 0),
  created_at timestamptz NOT NULL DEFAULT now());
CREATE TRIGGER surcharge_note_record_revision_trg AFTER UPDATE ON surcharge_note FOR EACH ROW
  EXECUTE FUNCTION record_revision_capture();
