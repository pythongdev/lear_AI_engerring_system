package yeuthich

import "banhcuon/be/internal/gia"

type FavouriteLineInput = gia.DongYeuCau

type FavouriteLine struct {
	FavouriteLineID int64            `json:"favourite_line_id"`
	MenuItemID      *int64           `json:"menu_item_id"`
	MenuComboID     *int64           `json:"menu_combo_id"`
	OptionIDs       []int64          `json:"option_ids"`
	Portions        []gia.SuatYeuCau `json:"portions"`
	Quantity        int32            `json:"quantity"`
	Available       bool             `json:"available"`
	UnavailableCode *string          `json:"unavailable_code"`
}

type FavouriteSetInput struct {
	Kind  string               `json:"kind"`
	Name  string               `json:"name"`
	Lines []FavouriteLineInput `json:"lines"`
}

type FavouriteSet struct {
	FavouriteSetID int64           `json:"favourite_set_id"`
	Kind           string          `json:"kind"`
	Name           string          `json:"name"`
	Lines          []FavouriteLine `json:"lines"`
}

type Favourites struct {
	Lines []FavouriteLine `json:"lines"`
	Sets  []FavouriteSet  `json:"sets"`
}

func (l FavouriteLine) request() FavouriteLineInput {
	in := FavouriteLineInput{Quantity: l.Quantity, OptionIDs: l.OptionIDs, Portions: l.Portions}
	if l.MenuItemID != nil {
		in.MenuItemID = *l.MenuItemID
	}
	if l.MenuComboID != nil {
		in.MenuComboID = *l.MenuComboID
	}
	return in
}
