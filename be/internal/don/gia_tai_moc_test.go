package don_test

import (
	"context"
	"errors"
	"fmt"
	"testing"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/platform/postgres"
	"github.com/jackc/pgx/v5"
)

// Phần hàm giá của ADR-099; chưa thay ca nghiệm thu qua cửa nhập bù.
func TestI009_GiaTaiMocDungVetSomNhat(t *testing.T) {
	c := dungBan(t)
	tp := c.id(t, "INSERT INTO shop.menu_component(name,base_price_vnd,takes_filling) VALUES ($1,1000,false) RETURNING id", t.Name())
	mon := c.id(t, "INSERT INTO shop.menu_item(name) VALUES ($1) RETURNING id", t.Name())
	c.id(t, "INSERT INTO shop.menu_item_component(menu_item_id,menu_component_id,quantity) VALUES ($1,$2,2) RETURNING id", mon, tp)
	var sold time.Time
	if err := c.owner.QueryRow(c.ctx, "SELECT clock_timestamp()").Scan(&sold); err != nil {
		t.Fatal(err)
	}
	for _, price := range []int64{2000, 3000} {
		c.suaMenu(t, c.chu, "PUT", fmt.Sprintf("/menu-components/%d/base-price", tp), map[string]any{"base_price_vnd": price, "reason": "kiểm giá tại mốc"})
	}
	lines := []gia.DongYeuCau{{MenuItemID: mon, Quantity: 1, OptionIDs: []int64{}}}
	tinh := func(at ...time.Time) (gia.KetQua, error) {
		var out gia.KetQua
		err := postgres.InTx(c.ctx, c.pool, func(tx pgx.Tx) error {
			var err error
			out, err = gia.Tinh(c.ctx, tx, lines, at...)
			return err
		})
		return out, err
	}
	cu, err := tinh(sold)
	if err != nil || cu.TotalVnd != 2000 {
		t.Fatalf("giá trước hai lần sửa: %+v, %v", cu, err)
	}
	moi, err := tinh()
	if err != nil || moi.TotalVnd != 6000 {
		t.Fatalf("giá hiện tại: %+v, %v", moi, err)
	}
	ban := c.banMoi(t, "giá mới")
	r := c.datHo(t, c.quay, ban, dauLanGui(t), map[string]any{"menu_item_id": mon, "quantity": 1, "option_ids": []int64{}})
	canDat(t, r, 201)
	if r.so(t, "total_vnd") != 6000 {
		t.Fatalf("đơn mới không dùng giá mới: %v", r.body)
	}
	c.suaMenu(t, c.chu, "POST", fmt.Sprintf("/menu-items/%d/discontinuation", mon), map[string]any{"reason": "kiểm ngừng sau mốc"})
	cu, err = tinh(sold)
	if err != nil || cu.TotalVnd != 2000 {
		t.Fatalf("món ngừng sau mốc: %+v, %v", cu, err)
	}
	_, err = tinh()
	var e apierr.Error
	if !errors.As(err, &e) || e.Code != apierr.CodeMenuItemDiscontinued {
		t.Fatalf("hiện tại phải ngừng bán: %v", err)
	}
	// Mốc trước khi tạo món: không được dựng một món chưa tồn tại từ bản hiện tại.
	var created time.Time
	if err := c.owner.QueryRow(c.ctx, "SELECT created_at FROM shop.menu_item WHERE id=$1", mon).Scan(&created); err != nil {
		t.Fatal(err)
	}
	_, err = tinh(created.Add(-time.Microsecond))
	if !errors.As(err, &e) || e.Code != apierr.CodeMenuItemNotFound {
		t.Fatalf("món tạo sau mốc: %v", err)
	}
}

// Mốc mặc định phải là now() của giao dịch, không phải đồng hồ Go hay lần đọc từng dòng.
func TestI009_GiaMacDinhDungMocGiaoDich(t *testing.T) {
	c := dungBan(t)
	tp := c.id(t, "INSERT INTO shop.menu_component(name,base_price_vnd,takes_filling) VALUES ($1,1000,false) RETURNING id", t.Name())
	mon := c.id(t, "INSERT INTO shop.menu_item(name) VALUES ($1) RETURNING id", t.Name())
	c.id(t, "INSERT INTO shop.menu_item_component(menu_item_id,menu_component_id,quantity) VALUES ($1,$2,1) RETURNING id", mon, tp)
	err := postgres.InTx(context.Background(), c.pool, func(tx pgx.Tx) error {
		// Mở giao dịch trước lần sửa bằng kết nối khác; READ COMMITTED nhìn được vết mới.
		var at time.Time
		if err := tx.QueryRow(c.ctx, "SELECT now()").Scan(&at); err != nil {
			return err
		}
		c.suaMenu(t, c.chu, "PUT", fmt.Sprintf("/menu-components/%d/base-price", tp), map[string]any{"base_price_vnd": 2000, "reason": "sửa sau mốc giao dịch"})
		out, err := gia.Tinh(c.ctx, tx, []gia.DongYeuCau{{MenuItemID: mon, Quantity: 1, OptionIDs: []int64{}}})
		if err != nil {
			return err
		}
		if out.TotalVnd != 1000 {
			return fmt.Errorf("giá ở now() %s phải là 1000, nhận %d", at, out.TotalVnd)
		}
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
}
