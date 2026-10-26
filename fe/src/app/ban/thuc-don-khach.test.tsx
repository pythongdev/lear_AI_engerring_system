import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import { useNhapKhach } from "@/lib/nhap-khach";
import { PhieuKhach } from "./_components/phieu-khach";
import { baoGia, clientBackend, serverBackend, sx, tinhTheoGio, type Ghi, type TraLoi } from "./mau-khach";
import type { components } from "@/lib/api/schema";

afterEach(() => { cleanup(); vi.unstubAllGlobals(); useNhapKhach.getState().xoaHet(); });

async function mo(tinhThu?: (...a: Parameters<Ghi>) => Promise<TraLoi>) {
  serverBackend();
  const menu: components["schemas"]["Menu"] = await (await fetch("http://localhost/menu")).json();
  menu.items[0].option_groups[0].options.push({ menu_option_id: 13, option_name: "Thịt + mộc nhĩ", is_default: false });
  menu.items[0].option_groups[1].prerequisite_option_ids.push(13);
  menu.items[0].prices.push({ option_ids: [13, 21], unit_price_vnd: 35000 }, { option_ids: [13, 22], unit_price_vnd: 40000 });
  menu.combos = [{
    menu_combo_id: 99, name: "Đầy đặn", price_vnd: 72000,
    items: [{ ...menu.items[0], quantity: 2, surcharges: [] }],
  }];
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
const GIA_DONG: Record<string, number> = { "11,21:1": 35000, "11,21:3": 105000, "13,22:1": 40000, "12:1": 30000 };
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
  expect(within(card("Thêm combo Đầy đặn")).getByText("×2")).toBeTruthy();
  click("Thêm Bánh cuốn");
  click("Thêm combo Đầy đặn");
  click("Thêm Bánh cuốn");
  await waitFor(() => expect([cot(1, "Nhân"), cot(1, "Lượng nhân"), cot(1, "Giá")]).toEqual(["Thịt", "Vừa", "35.000đ"]));
  const nut = dong(2).getByRole("button", { name: "Chi tiết" });
  expect(nut.getAttribute("aria-expanded")).toBe("false");
  fireEvent.click(nut);
  expect(nut.getAttribute("aria-expanded")).toBe("true");
  expect(thanhPhan(2)).toEqual(["×2 Bánh cuốn"]);
  expect([cot(2, "Nhân"), cot(2, "Lượng nhân")]).toEqual(["Thịt", "Vừa"]);
  fireEvent.click(nut);
  expect(nut.getAttribute("aria-expanded")).toBe("false");
  fireEvent.change(dong(3).getByRole("spinbutton"), { target: { value: "3" } });
  await waitFor(() => expect(cot(3, "Giá")).toBe("105.000đ"));
  expect(card("Thêm Bánh cuốn").querySelector("output")?.textContent).toBe("4");
  click("Bớt Bánh cuốn");
  expect((dong(3).getByRole("spinbutton") as HTMLInputElement).value).toBe("2");
  expect((dong(1).getByRole("spinbutton") as HTMLInputElement).value).toBe("1");
  click("Bớt Bánh cuốn"); click("Bớt Bánh cuốn");
  expect(screen.queryByRole("region", { name: "Dòng 3" })).toBeNull();
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
  expect(mon.getByRole("button", { name: "Nhân: Thịt" })).toBeTruthy();
  expect(mon.getByRole("button", { name: "Lượng nhân: Vừa" })).toBeTruthy();
  expect(mon.queryByRole("radio")).toBeNull();
  click("Thêm Bánh cuốn");
  fireEvent.click(mon.getByRole("button", { name: "Nhân: Thịt" }));
  fireEvent.click(screen.getByRole("radio", { name: "Thịt + mộc nhĩ" }));
  expect(mon.queryByRole("radio")).toBeNull();
  fireEvent.click(mon.getByRole("button", { name: "Lượng nhân: Vừa" }));
  fireEvent.click(screen.getByRole("radio", { name: "Nhiều" }));
  expect(mon.queryByRole("radio")).toBeNull();
  click("Thêm Bánh cuốn");
  fireEvent.click(mon.getByRole("button", { name: "Nhân: Thịt + mộc nhĩ" }));
  fireEvent.click(screen.getByRole("radio", { name: "Chay" }));
  expect(mon.queryByRole("radio")).toBeNull();
  expect(mon.queryByRole("button", { name: /Lượng nhân/ })).toBeNull();
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
  expect(combo.getByRole("button", { name: "Nhân: Thịt" })).toBeTruthy();
  expect(combo.getByRole("button", { name: "Lượng nhân: Vừa" })).toBeTruthy();
  fireEvent.click(combo.getByRole("button", { name: "Nhân: Thịt" }));
  fireEvent.click(screen.getByRole("radio", { name: "Thịt + mộc nhĩ" }));
  expect(combo.queryByRole("radio")).toBeNull();
  fireEvent.click(combo.getByRole("button", { name: "Lượng nhân: Vừa" }));
  fireEvent.click(screen.getByRole("radio", { name: "Nhiều" }));
  expect(combo.queryByRole("radio")).toBeNull();
  click("Thêm combo Đầy đặn");
  fireEvent.click(combo.getByRole("button", { name: "Nhân: Thịt + mộc nhĩ" }));
  fireEvent.click(screen.getByRole("radio", { name: "Chay" }));
  expect(combo.queryByRole("radio")).toBeNull();
  expect(combo.queryByRole("button", { name: /Lượng nhân/ })).toBeNull();
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
  fireEvent.click(combo.getByRole("button", { name: "Nhân: Thịt" }));
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

it("bấm nhóm thì danh sách lựa chọn mở ngay trong thẻ, đánh dấu hiện tại; bấm lại hoặc chọn lại thì thu, giữ lựa chọn", async () => {
  await mo();
  const mon = within(card("Thêm Bánh cuốn"));
  const nut = mon.getByRole("button", { name: "Nhân: Thịt" });
  expect(nut.getAttribute("aria-expanded")).toBe("false");
  fireEvent.click(nut);
  expect(nut.getAttribute("aria-expanded")).toBe("true");
  expect((mon.getByRole("radio", { name: /^Thịt$/ }) as HTMLInputElement).checked).toBe(true);
  fireEvent.click(nut);
  expect(nut.getAttribute("aria-expanded")).toBe("false");
  expect(mon.queryByRole("radio")).toBeNull();
  fireEvent.click(nut);
  fireEvent.click(mon.getByRole("radio", { name: /^Thịt$/ }));
  expect(mon.queryByRole("radio")).toBeNull();
  expect(mon.getByRole("button", { name: "Nhân: Thịt" })).toBeTruthy();
});
