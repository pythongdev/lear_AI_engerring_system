// P3-12: cắt đường đẩy thật, đọc lại từ PostgreSQL thật. Không t.Parallel vì đồng hồ don là chỗ nối test chung.
package main

import (
	"bufio"
	"bytes"
	"context"
	"crypto/rand"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"os/exec"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"

	"banhcuon/be/internal/don"
	"banhcuon/be/internal/platform/postgres"
	"banhcuon/be/internal/platform/realtime"
	"banhcuon/be/internal/taikhoan"
	"banhcuon/be/internal/testhelper"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type rtFixture struct {
	t                                 *testing.T
	ctx                               context.Context
	pool                              *pgxpool.Pool
	owner                             *pgx.Conn
	broker                            *realtime.Broker
	server                            *httptest.Server
	counter, ownerID, outsider, table int64
	qr                                string
	line                              map[string]any
}

func rtSetup(t *testing.T, heartbeat time.Duration) *rtFixture {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 90*time.Second)
	t.Cleanup(cancel)
	pool, err := postgres.Open(ctx, testhelper.AppDSN(t), testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	cfg, err := pgx.ParseConfig(testhelper.OwnerDSN(t))
	if err != nil {
		t.Fatal(err)
	}
	cfg.RuntimeParams["timezone"] = testhelper.ShopTZ(t)
	owner, err := pgx.ConnectConfig(ctx, cfg)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { owner.Close(context.Background()) })
	f := &rtFixture{t: t, ctx: ctx, pool: pool, owner: owner, broker: realtime.New(heartbeat)}
	f.ownerID = f.id("INSERT INTO shop.person(display_name,is_owner) VALUES ('P3-12 chủ',true) RETURNING id")
	f.counter = f.id("INSERT INTO shop.person(display_name) VALUES ('P3-12 quầy') RETURNING id")
	f.outsider = f.id("INSERT INTO shop.person(display_name) VALUES ('P3-12 ngoài quầy') RETURNING id")
	// Mỗi test chỉ khép dữ liệu hiện tại của chính khung; không xoá khoảng hay sửa mốc lịch sử.
	f.execVet("UPDATE shop.counter_duty SET ended_at=clock_timestamp() WHERE ended_at IS NULL")
	f.id("INSERT INTO shop.counter_duty(person_id,started_at) VALUES ($1,clock_timestamp()) RETURNING id", f.counter)
	// seed.pl đọc master_plan/shop-facts.md theo đường tương đối: chạy từ gốc repo như chaySeed của miền don.
	goc, err := exec.Command("git", "rev-parse", "--show-toplevel").Output()
	if err != nil {
		t.Fatal(err)
	}
	root := strings.TrimSpace(string(goc))
	seed := exec.Command("perl", "db/seed/seed.pl")
	seed.Dir = root
	var has bool
	if err := owner.QueryRow(ctx, "SELECT EXISTS (SELECT 1 FROM shop.menu_item)").Scan(&has); err != nil {
		t.Fatal(err)
	}
	if !has {
		sql, err := seed.Output()
		if err != nil {
			t.Fatal(err)
		}
		if _, err = owner.Exec(ctx, string(sql)); err != nil {
			t.Fatal(err)
		}
	}
	// Dùng ca hợp lệ số 2 của dữ liệu mồi như bộ test đơn hiện có; không chép giá hay lựa chọn.
	cases := exec.Command("perl", "db/seed/seed.pl", "--price-cases-tsv")
	cases.Dir = root
	data, err := cases.Output()
	if err != nil {
		t.Fatal(err)
	}
	for _, row := range strings.Split(strings.TrimSpace(string(data)), "\n") {
		fields := strings.Split(row, "\t")
		if len(fields) != 5 || fields[0] != "2" {
			continue
		}
		item := f.id("SELECT id FROM shop.menu_item WHERE name=$1", fields[1])
		qty, err := strconv.Atoi(fields[2])
		if err != nil {
			t.Fatal(err)
		}
		options := []int64{}
		if fields[3] != "" {
			for _, part := range strings.Split(fields[3], "|") {
				group, name, ok := strings.Cut(part, "=")
				if !ok {
					t.Fatal(part)
				}
				options = append(options, f.id("SELECT o.id FROM shop.menu_option o JOIN shop.option_group g ON g.id=o.option_group_id WHERE g.name=$1 AND o.name=$2", group, name))
			}
		}
		f.line = map[string]any{"menu_item_id": item, "quantity": qty, "option_ids": options, "is_takeaway": false}
	}
	if f.line == nil {
		t.Fatal("không có ca giá 2")
	}
	f.table = f.id("INSERT INTO shop.dining_table(label) VALUES ($1) RETURNING id", t.Name())
	old := don.DongHo
	loc, err := time.LoadLocation(testhelper.ShopTZ(t))
	if err != nil {
		t.Fatal(err)
	}
	// Mốc xét giờ ở ngày kế tiếp, trong giờ bán; mốc ghi khoảng và SSE vẫn now() thật.
	tomorrow := time.Now().In(loc).AddDate(0, 0, 1)
	at := time.Date(tomorrow.Year(), tomorrow.Month(), tomorrow.Day(), 8, 0, 0, 0, loc)
	don.DongHo = func(context.Context, pgx.Tx) (time.Time, error) { return at, nil }
	t.Cleanup(func() { don.DongHo = old })
	f.server = httptest.NewServer(routerWithRealtime(pool, taikhoan.NewAuthenticator(pool), f.broker))
	t.Cleanup(f.server.Close)
	_, b := f.request("POST", fmt.Sprintf("/dining-tables/%d/qr-code", f.table), f.ownerID, nil, 201)
	f.qr = b["code"].(string)
	// Các test khoảng này chạy trong database riêng của be-check. Khép khoảng của chính test
	// qua cửa thật để test tiếp theo không nhận một khoảng còn mở.
	t.Cleanup(func() {
		for _, p := range []string{"/order-intake/resume", "/shop-blind/reopening"} {
			req, _ := http.NewRequest("POST", f.server.URL+p, nil)
			req.AddCookie(&http.Cookie{Name: taikhoan.CookiePhien, Value: testhelper.Session(f.t, f.ownerID)})
			res, err := http.DefaultClient.Do(req)
			if err == nil {
				res.Body.Close()
			}
		}
	})
	return f
}
func (f *rtFixture) id(sql string, args ...any) int64 {
	f.t.Helper()
	var id int64
	if err := f.owner.QueryRow(f.ctx, sql, args...).Scan(&id); err != nil {
		f.t.Fatal(err)
	}
	return id
}
func (f *rtFixture) execVet(sql string) {
	f.t.Helper()
	err := pgx.BeginFunc(f.ctx, f.owner, func(tx pgx.Tx) error {
		if _, err := tx.Exec(f.ctx, "SELECT set_config('shop.actor_person_id',$1,true),set_config('shop.revision_reason','P3-12 fixture',true)", strconv.FormatInt(f.ownerID, 10)); err != nil {
			return err
		}
		_, err := tx.Exec(f.ctx, sql)
		return err
	})
	if err != nil {
		f.t.Fatal(err)
	}
}
func (f *rtFixture) request(method, path string, person int64, body any, want int) (int, map[string]any) {
	f.t.Helper()
	raw, err := json.Marshal(body)
	if err != nil {
		f.t.Fatal(err)
	}
	req, err := http.NewRequestWithContext(f.ctx, method, f.server.URL+path, bytes.NewReader(raw))
	if err != nil {
		f.t.Fatal(err)
	}
	req.Header.Set("Content-Type", "application/json")
	if person != 0 {
		req.AddCookie(&http.Cookie{Name: taikhoan.CookiePhien, Value: testhelper.Session(f.t, person)})
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		f.t.Fatal(err)
	}
	defer res.Body.Close()
	var out map[string]any
	if err := json.NewDecoder(res.Body).Decode(&out); err != nil {
		f.t.Fatal(err)
	}
	if res.StatusCode != want {
		f.t.Fatalf("%s %s: %d %v, muốn %d", method, path, res.StatusCode, out, want)
	}
	return res.StatusCode, out
}
func (f *rtFixture) code(path string, person int64, want string) {
	f.t.Helper()
	_, b := f.request("POST", path, person, nil, 409)
	if b["code"] != want {
		f.t.Fatalf("%s: %v", path, b)
	}
}
func (f *rtFixture) order(channel string, want int) map[string]any {
	f.t.Helper()
	var id [16]byte
	if _, err := rand.Read(id[:]); err != nil {
		f.t.Fatal(err)
	}
	submission := fmt.Sprintf("%x-%x-%x-%x-%x", id[:4], id[4:6], id[6:8], id[8:10], id[10:])
	line := map[string]any{}
	for k, v := range f.line {
		line[k] = v
	}
	body := map[string]any{"submission_code": submission, "lines": []any{line}}
	path := "/online-orders"
	person := int64(0)
	switch channel {
	case "qr_table":
		path = "/qr-codes/" + f.qr + "/orders"
	case "staff_pos":
		path = "/table-orders"
		person = f.counter
		body["dining_table_id"] = f.table
	default:
		delete(line, "is_takeaway")
		body["customer_phone"] = "0901234567"
		body["customer_needed_at"] = time.Now().Add(24 * time.Hour).Format(time.RFC3339)
		if channel == "phone_preorder" {
			path = "/phone-orders"
			person = f.counter
			body["handover_code"] = "shop_pickup"
		} else {
			body["channel_code"] = channel
		}
		if channel == "delivery" {
			body["delivery_address"] = "địa chỉ test"
		}
	}
	_, out := f.request("POST", path, person, body, want)
	return out
}

type rtStream struct {
	body   io.ReadCloser
	events chan string
	done   chan struct{}
}

func (f *rtFixture) stream(path string, person int64) *rtStream {
	f.t.Helper()
	req, _ := http.NewRequestWithContext(f.ctx, "GET", f.server.URL+path, nil)
	if person != 0 {
		req.AddCookie(&http.Cookie{Name: taikhoan.CookiePhien, Value: testhelper.Session(f.t, person)})
	}
	res, err := http.DefaultClient.Do(req)
	if err != nil {
		f.t.Fatal(err)
	}
	if res.StatusCode != 200 || res.Header.Get("Content-Type") != "text/event-stream" {
		res.Body.Close()
		f.t.Fatalf("SSE: %d %v", res.StatusCode, res.Header)
	}
	s := &rtStream{res.Body, make(chan string, 64), make(chan struct{})}
	go func() {
		defer close(s.done)
		defer close(s.events)
		sc := bufio.NewScanner(res.Body)
		event := ""
		valid := false
		for sc.Scan() {
			line := sc.Text()
			if strings.HasPrefix(line, "event: ") {
				event = strings.TrimPrefix(line, "event: ")
			}
			if strings.HasPrefix(line, "data: ") {
				var data map[string]json.RawMessage
				err := json.Unmarshal([]byte(strings.TrimPrefix(line, "data: ")), &data)
				var at time.Time
				valid = err == nil && len(data) == 1 && json.Unmarshal(data["read_at"], &at) == nil && !at.IsZero()
			}
			if line == "" && event != "" {
				if !valid {
					event = "invalid-payload"
				}
				select {
				case s.events <- event:
				case <-f.ctx.Done():
					return
				}
				event = ""
				valid = false
			}
		}
	}()
	f.t.Cleanup(func() { s.body.Close(); <-s.done })
	s.want(f.t, "hello")
	return s
}
func (s *rtStream) want(t *testing.T, event string) {
	t.Helper()
	select {
	case got := <-s.events:
		if got != event {
			t.Fatalf("SSE muốn %s, nhận %s", event, got)
		}
	case <-time.After(3 * time.Second):
		t.Fatalf("không nhận %s", event)
	}
}
func (f *rtFixture) closeCounter(s *rtStream) {
	f.t.Helper()
	s.body.Close()
	<-s.done
	deadline := time.Now().Add(2 * time.Second)
	for time.Now().Before(deadline) {
		if seeing, _ := f.broker.Seeing(); !seeing {
			return
		}
		time.Sleep(time.Millisecond)
	}
	f.t.Fatal("luồng đã đóng nhưng quầy vẫn thấy")
}
func rtCode(t *testing.T, b map[string]any, want string) {
	t.Helper()
	if b["code"] != want {
		t.Fatalf("muốn %s, nhận %v", want, b)
	}
}

func TestI008_KhongLuongQuayThiBaKenhTuBamBiTuChoi(t *testing.T) {
	f := rtSetup(t, time.Hour)
	before := f.id("SELECT count(*) FROM shop.sales_order")
	for _, channel := range []string{"qr_table", "delivery", "pickup"} {
		rtCode(t, f.order(channel, 409), "shop_not_seeing_orders")
	}
	if n := f.id("SELECT count(*) FROM shop.shop_blind_spell WHERE ended_at IS NULL AND declared_by_person_id IS NULL AND started_at<=now()"); n != 1 {
		t.Fatalf("khoảng máy ghi: %d", n)
	}
	if n := f.id("SELECT count(*) FROM shop.sales_order"); n != before {
		t.Fatal("đơn bị từ chối vẫn ghi")
	}
	f.order("phone_preorder", 201)
	f.order("staff_pos", 201)
}
func TestI008_CoLuongQuayThiNhanDon(t *testing.T) {
	f := rtSetup(t, time.Hour)
	s := f.stream("/counter/events", f.counter)
	f.order("qr_table", 201)
	f.closeCounter(s)
	rtCode(t, f.order("qr_table", 409), "shop_not_seeing_orders")
	s = f.stream("/counter/events", f.counter)
	s.want(t, "changed")
	rtCode(t, f.order("qr_table", 409), "shop_not_seeing_orders")
	f.request("POST", "/shop-blind/reopening", f.counter, nil, 200)
	f.order("qr_table", 201)
}
func TestI008_NutMoLaiKhepKhoangCoNguoi(t *testing.T) {
	f := rtSetup(t, time.Hour)
	f.order("qr_table", 409)
	_, b := f.request("POST", "/shop-blind/reopening", f.outsider, nil, 403)
	rtCode(t, b, "not_on_counter_duty")
	_, b = f.request("POST", "/shop-blind/reopening", f.counter, nil, 200)
	if b["ended_at"] == nil || b["ended_by_person_id"] != float64(f.counter) {
		t.Fatal(b)
	}
	f.code("/shop-blind/reopening", f.counter, "shop_not_blind")
}
func TestI008_BaoMuCoNguoi(t *testing.T) {
	f := rtSetup(t, time.Hour)
	_, b := f.request("POST", "/shop-blind/declaration", f.outsider, nil, 403)
	rtCode(t, b, "not_on_counter_duty")
	_, b = f.request("POST", "/shop-blind/declaration", f.ownerID, nil, 200)
	if b["declared_by_person_id"] != float64(f.ownerID) {
		t.Fatal(b)
	}
	f.code("/shop-blind/declaration", f.counter, "shop_already_blind")
}
func TestI008_TamDungNhanDonCuaChuQuan(t *testing.T) {
	f := rtSetup(t, time.Hour)
	f.stream("/counter/events", f.counter)
	for _, path := range []string{"/order-intake/pause", "/order-intake/resume"} {
		_, b := f.request("POST", path, f.counter, nil, 403)
		rtCode(t, b, "owner_only")
	}
	f.request("POST", "/order-intake/pause", f.ownerID, nil, 200)
	f.code("/order-intake/pause", f.ownerID, "order_intake_already_paused")
	for _, channel := range []string{"qr_table", "delivery", "pickup", "staff_pos", "phone_preorder"} {
		rtCode(t, f.order(channel, 409), "order_intake_paused")
	}
	_, b := f.request("GET", "/counter/queue", f.counter, nil, 200)
	if b["paused_since"] == nil {
		t.Fatal(b)
	}
	f.request("POST", "/order-intake/resume", f.ownerID, nil, 200)
	f.code("/order-intake/resume", f.ownerID, "order_intake_not_paused")
	for _, channel := range []string{"qr_table", "delivery", "pickup", "staff_pos", "phone_preorder"} {
		f.order(channel, 201)
	}
}
func TestYC34_KhoangMuDocLaiDuoc(t *testing.T) {
	f := rtSetup(t, time.Hour)
	f.order("qr_table", 409)
	_, b := f.request("POST", "/shop-blind/reopening", f.ownerID, nil, 200)
	var start, end time.Time
	var person int64
	if err := f.owner.QueryRow(f.ctx, "SELECT started_at,ended_at,ended_by_person_id FROM shop.shop_blind_spell WHERE id=$1", int64(b["id"].(float64))).Scan(&start, &end, &person); err != nil {
		t.Fatal(err)
	}
	if !end.After(start) || person != f.ownerID {
		t.Fatalf("%s %s %d", start, end, person)
	}
	t.Logf("đọc lại khoảng: %s → %s, người mở %d", start.Format(time.RFC3339Nano), end.Format(time.RFC3339Nano), person)
}
func TestI008_MoLaiKhiChuaCoLuongKhongChongKhoang(t *testing.T) {
	f := rtSetup(t, time.Hour)
	f.order("qr_table", 409)
	_, closed := f.request("POST", "/shop-blind/reopening", f.ownerID, nil, 200)
	rtCode(t, f.order("qr_table", 409), "shop_not_seeing_orders")
	var start, end time.Time
	if err := f.owner.QueryRow(f.ctx, "SELECT s.started_at,p.ended_at FROM shop.shop_blind_spell s CROSS JOIN shop.shop_blind_spell p WHERE s.ended_at IS NULL AND p.id=$1", int64(closed["id"].(float64))).Scan(&start, &end); err != nil {
		t.Fatal(err)
	}
	if !start.Equal(end) {
		t.Fatalf("khoảng mới %s, mốc mở lại %s", start, end)
	}
}
func TestQC12_DayChiBaoSauCommit(t *testing.T) {
	f := rtSetup(t, time.Hour)
	s := f.stream("/production-board/events", 0)
	f.request("POST", "/order-intake/pause", f.ownerID, nil, 200)
	s.want(t, "changed")
	f.code("/order-intake/pause", f.ownerID, "order_intake_already_paused")
	select {
	case got := <-s.events:
		t.Fatalf("giao dịch lùi phát %s", got)
	case <-time.After(100 * time.Millisecond):
	}
	// Luồng đọc và HEAD không được phát changed hoặc giữ quầy nhìn thấy.
	f.request("GET", "/counter/queue", f.counter, nil, 200)
	select {
	case got := <-s.events:
		t.Fatalf("đọc phát %s", got)
	case <-time.After(50 * time.Millisecond):
	}
}
func TestQC12_LuongCoHeartbeat(t *testing.T) {
	f := rtSetup(t, 20*time.Millisecond)
	s := f.stream("/production-board/events", 0)
	s.want(t, "heartbeat")
}
func TestI008_MatDayVanDocDuocDonDaNhan(t *testing.T) {
	f := rtSetup(t, time.Hour)
	s := f.stream("/counter/events", f.counter)
	order := f.order("qr_table", 201)
	f.closeCounter(s)
	f.order("staff_pos", 201)
	for _, path := range []string{"/counter/queue", "/production-board"} {
		_, b := f.request("GET", path, f.counter, nil, 200)
		if b["poll_interval_seconds"] != float64(20) || b["read_at"] == nil {
			t.Fatal(b)
		}
		if path == "/counter/queue" {
			found := false
			for _, v := range b["orders"].([]any) {
				if v.(map[string]any)["sales_order_id"] == order["sales_order_id"] {
					found = true
				}
			}
			if !found {
				t.Fatalf("mất đơn đã nhận: %v", b)
			}
		} else if len(b["rows"].([]any)) == 0 {
			t.Fatal("đường kéo không thấy việc vừa ghi")
		}
	}
	f.order("qr_table", 409)
	_, b := f.request("GET", "/counter/queue", f.counter, nil, 200)
	if b["blind_since"] == nil || b["paused_since"] != nil {
		t.Fatal(b)
	}
}
func TestI008_NhieuLuongQuayVaTuChoiSaiLop(t *testing.T) {
	f := rtSetup(t, time.Hour)
	for _, person := range []int64{f.ownerID, f.outsider} {
		_, b := f.request("GET", "/counter/events", person, nil, 403)
		rtCode(t, b, "not_on_counter_duty")
	}
	_, b := f.request("GET", "/counter/events", 0, nil, 401)
	rtCode(t, b, "unauthenticated")
	s1 := f.stream("/counter/events", f.counter)
	s2 := f.stream("/counter/events", f.counter)
	s1.body.Close()
	<-s1.done
	f.order("qr_table", 201)
	f.closeCounter(s2)
	f.order("qr_table", 409)
}

// TCP proxy: đóng các kết nối đang sống và từ chối kết nối mới, sau đó nối lại cùng database.
type rtCut struct {
	mu       sync.Mutex
	cut      bool
	conns    map[net.Conn]bool
	listener net.Listener
	target   string
}

func newRTCut(t *testing.T, target string) *rtCut {
	t.Helper()
	l, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	p := &rtCut{conns: map[net.Conn]bool{}, listener: l, target: target}
	t.Cleanup(func() { l.Close(); p.set(true) })
	go func() {
		for {
			c, err := l.Accept()
			if err != nil {
				return
			}
			go func() {
				defer c.Close()
				p.mu.Lock()
				if p.cut {
					p.mu.Unlock()
					return
				}
				p.conns[c] = true
				p.mu.Unlock()
				defer func() { p.mu.Lock(); delete(p.conns, c); p.mu.Unlock() }()
				upstream, err := net.DialTimeout("tcp", p.target, time.Second)
				if err != nil {
					return
				}
				defer upstream.Close()
				done := make(chan struct{})
				go func() { io.Copy(c, upstream); c.Close(); close(done) }()
				io.Copy(upstream, c)
				upstream.Close()
				<-done
			}()
		}
	}()
	return p
}
func (p *rtCut) set(cut bool) {
	p.mu.Lock()
	defer p.mu.Unlock()
	p.cut = cut
	if cut {
		for c := range p.conns {
			c.Close()
		}
	}
}
func TestI008_PT2_DatabaseMatVaNoiLai(t *testing.T) {
	f := rtSetup(t, time.Hour)
	cfg := f.pool.Config()
	proxy := newRTCut(t, net.JoinHostPort(cfg.ConnConfig.Host, strconv.Itoa(int(cfg.ConnConfig.Port))))
	host, port, _ := net.SplitHostPort(proxy.listener.Addr().String())
	n, _ := strconv.Atoi(port)
	cfg.ConnConfig.Host = host
	cfg.ConnConfig.Port = uint16(n)
	cfg.ConnConfig.ConnectTimeout = time.Second
	pool, err := pgxpool.NewWithConfig(f.ctx, cfg)
	if err != nil {
		t.Fatal(err)
	}
	defer pool.Close()
	server := httptest.NewServer(routerWithRealtime(pool, taikhoan.NewAuthenticator(pool), f.broker))
	defer server.Close()
	original := f.server
	f.server = server
	defer func() { f.server = original }()
	f.request("GET", "/counter/queue", f.counter, nil, 200)
	before := f.id("SELECT count(*) FROM shop.order_intake_pause")
	proxy.set(true)
	start := time.Now()
	_, b := f.request("POST", "/order-intake/pause", f.ownerID, nil, 500)
	rtCode(t, b, "internal_error")
	if time.Since(start) > 6*time.Second {
		t.Fatal("database mất làm cửa treo")
	}
	if got := f.id("SELECT count(*) FROM shop.order_intake_pause"); got != before {
		t.Fatal("ghi nửa khoảng khi database mất")
	}
	proxy.set(false)
	f.request("POST", "/order-intake/pause", f.ownerID, nil, 200)
	_, b = f.request("GET", "/counter/queue", f.counter, nil, 200)
	if b["paused_since"] == nil {
		t.Fatal("nối lại đọc sai trạng thái")
	}
	f.request("POST", "/order-intake/resume", f.ownerID, nil, 200)
}
