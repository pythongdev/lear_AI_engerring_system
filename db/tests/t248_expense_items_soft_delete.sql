-- I-029 · QD-50 · QD-52: liên kết khoản con, xoá mềm có vết và không cấp xoá cứng.
DO $$
DECLARE actor bigint; category bigint; other_category bigint; item bigint; entry bigint;
BEGIN
 INSERT INTO person(display_name,is_owner) VALUES ('test-T248-owner',true) RETURNING id INTO actor;
 PERFORM set_config('shop.actor_person_id',actor::text,true);
 PERFORM set_config('shop.revision_reason','test-T248-correction',true);
 INSERT INTO expense_category(name,paid_from_till) VALUES('test-T248-ingredients',true) RETURNING id INTO category;
 INSERT INTO expense_category(name,paid_from_till) VALUES('test-T248-other',false) RETURNING id INTO other_category;
 INSERT INTO expense_item(expense_category_id,name) VALUES(category,'test-rice') RETURNING id INTO item;
 INSERT INTO expense(expense_category_id,expense_item_id,amount_vnd,paid_date) VALUES(category,item,70000,'2026-10-20') RETURNING id INTO entry;
 BEGIN
  INSERT INTO expense(expense_category_id,expense_item_id,amount_vnd,paid_date) VALUES(other_category,item,1,'2026-10-20');
  RAISE EXCEPTION 'I-029: mismatched item/category accepted';
 EXCEPTION WHEN foreign_key_violation THEN NULL; END;
 BEGIN
  UPDATE expense SET deleted_at=now() WHERE id=entry;
  RAISE EXCEPTION 'QD-52: missing deletion actor accepted';
 EXCEPTION WHEN check_violation THEN NULL; END;
 UPDATE expense SET deleted_at=now(),deleted_by_person_id=actor WHERE id=entry;
 IF NOT EXISTS(SELECT 1 FROM expense WHERE id=entry AND deleted_at IS NOT NULL AND deleted_by_person_id=actor)
 OR NOT EXISTS(SELECT 1 FROM record_revision WHERE target_table_code='expense' AND target_row=entry AND reason='test-T248-correction' AND after_image->>'deleted_at' IS NOT NULL) THEN
  RAISE EXCEPTION 'QD-52: missing row or deletion revision';
 END IF;
 UPDATE expense_item SET name='test-rice-renamed' WHERE id=item;
 IF NOT EXISTS(SELECT 1 FROM record_revision WHERE target_table_code='expense_item' AND target_row=item AND before_image->>'name'='test-rice' AND after_image->>'name'='test-rice-renamed') THEN
  RAISE EXCEPTION 'QD-52: item rename has no before/after';
 END IF;
 IF has_table_privilege('shop_app','expense','DELETE') OR has_table_privilege('shop_app','expense_item','DELETE') OR has_table_privilege('shop_app','expense_category','DELETE') THEN
  RAISE EXCEPTION 'QD-50: hard delete privilege granted';
 END IF;
 RAISE NOTICE 'T-248 PASS: composite FK, paired deletion, retained row, revision, no DELETE privilege';
END $$;
