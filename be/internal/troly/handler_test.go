package troly_test

import (
	"context"
	"encoding/json"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/troly"
	"github.com/gin-gonic/gin"
)

func TestI041_DuongHoiKiemHinhKhongCanDB(t *testing.T) {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	troly.Routes(r, troly.MoiLop(nil, troly.CauHinh{NhaCungCap: "tat"}, nil), nil, nil)
	for _, tc := range []struct{ body, field string }{
		{`{"question":1}`, "question"},
		{`{"question":null}`, "question"},
		{`{"question":"   "}`, "question"},
		{`{"question":"hỏi","history":null}`, "history"},
		{`{"question":"hỏi","history":{}}`, "history"},
		{`{"question":"hỏi","history":[{"role":"user"}]}`, "history"},
		{`{"question":"hỏi","history":[{"role":"user","text":1}]}`, "history"},
		{`{"question":"hỏi"} {}`, ""},
	} {
		w := httptest.NewRecorder()
		r.ServeHTTP(w, httptest.NewRequest("POST", "/chat/turns", strings.NewReader(tc.body)))
		var got struct{ Code, Field string }
		if err := json.Unmarshal(w.Body.Bytes(), &got); err != nil {
			t.Fatal(err)
		}
		if w.Code != 400 || got.Code != "invalid_request" || got.Field != tc.field {
			t.Fatalf("%s: %d %s", tc.body, w.Code, w.Body.String())
		}
	}
	w := httptest.NewRecorder()
	r.ServeHTTP(w, httptest.NewRequest("POST", "/chat/turns", strings.NewReader(`{"question":"hỏi","history":[]}`)))
	if w.Code != 200 || w.Body.String() != `{"answer":null,"sources":[],"degraded_reason":"tat"}` {
		t.Fatalf("%d %s", w.Code, w.Body.String())
	}
}

func TestI041_NhaGiaMacDinhBatDauLaiMoiLuot(t *testing.T) {
	n := troly.MoiNhaGiaMacDinh()
	for i := 0; i < 2; i++ {
		first, err := n.Goi(context.Background(), troly.GoiModel{})
		if err != nil || first.GoiCongCu == nil || first.GoiCongCu.Ten != "doc_menu" {
			t.Fatalf("%+v %v", first, err)
		}
		next, err := n.Goi(context.Background(), troly.GoiModel{Buoc: []troly.BuocCongCu{{Loi: "loi_cong_cu"}}})
		if err != nil || next.GoiCongCu != nil || !strings.Contains(next.Chu, "model giả") || !strings.Contains(next.Chu, "menu") {
			t.Fatalf("%+v %v", next, err)
		}
	}
	ctx, cancel := context.WithDeadline(context.Background(), time.Now().Add(-time.Second))
	defer cancel()
	if _, err := n.Goi(ctx, troly.GoiModel{}); err == nil {
		t.Fatal("phải nhận huỷ context")
	}
}
