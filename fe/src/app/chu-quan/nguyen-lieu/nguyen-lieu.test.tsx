import { beforeEach, describe, expect, it, vi } from "vitest";
import Page from "./page";

const redirect = vi.hoisted(() => vi.fn());
vi.mock("next/navigation", () => ({ redirect }));
beforeEach(() => redirect.mockClear());

const mo = (searchParams: { thu?: string | string[]; khac?: string }) => Page({ searchParams: Promise.resolve(searchParams) });

describe("route Nguyên liệu cũ", () => {
  it.each(["1", "9", "9007199254740991"])("giữ thu=%s hợp lệ và bỏ tham số khác", async (thu) => {
    await mo({ thu, khac: "khong-giu" });
    expect(redirect).toHaveBeenCalledExactlyOnceWith(`/chu-quan/khoan-chi?thu=${thu}`);
  });

  it.each([undefined, "", "0", "01", "-1", "1.5", "abc", "9007199254740992", "999999999999999999999999", ["1", "2"]])("bỏ thu=%s không hợp lệ và mọi tham số khác", async (thu) => {
    await mo({ thu, khac: "khong-giu" });
    expect(redirect).toHaveBeenCalledExactlyOnceWith("/chu-quan/khoan-chi");
  });
});
