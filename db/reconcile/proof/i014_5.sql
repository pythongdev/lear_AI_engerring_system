-- kêu: I-014/5
-- Ngày mẫu đã bấm đối soát xong; sau đó POS khai sổ giấy hai lượt của chính ngày ấy mà chưa nhập
-- lượt nào (ADR-037: ngày còn N > 0 là ngày CHƯA đối soát xong).
INSERT INTO paper_ledger (sale_date, entry_count) VALUES (pg_temp.bc_ngay(), 2);
