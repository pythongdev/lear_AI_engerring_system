// Test hồi quy P4-06 — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Giữ (ADR-097, ADR-102 điểm 1 · 2, 09-realtime-du-phong.md §3): luồng SSE chỉ là tín hiệu ĐỌC LẠI — `hello` và
// `changed` làm mất hiệu lực query rồi đọc lại từ backend, `heartbeat` không; dữ liệu kèm tín hiệu không vào cache.
// Luồng đứt, nối không được, hay im quá ngưỡng ⇒ banner mất kết nối hiện (không nút đóng) và tự nối lại; nối lại
// được ⇒ `hello` ⇒ đọc lại, banner tắt. Rời màn ⇒ huỷ lời gọi luồng (backend thấy luồng quầy đóng). Đường đọc sống tự
// kéo theo `poll_interval_seconds` backend trả, kể cả khi luồng sống. Luồng mở ở layout, không mở lại khi đổi trang con.
import { act, cleanup, render, screen, waitFor } from "@testing-library/react";
import { useQuery } from "@tanstack/react-query";
import type { ReactNode } from "react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { call } from "@/lib/api/client";
import { ApiProvider, useApi } from "@/lib/api/provider";

import { BaoMatKetNoi, TinHieuProvider, chuKyKeoMs, tuyChonKeo } from "./tin-hieu";

import QuayLayout from "@/app/quay/layout";
import TramLayout from "@/app/tram/layout";

const replace = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ replace, push: vi.fn() }),
  usePathname: () => "/quay",
  useSearchParams: () => new URLSearchParams(),
}));
afterEach(() => { cleanup(); replace.mockReset(); });

const enc = new TextEncoder();
type Luong = { gui: (event: string, chunk?: "tach") => void; dong: () => void; signal: AbortSignal };

/** Backend giả: mỗi lần mở luồng tạo một luồng điều khiển được; đường đọc khác trả theo `doc`. */
function backend(o: { luong?: (lan: number) => "mo" | "mat-mang" | number; doc?: (path: string) => { status: number; body: unknown } } = {}) {
  const goi: { method: string; path: string; accept: string | null }[] = [];
  const luong: Luong[] = [];
  const fetch = async (req: Request) => {
    const path = new URL(req.url).pathname.replace(/^\/api/, "");
    goi.push({ method: req.method, path, accept: req.headers.get("accept") });
    if (path.endsWith("/events")) {
      const kieu = o.luong ? o.luong(luong.length + 1) : "mo";
      if (kieu === "mat-mang") { luong.push({ gui() {}, dong() {}, signal: req.signal }); throw new TypeError("fetch failed"); }
      if (typeof kieu === "number") {
        luong.push({ gui() {}, dong() {}, signal: req.signal });
        return new Response(JSON.stringify({ code: "not_on_counter_duty", message: "x" }), { status: kieu, headers: { "content-type": "application/json" } });
      }
      let c!: ReadableStreamDefaultController<Uint8Array>;
      const s = new ReadableStream<Uint8Array>({ start(x) { c = x; } });
      luong.push({
        signal: req.signal,
        gui(event, chunk) {
          const khung = `event: ${event}\ndata: {"read_at":"2026-10-20T02:00:00Z"}\n\n`;
          if (chunk === "tach") { c.enqueue(enc.encode(khung.slice(0, 9))); c.enqueue(enc.encode(khung.slice(9))); }
          else c.enqueue(enc.encode(khung));
        },
        dong() { c.close(); },
      });
      return new Response(s, { status: 200, headers: { "content-type": "text/event-stream" } });
    }
    const r = o.doc ? o.doc(path) : path === "/sessions/current"
      ? { status: 200, body: { person_id: 7, display_name: "Lan", role_code: "quay", is_owner: false, must_change_password: false, counter_duty_id: 3 } }
      : { status: 200, body: { read_at: "2026-10-20T02:00:00Z", poll_interval_seconds: 20, orders: [], paused_since: null, blind_since: null } };
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  };
  return { fetch, goi, luong };
}

/** Một màn đọc hàng chờ quầy để đếm số lần đọc lại. */
function DocHangCho() {
  const api = useApi();
  const q = useQuery({ queryKey: ["counter", "queue"], queryFn: async () => {
    const r = await call(api.GET("/counter/queue"));
    if (!r.ok) throw r.failure;
    return r.data;
  } });
  return <p>{q.data ? "đã đọc" : "chưa đọc"}</p>;
}

const NHANH = { noiLaiSauMs: () => 20, hetHoiSauMs: 10_000 };
function voi(b: ReturnType<typeof backend>, ui: ReactNode) {
  return render(<ApiProvider fetch={b.fetch}>{ui}</ApiProvider>);
}
const soLuong = (b: ReturnType<typeof backend>, path = "/counter/events") => b.goi.filter((g) => g.path === path).length;
const soDoc = (b: ReturnType<typeof backend>) => b.goi.filter((g) => g.path === "/counter/queue").length;

describe("lớp realtime — tín hiệu đọc lại", () => {
  it("mở luồng với Accept text/event-stream; hello và changed ⇒ đọc lại, heartbeat thì không", async () => {
    const b = backend();
    voi(b, <TinHieuProvider duong="/counter/events" {...NHANH}><BaoMatKetNoi /><DocHangCho /></TinHieuProvider>);
    await screen.findByText("đã đọc");
    await waitFor(() => expect(b.luong).toHaveLength(1));
    expect(b.goi.find((g) => g.path === "/counter/events")?.accept).toBe("text/event-stream");
    const dau = soDoc(b);
    await act(async () => b.luong[0].gui("hello"));
    await waitFor(() => expect(soDoc(b)).toBe(dau + 1));
    await act(async () => b.luong[0].gui("heartbeat"));
    await new Promise((r) => setTimeout(r, 60));
    expect(soDoc(b)).toBe(dau + 1);
    // Khung SSE bị cắt giữa hai mẩu vẫn đọc đúng.
    await act(async () => b.luong[0].gui("changed", "tach"));
    await waitFor(() => expect(soDoc(b)).toBe(dau + 2));
    expect(screen.queryByRole("alert")).toBeNull();
  });

  it("luồng đứt ⇒ banner hiện, không nút; tự nối lại; hello của luồng mới ⇒ đọc lại và banner tắt", async () => {
    const b = backend();
    voi(b, <TinHieuProvider duong="/counter/events" {...NHANH}><BaoMatKetNoi /><DocHangCho /></TinHieuProvider>);
    await waitFor(() => expect(b.luong).toHaveLength(1));
    await act(async () => b.luong[0].gui("hello"));
    await act(async () => b.luong[0].dong());
    const bao = await screen.findByRole("alert");
    expect(bao.textContent).toMatch(/Mất kết nối trực tiếp/);
    expect(bao.querySelector("button")).toBeNull();
    await waitFor(() => expect(b.luong).toHaveLength(2));
    const truoc = soDoc(b);
    await act(async () => b.luong[1].gui("hello"));
    await waitFor(() => expect(screen.queryByRole("alert")).toBeNull());
    await waitFor(() => expect(soDoc(b)).toBeGreaterThan(truoc));
  });

  it.each([["mất mạng", "mat-mang" as const], ["backend từ chối 403", 403], ["tầng chuyển tiếp 502", 502]])(
    "lần nối đầu thất bại (%s) ⇒ banner hiện và vẫn thử nối lại", async (_ten, kieu) => {
      const b = backend({ luong: (lan) => lan < 3 ? kieu : "mo" });
      voi(b, <TinHieuProvider duong="/counter/events" {...NHANH}><BaoMatKetNoi /></TinHieuProvider>);
      expect(await screen.findByRole("alert")).toBeTruthy();
      await waitFor(() => expect(b.luong.length).toBeGreaterThanOrEqual(3));
      await act(async () => b.luong[2].gui("hello"));
      await waitFor(() => expect(screen.queryByRole("alert")).toBeNull());
    });

  it("đang nối lần đầu thì chưa hiện banner", async () => {
    const b = backend();
    voi(b, <TinHieuProvider duong="/counter/events" {...NHANH}><BaoMatKetNoi /></TinHieuProvider>);
    await waitFor(() => expect(b.luong).toHaveLength(1));
    expect(screen.queryByRole("alert")).toBeNull();
  });

  it("luồng im quá ngưỡng (không cả heartbeat) ⇒ coi là đứt: huỷ lời gọi cũ, banner, nối lại", async () => {
    const b = backend();
    voi(b, <TinHieuProvider duong="/counter/events" noiLaiSauMs={() => 20} hetHoiSauMs={120}><BaoMatKetNoi /></TinHieuProvider>);
    await waitFor(() => expect(b.luong).toHaveLength(1));
    await act(async () => b.luong[0].gui("hello"));
    expect(await screen.findByRole("alert", {}, { timeout: 1000 })).toBeTruthy();
    expect(b.luong[0].signal.aborted).toBe(true);
    await waitFor(() => expect(b.luong.length).toBeGreaterThanOrEqual(2));
  });

  it("heartbeat đều thì không coi là im", async () => {
    const b = backend();
    voi(b, <TinHieuProvider duong="/counter/events" noiLaiSauMs={() => 20} hetHoiSauMs={150}><BaoMatKetNoi /></TinHieuProvider>);
    await waitFor(() => expect(b.luong).toHaveLength(1));
    await act(async () => b.luong[0].gui("hello"));
    for (let i = 0; i < 4; i++) {
      await new Promise((r) => setTimeout(r, 80));
      await act(async () => b.luong[0].gui("heartbeat"));
    }
    expect(screen.queryByRole("alert")).toBeNull();
    expect(b.luong).toHaveLength(1);
  });

  it("rời màn ⇒ huỷ lời gọi luồng, không nối lại nữa", async () => {
    const b = backend();
    const r = voi(b, <TinHieuProvider duong="/counter/events" {...NHANH}><BaoMatKetNoi /></TinHieuProvider>);
    await waitFor(() => expect(b.luong).toHaveLength(1));
    r.unmount();
    expect(b.luong[0].signal.aborted).toBe(true);
    await new Promise((r2) => setTimeout(r2, 80));
    expect(b.luong).toHaveLength(1);
  });
});

describe("lớp realtime — kéo theo chu kỳ", () => {
  it("chuKyKeoMs đọc poll_interval_seconds; chưa có lần đọc thì dùng 20 giây của hợp đồng", () => {
    expect(chuKyKeoMs(undefined)).toBe(20_000);
    expect(chuKyKeoMs({ poll_interval_seconds: 20 })).toBe(20_000);
    expect(chuKyKeoMs({ poll_interval_seconds: 5 })).toBe(5_000);
  });

  it("tuyChonKeo: đường đọc tự kéo theo chu kỳ backend trả, cả khi luồng không gửi gì", async () => {
    const b = backend({ doc: () => ({ status: 200, body: { read_at: "x", poll_interval_seconds: 0.05, orders: [], paused_since: null, blind_since: null } }) });
    function Keo() {
      const api = useApi();
      useQuery({ queryKey: ["counter", "queue"], ...tuyChonKeo(), queryFn: async () => {
        const r = await call(api.GET("/counter/queue"));
        if (!r.ok) throw r.failure;
        return r.data;
      } });
      return null;
    }
    voi(b, <Keo />);
    await waitFor(() => expect(soDoc(b)).toBeGreaterThanOrEqual(4), { timeout: 1500 });
    expect(tuyChonKeo().refetchIntervalInBackground).toBe(true);
  });
});

describe("lớp realtime — gắn vào khung", () => {
  it("layout quầy mở /counter/events một lần; đổi trang con không mở lại", async () => {
    const b = backend();
    const r = voi(b, <QuayLayout><p>trang một</p></QuayLayout>);
    await screen.findByText("trang một");
    await waitFor(() => expect(soLuong(b)).toBe(1));
    r.rerender(<ApiProvider fetch={b.fetch}><QuayLayout><p>trang hai</p></QuayLayout></ApiProvider>);
    await screen.findByText("trang hai");
    await new Promise((x) => setTimeout(x, 60));
    expect(soLuong(b)).toBe(1);
    expect(screen.getByText("Quầy")).toBeTruthy();
  });

  it("phiên chủ quán vào khung quầy: chuyển đi, không mở luồng quầy", async () => {
    const b = backend({ doc: (p) => p === "/sessions/current"
      ? { status: 200, body: { person_id: 1, display_name: "Chủ", role_code: "owner", is_owner: true, must_change_password: false, counter_duty_id: 0 } }
      : { status: 599, body: {} } });
    voi(b, <QuayLayout><p>trang</p></QuayLayout>);
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/chu-quan"));
    expect(soLuong(b)).toBe(0);
  });

  it("layout trạm mở /production-board/events và có banner khi luồng đứt", async () => {
    const b = backend({ doc: (p) => p === "/sessions/current"
      ? { status: 200, body: { person_id: 4, display_name: "Bếp", role_code: "tram_cuon", is_owner: false, must_change_password: false, counter_duty_id: 0 } }
      : { status: 200, body: {} } });
    voi(b, <TramLayout><p>bảng</p></TramLayout>);
    await screen.findByText("bảng");
    await waitFor(() => expect(soLuong(b, "/production-board/events")).toBe(1));
    await act(async () => b.luong[0].dong());
    const bao = await screen.findByRole("alert");
    expect(bao.querySelector("button")).toBeNull();
  });
});
