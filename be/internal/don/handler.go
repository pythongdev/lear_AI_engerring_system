package don

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"strings"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/middleware"
	"github.com/gin-gonic/gin"
)

func Routes(r *gin.Engine, svc *Service) {
	h := handler{svc: svc}
	r.POST("/preorder-releases", h.nhaHen)
	r.GET("/preorder-reminders", h.nhacHen)
	r.POST("/orders/:sales_order_id/cancellation", h.huy)
	r.POST("/online-orders", h.taoOnline)
	r.POST("/phone-orders", h.taoPhone)
	r.POST("/orders/:sales_order_id/departure", h.roiQuan)
	r.POST("/table-orders", h.taoTaiQuay)
	r.POST("/qr-codes/:code/orders", h.taoQR)
	r.POST("/orders/:sales_order_id/approval", h.duyet)
	r.POST("/orders/:sales_order_id/rejection", h.tuChoi)
}

type handler struct{ svc *Service }

func nguoi(c *gin.Context) int64 {
	id, _ := middleware.Nguoi(c)
	return id
}

// docID giữ lời từ chối của apierr.ReadID: không phải số nguyên dương ⇒ 400, field là tên tham số.
func docID(c *gin.Context) (int64, bool) {
	id, err := strconv.ParseInt(c.Param("sales_order_id"), 10, 64)
	if err != nil || id <= 0 {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "sales_order_id"})
		return 0, false
	}
	return id, true
}

func (h handler) taoTaiQuay(c *gin.Context) { h.taoHTTP(c, "") }
func (h handler) taoQR(c *gin.Context)      { h.taoHTTP(c, c.Param("code")) }
func (h handler) taoHTTP(c *gin.Context, qr string) {
	var raw map[string]json.RawMessage
	if !apierr.ReadJSON(c.Writer, c.Request, &raw) {
		return
	}
	var yc YeuCauTaiQuay
	// Dấu kiểm trước mọi quyền, gồm cả lỗi kiểu của chính trường ấy.
	if err := json.Unmarshal(raw["submission_code"], &yc.SubmissionCode); err != nil || !submissionPattern.MatchString(yc.SubmissionCode) {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "submission_code"})
		return
	}
	for _, f := range []string{"table_session_id", "dining_table_id"} {
		if _, co := raw[f]; co && (f == "table_session_id" || qr != "") {
			apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: f})
			return
		}
	}
	if qr == "" {
		if err := json.Unmarshal(raw["dining_table_id"], &yc.DiningTableID); err != nil || yc.DiningTableID <= 0 {
			apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "dining_table_id"})
			return
		}
	}
	if err := kiemHinhDong(raw["lines"]); err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	if err := json.Unmarshal(raw["lines"], &yc.Lines); err != nil {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "lines"})
		return
	}
	out, replay, err := h.svc.Tao(c.Request.Context(), authz.Caller{PersonID: nguoi(c), QRCode: qr}, yc)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	status := http.StatusCreated
	if replay {
		status = http.StatusOK
	}
	apierr.JSON(c.Writer, status, out)
}

func (h handler) taoOnline(c *gin.Context) { h.taoNgoaiBan(c, false) }
func (h handler) taoPhone(c *gin.Context)  { h.taoNgoaiBan(c, true) }
func (h handler) taoNgoaiBan(c *gin.Context, phone bool) {
	var raw map[string]json.RawMessage
	if !apierr.ReadJSON(c.Writer, c.Request, &raw) {
		return
	}
	yc, err := docNgoaiBan(raw, phone)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	// Khách web không đọc danh tính, kể cả yêu cầu có header của người trong quán.
	caller := authz.Caller{Online: true}
	if phone {
		caller = authz.Caller{PersonID: nguoi(c)}
	}
	out, replay, err := h.svc.Tao(c.Request.Context(), caller, yc)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	status := http.StatusCreated
	if replay {
		status = http.StatusOK
	}
	apierr.JSON(c.Writer, status, DonMangDi{SalesOrderID: out.SalesOrderID, ChannelCode: out.ChannelCode,
		Status: out.Status, TotalVnd: out.TotalVnd, Lines: out.Lines, LienHe: out.LienHe})
}

func (h handler) duyet(c *gin.Context)  { h.chuyen(c, false) }
func (h handler) tuChoi(c *gin.Context) { h.chuyen(c, true) }
func (h handler) chuyen(c *gin.Context, tuChoi bool) {
	id, ok := docID(c)
	if !ok {
		return
	}
	den, sessionID, sessionStatus, err := h.svc.Chuyen(c.Request.Context(), nguoi(c), id, tuChoi)
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, map[string]any{"sales_order_id": id, "status": den, "table_session_id": sessionID, "table_session_status": sessionStatus})
}

func (h handler) huy(c *gin.Context) {
	id, ok := docID(c)
	if !ok {
		return
	}
	if err := h.svc.HuyDon(c.Request.Context(), nguoi(c), id); err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, map[string]any{"sales_order_id": id, "status": "cancelled"})
}

func (h handler) roiQuan(c *gin.Context) {
	id, ok := docID(c)
	if !ok {
		return
	}
	if err := h.svc.RoiQuanDon(c.Request.Context(), nguoi(c), id); err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, map[string]any{"sales_order_id": id, "status": "delivering", "table_session_id": nil, "table_session_status": nil})
}

func (h handler) nhaHen(c *gin.Context) {
	// Không có trường đầu vào; thân rỗng hoặc object theo hợp đồng.
	dec := json.NewDecoder(c.Request.Body)
	var body map[string]json.RawMessage
	err := dec.Decode(&body)
	if err != io.EOF && (err != nil || body == nil || dec.Decode(new(any)) != io.EOF) {
		apierr.Write(c.Writer, apierr.Error{Code: apierr.CodeInvalidRequest})
		return
	}
	ids, err := h.svc.NhaHenDon(c.Request.Context(), nguoi(c))
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, map[string]any{"released_order_ids": ids})
}

func (h handler) nhacHen(c *gin.Context) {
	preorders, err := h.svc.DocNhacHen(c.Request.Context())
	if err != nil {
		apierr.WriteError(c.Writer, err)
		return
	}
	apierr.JSON(c.Writer, http.StatusOK, map[string]any{"preorders": preorders})
}

// Kiểm hình các dòng trước quyền; tra món và tổ hợp vẫn thuộc gia.Tinh trong giao dịch.
func kiemHinhDong(raw json.RawMessage) error {
	var lines []struct {
		MenuItemID *int64    `json:"menu_item_id"`
		Quantity   *int32    `json:"quantity"`
		OptionIDs  *[]*int64 `json:"option_ids"`
	}
	if err := json.Unmarshal(raw, &lines); err != nil || len(lines) == 0 {
		return apierr.Error{Code: apierr.CodeInvalidRequest, Field: "lines"}
	}
	for i, line := range lines {
		field := ""
		switch {
		case line.MenuItemID == nil:
			field = "menu_item_id"
		case line.Quantity == nil || *line.Quantity <= 0:
			field = "quantity"
		case line.OptionIDs == nil:
			field = "option_ids"
		default:
			for _, id := range *line.OptionIDs {
				if id == nil {
					field = "option_ids"
					break
				}
			}
		}
		if field != "" {
			return apierr.Error{Code: apierr.CodeInvalidRequest, Field: fmt.Sprintf("lines[%d].%s", i, field)}
		}
	}
	return nil
}

func docNgoaiBan(raw map[string]json.RawMessage, phone bool) (YeuCauTaiQuay, error) {
	var yc YeuCauTaiQuay
	sai := func(field string) (YeuCauTaiQuay, error) {
		return yc, apierr.Error{Code: apierr.CodeInvalidRequest, Field: field}
	}
	if err := json.Unmarshal(raw["submission_code"], &yc.SubmissionCode); err != nil || !submissionPattern.MatchString(yc.SubmissionCode) {
		return sai("submission_code")
	}
	for _, f := range []string{"dining_table_id", "table_session_id"} {
		if _, co := raw[f]; co {
			return sai(f)
		}
	}
	var lh LienHe
	if phone {
		yc.kenh = "phone_preorder"
		if err := json.Unmarshal(raw["handover_code"], &lh.HandoverCode); err != nil || (lh.HandoverCode != "door_delivery" && lh.HandoverCode != "shop_pickup") {
			return sai("handover_code")
		}
	} else {
		if err := json.Unmarshal(raw["channel_code"], &yc.kenh); err != nil || (yc.kenh != "delivery" && yc.kenh != "pickup") {
			return sai("channel_code")
		}
		lh.HandoverCode = "shop_pickup"
		if yc.kenh == "delivery" {
			lh.HandoverCode = "door_delivery"
		}
	}
	if err := json.Unmarshal(raw["customer_phone"], &lh.CustomerPhone); err != nil || strings.TrimSpace(lh.CustomerPhone) == "" {
		return sai("customer_phone")
	}
	if v, co := raw["delivery_address"]; co {
		if err := json.Unmarshal(v, &lh.DeliveryAddress); err != nil {
			return sai("delivery_address")
		}
	}
	if lh.HandoverCode == "door_delivery" && (lh.DeliveryAddress == nil || strings.TrimSpace(*lh.DeliveryAddress) == "") {
		return sai("delivery_address")
	}
	if v, co := raw["customer_needed_at"]; co {
		// time.Time.UnmarshalJSON đòi RFC 3339 có độ lệch múi giờ.
		if err := json.Unmarshal(v, &lh.CustomerNeededAt); err != nil {
			return sai("customer_needed_at")
		}
		// PostgreSQL giữ mốc tới micro giây; cắt ngay ở đây để lần gửi lại so đúng với mốc đã ghi.
		if lh.CustomerNeededAt != nil {
			moc := lh.CustomerNeededAt.Add(-time.Duration(lh.CustomerNeededAt.Nanosecond() % 1000))
			lh.CustomerNeededAt = &moc
		}
	}
	if (phone || yc.kenh == "pickup") && lh.CustomerNeededAt == nil {
		return sai("customer_needed_at")
	}
	for _, f := range []struct {
		name  string
		value **string
	}{{"customer_name", &lh.CustomerName}, {"contact_note", &lh.ContactNote}} {
		if v, co := raw[f.name]; co {
			if err := json.Unmarshal(v, f.value); err != nil {
				return sai(f.name)
			}
		}
	}
	if err := kiemHinhDong(raw["lines"]); err != nil {
		return yc, err
	}
	var lines []gia.DongYeuCau
	if err := json.Unmarshal(raw["lines"], &lines); err != nil || len(lines) == 0 {
		return sai("lines")
	}
	yc.Lines = make([]DongGoi, len(lines))
	for i, line := range lines {
		yc.Lines[i].DongYeuCau = line
	}
	yc.ngoaiBan = &lh
	return yc, nil
}
