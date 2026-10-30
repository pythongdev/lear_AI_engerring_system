package dinhdanh

import "testing"

func TestI035_ChuanHoa(t *testing.T) {
	for _, c := range []struct {
		in, out string
		kind    Loai
	}{
		{"0912 345 678", "0912345678", DienThoai}, {"0912.345.678", "0912345678", DienThoai}, {"+84 912 345 678", "0912345678", DienThoai}, {"84912345678", "0912345678", DienThoai}, {"024 3826 1234", "02438261234", DienThoai}, {" An@Gmail.com ", "an@gmail.com", Thu}, {"abc", "", ""}, {"@gmail.com", "", ""}, {"09123", "", ""}, {"", "", ""}} {
		t.Run(c.in, func(t *testing.T) {
			k, s, e := ChuanHoa(c.in)
			if k != c.kind || s != c.out || (e != nil) != (c.out == "") {
				t.Fatalf("got %q %q %v", k, s, e)
			}
		})
	}
}
