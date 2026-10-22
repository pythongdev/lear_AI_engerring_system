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
  expect((dong(1).getByRole("radio", { name: "Chay" }) as HTMLInputElement).checked).toBe(false);
  expect(dong(2).getAllByRole("group").some((g) => g.textContent?.includes("suất 2"))).toBe(true);
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
  expect(dong(2).getAllByRole("group").some((g) => g.textContent?.includes("suất 3"))).toBe(false);
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
