// T-312 (ADR-141, Claude viết TRƯỚC code, 2026-11-09): máy dev bỏ được ĐÚNG MỘT điều kiện của I-008 — giờ bán.
// Codex làm cho xanh mà không sửa điều kiện kiểm nào. Bỏ giờ bán là một lựa chọn của Service lúc dựng
// (WithBoGioBan); bản mặc định giữ luật, và tạm dừng cùng quán mù vẫn chặn như cũ.
package don_test

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"banhcuon/be/internal/don"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/platform/realtime"
	"banhcuon/be/internal/taikhoan"
	"github.com/gin-gonic/gin"
)

// boGioBan: cùng database, cùng dữ liệu dựng sẵn, nhưng cửa đơn đi qua một Service đã bật bỏ giờ bán.
func (n ngoai) boGioBan(t *testing.T) ngoai {
	t.Helper()
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(n.pool)))
	don.Routes(r, don.NewService(n.pool, realtime.AlwaysSeeing{}).WithBoGioBan(true))
	srv := httptest.NewServer(r)
	t.Cleanup(srv.Close)
	m := n
	m.srv = srv
	return m
}

// Bật bỏ giờ bán: cả năm kênh nhận đơn trước giờ mở và sau giờ đóng.
func TestI008_MayDevBoGioBanThiNhanDonNgoaiGio(t *testing.T) {
	n := dungNgoai(t)
	dev := n.boGioBan(t)
	for _, moc := range []time.Time{n.luc(21, n.gioMo-time.Hour), n.luc(21, n.gioDong+2*time.Hour)} {
		datDongHo(t, moc)
		for _, kenh := range namKenh {
			r := dev.taoKenh(t, kenh)
			canDat(t, r, http.StatusCreated)
			t.Logf("bỏ giờ bán, %s lúc %s ⇒ %d", kenh, moc.Format("15:04"), r.status)
		}
	}
}

// Bản mặc định (không gọi WithBoGioBan) vẫn từ chối ngoài giờ — cùng mốc, cùng dữ liệu.
func TestI008_MacDinhVanChanNgoaiGio(t *testing.T) {
	n := dungNgoai(t)
	datDongHo(t, n.luc(22, n.gioDong+2*time.Hour))
	for _, kenh := range namKenh {
		truoc := n.demTatCa(t)
		canMa(t, n.taoKenh(t, kenh), http.StatusConflict, "outside_selling_hours", "")
		if sau := n.demTatCa(t); sau != truoc {
			t.Fatalf("%s ngoài giờ bị từ chối mà vẫn ghi: %s → %s", kenh, truoc, sau)
		}
	}
}

// Bỏ giờ bán KHÔNG bỏ tạm dừng: năm kênh vẫn order_intake_paused, không ghi gì.
func TestI008_MayDevBoGioBanVanTheoTamDung(t *testing.T) {
	n := dungNgoai(t)
	dev := n.boGioBan(t)
	bat := n.luc(23, n.gioDong+time.Hour)
	n.tamDung(t, bat, bat.Add(2*time.Hour))
	datDongHo(t, bat.Add(30*time.Minute))
	truoc := n.demTatCa(t)
	for _, kenh := range namKenh {
		canMa(t, dev.taoKenh(t, kenh), http.StatusConflict, "order_intake_paused", "")
	}
	if sau := n.demTatCa(t); sau != truoc {
		t.Fatalf("tạm dừng mà vẫn ghi: %s → %s", truoc, sau)
	}
}

// Bỏ giờ bán KHÔNG bỏ quán mù: ba kênh khách tự bấm vẫn shop_not_seeing_orders, hai kênh người của quán vẫn nhận.
func TestI008_MayDevBoGioBanVanTheoQuanMu(t *testing.T) {
	n := dungNgoai(t)
	dev := n.boGioBan(t)
	tu := n.luc(24, n.gioDong+time.Hour)
	n.quanMu(t, tu, tu.Add(2*time.Hour))
	datDongHo(t, tu.Add(30*time.Minute))
	for _, kenh := range namKenh {
		truoc := n.demTatCa(t)
		r := dev.taoKenh(t, kenh)
		switch kenh {
		case "delivery", "pickup", "qr_table":
			canMa(t, r, http.StatusConflict, "shop_not_seeing_orders", "")
			if sau := n.demTatCa(t); sau != truoc {
				t.Fatalf("%s lúc quán mù bị từ chối mà vẫn ghi: %s → %s", kenh, truoc, sau)
			}
		default:
			canDat(t, r, http.StatusCreated)
		}
	}
}
