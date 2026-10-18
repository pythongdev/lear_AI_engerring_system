-- T-199, ADR-118 điểm 1 theo phiếu Claude 2026-10-18.
CREATE TABLE daily_minimum (
  id bigint GENERATED ALWAYS AS IDENTITY,
  sale_date date NOT NULL,
  minimum_banh integer NOT NULL,
  minimum_workers integer NOT NULL,
  person_id bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT daily_minimum_pkey PRIMARY KEY (id),
  CONSTRAINT daily_minimum_sale_date_key UNIQUE (sale_date),
  CONSTRAINT daily_minimum_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT daily_minimum_banh_positive_check CHECK (minimum_banh > 0),
  CONSTRAINT daily_minimum_workers_positive_check CHECK (minimum_workers > 0)
);
CREATE TRIGGER daily_minimum_record_revision_trg AFTER UPDATE ON daily_minimum
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE, DELETE ON daily_minimum FROM shop_app;
GRANT UPDATE (minimum_banh, minimum_workers) ON daily_minimum TO shop_app;
