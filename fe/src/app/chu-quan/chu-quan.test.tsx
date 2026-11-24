import { existsSync } from "node:fs";
import { join } from "node:path";
import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { voiBackend } from "@/components/tai-khoan/test-utils";

import { mucChuQuan } from "./_components/muc-chu-quan";
import Layout from "./layout";
import Page from "./page";

const replace = vi.fn();
let duongDan = "/chu-quan";
vi.mock("next/navigation", () => ({
  useRouter: () => ({ replace }),
  usePathname: () => duongDan,
}));

beforeEach(() => {
  replace.mockReset();
  duongDan = "/chu-quan";
});
afterEach(cleanup);

const phien = (chuQuan: boolean) => ({
  person_id: 7, display_name: "Lan", role_code: chuQuan ? "owner" : "quay",
  is_owner: chuQuan, must_change_password: false, counter_duty_id: 0,
});

function moKhung(status: number, body: unknown) {
  return voiBackend(<Layout><Page /></Layout>, () => ({ status, body }));
}

function moNhom(nav: HTMLElement, ten: string) {
  const nut = within(nav).getByRole("button", { name: new RegExp(`^${ten}`) });
  fireEvent.click(nut);
  return nut;
}

function routeThieuTrang(danhSach: readonly { nhan: string; route: string }[]) {
  const thuMucApp = join(process.cwd(), "src/app");
  return danhSach.filter((muc) => !existsSync(join(thuMucApp, muc.route, "page.tsx")))
    .map((muc) => muc.route);
}

describe("khung chủ quán", () => {
  it("chủ quán: hiện Tổng quan là trang hiện tại và nội dung con", async () => {
    moKhung(200, phien(true));
    const nav = await screen.findByRole("navigation", { name: "Trang chủ quán" });
    const muc = within(nav).getByRole("link", { name: "Tổng quan" });
    expect(muc.getAttribute("href")).toBe("/chu-quan");
    expect(muc.getAttribute("aria-current")).toBe("page");
    expect(within(nav).getAllByRole("link")).toHaveLength(3);
    expect(within(nav).getAllByRole("button")).toHaveLength(3);
    expect(within(nav).queryByRole("link", { name: "Sản phẩm" })).toBeNull();
    expect(screen.getByRole("heading", { name: "Tổng quan" })).toBeTruthy();
    expect(replace).not.toHaveBeenCalled();
  });

  it("đường dẫn con không làm Tổng quan sáng; Tổng kết sáng", async () => {
    duongDan = "/chu-quan/tong-ket";
    moKhung(200, phien(true));
    const nav = await screen.findByRole("navigation");
    expect(within(nav).getByRole("link", { name: "Tổng quan" }).getAttribute("aria-current")).toBeNull();
    const tongKet = within(nav).getByRole("link", { name: "Tổng kết" });
    expect(tongKet.getAttribute("href")).toBe("/chu-quan/tong-ket");
    expect(tongKet.getAttribute("aria-current")).toBe("page");
  });

  it("Sản phẩm sáng ở route của nó", async () => {
    duongDan = "/chu-quan/san-pham";
    moKhung(200, phien(true));
    const nav = await screen.findByRole("navigation");
    moNhom(nav, "Bán hàng");
    const sanPham = within(nav).getByRole("link", { name: "Sản phẩm" });
    expect(sanPham.getAttribute("href")).toBe("/chu-quan/san-pham");
    expect(sanPham.getAttribute("aria-current")).toBe("page");
    expect(within(nav).getByRole("link", { name: "Tổng kết" }).getAttribute("aria-current")).toBeNull();
  });

  it("Combo và Danh mục sáng ở route của mình", async () => {
    duongDan = "/chu-quan/danh-muc";
    moKhung(200, phien(true));
    const nav = await screen.findByRole("navigation");
    moNhom(nav, "Bán hàng");
    const danhMuc = within(nav).getByRole("link", { name: "Danh mục" });
    expect(danhMuc.getAttribute("href")).toBe("/chu-quan/danh-muc");
    expect(danhMuc.getAttribute("aria-current")).toBe("page");
    const combo = within(nav).getByRole("link", { name: "Combo" });
    expect(combo.getAttribute("href")).toBe("/chu-quan/combo");
    expect(combo.getAttribute("aria-current")).toBeNull();
  });

  it("Nhân viên sáng ở route của nó", async () => {
    duongDan = "/chu-quan/nhan-vien";
    moKhung(200, phien(true));
    const nav = await screen.findByRole("navigation");
    moNhom(nav, "Nhân sự");
    const nhanVien = within(nav).getByRole("link", { name: "Nhân viên" });
    expect(nhanVien.getAttribute("href")).toBe("/chu-quan/nhan-vien");
    expect(nhanVien.getAttribute("aria-current")).toBe("page");
  });

  it.each([["Vận hành", "/chu-quan/van-hanh", null], ["Giao việc", "/chu-quan/giao-viec", "Nhân sự"], ["Khoản chi", "/chu-quan/khoan-chi", "Kho & chi"], ["Đào tạo", "/chu-quan/dao-tao", "Nhân sự"]])("%s sáng ở route của nó", async (nhan, route, nhom) => {
    duongDan = route;
    moKhung(200, phien(true));
    const nav = await screen.findByRole("navigation");
    if (nhom) {
      const nut = within(nav).getByRole("button", { name: `${nhom} · ${nhan}` });
      expect(nut.className).toContain("font-semibold");
      fireEvent.click(nut);
    }
    const muc = within(nav).getByRole("link", { name: nhan });
    expect(muc.getAttribute("href")).toBe(route);
    expect(muc.getAttribute("aria-current")).toBe("page");
  });

  it("ba nhóm mở đúng các trang, chỉ một nhóm mở mỗi lần", async () => {
    moKhung(200, phien(true));
    const nav = await screen.findByRole("navigation", { name: "Trang chủ quán" });
    const cacNhom = [
      ["Bán hàng", ["Sản phẩm", "Menu & giá", "Danh mục", "Combo", "Topping"]],
      ["Nhân sự", ["Nhân viên", "Giao việc", "Đào tạo"]],
      ["Kho & chi", ["Khoản chi"]],
    ] as const;
    for (const [ten, cacTrang] of cacNhom) {
      const nut = moNhom(nav, ten);
      expect(nut.getAttribute("aria-expanded")).toBe("true");
      expect(within(nav).getAllByRole("link")).toHaveLength(3 + cacTrang.length);
      for (const trang of cacTrang) expect(within(nav).getByRole("link", { name: trang })).toBeTruthy();
    }
    expect(within(nav).getByRole("button", { name: "Bán hàng" }).getAttribute("aria-expanded")).toBe("false");
  });

  it("Escape, bấm ngoài và chọn trang đều thu nhóm", async () => {
    moKhung(200, phien(true));
    const nav = await screen.findByRole("navigation", { name: "Trang chủ quán" });
    const nut = moNhom(nav, "Bán hàng");
    fireEvent.keyDown(document, { key: "Escape" });
    expect(nut.getAttribute("aria-expanded")).toBe("false");
    expect(document.activeElement).toBe(nut);

    moNhom(nav, "Bán hàng");
    fireEvent.pointerDown(document.body);
    expect(nut.getAttribute("aria-expanded")).toBe("false");

    moNhom(nav, "Bán hàng");
    const combo = within(nav).getByRole("link", { name: "Combo" });
    combo.addEventListener("click", (event) => event.preventDefault(), { once: true });
    fireEvent.click(combo);
    expect(nut.getAttribute("aria-expanded")).toBe("false");
  });

  it("phiên quầy: chuyển về /quay, không hiện nav hay nội dung con", async () => {
    moKhung(200, phien(false));
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/quay"));
    expect(screen.queryByRole("navigation")).toBeNull();
    expect(screen.queryByRole("heading", { name: "Tổng quan" })).toBeNull();
  });

  it("401 unauthenticated: chuyển về /dang-nhap, không hiện nav hay nội dung con", async () => {
    moKhung(401, { code: "unauthenticated" });
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/dang-nhap"));
    expect(screen.queryByRole("navigation")).toBeNull();
    expect(screen.queryByRole("heading", { name: "Tổng quan" })).toBeNull();
  });

  it("mọi mục có page.tsx thật; phát hiện route giả trong bản sao", () => {
    expect(mucChuQuan).toEqual([
      { nhan: "Tổng quan", route: "/chu-quan", nhom: "truc_tiep" },
      { nhan: "Vận hành", route: "/chu-quan/van-hanh", nhom: "truc_tiep" },
      { nhan: "Tổng kết", route: "/chu-quan/tong-ket", nhom: "truc_tiep" },
      { nhan: "Sản phẩm", route: "/chu-quan/san-pham", nhom: "ban_hang" },
      { nhan: "Menu & giá", route: "/chu-quan/menu-gia", nhom: "ban_hang" },
      { nhan: "Danh mục", route: "/chu-quan/danh-muc", nhom: "ban_hang" },
      { nhan: "Combo", route: "/chu-quan/combo", nhom: "ban_hang" },
      { nhan: "Topping", route: "/chu-quan/topping", nhom: "ban_hang" },
      { nhan: "Nhân viên", route: "/chu-quan/nhan-vien", nhom: "nhan_su" },
      { nhan: "Giao việc", route: "/chu-quan/giao-viec", nhom: "nhan_su" },
      { nhan: "Khoản chi", route: "/chu-quan/khoan-chi", nhom: "kho_chi" },
      { nhan: "Đào tạo", route: "/chu-quan/dao-tao", nhom: "nhan_su" },
    ]);
    expect(routeThieuTrang(mucChuQuan)).toEqual([]);
    expect(routeThieuTrang([...mucChuQuan, { nhan: "Không có", route: "/chu-quan/khong-co" }]))
      .toEqual(["/chu-quan/khong-co"]);
  });
});
