package khach

import (
	"context"
	"errors"
	"strings"
	"unicode/utf8"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/dinhdanh"
	"banhcuon/be/internal/google"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

// WithGoogle configures the verifier before the service begins serving requests.
func (s *Service) WithGoogle(clientID string, verifier google.Verifier) *Service {
	s.googleClientID = strings.TrimSpace(clientID)
	s.googleVerifier = verifier
	return s
}
func (s *Service) loginGoogle(ctx context.Context, credential string) (Profile, string, error) {
	if s.googleClientID == "" {
		return Profile{}, "", fail(apierr.CodeGoogleLoginDisabled)
	}
	if s.googleVerifier == nil {
		return Profile{}, "", fail(apierr.CodeGoogleTokenInvalid)
	}
	claims, err := s.googleVerifier.Verify(ctx, credential)
	if err != nil || strings.TrimSpace(claims.Sub) == "" || utf8.RuneCountInString(claims.Sub) > 255 {
		return Profile{}, "", fail(apierr.CodeGoogleTokenInvalid)
	}
	// Resolve an existing subject first: a later change of Google email cannot
	// change the customer's account or force a new link.
	attempt := func(create bool) (Profile, string, error) {
		var out Profile
		var token string
		err := authz.Run(ctx, s.pool, 0, GoogleLogin, func(tx pgx.Tx) error {
			r := repo(tx)
			id, e := r.GoogleAccount(ctx, claims.Sub)
			if errors.Is(e, pgx.ErrNoRows) && create {
				kind, email, e := dinhdanh.ChuanHoa(claims.Email)
				if e != nil || kind != dinhdanh.Thu {
					return fail(apierr.CodeGoogleTokenInvalid)
				}
				_, e = r.DinhDanh(ctx, text(email))
				if e == nil {
					return fail(apierr.CodeEmailTaken)
				}
				if !errors.Is(e, pgx.ErrNoRows) {
					return e
				}
				name := strings.TrimSpace(claims.Name)
				if name == "" {
					name, _, _ = strings.Cut(email, "@")
				}
				id, e = r.createGoogle(ctx, Registration{Email: email, DisplayName: name})
				if e != nil {
					return e
				}
				if e = r.linkGoogle(ctx, id, claims.Sub); e != nil {
					return e
				}
			} else if e != nil {
				return e
			}
			// Lock the account before opening a session, as with password login.
			out, e = r.profile(ctx, id)
			if e != nil {
				return e
			}
			token, e = open(ctx, r, id)
			return e
		})
		if err != nil {
			return Profile{}, "", err
		}
		return out, token, nil
	}
	out, token, err := attempt(true)
	var pg *pgconn.PgError
	var public apierr.Error
	collision := errors.As(err, &pg) && pg.Code == "23505" &&
		(pg.ConstraintName == "customer_google_identity_sub_key" || pg.ConstraintName == "customer_account_email_key")
	// The winner can also commit between our subject lookup and email lookup.
	collision = collision || (errors.As(err, &public) && public.Code == apierr.CodeEmailTaken)
	if collision {
		// The losing transaction is rolled back in full before reading the winner.
		// Email may collide first when both requests carry the same subject/email.
		recovered, recoveredToken, retryErr := attempt(false)
		if retryErr == nil {
			return recovered, recoveredToken, nil
		}
		if !errors.Is(retryErr, pgx.ErrNoRows) {
			return Profile{}, "", retryErr
		}
	}
	return out, token, err
}
