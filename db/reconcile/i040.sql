-- CHAT-35 — I-040, ADR-139; mỗi tập phải rỗng.

-- @@ I-040/1 — tháng theo giờ Việt Nam vượt trần, dòng treo tính bằng giữ chỗ
SELECT date_trunc('month', created_at AT TIME ZONE 'Asia/Ho_Chi_Minh') AS month,
       sum(coalesce(cost_microusd, reserved_microusd)) AS total_microusd
FROM model_call
GROUP BY 1
HAVING sum(coalesce(cost_microusd, reserved_microusd)) > 10000000

-- @@ I-040/2 — sổ gọi model có khoá ngoại
SELECT conname FROM pg_constraint
WHERE contype = 'f' AND conrelid = 'shop.model_call'::regclass

-- @@ I-040/3 — vai ghi có quyền xoá hoặc ghi cột ngoài danh sách
SELECT 'model_call' AS table_name
WHERE has_table_privilege('shop_app', 'shop.model_call', 'DELETE')
   OR EXISTS (SELECT 1 FROM information_schema.columns c
              WHERE c.table_schema = 'shop' AND c.table_name = 'model_call'
                AND ((c.column_name NOT IN ('provider_code', 'model_code', 'reserved_microusd')
                      AND has_column_privilege('shop_app', 'shop.model_call', c.column_name, 'INSERT'))
                  OR (c.column_name NOT IN ('settled_at', 'input_token_count', 'output_token_count', 'cost_microusd')
                      AND has_column_privilege('shop_app', 'shop.model_call', c.column_name, 'UPDATE'))))

-- @@ I-040/4 — dòng đã chốt thiếu chi phí hoặc chốt trước giữ chỗ
SELECT id FROM model_call
WHERE settled_at IS NOT NULL AND (settled_at < created_at OR cost_microusd IS NULL)
