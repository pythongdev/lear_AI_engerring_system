// Package authz chạy một cửa ghi sau khi kiểm quyền theo CHỖ ĐỨNG tại mốc giao dịch của chính cửa
// ấy (P3-05, ADR-085; docs/product/3-be/02-vai-va-quyen.md). Quyền là một lớp của cửa, không phải
// một vai của người: chức vụ không mở cửa nào (architecture.md §4). Package không có câu ghi nào.
package authz

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strconv"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/db"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Need là lớp quyền của một cửa — một giá trị ở cột *Lớp* của ma trận; Gate 1g so hai bản.
type Need string

const (
	// NeedCounter: người bấm có một khoảng counter_duty chứa mốc giao dịch của cửa (YC-15).
	NeedCounter Need = "quay"
	// NeedOwner: người bấm mang cờ chủ quán, đứng đâu cũng được (YC-16).
	NeedOwner Need = "chu_quan"
)

// Door là một cửa ghi và lớp quyền của nó. Code là mã <gói>/<cửa> của QC-13 — thư mục
// be/internal/<gói>/sql/<cửa>/; mỗi cửa khai đúng một Door, ma trận có đúng một dòng.
type Door struct {
	Code string
	Need Need
}

// Authenticator cho cửa biết người gửi yêu cầu là ai. Cách xác định chờ chủ quán (U-075):
// chưa có bản thật nào; test cấp bản của mình trong file _test.go.
type Authenticator interface {
	PersonID(r *http.Request) (int64, bool)
}

// Mỗi câu kiểm trả đúng một dòng: người có tồn tại không, và có qua lớp không — đọc tại now()
// của giao dịch đang mở, tức mốc ghi của cửa.
const (
	kiemQuay = `SELECT EXISTS (SELECT 1 FROM counter_duty
	 WHERE person_id = $1 AND tstzrange(started_at, ended_at, '[)') @> now())`
	kiemChuQuan = `SELECT is_owner FROM person WHERE id = $1`
)

// Run mở giao dịch, kiểm người và lớp của d tại mốc giao dịch, khai người thao tác của giao dịch
// (shop.actor_person_id) bằng chính người đã kiểm, rồi mới chạy fn. Bị từ chối thì fn không chạy
// và lỗi là apierr.Error; lỗi của fn trả nguyên, giao dịch lùi.
func Run(ctx context.Context, pool *pgxpool.Pool, personID int64, d Door, fn func(pgx.Tx) error) error {
	if d.Need != NeedCounter && d.Need != NeedOwner {
		return fmt.Errorf("cửa %q khai lớp quyền lạ %q", d.Code, d.Need)
	}
	if personID <= 0 {
		return apierr.Error{Code: apierr.CodeUnauthenticated}
	}
	return db.InTx(ctx, pool, func(tx pgx.Tx) error {
		var chuQuan bool
		if err := tx.QueryRow(ctx, kiemChuQuan, personID).Scan(&chuQuan); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeUnauthenticated}
			}
			return err
		}
		switch d.Need {
		case NeedOwner:
			if !chuQuan {
				return apierr.Error{Code: apierr.CodeOwnerOnly}
			}
		case NeedCounter:
			var dangDung bool
			if err := tx.QueryRow(ctx, kiemQuay, personID).Scan(&dangDung); err != nil {
				return err
			}
			if !dangDung {
				return apierr.Error{Code: apierr.CodeNotOnCounterDuty}
			}
		}
		if _, err := tx.Exec(ctx, "SELECT set_config('shop.actor_person_id', $1, true)",
			strconv.FormatInt(personID, 10)); err != nil {
			return err
		}
		return fn(tx)
	})
}
