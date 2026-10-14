-- P2A-11 — giao việc và các sự kiện đánh dấu (I-030 · YC-35, ADR-105).
-- Ý định và ánh xạ: docs/product/2-db/16-luoc-do-giao-viec.md.
CREATE TABLE assigned_task (
  id bigint GENERATED ALWAYS AS IDENTITY,
  content text COLLATE "vi-x-icu" NOT NULL,
  assignee_person_id bigint NOT NULL,
  person_id bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  hidden_at timestamptz,
  hidden_by_person_id bigint,
  CONSTRAINT assigned_task_pkey PRIMARY KEY (id),
  CONSTRAINT assigned_task_content_check CHECK (btrim(content) <> ''),
  CONSTRAINT assigned_task_assignee_person_fkey FOREIGN KEY (assignee_person_id) REFERENCES person (id),
  CONSTRAINT assigned_task_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT assigned_task_hidden_by_person_fkey FOREIGN KEY (hidden_by_person_id) REFERENCES person (id),
  CONSTRAINT assigned_task_hidden_by_iff_hidden_check
    CHECK ((hidden_at IS NULL) = (hidden_by_person_id IS NULL)),
  CONSTRAINT assigned_task_hidden_after_created_check CHECK (hidden_at IS NULL OR hidden_at >= created_at)
);

CREATE TABLE assigned_task_mark (
  id bigint GENERATED ALWAYS AS IDENTITY,
  assigned_task_id bigint NOT NULL,
  mark_code text NOT NULL,
  person_id bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT assigned_task_mark_pkey PRIMARY KEY (id),
  CONSTRAINT assigned_task_mark_assigned_task_fkey FOREIGN KEY (assigned_task_id) REFERENCES assigned_task (id),
  CONSTRAINT assigned_task_mark_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT assigned_task_mark_mark_code_check CHECK (mark_code IN ('done', 'undone'))
);

-- QD-52: cả sự kiện cũng giữ vết khi chủ lược đồ sửa tay.
CREATE TRIGGER assigned_task_record_revision_trg AFTER UPDATE ON assigned_task
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
CREATE TRIGGER assigned_task_mark_record_revision_trg AFTER UPDATE ON assigned_task_mark
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();

-- Quyền xoá không được cấp sẵn (QD-50); khoá ngoại không dây chuyền (QD-51).
REVOKE UPDATE ON assigned_task FROM shop_app;
GRANT UPDATE (content, assignee_person_id, hidden_at, hidden_by_person_id) ON assigned_task TO shop_app;
REVOKE UPDATE ON assigned_task_mark FROM shop_app;
