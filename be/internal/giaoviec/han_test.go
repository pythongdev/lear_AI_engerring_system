package giaoviec_test

import (
	"fmt"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/giaoviec"
	"context"
	"errors"
)

func TestI030_TaoViecKhongHanBiChanTruocDatabase(t *testing.T) {
	_, err := giaoviec.NewService(nil).Tao(context.Background(), 1, giaoviec.YeuCau{Content: "Việc", AssigneeID: 2})
	var e apierr.Error
	if !errors.As(err, &e) || e.Code != apierr.CodeInvalidRequest || e.Field != "due_at" {
		t.Fatalf("muốn invalid_request due_at, nhận %v", err)
	}
}

// PostgreSQL thật: hạn đi qua API, lưu DB, danh sách, sửa có vết; bỏ trường giữ nguyên.
func TestI030_HanHoanThanhLuuDocSuaCoVet(t *testing.T) {
	k := dung(t)
	r := k.tao(t, k.chu, "test-hạn ngày giờ", k.nv)
	canDat(t, r, http.StatusCreated)
	id := r.so(t, "assigned_task_id")
	path := fmt.Sprintf("/assigned-tasks/%d", id)
	check := func(body map[string]any, want string) {
		t.Helper()
		raw, ok := body["due_at"].(string)
		got, err := time.Parse(time.RFC3339Nano, raw)
		expected, _ := time.Parse(time.RFC3339Nano, want)
		if !ok || err != nil || !got.Equal(expected) {
			t.Fatalf("due_at muốn %s, nhận %v", want, body["due_at"])
		}
	}
	check(r.body, "2026-10-25T09:30:00+07:00")
	check(k.trongDanhSach(t, "", id), "2026-10-25T09:30:00+07:00")
	r = k.goi(t, "PUT", path, k.chu, map[string]any{"content": "test-hạn ngày giờ", "assignee_person_id": k.nv, "reason": "đổi hạn", "due_at": "2026-10-26T03:45:00Z"})
	canDat(t, r, http.StatusOK)
	check(r.body, "2026-10-26T10:45:00+07:00")
	var before, after time.Time
	var reason string
	if err := k.owner.QueryRow(k.ctx, `SELECT (before_image->>'due_at')::timestamptz, (after_image->>'due_at')::timestamptz, reason FROM shop.record_revision WHERE target_table_code='assigned_task' AND target_row=$1 ORDER BY id DESC LIMIT 1`, id).Scan(&before, &after, &reason); err != nil {
		t.Fatal(err)
	}
	old, _ := time.Parse(time.RFC3339, "2026-10-25T09:30:00+07:00")
	newer, _ := time.Parse(time.RFC3339, "2026-10-26T10:45:00+07:00")
	if !before.Equal(old) || !after.Equal(newer) || reason != "đổi hạn" {
		t.Fatalf("vết hạn sai: %v -> %v, %s", before, after, reason)
	}
	r = k.goi(t, "PUT", path, k.chu, map[string]any{"content": "test-đổi nội dung", "assignee_person_id": k.nv, "reason": "giữ hạn"})
	canDat(t, r, http.StatusOK)
	check(r.body, "2026-10-26T10:45:00+07:00")
	// Bản ghi cũ mô phỏng bằng INSERT không hạn: migration không backfill giả.
	legacy := k.so(t, "INSERT INTO shop.assigned_task (content, assignee_person_id) VALUES ('test-việc cũ', $1) RETURNING id", k.nv)
	r = k.goi(t, "GET", fmt.Sprintf("/assigned-tasks/%d", legacy), k.chu, nil)
	canDat(t, r, http.StatusOK)
	due, exists := r.body["due_at"]
	if !exists || due != nil {
		t.Fatalf("việc cũ phải có due_at:null: %v", r.body)
	}
	r = k.goi(t, "PUT", fmt.Sprintf("/assigned-tasks/%d", legacy), k.chu, map[string]any{"content": "test-việc cũ sửa", "assignee_person_id": k.nv, "reason": "sửa nội dung"})
	canDat(t, r, http.StatusOK)
	if r.body["due_at"] != nil {
		t.Fatalf("không được gán hạn giả: %v", r.body)
	}
}

func TestI030_LuiMigrationKhongLamMatHan(t *testing.T) {
	k := dung(t)
	r := k.tao(t, k.chu, "test-khoá lùi hạn", k.nv)
	canDat(t, r, http.StatusCreated)
	source, err := os.ReadFile("../../../db/migrations/20261024120000_han_giao_viec.down.sql")
	if err != nil {
		t.Fatal(err)
	}
	tx, err := k.owner.Begin(k.ctx)
	if err != nil {
		t.Fatal(err)
	}
	defer tx.Rollback(k.ctx)
	if _, err = tx.Exec(k.ctx, "SET LOCAL search_path = shop, public"); err != nil {
		t.Fatal(err)
	}
	_, err = tx.Exec(k.ctx, string(source))
	if err == nil || !strings.Contains(err.Error(), "đường lùi từ chối") {
		t.Fatalf("lùi phải từ chối mất hạn, nhận %v", err)
	}
	if err = tx.Rollback(k.ctx); err != nil {
		t.Fatal(err)
	}
	if k.so(t, "SELECT count(*) FROM shop.assigned_task WHERE id=$1 AND due_at IS NOT NULL", r.so(t, "assigned_task_id")) != 1 {
		t.Fatal("lùi làm mất hạn đã lưu")
	}
}
