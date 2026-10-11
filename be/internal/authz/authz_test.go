// Test từ chối của quyền theo chỗ đứng (P3-05, ADR-085). Viết TRƯỚC khi có package authz —
// Claude viết, Codex làm cho xanh mà không sửa điều kiện kiểm nào.
package authz_test

import (
	"context"
	"errors"
	"fmt"
	"testing"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Cửa giả chỉ sống trong test: lớp quyền của nó là thứ được kiểm, không phải câu ghi nào.
var (
	cuaQuay    = authz.Door{Code: "test/viec_cua_quay", Need: authz.NeedCounter}
	cuaChuQuan = authz.Door{Code: "test/viec_cua_chu_quan", Need: authz.NeedOwner}
)

type khung struct {
	ctx   context.Context
	pool  *pgxpool.Pool
	owner *pgx.Conn
}

// coVet chạy câu dựng dữ liệu trong một giao dịch có khai người và lý do: từ bước 20 (T-138, ADR-092)
// database từ chối lần sửa — và lần thêm dòng con vào bản ghi đã có — mà giao dịch không khai.
func (k khung) coVet(fn func(pgx.Tx) error) error {
	return pgx.BeginFunc(k.ctx, k.owner, func(tx pgx.Tx) error {
		if _, err := tx.Exec(k.ctx, `WITH co AS (SELECT id FROM shop.person WHERE display_name = 'test-người dựng dữ liệu' ORDER BY id LIMIT 1),
			moi AS (INSERT INTO shop.person (display_name) SELECT 'test-người dựng dữ liệu' WHERE NOT EXISTS (SELECT 1 FROM co) RETURNING id)
			SELECT set_config('shop.actor_person_id', id::text, true), set_config('shop.revision_reason', 'test-dựng dữ liệu', true)
			FROM (SELECT id FROM co UNION ALL SELECT id FROM moi) p`); err != nil {
			return err
		}
		return fn(tx)
	})
}

func dung(t *testing.T) khung {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	t.Cleanup(cancel)
	pool, err := postgres.Open(ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	owner, err := pgx.Connect(ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { owner.Close(context.Background()) })
	return khung{ctx: ctx, pool: pool, owner: owner}
}

func (k khung) nguoi(t *testing.T, ten string, chuQuan bool) int64 {
	t.Helper()
	var id int64
	if err := k.owner.QueryRow(k.ctx,
		"INSERT INTO shop.person (display_name, is_owner) VALUES ($1, $2) RETURNING id",
		fmt.Sprintf("%s · %s", ten, t.Name()), chuQuan).Scan(&id); err != nil {
		t.Fatal(err)
	}
	return id
}

// vaoQuay: người đang đứng (nếu có) khép khoảng của mình, người này mở khoảng mới — một mốc đổi.
func (k khung) vaoQuay(t *testing.T, nguoi int64) {
	t.Helper()
	time.Sleep(2 * time.Millisecond)
	if err := k.coVet(func(tx pgx.Tx) error {
		_, err := tx.Exec(k.ctx, "UPDATE shop.counter_duty SET ended_at = now() WHERE ended_at IS NULL")
		return err
	}); err != nil {
		t.Fatal(err)
	}
	time.Sleep(2 * time.Millisecond)
	if _, err := k.owner.Exec(k.ctx,
		"INSERT INTO shop.counter_duty (person_id, started_at) VALUES ($1, now())", nguoi); err != nil {
		t.Fatal(err)
	}
}

// roiQuay: khép mọi khoảng đang mở — quầy trống.
func (k khung) roiQuay(t *testing.T) {
	t.Helper()
	time.Sleep(2 * time.Millisecond)
	if err := k.coVet(func(tx pgx.Tx) error {
		_, err := tx.Exec(k.ctx, "UPDATE shop.counter_duty SET ended_at = now() WHERE ended_at IS NULL")
		return err
	}); err != nil {
		t.Fatal(err)
	}
	time.Sleep(2 * time.Millisecond)
}

// chay gọi authz.Run và trả mã lỗi ("" khi chạy được) cùng người thao tác đọc trong giao dịch.
func (k khung) chay(t *testing.T, nguoi int64, d authz.Door) (apierr.Code, int64, bool) {
	t.Helper()
	var actor int64
	daChay := false
	err := authz.Run(k.ctx, k.pool, nguoi, d, func(tx pgx.Tx) error {
		daChay = true
		return tx.QueryRow(k.ctx, "SELECT actor_person_id()").Scan(&actor)
	})
	if err == nil {
		return "", actor, daChay
	}
	var e apierr.Error
	if !errors.As(err, &e) {
		t.Fatalf("authz.Run trả lỗi không phải apierr.Error: %v", err)
	}
	return e.Code, actor, daChay
}

func TestYC15_NguoiDaRoiQuayKhongLamViecCuaQuay(t *testing.T) {
	k := dung(t)
	a := k.nguoi(t, "A", false)
	b := k.nguoi(t, "B", false)
	k.vaoQuay(t, a)
	k.vaoQuay(t, b) // A ra, B vào — một mốc đổi
	code, _, daChay := k.chay(t, a, cuaQuay)
	t.Logf("A đã rời quầy bấm việc của quầy: mã=%q, thân cửa chạy=%t", code, daChay)
	if code != apierr.CodeNotOnCounterDuty || daChay {
		t.Fatalf("muốn %q và thân cửa không chạy", apierr.CodeNotOnCounterDuty)
	}
	code, actor, daChay := k.chay(t, b, cuaQuay)
	t.Logf("B đang đứng quầy: mã=%q, thân cửa chạy=%t, người thao tác=%d (B=%d)", code, daChay, actor, b)
	if code != "" || !daChay || actor != b {
		t.Fatal("người đang đứng quầy phải làm được việc của quầy, và người thao tác là chính người ấy")
	}
	k.roiQuay(t)
	code, _, daChay = k.chay(t, b, cuaQuay)
	t.Logf("quầy trống, B bấm: mã=%q, thân cửa chạy=%t", code, daChay)
	if code != apierr.CodeNotOnCounterDuty || daChay {
		t.Fatalf("muốn %q khi không ai đứng quầy", apierr.CodeNotOnCounterDuty)
	}
}

func TestYC16_ChuQuanKhongDungQuayKhongLamViecCuaQuay(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ quán", true)
	a := k.nguoi(t, "A", false)
	k.vaoQuay(t, a)
	code, _, daChay := k.chay(t, chu, cuaQuay)
	t.Logf("chủ quán không đứng quầy bấm việc của quầy: mã=%q, thân cửa chạy=%t", code, daChay)
	if code != apierr.CodeNotOnCounterDuty || daChay {
		t.Fatalf("chức vụ không mở cửa của quầy (architecture.md §4): muốn %q", apierr.CodeNotOnCounterDuty)
	}
	code, actor, _ := k.chay(t, chu, cuaChuQuan)
	if code != "" || actor != chu {
		t.Fatalf("chủ quán không đứng quầy vẫn giữ quyền quản trị: mã=%q", code)
	}
	code, _, daChay = k.chay(t, a, cuaChuQuan)
	t.Logf("A đứng quầy bấm việc của chủ quán: mã=%q, thân cửa chạy=%t", code, daChay)
	if code != apierr.CodeOwnerOnly || daChay {
		t.Fatalf("đứng quầy không mở cửa của chủ quán: muốn %q", apierr.CodeOwnerOnly)
	}
	k.roiQuay(t)
}

func TestYC16_ChuQuanDungQuayCoCaHaiQuyen(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ quán", true)
	k.vaoQuay(t, chu)
	codeQuay, actorQuay, _ := k.chay(t, chu, cuaQuay)
	codeChu, actorChu, _ := k.chay(t, chu, cuaChuQuan)
	t.Logf("chủ quán đứng quầy: lớp quay=%q, lớp chu_quan=%q", codeQuay, codeChu)
	if codeQuay != "" || codeChu != "" || actorQuay != chu || actorChu != chu {
		t.Fatal("chủ quán đứng quầy phải qua cả hai lớp — hai vai cộng vào nhau, không thay nhau")
	}
	k.roiQuay(t)
}

func TestI012_KhongNguoiThiKhongThaoTacNao(t *testing.T) {
	k := dung(t)
	a := k.nguoi(t, "A", false)
	k.vaoQuay(t, a)
	for _, nguoi := range []int64{0, -1, 9_000_000_000} {
		for _, d := range []authz.Door{cuaQuay, cuaChuQuan} {
			code, _, daChay := k.chay(t, nguoi, d)
			t.Logf("người %d bấm %s: mã=%q, thân cửa chạy=%t", nguoi, d.Code, code, daChay)
			if code != apierr.CodeUnauthenticated || daChay {
				t.Fatalf("muốn %q và thân cửa không chạy", apierr.CodeUnauthenticated)
			}
		}
	}
	k.roiQuay(t)
}

func TestI012_LoiCuaThanCuaLuiCaGiaoDich(t *testing.T) {
	k := dung(t)
	chu := k.nguoi(t, "chủ quán", true)
	ten := "bàn lùi · " + t.Name()
	loi := errors.New("thân cửa hỏng")
	err := authz.Run(k.ctx, k.pool, chu, cuaChuQuan, func(tx pgx.Tx) error {
		if _, err := tx.Exec(k.ctx, "INSERT INTO dining_table (label) VALUES ($1)", ten); err != nil {
			return err
		}
		return loi
	})
	if !errors.Is(err, loi) {
		t.Fatalf("authz.Run phải trả nguyên lỗi của thân cửa, nhận %v", err)
	}
	var n int
	if err := k.owner.QueryRow(k.ctx, "SELECT count(*) FROM shop.dining_table WHERE label = $1", ten).Scan(&n); err != nil {
		t.Fatal(err)
	}
	if n != 0 {
		t.Fatalf("thân cửa lỗi mà vẫn ghi %d dòng", n)
	}
}

// ADR-089 điểm 8: lớp két cộng quyền quầy và cờ chủ quán.
func TestI012_QuayHoacChuQuanTuChoiNguoiNgoaiQuay(t *testing.T) {
	k := dung(t)
	d := authz.Door{Code: "test/ket", Need: authz.NeedCounterOrOwner}
	thuong := k.nguoi(t, "người thường", false)
	chu := k.nguoi(t, "chủ quán", true)
	k.roiQuay(t)
	for _, c := range []struct {
		id   int64
		code apierr.Code
	}{
		{0, apierr.CodeUnauthenticated}, {thuong, apierr.CodeNotOnCounterDuty},
	} {
		code, _, ran := k.chay(t, c.id, d)
		if code != c.code || ran {
			t.Fatalf("người %d: mã %s, đã chạy %v", c.id, code, ran)
		}
	}
	code, actor, ran := k.chay(t, chu, d)
	if code != "" || !ran || actor != chu {
		t.Fatalf("chủ quán: %s %d %v", code, actor, ran)
	}
	k.vaoQuay(t, thuong)
	code, actor, ran = k.chay(t, thuong, d)
	if code != "" || !ran || actor != thuong {
		t.Fatalf("người quầy: %s %d %v", code, actor, ran)
	}
}
