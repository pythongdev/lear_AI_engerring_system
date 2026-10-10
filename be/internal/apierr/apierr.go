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
	CodeOrderDiscountUndecided      Code = "order_discount_undecided"
	CodeDebtNoteRequired            Code = "debt_note_required"
	CodeOrderHandoverMismatch       Code = "order_handover_mismatch"
	CodeOrderJobsNotServed          Code = "order_jobs_not_served"
	CodePrepaymentBalanceExceeded   Code = "prepayment_balance_exceeded"
	CodeBillNotFound                Code = "bill_not_found"
	CodePrepaymentNotFound          Code = "prepayment_not_found"
	CodeBillHasNoDebt               Code = "bill_has_no_debt"
	CodeDebtAlreadySettled          Code = "debt_already_settled"
	CodeDebtOverpaid                Code = "debt_overpaid"
	CodeOrderNotPrepayable          Code = "order_not_prepayable"
	CodePrepaymentAlreadyReceived   Code = "prepayment_already_received"
	CodeOpeningFloatAlreadyDeclared Code = "opening_float_already_declared"
	CodeCashCountAlreadyRecorded    Code = "cash_count_already_recorded"
	CodeSaleDayReconciled           Code = "sale_day_reconciled"
	CodeCashDayIncomplete           Code = "cash_day_incomplete"
	CodeSaleDayAlreadyReconciled    Code = "sale_day_already_reconciled"
	CodePaperEntriesPending         Code = "paper_entries_pending"
	CodeGapExplanationRequired      Code = "gap_explanation_required"

	CodeStationJobNotFound               Code = "station_job_not_found"
	CodeStationJobTransitionNotAllowed   Code = "station_job_transition_not_allowed"
	CodeProductionBatchNotFound          Code = "production_batch_not_found"
	CodeProductionBatchAlreadyRolledBack Code = "production_batch_already_rolled_back"
	CodeProductionBatchHasServedUnits    Code = "production_batch_has_served_units"
	CodeStationJobHasWrongMakeNote       Code = "station_job_has_wrong_make_note"
	CodeTransferSourceNotAvailable       Code = "transfer_source_not_available"
	CodeTransferTargetNotWaiting         Code = "transfer_target_not_waiting"
	CodeWrongMakeNoteNotAllowed          Code = "wrong_make_note_not_allowed"
	CodeWrongMakeNoteNotFound            Code = "wrong_make_note_not_found"
	CodeWrongMakeNoteAlreadyCancelled    Code = "wrong_make_note_already_cancelled"
	CodeServedQuantityExceedsMade        Code = "served_quantity_exceeds_made"

	CodeOrderIntakePaused           Code = "order_intake_paused"
	CodeOutsideSellingHours         Code = "outside_selling_hours"
	CodeShopNotSeeingOrders         Code = "shop_not_seeing_orders"
	CodeDeliveryServedMarkUndecided Code = "delivery_served_mark_undecided"

	CodeSubmissionCodeConflict           Code = "submission_code_conflict"
	CodeDiningTableNeedsCleaning         Code = "dining_table_needs_cleaning"
	CodeDiningTableNotNeedingCleaning    Code = "dining_table_not_needing_cleaning"
	CodeSalesOrderNotFound               Code = "sales_order_not_found"
	CodeTableSessionNotFound             Code = "table_session_not_found"
	CodeOrderTransitionNotAllowed        Code = "order_transition_not_allowed"
	CodeTableSessionTransitionNotAllowed Code = "table_session_transition_not_allowed"
	CodeTableSessionHasOpenOrders        Code = "table_session_has_open_orders"
	CodePaymentPartsMismatch             Code = "payment_parts_mismatch"
	CodeDebtorNameMismatch               Code = "debtor_name_mismatch"

	CodeInternalError  Code = "internal_error"
	CodeInvalidRequest Code = "invalid_request"

	// Quyền theo chỗ đứng (P3-05, ADR-085).
	CodeUnauthenticated     Code = "unauthenticated"
	CodeNotOnCounterDuty    Code = "not_on_counter_duty"
	CodeCounterDutyChanged  Code = "counter_duty_changed"
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
	CodeOrderDiscountUndecided:      409,
	CodeDebtNoteRequired:            422,
	CodeOrderHandoverMismatch:       409,
	CodeOrderJobsNotServed:          409,
	CodePrepaymentBalanceExceeded:   409,
	CodeBillNotFound:                404,
	CodePrepaymentNotFound:          404,
	CodeBillHasNoDebt:               409,
	CodeDebtAlreadySettled:          409,
	CodeDebtOverpaid:                409,
	CodeOrderNotPrepayable:          409,
	CodePrepaymentAlreadyReceived:   409,
	CodeOpeningFloatAlreadyDeclared: 409,
	CodeCashCountAlreadyRecorded:    409,
	CodeSaleDayReconciled:           409,
	CodeCashDayIncomplete:           409,
	CodeSaleDayAlreadyReconciled:    409,
	CodePaperEntriesPending:         409,
	CodeGapExplanationRequired:      422,

	CodeStationJobNotFound:               404,
	CodeStationJobTransitionNotAllowed:   409,
	CodeProductionBatchNotFound:          404,
	CodeProductionBatchAlreadyRolledBack: 409,
	CodeProductionBatchHasServedUnits:    409,
	CodeStationJobHasWrongMakeNote:       409,
	CodeTransferSourceNotAvailable:       409,
	CodeTransferTargetNotWaiting:         409,
	CodeWrongMakeNoteNotAllowed:          409,
	CodeWrongMakeNoteNotFound:            404,
	CodeWrongMakeNoteAlreadyCancelled:    409,
	CodeServedQuantityExceedsMade:        409,

	CodeOrderIntakePaused:           409,
	CodeOutsideSellingHours:         409,
	CodeShopNotSeeingOrders:         409,
	CodeDeliveryServedMarkUndecided: 409,

	CodeSubmissionCodeConflict:           409,
	CodeDiningTableNeedsCleaning:         409,
	CodeDiningTableNotNeedingCleaning:    409,
	CodeSalesOrderNotFound:               404,
	CodeTableSessionNotFound:             404,
	CodeOrderTransitionNotAllowed:        409,
	CodeTableSessionTransitionNotAllowed: 409,
	CodeTableSessionHasOpenOrders:        409,
	CodePaymentPartsMismatch:             422,
	CodeDebtorNameMismatch:               422,

	CodeInternalError:             500,
	CodeInvalidRequest:            400,
	CodeUnauthenticated:           401,
	CodeNotOnCounterDuty:          403,
	CodeCounterDutyChanged:        409,
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
	"counter_duty_one_at_a_time_excl":                CodeCounterDutyChanged,
	"counter_duty_ended_after_started_check":         CodeCounterDutyChanged,
	"bill_standalone_debt_note_check":                CodeDebtNoteRequired,
	"reconciled_day_gap_explained_check":             CodeGapExplanationRequired,
	"prepayment_use_balance_check":                   CodePrepaymentBalanceExceeded,
	"prepayment_one_per_order_key":                   CodePrepaymentAlreadyReceived,
	"opening_float_one_per_day_key":                  CodeOpeningFloatAlreadyDeclared,
	"cash_count_one_per_day_key":                     CodeCashCountAlreadyRecorded,
	"reconciled_day_one_per_day_key":                 CodeSaleDayAlreadyReconciled,
	"debt_collection_amounts_check":                  CodeDebtOverpaid,
	"cash_count_reconciled_day_locked_check":         CodeSaleDayReconciled,
	"cash_count_line_reconciled_day_locked_check":    CodeSaleDayReconciled,
	"opening_float_reconciled_day_locked_check":      CodeSaleDayReconciled,
	"opening_float_line_reconciled_day_locked_check": CodeSaleDayReconciled,
	"reconciled_day_cash_count_fkey":                 CodeCashDayIncomplete,
	"reconciled_day_cash_count_has_lines_check":      CodeCashDayIncomplete,
	"reconciled_day_opening_float_fkey":              CodeCashDayIncomplete,
	"reconciled_day_opening_float_has_lines_check":   CodeCashDayIncomplete,

	"wrong_make_note_live_station_job_fkey": CodeStationJobHasWrongMakeNote,
	"wrong_make_note_live_key":              CodeStationJobHasWrongMakeNote,
	"wrong_make_note_cancelled_order_fkey":  CodeWrongMakeNoteNotAllowed,
	"bill_parts_equal_due_check":            CodePaymentPartsMismatch,
	"bill_debtor_iff_debt_check":            CodeDebtorNameMismatch,
	"qr_code_dining_table_fkey":             CodeDiningTableNotFound,
	"qr_code_one_current_per_table_key":     CodeQRCodeIssueConflict,
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
