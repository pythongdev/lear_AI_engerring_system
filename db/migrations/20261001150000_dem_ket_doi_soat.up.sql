-- T-133 — số tiền mặt đếm được cuối ngày và dấu ngày đã đối soát xong (F-048; docs/decisions.md ADR-079).
-- Ý định, lý do và ánh xạ I-012 · I-014 · I-021: docs/product/2-db/04-luoc-do-duong-tien.md §7.
-- File này thắng về tên · kiểu · ràng buộc (ADR-053 luật 2).

-- Số đếm cuối ngày: cùng hình tiền đầu két (opening_float) — mỗi ngày bán một lần đếm, mỗi dòng một
-- mệnh giá, con số của ngày là TỔNG các dòng, không ô tổng thứ hai (shop-facts §8.5, lời đóng U-038).
-- Đếm là việc của người: con số là số đếm thật hay không, máy không biết (I-021 tầng 4).
CREATE TABLE cash_count (
  id         bigint GENERATED ALWAYS AS IDENTITY,
  sale_date  date NOT NULL,
  person_id  bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT cash_count_pkey PRIMARY KEY (id),
  CONSTRAINT cash_count_one_per_day_key UNIQUE (sale_date),
  CONSTRAINT cash_count_person_fkey FOREIGN KEY (person_id) REFERENCES person (id)
);

CREATE TABLE cash_count_line (
  id               bigint GENERATED ALWAYS AS IDENTITY,
  cash_count_id    bigint NOT NULL,
  denomination_vnd bigint NOT NULL,
  amount_vnd       bigint NOT NULL,
  created_at       timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT cash_count_line_pkey PRIMARY KEY (id),
  CONSTRAINT cash_count_line_cash_count_fkey FOREIGN KEY (cash_count_id) REFERENCES cash_count (id),
  CONSTRAINT cash_count_line_one_per_denomination_key UNIQUE (cash_count_id, denomination_vnd),
  -- Một dòng là một xấp tiền cùng mệnh giá: số tiền là bội của mệnh giá.
  CONSTRAINT cash_count_line_amount_check
    CHECK (denomination_vnd > 0 AND amount_vnd >= 0 AND amount_vnd % denomination_vnd = 0)
);

-- Dấu ngày đã đối soát xong: mỗi ngày nhiều nhất một dấu, người bấm và lúc bấm. Ngày thiếu tiền đầu
-- két hay thiếu số đếm thì phép trừ két không chạy được, nên ngày ấy CHƯA đối soát xong (I-021 điều
-- kiện biên thứ nhất, ADR-037) — hai khoá ngoại làm trạng thái ấy không tồn tại được. Còn lượt sổ
-- giấy chưa nhập là một phép trừ qua nhiều dòng: câu đối chiếu I-014/5 giữ, không ràng buộc nào.
-- Dấu không đòi phép trừ ra 0: ngày lệch mà đã tìm ra lý do có đóng được không là U-073.
CREATE TABLE reconciled_day (
  id         bigint GENERATED ALWAYS AS IDENTITY,
  sale_date  date NOT NULL,
  person_id  bigint NOT NULL DEFAULT actor_person_id(),
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT reconciled_day_pkey PRIMARY KEY (id),
  CONSTRAINT reconciled_day_one_per_day_key UNIQUE (sale_date),
  CONSTRAINT reconciled_day_cash_count_fkey FOREIGN KEY (sale_date) REFERENCES cash_count (sale_date),
  CONSTRAINT reconciled_day_opening_float_fkey FOREIGN KEY (sale_date) REFERENCES opening_float (sale_date),
  CONSTRAINT reconciled_day_person_fkey FOREIGN KEY (person_id) REFERENCES person (id)
);

-- QD-52: trigger vết như mọi bảng — đếm lại một xấp là một lần sửa có bản trước, bản sau (I-018).
CREATE TRIGGER cash_count_record_revision_trg AFTER UPDATE ON cash_count
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
CREATE TRIGGER cash_count_line_record_revision_trg AFTER UPDATE ON cash_count_line
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();
CREATE TRIGGER reconciled_day_record_revision_trg AFTER UPDATE ON reconciled_day
  FOR EACH ROW EXECUTE FUNCTION record_revision_capture();

-- Dấu đối soát xong đã bấm không dời, không đổi người; dòng ở lại (QD-50).
REVOKE UPDATE ON reconciled_day FROM shop_app;
