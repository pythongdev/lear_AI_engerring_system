import { cleanup, fireEvent, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { FormDangNhap } from "./form-dang-nhap";
import { CAU_DA_GUI, FormQuenMatKhau } from "./form-quen-mat-khau";
import { KhungTheoVai } from "./khung-theo-vai";
import { voiBackend } from "./test-utils";

const replace = vi.fn();
vi.mock("next/navigation", () => ({ useRouter: () => ({ replace }) }));
vi.mock("next/link", () => ({ default: ({ href, children }: { href: string; children: React.ReactNode }) => <a href={href}>{children}</a> }));

beforeEach(() => replace.mockReset());
afterEach(cleanup);

const phien = (p: object = {}) => ({
  person_id: 7, display_name: "Lan", role_code: "quay", is_owner: false, must_change_password: false, counter_duty_id: 0, ...p,
});

function dien(user: string, pass: string, taiQuay: boolean) {
  fireEvent.change(screen.getByLabelText("Tên đăng nhập"), { target: { value: user } });
  fireEvent.change(screen.getByLabelText("Mật khẩu"), { target: { value: pass } });
  if (taiQuay) fireEvent.click(screen.getByLabelText(/Đăng nhập tại quầy/));
  fireEvent.click(screen.getByRole("button", { name: "Đăng nhập" }));
}

describe("màn đăng nhập", () => {
  it("tại quầy: gửi at_counter=true rồi vào khung quầy", async () => {
    const goi = voiBackend(<FormDangNhap />, () => ({ status: 201, body: phien({ counter_duty_id: 3 }) }));
    dien("lan", "mat-khau-1", true);
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/quay"));
    expect(goi[0]).toEqual({ method: "POST", path: "/sessions", body: { username: "lan", password: "mat-khau-1", at_counter: true } });
  });

  it("ngoài quầy: at_counter=false; chủ quán vào khung chủ quán", async () => {
    const goi = voiBackend(<FormDangNhap />, () => ({ status: 201, body: phien({ is_owner: true, role_code: "owner" }) }));
    dien("chu", "mat-khau-1", false);
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/chu-quan"));
    expect((goi[0].body as { at_counter: boolean }).at_counter).toBe(false);
  });

  it("mật khẩu tạm ⇒ màn đổi mật khẩu", async () => {
    voiBackend(<FormDangNhap />, () => ({ status: 201, body: phien({ must_change_password: true }) }));
    dien("lan", "tam-thoi-1", false);
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/doi-mat-khau"));
  });

  it.each([
    ["invalid_credentials", 401, /Sai tên đăng nhập hoặc mật khẩu/],
    ["login_temporarily_blocked", 429, /15 phút/],
  ])("từ chối %s ⇒ chữ riêng, không đi đâu", async (code, status, chu) => {
    voiBackend(<FormDangNhap />, () => ({ status, body: { code } }));
    dien("lan", "sai", false);
    expect((await screen.findByRole("alert")).textContent).toMatch(chu);
    expect(replace).not.toHaveBeenCalled();
  });
});

describe("màn quên mật khẩu", () => {
  it("luôn nói cùng một câu — không lộ Gmail có tài khoản hay không", async () => {
    voiBackend(<FormQuenMatKhau />, () => ({ status: 202, body: {} }));
    fireEvent.change(screen.getByLabelText("Gmail của tài khoản"), { target: { value: "Ai@Gmail.com" } });
    fireEvent.click(screen.getByRole("button", { name: "Gửi mã đặt lại" }));
    expect((await screen.findByRole("status")).textContent).toContain(CAU_DA_GUI);
  });

  it("mã đặt lại hỏng ⇒ chữ của reset_token_invalid", async () => {
    voiBackend(<FormQuenMatKhau />, () => ({ status: 400, body: { code: "reset_token_invalid" } }));
    fireEvent.change(screen.getByLabelText("Mã đặt lại"), { target: { value: "x" } });
    fireEvent.change(screen.getByLabelText(/Mật khẩu mới/), { target: { value: "mat-khau-moi" } });
    fireEvent.click(screen.getByRole("button", { name: "Đặt mật khẩu mới" }));
    expect((await screen.findByRole("alert")).textContent).toMatch(/30 phút/);
  });
});

describe("khung theo vai — tiện, không phải bảo vệ", () => {
  it("chưa đăng nhập (401) ⇒ về màn đăng nhập", async () => {
    voiBackend(<KhungTheoVai khung="/quay">nội dung</KhungTheoVai>, () => ({ status: 401, body: { code: "unauthenticated" } }));
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/dang-nhap"));
    expect(screen.queryByText("nội dung")).toBeNull();
  });

  it("chủ quán mở khung quầy ⇒ về khung chủ quán", async () => {
    voiBackend(<KhungTheoVai khung="/quay">nội dung</KhungTheoVai>, () => ({ status: 200, body: phien({ is_owner: true, role_code: "owner" }) }));
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/chu-quan"));
  });

  it("đúng khung: bày nội dung, đăng xuất gọi cửa kết thúc phiên rồi về đăng nhập", async () => {
    const goi = voiBackend(<KhungTheoVai khung="/quay">nội dung</KhungTheoVai>, (g) =>
      g.path === "/sessions/current/end" ? { status: 200, body: {} } : { status: 200, body: phien({ counter_duty_id: 4 }) });
    expect(await screen.findByText("nội dung")).toBeTruthy();
    expect(screen.getByText(/đang đứng quầy/)).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Đăng xuất" }));
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/dang-nhap"));
    expect(goi.some((g) => g.method === "POST" && g.path === "/sessions/current/end")).toBe(true);
  });
});
