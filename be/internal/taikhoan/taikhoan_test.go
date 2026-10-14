// Test đỏ của đăng nhập bằng tài khoản (T-190; ADR-109, I-033, YC-15 · YC-38). Viết TRƯỚC khi có
// package taikhoan — Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào. Danh tính đi
// qua bản THẬT của Authenticator cookie, không qua bản chỉ cho test; header X-Person-Id không còn
// được tin (ADR-109 điểm 6). Thư đặt lại đi qua một Mailer giả để test đọc được mã (PT-7).
package taikhoan_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/nguoi"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// thuGia giữ thư đặt lại thay cho dịch vụ gửi thư thật.
type thuGia struct {
	mu  sync.Mutex
	thu map[string][]string // email → các mã đã gửi, theo thứ tự
}

func (m *thuGia) SendPasswordReset(_ context.Context, email, token string) error {
	m.mu.Lock()
	defer m.mu.Unlock()
	m.thu[email] = append(m.thu[email], token)
	return nil
}

func (m *thuGia) cuaToi(email string) []string {
	m.mu.Lock()
	defer m.mu.Unlock()
	return append([]string(nil), m.thu[email]...)
}

type khung struct {
	ctx   context.Context
	pool  *pgxpool.Pool
	srv   *httptest.Server
	owner *pgx.Conn
	thu   *thuGia
}

func dung(t *testing.T) khung {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
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
	thu := &thuGia{thu: map[string][]string{}}
	r := gin.New()
	srv := httptest.NewUnstartedServer(r)
	origin := "http://" + srv.Listener.Addr().String()
	r.Use(middleware.CungNguon(origin))
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(pool)))
	taikhoan.Routes(r, taikhoan.NewService(pool, thu))
	nguoi.Routes(r, nguoi.NewService(pool))
	srv.Start()
	t.Cleanup(srv.Close)
	return khung{ctx: ctx, pool: pool, srv: srv, owner: owner, thu: thu}
}

type traVe struct {
	status int
	body   map[string]any
	cookie string // giá trị cookie phiên nếu yêu cầu đặt nó
	hdr    http.Header
}

func (t traVe) so(ten string) int64 {
	f, _ := t.body[ten].(float64)
	return int64(f)
}

func (t traVe) chu(ten string) string {
	s, _ := t.body[ten].(string)
	return s
}

func (t traVe) ma() apierr.Code { return apierr.Code(t.chu("code")) }

// goi gửi yêu cầu cùng nguồn. phien = "" thì không gửi cookie. Mọi header thêm đi qua them.
func (k khung) goi(t *testing.T, method, path, phien string, body any, them ...string) traVe {
	t.Helper()
	var rd *bytes.Reader
	if body != nil {
		b, _ := json.Marshal(body)
		rd = bytes.NewReader(b)
	} else {
		rd = bytes.NewReader(nil)
	}
	req, err := http.NewRequestWithContext(k.ctx, method, k.srv.URL+path, rd)
	if err != nil {
		t.Fatal(err)
	}
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	req.Header.Set("Origin", k.srv.URL)
	if phien != "" {
		req.AddCookie(&http.Cookie{Name: taikhoan.CookiePhien, Value: phien})
	}
	for i := 0; i+1 < len(them); i += 2 {
		req.Header.Set(them[i], them[i+1])
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer res.Body.Close()
	out := traVe{status: res.StatusCode, body: map[string]any{}, hdr: res.Header}
	_ = json.NewDecoder(res.Body).Decode(&out.body)
	for _, c := range res.Cookies() {
		if c.Name == taikhoan.CookiePhien {
			out.cookie = c.Value
		}
	}
	t.Logf("%s %s ⇒ %d %v", method, path, out.status, out.body)
	return out
}

// chuQuan khởi tạo một chủ quán bằng đường của máy chủ (ADR-109 điểm 10) và đăng nhập ngoài quầy.
func (k khung) chuQuan(t *testing.T, ten string) (personID int64, phien string) {
	t.Helper()
	user := tenDangNhap(t, ten)
	if _, err := taikhoan.KhoiTaoChuQuan(k.ctx, k.pool, taikhoan.ChuQuanMoi{
		Username: user, Email: user + "@quan.test", DisplayName: ten + " · " + t.Name(), Password: "mat-khau-chu-quan",
	}); err != nil {
		t.Fatalf("khởi tạo chủ quán: %v", err)
	}
	ra := k.dangNhap(t, user, "mat-khau-chu-quan", false)
	if ra.status != http.StatusCreated || ra.cookie == "" {
		t.Fatalf("chủ quán đăng nhập: muốn 201 kèm cookie %s", taikhoan.CookiePhien)
	}
	return ra.so("person_id"), ra.cookie
}

func tenDangNhap(t *testing.T, ten string) string {
	s := strings.ToLower(fmt.Sprintf("%s.%d", ten, time.Now().UnixNano()%1_000_000_000))
	return strings.Map(func(r rune) rune {
		if (r >= 'a' && r <= 'z') || (r >= '0' && r <= '9') || r == '.' {
			return r
		}
		return -1
	}, s)
}

func (k khung) dangKy(t *testing.T, user, email, ten, matKhau string) traVe {
	t.Helper()
	return k.goi(t, "POST", "/accounts", "", map[string]any{
		"username": user, "email": email, "display_name": ten, "password": matKhau,
	})
}

func (k khung) dangNhap(t *testing.T, user, matKhau string, taiQuay bool) traVe {
	t.Helper()
	return k.goi(t, "POST", "/sessions", "", map[string]any{
		"username": user, "password": matKhau, "at_counter": taiQuay,
	})
}

// nhanVien: đăng ký, chủ quán duyệt với vai quay, trả tên đăng nhập và account_id.
func (k khung) nhanVien(t *testing.T, chu string, ten string) (user string, accountID int64) {
	t.Helper()
	user = tenDangNhap(t, ten)
	dk := k.dangKy(t, user, user+"@quan.test", ten+" · "+t.Name(), "mat-khau-nv-1")
	if dk.status != http.StatusCreated || dk.chu("status") != "cho_duyet" || dk.so("account_id") == 0 {
		t.Fatal("tự đăng ký: muốn 201, status cho_duyet và account_id")
	}
	accountID = dk.so("account_id")
	d := k.goi(t, "POST", fmt.Sprintf("/accounts/%d/approval", accountID), chu, map[string]any{"role_code": "quay"})
	if d.status != http.StatusOK || d.chu("status") != "hoat_dong" || d.so("person_id") == 0 {
		t.Fatal("chủ quán duyệt: muốn 200, status hoat_dong, person_id mới tạo từ tên đã khai")
	}
	return user, accountID
}

func TestI033_DangKyChoDuyetRoiChuQuanDuyetMoiDangNhapDuoc(t *testing.T) {
	k := dung(t)
	_, chu := k.chuQuan(t, "chu")
	user := tenDangNhap(t, "moi")
	dk := k.dangKy(t, user, strings.ToUpper(user)+"@Quan.Test", "Người mới · "+t.Name(), "mat-khau-moi")
	if dk.status != http.StatusCreated || dk.chu("status") != "cho_duyet" {
		t.Fatal("tự đăng ký: muốn 201 cho_duyet")
	}
	if ra := k.dangNhap(t, user, "mat-khau-moi", false); ra.status != http.StatusUnauthorized || ra.cookie != "" {
		t.Fatal("tài khoản chờ duyệt KHÔNG được mở phiên (ADR-109 điểm 2)")
	}
	// Trùng tên đăng nhập hay Gmail, khác hoa thường ⇒ 409 (điểm 4).
	if ra := k.dangKy(t, strings.ToUpper(user), "khac."+user+"@quan.test", "X", "mat-khau-moi"); ra.status != http.StatusConflict || ra.ma() != "username_taken" {
		t.Fatal("tên đăng nhập trùng khác hoa thường: muốn 409 username_taken")
	}
	if ra := k.dangKy(t, "khac."+user, user+"@quan.test", "X", "mat-khau-moi"); ra.status != http.StatusConflict || ra.ma() != "email_taken" {
		t.Fatal("Gmail trùng khác hoa thường: muốn 409 email_taken")
	}
	if ra := k.dangKy(t, "ngan."+user, "ngan."+user+"@quan.test", "X", "1234567"); ra.status != http.StatusBadRequest || ra.ma() != "password_too_short" {
		t.Fatal("mật khẩu 7 ký tự: muốn 400 password_too_short (tối thiểu 8)")
	}
	// Người chưa đăng nhập và người không phải chủ quán không duyệt được.
	path := fmt.Sprintf("/accounts/%d/approval", dk.so("account_id"))
	if ra := k.goi(t, "POST", path, "", map[string]any{"role_code": "quay"}); ra.status != http.StatusUnauthorized {
		t.Fatal("duyệt không đăng nhập: muốn 401")
	}
	nv, _ := k.nhanVien(t, chu, "nv")
	phienNV := k.dangNhap(t, nv, "mat-khau-nv-1", false).cookie
	if ra := k.goi(t, "POST", path, phienNV, map[string]any{"role_code": "quay"}); ra.status != http.StatusForbidden || ra.ma() != apierr.CodeOwnerOnly {
		t.Fatal("người làm duyệt tài khoản: muốn 403 owner_only")
	}
	// Vai owner không gán được qua màn duyệt (ADR-109 Sửa đổi).
	if ra := k.goi(t, "POST", path, chu, map[string]any{"role_code": "owner"}); ra.status != http.StatusBadRequest {
		t.Fatal("duyệt với vai owner: muốn 400")
	}
	// Danh sách chờ duyệt chỉ chủ quán đọc được.
	ds := k.goi(t, "GET", "/accounts?status=cho_duyet", chu, nil)
	if ds.status != http.StatusOK || !strings.Contains(fmt.Sprint(ds.body["accounts"]), user) {
		t.Fatal("chủ quán đọc danh sách chờ duyệt: muốn 200 có tài khoản vừa đăng ký")
	}
	if ra := k.goi(t, "GET", "/accounts?status=cho_duyet", phienNV, nil); ra.status != http.StatusForbidden {
		t.Fatal("người làm đọc danh sách tài khoản: muốn 403")
	}
	d := k.goi(t, "POST", path, chu, map[string]any{"role_code": "gap_banh"})
	if d.status != http.StatusOK || d.chu("status") != "hoat_dong" {
		t.Fatal("chủ quán duyệt: muốn 200 hoat_dong")
	}
	if ra := k.goi(t, "POST", path, chu, map[string]any{"role_code": "quay"}); ra.status != http.StatusConflict || ra.ma() != "account_not_pending" {
		t.Fatal("duyệt lần hai: muốn 409 account_not_pending")
	}
	vao := k.dangNhap(t, strings.ToUpper(user), "mat-khau-moi", false)
	if vao.status != http.StatusCreated || vao.cookie == "" || vao.chu("role_code") != "gap_banh" || vao.so("person_id") != d.so("person_id") {
		t.Fatal("đăng nhập sau duyệt (tên không phân biệt hoa thường): muốn 201, cookie, đúng vai và person_id")
	}
	sc := vao.hdr.Get("Set-Cookie")
	for _, co := range []string{"HttpOnly", "Secure", "SameSite=Strict"} {
		if !strings.Contains(sc, co) {
			t.Fatalf("cookie phiên thiếu %s: %s", co, sc)
		}
	}
	toi := k.goi(t, "GET", "/sessions/current", vao.cookie, nil)
	if toi.status != http.StatusOK || toi.so("person_id") != d.so("person_id") {
		t.Fatal("GET /sessions/current: muốn 200 đúng người")
	}
	// Mật khẩu chỉ ở dạng băm argon2id; mã phiên chỉ ở dạng băm (I-033 vế 3 · 5).
	var bam string
	if err := k.owner.QueryRow(k.ctx, `SELECT password_hash FROM shop.account_password
	 WHERE account_id = $1 ORDER BY id DESC LIMIT 1`, dk.so("account_id")).Scan(&bam); err != nil {
		t.Fatal(err)
	}
	if !strings.HasPrefix(bam, "$argon2id$") || strings.Contains(bam, "mat-khau-moi") {
		t.Fatalf("bản mật khẩu không phải băm argon2id: %q", bam)
	}
	var thay int
	if err := k.owner.QueryRow(k.ctx, `SELECT count(*) FROM shop.login_session WHERE token_hash = convert_to($1, 'UTF8')`,
		vao.cookie).Scan(&thay); err != nil || thay != 0 {
		t.Fatal("mã phiên thô không được nằm ở database")
	}
}

func TestI033_HeaderXPersonIdKhongConDuocTin(t *testing.T) {
	k := dung(t)
	chuID, _ := k.chuQuan(t, "chu")
	ra := k.goi(t, "GET", "/sessions/current", "", nil, "X-Person-Id", fmt.Sprint(chuID))
	if ra.status != http.StatusUnauthorized || ra.ma() != apierr.CodeUnauthenticated {
		t.Fatal("chỉ có X-Person-Id, không cookie: muốn 401 unauthenticated")
	}
	if ra := k.goi(t, "GET", "/accounts?status=cho_duyet", "", nil, "X-Person-Id", fmt.Sprint(chuID)); ra.status != http.StatusUnauthorized {
		t.Fatal("cửa chủ quán qua X-Person-Id: muốn 401")
	}
	if ra := k.goi(t, "GET", "/sessions/current", "khong-phai-ma-that", nil); ra.status != http.StatusUnauthorized {
		t.Fatal("cookie bịa: muốn 401")
	}
	if ra := k.goi(t, "GET", "/people", "", nil); ra.status != http.StatusUnauthorized {
		t.Fatal("GET /people thôi công khai (ADR-109 điểm 11): muốn 401 khi chưa đăng nhập")
	}
}

func TestI033_CuaGhiKhacNguonBiChan(t *testing.T) {
	k := dung(t)
	_, chu := k.chuQuan(t, "chu")
	ra := k.goi(t, "POST", "/sessions/current/end", chu, nil, "Origin", "https://ke-gian.test")
	if ra.status != http.StatusForbidden || ra.ma() != "cross_origin_write" {
		t.Fatal("cửa ghi với Origin lạ: muốn 403 cross_origin_write")
	}
	if toi := k.goi(t, "GET", "/sessions/current", chu, nil); toi.status != http.StatusOK {
		t.Fatal("yêu cầu khác nguồn bị chặn thì phiên phải còn nguyên")
	}
}

func TestI033_NamLanSaiChanMuoiLamPhut(t *testing.T) {
	k := dung(t)
	_, chu := k.chuQuan(t, "chu")
	nv, _ := k.nhanVien(t, chu, "nv")
	for i := 1; i <= 5; i++ {
		if ra := k.dangNhap(t, nv, "sai-mat-khau", false); ra.status != http.StatusUnauthorized || ra.ma() != "invalid_credentials" {
			t.Fatalf("lần sai %d: muốn 401 invalid_credentials", i)
		}
	}
	ra := k.dangNhap(t, nv, "mat-khau-nv-1", false)
	if ra.status != http.StatusTooManyRequests || ra.ma() != "login_temporarily_blocked" || ra.cookie != "" {
		t.Fatal("sau 5 lần sai liền, đúng mật khẩu cũng bị chặn: muốn 429 login_temporarily_blocked")
	}
	// Tên đăng nhập không tồn tại trả cùng câu với sai mật khẩu — không để lộ ai có tài khoản.
	if ra := k.dangNhap(t, "khong.ai."+nv, "sai-mat-khau", false); ra.status != http.StatusUnauthorized || ra.ma() != "invalid_credentials" {
		t.Fatal("tên không tồn tại: muốn 401 invalid_credentials như sai mật khẩu")
	}
}

func TestYC15_DangNhapTaiQuayMoTrucDangXuatKhepTruc(t *testing.T) {
	k := dung(t)
	_, chu := k.chuQuan(t, "chu")
	a, _ := k.nhanVien(t, chu, "a")
	b, _ := k.nhanVien(t, chu, "b")

	va := k.dangNhap(t, a, "mat-khau-nv-1", true)
	if va.status != http.StatusCreated || va.so("counter_duty_id") == 0 {
		t.Fatal("A đăng nhập tại quầy: muốn 201 kèm counter_duty_id")
	}
	var nguoiTruc, phienTruc int64
	if err := k.owner.QueryRow(k.ctx, `SELECT d.person_id, s.counter_duty_id FROM shop.login_session s
	 JOIN shop.counter_duty d ON d.id = s.counter_duty_id WHERE s.counter_duty_id = $1`, va.so("counter_duty_id")).
		Scan(&nguoiTruc, &phienTruc); err != nil {
		t.Fatalf("phiên phải ghi khoảng trực nó đã mở: %v", err)
	}
	if nguoiTruc != va.so("person_id") {
		t.Fatal("khoảng trực phải của chính người đăng nhập (I-033 vế 6)")
	}
	if hien := k.goi(t, "GET", "/counter-duty/current", va.cookie, nil); hien.so("person_id") != va.so("person_id") {
		t.Fatal("người đang đứng quầy phải là A")
	}
	// Cửa POST /counter-duty bị gỡ khỏi hợp đồng (điểm 7).
	if ra := k.goi(t, "POST", "/counter-duty", va.cookie, nil); ra.status != http.StatusNotFound && ra.status != http.StatusMethodNotAllowed {
		t.Fatal("POST /counter-duty phải bị gỡ")
	}
	// B quên không đăng xuất A: B đăng nhập tại quầy thay khoảng của A, đúng một mốc.
	vb := k.dangNhap(t, b, "mat-khau-nv-1", true)
	if vb.status != http.StatusCreated || vb.so("counter_duty_id") == 0 {
		t.Fatal("B đăng nhập tại quầy: muốn 201")
	}
	var aRa, bVao time.Time
	if err := k.owner.QueryRow(k.ctx, "SELECT ended_at FROM shop.counter_duty WHERE id = $1", va.so("counter_duty_id")).Scan(&aRa); err != nil {
		t.Fatalf("khoảng của A phải được khép khi B vào: %v", err)
	}
	if err := k.owner.QueryRow(k.ctx, "SELECT started_at FROM shop.counter_duty WHERE id = $1", vb.so("counter_duty_id")).Scan(&bVao); err != nil {
		t.Fatal(err)
	}
	if !aRa.Equal(bVao) {
		t.Fatal("C36: giờ A ra phải đúng bằng giờ B vào")
	}
	// A đăng xuất sau đó: khoảng của B KHÔNG bị đụng; phiên A kết thúc vì dang_xuat.
	if ra := k.goi(t, "POST", "/sessions/current/end", va.cookie, nil); ra.status != http.StatusOK {
		t.Fatal("A đăng xuất: muốn 200")
	}
	var bHet *time.Time
	if err := k.owner.QueryRow(k.ctx, "SELECT ended_at FROM shop.counter_duty WHERE id = $1", vb.so("counter_duty_id")).Scan(&bHet); err != nil || bHet != nil {
		t.Fatal("đăng xuất của A không được khép khoảng trực của B")
	}
	if ra := k.goi(t, "GET", "/sessions/current", va.cookie, nil); ra.status != http.StatusUnauthorized {
		t.Fatal("phiên đã đăng xuất: muốn 401")
	}
	// B đăng xuất: khép đúng khoảng của B.
	if ra := k.goi(t, "POST", "/sessions/current/end", vb.cookie, nil); ra.status != http.StatusOK {
		t.Fatal("B đăng xuất: muốn 200")
	}
	if err := k.owner.QueryRow(k.ctx, "SELECT ended_at FROM shop.counter_duty WHERE id = $1", vb.so("counter_duty_id")).Scan(&bHet); err != nil || bHet == nil {
		t.Fatal("đăng xuất của phiên tại quầy phải khép khoảng trực của chính phiên ấy")
	}
	var lyDo string
	if err := k.owner.QueryRow(k.ctx, "SELECT end_reason FROM shop.login_session WHERE counter_duty_id = $1", vb.so("counter_duty_id")).Scan(&lyDo); err != nil || lyDo != "dang_xuat" {
		t.Fatal("phiên đăng xuất phải mang lý do dang_xuat")
	}
	// Đăng nhập ngoài quầy không đụng trực quầy.
	vc := k.dangNhap(t, a, "mat-khau-nv-1", false)
	if vc.status != http.StatusCreated || vc.so("counter_duty_id") != 0 {
		t.Fatal("đăng nhập không tại quầy: không mở trực")
	}
	if hien := k.goi(t, "GET", "/counter-duty/current", vc.cookie, nil); hien.so("person_id") != 0 {
		t.Fatal("sau khi B đăng xuất và A đăng nhập ngoài quầy, quầy không có ai")
	}
}

func TestI033_KhoaKetThucPhienNgayMoLaiKemMatKhauTam(t *testing.T) {
	k := dung(t)
	_, chu := k.chuQuan(t, "chu")
	nv, acc := k.nhanVien(t, chu, "nv")
	p1 := k.dangNhap(t, nv, "mat-khau-nv-1", false).cookie
	p2 := k.dangNhap(t, nv, "mat-khau-nv-1", false).cookie
	if ra := k.goi(t, "POST", fmt.Sprintf("/accounts/%d/lock", acc), chu, nil); ra.status != http.StatusOK || ra.chu("status") != "khoa" {
		t.Fatal("chủ quán khoá: muốn 200 khoa")
	}
	for _, p := range []string{p1, p2} {
		if ra := k.goi(t, "GET", "/sessions/current", p, nil); ra.status != http.StatusUnauthorized {
			t.Fatal("khoá xong mọi phiên đang mở hết hiệu lực ngay")
		}
	}
	var con int
	if err := k.owner.QueryRow(k.ctx, `SELECT count(*) FROM shop.login_session WHERE account_id = $1
	 AND (ended_at IS NULL OR end_reason <> 'khoa_tai_khoan')`, acc).Scan(&con); err != nil || con != 0 {
		t.Fatal("mọi phiên của tài khoản bị khoá phải kết thúc với lý do khoa_tai_khoan")
	}
	if ra := k.dangNhap(t, nv, "mat-khau-nv-1", false); ra.status != http.StatusUnauthorized {
		t.Fatal("tài khoản khoá không mở phiên được")
	}
	if ra := k.goi(t, "POST", fmt.Sprintf("/accounts/%d/unlock", acc), chu, map[string]any{"temporary_password": "tam-thoi-123"}); ra.status != http.StatusOK || ra.chu("status") != "hoat_dong" {
		t.Fatal("mở lại kèm mật khẩu tạm: muốn 200 hoat_dong")
	}
	vao := k.dangNhap(t, nv, "tam-thoi-123", false)
	if vao.status != http.StatusCreated || vao.body["must_change_password"] != true {
		t.Fatal("đăng nhập bằng mật khẩu tạm: muốn 201 và must_change_password=true")
	}
	if ra := k.goi(t, "POST", "/accounts/current/password", vao.cookie, map[string]any{
		"current_password": "tam-thoi-123", "new_password": "mat-khau-moi-cua-nv",
	}); ra.status != http.StatusOK {
		t.Fatal("đổi mật khẩu: muốn 200")
	}
	if ra := k.goi(t, "GET", "/sessions/current", vao.cookie, nil); ra.status != http.StatusUnauthorized {
		t.Fatal("đổi mật khẩu kết thúc mọi phiên (lý do doi_mat_khau)")
	}
	moi := k.dangNhap(t, nv, "mat-khau-moi-cua-nv", false)
	if moi.status != http.StatusCreated || moi.body["must_change_password"] != false {
		t.Fatal("đăng nhập bằng mật khẩu mới: muốn 201, must_change_password=false")
	}
	var banMK int
	if err := k.owner.QueryRow(k.ctx, "SELECT count(*) FROM shop.account_password WHERE account_id = $1", acc).Scan(&banMK); err != nil || banMK != 3 {
		t.Fatalf("mỗi lần đặt mật khẩu là một bản mới, bản cũ ở lại: muốn 3 bản, có %d", banMK)
	}
}

func TestI033_TuChoiGiuVetKhongMoPhien(t *testing.T) {
	k := dung(t)
	_, chu := k.chuQuan(t, "chu")
	user := tenDangNhap(t, "la")
	dk := k.dangKy(t, user, user+"@quan.test", "Người lạ · "+t.Name(), "mat-khau-la")
	if ra := k.goi(t, "POST", fmt.Sprintf("/accounts/%d/rejection", dk.so("account_id")), chu, nil); ra.status != http.StatusOK || ra.chu("status") != "tu_choi" {
		t.Fatal("từ chối: muốn 200 tu_choi")
	}
	if ra := k.dangNhap(t, user, "mat-khau-la", false); ra.status != http.StatusUnauthorized {
		t.Fatal("tài khoản bị từ chối không mở phiên")
	}
}

func TestI033_DatLaiTraCungMotCauMaDungMotLan(t *testing.T) {
	k := dung(t)
	_, chu := k.chuQuan(t, "chu")
	nv, _ := k.nhanVien(t, chu, "nv")
	email := nv + "@quan.test"
	p := k.dangNhap(t, nv, "mat-khau-nv-1", false).cookie

	co := k.goi(t, "POST", "/password-reset-requests", "", map[string]any{"email": strings.ToUpper(email)})
	khong := k.goi(t, "POST", "/password-reset-requests", "", map[string]any{"email": "khong-ai-" + email})
	if co.status != http.StatusAccepted || khong.status != http.StatusAccepted || fmt.Sprint(co.body) != fmt.Sprint(khong.body) {
		t.Fatal("đặt lại: có tài khoản hay không đều trả 202 cùng một câu (ADR-109 điểm 8)")
	}
	if len(k.thu.cuaToi("khong-ai-"+email)) != 0 {
		t.Fatal("Gmail không có tài khoản thì không gửi thư")
	}
	ma := k.thu.cuaToi(email)
	if len(ma) != 1 || len(ma[0]) < 32 {
		t.Fatal("Gmail có tài khoản hoạt động nhận đúng một mã ngẫu nhiên")
	}
	if ra := k.goi(t, "POST", "/password-resets", "", map[string]any{"token": ma[0], "new_password": "1234567"}); ra.status != http.StatusBadRequest {
		t.Fatal("mật khẩu mới quá ngắn: muốn 400")
	}
	if ra := k.goi(t, "POST", "/password-resets", "", map[string]any{"token": ma[0], "new_password": "dat-lai-roi-nhe"}); ra.status != http.StatusOK {
		t.Fatal("đặt lại bằng mã: muốn 200")
	}
	if ra := k.goi(t, "GET", "/sessions/current", p, nil); ra.status != http.StatusUnauthorized {
		t.Fatal("đặt lại xong mọi phiên của tài khoản kết thúc")
	}
	if ra := k.goi(t, "POST", "/password-resets", "", map[string]any{"token": ma[0], "new_password": "lan-hai-nua-nhe"}); ra.status != http.StatusBadRequest || ra.ma() != "reset_token_invalid" {
		t.Fatal("mã đặt lại dùng lần hai: muốn 400 reset_token_invalid")
	}
	if ra := k.dangNhap(t, nv, "dat-lai-roi-nhe", false); ra.status != http.StatusCreated {
		t.Fatal("đăng nhập bằng mật khẩu đặt lại: muốn 201")
	}
	// Mỗi Gmail nhiều nhất 3 thư một giờ: lần 1 ở trên, thêm 3 lần nữa ⇒ chỉ 2 thư mới đi, câu trả lời vẫn y nguyên.
	for i := 0; i < 3; i++ {
		if ra := k.goi(t, "POST", "/password-reset-requests", "", map[string]any{"email": email}); ra.status != http.StatusAccepted {
			t.Fatal("yêu cầu đặt lại vượt hạn mức vẫn trả 202 cùng câu")
		}
	}
	if n := len(k.thu.cuaToi(email)); n != 3 {
		t.Fatalf("mỗi Gmail nhiều nhất 3 thư một giờ: muốn 3 thư, có %d", n)
	}
	var bam int
	if err := k.owner.QueryRow(k.ctx, `SELECT count(*) FROM shop.password_reset WHERE token_hash = convert_to($1, 'UTF8')`, ma[0]).Scan(&bam); err != nil || bam != 0 {
		t.Fatal("mã đặt lại thô không được nằm ở database")
	}
}
