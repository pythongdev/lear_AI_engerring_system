import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import Page from "./page";

let search = "";
const replace = vi.fn();
vi.mock("next/navigation", () => ({ useSearchParams: () => new URLSearchParams(search), useRouter: () => ({ replace }) }));
afterEach(() => { cleanup(); search = ""; replace.mockReset(); });
type K = components["schemas"];
type Tra = { status: number; body?: unknown };
type Goi = { method: string; path: string; body: unknown; query: URLSearchParams };
const con = (id: number, name: string, supply: number): K["ExpenseItem"] => ({ expense_item_id: id, expense_category_id: 3, name, supply_item_id: supply, last_paid_date: null });
const loai: K["ExpenseCategory"][] = [
  { expense_category_id: 3, name: "Nguyên liệu chính", paid_from_till: false, tracks_supply: true, last_paid_date: null, items: [con(31, "Bột gạo", 7), con(32, "Hành khô", 8)] },
  { expense_category_id: 4, name: "Điện", paid_from_till: true, tracks_supply: false, last_paid_date: null, items: [] },
];
const thu = (id: number, name: string, extra: Partial<K["SupplyItem"]> = {}): K["SupplyItem"] => ({
  supply_item_id: id, name, expense_item_id: null, expense_category_id: null, stopped_at: null, purchase_unit: "kg",
  purchased_total: "20", used_total: "7", balance: "13", usage_estimate: { status: "ready", usage_days: 2, used_in_window: "7", days_left: "3.7" },
  reminder_ratio: "0.2", latest_purchase_date: "2026-10-17", latest_purchase_measure: "20", reminder_status: "ready", check_reminder: false, ...extra,
});
const so: K["SupplyItem"][] = [thu(7, "Bột gạo", { expense_item_id: 31, expense_category_id: 3 }), thu(8, "Hành khô", { expense_item_id: 32, expense_category_id: 3 }), thu(9, "Chưa xếp"), thu(10, "Đã ngừng", { expense_item_id: 33, expense_category_id: 3, stopped_at: "2026-10-20T00:00:00Z" })];
const detail = (id: number): K["SupplyItemDetail"] => ({ ...so.find((s) => s.supply_item_id === id)!, entries: [{ supply_day_entry_id: id, supply_item_id: id, entry_date: "2026-10-17", kind: "used", measure: "2.5", person_id: 1, person_name: "Hoa", created_at: "2026-10-17T01:00:00Z" }] });
const expenses: K["Expenses"] = { from: "2026-10-19", to: "2026-10-19", expenses: [], total_vnd: 0, day_totals: [], category_totals: [], item_totals: [] };
function mo(opts: { ghi?: (g: Goi) => Tra; categories?: K["ExpenseCategory"][]; supplies?: K["SupplyItem"][] } = {}) {
  const goi: Goi[] = [];
  render(<ApiProvider fetch={async (req: Request) => {
    const url = new URL(req.url); const raw = await req.text();
    const g: Goi = { method: req.method, path: url.pathname.replace(/^\/api/, ""), query: url.searchParams, body: raw ? JSON.parse(raw) : undefined };
    goi.push(g);
    let r: Tra;
    if (g.method !== "GET") r = opts.ghi?.(g) ?? { status: 200, body: { ...so[0] } };
    else if (g.path === "/owner-overview") r = { status: 200, body: { sale_date: "2026-10-19" } };
    else if (g.path === "/expense-categories") r = { status: 200, body: { expense_categories: opts.categories ?? loai } };
    else if (g.path === "/supply-items") r = { status: 200, body: { supply_items: opts.supplies ?? so } };
    else if (/^\/supply-items\/\d+$/.test(g.path)) r = { status: 200, body: detail(Number(g.path.split("/").pop())) };
    else if (g.path === "/expenses") r = { status: 200, body: expenses };
    else r = { status: 404, body: { code: "invalid_request" } };
    return new Response(r.body === undefined ? null : JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  }}><Page /></ApiProvider>);
  return goi;
}
const viet = (g: Goi[]) => g.filter((x) => x.method !== "GET");
const go = (f: HTMLElement, label: string, value: string) => fireEvent.change(within(f).getByLabelText(label), { target: { value } });
async function nutTen(name: string) {
  const bang = await screen.findByRole("table", { name: "Nguyên liệu trong Nguyên liệu chính" });
  return within(bang).getByRole("button", { name });
}
async function moForm(kind: "Ghi lượng" | "Đặt tỉ lệ nhắc") {
  fireEvent.click(await nutTen("Bột gạo"));
  fireEvent.click(await screen.findByRole("button", { name: kind }));
  const form = await screen.findByRole("form", { name: `${kind} Bột gạo` });
  if (kind === "Ghi lượng") { go(form, "Ngày", "2026-10-19"); go(form, "Loại", "used"); go(form, "Con số", "1.250"); }
  else { go(form, "Tỉ lệ nhắc", "0.35"); go(form, "Lý do", "Đổi mức nhắc"); }
  return form;
}

describe("KC-14 — mở nguyên liệu theo URL", () => {
  it("thu hợp lệ mở đúng ngăn, chọn Xem nguyên liệu, cuộn và focus một lần; bộ lọc khác giữ nguyên", async () => {
    search = "thu=7&tu=2026-10-01&den=2026-10-19&loai=3&nguon=rieng";
    const scroll = vi.fn(); HTMLElement.prototype.scrollIntoView = scroll;
    const g = mo(); const nut = await nutTen("Bột gạo");
    await waitFor(() => expect(nut.getAttribute("aria-expanded")).toBe("true"));
    expect(document.activeElement).toBe(nut); expect(scroll).toHaveBeenCalledTimes(1);
    const muc = (await screen.findByRole("heading", { name: "Nguyên liệu chính" })).closest("article")!;
    expect((within(muc).getAllByLabelText("Xem nguyên liệu")[0] as HTMLSelectElement).value).toBe("31");
    expect((await nutTen("Hành khô")).getAttribute("aria-expanded")).toBe("false");
    expect(g.filter((x) => x.path === "/expenses").some((x) => x.query.get("from") === "2026-10-01" && x.query.get("to") === "2026-10-19" && x.query.get("expense_category_id") === "3" && x.query.get("paid_from_till") === "false")).toBe(true);
  });
  it.each(["0", "01", "-1", "1.5", "9007199254740992", "99", "9", "10"])("thu=%s không mở ngăn hoặc báo lỗi", async (id) => {
    search = `thu=${id}`;
    const categories = id === "10" ? [{ ...loai[0], items: [...loai[0].items!, con(33, "Đã ngừng", 10)] }, loai[1]] : undefined;
    mo({ categories });
    expect((await nutTen("Bột gạo")).getAttribute("aria-expanded")).toBe("false");
    expect((await nutTen("Hành khô")).getAttribute("aria-expanded")).toBe("false");
    if (id === "10") expect((await nutTen("Đã ngừng")).getAttribute("aria-expanded")).toBe("false");
    expect(document.body.textContent).not.toContain("Không tìm thấy nguyên liệu này");
  });
});

describe("KC-14 — ca ghi kế thừa từ hai trang cũ", () => {
  it.each([
    ["no_purchase", true, "chưa có lần mua"],
    ["latest_purchase_zero", true, "lần mua gần nhất bằng 0"],
    ["usage_before_first_purchase", true, "có số dùng trước lần mua đầu"],
    ["usage_before_first_purchase", false, "có số dùng trước lần mua đầu"],
  ])("trạng thái nhắc %s, cờ %s hiện đúng lý do %s", async (status, check, reason) => {
    mo({ supplies: [{ ...so[0], reminder_status: status as K["SupplyItem"]["reminder_status"], check_reminder: check }, ...so.slice(1)] });
    fireEvent.click(await nutTen("Bột gạo"));
    const detail = document.getElementById((await nutTen("Bột gạo")).getAttribute("aria-controls")!)!;
    const row = Array.from(detail.querySelectorAll("dl > div")).find((x) => x.querySelector("dt")?.textContent === "Nhắc kiểm tra")!;
    expect(row.querySelector("dd")?.textContent).toBe(`${check ? "Nhắc POS kiểm tra" : "Không nhắc"} · ${reason}`);
  });
  it.each(["Ghi lượng", "Đặt tỉ lệ nhắc"])("%s: bấm gửi hai lần nhanh chỉ một lời gọi", async (kind) => {
    const g = mo(); const form = await moForm(kind as "Ghi lượng" | "Đặt tỉ lệ nhắc");
    const nut = within(form).getByRole("button", { name: kind === "Ghi lượng" ? "Lưu con số" : "Lưu tỉ lệ" });
    fireEvent.click(nut); fireEvent.click(nut);
    await screen.findByText(kind === "Ghi lượng" ? "Đã ghi con số cho Bột gạo." : "Đã đặt tỉ lệ nhắc cho Bột gạo.");
    expect(viet(g)).toHaveLength(1);
  });
  it.each(["Ghi lượng", "Đặt tỉ lệ nhắc"])("%s: phản hồi 502 lạ giữ nháp, không tự gửi lại", async (kind) => {
    const g = mo({ ghi: () => ({ status: 502, body: { strange: true } }) });
    const form = await moForm(kind as "Ghi lượng" | "Đặt tỉ lệ nhắc"); fireEvent.submit(form);
    await within(form).findByText(/Chưa xác nhận được kết quả/);
    expect((within(form).getByLabelText(kind === "Ghi lượng" ? "Con số" : "Tỉ lệ nhắc") as HTMLInputElement).value).toBe(kind === "Ghi lượng" ? "1.250" : "0.35");
    expect(viet(g)).toHaveLength(1);
  });
  it.each(["0", "1", "1.000000", "0.000001", "0.350000"])("tỉ lệ biên %s gửi đúng chuỗi", async (value) => {
    const g = mo(); const form = await moForm("Đặt tỉ lệ nhắc"); go(form, "Tỉ lệ nhắc", value); fireEvent.submit(form);
    await screen.findByText("Đã đặt tỉ lệ nhắc cho Bột gạo.");
    expect(viet(g)[0].body).toEqual({ reminder_ratio: value, reason: "Đổi mức nhắc" });
  });
  it.each(["1.1", "1.5", "-0.1", "0,2", "0.1234567"])("tỉ lệ ngoài khuôn %s không gửi", async (value) => {
    const g = mo(); const form = await moForm("Đặt tỉ lệ nhắc"); go(form, "Tỉ lệ nhắc", value); fireEvent.submit(form);
    await waitFor(() => expect(within(form).getByLabelText("Tỉ lệ nhắc").getAttribute("aria-invalid")).toBe("true"));
    expect(viet(g)).toHaveLength(0);
  });
  it.each([["reminder_ratio", "Tỉ lệ nhắc"], ["reason", "Lý do"]])("lỗi 400 field=%s gắn đúng ô tỉ lệ và giữ nháp", async (field, label) => {
    const g = mo({ ghi: () => ({ status: 400, body: { code: "invalid_request", field } }) });
    const form = await moForm("Đặt tỉ lệ nhắc"); fireEvent.submit(form);
    await waitFor(() => expect(within(form).getByLabelText(label).getAttribute("aria-invalid")).toBe("true"));
    expect((within(form).getByLabelText("Tỉ lệ nhắc") as HTMLInputElement).value).toBe("0.35");
    expect(viet(g)).toHaveLength(1);
  });
  it.each(["1,5", "-1", "1.2345", "1000000000", "01"])("con số sai khuôn %s không gửi", async (value) => {
    const g = mo(); const form = await moForm("Ghi lượng"); go(form, "Con số", value); fireEvent.submit(form);
    await waitFor(() => expect(within(form).getByLabelText("Con số").getAttribute("aria-invalid")).toBe("true"));
    expect(viet(g)).toHaveLength(0);
  });
  it("Ghi lượng thiếu ngày và loại không gửi; đủ thì gửi đúng chuỗi", async () => {
    const g = mo(); const form = await moForm("Ghi lượng");
    go(form, "Ngày", ""); go(form, "Loại", ""); fireEvent.submit(form);
    await waitFor(() => expect(within(form).getByLabelText("Ngày").getAttribute("aria-invalid")).toBe("true"));
    expect(within(form).getByLabelText("Loại").getAttribute("aria-invalid")).toBe("true");
    expect(viet(g)).toHaveLength(0);
    go(form, "Ngày", "2026-10-19"); go(form, "Loại", "used"); fireEvent.submit(form);
    await screen.findByText("Đã ghi con số cho Bột gạo.");
    expect(viet(g)[0].body).toEqual({ supply_item_id: 7, entry_date: "2026-10-19", kind: "used", measure: "1.250" });
  });
  it.each([["entry_date", "Ngày"], ["kind", "Loại"], ["measure", "Con số"]])("lỗi 400 field=%s gắn đúng ô lượng", async (field, label) => {
    const g = mo({ ghi: () => ({ status: 400, body: { code: "invalid_request", field } }) });
    const form = await moForm("Ghi lượng"); fireEvent.submit(form);
    await waitFor(() => expect(within(form).getByLabelText(label).getAttribute("aria-invalid")).toBe("true"));
    expect(viet(g)).toHaveLength(1);
  });
  it("nguyên liệu mất khi đặt tỉ lệ: báo lỗi và đọc lại danh mục", async () => {
    const g = mo({ ghi: () => ({ status: 404, body: { code: "supply_item_not_found" } }) });
    const form = await moForm("Đặt tỉ lệ nhắc");
    const truoc = g.filter((x) => x.path === "/supply-items").length;
    fireEvent.submit(form);
    await within(form).findByText(/Không tìm thấy nguyên liệu này/);
    await waitFor(() => expect(g.filter((x) => x.path === "/supply-items").length).toBeGreaterThan(truoc));
    expect(viet(g)).toHaveLength(1);
  });
  it("con số mất khi sửa: báo lỗi và đọc lại sổ", async () => {
    const g = mo({ ghi: () => ({ status: 404, body: { code: "supply_day_entry_not_found" } }) });
    fireEvent.click(await nutTen("Bột gạo"));
    fireEvent.click(await screen.findByRole("button", { name: "Sổ lượng" }));
    fireEvent.click(await screen.findByRole("button", { name: "Sửa con số Đã dùng ngày 17/10/2026" }));
    const form = await screen.findByRole("form", { name: "Sửa con số Bột gạo" });
    go(form, "Lý do", "Ghi nhầm"); fireEvent.submit(form);
    await within(form).findByText(/Không tìm thấy con số này/);
    await waitFor(() => expect(g.filter((x) => x.path === "/supply-items/7")).toHaveLength(2));
    expect(viet(g)).toHaveLength(1);
  });
});
