// Package realtime phát tín hiệu đọc lại trong một tiến trình (ADR-097).
// Không giữ dữ liệu nghiệp vụ hay lịch sử sự kiện; người đọc chậm chỉ cần một tín hiệu.
package realtime

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"sync"
	"time"
)

const PollIntervalSeconds = 20
const HeartbeatInterval = 10 * time.Second

type headKey struct{}

func HeadContext(ctx context.Context) context.Context { return context.WithValue(ctx, headKey{}, true) }

type Visibility interface{ Seeing() (bool, time.Time) }
type AlwaysSeeing struct{}

func (AlwaysSeeing) Seeing() (bool, time.Time) { return true, time.Time{} }

type Broker struct {
	mu         sync.Mutex
	readers    map[chan time.Time]bool
	counters   int
	blindSince time.Time
	heartbeat  time.Duration
}

func New(heartbeat time.Duration) *Broker {
	if heartbeat <= 0 {
		heartbeat = HeartbeatInterval
	}
	return &Broker{readers: make(map[chan time.Time]bool), blindSince: time.Now(), heartbeat: heartbeat}
}
func (b *Broker) Seeing() (bool, time.Time) {
	b.mu.Lock()
	defer b.mu.Unlock()
	return b.counters > 0, b.blindSince
}
func (b *Broker) subscribe(counter bool) (<-chan time.Time, func()) {
	b.mu.Lock()
	ch := make(chan time.Time, 1)
	b.readers[ch] = counter
	if counter {
		b.counters++
	}
	b.mu.Unlock()
	var once sync.Once
	return ch, func() {
		once.Do(func() {
			b.mu.Lock()
			defer b.mu.Unlock()
			delete(b.readers, ch)
			if counter {
				b.counters--
				if b.counters == 0 {
					b.blindSince = time.Now()
				}
			}
		})
	}
}

// Publish không chờ một màn đang chậm, không gọi database và không thể làm hỏng COMMIT.
func (b *Broker) Publish(at time.Time) {
	b.mu.Lock()
	defer b.mu.Unlock()
	for ch := range b.readers {
		select {
		case ch <- at:
		default:
		}
	}
}

// Serve đóng luồng khi client huỷ, ghi lỗi hoặc database không còn trả lời.
// Hạn ghi chỉ là hạn I/O; không có khoảng chờ được nhận đơn sau khi luồng đã đóng.
func (b *Broker) Serve(w http.ResponseWriter, r *http.Request, counter, blind bool, at time.Time, clock func(context.Context) (time.Time, error)) {
	w.Header().Set("Content-Type", "text/event-stream")
	w.Header().Set("Cache-Control", "no-cache")
	w.Header().Set("X-Accel-Buffering", "no")
	if head, _ := r.Context().Value(headKey{}).(bool); head {
		w.WriteHeader(http.StatusOK)
		return
	}
	ch, closeStream := b.subscribe(counter)
	defer closeStream()
	control := http.NewResponseController(w)
	send := func(event string, at time.Time) bool {
		_ = control.SetWriteDeadline(time.Now().Add(HeartbeatInterval))
		data, _ := json.Marshal(struct {
			ReadAt time.Time `json:"read_at"`
		}{at})
		if _, err := fmt.Fprintf(w, "event: %s\ndata: %s\n\n", event, data); err != nil {
			return false
		}
		return control.Flush() == nil
	}
	if !send("hello", at) {
		return
	}
	if counter && blind && !send("changed", at) {
		return
	}
	ticker := time.NewTicker(b.heartbeat)
	defer ticker.Stop()
	defer control.SetWriteDeadline(time.Time{})
	for {
		select {
		case <-r.Context().Done():
			return
		case at := <-ch:
			if !send("changed", at) {
				return
			}
		case <-ticker.C:
			ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
			at, err := clock(ctx)
			cancel()
			if err != nil || !send("heartbeat", at) {
				return
			}
		}
	}
}
