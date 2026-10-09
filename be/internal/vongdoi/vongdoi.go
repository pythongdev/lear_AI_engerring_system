// Package vongdoi sở hữu hai cột trạng thái; chỉ chạy trong giao dịch của cửa gọi.
package vongdoi

import (
	"context"
	_ "embed"
	"errors"
	"fmt"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"github.com/jackc/pgx/v5"
)

var CuaChuyenDon = authz.Door{Code: "vongdoi/chuyen_don", Need: authz.NeedCallingDoor}
var CuaChuyenPhien = authz.Door{Code: "vongdoi/chuyen_phien", Need: authz.NeedCallingDoor}

//go:embed sql/chuyen_don/khoa.sql
var khoaDon string

//go:embed sql/chuyen_don/chuyen.sql
var chuyenDon string

//go:embed sql/chuyen_phien/khoa.sql
var khoaPhien string

//go:embed sql/chuyen_phien/chuyen.sql
var chuyenPhien string

//go:embed sql/chuyen_phien/dong_ban.sql
var dongBan string

// CapDon và CapPhien trả bản riêng để bên gọi không sửa bảng dùng chung.
func CapDon() [][2]string {
	return [][2]string{{"", "new"}, {"new", "pending_confirmation"}, {"new", "confirmed"},
		{"pending_confirmation", "confirmed"}, {"pending_confirmation", "cancelled"},
		{"confirmed", "in_progress"}, {"confirmed", "cancelled"},
		{"in_progress", "completed"}, {"in_progress", "delivering"}, {"in_progress", "cancelled"},
		{"completed", "cancelled"}, {"delivering", "completed"}}
}
func CapPhien() [][2]string {
	return [][2]string{{"", "open"}, {"open", "serving"}, {"serving", "awaiting_payment"}, {"awaiting_payment", "serving"}, {"awaiting_payment", "closed"}}
}
func coCap(cap [][2]string, tu, den string) bool {
	for _, c := range cap {
		if c == [2]string{tu, den} {
			return true
		}
	}
	return false
}
func KiemChuyenPhien(tu, den string) error {
	if !coCap(CapPhien(), tu, den) {
		return apierr.Error{Code: apierr.CodeTableSessionTransitionNotAllowed}
	}
	return nil
}
func TrangThaiDauDon(kenh string) (string, error) {
	switch kenh {
	case "qr_table", "delivery", "pickup":
		return "pending_confirmation", nil
	case "staff_pos", "phone_preorder":
		return "confirmed", nil
	default:
		return "", fmt.Errorf("kênh lạ %q", kenh)
	}
}

// CoVet khai và gỡ lý do sát câu sửa. Khách QR không khai lý do (F-060).
func CoVet(ctx context.Context, tx pgx.Tx, reason string, fn func() error) error {
	var actor bool
	if err := tx.QueryRow(ctx, "SELECT actor_person_id() IS NOT NULL").Scan(&actor); err != nil {
		return err
	}
	if actor {
		if _, err := tx.Exec(ctx, "SELECT set_config('shop.revision_reason', $1, true)", reason); err != nil {
			return err
		}
	}
	if err := fn(); err != nil {
		return err
	}
	if actor {
		_, err := tx.Exec(ctx, "SELECT set_config('shop.revision_reason', '', true)")
		return err
	}
	return nil
}

// Cửa gọi phải khoá phiên trước khi gọi ChuyenDon.
func ChuyenDon(ctx context.Context, tx pgx.Tx, id int64, den string) error {
	var tu, kenh string
	var trao *string
	if err := tx.QueryRow(ctx, khoaDon, id).Scan(&tu, &kenh, &trao); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return apierr.Error{Code: apierr.CodeSalesOrderNotFound}
		}
		return err
	}
	hop := coCap(CapDon(), tu, den)
	if tu == "new" {
		dau, err := TrangThaiDauDon(kenh)
		hop = hop && err == nil && dau == den
	}
	if den == "delivering" {
		hop = hop && trao != nil && *trao == "door_delivery"
	}
	if !hop {
		return apierr.Error{Code: apierr.CodeOrderTransitionNotAllowed}
	}
	return CoVet(ctx, tx, CuaChuyenDon.Code+": "+tu+" → "+den, func() error { _, err := tx.Exec(ctx, chuyenDon, id, den); return err })
}
func ChuyenPhien(ctx context.Context, tx pgx.Tx, id int64, den string) error {
	var tu string
	if err := tx.QueryRow(ctx, khoaPhien, id).Scan(&tu); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return apierr.Error{Code: apierr.CodeTableSessionNotFound}
		}
		return err
	}
	if err := KiemChuyenPhien(tu, den); err != nil {
		return err
	}
	reason := CuaChuyenPhien.Code + ": " + tu + " → " + den
	if err := CoVet(ctx, tx, reason, func() error { _, err := tx.Exec(ctx, chuyenPhien, id, den); return err }); err != nil {
		return err
	}
	if den == "closed" {
		return CoVet(ctx, tx, reason, func() error { _, err := tx.Exec(ctx, dongBan, id); return err })
	}
	return nil
}
