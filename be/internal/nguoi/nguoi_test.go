// Test đỏ của đăng nhập bằng chọn tên và mốc đổi người ở quầy (T-143; U-075, C36 · U-056; ADR-085
// Sửa đổi 2026-10-10). Viết TRƯỚC khi có package nguoi — Claude viết, Codex làm cho xanh mà không sửa
// điều kiện kiểm nào. Danh tính đi qua bản THẬT authz.ChonTen, không qua bản chỉ cho test.
package nguoi_test

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strconv"
	"sync"
	"testing"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/nguoi"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var cuaQuay = authz.Door{Code: "test/viec_cua_quay", Need: authz.NeedCounter}

type khung struct {
	ctx    context.Context
	pool   *pgxpool.Pool
	srv    *httptest.Server
	owner  *pgx.Conn
	batDau time.Time
}

func dung(t *testing.T) khung {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	t.Cleanup(cancel)
	pool, err := postgres.Open(ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	owner, err := pgx.Connect(ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { owner.Close(context.Background()) })
	mux := http.NewServeMux()
	nguoi.Routes(mux, pool, authz.ChonTen{})
	srv := httptest.NewServer(mux)
	t.Cleanup(srv.Close)
	var batDau time.Time
	if err := owner.QueryRow(ctx, "SELECT clock_timestamp()").Scan(&batDau); err != nil {
		t.Fatal(err)
	}
	return khung{ctx: ctx, pool: pool, srv: srv, owner: owner, batDau: batDau}
}

func (k khung) nguoi(t *testing.T, ten string, chuQuan bool) int64 {
	t.Helper()
	var id int64
	if err := k.owner.QueryRow(k.ctx,
		"INSERT INTO shop.person (display_name, is_owner) VALUES ($1, $2) RETURNING id",
		fmt.Sprintf("%s · %s", ten, t.Name()), chuQuan).Scan(&id); err != nil {
		t.Fatal(err)
	}
	return id
}

type traVe struct {
	status int
	body   map[string]any
}

func (t traVe) so(ten string) int64 {
	f, _ := t.body[ten].(float64)
	return int64(f)
}

func (t traVe) ma() apierr.Code {
	s, _ := t.body["code"].(string)
	return apierr.Code(s)
}

// goiTran không chạm t — gọi được từ goroutine. nguoi = "" thì không gửi header nào.
func (k khung) goiTran(method, path, nguoi string) (traVe, error) {
	req, err := http.NewRequestWithContext(k.ctx, method, k.srv.URL+path, nil)
	if err != nil {
		return traVe{}, err
	}
	if nguoi != "" {
		req.Header.Set(authz.HeaderNguoi, nguoi)
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		return traVe{}, err
	}
	defer res.Body.Close()
	out := traVe{status: res.StatusCode, body: map[string]any{}}
	_ = json.NewDecoder(res.Body).Decode(&out.body)
	return out, nil
}

func (k khung) goi(t *testing.T, method, path string, nguoi int64) traVe {
	t.Helper()
	h := ""
	if nguoi != 0 {
		h = strconv.FormatInt(nguoi, 10)
	}
	out, err := k.goiTran(method, path, h)
	if err != nil {
		t.Fatal(err)
	}
	t.Logf("%s %s (người %d) ⇒ %d %v", method, path, nguoi, out.status, out.body)
	return out
}

func (k khung) vao(t *testing.T, nguoi int64) traVe {
	t.Helper()
	time.Sleep(2 * time.Millisecond)
	return k.goi(t, "POST", "/counter-duty", nguoi)
}

type khoang struct {
	id      int64
	person  int64
	batDau  time.Time
	ketThuc *time.Time
}

// khoangTu: mọi khoảng trực quầy chạm thời gian từ lúc test bắt đầu, theo giờ mở.
func (k khung) khoangTu(t *testing.T) []khoang {
	t.Helper()
	rows, err := k.owner.Query(k.ctx, `SELECT id, person_id, started_at, ended_at FROM shop.counter_duty
	 WHERE ended_at IS NULL OR ended_at > $1 ORDER BY started_at`, k.batDau)
	if err != nil {
		t.Fatal(err)
	}
	defer rows.Close()
	var out []khoang
	for rows.Next() {
		var x khoang
		if err := rows.Scan(&x.id, &x.person, &x.batDau, &x.ketThuc); err != nil {
			t.Fatal(err)
		}
		out = append(out, x)
	}
	if err := rows.Err(); err != nil {
		t.Fatal(err)
	}
	return out
}

func (k khung) dangMo(t *testing.T) []khoang {
	t.Helper()
	var out []khoang
	for _, x := range k.khoangTu(t) {
		if x.ketThuc == nil {
			out = append(out, x)
		}
	}
	return out
}

func TestYC15_VaoQuayLaMotMocDoiAiVaoAiRa(t *testing.T) {
	k := dung(t)
	a := k.nguoi(t, "A", false)
	b := k.nguoi(t, "B", false)

	ra := k.vao(t, a)
	if ra.status != http.StatusCreated || ra.so("person_id") != a || ra.so("counter_duty_id") == 0 {
		t.Fatalf("A vào quầy: muốn 201 với person_id=%d và counter_duty_id", a)
	}
	khoangA := ra.so("counter_duty_id")
	hien := k.goi(t, "GET", "/counter-duty/current", 0)
	if hien.status != http.StatusOK || hien.so("person_id") != a {
		t.Fatalf("người đang đứng quầy: muốn A=%d", a)
	}

	rb := k.vao(t, b)
	if rb.status != http.StatusCreated || rb.so("person_id") != b || rb.so("replaced_person_id") != a {
		t.Fatalf("B vào thay A: muốn 201, person_id=%d, replaced_person_id=%d", b, a)
	}
	var ketThucA, batDauB time.Time
	if err := k.owner.QueryRow(k.ctx, "SELECT ended_at FROM shop.counter_duty WHERE id = $1", khoangA).Scan(&ketThucA); err != nil {
		t.Fatalf("khoảng của A phải được khép: %v", err)
	}
	if err := k.owner.QueryRow(k.ctx, "SELECT started_at FROM shop.counter_duty WHERE id = $1", rb.so("counter_duty_id")).Scan(&batDauB); err != nil {
		t.Fatal(err)
	}
	t.Logf("A ra lúc %s, B vào lúc %s", ketThucA.Format(time.RFC3339Nano), batDauB.Format(time.RFC3339Nano))
	if !ketThucA.Equal(batDauB) {
		t.Fatal("một mốc đổi: giờ A ra phải đúng bằng giờ B vào (C36 — một mốc, hai vế)")
	}
	mo := k.dangMo(t)
	if len(mo) != 1 || mo[0].person != b {
		t.Fatalf("sau lần đổi phải đúng một khoảng mở, của B; có %v", mo)
	}

	// I-018: khép khoảng của A là một lần sửa — có vết, người của vết là người bấm (B), có lý do.
	var nguoiVet int64
	var lyDo string
	if err := k.owner.QueryRow(k.ctx, `SELECT person_id, reason FROM shop.record_revision
	 WHERE target_table_code = 'counter_duty' AND target_row = $1 ORDER BY id DESC LIMIT 1`, khoangA).Scan(&nguoiVet, &lyDo); err != nil {
		t.Fatalf("lần khép khoảng của A phải để lại vết: %v", err)
	}
	t.Logf("vết khép khoảng A: người=%d, lý do=%q", nguoiVet, lyDo)
	if nguoiVet != b || lyDo == "" {
		t.Fatalf("vết phải mang người bấm B=%d và một lý do", b)
	}

	hien = k.goi(t, "GET", "/counter-duty/current", 0)
	if hien.so("person_id") != b || hien.body["display_name"] != fmt.Sprintf("B · %s", t.Name()) {
		t.Fatal("người đang đứng quầy phải là B, kèm tên")
	}
}

func TestYC15_NguoiDangDungVaoLaiKhongTaoMocMoi(t *testing.T) {
	k := dung(t)
	a := k.nguoi(t, "A", false)
	r1 := k.vao(t, a)
	r2 := k.vao(t, a)
	if r1.status != http.StatusCreated || r2.status != http.StatusOK {
		t.Fatalf("vào lần hai khi đang đứng: muốn 200, nhận %d", r2.status)
	}
	if r2.so("counter_duty_id") != r1.so("counter_duty_id") {
		t.Fatal("vào lần hai phải trả lại đúng khoảng đang mở, không mở khoảng mới")
	}
	if _, co := r2.body["replaced_person_id"]; co && r2.body["replaced_person_id"] != nil {
		t.Fatal("không ai bị thay khi người đang đứng chọn lại tên mình")
	}
	var n int
	if err := k.owner.QueryRow(k.ctx, "SELECT count(*) FROM shop.counter_duty WHERE person_id = $1", a).Scan(&n); err != nil {
		t.Fatal(err)
	}
	if n != 1 {
		t.Fatalf("A có %d khoảng, muốn 1", n)
	}
}

func TestYC15_RoiQuayChiNguoiDangDung(t *testing.T) {
	k := dung(t)
	a := k.nguoi(t, "A", false)
	b := k.nguoi(t, "B", false)
	k.vao(t, a)
	time.Sleep(2 * time.Millisecond)

	rb := k.goi(t, "POST", "/counter-duty/end", b)
	if rb.status != http.StatusForbidden || rb.ma() != apierr.CodeNotOnCounterDuty {
		t.Fatalf("B không đứng quầy bấm rời quầy: muốn 403 %q", apierr.CodeNotOnCounterDuty)
	}
	ra := k.goi(t, "POST", "/counter-duty/end", a)
	if ra.status != http.StatusOK || ra.so("person_id") != a || ra.body["ended_at"] == nil {
		t.Fatal("A rời quầy: muốn 200 kèm ended_at")
	}
	if mo := k.dangMo(t); len(mo) != 0 {
		t.Fatalf("A ra mà không ai vào: quầy phải trống, còn %v", mo)
	}
	hien := k.goi(t, "GET", "/counter-duty/current", 0)
	if hien.status != http.StatusOK || hien.body["person_id"] != nil {
		t.Fatal("quầy trống: person_id phải null")
	}
	time.Sleep(2 * time.Millisecond)
	lai := k.goi(t, "POST", "/counter-duty/end", a)
	if lai.status != http.StatusForbidden || lai.ma() != apierr.CodeNotOnCounterDuty {
		t.Fatal("A đã rời quầy bấm rời lần nữa: muốn 403 not_on_counter_duty")
	}
}

func TestI012_KhongChonTenThiKhongVaoQuay(t *testing.T) {
	k := dung(t)
	for _, h := range []string{"", "abc", "0", "-4", "999999999"} {
		r, err := k.goiTran("POST", "/counter-duty", h)
		if err != nil {
			t.Fatal(err)
		}
		t.Logf("header %q ⇒ %d %v", h, r.status, r.body)
		if r.status != http.StatusUnauthorized || r.ma() != apierr.CodeUnauthenticated {
			t.Fatalf("header %q: muốn 401 %q", h, apierr.CodeUnauthenticated)
		}
	}
}

func TestYC15_VaoQuayQuaCuaMoQuyenCuaQuay(t *testing.T) {
	k := dung(t)
	a := k.nguoi(t, "A", false)
	b := k.nguoi(t, "B", false)
	k.vao(t, a)
	time.Sleep(2 * time.Millisecond)
	chay := func(p int64) error {
		return authz.Run(k.ctx, k.pool, p, cuaQuay, func(pgx.Tx) error { return nil })
	}
	if err := chay(a); err != nil {
		t.Fatalf("A vừa vào quầy qua cửa phải làm được việc của quầy: %v", err)
	}
	if err := chay(b); err == nil {
		t.Fatal("B không đứng quầy phải bị từ chối")
	}
	k.vao(t, b)
	time.Sleep(2 * time.Millisecond)
	if err := chay(a); err == nil {
		t.Fatal("A đã bị B thay phải bị từ chối việc của quầy")
	}
	if err := chay(b); err != nil {
		t.Fatalf("B vừa vào phải làm được việc của quầy: %v", err)
	}
}

func TestYC15_NamNguoiVaoCungLucVanMotChuoiMoc(t *testing.T) {
	k := dung(t)
	x := k.nguoi(t, "X", false)
	k.vao(t, x)
	time.Sleep(2 * time.Millisecond)
	ids := make([]int64, 5)
	for i := range ids {
		ids[i] = k.nguoi(t, fmt.Sprintf("N%d", i), false)
	}
	kq := make([]traVe, len(ids))
	loi := make([]error, len(ids))
	var wg sync.WaitGroup
	for i, p := range ids {
		wg.Add(1)
		go func(i int, p int64) {
			defer wg.Done()
			kq[i], loi[i] = k.goiTran("POST", "/counter-duty", strconv.FormatInt(p, 10))
		}(i, p)
	}
	wg.Wait()
	thanhCong := 0
	for i, r := range kq {
		if loi[i] != nil {
			t.Fatal(loi[i])
		}
		t.Logf("N%d ⇒ %d %v", i, r.status, r.body)
		switch {
		case r.status == http.StatusCreated:
			thanhCong++
		case r.status == http.StatusConflict && r.ma() == apierr.CodeCounterDutyChanged:
		default:
			t.Fatalf("N%d: muốn 201 hoặc 409 %q, nhận %d", i, apierr.CodeCounterDutyChanged, r.status)
		}
	}
	if thanhCong == 0 {
		t.Fatal("ít nhất một người phải vào được")
	}
	cuaTest := map[int64]bool{x: true}
	for _, p := range ids {
		cuaTest[p] = true
	}
	var ks []khoang
	for _, kh := range k.khoangTu(t) {
		if cuaTest[kh.person] {
			ks = append(ks, kh)
		}
	}
	mo := 0
	for i, kh := range ks {
		if kh.ketThuc == nil {
			mo++
			continue
		}
		if i+1 < len(ks) && !kh.ketThuc.Equal(ks[i+1].batDau) {
			t.Fatalf("khoảng %d khép lúc %s nhưng khoảng sau mở lúc %s — mốc đổi bị đứt", kh.id, kh.ketThuc, ks[i+1].batDau)
		}
	}
	if mo != 1 {
		t.Fatalf("sau năm lần vào cùng lúc phải đúng một khoảng mở, có %d", mo)
	}
	if len(ks) != thanhCong+1 {
		t.Fatalf("muốn %d khoảng (X và %d lần vào được), có %d", thanhCong+1, thanhCong, len(ks))
	}
}

func TestI012_DanhSachTenDeChon(t *testing.T) {
	k := dung(t)
	a := k.nguoi(t, "A", false)
	cq := k.nguoi(t, "Chủ", true)
	r := k.goi(t, "GET", "/people", 0)
	if r.status != http.StatusOK {
		t.Fatalf("danh sách tên: muốn 200, nhận %d", r.status)
	}
	ds, _ := r.body["people"].([]any)
	thay := map[int64]map[string]any{}
	for _, p := range ds {
		m, _ := p.(map[string]any)
		f, _ := m["person_id"].(float64)
		thay[int64(f)] = m
	}
	if thay[a] == nil || thay[a]["display_name"] != fmt.Sprintf("A · %s", t.Name()) || thay[a]["is_owner"] != false {
		t.Fatal("danh sách phải có A, đúng tên, không cờ chủ quán")
	}
	if thay[cq] == nil || thay[cq]["is_owner"] != true {
		t.Fatal("danh sách phải có chủ quán, mang cờ chủ quán")
	}
}
