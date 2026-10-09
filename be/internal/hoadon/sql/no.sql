SELECT b.id, b.debtor_name, b.debt_vnd, coalesce(d.remaining_vnd,b.debt_vnd)
FROM bill b LEFT JOIN LATERAL (
 SELECT min(remaining_vnd) AS remaining_vnd FROM debt_collection WHERE bill_id = b.id
) d ON true WHERE coalesce(d.remaining_vnd,b.debt_vnd) > 0 ORDER BY b.id
