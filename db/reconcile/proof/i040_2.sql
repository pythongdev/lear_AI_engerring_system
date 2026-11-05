-- kêu: I-040/2
ALTER TABLE model_call ADD CONSTRAINT model_call_person_fkey
  FOREIGN KEY (id) REFERENCES person (id);
