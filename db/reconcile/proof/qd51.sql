-- kêu: QD-51
-- Một khoá ngoại xoá dây chuyền.
ALTER TABLE order_line DROP CONSTRAINT order_line_sales_order_fkey;
ALTER TABLE order_line ADD CONSTRAINT order_line_sales_order_fkey
  FOREIGN KEY (sales_order_id) REFERENCES sales_order (id) ON DELETE CASCADE;
