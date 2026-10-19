import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import type { components } from "@/lib/api/schema";
import Page from "./page";

const replace = vi.fn();
let thamSo = "";
vi.mock("next/navigation", () => ({ useRouter: () => ({ replace }), useSearchParams: () => new URLSearchParams(thamSo) }));
beforeEach(() => { thamSo = ""; replace.mockReset(); });
afterEach(cleanup);
type K = components["schemas"];
const thu: K["SupplyItem"] = { supply_item_id: 2, name: "Gạo", purchase_unit: null, purchased_total: "7", used_total: "11", balance: "-4", reminder_ratio: "0.2", latest_purchase_date: "2026-10-18", latest_purchase_measure: "7", reminder_status: "ready", check_reminder: true };
const dong: K["SupplyDayEntry"] = { supply_day_entry_id: 9, supply_item_id: 2, entry_date: "2026-10-18", kind: "purchased", measure: "1.250", person_id: 1, person_name: "Hoa", created_at: "2026-10-18T01:00:00Z" };
type Tra = { status: number; body?: unknown };
function mo(opts: { ghi?: (g: GoiDen) => Tra; doc?: () => Tra; so?: () => Tra } = {}) {
  return voiBackend(<Page />, (g) => {
    if (g.method !== "GET") return opts.ghi?.(g) ?? { status: 200, body: dong };
    if (g.path === "/supply-items") return opts.doc?.() ?? { status: 200, body: { supply_items: [thu, { ...thu, supply_item_id: 1, name: "Bột", purchase_unit: "kg" }] } };
    if (g.path === "/supply-items/2") return opts.so?.() ?? { status: 200, body: { ...thu, entries: [dong, { ...dong, supply_day_entry_id: 8, kind: "used", measure: "0.500", person_name: "Lan" }] } };
    return { status: 404, body: { code: "supply_item_not_found" } };
  });
}
const ghi = (g: GoiDen[]) => g.filter((x) => x.method !== "GET");
const doc = (g: GoiDen[], path: string) => g.filter((x) => x.method === "GET" && x.path === path);
const go = (f: HTMLElement, label: string, value: string) => fireEvent.change(within(f).getByLabelText(label), { target: { value } });
const gui = (f: HTMLElement) => fireEvent.submit(f);
const sai = (f: HTMLElement, label: string) => within(f).getByLabelText(label).getAttribute("aria-invalid");
async function formGhi() { const f = await screen.findByRole("form", { name: "Ghi con số" }); go(f, "Ngày", "2026-10-18"); go(f, "Loại", "purchased"); go(f, "Con số", " 1.250 "); return f; }

describe("Nguyên liệu", () => {
  it("giữ thứ tự danh mục, chưa có đơn vị; không bày số dư hay lời nhắc; chỉ đặt đơn vị lần đầu", async () => {
    mo(); const list = await screen.findByRole("list", { name: "Danh mục nguyên liệu" });
    expect(within(list).getAllByRole("listitem").map((x) => x.textContent)).toEqual(["GạoChưa có đơn vịĐặt đơn vị", "Bộtkg"]);
    expect(document.body.textContent).not.toMatch(/-4|0\.2|2026-10-18|ready|nhắc/i);
    expect(screen.getAllByRole("button", { name: /Đặt đơn vị/ })).toHaveLength(1);
    fireEvent.click(screen.getByRole("button", { name: "Gạo" })); expect(replace).toHaveBeenCalledWith("/chu-quan/nguyen-lieu?thu=2");
  });
  it("danh mục rỗng", async () => { mo({ doc: () => ({ status: 200, body: { supply_items: [] } }) }); expect(await screen.findByText("Chưa có nguyên liệu nào.")).toBeTruthy(); });
  it.each(["", " kg "])("thêm thứ với đơn vị '%s': gửi đúng thân và đọc lại", async (unit) => {
    const g = mo(); const f = await screen.findByRole("form", { name: "Thêm nguyên liệu" });
    go(f, "Tên nguyên liệu", " Rau "); go(f, "Đơn vị mua (tuỳ chọn)", unit); gui(f);
    await screen.findByText("Đã thêm nguyên liệu.");
    expect(ghi(g)).toEqual([{ method: "POST", path: "/supply-items", body: unit ? { name: "Rau", purchase_unit: "kg" } : { name: "Rau" } }]);
    expect(doc(g, "/supply-items")).toHaveLength(2);
  });
  it("tên trống không gửi; tên trùng gắn ô tên và giữ nháp", async () => {
    const g = mo({ ghi: () => ({ status: 409, body: { code: "supply_item_name_taken" } }) }); const f = await screen.findByRole("form", { name: "Thêm nguyên liệu" });
    gui(f); await waitFor(() => expect(sai(f, "Tên nguyên liệu")).toBe("true")); expect(ghi(g)).toHaveLength(0);
    go(f, "Tên nguyên liệu", "Gạo"); gui(f); await waitFor(() => expect(f.textContent).toMatch(/trùng/)); expect(sai(f, "Tên nguyên liệu")).toBe("true");
    expect((within(f).getByLabelText("Tên nguyên liệu") as HTMLInputElement).value).toBe("Gạo");
  });
  it.each([false, true])("đặt đơn vị đúng đường; đã có đơn vị thì báo và đọc lại (%s)", async (conflict) => {
    const g = mo({ ghi: () => conflict ? { status: 409, body: { code: "supply_item_unit_already_set" } } : { status: 200, body: { ...thu, purchase_unit: "kg" } } });
    fireEvent.click(await screen.findByRole("button", { name: "Đặt đơn vị Gạo" })); const f = screen.getByRole("form", { name: "Đặt đơn vị Gạo" }); go(f, "Đơn vị mua", " kg "); gui(f);
    await screen.findByText(conflict ? /Nguyên liệu đã có đơn vị/ : "Đã đặt đơn vị.");
    expect(ghi(g)).toEqual([{ method: "PUT", path: "/supply-items/2/purchase-unit", body: { purchase_unit: "kg" } }]); expect(doc(g, "/supply-items")).toHaveLength(2);
  });
  it("mở sổ đúng URL; giữ thứ tự, chuỗi, người ghi và đóng sổ", async () => {
    thamSo = "thu=2"; const g = mo(); const s = await screen.findByText(/2026-10-18 · Mua vào/);
    expect(s.textContent).toBe("2026-10-18 · Mua vào · 1.250 chưa có đơn vị · Hoa");
    const rows = within(screen.getByRole("region", { name: "Sổ nguyên liệu" })).getAllByRole("listitem"); expect(rows[1].textContent).toContain("Đã dùng · 0.500 chưa có đơn vị · Lan");
    expect(doc(g, "/supply-items/2")).toHaveLength(1); fireEvent.click(screen.getByRole("button", { name: "Đóng sổ" })); expect(replace).toHaveBeenCalledWith("/chu-quan/nguyen-lieu");
  });
  it("sổ rỗng", async () => { thamSo = "thu=2"; mo({ so: () => ({ status: 200, body: { ...thu, entries: [] } }) }); expect(await screen.findByText("Chưa ghi con số nào.")).toBeTruthy(); });
  it("ngày và loại chưa chọn không gửi; ghi giữ 1.250, đọc lại sổ", async () => {
    thamSo = "thu=2"; const g = mo(); const f = await screen.findByRole("form", { name: "Ghi con số" });
    expect((within(f).getByLabelText("Ngày") as HTMLInputElement).value).toBe(""); expect(within(f).getByLabelText("Ngày").getAttribute("type")).toBe("date");
    go(f, "Con số", "1.250"); gui(f); await waitFor(() => expect(sai(f, "Ngày")).toBe("true")); expect(sai(f, "Loại")).toBe("true"); expect(ghi(g)).toHaveLength(0);
    go(f, "Ngày", "2026-10-18"); go(f, "Loại", "purchased"); gui(f); await screen.findByText("Đã ghi con số.");
    expect(ghi(g)).toEqual([{ method: "POST", path: "/supply-day-entries", body: { supply_item_id: 2, entry_date: "2026-10-18", kind: "purchased", measure: "1.250" } }]);
    expect(doc(g, "/supply-items/2")).toHaveLength(2); expect(doc(g, "/supply-items")).toHaveLength(2);
  });
  it.each(["1,5", "-1", "1.2345", "1000000000", "01"])("con số sai khuôn %s không gửi", async (value) => {
    thamSo = "thu=2"; const g = mo(); const f = await formGhi(); go(f, "Con số", value); gui(f); await waitFor(() => expect(sai(f, "Con số")).toBe("true")); expect(ghi(g)).toHaveLength(0);
  });
  it.each([["entry_date", "Ngày"], ["kind", "Loại"], ["measure", "Con số"]])("400 field=%s gắn đúng ô", async (field, label) => {
    thamSo = "thu=2"; mo({ ghi: () => ({ status: 400, body: { code: "invalid_request", field } }) }); const f = await formGhi(); gui(f); await waitFor(() => expect(sai(f, label)).toBe("true"));
  });
  it("trùng con số báo dùng Sửa", async () => {
    thamSo = "thu=2"; mo({ ghi: () => ({ status: 409, body: { code: "supply_day_entry_already_recorded" } }) }); const f = await formGhi(); gui(f); expect(await screen.findByText(/Hãy dùng Sửa ở dòng đã có/)).toBeTruthy();
  });
  it("sửa mặc định chuỗi hiện tại; thiếu lý do không gửi; đủ gửi chỉ measure và reason", async () => {
    thamSo = "thu=2"; const g = mo(); fireEvent.click((await screen.findAllByRole("button", { name: "Sửa" }))[0]); const f = screen.getByRole("form", { name: "Sửa con số" });
    expect((within(f).getByLabelText("Con số") as HTMLInputElement).value).toBe("1.250"); gui(f); await waitFor(() => expect(sai(f, "Lý do")).toBe("true")); expect(ghi(g)).toHaveLength(0);
    go(f, "Con số", " 2.500 "); go(f, "Lý do", " Ghi nhầm "); gui(f); await screen.findByText("Đã sửa con số.");
    expect(ghi(g)).toEqual([{ method: "PUT", path: "/supply-day-entries/9", body: { measure: "2.500", reason: "Ghi nhầm" } }]); expect(doc(g, "/supply-items/2")).toHaveLength(2);
  });
  it("dòng không còn thì báo và đọc lại", async () => {
    thamSo = "thu=2"; const g = mo({ ghi: () => ({ status: 404, body: { code: "supply_day_entry_not_found" } }) }); fireEvent.click((await screen.findAllByRole("button", { name: "Sửa" }))[0]); const f = screen.getByRole("form", { name: "Sửa con số" }); go(f, "Lý do", "Sửa nhầm"); gui(f);
    await screen.findByText(/Không tìm thấy con số này/); expect(doc(g, "/supply-items/2")).toHaveLength(2);
  });
  it.each(["abc", "0", "-1", "1.5", ""])("URL thu=%s không hợp lệ không đọc sổ", async (id) => {
    thamSo = `thu=${id}`; const g = mo(); await screen.findByText("Không tìm thấy nguyên liệu này"); expect(screen.queryByRole("region", { name: "Sổ nguyên liệu" })).toBeNull(); expect(g.some((x) => x.path.startsWith("/supply-items/"))).toBe(false);
  });
  it("backend không tìm thấy thứ thì không bày sổ", async () => { thamSo = "thu=3"; mo(); await screen.findByText("Không tìm thấy nguyên liệu này"); expect(screen.queryByRole("region", { name: "Sổ nguyên liệu" })).toBeNull(); });
  it("phản hồi lạ giữ nháp và không tự gửi lại", async () => {
    thamSo = "thu=2"; const g = mo({ ghi: () => ({ status: 500, body: { strange: true } }) }); const f = await formGhi(); gui(f); await screen.findByText(/Chưa xác nhận được kết quả/);
    expect((within(f).getByLabelText("Con số") as HTMLInputElement).value).toBe(" 1.250 "); expect(ghi(g)).toHaveLength(1);
  });
  it("bấm gửi hai lần nhanh chỉ một lời gọi", async () => {
    thamSo = "thu=2"; const g = mo(); const f = await formGhi(); const b = within(f).getByRole("button", { name: "Ghi con số" }); fireEvent.click(b); fireEvent.click(b); await screen.findByText("Đã ghi con số."); expect(ghi(g)).toHaveLength(1);
  });
});
