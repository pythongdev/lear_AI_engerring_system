-- tu-choi: QD-21
-- Nội dung "≥ 0" của QD-21 (01-quy-uoc-du-lieu.md): câu kiểm của QD-21 chỉ chứng minh CÓ một ràng
-- buộc kiểm trên mỗi cột tiền; file này chứng minh ràng buộc ấy TỪ CHỐI số âm. Trên ngày bán mẫu,
-- mỗi cột _vnd không tự tính của mọi bảng nhận -1 ở một dòng thật, trong một khối tự rollback: phải
-- bị từ chối bởi một ràng buộc kiểm có nhắc CHÍNH cột ấy (ràng buộc kiểm được xét theo thứ tự tên,
-- nên một ràng buộc tổng khớp đứng trước không được tính thay). Không phải một câu truy vấn của bộ
-- đối chiếu: nó là lời từ chối (QC-07), chạy một lần trong scripts/db-check.sh bước 6.
DO $$
DECLARE c record; r bigint; n integer := 0; rb text; def text;
BEGIN
  FOR c IN
    SELECT table_name, column_name FROM information_schema.columns
    WHERE table_schema = 'shop' AND column_name LIKE '%\_vnd' AND is_generated = 'NEVER'
    ORDER BY 1, 2
  LOOP
    EXECUTE format('SELECT min(id) FROM %I', c.table_name) INTO r;
    IF r IS NULL THEN
      RAISE EXCEPTION 'QD-21: %.% — ngày mẫu không có dòng nào để thử', c.table_name, c.column_name;
    END IF;
    BEGIN
      EXECUTE format('UPDATE %I SET %I = -1 WHERE id = %s', c.table_name, c.column_name, r);
      RAISE EXCEPTION 'QD-21: %.% nhận -1 — database KHÔNG từ chối', c.table_name, c.column_name
        USING ERRCODE = 'P0001';
    EXCEPTION WHEN check_violation THEN
      GET STACKED DIAGNOSTICS rb = CONSTRAINT_NAME;
      SELECT pg_get_constraintdef(oid) INTO def FROM pg_constraint
       WHERE conname = rb AND connamespace = 'shop'::regnamespace;
      -- Ràng buộc từ chối phải nhắc chính cột ấy, hoặc một cột tự tính dựng từ nó (thành tiền =
      -- đơn giá × số lượng: ràng buộc của thành tiền đứng trước theo tên và từ chối trước).
      IF def IS NULL OR NOT EXISTS (
           SELECT 1 FROM information_schema.columns g
           WHERE g.table_schema = 'shop' AND g.table_name = c.table_name
             AND def ~ ('\m' || g.column_name || '\M')
             AND (g.column_name = c.column_name
                  OR g.generation_expression ~ ('\m' || c.column_name || '\M'))) THEN
        RAISE EXCEPTION 'QD-21: %.% = -1 bị từ chối bởi % — ràng buộc ấy không nhắc cột này', c.table_name,
          c.column_name, rb;
      END IF;
      n := n + 1;
    END;
  END LOOP;
  RAISE NOTICE 'QD-21 nội dung: % cột tiền, cột nào nhận -1 cũng bị một ràng buộc nhắc chính nó (hay cột tự tính dựng từ nó) từ chối', n;
END $$;
