import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import { useNhapKhach } from "@/lib/nhap-khach";
import { PhieuKhach } from "./_components/phieu-khach";
import { baoGia, clientBackend, serverBackend, sx, tinhTheoGio, type Ghi, type TraLoi } from "./mau-khach";
import type { components } from "@/lib/api/schema";

afterEach(() => { cleanup(); vi.unstubAllGlobals(); useNhapKhach.getState().xoaHet(); });

async function mo(tinhThu?: (...a: Parameters<Ghi>) => Promise<TraLoi>, suaMenu?: (menu: components["schemas"]["Menu"]) => void) {
  serverBackend();
  const menu: components["schemas"]["Menu"] = await (await fetch("http://localhost/menu")).json();
  menu.items[0].option_groups[0].options.push({ menu_option_id: 13, option_name: "Thịt + mộc nhĩ", is_default: false });
  menu.items[0].option_groups[1].prerequisite_option_ids.push(13);
  menu.items[0].prices.push({ option_ids: [13, 21], unit_price_vnd: 35000 }, { option_ids: [13, 22], unit_price_vnd: 40000 });
  menu.combos = [{
    menu_combo_id: 99, name: "Đầy đặn", price_vnd: 72000,
    items: [{ ...menu.items[0], quantity: 2, surcharges: [] }],
  }];
  suaMenu?.(menu);
  const b = clientBackend(tinhThu);
  // Giữ menu thử có combo khi hook đọc lại.
  const fetchMenu: typeof fetch = async (input) => {
    const url = input instanceof Request ? input.url : String(input);
    if (new URL(url).pathname.replace(/^\/api/, "") === "/menu") return Response.json(menu);
    return b.fetch(input instanceof Request ? input : new Request(input));
  };
  render(<ApiProvider fetch={fetchMenu}><PhieuKhach ma="test-menu" nhan="3" initialMenu={menu} /></ApiProvider>);
  return b;
}
const click = (name: string) => fireEvent.click(screen.getByRole("button", { name }));
const dong = (n: number) => within(screen.getByRole("region", { name: `Dòng ${n}` }));
// Thành phần combo đã gộp trong tóm tắt, ví dụ "×2 Bánh cuốn".
const thanhPhan = (n: number) => [...screen.getByRole("region", { name: `Dòng ${n}` }).querySelectorAll("li")].map((li) => li.textContent?.replace(/\s+/g, " ").trim());
const cot = (n: number, ten: string) => dong(n).getByLabelText(ten).textContent;
// Giá dòng món lẻ do "backend" trả theo tổ hợp:số lượng; số cố định, FE chỉ bày.
const GIA_DONG: Record<string, number> = { "11,21:1": 35000, "11,21:2": 70000, "11,21:3": 105000, "13,22:1": 40000, "12:1": 30000 };
const giaTheoDong = async (...[g, lan]: Parameters<Ghi>): Promise<TraLoi> => {
  const tra = await tinhTheoGio(g, lan);
  const lines = (g.body?.lines ?? []) as { menu_item_id?: number; quantity: number; option_ids?: number[] }[];
  const gia = lines.length === 1 && lines[0].option_ids ? GIA_DONG[`${sx(lines[0].option_ids).join(",")}:${lines[0].quantity}`] : undefined;
  return gia === undefined || tra === "mat-mang" ? tra : { ...tra, body: { ...(tra.body as object), lines: [{ line_total_vnd: gia }] } };
};
const card = (name: string) => screen.getByRole("button", { name }).closest("article")!;

it("thẻ món và combo: thêm dòng mặc định; bớt dòng cuối, bỏ ở 0 và tắt; output cộng số lượng", async () => {
  await mo(giaTheoDong);
  expect((screen.getByRole("button", { name: "Bớt Bánh cuốn" }) as HTMLButtonElement).disabled).toBe(true);
  expect(within(card("Thêm combo Đầy đặn")).getByText("72.000đ")).toBeTruthy();
  const thanhPhanNut = within(card("Thêm combo Đầy đặn")).getByRole("button", { name: "Thành phần" });
  expect(thanhPhanNut.getAttribute("aria-expanded")).toBe("false");
  fireEvent.click(thanhPhanNut);
  expect(within(card("Thêm combo Đầy đặn")).getByText("×2 Bánh cuốn")).toBeTruthy();
  click("Thêm Bánh cuốn");
  click("Thêm combo Đầy đặn");
  click("Thêm Bánh cuốn");
  await waitFor(() => expect([cot(1, "Nhân"), cot(1, "Lượng nhân"), cot(1, "Giá")]).toEqual(["Thịt", "Vừa", "70.000đ"]));
  expect(screen.queryByRole("region", { name: "Dòng 3" })).toBeNull();
  const nut = dong(2).getByRole("button", { name: "Chi tiết" });
  expect(nut.getAttribute("aria-expanded")).toBe("false");
  fireEvent.click(nut);
  expect(nut.getAttribute("aria-expanded")).toBe("true");
  expect(thanhPhan(2)).toEqual(["×2 Bánh cuốn"]);
  expect([cot(2, "Nhân"), cot(2, "Lượng nhân")]).toEqual(["Thịt", "Vừa"]);
  fireEvent.click(nut);
  expect(nut.getAttribute("aria-expanded")).toBe("false");
  fireEvent.change(dong(1).getByRole("spinbutton"), { target: { value: "3" } });
  await waitFor(() => expect(cot(1, "Giá")).toBe("105.000đ"));
  expect(card("Thêm Bánh cuốn").querySelector("output")?.textContent).toBe("3");
  click("Bớt Bánh cuốn");
  expect((dong(1).getByRole("spinbutton") as HTMLInputElement).value).toBe("2");
  click("Bớt Bánh cuốn");
  expect((dong(1).getByRole("spinbutton") as HTMLInputElement).value).toBe("1");
  fireEvent.change(dong(2).getByRole("spinbutton"), { target: { value: "2" } });
  click("Thêm combo Đầy đặn");
  click("Bớt Đầy đặn");
  expect((dong(2).getByRole("spinbutton") as HTMLInputElement).value).toBe("2");
  click("Bớt Đầy đặn");
  expect(thanhPhan(2)).toEqual(["×2 Bánh cuốn"]);
  click("Bớt Đầy đặn");
  expect((screen.getByRole("button", { name: "Bớt Đầy đặn" }) as HTMLButtonElement).disabled).toBe(true);
  click("Bớt Bánh cuốn");
  expect(card("Thêm Bánh cuốn").querySelector("output")?.textContent).toBe("0");
  expect((screen.getByRole("button", { name: "Bớt Bánh cuốn" }) as HTMLButtonElement).disabled).toBe(true);
});

it("tìm tên không phân biệt hoa thường, dấu và đ; không khớp có câu báo", async () => {
  const b = await mo();
  const tim = screen.getByRole("searchbox", { name: "Tìm món nhanh" });
  const truoc = b.goi.length;
  fireEvent.change(tim, { target: { value: "BANH cuon" } });
  expect(screen.getByRole("button", { name: "Thêm Bánh cuốn" })).toBeTruthy();
  expect(screen.queryByRole("button", { name: "Thêm Canh" })).toBeNull();
  fireEvent.change(tim, { target: { value: "day DAN" } });
  expect(screen.getByRole("button", { name: "Thêm combo Đầy đặn" })).toBeTruthy();
  expect(screen.queryByRole("button", { name: "Thêm Bánh cuốn" })).toBeNull();
  fireEvent.change(tim, { target: { value: "xyz" } });
  expect(screen.getByText("Không có món nào khớp.")).toBeTruthy();
  expect(b.goi.length).toBe(truoc);
});

it("dải giỏ cộng số lượng và chỉ hiện total_vnd sau khi backend tính xong", async () => {
  let xong!: (v: TraLoi) => void;
  await mo(() => new Promise((resolve) => { xong = resolve; }));
  click("Thêm Canh");
  fireEvent.change(dong(1).getByRole("spinbutton"), { target: { value: "3" } });
  const strip = screen.getByRole("button", { name: "3 món" }).parentElement!;
  expect(within(strip).getByText("Canh ×3")).toBeTruthy();
  expect(strip.textContent).not.toContain("đ");
  await waitFor(() => expect(xong).toBeTypeOf("function"));
  await act(async () => xong(baoGia(123456)));
  expect(await within(strip).findByText("123.456đ")).toBeTruthy();
  expect(screen.getAllByText(/Tổng tạm tính/)).toHaveLength(1);
});

it("ô số lượng xoá trống: thẻ và dải giỏ đếm 0, không hiện NaN; bớt bỏ dòng ấy", async () => {
  await mo();
  click("Thêm Canh");
  fireEvent.change(dong(1).getByRole("spinbutton"), { target: { value: "" } });
  expect(card("Thêm Canh").querySelector("output")?.textContent).toBe("0");
  expect(screen.getByRole("button", { name: "0 món" })).toBeTruthy();
  expect(document.body.textContent).not.toContain("NaN");
  click("Bớt Canh");
  expect(screen.queryByRole("region", { name: "Dòng 1" })).toBeNull();
});

it("chọn nhân và lượng ngay trên thẻ; thêm giữ từng tổ hợp, tóm tắt chỉ đọc", async () => {
  const b = await mo(giaTheoDong);
  const mon = within(card("Thêm Bánh cuốn"));
  expect(mon.getByRole("button", { name: "Thịt · Vừa" })).toBeTruthy();
  expect(mon.queryByRole("radio")).toBeNull();
  click("Thêm Bánh cuốn");
  fireEvent.click(mon.getByRole("button", { name: "Thịt · Vừa" }));
  fireEvent.click(screen.getByRole("radio", { name: "Thịt + mộc nhĩ" }));
  expect(mon.getByRole("group", { name: "Lượng nhân:" })).toBeTruthy();
  fireEvent.click(screen.getByRole("radio", { name: "Nhiều" }));
  expect(mon.getByRole("radio", { name: "Nhiều" }).getAttribute("type")).toBe("radio");
  click("Thêm Bánh cuốn");
  fireEvent.click(screen.getByRole("radio", { name: "Chay" }));
  expect(mon.queryByRole("group", { name: "Lượng nhân:" })).toBeNull();
  expect(mon.getByRole("button", { name: "Chay" }).getAttribute("aria-expanded")).toBe("true");
  click("Thêm Bánh cuốn");
  await waitFor(() => expect([cot(1, "Nhân"), cot(1, "Lượng nhân"), cot(1, "Giá")]).toEqual(["Thịt", "Vừa", "35.000đ"]));
  await waitFor(() => expect([cot(2, "Nhân"), cot(2, "Lượng nhân"), cot(2, "Giá")]).toEqual(["Thịt + mộc nhĩ", "Nhiều", "40.000đ"]));
  await waitFor(() => expect([cot(3, "Nhân"), cot(3, "Lượng nhân"), cot(3, "Giá")]).toEqual(["Chay", "—", "30.000đ"]));
  expect(document.querySelector('[data-component="OrderSummary"]')!.querySelectorAll('input[type="radio"]')).toHaveLength(0);
  await waitFor(() => expect(b.goi.some((g) => JSON.stringify(g.body?.lines) === JSON.stringify([
    { menu_item_id: 1, quantity: 1, option_ids: [11, 21] },
    { menu_item_id: 1, quantity: 1, option_ids: [13, 22] },
    { menu_item_id: 1, quantity: 1, option_ids: [12] },
  ]))).toBe(true));
});

it("combo chọn chung mọi suất, từng lần thêm giữ nhân riêng và chay bỏ lượng nhân", async () => {
  const b = await mo();
  const combo = within(card("Thêm combo Đầy đặn"));
  expect(combo.getByRole("button", { name: "Thịt · Vừa" })).toBeTruthy();
  fireEvent.click(combo.getByRole("button", { name: "Thịt · Vừa" }));
  fireEvent.click(screen.getByRole("radio", { name: "Thịt + mộc nhĩ" }));
  expect(combo.getByRole("group", { name: "Lượng nhân:" })).toBeTruthy();
  fireEvent.click(screen.getByRole("radio", { name: "Nhiều" }));
  expect(combo.getByRole("radio", { name: "Nhiều" }).getAttribute("type")).toBe("radio");
  click("Thêm combo Đầy đặn");
  fireEvent.click(screen.getByRole("radio", { name: "Chay" }));
  expect(combo.queryByRole("group", { name: "Lượng nhân:" })).toBeNull();
  expect(combo.getByRole("button", { name: "Chay" }).getAttribute("aria-expanded")).toBe("true");
  click("Thêm combo Đầy đặn");
  expect([cot(1, "Nhân"), cot(1, "Lượng nhân")]).toEqual(["Thịt + mộc nhĩ", "Nhiều"]);
  expect([cot(2, "Nhân"), cot(2, "Lượng nhân")]).toEqual(["Chay", "—"]);
  fireEvent.change(dong(1).getByRole("spinbutton"), { target: { value: "2" } });
  expect(thanhPhan(1)).toEqual(["×4 Bánh cuốn"]);
  await waitFor(() => expect(b.goi.some((g) => JSON.stringify(g.body?.lines) === JSON.stringify([
    { menu_combo_id: 99, quantity: 2, portions: [{ menu_item_id: 1, quantity: 4, option_ids: [13, 22] }] },
    { menu_combo_id: 99, quantity: 1, portions: [{ menu_item_id: 1, quantity: 2, option_ids: [12] }] },
  ]))).toBe(true));
});

it("thêm cùng combo cùng lựa chọn thì gom một dòng cộng số lượng; khác lựa chọn thì dòng riêng", async () => {
  await mo();
  click("Thêm combo Đầy đặn");
  click("Thêm combo Đầy đặn");
  expect(screen.queryByRole("region", { name: "Dòng 2" })).toBeNull();
  expect((dong(1).getByRole("spinbutton") as HTMLInputElement).value).toBe("2");
  expect(thanhPhan(1)).toEqual(["×4 Bánh cuốn"]);
  const combo = within(card("Thêm combo Đầy đặn"));
  fireEvent.click(combo.getByRole("button", { name: "Thịt · Vừa" }));
  fireEvent.click(screen.getByRole("radio", { name: "Chay" }));
  click("Thêm combo Đầy đặn");
  expect([cot(2, "Nhân"), cot(2, "Lượng nhân")]).toEqual(["Chay", "—"]);
  expect(within(screen.getByRole("heading", { name: "Tóm tắt đơn hàng" }).closest("section")!).getAllByRole("heading", { name: "COMBO" })).toHaveLength(1);
});

it("ảnh thẻ dẫn đúng chi tiết combo/món và giữ mã bàn", async () => {
  await mo();
  expect(within(card("Thêm combo Đầy đặn")).getByRole("link", { name: "Xem chi tiết combo Đầy đặn" }).getAttribute("href")).toBe("/thuc-don/combo/99?ban=test-menu");
  expect(within(card("Thêm Bánh cuốn")).getByRole("link", { name: "Xem chi tiết món Bánh cuốn" }).getAttribute("href")).toBe("/thuc-don/mon/1?ban=test-menu");
});

it("nút gộp mở mọi nhóm trong thẻ; chọn giữ mở, bấm lại thu và giữ lựa chọn", async () => {
  await mo();
  const mon = within(card("Thêm Bánh cuốn"));
  const nut = mon.getByRole("button", { name: "Thịt · Vừa" });
  expect(nut.getAttribute("aria-expanded")).toBe("false");
  expect(mon.queryByRole("radio")).toBeNull();
  fireEvent.click(nut);
  expect(nut.getAttribute("aria-expanded")).toBe("true");
  expect((mon.getByRole("radio", { name: /^Thịt$/ }) as HTMLInputElement).checked).toBe(true);
  expect(mon.getByRole("group", { name: "Lượng nhân:" })).toBeTruthy();
  fireEvent.click(mon.getByRole("radio", { name: "Nhiều" }));
  expect(nut.getAttribute("aria-expanded")).toBe("true");
  expect(nut.textContent).toBe("Thịt · Nhiều");
  fireEvent.click(nut);
  expect(mon.queryByRole("radio")).toBeNull();
  fireEvent.click(nut);
  expect((mon.getByRole("radio", { name: "Nhiều" }) as HTMLInputElement).checked).toBe(true);
});

it("canh bánh cuốn nằm cuối món lẻ, nút Rau mặc định Ít rau và chọn được Nhiều rau (T-261)", async () => {
  await mo(undefined, (menu) => menu.items.unshift({ menu_item_id: 3, item_name: "Canh bánh cuốn", option_groups: [
    { option_group_id: 7, option_group_name: "Rau", prerequisite_option_ids: [], options: [
      { menu_option_id: 31, option_name: "Không rau", is_default: false }, { menu_option_id: 32, option_name: "Ít rau", is_default: true },
      { menu_option_id: 33, option_name: "Nhiều rau", is_default: false }] },
  ], prices: [{ option_ids: [31], unit_price_vnd: 0 }, { option_ids: [32], unit_price_vnd: 0 }, { option_ids: [33], unit_price_vnd: 0 }], menu_category_id: null }));
  const list = screen.getByRole("heading", { name: "MÓN LẺ" }).closest("section")!;
  expect([...list.querySelectorAll("h3")].map((h) => h.textContent)).toEqual(["Bánh cuốn", "Canh", "Canh bánh cuốn"]);
  const nut = within(card("Thêm Canh bánh cuốn")).getByRole("button", { name: "Ít rau" });
  expect(nut.textContent).toContain("Ít rau");
  fireEvent.click(nut);
  fireEvent.click(within(card("Thêm Canh bánh cuốn")).getByLabelText("Nhiều rau"));
  expect(nut.textContent).toContain("Nhiều rau");
});


it("món không lựa chọn gộp số lượng; xoá dòng gộp bỏ toàn bộ số lượng", async () => {
  const b = await mo();
  click("Thêm Canh"); click("Thêm Canh");
  expect(screen.queryByRole("region", { name: "Dòng 2" })).toBeNull();
  expect((dong(1).getByRole("spinbutton") as HTMLInputElement).value).toBe("2");
  await waitFor(() => expect(b.goi.some((g) => JSON.stringify(g.body?.lines) === JSON.stringify([
    { menu_item_id: 2, quantity: 2, option_ids: [] },
  ]))).toBe(true));
  click("Xoá dòng 1");
  expect(screen.queryByRole("region", { name: "Dòng 1" })).toBeNull();
  expect(card("Thêm Canh").querySelector("output")?.textContent).toBe("0");
  click("Thêm Canh"); click("Thêm Canh");
  const gui = screen.getByRole("button", { name: "Đặt món" }) as HTMLButtonElement;
  await waitFor(() => expect(gui.disabled).toBe(false));
  fireEvent.click(gui);
  await waitFor(() => expect(b.goi.find((g) => g.path === "/qr-codes/test-menu/orders")?.body?.lines).toEqual([
    { menu_item_id: 2, quantity: 2, option_ids: [] },
  ]));
});

it("nháp cũ gộp cùng tập lựa chọn dù đảo thứ tự; khác món hoặc lựa chọn rau vẫn tách", async () => {
  useNhapKhach.setState({ gio: { "qr:test-menu": [
    { menu_item_id: 1, quantity: 1, option_ids: [21, 11] },
    { menu_item_id: 2, quantity: 1, option_ids: [] },
    { menu_item_id: 1, quantity: 2, option_ids: [11, 21] },
    { menu_item_id: 2, quantity: 1, option_ids: [] },
    { menu_item_id: 3, quantity: 1, option_ids: [31] },
    { menu_item_id: 3, quantity: 1, option_ids: [32] },
  ] } });
  await mo(giaTheoDong, (menu) => menu.items.push({ menu_item_id: 3, item_name: "Canh bánh cuốn", option_groups: [
    { option_group_id: 7, option_group_name: "Rau", prerequisite_option_ids: [], options: [
      { menu_option_id: 31, option_name: "Ít rau", is_default: true },
      { menu_option_id: 32, option_name: "Nhiều rau", is_default: false },
    ] },
  ], prices: [{ option_ids: [31], unit_price_vnd: 0 }, { option_ids: [32], unit_price_vnd: 0 }], menu_category_id: null }));
  expect((dong(1).getByRole("spinbutton") as HTMLInputElement).value).toBe("3");
  expect((dong(2).getByRole("spinbutton") as HTMLInputElement).value).toBe("2");
  expect(dong(3).getByRole("heading", { name: "Canh bánh cuốn" })).toBeTruthy();
  expect(dong(4).getByRole("heading", { name: "Canh bánh cuốn" })).toBeTruthy();
  expect(screen.queryByRole("region", { name: "Dòng 5" })).toBeNull();
  await waitFor(() => expect(cot(1, "Giá")).toBe("105.000đ"));
  fireEvent.change(dong(1).getByRole("spinbutton"), { target: { value: "" } });
  click("Thêm Bánh cuốn");
  expect((dong(1).getByRole("spinbutton") as HTMLInputElement).value).toBe("");
  expect((dong(5).getByRole("spinbutton") as HTMLInputElement).value).toBe("1");
});

it("thanh cam dùng giá dòng API và chờ báo giá, không nhân giá gốc combo", async () => {
  const cho: ((v: TraLoi) => void)[] = [];
  await mo(() => new Promise((resolve) => { cho.push(resolve); }));
  click("Thêm combo Đầy đặn");
  const combo = card("Thêm combo Đầy đặn");
  expect(combo.querySelector(".menu-quantity-text")?.textContent).toBe("1 suất · Đang tính…");
  await waitFor(() => expect(cho).toHaveLength(2));
  await act(async () => cho.forEach((tra) => tra({ status: 200, body: { lines: [{ line_total_vnd: 98765 }], total_vnd: 98765 } })));
  await waitFor(() => expect(combo.querySelector(".menu-quantity-text")?.textContent).toBe("1 suất · 98.765đ"));
});

it("thanh cam báo khi API lỗi và cộng đúng nhiều tổ hợp món lẻ", async () => {
  await mo(giaTheoDong);
  click("Thêm Bánh cuốn");
  const mon = within(card("Thêm Bánh cuốn"));
  fireEvent.click(mon.getByRole("button", { name: "Thịt · Vừa" }));
  fireEvent.click(mon.getByRole("radio", { name: "Chay" }));
  click("Thêm Bánh cuốn");
  await waitFor(() => expect(card("Thêm Bánh cuốn").querySelector(".menu-quantity-text")?.textContent).toBe("2 món · 65.000đ"));
  // Fixture mặc định của combo không có giá dòng: giữ lời lỗi, không tự suy giá.
  click("Thêm combo Đầy đặn");
  await waitFor(() => expect(card("Thêm combo Đầy đặn").querySelector(".menu-quantity-text")?.textContent).toBe("1 suất · Chưa tính được giá"));
});


it.each([2, 3])("hỗn hợp chia cả bánh trứng, giữ tỷ lệ mỗi combo khi tăng/bớt (%i bánh cuốn)", async (banh) => {
  await mo(giaTheoDong, (menu) => {
    const mon = menu.items[0];
    mon.option_groups[0].options.push({ menu_option_id: 14, option_name: "Mộc nhĩ", is_default: false });
    mon.option_groups[1].prerequisite_option_ids.push(14);
    menu.combos[0].items = [
      { ...mon, quantity: banh, surcharges: [] },
      { ...mon, menu_item_id: 81, item_name: "Bánh trứng", quantity: 1, surcharges: [] },
      { menu_item_id: 82, item_name: "Giò", quantity: 1, option_groups: [], surcharges: [] },
    ];
  });
  const c = within(card("Thêm combo Đầy đặn"));
  fireEvent.click(c.getByRole("button", { name: "Thịt · Vừa" }));
  fireEvent.click(c.getByRole("radio", { name: "Mộc nhĩ và thịt" }));
  expect((c.getByRole("radio", { name: "Thịt" }) as HTMLInputElement).checked).toBe(false);
  fireEvent.click(c.getByRole("radio", { name: "Nhiều" }));
  expect((c.getByRole("radio", { name: "Mộc nhĩ và thịt" }) as HTMLInputElement).checked).toBe(true);
  const dem = (soCombo: number) => {
    const d = Object.values(useNhapKhach.getState().gio)[0][0];
    if (d.menu_combo_id === undefined) throw new Error("Cần dòng combo");
    expect(d.quantity).toBe(soCombo);
    expect(d.portions.filter((p) => p.option_ids.includes(11))).toHaveLength(Math.ceil((banh + 1) / 2) * soCombo);
    expect(d.portions.filter((p) => p.option_ids.includes(14))).toHaveLength(Math.floor((banh + 1) / 2) * soCombo);
    expect(d.portions.filter((p) => p.menu_item_id === 81).every((p) => p.option_ids.includes(14))).toBe(true);
    expect(d.portions.filter((p) => p.menu_item_id !== 82).every((p) => p.option_ids.includes(22))).toBe(true);
    expect(d.portions.filter((p) => p.menu_item_id === 82).every((p) => p.option_ids.length === 0)).toBe(true);
  };
  click("Thêm combo Đầy đặn"); dem(1);
  click("Thêm combo Đầy đặn"); dem(2);
  fireEvent.change(dong(1).getByRole("spinbutton"), { target: { value: "3" } }); dem(3);
  click("Bớt Đầy đặn"); dem(2);
  fireEvent.change(dong(1).getByRole("spinbutton"), { target: { value: "1" } }); dem(1);
  fireEvent.click(c.getByRole("radio", { name: "Thịt" }));
  expect((c.getByRole("radio", { name: "Mộc nhĩ và thịt" }) as HTMLInputElement).checked).toBe(false);
  click("Thêm combo Đầy đặn");
  expect(screen.getByRole("region", { name: "Dòng 2" })).toBeTruthy();
});
