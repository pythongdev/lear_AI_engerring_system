-- T-197, ADR-121 điểm 1: mỗi lần POS khai một dòng, vai ứng dụng chỉ thêm.
CREATE TABLE workers_present_declaration (
  id bigint GENERATED ALWAYS AS IDENTITY,
  sale_date date NOT NULL,
  worker_count integer NOT NULL,
  person_id bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT workers_present_declaration_pkey PRIMARY KEY (id),
  CONSTRAINT workers_present_declaration_person_fkey FOREIGN KEY (person_id) REFERENCES person (id),
  CONSTRAINT workers_present_declaration_count_positive_check CHECK (worker_count > 0)
);
CREATE TRIGGER workers_present_declaration_record_revision_trg AFTER UPDATE ON workers_present_declaration
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE, DELETE ON workers_present_declaration FROM shop_app;
