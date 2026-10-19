// Package tongquan gom nguồn đọc, giữ cửa số tối thiểu của ngày (T-199) và cửa POS khai số người (T-197).
package tongquan

import (
	"context"
	"encoding/json"
	"time"

	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ngayban"
	"banhcuon/be/internal/nguyenlieu"
	"banhcuon/be/internal/sanxuat"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// MucNguoi là mục số người và thiếu người: chưa có thì không bịa số, có thể kèm
// mức tối thiểu đã nhập; có số thì chỉ là con số POS khai (ADR-121).
type MucNguoi struct {
	Status         string     `json:"status"`
	Name           string     `json:"name"`
	Reason         string     `json:"reason,omitempty"`
	WorkerCount    *int32     `json:"worker_count,omitempty"`
	PersonID       *int64     `json:"person_id,omitempty"`
	PersonName     *string    `json:"person_name,omitempty"`
	DeclaredAt     *time.Time `json:"declared_at,omitempty"`
	MinimumWorkers *int32     `json:"minimum_workers,omitempty"`
	Short          *bool      `json:"short,omitempty"`
	MissingWorkers *int32     `json:"missing_workers,omitempty"`
}

func chuaCo(name, reason string) MucNguoi {
	return MucNguoi{Status: "unavailable", Name: name, Reason: reason}
}

type Phan struct {
	Group            string  `json:"group"`
	StationCode      string  `json:"station_code"`
	MenuComponentID  *int64  `json:"menu_component_id"`
	ComponentName    string  `json:"component_name"`
	FillingOptionIDs []int64 `json:"filling_option_ids"`
	Quantity         int64   `json:"quantity"`
}
type CacPhan struct {
	Status string    `json:"status"`
	ReadAt time.Time `json:"read_at"`
	Rows   []Phan    `json:"rows"`
}
type NguyenLieu struct {
	Status string           `json:"status"`
	Items  []nguyenlieu.Thu `json:"items"`
}
type Thieu struct {
	Supplies  NguyenLieu `json:"supplies"`
	Workers   MucNguoi   `json:"workers"`
	MenuItems ThieuMon   `json:"menu_items"`
}

// TongQuan không chứa doanh thu đã đối soát.
type TongQuan struct {
	SaleDate         string    `json:"sale_date"`
	ReadAt           time.Time `json:"read_at"`
	ServingGuests    SoPhien   `json:"serving_guests"`
	ServedPortions   CacPhan   `json:"served_portions"`
	MissingPortions  CacPhan   `json:"missing_portions"`
	SalesProgress    TienDo    `json:"sales_progress"`
	ProvisionalSales TamTinh   `json:"provisional_sales"`
	WorkersPresent   MucNguoi  `json:"workers_present"`
	Shortages        Thieu     `json:"shortages"`
}

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

func (s *Service) Doc(ctx context.Context, nguoi int64) (out TongQuan, err error) {
	var ngay string
	var moc time.Time
	var tong soTong
	var khai *KhaiNguoi
	// Kiểm quyền trước mọi nguồn; đóng giao dịch trước các service khác để không
	// giữ một kết nối trong lúc chờ kết nối thứ hai (pool có thể chỉ có một).
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedOwner, func(tx pgx.Tx) error {
		var e error
		moc, e = ngayban.DongHo(ctx, tx)
		if e != nil {
			return e
		}
		repo := newRepository(tx)
		ngay, e = repo.ngay(ctx, moc)
		if e != nil {
			return e
		}
		tong, e = repo.tong(ctx, ngay)
		if e != nil {
			return e
		}
		khai, e = repo.moiNhat(ctx, ngay)
		return e
	})
	if err != nil {
		return out, err
	}
	board, err := sanxuat.NewService(s.pool).DocGom(ctx, "", nil)
	if err != nil {
		return out, err
	}
	supplies := nguyenlieu.NewService(s.pool)
	items, err := supplies.Doc(ctx, nguoi)
	if err != nil {
		return out, err
	}
	out, err = lap(ngay, moc, board, items)
	if err == nil {
		out.apDung(tong)
		out.apDungNguoi(khai, tong.MinimumWorkers)
	}
	return
}

func lap(ngay string, moc time.Time, raw json.RawMessage, supplies []nguyenlieu.Thu) (TongQuan, error) {
	var board struct {
		ReadAt time.Time `json:"read_at"`
		Rows   []struct {
			StationCode      string  `json:"station_code"`
			MenuComponentID  *int64  `json:"menu_component_id"`
			ComponentName    string  `json:"component_name"`
			FillingOptionIDs []int64 `json:"filling_option_ids"`
			Parts            []struct {
				DiningTableID *int64 `json:"dining_table_id"`
				Served        int64  `json:"served"`
				Missing       int64  `json:"missing"`
			} `json:"parts"`
		} `json:"rows"`
	}
	if err := json.Unmarshal(raw, &board); err != nil {
		return TongQuan{}, err
	}
	served := CacPhan{Status: "available", ReadAt: board.ReadAt, Rows: []Phan{}}
	missing := CacPhan{Status: "available", ReadAt: board.ReadAt, Rows: []Phan{}}
	for _, row := range board.Rows {
		for _, group := range []string{"in_store", "online"} {
			a := Phan{Group: group, StationCode: row.StationCode, MenuComponentID: row.MenuComponentID, ComponentName: row.ComponentName, FillingOptionIDs: row.FillingOptionIDs}
			if a.FillingOptionIDs == nil {
				a.FillingOptionIDs = []int64{}
			}
			b := a
			co := false
			for _, part := range row.Parts {
				if (part.DiningTableID != nil) != (group == "in_store") {
					continue
				}
				co = true
				a.Quantity += part.Served
				b.Quantity += part.Missing
			}
			if co {
				served.Rows = append(served.Rows, a)
				missing.Rows = append(missing.Rows, b)
			}
		}
	}
	return TongQuan{
		SaleDate: ngay, ReadAt: moc,
		ServingGuests:  SoPhien{Status: "available", Name: "Khách đang được phục vụ"},
		ServedPortions: served, MissingPortions: missing,
		SalesProgress:    TienDo{Status: "unavailable", Name: "Tiến độ bán trong buổi", Reason: "daily_minimum_missing"},
		ProvisionalSales: TamTinh{Status: "available", Name: "Tiền bán tạm tính"},
		WorkersPresent:   chuaCo("Người thực tế đang làm", "workers_present_missing"),
		Shortages: Thieu{
			Supplies:  NguyenLieu{Status: "available", Items: supplies},
			Workers:   chuaCo("Thiếu người", "workers_present_missing"),
			MenuItems: ThieuMon{Status: "available", Items: []Mon{}},
		},
	}, nil
}

type SoPhien struct {
	Status   string `json:"status"`
	Name     string `json:"name"`
	Quantity int64  `json:"quantity"`
}
type TienDo struct {
	Status      string `json:"status"`
	Name        string `json:"name"`
	Reason      string `json:"reason,omitempty"`
	ServedBanh  *int64 `json:"served_banh,omitempty"`
	MinimumBanh *int32 `json:"minimum_banh,omitempty"`
}
type TamTinh struct {
	Status    string `json:"status"`
	Name      string `json:"name"`
	AmountVnd int64  `json:"amount_vnd"`
}
type Mon struct {
	MenuItemID  *int64 `json:"menu_item_id"`
	MenuComboID *int64 `json:"menu_combo_id"`
	Name        string `json:"name"`
	Ordered     int64  `json:"ordered"`
	Served      int64  `json:"served"`
}
type ThieuMon struct {
	Status string `json:"status"`
	Items  []Mon  `json:"items"`
}
type soTong struct {
	Serving        int64  `json:"serving"`
	ServedBanh     int64  `json:"served_banh"`
	MinimumBanh    *int32 `json:"minimum_banh"`
	MinimumWorkers *int32 `json:"minimum_workers"`
	AmountVnd      int64  `json:"amount_vnd"`
	MenuItems      []Mon  `json:"menu_items"`
}

func (out *TongQuan) apDung(t soTong) {
	out.ServingGuests.Quantity = t.Serving
	out.ProvisionalSales.AmountVnd = t.AmountVnd
	if t.MinimumBanh != nil {
		out.SalesProgress.Status = "available"
		out.SalesProgress.Reason = ""
		out.SalesProgress.MinimumBanh = t.MinimumBanh
		out.SalesProgress.ServedBanh = &t.ServedBanh
	}
	out.Shortages.Workers.MinimumWorkers = t.MinimumWorkers
	out.Shortages.MenuItems.Items = t.MenuItems
}
