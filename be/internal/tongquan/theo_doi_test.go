package tongquan

import (
	"context"
	_ "embed"
	"encoding/json"
	"errors"
	"reflect"
	"strings"
	"testing"

	"banhcuon/be/internal/apierr"
	"github.com/jackc/pgx/v5"
)

// T-372 (ADR-148): Claude viết trước khi giao; Codex làm cho xanh, KHÔNG sửa kỳ vọng.
// Hàm cần có (Codex viết): theoDoi(ctx, tx, ngay, code) đọc trong giao dịch đã cho, cùng ngày bán như docBang;
// Service.TheoDoi(ctx, code) mở giao dịch đọc, quy ngày bán như DocBang rồi gọi theoDoi — không qua authz.
//
//	type TheoDoiBan struct {
//		TableLabel string        `json:"table_label"`
//		ReadAt     time.Time     `json:"read_at"`
//		Session    *PhienTheoDoi `json:"session"` // null khi bàn không có phiên chưa đóng
//	}
//	type PhienTheoDoi struct {
//		Tables          []string        `json:"tables"`            // nhãn mọi bàn của phiên, cùng thứ tự PhienBan.Tables
//		Items           []ThuCuaBan     `json:"items"`             // = PhienBan.Items
//		Lines           json.RawMessage `json:"lines"`             // = PhienBan.Lines
//		LinesTotalVnd   int64           `json:"lines_total_vnd"`   // = PhienBan.LinesTotalVnd
//		ServedAmountVnd int64           `json:"served_amount_vnd"` // = PhienBan.ServedAmountVnd
//		PendingLines    json.RawMessage `json:"pending_lines"`     // dòng gốc của đơn chưa duyệt, chưa huỷ; cùng hình Lines
//		OrdersAhead     *int64          `json:"orders_ahead"`      // ADR-148 điểm 3
//	}

//go:embed testdata/theo_doi.sql
var theoDoiFixture string

type theoDoiCanh struct {
	ctx  context.Context
	tx   pgx.Tx
	ngay string
	bang BangVanHanh
}

func theoDoiDung(t *testing.T) theoDoiCanh {
	t.Helper()
	ctx, tx, _, _, _, _ := bangFixture(t)
	if _, err := tx.Exec(ctx, theoDoiFixture); err != nil {
		t.Fatal(err)
	}
	var ngay string
	if err := tx.QueryRow(ctx, `SELECT now()::date::text`).Scan(&ngay); err != nil {
		t.Fatal(err)
	}
	bang, err := docBang(ctx, tx, ngay)
	if err != nil {
		t.Fatal(err)
	}
	return theoDoiCanh{ctx: ctx, tx: tx, ngay: ngay, bang: bang}
}

func (c theoDoiCanh) doc(t *testing.T, code string) TheoDoiBan {
	t.Helper()
	out, err := theoDoi(c.ctx, c.tx, c.ngay, code)
	if err != nil {
		t.Fatalf("theoDoi(%q): %v", code, err)
	}
	return out
}

func dongJSON(t *testing.T, raw json.RawMessage) []map[string]any {
	t.Helper()
	var ds []map[string]any
	if err := json.Unmarshal(raw, &ds); err != nil {
		t.Fatalf("không đọc được mảng dòng %s: %v", raw, err)
	}
	return ds
}

// A2 (số món): cùng nguồn với trang Vận hành — items và bàn ghép bằng đúng phiên ấy của docBang.
func TestI020_TheoDoiSoMonCungNguonVanHanh(t *testing.T) {
	c := theoDoiDung(t)
	for _, ca := range []struct{ code, nhan string }{{"test-t372-A", "test-t225-A"}, {"test-t372-B1", "test-t225-B1"}} {
		got := c.doc(t, ca.code)
		want := phienCuaBan(t, c.bang, ca.nhan)
		if got.Session == nil {
			t.Fatalf("%s: bàn có phiên mở phải trả session", ca.code)
		}
		if !reflect.DeepEqual(got.Session.Items, want.Items) {
			t.Fatalf("%s: items lệch Vận hành\n có  %+v\n muốn %+v", ca.code, got.Session.Items, want.Items)
		}
		if got.TableLabel != ca.nhan {
			t.Fatalf("%s: table_label %q, muốn %q", ca.code, got.TableLabel, ca.nhan)
		}
	}
	// Bàn ghép: mã của B1 thấy cả hai bàn của phiên.
	if got := c.doc(t, "test-t372-B1").Session.Tables; !reflect.DeepEqual(got, []string{"test-t225-B1", "test-t225-B2"}) {
		t.Fatalf("bàn ghép phải trả hai nhãn B1, B2; có %v", got)
	}
}

// A2 (tiền): lines, tổng dòng và tiền đã ra bằng đúng phiên ấy của docBang (ADR-125, một nguồn tiền phiên).
func TestI002_TheoDoiTienCungNguonVanHanh(t *testing.T) {
	c := theoDoiDung(t)
	for _, ca := range []struct{ code, nhan string }{{"test-t372-A", "test-t225-A"}, {"test-t372-B1", "test-t225-B1"}} {
		s := c.doc(t, ca.code).Session
		want := phienCuaBan(t, c.bang, ca.nhan)
		if s == nil {
			t.Fatalf("%s: bàn có phiên mở phải trả session", ca.code)
		}
		if string(s.Lines) != string(want.Lines) {
			t.Fatalf("%s: lines lệch Vận hành\n có  %s\n muốn %s", ca.code, s.Lines, want.Lines)
		}
		if s.LinesTotalVnd != want.LinesTotalVnd || s.ServedAmountVnd != want.ServedAmountVnd {
			t.Fatalf("%s: tiền lệch Vận hành: lines_total %d/%d, served_amount %d/%d", ca.code,
				s.LinesTotalVnd, want.LinesTotalVnd, s.ServedAmountVnd, want.ServedAmountVnd)
		}
	}
}

// A3: đơn chờ duyệt chỉ ở pending_lines.
func TestI004_TheoDoiDonChoDuyet(t *testing.T) {
	c := theoDoiDung(t)
	s := c.doc(t, "test-t372-A").Session
	cho := dongJSON(t, s.PendingLines)
	if len(cho) != 1 || cho[0]["item_name"] != "test-t372-cho-A" || cho[0]["quantity"] != float64(2) {
		t.Fatalf("pending_lines của A phải đúng một dòng test-t372-cho-A ×2; có %s", s.PendingLines)
	}
	if strings.Contains(string(s.Lines), "test-t372-cho") {
		t.Fatalf("dòng chờ duyệt lọt vào lines: %s", s.Lines)
	}
	// Bàn chỉ có đơn chờ duyệt: chưa có số, chưa có lượt.
	f := c.doc(t, "test-t372-F").Session
	if f == nil {
		t.Fatal("bàn F có phiên mở phải trả session")
	}
	if len(dongJSON(t, f.PendingLines)) != 1 || len(f.Items) != 0 || string(f.Lines) != "[]" ||
		f.LinesTotalVnd != 0 || f.ServedAmountVnd != 0 || f.OrdersAhead != nil {
		t.Fatalf("bàn F chỉ có đơn chờ duyệt: muốn 1 pending, items/lines rỗng, tiền 0, orders_ahead null; có %+v", f)
	}
}

// A4: số lượt gọi trước (hành vi ADR-148, không có bất biến riêng; xếp ở I-004 vì chỉ đếm đơn đã duyệt còn việc) — mọi kênh, đã duyệt, còn việc chưa ra, tạo trước hẳn, trong ngày bán hiện tại.
func TestI004_TheoDoiLuotTruocChiDemDonDaDuyetConViec(t *testing.T) {
	c := theoDoiDung(t)
	cases := []struct {
		code string
		muon int64
		vi   string
	}{
		// Mốc A = now() (đơn S1). Trước A: đơn B tạo -5s, P1 (đến lấy) -10s. Không tính: đơn gốc của S2 (cùng mốc now()),
		// P2 huỷ, P3 xong, P4 mọi việc đã served, P5 của ngày trước, đơn chờ duyệt của A và F.
		{"test-t372-A", 2, "đơn bàn B -5s và đơn đến lấy P1 -10s"},
		// Mốc B = -5s (đơn sớm nhất còn chờ của phiên B). Trước B: chỉ P1.
		{"test-t372-B1", 1, "chỉ đơn đến lấy P1 -10s"},
	}
	for _, ca := range cases {
		s := c.doc(t, ca.code).Session
		if s.OrdersAhead == nil || *s.OrdersAhead != ca.muon {
			t.Fatalf("%s: orders_ahead muốn %d (%s); có %v", ca.code, ca.muon, ca.vi, s.OrdersAhead)
		}
	}
}

// A1: mã cũ hoặc lạ; bàn không phiên; phiên chưa có đơn.
func TestI023_TheoDoiMaVaPhien(t *testing.T) {
	c := theoDoiDung(t)
	for _, code := range []string{"test-t372-A-cu", "test-t372-khong-co"} {
		_, err := theoDoi(c.ctx, c.tx, c.ngay, code)
		var e apierr.Error
		if !errors.As(err, &e) || e.Code != apierr.CodeQRCodeNotCurrent {
			t.Fatalf("mã %q phải trả qr_code_not_current; có %v", code, err)
		}
	}
	if d := c.doc(t, "test-t372-D"); d.Session != nil || d.TableLabel != "test-t225-D" {
		t.Fatalf("bàn D không phiên: muốn session null và nhãn test-t225-D; có %+v", d)
	}
	s := c.doc(t, "test-t372-C").Session
	if s == nil || len(s.Items) != 0 || string(s.Lines) != "[]" || string(s.PendingLines) != "[]" || s.OrdersAhead != nil {
		t.Fatalf("bàn C phiên mở chưa có đơn: muốn items [], lines [], pending_lines [], orders_ahead null; có %+v", s)
	}
}

// A5: không lộ người, lịch sử đem ra hay bàn khác; mảng rỗng là [] chứ không null.
func TestI023_TheoDoiKhongLoBanKhac(t *testing.T) {
	c := theoDoiDung(t)
	raw, err := json.Marshal(c.doc(t, "test-t372-A"))
	if err != nil {
		t.Fatal(err)
	}
	for _, cam := range []string{"person", "serve_history", "test-t225-quay", "test-t225-B", "test-t225-E", "empty_tables", "0900000"} {
		if strings.Contains(string(raw), cam) {
			t.Fatalf("phản hồi của bàn A chứa %q: %s", cam, raw)
		}
	}
	raw, err = json.Marshal(c.doc(t, "test-t372-C"))
	if err != nil {
		t.Fatal(err)
	}
	var wire struct {
		Session map[string]json.RawMessage `json:"session"`
	}
	if err := json.Unmarshal(raw, &wire); err != nil {
		t.Fatal(err)
	}
	for _, k := range []string{"items", "lines", "pending_lines", "tables"} {
		if v := string(wire.Session[k]); v == "" || v == "null" {
			t.Fatalf("JSON của phiên C thiếu mảng %s (có %q): %s", k, v, raw)
		}
	}
	if string(wire.Session["orders_ahead"]) != "null" {
		t.Fatalf("orders_ahead của phiên C phải là null tường minh: %s", raw)
	}
}
