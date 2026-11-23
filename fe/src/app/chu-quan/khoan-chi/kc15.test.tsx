// Test KC-15 (ADR-147 điểm 9–10; work/backlog_KC.md#kc-15): hai lịch sử của cả mục nguyên liệu. Claude viết TRƯỚC code; Codex
// làm cho xanh mà không sửa điều kiện kiểm nào.
//   - *Lịch sử sử dụng nguyên liệu*: đọc `GET /supply-items/{id}` của từng thứ trong mục, con số `used`, mỗi ngày một hàng, mới
//     trước; chọn một thứ hay tất cả; mở chi tiết một thứ (KC-11) thì chọn theo thứ ấy, đóng thì về tất cả. Một lời gọi hỏng thì
//     báo lỗi và không bày tập thiếu như đủ.
//   - *Lịch sử mua hàng*: đọc `listExpenses` chỉ với from · to · expense_category_id (không mang bộ lọc chung), mặc định 30 ngày tới
//     `last_paid_date` của mục; nhóm theo `received_date`, mới trước, khoản thiếu ngày nhập ở hàng riêng cuối.
//   - Hai khối Hiện/Ẩn độc lập, giữ lựa chọn; nút *Lịch sử mua hàng ↓* mở khối đang ẩn và đưa focus tới tiêu đề.
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
type GoiDen = { method: string; path: string; query: URLSearchParams };

const con = (id: number, name: string, supply: number): K["ExpenseItem"] => ({ expense_item_id: id, expense_category_id: 3, name, supply_item_id: supply, last_paid_date: null });
const loai: K["ExpenseCategory"][] = [{ expense_category_id: 3, name: "Nguyên liệu chính", paid_from_till: false, tracks_supply: true, last_paid_date: "2026-10-18",
  items: [con(31, "Bột gạo", 7), con(32, "Hành khô", 8), con(33, "Trứng", 9)] }];
const uoc: K["SupplyUsageEstimate"] = { status: "no_usage", usage_days: 0, used_in_window: "0", days_left: null };
const thu = (id: number, name: string, unit: string | null, item: number): K["SupplyItem"] => ({ supply_item_id: id, name, purchase_unit: unit, purchased_total: "10",
  used_total: "1", balance: "9", usage_estimate: uoc, reminder_ratio: "0.2", latest_purchase_date: "2026-10-17", latest_purchase_measure: "10",
  reminder_status: "ready", check_reminder: false, expense_item_id: item, expense_category_id: 3, stopped_at: null });
const so = [thu(7, "Bột gạo", "kg", 31), thu(8, "Hành khô", null, 32), thu(9, "Trứng", "quả", 33)];
const dong = (id: number, thuId: number, ngay: string, kind: "purchased" | "used", measure: string): K["SupplyDayEntry"] => ({
  supply_day_entry_id: id, supply_item_id: thuId, entry_date: ngay, kind, measure, person_id: 1, person_name: "Hoa", created_at: `${ngay}T01:00:00Z` });
const soTung: Record<string, K["SupplyItemDetail"]> = {
  7: { ...so[0], entries: [dong(1, 7, "2026-10-17", "purchased", "20"), dong(2, 7, "2026-10-17", "used", "4"), dong(3, 7, "2026-10-15", "used", "3.5")] },
  8: { ...so[1], entries: [dong(4, 8, "2026-10-17", "used", "0.5")] },
  9: { ...so[2], entries: [dong(5, 9, "2026-10-16", "used", "6")] },
};
const chi = (id: number, item: number, name: string, amt: number, paid: string, rec: string | null, who: string): K["Expense"] => ({
  expense_id: id, expense_category_id: 3, category_name: "Nguyên liệu chính", paid_from_till: false, amount_vnd: amt, paid_date: paid, received_date: rec,
  person_id: 1, person_name: who, created_at: `${paid}T01:00:00Z`, expense_item_id: item, item_name: name });
const mua: K["Expenses"] = { from: "2026-09-19", to: "2026-10-18", total_vnd: 410000, day_totals: [], expenses: [
  chi(44, 31, "Bột gạo", 100000, "2026-10-10", "2026-10-09", "Hoa"), chi(43, 33, "Trứng", 60000, "2026-10-16", null, "Hoa"),
  chi(41, 31, "Bột gạo", 200000, "2026-10-18", "2026-10-17", "Hoa"), chi(42, 32, "Hành khô", 50000, "2026-10-18", "2026-10-17", "Lan"),
] };
const ds: K["Expenses"] = { from: "2026-10-19", to: "2026-10-19", expenses: [], total_vnd: 0, day_totals: [], category_totals: [], item_totals: [] };

function mo(opts: { chiTiet?: (id: string) => Tra; mua?: () => Tra } = {}) {
  const goi: GoiDen[] = [];
  render(<ApiProvider fetch={async (req: Request) => {
    const u = new URL(req.url);
    const g: GoiDen = { method: req.method, path: u.pathname.replace(/^\/api/, ""), query: u.searchParams };
    goi.push(g);
    let r: Tra;
    const m = g.path.match(/^\/supply-items\/(\d+)$/);
    if (g.method !== "GET") r = { status: 500, body: { code: "internal" } };
    else if (g.path === "/owner-overview") r = { status: 200, body: { sale_date: "2026-10-19" } };
    else if (g.path === "/expense-categories") r = { status: 200, body: { expense_categories: loai } };
    else if (g.path === "/supply-items") r = { status: 200, body: { supply_items: so } };
    else if (m) r = opts.chiTiet?.(m[1]) ?? { status: 200, body: soTung[m[1]] };
    else if (g.path === "/expenses" && g.query.get("from") === "2026-10-19" && g.query.get("to") === "2026-10-19") r = { status: 200, body: ds };
    else if (g.path === "/expenses") r = opts.mua?.() ?? { status: 200, body: mua };
    else r = { status: 404, body: { code: "invalid_request" } };
    return new Response(r.body === undefined ? null : JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  }}><Page /></ApiProvider>);
  return goi;
}
const hang = (t: HTMLElement) => within(t).getAllByRole("row").slice(1);
const ngayO = (r: HTMLElement) => within(r).getAllByRole("cell")[0].textContent?.trim();
const cacLan = (r: HTMLElement) => within(r).getAllByRole("listitem").map((li) => li.textContent?.replace(/\s+/g, " ").trim());
const mucCho = async () => (await screen.findByRole("heading", { level: 3, name: "Nguyên liệu chính" })).closest("article") as HTMLElement;
const khoi = async (ten: string) => within(await mucCho()).getByRole("region", { name: ten });

describe("KC-15 — lịch sử sử dụng nguyên liệu", () => {
  it("đọc sổ từng thứ của mục, chỉ con số đã dùng, mỗi ngày một hàng, mới trước, các thứ cùng ngày nằm ngang theo tên", async () => {
    const g = mo();
    const k = await khoi("Lịch sử sử dụng nguyên liệu");
    const t = await within(k).findByRole("table", { name: "Ngày dùng nguyên liệu trong Nguyên liệu chính" });
    await waitFor(() => expect(hang(t)).toHaveLength(3));
    expect(hang(t).map(ngayO)).toEqual(["17/10/2026", "16/10/2026", "15/10/2026"]);
    expect(cacLan(hang(t)[0])).toEqual(["Bột gạo 4 kg", "Hành khô 0,5"]);
    expect(cacLan(hang(t)[1])).toEqual(["Trứng 6 quả"]);
    expect(cacLan(hang(t)[2])).toEqual(["Bột gạo 3,5 kg"]);
    expect(within(t).queryByText(/20 kg/)).toBeNull();
    expect(g.filter((x) => /^\/supply-items\/\d+$/.test(x.path)).map((x) => x.path).sort()).toEqual(["/supply-items/7", "/supply-items/8", "/supply-items/9"]);
  });
  it("chọn một thứ thì chỉ còn thứ ấy; mở chi tiết một thứ thì chọn theo nó, đóng thì về tất cả", async () => {
    mo();
    const k = await khoi("Lịch sử sử dụng nguyên liệu");
    const t = await within(k).findByRole("table", { name: "Ngày dùng nguyên liệu trong Nguyên liệu chính" });
    await waitFor(() => expect(hang(t)).toHaveLength(3));
    const chon = within(k).getByLabelText("Xem nguyên liệu") as HTMLSelectElement;
    expect(chon.value).toBe("");
    fireEvent.change(chon, { target: { value: "32" } });
    await waitFor(() => expect(hang(t)).toHaveLength(1));
    expect(cacLan(hang(t)[0])).toEqual(["Hành khô 0,5"]);
    fireEvent.change(chon, { target: { value: "" } });
    const bang = within(await mucCho()).getByRole("table", { name: "Nguyên liệu trong Nguyên liệu chính" });
    const nut = within(bang).getByRole("button", { name: "Trứng" });
    fireEvent.click(nut);
    await waitFor(() => expect(chon.value).toBe("33"));
    expect(hang(t).map(ngayO)).toEqual(["16/10/2026"]);
    fireEvent.click(nut);
    await waitFor(() => expect(chon.value).toBe(""));
    expect(hang(t)).toHaveLength(3);
  });
  it("một sổ không đọc được thì báo lỗi, không bày tập thiếu như đủ", async () => {
    mo({ chiTiet: (id) => id === "9" ? { status: 500, body: { code: "internal" } } : { status: 200, body: soTung[id] } });
    const k = await khoi("Lịch sử sử dụng nguyên liệu");
    await within(k).findByText(/Chưa đọc được sổ của Trứng/);
    expect(within(k).getByRole("alert")).toBeTruthy();
    expect(within(k).queryByRole("table", { name: "Ngày dùng nguyên liệu trong Nguyên liệu chính" })).toBeNull();
    expect(within(k).queryByText(/Chưa có ngày dùng nào/)).toBeNull();
  });
  it("chưa có con số đã dùng nào: câu rỗng nói đúng phạm vi chọn", async () => {
    mo({ chiTiet: (id) => ({ status: 200, body: { ...soTung[id], entries: [] } }) });
    const k = await khoi("Lịch sử sử dụng nguyên liệu");
    await within(k).findByText("Chưa có ngày dùng nào được ghi.");
    fireEvent.change(within(k).getByLabelText("Xem nguyên liệu"), { target: { value: "31" } });
    await within(k).findByText("Chưa có ngày dùng nào được ghi cho Bột gạo.");
  });
});

describe("KC-15 — lịch sử mua hàng", () => {
  it("đọc khoản chi của mục ngoài bộ lọc chung, 30 ngày tới lần chi gần nhất, nhóm theo ngày nhập, thiếu ngày nhập ở cuối", async () => {
    nav.search = "tu=2026-10-19&den=2026-10-19&nguon=rieng";
    const g = mo();
    const k = await khoi("Lịch sử mua hàng");
    const t = await within(k).findByRole("table", { name: "Các lần mua theo ngày nhập trong Nguyên liệu chính" });
    await waitFor(() => expect(hang(t)).toHaveLength(3));
    const q = g.filter((x) => x.path === "/expenses" && x.query.get("from") !== "2026-10-19").map((x) => Object.fromEntries(x.query));
    expect(q.at(-1)).toEqual({ from: "2026-09-19", to: "2026-10-18", expense_category_id: "3" });
    expect((within(k).getByLabelText("Từ ngày") as HTMLInputElement).value).toBe("2026-09-19");
    expect((within(k).getByLabelText("Đến ngày") as HTMLInputElement).value).toBe("2026-10-18");
    expect(hang(t).map(ngayO)).toEqual(["17/10/2026", "09/10/2026", "Chưa ghi ngày nhập"]);
    expect(cacLan(hang(t)[0])).toEqual([
      "Hành khô 50.000 đ Ngày chi: 18/10/2026 · Người ghi: Lan",
      "Bột gạo 200.000 đ Ngày chi: 18/10/2026 · Người ghi: Hoa",
    ]);
    expect(cacLan(hang(t)[2])).toEqual(["Trứng 60.000 đ Ngày chi: 16/10/2026 · Người ghi: Hoa"]);
  });
  it("chọn một nguyên liệu thì chỉ còn các lần mua của nó; đổi khoảng thì đọc lại; khoảng sai báo lỗi không gọi", async () => {
    const g = mo();
    const k = await khoi("Lịch sử mua hàng");
    const t = await within(k).findByRole("table", { name: "Các lần mua theo ngày nhập trong Nguyên liệu chính" });
    await waitFor(() => expect(hang(t)).toHaveLength(3));
    fireEvent.change(within(k).getByLabelText("Xem nguyên liệu"), { target: { value: "31" } });
    await waitFor(() => expect(hang(t)).toHaveLength(2));
    expect(hang(t).map(ngayO)).toEqual(["17/10/2026", "09/10/2026"]);
    const doc = () => g.filter((x) => x.path === "/expenses" && x.query.get("expense_category_id") === "3" && x.query.get("from") !== "2026-10-19");
    fireEvent.change(within(k).getByLabelText("Từ ngày"), { target: { value: "2026-10-01" } });
    await waitFor(() => expect(doc().at(-1)?.query.get("from")).toBe("2026-10-01"));
    const truoc = doc().length;
    fireEvent.change(within(k).getByLabelText("Từ ngày"), { target: { value: "2026-10-30" } });
    await within(k).findByText("Từ ngày phải trước hoặc bằng Đến ngày.");
    expect(doc()).toHaveLength(truoc);
  });
  it("đọc lỗi khác rỗng", async () => {
    mo({ mua: () => ({ status: 500, body: { code: "internal" } }) });
    const k = await khoi("Lịch sử mua hàng");
    await within(k).findByText(/Chưa đọc được lịch sử mua hàng/);
    expect(within(k).getByRole("alert")).toBeTruthy();
    expect(within(k).queryByText(/Chưa có lần mua/)).toBeNull();
  });
});

describe("KC-15 — hai khối", () => {
  it("Hiện/Ẩn độc lập, giữ lựa chọn; nút nhảy mở lịch sử mua hàng đang ẩn và đưa focus tới tiêu đề", async () => {
    mo();
    const sd = await khoi("Lịch sử sử dụng nguyên liệu");
    const mh = await khoi("Lịch sử mua hàng");
    await within(sd).findByRole("table", { name: "Ngày dùng nguyên liệu trong Nguyên liệu chính" });
    fireEvent.change(within(sd).getByLabelText("Xem nguyên liệu"), { target: { value: "32" } });
    const anSd = within(sd).getByRole("button", { name: "Ẩn lịch sử sử dụng nguyên liệu" });
    fireEvent.click(anSd);
    expect(anSd.getAttribute("aria-expanded")).toBe("false");
    expect(document.getElementById(anSd.getAttribute("aria-controls")!)?.hidden).toBe(true);
    expect(within(mh).getByRole("table", { name: "Các lần mua theo ngày nhập trong Nguyên liệu chính" })).toBeTruthy();
    fireEvent.click(within(sd).getByRole("button", { name: "Hiện lịch sử sử dụng nguyên liệu" }));
    expect((within(sd).getByLabelText("Xem nguyên liệu") as HTMLSelectElement).value).toBe("32");
    const anMh = within(mh).getByRole("button", { name: "Ẩn lịch sử mua hàng" });
    fireEvent.click(anMh);
    expect(document.getElementById(anMh.getAttribute("aria-controls")!)?.hidden).toBe(true);
    fireEvent.click(within(await mucCho()).getByRole("button", { name: "Lịch sử mua hàng ↓" }));
    expect(document.getElementById(anMh.getAttribute("aria-controls")!)?.hidden).toBe(false);
    await waitFor(() => expect(document.activeElement).toBe(within(mh).getByRole("heading", { name: "Lịch sử mua hàng" })));
  });
});
