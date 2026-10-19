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
const loai: K["ExpenseCategory"][] = [{ expense_category_id: 2, name: "Điện", paid_from_till: true }, { expense_category_id: 1, name: "Marketing", paid_from_till: false }];
const khoan: K["Expense"] = { expense_id: 9, expense_category_id: 2, category_name: "Điện", paid_from_till: false, amount_vnd: 125000, paid_date: "2026-10-18", person_id: 1, person_name: "Hoa", created_at: "2026-10-18T01:00:00Z" };
const ds: K["Expenses"] = { from: "2026-10-19", to: "2026-10-19", expenses: [khoan], total_vnd: 987654 };
type Tra = { status: number; body?: unknown };
type GoiDen = { method: string; path: string; body: unknown };
// Như test-utils nhưng giữ cả chuỗi tham số trong path, vì trang lọc khoản chi bằng tham số (giống giao-viec.test.tsx).
function voiBackend(ui: React.ReactElement, traLoi: (g: GoiDen) => Tra) {
  const goi: GoiDen[] = [];
  render(<ApiProvider fetch={async (req: Request) => {
    const text = await req.text(); const u = new URL(req.url);
    const g = { method: req.method, path: u.pathname.replace(/^\/api/, "") + u.search, body: text ? JSON.parse(text) : undefined };
    goi.push(g); const r = traLoi(g);
    return new Response(r.body === undefined ? null : JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  }}>{ui}</ApiProvider>);
  return goi;
}
function mo(opts: { ghi?: (g: GoiDen) => Tra; doc?: () => Tra; loai?: () => Tra; ngay?: () => Tra } = {}) {
  return voiBackend(<Page />, (g) => {
    if (g.method !== "GET") return opts.ghi?.(g) ?? { status: 200, body: khoan };
    if (g.path === "/owner-overview") return opts.ngay?.() ?? { status: 200, body: { sale_date: "2026-10-19" } };
    if (g.path === "/expense-categories") return opts.loai?.() ?? { status: 200, body: { expense_categories: loai } };
    if (g.path.startsWith("/expenses?")) return opts.doc?.() ?? { status: 200, body: ds };
    return { status: 404, body: { code: "invalid_request" } };
  });
}
const ghi = (g: GoiDen[]) => g.filter((x) => x.method !== "GET");
const doc = (g: GoiDen[], path = "/expenses?") => g.filter((x) => x.method === "GET" && x.path.startsWith(path));
const go = (f: HTMLElement, label: string, value: string) => fireEvent.change(within(f).getByLabelText(label), { target: { value } });
const sai = (f: HTMLElement, label: string) => within(f).getByLabelText(label).getAttribute("aria-invalid");
const gui = (f: HTMLElement) => fireEvent.submit(f);
async function formGhi() {
  await screen.findByRole("list", { name: "Danh sách loại chi" });
  fireEvent.click(screen.getByRole("button", { name: "Ghi khoản chi" }));
  const f = screen.getByRole("form", { name: "Ghi khoản chi" });
  go(f, "Loại chi", "2"); go(f, "Số tiền (đồng)", "123456"); go(f, "Ngày chi", "2026-10-18"); return f;
}
describe("Khoản chi", () => {
  it("bày loại theo thứ tự backend với đúng nguồn; khoản dùng nguồn riêng và tổng backend", async () => {
    mo(); const list = await screen.findByRole("list", { name: "Danh sách loại chi" });
    expect(within(list).getAllByRole("listitem").map((x) => x.textContent)).toEqual(["Điện · Trả từ két", "Marketing · Tiền riêng"]);
    expect(await screen.findByText("18/10/2026 · Điện · Tiền riêng · 125.000 đ · Hoa")).toBeTruthy();
    expect(screen.getByText("Tổng: 987.654 đ")).toBeTruthy();
    expect(screen.queryByRole("button", { name: /xoá/i })).toBeNull();
  });
  it("hai danh sách rỗng không gài sẵn loại", async () => {
    mo({ loai: () => ({ status: 200, body: { expense_categories: [] } }), doc: () => ({ status: 200, body: { ...ds, expenses: [], total_vnd: 0 } }) });
    expect(await screen.findByText("Chưa có loại chi nào.")).toBeTruthy(); expect(await screen.findByText("Không có khoản chi nào trong khoảng này.")).toBeTruthy();
    expect(screen.queryByText(/Marketing/)).toBeNull();
  });
  it("thêm loại bắt buộc nguồn, tên; Tiền riêng gửi false và đọc lại", async () => {
    const g = mo(); const f = await screen.findByRole("form", { name: "Thêm loại chi" });
    expect((within(f).getByLabelText("Nguồn tiền") as HTMLSelectElement).value).toBe("");
    gui(f); await waitFor(() => expect(sai(f, "Tên loại chi")).toBe("true"));
    go(f, "Tên loại chi", "  Quảng cáo  "); gui(f); await waitFor(() => expect(sai(f, "Nguồn tiền")).toBe("true")); expect(ghi(g)).toHaveLength(0);
    go(f, "Nguồn tiền", "rieng"); gui(f); await screen.findByText("Đã thêm loại chi.");
    expect(ghi(g)).toEqual([{ method: "POST", path: "/expense-categories", body: { name: "Quảng cáo", paid_from_till: false } }]); expect(doc(g, "/expense-categories")).toHaveLength(2);
  });
  it("tên loại trùng gắn ô tên", async () => {
    mo({ ghi: () => ({ status: 409, body: { code: "expense_category_name_taken" } }) });
    const f = await screen.findByRole("form", { name: "Thêm loại chi" }); go(f, "Tên loại chi", "Điện"); go(f, "Nguồn tiền", "ket"); gui(f);
    await screen.findByText(/Tên loại chi bị trùng/); expect(sai(f, "Tên loại chi")).toBe("true");
  });
  it.each(["", "tu=2026-10-01", "den=2026-10-30"])("thiếu ngày dùng sale_date, không gửi loại hoặc nguồn: %s", async (search) => {
    nav.search = search; const g = mo(); await screen.findByText("Tổng: 987.654 đ");
    const q = new URLSearchParams(doc(g)[0].path.split("?")[1]);
    expect(Object.fromEntries(q)).toEqual({ from: search.startsWith("tu=") ? "2026-10-01" : "2026-10-19", to: search.startsWith("den=") ? "2026-10-30" : "2026-10-19" });
  });
  it.each(["ket", "rieng"])("URL gửi đúng bốn tham số với nguồn %s", async (nguon) => {
    nav.search = `tu=2026-10-01&den=2026-10-18&loai=2&nguon=${nguon}`; const g = mo(); await screen.findByText("Tổng: 987.654 đ");
    expect(Object.fromEntries(new URLSearchParams(doc(g)[0].path.split("?")[1]))).toEqual({ from: "2026-10-01", to: "2026-10-18", expense_category_id: "2", paid_from_till: String(nguon === "ket") });
  });
  it("đổi các bộ lọc bằng router.replace và đọc theo URL mới", async () => {
    const g = mo(); await screen.findByText("Tổng: 987.654 đ");
    for (const [label, value] of [["Từ ngày", "2026-10-01"], ["Đến ngày", "2026-10-20"], ["Lọc loại chi", "2"], ["Lọc nguồn", "rieng"]]) go(document.body, label, value);
    await waitFor(() => expect(doc(g).at(-1)?.path).toContain("paid_from_till=false"));
    expect(nav.replace).toHaveBeenLastCalledWith("/chu-quan/khoan-chi?tu=2026-10-01&den=2026-10-20&loai=2&nguon=rieng");
  });
  it("ngày chi trống lúc mở, thiếu ngày và loại không gửi", async () => {
    const g = mo(); await screen.findByRole("list", { name: "Danh sách loại chi" }); fireEvent.click(screen.getByRole("button", { name: "Ghi khoản chi" }));
    const f = screen.getByRole("form", { name: "Ghi khoản chi" }); const ngay = within(f).getByLabelText("Ngày chi") as HTMLInputElement;
    expect(ngay.value).toBe(""); expect(ngay.type).toBe("date"); go(f, "Số tiền (đồng)", "10"); gui(f);
    await waitFor(() => expect(sai(f, "Ngày chi")).toBe("true")); expect(sai(f, "Loại chi")).toBe("true"); expect(ghi(g)).toHaveLength(0);
  });
  it.each(["", "0", "1.5"])("tiền không hợp lệ '%s' không gửi", async (value) => {
    const g = mo(); const f = await formGhi(); go(f, "Số tiền (đồng)", value); gui(f); await waitFor(() => expect(sai(f, "Số tiền (đồng)")).toBe("true")); expect(ghi(g)).toHaveLength(0);
  });
  it("ghi số nguyên, đọc lại; bấm gửi hai lần nhanh chỉ một lời gọi", async () => {
    const g = mo(); const f = await formGhi(); const b = within(f).getByRole("button", { name: "Lưu khoản chi" }); fireEvent.click(b); fireEvent.click(b); await screen.findByText("Đã ghi khoản chi.");
    expect(ghi(g)).toEqual([{ method: "POST", path: "/expenses", body: { expense_category_id: 2, amount_vnd: 123456, paid_date: "2026-10-18" } }]); expect(doc(g)).toHaveLength(2);
  });
  it.each([false, true])("sale_day_reconciled gắn ô ngày khi sửa=%s", async (edit) => {
    mo({ ghi: () => ({ status: 409, body: { code: "sale_day_reconciled" } }) }); let f: HTMLElement;
    if (edit) { fireEvent.click(await screen.findByRole("button", { name: "Sửa" })); f = screen.getByRole("form", { name: "Sửa khoản chi" }); go(f, "Lý do", "Nhầm"); } else f = await formGhi();
    gui(f); await screen.findByText("Ngày này đã đối soát két nên không ghi được khoản trả từ két vào ngày ấy."); expect(sai(f, "Ngày chi")).toBe("true");
  });
  it("sửa điền sẵn, bắt buộc lý do rồi gửi đủ bốn trường và đọc lại", async () => {
    const g = mo(); fireEvent.click(await screen.findByRole("button", { name: "Sửa" })); const f = screen.getByRole("form", { name: "Sửa khoản chi" });
    for (const [label, value] of [["Loại chi", "2"], ["Số tiền (đồng)", "125000"], ["Ngày chi", "2026-10-18"]]) expect((within(f).getByLabelText(label) as HTMLInputElement).value).toBe(value);
    gui(f); await waitFor(() => expect(sai(f, "Lý do")).toBe("true")); expect(ghi(g)).toHaveLength(0);
    go(f, "Lý do", " Ghi nhầm "); gui(f); await screen.findByText("Đã sửa khoản chi."); expect(ghi(g)).toEqual([{ method: "PUT", path: "/expenses/9", body: { expense_category_id: 2, amount_vnd: 125000, paid_date: "2026-10-18", reason: "Ghi nhầm" } }]); expect(doc(g)).toHaveLength(2);
  });
  it.each(["from", "to"])("400 field=%s gắn bộ lọc, không tự so khoảng ngày", async (field) => {
    nav.search = "tu=2026-10-20&den=2026-10-01"; const g = mo({ doc: () => ({ status: 400, body: { code: "invalid_request", field } }) });
    await waitFor(() => expect(sai(document.body, field === "from" ? "Từ ngày" : "Đến ngày")).toBe("true")); expect(doc(g)).toHaveLength(1);
  });
  it.each([["expense_category_id", "Loại chi"], ["amount_vnd", "Số tiền (đồng)"], ["paid_date", "Ngày chi"]])("lỗi field=%s gắn ô ghi", async (field, label) => {
    mo({ ghi: () => ({ status: 400, body: { code: "invalid_request", field } }) }); const f = await formGhi(); gui(f); await waitFor(() => expect(sai(f, label)).toBe("true"));
  });
  it("loại không có báo và đọc lại loại", async () => {
    const g = mo({ ghi: () => ({ status: 404, body: { code: "expense_category_not_found" } }) }); const f = await formGhi(); gui(f); await screen.findByText(/Không tìm thấy loại chi này/); expect(doc(g, "/expense-categories")).toHaveLength(2);
  });
  it("khoản không có báo và đọc lại kể cả khi dòng biến mất", async () => {
    let lan = 0; const g = mo({ ghi: () => ({ status: 404, body: { code: "expense_not_found" } }), doc: () => ({ status: 200, body: ++lan === 1 ? ds : { ...ds, expenses: [] } }) });
    fireEvent.click(await screen.findByRole("button", { name: "Sửa" })); const f = screen.getByRole("form", { name: "Sửa khoản chi" }); go(f, "Lý do", "Nhầm"); gui(f); await screen.findByText(/Không tìm thấy khoản chi này/); expect(doc(g)).toHaveLength(2);
  });
  it("phản hồi không phải Error giữ nháp, không tự gửi lại", async () => {
    const g = mo({ ghi: () => ({ status: 500, body: { strange: true } }) }); const f = await formGhi(); gui(f); await screen.findByText(/Chưa xác nhận được kết quả/);
    expect((within(f).getByLabelText("Số tiền (đồng)") as HTMLInputElement).value).toBe("123456"); expect(ghi(g)).toHaveLength(1);
  });
  it("đã ghi nhưng đọc lại lỗi giữ bản cũ và cảnh báo", async () => {
    let lan = 0; mo({ doc: () => ++lan === 1 ? { status: 200, body: ds } : { status: 403, body: { code: "owner_only" } } });
    const f = await formGhi(); gui(f); await screen.findByText("Đã ghi khoản chi."); expect(screen.getByText("Tổng: 987.654 đ")).toBeTruthy(); expect(screen.getByRole("alert").textContent).toMatch(/Đang hiện bản đọc trước.*Đã ghi, chưa cập nhật/);
  });
  it("đọc loại lỗi giữ bản cũ và mốc đọc", async () => {
    let lan = 0; mo({ loai: () => ++lan === 1 ? { status: 200, body: { expense_categories: loai } } : { status: 403, body: { code: "owner_only" } } });
    await screen.findByRole("list", { name: "Danh sách loại chi" }); fireEvent.click(screen.getByRole("button", { name: "Đọc lại loại chi" }));
    expect((await screen.findByRole("alert")).textContent).toMatch(/Đang hiện bản đọc trước, lúc/); expect(screen.getByRole("list", { name: "Danh sách loại chi" })).toBeTruthy();
  });
  it("không đọc khoản chi khi chưa lấy được ngày mặc định", async () => {
    const g = mo({ ngay: () => ({ status: 403, body: { code: "owner_only" } }) }); await screen.findByRole("button", { name: "Đọc lại ngày bán" }); expect(doc(g)).toHaveLength(0);
  });
});
