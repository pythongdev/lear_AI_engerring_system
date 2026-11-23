// Test KC-11 (ADR-147 điểm 2, 8, 9; work/backlog_KC.md#kc-11, chia lại 2026-11-23): bảng nguyên liệu ba cột của mục theo dõi
// lượng, chi tiết ngay dưới dòng (một ngăn mở một lúc) và lịch sử sử dụng của từng thứ. Claude viết TRƯỚC code; Codex làm cho
// xanh mà không sửa điều kiện kiểm nào.
//   - Nối theo mã: khoản con `supply_item_id` ↔ thứ trong `GET /supply-items`; thứ chưa xếp mục không vào bảng.
//   - Cột *Ước tính còn dùng* đọc `usage_estimate` (KC-07), không tự chia; số thập phân đổi dấu chấm thành dấu phẩy, không qua số.
//   - *Lịch sử sử dụng* đọc `GET /supply-items/{id}` (con số `used`), mặc định bảy ngày tới ngày dùng gần nhất.
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { useSyncExternalStore } from "react";
import { afterEach, describe, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import Page from "./page";

const nav = vi.hoisted(() => ({ search: "", listeners: new Set<() => void>(), replace: vi.fn() }));
vi.mock("next/navigation", () => ({
  useSearchParams: () => new URLSearchParams(useSyncExternalStore(
    (fn) => { nav.listeners.add(fn); return () => { nav.listeners.delete(fn); }; }, () => nav.search,
  )),
  useRouter: () => ({ replace: (url: string) => { nav.replace(url); nav.search = url.split("?")[1] ?? ""; nav.listeners.forEach((fn) => fn()); } }),
}));
afterEach(() => { cleanup(); nav.search = ""; nav.replace.mockReset(); });

type K = components["schemas"];
type Tra = { status: number; body?: unknown };
type GoiDen = { method: string; path: string; query: URLSearchParams; body: unknown };

const con = (id: number, name: string, supply: number): K["ExpenseItem"] => ({ expense_item_id: id, expense_category_id: 3, name, supply_item_id: supply, last_paid_date: null });
const loai: K["ExpenseCategory"][] = [
  { expense_category_id: 2, name: "Điện", paid_from_till: true, tracks_supply: false, last_paid_date: null, items: [] },
  { expense_category_id: 3, name: "Nguyên liệu chính", paid_from_till: false, tracks_supply: true, last_paid_date: "2026-10-18", items: [
    con(31, "Bột gạo", 7), con(32, "Hành khô", 8), con(33, "Trứng", 9), con(34, "Muối", 10), con(35, "Mắm", 12), con(36, "Tiêu", 13),
  ] },
];
type UT = K["SupplyUsageEstimate"];
const thu = (id: number, name: string, unit: string | null, mua: string, dung: string, con: string, uoc: UT, extra: Partial<K["SupplyItem"]> = {}): K["SupplyItem"] => ({
  supply_item_id: id, name, purchase_unit: unit, purchased_total: mua, used_total: dung, balance: con, usage_estimate: uoc,
  reminder_ratio: "0.2", latest_purchase_date: mua === "0" ? null : "2026-10-17", latest_purchase_measure: mua === "0" ? null : mua,
  reminder_status: mua === "0" ? "no_purchase" : "ready", check_reminder: false,
  expense_item_id: id === 70 ? null : 30 + [7, 8, 9, 10, 12, 13].indexOf(id) + 1, expense_category_id: id === 70 ? null : 3, stopped_at: null, ...extra,
});
// Thứ tự cố ý khác thứ tự khoản con; thứ 70 chưa xếp mục, không được hiện trong bảng.
const so: K["SupplyItem"][] = [
  thu(70, "Đường", "kg", "5", "0", "5", { status: "no_usage", usage_days: 0, used_in_window: "0", days_left: null }),
  thu(13, "Tiêu", "kg", "3", "0", "3", { status: "zero_usage", usage_days: 2, used_in_window: "0", days_left: null }),
  thu(12, "Mắm", "lít", "1.05", "1", "0.05", { status: "ready", usage_days: 1, used_in_window: "1", days_left: "0.0" }),
  thu(10, "Muối", "kg", "1.25", "0", "1.25", { status: "no_usage", usage_days: 0, used_in_window: "0", days_left: null }),
  thu(9, "Trứng", "quả", "10", "12", "-2", { status: "out_by_ledger", usage_days: 2, used_in_window: "12", days_left: null }),
  thu(8, "Hành khô", null, "0", "0", "0", { status: "out_by_ledger", usage_days: 0, used_in_window: "0", days_left: null }),
  thu(7, "Bột gạo", "kg", "20", "7", "13", { status: "ready", usage_days: 2, used_in_window: "7", days_left: "3.7" }),
];
const ds: K["Expenses"] = { from: "2026-10-19", to: "2026-10-19", expenses: [], total_vnd: 200000, day_totals: [],
  category_totals: [{ expense_category_id: 3, total_vnd: 200000 }], item_totals: [{ expense_item_id: 31, total_vnd: 200000, last_paid_date: "2026-10-18" }] };
const dong = (id: number, ngay: string, kind: "purchased" | "used", measure: string): K["SupplyDayEntry"] => ({
  supply_day_entry_id: id, supply_item_id: 7, entry_date: ngay, kind, measure, person_id: 1, person_name: "Hoa", created_at: `${ngay}T01:00:00Z` });
const soBotGao: K["SupplyItemDetail"] = { ...so[6], entries: [
  dong(1, "2026-10-17", "purchased", "20"), dong(2, "2026-10-17", "used", "4"), dong(3, "2026-10-15", "used", "3.5"), dong(4, "2026-10-01", "used", "5"),
] };

function mo(opts: { so?: () => Tra; chiTiet?: (id: string) => Tra; ghi?: () => Tra } = {}) {
  const goi: GoiDen[] = [];
  render(<ApiProvider fetch={async (req: Request) => {
    const text = await req.text(); const u = new URL(req.url);
    const g: GoiDen = { method: req.method, path: u.pathname.replace(/^\/api/, ""), query: u.searchParams, body: text ? JSON.parse(text) : undefined };
    goi.push(g);
    let r: Tra;
    const m = g.path.match(/^\/supply-items\/(\d+)$/);
    if (g.method !== "GET") r = opts.ghi?.() ?? { status: 200, body: { expense_item_id: 31, expense_category_id: 3, name: "Bột gạo mịn", supply_item_id: 7 } };
    else if (g.path === "/owner-overview") r = { status: 200, body: { sale_date: "2026-10-19" } };
    else if (g.path === "/expense-categories") r = { status: 200, body: { expense_categories: loai } };
    else if (g.path === "/supply-items") r = opts.so?.() ?? { status: 200, body: { supply_items: so } };
    else if (m) r = opts.chiTiet?.(m[1]) ?? { status: 200, body: soBotGao };
    else if (g.path === "/expenses") r = { status: 200, body: ds };
    else r = { status: 404, body: { code: "invalid_request" } };
    return new Response(r.body === undefined ? null : JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  }}><Page /></ApiProvider>);
  return goi;
}
const hang = (t: HTMLElement) => within(t).getAllByRole("row").slice(1);
const o = (r: HTMLElement) => within(r).getAllByRole("cell").map((c) => c.textContent?.trim());
const go = (f: HTMLElement, label: string, value: string) => fireEvent.change(within(f).getByLabelText(label), { target: { value } });
const mucCho = async (ten: string) => (await screen.findByRole("heading", { level: 3, name: ten })).closest("article") as HTMLElement;
async function bang() {
  const t = await within(await mucCho("Nguyên liệu chính")).findByRole("table", { name: "Nguyên liệu trong Nguyên liệu chính" });
  await waitFor(() => expect(within(t).getByText("Khoảng 3,7 ngày")).toBeTruthy());
  return t;
}
function moThu(t: HTMLElement, ten: string) {
  const nut = within(t).getByRole("button", { name: ten });
  fireEvent.click(nut);
  return { nut, ct: document.getElementById(nut.getAttribute("aria-controls")!)! };
}

describe("KC-11 — bảng nguyên liệu", () => {
  it("ba cột, một dòng mỗi khoản con theo thứ tự danh mục, nối theo mã; thứ chưa xếp mục không vào bảng", async () => {
    mo();
    const t = await bang();
    expect(within(t).getAllByRole("columnheader").map((c) => c.textContent)).toEqual(["Nguyên liệu", "Ước tính còn dùng", "Lượng còn lại"]);
    expect(hang(t).map(o)).toEqual([
      ["Bột gạo", "Khoảng 3,7 ngày", "13 kg"],
      ["Hành khô", "Chưa nhập", "Chưa nhập"],
      ["Trứng", "Hết theo sổ", "-2 quả"],
      ["Muối", "Chưa ghi ngày dùng", "1,25 kg"],
      ["Mắm", "Dưới 0,1 ngày", "0,05 lít"],
      ["Tiêu", "Chưa tính được (dùng 0)", "3 kg"],
    ]);
    expect(within(t).queryByText(/Đường/)).toBeNull();
    expect(within(await mucCho("Nguyên liệu chính")).getByText(/chỉ để xem/)).toBeTruthy();
    // Mục thường vẫn dùng bảng khoản con của KC-09.
    expect(within(await mucCho("Điện")).queryByRole("table", { name: /^Nguyên liệu trong/ })).toBeNull();
  });
  it("sổ chưa đọc được thì cột lượng hiện gạch, không hiện số giả hay Chưa nhập", async () => {
    mo({ so: () => ({ status: 500, body: { code: "internal" } }) });
    const t = await within(await mucCho("Nguyên liệu chính")).findByRole("table", { name: "Nguyên liệu trong Nguyên liệu chính" });
    await within(await mucCho("Nguyên liệu chính")).findByText(/Chưa đọc được sổ nguyên liệu/);
    expect(hang(t).map((r) => o(r).slice(1))).toEqual(Array(6).fill(["—", "—"]));
  });
});

describe("KC-11 — chi tiết dưới dòng", () => {
  it("bấm tên mở chi tiết ngay dưới dòng; mở thứ khác thì ngăn cũ đóng", async () => {
    mo();
    const t = await bang();
    const a = moThu(t, "Bột gạo");
    expect(a.nut.getAttribute("aria-expanded")).toBe("true");
    expect(a.nut.closest("tr")!.nextElementSibling?.contains(a.ct)).toBe(true);
    for (const s of ["17/10/2026", "7 kg trong 2 ngày có ghi gần nhất", "200.000 đ"]) expect(within(a.ct).getByText(s)).toBeTruthy();
    for (const n of ["Sửa tên", "Ngừng dùng", "Ghi mua", "Lịch sử sử dụng"]) expect(within(a.ct).getByRole("button", { name: n })).toBeTruthy();
    const b = moThu(t, "Hành khô");
    expect(b.nut.getAttribute("aria-expanded")).toBe("true");
    expect(a.nut.getAttribute("aria-expanded")).toBe("false");
    expect(a.ct.closest("[hidden]")).not.toBeNull();
    expect(within(b.ct).getByText("Chưa ghi")).toBeTruthy();
    expect(within(b.ct).getByText("Chưa ghi ngày dùng")).toBeTruthy();
    expect(within(b.ct).getByText("0 đ")).toBeTruthy();
  });
  it("Ghi mua mở hộp ghi đúng mục và khoản con; Ngừng dùng mở hộp ngừng dùng", async () => {
    mo();
    const t = await bang();
    const { ct } = moThu(t, "Bột gạo");
    fireEvent.click(within(ct).getByRole("button", { name: "Ghi mua" }));
    const f = screen.getByRole("form", { name: "Ghi khoản chi" });
    expect((within(f).getByLabelText("Loại chi") as HTMLSelectElement).value).toBe("3");
    expect((within(f).getByLabelText("Nguyên liệu / sản phẩm") as HTMLSelectElement).value).toBe("31");
    fireEvent.keyDown(screen.getByRole("dialog"), { key: "Escape" });
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    fireEvent.click(within(ct).getByRole("button", { name: "Ngừng dùng" }));
    expect(screen.getByRole("form", { name: "Ngừng dùng" }).textContent).toMatch(/Ngừng dùng Bột gạo/);
  });
  it("đổi tên khoản con nối sổ thì đọc lại cả sổ nguyên liệu", async () => {
    const g = mo();
    const t = await bang();
    const truoc = g.filter((x) => x.method === "GET" && x.path === "/supply-items").length;
    const { ct } = moThu(t, "Bột gạo");
    fireEvent.click(within(ct).getByRole("button", { name: "Sửa tên" }));
    const f = screen.getByRole("form", { name: "Đổi tên" });
    go(f, "Tên mới", "Bột gạo mịn"); go(f, "Lý do", "Đổi loại bột"); fireEvent.submit(f);
    await screen.findByText(/Đã đổi tên/);
    await waitFor(() => expect(g.filter((x) => x.method === "GET" && x.path === "/supply-items").length).toBeGreaterThan(truoc));
  });
});

describe("KC-11 — lịch sử sử dụng của từng thứ", () => {
  async function moLichSu() {
    const g = mo();
    const t = await bang();
    const { ct } = moThu(t, "Bột gạo");
    const nut = within(ct).getByRole("button", { name: "Lịch sử sử dụng" });
    fireEvent.click(nut);
    expect(nut.getAttribute("aria-expanded")).toBe("true");
    return { g, ls: within(ct).getByRole("region", { name: "Lịch sử sử dụng Bột gạo" }) };
  }
  it("đọc sổ của đúng thứ, chỉ con số đã dùng, bảy ngày tới ngày dùng gần nhất, ngày mới trước", async () => {
    const { g, ls } = await moLichSu();
    await within(ls).findByText("2 lần dùng từ 11/10/2026 đến 17/10/2026.");
    expect(g.filter((x) => x.method === "GET" && /^\/supply-items\/\d+$/.test(x.path)).map((x) => x.path)).toEqual(["/supply-items/7"]);
    expect((within(ls).getByLabelText("Từ ngày") as HTMLInputElement).value).toBe("2026-10-11");
    expect((within(ls).getByLabelText("Đến ngày") as HTMLInputElement).value).toBe("2026-10-17");
    const t = within(ls).getByRole("table", { name: "Ngày đã dùng Bột gạo" });
    expect(hang(t).map(o)).toEqual([["17/10/2026", "4 kg"], ["15/10/2026", "3,5 kg"]]);
    expect(within(t).queryByText("20 kg")).toBeNull();
  });
  it("đổi khoảng lọc trên sổ đã đọc, không gọi lại; khoảng sai báo lỗi; Xem lại 7 ngày", async () => {
    const { g, ls } = await moLichSu();
    await within(ls).findByText("2 lần dùng từ 11/10/2026 đến 17/10/2026.");
    go(ls, "Từ ngày", "2026-09-30");
    await within(ls).findByText("3 lần dùng từ 30/09/2026 đến 17/10/2026.");
    go(ls, "Từ ngày", "2026-10-20");
    await within(ls).findByText("Từ ngày phải trước hoặc bằng Đến ngày.");
    expect(within(ls).getByRole("alert")).toBeTruthy();
    fireEvent.click(within(ls).getByRole("button", { name: "Xem lại 7 ngày" }));
    expect((within(ls).getByLabelText("Từ ngày") as HTMLInputElement).value).toBe("2026-10-11");
    expect(g.filter((x) => x.path === "/supply-items/7")).toHaveLength(1);
  });
  it("sổ chưa có con số đã dùng và lỗi đọc sổ là hai câu khác nhau", async () => {
    const g = mo({ chiTiet: (id) => id === "7" ? { status: 200, body: { ...soBotGao, entries: [dong(1, "2026-10-17", "purchased", "20")] } } : { status: 500, body: { code: "internal" } } });
    const t = await bang();
    let { ct } = moThu(t, "Bột gạo");
    fireEvent.click(within(ct).getByRole("button", { name: "Lịch sử sử dụng" }));
    const ls = within(ct).getByRole("region", { name: "Lịch sử sử dụng Bột gạo" });
    await within(ls).findByText("Chưa có lần sử dụng nào.");
    expect(within(ls).queryByRole("alert")).toBeNull();
    ({ ct } = moThu(t, "Trứng"));
    fireEvent.click(within(ct).getByRole("button", { name: "Lịch sử sử dụng" }));
    const ls2 = within(ct).getByRole("region", { name: "Lịch sử sử dụng Trứng" });
    await within(ls2).findByText(/Chưa đọc được sổ của Trứng/);
    expect(within(ls2).getByRole("alert")).toBeTruthy();
    expect(within(ls2).queryByText("Chưa có lần sử dụng nào.")).toBeNull();
    expect(g.filter((x) => x.path === "/supply-items/9")).toHaveLength(1);
  });
});
