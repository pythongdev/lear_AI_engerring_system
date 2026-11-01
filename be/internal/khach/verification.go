package khach

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/taikhoan"
	"context"
	"errors"
	"github.com/jackc/pgx/v5"
	"log"
	"net/url"
	"strings"
)

func (s *Service) WithOrigin(origin string) *Service {
	s.origin = strings.TrimRight(origin, "/")
	return s
}
func (s *Service) sendVerification(ctx context.Context, email, token string) {
	if s.mail == nil {
		log.Print("không gửi được thư xác nhận khách: chưa cấu hình SMTP")
	} else if err := s.mail.SendEmailVerification(ctx, email, s.origin+"/khach/xac-nhan-gmail?ma="+url.QueryEscape(token)); err != nil {
		log.Print("không gửi được thư xác nhận khách")
	}
}
func (s *Service) verify(ctx context.Context, token string) (Profile, error) {
	var out Profile
	err := authz.Run(ctx, s.pool, 0, XacNhan, func(tx pgx.Tx) error {
		r := repo(tx)
		code, err := r.MaXacNhan(ctx, taikhoan.TokenHash(token))
		if errors.Is(err, pgx.ErrNoRows) {
			return fail(apierr.CodeVerificationInvalid)
		}
		if err != nil {
			return err
		}
		// Lock account first, as resend and login do; reread token after the lock.
		a, err := r.Doc(ctx, code.CustomerAccountID)
		if err != nil {
			return err
		}
		code, err = r.MaXacNhan(ctx, taikhoan.TokenHash(token))
		if errors.Is(err, pgx.ErrNoRows) {
			return fail(apierr.CodeVerificationInvalid)
		}
		if err != nil {
			return err
		}
		if !a.PendingEmail.Valid || a.PendingEmail.String != code.Email {
			return fail(apierr.CodeVerificationInvalid)
		}
		if err = r.verifyEmail(ctx, a.ID, code.ID); err != nil {
			return err
		}
		out, err = r.profile(ctx, a.ID)
		return err
	})
	return out, err
}
func (s *Service) resend(ctx context.Context, session string) error {
	var email, token string
	err := s.run(ctx, session, GuiXacNhan, func(r repository, g authz.Granted) error {
		a, err := r.Doc(ctx, g.CustomerAccountID)
		if err != nil {
			return err
		}
		if !a.PendingEmail.Valid {
			return fail(apierr.CodeNoPendingEmail)
		}
		n, err := r.DemXacNhan(ctx, a.ID)
		if err != nil {
			return err
		}
		if n >= 3 {
			return fail(apierr.CodeVerificationRateLimited)
		}
		email = a.PendingEmail.String
		var hash []byte
		token, hash, err = taikhoan.NewToken()
		if err != nil {
			return err
		}
		return r.verificationCode(ctx, a.ID, email, hash)
	})
	if err == nil {
		s.sendVerification(ctx, email, token)
	}
	return err
}
