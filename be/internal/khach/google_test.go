package khach

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"sync"
	"testing"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/google"
)

type fakeGoogle struct {
	claims google.Claims
	err    error
}

func (f fakeGoogle) Verify(context.Context, string) (google.Claims, error) { return f.claims, f.err }

func TestI035_GoogleDisabledAndInvalid(t *testing.T) {
	s := NewService(nil, nil)
	_, _, err := s.loginGoogle(context.Background(), "token")
	wantCode(t, err, apierr.CodeGoogleLoginDisabled)
	s.WithGoogle("client", fakeGoogle{err: errors.New("bad signature")})
	_, _, err = s.loginGoogle(context.Background(), "token")
	wantCode(t, err, apierr.CodeGoogleTokenInvalid)
}
func TestI035_GoogleAccountSessionAndEmailCollision(t *testing.T) {
	ctx, s, m := testService(t)
	suffix := fmt.Sprint(time.Now().UnixNano())
	email := "google." + suffix + "@gmail.com"
	sub := "google-" + suffix
	s.WithGoogle("client", fakeGoogle{claims: google.Claims{Sub: sub, Email: strings.ToUpper(email), Name: "  Lan  "}})
	a, token, err := s.loginGoogle(ctx, "credential")
	if err != nil {
		t.Fatal(err)
	}
	if a.DisplayName != "Lan" || a.Email == nil || *a.Email != email || a.Phone != nil || len(token) != 43 {
		t.Fatalf("profile=%+v token=%q", a, token)
	}
	current, err := s.current(ctx, token)
	if err != nil || current.AccountID != a.AccountID {
		t.Fatalf("session: %+v %v", current, err)
	}
	var links, passwords, sessions int
	if err = s.pool.QueryRow(ctx, `SELECT (SELECT count(*) FROM customer_google_identity WHERE customer_account_id=$1 AND google_sub_code=$2), (SELECT count(*) FROM customer_password WHERE customer_account_id=$1), (SELECT count(*) FROM customer_session WHERE customer_account_id=$1)`, a.AccountID, sub).Scan(&links, &passwords, &sessions); err != nil {
		t.Fatal(err)
	}
	if links != 1 || passwords != 0 || sessions != 1 {
		t.Fatalf("link/password/session: %d/%d/%d", links, passwords, sessions)
	}
	_, _, err = s.login(ctx, email, "mat-khau-khong-co")
	wantCode(t, err, apierr.CodeLoginFailed)
	// Subject wins even when Google later returns a different email/name.
	s.WithGoogle("client", fakeGoogle{claims: google.Claims{Sub: sub, Email: "changed." + email, Name: "Khác"}})
	b, second, err := s.loginGoogle(ctx, "credential")
	if err != nil || b.AccountID != a.AccountID || *b.Email != email || second == token {
		t.Fatalf("existing sub: %+v %v", b, err)
	}
	// An existing password account must never receive a Google link or session.
	registered, _, err := s.register(ctx, Registration{Email: "password." + email, DisplayName: "Mật khẩu", Password: "mat-khau-123"})
	if err != nil {
		t.Fatal(err)
	}
	confirmLast(t, ctx, s, m)
	s.WithGoogle("client", fakeGoogle{claims: google.Claims{Sub: "new-" + sub, Email: "password." + email}})
	_, _, err = s.loginGoogle(ctx, "credential")
	wantCode(t, err, apierr.CodeEmailTaken)
	var accounts int
	if err = s.pool.QueryRow(ctx, `SELECT (SELECT count(*) FROM customer_account WHERE email=$1), (SELECT count(*) FROM customer_google_identity WHERE google_sub_code=$2 OR customer_account_id=$3), (SELECT count(*) FROM customer_session WHERE customer_account_id=$3)`, "password."+email, "new-"+sub, registered.AccountID).Scan(&accounts, &links, &sessions); err != nil {
		t.Fatal(err)
	}
	if accounts != 1 || links != 0 || sessions != 1 {
		t.Fatalf("collision wrote rows: %d/%d/%d", accounts, links, sessions)
	}
	s.WithGoogle("client", fakeGoogle{claims: google.Claims{Sub: "fallback-" + sub, Email: "fallback." + email, Name: "  "}})
	fallback, _, err := s.loginGoogle(ctx, "credential")
	if err != nil || fallback.DisplayName != "fallback.google."+suffix {
		t.Fatalf("fallback: %+v %v", fallback, err)
	}
}
func TestI035_GoogleConcurrentSubject(t *testing.T) {
	ctx, s, _ := testService(t)
	suffix := fmt.Sprint(time.Now().UnixNano())
	sub := "race-" + suffix
	s.WithGoogle("client", fakeGoogle{claims: google.Claims{Sub: sub, Email: "race." + suffix + "@gmail.com"}})
	const n = 8
	var wg sync.WaitGroup
	start := make(chan struct{})
	ids := make([]int64, n)
	errs := make([]error, n)
	for i := 0; i < n; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			<-start
			a, _, err := s.loginGoogle(ctx, "credential")
			ids[i], errs[i] = a.AccountID, err
		}(i)
	}
	close(start)
	wg.Wait()
	for i, err := range errs {
		if err != nil || ids[i] != ids[0] || ids[i] == 0 {
			t.Fatalf("request %d: id=%d error=%v", i, ids[i], err)
		}
	}
	var accounts, links, sessions int
	if err := s.pool.QueryRow(ctx, `SELECT (SELECT count(*) FROM customer_account WHERE email=$1), (SELECT count(*) FROM customer_google_identity WHERE google_sub_code=$2), (SELECT count(*) FROM customer_session WHERE customer_account_id=$3)`, "race."+suffix+"@gmail.com", sub, ids[0]).Scan(&accounts, &links, &sessions); err != nil {
		t.Fatal(err)
	}
	if accounts != 1 || links != 1 || sessions != n {
		t.Fatalf("race account/link/session: %d/%d/%d", accounts, links, sessions)
	}
}
