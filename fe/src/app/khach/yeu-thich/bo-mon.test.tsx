// YT-05: kiểm thêm lệnh ghi, bộ soạn và các đường lỗi (không thay test Claude).
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { YeuThichKhach } from "@/components/khach/yeu-thich";
import { ApiProvider } from "@/lib/api/provider";
import { useNhapKhach } from "@/lib/nhap-khach";

beforeEach(() => { localStorage.clear(); sessionStorage.clear(); });
afterEach(() => { cleanup(); useNhapKhach.getState().xoaHet(); });

const nhan = { option_group_id: 1, option_group_name: "Nhân", prerequisite_option_ids: [], options: [
  { menu_option_id: 11, option_name: "Thịt", is_default: true }, { menu_option_id: 12, option_name: "Chay", is_default: false },
] };
const luong = { option_group_id: 2, option_group_name: "Lượng nhân", prerequisite_option_ids: [11], options: [
  { menu_option_id: 21, option_name: "Thường", is_default: true }, { menu_option_id: 22, option_name: "Nhiều", is_default: false },
] };
const banh = { menu_item_id: 1, item_name: "Bánh cuốn", menu_category_id: 1, option_groups: [nhan, luong], prices: [] };
const canh = { menu_item_id: 2, item_name: "Canh", menu_category_id: 1, option_groups: [], prices: [] };
const menu = { categories: [{ menu_category_id: 1, name: "Món lẻ" }], items: [banh, canh], combos: [
  { menu_combo_id: 5, name: "Bữa sáng", price_vnd: 45000, items: [
    { menu_item_id: 1, item_name: "Bánh cuốn", quantity: 2, option_groups: [nhan, luong], surcharges: [] },
    { menu_item_id: 2, item_name: "Canh", quantity: 1, option_groups: [], surcharges: [] },
  ] },
] };
const dong = (id: number, quantity = 1, available = true) => ({ favourite_line_id: id, menu_item_id: 1, menu_combo_id: null, option_ids: [11, 22], portions: [], quantity, available, unavailable_code: available ? null : "menu_item_discontinued" });
const combo = { favourite_line_id: 2, menu_item_id: null, menu_combo_id: 5, option_ids: [], quantity: 1, available: true, unavailable_code: null, portions: [
  { menu_item_id: 1, quantity: 1, option_ids: [12] }, { menu_item_id: 1, quantity: 1, option_ids: [11, 22] }, { menu_item_id: 2, quantity: 1, option_ids: [] },
] };
const data = { lines: [dong(1), combo], sets: [{ favourite_set_id: 7, kind: "rieng", name: "Bộ của mình", lines: [dong(3, 2)] }] };
type Goi = { method: string; path: string; body: Record<string, unknown> };
type Dap = { status: number; body: unknown };
const ok = (body: unknown = { status: "ok" }): Dap => ({ status: 200, body });
function mo(options: { doc?: () => Dap; ghi?: (g: Goi) => Dap | Promise<Dap>; quote?: () => Dap } = {}) {
  const calls: Goi[] = [];
  const fetch = vi.fn(async (req: Request) => {
    const raw = await req.text();
    const g = { method: req.method, path: new URL(req.url).pathname.replace(/^\/api/, ""), body: raw ? JSON.parse(raw) : undefined };
    calls.push(g);
    const r = g.path === "/menu" ? ok(menu) : g.method === "GET" ? (options.doc?.() ?? ok(data)) : g.path === "/price-quotes"
      ? options.quote?.() ?? ok({ total_vnd: 98765, lines: g.body.lines.map(() => ({ line_total_vnd: 12345 })) })
      : await (options.ghi?.(g) ?? ok());
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  });
  render(<ApiProvider fetch={fetch}><YeuThichKhach /></ApiProvider>);
  return {
    calls,
    ghi: () => calls.filter((g) => g.method !== "GET" && g.path !== "/price-quotes"),
    doc: () => calls.filter((g) => g.method === "GET" && g.path.endsWith("/favourites")),
  };
}
async function tao() {
  fireEvent.click(await screen.findByRole("button", { name: "Tạo bộ món riêng" }));
  return screen.findByRole("dialog", { name: "Tạo bộ món riêng" });
}

describe("YT-05 bộ món riêng", () => {
  it("tạo gửi kind rieng, tên, lựa chọn theo LuaChon và suất combo mặc định; đọc lại sau ghi", async () => {
    const r = mo(); const hop = await tao();
    fireEvent.change(within(hop).getByLabelText("Tên bộ món"), { target: { value: "  Bữa trưa  " } });
    fireEvent.click(within(hop).getByRole("button", { name: "Thêm Bánh cuốn" }));
    fireEvent.click(within(hop).getByLabelText("Chay"));
    expect(within(hop).queryByLabelText("Nhiều")).toBeNull();
    fireEvent.click(within(hop).getByRole("button", { name: "Thêm combo Bữa sáng" }));
    fireEvent.click(within(hop).getByRole("button", { name: "Lưu bộ món" }));
    await waitFor(() => expect(r.doc()).toHaveLength(2));
    expect(r.ghi()).toEqual([{ method: "POST", path: "/customer-accounts/current/favourite-sets", body: {
      kind: "rieng", name: "Bữa trưa", lines: [
        { menu_item_id: 1, option_ids: [12], quantity: 1 },
        { menu_combo_id: 5, quantity: 1, portions: [
          { menu_item_id: 1, quantity: 2, option_ids: [11, 21] }, { menu_item_id: 2, quantity: 1, option_ids: [] },
        ] },
      ],
    } }]);
  });

  it.each(["", "   ", "a".repeat(61)])("tên không hợp lệ (%s) không gửi", async (name) => {
    const r = mo(); const hop = await tao();
    fireEvent.change(within(hop).getByLabelText("Tên bộ món"), { target: { value: name } });
    fireEvent.click(within(hop).getByRole("button", { name: "Thêm Canh" }));
    fireEvent.click(within(hop).getByRole("button", { name: "Lưu bộ món" }));
    expect(within(hop).getByRole("alert").textContent).toContain("1 đến 60");
    expect(r.ghi()).toHaveLength(0);
  });

  it("sửa bộ gửi PUT với tên và dòng mới, không gửi kind hoặc mã dòng; đọc lại", async () => {
    const r = mo();
    fireEvent.click(within(await screen.findByRole("article", { name: "Bộ của mình" })).getByRole("button", { name: "Sửa" }));
    const hop = await screen.findByRole("dialog", { name: "Sửa bộ món riêng" });
    fireEvent.change(within(hop).getByLabelText("Tên bộ món"), { target: { value: "Bộ mới" } });
    fireEvent.change(within(hop).getByLabelText("Số lượng"), { target: { value: "3" } });
    fireEvent.click(within(hop).getByRole("button", { name: "Lưu bộ món" }));
    await waitFor(() => expect(r.doc()).toHaveLength(2));
    expect(r.ghi()).toEqual([{ method: "PUT", path: "/customer-accounts/current/favourite-sets/7", body: { name: "Bộ mới", lines: [{ menu_item_id: 1, option_ids: [11, 22], quantity: 3 }] } }]);
  });

  it.each(["rieng", "da_luu"])("xoá bộ %s gửi removal đúng mã rồi đọc lại", async (kind) => {
    let removed = false;
    const r = mo({ doc: () => ok({ ...data, sets: removed ? [] : [{ ...data.sets[0], kind }] }), ghi: () => { removed = true; return ok(); } });
    if (kind === "da_luu") fireEvent.click(await screen.findByRole("button", { name: /Bộ đã lưu/ }));
    const bo = await screen.findByRole("article", { name: "Bộ của mình" });
    fireEvent.click(within(bo).getByRole("button", { name: "Xoá" }));
    await waitFor(() => expect(screen.queryByRole("article", { name: "Bộ của mình" })).toBeNull());
    expect(r.doc()).toHaveLength(2);
    expect(r.ghi()).toEqual([{ method: "POST", path: "/customer-accounts/current/favourite-sets/7/removal", body: undefined }]);
  });

  it("tên bộ rỗng sau khi bỏ khoảng trắng hoặc quá 60 ký tự không gửi; đúng 60 ký tự thì gửi tên đã bỏ khoảng trắng", async () => {
    const r = mo();
    const hop = await tao();
    fireEvent.click(within(hop).getByRole("button", { name: "Thêm Canh" }));
    for (const ten of ["   ", "a".repeat(61)]) {
      fireEvent.change(within(hop).getByLabelText("Tên bộ món"), { target: { value: ten } });
      fireEvent.click(within(hop).getByRole("button", { name: "Lưu bộ món" }));
      expect((await within(hop).findByRole("alert")).textContent).toBe("Tên bộ cần từ 1 đến 60 ký tự.");
    }
    expect(r.ghi()).toHaveLength(0);
    fireEvent.change(within(hop).getByLabelText("Tên bộ món"), { target: { value: ` ${"b".repeat(60)} ` } });
    fireEvent.click(within(hop).getByRole("button", { name: "Lưu bộ món" }));
    await waitFor(() => expect(r.ghi()).toHaveLength(1));
    expect(r.ghi()[0].body).toMatchObject({ kind: "rieng", name: "b".repeat(60) });
  });

  it("favourite_limit_reached hiện câu tiếng Việt trong hộp, không đọc lại hay gửi ngầm", async () => {
    const r = mo({ ghi: () => ({ status: 422, body: { code: "favourite_limit_reached" } }) });
    const hop = await tao();
    fireEvent.change(within(hop).getByLabelText("Tên bộ món"), { target: { value: "Bộ sáng" } });
    fireEvent.click(within(hop).getByRole("button", { name: "Thêm Canh" }));
    fireEvent.click(within(hop).getByRole("button", { name: "Lưu bộ món" }));
    expect((await within(hop).findByRole("alert")).textContent).toBe("Đã chạm giới hạn món yêu thích hoặc bộ món. Hãy bớt món hoặc xoá bớt bộ rồi thử lại.");
    expect(r.ghi()).toHaveLength(1); expect(r.doc()).toHaveLength(1);
  });
});

describe("YT-05 lọc, giá và phiên", () => {
  it("tab Món lẻ chỉ còn món, Combo chỉ còn combo; tổng không đổi theo lọc", async () => {
    mo(); await screen.findByRole("article", { name: "Bánh cuốn" });
    const list = screen.getByRole("region", { name: "Món yêu thích" });
    fireEvent.click(screen.getByRole("button", { name: "Món lẻ" }));
    expect(within(list).getAllByRole("article")).toHaveLength(1);
    expect(within(list).getByRole("article", { name: "Bánh cuốn" })).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Combo" }));
    expect(within(list).getAllByRole("article")).toHaveLength(1);
    expect(within(list).getByRole("article", { name: "Bữa sáng" })).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Tất cả" }));
    expect(within(list).getAllByRole("article")).toHaveLength(2);
    await screen.findAllByText("98.765đ");
  });

  it("giá lỗi sau lần đọc thành công thay giá cũ bằng chữ lỗi", async () => {
    let loi = false;
    mo({ quote: () => loi ? { status: 503, body: { code: "internal" } } : ok({ total_vnd: 98765, lines: [{ line_total_vnd: 12345 }, { line_total_vnd: 22222 }] }), doc: () => ok({ ...data, sets: [] }) });
    await screen.findByText("98.765đ"); loi = true;
    fireEvent.click(screen.getByRole("button", { name: "Đọc lại danh sách" }));
    await screen.findAllByText("Chưa tính được giá. Hãy đọc lại danh sách.");
    expect(screen.queryByText("98.765đ")).toBeNull();
    expect(screen.queryByText("12.345đ")).toBeNull();
  });

  it("đọc lại lỗi giữ bản cũ kèm mốc và nút Đọc lại", async () => {
    let loi = false;
    mo({ doc: () => loi ? { status: 503, body: { code: "internal" } } : ok(data) });
    await screen.findByRole("article", { name: "Bánh cuốn" }); loi = true;
    fireEvent.click(screen.getByRole("button", { name: "Đọc lại danh sách" }));
    expect((await screen.findByRole("alert")).textContent).toContain("Đang hiện bản đọc lúc");
    expect(screen.getByRole("button", { name: "Đọc lại" })).toBeTruthy();
    expect(screen.getByRole("article", { name: "Bánh cuốn" })).toBeTruthy();
  });

  it("401 khi ghi mời đăng nhập, bỏ các thẻ, không lưu trình duyệt", async () => {
    const r = mo({ ghi: () => ({ status: 401, body: { code: "unauthenticated" } }) });
    fireEvent.click(within(await screen.findByRole("article", { name: "Bánh cuốn" })).getByRole("button", { name: "Bỏ yêu thích Bánh cuốn" }));
    expect((await screen.findByRole("link", { name: "Đăng nhập" })).getAttribute("href")).toBe("/khach/dang-nhap");
    expect(screen.queryByRole("article")).toBeNull();
    expect(r.ghi()).toHaveLength(1);
    expect(localStorage.length).toBe(0); expect(sessionStorage.length).toBe(0);
  });

  it("gửi một lệnh khi bấm nhanh nhiều lần; giữ khoá tới khi đọc lại xong", async () => {
    let resolve!: (r: Dap) => void;
    const r = mo({ ghi: () => new Promise((r) => { resolve = r; }) });
    const card = await screen.findByRole("article", { name: "Bánh cuốn" });
    const tang = within(card).getByRole("button", { name: "Tăng Bánh cuốn" });
    fireEvent.click(tang); fireEvent.click(tang); fireEvent.click(tang);
    await waitFor(() => expect(r.ghi()).toHaveLength(1));
    expect(tang.hasAttribute("disabled")).toBe(true);
    resolve(ok()); await waitFor(() => expect(r.doc()).toHaveLength(2));
  });

  it("tăng combo giữ suất cũ và thêm suất mặc định đủ số combo", async () => {
    const r = mo(); const card = await screen.findByRole("article", { name: "Bữa sáng" });
    fireEvent.click(within(card).getByRole("button", { name: "Tăng Bữa sáng" }));
    await waitFor(() => expect(r.ghi()).toHaveLength(1));
    expect(r.ghi()[0].body).toEqual({ menu_combo_id: 5, quantity: 2, portions: [
      { menu_item_id: 1, quantity: 1, option_ids: [12] }, { menu_item_id: 1, quantity: 1, option_ids: [11, 22] },
      { menu_item_id: 1, quantity: 2, option_ids: [11, 21] }, { menu_item_id: 2, quantity: 2, option_ids: [] },
    ] });
  });

  it("thêm một dòng combo trải suất đúng hình giỏ, báo và dẫn tới giỏ", async () => {
    mo(); const card = await screen.findByRole("article", { name: "Bữa sáng" });
    fireEvent.click(within(card).getByRole("button", { name: "Thêm vào giỏ" }));
    expect(useNhapKhach.getState().gio.web).toEqual([{ menu_combo_id: 5, quantity: 1, portions: [
      { menu_item_id: 1, option_ids: [12] }, { menu_item_id: 1, option_ids: [11, 22] }, { menu_item_id: 2, option_ids: [] },
    ] }]);
    expect(screen.getByText(/Đã thêm Bữa sáng vào giỏ hàng\./).getAttribute("role")).toBe("status");
    expect(screen.getByRole("link", { name: "Xem giỏ hàng" }).getAttribute("href")).toBe("/dat-mon");
  });

  it("sửa bộ có dòng hết bán không âm thầm bỏ dòng; yêu cầu khách bỏ rồi mới lưu", async () => {
    const r = mo({ doc: () => ok({ ...data, sets: [{ ...data.sets[0], lines: [dong(3, 1, false)] }] }) });
    fireEvent.click(within(await screen.findByRole("article", { name: "Bộ của mình" })).getByRole("button", { name: "Sửa" }));
    const hop = await screen.findByRole("dialog", { name: "Sửa bộ món riêng" });
    fireEvent.click(within(hop).getByRole("button", { name: "Thêm Canh" }));
    fireEvent.click(within(hop).getByRole("button", { name: "Lưu bộ món" }));
    expect(within(hop).getByRole("alert").textContent).toContain("Có món hết bán"); expect(r.ghi()).toHaveLength(0);
    fireEvent.click(within(hop).getByRole("button", { name: "Bỏ dòng 1" }));
    fireEvent.click(within(hop).getByRole("button", { name: "Lưu bộ món" }));
    await waitFor(() => expect(r.ghi()).toHaveLength(1));
    expect(r.ghi()[0].body.lines).toEqual([{ menu_item_id: 2, option_ids: [], quantity: 1 }]);
  });
});
