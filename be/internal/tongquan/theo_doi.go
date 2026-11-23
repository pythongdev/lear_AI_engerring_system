package tongquan

import (
	"context"
	"encoding/json"
	"time"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/platform/postgres"
	"github.com/jackc/pgx/v5"
)

type TheoDoiBan struct {
	TableLabel string        `json:"table_label"`
	ReadAt     time.Time     `json:"read_at"`
	Session    *PhienTheoDoi `json:"session"`
}

type PhienTheoDoi struct {
	Tables          []string        `json:"tables"`
	Items           []ThuCuaBan     `json:"items"`
	Lines           json.RawMessage `json:"lines"`
	LinesTotalVnd   int64           `json:"lines_total_vnd"`
	ServedAmountVnd int64           `json:"served_amount_vnd"`
	PendingLines    json.RawMessage `json:"pending_lines"`
	OrdersAhead     *int64          `json:"orders_ahead"`
}

// TheoDoi chỉ đọc; mã hiện hành là lối vào công khai, không cần danh tính.
func (s *Service) TheoDoi(ctx context.Context, code string) (out TheoDoiBan, err error) {
	err = postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		moc, e := ngayban.DongHo(ctx, tx)
		if e != nil {
			return e
		}
		ngay, e := newRepository(tx).ngay(ctx, moc)
		if e != nil {
			return e
		}
		out, e = theoDoi(ctx, tx, ngay, code)
		return e
	})
	return
}

// ADR-148: lấy chính docBang rồi chỉ chiếu các trường công khai của phiên chứa bàn.
func theoDoi(ctx context.Context, tx pgx.Tx, ngay, code string) (TheoDoiBan, error) {
	seat, err := authz.CurrentTable(ctx, tx, code)
	if err != nil {
		return TheoDoiBan{}, err
	}
	bang, err := docBang(ctx, tx, ngay)
	if err != nil {
		return TheoDoiBan{}, err
	}
	out := TheoDoiBan{TableLabel: seat.Label, ReadAt: bang.ReadAt}
	for _, phien := range bang.Sessions {
		for _, ban := range phien.Tables {
			if ban.DiningTableID != seat.DiningTableID {
				continue
			}
			repo := newRepository(tx)
			pending, err := repo.dongChoDuyet(ctx, phien.TableSessionID)
			if err != nil {
				return out, err
			}
			ahead, err := repo.luotTruoc(ctx, phien.TableSessionID, ngay)
			if err != nil {
				return out, err
			}
			labels := make([]string, 0, len(phien.Tables))
			for _, b := range phien.Tables {
				labels = append(labels, b.Label)
			}
			out.Session = &PhienTheoDoi{
				Tables: labels, Items: phien.Items, Lines: phien.Lines,
				LinesTotalVnd: phien.LinesTotalVnd, ServedAmountVnd: phien.ServedAmountVnd,
				PendingLines: pending, OrdersAhead: ahead,
			}
			return out, nil
		}
	}
	return out, nil
}
