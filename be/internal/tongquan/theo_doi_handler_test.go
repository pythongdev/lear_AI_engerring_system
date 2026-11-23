package tongquan_test

import (
	"context"
	"encoding/json"
	"net/http/httptest"
	"testing"

	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/testhelper"
	"banhcuon/be/internal/tongquan"
	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5"
)

func TestI023_TheoDoiHandlerKhongDangNhap(t *testing.T) {
	ctx := context.Background()
	pool, err := postgres.Open(ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	db, err := pgx.Connect(ctx, testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close(ctx)
	var tableID int64
	if err := db.QueryRow(ctx, `INSERT INTO shop.dining_table(label) VALUES ('test-t372-http') RETURNING id`).Scan(&tableID); err != nil {
		t.Fatal(err)
	}
	var personID int64
	if err := db.QueryRow(ctx, `INSERT INTO shop.person(display_name) VALUES ('test-t372-http-cap-ma') RETURNING id`).Scan(&personID); err != nil {
		t.Fatal(err)
	}
	if _, err := db.Exec(ctx, `INSERT INTO shop.qr_code(person_id,dining_table_id,code,issued_at,replaced_at) VALUES
	 ($2,$1,'test-t372-http-old',now()-interval '2 days',now()-interval '1 day'),
	 ($2,$1,'test-t372-http-current',now()-interval '1 day',NULL)`, tableID, personID); err != nil {
		t.Fatal(err)
	}
	r := gin.New()
	tongquan.Routes(r, tongquan.NewService(pool))
	for _, ca := range []struct {
		code   string
		status int
	}{{"test-t372-http-current", 200}, {"test-t372-http-old", 404}, {"test-t372-http-unknown", 404}} {
		t.Run(ca.code, func(t *testing.T) {
			w := httptest.NewRecorder()
			r.ServeHTTP(w, httptest.NewRequest("GET", "/qr-codes/"+ca.code+"/progress", nil))
			if w.Code != ca.status {
				t.Fatalf("HTTP %d: %s", w.Code, w.Body.String())
			}
			var body map[string]json.RawMessage
			if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
				t.Fatal(err)
			}
			if ca.status == 404 {
				if string(body["code"]) != `"qr_code_not_current"` {
					t.Fatalf("mã lỗi: %s", w.Body.String())
				}
			} else if string(body["session"]) != "null" || string(body["table_label"]) != `"test-t372-http"` || len(body["read_at"]) == 0 {
				t.Fatalf("bàn chưa có phiên: %s", w.Body.String())
			}
		})
	}
}
