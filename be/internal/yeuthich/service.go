// Package yeuthich lưu dòng tim và bộ món theo tài khoản khách (ADR-145, YT-04).
// gia.Tinh là bước kiểm menu duy nhất; kết quả tính không được cất vào yêu thích.
package yeuthich

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"unicode/utf8"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/gia"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

func (s *Service) run(ctx context.Context, token string, door authz.Door, fn func(pgx.Tx, repository, int64) error) error {
	return authz.RunAs(ctx, s.pool, authz.Caller{CustomerToken: token}, door, func(tx pgx.Tx, g authz.Granted) error {
		r := repo(tx)
		// Câu khoá riêng trước câu đọc để thấy lần ghi vừa commit khi phải chờ khoá.
		if _, err := r.KhoaKhach(ctx, g.CustomerAccountID); err != nil {
			return err
		}
		if err := r.KhaiLyDo(ctx, door.Code); err != nil {
			return err
		}
		return fn(tx, r, g.CustomerAccountID)
	})
}

func (s *Service) read(ctx context.Context, token string) (Favourites, error) {
	var out Favourites
	err := authz.ReadAs(ctx, s.pool, authz.Caller{CustomerToken: token}, Doc.Need, func(tx pgx.Tx, g authz.Granted) error {
		r := repo(tx)
		// Giữ bộ và các dòng cùng một trạng thái trong lúc ghép các câu đọc.
		if _, err := r.KhoaKhach(ctx, g.CustomerAccountID); err != nil {
			return err
		}
		var err error
		if out, err = r.load(ctx, g.CustomerAccountID); err != nil {
			return err
		}
		check := func(lines []FavouriteLine) error {
			for i := range lines {
				_, err := gia.Tinh(ctx, tx, []gia.DongYeuCau{lines[i].request()})
				if err == nil {
					lines[i].Available = true
					continue
				}
				var e apierr.Error
				if !errors.As(err, &e) {
					return err
				}
				code := string(e.Code)
				lines[i].UnavailableCode = &code
			}
			return nil
		}
		if err = check(out.Lines); err != nil {
			return err
		}
		for i := range out.Sets {
			if err = check(out.Sets[i].Lines); err != nil {
				return err
			}
		}
		return nil
	})
	return out, err
}

func validateLines(ctx context.Context, tx pgx.Tx, lines []FavouriteLineInput) error {
	if _, err := gia.Tinh(ctx, tx, lines); err != nil {
		return err
	}
	// Giới hạn riêng của yêu thích; mọi kiểm hình/menu vẫn do gia.Tinh ở trên.
	for i, line := range lines {
		if line.Quantity > 99 {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: fmt.Sprintf("lines[%d].quantity", i)}
		}
	}
	return nil
}

func requireLine(ctx context.Context, r repository, customer, id int64) error {
	_, err := r.findLine(ctx, customer, id)
	if errors.Is(err, pgx.ErrNoRows) {
		return apierr.Error{Code: apierr.CodeFavouriteLineNotFound}
	}
	return err
}

func requireSet(ctx context.Context, r repository, customer, id int64) (FavouriteSet, error) {
	set, err := r.findSet(ctx, customer, id)
	if errors.Is(err, pgx.ErrNoRows) {
		err = apierr.Error{Code: apierr.CodeFavouriteSetNotFound}
	}
	return set, err
}

func (s *Service) saveLine(ctx context.Context, token string, id int64, in FavouriteLineInput) (FavouriteLine, error) {
	var out FavouriteLine
	door := ThaTim
	if id != 0 {
		door = SuaTim
	}
	err := s.run(ctx, token, door, func(tx pgx.Tx, r repository, customer int64) error {
		if id != 0 {
			if err := requireLine(ctx, r, customer, id); err != nil {
				return err
			}
		}
		if err := validateLines(ctx, tx, []FavouriteLineInput{in}); err != nil {
			return err
		}
		if id != 0 {
			if err := r.removeLine(ctx, customer, id); err != nil {
				return err
			}
		}
		all, err := r.load(ctx, customer)
		if err != nil {
			return err
		}
		var saved int64
		for _, old := range all.Lines {
			if !sameShape(old.request(), in) {
				continue
			}
			if old.Quantity+in.Quantity > 99 {
				return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "quantity"}
			}
			saved = old.FavouriteLineID
			if err = r.setQuantity(ctx, customer, saved, old.Quantity+in.Quantity); err != nil {
				return err
			}
			// Suất của nhóm combo mới cộng vào tổng suất của dòng đang giữ.
			if err = r.insertPortions(ctx, customer, 0, saved, in.Portions); err != nil {
				return err
			}
			break
		}
		if saved == 0 {
			if saved, err = r.insert(ctx, customer, 0, in); err != nil {
				return err
			}
		}
		all, err = r.load(ctx, customer)
		if err != nil {
			return err
		}
		for _, line := range all.Lines {
			if line.FavouriteLineID == saved {
				out = line
				out.Available = true
				return nil
			}
		}
		return apierr.Error{Code: apierr.CodeInternalError}
	})
	return out, err
}

func (s *Service) removeLine(ctx context.Context, token string, id int64) error {
	return s.run(ctx, token, BoTim, func(_ pgx.Tx, r repository, customer int64) error {
		if err := requireLine(ctx, r, customer, id); err != nil {
			return err
		}
		return r.removeLine(ctx, customer, id)
	})
}

func (s *Service) saveSet(ctx context.Context, token string, id int64, in FavouriteSetInput) (FavouriteSet, error) {
	var out FavouriteSet
	door := TaoBo
	if id != 0 {
		door = SuaBo
	}
	err := s.run(ctx, token, door, func(tx pgx.Tx, r repository, customer int64) error {
		if id != 0 {
			old, err := requireSet(ctx, r, customer, id)
			if err != nil {
				return err
			}
			in.Kind = old.Kind
		}
		if strings.Trim(in.Name, " ") == "" || utf8.RuneCountInString(in.Name) > 60 {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "name"}
		}
		if in.Kind != "rieng" && in.Kind != "da_luu" {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "kind"}
		}
		if err := validateLines(ctx, tx, in.Lines); err != nil {
			return err
		}
		if id == 0 {
			var err error
			id, err = r.insertSet(ctx, customer, in)
			if err != nil {
				return err
			}
		} else {
			if err := r.renameSet(ctx, customer, id, in.Name); err != nil {
				return err
			}
			if err := r.removeSetLines(ctx, customer, id); err != nil {
				return err
			}
		}
		for _, line := range in.Lines {
			if _, err := r.insert(ctx, customer, id, line); err != nil {
				return err
			}
		}
		all, err := r.load(ctx, customer)
		if err != nil {
			return err
		}
		for _, set := range all.Sets {
			if set.FavouriteSetID == id {
				out = set
				for i := range out.Lines {
					out.Lines[i].Available = true
				}
				return nil
			}
		}
		return apierr.Error{Code: apierr.CodeInternalError}
	})
	return out, err
}

func (s *Service) removeSet(ctx context.Context, token string, id int64) error {
	return s.run(ctx, token, XoaBo, func(_ pgx.Tx, r repository, customer int64) error {
		if _, err := requireSet(ctx, r, customer, id); err != nil {
			return err
		}
		return r.removeSet(ctx, customer, id)
	})
}
