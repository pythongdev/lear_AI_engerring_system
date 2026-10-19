// Package taikhoan thực hiện ADR-109 trên các cửa ghi có quyền và giao dịch riêng.
package taikhoan

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/nguoi"
	"banhcuon/be/internal/vongdoi"
	"context"
	"errors"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"log"
	"strings"
	"sync"
	"time"
)

type Mailer interface {
	SendPasswordReset(context.Context, string, string) error
}
type attempt struct {
	count int
	until time.Time
}
type Service struct {
	pool     *pgxpool.Pool
	mail     Mailer
	mu       sync.Mutex
	attempts map[int64]attempt
}

func NewService(pool *pgxpool.Pool, mail Mailer) *Service {
	return &Service{pool: pool, mail: mail, attempts: map[int64]attempt{}}
}

type ChuQuanMoi struct {
	Username    string `json:"username"`
	Email       string `json:"email"`
	DisplayName string `json:"display_name"`
	Password    string `json:"password"`
}
type KetQua struct {
	AccountID int64  `json:"account_id"`
	Status    string `json:"status"`
	PersonID  int64  `json:"person_id,omitempty"`
}
type Session struct {
	PersonID           int64  `json:"person_id"`
	DisplayName        string `json:"display_name"`
	RoleCode           string `json:"role_code"`
	IsOwner            bool   `json:"is_owner"`
	MustChangePassword bool   `json:"must_change_password"`
	CounterDutyID      int64  `json:"counter_duty_id"`
}
type Account struct {
	AccountID   int64     `json:"account_id"`
	Username    string    `json:"username"`
	Email       string    `json:"email"`
	DisplayName string    `json:"display_name"`
	Status      string    `json:"status"`
	RoleCode    *string   `json:"role_code"`
	PersonID    *int64    `json:"person_id"`
	CreatedAt   time.Time `json:"created_at"`
}

func fail(c apierr.Code) error                             { return apierr.Error{Code: c} }
func actor(ctx context.Context, tx pgx.Tx, id int64) error { return newRepository(tx).actor(ctx, id) }
func (s *Service) register(ctx context.Context, in ChuQuanMoi, owner bool) (KetQua, error) {
	var out KetQua
	hash, err := hashPassword(in.Password)
	if err != nil {
		return out, err
	}
	door := DangKy
	if owner {
		door = KhoiTao
	}
	err = authz.Run(ctx, s.pool, 0, door, func(tx pgx.Tx) error {
		r := newRepository(tx)
		id, err := r.ThemTaiKhoan(ctx, themTaiKhoanParams{Username: strings.ToLower(in.Username), Email: strings.ToLower(in.Email), RequestedDisplayName: in.DisplayName})
		if err != nil {
			return err
		}
		out = KetQua{AccountID: id, Status: "cho_duyet"}
		if owner {
			person, err := nguoi.TaoNguoi(ctx, tx, in.DisplayName, true)
			if err != nil {
				return err
			}
			if err = actor(ctx, tx, person); err != nil {
				return err
			}
			if err = vongdoi.CoVet(ctx, tx, door.Code, func() error { return r.state(ctx, id, "hoat_dong", person, "owner", person) }); err != nil {
				return err
			}
			out.Status = "hoat_dong"
			out.PersonID = person
		}
		return r.password(ctx, id, hash, 0)
	})
	return out, err
}
func KhoiTaoChuQuan(ctx context.Context, pool *pgxpool.Pool, in ChuQuanMoi) (KetQua, error) {
	return NewService(pool, nil).register(ctx, in, true)
}
func (s *Service) blocked(id int64) bool {
	s.mu.Lock()
	defer s.mu.Unlock()
	a := s.attempts[id]
	if !a.until.IsZero() && !time.Now().Before(a.until) {
		delete(s.attempts, id)
		return false
	}
	return !a.until.IsZero()
}
func (s *Service) failed(id int64) {
	s.mu.Lock()
	defer s.mu.Unlock()
	a := s.attempts[id]
	a.count++
	if a.count >= 5 {
		a.until = time.Now().Add(15 * time.Minute)
	}
	s.attempts[id] = a
}
func (s *Service) success(id int64) { s.mu.Lock(); defer s.mu.Unlock(); delete(s.attempts, id) }
func sessionResult(ctx context.Context, r repository, a account, duty int64) (Session, error) {
	p, err := r.DocNguoi(ctx, a.PersonID.Int64)
	if err != nil {
		return Session{}, err
	}
	pw, err := r.DocMatKhau(ctx, a.ID)
	if err != nil {
		return Session{}, err
	}
	return Session{p.ID, p.DisplayName, a.RoleCode.String, p.IsOwner, pw.MustChangePassword, duty}, nil
}
func (s *Service) login(ctx context.Context, username, password string, atCounter bool) (Session, string, error) {
	var out Session
	var token string
	err := authz.Run(ctx, s.pool, 0, DangNhap, func(tx pgx.Tx) error {
		r := newRepository(tx)
		a, err := r.DocTen(ctx, strings.ToLower(username))
		if errors.Is(err, pgx.ErrNoRows) {
			return fail(apierr.CodeInvalidCredentials)
		}
		if err != nil {
			return err
		}
		if a.Status != "hoat_dong" {
			return fail(apierr.CodeInvalidCredentials)
		}
		if s.blocked(a.ID) {
			return fail(apierr.CodeLoginTemporarilyBlocked)
		}
		pw, err := r.DocMatKhau(ctx, a.ID)
		if errors.Is(err, pgx.ErrNoRows) {
			return fail(apierr.CodeInvalidCredentials)
		}
		if err != nil {
			return err
		}
		if !verifyPassword(password, pw.PasswordHash) {
			s.failed(a.ID)
			return fail(apierr.CodeInvalidCredentials)
		}
		s.success(a.ID)
		if err = actor(ctx, tx, a.PersonID.Int64); err != nil {
			return err
		}
		var duty int64
		if atCounter {
			old, err := nguoi.KhoaQuay(ctx, tx)
			if err != nil {
				return err
			}
			if old != 0 {
				if err = nguoi.KhepKhoang(ctx, tx, old, DangNhap.Code); err != nil {
					return err
				}
			}
			duty, err = nguoi.MoKhoang(ctx, tx, a.PersonID.Int64)
			if err != nil {
				return err
			}
		}
		var hash []byte
		token, hash, err = newToken()
		if err != nil {
			return err
		}
		if err = r.MoPhien(ctx, moPhienParams{AccountID: a.ID, TokenHash: hash, CounterDutyID: nullableID(duty)}); err != nil {
			return err
		}
		out, err = sessionResult(ctx, r, a, duty)
		return err
	})
	return out, token, err
}

// Khoá account trước, rồi đọc lại phiên: khoá/đổi mật khẩu chen vào không vượt qua kiểm tra.
func active(ctx context.Context, r repository, token string, person int64) (account, loginSession, error) {
	var a account
	var session loginSession
	row, err := r.DocPhien(ctx, tokenHash(token))
	if errors.Is(err, pgx.ErrNoRows) {
		err = fail(apierr.CodeUnauthenticated)
	}
	if err != nil {
		return a, session, err
	}
	a, err = r.DocTaiKhoan(ctx, row.AccountID)
	if err != nil {
		return a, session, err
	}
	session, err = r.DocPhien(ctx, tokenHash(token))
	if errors.Is(err, pgx.ErrNoRows) || a.PersonID.Int64 != person {
		return a, session, fail(apierr.CodeUnauthenticated)
	}
	return a, session, err
}
func (s *Service) current(ctx context.Context, person int64, token string) (Session, error) {
	var out Session
	err := authz.Read(ctx, s.pool, person, authz.NeedPerson, func(tx pgx.Tx) error {
		r := newRepository(tx)
		a, p, err := active(ctx, r, token, person)
		if err != nil {
			return err
		}
		out, err = sessionResult(ctx, r, a, p.CounterDutyID.Int64)
		return err
	})
	return out, err
}
func endSessions(ctx context.Context, tx pgx.Tx, r repository, account, session int64, reason string) error {
	return vongdoi.CoVet(ctx, tx, reason, func() error {
		return r.KetThucPhien(ctx, ketThucPhienParams{AccountID: account, Column2: session, EndReason: nullableText(reason)})
	})
}
func (s *Service) logout(ctx context.Context, person int64, token string) error {
	return authz.Run(ctx, s.pool, person, DangXuat, func(tx pgx.Tx) error {
		r := newRepository(tx)
		a, p, err := active(ctx, r, token, person)
		if err != nil {
			return err
		}
		if p.CounterDutyID.Valid {
			if err = nguoi.KhepKhoangCuaPhien(ctx, tx, p.CounterDutyID.Int64, person); err != nil {
				return err
			}
		}
		return endSessions(ctx, tx, r, a.ID, p.ID, "dang_xuat")
	})
}
func (s *Service) changePassword(ctx context.Context, person int64, token, current, next string) error {
	hash, err := hashPassword(next)
	if err != nil {
		return err
	}
	return authz.Run(ctx, s.pool, person, DoiMatKhau, func(tx pgx.Tx) error {
		r := newRepository(tx)
		a, _, err := active(ctx, r, token, person)
		if err != nil {
			return err
		}
		pw, err := r.DocMatKhau(ctx, a.ID)
		if err != nil {
			return err
		}
		if !verifyPassword(current, pw.PasswordHash) {
			return fail(apierr.CodeInvalidCredentials)
		}
		if err = r.password(ctx, a.ID, hash, 0); err != nil {
			return err
		}
		return endSessions(ctx, tx, r, a.ID, 0, "doi_mat_khau")
	})
}
func (s *Service) requestReset(ctx context.Context, email string) error {
	var token, address string
	err := authz.Run(ctx, s.pool, 0, YeuCauDatLai, func(tx pgx.Tx) error {
		r := newRepository(tx)
		a, err := r.DocThu(ctx, strings.ToLower(email))
		if errors.Is(err, pgx.ErrNoRows) {
			return nil
		}
		if err != nil {
			return err
		}
		if a.Status != "hoat_dong" {
			return nil
		}
		n, err := r.DemThu(ctx, a.ID)
		if err != nil {
			return err
		}
		if n >= 3 {
			return nil
		}
		var hash []byte
		token, hash, err = newToken()
		if err != nil {
			return err
		}
		address = a.Email
		return r.TaoMa(ctx, taoMaParams{AccountID: a.ID, TokenHash: hash})
	})
	if err != nil {
		return err
	}
	if token != "" {
		if s.mail == nil {
			log.Print("không gửi được thư: chưa cấu hình SMTP")
		} else if err = s.mail.SendPasswordReset(ctx, address, token); err != nil {
			log.Print("không gửi được thư")
		}
	}
	return nil
}
func (s *Service) reset(ctx context.Context, token, password string) error {
	hash, err := hashPassword(password)
	if err != nil {
		return err
	}
	return authz.Run(ctx, s.pool, 0, DatLai, func(tx pgx.Tx) error {
		r := newRepository(tx)
		a, err := r.DocTaiKhoanMa(ctx, tokenHash(token))
		if errors.Is(err, pgx.ErrNoRows) {
			return fail(apierr.CodeResetTokenInvalid)
		}
		if err != nil {
			return err
		}
		if a.Status != "hoat_dong" {
			return fail(apierr.CodeResetTokenInvalid)
		}
		code, err := r.DocMa(ctx, tokenHash(token))
		if errors.Is(err, pgx.ErrNoRows) {
			return fail(apierr.CodeResetTokenInvalid)
		}
		if err != nil {
			return err
		}
		if err = actor(ctx, tx, a.PersonID.Int64); err != nil {
			return err
		}
		if err = vongdoi.CoVet(ctx, tx, DatLai.Code, func() error { return r.DungMa(ctx, code.ID) }); err != nil {
			return err
		}
		if err = r.password(ctx, a.ID, hash, 0); err != nil {
			return err
		}
		return endSessions(ctx, tx, r, a.ID, 0, "dat_lai_mat_khau")
	})
}
func (s *Service) list(ctx context.Context, person int64, status string) ([]Account, error) {
	out := []Account{}
	err := authz.Read(ctx, s.pool, person, authz.NeedOwner, func(tx pgx.Tx) error {
		rows, err := newRepository(tx).DanhSach(ctx, status)
		if err != nil {
			return err
		}
		for _, a := range rows {
			var p *int64
			var role *string
			if a.PersonID.Valid {
				v := a.PersonID.Int64
				p = &v
			}
			if a.RoleCode.Valid {
				v := a.RoleCode.String
				role = &v
			}
			out = append(out, Account{a.ID, a.Username, a.Email, a.RequestedDisplayName, a.Status, role, p, a.CreatedAt.Time})
		}
		return nil
	})
	return out, err
}
func (s *Service) decide(ctx context.Context, person, id int64, action, role string, link int64, password, token string) (KetQua, error) {
	var out KetQua
	doors := map[string]authz.Door{"approval": Duyet, "rejection": TuChoi, "lock": Khoa, "unlock": MoKhoa}
	door := doors[action]
	err := authz.Run(ctx, s.pool, person, door, func(tx pgx.Tx) error {
		r := newRepository(tx)
		if _, _, err := active(ctx, r, token, person); err != nil {
			return err
		}
		a, err := r.DocTaiKhoan(ctx, id)
		expected, code := "cho_duyet", apierr.CodeAccountNotPending
		if action == "lock" {
			expected, code = "hoat_dong", apierr.CodeAccountNotActive
		}
		if action == "unlock" {
			expected, code = "khoa", apierr.CodeAccountNotLocked
		}
		if errors.Is(err, pgx.ErrNoRows) {
			return fail(code)
		}
		if err != nil {
			return err
		}
		if a.Status != expected {
			return fail(code)
		}
		status, target, targetRole := a.Status, a.PersonID.Int64, a.RoleCode.String
		switch action {
		case "approval":
			switch role {
			case "quay", "trang_banh", "gap_banh", "canh_don_ban":
			default:
				return fail(apierr.CodeInvalidRequest)
			}
			target = link
			if target < 0 {
				return fail(apierr.CodeInvalidRequest)
			}
			if target > 0 {
				isOwner, err := r.personIsOwner(ctx, target)
				if err != nil {
					return err
				}
				if isOwner {
					return apierr.Error{Code: apierr.CodeAccountPersonIsOwner, Field: "person_id"}
				}
			}
			if target == 0 {
				target, err = nguoi.TaoNguoi(ctx, tx, a.RequestedDisplayName, false)
				if err != nil {
					return err
				}
			}
			status, targetRole = "hoat_dong", role
		case "rejection":
			status = "tu_choi"
		case "lock":
			status = "khoa"
		case "unlock":
			hash, err := hashPassword(password)
			if err != nil {
				return err
			}
			if err = r.password(ctx, a.ID, hash, person); err != nil {
				return err
			}
			status = "hoat_dong"
		}
		if err = vongdoi.CoVet(ctx, tx, door.Code, func() error { return r.state(ctx, id, status, target, targetRole, person) }); err != nil {
			return err
		}
		if action == "lock" {
			if err = endSessions(ctx, tx, r, id, 0, "khoa_tai_khoan"); err != nil {
				return err
			}
		}
		out = KetQua{id, status, target}
		return nil
	})
	return out, err
}
