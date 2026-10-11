SELECT id, status FROM sales_order
WHERE channel_code = 'phone_preorder' AND status = 'confirmed'
  AND customer_needed_at - interval '20 minutes' <= $1
ORDER BY customer_needed_at, id
FOR UPDATE SKIP LOCKED
