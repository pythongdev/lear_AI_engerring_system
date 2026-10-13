// Package gia giữ một hàm tính giá cho tính thử, menu và cửa ghi đơn (P3-06, I-009 · I-010 · I-013).
// Không câu ghi nào; giá và điều kiện lựa chọn đều đọc từ menu, không chép dữ kiện quán vào code.
package gia

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"math"
	"sort"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/platform/postgres"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Querier là thứ đọc được — pool hoặc giao dịch đang mở của cửa.
type Querier interface {
	Exec(ctx context.Context, sql string, args ...any) (pgconn.CommandTag, error)
	Query(ctx context.Context, sql string, args ...any) (pgx.Rows, error)
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
}

// DongYeuCau chỉ nhận món, số suất và lựa chọn; không có giá do khách gửi.
type DongYeuCau struct {
	MenuItemID int64   `json:"menu_item_id"`
	Quantity   int32   `json:"quantity"`
	OptionIDs  []int64 `json:"option_ids"`
}

// ThanhPhan và LuaChon là dữ liệu đã dùng để tính, cũng là ảnh chụp cửa ghi đơn cất lại.
type ThanhPhan struct {
	MenuComponentID int64  `json:"menu_component_id"`
	ComponentName   string `json:"component_name"`
	Quantity        int32  `json:"quantity"`
	TakesFilling    bool   `json:"takes_filling"`
	BasePriceVnd    int64  `json:"base_price_vnd"`
}

type LuaChon struct {
	MenuOptionID    int64  `json:"menu_option_id"`
	OptionGroupName string `json:"option_group_name"`
	OptionName      string `json:"option_name"`
	SurchargeVnd    int64  `json:"surcharge_vnd"`
}

type Dong struct {
	MenuItemID   int64       `json:"menu_item_id"`
	ItemName     string      `json:"item_name"`
	Quantity     int32       `json:"quantity"`
	UnitPriceVnd int64       `json:"unit_price_vnd"`
	LineTotalVnd int64       `json:"line_total_vnd"`
	Components   []ThanhPhan `json:"components"`
	Options      []LuaChon   `json:"options"`
}

type KetQua struct {
	Lines    []Dong `json:"lines"`
	TotalVnd int64  `json:"total_vnd"`
}

// IsDefault chỉ để màn gọi món chọn sẵn (§4.6 luật 8, ADR-094); Tinh không đọc nó.
type luaChonMenu struct {
	MenuOptionID int64  `json:"menu_option_id"`
	OptionName   string `json:"option_name"`
	IsDefault    bool   `json:"is_default"`
}

type nhomMenu struct {
	OptionGroupID         int64         `json:"option_group_id"`
	OptionGroupName       string        `json:"option_group_name"`
	PrerequisiteOptionIDs []int64       `json:"prerequisite_option_ids"`
	Options               []luaChonMenu `json:"options"`
}

type luaChonDaDoc struct {
	LuaChon
	OptionGroupID int64 `json:"option_group_id"`
}

// Tinh kiểm từng dòng theo thứ tự gửi; lỗi đầu tiên thắng, không có kết quả một phần.
// Không truyền mốc thì SQL dùng now() của giao dịch; nhập bù truyền sold_at (ADR-099).
// Mọi tổ hợp phải do người gọi chọn đủ, không có đường tự điền lựa chọn mặc định.
func Tinh(ctx context.Context, q Querier, lines []DongYeuCau, taiMoc ...time.Time) (KetQua, error) {
	if len(taiMoc) > 1 {
		return KetQua{}, fmt.Errorf("gia: chỉ nhận một mốc tính giá")
	}
	var moc *time.Time
	if len(taiMoc) == 1 {
		moc = &taiMoc[0]
	}
	if len(lines) == 0 {
		return KetQua{}, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "lines"}
	}
	out := KetQua{Lines: make([]Dong, 0, len(lines))}
	for i, yc := range lines {
		tuChoi := func(code apierr.Code, field string) (KetQua, error) {
			return KetQua{}, apierr.Error{Code: code, Field: fmt.Sprintf("lines[%d].%s", i, field)}
		}
		if yc.Quantity < 1 {
			return tuChoi(apierr.CodeInvalidRequest, "quantity")
		}
		d := Dong{MenuItemID: yc.MenuItemID, Quantity: yc.Quantity, Options: []LuaChon{}}
		var ngung bool
		var tpJSON, nhomJSON, chonJSON []byte
		var err error
		d.ItemName, ngung, tpJSON, nhomJSON, chonJSON, err = newRepository(q).docMon(ctx, yc.MenuItemID, yc.OptionIDs, moc)
		if errors.Is(err, pgx.ErrNoRows) {
			return tuChoi(apierr.CodeMenuItemNotFound, "menu_item_id")
		}
		if err != nil {
			return KetQua{}, err
		}
		if ngung {
			return tuChoi(apierr.CodeMenuItemDiscontinued, "menu_item_id")
		}
		var nhoms []nhomMenu
		var luaChons []luaChonDaDoc
		if err := json.Unmarshal(tpJSON, &d.Components); err != nil {
			return KetQua{}, err
		}
		if err := json.Unmarshal(nhomJSON, &nhoms); err != nil {
			return KetQua{}, err
		}
		if err := json.Unmarshal(chonJSON, &luaChons); err != nil {
			return KetQua{}, err
		}
		theoMa := make(map[int64]luaChonDaDoc, len(luaChons))
		for _, o := range luaChons {
			theoMa[o.MenuOptionID] = o
		}
		// Kiểm tồn tại toàn bộ lựa chọn TRƯỚC khi xét tổ hợp (kể cả mã lặp và mã lạ cùng dòng).
		for _, id := range yc.OptionIDs {
			if _, co := theoMa[id]; !co {
				return tuChoi(apierr.CodeMenuOptionNotFound, "option_ids")
			}
		}
		daChon := make(map[int64]bool, len(yc.OptionIDs))
		theoNhom := make(map[int64]int)
		nhomCuaMon := make(map[int64]bool, len(nhoms))
		for _, g := range nhoms {
			nhomCuaMon[g.OptionGroupID] = true
		}
		for _, id := range yc.OptionIDs {
			o := theoMa[id]
			if daChon[id] || theoNhom[o.OptionGroupID] != 0 || !nhomCuaMon[o.OptionGroupID] {
				return tuChoi(apierr.CodeOptionCombinationInvalid, "option_ids")
			}
			daChon[id] = true
			theoNhom[o.OptionGroupID]++
			d.Options = append(d.Options, o.LuaChon)
		}
		for _, g := range nhoms {
			coMat := len(g.PrerequisiteOptionIDs) == 0
			for _, id := range g.PrerequisiteOptionIDs {
				coMat = coMat || daChon[id]
			}
			if (coMat && theoNhom[g.OptionGroupID] != 1) || (!coMat && theoNhom[g.OptionGroupID] != 0) {
				return tuChoi(apierr.CodeOptionCombinationInvalid, "option_ids")
			}
		}
		if len(d.Components) == 0 {
			log.Printf("gia: lỗi hệ thống: món %d không có thành phần", yc.MenuItemID)
			return KetQua{}, apierr.Error{Code: apierr.CodeInternalError}
		}
		// Số nguyên đồng xuyên suốt. Tràn int64 là lỗi hệ thống, không được quấn về một giá thấp hơn.
		var giaGoc, soNhan, phuThu int64
		for _, c := range d.Components {
			tien, err := nhan(int64(c.Quantity), c.BasePriceVnd)
			if err != nil {
				return KetQua{}, err
			}
			giaGoc, err = cong(giaGoc, tien)
			if err != nil {
				return KetQua{}, err
			}
			if c.TakesFilling {
				soNhan, err = cong(soNhan, int64(c.Quantity))
				if err != nil {
					return KetQua{}, err
				}
			}
		}
		for _, o := range d.Options {
			phuThu, err = cong(phuThu, o.SurchargeVnd)
			if err != nil {
				return KetQua{}, err
			}
		}
		tienNhan, err := nhan(soNhan, phuThu)
		if err != nil {
			return KetQua{}, err
		}
		d.UnitPriceVnd, err = cong(giaGoc, tienNhan)
		if err != nil {
			return KetQua{}, err
		}
		d.LineTotalVnd, err = nhan(d.UnitPriceVnd, int64(d.Quantity))
		if err != nil {
			return KetQua{}, err
		}
		out.TotalVnd, err = cong(out.TotalVnd, d.LineTotalVnd)
		if err != nil {
			return KetQua{}, err
		}
		out.Lines = append(out.Lines, d)
	}
	return out, nil
}

func cong(a, b int64) (int64, error) {
	if a < 0 || b < 0 || a > math.MaxInt64-b {
		return 0, fmt.Errorf("gia: tổng vượt miền số nguyên đồng")
	}
	return a + b, nil
}

func nhan(a, b int64) (int64, error) {
	if a < 0 || b < 0 || (b != 0 && a > math.MaxInt64/b) {
		return 0, fmt.Errorf("gia: tích vượt miền số nguyên đồng")
	}
	return a * b, nil
}

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }
func (s *Service) TinhThu(ctx context.Context, lines []DongYeuCau) (KetQua, error) {
	var out KetQua
	err := postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		var err error
		out, err = Tinh(ctx, tx, lines)
		return err
	})
	return out, err
}

type menuKetQua struct {
	Items []monMenu `json:"items"`
}

type giaMenu struct {
	OptionIDs    []int64 `json:"option_ids"`
	UnitPriceVnd int64   `json:"unit_price_vnd"`
}

type monMenu struct {
	MenuItemID   int64      `json:"menu_item_id"`
	ItemName     string     `json:"item_name"`
	OptionGroups []nhomMenu `json:"option_groups"`
	Prices       []giaMenu  `json:"prices"`
}

func (s *Service) DocMenu(ctx context.Context) (menuKetQua, error) {
	out := menuKetQua{Items: []monMenu{}}
	err := postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		items, err := repo.docMonDangBan(ctx)
		if err != nil {
			return err
		}
		for _, m := range items {
			raw, err := repo.docNhom(ctx, m.MenuItemID)
			if err != nil {
				return err
			}
			if err := json.Unmarshal(raw, &m.OptionGroups); err != nil {
				return err
			}
			// Mỗi nhóm ứng viên: không chọn, hoặc chọn một lựa chọn. Tinh là chỗ duy nhất quyết
			// nhóm có mặt và tổ hợp có hợp lệ không; không mang một bản luật khác vào đường menu.
			if err := keGia(ctx, tx, &m, 0, nil); err != nil {
				return err
			}
			out.Items = append(out.Items, m)
		}
		return nil
	})
	return out, err
}

func keGia(ctx context.Context, q Querier, m *monMenu, nhom int, ids []int64) error {
	if nhom == len(m.OptionGroups) {
		chon := append([]int64{}, ids...)
		sort.Slice(chon, func(i, j int) bool { return chon[i] < chon[j] })
		kq, err := Tinh(ctx, q, []DongYeuCau{{MenuItemID: m.MenuItemID, Quantity: 1, OptionIDs: chon}})
		if err != nil {
			var e apierr.Error
			if errors.As(err, &e) && e.Code == apierr.CodeOptionCombinationInvalid {
				return nil
			}
			return err
		}
		m.Prices = append(m.Prices, giaMenu{OptionIDs: chon, UnitPriceVnd: kq.Lines[0].UnitPriceVnd})
		return nil
	}
	if err := keGia(ctx, q, m, nhom+1, ids); err != nil {
		return err
	}
	for _, o := range m.OptionGroups[nhom].Options {
		if err := keGia(ctx, q, m, nhom+1, append(ids, o.MenuOptionID)); err != nil {
			return err
		}
	}
	return nil
}
