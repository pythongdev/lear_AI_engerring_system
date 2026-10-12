package don_test

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"reflect"
	"testing"
	"time"

	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
)

func ngaySuaDem(t *testing.T, n tien, day int) string {
	t.Helper()
	moc := time.Date(2031, 5, day, 0, 0, 0, 0, n.loc).Add(n.gioMo + time.Hour)
	goc := ngayban.DongHo
	ngayban.DongHo = func(context.Context, pgx.Tx) (time.Time, error) { return moc, nil }
	t.Cleanup(func() { ngayban.DongHo = goc })
	datDongHo(t, moc)
	return moc.Format("2006-01-02")
}
func suaDem(t *testing.T, n tien, who int64, day string, body map[string]any) traLoi {
	t.Helper()
	status, out := n.goi(t, http.MethodPut, "/sale-days/"+day+"/cash-count", who, body)
	return traLoi{status: status, body: out}
}
func suaXap(t *testing.T, n tien, day, reason string, ds []xap) traLoi {
	t.Helper()
	return suaDem(t, n, n.chu, day, voi(cacXap(ds), map[string]any{"reason": reason}))
}
func kySuaDem(t *testing.T, n tien, day string) traLoi {
	t.Helper()
	return n.post(t, "/sale-days/"+day+"/reconciliation", n.chu, map[string]any{"gap_explanation": "đếm lại thấy lệch"})
}
func anhXap(t *testing.T, n tien, id int64) map[string]any {
	t.Helper()
	var raw []byte
	if err := n.owner.QueryRow(n.ctx, "SELECT to_jsonb(x) FROM shop.cash_count_line x WHERE id=$1", id).Scan(&raw); err != nil {
		t.Fatal(err)
	}
	var out map[string]any
	if err := json.Unmarshal(raw, &out); err != nil {
		t.Fatal(err)
	}
	return out
}
func TestI021_ChuQuanSuaSoDemNgayDaKy(t *testing.T) {
	n := dungTien(t)
	day := ngaySuaDem(t, n, 1)
	var tz string
	if err := n.pool.QueryRow(n.ctx, "SHOW TimeZone").Scan(&tz); err != nil {
		t.Fatal(err)
	}
	if _, err := n.owner.Exec(n.ctx, "SELECT set_config('TimeZone',$1,false)", tz); err != nil {
		t.Fatal(err)
	}
	canDat(t, n.khaiDauKet(t, n.quay, []xap{{1000, 3000}}), 201)
	counted := n.demKet(t, n.quay, []xap{{1000, 1000}, {2000, 2000}})
	canDat(t, counted, 201)
	c := counted.so(t, "cash_count_id")
	first := kySuaDem(t, n, day)
	canDat(t, first, 201)
	a := first.so(t, "reconciled_day_id")
	ids := []int64{n.docSo(t, "SELECT id FROM shop.cash_count_line WHERE cash_count_id=$1 AND denomination_vnd=1000", c), n.docSo(t, "SELECT id FROM shop.cash_count_line WHERE cash_count_id=$1 AND denomination_vnd=2000", c)}
	before := []map[string]any{anhXap(t, n, ids[0]), anhXap(t, n, ids[1])}
	mark := n.docSo(t, "SELECT coalesce(max(id),0) FROM shop.record_revision")
	r := suaXap(t, n, day, "  đếm nhầm hai xấp  ", []xap{{1000, 4000}, {5000, 5000}})
	canDat(t, r, 200)
	if r.so(t, "total_vnd") != 9000 || r.so(t, "cash_count_id") != c || r.chu("sale_date") != day {
		t.Fatalf("trả về: %v", r.body)
	}
	for i, id := range ids {
		var b, auditAfter []byte
		var reason string
		var person int64
		if err := n.owner.QueryRow(n.ctx, `SELECT before_image,after_image,reason,person_id FROM shop.record_revision WHERE id>$1 AND target_table_code='cash_count_line' AND target_row=$2`, mark, id).Scan(&b, &auditAfter, &reason, &person); err != nil {
			t.Fatal(err)
		}
		var bi, ai map[string]any
		if err := json.Unmarshal(b, &bi); err != nil {
			t.Fatal(err)
		}
		if err := json.Unmarshal(auditAfter, &ai); err != nil {
			t.Fatal(err)
		}
		if !reflect.DeepEqual(bi, before[i]) || !reflect.DeepEqual(ai, anhXap(t, n, id)) || reason != "đếm nhầm hai xấp" || person != n.chu {
			t.Fatalf("vết xấp %d sai: %s → %s, %q người %d", id, b, auditAfter, reason, person)
		}
	}
	if n.docSo(t, "SELECT amount_vnd FROM shop.cash_count_line WHERE id=$1", ids[1]) != 0 {
		t.Fatal("xấp bị bỏ không về 0")
	}
	if n.docSo(t, "SELECT count(*) FROM shop.cash_count_line WHERE cash_count_id=$1", c) != 3 {
		t.Fatal("mất xấp cũ hoặc chưa thêm xấp mới")
	}
	if got := n.docSo(t, `SELECT count(*) FROM shop.record_revision WHERE id>$1 AND target_table_code='cash_count' AND target_row=$2 AND reason='đếm nhầm hai xấp' AND person_id=$3 AND jsonb_array_length(before_image->'cash_count_line')=2 AND jsonb_array_length(after_image->'cash_count_line')=3`, mark, c, n.chu); got != 1 {
		t.Fatalf("vết thêm xấp: %d", got)
	}
	r = ketGiay(t, n, day)
	canDat(t, r, 200)
	if r.chu("status") != "reopened" || r.so(t, "counted_vnd") != 9000 {
		t.Fatalf("số mở lại: %v", r.body)
	}
	stamps := r.body["reconciliations"].([]any)
	opening := stamps[0].(map[string]any)["reopening"].(map[string]any)
	if opening["reason"] != "đếm nhầm hai xấp" || opening["person_id"] != float64(n.chu) {
		t.Fatalf("mở lại: %v", opening)
	}
	// Sửa tiếp khi chưa ký lại: một vết mới, không thêm dòng mở lại.
	mark = n.docSo(t, "SELECT coalesce(max(id),0) FROM shop.record_revision")
	canDat(t, suaXap(t, n, day, "đếm tiếp", []xap{{1000, 5000}, {5000, 5000}}), 200)
	if n.docSo(t, "SELECT count(*) FROM shop.reconciled_day_reopening WHERE sale_date=$1::date", day) != 1 {
		t.Fatal("sửa tiếp mở lại dấu hai lần")
	}
	if n.docSo(t, "SELECT count(*) FROM shop.record_revision WHERE id>$1 AND target_table_code='cash_count_line' AND target_row=$2 AND reason='đếm tiếp' AND person_id=$3", mark, ids[0], n.chu) != 1 {
		t.Fatal("sửa tiếp thiếu vết")
	}
	canMa(t, n.post(t, "/sale-days/"+day+"/reconciliation", n.chu, map[string]any{}), 422, "gap_explanation_required", "")
	second := kySuaDem(t, n, day)
	canDat(t, second, 201)
	b := second.so(t, "reconciled_day_id")
	if n.docSo(t, "SELECT previous_reconciled_day_id FROM shop.reconciled_day WHERE id=$1", b) != a {
		t.Fatal("dấu mới không nối dấu cũ")
	}
	r = ketGiay(t, n, day)
	canDat(t, r, 200)
	stamps = r.body["reconciliations"].([]any)
	if r.chu("status") != "reconciled" || len(stamps) != 2 || stamps[0].(map[string]any)["gap_vnd"] != float64(0) || stamps[1].(map[string]any)["gap_vnd"] != float64(7000) {
		t.Fatalf("chuỗi: %v", r.body)
	}
	canMa(t, kySuaDem(t, n, day), 409, "sale_day_already_reconciled", "")
}

func TestI021_SuaSoDemTuChoi(t *testing.T) {
	n := dungTien(t)
	day := ngaySuaDem(t, n, 2)
	duKetGiay(t, n)
	valid := cacXap([]xap{{1000, 2000}})
	for _, reason := range []any{nil, "", " \t\n ", "\u2003"} {
		canMa(t, suaDem(t, n, n.chu, day, voi(valid, map[string]any{"reason": reason})), 400, "invalid_request", "reason")
	}
	canMa(t, suaDem(t, n, n.chu, day, valid), 400, "invalid_request", "reason")
	body := voi(valid, map[string]any{"reason": "sửa"})
	canMa(t, suaDem(t, n, n.quay, day, body), 403, "owner_only", "")
	canMa(t, suaDem(t, n, 0, day, body), 401, "unauthenticated", "")
	canMa(t, suaDem(t, n, n.chu, day, body), 409, "sale_day_not_reconciled", "")
	canMa(t, suaDem(t, n, n.chu, "2031-05-30", body), 409, "sale_day_not_reconciled", "")
	canMa(t, suaDem(t, n, n.chu, "2031-02-30", body), 400, "invalid_request", "sale_date")
	for _, ca := range []struct {
		lines any
		field string
	}{
		{nil, "lines"}, {[]any{}, "lines"},
		{[]any{map[string]any{"amount_vnd": 1000}}, "lines[0].denomination_vnd"},
		{[]any{map[string]any{"denomination_vnd": 1000}}, "lines[0].amount_vnd"},
		{cacXap([]xap{{0, 1000}})["lines"], "lines[0].denomination_vnd"},
		{cacXap([]xap{{1000, -1000}})["lines"], "lines[0].amount_vnd"},
		{cacXap([]xap{{1000, 1500}})["lines"], "lines[0].amount_vnd"},
		{cacXap([]xap{{1000, 1000}, {1000, 2000}})["lines"], "lines[1].denomination_vnd"},
		{cacXap([]xap{{1, 9223372036854775807}, {2, 2}})["lines"], "lines[1].amount_vnd"},
	} {
		canMa(t, suaDem(t, n, 0, day, map[string]any{"lines": ca.lines, "reason": "sửa"}), 400, "invalid_request", ca.field)
	}
	if n.docSo(t, "SELECT count(*) FROM shop.reconciled_day_reopening WHERE sale_date=$1::date", day) != 0 {
		t.Fatal("từ chối vẫn mở lại")
	}
	if n.docSo(t, "SELECT sum(l.amount_vnd) FROM shop.cash_count_line l JOIN shop.cash_count c ON c.id=l.cash_count_id WHERE c.sale_date=$1::date", day) != 1000 {
		t.Fatal("từ chối vẫn sửa số")
	}
}

func TestI021_NgayMoLaiVanDongVoiCuaTien(t *testing.T) {
	n := dungTien(t)
	day := ngaySuaDem(t, n, 3)
	hd, tong := n.hoaDonBan(t)
	don, tienDon := n.donLay(t)
	n.phucVuHet(t, n.quay, don)
	canDat(t, n.khaiDauKet(t, n.quay, []xap{{1000, 1000}}), 201)
	canDat(t, n.demKet(t, n.quay, []xap{{1, tong + 1000}}), 201)
	canDat(t, kySuaDem(t, n, day), 201)
	canDat(t, suaXap(t, n, day, "đếm lại", []xap{{1, tong + 2000}}), 200)
	before := n.demTien(t)
	canMa(t, n.traoTaiQuay(t, n.quay, don, thu(tienDon, 0)), 409, "sale_day_reconciled", "")
	canMa(t, n.hoan(t, n.quay, hd, 1000, "cash", "cash", "hoàn"), 409, "sale_day_reconciled", "")
	canMa(t, n.nhanTraTruoc(t, n.quay, don, 1000, 0), 409, "sale_day_reconciled", "")
	canMa(t, n.khaiDauKet(t, n.chu, []xap{{1000, 1000}}), 409, "sale_day_reconciled", "")
	canMa(t, n.demKet(t, n.chu, []xap{{1000, 1000}}), 409, "sale_day_reconciled", "")
	canMa(t, khaiGiay(t, n, n.chu, day, 1), 409, "sale_day_reconciled", "")
	n.khongDoi(t, before, "cửa tiền ngày mở lại")
}

// Cả hai thứ tự đều dựng bằng khoá bảng ở câu ghi, rồi quan sát pg_stat_activity.
// Không dựa vào sleep để đoán cửa nào chạy trước.
func TestI021_SuaSoDemChenLucKy(t *testing.T) {
	for i, suaTruoc := range []bool{true, false} {
		t.Run(fmt.Sprintf("sua_truoc_%v", suaTruoc), func(t *testing.T) {
			n := dungTien(t)
			day := ngaySuaDem(t, n, 4+i)
			duKetGiay(t, n)
			first := kySuaDem(t, n, day)
			canDat(t, first, 201)
			canDat(t, suaXap(t, n, day, "mở lại", []xap{{1000, 2000}}), 200)
			giu, err := pgx.Connect(n.ctx, testhelper.OwnerDSN(t))
			if err != nil {
				t.Fatal(err)
			}
			defer giu.Close(context.Background())
			tx, err := giu.Begin(n.ctx)
			if err != nil {
				t.Fatal(err)
			}
			defer tx.Rollback(context.Background())
			table, query := "reconciled_day", "INSERT INTO reconciled_day"
			if suaTruoc {
				table, query = "cash_count_line", "UPDATE cash_count_line"
			}
			if _, err := tx.Exec(n.ctx, "LOCK TABLE shop."+table+" IN SHARE MODE"); err != nil {
				t.Fatal(err)
			}
			var sua, ky traLoi
			suaXong, kyXong := make(chan struct{}), make(chan struct{})
			goSua := func() {
				go func() { defer close(suaXong); sua = suaXap(t, n, day, "sửa chen", []xap{{1000, 3000}}) }()
			}
			goKy := func() { go func() { defer close(kyXong); ky = kySuaDem(t, n, day) }() }
			if suaTruoc {
				goSua()
				if !n.choDen(t, "relation", query, suaXong) {
					t.Fatal("sửa chưa dừng ở câu ghi")
				}
				goKy()
			} else {
				goKy()
				if !n.choDen(t, "relation", query, kyXong) {
					t.Fatal("ký chưa dừng ở câu ghi")
				}
				goSua()
			}
			secondDone := suaXong
			if suaTruoc {
				secondDone = kyXong
			}
			cho := n.choDen(t, "advisory", "", secondDone)
			if err := tx.Commit(n.ctx); err != nil {
				t.Fatal(err)
			}
			<-suaXong
			<-kyXong
			canDat(t, sua, 200)
			canDat(t, ky, 201)
			if !cho {
				t.Fatal("cửa thứ hai không đợi khoá riêng ngày")
			}
			r := ketGiay(t, n, day)
			canDat(t, r, 200)
			if suaTruoc {
				if ky.so(t, "gap_vnd") != 2000 || r.chu("status") != "reconciled" {
					t.Fatalf("ký không thấy số sửa: %v / %v", ky.body, r.body)
				}
			} else {
				if ky.so(t, "gap_vnd") != 1000 || r.chu("status") != "reopened" || n.docSo(t, "SELECT count(*) FROM shop.reconciled_day_reopening WHERE sale_date=$1::date", day) != 2 {
					t.Fatalf("sửa không mở lại dấu vừa ký: %v / %v", ky.body, r.body)
				}
			}
			if r.so(t, "counted_vnd") != 3000 {
				t.Fatalf("mất số sửa: %v", r.body)
			}
		})
	}
}

func TestI021_SuaSoDemLoiGhiLuiCaMoLai(t *testing.T) {
	n := dungTien(t)
	day := ngaySuaDem(t, n, 6)
	duKetGiay(t, n)
	canDat(t, kySuaDem(t, n, day), 201)
	mark := n.docSo(t, "SELECT coalesce(max(id),0) FROM shop.record_revision")
	// Lỗi cài sau khi dòng mở lại đã ghi, tại chính câu sửa xấp.
	if _, err := n.owner.Exec(n.ctx, `CREATE FUNCTION shop.test_t146_refuse_update() RETURNS trigger LANGUAGE plpgsql AS $$
 BEGIN RAISE EXCEPTION 'test T-146 từ chối câu sửa' USING ERRCODE='check_violation'; END $$;
 CREATE TRIGGER test_t146_refuse_update_trg BEFORE UPDATE ON shop.cash_count_line
 FOR EACH ROW EXECUTE FUNCTION shop.test_t146_refuse_update();`); err != nil {
		t.Fatal(err)
	}
	defer func() {
		if _, err := n.owner.Exec(context.Background(), `DROP TRIGGER test_t146_refuse_update_trg ON shop.cash_count_line; DROP FUNCTION shop.test_t146_refuse_update();`); err != nil {
			t.Error(err)
		}
	}()
	canMa(t, suaXap(t, n, day, "sửa bị lỗi", []xap{{1000, 2000}}), 500, "internal_error", "")
	if n.docSo(t, "SELECT count(*) FROM shop.reconciled_day_reopening WHERE sale_date=$1::date", day) != 0 {
		t.Fatal("lỗi ghi để lại dòng mở lại")
	}
	r := ketGiay(t, n, day)
	canDat(t, r, 200)
	if r.chu("status") != "reconciled" || r.so(t, "counted_vnd") != 1000 {
		t.Fatalf("giao dịch không lùi đủ: %v", r.body)
	}
	if n.docSo(t, "SELECT count(*) FROM shop.record_revision WHERE id>$1", mark) != 0 {
		t.Fatal("lỗi ghi để lại vết")
	}
}
