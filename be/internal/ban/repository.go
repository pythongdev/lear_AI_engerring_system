package ban

import (
	"context"

	"banhcuon/be/internal/ban/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

// repository nhận giao dịch của service; chỉ gọi code sqlc sinh (QC-13).
type repository struct{ q *sqlcgen.Queries }

func newRepository(tx pgx.Tx) repository { return repository{q: sqlcgen.New(tx)} }

func (r repository) docBan(ctx context.Context, id int64) (Ban, error) {
	row, err := r.q.DocBan(ctx, id)
	return Ban{DiningTableID: row.ID, Label: row.Label, State: row.State,
		TableSessionID: sessionID(row.ID_2), TableSessionStatus: sessionStatus(row.Status)}, err
}

func (r repository) docCacBan(ctx context.Context) ([]Ban, error) {
	rows, err := r.q.DocCacBan(ctx)
	if err != nil {
		return nil, err
	}
	out := make([]Ban, 0, len(rows))
	for _, row := range rows {
		out = append(out, Ban{DiningTableID: row.ID, Label: row.Label, State: row.State,
			TableSessionID: sessionID(row.ID_2), TableSessionStatus: sessionStatus(row.Status)})
	}
	return out, nil
}

func (r repository) khoaChoDon(ctx context.Context, id int64) ([]int64, error) {
	return r.q.KhoaChoDon(ctx, id)
}

func (r repository) don(ctx context.Context, ids []int64) error {
	return r.q.Don(ctx, ids)
}

// LEFT JOIN không có phiên phải giữ nil để Ban bỏ trường JSON qua omitempty.
func sessionID(v pgtype.Int8) *int64 {
	if !v.Valid {
		return nil
	}
	return &v.Int64
}

func sessionStatus(v pgtype.Text) *string {
	if !v.Valid {
		return nil
	}
	return &v.String
}
