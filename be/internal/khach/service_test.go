package khach

import (
	"context"
	"errors"
	"fmt"
	"net/url"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
)

type testMailer struct {
	links                 []string
	verificationAddresses []string
	verificationError     error
	onVerification        func(string, string)
	tokens                []string
	addresses             []string
}

func (m *testMailer) SendPasswordReset(_ context.Context, email, token string) error {
	m.tokens = append(m.tokens, token)
	m.addresses = append(m.addresses, email)
	return nil
}
func testService(t *testing.T) (context.Context, *Service, *testMailer) {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	t.Cleanup(cancel)
	p, e := postgres.Open(ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if e != nil {
		t.Fatal(e)
	}
	t.Cleanup(p.Close)
	m := &testMailer{}
	return ctx, NewService(p, m), m
}
func wantCode(t *testing.T, e error, c apierr.Code) {
	t.Helper()
	var a apierr.Error
	if !errors.As(e, &a) || a.Code != c {
		t.Fatalf("muốn %s, được %v", c, e)
	}
}

func TestI035_KhachChanNamLanMuoiLamPhut(t *testing.T) {
	ctx, s, m := testService(t)
	email := fmt.Sprintf("chan.%d@quan.test", time.Now().UnixNano())
	a, token, e := s.register(ctx, Registration{Email: email, DisplayName: "Chặn thử", Password: "mat-khau-123"})
	if e != nil {
		t.Fatal(e)
	}
	confirmLast(t, ctx, s, m)
	for i := 0; i < 5; i++ {
		_, _, e = s.login(ctx, strings.ToUpper(email), "sai")
		wantCode(t, e, apierr.CodeLoginFailed)
	}
	_, _, e = s.login(ctx, email, "mat-khau-123")
	wantCode(t, e, apierr.CodeLoginTemporarilyBlocked)
	s.mu.Lock()
	at := s.attempts[a.AccountID]
	remaining := time.Until(at.until)
	at.until = time.Now().Add(-time.Second)
	s.attempts[a.AccountID] = at
	s.mu.Unlock()
	if remaining < 14*time.Minute || remaining > 15*time.Minute {
		t.Fatalf("hạn chặn: %v", remaining)
	}
	if _, _, e = s.login(ctx, email, "mat-khau-123"); e != nil {
		t.Fatal(e)
	}
	// Tài khoản khách không bị khoá hoặc mất phiên do năm lần sai.
	if _, e = s.current(ctx, token); e != nil {
		t.Fatal(e)
	}
	// Lớp khach không nhận person_id kể cả người gọi tự điền cùng số id.
	e = authz.RunAs(ctx, s.pool, authz.Caller{PersonID: a.AccountID}, DangXuat, func(pgx.Tx, authz.Granted) error { t.Fatal("chạy thân cửa không có phiên khách"); return nil })
	wantCode(t, e, apierr.CodeUnauthenticated)
}

func TestI035_KhachDatLaiThuBaLanMotGioMaMotLan(t *testing.T) {
	ctx, s, m := testService(t)
	email := fmt.Sprintf("thu.%d@quan.test", time.Now().UnixNano())
	_, token, e := s.register(ctx, Registration{Email: email, DisplayName: "Thư thử", Password: "mat-khau-123"})
	if e != nil {
		t.Fatal(e)
	}
	confirmLast(t, ctx, s, m)
	if e = s.requestReset(ctx, "khongco."+email); e != nil || len(m.tokens) != 0 {
		t.Fatalf("thư không có tài khoản: %v", e)
	}
	for i := 0; i < 4; i++ {
		if e = s.requestReset(ctx, strings.ToUpper(email)); e != nil {
			t.Fatal(e)
		}
	}
	if len(m.tokens) != 3 || m.addresses[0] != email {
		t.Fatalf("thư: %v", m)
	}
	code := m.tokens[0]
	if len(code) != 43 {
		t.Fatalf("mã không đúng base64url 32 byte: %q", code)
	}
	if e = s.reset(ctx, code, "mat-khau-moi"); e != nil {
		t.Fatal(e)
	}
	wantCode(t, s.reset(ctx, code, "mat-khau-lai"), apierr.CodeResetTokenInvalid)
	_, e = s.current(ctx, token)
	wantCode(t, e, apierr.CodeUnauthenticated)
	_, _, e = s.login(ctx, email, "mat-khau-123")
	wantCode(t, e, apierr.CodeLoginFailed)
	if _, _, e = s.login(ctx, email, "mat-khau-moi"); e != nil {
		t.Fatal(e)
	}
	// Chỉ có số: yêu cầu đặt lại không gửi thư.
	phone := fmt.Sprintf("09%08d", time.Now().UnixNano()%100000000)
	if _, _, e = s.register(ctx, Registration{Phone: phone, DisplayName: "Không thư", Password: "mat-khau-123"}); e != nil {
		t.Fatal(e)
	}
	if e = s.requestReset(ctx, phone); e != nil || len(m.tokens) != 3 {
		t.Fatalf("số điện thoại nhận thư: %v", e)
	}
}

func (m *testMailer) SendEmailVerification(_ context.Context, email, link string) error {
	if m.onVerification != nil {
		m.onVerification(email, link)
	}
	m.links = append(m.links, link)
	m.verificationAddresses = append(m.verificationAddresses, email)
	return m.verificationError
}
func confirmLast(t *testing.T, ctx context.Context, s *Service, m *testMailer) {
	t.Helper()
	link, err := url.Parse(m.links[len(m.links)-1])
	if err != nil {
		t.Fatal(err)
	}
	if _, err = s.verify(ctx, link.Query().Get("ma")); err != nil {
		t.Fatal(err)
	}
}
