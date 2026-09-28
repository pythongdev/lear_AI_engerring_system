-- I-016 (tầng 3): phần lược đồ nợ — trạng thái ngoài bảng §5 không ghi được, và
-- "phiên đã đóng chưa" chỉ có MỘT đường ghi (status). Tra bảng chuyển tiếp là
-- việc của hàm xác thực ở pha 3. Lát: 02-luoc-do-ban-hang.md.
DO $$
DECLARE s1 bigint;
BEGIN
  BEGIN
    -- Đủ liên hệ của I-022 (T-111): lời từ chối phải đến từ sales_order_status_check.
    INSERT INTO sales_order (channel_code, status, handover_code, customer_phone, customer_needed_at)
    VALUES ('pickup', 'reopened', 'shop_pickup', '0900000000', now());
    RAISE EXCEPTION 'I-016: database KHÔNG từ chối trạng thái đơn ngoài §5.2';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-016 bị từ chối (trạng thái đơn ngoài §5.2): %', SQLERRM;
  END;
  INSERT INTO table_session (status) VALUES ('open') RETURNING id INTO s1;
  BEGIN
    UPDATE table_session SET status = 'paid' WHERE id = s1;
    RAISE EXCEPTION 'I-016: database KHÔNG từ chối trạng thái phiên ngoài §5.3';
  EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'I-016 bị từ chối (trạng thái phiên ngoài §5.3): %', SQLERRM;
  END;
  BEGIN
    UPDATE table_session SET is_closed = true WHERE id = s1;
    RAISE EXCEPTION 'I-016: database KHÔNG từ chối ghi tay is_closed';
  EXCEPTION WHEN generated_always THEN
    RAISE NOTICE 'I-016 bị từ chối (đường ghi thứ hai tới "đã đóng"): %', SQLERRM;
  END;
END $$;
