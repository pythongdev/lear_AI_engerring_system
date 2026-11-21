// YT-06: kiểm qua fetch của ApiProvider, gồm cả chỗ gắn nút trên web và QR.
import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { useQueryClient } from "@tanstack/react-query";
import type { ReactNode } from "react";
import { ThucDonKhach } from "@/app/ban/_components/thuc-don-khach";
import { ChonMonChiTiet } from "@/app/thuc-don/chon-mon-chi-tiet";
import { DatMonKhach } from "@/app/dat-mon/dat-mon-khach";
import { ApiProvider } from "@/lib/api/provider";
import { useNhapKhach } from "@/lib/nhap-khach";
import { KhungKhach } from "./khung";
import { NutTim } from "./nut-tim";
import { KHOA, type Dong, type Menu } from "./yeu-thich/du-lieu";

beforeEach(() => { localStorage.clear(); sessionStorage.clear(); });
afterEach(() => { cleanup(); useNhapKhach.getState().xoaHet(); });

const nhan = { option_group_id: 1, option_group_name: "Nhân", prerequisite_option_ids: [], options: [
  { menu_option_id: 11, option_name: "Thịt", is_default: true }, { menu_option_id: 12, option_name: "Chay", is_default: false },
] };
const luong = { option_group_id: 2, option_group_name: "Lượng nhân", prerequisite_option_ids: [11], options: [
  { menu_option_id: 21, option_name: "Thường", is_default: true }, { menu_option_id: 22, option_name: "Nhiều", is_default: false },
] };
const menu: Menu = { categories: [], items: [
  { menu_item_id: 1, item_name: "Bánh cuốn", menu_category_id: null, option_groups: [nhan, luong], prices: [
    { option_ids: [11, 21], unit_price_vnd: 35000 }, { option_ids: [11, 22], unit_price_vnd: 40000 }, { option_ids: [12], unit_price_vnd: 30000 },
  ] },
], combos: [{ menu_combo_id: 5, name: "Bữa sáng", price_vnd: 72000, items: [
  { menu_item_id: 1, item_name: "Bánh cuốn", quantity: 2, option_groups: [nhan, luong], surcharges: [] },
  { menu_item_id: 2, item_name: "Canh", quantity: 1, option_groups: [], surcharges: [] },
] }] };
const mon = menu.items[0]; const combo = menu.combos[0];
const dongMon: Dong = { favourite_line_id: 101, menu_item_id: 1, menu_combo_id: null, option_ids: [21, 11], quantity: 3, portions: [], available: true, unavailable_code: null };
const suatMacDinh = [{ menu_item_id: 1, option_ids: [11, 21], quantity: 2 }, { menu_item_id: 2, option_ids: [], quantity: 1 }];
const dongCombo: Dong = { ...dongMon, favourite_line_id: 102, menu_item_id: null, menu_combo_id: 5, option_ids: [], quantity: 3, portions: [
  { menu_item_id: 2, option_ids: [], quantity: 3 },
  { menu_item_id: 1, option_ids: [21, 11], quantity: 2 }, { menu_item_id: 1, option_ids: [11, 21], quantity: 4 },
] };
const rong = { lines: [], sets: [] };
const duong = "/customer-accounts/current/favourites";
type Goi = { method: string; path: string; body: unknown };
type Dap = { status: number; body: unknown };
const ok = (body: unknown = { status: "ok" }): Dap => ({ status: 200, body });
const chuaDangNhap = () => ({ status: 401, body: { code: "unauthenticated" } });

function mo(children: ReactNode, options: { doc?: () => Dap | Promise<Dap>; ghi?: (g: Goi) => Dap | Promise<Dap> } = {}) {
  const calls: Goi[] = [];
  const fetch = vi.fn(async (req: Request) => {
    const raw = await req.text();
    const g: Goi = { method: req.method, path: new URL(req.url).pathname.replace(/^\/api/, ""), body: raw ? JSON.parse(raw) : undefined };
    calls.push(g);
    const r = g.method === "GET" && g.path === duong ? await (options.doc?.() ?? ok(rong))
      : g.method === "POST" && g.path.startsWith(duong) ? await (options.ghi?.(g) ?? ok())
      : g.path === "/menu" ? ok(menu)
      : g.path === "/customer-sessions/current" ? chuaDangNhap()
      : { status: 599, body: { code: "ngoai_hop_dong_test" } };
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  });
  const view = render(<ApiProvider fetch={fetch}>{children}</ApiProvider>);
  return { ...view, calls, doc: () => calls.filter((g) => g.method === "GET" && g.path === duong), ghi: () => calls.filter((g) => g.method === "POST" && g.path.startsWith(duong)) };
}
const thucDon = (maBan?: string) => <ThucDonKhach items={menu.items} combos={menu.combos} lines={[]} onChange={() => {}} quotes={[]} thongTin={null} tong={null} maBan={maBan} />;
const chiTiet = (loai: "mon" | "combo" = "mon", maBan?: string) => <ChonMonChiTiet menu={menu} mon={loai === "mon" ? mon : undefined} combo={loai === "combo" ? combo : undefined} groups={mon.option_groups} maBan={maBan} />;
const timMon = () => <NutTim dong={{ menu_item_id: 1, option_ids: [11, 21] }} ten="Bánh cuốn" />;
async function nut(ten = "Thêm Bánh cuốn vào yêu thích") {
  const b = await screen.findByRole("button", { name: ten });
  await waitFor(() => expect(b.hasAttribute("disabled")).toBe(false));
  return b;
}

describe("YT-06 A1 — thân lệnh trên thực đơn và chi tiết", () => {
  it("thẻ món web gửi đúng thân mặc định, không tên hay giá", async () => {
    const r = mo(thucDon());
    const b = await nut();
    expect(b.getAttribute("aria-pressed")).toBe("false"); expect(b.textContent).toBe("♡");
    fireEvent.click(b);
    await waitFor(() => expect(r.doc()).toHaveLength(2));
    expect(r.ghi()).toEqual([{ method: "POST", path: duong, body: { menu_item_id: 1, option_ids: [11, 21], quantity: 1 } }]);
  });

  it("chi tiết món đổi một nhóm rồi gửi lựa chọn đang chọn với quantity 1", async () => {
    const r = mo(chiTiet());
    await nut();
    fireEvent.click(screen.getByRole("radio", { name: "Nhiều" }));
    fireEvent.change(screen.getByRole("spinbutton", { name: "Số lượng" }), { target: { value: "4" } });
    fireEvent.click(await nut());
    await waitFor(() => expect(r.doc()).toHaveLength(2));
    expect(r.ghi()).toEqual([{ method: "POST", path: duong, body: { menu_item_id: 1, option_ids: [11, 22], quantity: 1 } }]);
  });

  it.each(["thẻ", "chi tiết"])("combo ở %s gửi suất mặc định đã gộp", async (noi) => {
    const r = mo(noi === "thẻ" ? thucDon() : chiTiet("combo"));
    if (noi === "chi tiết") {
      fireEvent.click(screen.getByRole("radio", { name: "Chay" }));
      fireEvent.change(screen.getByRole("spinbutton", { name: "Số lượng" }), { target: { value: "3" } });
    }
    fireEvent.click(await nut("Thêm Bữa sáng vào yêu thích"));
    await waitFor(() => expect(r.doc()).toHaveLength(2));
    expect(r.ghi()).toEqual([{ method: "POST", path: duong, body: { menu_combo_id: 5, quantity: 1, portions: suatMacDinh } }]);
  });
});

describe("YT-06 A2 — nhận diện và bỏ tim, cache chung", () => {
  it("món cùng tập lựa chọn khác thứ tự đã thả; removal đúng id rồi đọc lại", async () => {
    let daBo = false;
    const r = mo(timMon(), { doc: () => ok({ lines: daBo ? [] : [dongMon], sets: [] }), ghi: () => { daBo = true; return ok(); } });
    const b = await nut("Bỏ Bánh cuốn khỏi yêu thích");
    expect(b.getAttribute("aria-pressed")).toBe("true"); expect(b.textContent).toBe("♥");
    fireEvent.click(b);
    await waitFor(() => expect(r.doc()).toHaveLength(2));
    expect((await nut()).getAttribute("aria-pressed")).toBe("false");
    expect(r.ghi()).toEqual([{ method: "POST", path: `${duong}/101/removal`, body: undefined }]);
  });

  it("combo gộp suất cùng món và tập lựa chọn, so số suất mỗi combo rồi removal", async () => {
    const r = mo(<NutTim ten="Bữa sáng" dong={{ menu_combo_id: 5, portions: suatMacDinh }} />, { doc: () => ok({ lines: [dongCombo], sets: [] }) });
    const b = await nut("Bỏ Bữa sáng khỏi yêu thích");
    expect(b.getAttribute("aria-pressed")).toBe("true");
    fireEvent.click(b);
    await waitFor(() => expect(r.doc()).toHaveLength(2));
    expect(r.ghi()).toEqual([{ method: "POST", path: `${duong}/102/removal`, body: undefined }]);
  });

  it.each(["khác lựa chọn", "chỉ trong bộ"])("món %s không được tính đã thả", async (truongHop) => {
    const r = mo(timMon(), { doc: () => ok(truongHop === "khác lựa chọn" ? { lines: [{ ...dongMon, option_ids: [11, 22] }], sets: [] }
      : { lines: [], sets: [{ favourite_set_id: 7, kind: "rieng", name: "Bộ sáng", lines: [dongMon] }] }) });
    fireEvent.click(await nut());
    await waitFor(() => expect(r.ghi()).toHaveLength(1));
    expect(r.ghi()[0].path).toBe(duong);
  });

  it.each(["số suất", "lựa chọn", "mã combo"])("combo khác %s không được tính đã thả", async (khac) => {
    const d = khac === "mã combo" ? { ...dongCombo, menu_combo_id: 6 } : { ...dongCombo, portions: dongCombo.portions.map((p, i) => i !== 2 ? p
      : khac === "số suất" ? { ...p, quantity: 3 } : { ...p, option_ids: [11, 22] }) };
    mo(<NutTim ten="Bữa sáng" dong={{ menu_combo_id: 5, portions: suatMacDinh }} />, { doc: () => ok({ lines: [d], sets: [] }) });
    expect((await nut("Thêm Bữa sáng vào yêu thích")).getAttribute("aria-pressed")).toBe("false");
  });

  it("dùng đúng KHOA của trang Yêu thích và cập nhật các nút qua đọc lại", async () => {
    let client!: ReturnType<typeof useQueryClient>; let daThem = false;
    function Cache() { client = useQueryClient(); return null; }
    const r = mo(<><Cache />{timMon()}<NutTim ten="Món ở chỗ khác" dong={{ menu_item_id: 1, option_ids: [21, 11] }} /></>, {
      doc: () => ok({ lines: daThem ? [dongMon] : [], sets: [] }), ghi: () => { daThem = true; return ok(); },
    });
    const b = await nut();
    expect(client.getQueryData(KHOA)).toEqual(rong); expect(r.doc()).toHaveLength(1);
    const setData = vi.spyOn(client, "setQueryData");
    fireEvent.click(b);
    await nut("Bỏ Món ở chỗ khác khỏi yêu thích");
    expect(r.doc()).toHaveLength(2); expect(client.getQueryData(KHOA)).toEqual({ lines: [dongMon], sets: [] });
    expect(setData).not.toHaveBeenCalled(); setData.mockRestore();
  });
});

describe("YT-06 A3 — QR và điều hướng", () => {
  it.each(["thực đơn", "chi tiết món", "chi tiết combo"])("QR ở %s không có nút tim và không đọc yêu thích", async (noi) => {
    const r = mo(noi === "thực đơn" ? thucDon("ban-3") : chiTiet(noi === "chi tiết món" ? "mon" : "combo", "ban-3"));
    expect(screen.queryByRole("button", { name: /yêu thích/ })).toBeNull();
    await act(async () => {});
    expect(r.doc()).toHaveLength(0); expect(r.ghi()).toHaveLength(0);
  });

  it("khung khách và trang đặt món có link Yêu thích đúng đích", async () => {
    mo(<><KhungKhach title="Tài khoản">Nội dung</KhungKhach><DatMonKhach initialMenu={menu} /></>);
    for (const name of ["Điều hướng khách", "Tài khoản khách"]) {
      const nav = screen.getByRole("navigation", { name });
      expect(within(nav).getByRole("link", { name: "Yêu thích" }).getAttribute("href")).toBe("/khach/yeu-thich");
    }
    await screen.findByRole("link", { name: "Đăng nhập" });
  });
});

describe("YT-06 A4 — mời đăng nhập", () => {
  it("401 khi đọc giữ tim rỗng; bấm mời đăng nhập, không ghi và không lưu trên máy", async () => {
    const r = mo(timMon(), { doc: chuaDangNhap });
    const b = await nut();
    expect(b.textContent).toBe("♡"); expect(b.getAttribute("aria-pressed")).toBe("false");
    expect(screen.queryByText("Đăng nhập để lưu món yêu thích.")).toBeNull();
    fireEvent.click(b); fireEvent.click(b);
    expect(await screen.findByText("Đăng nhập để lưu món yêu thích.")).toBeTruthy();
    expect(screen.getByRole("link", { name: "Đăng nhập" }).getAttribute("href")).toBe("/khach/dang-nhap");
    expect(r.ghi()).toHaveLength(0); expect(r.doc()).toHaveLength(1);
    expect(localStorage.length).toBe(0); expect(sessionStorage.length).toBe(0);
  });

  it("401 khi ghi mời đăng nhập, lần bấm sau không gửi thêm", async () => {
    const r = mo(timMon(), { ghi: chuaDangNhap });
    fireEvent.click(await nut());
    expect(await screen.findByText("Đăng nhập để lưu món yêu thích.")).toBeTruthy();
    expect(screen.getByRole("link", { name: "Đăng nhập" }).getAttribute("href")).toBe("/khach/dang-nhap");
    fireEvent.click(await nut());
    expect(r.ghi()).toHaveLength(1); expect(r.doc()).toHaveLength(1);
    expect(localStorage.length).toBe(0); expect(sessionStorage.length).toBe(0);
  });
});

describe("YT-06 A5 — một lệnh đang bay và mất phản hồi", () => {
  it("503 trên thực đơn không có nút Đọc lại; bấm một tim chỉ báo lỗi tại thẻ đó và GET lại, không POST", async () => {
    const r = mo(thucDon(), { doc: () => ({ status: 503, body: { code: "internal" } }) });
    const b = await nut();
    expect(screen.getAllByRole("button", { name: /vào yêu thích/ })).toHaveLength(2);
    expect(b.textContent).toBe("♡"); expect(b.getAttribute("aria-pressed")).toBe("false");
    expect(screen.queryByRole("button", { name: "Đọc lại" })).toBeNull();
    expect(screen.queryByRole("alert")).toBeNull();
    expect(r.doc()).toHaveLength(1);
    fireEvent.click(b);
    await waitFor(() => expect(r.doc()).toHaveLength(2));
    await nut();
    expect(screen.getAllByRole("alert")).toHaveLength(1);
    expect(within(b.closest("article")!).getByRole("alert").textContent).toBe("Chưa đọc được danh sách yêu thích. Hãy thử lại.");
    const theCombo = screen.getByRole("button", { name: "Thêm Bữa sáng vào yêu thích" }).closest("article")!;
    expect(within(theCombo).queryByRole("alert")).toBeNull();
    expect(screen.queryByRole("button", { name: "Đọc lại" })).toBeNull();
    expect(r.calls.filter((g) => g.method === "POST")).toHaveLength(0);
  });

  it("đọc favourites sai hình báo lỗi, giữ tim rỗng và trang chi tiết vẫn dùng được", async () => {
    const r = mo(chiTiet(), { doc: () => ok({ customer_account_id: 1, display_name: "Khách" }) });
    const b = await nut();
    expect(screen.queryByRole("alert")).toBeNull();
    expect(b.textContent).toBe("♡"); expect(b.getAttribute("aria-pressed")).toBe("false");
    fireEvent.click(b);
    expect((await screen.findByRole("alert")).textContent).toBe("Chưa đọc được danh sách yêu thích. Hãy thử lại.");
    expect(screen.queryByRole("button", { name: "Đọc lại" })).toBeNull();
    await waitFor(() => expect(r.doc()).toHaveLength(2));
    expect(r.ghi()).toHaveLength(0);
    fireEvent.click(screen.getByRole("radio", { name: "Nhiều" }));
    fireEvent.click(screen.getByRole("button", { name: "Thêm vào giỏ" }));
    expect(useNhapKhach.getState().gio.web).toEqual([{ menu_item_id: 1, option_ids: [11, 22], quantity: 1 }]);
  });

  it("bấm liên tiếp chỉ gửi một lệnh, giữ khoá tới khi đọc lại xong", async () => {
    let xongGhi!: (r: Dap) => void; let xongDoc!: (r: Dap) => void; let lanDoc = 0;
    const r = mo(timMon(), { ghi: () => new Promise((resolve) => { xongGhi = resolve; }), doc: () => ++lanDoc === 1 ? ok(rong) : new Promise((resolve) => { xongDoc = resolve; }) });
    const b = await nut();
    fireEvent.click(b); fireEvent.click(b); fireEvent.click(b);
    await waitFor(() => expect(r.ghi()).toHaveLength(1));
    expect(b.hasAttribute("disabled")).toBe(true);
    await act(async () => { xongGhi(ok()); });
    await waitFor(() => expect(r.doc()).toHaveLength(2));
    expect(b.hasAttribute("disabled")).toBe(true); fireEvent.click(b);
    await act(async () => { xongDoc(ok({ lines: [dongMon], sets: [] })); });
    await nut("Bỏ Bánh cuốn khỏi yêu thích"); expect(r.ghi()).toHaveLength(1);
  });

  it("mất phản hồi báo chưa rõ bằng alert và không gửi lại ngầm", async () => {
    const r = mo(timMon(), { ghi: () => { throw new TypeError("fetch failed"); } });
    fireEvent.click(await nut());
    expect((await screen.findByRole("alert")).textContent).toContain("chưa rõ");
    await act(async () => { await new Promise((resolve) => setTimeout(resolve, 50)); });
    expect(r.ghi()).toHaveLength(1); expect(r.doc()).toHaveLength(1);
  });
});
