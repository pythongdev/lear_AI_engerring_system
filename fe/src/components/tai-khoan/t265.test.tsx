import { cleanup, fireEvent, screen, waitFor } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";
import { FormDangNhap } from "./form-dang-nhap";
import { FormDangKy } from "./form-dang-ky";
import { voiBackend } from "./test-utils";
vi.mock("next/navigation", () => ({ useRouter: () => ({ replace: vi.fn() }) }));
afterEach(cleanup);
it("T-265 người làm gửi identifier nguyên số có dấu cách", async () => {
  const calls = voiBackend(<FormDangNhap />, () => ({ status: 401, body: { code: "login_failed" } }));
  fireEvent.change(screen.getByLabelText("Số điện thoại hoặc Gmail"), { target: { value: " 0912 345 678 " } });
  fireEvent.change(screen.getByLabelText("Mật khẩu"), { target: { value: "abcdefgh" } });
  fireEvent.click(screen.getByRole("button", { name: "Đăng nhập" }));
  await waitFor(() => expect(calls).toHaveLength(1));
  expect(calls[0]).toMatchObject({ path: "/sessions", body: { identifier: " 0912 345 678 ", password: "abcdefgh", tai_quay: false } });
});
it("T-265 người làm đăng ký thiếu số và thư hiện lỗi, không gọi API", async () => {
  const calls = voiBackend(<FormDangKy />, () => ({ status: 201, body: {} }));
  fireEvent.change(screen.getByLabelText("Tên hiển thị"), { target: { value: "Lan" } });
  fireEvent.change(screen.getByLabelText(/Mật khẩu/), { target: { value: "abcdefgh" } });
  fireEvent.click(screen.getByRole("button", { name: "Đăng ký" }));
  expect(await screen.findByText("Nhập số điện thoại hoặc Gmail.")).toBeTruthy(); expect(calls).toHaveLength(0);
});

it.each([
  ["identifier_invalid", "Số điện thoại hoặc Gmail chưa đúng dạng."],
  ["contact_required", "Nhập số điện thoại hoặc Gmail."],
  ["phone_taken", "Số điện thoại này đã có người dùng."],
  ["email_taken", "Gmail này đã gắn với một tài khoản khác."],
  ["login_failed", "Sai số điện thoại, Gmail hoặc mật khẩu."],
] as const)("T-265 mã %s có câu tiếng Việt", async (code, text) => {
  const { loiTaiKhoan } = await import("@/lib/auth/messages");
  expect(loiTaiKhoan({ kind: "rejected", status: 400, code })).toBe(text);
});
