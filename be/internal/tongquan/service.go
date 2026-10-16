// Package tongquan gom các nguồn đọc cho chủ quán; không có cửa ghi (P3A-09).
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

// ChuaCo không có trường số: chưa biết không phải số 0.
type ChuaCo struct {
	Status string `json:"status"`
	Name   string `json:"name"`
	Reason string `json:"reason"`
}

func chuaCo(name, reason string) ChuaCo { return ChuaCo{"unavailable", name, reason} }

type Phan struct {
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
	Status string               `json:"status"`
	Items  []nguyenlieu.ChiTiet `json:"items"`
}
type Thieu struct {
	Supplies  NguyenLieu `json:"supplies"`
	Workers   ChuaCo     `json:"workers"`
	MenuItems ChuaCo     `json:"menu_items"`
}

// TongQuan có đúng bảy mục §8.6, ngoài metadata. Không có doanh thu đã đối soát
// trong hình này. Tiền tạm tính chưa có công thức được chốt, không lấy số két thay thế.
type TongQuan struct {
	SaleDate         string    `json:"sale_date"`
	ReadAt           time.Time `json:"read_at"`
	ServingGuests    ChuaCo    `json:"serving_guests"`
	ServedPortions   CacPhan   `json:"served_portions"`
	MissingPortions  CacPhan   `json:"missing_portions"`
	SalesProgress    ChuaCo    `json:"sales_progress"`
	ProvisionalSales ChuaCo    `json:"provisional_sales"`
	WorkersPresent   ChuaCo    `json:"workers_present"`
	Shortages        Thieu     `json:"shortages"`
}

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

func (s *Service) Doc(ctx context.Context, nguoi int64) (out TongQuan, err error) {
	var ngay string
	var moc time.Time
	// Kiểm quyền trước mọi nguồn; đóng giao dịch trước các service khác để không
	// giữ một kết nối trong lúc chờ kết nối thứ hai (pool có thể chỉ có một).
	err = authz.Read(ctx, s.pool, nguoi, authz.NeedOwner, func(tx pgx.Tx) error {
		var e error
		moc, e = ngayban.DongHo(ctx, tx)
		if e != nil {
			return e
		}
		ngay, e = newRepository(tx).ngay(ctx, moc)
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
	details := make([]nguyenlieu.ChiTiet, 0, len(items))
	for _, item := range items {
		detail, e := supplies.DocChiTiet(ctx, nguoi, item.ID)
		if e != nil {
			return out, e
		}
		details = append(details, detail)
	}
	return lap(ngay, moc, board, details)
}

func lap(ngay string, moc time.Time, raw json.RawMessage, supplies []nguyenlieu.ChiTiet) (TongQuan, error) {
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
		a := Phan{StationCode: row.StationCode, MenuComponentID: row.MenuComponentID, ComponentName: row.ComponentName, FillingOptionIDs: row.FillingOptionIDs}
		b := a
		coBan := false
		for _, part := range row.Parts {
			if part.DiningTableID == nil {
				continue
			}
			coBan = true
			a.Quantity += part.Served
			b.Quantity += part.Missing
		}
		if coBan {
			served.Rows = append(served.Rows, a)
			missing.Rows = append(missing.Rows, b)
		}
	}
	return TongQuan{
		SaleDate: ngay, ReadAt: moc,
		ServingGuests:  chuaCo("Khách đang được phục vụ", "guest_count_source_missing"),
		ServedPortions: served, MissingPortions: missing,
		SalesProgress:    chuaCo("Tiến độ bán trong buổi", "sales_progress_definition_unspecified"),
		ProvisionalSales: chuaCo("Tiền bán tạm tính", "provisional_sales_formula_unspecified"),
		WorkersPresent:   chuaCo("Người thực tế đang làm", "pos_headcount_source_missing"),
		Shortages: Thieu{
			Supplies:  NguyenLieu{Status: "available", Items: supplies},
			Workers:   chuaCo("Thiếu người", "staff_shortage_rule_unspecified"),
			MenuItems: chuaCo("Thiếu món trên menu", "menu_shortage_rule_unspecified"),
		},
	}, nil
}
