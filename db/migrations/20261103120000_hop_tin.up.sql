-- CHAT-12 — ADR-137 điểm 3, 6, 9; I-038.
-- Ý định và ánh xạ: docs/product/2-db/26-luoc-do-hop-tin.md.
CREATE TABLE station_message (
  id bigint GENERATED ALWAYS AS IDENTITY,
  sender_person_id bigint NOT NULL DEFAULT actor_person_id(),
  recipient_person_id bigint,
  work_code text COLLATE "C" NOT NULL,
  body text COLLATE "vi-x-icu" NOT NULL,
  dining_table_id bigint,
  reply_to_message_id bigint,
  submission_code text COLLATE "C" NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT station_message_pkey PRIMARY KEY (id),
  CONSTRAINT station_message_sender_person_fkey FOREIGN KEY (sender_person_id) REFERENCES person (id),
  CONSTRAINT station_message_recipient_person_fkey FOREIGN KEY (recipient_person_id) REFERENCES person (id),
  CONSTRAINT station_message_dining_table_fkey FOREIGN KEY (dining_table_id) REFERENCES dining_table (id),
  CONSTRAINT station_message_reply_to_message_fkey FOREIGN KEY (reply_to_message_id) REFERENCES station_message (id),
  CONSTRAINT station_message_different_people_check CHECK (sender_person_id <> recipient_person_id),
  CONSTRAINT station_message_work_code_check CHECK (work_code IN ('canh', 'don_ban', 'trang_banh', 'gap_banh', 'khac')),
  CONSTRAINT station_message_body_check CHECK (char_length(body) BETWEEN 1 AND 500 AND body ~ '[^[:space:]]'),
  CONSTRAINT station_message_submission_code_check CHECK (submission_code ~ '[^[:space:]]'),
  CONSTRAINT station_message_submission_code_key UNIQUE (submission_code)
);

-- QD-52: chủ lược đồ sửa tay vẫn có vết; vai ứng dụng chỉ được thêm.
CREATE TRIGGER station_message_record_revision_trg AFTER UPDATE ON station_message
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
-- QC-03 đã cấp SELECT, INSERT và quyền sequence; thu hồi quyền sửa mặc định.
REVOKE UPDATE, DELETE ON station_message FROM shop_app;
