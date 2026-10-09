package authz

import (
	"banhcuon/be/internal/apierr"
	"context"
	"errors"
	"github.com/jackc/pgx/v5"
)

const docBanHienHanh = `SELECT q.dining_table_id, q.id, t.label
  FROM qr_code q JOIN dining_table t ON t.id = q.dining_table_id
 WHERE q.code = $1 AND q.replaced_at IS NULL`

// Querier là thứ đọc được một dòng — pool hay giao dịch của cửa đang mở.
type Querier interface {
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
}

// Seat là bàn mà một mã hiện hành chỉ tới.
type Seat struct {
	DiningTableID int64
	QRCodeID      int64
	Label         string
}

// CurrentTable tra bàn TỪ mã, tại mốc của q: mã đã thay hay không tồn tại đều là
// qr_code_not_current. Cửa tạo lượt gọi QR (P3-07) gọi nó trong giao dịch của mình.
func CurrentTable(ctx context.Context, q Querier, code string) (Seat, error) {
	var s Seat
	err := q.QueryRow(ctx, docBanHienHanh, code).Scan(&s.DiningTableID, &s.QRCodeID, &s.Label)
	if errors.Is(err, pgx.ErrNoRows) {
		return Seat{}, apierr.Error{Code: apierr.CodeQRCodeNotCurrent}
	}
	return s, err
}
