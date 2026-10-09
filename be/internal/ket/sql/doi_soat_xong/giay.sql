SELECT EXISTS (SELECT 1 FROM paper_ledger p WHERE p.sale_date = $1::date
 AND p.entry_count > (SELECT count(*) FROM bill b WHERE b.paper_ledger_id = p.id))
