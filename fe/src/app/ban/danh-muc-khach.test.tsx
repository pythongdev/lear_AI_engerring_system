// T-237 — trang gọi món của khách chia món theo danh mục đọc từ GET /menu (I-032; bản thiết kế
// docs/product/4-fe/thiet_ke/khach_hang/menu/menu.html, khối CategoryTabs). Claude viết TRƯỚC khi có code.
//
// Hợp đồng màn Claude chốt (2026-11-04) — áp cho `PhieuKhach`, tức cả `/ban/[ma]` lẫn `/dat-mon`:
// - Có ít nhất một phần tử trong `menu.categories` ⇒ hàng thẻ `<nav aria-label="Danh mục">` gồm các nút có `aria-pressed`,
//   theo thứ tự: "Tất cả" (bấm sẵn), mỗi danh mục theo ĐÚNG thứ tự API (không tự xếp lại), "Món khác" khi có món
//   `menu_category_id` null, "Combo" khi có combo. Bấm một nút ⇒ nút ấy `aria-pressed="true"`, các nút khác "false".
// - "Tất cả": khối COMBO như cũ (tiêu đề "COMBO"), rồi mỗi danh mục một `<section>` có tiêu đề cấp 2 là tên danh mục và
//   là vùng (`role="region"`) mang tên ấy, rồi vùng "Món khác" cho món chưa xếp. Danh mục không có món nào khớp tìm kiếm
//   thì ẩn cả khối.
// - Chọn một danh mục ⇒ chỉ khối danh mục ấy; "Món khác" ⇒ chỉ khối ấy; "Combo" ⇒ chỉ khối COMBO. Ô "Tìm món nhanh" lọc
//   trong lựa chọn đang bấm; không còn gì ⇒ "Không có món nào khớp.".
// - Đổi thẻ không làm mất giỏ (dải "{n} món" giữ nguyên).
// - `menu.categories` rỗng ⇒ không có hàng thẻ, bố cục cũ giữ nguyên: COMBO rồi một khối "MÓN LẺ" chứa mọi món.
import { cleanup, fireEvent, render, screen, within } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import { useNhapKhach } from "@/lib/nhap-khach";
import { PhieuKhach } from "./_components/phieu-khach";
import { clientBackend, menuMau } from "./mau-khach";

type Menu = components["schemas"]["Menu"];

afterEach(() => { cleanup(); vi.unstubAllGlobals(); useNhapKhach.getState().xoaHet(); });

function menuCoDanhMuc(): Menu {
  const [banh, canh] = structuredClone(menuMau.items) as Menu["items"];
  return {
    // Cố ý không theo bảng chữ cái: màn giữ đúng thứ tự API.
    categories: [{ menu_category_id: 7, name: "Bánh cuốn" }, { menu_category_id: 8, name: "Ăn kèm" }],
    items: [
      { ...banh, menu_category_id: 7 },
      { ...canh, menu_category_id: 8 },
      { menu_item_id: 3, item_name: "Chả quế", option_groups: [], prices: [{ option_ids: [], unit_price_vnd: 15000 }], menu_category_id: 8 },
      { menu_item_id: 4, item_name: "Nước chanh", option_groups: [], prices: [{ option_ids: [], unit_price_vnd: 12000 }], menu_category_id: null },
    ],
    combos: [{ menu_combo_id: 99, name: "Đầy đặn", price_vnd: 72000, items: [{ ...banh, quantity: 2, surcharges: [] }] }],
  };
}

function mo(menu: Menu) {
  const b = clientBackend();
  const fetchMenu = async (req: Request) => {
    if (new URL(req.url).pathname.replace(/^\/api/, "") === "/menu") return Response.json(menu);
    return b.fetch(req);
  };
  render(<ApiProvider fetch={fetchMenu}><PhieuKhach ma="test-danh-muc" nhan="3" initialMenu={menu} /></ApiProvider>);
}

const theDanhMuc = () => screen.getByRole("navigation", { name: "Danh mục" });
const nut = (ten: string) => within(theDanhMuc()).getByRole("button", { name: ten });
const tieuDe2 = () => screen.getAllByRole("heading", { level: 2 }).map((h) => h.textContent?.trim());
const monTrong = (vung: string) => within(screen.getByRole("region", { name: vung })).getAllByRole("heading", { level: 3 }).map((h) => h.textContent?.trim());

it("D1 hàng thẻ theo đúng thứ tự API, Tất cả bấm sẵn và bày mọi khối theo danh mục", () => {
  mo(menuCoDanhMuc());
  const nhan = within(theDanhMuc()).getAllByRole("button").map((b) => b.textContent?.trim());
  expect(nhan).toEqual(["Tất cả", "Bánh cuốn", "Ăn kèm", "Món khác", "Combo"]);
  expect(nut("Tất cả").getAttribute("aria-pressed")).toBe("true");
  for (const ten of ["Bánh cuốn", "Ăn kèm", "Món khác", "Combo"]) expect(nut(ten).getAttribute("aria-pressed")).toBe("false");
  expect(tieuDe2()).toEqual(["COMBO", "Bánh cuốn", "Ăn kèm", "Món khác", "Tóm tắt đơn hàng"]);
  expect(monTrong("Bánh cuốn")).toEqual(["Bánh cuốn"]);
  expect(new Set(monTrong("Ăn kèm"))).toEqual(new Set(["Canh", "Chả quế"]));
  expect(monTrong("Món khác")).toEqual(["Nước chanh"]);
  expect(screen.queryByRole("heading", { name: "MÓN LẺ" })).toBeNull();
});

it("D2 chọn một thẻ chỉ bày khối của thẻ ấy; Tất cả trả lại mọi khối", () => {
  mo(menuCoDanhMuc());
  fireEvent.click(nut("Ăn kèm"));
  expect(nut("Ăn kèm").getAttribute("aria-pressed")).toBe("true");
  expect(nut("Tất cả").getAttribute("aria-pressed")).toBe("false");
  expect(tieuDe2()).toEqual(["Ăn kèm", "Tóm tắt đơn hàng"]);
  expect(new Set(monTrong("Ăn kèm"))).toEqual(new Set(["Canh", "Chả quế"]));

  fireEvent.click(nut("Combo"));
  expect(tieuDe2()).toEqual(["COMBO", "Tóm tắt đơn hàng"]);
  expect(screen.getByRole("heading", { level: 3, name: "Đầy đặn" })).toBeTruthy();

  fireEvent.click(nut("Món khác"));
  expect(tieuDe2()).toEqual(["Món khác", "Tóm tắt đơn hàng"]);
  expect(monTrong("Món khác")).toEqual(["Nước chanh"]);

  fireEvent.click(nut("Tất cả"));
  expect(tieuDe2()).toEqual(["COMBO", "Bánh cuốn", "Ăn kèm", "Món khác", "Tóm tắt đơn hàng"]);
});

it("D3 tìm món lọc trong thẻ đang bấm; không còn gì thì báo không khớp", () => {
  mo(menuCoDanhMuc());
  const tim = screen.getByRole("searchbox", { name: "Tìm món nhanh" });
  fireEvent.click(nut("Ăn kèm"));
  fireEvent.change(tim, { target: { value: "chả" } });
  expect(monTrong("Ăn kèm")).toEqual(["Chả quế"]);
  fireEvent.change(tim, { target: { value: "bánh" } });
  expect(screen.queryByRole("region", { name: "Ăn kèm" })).toBeNull();
  expect(screen.getByText("Không có món nào khớp.")).toBeTruthy();
  // Ở "Tất cả", danh mục không có món khớp thì ẩn cả khối. Combo vẫn chỉ tìm theo tên combo như màn cũ
  // ("Đầy đặn" không khớp "bánh" dù có món Bánh cuốn bên trong) — sửa 2026-11-04 khi duyệt, Claude.
  fireEvent.click(nut("Tất cả"));
  expect(tieuDe2()).toEqual(["Bánh cuốn", "Tóm tắt đơn hàng"]);
});

it("D4 đổi thẻ không làm mất giỏ", () => {
  mo(menuCoDanhMuc());
  fireEvent.click(nut("Ăn kèm"));
  fireEvent.click(screen.getByRole("button", { name: "Thêm Chả quế" }));
  expect(screen.getByRole("button", { name: "1 món" })).toBeTruthy();
  fireEvent.click(nut("Bánh cuốn"));
  expect(screen.getByRole("button", { name: "1 món" })).toBeTruthy();
  fireEvent.click(nut("Ăn kèm"));
  expect(screen.getByRole("button", { name: "Bớt Chả quế" })).toBeTruthy();
});

it("D5 chưa có danh mục nào thì giữ bố cục cũ, không có hàng thẻ", () => {
  const menu: Menu = { ...structuredClone(menuMau) as Menu, categories: [] };
  mo(menu);
  expect(screen.queryByRole("navigation", { name: "Danh mục" })).toBeNull();
  const list = screen.getByRole("heading", { name: "MÓN LẺ" }).closest("section")!;
  expect(new Set(within(list).getAllByRole("heading", { level: 3 }).map((h) => h.textContent?.trim()))).toEqual(new Set(["Bánh cuốn", "Canh"]));
});
