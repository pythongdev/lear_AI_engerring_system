package yeuthich

import (
	"context"
	"fmt"
	"slices"

	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/yeuthich/internal/sqlcgen"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
)

type repository struct{ *sqlcgen.Queries }

func repo(tx pgx.Tx) repository       { return repository{sqlcgen.New(tx)} }
func nullableID(id int64) pgtype.Int8 { return pgtype.Int8{Int64: id, Valid: id != 0} }
func pointerID(id pgtype.Int8) *int64 {
	if !id.Valid {
		return nil
	}
	return &id.Int64
}

func (r repository) findLine(ctx context.Context, customer, id int64) (int64, error) {
	return r.DocTim(ctx, sqlcgen.DocTimParams{ID: id, CustomerAccountID: customer})
}

func (r repository) findSet(ctx context.Context, customer, id int64) (FavouriteSet, error) {
	set, err := r.TimBo(ctx, sqlcgen.TimBoParams{ID: id, CustomerAccountID: customer})
	return FavouriteSet{FavouriteSetID: set.ID, Kind: set.Kind, Name: set.Name}, err
}

func (r repository) setQuantity(ctx context.Context, customer, id int64, quantity int32) error {
	return r.SoLuong(ctx, sqlcgen.SoLuongParams{ID: id, CustomerAccountID: customer, Quantity: quantity})
}

func (r repository) insertSet(ctx context.Context, customer int64, in FavouriteSetInput) (int64, error) {
	return r.ThemBo(ctx, sqlcgen.ThemBoParams{CustomerAccountID: customer, Kind: in.Kind, Name: in.Name})
}

func (r repository) renameSet(ctx context.Context, customer, id int64, name string) error {
	return r.DoiTen(ctx, sqlcgen.DoiTenParams{ID: id, CustomerAccountID: customer, Name: name})
}

func (r repository) removeSetLines(ctx context.Context, customer, id int64) error {
	return r.GoDongBo(ctx, sqlcgen.GoDongBoParams{CustomerAccountID: customer, FavouriteSetID: nullableID(id)})
}

func (r repository) removeSet(ctx context.Context, customer, id int64) error {
	return r.GoBo(ctx, sqlcgen.GoBoParams{ID: id, CustomerAccountID: customer})
}

func (r repository) removeLine(ctx context.Context, customer, id int64) error {
	if err := r.GoSuat(ctx, sqlcgen.GoSuatParams{CustomerAccountID: customer, ParentLineID: nullableID(id)}); err != nil {
		return err
	}
	return r.GoDong(ctx, sqlcgen.GoDongParams{CustomerAccountID: customer, ID: id})
}

func (r repository) load(ctx context.Context, customer int64) (Favourites, error) {
	out := Favourites{Lines: []FavouriteLine{}, Sets: []FavouriteSet{}}
	sets, err := r.DocBo(ctx, customer)
	if err != nil {
		return out, err
	}
	rows, err := r.DocDong(ctx, customer)
	if err != nil {
		return out, err
	}
	children := make(map[int64][]gia.SuatYeuCau)
	for _, row := range rows {
		if row.ParentLineID.Valid {
			children[row.ParentLineID.Int64] = append(children[row.ParentLineID.Int64], gia.SuatYeuCau{
				MenuItemID: row.MenuItemID.Int64, Quantity: row.Quantity, OptionIDs: append([]int64{}, row.OptionIds...),
			})
		}
	}
	bySet := make(map[int64][]FavouriteLine)
	for _, row := range rows {
		if row.ParentLineID.Valid {
			continue
		}
		line := FavouriteLine{FavouriteLineID: row.ID, MenuItemID: pointerID(row.MenuItemID),
			MenuComboID: pointerID(row.MenuComboID), Quantity: row.Quantity,
			OptionIDs: append([]int64{}, row.OptionIds...), Portions: append([]gia.SuatYeuCau{}, children[row.ID]...)}
		if row.FavouriteSetID.Valid {
			bySet[row.FavouriteSetID.Int64] = append(bySet[row.FavouriteSetID.Int64], line)
		} else {
			out.Lines = append(out.Lines, line)
		}
	}
	for _, set := range sets {
		out.Sets = append(out.Sets, FavouriteSet{FavouriteSetID: set.ID, Kind: set.Kind, Name: set.Name,
			Lines: append([]FavouriteLine{}, bySet[set.ID]...)})
	}
	return out, nil
}

// Các cửa tạo bộ và sửa gọi lại ô thêm của tha_tim trong giao dịch đã kiểm khách.
func (r repository) insert(ctx context.Context, customer, set int64, in FavouriteLineInput) (int64, error) {
	id, err := r.ThemDong(ctx, sqlcgen.ThemDongParams{CustomerAccountID: customer, FavouriteSetID: nullableID(set),
		MenuItemID: nullableID(in.MenuItemID), MenuComboID: nullableID(in.MenuComboID), Quantity: in.Quantity})
	if err != nil {
		return 0, err
	}
	if err = r.ThemChon(ctx, sqlcgen.ThemChonParams{FavouriteLineID: id, Column2: in.OptionIDs}); err != nil {
		return 0, err
	}
	return id, r.insertPortions(ctx, customer, set, id, in.Portions)
}

func (r repository) insertPortions(ctx context.Context, customer, set, parent int64, portions []gia.SuatYeuCau) error {
	for _, p := range portions {
		// Giữ nguyên tổng suất mà gia.Tinh đã nhận. Mỗi dòng vật lý bị giới hạn 99,
		// còn một nhóm suất có thể lớn hơn (ví dụ 99 combo, mỗi combo hai suất).
		for remaining := p.Quantity; remaining > 0; {
			n := min(remaining, 99)
			id, err := r.ThemDong(ctx, sqlcgen.ThemDongParams{CustomerAccountID: customer, FavouriteSetID: nullableID(set),
				ParentLineID: nullableID(parent), MenuItemID: nullableID(p.MenuItemID), Quantity: n})
			if err != nil {
				return err
			}
			if err = r.ThemChon(ctx, sqlcgen.ThemChonParams{FavouriteLineID: id, Column2: p.OptionIDs}); err != nil {
				return err
			}
			remaining -= n
		}
	}
	return nil
}

func sortedOptions(ids []int64) []int64 {
	out := append([]int64{}, ids...)
	slices.Sort(out)
	return out
}

// Tập suất so theo món, tập lựa chọn và tỉ lệ số suất trên số combo;
// thứ tự gửi và cách chia các suất cùng hình thành nhóm không đổi hình dòng.
func sameShape(a, b FavouriteLineInput) bool {
	if a.MenuItemID != b.MenuItemID || a.MenuComboID != b.MenuComboID ||
		!slices.Equal(sortedOptions(a.OptionIDs), sortedOptions(b.OptionIDs)) {
		return false
	}
	counts := func(portions []gia.SuatYeuCau) map[string]int64 {
		out := make(map[string]int64)
		for _, p := range portions {
			out[fmt.Sprintf("%d:%v", p.MenuItemID, sortedOptions(p.OptionIDs))] += int64(p.Quantity)
		}
		return out
	}
	x, y := counts(a.Portions), counts(b.Portions)
	if len(x) != len(y) {
		return false
	}
	for k, n := range x {
		if n*int64(b.Quantity) != y[k]*int64(a.Quantity) {
			return false
		}
	}
	return true
}
