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

	"banhcuon/be/internal/apierr"
	"github.com/jackc/pgx/v5"
)

// Querier là thứ đọc được — pool hoặc giao dịch đang mở của cửa.
type Querier interface {
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

type luaChonMenu struct {
	MenuOptionID int64  `json:"menu_option_id"`
	OptionName   string `json:"option_name"`
}

type nhomMenu struct {
	OptionGroupID         int64         `json:"option_group_id"`
	OptionGroupName       string        `json:"option_group_name"`
	PrerequisiteOptionIDs []int64       `json:"prerequisite_option_ids"`
	Options               []luaChonMenu `json:"options"`
}

// Một câu đọc lấy cả tên, thành phần, nhóm và lựa chọn: không trộn hai phiên bản của một
// dòng menu khi chủ quán sửa giữa các lần đọc. Mốc ngừng bán là now() của giao dịch.
const docNhom = `SELECT COALESCE(jsonb_agg(jsonb_build_object(
 'option_group_id', g.id, 'option_group_name', g.name,
 'prerequisite_option_ids', (SELECT COALESCE(jsonb_agg(p.menu_option_id ORDER BY p.menu_option_id), '[]'::jsonb)
   FROM option_group_prerequisite p WHERE p.option_group_id = g.id),
 'options', (SELECT COALESCE(jsonb_agg(jsonb_build_object(
   'menu_option_id', o.id, 'option_name', o.name) ORDER BY o.id), '[]'::jsonb)
   FROM menu_option o WHERE o.option_group_id = g.id)) ORDER BY g.id), '[]'::jsonb)
 FROM menu_item_option_group ig JOIN option_group g ON g.id = ig.option_group_id
 WHERE ig.menu_item_id = $1`

const docMon = `SELECT m.name, COALESCE(m.discontinued_at <= now(), false),
 (SELECT COALESCE(jsonb_agg(jsonb_build_object(
   'menu_component_id', c.id, 'component_name', c.name, 'quantity', ic.quantity,
   'takes_filling', c.takes_filling, 'base_price_vnd', c.base_price_vnd) ORDER BY ic.id), '[]'::jsonb)
  FROM menu_item_component ic JOIN menu_component c ON c.id = ic.menu_component_id
  WHERE ic.menu_item_id = m.id),
 (` + docNhom + `),
 (SELECT COALESCE(jsonb_agg(jsonb_build_object(
   'menu_option_id', o.id, 'option_group_id', g.id, 'option_group_name', g.name,
   'option_name', o.name, 'surcharge_vnd', o.surcharge_vnd) ORDER BY o.id), '[]'::jsonb)
  FROM menu_option o JOIN option_group g ON g.id = o.option_group_id WHERE o.id = ANY($2::bigint[]))
 FROM menu_item m WHERE m.id = $1`

type luaChonDaDoc struct {
	LuaChon
	OptionGroupID int64 `json:"option_group_id"`
}

// Tinh kiểm từng dòng theo thứ tự gửi; lỗi đầu tiên thắng, không có kết quả một phần.
// Mọi tổ hợp phải do người gọi chọn đủ, không có đường tự điền lựa chọn mặc định.
func Tinh(ctx context.Context, q Querier, lines []DongYeuCau) (KetQua, error) {
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
		err := q.QueryRow(ctx, docMon, yc.MenuItemID, yc.OptionIDs).Scan(&d.ItemName, &ngung, &tpJSON, &nhomJSON, &chonJSON)
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
