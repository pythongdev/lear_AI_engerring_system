import { cleanup, render, screen, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { coThanhTabKhach, ThanhTabKhach } from "./thanh-tab-khach";

const route = vi.hoisted(() => ({ path: "/dat-mon" as string | null }));
vi.mock("next/navigation", () => ({ usePathname: () => route.path }));
beforeEach(() => { route.path = "/dat-mon"; });
afterEach(cleanup);

describe("T-374 ThanhTabKhach", () => {
  it("thanh cố định đáy có đúng bốn liên kết theo thứ tự, biểu tượng và nhãn", () => {
    render(<ThanhTabKhach />);
    const nav = screen.getByRole("navigation", { name: "Điều hướng khách" });
    expect(nav.getAttribute("data-component")).toBe("ThanhTabKhach");
    for (const token of ["fixed", "inset-x-0", "bottom-0", "z-40", "border-t", "bg-background", "pb-[env(safe-area-inset-bottom)]"]) {
      expect(nav.classList.contains(token)).toBe(true);
    }
    const links = within(nav).getAllByRole("link");
    expect(links.map((link) => [link.textContent, link.getAttribute("href")])).toEqual([
      ["Đặt món", "/dat-mon"], ["Đơn đã đặt", "/khach/don"],
      ["Tài khoản", "/khach/tai-khoan"], ["Yêu thích", "/khach/yeu-thich"],
    ]);
    for (const link of links) {
      expect(link.classList.contains("min-h-14")).toBe(true);
      expect(link.querySelectorAll("svg")).toHaveLength(1);
      expect(link.querySelector("svg")?.getAttribute("aria-hidden")).toBe("true");
      expect(link.querySelector("svg")?.classList.contains("size-5")).toBe(true);
    }
  });

  it.each([
    ["/dat-mon", "Đặt món"], ["/khach/don", "Đơn đã đặt"], ["/khach/don/12", "Đơn đã đặt"],
    ["/khach/yeu-thich", "Yêu thích"], ["/khach/tai-khoan", "Tài khoản"],
    ["/khach/dang-nhap", "Tài khoản"], ["/khach/dang-ky", "Tài khoản"],
    ["/khach/quen-mat-khau", "Tài khoản"], ["/khach/dat-lai-mat-khau", "Tài khoản"], ["/khach/xac-nhan-gmail", "Tài khoản"],
  ])("%s chỉ làm sáng mục %s", (path, nhan) => {
    route.path = path;
    render(<ThanhTabKhach />);
    const active = screen.getAllByRole("link", { current: "page" });
    expect(active).toHaveLength(1);
    expect(active[0].textContent).toBe(nhan);
    expect(active[0].className).toContain("text-[#EA6A0C] dark:text-[#FF7A1A]");
    for (const link of screen.getAllByRole("link").filter((link) => link !== active[0])) {
      expect(link.hasAttribute("aria-current")).toBe(false);
      expect(link.classList.contains("text-muted-foreground")).toBe(true);
    }
  });

  it.each(["/khach/donx", null])("%s không làm sáng mục nào", (path) => {
    route.path = path;
    render(<ThanhTabKhach />);
    expect(screen.queryAllByRole("link", { current: "page" })).toHaveLength(0);
  });

  it.each([
    ["/dat-mon", true], ["/khach/don", true], ["/khach/donx", true],
    ["/ban/3", false], ["/thuc-don/mon/1", false], ["/chu-quan", false], ["/khachx/don", false], [null, false],
  ])("coThanhTabKhach(%s) = %s", (path, expected) => {
    expect(coThanhTabKhach(path)).toBe(expected);
  });
});
