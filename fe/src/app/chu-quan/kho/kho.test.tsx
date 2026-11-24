import { beforeEach, describe, expect, it, vi } from "vitest";
import Page from "./page";

const redirect = vi.hoisted(() => vi.fn());
vi.mock("next/navigation", () => ({ redirect }));
beforeEach(() => redirect.mockClear());

describe("route Kho cũ", () => {
  it("chuyển phía server tới Khoản chi, không render trang Kho", () => {
    Page();
    expect(redirect).toHaveBeenCalledExactlyOnceWith("/chu-quan/khoan-chi");
  });
});
