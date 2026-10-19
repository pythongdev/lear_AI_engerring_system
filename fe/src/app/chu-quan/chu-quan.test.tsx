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
    expect(within(nav).getAllByRole("link")).toHaveLength(2);
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
    ]);
    expect(routeThieuTrang(mucChuQuan)).toEqual([]);
    expect(routeThieuTrang([...mucChuQuan, { nhan: "Không có", route: "/chu-quan/khong-co" }]))
      .toEqual(["/chu-quan/khong-co"]);
  });
});
