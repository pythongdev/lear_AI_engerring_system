// Test hồi quy P4-07 (đợt một: hàng chờ quầy) — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa
// điều kiện kiểm. Giữ (ADR-097, ADR-102 dòng Quầy, 05-luong-mang-di.md §2 · §3, 09-realtime-du-phong.md §2 · §3):
// hàng chờ là đúng GET /counter/queue theo thứ tự backend, tự kéo theo chu kỳ; duyệt · từ chối chờ backend rồi đọc lại;
// tạm dừng và quán mù chỉ hiện theo paused_since · blind_since backend trả; quầy mở lại khi quán mù; đơn hẹn đọc từ
// GET /preorder-reminders; máy quầy tự gọi POST /preorder-releases theo chu kỳ, lỗi thì nói ra. Đơn chờ chưa bày được món
// (F-074). Một lần bấm một lời gọi; lời từ chối theo code; mất phản hồi là chưa rõ kết quả.
import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { ApiProvider } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

import { TuNhaDonHen } from "./_components/tu-nha-don-hen";
import QuayLayout from "./layout";
import Page from "./page";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/quay",
  useSearchParams: () => new URLSearchParams(),
}));
afterEach(cleanup);

type CounterQueue = components["schemas"]["CounterQueue"];
// Cố ý không theo mã đơn: màn giữ thứ tự backend.
const hangMau: CounterQueue = {
  read_at: "2026-10-20T02:15:00Z", poll_interval_seconds: 20, paused_since: null, blind_since: null,
  orders: [
    { sales_order_id: 41, channel_code: "delivery", dining_table_id: null, created_at: "2026-10-20T02:10:00Z", customer_phone: "0901111111", customer_needed_at: null },
    { sales_order_id: 40, channel_code: "qr_table", dining_table_id: 3, created_at: "2026-10-20T02:05:00Z", customer_phone: null, customer_needed_at: null },
    { sales_order_id: 42, channel_code: "pickup", dining_table_id: null, created_at: "2026-10-20T02:12:00Z", customer_phone: "0902222222", customer_needed_at: "2026-10-20T03:00:00Z" },
  ],
};
const banMau = { tables: [{ dining_table_id: 3, label: "Bàn 3", state: "in_session", table_session_id: 9, table_session_status: "open" }] };
const henMau = { preorders: [
  { sales_order_id: 50, customer_needed_at: "2026-10-20T03:30:00Z", status: "confirmed", remind_at: ["2026-10-20T03:10:00Z", "2026-10-20T03:20:00Z"], due_reminders: [] },
  { sales_order_id: 51, customer_needed_at: "2026-10-20T02:40:00Z", status: "in_progress", remind_at: ["2026-10-20T02:20:00Z", "2026-10-20T02:30:00Z"], due_reminders: [20, 10] },
] };

type Goi = { method: string; path: string; body: unknown };
type TraLoi = { status: number; body?: unknown } | "mat-mang";
type XuLy = { hang?: (lan: number) => TraLoi; ghi?: (g: Goi) => TraLoi | Promise<TraLoi>; nha?: (lan: number) => TraLoi };
function backend(x: XuLy = {}) {
  const goi: Goi[] = [];
  let lanHang = 0, lanNha = 0;
  const fetch = async (req: Request) => {
    const text = await req.text();
    const g: Goi = { method: req.method, path: new URL(req.url).pathname.replace(/^\/api/, ""), body: text ? JSON.parse(text) : undefined };
    goi.push(g);
    let r: TraLoi = { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    if (g.path === "/counter/queue") { lanHang += 1; r = x.hang ? x.hang(lanHang) : { status: 200, body: hangMau }; }
    else if (g.path === "/dining-tables") r = { status: 200, body: banMau };
    else if (g.path === "/preorder-reminders") r = { status: 200, body: henMau };
    else if (g.path === "/preorder-releases") { lanNha += 1; r = x.nha ? x.nha(lanNha) : { status: 200, body: { released_order_ids: [] } }; }
    else if (g.path === "/sessions/current") r = { status: 200, body: { person_id: 7, display_name: "Lan", role_code: "quay", is_owner: false, must_change_password: false, counter_duty_id: 3 } };
    else if (g.path.endsWith("/events")) return new Response(new ReadableStream(), { status: 200, headers: { "content-type": "text/event-stream" } });
    else if (g.method === "POST" && x.ghi) r = await x.ghi(g);
    if (r === "mat-mang") throw new TypeError("fetch failed");
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  };
  return { fetch, goi };
}
function mo(x: XuLy = {}) {
  const b = backend(x);
  render(<ApiProvider fetch={b.fetch}><Page /></ApiProvider>);
  return b.goi;
}
const ghiDi = (g: Goi[]) => g.filter((x) => x.method === "POST" && x.path !== "/preorder-releases");
const docHang = (g: Goi[]) => g.filter((x) => x.path === "/counter/queue").length;
const xong = { status: 200, body: { sales_order_id: 41, status: "in_progress", table_session_id: null, table_session_status: null } };

describe("hàng chờ quầy — đọc", () => {
  it("bày đơn chờ đúng thứ backend, kênh, bàn, số điện thoại, giờ cần hàng", async () => {
    mo();
    const d41 = await screen.findByRole("region", { name: "Đơn 41" });
    const d40 = screen.getByRole("region", { name: "Đơn 40" });
    const d42 = screen.getByRole("region", { name: "Đơn 42" });
    expect(d41.compareDocumentPosition(d40) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(d40.compareDocumentPosition(d42) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
    expect(d41.textContent).toContain("Giao tận nơi");
    expect(d41.textContent).toContain("0901111111");
    await waitFor(() => expect(d40.textContent).toContain("Bàn 3"));
    expect(d40.textContent).toContain("QR");
    expect(d42.textContent).toContain("Khách tự đến lấy");
    expect(d42.textContent).toMatch(/Cần lúc/);
  });

  it("không có đơn: nói rõ; đọc lỗi: cảnh báo, không bày như rỗng", async () => {
    mo({ hang: () => ({ status: 200, body: { ...hangMau, orders: [] } }) });
    expect(await screen.findByText("Không có đơn chờ xác nhận.")).toBeTruthy();
    cleanup();
    mo({ hang: () => ({ status: 500, body: { code: "internal_error" } }) });
    expect(await screen.findByText(/Chưa đọc được hàng chờ/)).toBeTruthy();
    expect(screen.queryByText("Không có đơn chờ xác nhận.")).toBeNull();
  });

  it("tự kéo theo poll_interval_seconds backend trả", async () => {
    const goi = mo({ hang: () => ({ status: 200, body: { ...hangMau, poll_interval_seconds: 0.05 } }) });
    await waitFor(() => expect(docHang(goi)).toBeGreaterThanOrEqual(3), { timeout: 1500 });
  });

  it("tạm dừng và quán mù chỉ hiện theo backend; quán mù có nút mở lại nhận đơn", async () => {
    mo();
    await screen.findByRole("region", { name: "Đơn 41" });
    expect(screen.queryByText(/Đang tạm dừng nhận đơn/)).toBeNull();
    expect(screen.queryByText(/Quán đang không thấy đơn/)).toBeNull();
    expect(screen.queryByRole("button", { name: "Mở lại nhận đơn" })).toBeNull();
    cleanup();
    mo({ hang: () => ({ status: 200, body: { ...hangMau, paused_since: "2026-10-20T02:00:00Z", blind_since: "2026-10-20T02:01:00Z" } }) });
    expect(await screen.findByText(/Đang tạm dừng nhận đơn/)).toBeTruthy();
    expect(screen.getByText(/Quán đang không thấy đơn/)).toBeTruthy();
    expect(screen.getByRole("button", { name: "Mở lại nhận đơn" })).toBeTruthy();
  });

  it("đơn hẹn: bày theo backend, nói mốc nhắc đã tới", async () => {
    mo();
    const d50 = await screen.findByRole("region", { name: "Đơn hẹn 50" });
    const d51 = screen.getByRole("region", { name: "Đơn hẹn 51" });
    expect(d50.textContent).toMatch(/Chưa tới mốc nhắc/);
    expect(d51.textContent).toMatch(/Đã tới mốc nhắc 10 phút/);
  });
});

describe("hàng chờ quầy — duyệt, từ chối, mở lại", () => {
  it("duyệt: POST /orders/{id}/approval không thân; xong thì báo và đọc lại; bấm hai lần một lời gọi", async () => {
    let tra!: (v: TraLoi) => void;
    const goi = mo({ ghi: () => new Promise<TraLoi>((r) => { tra = r; }) });
    const d41 = await screen.findByRole("region", { name: "Đơn 41" });
    const nut = within(d41).getByRole("button", { name: "Duyệt đơn 41" });
    fireEvent.click(nut);
    fireEvent.click(nut);
    await waitFor(() => expect((nut as HTMLButtonElement).disabled).toBe(true));
    const truoc = docHang(goi);
    await act(async () => tra(xong));
    expect(await screen.findByText("Đã duyệt đơn 41.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([{ method: "POST", path: "/orders/41/approval", body: undefined }]);
    await waitFor(() => expect(docHang(goi)).toBeGreaterThan(truoc));
  });

  it("từ chối: hỏi lại trong hộp thoại; Huỷ không gửi; Từ chối gửi POST /orders/{id}/rejection rồi đọc lại", async () => {
    const goi = mo({ ghi: () => ({ status: 200, body: { ...xong.body, sales_order_id: 40, status: "rejected" } }) });
    const d40 = await screen.findByRole("region", { name: "Đơn 40" });
    fireEvent.click(within(d40).getByRole("button", { name: "Từ chối đơn 40" }));
    let hop = await screen.findByRole("dialog");
    fireEvent.click(within(hop).getByRole("button", { name: "Huỷ" }));
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    expect(ghiDi(goi)).toEqual([]);
    fireEvent.click(within(d40).getByRole("button", { name: "Từ chối đơn 40" }));
    hop = await screen.findByRole("dialog");
    fireEvent.click(within(hop).getByRole("button", { name: "Từ chối" }));
    expect(await screen.findByText("Đã từ chối đơn 40.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([{ method: "POST", path: "/orders/40/rejection", body: undefined }]);
  });

  it("đơn đã được xử lý nơi khác (409 order_transition_not_allowed): báo và đọc lại", async () => {
    const goi = mo({ ghi: () => ({ status: 409, body: { code: "order_transition_not_allowed", message: "x" } }) });
    const d41 = await screen.findByRole("region", { name: "Đơn 41" });
    const truoc = docHang(goi);
    fireEvent.click(within(d41).getByRole("button", { name: "Duyệt đơn 41" }));
    expect(await screen.findByText(/đã được xử lý/i)).toBeTruthy();
    await waitFor(() => expect(docHang(goi)).toBeGreaterThan(truoc));
  });

  it("không đứng quầy (403): báo theo code; mất phản hồi: chưa rõ kết quả, không gửi lại", async () => {
    mo({ ghi: () => ({ status: 403, body: { code: "not_on_counter_duty", message: "x" } }) });
    fireEvent.click(within(await screen.findByRole("region", { name: "Đơn 41" })).getByRole("button", { name: "Duyệt đơn 41" }));
    expect(await screen.findByText(/đứng quầy/i)).toBeTruthy();
    cleanup();
    const goi = mo({ ghi: () => "mat-mang" });
    fireEvent.click(within(await screen.findByRole("region", { name: "Đơn 41" })).getByRole("button", { name: "Duyệt đơn 41" }));
    expect(await screen.findByText(/Chưa xác nhận được kết quả/)).toBeTruthy();
    await new Promise((r) => setTimeout(r, 50));
    expect(ghiDi(goi)).toHaveLength(1);
  });

  it("mở lại nhận đơn khi quán mù: POST /shop-blind/reopening rồi đọc lại; shop_not_blind cũng đọc lại", async () => {
    const mu = { ...hangMau, blind_since: "2026-10-20T02:01:00Z" };
    let lanGhi = 0;
    const goi = mo({
      hang: () => ({ status: 200, body: mu }),
      ghi: () => (++lanGhi === 1 ? { status: 200, body: {} } : { status: 409, body: { code: "shop_not_blind", message: "x" } }),
    });
    const nut = await screen.findByRole("button", { name: "Mở lại nhận đơn" });
    const truoc = docHang(goi);
    fireEvent.click(nut);
    await waitFor(() => expect(ghiDi(goi)).toEqual([{ method: "POST", path: "/shop-blind/reopening", body: undefined }]));
    await waitFor(() => expect(docHang(goi)).toBeGreaterThan(truoc));
    const truoc2 = docHang(goi);
    fireEvent.click(await screen.findByRole("button", { name: "Mở lại nhận đơn" }));
    await waitFor(() => expect(docHang(goi)).toBeGreaterThan(truoc2));
  });
});

describe("máy quầy tự nhả đơn hẹn", () => {
  it("gọi POST /preorder-releases ngay và theo chu kỳ, thân {}", async () => {
    const b = backend();
    render(<ApiProvider fetch={b.fetch}><TuNhaDonHen chuKyMs={50} /></ApiProvider>);
    await waitFor(() => expect(b.goi.filter((g) => g.path === "/preorder-releases").length).toBeGreaterThanOrEqual(3), { timeout: 1500 });
    expect(b.goi.find((g) => g.path === "/preorder-releases")).toEqual({ method: "POST", path: "/preorder-releases", body: {} });
  });

  it("nhả lỗi: nói ra; lần sau được thì thôi báo", async () => {
    const b = backend({ nha: (lan) => (lan === 1 ? { status: 403, body: { code: "not_on_counter_duty", message: "x" } } : { status: 200, body: { released_order_ids: [50] } }) });
    render(<ApiProvider fetch={b.fetch}><TuNhaDonHen chuKyMs={80} /></ApiProvider>);
    expect(await screen.findByText(/Chưa nhả được đơn hẹn/)).toBeTruthy();
    await waitFor(() => expect(screen.queryByText(/Chưa nhả được đơn hẹn/)).toBeNull(), { timeout: 1500 });
  });

  it("khung quầy (layout) chạy việc tự nhả", async () => {
    const b = backend();
    render(<ApiProvider fetch={b.fetch}><QuayLayout><p>trang</p></QuayLayout></ApiProvider>);
    await screen.findByText("trang");
    await waitFor(() => expect(b.goi.some((g) => g.path === "/preorder-releases")).toBe(true));
  });
});
