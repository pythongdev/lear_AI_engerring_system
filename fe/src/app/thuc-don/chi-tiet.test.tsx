import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";
import ChiTietMonPage from "./[loai]/[id]/page";
import { dungLai, useNhapKhach } from "@/lib/nhap-khach";
import { menuMau } from "../ban/mau-khach";

vi.mock("next/navigation", () => ({ notFound: () => { throw new Error("NEXT_NOT_FOUND"); } }));
afterEach(() => { cleanup(); useNhapKhach.getState().xoaHet(); vi.unstubAllGlobals(); });

const menu = { ...menuMau, combos: [{ menu_combo_id: 99, name: "Combo hai bánh", price_vnd: 72000,
  items: [{ ...menuMau.items[0], quantity: 2, surcharges: [] }],
}] };
const trang = (loai: string, id: string, ban?: string) => ChiTietMonPage({ params: Promise.resolve({ loai, id }), searchParams: Promise.resolve({ ban }) });

it("chi tiết combo đọc menu mới, hiện thành phần và giá backend, giữ đường về bàn", async () => {
  const fetchMenu = vi.fn(async () => Response.json(menu));
  vi.stubGlobal("fetch", fetchMenu);
  render(await trang("combo", "99", "3"));
  expect(screen.getByRole("heading", { level: 1 }).textContent).toBe("Combo hai bánh");
  expect(screen.getByText("Giá combo 72.000đ")).toBeTruthy();
  expect(screen.getByText("×2")).toBeTruthy();
  expect(screen.getByRole("link", { name: "Bánh cuốn" }).getAttribute("href")).toBe("/thuc-don/mon/1?ban=3");
  expect(screen.getByRole("link", { name: "Quay lại menu" }).getAttribute("href")).toBe("/ban/3");
  expect(fetchMenu).toHaveBeenCalledWith(expect.stringMatching(/\/menu$/), { cache: "no-store" });
});

it("chi tiết món hiện giá từng tổ hợp, không có bàn quay về đặt món", async () => {
  vi.stubGlobal("fetch", async () => Response.json(menu));
  render(await trang("mon", "1"));
  expect(screen.getByRole("heading", { level: 1 }).textContent).toBe("Bánh cuốn");
  expect(screen.getByText("Thịt · Vừa")).toBeTruthy();
  expect(screen.getByText("35.000đ")).toBeTruthy();
  expect(screen.getByText("Thịt · Nhiều")).toBeTruthy();
  expect(screen.getByText("40.000đ")).toBeTruthy();
  expect(screen.getByRole("link", { name: "Quay lại menu" }).getAttribute("href")).toBe("/dat-mon");
});

it.each([["khac", "1"], ["mon", "-1"], ["combo", "9007199254740993"], ["mon", "999"]])("loại/id không tồn tại trả 404: %s/%s", async (loai, id) => {
  vi.stubGlobal("fetch", async () => Response.json(menu));
  await expect(trang(loai, id)).rejects.toThrow("NEXT_NOT_FOUND");
});

it.each([false, true])("lỗi đọc không hiện như món không tồn tại, vẫn có đường về an toàn (mất mạng=%s)", async (matMang) => {
  vi.stubGlobal("fetch", async () => { if (matMang) throw new TypeError("network"); return new Response(null, { status: 503 }); });
  render(await trang("mon", "1", "//example.com"));
  expect(screen.getByRole("alert").textContent).toContain("Chưa đọc được chi tiết món");
  expect(screen.getByRole("link", { name: "Quay lại menu" }).getAttribute("href")).toBe("/ban/%2F%2Fexample.com");
});


it("chi tiết thêm từng lựa chọn và số lượng vào giỏ bàn, giữ giỏ cũ và cách ly bàn/web", async () => {
  useNhapKhach.getState().sua("qr:3", [{ mon: menu.items[1], quantity: 1, option_ids: [], is_takeaway: false }]);
  vi.stubGlobal("fetch", async () => Response.json(menu));
  const view = render(await trang("mon", "1", "3"));
  expect((screen.getByRole("radio", { name: "Thịt" }) as HTMLInputElement).checked).toBe(true);
  expect((screen.getByRole("radio", { name: "Vừa" }) as HTMLInputElement).checked).toBe(true);
  fireEvent.click(screen.getByRole("radio", { name: "Nhiều" }));
  expect(screen.getByText("Giá đơn vị 40.000đ")).toBeTruthy();
  fireEvent.change(screen.getByRole("spinbutton", { name: "Số lượng" }), { target: { value: "2" } });
  fireEvent.click(screen.getByRole("button", { name: "Thêm vào giỏ" }));
  expect(screen.getByRole("status").textContent).toContain("Đã thêm 2 Bánh cuốn");
  fireEvent.click(screen.getByRole("radio", { name: "Chay" }));
  expect(screen.queryByRole("radio", { name: "Nhiều" })).toBeNull();
  fireEvent.click(screen.getByRole("button", { name: "Thêm vào giỏ" }));
  expect(useNhapKhach.getState().gio["qr:3"]).toEqual([
    { menu_item_id: 2, quantity: 1, option_ids: [] },
    { menu_item_id: 1, quantity: 2, option_ids: [11, 22] },
    { menu_item_id: 1, quantity: 2, option_ids: [12] },
  ]);
  expect(useNhapKhach.getState().gio.web).toBeUndefined();
  expect(useNhapKhach.getState().gio["qr:4"]).toBeUndefined();
  view.unmount();
  expect(dungLai(useNhapKhach.getState().gio["qr:3"], menu)).toHaveLength(3);
});

it("combo áp lựa chọn chung đúng mọi suất, thêm vào giỏ web khi không có bàn", async () => {
  vi.stubGlobal("fetch", async () => Response.json(menu));
  render(await trang("combo", "99"));
  fireEvent.click(screen.getByRole("radio", { name: "Chay" }));
  fireEvent.change(screen.getByRole("spinbutton", { name: "Số lượng" }), { target: { value: "2" } });
  fireEvent.click(screen.getByRole("button", { name: "Thêm vào giỏ" }));
  expect(useNhapKhach.getState().gio.web).toEqual([{ menu_combo_id: 99, quantity: 2,
    portions: Array.from({ length: 4 }, () => ({ menu_item_id: 1, option_ids: [12] })),
  }]);
});

it.each(["", "0", "-1", "1.5"])("số lượng không nguyên dương không thể thêm: %s", async (value) => {
  vi.stubGlobal("fetch", async () => Response.json(menu));
  render(await trang("mon", "1", "3"));
  fireEvent.change(screen.getByRole("spinbutton", { name: "Số lượng" }), { target: { value } });
  expect((screen.getByRole("button", { name: "Thêm vào giỏ" }) as HTMLButtonElement).disabled).toBe(true);
  fireEvent.click(screen.getByRole("button", { name: "Thêm vào giỏ" }));
  expect(useNhapKhach.getState().gio).toEqual({});
});

it("tổ hợp không có giá bị chặn, món không có nhóm vẫn thêm được", async () => {
  vi.stubGlobal("fetch", async () => Response.json({ ...menu, items: [{ ...menu.items[0], prices: [] }, menu.items[1]] }));
  const view = render(await trang("mon", "1"));
  expect((screen.getByRole("button", { name: "Thêm vào giỏ" }) as HTMLButtonElement).disabled).toBe(true);
  view.unmount();
  render(await trang("mon", "2"));
  expect(screen.queryByRole("radio")).toBeNull();
  fireEvent.click(screen.getByRole("button", { name: "Thêm vào giỏ" }));
  expect(useNhapKhach.getState().gio.web).toEqual([{ menu_item_id: 2, quantity: 1, option_ids: [] }]);
});


it("chuyển sang món khác bắt đầu lại số lượng và lựa chọn của món đó", async () => {
  vi.stubGlobal("fetch", async () => Response.json(menu));
  const view = render(await trang("mon", "1", "3"));
  fireEvent.click(screen.getByRole("radio", { name: "Chay" }));
  fireEvent.change(screen.getByRole("spinbutton", { name: "Số lượng" }), { target: { value: "3" } });
  view.rerender(await trang("mon", "2", "3"));
  expect((screen.getByRole("spinbutton", { name: "Số lượng" }) as HTMLInputElement).value).toBe("1");
  fireEvent.click(screen.getByRole("button", { name: "Thêm vào giỏ" }));
  expect(useNhapKhach.getState().gio["qr:3"]).toEqual([{ menu_item_id: 2, quantity: 1, option_ids: [] }]);
});
