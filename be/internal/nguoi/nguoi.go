// Package nguoi giữ danh sách tên và mốc đổi người ở quầy: C36 đòi một mốc có cả ai vào,
// ai ra, nên khép khoảng cũ và mở khoảng mới phải dùng cùng giao dịch của cửa gọi.
package nguoi

import (
	"context"
	_ "embed"
	"errors"
	"fmt"
	"net/http"
	"time"

	"banhcuon/be/internal/apierr"
	"banhcuon/be/internal/authz"
	"banhcuon/be/internal/db"
	"banhcuon/be/internal/vongdoi"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

var VaoQuay = authz.Door{Code: "nguoi/vao_quay", Need: authz.NeedPerson}
var RoiQuay = authz.Door{Code: "nguoi/roi_quay", Need: authz.NeedCounter}
var CuaKhepQuay = authz.Door{Code: "nguoi/khep_quay", Need: authz.NeedCallingDoor}

//go:embed sql/vao_quay/khoa.sql
var khoaQuay string

//go:embed sql/vao_quay/them.sql
var themKhoang string

//go:embed sql/roi_quay/khoa.sql
var khoaNguoi string

//go:embed sql/khep_quay/khep.sql
var khepKhoang string

type person struct {
	PersonID    int64  `json:"person_id"`
	DisplayName string `json:"display_name"`
	IsOwner     bool   `json:"is_owner"`
}

type currentDuty struct {
	PersonID      *int64     `json:"person_id"`
	DisplayName   *string    `json:"display_name"`
	CounterDutyID *int64     `json:"counter_duty_id"`
	StartedAt     *time.Time `json:"started_at"`
}

type enteredDuty struct {
	CounterDutyID    int64     `json:"counter_duty_id"`
	PersonID         int64     `json:"person_id"`
	StartedAt        time.Time `json:"started_at"`
	ReplacedPersonID *int64    `json:"replaced_person_id"`
}

type endedDuty struct {
	CounterDutyID int64     `json:"counter_duty_id"`
	PersonID      int64     `json:"person_id"`
	StartedAt     time.Time `json:"started_at"`
	EndedAt       time.Time `json:"ended_at"`
}

// khepQuay là thân cửa nguoi/khep_quay, chủ duy nhất của ô counter_duty.ended_at.
// Cửa gọi đã kiểm quyền và khoá khoảng; dùng giao dịch và lý do của nó để giữ cùng mốc và vết.
func khepQuay(ctx context.Context, tx pgx.Tx, dutyID int64, reason string) (endedDuty, error) {
	var result endedDuty
	err := vongdoi.CoVet(ctx, tx, reason, func() error {
		return tx.QueryRow(ctx, khepKhoang, dutyID).Scan(
			&result.CounterDutyID, &result.PersonID, &result.StartedAt, &result.EndedAt)
	})
	return result, err
}

func nguoiGoi(request *http.Request, auth authz.Authenticator) int64 {
	if auth != nil {
		if personID, ok := auth.PersonID(request); ok {
			return personID
		}
	}
	return 0
}

func Routes(mux *http.ServeMux, pool *pgxpool.Pool, auth authz.Authenticator) {
	mux.HandleFunc("GET /people", func(writer http.ResponseWriter, request *http.Request) {
		result := struct {
			People []person `json:"people"`
		}{People: []person{}}
		err := db.InTx(request.Context(), pool, func(tx pgx.Tx) error {
			rows, err := tx.Query(request.Context(), "SELECT id, display_name, is_owner FROM person ORDER BY display_name, id")
			if err != nil {
				return err
			}
			defer rows.Close()
			for rows.Next() {
				var entry person
				if err := rows.Scan(&entry.PersonID, &entry.DisplayName, &entry.IsOwner); err != nil {
					return err
				}
				result.People = append(result.People, entry)
			}
			return rows.Err()
		})
		if err != nil {
			apierr.WriteError(writer, err)
			return
		}
		apierr.JSON(writer, http.StatusOK, result)
	})
	mux.HandleFunc("GET /counter-duty/current", func(writer http.ResponseWriter, request *http.Request) {
		var result currentDuty
		err := db.InTx(request.Context(), pool, func(tx pgx.Tx) error {
			err := tx.QueryRow(request.Context(), `SELECT duty.person_id, person.display_name, duty.id, duty.started_at
			 FROM counter_duty duty JOIN person ON person.id = duty.person_id WHERE duty.ended_at IS NULL`).Scan(
				&result.PersonID, &result.DisplayName, &result.CounterDutyID, &result.StartedAt)
			if errors.Is(err, pgx.ErrNoRows) {
				return nil
			}
			return err
		})
		if err != nil {
			apierr.WriteError(writer, err)
			return
		}
		apierr.JSON(writer, http.StatusOK, result)
	})
	mux.HandleFunc("POST /counter-duty", func(writer http.ResponseWriter, request *http.Request) {
		personID := nguoiGoi(request, auth)
		var result enteredDuty
		status := http.StatusCreated
		err := authz.Run(request.Context(), pool, personID, VaoQuay, func(tx pgx.Tx) error {
			var current enteredDuty
			var changed bool
			err := tx.QueryRow(request.Context(), khoaQuay).Scan(
				&current.CounterDutyID, &current.PersonID, &current.StartedAt, &changed)
			if err != nil && !errors.Is(err, pgx.ErrNoRows) {
				return err
			}
			if err == nil {
				if current.PersonID == personID {
					result = current
					status = http.StatusOK
					return nil
				}
				if changed {
					return apierr.Error{Code: apierr.CodeCounterDutyChanged}
				}
				reason := fmt.Sprintf("%s: %d thay %d", VaoQuay.Code, personID, current.PersonID)
				if _, err := khepQuay(request.Context(), tx, current.CounterDutyID, reason); err != nil {
					return err
				}
				result.ReplacedPersonID = &current.PersonID
			}
			return tx.QueryRow(request.Context(), themKhoang, personID).Scan(
				&result.CounterDutyID, &result.PersonID, &result.StartedAt)
		})
		if err != nil {
			apierr.WriteError(writer, err)
			return
		}
		apierr.JSON(writer, status, result)
	})
	mux.HandleFunc("POST /counter-duty/end", func(writer http.ResponseWriter, request *http.Request) {
		personID := nguoiGoi(request, auth)
		var result endedDuty
		err := authz.Run(request.Context(), pool, personID, RoiQuay, func(tx pgx.Tx) error {
			var dutyID int64
			if err := tx.QueryRow(request.Context(), khoaNguoi, personID).Scan(&dutyID); err != nil {
				if errors.Is(err, pgx.ErrNoRows) {
					return apierr.Error{Code: apierr.CodeNotOnCounterDuty}
				}
				return err
			}
			var err error
			result, err = khepQuay(request.Context(), tx, dutyID, fmt.Sprintf("%s: %d rời quầy", RoiQuay.Code, personID))
			return err
		})
		if err != nil {
			apierr.WriteError(writer, err)
			return
		}
		apierr.JSON(writer, http.StatusOK, result)
	})
}
