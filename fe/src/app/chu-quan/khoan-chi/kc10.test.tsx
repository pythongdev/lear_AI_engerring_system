// Test KC-10 (ADR-147 điểm 1, 4, 5, 7; work/backlog_KC.md#kc-10): các hộp thao tác của trang Khoản chi dùng cửa thật của
// KC-06. Claude viết TRƯỚC code; Codex làm cho xanh mà không sửa điều kiện kiểm nào.
//   - Thêm mục: bắt buộc chọn theo dõi lượng (không mặc định), hộp liệt kê các mục hiện có.
//   - Ghi/Sửa khoản chi: ô Ngày nhập hàng chỉ ở mục theo dõi lượng; trống thì không gửi (backend lấy ngày chi).
//   - Thêm khoản con kèm tiền: mục theo dõi ⇒ một lời gọi nguyên khối POST /supply-expense-items; mục thường ⇒ hai lời gọi,
//     bước hai hỏng thì giữ khoản con đã tạo, lần bấm sau chỉ ghi khoản chi; mất phản hồi thì không cho gửi lại.
//   - Sửa tiền đã ghi đọc lịch sử ngoài bộ lọc chung: bảy ngày tới lần chi gần nhất (last_paid_date của danh mục).
//   - Xoá khoản con nối sổ là ngừng dùng.
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
type Tra = { status: number; body?: unknown } | "mat-ket-noi";
type GoiDen = { method: string; path: string; query: URLSearchParams; body: unknown };

const loai: K["ExpenseCategory"][] = [
  { expense_category_id: 2, name: "Điện", paid_from_till: true, tracks_supply: false, last_paid_date: "2026-10-19", items: [
    { expense_item_id: 21, expense_category_id: 2, name: "Hoá đơn tháng 10", supply_item_id: null, last_paid_date: "2026-10-19" },
    { expense_item_id: 22, expense_category_id: 2, name: "Sửa đồng hồ", supply_item_id: null, last_paid_date: "2026-09-01" },
    { expense_item_id: 23, expense_category_id: 2, name: "Dây điện mới", supply_item_id: null, last_paid_date: null },
  ] },
  { expense_category_id: 3, name: "Nguyên liệu", paid_from_till: false, tracks_supply: true, last_paid_date: "2026-10-18", items: [
    { expense_item_id: 31, expense_category_id: 3, name: "Bột gạo", supply_item_id: 7, last_paid_date: "2026-10-18" },
  ] },
];
const chi = (p: Partial<K["Expense"]> & Pick<K["Expense"], "expense_id" | "expense_category_id" | "amount_vnd" | "paid_date">): K["Expense"] => ({
  category_name: p.expense_category_id === 2 ? "Điện" : "Nguyên liệu", paid_from_till: p.expense_category_id === 2, received_date: null,
  person_id: 1, person_name: "Hoa", created_at: `${p.paid_date}T01:00:00Z`, expense_item_id: null, item_name: null, ...p,
});
const e11 = chi({ expense_id: 11, expense_category_id: 2, expense_item_id: 21, item_name: "Hoá đơn tháng 10", amount_vnd: 100000, paid_date: "2026-10-19" });
const e40 = chi({ expense_id: 40, expense_category_id: 3, expense_item_id: 31, item_name: "Bột gạo", amount_vnd: 200000, paid_date: "2026-10-18", received_date: "2026-10-17" });
const ds: K["Expenses"] = {
  from: "2026-10-18", to: "2026-10-19", expenses: [e40, e11], total_vnd: 300000,
  day_totals: [{ paid_date: "2026-10-19", expense_count: 1, total_vnd: 100000 }, { paid_date: "2026-10-18", expense_count: 1, total_vnd: 200000 }],
  category_totals: [{ expense_category_id: 2, total_vnd: 100000 }, { expense_category_id: 3, total_vnd: 200000 }],
  item_totals: [{ expense_item_id: 21, total_vnd: 100000, last_paid_date: "2026-10-19" }, { expense_item_id: 31, total_vnd: 200000, last_paid_date: "2026-10-18" }],
};
const lichSu22: K["Expenses"] = {
  from: "2026-08-26", to: "2026-09-01", total_vnd: 500000, day_totals: [],
  expenses: [chi({ expense_id: 51, expense_category_id: 2, expense_item_id: 22, item_name: "Sửa đồng hồ", amount_vnd: 200000, paid_date: "2026-08-28" }),
    chi({ expense_id: 52, expense_category_id: 2, expense_item_id: 22, item_name: "Sửa đồng hồ", amount_vnd: 300000, paid_date: "2026-09-01" })],
};

function mo(opts: { ghi?: (g: GoiDen, lan: number) => Tra; rieng?: (g: GoiDen) => Tra } = {}) {
  const goi: GoiDen[] = [];
  let lanGhi = 0;
  render(<ApiProvider fetch={async (req: Request) => {
    const text = await req.text(); const u = new URL(req.url);
    const g: GoiDen = { method: req.method, path: u.pathname.replace(/^\/api/, ""), query: u.searchParams, body: text ? JSON.parse(text) : undefined };
    goi.push(g);
    let r: Tra;
    if (g.method !== "GET") r = opts.ghi?.(g, lanGhi++) ?? { status: 204 };
    else if (g.path === "/owner-overview") r = { status: 200, body: { sale_date: "2026-10-19" } };
    else if (g.path === "/expense-categories") r = { status: 200, body: { expense_categories: loai } };
    // Lời gọi chung của trang luôn là khoảng 19/10–19/10 (ngày bán hoặc URL của test); khác khoảng ấy, hay có
    // expense_item_id, là lời gọi đọc riêng (lịch sử, Sửa tiền đã ghi).
    else if (g.path === "/expenses" && (g.query.has("expense_item_id") || g.query.get("from") !== "2026-10-19" || g.query.get("to") !== "2026-10-19"))
      r = opts.rieng?.(g) ?? { status: 200, body: lichSu22 };
    else if (g.path === "/expenses") r = { status: 200, body: ds };
    else r = { status: 404, body: { code: "invalid_request" } };
    if (r === "mat-ket-noi") throw new TypeError("Failed to fetch");
    return new Response(r.body === undefined ? null : JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  }}><Page /></ApiProvider>);
  return goi;
}
const ghi = (g: GoiDen[]) => g.filter((x) => x.method !== "GET").map((x) => ({ method: x.method, path: x.path, body: x.body }));
const go = (f: HTMLElement, label: string, value: string) => fireEvent.change(within(f).getByLabelText(label), { target: { value } });
const sai = (f: HTMLElement, label: string) => within(f).getByLabelText(label).getAttribute("aria-invalid");
const mucCho = async (ten: string) => (await screen.findByRole("heading", { level: 3, name: ten })).closest("article") as HTMLElement;
async function moChiTiet(muc: string, ten: string) {
  const bang = await within(await mucCho(muc)).findByRole("table", { name: `Khoản con trong ${muc}` });
  const nut = within(bang).getByRole("button", { name: ten });
  fireEvent.click(nut);
  return document.getElementById(nut.getAttribute("aria-controls")!)!;
}

describe("KC-10 — thêm mục chi", () => {
  it("bắt buộc chọn theo dõi lượng, không mặc định; gửi đúng cờ; hộp liệt kê các mục hiện có", async () => {
    const g = mo({ ghi: () => ({ status: 201, body: { expense_category_id: 9, name: "Gia vị", paid_from_till: true, tracks_supply: true } }) });
    await mucCho("Điện");
    fireEvent.click(screen.getByRole("button", { name: "＋ Thêm mục chi" }));
    const hop = screen.getByRole("dialog");
    const ds = within(hop).getByRole("list", { name: "Các mục chi hiện có" });
    const muc = within(ds).getAllByRole("listitem").map((li) => li.textContent ?? "");
    expect(muc).toHaveLength(2);
    expect(muc[0]).toMatch(/Điện.*Trả từ két/);
    expect(muc[0]).not.toMatch(/Theo dõi lượng/);
    expect(muc[1]).toMatch(/Nguyên liệu.*Tiền riêng.*Theo dõi lượng/);
    const f = within(hop).getByRole("form", { name: "Thêm loại chi" });
    expect((within(f).getByLabelText("Theo dõi lượng") as HTMLSelectElement).value).toBe("");
    go(f, "Tên loại chi", "Gia vị"); go(f, "Nguồn tiền", "ket"); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Theo dõi lượng")).toBe("true"));
    expect(ghi(g)).toHaveLength(0);
    go(f, "Theo dõi lượng", "co"); fireEvent.submit(f);
    await screen.findByText("Đã thêm loại chi.");
    expect(ghi(g)).toEqual([{ method: "POST", path: "/expense-categories", body: { name: "Gia vị", paid_from_till: true, tracks_supply: true } }]);
  });
});

describe("KC-10 — ngày nhập hàng", () => {
  async function formGhi(loaiId: string) {
    await mucCho("Điện");
    fireEvent.click(screen.getByRole("button", { name: "Ghi khoản chi" }));
    const f = screen.getByRole("form", { name: "Ghi khoản chi" });
    go(f, "Loại chi", loaiId);
    return f;
  }
  it("ô Ngày nhập hàng chỉ có ở mục theo dõi lượng; để trống thì không gửi", async () => {
    const g = mo({ ghi: () => ({ status: 201, body: e40 }) });
    const f = await formGhi("2");
    expect(within(f).queryByLabelText("Ngày nhập hàng")).toBeNull();
    go(f, "Loại chi", "3");
    expect(within(f).getByLabelText("Ngày nhập hàng")).toBeTruthy();
    expect(within(f).getByText("Ngày hàng về; có thể khác ngày chi tiền.")).toBeTruthy();
    go(f, "Nguyên liệu / sản phẩm", "31"); go(f, "Số tiền (đồng)", "200000"); go(f, "Ngày chi", "2026-10-18");
    fireEvent.submit(f);
    await screen.findByText("Đã ghi khoản chi.");
    expect(ghi(g)).toEqual([{ method: "POST", path: "/expenses", body: { expense_category_id: 3, expense_item_id: 31, amount_vnd: 200000, paid_date: "2026-10-18" } }]);
  });
  it("có Ngày nhập hàng thì gửi received_date; mục thường không bao giờ gửi", async () => {
    const g = mo({ ghi: () => ({ status: 201, body: e40 }) });
    const f = await formGhi("3");
    go(f, "Nguyên liệu / sản phẩm", "31"); go(f, "Số tiền (đồng)", "200000"); go(f, "Ngày chi", "2026-10-18"); go(f, "Ngày nhập hàng", "2026-10-16");
    fireEvent.submit(f);
    await screen.findByText("Đã ghi khoản chi.");
    expect(ghi(g)).toEqual([{ method: "POST", path: "/expenses", body: { expense_category_id: 3, expense_item_id: 31, amount_vnd: 200000, paid_date: "2026-10-18", received_date: "2026-10-16" } }]);
  });
  it("sửa khoản của mục theo dõi điền sẵn ngày nhập và gửi lại; sửa khoản mục thường không gửi ngày nhập", async () => {
    const g = mo({ ghi: () => ({ status: 200, body: e40 }) });
    const bang = await screen.findByRole("table", { name: "Các khoản chi theo ngày" });
    fireEvent.click(await within(bang).findByRole("button", { name: "Sửa Bột gạo ngày 18/10/2026" }));
    let f = screen.getByRole("form", { name: "Sửa khoản chi" });
    expect((within(f).getByLabelText("Ngày nhập hàng") as HTMLInputElement).value).toBe("2026-10-17");
    go(f, "Ngày nhập hàng", "2026-10-15"); go(f, "Lý do", "Nhập nhầm ngày");
    fireEvent.submit(f);
    await screen.findByText("Đã sửa khoản chi.");
    expect(ghi(g)[0]).toEqual({ method: "PUT", path: "/expenses/40", body: { expense_category_id: 3, expense_item_id: 31, amount_vnd: 200000, paid_date: "2026-10-18", received_date: "2026-10-15", reason: "Nhập nhầm ngày" } });
    fireEvent.click(within(bang).getByRole("button", { name: "Sửa Hoá đơn tháng 10 ngày 19/10/2026" }));
    f = screen.getByRole("form", { name: "Sửa khoản chi" });
    expect(within(f).queryByLabelText("Ngày nhập hàng")).toBeNull();
    go(f, "Lý do", "Sửa số"); fireEvent.submit(f);
    await waitFor(() => expect(ghi(g)).toHaveLength(2));
    expect(ghi(g)[1].body).not.toHaveProperty("received_date");
  });
});

describe("KC-10 — thêm khoản con kèm tiền", () => {
  async function formThem(muc: string) {
    fireEvent.click(within(await mucCho(muc)).getByRole("button", { name: "＋ Thêm khoản con" }));
    return screen.getByRole("form", { name: "Thêm khoản con" });
  }
  it("mục theo dõi lượng: một lời gọi nguyên khối, kèm tiền, ngày chi và ngày nhập", async () => {
    const g = mo({ ghi: () => ({ status: 201, body: { supply_item: {}, expense_item: { expense_item_id: 32, expense_category_id: 3, name: "Hành khô", supply_item_id: 8 }, expense: null } }) });
    const f = await formThem("Nguyên liệu");
    go(f, "Tên nguyên liệu / sản phẩm", "  Hành khô  "); go(f, "Tiền mua sản phẩm (đồng, không bắt buộc)", "50000");
    fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Ngày chi")).toBe("true"));
    expect(ghi(g)).toHaveLength(0);
    go(f, "Ngày chi", "2026-10-19"); go(f, "Ngày nhập hàng", "2026-10-18");
    fireEvent.submit(f);
    await screen.findByText(/Đã thêm khoản con/);
    expect(ghi(g)).toEqual([{ method: "POST", path: "/supply-expense-items", body: {
      expense_category_id: 3, name: "Hành khô", expense: { amount_vnd: 50000, paid_date: "2026-10-19", received_date: "2026-10-18" } } }]);
  });
  it("mục theo dõi lượng không kèm tiền: vẫn qua cửa gộp, không có khối expense", async () => {
    const g = mo({ ghi: () => ({ status: 201, body: { supply_item: {}, expense_item: { expense_item_id: 32, expense_category_id: 3, name: "Hành khô", supply_item_id: 8 }, expense: null } }) });
    const f = await formThem("Nguyên liệu");
    go(f, "Tên nguyên liệu / sản phẩm", "Hành khô"); fireEvent.submit(f);
    await screen.findByText(/Đã thêm khoản con/);
    expect(ghi(g)).toEqual([{ method: "POST", path: "/supply-expense-items", body: { expense_category_id: 3, name: "Hành khô" } }]);
  });
  it("tên đã có trong sổ nguyên liệu báo ở ô tên, giữ hộp", async () => {
    mo({ ghi: () => ({ status: 409, body: { code: "supply_item_name_taken" } }) });
    const f = await formThem("Nguyên liệu");
    go(f, "Tên nguyên liệu / sản phẩm", "Bột gạo"); fireEvent.submit(f);
    await within(f).findByText(/đã có trong sổ nguyên liệu/);
    expect(sai(f, "Tên nguyên liệu / sản phẩm")).toBe("true");
    expect(screen.getByRole("dialog")).toBeTruthy();
  });
  it("mục thường: hai lời gọi; khoản chi bị từ chối thì giữ khoản con đã tạo, lần sau chỉ ghi khoản chi", async () => {
    const g = mo({ ghi: (x, lan) => x.path === "/expense-items" ? { status: 201, body: { expense_item_id: 24, expense_category_id: 2, name: "Bóng đèn", supply_item_id: null } }
      : lan === 1 ? { status: 409, body: { code: "sale_day_reconciled" } } : { status: 201, body: e11 } });
    const f = await formThem("Điện");
    expect(within(f).queryByLabelText("Ngày nhập hàng")).toBeNull();
    go(f, "Tên nguyên liệu / sản phẩm", "Bóng đèn"); go(f, "Tiền mua sản phẩm (đồng, không bắt buộc)", "30000"); go(f, "Ngày chi", "2026-10-19");
    fireEvent.submit(f);
    await within(f).findByText(/Đã thêm khoản con Bóng đèn.*chưa ghi được khoản chi/);
    expect(screen.getByRole("dialog")).toBeTruthy();
    expect(ghi(g)).toEqual([
      { method: "POST", path: "/expense-items", body: { expense_category_id: 2, name: "Bóng đèn" } },
      { method: "POST", path: "/expenses", body: { expense_category_id: 2, expense_item_id: 24, amount_vnd: 30000, paid_date: "2026-10-19" } },
    ]);
    go(f, "Ngày chi", "2026-10-18"); fireEvent.submit(f);
    await screen.findByText(/Đã ghi khoản chi/);
    expect(ghi(g)).toHaveLength(3);
    expect(ghi(g)[2]).toEqual({ method: "POST", path: "/expenses", body: { expense_category_id: 2, expense_item_id: 24, amount_vnd: 30000, paid_date: "2026-10-18" } });
  });
  it("mục thường: mất phản hồi ở bước ghi tiền thì báo chưa xác nhận, không cho gửi lại", async () => {
    const g = mo({ ghi: (x) => x.path === "/expense-items" ? { status: 201, body: { expense_item_id: 24, expense_category_id: 2, name: "Bóng đèn", supply_item_id: null } } : "mat-ket-noi" });
    const f = await formThem("Điện");
    go(f, "Tên nguyên liệu / sản phẩm", "Bóng đèn"); go(f, "Tiền mua sản phẩm (đồng, không bắt buộc)", "30000"); go(f, "Ngày chi", "2026-10-19");
    fireEvent.submit(f);
    await within(f).findByText(/Đã thêm khoản con Bóng đèn.*Chưa xác nhận được khoản chi/);
    expect((within(f).getByRole("button", { name: "Thêm vào mục" }) as HTMLButtonElement).disabled).toBe(true);
    fireEvent.submit(f);
    await new Promise((r) => setTimeout(r, 50));
    expect(ghi(g)).toHaveLength(2);
  });
  it("mục thường không kèm tiền chỉ tạo khoản con", async () => {
    const g = mo({ ghi: () => ({ status: 201, body: { expense_item_id: 24, expense_category_id: 2, name: "Bóng đèn", supply_item_id: null } }) });
    const f = await formThem("Điện");
    go(f, "Tên nguyên liệu / sản phẩm", "Bóng đèn"); fireEvent.submit(f);
    await screen.findByText(/Đã thêm khoản con/);
    expect(ghi(g)).toEqual([{ method: "POST", path: "/expense-items", body: { expense_category_id: 2, name: "Bóng đèn" } }]);
  });
});

describe("KC-10 — sửa tiền đã ghi đọc ngoài bộ lọc", () => {
  it("khoản con: bảy ngày tới lần chi gần nhất trên mọi ngày, không mang bộ lọc chung; chọn đúng lần ghi", async () => {
    nav.search = "tu=2026-10-19&den=2026-10-19&nguon=ket";
    const g = mo();
    const ct = await moChiTiet("Điện", "Sửa đồng hồ");
    fireEvent.click(within(ct).getByRole("button", { name: "Sửa tên" }));
    const hop = screen.getByRole("dialog");
    const phan = within(hop).getByRole("region", { name: "Sửa tiền đã ghi" });
    await within(phan).findByText("300.000 đ");
    const q = g.filter((x) => x.method === "GET" && x.path === "/expenses" && x.query.get("expense_item_id") === "22").map((x) => Object.fromEntries(x.query));
    expect(q.at(-1)).toEqual({ from: "2026-08-26", to: "2026-09-01", expense_item_id: "22" });
    const dong = within(phan).getAllByRole("button", { name: "Sửa tiền" });
    expect(dong).toHaveLength(2);
    fireEvent.click(dong[0]);
    const f = screen.getByRole("form", { name: "Sửa khoản chi" });
    expect((within(f).getByLabelText("Số tiền (đồng)") as HTMLInputElement).value).toBe("300000");
    expect((within(f).getByLabelText("Ngày chi") as HTMLInputElement).value).toBe("2026-09-01");
  });
  it("mục: đọc theo expense_category_id, bảy ngày tới lần chi gần nhất của mục", async () => {
    nav.search = "tu=2026-10-19&den=2026-10-19";
    const g = mo({ rieng: () => ({ status: 200, body: { ...ds, expenses: [e11] } }) });
    fireEvent.click(within(await mucCho("Điện")).getByRole("button", { name: "Sửa mục" }));
    const phan = within(screen.getByRole("dialog")).getByRole("region", { name: "Sửa tiền đã ghi" });
    await within(phan).findByText("100.000 đ");
    const q = g.filter((x) => x.method === "GET" && x.path === "/expenses" && x.query.has("expense_category_id") && !x.query.has("paid_from_till")).map((x) => Object.fromEntries(x.query));
    expect(q).toContainEqual({ from: "2026-10-13", to: "2026-10-19", expense_category_id: "2" });
  });
  it("khoản con chưa chi lần nào không gọi lịch sử", async () => {
    const g = mo();
    const ct = await moChiTiet("Điện", "Dây điện mới");
    fireEvent.click(within(ct).getByRole("button", { name: "Sửa tên" }));
    const phan = within(screen.getByRole("dialog")).getByRole("region", { name: "Sửa tiền đã ghi" });
    expect(within(phan).getByText("Khoản con này chưa có lần chi nào.")).toBeTruthy();
    expect(g.filter((x) => x.query.get("expense_item_id") === "23")).toHaveLength(0);
  });
});

describe("KC-10 — ngừng dùng thứ nối sổ", () => {
  it("xoá khoản con nối sổ là ngừng dùng: hộp nói rõ giữ lịch sử, gửi DELETE có lý do", async () => {
    const g = mo();
    const muc = await mucCho("Nguyên liệu");
    const dong = within(muc).getByText("Bột gạo").closest("li") as HTMLElement;
    fireEvent.click(within(dong).getByRole("button", { name: "Xoá" }));
    const f = screen.getByRole("form", { name: "Ngừng dùng" });
    expect(f.textContent).toMatch(/Ngừng dùng Bột gạo/);
    expect(f.textContent).toMatch(/giữ/);
    go(f, "Lý do", "Không bán món dùng bột này nữa"); fireEvent.submit(f);
    await screen.findByText(/Đã ngừng dùng/);
    expect(ghi(g)).toEqual([{ method: "DELETE", path: "/expense-items/31", body: { reason: "Không bán món dùng bột này nữa" } }]);
  });
});
