-- T-267 — ADR-132, I-035; ý định: 24-luoc-do-khach-google.md.
CREATE TABLE customer_google_identity (
  id bigint GENERATED ALWAYS AS IDENTITY,
  customer_account_id bigint NOT NULL,
  google_sub_code text COLLATE "C" NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT customer_google_identity_pkey PRIMARY KEY (id),
  CONSTRAINT customer_google_identity_account_fkey FOREIGN KEY (customer_account_id) REFERENCES customer_account (id),
  CONSTRAINT customer_google_identity_account_key UNIQUE (customer_account_id),
  CONSTRAINT customer_google_identity_sub_key UNIQUE (google_sub_code),
  CONSTRAINT customer_google_identity_sub_check CHECK (btrim(google_sub_code) <> '' AND length(google_sub_code) <= 255)
);
CREATE TRIGGER customer_google_identity_record_revision_trg AFTER UPDATE ON customer_google_identity
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
REVOKE UPDATE ON customer_google_identity FROM shop_app;
