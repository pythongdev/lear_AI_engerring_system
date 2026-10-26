import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import { useNhapKhach } from "@/lib/nhap-khach";
import { PhieuKhach } from "./_components/phieu-khach";
import { baoGia, clientBackend, serverBackend, type TraLoi } from "./mau-khach";
import type { components } from "@/lib/api/schema";

afterEach(() => { cleanup(); vi.unstubAllGlobals(); useNhapKhach.getState().xoaHet(); });

async function mo(tinhThu?: () => Promise<TraLoi>) {
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
    if (new URL(url).pathname === "/menu") return Response.json(menu);
    return b.fetch(input instanceof Request ? input : new Request(input));
  };
  render(<ApiProvider fetch={fetchMenu}><PhieuKhach ma="test-menu" nhan="3" initialMenu={menu} /></ApiProvider>);
  return b;
}
const click = (name: string) => fireEvent.click(screen.getByRole("button", { name }));
const dong = (n: number) => within(screen.getByRole("region", { name: `Dòng ${n}` }));
const card = (name: string) => screen.getByRole("button", { name }).closest("article")!;

it("thẻ món và combo: thêm dòng mặc định; bớt dòng cuối, bỏ ở 0 và tắt; output cộng số lượng", async () => {
  await mo();
  expect((screen.getByRole("button", { name: "Bớt Bánh cuốn" }) as HTMLButtonElement).disabled).toBe(true);
  expect(within(card("Thêm combo Đầy đặn")).getByText("72.000đ")).toBeTruthy();
  expect(within(card("Thêm combo Đầy đặn")).getByText("×2")).toBeTruthy();
  click("Thêm Bánh cuốn");
  click("Thêm combo Đầy đặn");
  click("Thêm Bánh cuốn");
  expect(dong(1).getByText("Thịt · Vừa")).toBeTruthy();
  expect(dong(2).getByText("Bánh cuốn suất 2: Thịt · Vừa")).toBeTruthy();
  fireEvent.change(dong(3).getByRole("spinbutton"), { target: { value: "3" } });
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
  expect(dong(2).queryByText(/suất 3/)).toBeNull();
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
  const b = await mo();
  const mon = within(card("Thêm Bánh cuốn"));
  expect((mon.getByRole("radio", { name: /^Thịt$/ }) as HTMLInputElement).checked).toBe(true);
  expect((mon.getByRole("radio", { name: "Vừa" }) as HTMLInputElement).checked).toBe(true);
  click("Thêm Bánh cuốn");
  fireEvent.click(mon.getByRole("radio", { name: "Thịt + mộc nhĩ" }));
  fireEvent.click(mon.getByRole("radio", { name: "Nhiều" }));
  click("Thêm Bánh cuốn");
  fireEvent.click(mon.getByRole("radio", { name: "Chay" }));
  expect(mon.queryByRole("radio", { name: "Nhiều" })).toBeNull();
  click("Thêm Bánh cuốn");
  expect(dong(1).getByText("Thịt · Vừa")).toBeTruthy();
  expect(dong(2).getByText("Thịt + mộc nhĩ · Nhiều")).toBeTruthy();
  expect(dong(3).getByText("Chay")).toBeTruthy();
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
  expect((combo.getByRole("radio", { name: /^Thịt$/ }) as HTMLInputElement).checked).toBe(true);
  expect((combo.getByRole("radio", { name: "Vừa" }) as HTMLInputElement).checked).toBe(true);
  fireEvent.click(combo.getByRole("radio", { name: "Thịt + mộc nhĩ" }));
  fireEvent.click(combo.getByRole("radio", { name: "Nhiều" }));
  click("Thêm combo Đầy đặn");
  fireEvent.click(combo.getByRole("radio", { name: "Chay" }));
  expect(combo.queryByRole("radio", { name: "Nhiều" })).toBeNull();
  click("Thêm combo Đầy đặn");
  expect(dong(1).getByText("Bánh cuốn suất 1: Thịt + mộc nhĩ · Nhiều")).toBeTruthy();
  expect(dong(1).getByText("Bánh cuốn suất 2: Thịt + mộc nhĩ · Nhiều")).toBeTruthy();
  expect(dong(2).getByText("Bánh cuốn suất 2: Chay")).toBeTruthy();
  fireEvent.change(dong(1).getByRole("spinbutton"), { target: { value: "2" } });
  expect(dong(1).getByText("Bánh cuốn suất 4: Thịt + mộc nhĩ · Nhiều")).toBeTruthy();
  await waitFor(() => expect(b.goi.some((g) => JSON.stringify(g.body?.lines) === JSON.stringify([
    { menu_combo_id: 99, quantity: 2, portions: [{ menu_item_id: 1, quantity: 4, option_ids: [13, 22] }] },
    { menu_combo_id: 99, quantity: 1, portions: [{ menu_item_id: 1, quantity: 2, option_ids: [12] }] },
  ]))).toBe(true));
});

it("ảnh thẻ dẫn đúng chi tiết combo/món và giữ mã bàn", async () => {
  await mo();
  expect(within(card("Thêm combo Đầy đặn")).getByRole("link", { name: "Xem chi tiết combo Đầy đặn" }).getAttribute("href")).toBe("/thuc-don/combo/99?ban=test-menu");
  expect(within(card("Thêm Bánh cuốn")).getByRole("link", { name: "Xem chi tiết món Bánh cuốn" }).getAttribute("href")).toBe("/thuc-don/mon/1?ban=test-menu");
});
