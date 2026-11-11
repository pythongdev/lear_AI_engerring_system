import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import { cotVanHanh, type ThuVanHanh } from "../_components/cot-van-hanh";
import type { BangVanHanh, HangChoChuQuan } from "../_components/du-lieu-van-hanh";
import Page, { metadata } from "./page";

type Luong = { gui: (event: string) => void; dong: () => void; signal: AbortSignal };
let luong: Luong[] = [];
afterEach(() => { cleanup(); vi.restoreAllMocks(); luong = []; });
const thu = (component_name: string, nhan?: string, extra: Partial<ThuVanHanh> = {}): ThuVanHanh => ({
  menu_component_id: 81, component_name, filling_option_ids: [], options: nhan ? [{ option_group_name: "Nhân", option_name: nhan }] : [],
  extra_filling: false, ordered: 13, served: 6, missing: 7, ...extra,
});
const items = [thu("Bánh cuốn", "Thịt", { extra_filling: true }), thu("Bánh cuốn", "Thịt + mộc nhĩ"), thu("Bánh cuốn", "Chay"), thu("Trứng tái"), thu("Trứng chín"), thu("Canh bánh cuốn"), thu("Giò")];
const phien = (id: number, service_group: BangVanHanh["sessions"][number]["service_group"], label: string, its = [items[0]]): BangVanHanh["sessions"][number] => ({
  table_session_id: id, session_status: "open", service_group, tables: [{ dining_table_id: id, label }], order_total_vnd: 79123, served_amount_vnd: service_group === "serving" ? 23123 : 0, items: its, lines: [], lines_total_vnd: 0,
});
type Dong = BangVanHanh["sessions"][number]["lines"][number];
const dong = (item_name: string, extra: Partial<Dong> = {}): Dong => ({
  menu_item_id: 1, item_name, quantity: 1, unit_price_vnd: 7000, line_total_vnd: 7000, components: [], options: [], ...extra,
});
// Ba dòng gốc từ nhiều đơn nối tiếp. Như dữ liệu thật: dòng combo chỉ mang giá combo × số lượng, phụ thu nằm ở suất;
// tổng là lines_total_vnd backend cộng (63.000đ), khác cộng dòng gốc (61.000đ) — FE không tự cộng (ADR-102 điểm 3).
const dongCuaBan: Dong[] = [
  { menu_combo_id: 9, item_name: "Combo bữa sáng", quantity: 2, unit_price_vnd: 20000, line_total_vnd: 40000, components: [], options: [],
    portions: [dong("Bánh cuốn thịt", { quantity: 2, unit_price_vnd: 1000, line_total_vnd: 2000,
      options: [{ menu_option_id: 15, option_group_name: "Lượng nhân", option_name: "Nhiều nhân", surcharge_vnd: 1000 }] }), dong("Canh combo", { quantity: 2, unit_price_vnd: 0, line_total_vnd: 0 })] },
  dong("Trứng chín"), dong("Canh thêm", { quantity: 2, line_total_vnd: 14000 }),
];
const hist = (served_at: string, name: string): BangVanHanh["serve_history"][number] => ({ served_at, dining_table_id: 21, table_label: "A", person_id: 91, person_name: "Người thử", station_code: "banh", menu_component_id: 81, component_name: name, filling_option_ids: [], quantity: 9 });
const data: BangVanHanh = {
  sale_date: "2025-02-03", read_at: "2025-02-03T03:17:29Z",
  sessions: [phien(28, "serving", "D"), { ...phien(21, "serving", "A", items), tables: [{ dining_table_id: 21, label: "A" }, { dining_table_id: 22, label: "B" }] }, phien(31, "waiting", "C", [thu("Bánh cuốn", "Thịt", { ordered: 11, served: 0, missing: 11 })]), phien(41, "no_order", "E", [])],
  empty_tables: [{ dining_table_id: 51, label: "F" }],
  serve_history: [hist("2025-02-03T03:16:12Z", "Món mới"), hist("2025-02-03T03:16:12Z", "Món cùng lần"), hist("2025-02-03T02:11:03Z", "Món cũ")],
};
const hangRong: HangChoChuQuan = { read_at: data.read_at, poll_interval_seconds: 20, paused_since: null, blind_since: null, orders: [], active_orders: [] };
function mo(doc: (n: number) => { status: number; body: unknown } = () => ({ status: 200, body: data }),
  docHang: (n: number) => { status: number; body: unknown } = () => ({ status: 200, body: hangRong }), chu = false) {
  let n = 0, hn = 0;
  const goi: { method: string; path: string; body: unknown }[] = [];
  const fetch = async (req: Request) => {
    const path = new URL(req.url).pathname.replace(/^\/api/, "");
    const raw = await req.text();
    goi.push({ method: req.method, path, body: raw ? JSON.parse(raw) : undefined });
    if (path === "/counter/events") {
      let controller!: ReadableStreamDefaultController<Uint8Array>;
      const stream = new ReadableStream<Uint8Array>({ start(c) { controller = c; } });
      luong.push({
        signal: req.signal,
        gui(event) { controller.enqueue(new TextEncoder().encode(`event: ${event}\ndata: {"read_at":"2025-02-03T03:17:29Z"}\n\n`)); },
        dong() { controller.close(); },
      });
      return new Response(stream, { status: 200, headers: { "content-type": "text/event-stream" } });
    }
    const r = path === "/sessions/current" ? chu ? { status: 200, body: { is_owner: true, counter_duty_id: null } } : { status: 401, body: { code: "unauthenticated" } }
      : path === "/counter/queue" ? docHang(++hn)
        : req.method === "POST" ? { status: 200, body: {} } : doc(++n);
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  };
  render(<ApiProvider fetch={fetch}><Page /></ApiProvider>);
  return goi;
}
const bang = async () => within(await screen.findByRole("region", { name: "Bảng tổng thiếu" }));
const cells = (r: HTMLElement) => within(r).getAllByRole("cell").map((x) => x.textContent);
const nut = (name: string) => screen.getByRole("button", { name });
const vungAn = (b: HTMLElement) => document.getElementById(b.getAttribute("aria-controls")!)!;

describe("Vận hành", () => {
  it.each(["serving", "waiting"] as const)("T-314: hàng %s mặc định hiện đơn, chuyển cột riêng từng bàn rồi về đơn", async (nhom) => {
    mo(() => ({ status: 200, body: { ...data, sessions: [
      { ...phien(21, nhom, "Bàn X"), lines: dongCuaBan, lines_total_vnd: 63000 },
      { ...phien(22, "serving", "Bàn Y"), lines: [dong("Món bàn Y")], lines_total_vnd: 7000 },
    ] } }), undefined, true);
    const b = await bang();
    await screen.findByText("Bấm Chi tiết đem ra ở một bàn rồi bấm vào ô số để báo đã đem ra.");
    if (nhom === "waiting") fireEvent.click(screen.getByRole("checkbox", { name: "Bàn X · 79.123đ" }));
    const nhan = b.getByRole("button", { name: "Bàn X" });
    const hang = nhan.closest("tr")!;
    const hangKhac = b.getByRole("button", { name: "Bàn Y" }).closest("tr")!;
    const donKhac = cells(hangKhac);
    const cot = b.getAllByRole("columnheader").map((c) => c.textContent);
    const tong = cells(b.getAllByRole("row").at(-1)!);
    const tienDaRa = nhom === "serving" ? "23.123đ" : "0đ";
    const kiemDon = () => {
      const o = within(hang).getAllByRole("cell");
      expect(o).toHaveLength(2);
      expect(o[0].getAttribute("colspan")).toBe(String(cot.length - 2));
      expect(Array.from(o[0].querySelectorAll("p")).map((p) => p.textContent)).toEqual([
        "Combo bữa sáng ·  · Số lượng 2 · 40.000đ", "Bánh cuốn thịt · Nhiều nhân · Số suất 2", "Canh combo ·  · Số suất 2",
        "Trứng chín ·  · Số lượng 1 · 7.000đ", "Canh thêm ·  · Số lượng 2 · 14.000đ", "Tổng 63.000đ",
      ]);
      expect(o[1].textContent).toBe(tienDaRa);
      expect(within(hang).queryAllByRole("button", { name: /^Đem ra / })).toHaveLength(0);
    };
    kiemDon();
    expect(b.queryAllByRole("button", { name: /^Đem ra / })).toHaveLength(0);
    const chuyen = within(hang).getByRole("button", { name: "Chi tiết đem ra Bàn X" });
    expect(chuyen.closest("th")).toBe(nhan.closest("th"));
    expect(chuyen.textContent).toBe("Chi tiết đem ra");
    expect(chuyen.getAttribute("aria-pressed")).toBe("false");
    fireEvent.click(chuyen);
    expect(within(hang).getByRole("button", { name: "Xem đơn đã đặt Bàn X" })).toBe(chuyen);
    expect(chuyen.textContent).toBe("Xem đơn đã đặt");
    expect(chuyen.getAttribute("aria-pressed")).toBe("true");
    expect(nhan.getAttribute("aria-expanded")).toBe("false");
    expect(cells(hang)).toEqual(["7*", "0", "0", "0", "0", tienDaRa]);
    if (nhom === "serving") expect(within(hang).getByRole("button", { name: "Đem ra Bàn X · Thịt nhiều" })).toBeTruthy();
    else expect(within(hang).queryAllByRole("button", { name: /^Đem ra / })).toHaveLength(0);
    expect(cells(hangKhac)).toEqual(donKhac);
    expect(within(hangKhac).getByRole("button", { name: "Chi tiết đem ra Bàn Y" }).getAttribute("aria-pressed")).toBe("false");
    expect(b.getAllByRole("columnheader").map((c) => c.textContent)).toEqual(cot);
    expect(cells(b.getAllByRole("row").at(-1)!)).toEqual(tong);
    expect(screen.getByText("* nhiều nhân")).toBeTruthy();
    fireEvent.click(chuyen);
    expect(within(hang).getByRole("button", { name: "Chi tiết đem ra Bàn X" }).getAttribute("aria-pressed")).toBe("false");
    kiemDon();
    expect(cells(hangKhac)).toEqual(donKhac);
    expect(cells(b.getAllByRole("row").at(-1)!)).toEqual(tong);
  });
  it.each(["nút Đọc lại", "tín hiệu changed"])("T-314: %s giữ chế độ từng hàng đang phục vụ và ghép thử", async (cachDoc) => {
    const goi = mo((n) => ({ status: 200, body: n === 1 ? data : { ...data, sessions: data.sessions.map((p) => ({
      ...p, items: p.items.map((i) => ({ ...i, missing: 3 })), lines: [dong("Món đọc lại")], lines_total_vnd: 9001,
    })) } }), undefined, true);
    const b = await bang();
    await screen.findByText("Bấm Chi tiết đem ra ở một bàn rồi bấm vào ô số để báo đã đem ra.");
    fireEvent.click(screen.getByRole("checkbox", { name: "C · 79.123đ" }));
    for (const ten of ["D", "C"]) fireEvent.click(b.getByRole("button", { name: `Chi tiết đem ra ${ten}` }));
    if (cachDoc === "nút Đọc lại") fireEvent.click(nut("Đọc lại"));
    else {
      await waitFor(() => expect(luong).toHaveLength(1));
      await act(async () => luong[0].gui("changed"));
    }
    const hangDon = b.getByRole("button", { name: "A + B" }).closest("tr")!;
    expect(await within(hangDon).findByText("Tổng 9.001đ")).toBeTruthy();
    expect(within(hangDon).getByRole("button", { name: "Chi tiết đem ra A + B" }).getAttribute("aria-pressed")).toBe("false");
    for (const ten of ["D", "C"]) {
      const hang = b.getByRole("button", { name: ten }).closest("tr")!;
      expect(within(hang).getByRole("button", { name: `Xem đơn đã đặt ${ten}` }).getAttribute("aria-pressed")).toBe("true");
      expect(cells(hang)[0]).toBe(ten === "D" ? "3*" : "3");
    }
    expect(b.getByRole("button", { name: "Đem ra D · Thịt nhiều" }).textContent).toBe("3*");
    expect(b.queryAllByRole("button", { name: /^Đem ra C/ })).toHaveLength(0);
    expect(goi.filter((g) => g.path === "/service-board")).toHaveLength(2);
  });
  it("chủ quán không đứng quầy thấy đơn QR, duyệt rồi đọc lại; luồng nhận đơn là counter/events", async () => {
    const don: HangChoChuQuan["orders"][number] = { sales_order_id: 77, channel_code: "qr_table", dining_table_id: 3,
      created_at: data.read_at, customer_phone: null, customer_needed_at: null, total_vnd: 8000,
      lines: [{ menu_item_id: 1, item_name: "Bánh cuốn", quantity: 2, unit_price_vnd: 4000, line_total_vnd: 8000, components: [], options: [] }] };
    const ban3 = { ...data, sessions: [...data.sessions, phien(3, "waiting", "3")] };
    const goi = mo(() => ({ status: 200, body: ban3 }), (n) => ({ status: 200, body: n === 1 ? { ...hangRong, orders: [don] } : hangRong }), true);
    await bang();
    const vung = within(await screen.findByRole("region", { name: "Đơn chờ chủ quán xử lý" }));
    expect((await vung.findByRole("article", { name: "Đơn 77" })).textContent).toContain("Bàn 3");
    expect(vung.getByText(/Bánh cuốn ·/).textContent).toContain("Số lượng 2");
    await waitFor(() => expect(luong).toHaveLength(1));
    expect(goi.some((g) => g.path === "/counter/events")).toBe(true);
    fireEvent.click(vung.getByRole("button", { name: "Duyệt đơn 77" }));
    await waitFor(() => expect(goi.some((g) => g.method === "POST" && g.path === "/orders/77/approval")).toBe(true));
    await waitFor(() => expect(vung.getByText("Không có đơn chờ xác nhận.")).toBeTruthy());
    fireEvent.click(nut("Chi tiết đem ra D"));
    expect(screen.getByRole("button", { name: /Đem ra D/ })).toBeTruthy();
  });
  it("chủ quán mở lại trạng thái mù bằng nút và từ chối đơn qua bước xác nhận", async () => {
    const don: HangChoChuQuan["orders"][number] = { sales_order_id: 78, channel_code: "pickup", dining_table_id: null,
      created_at: data.read_at, customer_phone: "0900", customer_needed_at: null, total_vnd: 0, lines: [] };
    const goi = mo(undefined, (n) => ({ status: 200, body: n === 1 ? { ...hangRong, blind_since: data.read_at, orders: [don] } : { ...hangRong, orders: [don] } }), true);
    await bang();
    const vung = within(screen.getByRole("region", { name: "Đơn chờ chủ quán xử lý" }));
    fireEvent.click(await vung.findByRole("button", { name: "Mở lại nhận đơn" }));
    await waitFor(() => expect(goi.some((g) => g.path === "/shop-blind/reopening" && g.method === "POST")).toBe(true));
    fireEvent.click(vung.getByRole("button", { name: "Từ chối đơn 78" }));
    expect(goi.some((g) => g.path === "/orders/78/rejection")).toBe(false);
    fireEvent.click(screen.getByRole("button", { name: "Xác nhận từ chối" }));
    await waitFor(() => expect(goi.some((g) => g.path === "/orders/78/rejection" && g.method === "POST")).toBe(true));
  });
  it("đơn QR mới phát changed thì đọc lại service-board và hiện bàn cùng số món; heartbeat không đọc", async () => {
    const moi = { ...data, sessions: [...data.sessions, { ...phien(3, "waiting", "3", [thu("Bánh cuốn", "Thịt", { ordered: 2, served: 0, missing: 2 })]), lines: [dong("Bánh cuốn", { quantity: 2, line_total_vnd: 14000 })], lines_total_vnd: 14000 }] };
    const goi = mo((n) => ({ status: 200, body: n === 1 ? data : moi }));
    await bang();
    await waitFor(() => expect(luong).toHaveLength(1));
    const soDoc = () => goi.filter((g) => g.path === "/service-board").length;
    expect(soDoc()).toBe(1);
    await act(async () => luong[0].gui("heartbeat"));
    expect(soDoc()).toBe(1);
    await act(async () => luong[0].gui("changed"));
    await waitFor(() => expect(soDoc()).toBe(2));
    const b = within(screen.getByRole("region", { name: "Cộng thử ghép đơn" }));
    const banMoi = b.getByRole("checkbox", { name: "3 · 79.123đ" }).closest(".choice");
    expect(banMoi?.textContent).toContain("Bánh cuốn ·  · Số lượng 2 · 14.000đ");
    expect(goi.every((g) => g.method === "GET")).toBe(true);
  });
  it("luồng đứt báo mất kết nối; nối lại nhận hello thì đọc bảng mới", async () => {
    const moi = { ...data, sessions: [...data.sessions, phien(3, "waiting", "3")] };
    const goi = mo((n) => ({ status: 200, body: n === 1 ? data : moi }));
    await bang();
    await waitFor(() => expect(luong).toHaveLength(1));
    await act(async () => luong[0].dong());
    expect((await screen.findByRole("alert")).textContent).toContain("Mất kết nối trực tiếp");
    await waitFor(() => expect(luong).toHaveLength(2), { timeout: 2500 });
    await act(async () => luong[1].gui("hello"));
    await waitFor(() => expect(screen.queryByRole("alert")).toBeNull());
    expect(screen.getByRole("checkbox", { name: "3 · 79.123đ" })).toBeTruthy();
    expect(goi.filter((g) => g.path === "/service-board")).toHaveLength(2);
  });
  it("rời trang huỷ luồng và không tạo lời gọi ghi đơn", async () => {
    const goi = mo();
    await bang();
    await waitFor(() => expect(luong).toHaveLength(1));
    const signal = luong[0].signal;
    cleanup();
    expect(signal.aborted).toBe(true);
    expect(goi.every((g) => g.method === "GET")).toBe(true);
  });
  it("ánh xạ mỗi thứ đúng một cột, giữ chính xác tên và không giấu Khác", async () => {
    expect(items.map(cotVanHanh)).toEqual([{ cot: "Thịt", dong: "" }, { cot: "Mộc nhĩ", dong: "" }, { cot: "Chay", dong: "" }, { cot: "Trứng", dong: "tái" }, { cot: "Trứng", dong: "chín" }, { cot: "Canh", dong: "" }, { cot: "Khác", dong: "Giò" }]);
    for (const i of [thu("Bánh cuốn ", "Thịt"), thu("Bánh cuốn", "Thit"), thu("Bánh cuốn", " Thịt"), thu("Món đổi tên"), thu("Nước chấm")]) expect(cotVanHanh(i).cot).toBe("Khác");
    mo((n) => ({ status: 200, body: n === 1 ? data : { ...data, sessions: data.sessions.map((p) => ({ ...p, items: p.items.filter((i) => i.component_name !== "Giò") })) } }));
    expect((await bang()).getByRole("columnheader", { name: "Khác" })).toBeTruthy();
    fireEvent.click(nut("Đọc lại"));
    await waitFor(() => expect(screen.queryByRole("columnheader", { name: "Khác" })).toBeNull());
  });
  it("chỉ serving, ghép A + B, xếp theo mã bàn, cộng missing và tiền backend, đánh dấu nhiều", async () => {
    mo(); const b = await bang(); const rows = b.getAllByRole("row");
    fireEvent.click(nut("Chi tiết đem ra A + B"));
    expect(rows).toHaveLength(4);
    expect(rows[1].textContent).toContain("A + B"); expect(rows[2].textContent).toContain("D");
    expect(cells(rows[1])).toEqual(["7*", "7", "7 tái7 chín", "7", "7", "7 Giò", "23.123đ"]);
    expect(cells(rows[3])).toEqual(["14*", "7", "7 tái7 chín", "7", "7", "7 Giò", "46.246đ"]);
    expect(rows[1].querySelector(".nhieu")).toBeTruthy();
    expect(b.queryByRole("button", { name: "C" })).toBeNull();
    expect(metadata.title).toBe("Vận hành"); expect(screen.getByText(/Ngày bán: 2025-02-03/).textContent).toContain("10:17:29");
  });
  it("bấm nhãn bàn mở ngay dưới hàng với tổng, đã ra, thiếu, tiền đơn rồi đóng", async () => {
    mo(); const b = await bang(); const btn = b.getByRole("button", { name: "A + B" });
    fireEvent.click(btn); expect(btn.getAttribute("aria-expanded")).toBe("true");
    const detail = btn.closest("tr")!.nextElementSibling! as HTMLElement;
    expect(detail.id).toBe(btn.getAttribute("aria-controls"));
    expect(within(detail).getAllByText("tổng")).toHaveLength(6); expect(within(detail).getAllByText("đã ra")).toHaveLength(6); expect(within(detail).getAllByText("thiếu")).toHaveLength(6);
    expect(detail.textContent).toContain("Tiền đơn: 79.123đ");
    fireEvent.click(btn); expect(btn.getAttribute("aria-expanded")).toBe("false"); expect(document.getElementById(detail.id)).toBeNull();
  });
  it("tick thêm hàng đỏ và tổng x+y, bỏ chọn gỡ; chỉ GET service-board và sessions/current, không ghi trình duyệt", async () => {
    const set = vi.spyOn(Storage.prototype, "setItem"); const remove = vi.spyOn(Storage.prototype, "removeItem"); const clear = vi.spyOn(Storage.prototype, "clear");
    const g = mo(); const b = await bang();
    fireEvent.click(screen.getByRole("checkbox", { name: "C · 79.123đ" }));
    fireEvent.click(nut("Chi tiết đem ra C"));
    const row = b.getByRole("button", { name: "C" }).closest("tr")!;
    expect(row.className).toContain("dong-ghep"); expect(cells(row)[0]).toBe("11"); expect(cells(row).at(-1)).toBe("0đ");
    expect(cells(b.getAllByRole("row").at(-1)!)[0]).toBe("14+11*");
    expect(b.getByText("+11").className).toContain("them"); expect(screen.getByText("Đã chọn 1 bàn.")).toBeTruthy();
    fireEvent.click(nut("Bỏ chọn hết")); expect(b.queryByRole("button", { name: "C" })).toBeNull(); expect(screen.getByText("Đã chọn 0 bàn.")).toBeTruthy();
    expect(g.filter(({ path }) => path !== "/counter/events").map(({ method, path }) => ({ method, path })).sort((a, b) => a.path.localeCompare(b.path))).toEqual([{ method: "GET", path: "/counter/queue" }, { method: "GET", path: "/service-board" }, { method: "GET", path: "/sessions/current" }].sort((a, b) => a.path.localeCompare(b.path)));
    expect(set).not.toHaveBeenCalled(); expect(remove).not.toHaveBeenCalled(); expect(clear).not.toHaveBeenCalled();
  });
  it("T-313: thẻ cộng thử hiện liên tiếp dòng món và suất combo, tổng lấy từ backend, giữ chọn bàn", async () => {
    mo(() => ({ status: 200, body: { ...data, sessions: data.sessions.map((p) => p.service_group === "waiting" ? { ...p, lines: dongCuaBan, lines_total_vnd: 63000 } : p) } }));
    const b = await bang();
    const congThu = within(screen.getByRole("region", { name: "Cộng thử ghép đơn" }));
    const chon = congThu.getByRole("checkbox", { name: "C · 79.123đ" });
    const the = chon.closest(".choice")!;
    expect(Array.from(the.querySelectorAll("p")).map((p) => p.textContent)).toEqual([
      "Combo bữa sáng ·  · Số lượng 2 · 40.000đ", "Bánh cuốn thịt · Nhiều nhân · Số suất 2", "Canh combo ·  · Số suất 2",
      "Trứng chín ·  · Số lượng 1 · 7.000đ", "Canh thêm ·  · Số lượng 2 · 14.000đ", "Tổng 63.000đ",
    ]);
    expect(the.querySelector("h3")).toBeNull();
    expect(the.textContent).not.toContain("Thịt:");
    fireEvent.click(chon);
    expect(congThu.getByText("Đã chọn 1 bàn.")).toBeTruthy();
    fireEvent.click(nut("Chi tiết đem ra C"));
    expect(cells(b.getByRole("button", { name: "C" }).closest("tr")!)[0]).toBe("11");
    fireEvent.click(congThu.getByRole("button", { name: "Bỏ chọn hết" }));
    expect(congThu.getByText("Đã chọn 0 bàn.")).toBeTruthy();
    expect(b.queryByRole("button", { name: "C" })).toBeNull();
  });
  it("T-313: chi tiết hàng đang phục vụ và bàn chờ đã chọn hiện dòng món dưới cột, giữ tiền đơn và tổng thiếu", async () => {
    mo(() => ({ status: 200, body: { ...data, sessions: data.sessions.map((p) => ({ ...p, lines: dongCuaBan, lines_total_vnd: 63000 })) } }));
    const b = await bang();
    fireEvent.click(screen.getByRole("checkbox", { name: "C · 79.123đ" }));
    const tongTruoc = cells(b.getAllByRole("row").at(-1)!);
    for (const name of ["A + B", "C"]) {
      const btn = b.getByRole("button", { name });
      const hangTruoc = cells(btn.closest("tr")!);
      fireEvent.click(btn);
      const detail = document.getElementById(btn.getAttribute("aria-controls")!)!;
      const ct = within(detail);
      expect(ct.getByText("Combo bữa sáng · · Số lượng 2 · 40.000đ")).toBeTruthy();
      expect(ct.getByText("Bánh cuốn thịt · Nhiều nhân · Số suất 2")).toBeTruthy();
      expect(ct.getByText("Trứng chín · · Số lượng 1 · 7.000đ")).toBeTruthy();
      expect(ct.getByText("Tổng 63.000đ")).toBeTruthy();
      expect(ct.getByText("Tiền đơn: 79.123đ")).toBeTruthy();
      expect(ct.getAllByText("thiếu")).toHaveLength(6);
      expect(detail.textContent!.indexOf("Combo bữa sáng")).toBeGreaterThan(detail.textContent!.lastIndexOf("thiếu"));
      expect(cells(btn.closest("tr")!)).toEqual(hangTruoc);
    }
    expect(cells(b.getAllByRole("row").at(-1)!)).toEqual(tongTruoc);
  });
  it("đọc lại bỏ tick phiên hết waiting và không tự chọn lại khi nó quay về", async () => {
    mo((n) => ({ status: 200, body: n === 2 ? { ...data, sessions: data.sessions.map((p) => p.table_session_id === 31 ? { ...p, service_group: "serving" } : p) } : data }));
    await bang(); fireEvent.click(screen.getByRole("checkbox")); fireEvent.click(nut("Đọc lại"));
    await screen.findByText("Chưa bàn nào sắp phục vụ."); expect(screen.getByText("Đã chọn 0 bàn.")).toBeTruthy();
    fireEvent.click(nut("Đọc lại")); expect((await screen.findByRole("checkbox")).getAttribute("aria-checked")).toBe("false");
  });
  it("các phần mặc định ẩn; Hiện và Chi tiết đổi aria-expanded cùng hidden, bảng đủ data-label", async () => {
    mo(); await bang();
    for (const name of ["Hiện A + B", "Hiện D", "Chi tiết bàn đang phục vụ", "Hiện sơ đồ bàn", "Hiện lịch sử đem ra", "Hiện lịch sử theo bàn"]) {
      const b = nut(name), v = vungAn(b); expect(b.getAttribute("aria-expanded")).toBe("false"); expect(v.hidden).toBe(true);
      fireEvent.click(b); expect(b.getAttribute("aria-expanded")).toBe("true"); expect(v.hidden).toBe(false);
      fireEvent.click(b); expect(v.hidden).toBe(true);
    }
    fireEvent.click(nut("Chi tiết bàn đang phục vụ"));
    const rows = within(screen.getByRole("region", { name: "Bảng đầy đủ" })).getAllByRole("row");
    expect(cells(rows[1]).slice(0, 3)).toEqual(["91", "42", "49"]);
    expect(rows.at(-1)!.textContent).toContain("Tổng 2 bàn");
    expect(rows[1].querySelectorAll("td[data-label]")).toHaveLength(11);
  });
  it("sơ đồ đủ bốn trạng thái, số ô và thứ tự đúng bàn backend", async () => {
    mo(); await bang(); fireEvent.click(nut("Hiện sơ đồ bàn")); const list = screen.getByRole("list", { name: "Các bàn" });
    const rows = within(list).getAllByRole("listitem"); expect(rows).toHaveLength(6);
    expect(rows.map((r) => r.querySelector("strong")!.textContent)).toEqual(["A", "B", "D", "C", "E", "F"]);
    expect(within(list).getAllByText("Đang phục vụ")).toHaveLength(3);
    for (const text of ["Sắp phục vụ", "Đã mở, chưa gọi", "Còn trống"]) expect(within(list).getByText(text)).toBeTruthy();
  });
  it("lịch sử giữ thứ tự backend, lần thứ theo mốc khác nhau và có người, giờ Việt Nam", async () => {
    mo(); await bang(); fireEvent.click(nut("Hiện lịch sử đem ra"));
    const rows = within(screen.getByRole("region", { name: "Bảng lịch sử đem ra" })).getAllByRole("row").slice(1);
    expect(rows.map(cells)).toEqual([["10:16:12", "A", "Món mới", "9", "Người thử", "2"], ["10:16:12", "A", "Món cùng lần", "9", "Người thử", "2"], ["09:11:03", "A", "Món cũ", "9", "Người thử", "1"]]);
    fireEvent.click(nut("Hiện lịch sử theo bàn")); expect(screen.getByText("Lần 1 · 09:11:03 · Món cũ · 9 cái · Người thử")).toBeTruthy();
  });
  it.each([['unauthenticated', 'đăng nhập lại'], ['not_on_counter_duty', 'not_on_counter_duty']])("lỗi đầu %s có Alert, không khối dữ liệu", async (code, text) => {
    mo(() => ({ status: 403, body: { code } })); const a = await screen.findByRole("alert");
    expect(a.textContent).toContain("Chưa đọc được tình hình bàn"); expect(a.textContent).toContain(text);
    expect(screen.queryByRole("region", { name: "Bảng tổng thiếu" })).toBeNull();
  });
  it("dữ liệu rỗng có ba câu rỗng, không lỗi", async () => {
    mo(() => ({ status: 200, body: { ...data, sessions: [], empty_tables: [], serve_history: [] } }));
    expect(await screen.findByText("Chưa bàn nào đang phục vụ.")).toBeTruthy(); expect(screen.getByText("Chưa bàn nào sắp phục vụ.")).toBeTruthy(); expect(screen.getByText("Chưa có lần đem ra nào hôm nay.")).toBeTruthy(); expect(screen.queryByRole("alert")).toBeNull();
  });
  it("lỗi đọc lại giữ bản cũ và giờ read_at backend", async () => {
    mo((n) => n === 1 ? { status: 200, body: data } : { status: 403, body: { code: "not_on_counter_duty" } }); await bang(); fireEvent.click(nut("Đọc lại"));
    expect((await screen.findByRole("alert")).textContent).toContain(`lúc ${new Date(data.read_at).toLocaleTimeString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh", hour12: false })}.`); expect(nut("A + B")).toBeTruthy();
  });
  it("tiền lấy từ backend hoặc tổng dòng đã chụp, số thành phần đổi không đổi tiền, số tiền không là nút", async () => {
    mo(() => ({ status: 200, body: { ...data, sessions: data.sessions.map((p) => ({ ...p, items: p.items.map((i) => ({ ...i, ordered: 107, served: 101, missing: 6 })) })) } }));
    await bang(); fireEvent.click(nut("A + B")); fireEvent.click(nut("Chi tiết bàn đang phục vụ"));
    const values = Array.from(document.querySelectorAll("td, p, label")).flatMap((el) => el.children.length && el.tagName === "TD" ? [] : el.textContent!.match(/[\d.]+đ/g) ?? []);
    expect(values.length).toBeGreaterThan(5);
    expect(values.every((v) => ["79.123đ", "23.123đ", "46.246đ", "158.246đ", "0đ"].includes(v))).toBe(true);
    expect(screen.getAllByRole("button").every((b) => !/[\d.]+đ/.test(b.textContent!))).toBe(true);
    expect(document.body.textContent).toContain("Chỉ chủ quán hoặc người đang đứng quầy ghi được đem ra. Các ô này chỉ để xem.");
  });
  it("không đánh dấu nhiều khi không thiếu, Khác hiện cả khi chỉ có ở phiên no_order", async () => {
    mo(() => ({ status: 200, body: { ...data, sessions: [phien(21, "serving", "A", [thu("Bánh cuốn", "Thịt", { extra_filling: true, missing: 0, served: 13 })]), phien(41, "no_order", "E", [thu("Giò")])] } }));
    const b = await bang();
    fireEvent.click(nut("Chi tiết đem ra A"));
    expect(cells(b.getAllByRole("row")[1])[0]).toBe("0"); expect(b.getByRole("columnheader", { name: "Khác" })).toBeTruthy();
  });
});
