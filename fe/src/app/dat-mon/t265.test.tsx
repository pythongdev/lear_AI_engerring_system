import { cleanup, fireEvent, screen } from "@testing-library/react";
import { afterEach, expect, it, vi } from "vitest";
import { voiBackend } from "@/components/tai-khoan/test-utils";
import { useNhapKhach } from "@/lib/nhap-khach";
import { menuMau } from "../ban/mau-khach";
import { DatMonKhach } from "./dat-mon-khach";
vi.mock("next/navigation", () => ({ useRouter: () => ({ replace: vi.fn() }), usePathname: () => "/dat-mon", useSearchParams: () => new URLSearchParams() }));
afterEach(() => { cleanup(); useNhapKhach.getState().xoaHet(); });
it("T-265 có phiên điền sẵn; sửa form không PUT bộ đã nhớ", async () => {
  const calls = voiBackend(<DatMonKhach initialMenu={menuMau} />, (g) => g.path === "/customer-sessions/current" ? { status: 200, body: {
    customer_account_id: 1, display_name: "Tên tài khoản", phone: null, email: "lan@gmail.com", delivery_name: "Lan nhận", delivery_phone: "0912345678", delivery_address: "5 Lò Sũ",
  } } : { status: 200, body: menuMau });
  await screen.findByLabelText("Tên");
  fireEvent.click(screen.getByRole("radio", { name: "Giao tận nơi" }));
  expect((screen.getByLabelText("Tên") as HTMLInputElement).value).toBe("Lan nhận");
  expect((screen.getByLabelText("Số điện thoại") as HTMLInputElement).value).toBe("0912345678");
  expect((screen.getByLabelText("Địa chỉ giao") as HTMLInputElement).value).toBe("5 Lò Sũ");
  fireEvent.change(screen.getByLabelText("Tên"), { target: { value: "Tên cho đơn này" } });
  fireEvent.change(screen.getByLabelText("Địa chỉ giao"), { target: { value: "7 Lò Sũ" } });
  expect(calls.some((g) => g.method === "PUT")).toBe(false);
  expect(screen.getByRole("link", { name: "Tài khoản" }).getAttribute("href")).toBe("/khach/tai-khoan");
});
it("T-265 không phiên vẫn đặt món với form trống", async () => {
  voiBackend(<DatMonKhach initialMenu={menuMau} />, (g) => g.path === "/customer-sessions/current" ? { status: 401, body: { code: "unauthenticated" } } : { status: 200, body: menuMau });
  await screen.findByLabelText("Tên"); fireEvent.click(screen.getByRole("radio", { name: "Giao tận nơi" }));
  for (const label of ["Tên", "Số điện thoại", "Địa chỉ giao"]) expect((screen.getByLabelText(label) as HTMLInputElement).value).toBe("");
  expect(screen.getByRole("button", { name: "Thêm Canh" })).toBeTruthy();
  expect(screen.getByRole("link", { name: "Đăng nhập" }).getAttribute("href")).toBe("/khach/dang-nhap");
});
