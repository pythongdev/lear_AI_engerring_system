// Test bảng chuyển trạng thái (P3-07, ADR-087; I-016). Viết TRƯỚC khi có package vongdoi — Claude
// viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào. Bảng của code KHÔNG được so với một bản
// gõ lại trong test: test đọc LÚC CHẠY hai bảng §5.2 · §5.3 của owner
// (docs/product/0-ba/ban-hang/05-vong-doi.md) và bảng tên → mã của
// docs/product/2-db/02-luoc-do-ban-hang.md §4, nên bảng §5 đổi mà code không đổi thì test đỏ.
package vongdoi_test

import (
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"

	"banhcuon/be/internal/vongdoi"
)

func docFile(t *testing.T, rel string) string {
	t.Helper()
	goc, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	b, err := os.ReadFile(filepath.Join(strings.TrimSpace(string(goc)), rel))
	if err != nil {
		t.Fatal(err)
	}
	return string(b)
}

// muc trả phần thân của mục mở bằng dòng `tieuDe` tới tiêu đề cùng bậc kế tiếp.
func muc(t *testing.T, s, tieuDe string) string {
	t.Helper()
	i := strings.Index(s, "\n"+tieuDe)
	if i < 0 {
		t.Fatalf("không thấy mục %q", tieuDe)
	}
	s = s[i+1:]
	bac := tieuDe[:strings.Index(tieuDe, " ")+1]
	if j := strings.Index(s[1:], "\n"+bac); j >= 0 {
		s = s[:j+1]
	}
	return s
}

var chuThichNgoac = regexp.MustCompile(`\*\([^)]*\)\*`)

// ten bỏ chú thích kiểu *(bàn)*, dấu nhấn và khoảng trắng: "**Trống** *(bàn)*" ⇒ "Trống".
func ten(o string) string {
	o = chuThichNgoac.ReplaceAllString(o, "")
	o = strings.ReplaceAll(o, "*", "")
	return strings.TrimSpace(o)
}

// maTrangThai đọc bảng §4 của 02-luoc-do-ban-hang.md: tên ở owner → mã, cho đúng một cột.
func maTrangThai(t *testing.T, cot string) map[string]string {
	t.Helper()
	bang := muc(t, docFile(t, "docs/product/2-db/02-luoc-do-ban-hang.md"), "## 4.")
	dong := regexp.MustCompile("(?m)^\\| `" + regexp.QuoteMeta(cot) + "` \\| `([a-z_]+)` \\| (.+?) \\(§5\\.[0-9]\\) \\|$")
	out := map[string]string{}
	for _, m := range dong.FindAllStringSubmatch(bang, -1) {
		out[strings.TrimSpace(m[2])] = m[1]
	}
	if len(out) == 0 {
		t.Fatalf("§4 không có dòng nào của %s", cot)
	}
	return out
}

// capCuaOwner đọc một bảng §5 (bốn cột: nguồn · sự kiện · đích · ai) thành tập cặp (nguồn, đích) theo
// mã. Nguồn không có mã mà đích có mã là dòng SINH RA ("(chưa có đơn)", bàn "Trống") ⇒ nguồn "".
// Đích không có mã (trạng thái của cái bàn, ghép bàn) không thuộc vòng đời có cột trạng thái ⇒ bỏ.
func capCuaOwner(t *testing.T, tieuDe string, ma map[string]string) []string {
	t.Helper()
	bang := muc(t, docFile(t, "docs/product/0-ba/ban-hang/05-vong-doi.md"), tieuDe)
	tap := map[string]bool{}
	for _, l := range strings.Split(bang, "\n") {
		if !strings.HasPrefix(l, "| ") || strings.HasPrefix(l, "| Trạng thái nguồn") || strings.HasPrefix(l, "|---") {
			continue
		}
		o := strings.Split(l, "|")
		if len(o) != 6 {
			t.Fatalf("dòng bảng sai hình: %q", l)
		}
		nguon, dich := ten(o[1]), ten(o[3])
		maDich, coDich := ma[dich]
		if !coDich {
			continue
		}
		maNguon := ma[nguon]
		tap[maNguon+" → "+maDich] = true
	}
	return sapXep(tap)
}

func sapXep(tap map[string]bool) []string {
	out := make([]string, 0, len(tap))
	for k := range tap {
		out = append(out, k)
	}
	sort.Strings(out)
	return out
}

func capCuaCode(cap [][2]string) []string {
	tap := map[string]bool{}
	for _, c := range cap {
		tap[c[0]+" → "+c[1]] = true
	}
	return sapXep(tap)
}

func soHaiTap(t *testing.T, ten string, owner, code []string) {
	t.Helper()
	t.Logf("%s — owner %d cặp: %s", ten, len(owner), strings.Join(owner, " · "))
	if strings.Join(owner, "\n") != strings.Join(code, "\n") {
		t.Fatalf("%s: bảng của code khác owner\n owner: %v\n code:  %v", ten, owner, code)
	}
	if len(owner) < 4 {
		t.Fatalf("%s: owner chỉ đọc ra %d cặp — bộ đọc bảng hỏng", ten, len(owner))
	}
}

// Mọi cặp (nguồn, đích) của §5.2 có trong bảng đơn của code, và không cặp nào ngoài nó.
func TestI016_BangChuyenDonKhopVongDoi(t *testing.T) {
	owner := capCuaOwner(t, "### 5.2", maTrangThai(t, "sales_order.status"))
	soHaiTap(t, "vòng đời đơn §5.2", owner, capCuaCode(vongdoi.CapDon()))
}

// Như trên cho §5.3 — chỉ những dòng có đích là trạng thái của PHIÊN; hai trạng thái của cái bàn
// đọc ra từ chi tiết (02-luoc-do-ban-hang.md §3, I-003), không phải một cột.
func TestI016_BangChuyenPhienKhopVongDoi(t *testing.T) {
	owner := capCuaOwner(t, "### 5.3", maTrangThai(t, "table_session.status"))
	soHaiTap(t, "vòng đời phiên §5.3", owner, capCuaCode(vongdoi.CapPhien()))
}

// Trạng thái đầu của một đơn do KÊNH quyết (§5.2 hai dòng "Mới → …", shop-facts §6.2): kênh khách tự
// bấm phải duyệt, kênh người của quán nhập thì không. Kênh lạ bị từ chối, không đoán.
func TestI016_TrangThaiDauTheoKenh(t *testing.T) {
	muon := map[string]string{
		"qr_table":       "pending_confirmation",
		"delivery":       "pending_confirmation",
		"pickup":         "pending_confirmation",
		"staff_pos":      "confirmed",
		"phone_preorder": "confirmed",
	}
	for kenh, dau := range muon {
		got, err := vongdoi.TrangThaiDauDon(kenh)
		if err != nil || got != dau {
			t.Fatalf("kênh %s: muốn %s, nhận %q %v", kenh, dau, got, err)
		}
	}
	if _, err := vongdoi.TrangThaiDauDon("grab"); err == nil {
		t.Fatal("kênh lạ phải bị từ chối")
	}
}
