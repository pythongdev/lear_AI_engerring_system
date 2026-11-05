package danhgia

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"

	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/troly"
	"github.com/jackc/pgx/v5/pgxpool"
)

type ChuanBi struct {
	Ca            Ca
	ThamSoTinhGia json.RawMessage
	GiaChuan      int64
	LoiTinhGia    error
}
type MoiTruong struct {
	Pool               *pgxpool.Pool
	CauHinh            troly.CauHinh
	Menu               *gia.Service
	CongCu             []troly.CongCu
	DuocPhep, TenRieng []string
}

// Nhúng giao diện để giữ nguyên Ma, Model và Gia của nhà bên trong.
type nhaGhi struct {
	troly.NhaCungCap
	daGui []troly.GoiModel
}

func (n *nhaGhi) Goi(ctx context.Context, g troly.GoiModel) (troly.PhanHoi, error) {
	ban := g
	ban.LichSu = append([]troly.Tin(nil), g.LichSu...)
	ban.CongCu = append([]string(nil), g.CongCu...)
	ban.Buoc = append([]troly.BuocCongCu(nil), g.Buoc...)
	for i := range ban.Buoc {
		ban.Buoc[i].LoiGoi.ThamSo = append(json.RawMessage(nil), g.Buoc[i].LoiGoi.ThamSo...)
		ban.Buoc[i].KetQua = append(json.RawMessage(nil), g.Buoc[i].KetQua...)
	}
	n.daGui = append(n.daGui, ban)
	return n.NhaCungCap.Goi(ctx, g)
}

func chuanBi(ctx context.Context, mt MoiTruong, ca Ca) (ChuanBi, error) {
	cb := ChuanBi{Ca: ca}
	cb.Ca.LichSu = append([]troly.Tin(nil), ca.LichSu...)
	if len(ca.Dong) > 0 {
		if mt.Menu == nil {
			return cb, fmt.Errorf("thiếu service menu")
		}
		menu, err := mt.Menu.DocMenu(ctx)
		if err != nil {
			return cb, err
		}
		mon := func(d DongTheoTen) (gia.SuatYeuCau, error) {
			for _, m := range menu.Items {
				if m.ItemName != d.Mon {
					continue
				}
				p := gia.SuatYeuCau{MenuItemID: m.MenuItemID, Quantity: d.SoLuong, OptionIDs: []int64{}}
				for _, ten := range d.LuaChon {
					var id int64
					for _, nhom := range m.OptionGroups {
						for _, o := range nhom.Options {
							if o.OptionName == ten {
								if id != 0 {
									return p, fmt.Errorf("lựa chọn %q không duy nhất trong món %q", ten, d.Mon)
								}
								id = o.MenuOptionID
							}
						}
					}
					if id == 0 {
						return p, fmt.Errorf("không tìm thấy lựa chọn %q của món %q", ten, d.Mon)
					}
					p.OptionIDs = append(p.OptionIDs, id)
				}
				return p, nil
			}
			return gia.SuatYeuCau{}, fmt.Errorf("không tìm thấy món %q", d.Mon)
		}
		lines := make([]gia.DongYeuCau, 0, len(ca.Dong))
		for _, d := range ca.Dong {
			line := gia.DongYeuCau{Quantity: d.SoLuong}
			if d.Combo != "" {
				for _, c := range menu.Combos {
					if c.Name == d.Combo {
						line.MenuComboID = c.MenuComboID
						break
					}
				}
				if line.MenuComboID == 0 {
					return cb, fmt.Errorf("không tìm thấy combo %q", d.Combo)
				}
				for _, suat := range d.Suat {
					p, err := mon(suat)
					if err != nil {
						return cb, err
					}
					line.Portions = append(line.Portions, p)
				}
			} else {
				p, err := mon(d)
				if err != nil {
					return cb, err
				}
				line.MenuItemID, line.OptionIDs = p.MenuItemID, p.OptionIDs
			}
			lines = append(lines, line)
		}
		cb.ThamSoTinhGia, err = json.Marshal(struct {
			Lines []gia.DongYeuCau `json:"lines"`
		}{lines})
		if err != nil {
			return cb, err
		}
		kq, err := mt.Menu.TinhThu(ctx, lines)
		cb.LoiTinhGia = err
		if ca.Loai == CoGia && err != nil {
			return cb, fmt.Errorf("tính giá chuẩn: %w", err)
		}
		if err == nil {
			cb.GiaChuan = kq.TotalVnd
		}
	}
	thay := func(s string) (string, error) {
		if strings.Contains(s, "{ten_rieng}") {
			if len(mt.TenRieng) == 0 {
				return "", fmt.Errorf("thiếu tên riêng để thay dấu chỗ")
			}
			s = strings.ReplaceAll(s, "{ten_rieng}", mt.TenRieng[0])
		}
		cu := fmt.Sprint(cb.GiaChuan + 5000)
		for i := len(cu) - 3; i > 0; i -= 3 {
			cu = cu[:i] + "." + cu[i:]
		}
		return strings.ReplaceAll(s, "{gia_cu}", cu+" đồng"), nil
	}
	var err error
	cb.Ca.Cau, err = thay(cb.Ca.Cau)
	if err != nil {
		return cb, err
	}
	for i := range cb.Ca.LichSu {
		cb.Ca.LichSu[i].Chu, err = thay(cb.Ca.LichSu[i].Chu)
		if err != nil {
			return cb, err
		}
	}
	return cb, nil
}

func Chay(ctx context.Context, mt MoiTruong, cacCa []Ca, moiNha func(ChuanBi) troly.NhaCungCap) (BaoCao, error) {
	var bc BaoCao
	if moiNha == nil {
		return bc, fmt.Errorf("thiếu hàm dựng nhà giả")
	}
	for _, ca := range cacCa {
		if err := ctx.Err(); err != nil {
			return bc, err
		}
		cb, err := chuanBi(ctx, mt, ca)
		if err != nil {
			return bc, fmt.Errorf("%s: %w", ca.Ma, err)
		}
		nha := moiNha(cb)
		if nha == nil || nha.Ma() != "gia" {
			return bc, fmt.Errorf("%s: bộ kiểm chỉ chạy nhà giả", ca.Ma)
		}
		dau := DauVan(nha, mt.CongCu)
		if len(bc.Diem) == 0 {
			bc.NhaCungCap, bc.Model, bc.DauVan = nha.Ma(), nha.Model(), dau
		} else if bc.DauVan != dau {
			return bc, fmt.Errorf("%s: nhà cung cấp hoặc model đổi giữa bộ ca", ca.Ma)
		}
		boc := &nhaGhi{NhaCungCap: nha}
		kq, loi := troly.MoiLop(mt.Pool, mt.CauHinh, boc).Luot(ctx, cb.Ca.Cau, cb.Ca.LichSu, mt.CongCu)
		bc.SoLanGoi += len(boc.daGui)
		bc.Diem = append(bc.Diem, Cham(LuotDaChay{Ca: cb.Ca, KetQua: kq, Loi: loi, DaGui: boc.daGui, GiaChuan: cb.GiaChuan}, CanCu{DuocPhep: mt.DuocPhep, TenRieng: mt.TenRieng}))
	}
	return bc, nil
}
