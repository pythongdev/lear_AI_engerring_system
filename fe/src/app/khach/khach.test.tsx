import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { useNhapKhach } from "@/lib/nhap-khach";
import { ApiProvider } from "@/lib/api/provider";
import { DangNhapKhach } from "@/components/khach/dang-nhap";
import { TaiKhoanKhach } from "@/components/khach/tai-khoan";
import { DonKhach } from "@/components/khach/don";
import { CAU_GUI_KHACH, QuenMatKhauKhach, DatLaiMatKhauKhach } from "@/components/khach/quen-mat-khau";
import type { ReactElement } from "react";

const replace = vi.fn();
vi.mock("next/navigation", () => ({ useRouter: () => ({ replace }), useSearchParams: () => new URLSearchParams("token=ma-trong-thu") }));
afterEach(() => { cleanup(); useNhapKhach.getState().xoaHet(); }); beforeEach(() => replace.mockReset());
const profile = { customer_account_id: 1, display_name: "Lan", phone: null, email: "lan@gmail.com", delivery_name: "Lan nhận", delivery_phone: "0912345678", delivery_address: "5 Lò Sũ" };
type Goi = { method: string; path: string; query: URLSearchParams; body: unknown };
function mo(ui: ReactElement, reply: (g: Goi) => { status: number; body: unknown }) {
  const calls: Goi[] = [];
  render(<ApiProvider fetch={async (req) => {
    const url = new URL(req.url); const raw = await req.text();
    const g = { method: req.method, path: url.pathname.replace(/^\/api/, ""), query: url.searchParams, body: raw ? JSON.parse(raw) : undefined };
    calls.push(g); const r = reply(g);
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  }}>{ui}</ApiProvider>);
  return calls;
}
function dien(label: string | RegExp, value: string) { fireEvent.change(screen.getByLabelText(label), { target: { value } }); }
const ok = { status: 200, body: { status: "ok" } };
const unauthorized = { status: 401, body: { code: "unauthenticated" } };

describe("T-265 tài khoản khách", () => {
  it("đăng ký mở phiên rồi chuyển /khach/tai-khoan", async () => {
    useNhapKhach.setState({ gio: { "qr:ban-1": [{ menu_item_id: 2, quantity: 1, option_ids: [] }] } });
    const nhapQR = useNhapKhach.getState().gio["qr:ban-1"];
    const calls = mo(<DangNhapKhach dangKy />, () => ({ status: 201, body: profile }));
    dien("Tên", "Lan"); dien("Số điện thoại", "0912 345 678"); dien(/Mật khẩu/, "abcdefgh");
    fireEvent.click(screen.getByRole("button", { name: "Đăng ký" }));
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/khach/tai-khoan"));
    expect(useNhapKhach.getState().gio["qr:ban-1"]).toEqual(nhapQR);
    expect(calls).toHaveLength(1);
    expect(calls[0]).toMatchObject({ method: "POST", path: "/customer-accounts", body: { display_name: "Lan", phone: "0912 345 678", email: "", password: "abcdefgh" } });
  });
  it("đăng ký thiếu cả số và thư không gọi API", async () => {
    const calls = mo(<DangNhapKhach dangKy />, () => ok);
    dien("Tên", "Lan"); dien(/Mật khẩu/, "abcdefgh"); fireEvent.click(screen.getByRole("button", { name: "Đăng ký" }));
    expect(await screen.findByText("Nhập số điện thoại hoặc Gmail.")).toBeTruthy(); expect(calls).toHaveLength(0);
  });
  it("đăng nhập gửi nguyên định danh qua cửa khách", async () => {
    const calls = mo(<DangNhapKhach />, () => ({ status: 201, body: profile }));
    dien("Số điện thoại hoặc Gmail", " 0912 345 678 "); dien("Mật khẩu", "abcdefgh");
    fireEvent.click(screen.getByRole("button", { name: "Đăng nhập" }));
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/khach/tai-khoan"));
    expect(calls[0]).toMatchObject({ path: "/customer-sessions", body: { identifier: " 0912 345 678 ", password: "abcdefgh" } });
  });
  it("tài khoản khi 401 chuyển /khach/dang-nhap, không lộ hồ sơ", async () => {
    mo(<TaiKhoanKhach />, () => unauthorized);
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/khach/dang-nhap"));
    expect(screen.queryByLabelText("Tên người nhận")).toBeNull();
  });
  it("sửa và xoá bộ giao gửi PUT; đọc lại sau ghi", async () => {
    let current = { ...profile }; let reads = 0;
    const calls = mo(<TaiKhoanKhach />, (g) => {
      if (g.method === "GET") { reads++; return { status: 200, body: current }; }
      current = { ...current, ...(g.body as object) }; return ok;
    });
    await screen.findByLabelText("Tên người nhận");
    expect(screen.getByText("Số điện thoại: Chưa có")).toBeTruthy();
    dien("Tên người nhận", "Ngọc"); fireEvent.click(screen.getByRole("button", { name: "Lưu thông tin giao" }));
    await screen.findByText("Đã lưu thông tin giao."); expect(reads).toBe(2);
    expect(calls[1]).toMatchObject({ method: "PUT", path: "/customer-accounts/current/delivery-profile", body: { delivery_name: "Ngọc", delivery_phone: "0912345678", delivery_address: "5 Lò Sũ" } });
    for (const label of ["Tên người nhận", "Số điện thoại người nhận", "Địa chỉ giao"]) dien(label, "");
    fireEvent.click(screen.getByRole("button", { name: "Lưu thông tin giao" }));
    await waitFor(() => expect(reads).toBe(3));
    expect(calls.filter((g) => g.method === "PUT")[1].body).toEqual({ delivery_name: "", delivery_phone: "", delivery_address: "" });
  });
  it("đổi mật khẩu giữ phiên, đăng xuất kết thúc phiên khách", async () => {
    const calls = mo(<TaiKhoanKhach />, (g) => g.method === "GET" ? { status: 200, body: profile } : ok);
    await screen.findByLabelText("Mật khẩu hiện tại"); dien("Mật khẩu hiện tại", "abcdefgh"); dien(/Mật khẩu mới/, "12345678");
    fireEvent.click(screen.getByRole("button", { name: "Đổi mật khẩu" }));
    await screen.findByText(/Các phiên khác đã kết thúc/);
    expect(replace).not.toHaveBeenCalled();
    expect(calls.find((g) => g.method === "PUT")).toMatchObject({ path: "/customer-accounts/current/password", body: { current_password: "abcdefgh", new_password: "12345678" } });
    fireEvent.click(screen.getByRole("button", { name: "Đăng xuất" }));
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/khach/dang-nhap"));
    expect(calls.some((g) => g.path === "/customer-sessions/current/end" && g.method === "POST")).toBe(true);
  });
  it("PUT hồ sơ hết phiên cũng chuyển đăng nhập", async () => {
    mo(<TaiKhoanKhach />, (g) => g.method === "GET" ? { status: 200, body: profile } : unauthorized);
    await screen.findByLabelText("Tên người nhận"); fireEvent.click(screen.getByRole("button", { name: "Lưu thông tin giao" }));
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/khach/dang-nhap"));
  });
  it("lịch sử hiện trang đầu, Xem thêm gửi next_before_id, null ẩn nút", async () => {
    const order = (id: number) => ({ sales_order_id: id, created_at: "2026-10-28T01:00:00Z", channel_code: "delivery", status: "pending_confirmation", total_vnd: 12345,
      lines: [{ item_name: "Canh", quantity: 2, unit_price_vnd: 6000, line_total_vnd: 12345, options: [], components: [] }] });
    const calls = mo(<DonKhach />, (g) => ({ status: 200, body: { orders: [order(g.query.has("before_id") ? 8 : 9)], next_before_id: g.query.has("before_id") ? null : 9 } }));
    expect(await screen.findByRole("region", { name: "Đơn 9" })).toBeTruthy();
    expect(screen.getByText("Tổng 12.345đ")).toBeTruthy(); expect(screen.getByText(/Canh ·.*Số lượng 2/)).toBeTruthy();
    fireEvent.click(screen.getByRole("button", { name: "Xem thêm" }));
    await screen.findByRole("region", { name: "Đơn 8" });
    expect(calls[1].query.get("before_id")).toBe("9"); expect(screen.queryByRole("button", { name: "Xem thêm" })).toBeNull();
    expect(screen.getAllByRole("region").map((n) => n.getAttribute("aria-label"))).toEqual(["Đơn 9", "Đơn 8"]);
  });
  it("lịch sử khi 401 chuyển đăng nhập", async () => {
    mo(<DonKhach />, () => unauthorized); await waitFor(() => expect(replace).toHaveBeenCalledWith("/khach/dang-nhap"));
  });
  it("quên mật khẩu báo rõ tài khoản chỉ có số; luôn cùng câu sau gửi", async () => {
    const calls = mo(<QuenMatKhauKhach />, () => ({ status: 202, body: { status: "ok" } }));
    expect(screen.getByText("Tài khoản chỉ có số điện thoại hiện chưa có cách lấy lại mật khẩu.")).toBeTruthy();
    for (const email of ["co@gmail.com", "khong@gmail.com"]) {
      dien("Gmail của tài khoản", email); fireEvent.click(screen.getByRole("button", { name: "Gửi mã đặt lại" }));
      expect(await screen.findByText(CAU_GUI_KHACH)).toBeTruthy();
      await waitFor(() => expect((screen.getByRole("button", { name: "Gửi mã đặt lại" }) as HTMLButtonElement).disabled).toBe(false));
    }
    expect(calls.every((g) => g.path === "/customer-password-reset-requests")).toBe(true);
  });
  it("đặt lại lấy token từ đường dẫn và gửi mật khẩu mới", async () => {
    const calls = mo(<DatLaiMatKhauKhach />, () => ok);
    expect((screen.getByLabelText("Mã đặt lại") as HTMLInputElement).value).toBe("ma-trong-thu");
    dien(/Mật khẩu mới/, "abcdefgh"); fireEvent.click(screen.getByRole("button", { name: "Đặt mật khẩu mới" }));
    await screen.findByText(/Mọi phiên cũ đã kết thúc/);
    expect(calls[0]).toMatchObject({ path: "/customer-password-resets", method: "POST", body: { token: "ma-trong-thu", new_password: "abcdefgh" } });
  });
});

it("T-265 lỗi có field gắn đúng ô; đăng nhập sai không chuyển trang", async () => {
  mo(<DangNhapKhach />, () => ({ status: 401, body: { code: "login_failed", field: "identifier" } }));
  dien("Số điện thoại hoặc Gmail", "0912345678"); dien("Mật khẩu", "abcdefgh");
  fireEvent.click(screen.getByRole("button", { name: "Đăng nhập" }));
  await waitFor(() => expect(screen.getByLabelText("Số điện thoại hoặc Gmail").getAttribute("aria-invalid")).toBe("true"));
  expect(replace).not.toHaveBeenCalled();
});
it("T-265 gửi hai lần chỉ một lệnh đang bay; mất phản hồi không gửi lại ngầm", async () => {
  let reject!: (reason: Error) => void;
  const fetch = vi.fn(() => new Promise<Response>((_resolve, no) => { reject = no; }));
  render(<ApiProvider fetch={fetch}><DangNhapKhach /></ApiProvider>);
  dien("Số điện thoại hoặc Gmail", "0912345678"); dien("Mật khẩu", "abcdefgh");
  const form = screen.getByRole("button", { name: "Đăng nhập" }).closest("form")!;
  fireEvent.submit(form); fireEvent.submit(form);
  await waitFor(() => expect(fetch).toHaveBeenCalledTimes(1));
  reject(new Error("offline"));
  expect((await screen.findByRole("alert")).textContent).toContain("chưa rõ yêu cầu đã tới chưa");
  expect(fetch).toHaveBeenCalledTimes(1);
});
