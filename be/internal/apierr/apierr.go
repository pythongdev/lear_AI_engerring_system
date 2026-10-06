// Package apierr là bản code của hình lỗi chung và bảng tên từ chối → mã trong hợp đồng API
// (docs/product/3-be/openapi.yaml; 01-hop-dong-api.md §3 · §4). Hợp đồng thắng (ADR-084):
// thêm một mã hay một dòng ánh xạ là sửa hợp đồng trước, rồi sửa ở đây; Gate 1g so hai bản.
package apierr

import (
	"encoding/json"
	"errors"
	"net/http"

	"github.com/jackc/pgx/v5/pgconn"
)

// Code là một giá trị của ErrorCode trong hợp đồng.
type Code string

const (
	CodeInternalError  Code = "internal_error"
	CodeInvalidRequest Code = "invalid_request"

	// Quyền theo chỗ đứng (P3-05, ADR-085).
	CodeUnauthenticated     Code = "unauthenticated"
	CodeNotOnCounterDuty    Code = "not_on_counter_duty"
	CodeOwnerOnly           Code = "owner_only"
	CodeQRCodeNotCurrent    Code = "qr_code_not_current"
	CodeDiningTableNotFound Code = "dining_table_not_found"
	CodeQRCodeIssueConflict Code = "qr_code_issue_conflict"

	// Menu và giá (P3-06, I-009 · I-010).
	CodeMenuItemNotFound          Code = "menu_item_not_found"
	CodeMenuOptionNotFound        Code = "menu_option_not_found"
	CodeMenuComponentNotFound     Code = "menu_component_not_found"
	CodeMenuItemComponentNotFound Code = "menu_item_component_not_found"
	CodeMenuItemDiscontinued      Code = "menu_item_discontinued"
	CodeOptionCombinationInvalid  Code = "option_combination_invalid"
)

// statusOf là x-http-status của ErrorCode.
var statusOf = map[Code]int{
	CodeInternalError:             500,
	CodeInvalidRequest:            400,
	CodeUnauthenticated:           401,
	CodeNotOnCounterDuty:          403,
	CodeOwnerOnly:                 403,
	CodeQRCodeNotCurrent:          404,
	CodeDiningTableNotFound:       404,
	CodeQRCodeIssueConflict:       409,
	CodeMenuItemNotFound:          404,
	CodeMenuOptionNotFound:        404,
	CodeMenuComponentNotFound:     404,
	CodeMenuItemComponentNotFound: 404,
	CodeMenuItemDiscontinued:      409,
	CodeOptionCombinationInvalid:  422,
}

// constraintCodes giữ đúng các dòng của x-constraint-errors mang mã công khai. Tên vắng mặt ở đây —
// internal, unreviewed hay chưa từng thấy — là lỗi hệ thống chung, không bao giờ là ghi thành công
// (ADR-082 điểm 5.3).
var constraintCodes = map[string]Code{
	"qr_code_dining_table_fkey":         CodeDiningTableNotFound,
	"qr_code_one_current_per_table_key": CodeQRCodeIssueConflict,
	// Lần đổi bắt đầu trước mà ghi sau một lần đổi khác: now() của nó sớm hơn mốc cấp của mã
	// vừa sinh, nên "thay trước lúc cấp" bị từ chối — cùng một ca chen nhau.
	"qr_code_replaced_after_issued_check": CodeQRCodeIssueConflict,
}

// Error là hình lỗi chung trên dây (schema Error của hợp đồng).
type Error struct {
	Code  Code   `json:"code"`
	Field string `json:"field,omitempty"`
}

// Error cho Error đi qua đường lỗi của Go (errors.As) từ cửa tới chỗ gửi.
func (e Error) Error() string {
	if e.Field != "" {
		return string(e.Code) + ": " + e.Field
	}
	return string(e.Code)
}

// Status trả status HTTP của mã theo hợp đồng.
func (e Error) Status() int {
	if s, ok := statusOf[e.Code]; ok {
		return s
	}
	return statusOf[CodeInternalError]
}

// FromDB dịch một lời từ chối của database qua TÊN của nó (QC-10), không qua chữ của câu báo lỗi.
// Tên trả về là để cửa ghi lại; nó và câu nguyên văn của database không tới người dùng.
func FromDB(err error) (Error, string) {
	var pg *pgconn.PgError
	if !errors.As(err, &pg) {
		return Error{Code: CodeInternalError}, ""
	}
	if code, ok := constraintCodes[pg.ConstraintName]; ok {
		return Error{Code: code}, pg.ConstraintName
	}
	return Error{Code: CodeInternalError}, pg.ConstraintName
}

// Write gửi lỗi theo hình chung, với status của mã.
func Write(w http.ResponseWriter, e Error) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(e.Status())
	_ = json.NewEncoder(w).Encode(e)
}
