-- T-111 — liên hệ tối thiểu của đơn mang đi (I-022, YC-22), thêm vào lát bán hàng lõi.
-- Ý định, lý do và ánh xạ: docs/product/2-db/02-luoc-do-ban-hang.md §2 hàng I-022.
-- File này thắng về tên · kiểu · ràng buộc (docs/decisions.md ADR-053 luật 2).
-- Quy ước: docs/product/2-db/01-quy-uoc-du-lieu.md (QD-XX) · 10-quy-uoc-code.md (QC-XX).
-- Bảng trường nào bắt buộc ở kênh nào: master_plan/shop-facts.md §6 quy tắc 5 — không chép ở đây.

-- Liên hệ nằm TRÊN đơn, không ở bảng riêng: cả năm vế tầng 1 là điều kiện đọc trên
-- chính một đơn (kênh · cách trao hàng · trường có mặt), và một ràng buộc kiểm không
-- đọc được bảng khác. Kênh gắn bàn để trống mọi cột này — mệnh đề không áp cho chúng.
ALTER TABLE sales_order
  -- Cách trao hàng: giao tận nơi hay tới lấy. Với delivery · pickup nó chính là kênh.
  ADD COLUMN handover_code      text,
  -- Tự tính, không ghi tay được: đường ghi duy nhất tới cách trao hàng là handover_code.
  -- Ràng buộc nhắc tới channel_code đọc cột này thay cho chuỗi mã, để mọi chuỗi trong
  -- chúng vẫn là mã kênh — phép kiểm QD-02 gom chuỗi của mọi ràng buộc trên channel_code.
  ADD COLUMN is_door_delivery   boolean GENERATED ALWAYS AS (handover_code = 'door_delivery') STORED,
  ADD COLUMN customer_phone     text COLLATE "vi-x-icu",
  ADD COLUMN delivery_address   text COLLATE "vi-x-icu",
  -- Giờ khách cần hàng: giờ hẹn lấy của pickup, mốc giờ của đơn hotline.
  ADD COLUMN customer_needed_at timestamptz,
  -- Hai trường "nên có" / "tuỳ tình huống": có chỗ cất, KHÔNG ràng buộc nào đòi.
  ADD COLUMN customer_name      text COLLATE "vi-x-icu",
  ADD COLUMN contact_note       text COLLATE "vi-x-icu";

ALTER TABLE sales_order
  ADD CONSTRAINT sales_order_handover_code_check
    CHECK (handover_code IN ('door_delivery', 'shop_pickup')),
  -- Vế "cách trao hàng của đơn hotline" và vế "Delivery là giao, Pickup là tới lấy":
  -- kênh delivery · pickup không tự chọn được nhánh; đơn hotline phải có đúng một nhánh.
  ADD CONSTRAINT sales_order_takeaway_handover_check
    -- handover_code chỉ nhận hai mã (ràng buộc trên), nên FALSE ở đây nghĩa là tới lấy.
    CHECK (CASE channel_code
             WHEN 'delivery'       THEN is_door_delivery IS TRUE
             WHEN 'pickup'         THEN is_door_delivery IS FALSE
             WHEN 'phone_preorder' THEN is_door_delivery IS NOT NULL
             ELSE true
           END),
  -- Mệnh đề nói THIẾU, không nói SAI: NULL và chuỗi trắng là thiếu (kịch bản "xoá
  -- trắng địa chỉ"), còn định dạng hay độ đúng thì không ràng buộc nào xét. Viết bằng
  -- length(...) IS TRUE chứ không bằng <> '': chuỗi rỗng trong một ràng buộc trên
  -- channel_code bị QD-02 đọc thành một mã kênh.
  ADD CONSTRAINT sales_order_takeaway_phone_check
    CHECK (channel_code NOT IN ('delivery', 'pickup', 'phone_preorder')
           OR (length(btrim(customer_phone)) > 0) IS TRUE),
  ADD CONSTRAINT sales_order_door_delivery_address_check
    CHECK (is_door_delivery IS NOT TRUE
           OR (length(btrim(delivery_address)) > 0) IS TRUE),
  ADD CONSTRAINT sales_order_takeaway_needed_at_check
    CHECK (channel_code NOT IN ('pickup', 'phone_preorder')
           OR customer_needed_at IS NOT NULL);
