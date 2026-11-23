-- KC-02 · ADR-147 điểm 1–6, 12 · I-046: mục chi theo dõi lượng, khoản con nối đúng một thứ của sổ, một tên, ngừng dùng
-- khoá phần lượng và mở lại được, ngày nhập trên khoản chi, chuyển mục cùng khoản chi trong một giao dịch (QD-51). Claude viết TRƯỚC migration.
-- Cột theo dõi lượng còn DEFAULT false trong lúc backend cũ chưa khai nó (KC-06 bắt khai ở API).
DO $$
DECLARE actor bigint; cat_a bigint; cat_b bigint; plain bigint; s1 bigint; s2 bigint; s3 bigint;
  i1 bigint; i2 bigint; e1 bigint; e2 bigint; d1 bigint; c text;
BEGIN
 INSERT INTO person(display_name,is_owner) VALUES ('test-KC02-owner',true) RETURNING id INTO actor;
 PERFORM set_config('shop.actor_person_id',actor::text,true);
 PERFORM set_config('shop.revision_reason','test-KC02',true);

 -- Quyền: cờ không sửa được; chuyển mục, ngừng/mở lại, ngày nhập sửa được; không xoá cứng.
 IF has_column_privilege('shop_app','expense_category','tracks_supply','UPDATE') THEN
  RAISE EXCEPTION 'ADR-147.1: tracks_supply must not be updatable'; END IF;
 IF NOT has_column_privilege('shop_app','expense_item','expense_category_id','UPDATE')
 OR NOT has_column_privilege('shop_app','supply_item','deleted_at','UPDATE')
 OR NOT has_column_privilege('shop_app','supply_item','deleted_by_person_id','UPDATE')
 OR NOT has_column_privilege('shop_app','supply_item','name','UPDATE')
 OR NOT has_column_privilege('shop_app','expense','received_date','UPDATE') THEN
  RAISE EXCEPTION 'ADR-147: missing column UPDATE grant'; END IF;
 IF has_table_privilege('shop_app','supply_item','DELETE') THEN RAISE EXCEPTION 'QD-50: supply_item DELETE granted'; END IF;

 INSERT INTO expense_category(name,paid_from_till) VALUES('test-KC02-plain',false) RETURNING id INTO plain;
 IF (SELECT tracks_supply FROM expense_category WHERE id=plain) IS DISTINCT FROM false THEN
  RAISE EXCEPTION 'ADR-147.1: category without tracks_supply must read false'; END IF;
 INSERT INTO expense_category(name,paid_from_till,tracks_supply) VALUES('test-KC02-a',false,true) RETURNING id INTO cat_a;
 INSERT INTO expense_category(name,paid_from_till,tracks_supply) VALUES('test-KC02-b',false,true) RETURNING id INTO cat_b;
 INSERT INTO supply_item(name,purchase_unit) VALUES('test-KC02-gao','kg') RETURNING id INTO s1;
 INSERT INTO supply_item(name) VALUES('test-KC02-giay') RETURNING id INTO s2;
 INSERT INTO supply_item(name) VALUES('test-KC02-tui') RETURNING id INTO s3;
 INSERT INTO supply_day_entry(supply_item_id,entry_date,kind_code,entered_measure) VALUES(s1,'2026-11-20','purchased',5) RETURNING id INTO d1;

 -- Nối đúng: khoản con của mục theo dõi, cùng tên.
 INSERT INTO expense_item(expense_category_id,tracks_supply,supply_item_id,name) VALUES(cat_a,true,s1,'test-KC02-gao') RETURNING id INTO i1;
 SET CONSTRAINTS ALL IMMEDIATE; SET CONSTRAINTS ALL DEFERRED;

 BEGIN -- mục theo dõi mà không nối
  INSERT INTO expense_item(expense_category_id,tracks_supply,name) VALUES(cat_a,true,'test-KC02-khong-noi');
  RAISE EXCEPTION 'ADR-147.2: tracking item without supply_item accepted';
 EXCEPTION WHEN check_violation THEN GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
  IF c <> 'expense_item_supply_link_check' THEN RAISE EXCEPTION 'ADR-147.2: wrong constraint %', c; END IF; END;
 BEGIN -- mục thường mà có nối
  INSERT INTO expense_item(expense_category_id,tracks_supply,supply_item_id,name) VALUES(plain,false,s2,'test-KC02-giay');
  RAISE EXCEPTION 'ADR-147.2: plain item with supply_item accepted';
 EXCEPTION WHEN check_violation THEN GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
  IF c <> 'expense_item_supply_link_check' THEN RAISE EXCEPTION 'ADR-147.2: wrong constraint %', c; END IF; END;
 BEGIN -- khai cờ khác cờ của mục
  INSERT INTO expense_item(expense_category_id,tracks_supply,supply_item_id,name) VALUES(plain,true,s2,'test-KC02-giay');
  RAISE EXCEPTION 'ADR-147.2: item flag differs from category flag';
 EXCEPTION WHEN foreign_key_violation THEN GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
  IF c <> 'expense_item_category_tracks_supply_fkey' THEN RAISE EXCEPTION 'ADR-147.2: wrong constraint %', c; END IF; END;
 BEGIN -- một thứ hai khoản con (U-120 điểm a: một thứ một mục)
  INSERT INTO expense_item(expense_category_id,tracks_supply,supply_item_id,name) VALUES(cat_b,true,s1,'test-KC02-gao');
  RAISE EXCEPTION 'ADR-147.2: supply_item linked twice';
 EXCEPTION WHEN unique_violation THEN GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
  IF c <> 'expense_item_supply_item_key' THEN RAISE EXCEPTION 'ADR-147.2: wrong constraint %', c; END IF; END;

 -- Một tên (điểm 3): lệch tên bị bắt khi kiểm ràng buộc; đổi cả hai trong một giao dịch thì qua.
 BEGIN
  INSERT INTO expense_item(expense_category_id,tracks_supply,supply_item_id,name) VALUES(cat_b,true,s2,'test-KC02-ten-khac');
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE EXCEPTION 'ADR-147.3: linked item with different name accepted';
 EXCEPTION WHEN check_violation THEN GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
  IF c <> 'expense_item_supply_name_match_check' THEN RAISE EXCEPTION 'ADR-147.3: wrong constraint %', c; END IF; END;
 SET CONSTRAINTS ALL DEFERRED;
 BEGIN
  UPDATE supply_item SET name='test-KC02-gao-te' WHERE id=s1;
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE EXCEPTION 'ADR-147.3: rename of one side accepted';
 EXCEPTION WHEN check_violation THEN GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
  IF c <> 'expense_item_supply_name_match_check' THEN RAISE EXCEPTION 'ADR-147.3: wrong constraint %', c; END IF; END;
 SET CONSTRAINTS ALL DEFERRED;
 UPDATE supply_item SET name='test-KC02-gao-te' WHERE id=s1;
 UPDATE expense_item SET name='test-KC02-gao-te' WHERE id=i1;
 SET CONSTRAINTS ALL IMMEDIATE; SET CONSTRAINTS ALL DEFERRED;

 -- Ngày nhập (điểm 5): trống được, khác ngày chi được, sửa được.
 INSERT INTO expense(expense_category_id,expense_item_id,amount_vnd,paid_date,received_date) VALUES(cat_a,i1,70000,'2026-11-22','2026-11-20') RETURNING id INTO e1;
 INSERT INTO expense(expense_category_id,amount_vnd,paid_date) VALUES(plain,10000,'2026-11-22') RETURNING id INTO e2;
 IF (SELECT received_date FROM expense WHERE id=e2) IS NOT NULL THEN RAISE EXCEPTION 'ADR-147.5: received_date must default to null'; END IF;

 -- Chuyển mục (điểm 12): QD-51 cấm dây chuyền, nên khoá ngoại (khoản con, mục) của expense kiểm hoãn tới cuối giao
 -- dịch; cửa chuyển đổi khoản con và các khoản chi của nó trong cùng giao dịch. Chỉ đổi khoản con thì bị bắt.
 BEGIN
  UPDATE expense_item SET expense_category_id=cat_b WHERE id=i1;
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE EXCEPTION 'ADR-147.12: item moved without its expenses';
 EXCEPTION WHEN foreign_key_violation THEN GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
  IF c <> 'expense_item_fkey' THEN RAISE EXCEPTION 'ADR-147.12: wrong constraint %', c; END IF; END;
 SET CONSTRAINTS ALL DEFERRED;
 UPDATE expense_item SET expense_category_id=cat_b WHERE id=i1;
 UPDATE expense SET expense_category_id=cat_b WHERE expense_item_id=i1;
 SET CONSTRAINTS ALL IMMEDIATE; SET CONSTRAINTS ALL DEFERRED;
 IF (SELECT expense_category_id FROM expense WHERE id=e1) <> cat_b THEN RAISE EXCEPTION 'ADR-147.12: expense did not follow item'; END IF;
 BEGIN
  UPDATE expense_item SET expense_category_id=plain WHERE id=i1;
  RAISE EXCEPTION 'ADR-147.12: tracking item moved into plain category';
 EXCEPTION WHEN foreign_key_violation THEN NULL; END;

 -- Ngừng dùng (điểm 4): hai bên cùng lúc; khoá phần lượng; mở lại được.
 BEGIN
  UPDATE supply_item SET deleted_at=now() WHERE id=s1;
  RAISE EXCEPTION 'QD-52: stop without actor accepted';
 EXCEPTION WHEN check_violation THEN GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
  IF c <> 'supply_item_deleted_pair_check' THEN RAISE EXCEPTION 'QD-52: wrong constraint %', c; END IF; END;
 BEGIN
  UPDATE supply_item SET deleted_at=now(),deleted_by_person_id=actor WHERE id=s1;
  SET CONSTRAINTS ALL IMMEDIATE;
  RAISE EXCEPTION 'ADR-147.4: stopping one side accepted';
 EXCEPTION WHEN check_violation THEN GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
  IF c <> 'expense_item_supply_stopped_match_check' THEN RAISE EXCEPTION 'ADR-147.4: wrong constraint %', c; END IF; END;
 SET CONSTRAINTS ALL DEFERRED;
 UPDATE supply_item SET deleted_at=now(),deleted_by_person_id=actor WHERE id=s1;
 UPDATE expense_item SET deleted_at=now(),deleted_by_person_id=actor WHERE id=i1;
 SET CONSTRAINTS ALL IMMEDIATE; SET CONSTRAINTS ALL DEFERRED;
 BEGIN
  INSERT INTO supply_day_entry(supply_item_id,entry_date,kind_code,entered_measure) VALUES(s1,'2026-11-21','used',1);
  RAISE EXCEPTION 'ADR-147.4: new measure for stopped item accepted';
 EXCEPTION WHEN check_violation THEN GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
  IF c <> 'supply_day_entry_supply_item_stopped_check' THEN RAISE EXCEPTION 'ADR-147.4: wrong constraint %', c; END IF; END;
 BEGIN
  UPDATE supply_day_entry SET entered_measure=6 WHERE id=d1;
  RAISE EXCEPTION 'ADR-147.4: old measure of stopped item edited';
 EXCEPTION WHEN check_violation THEN GET STACKED DIAGNOSTICS c = CONSTRAINT_NAME;
  IF c <> 'supply_day_entry_supply_item_stopped_check' THEN RAISE EXCEPTION 'ADR-147.4: wrong constraint %', c; END IF; END;
 IF (SELECT entered_measure FROM supply_day_entry WHERE id=d1) <> 5
 OR NOT EXISTS (SELECT 1 FROM expense WHERE id=e1 AND deleted_at IS NULL) THEN
  RAISE EXCEPTION 'ADR-147.4: history changed by stopping'; END IF;
 BEGIN -- tên của thứ đã ngừng vẫn giữ chỗ
  INSERT INTO supply_item(name) VALUES('test-KC02-gao-te');
  RAISE EXCEPTION 'ADR-147.4: name of stopped item reused';
 EXCEPTION WHEN unique_violation THEN NULL; END;
 UPDATE supply_item SET deleted_at=NULL,deleted_by_person_id=NULL WHERE id=s1;
 UPDATE expense_item SET deleted_at=NULL,deleted_by_person_id=NULL WHERE id=i1;
 SET CONSTRAINTS ALL IMMEDIATE; SET CONSTRAINTS ALL DEFERRED;
 INSERT INTO supply_day_entry(supply_item_id,entry_date,kind_code,entered_measure) VALUES(s1,'2026-11-21','used',1);
 IF NOT EXISTS (SELECT 1 FROM record_revision WHERE target_table_code='supply_item' AND target_row=s1
               AND before_image->>'deleted_at' IS NOT NULL AND after_image->>'deleted_at' IS NULL) THEN
  RAISE EXCEPTION 'QD-52: reopen left no revision'; END IF;

 -- Thứ chưa xếp mục vẫn ghi sổ được (điểm 2, vế 9 của §8.10).
 INSERT INTO supply_day_entry(supply_item_id,entry_date,kind_code,entered_measure) VALUES(s3,'2026-11-21','purchased',2);
 RAISE NOTICE 'KC-02 PASS: flag, one-to-one link, one name, stop/reopen locks measures, received_date, move category';
END $$;
