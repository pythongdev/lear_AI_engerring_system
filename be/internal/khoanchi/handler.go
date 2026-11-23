package khoanchi

import (
	"encoding/json"
	"strconv"
	"strings"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/middleware"
	"banhcuon/be/internal/nguyenlieu"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.GET("/expense-categories", h.docLoai)
	r.POST("/expense-categories", h.themLoai)
	r.POST("/expenses", h.ghi)
	r.PUT("/expenses/:expense_id", h.sua)
	r.GET("/expenses", h.doc)
	r.PUT("/expense-categories/:expense_category_id", h.suaLoai)
	r.DELETE("/expense-categories/:expense_category_id", h.xoaLoai)
	r.POST("/expense-items", h.themCon)
	r.POST("/expense-items/:expense_item_id/reopen", h.moCon)
	r.PUT("/expense-items/:expense_item_id/category", h.chuyenMuc)
	r.POST("/supply-expense-items", h.themThuKemTien)
	r.PUT("/expense-items/:expense_item_id", h.suaCon)
	r.DELETE("/expense-items/:expense_item_id", h.xoaCon)
	r.DELETE("/expenses/:expense_id", h.xoaKhoan)
}

type handler struct{ svc *Service }

func nguoi(c *gin.Context) int64 { id, _ := middleware.Nguoi(c); return id }
func sai(c *gin.Context, field string) {
	apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: field})
}
func ngayHopLe(s string) bool {
	d, err := time.Parse("2006-01-02", s)
	return err == nil && d.Year() >= 1 && d.Format("2006-01-02") == s
}
func (h handler) themLoai(c *gin.Context) {
	var p struct {
		Name         string `json:"name"`
		PaidFromTill *bool  `json:"paid_from_till"`
		TracksSupply *bool  `json:"tracks_supply"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	p.Name = strings.TrimSpace(p.Name)
	if p.Name == "" {
		sai(c, "name")
		return
	}
	if p.PaidFromTill == nil {
		sai(c, "paid_from_till")
		return
	}
	if p.TracksSupply == nil {
		sai(c, "tracks_supply")
		return
	}
	out, err := h.svc.ThemLoai(c.Request.Context(), nguoi(c), p.Name, *p.PaidFromTill, *p.TracksSupply)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 201, out)
}
func (h handler) docLoai(c *gin.Context) {
	out, err := h.svc.DocLoai(c.Request.Context(), nguoi(c))
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, map[string]any{"expense_categories": out})
}

// Kiểm mọi hình trước quyền và database, kể cả path và bộ lọc.
func docYeuCau(c *gin.Context, sua bool) (YeuCau, bool) {
	var p YeuCau
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return p, false
	}
	if p.ItemID != nil && *p.ItemID <= 0 {
		sai(c, "expense_item_id")
		return p, false
	}
	if p.Amount <= 0 {
		sai(c, "amount_vnd")
		return p, false
	}
	if !ngayHopLe(p.PaidDate) {
		sai(c, "paid_date")
		return p, false
	}
	if p.ReceivedSent && (p.ReceivedDate == nil || !ngayHopLe(*p.ReceivedDate)) {
		sai(c, "received_date")
		return p, false
	}
	if p.MeasureSent {
		if sua || p.PurchasedMeasure == nil || !nguyenlieu.DoLuongHopLe(*p.PurchasedMeasure) {
			sai(c, "purchased_measure")
			return p, false
		}
	}
	if p.CategoryID <= 0 {
		sai(c, "expense_category_id")
		return p, false
	}
	p.Reason = strings.TrimSpace(p.Reason)
	if sua && p.Reason == "" {
		sai(c, "reason")
		return p, false
	}
	return p, true
}
func (h handler) ghi(c *gin.Context) {
	p, ok := docYeuCau(c, false)
	if !ok {
		return
	}
	out, err := h.svc.GhiKhoan(c.Request.Context(), nguoi(c), p)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 201, out)
}
func (h handler) sua(c *gin.Context) {
	id, err := strconv.ParseInt(c.Param("expense_id"), 10, 64)
	if err != nil || id <= 0 {
		sai(c, "expense_id")
		return
	}
	p, ok := docYeuCau(c, true)
	if !ok {
		return
	}
	out, err := h.svc.SuaKhoan(c.Request.Context(), nguoi(c), id, p)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, out)
}
func (h handler) doc(c *gin.Context) {
	loc := BoLoc{From: c.Query("from"), To: c.Query("to")}
	if !ngayHopLe(loc.From) {
		sai(c, "from")
		return
	}
	if !ngayHopLe(loc.To) || loc.From > loc.To {
		sai(c, "to")
		return
	}
	if v, ok := c.GetQuery("expense_category_id"); ok {
		id, err := strconv.ParseInt(v, 10, 64)
		if err != nil || id <= 0 {
			sai(c, "expense_category_id")
			return
		}
		loc.CategoryID = &id
	} else if _, ok := c.Request.URL.Query()["expense_category_id"]; ok {
		sai(c, "expense_category_id")
		return
	}
	if v, ok := c.GetQuery("expense_item_id"); ok {
		id, err := strconv.ParseInt(v, 10, 64)
		if err != nil || id <= 0 {
			sai(c, "expense_item_id")
			return
		}
		loc.ItemID = &id
	}
	if vs, ok := c.Request.URL.Query()["paid_from_till"]; ok {
		if vs[0] != "true" && vs[0] != "false" {
			sai(c, "paid_from_till")
			return
		}
		ket := vs[0] == "true"
		loc.PaidFromTill = &ket
	}
	out, err := h.svc.Doc(c.Request.Context(), nguoi(c), loc)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, 200, out)
}

func readID(c *gin.Context, key string) (int64, bool) {
	id, err := strconv.ParseInt(c.Param(key), 10, 64)
	if err != nil || id <= 0 {
		sai(c, key)
		return 0, false
	}
	return id, true
}

type catalogRequest struct {
	Name       string `json:"name"`
	Reason     string `json:"reason"`
	CategoryID int64  `json:"expense_category_id"`
}

func readCatalog(c *gin.Context, rename, create bool) (p catalogRequest, ok bool) {
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	p.Name = strings.TrimSpace(p.Name)
	p.Reason = strings.TrimSpace(p.Reason)
	if (rename || create) && p.Name == "" {
		sai(c, "name")
		return
	}
	if !create && p.Reason == "" {
		sai(c, "reason")
		return
	}
	if create && p.CategoryID <= 0 {
		sai(c, "expense_category_id")
		return
	}
	return p, true
}
func respondCatalog(c *gin.Context, out any, err error, status int) {
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	if status == 204 {
		c.Status(204)
		return
	}
	apierr.JSON(c.Writer, status, out)
}
func (h handler) suaLoai(c *gin.Context) {
	id, ok := readID(c, "expense_category_id")
	if !ok {
		return
	}
	p, ok := readCatalog(c, true, false)
	if !ok {
		return
	}
	out, err := h.svc.DoiTenLoai(c.Request.Context(), nguoi(c), id, p.Name, p.Reason)
	respondCatalog(c, out, err, 200)
}
func (h handler) xoaLoai(c *gin.Context) {
	id, ok := readID(c, "expense_category_id")
	if !ok {
		return
	}
	p, ok := readCatalog(c, false, false)
	if !ok {
		return
	}
	err := h.svc.XoaLoaiChi(c.Request.Context(), nguoi(c), id, p.Reason)
	respondCatalog(c, nil, err, 204)
}
func (h handler) themCon(c *gin.Context) {
	var p struct {
		CategoryID   int64           `json:"expense_category_id"`
		Name         json.RawMessage `json:"name"`
		SupplyItemID json.RawMessage `json:"supply_item_id"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	if p.CategoryID <= 0 {
		sai(c, "expense_category_id")
		return
	}
	var supply *int64
	if p.SupplyItemID != nil {
		var id int64
		if err := json.Unmarshal(p.SupplyItemID, &id); err != nil || string(p.SupplyItemID) == "null" || id <= 0 {
			sai(c, "supply_item_id")
			return
		}
		supply = &id
	}
	var name *string
	if p.Name != nil {
		var n string
		if err := json.Unmarshal(p.Name, &n); err != nil || string(p.Name) == "null" {
			sai(c, "name")
			return
		}
		n = strings.TrimSpace(n)
		name = &n
	}
	out, err := h.svc.TaoKhoanCon(c.Request.Context(), nguoi(c), p.CategoryID, name, supply)
	respondCatalog(c, out, err, 201)
}
func (h handler) moCon(c *gin.Context) {
	id, ok := readID(c, "expense_item_id")
	if !ok {
		return
	}
	p, ok := readCatalog(c, false, false)
	if !ok {
		return
	}
	out, err := h.svc.MoKhoanCon(c.Request.Context(), nguoi(c), id, p.Reason)
	respondCatalog(c, out, err, 200)
}
func (h handler) chuyenMuc(c *gin.Context) {
	id, ok := readID(c, "expense_item_id")
	if !ok {
		return
	}
	var p struct {
		CategoryID int64  `json:"expense_category_id"`
		Reason     string `json:"reason"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	if p.CategoryID <= 0 {
		sai(c, "expense_category_id")
		return
	}
	p.Reason = strings.TrimSpace(p.Reason)
	if p.Reason == "" {
		sai(c, "reason")
		return
	}
	out, err := h.svc.ChuyenKhoanCon(c.Request.Context(), nguoi(c), id, p.CategoryID, p.Reason)
	respondCatalog(c, out, err, 200)
}
func (h handler) themThuKemTien(c *gin.Context) {
	var p struct {
		CategoryID   int64   `json:"expense_category_id"`
		Name         string  `json:"name"`
		PurchaseUnit *string `json:"purchase_unit"`
		Expense      *struct {
			Amount       int64   `json:"amount_vnd"`
			PaidDate     string  `json:"paid_date"`
			ReceivedDate *string `json:"received_date"`
		} `json:"expense"`
		Measure *string `json:"purchased_measure"`
	}
	if !apierr.ReadJSON(c.Writer, c.Request, &p) {
		return
	}
	p.Name = strings.TrimSpace(p.Name)
	if p.Name == "" {
		sai(c, "name")
		return
	}
	if p.CategoryID <= 0 {
		sai(c, "expense_category_id")
		return
	}
	unit := ""
	if p.PurchaseUnit != nil {
		unit = strings.TrimSpace(*p.PurchaseUnit)
		if unit == "" {
			sai(c, "purchase_unit")
			return
		}
	}
	if p.Measure != nil && !nguyenlieu.DoLuongHopLe(*p.Measure) {
		sai(c, "purchased_measure")
		return
	}
	if p.Measure != nil && p.Expense == nil {
		sai(c, "purchased_measure")
		return
	}
	var expense *YeuCau
	if p.Expense != nil {
		if p.Expense.Amount <= 0 {
			sai(c, "amount_vnd")
			return
		}
		if !ngayHopLe(p.Expense.PaidDate) {
			sai(c, "paid_date")
			return
		}
		if p.Expense.ReceivedDate != nil && !ngayHopLe(*p.Expense.ReceivedDate) {
			sai(c, "received_date")
			return
		}
		expense = &YeuCau{Amount: p.Expense.Amount, PaidDate: p.Expense.PaidDate, ReceivedDate: p.Expense.ReceivedDate}
	}
	out, err := h.svc.ThemThuKemTien(c.Request.Context(), nguoi(c), p.CategoryID, p.Name, unit, expense, p.Measure)
	respondCatalog(c, out, err, 201)
}
func (h handler) suaCon(c *gin.Context) {
	id, ok := readID(c, "expense_item_id")
	if !ok {
		return
	}
	p, ok := readCatalog(c, true, false)
	if !ok {
		return
	}
	out, err := h.svc.DoiTenKhoanCon(c.Request.Context(), nguoi(c), id, p.Name, p.Reason)
	respondCatalog(c, out, err, 200)
}
func (h handler) xoaCon(c *gin.Context) {
	id, ok := readID(c, "expense_item_id")
	if !ok {
		return
	}
	p, ok := readCatalog(c, false, false)
	if !ok {
		return
	}
	err := h.svc.XoaCon(c.Request.Context(), nguoi(c), id, p.Reason)
	respondCatalog(c, nil, err, 204)
}
func (h handler) xoaKhoan(c *gin.Context) {
	id, ok := readID(c, "expense_id")
	if !ok {
		return
	}
	p, ok := readCatalog(c, false, false)
	if !ok {
		return
	}
	err := h.svc.XoaKhoan(c.Request.Context(), nguoi(c), id, p.Reason)
	respondCatalog(c, nil, err, 204)
}
