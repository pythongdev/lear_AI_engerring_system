// Test hồi quy T-221 (bộ soạn món: lựa chọn phụ thuộc và combo) — Claude viết TRƯỚC khi có code (L1).
// Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm. Giữ (ADR-094, ADR-102 điểm 3, ADR-117 điểm 4 · 5, 03-ham-gia.md §1 · §1.1):
// nhóm có điều kiện chỉ có mặt khi một lựa chọn trong tập điều kiện được chọn — vắng thì không gửi mã nào của nó, có mặt lại thì
// chọn sẵn is_default; mỗi suất của combo chọn nhân riêng (shop-facts §8.9 lượt tám); giá dòng combo là số POST /price-quotes
// trả, màn không cộng price_vnd với mức phụ thu; dòng món vẫn lấy giá ở menu.prices, không gọi tính thử; thân gửi không giá.
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
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

type PriceLine = components["schemas"]["PriceLine"];
const nhom = (id: number, ten: string, dieuKien: number[], opts: [number, string, boolean][]) => ({
  option_group_id: id, option_group_name: ten, prerequisite_option_ids: dieuKien,
  options: opts.map(([menu_option_id, option_name, is_default]) => ({ menu_option_id, option_name, is_default })),
});
// Bánh cuốn: *Lượng nhân* chỉ có khi nhân là Thịt (03-ham-gia.md §1 — đọc theo tập).
const nhomBanhCuon = [
  nhom(5, "Nhân", [], [[11, "Thịt", true], [12, "Chay", false]]),
  nhom(6, "Lượng nhân", [11], [[21, "Thường", true], [22, "Nhiều", false]]),
];
const menuMau = {
  items: [
    { menu_item_id: 1, item_name: "Bánh cuốn", option_groups: nhomBanhCuon, prices: [
      { option_ids: [11, 21], unit_price_vnd: 35000 }, { option_ids: [11, 22], unit_price_vnd: 40000 }, { option_ids: [12], unit_price_vnd: 30000 }] },
    { menu_item_id: 2, item_name: "Canh", option_groups: [], prices: [{ option_ids: [], unit_price_vnd: 10000 }] },
    // Nhóm có điều kiện mà không lựa chọn nào là mặc định: hiện ra thì người soạn phải tự chọn.
    { menu_item_id: 4, item_name: "Bánh đặc biệt", option_groups: [
      nhom(7, "Kiểu", [], [[31, "Cuốn", true], [32, "Lá", false]]),
      nhom(8, "Nước chấm", [32], [[41, "Nước mắm", false], [42, "Nước tương", false]]),
    ], prices: [{ option_ids: [31], unit_price_vnd: 20000 }, { option_ids: [32, 41], unit_price_vnd: 22000 }, { option_ids: [32, 42], unit_price_vnd: 22000 }] },
  ],
  combos: [{ menu_combo_id: 9, name: "Combo Đầy đủ", price_vnd: 50000, items: [
    { menu_item_id: 1, item_name: "Bánh cuốn", quantity: 2, option_groups: nhomBanhCuon, surcharges: [{ menu_option_id: 22, surcharge_vnd: 5000 }] },
    { menu_item_id: 2, item_name: "Canh", quantity: 1, option_groups: [], surcharges: [] },
  ] }],
};
const banMau = { tables: [{ dining_table_id: 3, label: "Bàn 3", state: "empty" }] };
const dongCombo = (thanh: number): PriceLine => ({
  menu_combo_id: 9, item_name: "Combo Đầy đủ", quantity: 1, unit_price_vnd: 50000, line_total_vnd: thanh, components: [], options: [],
  portions: [
    { menu_item_id: 1, item_name: "Bánh cuốn", quantity: 2, unit_price_vnd: 0, line_total_vnd: 0, components: [], options: [
      { menu_option_id: 11, option_group_name: "Nhân", option_name: "Thịt", surcharge_vnd: 0 },
      { menu_option_id: 21, option_group_name: "Lượng nhân", option_name: "Thường", surcharge_vnd: 0 }] },
    { menu_item_id: 2, item_name: "Canh", quantity: 1, unit_price_vnd: 0, line_total_vnd: 0, components: [], options: [] },
  ],
});
// Số cố ý KHÁC price_vnd (50.000đ) và khác mọi phép cộng với mức phụ thu: màn phải bày đúng số tính thử trả.
const baoGia = (thanh: number) => ({ status: 200, body: { lines: [dongCombo(thanh)], total_vnd: thanh } });

type Goi = { method: string; path: string; body: Record<string, unknown> | undefined };
type TraLoi = { status: number; body?: unknown } | "mat-mang";
type Ghi = (g: Goi, lan: number) => TraLoi | Promise<TraLoi>;
function backend(tinhThu?: Ghi, gui?: Ghi, hang?: unknown) {
  const goi: Goi[] = [];
  let lanTinh = 0;
  let lanGui = 0;
  const fetch = async (req: Request) => {
    const text = await req.text();
    const g: Goi = { method: req.method, path: new URL(req.url).pathname.replace(/^\/api/, ""), body: text ? JSON.parse(text) : undefined };
    goi.push(g);
    let r: TraLoi = { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    if (g.path === "/counter/queue") r = { status: 200, body: hang ?? { read_at: "2026-10-21T02:15:00Z", poll_interval_seconds: 20, paused_since: null, blind_since: null, orders: [], active_orders: [] } };
    else if (g.path === "/dining-tables") r = { status: 200, body: banMau };
    else if (g.path === "/menu") r = { status: 200, body: menuMau };
    else if (g.path === "/preorder-reminders") r = { status: 200, body: { preorders: [] } };
    else if (g.path === "/preorder-releases") r = { status: 200, body: { released_order_ids: [] } };
    else if (g.path === "/sessions/current") r = { status: 200, body: { person_id: 7, display_name: "Lan", role_code: "quay", is_owner: false, must_change_password: false, counter_duty_id: 3 } };
    else if (g.path.endsWith("/events")) return new Response(new ReadableStream(), { status: 200, headers: { "content-type": "text/event-stream" } });
    else if (g.path === "/price-quotes") r = await (tinhThu ?? (() => baoGia(61000)))(g, ++lanTinh);
    else if (g.method === "POST" && gui) r = await gui(g, ++lanGui);
    if (r === "mat-mang") throw new TypeError("fetch failed");
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  };
  return { fetch, goi };
}
function mo(trang: ReactNode, tinhThu?: Ghi, gui?: Ghi, hang?: unknown) {
  const b = backend(tinhThu, gui, hang);
  render(<ApiProvider fetch={b.fetch}>{trang}</ApiProvider>);
  return b.goi;
}
const guiDi = (g: Goi[]) => g.filter((x) => x.method === "POST" && x.path !== "/preorder-releases" && x.path !== "/price-quotes");
const tinhThuDi = (g: Goi[]) => g.filter((x) => x.path === "/price-quotes");
// So chuỗi, không dùng regex: check-fe-rules đọc `|` trong regex literal là phép tính với tên tiền.
const coGia = (body: unknown) => ["price", "total", "vnd", "surcharge"].some((w) => JSON.stringify(body).includes(w));
const sx = (ids: unknown) => [...(ids as number[])].sort((a, b) => a - b);
// Thứ tự mã trong option_ids và thứ tự các suất không phải điều kiện kiểm; số suất của mỗi tổ hợp thì là.
type Suat = { menu_item_id: number; quantity: number; option_ids: number[] };
const chuan = (portions: unknown) => (portions as Suat[])
  .map((p) => ({ menu_item_id: p.menu_item_id, quantity: p.quantity, option_ids: sx(p.option_ids) }))
  .sort((a, b) => a.menu_item_id - b.menu_item_id || JSON.stringify(a.option_ids).localeCompare(JSON.stringify(b.option_ids)));
const luotXong = { status: 201, body: { sales_order_id: 70, table_session_id: 9, dining_table_id: 3, channel_code: "staff_pos", status: "in_progress",
  total_vnd: 61000, lines: [dongCombo(61000)] } };
const nutGui = () => screen.getByRole("button", { name: "Gửi lượt gọi" }) as HTMLButtonElement;
async function chonBan() {
  fireEvent.change(await screen.findByRole("combobox", { name: "Bàn" }), { target: { value: "3" } });
}
async function themCombo() {
  fireEvent.click(await screen.findByRole("button", { name: "Thêm combo Combo Đầy đủ" }));
  return screen.findByRole("region", { name: "Dòng 1" });
}

describe("lựa chọn phụ thuộc (prerequisite_option_ids)", () => {
  it("nhóm có điều kiện chỉ hiện khi điều kiện được chọn; vắng thì không gửi mã của nó; hiện lại thì chọn sẵn mặc định; không gọi tính thử", async () => {
    const goi = mo(<GoiMonPage />, undefined, () => luotXong);
    await chonBan();
    fireEvent.click(await screen.findByRole("button", { name: "Thêm Bánh cuốn" }));
    const d = await screen.findByRole("region", { name: "Dòng 1" });
    const luong = () => within(d).queryByRole("group", { name: "Lượng nhân" });
    expect(luong()).toBeTruthy();
    expect((within(luong()!).getByRole("radio", { name: "Thường" }) as HTMLInputElement).checked).toBe(true);
    expect(d.textContent).toContain("35.000đ");

    fireEvent.click(within(d).getByRole("radio", { name: "Chay" }));
    await waitFor(() => expect(luong()).toBeNull());
    expect(d.textContent).toContain("30.000đ");

    fireEvent.click(within(d).getByRole("radio", { name: "Thịt" }));
    await waitFor(() => expect(luong()).toBeTruthy());
    expect((within(luong()!).getByRole("radio", { name: "Thường" }) as HTMLInputElement).checked).toBe(true);
    fireEvent.click(within(luong()!).getByRole("radio", { name: "Nhiều" }));
    await waitFor(() => expect(d.textContent).toContain("40.000đ"));

    fireEvent.click(within(d).getByRole("radio", { name: "Chay" }));
    await waitFor(() => expect(nutGui().disabled).toBe(false));
    fireEvent.click(nutGui());
    await waitFor(() => expect(guiDi(goi)).toHaveLength(1));
    const lines = guiDi(goi)[0].body?.lines as { option_ids: number[] }[];
    expect(sx(lines[0].option_ids)).toEqual([12]);
    expect(tinhThuDi(goi)).toHaveLength(0);
  });

  it("nhóm có điều kiện không có mặc định: hiện ra chưa chọn gì, chưa gửi được tới khi chọn", async () => {
    const goi = mo(<GoiMonPage />, undefined, () => luotXong);
    await chonBan();
    fireEvent.click(await screen.findByRole("button", { name: "Thêm Bánh đặc biệt" }));
    const d = await screen.findByRole("region", { name: "Dòng 1" });
    expect(within(d).queryByRole("group", { name: "Nước chấm" })).toBeNull();
    await waitFor(() => expect(nutGui().disabled).toBe(false));

    fireEvent.click(within(d).getByRole("radio", { name: "Lá" }));
    const nuoc = await within(d).findByRole("group", { name: "Nước chấm" });
    expect(within(nuoc).getAllByRole("radio").some((r) => (r as HTMLInputElement).checked)).toBe(false);
    await waitFor(() => expect(nutGui().disabled).toBe(true));

    fireEvent.click(within(nuoc).getByRole("radio", { name: "Nước tương" }));
    await waitFor(() => expect(nutGui().disabled).toBe(false));
    expect(d.textContent).toContain("22.000đ");
    fireEvent.click(nutGui());
    await waitFor(() => expect(guiDi(goi)).toHaveLength(1));
    expect(sx((guiDi(goi)[0].body?.lines as { option_ids: number[] }[])[0].option_ids)).toEqual([32, 42]);
  });
});

describe("combo ở bộ soạn", () => {
  it("thêm combo: mỗi suất một nhóm chọn riêng, chọn sẵn mặc định; số combo nhân số suất", async () => {
    mo(<GoiMonPage />);
    const d = await themCombo();
    expect(d.textContent).toContain("Combo Đầy đủ");
    const suat1 = within(d).getByRole("group", { name: "Bánh cuốn suất 1" });
    expect(within(d).getByRole("group", { name: "Bánh cuốn suất 2" })).toBeTruthy();
    expect(within(d).getByRole("group", { name: "Canh suất 1" })).toBeTruthy();
    expect(within(d).queryByRole("group", { name: "Bánh cuốn suất 3" })).toBeNull();
    expect((within(suat1).getByRole("radio", { name: "Thịt" }) as HTMLInputElement).checked).toBe(true);
    expect((within(suat1).getByRole("radio", { name: "Thường" }) as HTMLInputElement).checked).toBe(true);

    fireEvent.change(within(d).getByRole("spinbutton", { name: "Số lượng" }), { target: { value: "2" } });
    expect(await within(d).findByRole("group", { name: "Bánh cuốn suất 4" })).toBeTruthy();
    expect(within(d).getByRole("group", { name: "Canh suất 2" })).toBeTruthy();
    expect(within(d).queryByRole("group", { name: "Bánh cuốn suất 5" })).toBeNull();

    fireEvent.change(within(d).getByRole("spinbutton", { name: "Số lượng" }), { target: { value: "1" } });
    await waitFor(() => expect(within(d).queryByRole("group", { name: "Bánh cuốn suất 3" })).toBeNull());
  });

  it("mỗi suất theo luật nhóm có điều kiện riêng của nó", async () => {
    mo(<GoiMonPage />);
    const d = await themCombo();
    const suat2 = within(d).getByRole("group", { name: "Bánh cuốn suất 2" });
    fireEvent.click(within(suat2).getByRole("radio", { name: "Chay" }));
    await waitFor(() => expect(within(suat2).queryByRole("radio", { name: "Thường" })).toBeNull());
    const suat1 = within(d).getByRole("group", { name: "Bánh cuốn suất 1" });
    expect((within(suat1).getByRole("radio", { name: "Thường" }) as HTMLInputElement).checked).toBe(true);
  });

  it("giá dòng combo là số POST /price-quotes trả; thân tính thử không giá, gom suất cùng tổ hợp, đổi suất thì tính lại", async () => {
    const goi = mo(<GoiMonPage />, (_g, lan) => baoGia(lan === 1 ? 61000 : 66000));
    const d = await themCombo();
    await waitFor(() => expect(d.textContent).toContain("61.000đ"));
    const dau = tinhThuDi(goi)[0].body?.lines as Record<string, unknown>[];
    expect(dau).toHaveLength(1);
    expect(dau[0].menu_combo_id).toBe(9);
    expect(dau[0].quantity).toBe(1);
    expect("menu_item_id" in dau[0]).toBe(false);
    expect("option_ids" in dau[0]).toBe(false);
    expect(chuan(dau[0].portions)).toEqual([
      { menu_item_id: 1, quantity: 2, option_ids: [11, 21] },
      { menu_item_id: 2, quantity: 1, option_ids: [] },
    ]);
    expect(coGia(tinhThuDi(goi)[0].body)).toBe(false);

    const suat2 = within(d).getByRole("group", { name: "Bánh cuốn suất 2" });
    fireEvent.click(within(suat2).getByRole("radio", { name: "Nhiều" }));
    await waitFor(() => expect(d.textContent).toContain("66.000đ"));
    const sau = tinhThuDi(goi).at(-1)!.body?.lines as Record<string, unknown>[];
    expect(chuan(sau[0].portions)).toEqual([
      { menu_item_id: 1, quantity: 1, option_ids: [11, 21] },
      { menu_item_id: 1, quantity: 1, option_ids: [11, 22] },
      { menu_item_id: 2, quantity: 1, option_ids: [] },
    ]);
  });

  it("gửi lượt gọi có combo: dòng combo chỉ mang menu_combo_id, quantity, portions, is_takeaway; không mã món, không giá", async () => {
    const goi = mo(<GoiMonPage />, undefined, () => luotXong);
    await chonBan();
    const d = await themCombo();
    await waitFor(() => expect(d.textContent).toContain("61.000đ"));
    fireEvent.click(within(d).getByRole("checkbox", { name: "Mang về" }));
    fireEvent.click(screen.getByRole("button", { name: "Thêm Canh" }));
    await waitFor(() => expect(nutGui().disabled).toBe(false));
    fireEvent.click(nutGui());
    expect(await screen.findByText("Đã gửi lượt gọi Bàn 3 · tổng 61.000đ")).toBeTruthy();
    const [g] = guiDi(goi);
    expect(g.path).toBe("/table-orders");
    const lines = g.body?.lines as Record<string, unknown>[];
    expect(Object.keys(lines[0]).sort()).toEqual(["is_takeaway", "menu_combo_id", "portions", "quantity"]);
    expect(lines[0]).toMatchObject({ menu_combo_id: 9, quantity: 1, is_takeaway: true });
    expect(chuan(lines[0].portions)).toEqual([
      { menu_item_id: 1, quantity: 2, option_ids: [11, 21] },
      { menu_item_id: 2, quantity: 1, option_ids: [] },
    ]);
    expect(lines[1]).toEqual({ menu_item_id: 2, quantity: 1, option_ids: [], is_takeaway: false });
    expect(coGia(g.body)).toBe(false);
  });

  it("đơn điện thoại có combo: dòng combo không mang is_takeaway", async () => {
    const goi = mo(<DienThoaiPage />, undefined, () => ({ status: 201, body: { sales_order_id: 77, channel_code: "phone_preorder", handover_code: "shop_pickup",
      status: "confirmed", total_vnd: 61000, lines: [dongCombo(61000)], customer_phone: "0907777777", delivery_address: null,
      customer_needed_at: "2026-10-21T04:30:00Z", customer_name: null, contact_note: null } }));
    fireEvent.click(await screen.findByRole("radio", { name: "Khách tự đến lấy" }));
    fireEvent.change(screen.getByRole("textbox", { name: "Số điện thoại" }), { target: { value: "0907777777" } });
    fireEvent.change(screen.getByLabelText("Giờ cần hàng"), { target: { value: "2026-10-21T11:30" } });
    const d = await themCombo();
    await waitFor(() => expect(d.textContent).toContain("61.000đ"));
    const nut = screen.getByRole("button", { name: "Gửi đơn điện thoại" }) as HTMLButtonElement;
    await waitFor(() => expect(nut.disabled).toBe(false));
    fireEvent.click(nut);
    expect(await screen.findByText("Đã tạo đơn 77 · tổng 61.000đ")).toBeTruthy();
    const lines = guiDi(goi)[0].body?.lines as Record<string, unknown>[];
    expect(Object.keys(lines[0]).sort()).toEqual(["menu_combo_id", "portions", "quantity"]);
  });

  it("tính thử bị từ chối (409 menu_combo_hidden): nói rõ, chưa gửi được", async () => {
    mo(<GoiMonPage />, () => ({ status: 409, body: { code: "menu_combo_hidden", message: "x" } }));
    await chonBan();
    const d = await themCombo();
    expect(await within(d).findByText(/Combo đã ẩn/i)).toBeTruthy();
    expect(nutGui().disabled).toBe(true);
  });

  it("tính thử mất phản hồi: chưa có giá, chưa gửi được", async () => {
    mo(<GoiMonPage />, () => "mat-mang");
    await chonBan();
    const d = await themCombo();
    expect(await within(d).findByText(/Chưa tính được giá/i)).toBeTruthy();
    expect(nutGui().disabled).toBe(true);
  });

  it("gửi bị từ chối theo code combo: nói rõ, giữ nguyên phiếu", async () => {
    const ca: [string, number, RegExp][] = [
      ["menu_combo_hidden", 409, /Combo đã ẩn/i],
      ["menu_combo_not_found", 404, /Không tìm thấy combo/i],
      ["combo_portions_mismatch", 422, /suất.*không khớp/i],
      ["menu_option_hidden", 409, /lựa chọn đã ẩn/i],
    ];
    for (const [code, status, chu] of ca) {
      mo(<GoiMonPage />, undefined, () => ({ status, body: { code, message: "x" } }));
      await chonBan();
      const d = await themCombo();
      await waitFor(() => expect(d.textContent).toContain("61.000đ"));
      await waitFor(() => expect(nutGui().disabled).toBe(false));
      fireEvent.click(nutGui());
      expect(await screen.findByText(chu)).toBeTruthy();
      expect(screen.getByRole("region", { name: "Dòng 1" })).toBeTruthy();
      cleanup();
    }
  });
});

describe("hàng chờ bày dòng combo", () => {
  it("dòng combo kèm từng suất: tên món, lựa chọn, số suất", async () => {
    mo(<Page />, undefined, undefined, {
      read_at: "2026-10-21T02:15:00Z", poll_interval_seconds: 20, paused_since: null, blind_since: null, active_orders: [],
      orders: [{ sales_order_id: 41, channel_code: "delivery", dining_table_id: null, created_at: "2026-10-21T02:10:00Z",
        customer_phone: "0901111111", customer_needed_at: null, total_vnd: 61000, lines: [dongCombo(61000)] }],
    });
    const d41 = await screen.findByRole("region", { name: "Đơn 41" });
    expect(d41.textContent).toContain("Combo Đầy đủ");
    expect(d41.textContent).toContain("61.000đ");
    expect(d41.textContent).toContain("Bánh cuốn");
    expect(d41.textContent).toContain("Thường");
    expect(d41.textContent).toContain("Canh");
  });
});
