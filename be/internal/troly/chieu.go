package troly

import (
	"banhcuon/be/internal/nguyenlieu"
	"banhcuon/be/internal/tongquan"
	"encoding/json"
	"time"
)

// Các kiểu riêng chỉ khai trường được phép gửi tới model (I-043).

type bangPhucVu struct {
	SaleDate    string        `json:"sale_date"`
	ReadAt      time.Time     `json:"read_at"`
	Sessions    []phienPhucVu `json:"sessions"`
	EmptyTables []banPhucVu   `json:"empty_tables"`
}

type phienPhucVu struct {
	TableSessionID int64       `json:"table_session_id"`
	SessionStatus  string      `json:"session_status"`
	ServiceGroup   string      `json:"service_group"`
	Tables         []banPhucVu `json:"tables"`
	Items          []thuPhucVu `json:"items"`
}

type banPhucVu struct {
	Label string `json:"label"`
}

type thuPhucVu struct {
	ComponentName string          `json:"component_name"`
	Options       []luaChonPhucVu `json:"options"`
	ExtraFilling  bool            `json:"extra_filling"`
	Ordered       int64           `json:"ordered"`
	Served        int64           `json:"served"`
	Missing       int64           `json:"missing"`
}

type luaChonPhucVu struct {
	OptionGroupName string `json:"option_group_name"`
	OptionName      string `json:"option_name"`
}

type tongQuanChoModel struct {
	SaleDate         string           `json:"sale_date"`
	ReadAt           time.Time        `json:"read_at"`
	ServingGuests    soPhienChoModel  `json:"serving_guests"`
	ServedPortions   cacPhanChoModel  `json:"served_portions"`
	MissingPortions  cacPhanChoModel  `json:"missing_portions"`
	SalesProgress    tienDoChoModel   `json:"sales_progress"`
	ProvisionalSales tamTinhChoModel  `json:"provisional_sales"`
	WorkersPresent   mucNguoiChoModel `json:"workers_present"`
	Shortages        thieuChoModel    `json:"shortages"`
}

type soPhienChoModel struct {
	Status   string `json:"status"`
	Name     string `json:"name"`
	Quantity int64  `json:"quantity"`
}

type cacPhanChoModel struct {
	Status string         `json:"status"`
	ReadAt time.Time      `json:"read_at"`
	Rows   []phanChoModel `json:"rows"`
}

type phanChoModel struct {
	Group         string `json:"group"`
	StationCode   string `json:"station_code"`
	ComponentName string `json:"component_name"`
	Quantity      int64  `json:"quantity"`
}

type tienDoChoModel struct {
	Status      string `json:"status"`
	Name        string `json:"name"`
	Reason      string `json:"reason,omitempty"`
	ServedBanh  *int64 `json:"served_banh,omitempty"`
	MinimumBanh *int32 `json:"minimum_banh,omitempty"`
}

type tamTinhChoModel struct {
	Status    string `json:"status"`
	Name      string `json:"name"`
	AmountVnd int64  `json:"amount_vnd"`
}

type mucNguoiChoModel struct {
	Status         string     `json:"status"`
	Name           string     `json:"name"`
	Reason         string     `json:"reason,omitempty"`
	WorkerCount    *int32     `json:"worker_count,omitempty"`
	DeclaredAt     *time.Time `json:"declared_at,omitempty"`
	MinimumWorkers *int32     `json:"minimum_workers,omitempty"`
	Short          *bool      `json:"short,omitempty"`
	MissingWorkers *int32     `json:"missing_workers,omitempty"`
}

type thieuChoModel struct {
	Supplies  nguyenLieuChoModel `json:"supplies"`
	Workers   mucNguoiChoModel   `json:"workers"`
	MenuItems thieuMonChoModel   `json:"menu_items"`
}

type nguyenLieuChoModel struct {
	Status string        `json:"status"`
	Items  []thuChoModel `json:"items"`
}

type thuChoModel struct {
	Name           string  `json:"name"`
	PurchaseUnit   *string `json:"purchase_unit"`
	Balance        string  `json:"balance"`
	ReminderStatus string  `json:"reminder_status"`
	CheckReminder  bool    `json:"check_reminder"`
}

type thieuMonChoModel struct {
	Status string        `json:"status"`
	Items  []monChoModel `json:"items"`
}

type monChoModel struct {
	Name    string `json:"name"`
	Ordered int64  `json:"ordered"`
	Served  int64  `json:"served"`
}

// ChieuBangPhucVu giữ số phục vụ, không đưa tiền hay lịch sử người đem ra tới model.
func ChieuBangPhucVu(v tongquan.BangVanHanh) (json.RawMessage, error) {
	return json.Marshal(chieuBangVanHanh(v))
}

// ChieuTongQuan giữ các số tổng quan và bỏ định danh người khai.
func ChieuTongQuan(v tongquan.TongQuan) (json.RawMessage, error) {
	return json.Marshal(chieuTongQuan(v))
}

func chieuBangVanHanh(v tongquan.BangVanHanh) bangPhucVu {
	out := bangPhucVu{
		SaleDate:    v.SaleDate,
		ReadAt:      v.ReadAt,
		Sessions:    make([]phienPhucVu, 0, len(v.Sessions)),
		EmptyTables: make([]banPhucVu, 0, len(v.EmptyTables)),
	}
	for _, x := range v.Sessions {
		out.Sessions = append(out.Sessions, chieuPhienBan(x))
	}
	for _, x := range v.EmptyTables {
		out.EmptyTables = append(out.EmptyTables, chieuBanTrong(x))
	}
	return out
}

func chieuPhienBan(v tongquan.PhienBan) phienPhucVu {
	out := phienPhucVu{
		TableSessionID: v.TableSessionID,
		SessionStatus:  v.SessionStatus,
		ServiceGroup:   v.ServiceGroup,
		Tables:         make([]banPhucVu, 0, len(v.Tables)),
		Items:          make([]thuPhucVu, 0, len(v.Items)),
	}
	for _, x := range v.Tables {
		out.Tables = append(out.Tables, chieuBanTrong(x))
	}
	for _, x := range v.Items {
		out.Items = append(out.Items, chieuThuCuaBan(x))
	}
	return out
}

func chieuBanTrong(v tongquan.BanTrong) banPhucVu {
	out := banPhucVu{
		Label: v.Label,
	}

	return out
}

func chieuThuCuaBan(v tongquan.ThuCuaBan) thuPhucVu {
	out := thuPhucVu{
		ComponentName: v.ComponentName,
		Options:       make([]luaChonPhucVu, 0, len(v.Options)),
		ExtraFilling:  v.ExtraFilling,
		Ordered:       v.Ordered,
		Served:        v.Served,
		Missing:       v.Missing,
	}
	for _, x := range v.Options {
		out.Options = append(out.Options, chieuLuaChonChup(x))
	}
	return out
}

func chieuLuaChonChup(v tongquan.LuaChonChup) luaChonPhucVu {
	out := luaChonPhucVu{
		OptionGroupName: v.OptionGroupName,
		OptionName:      v.OptionName,
	}

	return out
}

func chieuTongQuan(v tongquan.TongQuan) tongQuanChoModel {
	out := tongQuanChoModel{
		SaleDate:         v.SaleDate,
		ReadAt:           v.ReadAt,
		ServingGuests:    chieuSoPhien(v.ServingGuests),
		ServedPortions:   chieuCacPhan(v.ServedPortions),
		MissingPortions:  chieuCacPhan(v.MissingPortions),
		SalesProgress:    chieuTienDo(v.SalesProgress),
		ProvisionalSales: chieuTamTinh(v.ProvisionalSales),
		WorkersPresent:   chieuMucNguoi(v.WorkersPresent),
		Shortages:        chieuThieu(v.Shortages),
	}

	return out
}

func chieuSoPhien(v tongquan.SoPhien) soPhienChoModel {
	out := soPhienChoModel{
		Status:   v.Status,
		Name:     v.Name,
		Quantity: v.Quantity,
	}

	return out
}

func chieuCacPhan(v tongquan.CacPhan) cacPhanChoModel {
	out := cacPhanChoModel{
		Status: v.Status,
		ReadAt: v.ReadAt,
		Rows:   make([]phanChoModel, 0, len(v.Rows)),
	}
	for _, x := range v.Rows {
		out.Rows = append(out.Rows, chieuPhan(x))
	}
	return out
}

func chieuPhan(v tongquan.Phan) phanChoModel {
	out := phanChoModel{
		Group:         v.Group,
		StationCode:   v.StationCode,
		ComponentName: v.ComponentName,
		Quantity:      v.Quantity,
	}

	return out
}

func chieuTienDo(v tongquan.TienDo) tienDoChoModel {
	out := tienDoChoModel{
		Status:      v.Status,
		Name:        v.Name,
		Reason:      v.Reason,
		ServedBanh:  v.ServedBanh,
		MinimumBanh: v.MinimumBanh,
	}

	return out
}

func chieuTamTinh(v tongquan.TamTinh) tamTinhChoModel {
	out := tamTinhChoModel{
		Status:    v.Status,
		Name:      v.Name,
		AmountVnd: v.AmountVnd,
	}

	return out
}

func chieuMucNguoi(v tongquan.MucNguoi) mucNguoiChoModel {
	out := mucNguoiChoModel{
		Status:         v.Status,
		Name:           v.Name,
		Reason:         v.Reason,
		WorkerCount:    v.WorkerCount,
		DeclaredAt:     v.DeclaredAt,
		MinimumWorkers: v.MinimumWorkers,
		Short:          v.Short,
		MissingWorkers: v.MissingWorkers,
	}

	return out
}

func chieuThieu(v tongquan.Thieu) thieuChoModel {
	out := thieuChoModel{
		Supplies:  chieuNguyenLieu(v.Supplies),
		Workers:   chieuMucNguoi(v.Workers),
		MenuItems: chieuThieuMon(v.MenuItems),
	}

	return out
}

func chieuNguyenLieu(v tongquan.NguyenLieu) nguyenLieuChoModel {
	out := nguyenLieuChoModel{
		Status: v.Status,
		Items:  make([]thuChoModel, 0, len(v.Items)),
	}
	for _, x := range v.Items {
		out.Items = append(out.Items, chieuThu(x))
	}
	return out
}

func chieuThu(v nguyenlieu.Thu) thuChoModel {
	out := thuChoModel{
		Name:           v.Name,
		PurchaseUnit:   v.PurchaseUnit,
		Balance:        v.Balance,
		ReminderStatus: v.ReminderStatus,
		CheckReminder:  v.CheckReminder,
	}

	return out
}

func chieuThieuMon(v tongquan.ThieuMon) thieuMonChoModel {
	out := thieuMonChoModel{
		Status: v.Status,
		Items:  make([]monChoModel, 0, len(v.Items)),
	}
	for _, x := range v.Items {
		out.Items = append(out.Items, chieuMon(x))
	}
	return out
}

func chieuMon(v tongquan.Mon) monChoModel {
	out := monChoModel{
		Name:    v.Name,
		Ordered: v.Ordered,
		Served:  v.Served,
	}

	return out
}
