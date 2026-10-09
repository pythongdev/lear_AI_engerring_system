SELECT use_no, cash_after_vnd, transfer_after_vnd
FROM prepayment_use WHERE prepayment_id = $1 ORDER BY use_no DESC LIMIT 1
