// Test KC-16 (ADR-147 điểm 2, 4, 9, 12; work/backlog_KC.md#kc-16): việc của trang Kho và Nguyên liệu trên trang Khoản chi,
// bằng các cửa `supply-*` và `expense-items` đang có. Claude viết TRƯỚC code; Codex làm cho xanh mà không sửa điều kiện kiểm nào.
//   - Ngăn chi tiết của một nguyên liệu: hai tổng, lượng nhập gần nhất, tỉ lệ nhắc, lời nhắc; Ghi lượng · Sổ lượng (sửa có lý do)
//     · Đặt tỉ lệ nhắc · Chuyển mục (chỉ mục cùng theo dõi lượng và cùng nguồn tiền) · Đặt đơn vị (chỉ khi chưa có).
//   - Hai nhóm cấp trang: *Nguyên liệu chưa xếp mục* (thứ chưa có `expense_item_id`, chưa ngừng) và *Nguyên liệu đã ngừng dùng*.
//   - Không tự tính lượng: chỉ hiện chuỗi của backend, đổi dấu chấm thành dấu phẩy; lỗi của sổ hiện đúng ô.
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

const con = (id: number, name: string, supply: number, cat = 3): K["ExpenseItem"] => ({ expense_item_id: id, expense_category_id: cat, name, supply_item_id: supply, last_paid_date: null });
// Mục 3 theo dõi lượng, tiền riêng. Mục 4 theo dõi nhưng trả từ két (khác nguồn). Mục 5 theo dõi, tiền riêng (chuyển được).
const loaiDu: K["ExpenseCategory"][] = [
  { expense_category_id: 2, name: "Điện", paid_from_till: true, tracks_supply: false, last_paid_date: null, items: [] },
  { expense_category_id: 3, name: "Nguyên liệu chính", paid_from_till: false, tracks_supply: true, last_paid_date: null, items: [con(31, "Bột gạo", 7), con(32, "Hành khô", 8)] },
  { expense_category_id: 4, name: "Đồ đóng gói", paid_from_till: true, tracks_supply: true, last_paid_date: null, items: [] },
  { expense_category_id: 5, name: "Rau gia vị", paid_from_till: false, tracks_supply: true, last_paid_date: null, items: [] },
];
const uoc: K["SupplyUsageEstimate"] = { status: "ready", usage_days: 2, used_in_window: "7", days_left: "3.7" };
const thu = (id: number, name: string, extra: Partial<K["SupplyItem"]> = {}): K["SupplyItem"] => ({
  supply_item_id: id, name, purchase_unit: "kg", purchased_total: "20", used_total: "7", balance: "13", usage_estimate: uoc,
  reminder_ratio: "0.2", latest_purchase_date: "2026-10-17", latest_purchase_measure: "20", reminder_status: "ready", check_reminder: false,
  expense_item_id: null, expense_category_id: null, stopped_at: null, ...extra,
});
const soDu: K["SupplyItem"][] = [
  thu(7, "Bột gạo", { expense_item_id: 31, expense_category_id: 3 }),
  thu(8, "Hành khô", { expense_item_id: 32, expense_category_id: 3, purchase_unit: null, purchased_total: "0", used_total: "0", balance: "0",
    usage_estimate: { status: "out_by_ledger", usage_days: 0, used_in_window: "0", days_left: null },
    latest_purchase_date: null, latest_purchase_measure: null, reminder_status: "no_purchase", check_reminder: true }),
  thu(70, "Đường"),
  thu(14, "Ớt", { expense_item_id: 37, expense_category_id: 3, stopped_at: "2026-10-10T03:00:00Z" }),
];
const ds: K["Expenses"] = { from: "2026-10-19", to: "2026-10-19", expenses: [], total_vnd: 0, day_totals: [], category_totals: [], item_totals: [] };
const dong = (id: number, ngay: string, kind: "purchased" | "used", measure: string): K["SupplyDayEntry"] => ({
  supply_day_entry_id: id, supply_item_id: 7, entry_date: ngay, kind, measure, person_id: 1, person_name: "Hoa", created_at: `${ngay}T01:00:00Z` });
const soBotGao: K["SupplyItemDetail"] = { ...soDu[0], entries: [dong(1, "2026-10-17", "purchased", "20"), dong(2, "2026-10-17", "used", "4"), dong(3, "2026-10-15", "used", "3.5")] };

function mo(opts: { loai?: K["ExpenseCategory"][]; so?: K["SupplyItem"][]; ghi?: (g: GoiDen) => Tra | undefined } = {}) {
  const goi: GoiDen[] = [];
  render(<ApiProvider fetch={async (req: Request) => {
    const text = await req.text(); const u = new URL(req.url);
    const g: GoiDen = { method: req.method, path: u.pathname.replace(/^\/api/, ""), query: u.searchParams, body: text ? JSON.parse(text) : undefined };
    goi.push(g);
    let r: Tra;
    const m = g.path.match(/^\/supply-items\/(\d+)$/);
    if (g.method !== "GET") r = opts.ghi?.(g) ?? { status: 200, body: { expense_item_id: 31, expense_category_id: 3, name: "Bột gạo", supply_item_id: 7 } };
    else if (g.path === "/owner-overview") r = { status: 200, body: { sale_date: "2026-10-19" } };
    else if (g.path === "/expense-categories") r = { status: 200, body: { expense_categories: opts.loai ?? loaiDu } };
    else if (g.path === "/supply-items") r = { status: 200, body: { supply_items: opts.so ?? soDu } };
    else if (m) r = { status: 200, body: m[1] === "7" ? soBotGao : { ...soDu[1], entries: [] } };
    else if (g.path === "/expenses") r = { status: 200, body: ds };
    else r = { status: 404, body: { code: "invalid_request" } };
    return new Response(r.body === undefined ? null : JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  }}><Page /></ApiProvider>);
  return goi;
}
const hang = (t: HTMLElement) => within(t).getAllByRole("row").slice(1);
const o = (r: HTMLElement) => within(r).getAllByRole("cell").map((c) => c.textContent?.trim());
const go = (f: HTMLElement, label: string, value: string) => fireEvent.change(within(f).getByLabelText(label), { target: { value } });
const dem = (g: GoiDen[], path: string, method = "GET") => g.filter((x) => x.method === method && x.path === path).length;
const viet = (g: GoiDen[]) => g.filter((x) => x.method !== "GET");
const sai = (f: HTMLElement, label: string) => within(f).getByLabelText(label).getAttribute("aria-invalid") === "true";
const mucCho = async (ten: string) => (await screen.findByRole("heading", { level: 3, name: ten })).closest("article") as HTMLElement;
async function bang() {
  const t = await within(await mucCho("Nguyên liệu chính")).findByRole("table", { name: "Nguyên liệu trong Nguyên liệu chính" });
  await waitFor(() => expect(within(t).getByText("Khoảng 3,7 ngày")).toBeTruthy());
  return t;
}
async function moThu(ten: string) {
  const nut = within(await bang()).getByRole("button", { name: ten });
  fireEvent.click(nut);
  return document.getElementById(nut.getAttribute("aria-controls")!)!;
}
const theCap = (ct: HTMLElement) => Object.fromEntries(Array.from(ct.querySelectorAll("dl > div")).map((d) => [d.querySelector("dt")?.textContent?.trim(), d.querySelector("dd")?.textContent?.trim()]));
async function hop(ct: HTMLElement, nut: string, form: string) {
  fireEvent.click(within(ct).getByRole("button", { name: nut }));
  return screen.findByRole("form", { name: form });
}
async function xong(thongBao: string) {
  await screen.findByText(thongBao);
  await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
}

describe("KC-16 — ngăn chi tiết đủ việc của trang Kho", () => {
  it("hiện hai tổng, lượng nhập gần nhất, tỉ lệ nhắc và lời nhắc đúng chuỗi backend; Đặt đơn vị chỉ khi chưa có đơn vị", async () => {
    mo();
    let ct = await moThu("Bột gạo");
    expect(theCap(ct)).toMatchObject({ "Đơn vị mua": "kg", "Tổng mua vào": "20 kg", "Tổng đã dùng": "7 kg", "Lượng nhập gần nhất": "20 kg", "Tỉ lệ nhắc": "0,2", "Nhắc kiểm tra": "Không nhắc" });
    for (const n of ["Ghi lượng", "Sổ lượng", "Đặt tỉ lệ nhắc", "Chuyển mục"]) expect(within(ct).getByRole("button", { name: n })).toBeTruthy();
    expect(within(ct).queryByRole("button", { name: "Đặt đơn vị" })).toBeNull();
    ct = await moThu("Hành khô");
    expect(theCap(ct)).toMatchObject({ "Đơn vị mua": "Chưa có đơn vị", "Tổng mua vào": "0", "Tổng đã dùng": "0", "Lượng nhập gần nhất": "Chưa có lần mua", "Nhắc kiểm tra": "Nhắc POS kiểm tra · chưa có lần mua" });
    expect(within(ct).getByRole("button", { name: "Đặt đơn vị" })).toBeTruthy();
  });
  it("Đặt đơn vị gửi đúng cửa; đơn vị đã có thì báo và đọc lại sổ", async () => {
    let lan = 0;
    const g = mo({ ghi: () => (lan++ === 0 ? { status: 409, body: { code: "supply_item_unit_already_set" } } : { status: 200, body: { ...soDu[1], purchase_unit: "kg" } }) });
    const ct = await moThu("Hành khô");
    const f = await hop(ct, "Đặt đơn vị", "Đặt đơn vị Hành khô");
    const truoc = dem(g, "/supply-items");
    go(f, "Đơn vị mua", "kg"); fireEvent.submit(f);
    await within(f).findByText(/đã có đơn vị/);
    await waitFor(() => expect(dem(g, "/supply-items")).toBeGreaterThan(truoc));
    fireEvent.submit(f);
    await xong("Đã đặt đơn vị cho Hành khô.");
    expect(viet(g).map((x) => [x.method, x.path, x.body])).toEqual([
      ["PUT", "/supply-items/8/purchase-unit", { purchase_unit: "kg" }], ["PUT", "/supply-items/8/purchase-unit", { purchase_unit: "kg" }]]);
  });
  it("Đặt tỉ lệ nhắc: tỉ lệ ngoài 0…1 hay thiếu lý do không gửi; hợp lệ thì gửi chuỗi như đã gõ và đọc lại sổ", async () => {
    const g = mo({ ghi: () => ({ status: 200, body: { ...soDu[0], reminder_ratio: "0.25" } }) });
    const ct = await moThu("Bột gạo");
    const f = await hop(ct, "Đặt tỉ lệ nhắc", "Đặt tỉ lệ nhắc Bột gạo");
    expect((within(f).getByLabelText("Tỉ lệ nhắc") as HTMLInputElement).value).toBe("0.2");
    go(f, "Tỉ lệ nhắc", "1.5"); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Tỉ lệ nhắc")).toBe(true));
    expect(sai(f, "Lý do")).toBe(true);
    expect(viet(g)).toHaveLength(0);
    const truoc = dem(g, "/supply-items");
    go(f, "Tỉ lệ nhắc", "0.25"); go(f, "Lý do", "Hay hết"); fireEvent.submit(f);
    await xong("Đã đặt tỉ lệ nhắc cho Bột gạo.");
    expect(viet(g).map((x) => [x.method, x.path, x.body])).toEqual([["PUT", "/supply-items/7/reminder-ratio", { reminder_ratio: "0.25", reason: "Hay hết" }]]);
    await waitFor(() => expect(dem(g, "/supply-items")).toBeGreaterThan(truoc));
  });
});

describe("KC-16 — ghi và sửa con số của sổ", () => {
  it("Ghi lượng gửi đúng thứ, ngày, loại, con số như đã gõ; sai khuôn con số không gửi; xong thì đọc lại sổ", async () => {
    const g = mo({ ghi: () => ({ status: 201, body: dong(9, "2026-10-19", "used", "2.5") }) });
    const ct = await moThu("Bột gạo");
    const f = await hop(ct, "Ghi lượng", "Ghi lượng Bột gạo");
    go(f, "Ngày", "2026-10-19"); go(f, "Loại", "used"); go(f, "Con số", "2,5"); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Con số")).toBe(true));
    expect(viet(g)).toHaveLength(0);
    const truoc = dem(g, "/supply-items/7");
    go(f, "Con số", "2.5"); fireEvent.submit(f);
    await xong("Đã ghi con số cho Bột gạo.");
    expect(viet(g).map((x) => [x.method, x.path, x.body])).toEqual([["POST", "/supply-day-entries", { supply_item_id: 7, entry_date: "2026-10-19", kind: "used", measure: "2.5" }]]);
    await waitFor(() => expect(dem(g, "/supply-items/7")).toBeGreaterThan(truoc));
  });
  it("con số trùng thứ/ngày/loại báo ở ô Ngày, giữ nháp; thứ đã ngừng báo ở hộp và đọc lại danh mục lẫn sổ", async () => {
    let lan = 0;
    const g = mo({ ghi: () => (lan++ === 0 ? { status: 409, body: { code: "supply_day_entry_already_recorded" } } : { status: 409, body: { code: "supply_item_stopped" } }) });
    const ct = await moThu("Bột gạo");
    const f = await hop(ct, "Ghi lượng", "Ghi lượng Bột gạo");
    go(f, "Ngày", "2026-10-17"); go(f, "Loại", "purchased"); go(f, "Con số", "20"); fireEvent.submit(f);
    await within(f).findByText(/Đã có con số/);
    expect(sai(f, "Ngày")).toBe(true);
    expect((within(f).getByLabelText("Con số") as HTMLInputElement).value).toBe("20");
    const [loai, so] = [dem(g, "/expense-categories"), dem(g, "/supply-items")];
    fireEvent.submit(f);
    await within(f).findByText(/đã ngừng dùng/);
    await waitFor(() => expect([dem(g, "/expense-categories") > loai, dem(g, "/supply-items") > so]).toEqual([true, true]));
    expect(screen.getByRole("dialog")).toBeTruthy();
  });
  it("Sổ lượng liệt kê mọi con số theo thứ tự backend; Sửa đòi lý do, chỉ gửi con số và lý do", async () => {
    const g = mo({ ghi: () => ({ status: 200, body: dong(3, "2026-10-15", "used", "3.25") }) });
    const ct = await moThu("Bột gạo");
    const nut = within(ct).getByRole("button", { name: "Sổ lượng" });
    expect(nut.getAttribute("aria-expanded")).toBe("false");
    fireEvent.click(nut);
    expect(nut.getAttribute("aria-expanded")).toBe("true");
    const s = within(ct).getByRole("region", { name: "Sổ lượng Bột gạo" });
    const t = await within(s).findByRole("table", { name: "Các con số của Bột gạo" });
    expect(within(t).getAllByRole("columnheader").map((c) => c.textContent)).toEqual(["Ngày", "Loại", "Con số", "Người ghi", "Sửa"]);
    expect(hang(t).map(o)).toEqual([
      ["17/10/2026", "Mua vào", "20 kg", "Hoa", "Sửa"], ["17/10/2026", "Đã dùng", "4 kg", "Hoa", "Sửa"], ["15/10/2026", "Đã dùng", "3,5 kg", "Hoa", "Sửa"]]);
    const f = await hop(t, "Sửa con số Đã dùng ngày 15/10/2026", "Sửa con số Bột gạo");
    expect((within(f).getByLabelText("Con số") as HTMLInputElement).value).toBe("3.5");
    go(f, "Con số", "3.25"); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Lý do")).toBe(true));
    expect(viet(g)).toHaveLength(0);
    const truoc = dem(g, "/supply-items/7");
    go(f, "Lý do", "Cân lại"); fireEvent.submit(f);
    await xong("Đã sửa con số cho Bột gạo.");
    expect(viet(g).map((x) => [x.method, x.path, x.body])).toEqual([["PUT", "/supply-day-entries/3", { measure: "3.25", reason: "Cân lại" }]]);
    await waitFor(() => expect(dem(g, "/supply-items/7")).toBeGreaterThan(truoc));
  });
  it("sổ chưa có con số nào thì nói rõ, không bày bảng rỗng", async () => {
    mo();
    const ct = await moThu("Hành khô");
    fireEvent.click(within(ct).getByRole("button", { name: "Sổ lượng" }));
    const s = within(ct).getByRole("region", { name: "Sổ lượng Hành khô" });
    await within(s).findByText("Chưa ghi con số nào.");
    expect(within(s).queryByRole("table")).toBeNull();
  });
});

describe("KC-16 — chuyển mục", () => {
  it("chỉ cho chọn mục khác cùng theo dõi lượng và cùng nguồn tiền; gửi mã mục và lý do; đọc lại danh mục và khoản chi", async () => {
    const g = mo({ ghi: () => ({ status: 200, body: con(31, "Bột gạo", 7, 5) }) });
    const ct = await moThu("Bột gạo");
    const f = await hop(ct, "Chuyển mục", "Chuyển mục Bột gạo");
    expect(Array.from((within(f).getByLabelText("Chuyển sang mục") as HTMLSelectElement).options).map((x) => x.textContent)).toEqual(["Chọn mục", "Rau gia vị"]);
    const [loai, chi] = [dem(g, "/expense-categories"), dem(g, "/expenses")];
    go(f, "Chuyển sang mục", "5"); go(f, "Lý do", "Gom rau"); fireEvent.submit(f);
    await xong("Đã chuyển Bột gạo sang Rau gia vị.");
    expect(viet(g).map((x) => [x.method, x.path, x.body])).toEqual([["PUT", "/expense-items/31/category", { expense_category_id: 5, reason: "Gom rau" }]]);
    await waitFor(() => expect([dem(g, "/expense-categories") > loai, dem(g, "/expenses") > chi]).toEqual([true, true]));
  });
  it("không có mục nào chuyển được thì nói rõ và không có nút gửi; backend từ chối thì báo ở hộp", async () => {
    mo({ loai: loaiDu.filter((l) => l.expense_category_id !== 5) });
    let ct = await moThu("Bột gạo");
    fireEvent.click(within(ct).getByRole("button", { name: "Chuyển mục" }));
    const d = await screen.findByRole("dialog");
    await within(d).findByText("Không có mục theo dõi lượng nào khác cùng nguồn tiền.");
    expect(within(d).queryByRole("button", { name: "Chuyển mục" })).toBeNull();
    cleanup();
    mo({ ghi: () => ({ status: 409, body: { code: "expense_item_move_not_allowed" } }) });
    ct = await moThu("Bột gạo");
    const f = await hop(ct, "Chuyển mục", "Chuyển mục Bột gạo");
    go(f, "Chuyển sang mục", "5"); go(f, "Lý do", "Gom rau"); fireEvent.submit(f);
    await within(f).findByText(/cùng nguồn tiền/);
  });
});

describe("KC-16 — nguyên liệu chưa xếp mục và đã ngừng dùng", () => {
  it("nhóm Chưa xếp mục chỉ có thứ chưa nối và chưa ngừng; xếp bằng mã thứ, không gửi tên; đọc lại danh mục và sổ", async () => {
    const g = mo({ ghi: () => ({ status: 201, body: con(38, "Đường", 70, 4) }) });
    await bang();
    const nhom = await screen.findByRole("region", { name: "Nguyên liệu chưa xếp mục" });
    const dsChua = within(nhom).getAllByRole("listitem").map((li) => li.textContent ?? "");
    expect(dsChua).toHaveLength(1);
    expect(dsChua[0]).toMatch(/^Đường/);
    const f = await hop(nhom, "Xếp Đường vào mục", "Xếp Đường vào mục");
    expect(Array.from((within(f).getByLabelText("Mục chi") as HTMLSelectElement).options).map((x) => x.textContent)).toEqual(["Chọn mục chi", "Nguyên liệu chính", "Đồ đóng gói", "Rau gia vị"]);
    fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Mục chi")).toBe(true));
    expect(viet(g)).toHaveLength(0);
    const [loai, so] = [dem(g, "/expense-categories"), dem(g, "/supply-items")];
    go(f, "Mục chi", "4"); fireEvent.submit(f);
    await xong("Đã xếp Đường vào Đồ đóng gói.");
    expect(viet(g).map((x) => [x.method, x.path, x.body])).toEqual([["POST", "/expense-items", { expense_category_id: 4, supply_item_id: 70 }]]);
    await waitFor(() => expect([dem(g, "/expense-categories") > loai, dem(g, "/supply-items") > so]).toEqual([true, true]));
  });
  it("thứ đã được nối nơi khác thì báo ở hộp và đọc lại sổ", async () => {
    const g = mo({ ghi: () => ({ status: 409, body: { code: "supply_item_already_linked" } }) });
    await bang();
    const nhom = await screen.findByRole("region", { name: "Nguyên liệu chưa xếp mục" });
    const f = await hop(nhom, "Xếp Đường vào mục", "Xếp Đường vào mục");
    const so = dem(g, "/supply-items");
    go(f, "Mục chi", "3"); fireEvent.submit(f);
    await within(f).findByText(/đã nằm trong một mục/);
    await waitFor(() => expect(dem(g, "/supply-items")).toBeGreaterThan(so));
  });
  it("nhóm Đã ngừng dùng có Dùng lại: đòi lý do, gửi đúng khoản con; xong thì đọc lại; thứ không còn ngừng thì báo ở hộp", async () => {
    let lan = 0;
    const g = mo({ ghi: () => (lan++ === 0 ? { status: 409, body: { code: "expense_item_not_stopped" } } : { status: 200, body: con(37, "Ớt", 14) }) });
    await bang();
    const nhom = await screen.findByRole("region", { name: "Nguyên liệu đã ngừng dùng" });
    const dsNgung = within(nhom).getAllByRole("listitem").map((li) => li.textContent ?? "");
    expect(dsNgung).toHaveLength(1);
    expect(dsNgung[0]).toMatch(/^Ớt · Nguyên liệu chính/);
    const f = await hop(nhom, "Dùng lại Ớt", "Dùng lại Ớt");
    fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Lý do")).toBe(true));
    expect(viet(g)).toHaveLength(0);
    go(f, "Lý do", "Mua lại"); fireEvent.submit(f);
    await within(f).findByText(/không còn ngừng dùng/);
    const [loai, so] = [dem(g, "/expense-categories"), dem(g, "/supply-items")];
    fireEvent.submit(f);
    await xong("Đã dùng lại Ớt.");
    expect(viet(g).map((x) => [x.method, x.path, x.body])).toEqual([
      ["POST", "/expense-items/37/reopen", { reason: "Mua lại" }], ["POST", "/expense-items/37/reopen", { reason: "Mua lại" }]]);
    await waitFor(() => expect([dem(g, "/expense-categories") > loai, dem(g, "/supply-items") > so]).toEqual([true, true]));
  });
  it("không có thứ chưa xếp mục hay đã ngừng thì không bày hai nhóm", async () => {
    mo({ so: soDu.filter((s) => s.expense_item_id !== null && s.stopped_at === null) });
    await bang();
    expect(screen.queryByRole("region", { name: "Nguyên liệu chưa xếp mục" })).toBeNull();
    expect(screen.queryByRole("region", { name: "Nguyên liệu đã ngừng dùng" })).toBeNull();
  });
});
