package hoadon

import (
	"net/http"
	"strconv"
	"strings"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/tratruoc"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.POST("/orders/:sales_order_id/handover", h.traoTaiQuay)
	r.POST("/orders/:sales_order_id/delivered", h.giaoXong)
	r.POST("/bills/:bill_id/refunds", h.hoan)
	r.POST("/bills/:bill_id/debt-collections", h.thuNo)
	r.POST("/prepayments/:prepayment_id/returns", h.traLai)
	r.GET("/debts", h.docNo)
	r.POST("/table-sessions/:table_session_id/closing", h.dong)
}

type handler struct{ svc *Service }

// docID giữ lời từ chối của apierr.ReadID: không phải số nguyên dương ⇒ 400, field là tên tham số.
func docID(c *gin.Context, field string) (int64, bool) {
	id, err := strconv.ParseInt(c.Param(field), 10, 64)
	if err != nil || id <= 0 {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: field})
		return 0, false
	}
	return id, true
}

func nguoi(c *gin.Context) int64 {
	id, _ := middleware.Nguoi(c)
	return id
}

// Mọi lời từ chối hình xảy ra trước quyền và trước database (TestQC14_HinhDuongTienTruocQuyen).
func (h handler) dong(c *gin.Context) {
	id, ok := docID(c, "table_session_id")
	if !ok {
		return
	}
	var yc DongYeuCau
	if !apierr.ReadJSON(c.Writer, c.Request, &yc) {
		return
	}
	for _, v := range []struct {
		name  string
		value *int64
	}{{"cash_vnd", yc.CashVnd}, {"transfer_vnd", yc.TransferVnd}, {"debt_vnd", yc.DebtVnd}} {
		if v.value == nil || *v.value < 0 {
			apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: v.name})
			return
		}
	}
	if yc.DiscountVnd < 0 {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "discount_vnd"})
		return
	}
	if err := kiemTenGiam(yc.DiscountVnd, yc.DiscountCustomerName); err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	if yc.DebtorName != nil && strings.TrimSpace(*yc.DebtorName) == "" {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "debtor_name"})
		return
	}
	bill, due, err := h.svc.DongPhien(c.Request.Context(), nguoi(c), id, yc)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusCreated, map[string]any{"bill_id": bill, "table_session_id": id, "due_vnd": due})
}

func (h handler) traoTaiQuay(c *gin.Context) { h.trao(c, false) }
func (h handler) giaoXong(c *gin.Context)    { h.trao(c, true) }

func (h handler) trao(c *gin.Context, giao bool) {
	id, ok := docID(c, "sales_order_id")
	if !ok {
		return
	}
	var p struct {
		ThanhToan
		DebtNote *string `json:"debt_note"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	if err := p.Kiem(); err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	if p.Debt == 0 && p.DebtNote != nil {
		apierr.WriteError(c.Writer, sai("debt_note"))
		return
	}
	bill, due, err := h.svc.Trao(c.Request.Context(), nguoi(c), id, p.ThanhToan, p.DebtNote, giao)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 201, map[string]any{"bill_id": bill, "sales_order_id": id, "due_vnd": due, "status": "completed"})
}

func (h handler) hoan(c *gin.Context) {
	id, ok := docID(c, "bill_id")
	if !ok {
		return
	}
	var p HoanYeuCau
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	if err := p.Kiem(); err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	out, err := h.svc.HoanTien(c.Request.Context(), nguoi(c), id, p)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 201, map[string]any{"refund_id": out, "bill_id": id})
}

func (h handler) traLai(c *gin.Context) {
	id, ok := docID(c, "prepayment_id")
	if !ok {
		return
	}
	var p TraLaiYeuCau
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	if err := p.Kiem(); err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	out, amount, err := h.svc.TraLaiTraTruoc(c.Request.Context(), nguoi(c), id, p)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 201, map[string]any{"refund_id": out, "prepayment_id": id, "amount_vnd": amount})
}

func (h handler) thuNo(c *gin.Context) {
	id, ok := docID(c, "bill_id")
	if !ok {
		return
	}
	var p tratruoc.PhanTien
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	if err := p.Kiem(); err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	out, remaining, err := h.svc.ThuNoHoaDon(c.Request.Context(), nguoi(c), id, p)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 201, map[string]any{"debt_collection_id": out, "bill_id": id, "remaining_vnd": remaining})
}

func (h handler) docNo(c *gin.Context) {
	debts, err := h.svc.DanhSachNo(c.Request.Context())
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, map[string]any{"debts": debts})
}
