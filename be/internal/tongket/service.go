// Package tongket chỉ đọc tổng kết một ngày bán (P3A-10, ADR-120).
package tongket

import (
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ket"
	"banhcuon/be/internal/nguyenlieu"
	"context"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Revenue struct {
	TableSessionVnd      int64   `json:"table_session_vnd"`
	StandaloneVnd        int64   `json:"standalone_vnd"`
	RefundsVnd           int64   `json:"refunds_vnd"`
	TotalVnd             int64   `json:"total_vnd"`
	ReconciliationStatus *string `json:"reconciliation_status"`
	PaperEntriesPending  int64   `json:"paper_entries_pending"`
}
type Item struct {
	MenuItemID int64  `json:"menu_item_id"`
	Name       string `json:"name"`
	Quantity   int64  `json:"quantity"`
}
type Combo struct {
	MenuComboID int64  `json:"menu_combo_id"`
	Name        string `json:"name"`
	Quantity    int64  `json:"quantity"`
}
type BestSellers struct {
	Items  []Item  `json:"items"`
	Combos []Combo `json:"combos"`
}
type Staff struct {
	PersonID      int64  `json:"person_id"`
	DisplayName   string `json:"display_name"`
	Worked        bool   `json:"worked"`
	CounterOrders int64  `json:"counter_orders"`
	Deliveries    int64  `json:"deliveries"`
	Cancellations int64  `json:"cancellations"`
	Refunds       int64  `json:"refunds"`
}
type Summary struct {
	Revenue         Revenue                `json:"revenue"`
	BestSellers     BestSellers            `json:"best_sellers"`
	SupplyReminders nguyenlieu.NhacKiemTra `json:"supply_reminders"`
	Staff           []Staff                `json:"staff"`
}
type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

func (s *Service) Doc(ctx context.Context, nguoi int64, ngay string) (out Summary, err error) {
	// Đóng giao dịch trước khi gọi nguồn khác, tránh giữ kết nối trong pool một slot.
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedOwner, func(tx pgx.Tx) error {
		var e error
		out, e = newRepository(tx).doc(ctx, ngay)
		return e
	})
	if err != nil {
		return out, err
	}
	state, err := ket.NewService(s.pool).DocTrangThaiNgay(ctx, ngay)
	if err != nil {
		return out, err
	}
	out.Revenue.ReconciliationStatus = state.Status
	out.Revenue.PaperEntriesPending = state.PaperEntriesPending
	out.SupplyReminders, err = nguyenlieu.NewService(s.pool).DocNhacKiemTra(ctx, nguoi)
	return out, err
}
