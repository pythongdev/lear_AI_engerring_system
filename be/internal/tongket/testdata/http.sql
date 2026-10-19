DO $$
DECLARE p bigint; s bigint; ledger bigint;
BEGIN
 SELECT id INTO p FROM person WHERE display_name='test-p3a10-http-owner';
 PERFORM set_config('shop.actor_person_id',p::text,true);
 INSERT INTO paper_ledger(sale_date,entry_count) VALUES('2185-01-02',3) RETURNING id INTO ledger;
 INSERT INTO table_session(status) VALUES('closed') RETURNING id INTO s;
 INSERT INTO bill(table_session_id,due_vnd,cash_vnd,sale_date,booked_at,paper_ledger_id,paper_entry_count,paper_position)
 VALUES(s,100,100,'2185-01-02','2185-01-02T08:00:00+07',ledger,3,1);
END $$;
DO $$
DECLARE p bigint; r bigint; c bigint; f bigint; d date;
BEGIN
 SELECT id INTO p FROM person WHERE display_name='test-p3a10-http-owner';
 PERFORM set_config('shop.actor_person_id',p::text,true);
 FOREACH d IN ARRAY ARRAY['2185-02-01'::date,'2185-02-02'::date] LOOP
  INSERT INTO cash_count(sale_date) VALUES(d) RETURNING id INTO c;
  INSERT INTO cash_count_line(cash_count_id,denomination_vnd,amount_vnd) VALUES(c,1000,0);
  INSERT INTO opening_float(sale_date) VALUES(d) RETURNING id INTO f;
  INSERT INTO opening_float_line(opening_float_id,denomination_vnd,amount_vnd) VALUES(f,1000,0);
  INSERT INTO reconciled_day(sale_date,gap_vnd) VALUES(d,0) RETURNING id INTO r;
  INSERT INTO reconciled_day_reopening(reconciled_day_id,sale_date,reason) VALUES(r,d,'test-reopen');
  IF d='2185-02-01'::date THEN
   INSERT INTO reconciled_day(sale_date,gap_vnd,previous_reconciled_day_id) VALUES(d,0,r);
  END IF;
 END LOOP;
END $$;
