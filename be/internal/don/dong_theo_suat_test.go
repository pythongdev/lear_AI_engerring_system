package don_test

import (
	"fmt"
	"net/http"
	"testing"
)

// I-002: phần đã ra đếm theo suất, không theo cả dòng và không theo từng việc trạm.
func TestI002_DongPhienThuSuatDaRa(t *testing.T) {
	for _, combo := range []bool{false, true} {
		name := "dong_ba_suat_ra_hai"
		if combo {
			name = "combo_ra_do"
		}
		t.Run(name, func(t *testing.T) {
			c := dungBan(t)
			line := c.dong(false)
			line["quantity"] = 3
			if combo {
				line = c.comboThat(t).dong(false)
			}
			r := c.datHo(t, c.quay, c.banMoi(t, name), dauLanGui(t), line)
			canDat(t, r, http.StatusCreated)
			don, phien := r.so(t, "sales_order_id"), r.so(t, "table_session_id")
			// Chọn hai suất của dòng thường; combo chỉ làm một trong hai suất con.
			var ids []int64
			rows, err := c.owner.Query(c.ctx, `SELECT j.id FROM shop.station_job j
    JOIN shop.order_line l ON l.id=j.order_line_id
    JOIN shop.order_line_component c ON c.id=j.order_line_component_id
    WHERE j.sales_order_id=$1 AND j.position<=c.quantity * CASE WHEN $2::boolean THEN 1 ELSE 2 END
    ORDER BY j.id`, don, combo)
			if err != nil {
				t.Fatal(err)
			}
			for rows.Next() {
				var id int64
				if err = rows.Scan(&id); err != nil {
					t.Fatal(err)
				}
				ids = append(ids, id)
			}
			if err = rows.Err(); err != nil {
				t.Fatal(err)
			}
			rows.Close()
			if len(ids) == 0 {
				t.Fatal("fixture không có việc")
			}
			canDat(t, c.bamMe(t, c.quay, ids...), http.StatusCreated)
			canDat(t, c.raBan(t, c.quay, ids...), http.StatusOK)
			want := r.so(t, "total_vnd") / 3 * 2
			if combo {
				want = 0
			}
			tt := c.tinhTien(t, c.quay, phien)
			canDat(t, tt, http.StatusOK)
			if tt.so(t, "due_vnd") != want {
				t.Fatalf("bill-request=%v, muốn %d", tt.body, want)
			}
			status, board := c.goi(t, "GET", "/service-board", c.quay, nil)
			if status != http.StatusOK {
				t.Fatalf("service-board: %d %v", status, board)
			}
			found := false
			for _, x := range board["sessions"].([]any) {
				s := x.(map[string]any)
				if int64(s["table_session_id"].(float64)) == phien {
					found = true
					if int64(s["served_amount_vnd"].(float64)) != want {
						t.Fatalf("service-board=%v muốn %d", s, want)
					}
				}
			}
			if !found {
				t.Fatal("thiếu phiên trên service-board")
			}
			closed := c.dongPhien(t, c.quay, phien, want, 0, 0, "")
			canDat(t, closed, http.StatusCreated)
			if closed.so(t, "due_vnd") != want {
				t.Fatalf("hoá đơn=%v muốn %d", closed.body, want)
			}
			if c.trangThaiDon(t, don) != "completed" {
				t.Fatal("đơn có việc served phải completed")
			}
			c.khongViecSong(t, phien)
		})
	}
}

// Fixture menu riêng, không sửa menu seed. Mỗi thành phần giá price, có/không trạm theo tham số.
func (c canh) monThuSuat(t *testing.T, price int64, tram ...bool) map[string]any {
	t.Helper()
	mon := c.id(t, "INSERT INTO shop.menu_item(name) VALUES ($1) RETURNING id", t.Name()+" món")
	for i, coTram := range tram {
		tp := c.id(t, "INSERT INTO shop.menu_component(name,base_price_vnd,takes_filling) VALUES ($1,$2,false) RETURNING id", fmt.Sprintf("%s tp%d", t.Name(), i), price)
		c.id(t, "INSERT INTO shop.menu_item_component(menu_item_id,menu_component_id,quantity) VALUES ($1,$2,1) RETURNING id", mon, tp)
		if coTram {
			c.id(t, "INSERT INTO shop.menu_component_station(menu_component_id,station_code) VALUES ($1,'quay') RETURNING id", tp)
		}
	}
	return map[string]any{"menu_item_id": mon, "quantity": 1, "option_ids": []int64{}, "is_takeaway": false}
}

func TestI002_HaiThanhPhanVaThanhPhanKhongTram(t *testing.T) {
	for _, tc := range []struct {
		name        string
		tram        []bool
		price, want int64
	}{
		{"hai_thanh_phan_ra_mot", []bool{true, true}, 1000, 0},
		{"thanh_phan_khong_tram_khong_chan", []bool{true, false}, 1000, 2000},
		{"chi_thanh_phan_khong_tram", []bool{false}, 1000, 1000},
		{"suat_mien_phi_khong_tram", []bool{false}, 0, 0},
	} {
		t.Run(tc.name, func(t *testing.T) {
			c := dungBan(t)
			r := c.datHo(t, c.quay, c.banMoi(t, "bàn"), dauLanGui(t), c.monThuSuat(t, tc.price, tc.tram...))
			canDat(t, r, http.StatusCreated)
			don, phien := r.so(t, "sales_order_id"), r.so(t, "table_session_id")
			if tc.tram[0] {
				id := c.docSo(t, `SELECT min(id) FROM shop.station_job WHERE sales_order_id=$1 AND order_line_component_id IS NOT NULL`, don)
				canDat(t, c.bamMe(t, c.quay, id), http.StatusCreated)
				canDat(t, c.raBan(t, c.quay, id), http.StatusOK)
			}
			tt := c.tinhTien(t, c.quay, phien)
			canDat(t, tt, http.StatusOK)
			if tt.so(t, "due_vnd") != tc.want {
				t.Fatalf("tính tiền=%v muốn %d", tt.body, tc.want)
			}
			c.tienBangVanHanh(t, phien, tc.want)
			closed := c.dongPhien(t, c.quay, phien, tc.want, 0, 0, "")
			canDat(t, closed, http.StatusCreated)
			if closed.so(t, "due_vnd") != tc.want || c.trangThaiDon(t, don) != "completed" {
				t.Fatalf("đóng=%v trạng thái=%s", closed.body, c.trangThaiDon(t, don))
			}
			c.khongViecSong(t, phien)
		})
	}
}

func (c canh) tienBangVanHanh(t *testing.T, phien, want int64) {
	t.Helper()
	status, out := c.goi(t, "GET", "/service-board", c.quay, nil)
	if status != http.StatusOK {
		t.Fatalf("service-board: %d %v", status, out)
	}
	for _, x := range out["sessions"].([]any) {
		s := x.(map[string]any)
		if int64(s["table_session_id"].(float64)) == phien {
			if int64(s["served_amount_vnd"].(float64)) != want {
				t.Fatalf("service-board=%v muốn %d", s, want)
			}
			return
		}
	}
	t.Fatal("thiếu phiên trên service-board")
}

func TestI017_GiuDonDaHuyVaHuyQRChuaDuyetKhongTram(t *testing.T) {
	c := dungBan(t)
	ban, phien, don, _ := c.phienDangPhucVu(t, "bàn")
	ids := c.viec(t, don, "pending")
	canDat(t, c.bamMe(t, c.quay, ids...), http.StatusCreated)
	canDat(t, c.raBan(t, c.quay, ids[0]), http.StatusOK)
	canDat(t, c.huyDon(t, c.quay, don), http.StatusOK)
	// Đơn đã huỷ có cả served và made, giữ nguyên huỷ, không thu.
	qr := c.goiQR(t, c.capMaQR(t, ban), dauLanGui(t), c.monThuSuat(t, 1000, false))
	canDat(t, qr, http.StatusCreated)
	canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
	// Đơn QR chưa duyệt không mang suất nào, kể cả món không trạm; đóng thì huỷ, không thu.
	c.tienBangVanHanh(t, phien, 0)
	closed := c.dongPhien(t, c.quay, phien, 0, 0, 0, "")
	canDat(t, closed, http.StatusCreated)
	if closed.so(t, "due_vnd") != 0 || c.trangThaiDon(t, don) != "cancelled" || c.trangThaiDon(t, qr.so(t, "sales_order_id")) != "cancelled" {
		t.Fatalf("đóng sai trạng thái hay tiền: %v", closed.body)
	}
	c.khongViecSong(t, phien)
}

func TestI017_GhepBanHuyViecCaHaiBan(t *testing.T) {
	c := dungBan(t)
	banA, phien, donA, _ := c.phienDangPhucVu(t, "A")
	banB := c.banMoi(t, "B")
	c.ghepTay(t, phien, banB)
	b := c.datHo(t, c.quay, banB, dauLanGui(t), c.dong(false))
	canDat(t, b, http.StatusCreated)
	for _, don := range []int64{donA, b.so(t, "sales_order_id")} {
		ids := c.viec(t, don, "pending")
		canDat(t, c.bamMe(t, c.quay, ids[0]), http.StatusCreated)
	}
	canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
	canDat(t, c.dongPhien(t, c.quay, phien, 0, 0, 0, ""), http.StatusCreated)
	c.khongViecSong(t, phien)
	for _, don := range []int64{donA, b.so(t, "sales_order_id")} {
		if c.trangThaiDon(t, don) != "cancelled" || len(c.viecCua(t, don, "discarded")) != 1 || len(c.viecCua(t, don, "cancelled")) == 0 {
			t.Fatalf("đơn %d chưa huỷ đủ việc", don)
		}
	}
	for _, ban := range []int64{banA, banB} {
		if c.trangThaiBan(t, ban) != "needs_cleaning" {
			t.Fatalf("bàn %d chưa đóng", ban)
		}
	}
}

// Bao gồm việc, mục mẻ và vết, để bắt cả trường hợp rollback thiếu một nửa.
func (c canh) anhViecPhien(t *testing.T, phien int64) string {
	t.Helper()
	return c.docChu(t, `WITH jobs AS (SELECT j.* FROM shop.station_job j JOIN shop.sales_order o ON o.id=j.sales_order_id WHERE o.table_session_id=$1)
 SELECT jsonb_build_object('jobs',(SELECT jsonb_agg(to_jsonb(j) ORDER BY id) FROM jobs j),
 'items',(SELECT jsonb_agg(to_jsonb(i) ORDER BY i.id) FROM shop.production_batch_item i JOIN jobs j ON j.id=i.station_job_id),
 'revisions',(SELECT jsonb_agg(to_jsonb(r) ORDER BY r.id) FROM shop.record_revision r WHERE
 (r.target_table_code='station_job' AND r.target_row IN (SELECT id FROM jobs)) OR
 (r.target_table_code='sales_order' AND r.target_row IN (SELECT id FROM shop.sales_order WHERE table_session_id=$1))))::text`, phien)
}

func TestI017_TuChoiTienTruocMoiLanHuyViec(t *testing.T) {
	c := dungBan(t)
	ban, phien, don, tong := c.phienDangPhucVu(t, "bàn")
	c.xong(t, don)
	them := c.datHo(t, c.quay, ban, dauLanGui(t), c.dong(false))
	canDat(t, them, http.StatusCreated)
	ids := c.viec(t, them.so(t, "sales_order_id"), "pending")
	canDat(t, c.bamMe(t, c.quay, ids[0]), http.StatusCreated)
	canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
	// Nếu cửa thử ghi trước khi từ chối tiền, trigger sẽ biến kết quả thành 500, test đỏ.
	ham := fmt.Sprintf("test_t227_cam_ghi_%d", phien)
	_, err := c.owner.Exec(c.ctx, fmt.Sprintf(`CREATE FUNCTION shop.%s() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN
 IF NEW.sales_order_id IN (SELECT id FROM shop.sales_order WHERE table_session_id=%d) THEN RAISE EXCEPTION 'test: tiền chưa hợp lệ mà đã ghi'; END IF;
 RETURN NEW; END $$; CREATE TRIGGER %s BEFORE UPDATE ON shop.station_job FOR EACH ROW EXECUTE FUNCTION shop.%s()`, ham, phien, ham, ham))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		_, _ = c.owner.Exec(c.ctx, fmt.Sprintf("DROP TRIGGER IF EXISTS %s ON shop.station_job; DROP FUNCTION IF EXISTS shop.%s()", ham, ham))
	})
	before, jobs := c.anhPhien(t, phien), c.anhViecPhien(t, phien)
	canMa(t, c.dongPhien(t, c.quay, phien, tong-1, 0, 0, ""), 422, "payment_parts_mismatch", "")
	canMa(t, c.dongPhien(t, c.quay, phien, 0, 0, tong, ""), 422, "debtor_name_mismatch", "")
	canMa(t, c.dongPhien(t, c.quay, phien, tong, 0, 0, "không nợ"), 422, "debtor_name_mismatch", "")
	canMa(t, c.dongPhien(t, c.quay, phien, -1, 0, 0, ""), 400, "invalid_request", "cash_vnd")
	if c.anhPhien(t, phien) != before || c.anhViecPhien(t, phien) != jobs {
		t.Fatal("từ chối tiền đã đổi phiên, việc, mẻ hay vết")
	}
}

func TestI002_DemSuatKhongGhepTheoPosition(t *testing.T) {
	c := dungBan(t)
	line := c.monThuSuat(t, 1000, true, true)
	line["quantity"] = 3
	r := c.datHo(t, c.quay, c.banMoi(t, "bàn"), dauLanGui(t), line)
	canDat(t, r, http.StatusCreated)
	don, phien := r.so(t, "sales_order_id"), r.so(t, "table_session_id")
	// Thành phần thứ nhất ra vị trí 1,2; thứ hai ra 2,3: cả hai đều đủ hai suất.
	rows, err := c.owner.Query(c.ctx, `SELECT j.id FROM shop.station_job j JOIN shop.order_line_component c ON c.id=j.order_line_component_id
 WHERE j.sales_order_id=$1 AND ((c.position=1 AND j.position IN (1,2)) OR (c.position=2 AND j.position IN (2,3))) ORDER BY j.id`, don)
	if err != nil {
		t.Fatal(err)
	}
	var ids []int64
	for rows.Next() {
		var id int64
		if err = rows.Scan(&id); err != nil {
			t.Fatal(err)
		}
		ids = append(ids, id)
	}
	if err = rows.Err(); err != nil {
		t.Fatal(err)
	}
	rows.Close()
	if len(ids) != 4 {
		t.Fatalf("muốn 4 việc, có %v", ids)
	}
	canDat(t, c.bamMe(t, c.quay, ids...), http.StatusCreated)
	canDat(t, c.raBan(t, c.quay, ids...), http.StatusOK)
	canDat(t, c.tinhTien(t, c.quay, phien), http.StatusOK)
	c.tienBangVanHanh(t, phien, 4000)
	closed := c.dongPhien(t, c.quay, phien, 4000, 0, 0, "")
	canDat(t, closed, http.StatusCreated)
	if closed.so(t, "due_vnd") != 4000 {
		t.Fatalf("phải thu hai suất: %v", closed.body)
	}
	c.khongViecSong(t, phien)
}
