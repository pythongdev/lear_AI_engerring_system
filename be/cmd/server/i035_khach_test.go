// T-264 (ADR-131, I-035): hai điều không được hỏng khi khách có tài khoản. Viết TRƯỚC khi có cửa khách —
// Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào. Đi qua đúng router của main.go, trên
// PostgreSQL thật (QC-16), dùng lại khung rtSetup của realtime_test.go cho món, đồng hồ và kênh web.
package main

import (
	"bytes"
	"crypto/rand"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"testing"
	"time"

	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

const cookieKhach = "banhcuon_khach"

// soKhach sinh một số di động đã chuẩn hoá, khác nhau giữa các lần chạy.
func soKhach(t *testing.T) string {
	t.Helper()
	var b [4]byte
	if _, err := rand.Read(b[:]); err != nil {
		t.Fatal(err)
	}
	n := (uint32(b[0])<<24 | uint32(b[1])<<16 | uint32(b[2])<<8 | uint32(b[3])) % 100_000_000
	return fmt.Sprintf("09%08d", n)
}

// goiKhach gửi một yêu cầu cùng nguồn kèm các cookie cho sẵn, trả mã trạng thái, thân và cookie khách nếu có.
func (f *rtFixture) goiKhach(method, path string, body any, cookies ...*http.Cookie) (int, map[string]any, string) {
	f.t.Helper()
	var rd *bytes.Reader
	if body != nil {
		raw, err := json.Marshal(body)
		if err != nil {
			f.t.Fatal(err)
		}
		rd = bytes.NewReader(raw)
	} else {
		rd = bytes.NewReader(nil)
	}
	req, err := http.NewRequestWithContext(f.ctx, method, f.server.URL+path, rd)
	if err != nil {
		f.t.Fatal(err)
	}
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	// Router thật so Origin với BANHCUON_ORIGIN; biến rỗng ở test thì không gửi Origin (như yêu cầu cùng nguồn không trình duyệt).
	if o := os.Getenv("BANHCUON_ORIGIN"); o != "" {
		req.Header.Set("Origin", o)
	}
	for _, c := range cookies {
		req.AddCookie(c)
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		f.t.Fatal(err)
	}
	defer res.Body.Close()
	out := map[string]any{}
	_ = json.NewDecoder(res.Body).Decode(&out)
	khach := ""
	for _, c := range res.Cookies() {
		if c.Name == cookieKhach {
			khach = c.Value
		}
	}
	f.t.Logf("%s %s ⇒ %d %v", method, path, res.StatusCode, out)
	return res.StatusCode, out, khach
}

// dangKyKhach mở một tài khoản khách chỉ với số điện thoại và trả mã phiên trong cookie banhcuon_khach.
func (f *rtFixture) dangKyKhach(so string) string {
	f.t.Helper()
	st, body, khach := f.goiKhach("POST", "/customer-accounts", map[string]any{
		"display_name": "Khách " + f.t.Name(), "phone": so, "password": "mat-khau-khach-1",
	})
	if st != http.StatusCreated || khach == "" {
		f.t.Fatalf("khách đăng ký: muốn 201 kèm cookie %s, được %d %v", cookieKhach, st, body)
	}
	return khach
}

// donWeb gửi một đơn giao qua POST /online-orders kèm cookie cho sẵn, trả submission_code của đơn.
func (f *rtFixture) donWeb(cookies ...*http.Cookie) string {
	f.t.Helper()
	// Quán chỉ nhận đơn web khi quầy đang xem luồng sự kiện (khuôn TestI008_… của realtime_test.go).
	f.stream("/counter/events", f.counter)
	var id [16]byte
	if _, err := rand.Read(id[:]); err != nil {
		f.t.Fatal(err)
	}
	submission := fmt.Sprintf("%x-%x-%x-%x-%x", id[:4], id[4:6], id[6:8], id[8:10], id[10:])
	line := map[string]any{}
	for k, v := range f.line {
		if k != "is_takeaway" {
			line[k] = v
		}
	}
	st, body, _ := f.goiKhach("POST", "/online-orders", map[string]any{
		"submission_code":    submission,
		"lines":              []any{line},
		"channel_code":       "delivery",
		"customer_phone":     "0901234567",
		"delivery_address":   "địa chỉ test",
		"customer_needed_at": time.Now().Add(24 * time.Hour).Format(time.RFC3339),
	}, cookies...)
	if st != http.StatusCreated {
		f.t.Fatalf("POST /online-orders: muốn 201, được %d %v", st, body)
	}
	return submission
}

func (f *rtFixture) taiKhoanCuaDon(submission string) *int64 {
	f.t.Helper()
	var id *int64
	if err := f.owner.QueryRow(f.ctx,
		"SELECT customer_account_id FROM shop.sales_order WHERE submission_code=$1", submission).Scan(&id); err != nil {
		f.t.Fatal(err)
	}
	return id
}

// (a) Phiên khách không bao giờ mở được cửa của người làm: dù gửi đúng tên cookie khách hay
// nhét mã phiên khách vào cookie người làm, cửa nguoi_quan / chu_quan đều trả 401 unauthenticated.
func TestI035_CookieKhachKhongMoCuaNguoiLam(t *testing.T) {
	f := rtSetup(t, time.Hour)
	khach := f.dangKyKhach(soKhach(t))

	for _, path := range []string{"/accounts", "/sessions/current"} {
		for _, c := range []*http.Cookie{
			{Name: cookieKhach, Value: khach},
			{Name: taikhoan.CookiePhien, Value: khach},
		} {
			st, body, _ := f.goiKhach("GET", path, nil, c)
			if st != http.StatusUnauthorized || body["code"] != "unauthenticated" {
				t.Fatalf("GET %s với cookie %s mang phiên khách: muốn 401 unauthenticated, được %d %v", path, c.Name, st, body)
			}
		}
	}

	// Chiều ngược lại: phiên người làm không phải phiên khách.
	nguoi := &http.Cookie{Name: taikhoan.CookiePhien, Value: testhelper.Session(t, f.ownerID)}
	if st, body, _ := f.goiKhach("GET", "/customer-sessions/current", nil, nguoi); st != http.StatusUnauthorized {
		t.Fatalf("GET /customer-sessions/current với phiên người làm: muốn 401, được %d %v", st, body)
	}
}

// (b) Đơn web gắn tài khoản khách khi phiên còn hiệu lực; phiên đã hết hạn hay rác thì đơn vẫn tạo
// như ẩn danh, customer_account_id rỗng — không bao giờ từ chối đơn vì phiên khách.
func TestI035_DonWebGanTaiKhoanKhiPhienConHieuLuc(t *testing.T) {
	f := rtSetup(t, time.Hour)
	khach := f.dangKyKhach(soKhach(t))
	c := &http.Cookie{Name: cookieKhach, Value: khach}

	if id := f.taiKhoanCuaDon(f.donWeb(c)); id == nil {
		t.Fatal("đơn web có phiên khách hợp lệ: muốn customer_account_id, được rỗng")
	}

	if id := f.taiKhoanCuaDon(f.donWeb(&http.Cookie{Name: cookieKhach, Value: "khong-phai-ma-phien"})); id != nil {
		t.Fatalf("đơn web với cookie khách rác: muốn customer_account_id rỗng, được %d", *id)
	}

	// Đẩy phiên về quá khứ bằng vai chủ database: hết hạn từ hôm qua. Vết ở chế độ nghiêm (I-018) đòi lý do.
	var tag pgconn.CommandTag
	err := pgx.BeginFunc(f.ctx, f.owner, func(tx pgx.Tx) error {
		if _, err := tx.Exec(f.ctx, "SELECT set_config('shop.revision_reason', 'T-264 test: phiên khách hết hạn', true)"); err != nil {
			return err
		}
		var err error
		tag, err = tx.Exec(f.ctx, `UPDATE shop.customer_session
			SET created_at = now() - interval '8 days', expires_at = now() - interval '1 day'
			WHERE token_hash = sha256(convert_to($1, 'UTF8'))`, khach)
		return err
	})
	if err != nil {
		t.Fatalf("làm phiên khách hết hạn: %v", err)
	}
	if tag.RowsAffected() != 1 {
		t.Fatalf("làm phiên khách hết hạn: muốn đúng 1 dòng theo sha256(mã phiên), được %d", tag.RowsAffected())
	}
	if id := f.taiKhoanCuaDon(f.donWeb(c)); id != nil {
		t.Fatalf("đơn web với phiên khách đã hết hạn: muốn customer_account_id rỗng, được %d", *id)
	}
}
