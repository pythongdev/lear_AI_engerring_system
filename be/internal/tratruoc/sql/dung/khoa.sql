SELECT sales_order_id, cash_vnd, transfer_vnd FROM prepayment WHERE id = $1 FOR UPDATE
