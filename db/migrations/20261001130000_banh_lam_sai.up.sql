-- T-127 — ghi chú bánh làm sai của đơn đã huỷ (docs/decisions.md ADR-077).
-- Ý định và bằng chứng: docs/product/2-db/05-luoc-do-san-xuat.md.
-- Không bàn nào chờ đúng thứ ấy là quyết định của người đứng quầy (tầng 4).

-- Đơn đã huỷ chưa — đích khoá ngoại của ghi chú. Tự tính, cùng hình id_if_approved (P2-07): trống
-- khi đơn chưa Huỷ, nên ghi chú chỉ đứng tên một đơn đã Huỷ, và đơn đã có ghi chú không rời Huỷ.
ALTER TABLE sales_order
  ADD COLUMN id_if_cancelled bigint
    GENERATED ALWAYS AS (CASE WHEN status = 'cancelled' THEN id END) STORED,
  ADD CONSTRAINT sales_order_id_if_cancelled_key UNIQUE (id_if_cancelled);
ALTER TABLE station_job
  ADD CONSTRAINT station_job_id_order_key UNIQUE (id, sales_order_id);

CREATE TABLE wrong_make_note (
  id                     bigint GENERATED ALWAYS AS IDENTITY,
  station_job_id         bigint NOT NULL,
  sales_order_id         bigint NOT NULL,
  live_station_job_id    bigint GENERATED ALWAYS AS
    (CASE WHEN cancelled_at IS NULL THEN station_job_id END) STORED,
  note                   text COLLATE "vi-x-icu",
  person_id              bigint NOT NULL DEFAULT actor_person_id(),
  created_at             timestamptz NOT NULL DEFAULT now(),
  cancelled_at           timestamptz,
  cancelled_by_person_id bigint,
  CONSTRAINT wrong_make_note_pkey PRIMARY KEY (id),
  CONSTRAINT wrong_make_note_note_not_blank_check CHECK (note IS NULL OR btrim(note) <> ''),
  CONSTRAINT wrong_make_note_station_job_order_fkey
    FOREIGN KEY (station_job_id, sales_order_id) REFERENCES station_job (id, sales_order_id),
  CONSTRAINT wrong_make_note_cancelled_order_fkey
    FOREIGN KEY (sales_order_id) REFERENCES sales_order (id_if_cancelled),
  CONSTRAINT wrong_make_note_live_station_job_fkey
    FOREIGN KEY (live_station_job_id) REFERENCES station_job (id_if_made_or_served),
  CONSTRAINT wrong_make_note_live_key UNIQUE (live_station_job_id),
  CONSTRAINT wrong_make_note_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT wrong_make_note_cancelled_by_person_fkey
    FOREIGN KEY (cancelled_by_person_id) REFERENCES person (id),
  CONSTRAINT wrong_make_note_cancelled_by_iff_cancelled_check
    CHECK ((cancelled_at IS NULL) = (cancelled_by_person_id IS NULL)),
  CONSTRAINT wrong_make_note_cancelled_after_created_check
    CHECK (cancelled_at IS NULL OR cancelled_at >= created_at)
);

-- QD-52: dùng cơ chế vết hiện hành; cửa huỷ khai lý do để chụp bản trước và bản sau.
CREATE TRIGGER wrong_make_note_record_revision_trg AFTER UPDATE ON wrong_make_note
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();

-- Ghi chú đã ghi chỉ huỷ tại chỗ; dòng ở lại (QD-50).
REVOKE UPDATE ON wrong_make_note FROM shop_app;
GRANT UPDATE (cancelled_at, cancelled_by_person_id) ON wrong_make_note TO shop_app;
