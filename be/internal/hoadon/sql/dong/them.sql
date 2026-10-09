INSERT INTO bill (table_session_id, due_vnd, cash_vnd, transfer_vnd, debt_vnd, debtor_name)
VALUES ($1,$2,$3,$4,$5,$6) RETURNING id
