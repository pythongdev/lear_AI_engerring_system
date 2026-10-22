import { cleanup, fireEvent, render, screen } from "@testing-library/react";
import { renderToStaticMarkup } from "react-dom/server";
import { afterEach, beforeEach, expect, it, vi } from "vitest";
import { ChuyenGiaoDien } from "./chuyen-giao-dien";
import { scriptGiaoDien } from "@/lib/giao-dien";
import Layout from "@/app/layout";

beforeEach(() => {
  localStorage.clear();
  document.documentElement.classList.remove("dark");
  document.documentElement.style.colorScheme = "";
  vi.stubGlobal("matchMedia", vi.fn().mockReturnValue({ matches: false }));
});
afterEach(() => {
  cleanup();
  vi.restoreAllMocks();
  vi.unstubAllGlobals();
});

it("bấm nút thêm / bỏ dark, đổi aria-label và colorScheme", () => {
  render(<ChuyenGiaoDien />);
  fireEvent.click(screen.getByRole("button", { name: "Chuyển sang giao diện tối" }));
  expect(document.documentElement.classList.contains("dark")).toBe(true);
  expect(document.documentElement.style.colorScheme).toBe("dark");
  fireEvent.click(screen.getByRole("button", { name: "Chuyển sang giao diện sáng" }));
  expect(document.documentElement.classList.contains("dark")).toBe(false);
  expect(document.documentElement.style.colorScheme).toBe("light");
  expect(screen.getByRole("button", { name: "Chuyển sang giao diện tối" })).toBeDefined();
});

it.each(["sang", "toi"])("ghi và dựng lại đọc lựa chọn %s, ưu tiên hơn hệ thống", (luaChon) => {
  vi.mocked(matchMedia).mockReturnValue({ matches: luaChon === "sang" } as MediaQueryList);
  const view = render(<ChuyenGiaoDien />);
  fireEvent.click(screen.getByRole("button"));
  expect(localStorage.getItem("giao-dien")).toBe(luaChon);
  view.unmount();
  document.documentElement.classList.toggle("dark", luaChon !== "toi");
  render(<ChuyenGiaoDien />);
  expect(document.documentElement.classList.contains("dark")).toBe(luaChon === "toi");
});

it("localStorage ném lỗi khi đọc / ghi vẫn đổi giao diện", () => {
  vi.spyOn(Storage.prototype, "getItem").mockImplementation(() => { throw new Error("blocked"); });
  vi.spyOn(Storage.prototype, "setItem").mockImplementation(() => { throw new Error("blocked"); });
  expect(() => render(<ChuyenGiaoDien />)).not.toThrow();
  expect(() => fireEvent.click(screen.getByRole("button"))).not.toThrow();
  expect(document.documentElement.classList.contains("dark")).toBe(true);
  fireEvent.click(screen.getByRole("button"));
  expect(document.documentElement.classList.contains("dark")).toBe(false);
});

it.each([false, true])("chưa chọn thì theo prefers-color-scheme = %s", (matches) => {
  vi.mocked(matchMedia).mockReturnValue({ matches } as MediaQueryList);
  render(<ChuyenGiaoDien />);
  expect(matchMedia).toHaveBeenCalledWith("(prefers-color-scheme: dark)");
  expect(document.documentElement.classList.contains("dark")).toBe(matches);
});

it("root layout đặt script đồng bộ trong head và chỉ gắn một nút", () => {
  const layout = Layout({ children: "" } as Parameters<typeof Layout>[0]);
  expect(layout.props.suppressHydrationWarning).toBe(true);
  const html = renderToStaticMarkup(layout);
  expect(html).toContain(`<head><script>${scriptGiaoDien}</script></head>`);
  expect(html.match(/aria-label="Chuyển sang giao diện tối"/g)).toHaveLength(1);
});

it.each([null, "sang", "toi", "khong-hop-le"])("script trước khi vẽ thực thi đúng lựa chọn %s", (saved) => {
  if (saved !== null) localStorage.setItem("giao-dien", saved);
  vi.mocked(matchMedia).mockReturnValue({ matches: true } as MediaQueryList);
  new Function(scriptGiaoDien)();
  expect(document.documentElement.classList.contains("dark")).toBe(saved !== "sang");
  expect(document.documentElement.style.colorScheme).toBe(saved === "sang" ? "light" : "dark");
});

it("script vẫn theo hệ thống khi không truy cập được localStorage", () => {
  vi.spyOn(window, "localStorage", "get").mockImplementation(() => { throw new Error("blocked"); });
  vi.mocked(matchMedia).mockReturnValue({ matches: true } as MediaQueryList);
  expect(() => new Function(scriptGiaoDien)()).not.toThrow();
  expect(document.documentElement.classList.contains("dark")).toBe(true);
});
