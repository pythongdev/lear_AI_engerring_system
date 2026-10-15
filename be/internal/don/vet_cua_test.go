package don_test

import (
	"context"
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"reflect"
	"regexp"
	"sort"
	"strings"
	"testing"

	"banhcuon/be/internal/giaoviec"
	"banhcuon/be/internal/khoanchi"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/nguoi"
	"banhcuon/be/internal/nguyenlieu"
	"banhcuon/be/internal/nhandon"
	"banhcuon/be/internal/platform/realtime"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

type caVet struct {
	cua  string
	dung func(*testing.T, canh) dichVet
}
type dichVet struct {
	bang       string
	id, nguoi  int64
	cot        string
	truoc, sau any
	goi        func()
}

// Cùng một bảng cấp ca cho test HTTP và phép so tập thư mục: không có danh sách thứ hai.
var cacCaVet = []caVet{
	{"ket/sua_dem", func(t *testing.T, c canh) dichVet {
		const day = "2031-05-20"
		var line int64
		if err := c.coVet(func(tx pgx.Tx) error {
			var opening, counted int64
			if err := tx.QueryRow(c.ctx, "INSERT INTO shop.opening_float(sale_date) VALUES ($1::date) RETURNING id", day).Scan(&opening); err != nil {
				return err
			}
			if _, err := tx.Exec(c.ctx, "INSERT INTO shop.opening_float_line(opening_float_id,denomination_vnd,amount_vnd) VALUES ($1,1000,1000)", opening); err != nil {
				return err
			}
			if err := tx.QueryRow(c.ctx, "INSERT INTO shop.cash_count(sale_date) VALUES ($1::date) RETURNING id", day).Scan(&counted); err != nil {
				return err
			}
			if err := tx.QueryRow(c.ctx, "INSERT INTO shop.cash_count_line(cash_count_id,denomination_vnd,amount_vnd) VALUES ($1,1000,1000) RETURNING id", counted).Scan(&line); err != nil {
				return err
			}
			_, err := tx.Exec(c.ctx, "INSERT INTO shop.reconciled_day(sale_date) VALUES ($1::date)", day)
			return err
		}); err != nil {
			t.Fatal(err)
		}
		return dichVet{"cash_count_line", line, c.chu, "amount_vnd", float64(1000), float64(2000), func() {
			status, body := c.goi(t, "PUT", "/sale-days/"+day+"/cash-count", c.chu, voi(cacXap([]xap{{1000, 2000}}), map[string]any{"reason": "kiểm vết sửa két"}))
			canDat(t, traLoi{status: status, body: body}, 200)
		}}
	}},
	{"ban/da_don", func(t *testing.T, c canh) dichVet {
		ban, phien, don, tong := c.phienDangPhucVu(t, "vết dọn")
		c.xong(t, don)
		canDat(t, c.tinhTien(t, c.quay, phien), 200)
		canDat(t, c.dongPhien(t, c.quay, phien, tong, 0, 0, ""), 201)
		id := c.docSo(t, "SELECT id FROM shop.table_session_member WHERE table_session_id=$1 AND dining_table_id=$2", phien, ban)
		return dichVet{"table_session_member", id, c.quay, "cleaned_at", nil, "mốc", func() { canDat(t, c.donBan(t, c.quay, ban), 200) }}
	}},
	{"menu/doi_gia_thanh_phan", func(t *testing.T, c canh) dichVet {
		id := c.id(t, "INSERT INTO shop.menu_component(name,base_price_vnd,takes_filling) VALUES ($1,1000,false) RETURNING id", t.Name())
		return dichVet{"menu_component", id, c.chu, "base_price_vnd", float64(1000), float64(2000), func() {
			c.suaMenu(t, c.chu, "PUT", fmt.Sprintf("/menu-components/%d/base-price", id), map[string]any{"base_price_vnd": 2000, "reason": "đổi giá kiểm vết"})
		}}
	}},
	{"menu/doi_phu_thu", func(t *testing.T, c canh) dichVet {
		group := c.id(t, "INSERT INTO shop.option_group(name) VALUES ($1) RETURNING id", t.Name())
		id := c.id(t, "INSERT INTO shop.menu_option(option_group_id,name,surcharge_vnd) VALUES ($1,$2,1000) RETURNING id", group, t.Name())
		return dichVet{"menu_option", id, c.chu, "surcharge_vnd", float64(1000), float64(2000), func() {
			c.suaMenu(t, c.chu, "PUT", fmt.Sprintf("/menu-options/%d/surcharge", id), map[string]any{"surcharge_vnd": 2000, "reason": "đổi phụ thu kiểm vết"})
		}}
	}},
	{"menu/ngung_ban", func(t *testing.T, c canh) dichVet {
		id := c.id(t, "INSERT INTO shop.menu_item(name) VALUES ($1) RETURNING id", t.Name())
		return dichVet{"menu_item", id, c.chu, "discontinued_at", nil, "mốc", func() {
			c.suaMenu(t, c.chu, "POST", fmt.Sprintf("/menu-items/%d/discontinuation", id), map[string]any{"reason": "ngừng bán kiểm vết"})
		}}
	}},
	{"menu/sua_thanh_phan", func(t *testing.T, c canh) dichVet {
		mon := c.id(t, "INSERT INTO shop.menu_item(name) VALUES ($1) RETURNING id", t.Name())
		tp := c.id(t, "INSERT INTO shop.menu_component(name,base_price_vnd,takes_filling) VALUES ($1,1000,false) RETURNING id", t.Name())
		id := c.id(t, "INSERT INTO shop.menu_item_component(menu_item_id,menu_component_id,quantity) VALUES ($1,$2,1) RETURNING id", mon, tp)
		return dichVet{"menu_item_component", id, c.chu, "quantity", float64(1), float64(2), func() {
			c.suaMenu(t, c.chu, "PUT", fmt.Sprintf("/menu-items/%d/components/%d", mon, tp), map[string]any{"quantity": 2, "reason": "sửa thành phần kiểm vết"})
		}}
	}},
	{"nguoi/khep_quay", func(t *testing.T, c canh) dichVet {
		r := gin.New()
		r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(c.pool)))
		nguoi.Routes(r, nguoi.NewService(c.pool))
		srv := httptest.NewServer(r)
		t.Cleanup(srv.Close)
		c.srv = srv
		id := c.docSo(t, "SELECT id FROM shop.counter_duty WHERE person_id=$1 AND ended_at IS NULL", c.quay)
		return dichVet{"counter_duty", id, c.quay, "ended_at", nil, "mốc", func() { canDat(t, c.post(t, "/counter-duty/end", c.quay, map[string]any{}), 200) }}
	}},
	{"giaoviec/sua", func(t *testing.T, c canh) dichVet {
		r := gin.New()
		r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(c.pool)))
		giaoviec.Routes(r, giaoviec.NewService(c.pool))
		srv := httptest.NewServer(r)
		t.Cleanup(srv.Close)
		c.srv = srv
		id := c.id(t, "INSERT INTO shop.assigned_task(content,assignee_person_id) VALUES ('test-cũ',$1) RETURNING id", c.chu)
		return dichVet{"assigned_task", id, c.chu, "content", "test-cũ", "test-mới", func() {
			status, body := c.goi(t, "PUT", fmt.Sprintf("/assigned-tasks/%d", id), c.chu, map[string]any{"content": "test-mới", "assignee_person_id": c.chu, "reason": "sửa việc kiểm vết"})
			canDat(t, traLoi{status: status, body: body}, 200)
		}}
	}},
	{"giaoviec/an", func(t *testing.T, c canh) dichVet {
		r := gin.New()
		r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(c.pool)))
		giaoviec.Routes(r, giaoviec.NewService(c.pool))
		srv := httptest.NewServer(r)
		t.Cleanup(srv.Close)
		c.srv = srv
		id := c.id(t, "INSERT INTO shop.assigned_task(content,assignee_person_id) VALUES ('test-cũ',$1) RETURNING id", c.chu)
		return dichVet{"assigned_task", id, c.chu, "hidden_at", nil, "mốc", func() {
			status, body := c.goi(t, "POST", fmt.Sprintf("/assigned-tasks/%d/hiding", id), c.chu, map[string]any{"reason": "ẩn việc kiểm vết"})
			canDat(t, traLoi{status: status, body: body}, 200)
		}}
	}},
	// Cửa sửa khoản chi (P3A-01, Claude thêm khi duyệt: TestI018_TapCuaSuaKhopTapCa đòi). Loại tiền riêng
	// để ca không chạm két của ngày nào.
	{"khoanchi/sua", func(t *testing.T, c canh) dichVet {
		r := gin.New()
		r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(c.pool)))
		khoanchi.Routes(r, khoanchi.NewService(c.pool))
		srv := httptest.NewServer(r)
		t.Cleanup(srv.Close)
		c.srv = srv
		loai := c.id(t, "INSERT INTO shop.expense_category(name,paid_from_till) VALUES ($1,false) RETURNING id", t.Name())
		id := c.id(t, "INSERT INTO shop.expense(expense_category_id,amount_vnd,paid_date) VALUES ($1,1000,'2026-01-05') RETURNING id", loai)
		return dichVet{"expense", id, c.chu, "amount_vnd", float64(1000), float64(2000), func() {
			status, body := c.goi(t, "PUT", fmt.Sprintf("/expenses/%d", id), c.chu,
				map[string]any{"expense_category_id": loai, "amount_vnd": 2000, "paid_date": "2026-01-05", "reason": "sửa khoản chi kiểm vết"})
			canDat(t, traLoi{status: status, body: body}, 200)
		}}
	}},
	{"nguyenlieu/dat_don_vi", func(t *testing.T, c canh) dichVet {
		r := gin.New()
		r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(c.pool)))
		nguyenlieu.Routes(r, nguyenlieu.NewService(c.pool))
		srv := httptest.NewServer(r)
		t.Cleanup(srv.Close)
		c.srv = srv
		id := c.id(t, "INSERT INTO shop.supply_item(name) VALUES ($1) RETURNING id", t.Name())
		return dichVet{"supply_item", id, c.chu, "purchase_unit", nil, "kg", func() {
			status, body := c.goi(t, "PUT", fmt.Sprintf("/supply-items/%d/purchase-unit", id), c.chu, map[string]any{"purchase_unit": "kg"})
			canDat(t, traLoi{status: status, body: body}, 200)
		}}
	}},
	{"nguyenlieu/sua_so", func(t *testing.T, c canh) dichVet {
		r := gin.New()
		r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(c.pool)))
		nguyenlieu.Routes(r, nguyenlieu.NewService(c.pool))
		srv := httptest.NewServer(r)
		t.Cleanup(srv.Close)
		c.srv = srv
		thu := c.id(t, "INSERT INTO shop.supply_item(name) VALUES ($1) RETURNING id", t.Name())
		id := c.id(t, "INSERT INTO shop.supply_day_entry(supply_item_id,entry_date,kind_code,entered_measure) VALUES ($1,'2026-01-05','purchased',10) RETURNING id", thu)
		return dichVet{"supply_day_entry", id, c.chu, "entered_measure", float64(10), float64(12), func() {
			status, body := c.goi(t, "PUT", fmt.Sprintf("/supply-day-entries/%d", id), c.chu, map[string]any{"measure": "12", "reason": "sửa con số kiểm vết"})
			canDat(t, traLoi{status: status, body: body}, 200)
		}}
	}},
	// Ba cửa sửa của tài khoản (T-190, Claude thêm khi duyệt: TestI018_TapCuaSuaKhopTapCa đòi).
	{"taikhoan/doi_trang_thai", func(t *testing.T, c canh) dichVet {
		c.srv = taikhoanSrv(t, c, nil)
		testhelper.Session(t, c.quay)
		id := c.docSo(t, "SELECT id FROM shop.account WHERE person_id=$1", c.quay)
		return dichVet{"account", id, c.chu, "status", "hoat_dong", "khoa", func() {
			canDat(t, c.post(t, fmt.Sprintf("/accounts/%d/lock", id), c.chu, map[string]any{}), 200)
		}}
	}},
	{"taikhoan/ket_thuc_phien", func(t *testing.T, c canh) dichVet {
		c.srv = taikhoanSrv(t, c, nil)
		token := testhelper.Session(t, c.quay)
		h := sha256.Sum256([]byte(token))
		id := c.docSo(t, "SELECT id FROM shop.login_session WHERE token_hash=$1", h[:])
		return dichVet{"login_session", id, c.quay, "ended_at", nil, "mốc", func() {
			req, err := http.NewRequestWithContext(c.ctx, "POST", c.srv.URL+"/sessions/current/end", nil)
			if err != nil {
				t.Fatal(err)
			}
			req.AddCookie(&http.Cookie{Name: taikhoan.CookiePhien, Value: token})
			res, err := http.DefaultClient.Do(req)
			if err != nil {
				t.Fatal(err)
			}
			res.Body.Close()
			if res.StatusCode != 200 {
				t.Fatalf("đăng xuất: %d", res.StatusCode)
			}
		}}
	}},
	{"taikhoan/dat_lai", func(t *testing.T, c canh) dichVet {
		thu := &thuVet{}
		c.srv = taikhoanSrv(t, c, thu)
		testhelper.Session(t, c.quay)
		email := fmt.Sprintf("test.%d@session.test", c.quay)
		canDat(t, c.post(t, "/password-reset-requests", 0, map[string]any{"email": email}), 202)
		if thu.ma == "" {
			t.Fatal("không có mã đặt lại")
		}
		h := sha256.Sum256([]byte(thu.ma))
		id := c.docSo(t, "SELECT id FROM shop.password_reset WHERE token_hash=$1", h[:])
		return dichVet{"password_reset", id, c.quay, "used_at", nil, "mốc", func() {
			canDat(t, c.post(t, "/password-resets", 0, map[string]any{"token": thu.ma, "new_password": "mat-khau-vet-moi"}), 200)
		}}
	}},
	// Hai cửa khép khoảng của P3-12 (Claude thêm 2026-10-12 khi duyệt: TestI018_TapCuaSuaKhopTapCa đòi).
	{"nhandon/mo_lai", func(t *testing.T, c canh) dichVet {
		c.srv = nhandonSrv(t, c)
		// Database dùng chung giữa các test: một khoảng đang mở (do test trước để lại) thì khép chính nó.
		id := c.docSo(t, "SELECT coalesce(max(id),0) FROM shop.shop_blind_spell WHERE ended_at IS NULL")
		if id == 0 {
			canDat(t, c.post(t, "/shop-blind/declaration", c.quay, map[string]any{}), http.StatusOK)
			id = c.docSo(t, "SELECT id FROM shop.shop_blind_spell WHERE ended_at IS NULL")
		}
		return dichVet{"shop_blind_spell", id, c.quay, "ended_at", nil, "mốc", func() {
			canDat(t, c.post(t, "/shop-blind/reopening", c.quay, map[string]any{}), http.StatusOK)
		}}
	}},
	{"nhandon/tiep_tuc", func(t *testing.T, c canh) dichVet {
		c.srv = nhandonSrv(t, c)
		id := c.docSo(t, "SELECT coalesce(max(id),0) FROM shop.order_intake_pause WHERE ended_at IS NULL")
		if id == 0 {
			canDat(t, c.post(t, "/order-intake/pause", c.chu, map[string]any{}), http.StatusOK)
			id = c.docSo(t, "SELECT id FROM shop.order_intake_pause WHERE ended_at IS NULL")
		}
		return dichVet{"order_intake_pause", id, c.chu, "ended_at", nil, "mốc", func() {
			canDat(t, c.post(t, "/order-intake/resume", c.chu, map[string]any{}), http.StatusOK)
		}}
	}},
	{"sanxuat/chuyen", func(t *testing.T, c canh) dichVet {
		_, _, don, _ := c.phienDangPhucVu(t, "nguồn")
		_, _, nhan, _ := c.phienDangPhucVu(t, "đích")
		a, b := c.viec(t, don, "pending")[0], c.viec(t, nhan, "pending")[0]
		canDat(t, c.bamMe(t, c.quay, a), 201)
		canDat(t, c.huyDon(t, c.quay, don), 200)
		id := c.docSo(t, "SELECT id FROM shop.production_batch_item WHERE station_job_id=$1", a)
		return dichVet{"production_batch_item", id, c.quay, "station_job_id", float64(a), float64(b), func() { canDat(t, c.chuyen(t, c.quay, [2]int64{a, b}), 201) }}
	}},
	{"sanxuat/huy_ghi_lam_sai", func(t *testing.T, c canh) dichVet {
		_, _, don, _ := c.phienDangPhucVu(t, "làm sai")
		job := c.viec(t, don, "pending")[0]
		canDat(t, c.bamMe(t, c.quay, job), 201)
		canDat(t, c.huyDon(t, c.quay, don), 200)
		r := c.ghiLamSai(t, c.quay, job, nil)
		canDat(t, r, 201)
		id := r.so(t, "wrong_make_note_id")
		return dichVet{"wrong_make_note", id, c.quay, "cancelled_at", nil, "mốc", func() { canDat(t, c.huyGhiChu(t, c.quay, id), 200) }}
	}},
	{"sanxuat/lui_me", func(t *testing.T, c canh) dichVet {
		_, _, don, _ := c.phienDangPhucVu(t, "lùi")
		job := c.viec(t, don, "pending")[0]
		r := c.bamMe(t, c.quay, job)
		canDat(t, r, 201)
		id := r.so(t, "production_batch_id")
		return dichVet{"production_batch", id, c.quay, "rolled_back_at", nil, "mốc", func() { canDat(t, c.luiMe(t, c.quay, id), 200) }}
	}},
	{"vongdoi/chuyen_don", func(t *testing.T, c canh) dichVet {
		ban := c.banMoi(t, "QR")
		r := c.goiQR(t, c.capMaQR(t, ban), dauLanGui(t), c.dong(false))
		canDat(t, r, 201)
		id := r.so(t, "sales_order_id")
		return dichVet{"sales_order", id, c.quay, "status", "pending_confirmation", "cancelled", func() { canDat(t, c.tuChoi(t, c.quay, id), 200) }}
	}},
	{"vongdoi/chuyen_phien", func(t *testing.T, c canh) dichVet {
		_, id, don, _ := c.phienDangPhucVu(t, "tính tiền")
		c.xong(t, don)
		return dichVet{"table_session", id, c.quay, "status", "serving", "awaiting_payment", func() { canDat(t, c.tinhTien(t, c.quay, id), 200) }}
	}},
	{"vongdoi/chuyen_viec", func(t *testing.T, c canh) dichVet {
		_, _, don, _ := c.phienDangPhucVu(t, "việc")
		id := c.viec(t, don, "pending")[0]
		return dichVet{"station_job", id, c.quay, "status", "pending", "made", func() { canDat(t, c.bamMe(t, c.quay, id), http.StatusCreated) }}
	}},
}

func TestI018_MoiCuaSuaCoVet(t *testing.T) {
	for _, ca := range cacCaVet {
		t.Run(ca.cua, func(t *testing.T) {
			c := dungBan(t)
			d := ca.dung(t, c)
			// Vết chụp trong kết nối của cửa (múi giờ quán, QC-15); ảnh thật đọc cùng múi giờ ấy để hai
			// bản in mốc giống nhau từng ký tự.
			var tz string
			if err := c.pool.QueryRow(c.ctx, "SHOW TimeZone").Scan(&tz); err != nil {
				t.Fatal(err)
			}
			if _, err := c.owner.Exec(c.ctx, "SELECT set_config('TimeZone', $1, false)", tz); err != nil {
				t.Fatal(err)
			}
			anh := func() map[string]any {
				var raw []byte
				if err := c.owner.QueryRow(c.ctx, "SELECT to_jsonb(x) FROM shop."+d.bang+" x WHERE id=$1", d.id).Scan(&raw); err != nil {
					t.Fatal(err)
				}
				var out map[string]any
				if err := json.Unmarshal(raw, &out); err != nil {
					t.Fatal(err)
				}
				return out
			}
			truoc := anh()
			moc := c.docSo(t, "SELECT coalesce(max(id),0) FROM shop.record_revision")
			d.goi()
			sau := anh()
			if !reflect.DeepEqual(truoc[d.cot], d.truoc) {
				t.Fatalf("%s trước: %v, cần %v", d.cot, truoc[d.cot], d.truoc)
			}
			if d.sau == "mốc" {
				if s, ok := sau[d.cot].(string); !ok || s == "" {
					t.Fatalf("%s sau phải có mốc: %v", d.cot, sau[d.cot])
				}
			} else if !reflect.DeepEqual(sau[d.cot], d.sau) {
				t.Fatalf("%s sau: %v, cần %v", d.cot, sau[d.cot], d.sau)
			}
			var before, after []byte
			var reason string
			var person int64
			rows, err := c.owner.Query(c.ctx, `SELECT before_image,after_image,reason,person_id FROM shop.record_revision WHERE id>$1 AND target_table_code=$2 AND target_row=$3`, moc, d.bang, d.id)
			if err != nil {
				t.Fatal(err)
			}
			defer rows.Close()
			count := 0
			for rows.Next() {
				count++
				if err := rows.Scan(&before, &after, &reason, &person); err != nil {
					t.Fatal(err)
				}
				var b, a map[string]any
				if err := json.Unmarshal(before, &b); err != nil {
					t.Fatal(err)
				}
				if err := json.Unmarshal(after, &a); err != nil {
					t.Fatal(err)
				}
				if !reflect.DeepEqual(b, truoc) || !reflect.DeepEqual(a, sau) {
					t.Fatalf("vết khác ảnh thật: %s → %s", before, after)
				}
				if strings.TrimSpace(reason) == "" || person != d.nguoi {
					t.Fatalf("lý do %q, người %d, cần %d", reason, person, d.nguoi)
				}
			}
			if err := rows.Err(); err != nil {
				t.Fatal(err)
			}
			if count != 1 {
				t.Fatalf("cần đúng 1 vết mới của %s/%d, có %d", d.bang, d.id, count)
			}
			t.Logf("%s/%d: %s %v → %v; đủ hai ảnh, lý do, người %d", d.bang, d.id, d.cot, truoc[d.cot], sau[d.cot], d.nguoi)
		})
	}
}

func TestI018_TapCuaSuaKhopTapCa(t *testing.T) {
	files, err := filepath.Glob("../*/sql/*/*.sql")
	if err != nil {
		t.Fatal(err)
	}
	updates := map[string]bool{}
	// Bỏ chú thích trước khi tìm UPDATE; không tính SELECT ... FOR UPDATE.
	comments := regexp.MustCompile(`(?s)/\*.*?\*/|--[^\n]*`)
	update := regexp.MustCompile(`(?i)\bUPDATE\s+(?:shop\.)?[a-z_][a-z_0-9]*\s+SET\b`)
	for _, f := range files {
		raw, err := os.ReadFile(f)
		if err != nil {
			t.Fatal(err)
		}
		if update.Match(comments.ReplaceAll(raw, nil)) {
			p := strings.Split(filepath.ToSlash(f), "/")
			updates[p[1]+"/"+p[3]] = true
		}
	}
	cases := map[string]bool{}
	for _, c := range cacCaVet {
		if cases[c.cua] {
			t.Fatalf("trùng ca %s", c.cua)
		}
		cases[c.cua] = true
	}
	keys := func(m map[string]bool) []string {
		out := []string{}
		for k := range m {
			out = append(out, k)
		}
		sort.Strings(out)
		return out
	}
	if !reflect.DeepEqual(keys(updates), keys(cases)) {
		t.Fatalf("cửa UPDATE = %v\nca test = %v", keys(updates), keys(cases))
	}
	t.Logf("%d cửa UPDATE khớp %d ca", len(updates), len(cases))
}

// nhandonSrv dựng router riêng cho miền nhandon, cùng cách ca nguoi/khep_quay dựng miền nguoi.
func nhandonSrv(t *testing.T, c canh) *httptest.Server {
	t.Helper()
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(c.pool)))
	nhandon.Routes(r, nhandon.NewService(c.pool, realtime.New(0)))
	srv := httptest.NewServer(r)
	t.Cleanup(srv.Close)
	return srv
}

// thuVet giữ mã đặt lại thay cho dịch vụ gửi thư.
type thuVet struct{ ma string }

func (m *thuVet) SendPasswordReset(_ context.Context, _, token string) error {
	m.ma = token
	return nil
}

func taikhoanSrv(t *testing.T, c canh, thu taikhoan.Mailer) *httptest.Server {
	t.Helper()
	r := gin.New()
	r.Use(middleware.GanNguoi(taikhoan.NewAuthenticator(c.pool)))
	taikhoan.Routes(r, taikhoan.NewService(c.pool, thu))
	srv := httptest.NewServer(r)
	t.Cleanup(srv.Close)
	return srv
}
