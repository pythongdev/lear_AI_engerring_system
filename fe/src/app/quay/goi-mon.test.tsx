// Test hồi quy P4-07 (đợt hai: bày đơn, rời quán, soạn lượt gọi POS, đơn điện thoại) — Claude viết TRƯỚC khi có code (L2).
// Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm. Giữ (ADR-097, ADR-102 dòng Quầy, ADR-123 điểm 2, I-024):
// mọi số tiền là số backend trả (lines · total_vnd · menu.prices), màn chỉ định dạng `45.000đ`, không cộng; thân gửi không
// mang giá; lượt gọi và đơn điện thoại đặt submission_code một lần lúc bấm gửi, gửi lại sau mất phản hồi giữ nguyên dấu;
// lựa chọn mặc định (is_default) chọn sẵn nhưng option_ids gửi đầy đủ (ADR-094); rời quán chỉ cho đơn giao tận nơi
// đang làm; một lần bấm một lời gọi; lời từ chối theo code; mất phản hồi là chưa rõ kết quả. Giờ cần hàng đọc theo giờ quán
// (Asia/Ho_Chi_Minh). Combo ở bộ soạn để lượt sau.
import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import type { ReactNode } from "react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { ApiProvider } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";

import DienThoaiPage from "./dien-thoai/page";
import GoiMonPage from "./goi-mon/page";
import Page from "./page";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/quay",
  useSearchParams: () => new URLSearchParams(),
}));
afterEach(cleanup);

type CounterQueue = components["schemas"]["CounterQueue"];
type PriceLine = components["schemas"]["PriceLine"];
const dong = (ten: string, sl: number, thanh: number, luaChon: string[] = []): PriceLine => ({
  menu_item_id: 1, item_name: ten, quantity: sl, unit_price_vnd: 0, line_total_vnd: thanh, components: [],
  options: luaChon.map((o, i) => ({ menu_option_id: 100 + i, option_group_name: "Nhân", option_name: o, surcharge_vnd: 0 })),
});
// Tổng cố ý KHÁC tổng các dòng: màn phải bày total_vnd backend, không tự cộng.
const hangMau: CounterQueue = {
  read_at: "2026-10-20T02:15:00Z", poll_interval_seconds: 20, paused_since: null, blind_since: null,
  orders: [{ sales_order_id: 41, channel_code: "delivery", dining_table_id: null, created_at: "2026-10-20T02:10:00Z",
    customer_phone: "0901111111", customer_needed_at: null, total_vnd: 46000,
    lines: [dong("Bánh cuốn", 1, 35000, ["Thịt"]), dong("Canh", 1, 10000)] }],
  active_orders: [
    { sales_order_id: 60, channel_code: "delivery", handover_code: "door_delivery", status: "in_progress", created_at: "2026-10-20T01:50:00Z",
      customer_phone: "0903333333", customer_name: "Chị Hoa", delivery_address: "12 Ngõ Huế", customer_needed_at: null, contact_note: null,
      total_vnd: 70000, lines: [dong("Bánh cuốn", 2, 70000, ["Thịt"])], unserved_jobs: 0 },
    { sales_order_id: 61, channel_code: "pickup", handover_code: "shop_pickup", status: "in_progress", created_at: "2026-10-20T01:55:00Z",
      customer_phone: "0904444444", customer_name: null, delivery_address: null, customer_needed_at: null, contact_note: null,
      total_vnd: 30000, lines: [dong("Bánh cuốn", 1, 30000, ["Chay"])], unserved_jobs: 1 },
    { sales_order_id: 62, channel_code: "delivery", handover_code: "door_delivery", status: "delivering", created_at: "2026-10-20T01:40:00Z",
      customer_phone: "0905555555", customer_name: null, delivery_address: "3 Hàng Bông", customer_needed_at: null, contact_note: null,
      total_vnd: 35000, lines: [dong("Bánh cuốn", 1, 35000, ["Thịt"])], unserved_jobs: 0 },
  ],
};
const banMau = { tables: [
  { dining_table_id: 3, label: "Bàn 3", state: "in_session", table_session_id: 9, table_session_status: "open" },
  { dining_table_id: 4, label: "Bàn 4", state: "empty" },
] };
const menuMau = { combos: [], items: [
  { menu_item_id: 1, item_name: "Bánh cuốn", option_groups: [{ option_group_id: 5, option_group_name: "Nhân", prerequisite_option_ids: [], options: [
    { menu_option_id: 11, option_name: "Thịt", is_default: true }, { menu_option_id: 12, option_name: "Chay", is_default: false }] }],
    prices: [{ option_ids: [11], unit_price_vnd: 35000 }, { option_ids: [12], unit_price_vnd: 30000 }] },
  { menu_item_id: 2, item_name: "Canh", option_groups: [], prices: [{ option_ids: [], unit_price_vnd: 10000 }] },
] };
const henMau = { preorders: [] };

type Goi = { method: string; path: string; body: Record<string, unknown> | undefined };
type TraLoi = { status: number; body?: unknown } | "mat-mang";
function backend(ghi?: (g: Goi, lan: number) => TraLoi | Promise<TraLoi>) {
  const goi: Goi[] = [];
  let lan = 0;
  const fetch = async (req: Request) => {
    const text = await req.text();
    const g: Goi = { method: req.method, path: new URL(req.url).pathname.replace(/^\/api/, ""), body: text ? JSON.parse(text) : undefined };
    goi.push(g);
    let r: TraLoi = { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    if (g.path === "/counter/queue") r = { status: 200, body: hangMau };
    else if (g.path === "/dining-tables") r = { status: 200, body: banMau };
    else if (g.path === "/menu") r = { status: 200, body: menuMau };
    else if (g.path === "/preorder-reminders") r = { status: 200, body: henMau };
    else if (g.path === "/preorder-releases") r = { status: 200, body: { released_order_ids: [] } };
    else if (g.path === "/sessions/current") r = { status: 200, body: { person_id: 7, display_name: "Lan", role_code: "quay", is_owner: false, must_change_password: false, counter_duty_id: 3 } };
    else if (g.path.endsWith("/events")) return new Response(new ReadableStream(), { status: 200, headers: { "content-type": "text/event-stream" } });
    else if (g.method === "POST" && ghi) r = await ghi(g, ++lan);
    if (r === "mat-mang") throw new TypeError("fetch failed");
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  };
  return { fetch, goi };
}
function mo(trang: ReactNode, ghi?: Parameters<typeof backend>[0]) {
  const b = backend(ghi);
  render(<ApiProvider fetch={b.fetch}>{trang}</ApiProvider>);
  return b.goi;
}
const ghiDi = (g: Goi[]) => g.filter((x) => x.method === "POST" && x.path !== "/preorder-releases");
const docHang = (g: Goi[]) => g.filter((x) => x.path === "/counter/queue").length;
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
// So chuỗi, không dùng regex: check-fe-rules đọc `|` trong regex literal là phép tính với tên tiền.
const coGia = (body: unknown) => ["price", "total", "vnd"].some((w) => JSON.stringify(body).includes(w));
const luotXong = { status: 201, body: { sales_order_id: 70, table_session_id: 9, dining_table_id: 3, channel_code: "staff_pos", status: "in_progress",
  total_vnd: 71000, lines: [dong("Bánh cuốn", 2, 71000, ["Chay"])] } };

async function themBanhCuonChay() {
  fireEvent.click(await screen.findByRole("button", { name: "Thêm Bánh cuốn" }));
  const d = await screen.findByRole("region", { name: "Dòng 1" });
  expect((within(d).getByRole("radio", { name: "Thịt" }) as HTMLInputElement).checked).toBe(true);
  expect(d.textContent).toContain("35.000đ");
  fireEvent.click(within(d).getByRole("radio", { name: "Chay" }));
  await waitFor(() => expect(d.textContent).toContain("30.000đ"));
  fireEvent.change(within(d).getByRole("spinbutton", { name: "Số lượng" }), { target: { value: "2" } });
  return d;
}

describe("hàng chờ quầy — bày đơn và rời quán", () => {
  it("đơn chờ bày từng dòng món, lựa chọn, số lượng, thành tiền và tổng backend", async () => {
    mo(<Page />);
    const d41 = await screen.findByRole("region", { name: "Đơn 41" });
    expect(d41.textContent).toMatch(/Bánh cuốn/);
    expect(d41.textContent).toMatch(/Thịt/);
    expect(d41.textContent).toMatch(/Canh/);
    expect(d41.textContent).toContain("35.000đ");
    expect(d41.textContent).toContain("10.000đ");
    expect(d41.textContent).toContain("46.000đ");
    expect(d41.textContent).not.toContain("45.000đ");
  });

  it("đơn đang làm: bày cách trao, liên hệ, tiền; chỉ đơn giao tận nơi đang làm có nút rời quán", async () => {
    mo(<Page />);
    const d60 = await screen.findByRole("region", { name: "Đơn đang làm 60" });
    const d61 = screen.getByRole("region", { name: "Đơn đang làm 61" });
    const d62 = screen.getByRole("region", { name: "Đơn đang làm 62" });
    expect(d60.textContent).toMatch(/Giao tận nơi/);
    expect(d60.textContent).toContain("12 Ngõ Huế");
    expect(d60.textContent).toContain("0903333333");
    expect(d60.textContent).toContain("70.000đ");
    expect(d61.textContent).toMatch(/Khách tự đến lấy/);
    expect(d61.textContent).toMatch(/1 việc chưa ra bàn/);
    expect(within(d60).getByRole("button", { name: "Rời quán đơn 60" })).toBeTruthy();
    expect(within(d61).queryByRole("button", { name: /Rời quán/ })).toBeNull();
    expect(within(d62).queryByRole("button", { name: /Rời quán/ })).toBeNull();
    expect(d62.textContent).toMatch(/Đang giao/);
  });

  it("rời quán: POST /orders/{id}/departure không thân; xong thì báo và đọc lại; bấm hai lần một lời gọi", async () => {
    let tra!: (v: TraLoi) => void;
    const goi = mo(<Page />, () => new Promise<TraLoi>((r) => { tra = r; }));
    const nut = within(await screen.findByRole("region", { name: "Đơn đang làm 60" })).getByRole("button", { name: "Rời quán đơn 60" });
    fireEvent.click(nut);
    fireEvent.click(nut);
    await waitFor(() => expect((nut as HTMLButtonElement).disabled).toBe(true));
    const truoc = docHang(goi);
    await act(async () => tra({ status: 200, body: { sales_order_id: 60, status: "delivering", table_session_id: null, table_session_status: null } }));
    expect(await screen.findByText("Đơn 60 đã rời quán.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([{ method: "POST", path: "/orders/60/departure", body: undefined }]);
    await waitFor(() => expect(docHang(goi)).toBeGreaterThan(truoc));
  });

  it("rời quán bị từ chối vì còn việc chưa ra bàn (409 order_jobs_not_served): nói rõ rồi đọc lại", async () => {
    const goi = mo(<Page />, () => ({ status: 409, body: { code: "order_jobs_not_served", message: "x" } }));
    const d60 = await screen.findByRole("region", { name: "Đơn đang làm 60" });
    const truoc = docHang(goi);
    fireEvent.click(within(d60).getByRole("button", { name: "Rời quán đơn 60" }));
    expect(await screen.findByText(/còn món chưa ra bàn/i)).toBeTruthy();
    await waitFor(() => expect(docHang(goi)).toBeGreaterThan(truoc));
  });

  it("rời quán bị chặn vì S-6 chưa có lời (409 delivery_served_mark_undecided): nói rõ, không in mã trơ", async () => {
    mo(<Page />, () => ({ status: 409, body: { code: "delivery_served_mark_undecided", message: "x" } }));
    fireEvent.click(within(await screen.findByRole("region", { name: "Đơn đang làm 60" })).getByRole("button", { name: "Rời quán đơn 60" }));
    expect(await screen.findByText(/chưa chốt lúc nào ghi món đã ra/i)).toBeTruthy();
    expect(screen.queryByText(/Mã: delivery_served_mark_undecided/)).toBeNull();
  });

  it("/quay có lối vào soạn lượt gọi và đơn điện thoại", async () => {
    mo(<Page />);
    expect((await screen.findByRole("link", { name: "Gọi món tại bàn" })).getAttribute("href")).toBe("/quay/goi-mon");
    expect(screen.getByRole("link", { name: "Đơn điện thoại" }).getAttribute("href")).toBe("/quay/dien-thoai");
  });
});

describe("soạn lượt gọi tại bàn (POS)", () => {
  it("chưa chọn bàn hay chưa có dòng thì không gửi được", async () => {
    mo(<GoiMonPage />);
    const gui = await screen.findByRole("button", { name: "Gửi lượt gọi" });
    expect((gui as HTMLButtonElement).disabled).toBe(true);
    fireEvent.change(await screen.findByRole("combobox", { name: "Bàn" }), { target: { value: "3" } });
    expect((gui as HTMLButtonElement).disabled).toBe(true);
    fireEvent.click(await screen.findByRole("button", { name: "Thêm Canh" }));
    await waitFor(() => expect((gui as HTMLButtonElement).disabled).toBe(false));
  });

  it("gửi POST /table-orders đúng thân: dấu lần gửi, bàn, dòng có option_ids đầy đủ, mang về; không giá", async () => {
    const goi = mo(<GoiMonPage />, () => luotXong);
    fireEvent.change(await screen.findByRole("combobox", { name: "Bàn" }), { target: { value: "3" } });
    const d1 = await themBanhCuonChay();
    fireEvent.click(within(d1).getByRole("checkbox", { name: "Mang về" }));
    fireEvent.click(screen.getByRole("button", { name: "Thêm Canh" }));
    fireEvent.click(screen.getByRole("button", { name: "Gửi lượt gọi" }));
    await waitFor(() => expect(ghiDi(goi)).toHaveLength(1));
    const [g] = ghiDi(goi);
    expect(g.path).toBe("/table-orders");
    expect(g.body?.submission_code).toMatch(UUID);
    expect(g.body).toEqual({ submission_code: g.body?.submission_code, dining_table_id: 3, lines: [
      { menu_item_id: 1, quantity: 2, option_ids: [12], is_takeaway: true },
      { menu_item_id: 2, quantity: 1, option_ids: [], is_takeaway: false },
    ] });
    expect(coGia(g.body)).toBe(false);
  });

  it("xong: báo tổng backend, soạn trống lại; lượt sau mang dấu lần gửi mới", async () => {
    const goi = mo(<GoiMonPage />, () => luotXong);
    fireEvent.change(await screen.findByRole("combobox", { name: "Bàn" }), { target: { value: "3" } });
    await themBanhCuonChay();
    fireEvent.click(screen.getByRole("button", { name: "Gửi lượt gọi" }));
    expect(await screen.findByText("Đã gửi lượt gọi Bàn 3 · tổng 71.000đ")).toBeTruthy();
    expect(screen.queryByRole("region", { name: "Dòng 1" })).toBeNull();
    fireEvent.click(screen.getByRole("button", { name: "Thêm Canh" }));
    fireEvent.click(screen.getByRole("button", { name: "Gửi lượt gọi" }));
    await waitFor(() => expect(ghiDi(goi)).toHaveLength(2));
    expect(ghiDi(goi)[1].body?.submission_code).not.toBe(ghiDi(goi)[0].body?.submission_code);
  });

  it("mất phản hồi: chưa rõ kết quả, không tự gửi lại; Gửi lại giữ nguyên dấu lần gửi; bấm hai lần một lời gọi", async () => {
    let tra!: (v: TraLoi) => void;
    const goi = mo(<GoiMonPage />, (_g, lan) => (lan === 1 ? "mat-mang" : new Promise<TraLoi>((r) => { tra = r; })));
    fireEvent.change(await screen.findByRole("combobox", { name: "Bàn" }), { target: { value: "3" } });
    fireEvent.click(await screen.findByRole("button", { name: "Thêm Canh" }));
    fireEvent.click(screen.getByRole("button", { name: "Gửi lượt gọi" }));
    expect(await screen.findByText(/Chưa xác nhận được kết quả/)).toBeTruthy();
    await new Promise((r) => setTimeout(r, 50));
    expect(ghiDi(goi)).toHaveLength(1);
    const lai = screen.getByRole("button", { name: "Gửi lại" });
    fireEvent.click(lai);
    fireEvent.click(lai);
    await waitFor(() => expect(ghiDi(goi)).toHaveLength(2));
    await act(async () => tra({ ...luotXong, status: 200 }));
    expect(await screen.findByText(/Đã gửi lượt gọi Bàn 3/)).toBeTruthy();
    expect(ghiDi(goi)).toHaveLength(2);
    expect(ghiDi(goi)[1].body?.submission_code).toBe(ghiDi(goi)[0].body?.submission_code);
  });

  it("lời từ chối theo code: bàn chờ dọn, món ngừng bán, không đứng quầy", async () => {
    const ca: [string, number, RegExp][] = [
      ["dining_table_needs_cleaning", 409, /chờ dọn/i],
      ["menu_item_discontinued", 409, /ngừng bán/i],
      ["not_on_counter_duty", 403, /đứng quầy/i],
    ];
    for (const [code, status, chu] of ca) {
      mo(<GoiMonPage />, () => ({ status, body: { code, message: "x" } }));
      fireEvent.change(await screen.findByRole("combobox", { name: "Bàn" }), { target: { value: "3" } });
      fireEvent.click(await screen.findByRole("button", { name: "Thêm Canh" }));
      fireEvent.click(screen.getByRole("button", { name: "Gửi lượt gọi" }));
      expect(await screen.findByText(chu)).toBeTruthy();
      expect(screen.getByRole("region", { name: "Dòng 1" })).toBeTruthy();
      cleanup();
    }
  });
});

describe("đơn điện thoại", () => {
  async function dien(cach: "Giao tận nơi" | "Khách tự đến lấy") {
    fireEvent.click(await screen.findByRole("radio", { name: cach }));
    fireEvent.change(screen.getByRole("textbox", { name: "Số điện thoại" }), { target: { value: "0907777777" } });
    fireEvent.change(screen.getByLabelText("Giờ cần hàng"), { target: { value: "2026-10-20T11:30" } });
    fireEvent.click(await screen.findByRole("button", { name: "Thêm Canh" }));
  }

  it("giao tận nơi: thiếu địa chỉ thì không gửi; đủ thì POST /phone-orders đúng thân, giờ theo giờ quán, không bàn, không giá", async () => {
    const goi = mo(<DienThoaiPage />, () => ({ status: 201, body: { sales_order_id: 77, channel_code: "phone_preorder", handover_code: "door_delivery",
      status: "confirmed", total_vnd: 10000, lines: [dong("Canh", 1, 10000)], customer_phone: "0907777777", delivery_address: "5 Lò Sũ",
      customer_needed_at: "2026-10-20T04:30:00Z", customer_name: "Anh Nam", contact_note: null } }));
    await dien("Giao tận nơi");
    const gui = screen.getByRole("button", { name: "Gửi đơn điện thoại" });
    expect((gui as HTMLButtonElement).disabled).toBe(true);
    fireEvent.change(screen.getByRole("textbox", { name: "Địa chỉ giao" }), { target: { value: "5 Lò Sũ" } });
    fireEvent.change(screen.getByRole("textbox", { name: "Tên khách" }), { target: { value: "Anh Nam" } });
    await waitFor(() => expect((gui as HTMLButtonElement).disabled).toBe(false));
    fireEvent.click(gui);
    expect(await screen.findByText("Đã tạo đơn 77 · tổng 10.000đ")).toBeTruthy();
    const [g] = ghiDi(goi);
    expect(g.path).toBe("/phone-orders");
    expect(g.body?.submission_code).toMatch(UUID);
    expect(g.body).toMatchObject({ handover_code: "door_delivery", customer_phone: "0907777777", delivery_address: "5 Lò Sũ", customer_name: "Anh Nam",
      lines: [{ menu_item_id: 2, quantity: 1, option_ids: [] }] });
    expect(Date.parse(String(g.body?.customer_needed_at))).toBe(Date.parse("2026-10-20T11:30:00+07:00"));
    expect(g.body && "dining_table_id" in g.body).toBe(false);
    expect(g.body && "table_session_id" in g.body).toBe(false);
    expect(JSON.stringify(g.body?.lines)).not.toMatch(/is_takeaway/);
    expect(coGia(g.body)).toBe(false);
  });

  it("khách tự đến lấy: không ô địa chỉ, gửi được; ngoài giờ bán (outside_selling_hours) nói rõ, giữ nguyên phiếu", async () => {
    const goi = mo(<DienThoaiPage />, () => ({ status: 409, body: { code: "outside_selling_hours", message: "x" } }));
    await dien("Khách tự đến lấy");
    expect(screen.queryByRole("textbox", { name: "Địa chỉ giao" })).toBeNull();
    fireEvent.click(screen.getByRole("button", { name: "Gửi đơn điện thoại" }));
    expect(await screen.findByText(/ngoài giờ bán/i)).toBeTruthy();
    expect(ghiDi(goi)[0].body).toMatchObject({ handover_code: "shop_pickup" });
    expect(ghiDi(goi)[0].body?.delivery_address ?? null).toBeNull();
    expect((screen.getByRole("textbox", { name: "Số điện thoại" }) as HTMLInputElement).value).toBe("0907777777");
  });
});
