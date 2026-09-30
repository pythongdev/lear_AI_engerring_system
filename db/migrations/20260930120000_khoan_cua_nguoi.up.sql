-- P2A-04 — lát khoản của người: tạm ứng và thưởng lễ Tết.
-- Ý định, lý do và ánh xạ I-028/YC-31/YC-32: docs/product/2-db/14-luoc-do-khoan-cua-nguoi.md.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
-- Thiết kế: ADR-073; quy ước: 01-quy-uoc-du-lieu.md (QD-XX) · 10-quy-uoc-code.md (QC-XX).

CREATE TABLE staff_advance (
  id                 bigint GENERATED ALWAYS AS IDENTITY,
  worker_person_id   bigint NOT NULL,
  amount_vnd         bigint NOT NULL,
  paid_date          date NOT NULL,
  approver_person_id bigint NOT NULL,
  person_id          bigint NOT NULL DEFAULT actor_person_id(),
  created_at         timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT staff_advance_pkey PRIMARY KEY (id),
  CONSTRAINT staff_advance_worker_person_fkey FOREIGN KEY (worker_person_id) REFERENCES person (id),
  CONSTRAINT staff_advance_approver_person_fkey FOREIGN KEY (approver_person_id) REFERENCES person (id),
  CONSTRAINT staff_advance_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT staff_advance_positive_amount_check CHECK (amount_vnd > 0)
);

CREATE TABLE holiday_bonus (
  id               bigint GENERATED ALWAYS AS IDENTITY,
  worker_person_id bigint NOT NULL,
  amount_vnd       bigint NOT NULL,
  paid_date        date NOT NULL,
  person_id        bigint NOT NULL DEFAULT actor_person_id(),
  created_at       timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT holiday_bonus_pkey PRIMARY KEY (id),
  CONSTRAINT holiday_bonus_worker_person_fkey FOREIGN KEY (worker_person_id) REFERENCES person (id),
  CONSTRAINT holiday_bonus_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT holiday_bonus_positive_amount_check CHECK (amount_vnd > 0)
);

-- Dùng nguyên cơ chế vết của P2-08 (QD-52), kể cả chế độ mềm F-046.
CREATE TRIGGER staff_advance_record_revision_trg AFTER UPDATE ON staff_advance
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
CREATE TRIGGER holiday_bonus_record_revision_trg AFTER UPDATE ON holiday_bonus
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();

-- ADR-073 điểm 6: chỉ sửa ba dấu I-028 cho phép; quyền chèn được cấp sẵn,
-- quyền xoá không được cấp (QD-50).
REVOKE UPDATE ON staff_advance, holiday_bonus FROM shop_app;
GRANT UPDATE (worker_person_id, amount_vnd, paid_date) ON staff_advance TO shop_app;
GRANT UPDATE (worker_person_id, amount_vnd, paid_date) ON holiday_bonus TO shop_app;
