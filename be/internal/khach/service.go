// Package khach giữ tài khoản khách riêng, không tạo hoặc gán person.
package khach

import (
	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/dinhdanh"
	"banhcuon/be/internal/don"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/taikhoan"
	"context"
	"errors"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"log"
	"strings"
	"sync"
	"time"
)

type Registration struct {
	DisplayName string `json:"display_name"`
	Phone       string `json:"phone"`
	Email       string `json:"email"`
	Password    string `json:"password"`
}
type Delivery struct {
	Name    string `json:"delivery_name"`
	Phone   string `json:"delivery_phone"`
	Address string `json:"delivery_address"`
}
type Profile struct {
	AccountID       int64   `json:"customer_account_id"`
	DisplayName     string  `json:"display_name"`
	Phone           *string `json:"phone"`
	Email           *string `json:"email"`
	DeliveryName    *string `json:"delivery_name"`
	DeliveryPhone   *string `json:"delivery_phone"`
	DeliveryAddress *string `json:"delivery_address"`
}
type Order struct {
	ID        int64      `json:"sales_order_id"`
	CreatedAt time.Time  `json:"created_at"`
	Channel   string     `json:"channel_code"`
	Status    string     `json:"status"`
	Total     int64      `json:"total_vnd"`
	Lines     []gia.Dong `json:"lines"`
}
type History struct {
	Orders []Order `json:"orders"`
	Next   *int64  `json:"next_before_id"`
}
type attempt struct {
	count int
	until time.Time
}
type Service struct {
	pool     *pgxpool.Pool
	mail     taikhoan.Mailer
	mu       sync.Mutex
	attempts map[int64]attempt
}

func NewService(p *pgxpool.Pool, m taikhoan.Mailer) *Service {
	return &Service{pool: p, mail: m, attempts: map[int64]attempt{}}
}
func fail(c apierr.Code) error { return apierr.Error{Code: c} }
func (s *Service) register(ctx context.Context, in Registration) (Profile, string, error) {
	var out Profile
	var token string
	phone, email, e := dinhdanh.LienHe(in.Phone, in.Email)
	if e != nil {
		return out, token, e
	}
	in.Phone, in.Email = phone, email
	hash, e := taikhoan.HashPassword(in.Password)
	if e != nil {
		return out, token, e
	}
	e = authz.Run(ctx, s.pool, 0, DangKy, func(tx pgx.Tx) error {
		r := repo(tx)
		id, e := r.create(ctx, in)
		if e != nil {
			return e
		}
		if e = r.password(ctx, id, hash); e != nil {
			return e
		}
		token, e = open(ctx, r, id)
		if e != nil {
			return e
		}
		out, e = r.profile(ctx, id)
		return e
	})
	return out, token, e
}
func open(ctx context.Context, r repository, id int64) (string, error) {
	t, h, e := taikhoan.NewToken()
	if e != nil {
		return "", e
	}
	return t, r.session(ctx, id, h)
}
func (s *Service) login(ctx context.Context, identifier, password string) (Profile, string, error) {
	var out Profile
	var token string
	_, identifier, e := dinhdanh.ChuanHoa(identifier)
	if e != nil {
		return out, "", e
	}
	e = authz.Run(ctx, s.pool, 0, DangNhap, func(tx pgx.Tx) error {
		r := repo(tx)
		a, e := r.DinhDanh(ctx, text(identifier))
		if errors.Is(e, pgx.ErrNoRows) {
			return fail(apierr.CodeLoginFailed)
		}
		if e != nil {
			return e
		}
		s.mu.Lock()
		attempt := s.attempts[a.ID]
		if !attempt.until.IsZero() && !time.Now().Before(attempt.until) {
			delete(s.attempts, a.ID)
			attempt.count = 0
			attempt.until = time.Time{}
		}
		s.mu.Unlock()
		if !attempt.until.IsZero() {
			return fail(apierr.CodeLoginTemporarilyBlocked)
		}
		hash, e := r.MatKhau(ctx, a.ID)
		if e != nil {
			return e
		}
		if !taikhoan.VerifyPassword(password, hash) {
			s.mu.Lock()
			attempt.count++
			if attempt.count >= 5 {
				attempt.until = time.Now().Add(15 * time.Minute)
			}
			s.attempts[a.ID] = attempt
			s.mu.Unlock()
			return fail(apierr.CodeLoginFailed)
		}
		s.mu.Lock()
		delete(s.attempts, a.ID)
		s.mu.Unlock()
		token, e = open(ctx, r, a.ID)
		if e != nil {
			return e
		}
		out, e = r.profile(ctx, a.ID)
		return e
	})
	return out, token, e
}
func (s *Service) run(ctx context.Context, token string, d authz.Door, fn func(repository, authz.Granted) error) error {
	return authz.RunAs(ctx, s.pool, authz.Caller{CustomerToken: token}, d, func(tx pgx.Tx, g authz.Granted) error { return fn(repo(tx), g) })
}
func (s *Service) current(ctx context.Context, token string) (Profile, error) {
	var out Profile
	e := authz.ReadAs(ctx, s.pool, authz.Caller{CustomerToken: token}, authz.NeedCustomer, func(tx pgx.Tx, g authz.Granted) error {
		var e error
		out, e = repo(tx).profile(ctx, g.CustomerAccountID)
		return e
	})
	return out, e
}
func (s *Service) logout(ctx context.Context, token string) error {
	return s.run(ctx, token, DangXuat, func(r repository, g authz.Granted) error {
		return r.end(ctx, g.CustomerAccountID, g.CustomerSessionID, 0, "dang_xuat")
	})
}
func (s *Service) delivery(ctx context.Context, token string, in Delivery) error {
	in.Name = strings.TrimSpace(in.Name)
	in.Phone = strings.TrimSpace(in.Phone)
	in.Address = strings.TrimSpace(in.Address)
	if in.Phone != "" {
		k, p, e := dinhdanh.ChuanHoa(in.Phone)
		if e != nil || k != dinhdanh.DienThoai {
			return apierr.Error{Code: apierr.CodeIdentifierInvalid, Field: "delivery_phone"}
		}
		in.Phone = p
	}
	return s.run(ctx, token, LuuGiao, func(r repository, g authz.Granted) error { return r.delivery(ctx, g.CustomerAccountID, in) })
}
func (s *Service) changePassword(ctx context.Context, token, current, next string) error {
	h, e := taikhoan.HashPassword(next)
	if e != nil {
		return e
	}
	return s.run(ctx, token, DoiMatKhau, func(r repository, g authz.Granted) error {
		old, e := r.MatKhau(ctx, g.CustomerAccountID)
		if e != nil {
			return e
		}
		if !taikhoan.VerifyPassword(current, old) {
			return fail(apierr.CodeLoginFailed)
		}
		if e = r.password(ctx, g.CustomerAccountID, h); e != nil {
			return e
		}
		return r.end(ctx, g.CustomerAccountID, 0, g.CustomerSessionID, "doi_mat_khau")
	})
}
func (s *Service) requestReset(ctx context.Context, email string) error {
	k, email, e := dinhdanh.ChuanHoa(email)
	if e != nil || k != dinhdanh.Thu {
		return nil
	}
	var token, address string
	e = authz.Run(ctx, s.pool, 0, YeuCauDatLai, func(tx pgx.Tx) error {
		r := repo(tx)
		a, e := r.DinhDanh(ctx, text(email))
		if errors.Is(e, pgx.ErrNoRows) {
			return nil
		}
		if e != nil {
			return e
		}
		if !a.Email.Valid {
			return nil
		}
		n, e := r.DemThu(ctx, a.ID)
		if e != nil || n >= 3 {
			return e
		}
		var h []byte
		token, h, e = taikhoan.NewToken()
		if e != nil {
			return e
		}
		address = a.Email.String
		return r.resetCode(ctx, a.ID, h)
	})
	if e != nil {
		return e
	}
	if token != "" {
		if s.mail == nil {
			log.Print("không gửi được thư khách: chưa cấu hình SMTP")
		} else if e = s.mail.SendPasswordReset(ctx, address, token); e != nil {
			log.Print("không gửi được thư khách")
		}
	}
	return nil
}
func (s *Service) reset(ctx context.Context, token, password string) error {
	h, e := taikhoan.HashPassword(password)
	if e != nil {
		return e
	}
	return authz.Run(ctx, s.pool, 0, DatLai, func(tx pgx.Tx) error {
		r := repo(tx)
		m, e := r.Ma(ctx, taikhoan.TokenHash(token))
		if errors.Is(e, pgx.ErrNoRows) {
			return fail(apierr.CodeResetTokenInvalid)
		}
		if e != nil {
			return e
		}
		if _, e = r.Doc(ctx, m.CustomerAccountID); e != nil {
			return e
		}
		m, e = r.Ma(ctx, taikhoan.TokenHash(token))
		if errors.Is(e, pgx.ErrNoRows) {
			return fail(apierr.CodeResetTokenInvalid)
		}
		if e != nil {
			return e
		}
		if e = r.useReset(ctx, m.ID); e != nil {
			return e
		}
		if e = r.password(ctx, m.CustomerAccountID, h); e != nil {
			return e
		}
		return r.end(ctx, m.CustomerAccountID, 0, 0, "dat_lai_mat_khau")
	})
}
func (s *Service) history(ctx context.Context, token string, before int64, limit int32) (History, error) {
	out := History{Orders: []Order{}}
	e := authz.ReadAs(ctx, s.pool, authz.Caller{CustomerToken: token}, authz.NeedCustomer, func(tx pgx.Tx, g authz.Granted) error {
		rows, e := repo(tx).orders(ctx, g.CustomerAccountID, before, limit+1)
		if e != nil {
			return e
		}
		if len(rows) > int(limit) {
			rows = rows[:limit]
			id := rows[len(rows)-1].ID
			out.Next = &id
		}
		for _, row := range rows {
			d, e := don.DocDaTao(ctx, tx, row.SubmissionCode)
			if e != nil {
				return e
			}
			out.Orders = append(out.Orders, Order{d.SalesOrderID, row.CreatedAt.Time, d.ChannelCode, d.Status, d.TotalVnd, d.Lines})
		}
		return nil
	})
	return out, e
}
