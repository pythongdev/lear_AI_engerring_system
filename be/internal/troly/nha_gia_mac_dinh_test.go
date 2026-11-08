package troly_test

// Hợp đồng T-310 (Claude chốt 2026-11-08; suy ra của phiên, không phải lời quán). Nhà giả mặc định của server
// (`troly.MoiNhaGiaMacDinh`, CHAT_MODEL_PROVIDER=gia) phải gọi được công cụ đọc nội bộ của CHAT-08, để trên máy dev
// diễn được biên bản chỉ đọc của CHAT-09. Nó vẫn là model giả: không giữ gì giữa các lượt (I-041), không tự nói số.
//
//   - Lần gọi đầu (len(g.Buoc) == 0): đọc câu `Vai == "user"` **cuối cùng** của g.LichSu, so sau strings.ToLower,
//     xét đúng thứ tự dưới; luật đầu tiên khớp chữ **và** có tên công cụ trong g.CongCu thì thắng:
//       1. chứa "tổng quan" hoặc "hôm nay"  ⇒ doc_tong_quan
//       2. chứa "bàn" hoặc "phục vụ"        ⇒ doc_bang_phuc_vu
//       3. chứa "trạm" hoặc "bếp"           ⇒ doc_bang_tram
//     Không luật nào thắng (kể cả khi g.CongCu rỗng hay LichSu rỗng) ⇒ doc_menu như trước. Tham số luôn đúng `{}`.
//     Chữ khớp mà công cụ không có trong g.CongCu thì xét luật kế tiếp — nhà giả không bao giờ gọi tên ngoài danh sách
//     (trừ doc_menu dự phòng, như trước T-310).
//   - Lần gọi sau (len(g.Buoc) > 0), xét bước **cuối** của g.Buoc:
//       - công cụ nội bộ (doc_tong_quan · doc_bang_phuc_vu · doc_bang_tram) với Loi == "" ⇒ không gọi công cụ,
//         Chu chứa "model giả", tên công cụ, và KetQua sau json.Compact **nguyên văn** (không cắt, không tóm, không đổi số).
//       - công cụ nội bộ với Loi != "" ⇒ Chu chứa "model giả", tên công cụ, "chưa đọc được"; không chứa "menu".
//       - mọi trường hợp khác ⇒ đúng chữ cũ (có "model giả" và "menu"), không chép KetQua.
//   - Ma() "gia", Model() "gia-1", Gia() giữ nguyên; huỷ context ⇒ lỗi (TestI041_NhaGiaMacDinhBatDauLaiMoiLuot giữ).

import (
	"bytes"
	"context"
	"encoding/json"
	"strings"
	"testing"

	"banhcuon/be/internal/troly"
)

var (
	ccKhach   = []string{"doc_menu", "tinh_gia"}
	ccTram    = []string{"doc_menu", "tinh_gia", "doc_bang_tram"}
	ccQuay    = []string{"doc_menu", "tinh_gia", "doc_bang_tram", "doc_bang_phuc_vu"}
	ccChuQuan = []string{"doc_menu", "tinh_gia", "doc_bang_tram", "doc_bang_phuc_vu", "doc_tong_quan"}
)

func hoiNhaGia(t *testing.T, lichSu []troly.Tin, cc []string) string {
	t.Helper()
	ph, err := troly.MoiNhaGiaMacDinh().Goi(context.Background(), troly.GoiModel{LichSu: lichSu, CongCu: cc})
	if err != nil || ph.GoiCongCu == nil || ph.Chu != "" {
		t.Fatalf("lần đầu phải gọi một công cụ, không chữ: %+v %v", ph, err)
	}
	if string(ph.GoiCongCu.ThamSo) != `{}` {
		t.Fatalf("tham số phải đúng {}: %q", ph.GoiCongCu.ThamSo)
	}
	return ph.GoiCongCu.Ten
}

func TestI041_NhaGiaChonCongCuNoiBoTheoCauHoi(t *testing.T) {
	ca := []struct {
		cau  string
		cc   []string
		muon string
	}{
		{"Tình hình bàn thế nào?", ccQuay, "doc_bang_phuc_vu"},
		{"còn bao nhiêu món đang phục vụ", ccChuQuan, "doc_bang_phuc_vu"},
		{"Bếp đang có gì?", ccTram, "doc_bang_tram"},
		{"trạm tráng còn mấy việc", ccChuQuan, "doc_bang_tram"},
		{"TỔNG QUAN hôm nay", ccChuQuan, "doc_tong_quan"},
		{"bàn hôm nay", ccChuQuan, "doc_tong_quan"},             // luật 1 đứng trước luật 2
		{"tổng quan hôm nay ở bàn", ccQuay, "doc_bang_phuc_vu"}, // không có doc_tong_quan ⇒ luật kế tiếp
		{"tổng quan hôm nay", ccTram, "doc_menu"},               // không công cụ nào khớp được phép
		{"bàn 3 còn gì", ccTram, "doc_menu"},
		{"bàn 3 còn gì", ccKhach, "doc_menu"},
		{"bếp có gì", ccKhach, "doc_menu"},
		{"menu có món gì", ccChuQuan, "doc_menu"},
		{"bánh cuốn giá bao nhiêu", ccChuQuan, "doc_menu"}, // "bánh" không phải "bàn"
	}
	for _, c := range ca {
		got := hoiNhaGia(t, []troly.Tin{{Vai: "user", Chu: c.cau}}, c.cc)
		if got != c.muon {
			t.Errorf("%q với %v: muốn %s, ra %s", c.cau, c.cc, c.muon, got)
		}
	}
	if got := hoiNhaGia(t, nil, ccChuQuan); got != "doc_menu" {
		t.Errorf("lịch sử rỗng phải ra doc_menu, ra %s", got)
	}
}

func TestI041_NhaGiaDocCauNguoiDungCuoi(t *testing.T) {
	ls := []troly.Tin{
		{Vai: "user", Chu: "bàn 3 thế nào"},
		{Vai: "assistant", Chu: "trạm bếp tổng quan hôm nay"},
		{Vai: "user", Chu: "menu có gì"},
	}
	if got := hoiNhaGia(t, ls, ccChuQuan); got != "doc_menu" {
		t.Fatalf("phải đọc câu người dùng cuối, không câu trợ lý hay câu cũ: ra %s", got)
	}
	ls = []troly.Tin{{Vai: "user", Chu: "menu có gì"}, {Vai: "assistant", Chu: "có"}, {Vai: "user", Chu: "còn bếp?"}}
	if got := hoiNhaGia(t, ls, ccChuQuan); got != "doc_bang_tram" {
		t.Fatalf("câu cuối hỏi bếp phải ra doc_bang_tram: ra %s", got)
	}
}

func TestI043_NhaGiaChepNguyenKetQuaNoiBo(t *testing.T) {
	raw := json.RawMessage("{ \"jobs\": [ {\"station_code\": \"trang_banh\", \"quantity\": 7} ],\n \"read_at\": \"2026-11-08T09:00:00+07:00\" }")
	var gon bytes.Buffer
	if err := json.Compact(&gon, raw); err != nil {
		t.Fatal(err)
	}
	if gon.String() != `{"jobs":[{"station_code":"trang_banh","quantity":7}],"read_at":"2026-11-08T09:00:00+07:00"}` {
		t.Fatalf("mẫu nén sai: %s", gon.String())
	}
	for _, ten := range []string{"doc_bang_tram", "doc_bang_phuc_vu", "doc_tong_quan"} {
		ph, err := troly.MoiNhaGiaMacDinh().Goi(context.Background(), troly.GoiModel{
			LichSu: []troly.Tin{{Vai: "user", Chu: "bếp"}},
			CongCu: ccChuQuan,
			Buoc:   []troly.BuocCongCu{{LoiGoi: troly.LoiGoi{Ten: ten, ThamSo: json.RawMessage(`{}`)}, KetQua: raw}},
		})
		if err != nil || ph.GoiCongCu != nil {
			t.Fatalf("%s: sau kết quả phải trả lời, không gọi tiếp: %+v %v", ten, ph, err)
		}
		for _, can := range []string{"model giả", ten, gon.String()} {
			if !strings.Contains(ph.Chu, can) {
				t.Errorf("%s: chữ thiếu %q:\n%s", ten, can, ph.Chu)
			}
		}
	}
}

func TestI043_NhaGiaBaoChuaDocDuocKhiCongCuNoiBoLoi(t *testing.T) {
	ph, err := troly.MoiNhaGiaMacDinh().Goi(context.Background(), troly.GoiModel{
		Buoc: []troly.BuocCongCu{{LoiGoi: troly.LoiGoi{Ten: "doc_bang_phuc_vu", ThamSo: json.RawMessage(`{}`)}, Loi: "loi_cong_cu"}},
	})
	if err != nil || ph.GoiCongCu != nil {
		t.Fatalf("%+v %v", ph, err)
	}
	for _, can := range []string{"model giả", "doc_bang_phuc_vu", "chưa đọc được"} {
		if !strings.Contains(ph.Chu, can) {
			t.Errorf("chữ thiếu %q: %s", can, ph.Chu)
		}
	}
	if strings.Contains(ph.Chu, "menu") {
		t.Errorf("lỗi công cụ nội bộ không được bảo mở menu: %s", ph.Chu)
	}
}

func TestI041_NhaGiaGiuChuCuSauDocMenu(t *testing.T) {
	raw := json.RawMessage(`{"categories":[{"name":"Bánh cuốn","price":40000}]}`)
	ph, err := troly.MoiNhaGiaMacDinh().Goi(context.Background(), troly.GoiModel{
		Buoc: []troly.BuocCongCu{{LoiGoi: troly.LoiGoi{Ten: "doc_menu", ThamSo: json.RawMessage(`{}`)}, KetQua: raw}},
	})
	if err != nil || ph.GoiCongCu != nil || !strings.Contains(ph.Chu, "model giả") || !strings.Contains(ph.Chu, "menu") {
		t.Fatalf("%+v %v", ph, err)
	}
	if strings.Contains(ph.Chu, "40000") || strings.Contains(ph.Chu, "categories") {
		t.Fatalf("sau doc_menu không chép kết quả (không tự nói giá): %s", ph.Chu)
	}
}
