package taikhoan

import (
	"banhcuon/be/internal/authz"
	"github.com/jackc/pgx/v5/pgxpool"
	"net/http"
)

const CookiePhien = "banhcuon_phien"

type authenticator struct{ pool *pgxpool.Pool }

func NewAuthenticator(pool *pgxpool.Pool) authz.Authenticator { return authenticator{pool} }
func (a authenticator) PersonID(r *http.Request) (int64, bool) {
	c, err := r.Cookie(CookiePhien)
	if err != nil || len(c.Value) != 43 || a.pool == nil {
		return 0, false
	}
	id, err := nguoiCuaPhien(r.Context(), a.pool, tokenHash(c.Value))
	return id, err == nil && id > 0
}
