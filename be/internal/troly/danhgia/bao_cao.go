package danhgia

import (
	"crypto/sha256"
	"fmt"
	"io"
	"strings"

	"banhcuon/be/internal/troly"
)

type BaoCao struct {
	NhaCungCap, Model, DauVan string
	SoLanGoi                  int
	Diem                      []Diem
}

func (b BaoCao) MoDuoc() bool {
	for _, d := range b.Diem {
		if d.BatBuoc && !d.Dat {
			return false
		}
	}
	return true
}

func (b BaoCao) In(w io.Writer) error {
	var s strings.Builder
	fmt.Fprintf(&s, "danhgia nha=%s model=%s dau_van=%s so_ca=%d so_lan_goi=%d\n", b.NhaCungCap, b.Model, b.DauVan, len(b.Diem), b.SoLanGoi)
	for _, nhom := range CacNhom {
		tong, dat := 0, 0
		for _, d := range b.Diem {
			if d.Nhom == nhom {
				tong++
				if d.Dat {
					dat++
				}
			}
		}
		if tong > 0 {
			fmt.Fprintf(&s, "danhgia nhom=%s dat=%d/%d\n", nhom, dat, tong)
		}
	}
	for _, d := range b.Diem {
		if !d.Dat {
			fmt.Fprintf(&s, "danhgia TRUOT %s %s bat_buoc=%t\n", d.Ma, strings.Join(d.LyDo, ","), d.BatBuoc)
		}
	}
	ket := "chan"
	if b.MoDuoc() {
		ket = "mo_duoc"
	}
	fmt.Fprintf(&s, "danhgia ket_luan=%s\n", ket)
	_, err := io.WriteString(w, s.String())
	return err
}

func DauVan(nha troly.NhaCungCap, congCu []troly.CongCu) string {
	h := sha256.New()
	// Độ dài tách các trường, tránh hai bộ trường khác nhau có cùng chuỗi ghép.
	for _, s := range []string{nha.Ma(), nha.Model(), troly.HeThong} {
		fmt.Fprintf(h, "%d:%s", len(s), s)
	}
	for _, c := range congCu {
		fmt.Fprintf(h, "%d:%s%d:%s", len(c.Ten), c.Ten, len(c.MoTa), c.MoTa)
	}
	return fmt.Sprintf("%x", h.Sum(nil))[:12]
}
