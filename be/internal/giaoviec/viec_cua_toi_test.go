// Test cửa đọc việc của chính mình (CHAT-34, ADR-137 điểm 2; I-030). Claude viết TRƯỚC khi có cửa; Codex làm cho
// xanh, không sửa điều kiện kiểm. Người lấy từ phiên, không từ tham số; cửa chỉ đọc nên I-030 không đổi.
package giaoviec_test

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"testing"
	"time"

	"banhcuon/be/internal/authz"
	"github.com/jackc/pgx/v5"
)

type viecCuaToi struct {
	ID     int64
	Done   bool
	Guides []string
}

func docViecCuaToi(t *testing.T, r traVe) []viecCuaToi {
	t.Helper()
	canDat(t, r, http.StatusOK)
	raw, ok := r.body["assigned_tasks"].([]any)
	if !ok {
		t.Fatalf("thiếu assigned_tasks trong %v", r.body)
	}
	out := make([]viecCuaToi, 0, len(raw))
	for _, x := range raw {
		m := x.(map[string]any)
		for _, truong := range []string{"content", "due_at", "created_at", "assigned_by_name"} {
			if _, co := m[truong]; !co {
				t.Fatalf("việc thiếu %q: %v", truong, m)
			}
		}
		v := viecCuaToi{ID: int64(m["assigned_task_id"].(float64)), Done: m["done"].(bool)}
		for _, g := range m["guides"].([]any) {
			v.Guides = append(v.Guides, g.(map[string]any)["body"].(string))
		}
		out = append(out, v)
	}
	return out
}

func TestI030_ViecCuaToiChiTraViecCuaChinhNguoiDangNhap(t *testing.T) {
	k := dung(t)
	taoViec := func(content string, nhan int64) int64 {
		r := k.tao(t, k.chu, content, nhan)
		canDat(t, r, http.StatusCreated)
		return r.so(t, "assigned_task_id")
	}
	cu := taoViec("test-việc cũ của nv", k.nv)
	moi := taoViec("test-việc mới của nv", k.nv)
	daAn := taoViec("test-việc đã ẩn của nv", k.nv)
	cuaNguoiKhac := taoViec("test-việc của nv2", k.nv2)
	canDat(t, k.danhDau(t, k.chu, cu, "done"), http.StatusCreated)
	canDat(t, k.goi(t, "POST", fmt.Sprintf("/assigned-tasks/%d/hiding", daAn), k.chu, map[string]any{"reason": "test: ẩn"}), http.StatusOK)

	k.so(t, `INSERT INTO shop.assigned_task_guide (assigned_task_id, guide_kind_code, body) VALUES ($1, 'text', 'test-hướng dẫn chữ') RETURNING id`, moi)
	an := k.so(t, `INSERT INTO shop.assigned_task_guide (assigned_task_id, guide_kind_code, body) VALUES ($1, 'text', 'test-hướng dẫn đã ẩn') RETURNING id`, moi)
	k.so(t, `UPDATE shop.assigned_task_guide SET hidden_at = now(), hidden_by_person_id = person_id WHERE id = $1 RETURNING id`, an)
	k.so(t, `INSERT INTO shop.assigned_task_guide (assigned_task_id, guide_kind_code, file_code) VALUES ($1, 'image', 'abcdefabcdefabcdefabcdefabcdefab.png') RETURNING id`, moi)
	tokenKhach := phienKhach(t, k)
	truoc := k.soDong(t)

	// Người nhận không đứng quầy vẫn đọc được; mới nhất trước; không có việc đã ẩn, việc người khác.
	ds := docViecCuaToi(t, k.goi(t, "GET", "/assigned-tasks/mine", k.nv, nil))
	if len(ds) != 2 || ds[0].ID != moi || ds[1].ID != cu {
		t.Fatalf("muốn đúng hai việc %d, %d; nhận %+v (đã ẩn %d, người khác %d)", moi, cu, ds, daAn, cuaNguoiKhac)
	}
	if ds[0].Done || !ds[1].Done {
		t.Fatalf("cờ xong sai: %+v", ds)
	}
	// Chỉ hướng dẫn chữ chưa ẩn; không có hình.
	if len(ds[0].Guides) != 1 || ds[0].Guides[0] != "test-hướng dẫn chữ" || len(ds[1].Guides) != 0 {
		t.Fatalf("hướng dẫn sai: %+v", ds)
	}

	// Không nhận định danh người từ tham số.
	for _, q := range []string{"assignee_person_id", "person_id"} {
		ds = docViecCuaToi(t, k.goi(t, "GET", fmt.Sprintf("/assigned-tasks/mine?%s=%d", q, k.nv2), k.nv, nil))
		if len(ds) != 2 || ds[0].ID != moi {
			t.Fatalf("tham số %s đổi được người: %+v", q, ds)
		}
	}
	ds = docViecCuaToi(t, k.goi(t, "GET", "/assigned-tasks/mine", k.nv2, nil))
	if len(ds) != 1 || ds[0].ID != cuaNguoiKhac {
		t.Fatalf("nv2 đọc sai: %+v", ds)
	}

	// Không phiên ⇒ từ chối. Cửa cả quán vẫn không mở cho người nhận; người nhận vẫn không đánh dấu được.
	tuChoi(t, k.goi(t, "GET", "/assigned-tasks/mine", 0, nil), http.StatusUnauthorized, "unauthenticated", "")
	// Cookie khách còn hiệu lực không phải phiên người làm (I-035); bổ sung 2026-11-03, T-284.
	tuChoi(t, goiBangCookieKhach(t, k, "/assigned-tasks/mine", tokenKhach), http.StatusUnauthorized, "unauthenticated", "")
	tuChoi(t, k.goi(t, "GET", "/assigned-tasks", k.nv, nil), http.StatusForbidden, "not_on_counter_duty", "")
	tuChoi(t, k.goi(t, "POST", fmt.Sprintf("/assigned-tasks/%d/marks", moi), k.nv, map[string]any{"mark": "done"}), http.StatusForbidden, "not_on_counter_duty", "")

	if sau := k.soDong(t); sau != truoc {
		t.Fatalf("cửa đọc mà database đổi: %s → %s", truoc, sau)
	}
}

// phienKhach dựng một phiên khách còn hiệu lực bằng dòng thật, rồi đọc lại để chắc cookie ấy hợp lệ với cửa khách.
func phienKhach(t *testing.T, k khung) string {
	t.Helper()
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		t.Fatal(err)
	}
	token := base64.RawURLEncoding.EncodeToString(b)
	h := sha256.Sum256([]byte(token))
	email := fmt.Sprintf("test-khach-%d@example.test", time.Now().UnixNano())
	if err := k.coVet(func(tx pgx.Tx) error {
		var a int64
		if err := tx.QueryRow(k.ctx, `INSERT INTO shop.customer_account (email, display_name) VALUES ($1, 'test-khách') RETURNING id`, email).Scan(&a); err != nil {
			return err
		}
		_, err := tx.Exec(k.ctx, `INSERT INTO shop.customer_session (customer_account_id, token_hash, expires_at) VALUES ($1, $2, now() + interval '1 day')`, a, h[:])
		return err
	}); err != nil {
		t.Fatal(err)
	}
	var con int64
	if err := k.owner.QueryRow(k.ctx, `SELECT count(*) FROM shop.customer_session WHERE token_hash = $1 AND ended_at IS NULL AND expires_at > now()`, h[:]).Scan(&con); err != nil || con != 1 || len(token) != 43 {
		t.Fatalf("phiên khách dựng sai: %d phiên, token %d ký tự, %v", con, len(token), err)
	}
	return token
}

func goiBangCookieKhach(t *testing.T, k khung, path, token string) traVe {
	t.Helper()
	req, err := http.NewRequestWithContext(k.ctx, "GET", k.srv.URL+path, nil)
	if err != nil {
		t.Fatal(err)
	}
	req.AddCookie(&http.Cookie{Name: authz.CookieKhach, Value: token})
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer res.Body.Close()
	out := traVe{status: res.StatusCode, body: map[string]any{}}
	_ = json.NewDecoder(res.Body).Decode(&out.body)
	return out
}
