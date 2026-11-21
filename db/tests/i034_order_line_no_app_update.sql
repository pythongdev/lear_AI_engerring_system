-- I-034 (tầng 1) — dòng đơn đã ghi thì vai ứng dụng không sửa được (T-341).
-- Hai luật của I-034 — dòng combo có ít nhất một suất con, dòng combo không mang lựa chọn — chỉ được trigger
-- order_line_combo_has_child_check · order_line_option_not_on_combo_check xét lúc INSERT
-- (db/migrations/20261015120000_ban_combo.up.sql). Một lệnh UPDATE đặt parent_order_line_id về NULL làm cột sinh
-- parent_is_combo_line thành NULL, khoá ngoại về dòng cha thôi xét, và không trigger nào chạy lại: dòng combo còn đó
-- mà mất suất con. ADR-117 chưa có cửa sửa dòng riêng lẻ và backend không có câu UPDATE nào trên hai bảng, nên quyền
-- sửa bị thu cho tới khi cửa ấy được thiết kế cùng trigger của nó.
-- Không thu quá tay: shop_app vẫn đọc và ghi mới được dòng đơn và lựa chọn của dòng.
-- Viết trước migration (T-341, Claude Code, 2026-11-20): đỏ cho tới khi quyền UPDATE bị thu.

DO $$
BEGIN
  -- ------------------------------------------------------------------ quyền theo danh mục
  -- has_any_column_privilege bắt cả quyền cấp cho cả bảng lẫn quyền cấp riêng theo cột.
  IF has_any_column_privilege('shop_app', 'order_line', 'UPDATE') THEN
    RAISE EXCEPTION 'I-034: vai shop_app còn quyền UPDATE trên order_line (bảng hoặc cột)';
  END IF;
  IF has_any_column_privilege('shop_app', 'order_line_option', 'UPDATE') THEN
    RAISE EXCEPTION 'I-034: vai shop_app còn quyền UPDATE trên order_line_option (bảng hoặc cột)';
  END IF;
  IF NOT has_table_privilege('shop_app', 'order_line', 'SELECT')
     OR NOT has_table_privilege('shop_app', 'order_line', 'INSERT')
     OR NOT has_table_privilege('shop_app', 'order_line_option', 'SELECT')
     OR NOT has_table_privilege('shop_app', 'order_line_option', 'INSERT') THEN
    RAISE EXCEPTION 'T-341: thu quá tay — shop_app mất quyền SELECT hoặc INSERT trên dòng đơn';
  END IF;
  RAISE NOTICE 'I-034 quyền: shop_app đọc · ghi mới được, không sửa được order_line · order_line_option';

  -- ------------------------------------------------------------------ hành vi: lệnh sửa bị từ chối
  -- Quyền được xét lúc lập kế hoạch câu lệnh, nên WHERE false vẫn bị từ chối mà không cần dựng dữ liệu.
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE order_line SET parent_order_line_id = NULL WHERE false;
    RAISE EXCEPTION 'I-034: vai shop_app tách được suất con khỏi dòng combo (UPDATE order_line.parent_order_line_id)';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-034 tách suất con khỏi combo bị từ chối (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE order_line SET quantity = quantity WHERE false;
    RAISE EXCEPTION 'I-034: vai shop_app sửa được dòng đơn đã ghi (UPDATE order_line)';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-034 sửa dòng đơn bị từ chối (shop_app): %', SQLERRM;
  END;
  BEGIN
    SET LOCAL ROLE shop_app;
    UPDATE order_line_option SET order_line_id = order_line_id WHERE false;
    RAISE EXCEPTION 'I-034: vai shop_app chuyển được lựa chọn sang dòng khác, kể cả dòng combo (UPDATE order_line_option)';
  EXCEPTION WHEN insufficient_privilege THEN
    RAISE NOTICE 'I-034 chuyển lựa chọn sang dòng khác bị từ chối (shop_app): %', SQLERRM;
  END;
END $$;
