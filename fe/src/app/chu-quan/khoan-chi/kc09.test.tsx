// Test KC-09 (ADR-147 điểm 10; work/backlog_KC.md#kc-09): bảng tổng theo ngày, các khoản chi gom theo ngày, bảng khoản
// con ba cột của mục ngoài nguyên liệu, chi tiết ngay dưới dòng và lịch sử chi riêng. Claude viết TRƯỚC code; Codex làm
// cho xanh mà không sửa điều kiện kiểm nào. Mọi số tiền hiện ra là số backend trả: dữ liệu mẫu cố ý cho tổng backend
// KHÁC phép cộng các khoản, để FE tự cộng là đỏ.
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

const loai: K["ExpenseCategory"][] = [
  { expense_category_id: 2, name: "Điện", paid_from_till: true, tracks_supply: false, last_paid_date: "2026-10-19", items: [
    { expense_item_id: 21, expense_category_id: 2, name: "Hoá đơn tháng 10", supply_item_id: null, last_paid_date: "2026-10-19" },
    { expense_item_id: 22, expense_category_id: 2, name: "Sửa đồng hồ", supply_item_id: null, last_paid_date: "2026-09-01" },
    { expense_item_id: 23, expense_category_id: 2, name: "Dây điện mới", supply_item_id: null, last_paid_date: null },
  ] },
  { expense_category_id: 1, name: "Marketing", paid_from_till: false, tracks_supply: false, last_paid_date: "2026-10-19", items: [] },
];
const chi = (p: Partial<K["Expense"]> & Pick<K["Expense"], "expense_id" | "expense_category_id" | "amount_vnd" | "paid_date">): K["Expense"] => ({
  category_name: p.expense_category_id === 2 ? "Điện" : "Marketing", paid_from_till: p.expense_category_id === 2, received_date: null,
  person_id: 1, person_name: "Hoa", created_at: `${p.paid_date}T01:00:00Z`, expense_item_id: null, item_name: null, ...p,
});
const e11 = chi({ expense_id: 11, expense_category_id: 2, expense_item_id: 21, item_name: "Hoá đơn tháng 10", amount_vnd: 100000, paid_date: "2026-10-19" });
const e12 = chi({ expense_id: 12, expense_category_id: 1, amount_vnd: 50000, paid_date: "2026-10-19", person_name: "Lan", person_id: 2 });
const e9 = chi({ expense_id: 9, expense_category_id: 2, amount_vnd: 125000, paid_date: "2026-10-18" });
// Tổng backend khác phép cộng: ngày 19 là 150.000 nếu cộng, backend nói 777.777.
const ds: K["Expenses"] = {
  from: "2026-10-18", to: "2026-10-19", expenses: [e9, e11, e12], total_vnd: 987654,
  day_totals: [{ paid_date: "2026-10-19", expense_count: 2, total_vnd: 777777 }, { paid_date: "2026-10-18", expense_count: 1, total_vnd: 333333 }],
  category_totals: [{ expense_category_id: 2, total_vnd: 555555 }, { expense_category_id: 1, total_vnd: 50000 }],
  item_totals: [{ expense_item_id: 21, total_vnd: 444444, last_paid_date: "2026-10-19" }],
};
const lichSu22: K["Expenses"] = {
  from: "2026-08-26", to: "2026-09-01", total_vnd: 500000,
  expenses: [chi({ expense_id: 31, expense_category_id: 2, expense_item_id: 22, item_name: "Sửa đồng hồ", amount_vnd: 200000, paid_date: "2026-08-28", person_name: "Lan" }),
    chi({ expense_id: 32, expense_category_id: 2, expense_item_id: 22, item_name: "Sửa đồng hồ", amount_vnd: 300000, paid_date: "2026-09-01" })],
  day_totals: [{ paid_date: "2026-09-01", expense_count: 1, total_vnd: 300000 }, { paid_date: "2026-08-28", expense_count: 1, total_vnd: 200000 }],
};

function mo(opts: { doc?: (g: GoiDen, lan: number) => Tra; lichSu?: (g: GoiDen) => Tra; ghi?: (g: GoiDen) => Tra } = {}) {
  const goi: GoiDen[] = [];
  let lan = 0;
  render(<ApiProvider fetch={async (req: Request) => {
    const text = await req.text(); const u = new URL(req.url);
    const g: GoiDen = { method: req.method, path: u.pathname.replace(/^\/api/, ""), query: u.searchParams, body: text ? JSON.parse(text) : undefined };
    goi.push(g);
    let r: Tra;
    if (g.method !== "GET") r = opts.ghi?.(g) ?? { status: 204 };
    else if (g.path === "/owner-overview") r = { status: 200, body: { sale_date: "2026-10-19" } };
    else if (g.path === "/expense-categories") r = { status: 200, body: { expense_categories: loai } };
    else if (g.path === "/expenses" && g.query.has("expense_item_id")) r = opts.lichSu?.(g) ?? { status: 200, body: lichSu22 };
    else if (g.path === "/expenses") r = opts.doc?.(g, lan++) ?? { status: 200, body: ds };
    else r = { status: 404, body: { code: "invalid_request" } };
    return new Response(r.body === undefined ? null : JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  }}><Page /></ApiProvider>);
  return goi;
}
const docLichSu = (g: GoiDen[]) => g.filter((x) => x.method === "GET" && x.path === "/expenses" && x.query.has("expense_item_id"));
const docChung = (g: GoiDen[]) => g.filter((x) => x.method === "GET" && x.path === "/expenses" && !x.query.has("expense_item_id"));
const hang = (t: HTMLElement) => within(t).getAllByRole("row").slice(1);
const o = (r: HTMLElement) => within(r).getAllByRole("cell").map((c) => c.textContent?.trim());
const muc = (ten: string) => screen.getByRole("heading", { level: 3, name: ten }).closest("article") as HTMLElement;
// Chờ danh mục tải xong rồi mới lấy khối mục (GET /expense-categories trả sau lần render đầu).
const mucCho = async (ten: string) => (await screen.findByRole("heading", { level: 3, name: ten })).closest("article") as HTMLElement;
const go = (f: HTMLElement, label: string, value: string) => fireEvent.change(within(f).getByLabelText(label), { target: { value } });

describe("KC-09 — Sổ khoản chi theo ngày", () => {
  it("một dòng mỗi ngày theo day_totals của backend: ngày, số khoản, tổng — không tự cộng", async () => {
    nav.search = "tu=2026-10-18&den=2026-10-19";
    mo();
    const bang = await screen.findByRole("table", { name: "Tổng chi theo ngày" });
    await waitFor(() => expect(hang(bang)).toHaveLength(2));
    expect(hang(bang).map(o)).toEqual([["19/10/2026", "2 khoản", "777.777 đ"], ["18/10/2026", "1 khoản", "333.333 đ"]]);
    expect(within(bang).queryByText("150.000 đ")).toBeNull();
    // Bảng nằm trong khối Sổ khoản chi, ẩn cùng khối.
    const so = screen.getByRole("region", { name: "Bộ lọc sổ khoản chi" });
    expect(so.contains(bang)).toBe(true);
  });
  it("tập rỗng hiện một dòng trống, không dòng 0 đ", async () => {
    mo({ doc: () => ({ status: 200, body: { ...ds, expenses: [], total_vnd: 0, day_totals: [], category_totals: [], item_totals: [] } }) });
    const bang = await screen.findByRole("table", { name: "Tổng chi theo ngày" });
    await within(bang).findByText("Không có khoản chi trong phạm vi này.");
    expect(within(bang).queryByText("0 đ")).toBeNull();
  });
});

describe("KC-09 — Các khoản chi gom theo ngày", () => {
  it("một dòng mỗi ngày, mới trước; các lần chi cùng ngày nằm trong một ô, mới ghi trước, đủ tên · nguồn · tiền · người", async () => {
    mo();
    const bang = await screen.findByRole("table", { name: "Các khoản chi theo ngày" });
    await waitFor(() => expect(hang(bang)).toHaveLength(2));
    const [ngay19, ngay18] = hang(bang);
    expect(within(ngay19).getAllByRole("cell")[0].textContent).toBe("19/10/2026");
    expect(within(ngay18).getAllByRole("cell")[0].textContent).toBe("18/10/2026");
    const lan = within(ngay19).getAllByRole("listitem");
    expect(lan).toHaveLength(2);
    // expense_id 12 ghi sau 11 nên đứng trước.
    expect(lan[0].textContent).toContain("Marketing: Chưa chọn khoản con");
    for (const s of ["Tiền riêng", "50.000 đ", "Lan"]) expect(within(lan[0]).getByText(new RegExp(s))).toBeTruthy();
    expect(lan[1].textContent).toContain("Điện: Hoá đơn tháng 10");
    for (const s of ["Trả từ két", "100.000 đ", "Hoa"]) expect(within(lan[1]).getByText(new RegExp(s))).toBeTruthy();
    expect(within(ngay18).getAllByRole("listitem")[0].textContent).toContain("Điện: Chưa chọn khoản con");
  });
  it("Sửa và Xoá của từng lần chi mang tên và ngày, mở đúng mã", async () => {
    const g = mo();
    const bang = await screen.findByRole("table", { name: "Các khoản chi theo ngày" });
    fireEvent.click(await within(bang).findByRole("button", { name: "Sửa Hoá đơn tháng 10 ngày 19/10/2026" }));
    const f = screen.getByRole("form", { name: "Sửa khoản chi" });
    expect((within(f).getByLabelText("Số tiền (đồng)") as HTMLInputElement).value).toBe("100000");
    fireEvent.keyDown(screen.getByRole("dialog"), { key: "Escape" });
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    fireEvent.click(within(bang).getByRole("button", { name: "Xoá Marketing ngày 19/10/2026" }));
    const x = screen.getByRole("form", { name: "Xác nhận xoá" });
    expect(x.textContent).toContain("Marketing · 50.000 đ · 19/10/2026");
    go(x, "Lý do xoá", "Ghi trùng"); fireEvent.submit(x);
    await screen.findByText("Đã xoá và cập nhật danh sách.");
    expect(g.filter((c) => c.method !== "GET").map((c) => [c.method, c.path, c.body])).toEqual([["DELETE", "/expenses/12", { reason: "Ghi trùng" }]]);
  });
});

describe("KC-09 — mục ngoài nguyên liệu", () => {
  it("bảng chi theo ngày của riêng mục, giữ khoản chưa có khoản con", async () => {
    mo();
    await screen.findByRole("table", { name: "Các khoản chi theo ngày" });
    const bang = await within(await mucCho("Điện")).findByRole("table", { name: "Chi theo ngày của Điện" });
    await waitFor(() => expect(hang(bang)).toHaveLength(2));
    const [ngay19, ngay18] = hang(bang);
    expect(within(ngay19).getAllByRole("cell")[0].textContent).toBe("19/10/2026");
    expect(within(ngay19).getAllByRole("listitem").map((li) => li.textContent)).toEqual([expect.stringMatching(/Hoá đơn tháng 10.*100\.000 đ.*Hoa/)]);
    expect(within(ngay18).getAllByRole("listitem").map((li) => li.textContent)).toEqual([expect.stringMatching(/Chưa chọn khoản con.*125\.000 đ/)]);
    expect(within(bang).queryByText(/50\.000 đ/)).toBeNull();
  });
  it("bảng khoản con ba cột: tên, ngày chi gần nhất trong kỳ, tổng backend trong kỳ", async () => {
    mo();
    const bang = await within(await mucCho("Điện")).findByRole("table", { name: "Khoản con trong Điện" });
    expect(within(bang).getAllByRole("columnheader").map((c) => c.textContent)).toEqual(["Khoản con", "Ngày chi gần nhất", "Tổng chi trong kỳ"]);
    await waitFor(() => expect(within(bang).getByText("444.444 đ")).toBeTruthy());
    const dong = hang(bang);
    expect(dong.map(o)).toEqual([["Hoá đơn tháng 10", "19/10/2026", "444.444 đ"], ["Sửa đồng hồ", "Chưa chi trong kỳ", "0 đ"], ["Dây điện mới", "Chưa chi trong kỳ", "0 đ"]]);
    expect(within(muc("Điện")).getByText("555.555 đ")).toBeTruthy();
  });
  it("bấm tên mở chi tiết ngay dưới dòng, trước dòng kế; bấm lại thì đóng", async () => {
    mo();
    const bang = await within(await mucCho("Điện")).findByRole("table", { name: "Khoản con trong Điện" });
    await waitFor(() => expect(within(bang).getByText("444.444 đ")).toBeTruthy());
    const nut = within(bang).getByRole("button", { name: "Hoá đơn tháng 10" });
    expect(nut.getAttribute("aria-expanded")).toBe("false");
    fireEvent.click(nut);
    expect(nut.getAttribute("aria-expanded")).toBe("true");
    const chiTiet = document.getElementById(nut.getAttribute("aria-controls")!)!;
    expect(chiTiet).toBeTruthy();
    const dongTen = nut.closest("tr")!;
    expect(dongTen.nextElementSibling?.contains(chiTiet)).toBe(true);
    expect(dongTen.nextElementSibling?.nextElementSibling?.textContent).toContain("Sửa đồng hồ");
    for (const s of ["Trả từ két", "1 lần", "444.444 đ"]) expect(within(chiTiet).getByText(s)).toBeTruthy();
    for (const n of ["Sửa tên", "Xoá", "Ghi chi", "Lịch sử chi"]) expect(within(chiTiet).getByRole("button", { name: n })).toBeTruthy();
    fireEvent.click(within(chiTiet).getByRole("button", { name: "Ghi chi" }));
    const f = screen.getByRole("form", { name: "Ghi khoản chi" });
    expect((within(f).getByLabelText("Loại chi") as HTMLSelectElement).value).toBe("2");
    expect((within(f).getByLabelText("Nguyên liệu / sản phẩm") as HTMLSelectElement).value).toBe("21");
    fireEvent.keyDown(screen.getByRole("dialog"), { key: "Escape" });
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    fireEvent.click(nut);
    expect(nut.getAttribute("aria-expanded")).toBe("false");
    expect(document.getElementById(nut.getAttribute("aria-controls")!)?.closest("[hidden]") ?? null).not.toBeNull();
  });
});

describe("KC-09 — lịch sử chi riêng của khoản con", () => {
  async function moLichSu(ten: string) {
    const bang = await within(await mucCho("Điện")).findByRole("table", { name: "Khoản con trong Điện" });
    const nut = within(bang).getByRole("button", { name: ten });
    fireEvent.click(nut);
    const chiTiet = document.getElementById(nut.getAttribute("aria-controls")!)!;
    const mo = within(chiTiet).getByRole("button", { name: "Lịch sử chi" });
    fireEvent.click(mo);
    expect(mo.getAttribute("aria-expanded")).toBe("true");
    return within(chiTiet).getByRole("region", { name: `Lịch sử chi ${ten}` });
  }
  it("mặc định bảy ngày tới lần chi gần nhất trên mọi ngày, không mang bộ lọc chung", async () => {
    nav.search = "tu=2026-10-19&den=2026-10-19&nguon=ket";
    const g = mo();
    const ls = await moLichSu("Sửa đồng hồ");
    await waitFor(() => expect(docLichSu(g)).toHaveLength(1));
    const q = docLichSu(g)[0].query;
    expect(Object.fromEntries(q)).toEqual({ from: "2026-08-26", to: "2026-09-01", expense_item_id: "22" });
    expect((within(ls).getByLabelText("Từ ngày") as HTMLInputElement).value).toBe("2026-08-26");
    expect((within(ls).getByLabelText("Đến ngày") as HTMLInputElement).value).toBe("2026-09-01");
    await within(ls).findByText("2 lần chi từ 26/08/2026 đến 01/09/2026.");
    const bang = within(ls).getByRole("table", { name: "Ngày đã chi Sửa đồng hồ" });
    expect(hang(bang).map((r) => within(r).getAllByRole("cell")[0].textContent)).toEqual(["01/09/2026", "28/08/2026"]);
    expect(hang(bang)[0].textContent).toMatch(/300\.000 đ.*Hoa/);
    expect(hang(bang)[1].textContent).toMatch(/200\.000 đ.*Lan/);
  });
  it("đổi khoảng thì đọc lại; khoảng sai báo lỗi và không gọi; Xem lại 7 ngày trả về mặc định", async () => {
    const g = mo();
    const ls = await moLichSu("Sửa đồng hồ");
    await waitFor(() => expect(docLichSu(g)).toHaveLength(1));
    go(ls, "Từ ngày", "2026-08-30");
    await waitFor(() => expect(docLichSu(g).at(-1)?.query.get("from")).toBe("2026-08-30"));
    const truoc = docLichSu(g).length;
    go(ls, "Từ ngày", "2026-09-05");
    await within(ls).findByText("Từ ngày phải trước hoặc bằng Đến ngày.");
    expect(within(ls).getByRole("alert")).toBeTruthy();
    expect(docLichSu(g)).toHaveLength(truoc);
    go(ls, "Đến ngày", "");
    await within(ls).findByText("Chọn cả Từ ngày và Đến ngày.");
    expect(docLichSu(g)).toHaveLength(truoc);
    fireEvent.click(within(ls).getByRole("button", { name: "Xem lại 7 ngày" }));
    expect((within(ls).getByLabelText("Từ ngày") as HTMLInputElement).value).toBe("2026-08-26");
    expect((within(ls).getByLabelText("Đến ngày") as HTMLInputElement).value).toBe("2026-09-01");
  });
  it("khoản con chưa chi lần nào không gọi lịch sử; rỗng và lỗi đọc là hai câu khác nhau", async () => {
    const g = mo({ lichSu: (x) => x.query.get("from") === "2026-08-26" ? { status: 200, body: { ...lichSu22, expenses: [], total_vnd: 0, day_totals: [] } } : { status: 500, body: { code: "internal" } } });
    const chua = await moLichSu("Dây điện mới");
    expect(within(chua).getByText("Khoản con này chưa có lần chi nào.")).toBeTruthy();
    expect(docLichSu(g)).toHaveLength(0);
    const ls = await moLichSu("Sửa đồng hồ");
    await within(ls).findByText("Chưa có lần chi nào trong khoảng ngày đã chọn.");
    expect(within(ls).queryByRole("alert")).toBeNull();
    go(ls, "Từ ngày", "2026-08-27");
    await within(ls).findByText(/Chưa đọc được lịch sử chi/);
    expect(within(ls).getByRole("alert").textContent).toMatch(/Chưa đọc được lịch sử chi/);
    expect(within(ls).queryByText("Chưa có lần chi nào trong khoảng ngày đã chọn.")).toBeNull();
  });
  it("xoá một khoản thì đọc lại sổ, bảng ngày và lịch sử đang mở; chi tiết vẫn mở", async () => {
    const sau: K["Expenses"] = { ...ds, expenses: [e9, e11], total_vnd: 111111, day_totals: [{ paid_date: "2026-10-19", expense_count: 1, total_vnd: 222222 }, { paid_date: "2026-10-18", expense_count: 1, total_vnd: 333333 }] };
    const g = mo({ doc: (_x, lan) => ({ status: 200, body: lan === 0 ? ds : sau }) });
    const ls = await moLichSu("Sửa đồng hồ");
    await waitFor(() => expect(docLichSu(g)).toHaveLength(1));
    const truoc = docChung(g).length;
    const bang = screen.getByRole("table", { name: "Các khoản chi theo ngày" });
    fireEvent.click(within(bang).getByRole("button", { name: "Xoá Marketing ngày 19/10/2026" }));
    const x = screen.getByRole("form", { name: "Xác nhận xoá" });
    go(x, "Lý do xoá", "Ghi trùng"); fireEvent.submit(x);
    await screen.findByText("Đã xoá và cập nhật danh sách.");
    await waitFor(() => expect(docChung(g).length).toBeGreaterThan(truoc));
    await waitFor(() => expect(docLichSu(g).length).toBeGreaterThan(1));
    const tong = screen.getByRole("table", { name: "Tổng chi theo ngày" });
    await waitFor(() => expect(hang(tong).map(o)[0]).toEqual(["19/10/2026", "1 khoản", "222.222 đ"]));
    expect(ls.isConnected).toBe(true);
    expect(within(muc("Điện")).getByRole("button", { name: "Sửa đồng hồ" }).getAttribute("aria-expanded")).toBe("true");
  });
});
