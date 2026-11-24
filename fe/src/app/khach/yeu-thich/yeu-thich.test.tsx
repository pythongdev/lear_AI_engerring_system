// Test hồi quy YT-05 (trang Yêu thích của khách, ADR-145, I-045) — Claude viết TRƯỚC khi có code (L2, 2026-11-20). Người thi
// công làm cho xanh. T-367 bổ sung ca ảnh và PUT lựa chọn theo phiếu chủ repo; các ca YT-05 giữ nguyên.
//
// Hợp đồng màn Claude chốt:
//   - Component `YeuThichKhach` ở `@/components/khach/yeu-thich`; trang `/khach/yeu-thich` chỉ bọc nó (như /khach/don).
//   - Đọc ở trình duyệt qua ApiProvider: GET /customer-accounts/current/favourites và GET /menu (tên, lựa chọn).
//   - Giá CHỈ từ POST /price-quotes: một lần gọi cho mỗi nhóm (danh sách tim, mỗi bộ), thân chỉ gồm các dòng CÒN BÁN theo đúng
//     hình PriceLineRequest (món: menu_item_id + option_ids + quantity; combo: menu_combo_id + portions + quantity; không null, không
//     id dòng, không cờ). Giá dòng = lines[i].line_total_vnd, tổng nhóm = total_vnd của chính lần gọi ấy — FE không cộng tiền
//     (check-fe-rules cong-tien). Bảng giá trong GET /menu và price_vnd của combo không bao giờ hiện ra.
//   - Số tiền hiện thành một nút chữ riêng, đúng `tien()` của `dong-mon-da-ghi` (ví dụ "81.001đ"), không dính chữ khác.
//   - Mỗi dòng là một <article aria-label="{tên món hoặc combo}">; dòng có món không còn trên thực đơn mang tên
//     "Món không còn trên thực đơn". Dòng available=false hiện "Hết bán", không giá, không nút "Thêm vào giỏ".
//   - Nút: "Bỏ yêu thích {tên}", "Tăng {tên}", "Thêm vào giỏ" (trong thẻ dòng và thẻ bộ), "Thêm tất cả vào giỏ", "Lưu thành bộ"
//     → hộp có ô "Tên bộ" và nút "Lưu bộ", nút mở "Bộ đã lưu". Bộ `rieng` nằm trong vùng "Bộ món của bạn"; bộ `da_luu` chỉ hiện
//     sau khi mở "Bộ đã lưu". Mỗi bộ là <article aria-label="{tên bộ}">.
//   - Thêm vào giỏ = chép dòng vào giỏ nháp chung `useNhapKhach` khoá "web" (dòng combo: mỗi suất một phần tử, như
//     `chon-mon-chi-tiet`), gộp với giỏ đang có; không chép giá.
//   - 401 khi đọc: mời đăng nhập (link tới /khach/dang-nhap), không tự chuyển trang, không gọi giá, không ghi gì vào localStorage.
//   - Ghi xong thì đọc lại danh sách; mất phản hồi khi ghi: báo "chưa rõ", không gửi lại ngầm.
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import { useNhapKhach } from "@/lib/nhap-khach";
import { YeuThichKhach } from "@/components/khach/yeu-thich";

const replace = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ replace, push: vi.fn() }),
  usePathname: () => "/khach/yeu-thich",
  useSearchParams: () => new URLSearchParams(),
}));
beforeEach(() => { replace.mockReset(); window.localStorage.clear(); });
afterEach(() => { cleanup(); useNhapKhach.getState().xoaHet(); });

const nhan = { option_group_id: 5, option_group_name: "Nhân", prerequisite_option_ids: [], options: [
  { menu_option_id: 11, option_name: "Thịt", is_default: true }, { menu_option_id: 12, option_name: "Chay", is_default: false }] };
const luong = { option_group_id: 6, option_group_name: "Lượng nhân", prerequisite_option_ids: [11], options: [
  { menu_option_id: 21, option_name: "Thường", is_default: true }, { menu_option_id: 22, option_name: "Nhiều", is_default: false }] };
// Giá trong menu cố ý khác mọi số price-quotes trả: màn phải bày đúng số backend tính.
const menu = {
  categories: [{ menu_category_id: 1, name: "Món lẻ" }],
  items: [
    { menu_item_id: 1, item_name: "Bánh cuốn", image_url: "/menu-items/1/image", menu_category_id: 1, option_groups: [nhan, luong],
      prices: [{ option_ids: [11, 21], unit_price_vnd: 35000 }, { option_ids: [11, 22], unit_price_vnd: 40000 }, { option_ids: [12], unit_price_vnd: 30000 }] },
    { menu_item_id: 2, item_name: "Canh", menu_category_id: 1, option_groups: [], prices: [{ option_ids: [], unit_price_vnd: 10000 }] },
  ],
  combos: [{ menu_combo_id: 5, name: "Suất giò", price_vnd: 45000, items: [
    { menu_item_id: 2, item_name: "Canh", quantity: 1, option_groups: [], surcharges: [] },
    { menu_item_id: 1, item_name: "Bánh cuốn", quantity: 2, option_groups: [nhan, luong], surcharges: [] },
  ] }],
};
const dongMon = (id: number, menu_item_id: number, option_ids: number[], quantity: number, available = true, unavailable_code: string | null = null) =>
  ({ favourite_line_id: id, menu_item_id, menu_combo_id: null, option_ids, portions: [], quantity, available, unavailable_code });
const dongCombo = { favourite_line_id: 102, menu_item_id: null, menu_combo_id: 5, option_ids: [], quantity: 1, available: true, unavailable_code: null,
  portions: [{ menu_item_id: 1, quantity: 2, option_ids: [11, 21] }, { menu_item_id: 2, quantity: 1, option_ids: [] }] };
const yeuThich = {
  lines: [dongMon(101, 1, [11, 22], 2), dongCombo, dongMon(103, 9, [], 1, false, "menu_item_discontinued")],
  sets: [
    { favourite_set_id: 7, kind: "rieng", name: "Bữa sáng của mình", lines: [dongMon(201, 2, [], 3)] },
    { favourite_set_id: 8, kind: "da_luu", name: "Cuối tuần", lines: [dongMon(301, 1, [12], 1)] },
  ],
};
// Thân price-quotes mong đợi cho từng nhóm, và câu trả lời giả của backend (chỉ tra bảng, không cộng).
const guiTim = [{ menu_item_id: 1, option_ids: [11, 22], quantity: 2 },
  { menu_combo_id: 5, quantity: 1, portions: [{ menu_item_id: 1, quantity: 2, option_ids: [11, 21] }, { menu_item_id: 2, quantity: 1, option_ids: [] }] }];
const guiBo7 = [{ menu_item_id: 2, option_ids: [], quantity: 3 }];
const guiBo8 = [{ menu_item_id: 1, option_ids: [12], quantity: 1 }];
const dap = (lines: number[], tong: number) => ({ lines: lines.map((v) => ({ item_name: "x", quantity: 1, unit_price_vnd: v, line_total_vnd: v, components: [], options: [] })), total_vnd: tong });
const bangGia: [unknown, ReturnType<typeof dap>][] = [
  [guiTim, dap([81001, 52003], 99991)],
  [guiBo7, dap([30007], 30009)],
  [guiBo8, dap([41001], 41003)],
];

type Goi = { method: string; path: string; body: unknown };
type Dap = { status: number; body?: unknown } | "mat-mang";
function mo(ghi: (g: Goi, lan: number) => Dap = () => ({ status: 200, body: { status: "ok" } }), doc: () => Dap = () => ({ status: 200, body: yeuThich })) {
  const calls: Goi[] = [];
  let lanGhi = 0;
  const fetch = vi.fn(async (req: Request) => {
    const raw = await req.text();
    const g: Goi = { method: req.method, path: new URL(req.url).pathname.replace(/^\/api/, ""), body: raw ? JSON.parse(raw) : undefined };
    calls.push(g);
    let r: Dap = { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    if (g.method === "GET" && g.path === "/menu") r = { status: 200, body: menu };
    else if (g.method === "GET" && g.path === "/customer-accounts/current/favourites") r = doc();
    else if (g.path === "/price-quotes") {
      const hit = bangGia.find(([gui]) => JSON.stringify(gui) === JSON.stringify((g.body as { lines: unknown }).lines));
      r = hit ? { status: 200, body: hit[1] } : { status: 599, body: { code: "than_tinh_gia_la" } };
    } else if (g.method !== "GET") r = ghi(g, ++lanGhi);
    if (r === "mat-mang") throw new TypeError("fetch failed");
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  });
  render(<ApiProvider fetch={fetch}><YeuThichKhach /></ApiProvider>);
  return { calls, fetch };
}
const the = (name: string) => screen.findByRole("article", { name });
const tinhGia = (calls: Goi[]) => calls.filter((g) => g.path === "/price-quotes");
const docTim = (calls: Goi[]) => calls.filter((g) => g.method === "GET" && g.path === "/customer-accounts/current/favourites");
// So suất không theo thứ tự: mỗi suất thành chuỗi "món:lựa chọn đã xếp".
type Suat = { menu_item_id: number; option_ids: number[] };
const sxSuat = (lines: unknown) => (lines as Record<string, unknown>[]).map((d) => d.portions
  ? { ...d, portions: (d.portions as Suat[]).map((p) => `${p.menu_item_id}:${[...p.option_ids].sort((a, b) => a - b).join(",")}`).sort() } : d);

describe("YT-05 trang Yêu thích — đọc và giá", () => {
  it("giá dòng và tổng là đúng số price-quotes trả, không lấy từ menu hay dữ liệu yêu thích", async () => {
    const { calls } = mo();
    const banh = await the("Bánh cuốn");
    await within(banh).findByText("81.001đ");
    expect(within(banh).getByRole("button", { name: "Thịt · Nhiều" })).toBeTruthy();
    expect(within(await the("Suất giò")).getByText("52.003đ")).toBeTruthy();
    await screen.findByText("99.991đ");
    for (const sai of ["40.000đ", "80.000đ", "45.000đ", "133.004đ"]) expect(screen.queryByText(sai)).toBeNull();
    const gui = tinhGia(calls).map((g) => (g.body as { lines: unknown }).lines);
    expect(gui).toContainEqual(guiTim);
    for (const tu of ["favourite_line_id", "available", "null", "price", "vnd"]) expect(JSON.stringify(gui)).not.toContain(tu);
  });
  it("món hết bán: nhãn Hết bán, không giá, không nút thêm, không gửi đi tính giá", async () => {
    const { calls } = mo();
    const het = await the("Món không còn trên thực đơn");
    expect(within(het).getByText("Hết bán")).toBeTruthy();
    expect(within(het).queryByRole("button", { name: "Thêm vào giỏ" })).toBeNull();
    expect(within(het).queryByText(/\d+\.\d{3}đ/)).toBeNull();
    await screen.findByText("99.991đ");
    expect(JSON.stringify(tinhGia(calls).map((g) => g.body))).not.toContain("\"menu_item_id\":9");
  });
  it("Thêm tất cả vào giỏ chép các dòng còn bán vào giỏ nháp web, gộp với giỏ đang có, không chép giá", async () => {
    useNhapKhach.setState({ gio: { web: [{ menu_item_id: 2, option_ids: [], quantity: 1 }], "qr:ban-1": [{ menu_item_id: 1, option_ids: [12], quantity: 1 }] } });
    mo();
    await screen.findByText("99.991đ");
    fireEvent.click(screen.getByRole("button", { name: "Thêm tất cả vào giỏ" }));
    await waitFor(() => expect(useNhapKhach.getState().gio.web).toHaveLength(3));
    const web = useNhapKhach.getState().gio.web;
    expect(sxSuat(web)).toEqual(sxSuat([
      { menu_item_id: 2, option_ids: [], quantity: 1 },
      { menu_item_id: 1, option_ids: [11, 22], quantity: 2 },
      { menu_combo_id: 5, quantity: 1, portions: [{ menu_item_id: 1, option_ids: [11, 21] }, { menu_item_id: 1, option_ids: [11, 21] }, { menu_item_id: 2, option_ids: [] }] },
    ]));
    for (const tu of ["price", "vnd", "favourite"]) expect(JSON.stringify(web)).not.toContain(tu);
    expect(useNhapKhach.getState().gio["qr:ban-1"]).toEqual([{ menu_item_id: 1, option_ids: [12], quantity: 1 }]);
  });
});

describe("YT-05 trang Yêu thích — bộ món", () => {
  it("bộ riêng ở vùng Bộ món của bạn, tổng là total_vnd của bộ; Thêm vào giỏ đổ đúng các dòng của bộ", async () => {
    useNhapKhach.setState({ gio: { web: [{ menu_item_id: 2, option_ids: [], quantity: 1 }] } });
    mo();
    const vung = await screen.findByRole("region", { name: "Bộ món của bạn" });
    const bo = await within(vung).findByRole("article", { name: "Bữa sáng của mình" });
    await within(bo).findByText("30.009đ");
    expect(within(vung).queryByRole("article", { name: "Cuối tuần" })).toBeNull();
    fireEvent.click(within(bo).getByRole("button", { name: "Thêm vào giỏ" }));
    await waitFor(() => expect(useNhapKhach.getState().gio.web).toEqual([{ menu_item_id: 2, option_ids: [], quantity: 4 }]));
  });
  it("bộ đã lưu chỉ hiện sau khi mở Bộ đã lưu, kèm tổng của chính bộ ấy", async () => {
    mo();
    await the("Bánh cuốn");
    expect(screen.queryByRole("article", { name: "Cuối tuần" })).toBeNull();
    fireEvent.click(screen.getByRole("button", { name: /Bộ đã lưu/ }));
    const bo = await the("Cuối tuần");
    await within(bo).findByText("41.003đ");
  });
  it("Lưu thành bộ gửi kind da_luu, tên đã nhập và chỉ các dòng còn bán; rồi đọc lại", async () => {
    const { calls } = mo((g) => g.path === "/customer-accounts/current/favourite-sets"
      ? { status: 201, body: { favourite_set_id: 9, kind: "da_luu", name: "Cả nhà", lines: [] } } : { status: 599 });
    await screen.findByText("99.991đ");
    fireEvent.click(screen.getByRole("button", { name: /Lưu thành bộ/ }));
    fireEvent.change(await screen.findByLabelText("Tên bộ"), { target: { value: "Cả nhà" } });
    fireEvent.click(screen.getByRole("button", { name: "Lưu bộ" }));
    await waitFor(() => expect(docTim(calls)).toHaveLength(2));
    const tao = calls.filter((g) => g.method === "POST" && g.path === "/customer-accounts/current/favourite-sets");
    expect(tao).toHaveLength(1);
    expect(tao[0].body).toEqual({ kind: "da_luu", name: "Cả nhà", lines: guiTim });
  });
});

describe("YT-05 trang Yêu thích — ghi", () => {
  it("thẻ món có ảnh, đổi lựa chọn phụ thuộc gửi PUT hình mới rồi đọc lại", async () => {
    const { calls } = mo((g) => g.method === "PUT" ? { status: 200, body: dongMon(101, 1, [12], 2) } : { status: 599 });
    const banh = await the("Bánh cuốn");
    const anh = within(banh).getByRole("img", { name: "Bánh cuốn" });
    expect(anh.getAttribute("src")).toContain("/api/menu-items/1/image");
    expect(within(await the("Suất giò")).getByRole("img", { name: "Suất giò" })).toBeTruthy();
    expect(within(banh).getByRole("button", { name: "Thêm Bánh cuốn vào giỏ" }).textContent).toBe("＋ Giỏ");
    fireEvent.click(within(banh).getByRole("button", { name: "Thịt · Nhiều" }));
    expect(within(banh).getByRole("group", { name: "Lượng nhân:" })).toBeTruthy();
    fireEvent.click(within(banh).getByRole("radio", { name: "Chay" }));
    await waitFor(() => expect(docTim(calls)).toHaveLength(2));
    expect(calls.filter((g) => g.method === "PUT")).toEqual([{ method: "PUT", path: "/customer-accounts/current/favourites/101", body: { menu_item_id: 1, option_ids: [12], quantity: 2 } }]);
  });
  it("Tăng gửi PUT dòng với đúng hình và số lượng mới, rồi đọc lại", async () => {
    const { calls } = mo((g) => g.method === "PUT" ? { status: 200, body: { ...dongMon(101, 1, [11, 22], 3) } } : { status: 599 });
    fireEvent.click(within(await the("Bánh cuốn")).getByRole("button", { name: "Tăng Bánh cuốn" }));
    await waitFor(() => expect(docTim(calls)).toHaveLength(2));
    const put = calls.filter((g) => g.method === "PUT");
    expect(put).toHaveLength(1);
    expect(put[0]).toMatchObject({ path: "/customer-accounts/current/favourites/101", body: { menu_item_id: 1, option_ids: [11, 22], quantity: 3 } });
  });
  it("Bỏ yêu thích gọi removal của đúng dòng rồi đọc lại; dòng biến mất", async () => {
    let boDi = false;
    const { calls } = mo((g) => { boDi = true; return g.path.endsWith("/101/removal") ? { status: 200, body: { status: "ok" } } : { status: 599 }; },
      () => ({ status: 200, body: boDi ? { ...yeuThich, lines: yeuThich.lines.slice(1) } : yeuThich }));
    fireEvent.click(within(await the("Bánh cuốn")).getByRole("button", { name: "Bỏ yêu thích Bánh cuốn" }));
    await waitFor(() => expect(screen.queryByRole("article", { name: "Bánh cuốn" })).toBeNull());
    expect(calls.filter((g) => g.method === "POST" && g.path !== "/price-quotes").map((g) => g.path)).toEqual(["/customer-accounts/current/favourites/101/removal"]);
  });
  it("mất phản hồi khi ghi: báo chưa rõ, không gửi lại ngầm", async () => {
    const { calls } = mo(() => "mat-mang");
    fireEvent.click(within(await the("Bánh cuốn")).getByRole("button", { name: "Bỏ yêu thích Bánh cuốn" }));
    expect((await screen.findByRole("alert")).textContent).toContain("chưa rõ");
    await new Promise((r) => setTimeout(r, 50));
    expect(calls.filter((g) => g.path.endsWith("/removal"))).toHaveLength(1);
  });
});

describe("YT-05 trang Yêu thích — phiên và lỗi đọc", () => {
  it("chưa đăng nhập: mời đăng nhập, không tự chuyển trang, không tính giá, không lưu trên máy", async () => {
    const { calls } = mo(undefined, () => ({ status: 401, body: { code: "unauthenticated" } }));
    const link = await screen.findByRole("link", { name: /Đăng nhập/ });
    expect(link.getAttribute("href")).toBe("/khach/dang-nhap");
    await new Promise((r) => setTimeout(r, 50));
    expect(replace).not.toHaveBeenCalled();
    expect(tinhGia(calls)).toHaveLength(0);
    expect(screen.queryByRole("article")).toBeNull();
    expect(window.localStorage.length).toBe(0);
  });
  it("đọc lỗi: hiện lỗi và nút Đọc lại; đọc lại được thì hiện danh sách", async () => {
    let lan = 0;
    mo(undefined, () => (++lan === 1 ? { status: 503, body: { code: "internal" } } : { status: 200, body: yeuThich }));
    fireEvent.click(await screen.findByRole("button", { name: "Đọc lại" }));
    expect(await the("Bánh cuốn")).toBeTruthy();
  });
});

describe("T-377 thẻ trong hộp món yêu thích", () => {
  it("mỗi thẻ có ảnh hoặc khung ảnh dự phòng; giá món từ thấp nhất và giá combo chỉ để xem", async () => {
    const { calls } = mo();
    await screen.findByText("99.991đ");
    const soLanTinhGia = tinhGia(calls).length;
    fireEvent.click(screen.getByRole("button", { name: "Tạo món yêu thích" }));
    const hop = await screen.findByRole("dialog", { name: "Tạo món yêu thích" });
    for (const card of within(hop).getAllByRole("region")) {
      const ten = within(card).getByRole("heading", { level: 3 }).textContent!;
      expect(within(card).getByRole("img", { name: (name) => name === ten || name === `Chưa có ảnh ${ten}` })).toBeTruthy();
    }
    for (const banh of within(hop).getAllByRole("region", { name: "Lựa chọn Bánh cuốn" })) {
      expect(within(banh).getByRole("img", { name: "Bánh cuốn" }).getAttribute("src")).toContain("/api/menu-items/1/image");
      expect(within(banh).getByText("từ 30.000đ")).toBeTruthy();
    }
    const canh = within(hop).getByRole("region", { name: "Lựa chọn Canh" });
    expect(within(canh).getByText("10.000đ")).toBeTruthy();
    expect(within(canh).queryByText(/từ/)).toBeNull();
    const combo = within(hop).getByRole("region", { name: "Lựa chọn Suất giò" });
    expect(within(combo).getByRole("img", { name: "Suất giò" })).toBeTruthy();
    expect(within(combo).getByText("45.000đ")).toBeTruthy();
    expect(within(hop).getByText("Chưa chọn món")).toBeTruthy();
    expect(tinhGia(calls)).toHaveLength(soLanTinhGia);
  });

  it("Thành phần mở và đóng danh sách suất combo, không chọn dòng hay gửi lệnh", async () => {
    const { calls } = mo();
    await screen.findByText("99.991đ");
    fireEvent.click(screen.getByRole("button", { name: "Tạo món yêu thích" }));
    const hop = await screen.findByRole("dialog", { name: "Tạo món yêu thích" });
    const combo = within(hop).getByRole("region", { name: "Lựa chọn Suất giò" });
    const nut = within(combo).getByRole("button", { name: "Thành phần" });
    expect(nut.getAttribute("aria-expanded")).toBe("false");
    expect(within(combo).queryByRole("list")).toBeNull();
    fireEvent.click(nut);
    expect(nut.getAttribute("aria-expanded")).toBe("true");
    const suat = within(combo).getByRole("list");
    expect(within(suat).getByText("×2 Bánh cuốn · Thịt · Thường")).toBeTruthy();
    expect(within(suat).getByText("×1 Canh")).toBeTruthy();
    fireEvent.click(nut);
    expect(within(combo).queryByRole("list")).toBeNull();
    expect(within(hop).getByText("Chưa chọn món")).toBeTruthy();
    expect(calls.filter((g) => g.method !== "GET" && g.path !== "/price-quotes")).toHaveLength(0);
  });
});
