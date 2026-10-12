package realtime

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"
)

func TestI008_BoPhatDemLuongVaGiuMocDongCuoi(t *testing.T) {
	b := New(0)
	seeing, start := b.Seeing()
	if seeing || start.IsZero() {
		t.Fatal("khởi động phải mù")
	}
	_, stationClose := b.subscribe(false)
	if seeing, _ := b.Seeing(); seeing {
		t.Fatal("trạm không phải quầy")
	}
	_, close1 := b.subscribe(true)
	_, close2 := b.subscribe(true)
	close1()
	close1()
	if seeing, _ := b.Seeing(); !seeing {
		t.Fatal("còn một quầy")
	}
	close2()
	stationClose()
	seeing, end := b.Seeing()
	if seeing || end.Before(start) {
		t.Fatal("không giữ mốc luồng cuối đóng")
	}
}
func TestQC12_BoPhatKhongBiManChamChan(t *testing.T) {
	b := New(0)
	ch, closeStream := b.subscribe(false)
	defer closeStream()
	done := make(chan struct{})
	go func() {
		for i := 0; i < 10000; i++ {
			b.Publish(time.Now())
		}
		close(done)
	}()
	select {
	case <-done:
	case <-time.After(time.Second):
		t.Fatal("màn chậm chặn cửa ghi")
	}
	select {
	case <-ch:
	default:
		t.Fatal("mất tín hiệu đọc lại")
	}
	if len(ch) != 0 {
		t.Fatal("giữ lịch sử thay vì gộp tín hiệu")
	}
}
func TestI008_BoPhatAnToanKhiDongMoChenNhau(t *testing.T) {
	b := New(0)
	var wg sync.WaitGroup
	for i := 0; i < 30; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			for j := 0; j < 100; j++ {
				_, closeStream := b.subscribe(true)
				b.Publish(time.Now())
				closeStream()
			}
		}()
	}
	wg.Wait()
	if seeing, _ := b.Seeing(); seeing {
		t.Fatal("rò luồng quầy")
	}
}
func TestQC12_SSEHelloHeartbeatVaDongKhiDatabaseMat(t *testing.T) {
	b := New(time.Millisecond)
	w := httptest.NewRecorder()
	r := httptest.NewRequest("GET", "/events", nil)
	at := time.Date(2026, 10, 12, 1, 2, 3, 0, time.UTC)
	reads := 0
	b.Serve(w, r, true, true, at, func(context.Context) (time.Time, error) {
		reads++
		if reads == 1 {
			return at, nil
		}
		return time.Time{}, errors.New("database mất")
	})
	if w.Header().Get("Content-Type") != "text/event-stream" {
		t.Fatal(w.Header())
	}
	want := "event: hello\ndata: {\"read_at\":\"2026-10-12T01:02:03Z\"}\n\nevent: changed\ndata: {\"read_at\":\"2026-10-12T01:02:03Z\"}\n\nevent: heartbeat\ndata: {\"read_at\":\"2026-10-12T01:02:03Z\"}\n\n"
	if w.Body.String() != want {
		t.Fatalf("payload: %s", w.Body.String())
	}
	if seeing, _ := b.Seeing(); seeing {
		t.Fatal("database mất mà luồng còn đếm")
	}
}
func TestI008_HEADKhongMoLuongQuay(t *testing.T) {
	b := New(0)
	w := httptest.NewRecorder()
	r := httptest.NewRequest("GET", "/events", nil)
	r = r.WithContext(HeadContext(r.Context()))
	b.Serve(w, r, true, false, time.Now(), nil)
	if w.Code != http.StatusOK || !strings.HasPrefix(w.Header().Get("Content-Type"), "text/event-stream") || w.Body.Len() != 0 {
		t.Fatal(w)
	}
	if seeing, _ := b.Seeing(); seeing {
		t.Fatal("HEAD được tính là quầy đang nghe")
	}
}
