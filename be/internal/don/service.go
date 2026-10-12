// Package don giữ một cửa tạo lượt gọi cho mọi kênh, và các cửa duyệt, từ chối, huỷ, rời quán, nhả hẹn.
package don

import (
	"context"
	"errors"
	"regexp"
	"slices"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/ban"
	"banhcuon/be/internal/gia"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/sanxuat"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

var TaoLuotGoi = authz.Door{Code: "don/tao_luot_goi", Need: authz.NeedCounterOrCustomer}
var Duyet = authz.Door{Code: "don/duyet", Need: authz.NeedCounter}
var TuChoi = authz.Door{Code: "don/tu_choi", Need: authz.NeedCounter}
var Huy = authz.Door{Code: "don/huy", Need: authz.NeedCounter}
var RoiQuan = authz.Door{Code: "don/roi_quan", Need: authz.NeedCounter}
var NhaHen = authz.Door{Code: "don/nha_hen", Need: authz.NeedCounter}

// DongHo trả now() của chính giao dịch; chỉ test thay nó.
var DongHo func(context.Context, pgx.Tx) (time.Time, error) = func(ctx context.Context, tx pgx.Tx) (time.Time, error) {
	return newRepository(tx).dongHo(ctx)
}

type DongGoi struct {
	gia.DongYeuCau
	IsTakeaway bool `json:"is_takeaway"`
}
type YeuCauTaiQuay struct {
	SubmissionCode string    `json:"submission_code"`
	DiningTableID  int64     `json:"dining_table_id"`
	Lines          []DongGoi `json:"lines"`
	kenh           string    `json:"-"`
	ngoaiBan       *LienHe   `json:"-"`
}
type DaTao struct {
	LienHe         LienHe     `json:"-"`
	SalesOrderID   int64      `json:"sales_order_id"`
	TableSessionID int64      `json:"table_session_id"`
	DiningTableID  int64      `json:"dining_table_id"`
	ChannelCode    string     `json:"channel_code"`
	Status         string     `json:"status"`
	TotalVnd       int64      `json:"total_vnd"`
	Lines          []gia.Dong `json:"lines"`
}

type LienHe struct {
	HandoverCode     string     `json:"handover_code"`
	CustomerPhone    string     `json:"customer_phone"`
	DeliveryAddress  *string    `json:"delivery_address"`
	CustomerNeededAt *time.Time `json:"customer_needed_at"`
	CustomerName     *string    `json:"customer_name"`
	ContactNote      *string    `json:"contact_note"`
}

type DonMangDi struct {
	SalesOrderID int64      `json:"sales_order_id"`
	ChannelCode  string     `json:"channel_code"`
	Status       string     `json:"status"`
	TotalVnd     int64      `json:"total_vnd"`
	Lines        []gia.Dong `json:"lines"`
	LienHe
}

type NhacHen struct {
	SalesOrderID     int64       `json:"sales_order_id"`
	CustomerNeededAt time.Time   `json:"customer_needed_at"`
	Status           string      `json:"status"`
	RemindAt         []time.Time `json:"remind_at"`
	DueReminders     []int       `json:"due_reminders"`
}

var submissionPattern = regexp.MustCompile(`^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$`)

type Service struct{ pool *pgxpool.Pool }

func NewService(pool *pgxpool.Pool) *Service { return &Service{pool: pool} }

func Tao(ctx context.Context, pool *pgxpool.Pool, personID int64, yc YeuCauTaiQuay) (DaTao, error) {
	out, _, err := NewService(pool).Tao(ctx, authz.Caller{PersonID: personID}, yc)
	return out, err
}

// Chỉ hai tranh chấp đã biết chạy lại cả giao dịch; không che lỗi database khác.
func canThuLai(err error) bool {
	var pg *pgconn.PgError
	return errors.As(err, &pg) && (pg.ConstraintName == "table_session_member_one_unpaid_session_key" || pg.ConstraintName == "sales_order_submission_code_key")
}

// Tao chạy cửa tạo lượt gọi; replay = true khi cùng dấu đã ghi cùng nội dung.
func (s *Service) Tao(ctx context.Context, caller authz.Caller, yc YeuCauTaiQuay) (DaTao, bool, error) {
	if !submissionPattern.MatchString(yc.SubmissionCode) {
		return DaTao{}, false, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "submission_code"}
	}
	if yc.ngoaiBan == nil && caller.QRCode == "" && yc.DiningTableID <= 0 {
		return DaTao{}, false, apierr.Error{Code: apierr.CodeInvalidRequest, Field: "dining_table_id"}
	}
	var out DaTao
	var replay bool
	var err error
	for attempt := 0; attempt < 4; attempt++ {
		out = DaTao{}
		replay = false
		err = authz.RunAs(ctx, s.pool, caller, TaoLuotGoi, func(tx pgx.Tx, g authz.Granted) error {
			repo := newRepository(tx)
			// Đường QR kiểm mã trước dấu cả khi người đứng quầy gọi đường này.
			seat := g.Seat
			if caller.QRCode != "" && seat.QRCodeID == 0 {
				var err error
				seat, err = authz.CurrentTable(ctx, tx, caller.QRCode)
				if err != nil {
					return err
				}
			}
			saved, code, takeaways, err := repo.docDon(ctx, yc.SubmissionCode)
			if err == nil {
				same := saved.ChannelCode == "staff_pos" && saved.DiningTableID == yc.DiningTableID
				if caller.QRCode != "" {
					same = saved.ChannelCode == "qr_table" && code == caller.QRCode
				}
				if yc.ngoaiBan != nil {
					same = saved.ChannelCode == yc.kenh && cungLienHe(saved.LienHe, *yc.ngoaiBan)
				}
				if !same || !cungDong(saved.Lines, takeaways, yc.Lines) {
					return apierr.Error{Code: apierr.CodeSubmissionCodeConflict}
				}
				out = saved
				replay = true
				return nil
			}
			if !errors.Is(err, pgx.ErrNoRows) {
				return err
			}
			tableID := yc.DiningTableID
			var qrID *int64
			channel := "staff_pos"
			if caller.QRCode != "" {
				tableID = seat.DiningTableID
				qrID = &seat.QRCodeID
				channel = "qr_table"
			}
			if yc.ngoaiBan != nil {
				channel = yc.kenh
			}
			if err := xetNhanDon(ctx, tx, channel); err != nil {
				return err
			}
			var sessionID int64
			var sessionStatus string
			if yc.ngoaiBan == nil {
				if _, err := ban.Doc(ctx, tx, tableID); err != nil {
					return err
				}
				sessionID, sessionStatus, err = repo.khoaPhien(ctx, tableID)
				if errors.Is(err, pgx.ErrNoRows) {
					b, err := ban.Doc(ctx, tx, tableID)
					if err != nil {
						return err
					}
					if b.State == "needs_cleaning" {
						return apierr.Error{Code: apierr.CodeDiningTableNeedsCleaning}
					}
					// Không dùng kết quả kiểm phiên để chặn. Khoá duy nhất quyết tranh chấp tạo đầu.
					if sessionID, err = repo.themPhien(ctx); err != nil {
						return err
					}
					if err := repo.themBan(ctx, sessionID, tableID); err != nil {
						return err
					}
					sessionStatus = "open"
				} else if err != nil {
					return err
				}
			}
			lines := make([]gia.DongYeuCau, len(yc.Lines))
			for i, d := range yc.Lines {
				lines[i] = d.DongYeuCau
			}
			kq, err := gia.Tinh(ctx, tx, lines)
			if err != nil {
				return err
			}
			status, err := vongdoi.TrangThaiDauDon(channel)
			if err != nil {
				return err
			}
			var lh LienHe
			if yc.ngoaiBan != nil {
				lh = *yc.ngoaiBan
			}
			if out.SalesOrderID, err = repo.themDon(ctx, channel, status, sessionID, tableID, yc.SubmissionCode, qrID, lh); err != nil {
				return err
			}
			for index, d := range kq.Lines {
				n := int32(len(d.Components))
				var takeaway *bool
				if yc.ngoaiBan == nil {
					takeaway = &yc.Lines[index].IsTakeaway
				}
				dongID, err := repo.themDong(ctx, out.SalesOrderID, d, takeaway)
				if err != nil {
					return err
				}
				for i, c := range d.Components {
					if err := repo.themThanhPhan(ctx, dongID, int32(i+1), n, c); err != nil {
						return err
					}
				}
				for _, o := range d.Options {
					if err := repo.themLuaChon(ctx, dongID, o); err != nil {
						return err
					}
				}
			}
			if (status == "confirmed" && sessionStatus == "open") || sessionStatus == "awaiting_payment" {
				if err := vongdoi.ChuyenPhien(ctx, tx, sessionID, "serving"); err != nil {
					return err
				}
			}
			noNgay := status == "confirmed"
			if channel == "phone_preorder" {
				moc, err := DongHo(ctx, tx)
				if err != nil {
					return err
				}
				noNgay = !lh.CustomerNeededAt.Add(-20 * time.Minute).After(moc)
			}
			if noNgay {
				if err := sanxuat.NoDon(ctx, tx, out.SalesOrderID); err != nil {
					return err
				}
			}
			out, _, _, err = repo.docDon(ctx, yc.SubmissionCode)
			return err
		})
		if !canThuLai(err) {
			break
		}
	}
	if err != nil {
		return DaTao{}, false, err
	}
	return out, replay, nil
}

// Giờ bán theo master_plan/shop-facts.md §1, giữ trong be/internal/don/sql/ngoai_gio.sql.
func xetNhanDon(ctx context.Context, tx pgx.Tx, kenh string) error {
	moc, err := DongHo(ctx, tx)
	if err != nil {
		return err
	}
	repo := newRepository(tx)
	biChan, err := repo.tamDung(ctx, moc)
	if err != nil {
		return err
	}
	if biChan {
		return apierr.Error{Code: apierr.CodeOrderIntakePaused}
	}
	if biChan, err = repo.ngoaiGio(ctx, moc); err != nil {
		return err
	}
	if biChan {
		return apierr.Error{Code: apierr.CodeOutsideSellingHours}
	}
	if kenh == "delivery" || kenh == "pickup" || kenh == "qr_table" {
		if biChan, err = repo.quanMu(ctx, moc); err != nil {
			return err
		}
		if biChan {
			return apierr.Error{Code: apierr.CodeShopNotSeeingOrders}
		}
	}
	return nil
}

func cungDong(saved []gia.Dong, takeaways []bool, requested []DongGoi) bool {
	if len(saved) != len(requested) || len(takeaways) != len(saved) {
		return false
	}
	for i, d := range saved {
		r := requested[i]
		if d.MenuItemID != r.MenuItemID || d.Quantity != r.Quantity || takeaways[i] != r.IsTakeaway {
			return false
		}
		a := make([]int64, len(d.Options))
		for j, o := range d.Options {
			a[j] = o.MenuOptionID
		}
		b := slices.Clone(r.OptionIDs)
		slices.Sort(a)
		slices.Sort(b)
		if !slices.Equal(slices.Compact(a), slices.Compact(b)) {
			return false
		}
	}
	return true
}

func cungChu(a, b *string) bool { return (a == nil && b == nil) || (a != nil && b != nil && *a == *b) }
func cungLienHe(a, b LienHe) bool {
	cungMoc := a.CustomerNeededAt == nil && b.CustomerNeededAt == nil ||
		a.CustomerNeededAt != nil && b.CustomerNeededAt != nil && a.CustomerNeededAt.Equal(*b.CustomerNeededAt)
	return a.HandoverCode == b.HandoverCode && a.CustomerPhone == b.CustomerPhone &&
		cungChu(a.DeliveryAddress, b.DeliveryAddress) && cungChu(a.CustomerName, b.CustomerName) &&
		cungChu(a.ContactNote, b.ContactNote) && cungMoc
}

// Chuyen chạy cửa duyệt (tuChoi = false) hoặc từ chối một đơn chờ duyệt. Trả trạng thái đơn sau cửa
// và phiên của đơn (nil với đơn ngoài bàn).
func (s *Service) Chuyen(ctx context.Context, nguoi int64, id int64, tuChoi bool) (string, *int64, *string, error) {
	door, den := Duyet, "confirmed"
	if tuChoi {
		door, den = TuChoi, "cancelled"
	}
	var sessionID *int64
	var sessionStatus *string
	err := authz.Run(ctx, s.pool, nguoi, door, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		var err error
		if sessionID, err = repo.docPhienDon(ctx, tuChoi, id); err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeSalesOrderNotFound}
			}
			return err
		}
		if sessionID != nil {
			st, err := repo.khoaPhienDon(ctx, tuChoi, *sessionID)
			if err != nil {
				return err
			}
			sessionStatus = &st
		}
		status, err := repo.khoaDon(ctx, tuChoi, id)
		if err != nil {
			return err
		}
		// Từ chối chờ duyệt khác cửa huỷ một đơn đã xác nhận (P3-09/P3-10).
		if status != "pending_confirmation" {
			return apierr.Error{Code: apierr.CodeOrderTransitionNotAllowed}
		}
		if err := vongdoi.ChuyenDon(ctx, tx, id, den); err != nil {
			return err
		}
		if den == "confirmed" && sessionID != nil && sessionStatus != nil && *sessionStatus == "open" {
			if err := vongdoi.ChuyenPhien(ctx, tx, *sessionID, "serving"); err != nil {
				return err
			}
			*sessionStatus = "serving"
		}
		if den == "confirmed" {
			if err := sanxuat.NoDon(ctx, tx, id); err != nil {
				return err
			}
			den = "in_progress"
		}
		return nil
	})
	return den, sessionID, sessionStatus, err
}

// HuyDon chạy cửa huỷ một đơn đã xác nhận, đang làm hoặc đã xong.
func (s *Service) HuyDon(ctx context.Context, nguoi int64, id int64) error {
	return authz.Run(ctx, s.pool, nguoi, Huy, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		phien, err := repo.huyDocPhien(ctx, id)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeSalesOrderNotFound}
			}
			return err
		}
		if phien != nil {
			if _, err := repo.khoaPhienDon(ctx, false, *phien); err != nil {
				return err
			}
		}
		st, err := repo.khoaDon(ctx, false, id)
		if err != nil {
			return err
		}
		if st != "confirmed" && st != "in_progress" && st != "completed" {
			return apierr.Error{Code: apierr.CodeOrderTransitionNotAllowed}
		}
		return vongdoi.ChuyenDon(ctx, tx, id, "cancelled")
	})
}

// RoiQuanDon chạy cửa đơn giao rời quán.
func (s *Service) RoiQuanDon(ctx context.Context, nguoi int64, id int64) error {
	return authz.Run(ctx, s.pool, nguoi, RoiQuan, func(tx pgx.Tx) error {
		repo := newRepository(tx)
		status, handover, err := repo.roiQuanKhoaDon(ctx, id)
		if err != nil {
			if errors.Is(err, pgx.ErrNoRows) {
				return apierr.Error{Code: apierr.CodeSalesOrderNotFound}
			}
			return err
		}
		// Kiểm cặp trước S-6; chỉ ChuyenDon sở hữu lần ghi trạng thái.
		if err := vongdoi.KiemChuyenDon(status, "delivering", "", handover); err != nil {
			return err
		}
		chuaRaBan, err := repo.roiQuanDocViec(ctx, id)
		if err != nil {
			return err
		}
		if chuaRaBan {
			return apierr.Error{Code: apierr.CodeDeliveryServedMarkUndecided}
		}
		return vongdoi.ChuyenDon(ctx, tx, id, "delivering")
	})
}

// NhaHenDon chạy cửa nhả các đơn đặt trước đã tới lần nhắc đầu: nổ việc cho đơn còn confirmed.
func (s *Service) NhaHenDon(ctx context.Context, nguoi int64) ([]int64, error) {
	ids := make([]int64, 0)
	err := authz.Run(ctx, s.pool, nguoi, NhaHen, func(tx pgx.Tx) error {
		moc, err := DongHo(ctx, tx)
		if err != nil {
			return err
		}
		// Đọc hết các dòng bị khoá trước khi dùng lại kết nối để nổ đơn.
		dons, err := newRepository(tx).nhaHenKhoaDon(ctx, moc)
		if err != nil {
			return err
		}
		for _, d := range dons {
			if d.status == "confirmed" {
				ids = append(ids, d.id)
			}
		}
		for _, id := range ids {
			if err := sanxuat.NoDon(ctx, tx, id); err != nil {
				return err
			}
		}
		return nil
	})
	return ids, err
}

// DocNhacHen đọc các mốc nhắc của đơn đặt trước còn mở.
func (s *Service) DocNhacHen(ctx context.Context) ([]NhacHen, error) {
	preorders := make([]NhacHen, 0)
	// Đường đọc không kiểm quyền hay khai người; giao dịch chỉ để dùng cùng DongHo.
	err := postgres.InTx(ctx, s.pool, func(tx pgx.Tx) error {
		moc, err := DongHo(ctx, tx)
		if err != nil {
			return err
		}
		dons, err := newRepository(tx).nhacHen(ctx)
		if err != nil {
			return err
		}
		for _, n := range dons {
			n.RemindAt = make([]time.Time, 0, 2)
			n.DueReminders = make([]int, 0, 2)
			for _, phut := range []int{20, 10} {
				nhac := n.CustomerNeededAt.Add(-time.Duration(phut) * time.Minute)
				n.RemindAt = append(n.RemindAt, nhac)
				if !nhac.After(moc) {
					n.DueReminders = append(n.DueReminders, phut)
				}
			}
			preorders = append(preorders, n)
		}
		return nil
	})
	return preorders, err
}
