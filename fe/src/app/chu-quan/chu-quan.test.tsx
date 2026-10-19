import { existsSync } from "node:fs";
import { join } from "node:path";
import { cleanup, screen, waitFor, within } from "@testing-library/react";
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
    expect(within(nav).getAllByRole("link")).toHaveLength(11);
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
    const sanPham = within(nav).getByRole("link", { name: "Sản phẩm" });
    expect(sanPham.getAttribute("href")).toBe("/chu-quan/san-pham");
    expect(sanPham.getAttribute("aria-current")).toBe("page");
    expect(within(nav).getByRole("link", { name: "Tổng kết" }).getAttribute("aria-current")).toBeNull();
  });

  it("Combo và Danh mục sáng ở route của mình", async () => {
    duongDan = "/chu-quan/danh-muc";
    moKhung(200, phien(true));
    const nav = await screen.findByRole("navigation");
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
    const nhanVien = within(nav).getByRole("link", { name: "Nhân viên" });
    expect(nhanVien.getAttribute("href")).toBe("/chu-quan/nhan-vien");
    expect(nhanVien.getAttribute("aria-current")).toBe("page");
  });

  it.each([["Giao việc", "/chu-quan/giao-viec"], ["Nguyên liệu", "/chu-quan/nguyen-lieu"], ["Kho", "/chu-quan/kho"], ["Khoản chi", "/chu-quan/khoan-chi"], ["Đào tạo", "/chu-quan/dao-tao"]])("%s sáng ở route của nó", async (nhan, route) => {
    duongDan = route;
    moKhung(200, phien(true));
    const nav = await screen.findByRole("navigation");
    const muc = within(nav).getByRole("link", { name: nhan });
    expect(muc.getAttribute("href")).toBe(route);
    expect(muc.getAttribute("aria-current")).toBe("page");
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
      { nhan: "Tổng quan", route: "/chu-quan" },
      { nhan: "Tổng kết", route: "/chu-quan/tong-ket" },
      { nhan: "Sản phẩm", route: "/chu-quan/san-pham" },
      { nhan: "Danh mục", route: "/chu-quan/danh-muc" },
      { nhan: "Combo", route: "/chu-quan/combo" },
      { nhan: "Nhân viên", route: "/chu-quan/nhan-vien" },
      { nhan: "Giao việc", route: "/chu-quan/giao-viec" },
      { nhan: "Nguyên liệu", route: "/chu-quan/nguyen-lieu" },
      { nhan: "Kho", route: "/chu-quan/kho" },
      { nhan: "Khoản chi", route: "/chu-quan/khoan-chi" },
      { nhan: "Đào tạo", route: "/chu-quan/dao-tao" },
    ]);
    expect(routeThieuTrang(mucChuQuan)).toEqual([]);
    expect(routeThieuTrang([...mucChuQuan, { nhan: "Không có", route: "/chu-quan/khong-co" }]))
      .toEqual(["/chu-quan/khong-co"]);
  });
});
