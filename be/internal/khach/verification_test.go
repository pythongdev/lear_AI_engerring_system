package khach

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"net/http/httptest"
	"net/url"
	"testing"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/google"
	"banhcuon/be/internal/taikhoan"
	"github.com/gin-gonic/gin"
)

func verificationToken(t *testing.T, m *testMailer) string {
	t.Helper()
	u, err := url.Parse(m.links[len(m.links)-1])
	if err != nil {
		t.Fatal(err)
	}
	return u.Query().Get("ma")
}
func TestI035_EmailVerificationLifecycle(t *testing.T) {
	ctx, s, m := testService(t)
	s.WithOrigin("https://quan.test/")
	m.onVerification = func(email, link string) {
		u, err := url.Parse(link)
		if err != nil {
			t.Fatal(err)
		}
		var committed bool
		err = s.pool.QueryRow(ctx, `SELECT EXISTS (SELECT 1 FROM customer_email_verification v JOIN customer_account a ON a.id=v.customer_account_id WHERE v.token_hash=$1 AND a.pending_email=$2 AND EXISTS (SELECT 1 FROM customer_password p WHERE p.customer_account_id=a.id) AND EXISTS (SELECT 1 FROM customer_session s WHERE s.customer_account_id=a.id))`, taikhoan.TokenHash(u.Query().Get("ma")), email).Scan(&committed)
		if err != nil || !committed {
			t.Fatal("gửi thư trước khi giao dịch tài khoản/mật khẩu/phiên/mã đã commit", err)
		}
	}
	email := fmt.Sprintf("verify.%d@gmail.com", time.Now().UnixNano())
	a, session, err := s.register(ctx, Registration{Email: email, DisplayName: "Khách", Password: "mat-khau-123"})
	if err != nil {
		t.Fatal(err)
	}
	if a.Email != nil || a.PendingEmail == nil || *a.PendingEmail != email {
		t.Fatalf("profile: %+v", a)
	}
	if len(m.links) != 1 || m.verificationAddresses[0] != email {
		t.Fatal("số thư/địa chỉ sai")
	}
	token := verificationToken(t, m)
	if len(token) != 43 || m.links[0] != "https://quan.test/khach/xac-nhan-gmail?ma="+token {
		t.Fatal("link sai origin hoặc mã")
	}
	var codes int
	if err = s.pool.QueryRow(ctx, `SELECT count(*) FROM customer_email_verification WHERE customer_account_id=$1 AND token_hash=$2 AND expires_at=created_at+interval '24 hours'`, a.AccountID, taikhoan.TokenHash(token)).Scan(&codes); err != nil || codes != 1 {
		t.Fatalf("mã: %d %v", codes, err)
	}
	_, _, err = s.login(ctx, email, "mat-khau-123")
	wantCode(t, err, apierr.CodeLoginFailed)
	if err = s.requestReset(ctx, email); err != nil || len(m.tokens) != 0 {
		t.Fatal("Gmail chờ nhận thư đặt lại", err)
	}
	// Pending addresses do not reserve the email.
	if _, _, err = s.register(ctx, Registration{Email: email, DisplayName: "Khách khác", Password: "mat-khau-123"}); err != nil {
		t.Fatal(err)
	}
	if err = s.resend(ctx, session); err != nil {
		t.Fatal(err)
	}
	if err = s.resend(ctx, session); err != nil {
		t.Fatal(err)
	}
	wantCode(t, s.resend(ctx, session), apierr.CodeVerificationRateLimited)
	// The first token remains usable after resends.
	out, err := s.verify(ctx, token)
	if err != nil || out.Email == nil || *out.Email != email || out.PendingEmail != nil {
		t.Fatalf("xác nhận: %+v %v", out, err)
	}
	_, err = s.verify(ctx, token)
	wantCode(t, err, apierr.CodeVerificationInvalid)
	_, err = s.verify(ctx, "unknown")
	wantCode(t, err, apierr.CodeVerificationInvalid)
	_, err = s.verify(ctx, verificationToken(t, m))
	wantCode(t, err, apierr.CodeVerificationInvalid)
	if _, _, err = s.login(ctx, email, "mat-khau-123"); err != nil {
		t.Fatal(err)
	}
	wantCode(t, s.resend(ctx, session), apierr.CodeNoPendingEmail)
	_, _, err = s.register(ctx, Registration{Email: email, DisplayName: "Trùng", Password: "mat-khau-123"})
	wantCode(t, err, apierr.CodeEmailTaken)
}
func TestI035_EmailVerificationGoogleCollision(t *testing.T) {
	ctx, s, m := testService(t)
	email := fmt.Sprintf("collision.%d@gmail.com", time.Now().UnixNano())
	a, _, err := s.register(ctx, Registration{Email: email, DisplayName: "Chờ", Password: "mat-khau-123"})
	if err != nil {
		t.Fatal(err)
	}
	token := verificationToken(t, m)
	s.WithGoogle("client", fakeGoogle{claims: google.Claims{Sub: email, Email: email}})
	b, _, err := s.loginGoogle(ctx, "credential")
	if err != nil || b.AccountID == a.AccountID || b.Email == nil {
		t.Fatalf("Google không tạo riêng: %+v %v", b, err)
	}
	_, err = s.verify(ctx, token)
	public, _ := apierr.FromDB(err)
	wantCode(t, public, apierr.CodeEmailTaken)
	var used bool
	if err = s.pool.QueryRow(ctx, `SELECT used_at IS NOT NULL FROM customer_email_verification WHERE token_hash=$1`, taikhoan.TokenHash(token)).Scan(&used); err != nil || used {
		t.Fatal("mã không rollback", err)
	}
}
func TestI035_EmailVerificationExpiredAndChanged(t *testing.T) {
	ctx, s, _ := testService(t)
	email := fmt.Sprintf("invalid.%d@gmail.com", time.Now().UnixNano())
	a, _, err := s.register(ctx, Registration{Email: email, DisplayName: "Chờ", Password: "mat-khau-123"})
	if err != nil {
		t.Fatal(err)
	}
	now := time.Now()
	for _, tc := range []struct {
		name, email      string
		created, expires time.Time
	}{
		{"expired", email, now.Add(-25 * time.Hour), now.Add(-time.Hour)},
		{"changed", "old." + email, now.Add(-time.Hour), now.Add(time.Hour)},
	} {
		t.Run(tc.name, func(t *testing.T) {
			token, hash, err := taikhoan.NewToken()
			if err != nil {
				t.Fatal(err)
			}
			_, err = s.pool.Exec(ctx, `INSERT INTO customer_email_verification(customer_account_id,email,token_hash,created_at,expires_at) VALUES ($1,$2,$3,$4,$5)`, a.AccountID, tc.email, hash, tc.created, tc.expires)
			if err != nil {
				t.Fatal(err)
			}
			_, err = s.verify(ctx, token)
			wantCode(t, err, apierr.CodeVerificationInvalid)
		})
	}
}
func TestI035_EmailVerificationMailerFailureStill201(t *testing.T) {
	ctx, s, m := testService(t)
	m.verificationError = errors.New("SMTP unavailable")
	r := gin.New()
	Routes(r, s)
	for _, missing := range []bool{false, true} {
		if missing {
			s.mail = nil
		}
		body, _ := json.Marshal(Registration{Email: fmt.Sprintf("mail.%d@gmail.com", time.Now().UnixNano()), DisplayName: "Thư lỗi", Password: "mat-khau-123"})
		req := httptest.NewRequest("POST", "/customer-accounts", bytes.NewReader(body)).WithContext(ctx)
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != 201 {
			t.Fatalf("SMTP hỏng: %d", w.Code)
		}
	}
}

var _ taikhoan.Mailer = (*testMailer)(nil)
