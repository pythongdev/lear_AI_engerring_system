import { describe, expect, it } from "vitest";

import { errorCodeValues } from "@/lib/api/schema";

import { khungCua, sauDangNhap, type Session } from "./khung";
import { loiTaiKhoan } from "./messages";

const s = (p: Partial<Session>): Session => ({
  person_id: 1, display_name: "A", role_code: "quay", is_owner: false, must_change_password: false, counter_duty_id: 0, ...p,
});

describe("khung theo vai — vai chọn màn, không mở quyền (ADR-109 điểm 3)", () => {
  it("cờ chủ quán thắng vai", () => expect(khungCua(s({ is_owner: true, role_code: "owner" }))).toBe("/chu-quan"));
  it("vai quầy ⇒ khung quầy", () => expect(khungCua(s({ role_code: "quay" }))).toBe("/quay"));
  it.each(["trang_banh", "gap_banh", "canh_don_ban"] as const)("vai %s ⇒ khung trạm chỉ xem", (role_code) =>
    expect(khungCua(s({ role_code }))).toBe("/tram"));
  it("mật khẩu tạm ⇒ đổi mật khẩu trước", () =>
    expect(sauDangNhap(s({ is_owner: true, must_change_password: true }))).toBe("/doi-mat-khau"));
});

describe("chữ cho lời từ chối của cửa tài khoản", () => {
  const codes = ["invalid_credentials", "login_temporarily_blocked", "username_taken", "email_taken", "password_too_short", "reset_token_invalid"] as const;
  it("mỗi mã có trong hợp đồng và có chữ riêng", () => {
    const chu = codes.map((code) => {
      expect(errorCodeValues).toContain(code);
      return loiTaiKhoan({ kind: "rejected", status: 400, code });
    });
    expect(new Set(chu).size).toBe(codes.length);
    for (const c of chu) expect(c).not.toMatch(/Máy chủ từ chối/);
  });
  it("mất kết nối của lệnh ghi là chưa rõ kết quả", () =>
    expect(loiTaiKhoan({ kind: "no_response" })).toMatch(/chưa rõ/));
});
