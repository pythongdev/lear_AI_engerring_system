-- P2A-03 — lát chấm công: một ô có đi làm của một người một ngày.
-- Ý định, lý do và ánh xạ I-027/YC-30: docs/product/2-db/13-luoc-do-cham-cong.md.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
-- Thiết kế: ADR-072; quy ước: 01-quy-uoc-du-lieu.md (QD-XX) · 10-quy-uoc-code.md (QC-XX).

CREATE TABLE attendance_day (
  id                     bigint GENERATED ALWAYS AS IDENTITY,
  worker_person_id       bigint NOT NULL,
  work_date              date NOT NULL,
  person_id              bigint NOT NULL DEFAULT actor_person_id(),
  created_at             timestamptz NOT NULL DEFAULT now(),
  cancelled_at           timestamptz,
  cancelled_by_person_id bigint,
  cancel_note            text COLLATE "vi-x-icu",
  CONSTRAINT attendance_day_pkey PRIMARY KEY (id),
  CONSTRAINT attendance_day_worker_person_fkey FOREIGN KEY (worker_person_id) REFERENCES person (id),
  CONSTRAINT attendance_day_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT attendance_day_cancelled_by_person_fkey
    FOREIGN KEY (cancelled_by_person_id) REFERENCES person (id),
  CONSTRAINT attendance_day_cancelled_by_iff_cancelled_check
    CHECK ((cancelled_at IS NULL) = (cancelled_by_person_id IS NULL)),
  CONSTRAINT attendance_day_cancelled_after_created_check
    CHECK (cancelled_at IS NULL OR cancelled_at >= created_at),
  CONSTRAINT attendance_day_cancel_note_only_when_cancelled_check
    CHECK (cancel_note IS NULL OR (cancelled_at IS NOT NULL AND btrim(cancel_note) <> ''))
);

-- Một người, một ngày, nhiều nhất một ô CÒN HIỆU LỰC: ô đã huỷ ở lại làm vết và không chặn lần
-- tick lại (ADR-072 điểm 4).
CREATE UNIQUE INDEX attendance_day_one_live_per_worker_day_key
  ON attendance_day (worker_person_id, work_date) WHERE cancelled_at IS NULL;

-- Dùng lại cơ chế vết của P2-08 cho lần sửa bằng tay ngoài vai ghi (QD-52; chế độ mềm F-046).
CREATE TRIGGER attendance_day_record_revision_trg AFTER UPDATE ON attendance_day
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();

-- ADR-072 điểm 4: vai ghi tick được và HUỶ được một ô (ba cột của lần huỷ); không đổi được người
-- hay ngày của ô; quyền xoá không được cấp sẵn (QD-50).
REVOKE UPDATE ON attendance_day FROM shop_app;
GRANT UPDATE (cancelled_at, cancelled_by_person_id, cancel_note) ON attendance_day TO shop_app;
