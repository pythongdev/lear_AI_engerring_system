-- P2A-12 — hướng dẫn công việc và ghi nhận đào tạo (I-031 · YC-36, ADR-107).
-- Ý định và ánh xạ: docs/product/2-db/17-luoc-do-dao-tao.md.
CREATE TABLE assigned_task_guide (
  id bigint GENERATED ALWAYS AS IDENTITY,
  assigned_task_id bigint NOT NULL,
  guide_kind_code text NOT NULL,
  body text COLLATE "vi-x-icu",
  file_code text COLLATE "C",
  person_id bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  hidden_at timestamptz,
  hidden_by_person_id bigint,
  CONSTRAINT assigned_task_guide_pkey PRIMARY KEY (id),
  CONSTRAINT assigned_task_guide_assigned_task_fkey FOREIGN KEY (assigned_task_id) REFERENCES assigned_task (id),
  CONSTRAINT assigned_task_guide_guide_kind_code_check CHECK (guide_kind_code IN ('text', 'image', 'video')),
  CONSTRAINT assigned_task_guide_content_check CHECK (
    (guide_kind_code = 'text' AND body IS NOT NULL AND btrim(body) <> '' AND file_code IS NULL)
    OR (guide_kind_code IN ('image', 'video') AND file_code IS NOT NULL AND body IS NULL)),
  CONSTRAINT assigned_task_guide_file_code_check
    CHECK (file_code IS NULL OR (file_code ~ '^[a-z0-9][a-z0-9._/-]{0,254}$' AND position('..' IN file_code) = 0)),
  CONSTRAINT assigned_task_guide_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT assigned_task_guide_hidden_by_person_fkey FOREIGN KEY (hidden_by_person_id) REFERENCES person (id),
  CONSTRAINT assigned_task_guide_hidden_by_iff_hidden_check
    CHECK ((hidden_at IS NULL) = (hidden_by_person_id IS NULL)),
  CONSTRAINT assigned_task_guide_hidden_after_created_check CHECK (hidden_at IS NULL OR hidden_at >= created_at)
);

CREATE TABLE training_record (
  id bigint GENERATED ALWAYS AS IDENTITY,
  trainee_person_id bigint NOT NULL,
  remark text COLLATE "vi-x-icu",
  rating_code text,
  person_id bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  hidden_at timestamptz,
  hidden_by_person_id bigint,
  CONSTRAINT training_record_pkey PRIMARY KEY (id),
  CONSTRAINT training_record_trainee_person_fkey FOREIGN KEY (trainee_person_id) REFERENCES person (id),
  CONSTRAINT training_record_remark_check CHECK (remark IS NULL OR btrim(remark) <> ''),
  CONSTRAINT training_record_rating_code_check CHECK (rating_code IN ('pass', 'not_yet')),
  CONSTRAINT training_record_not_empty_check CHECK (remark IS NOT NULL OR rating_code IS NOT NULL),
  CONSTRAINT training_record_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT training_record_hidden_by_person_fkey FOREIGN KEY (hidden_by_person_id) REFERENCES person (id),
  CONSTRAINT training_record_hidden_by_iff_hidden_check
    CHECK ((hidden_at IS NULL) = (hidden_by_person_id IS NULL)),
  CONSTRAINT training_record_hidden_after_created_check CHECK (hidden_at IS NULL OR hidden_at >= created_at)
);

-- QD-52: dùng vết chung; ai được ghi thuộc tầng 3 (ADR-105 điểm 1).
CREATE TRIGGER assigned_task_guide_record_revision_trg AFTER UPDATE ON assigned_task_guide
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
CREATE TRIGGER training_record_record_revision_trg AFTER UPDATE ON training_record
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();

-- QD-50: quyền mặc định không cấp xoá; QD-51: khoá ngoại không dây chuyền.
REVOKE UPDATE ON assigned_task_guide FROM shop_app;
GRANT UPDATE (body, file_code, hidden_at, hidden_by_person_id) ON assigned_task_guide TO shop_app;
REVOKE UPDATE ON training_record FROM shop_app;
GRANT UPDATE (remark, rating_code, hidden_at, hidden_by_person_id) ON training_record TO shop_app;
