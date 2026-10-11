package gia

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"sort"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/platform/postgres"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Routes đăng ký hai đường đọc không cần danh tính; mỗi yêu cầu đọc trong một giao dịch.
func Routes(mux *http.ServeMux, pool *pgxpool.Pool) {
	h := handler{pool: pool}
	mux.HandleFunc("POST /price-quotes", h.tinhThu)
	mux.HandleFunc("GET /menu", h.docMenu)
}

type handler struct{ pool *pgxpool.Pool }

func (h handler) tinhThu(w http.ResponseWriter, r *http.Request) {
	var yc struct {
		Lines []DongYeuCau `json:"lines"`
	}
	dec := json.NewDecoder(r.Body)
	// Không DisallowUnknownFields: giá gửi lên và mọi trường lạ đều bị bỏ qua (I-013).
	if err := dec.Decode(&yc); err != nil {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest})
		return
	}
	if err := dec.Decode(new(any)); err != io.EOF {
		apierr.Write(w, apierr.Error{Code: apierr.CodeInvalidRequest})
		return
	}
	var out KetQua
	err := postgres.InTx(r.Context(), h.pool, func(tx pgx.Tx) error {
		var err error
		out, err = Tinh(r.Context(), tx, yc.Lines)
		return err
	})
	if err != nil {
		writeErr(w, err)
		return
	}
	writeJSON(w, out)
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

const docMonDangBan = `SELECT id, name FROM menu_item
 WHERE discontinued_at IS NULL OR discontinued_at > now() ORDER BY id`

func (h handler) docMenu(w http.ResponseWriter, r *http.Request) {
	out := struct {
		Items []monMenu `json:"items"`
	}{Items: []monMenu{}}
	err := postgres.InTx(r.Context(), h.pool, func(tx pgx.Tx) error {
		rows, err := tx.Query(r.Context(), docMonDangBan)
		if err != nil {
			return err
		}
		items, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (monMenu, error) {
			m := monMenu{OptionGroups: []nhomMenu{}, Prices: []giaMenu{}}
			err := row.Scan(&m.MenuItemID, &m.ItemName)
			return m, err
		})
		if err != nil {
			return err
		}
		for _, m := range items {
			var raw []byte
			if err := tx.QueryRow(r.Context(), docNhom, m.MenuItemID).Scan(&raw); err != nil {
				return err
			}
			if err := json.Unmarshal(raw, &m.OptionGroups); err != nil {
				return err
			}
			// Mỗi nhóm ứng viên: không chọn, hoặc chọn một lựa chọn. Tinh là chỗ duy nhất quyết
			// nhóm có mặt và tổ hợp có hợp lệ không; không mang một bản luật khác vào đường menu.
			if err := keGia(r.Context(), tx, &m, 0, nil); err != nil {
				return err
			}
			out.Items = append(out.Items, m)
		}
		return nil
	})
	if err != nil {
		writeErr(w, err)
		return
	}
	writeJSON(w, out)
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

// writeErr giữ lời từ chối có mã; lỗi hệ thống chỉ ghi log, không gửi câu database xuống dây.
func writeErr(w http.ResponseWriter, err error) {
	var e apierr.Error
	if errors.As(err, &e) {
		apierr.Write(w, e)
		return
	}
	e, name := apierr.FromDB(err)
	if e.Code == apierr.CodeInternalError {
		log.Printf("gia: lỗi hệ thống (tên từ chối %q): %v", name, err)
	}
	apierr.Write(w, e)
}

func writeJSON(w http.ResponseWriter, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_ = json.NewEncoder(w).Encode(v)
}
