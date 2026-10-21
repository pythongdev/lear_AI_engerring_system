package tongquan

import (
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/phien"
	"context"
	"github.com/jackc/pgx/v5"
	"time"
)

type BangVanHanh struct {
	SaleDate     string     `json:"sale_date"`
	ReadAt       time.Time  `json:"read_at"`
	Sessions     []PhienBan `json:"sessions"`
	EmptyTables  []BanTrong `json:"empty_tables"`
	ServeHistory []LanDemRa `json:"serve_history"`
}

type PhienBan struct {
	TableSessionID  int64       `json:"table_session_id"`
	SessionStatus   string      `json:"session_status"`
	ServiceGroup    string      `json:"service_group"`
	Tables          []BanTrong  `json:"tables"`
	OrderTotalVnd   int64       `json:"order_total_vnd"`
	ServedAmountVnd int64       `json:"served_amount_vnd"`
	Items           []ThuCuaBan `json:"items"`
}

type BanTrong struct {
	DiningTableID int64  `json:"dining_table_id"`
	Label         string `json:"label"`
}

type ThuCuaBan struct {
	MenuComponentID  *int64        `json:"menu_component_id"`
	ComponentName    string        `json:"component_name"`
	FillingOptionIDs []int64       `json:"filling_option_ids"`
	Options          []LuaChonChup `json:"options"`
	ExtraFilling     bool          `json:"extra_filling"`
	Ordered          int64         `json:"ordered"`
	Served           int64         `json:"served"`
	Missing          int64         `json:"missing"`
}

type LuaChonChup struct {
	OptionGroupName string `json:"option_group_name"`
	OptionName      string `json:"option_name"`
}

type LanDemRa struct {
	ServedAt         time.Time `json:"served_at"`
	PersonID         int64     `json:"person_id"`
	PersonName       string    `json:"person_name"`
	DiningTableID    int64     `json:"dining_table_id"`
	TableLabel       string    `json:"table_label"`
	StationCode      string    `json:"station_code"`
	MenuComponentID  *int64    `json:"menu_component_id"`
	ComponentName    string    `json:"component_name"`
	FillingOptionIDs []int64   `json:"filling_option_ids"`
	Quantity         int64     `json:"quantity"`
}

// DocBang kiểm quyền và quy ngày bán trong cùng giao dịch đọc (ADR-124).
func (s *Service) DocBang(ctx context.Context, nguoi int64) (out BangVanHanh, err error) {
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedCounterOrOwner, func(tx pgx.Tx) error {
		moc, e := ngayban.DongHo(ctx, tx)
		if e != nil {
			return e
		}
		ngay, e := newRepository(tx).ngay(ctx, moc)
		if e != nil {
			return e
		}
		out, e = docBang(ctx, tx, ngay)
		return e
	})
	return
}

// docBang giữ một nguồn tính tiền phiên: mọi số tiền đơn đi qua phien.TongTien.
func docBang(ctx context.Context, tx pgx.Tx, saleDate string) (BangVanHanh, error) {
	out, err := newRepository(tx).bang(ctx, saleDate)
	if err != nil {
		return out, err
	}
	for i := range out.Sessions {
		out.Sessions[i].OrderTotalVnd, err = phien.TongTien(ctx, tx, out.Sessions[i].TableSessionID)
		if err != nil {
			return out, err
		}
	}
	return out, nil
}
