// Test công cụ đọc nội bộ theo phiên (CHAT-08, ADR-139 điểm 4 · 8 · 9 và Sửa đổi 2026-11-06; I-043). Claude viết TRƯỚC khi có
// code; Codex làm cho xanh, không sửa điều kiện kiểm. Cần PostgreSQL thật: chạy qua ./scripts/be-check.sh.
//
// Hợp đồng Claude chốt trong test này (2026-11-06):
//   - troly.MoiNguonNoiBo(pool *pgxpool.Pool) *troly.NguonNoiBo — nguồn đọc nội bộ, dựng service của các cửa GET đã có
//     (tongquan.NewService, sanxuat.NewService); không câu SQL riêng của troly.
//   - (*troly.NguonNoiBo).CongCu(ctx, nguoi int64, menu *gia.Service) ([]troly.CongCu, error) — danh sách công cụ của lượt.
//     Receiver nil hoặc nguoi <= 0 hoặc người không có thật ⇒ đúng troly.CongCuCongKhai(menu) (không lỗi).
//     Người làm: công khai + "doc_bang_tram"; qua lớp quay_hoac_chu_quan ⇒ thêm "doc_bang_phuc_vu"; qua lớp chu_quan ⇒ thêm
//     "doc_tong_quan". Thứ tự cố định: doc_menu, tinh_gia, doc_bang_tram, doc_bang_phuc_vu, doc_tong_quan.
//     Lớp được đọc bằng authz như màn tay (authz.ReadAs), trong giao dịch chỉ đọc đóng trước khi trả.
//   - doc_bang_tram: tham số {"station_code": string} có thể vắng; trả đúng thân GET /production-board (sanxuat.Service.DocGom).
//     station_code không phải chuỗi ⇒ lỗi công cụ.
//   - doc_bang_phuc_vu: bỏ qua tham số; gọi tongquan.Service.DocBang(ctx, nguoi) DƯỚI CHÍNH NGƯỜI CỦA PHIÊN rồi
//     troly.ChieuBangPhucVu. doc_tong_quan: tongquan.Service.Doc(ctx, nguoi) rồi troly.ChieuTongQuan. Quyền kiểm lại lúc
//     chạy: người rời quầy giữa lượt ⇒ lỗi công cụ, không kết quả.
//   - troly.Routes(r, lop, menu, noiBo *troly.NguonNoiBo): đường POST /chat/turns lấy người từ middleware.Nguoi (cookie người
//     làm); cookie khách không mở công cụ nội bộ. noiBo nil ⇒ mọi người chỉ có công cụ công khai.
package troly_test

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"reflect"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/sanxuat"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"banhcuon/be/internal/tongquan"
	"banhcuon/be/internal/troly"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

var (
	dsCongKhai = []string{"doc_menu", "tinh_gia"}
	dsNguoiLam = []string{"doc_menu", "tinh_gia", "doc_bang_tram"}
	dsQuay     = []string{"doc_menu", "tinh_gia", "doc_bang_tram", "doc_bang_phuc_vu"}
	dsChuQuan  = []string{"doc_menu", "tinh_gia", "doc_bang_tram", "doc_bang_phuc_vu", "doc_tong_quan"}
)

type nguoiThu struct {
	khung
	chu, quay, ngoai int64
}

// moNguoi tạo ba người: chủ quán, người đứng quầy, người ngoài quầy — như test T-225 của bảng phục vụ.
func moNguoi(t *testing.T) nguoiThu {
	t.Helper()
	k := moKhung(t)
	napMenu(t, k)
	n := nguoiThu{khung: k}
	tag := time.Now().UnixNano()
	for _, x := range []struct {
		name  string
		owner bool
		id    *int64
	}{{"test-chat08-chu", true, &n.chu}, {"test-chat08-quay", false, &n.quay}, {"test-chat08-ngoai", false, &n.ngoai}} {
		if err := k.owner.QueryRow(k.ctx, `INSERT INTO shop.person(display_name,is_owner) VALUES ($1,$2) RETURNING id`,
			fmt.Sprintf("%s-%d", x.name, tag), x.owner).Scan(x.id); err != nil {
			t.Fatal(err)
		}
	}
	n.dungQuay(t, n.quay)
	t.Cleanup(func() { n.dungQuay(t, 0) })
	return n
}

// dungQuay đóng mọi ca quầy đang mở rồi mở ca cho person (0 ⇒ không ai đứng quầy).
func (n nguoiThu) dungQuay(t *testing.T, person int64) {
	t.Helper()
	err := pgx.BeginFunc(n.ctx, n.owner, func(tx pgx.Tx) error {
		if _, e := tx.Exec(n.ctx, `SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','test-chat08-duty',true)`, fmt.Sprint(n.chu)); e != nil {
			return e
		}
		if _, e := tx.Exec(n.ctx, `UPDATE shop.counter_duty SET ended_at=now() WHERE ended_at IS NULL`); e != nil {
			return e
		}
		if person > 0 {
			_, e := tx.Exec(n.ctx, `INSERT INTO shop.counter_duty(person_id,started_at) VALUES ($1,now())`, person)
			return e
		}
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
}

func tenCongCu(cc []troly.CongCu) []string {
	out := make([]string, 0, len(cc))
	for _, c := range cc {
		out = append(out, c.Ten)
	}
	return out
}

func timCongCu(t *testing.T, cc []troly.CongCu, ten string) troly.CongCu {
	t.Helper()
	for _, c := range cc {
		if c.Ten == ten {
			return c
		}
	}
	t.Fatalf("không có công cụ %s trong %v", ten, tenCongCu(cc))
	return troly.CongCu{}
}

// boMocDoc bỏ mọi khoá read_at ở mọi tầng: hai lần đọc khác mốc, số phải như nhau.
func boMocDoc(t *testing.T, raw []byte) any {
	t.Helper()
	var v any
	if err := json.Unmarshal(raw, &v); err != nil {
		t.Fatalf("không phải JSON: %s", raw)
	}
	var di func(any) any
	di = func(x any) any {
		switch y := x.(type) {
		case map[string]any:
			delete(y, "read_at")
			for k, con := range y {
				y[k] = di(con)
			}
		case []any:
			for i, con := range y {
				y[i] = di(con)
			}
		}
		return x
	}
	return di(v)
}

// ADR-139 điểm 9, I-043: danh sách công cụ do backend chọn theo lớp người của phiên; không phiên chỉ công khai.
func TestI043_DanhSachCongCuTheoLop(t *testing.T) {
	n := moNguoi(t)
	menu := gia.NewService(n.pool)
	nb := troly.MoiNguonNoiBo(n.pool)
	for _, ca := range []struct {
		ten   string
		nb    *troly.NguonNoiBo
		nguoi int64
		muon  []string
	}{
		{"không phiên", nb, 0, dsCongKhai},
		{"không nguồn nội bộ", nil, n.chu, dsCongKhai},
		{"người không có thật", nb, 999_999_999, dsCongKhai},
		{"người ngoài quầy", nb, n.ngoai, dsNguoiLam},
		{"người đứng quầy", nb, n.quay, dsQuay},
		{"chủ quán không đứng quầy", nb, n.chu, dsChuQuan},
	} {
		cc, err := ca.nb.CongCu(n.ctx, ca.nguoi, menu)
		if err != nil {
			t.Fatalf("%s: %v", ca.ten, err)
		}
		if got := tenCongCu(cc); !reflect.DeepEqual(got, ca.muon) {
			t.Fatalf("%s: danh sách công cụ phải %v, được %v", ca.ten, ca.muon, got)
		}
	}
	if got := tenCongCu(troly.CongCuCongKhai(menu)); !reflect.DeepEqual(got, dsCongKhai) {
		t.Fatalf("danh sách công khai của CHAT-05 không được đổi: %v", got)
	}
}

// ADR-139 điểm 9: công cụ chạy dưới chính người của phiên, quyền kiểm lại lúc chạy như màn tay.
func TestI043_CongCuKiemLaiQuyenLucChay(t *testing.T) {
	n := moNguoi(t)
	menu := gia.NewService(n.pool)
	cc, err := troly.MoiNguonNoiBo(n.pool).CongCu(n.ctx, n.quay, menu)
	if err != nil {
		t.Fatal(err)
	}
	bang := timCongCu(t, cc, "doc_bang_phuc_vu")
	if out, err := bang.Chay(n.ctx, json.RawMessage(`{}`)); err != nil || !json.Valid(out) {
		t.Fatalf("đang đứng quầy phải đọc được: %s %v", out, err)
	}
	n.dungQuay(t, 0)
	out, err := bang.Chay(n.ctx, json.RawMessage(`{}`))
	if err == nil || len(out) != 0 {
		t.Fatalf("rời quầy giữa lượt mà công cụ vẫn trả kết quả: %s", out)
	}
	var e apierr.Error
	if !errors.As(err, &e) || e.Code != apierr.CodeNotOnCounterDuty {
		t.Fatalf("lời từ chối phải là not_on_counter_duty như GET /service-board, được %v", err)
	}
}

// ADR-139 điểm 7(a) · 8: số tới model là đúng số của cửa GET cùng người, đã chiếu; bảng trạm là đúng thân GET /production-board.
func TestI043_KetQuaCongCuLaSoCuaCuaDoc(t *testing.T) {
	n := moNguoi(t)
	menu := gia.NewService(n.pool)
	cc, err := troly.MoiNguonNoiBo(n.pool).CongCu(n.ctx, n.chu, menu)
	if err != nil {
		t.Fatal(err)
	}
	tq := tongquan.NewService(n.pool)

	bang, err := tq.DocBang(n.ctx, n.chu)
	if err != nil {
		t.Fatal(err)
	}
	muon, err := troly.ChieuBangPhucVu(bang)
	if err != nil {
		t.Fatal(err)
	}
	got, err := timCongCu(t, cc, "doc_bang_phuc_vu").Chay(n.ctx, json.RawMessage(`{"bo_qua":true}`))
	if err != nil || !reflect.DeepEqual(boMocDoc(t, got), boMocDoc(t, muon)) {
		t.Fatalf("doc_bang_phuc_vu phải là ChieuBangPhucVu(GET /service-board):\n%s\n---\n%s\n%v", got, muon, err)
	}

	tong, err := tq.Doc(n.ctx, n.chu)
	if err != nil {
		t.Fatal(err)
	}
	muon, err = troly.ChieuTongQuan(tong)
	if err != nil {
		t.Fatal(err)
	}
	got, err = timCongCu(t, cc, "doc_tong_quan").Chay(n.ctx, json.RawMessage(`{}`))
	if err != nil || !reflect.DeepEqual(boMocDoc(t, got), boMocDoc(t, muon)) {
		t.Fatalf("doc_tong_quan phải là ChieuTongQuan(GET /owner-overview):\n%s\n---\n%s\n%v", got, muon, err)
	}

	tram := timCongCu(t, cc, "doc_bang_tram")
	sx := sanxuat.NewService(n.pool)
	for _, ca := range []struct{ thamSo, ma string }{{`{}`, ""}, {`{"station_code":"trang"}`, "trang"}} {
		muon, err := sx.DocGom(n.ctx, ca.ma, nil)
		if err != nil {
			t.Fatal(err)
		}
		got, err := tram.Chay(n.ctx, json.RawMessage(ca.thamSo))
		if err != nil || !reflect.DeepEqual(boMocDoc(t, got), boMocDoc(t, muon)) {
			t.Fatalf("doc_bang_tram %s phải là thân GET /production-board:\n%s\n---\n%s\n%v", ca.thamSo, got, muon, err)
		}
	}
	if out, err := tram.Chay(n.ctx, json.RawMessage(`{"station_code":1}`)); err == nil || len(out) != 0 {
		t.Fatalf("station_code không phải chuỗi phải là lỗi công cụ: %s", out)
	}
}

// phienKhachThat tạo một phiên khách thật (cookie banhcuon_khach) như test hộp tin.
func phienKhachThat(t *testing.T, n nguoiThu) string {
	t.Helper()
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		t.Fatal(err)
	}
	token := base64.RawURLEncoding.EncodeToString(b)
	h := sha256.Sum256([]byte(token))
	err := pgx.BeginFunc(n.ctx, n.owner, func(tx pgx.Tx) error {
		if _, e := tx.Exec(n.ctx, `SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','test-chat08-khach',true)`, fmt.Sprint(n.chu)); e != nil {
			return e
		}
		var a int64
		email := fmt.Sprintf("test-khach-chat08-%d@example.test", time.Now().UnixNano())
		if e := tx.QueryRow(n.ctx, `INSERT INTO shop.customer_account (email, display_name) VALUES ($1, 'test-khách') RETURNING id`, email).Scan(&a); e != nil {
			return e
		}
		_, e := tx.Exec(n.ctx, `INSERT INTO shop.customer_session (customer_account_id, token_hash, expires_at) VALUES ($1, $2, now() + interval '1 day')`, a, h[:])
		return e
	})
	if err != nil {
		t.Fatal(err)
	}
	return token
}

// G1, ADR-139 điểm 9 · 10, I-043: đường hỏi chọn công cụ theo cookie người làm; cookie khách — kể cả đặt vào tên cookie người
// làm — không mở công cụ nội bộ; câu trả lời có số kèm nguồn và mốc đọc, gói tới model không mang tên người.
func TestI043_DuongHoiChonCongCuTheoPhien(t *testing.T) {
	n := moNguoi(t)
	gin.SetMode(gin.TestMode)
	nha := troly.MoiNhaGia(traLoi("ok"))
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(n.pool)))
	menu := gia.NewService(n.pool)
	troly.Routes(r, troly.MoiLop(n.pool, cauHinh(t, "gia", 0), nha), menu, troly.MoiNguonNoiBo(n.pool))
	khach := phienKhachThat(t, n)
	hoi := func(cookies ...*http.Cookie) []byte {
		t.Helper()
		req := httptest.NewRequest("POST", "/chat/turns", strings.NewReader(`{"question":"Bàn nào còn thiếu bánh cuốn?"}`))
		req.Header.Set("Content-Type", "application/json")
		for _, c := range cookies {
			req.AddCookie(c)
		}
		w := httptest.NewRecorder()
		r.ServeHTTP(w, req)
		if w.Code != http.StatusOK {
			t.Fatalf("%d %s", w.Code, w.Body.String())
		}
		return w.Body.Bytes()
	}
	phien := func(person int64) *http.Cookie {
		return &http.Cookie{Name: "banhcuon_phien", Value: testhelper.Session(t, person)}
	}
	for _, ca := range []struct {
		ten    string
		cookie []*http.Cookie
		muon   []string
	}{
		{"không cookie", nil, dsCongKhai},
		{"cookie khách", []*http.Cookie{{Name: authz.CookieKhach, Value: khach}}, dsCongKhai},
		{"mã khách đặt vào cookie người làm", []*http.Cookie{{Name: "banhcuon_phien", Value: khach}}, dsCongKhai},
		{"người ngoài quầy", []*http.Cookie{phien(n.ngoai)}, dsNguoiLam},
		// Sửa 2026-11-09, CHAT-15 (Claude): lớp quay_hoac_chu_quan nay có thêm bốn công cụ giao việc, kể sau tên đọc.
		// Sửa 2026-11-09, CHAT-16 (Claude): thêm sáu công cụ đào tạo sau bốn công cụ giao việc.
		{"người đứng quầy", []*http.Cookie{phien(n.quay)}, append(append([]string{}, dsQuay...), dsGhiQuayChu...)},
		{"chủ quán", []*http.Cookie{phien(n.chu)}, append(append([]string{}, dsChuQuan...), dsGhiQuayChu...)},
	} {
		truoc := len(nha.DaNhan())
		hoi(ca.cookie...)
		g := nha.DaNhan()
		if len(g) != truoc+1 || !reflect.DeepEqual(g[truoc].CongCu, ca.muon) {
			t.Fatalf("%s: gói tới model phải kể đúng %v, được %+v", ca.ten, ca.muon, g[truoc:])
		}
	}

	// Lượt có số: người đứng quầy hỏi, model gọi doc_bang_phuc_vu rồi trả lời; nguồn có tên công cụ và mốc đọc.
	nha = troly.MoiNhaGia(goiTool("doc_bang_phuc_vu", `{}`), traLoi("Theo bảng phục vụ."))
	r = gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(n.pool)))
	troly.Routes(r, troly.MoiLop(n.pool, cauHinh(t, "gia", 0), nha), menu, troly.MoiNguonNoiBo(n.pool))
	var out struct {
		Answer  *string `json:"answer"`
		Sources []struct {
			Tool   string `json:"tool"`
			ReadAt string `json:"read_at"`
		} `json:"sources"`
		DegradedReason *string `json:"degraded_reason"`
	}
	if err := json.Unmarshal(hoi(phien(n.quay)), &out); err != nil {
		t.Fatal(err)
	}
	if out.Answer == nil || *out.Answer != "Theo bảng phục vụ." || out.DegradedReason != nil || len(out.Sources) != 1 ||
		out.Sources[0].Tool != "doc_bang_phuc_vu" || out.Sources[0].ReadAt == "" {
		t.Fatalf("câu trả lời có số phải kèm nguồn doc_bang_phuc_vu và mốc đọc: %+v", out)
	}
	g := nha.DaNhan()
	if len(g) != 2 || len(g[1].Buoc) != 1 || g[1].Buoc[0].Loi != "" {
		t.Fatalf("công cụ phải chạy được dưới phiên người đứng quầy: %+v", g)
	}
	if la := khoaLa(t, g[1].Buoc[0].KetQua, duocPhepBangPhucVu); len(la) != 0 {
		t.Fatalf("gói tới model mang khoá ngoài danh sách được phép: %v", la)
	}
}
