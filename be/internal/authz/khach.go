package authz

import (
	"banhcuon/be/internal/apierr"
	"context"
	"crypto/sha256"
	"errors"
	"github.com/jackc/pgx/v5"
	"net/http"
)

const CookieKhach = "banhcuon_khach"

func CustomerToken(r *http.Request) string {
	c, e := r.Cookie(CookieKhach)
	if e != nil {
		return ""
	}
	return c.Value
}

// CustomerSession khoá tài khoản trước khi đọc lại phiên để đổi mật khẩu không lọt qua.
// Không bao giờ dùng id khách như person_id hoặc đọc cookie người làm.
func CustomerSession(ctx context.Context, tx pgx.Tx, token string) (int64, int64, error) {
	if len(token) != 43 {
		return 0, 0, apierr.Error{Code: apierr.CodeUnauthenticated}
	}
	h := sha256.Sum256([]byte(token))
	var a, id int64
	e := tx.QueryRow(ctx, `SELECT a.id FROM customer_account a JOIN customer_session s ON s.customer_account_id=a.id WHERE s.token_hash=$1 FOR UPDATE OF a`, h[:]).Scan(&a)
	if errors.Is(e, pgx.ErrNoRows) {
		return 0, 0, apierr.Error{Code: apierr.CodeUnauthenticated}
	}
	if e != nil {
		return 0, 0, e
	}
	e = tx.QueryRow(ctx, `SELECT id FROM customer_session WHERE token_hash=$1 AND ended_at IS NULL AND expires_at>now()`, h[:]).Scan(&id)
	if errors.Is(e, pgx.ErrNoRows) {
		return 0, 0, apierr.Error{Code: apierr.CodeUnauthenticated}
	}
	return a, id, e
}
