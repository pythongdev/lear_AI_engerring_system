import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import type { components } from "@/lib/api/schema";
import { TaiKhoanKhach } from "./tai-khoan";

const replace = vi.fn();
vi.mock("next/navigation", () => ({ useRouter: () => ({ replace }), usePathname: () => "/khach/tai-khoan" }));
afterEach(cleanup);
beforeEach(() => replace.mockReset());

type Profile = components["schemas"]["CustomerProfile"];
type Goi = { method: string; path: string; body: unknown };
type Reply = { status: number; body: unknown };
const profile: Profile = {
  customer_account_id: 1, display_name: "Nguyễn Thị Ngọc Lan", phone: "0912345678", email: "lan@gmail.com", pending_email: null,
  delivery_name: "Lan nhận", delivery_phone: "0987654321", delivery_address: "5 Lò Sũ",
};
const ok = { status: 200, body: { status: "ok" } };
const unauthorized = { status: 401, body: { code: "unauthenticated" } };
function mo(p: Profile = profile, reply?: (g: Goi) => Reply | Promise<Reply>) {
  const calls: Goi[] = [];
  render(<ApiProvider fetch={async (req) => {
    const raw = await req.text();
    const g = { method: req.method, path: new URL(req.url).pathname.replace(/^\/api/, ""), body: raw ? JSON.parse(raw) : undefined };
    calls.push(g);
    const r = reply ? await reply(g) : g.method === "GET" ? { status: 200, body: p } : ok;
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  }}><TaiKhoanKhach /></ApiProvider>);
  return calls;
}
function dien(label: string | RegExp, value: string) { fireEvent.change(screen.getByLabelText(label), { target: { value } }); }
async function suaGiao() { fireEvent.click(await screen.findByRole("button", { name: "Cập nhật thông tin" })); }
async function moMatKhau() { fireEvent.click(await screen.findByRole("button", { name: "Đổi mật khẩu" })); }

describe("T-375 hồ sơ khách", () => {
  it.each([
    ["  Nguyễn   Thị ngọc lan  ", "NL"], ["đặng ánh", "ĐÁ"], ["Lan", "L"], ["   ", "KH"], ["", "KH"], ["Khách thử (dev)", "KT"], ["(dev) 123", "KH"],
  ])("chữ cái đầu từ hai chữ cuối của tên %j là %s; không có đổi ảnh", async (display_name, initials) => {
    mo({ ...profile, display_name });
    const header = await screen.findByRole("region", { name: "Thông tin hồ sơ" });
    expect(within(header).getByText(initials).getAttribute("aria-hidden")).toBe("true");
    expect(within(header).getByRole("heading").textContent).toBe(display_name.trim() || "Khách hàng");
    expect(within(header).getByText(profile.phone!)).toBeTruthy();
    expect(screen.queryByRole("button", { name: /ảnh/i })).toBeNull();
    expect(document.querySelector('input[type="file"]')).toBeNull();
  });

  it("hiện Gmail dưới tên khi thiếu số; thông tin tài khoản chỉ đọc", async () => {
    mo({ ...profile, phone: null });
    const header = await screen.findByRole("region", { name: "Thông tin hồ sơ" });
    expect(within(header).getByText("lan@gmail.com")).toBeTruthy();
    const info = screen.getByRole("region", { name: "Thông tin cá nhân" });
    expect(within(info).getByText(`Tên: ${profile.display_name}`)).toBeTruthy();
    expect(within(info).getByText("Số điện thoại: Chưa có")).toBeTruthy();
    expect(within(info).getByText("Gmail: lan@gmail.com")).toBeTruthy();
    expect(info.querySelector("input")).toBeNull();
    await suaGiao();
    expect(info.querySelector("input")).toBeNull();
    expect(screen.getByRole("region", { name: "Thông tin giao đã nhớ" }).querySelectorAll("input")).toHaveLength(3);
  });

  it("thông tin cá nhân vắng hiện Chưa có ở cả ba dòng", async () => {
    mo({ ...profile, display_name: "", phone: null, email: null });
    const info = await screen.findByRole("region", { name: "Thông tin cá nhân" });
    for (const label of ["Tên", "Số điện thoại", "Gmail"]) expect(within(info).getByText(`${label}: Chưa có`)).toBeTruthy();
  });

  it("Gmail chờ xác nhận giữ câu báo và POST gửi lại thư", async () => {
    const calls = mo({ ...profile, pending_email: "moi@gmail.com" });
    const info = await screen.findByRole("region", { name: "Xác nhận Gmail" });
    expect(within(info).getByText("Gmail moi@gmail.com đang chờ xác nhận")).toBeTruthy();
    fireEvent.click(within(info).getByRole("button", { name: "Gửi lại thư xác nhận" }));
    await waitFor(() => expect(screen.getByRole("status").textContent).toContain("Đã gửi thư xác nhận tới moi@gmail.com. Mở thư và bấm link trong 24 giờ."));
    expect(calls[1]).toMatchObject({ method: "POST", path: "/customer-accounts/current/email-verification" });
  });

  it("gửi lại thư bị giới hạn vẫn hiện câu thử lại sau một giờ", async () => {
    mo({ ...profile, pending_email: "moi@gmail.com" }, (g) => g.method === "GET"
      ? { status: 200, body: { ...profile, pending_email: "moi@gmail.com" } }
      : { status: 429, body: { code: "verification_rate_limited" } });
    fireEvent.click(await screen.findByRole("button", { name: "Gửi lại thư xác nhận" }));
    expect(await screen.findByText("Đã gửi nhiều lần, thử lại sau một giờ.")).toBeTruthy();
  });

  it("ba dòng giao chỉ đọc; mở form điền sẵn; Huỷ bỏ nháp không gọi API", async () => {
    const calls = mo();
    const info = await screen.findByRole("region", { name: "Thông tin giao đã nhớ" });
    expect(within(info).getByText("Tên người nhận: Lan nhận")).toBeTruthy();
    expect(within(info).getByText("Số điện thoại người nhận: 0987654321")).toBeTruthy();
    expect(within(info).getByText("Địa chỉ giao: 5 Lò Sũ")).toBeTruthy();
    expect(info.querySelector("input")).toBeNull();
    expect(screen.queryByText(/Để trống cả ba ô/)).toBeNull();
    await suaGiao();
    for (const [label, value] of [["Tên người nhận", "Lan nhận"], ["Số điện thoại người nhận", "0987654321"], ["Địa chỉ giao", "5 Lò Sũ"]]) {
      expect((screen.getByLabelText(label) as HTMLInputElement).value).toBe(value);
    }
    expect(within(info).getByText(/Để trống cả ba ô rồi lưu để xoá/)).toBeTruthy();
    dien("Tên người nhận", "Nháp không lưu");
    fireEvent.click(screen.getByRole("button", { name: "Huỷ" }));
    expect(info.querySelector("input")).toBeNull();
    expect(calls).toHaveLength(1);
    await suaGiao();
    expect((screen.getByLabelText("Tên người nhận") as HTMLInputElement).value).toBe("Lan nhận");
    expect(calls).toHaveLength(1);
  });

  it("ba ô trống hiện Chưa có thông tin giao; thiếu một dòng hiện Chưa có", async () => {
    mo({ ...profile, delivery_name: null, delivery_phone: "", delivery_address: null });
    expect(await screen.findByText("Chưa có thông tin giao")).toBeTruthy();
    await suaGiao();
    for (const label of ["Tên người nhận", "Số điện thoại người nhận", "Địa chỉ giao"]) expect((screen.getByLabelText(label) as HTMLInputElement).value).toBe("");
    cleanup();
    mo({ ...profile, delivery_name: null });
    expect(await screen.findByText("Tên người nhận: Chưa có")).toBeTruthy();
    expect(screen.queryByText("Chưa có thông tin giao")).toBeNull();
  });

  it("Lưu gửi đúng PUT rồi đọc phiên, đóng form; mở lại lấy dữ liệu mới và xoá bằng ba chuỗi rỗng", async () => {
    let current = { ...profile };
    const calls = mo(profile, (g) => {
      if (g.method === "GET") return { status: 200, body: current };
      current = { ...current, ...(g.body as object) }; return ok;
    });
    await suaGiao();
    dien("Tên người nhận", "Ngọc"); dien("Số điện thoại người nhận", "0901234567"); dien("Địa chỉ giao", "10 Phố Huế");
    fireEvent.click(screen.getByRole("button", { name: "Lưu thông tin giao" }));
    expect(await screen.findByText("Đã lưu thông tin giao.")).toBeTruthy();
    expect(screen.queryByLabelText("Tên người nhận")).toBeNull();
    expect(screen.getByText("Tên người nhận: Ngọc")).toBeTruthy();
    expect(calls.map((g) => `${g.method} ${g.path}`)).toEqual([
      "GET /customer-sessions/current", "PUT /customer-accounts/current/delivery-profile", "GET /customer-sessions/current",
    ]);
    expect(calls[1].body).toEqual({ delivery_name: "Ngọc", delivery_phone: "0901234567", delivery_address: "10 Phố Huế" });
    await suaGiao();
    expect((screen.getByLabelText("Tên người nhận") as HTMLInputElement).value).toBe("Ngọc");
    for (const label of ["Tên người nhận", "Số điện thoại người nhận", "Địa chỉ giao"]) dien(label, "");
    fireEvent.click(screen.getByRole("button", { name: "Lưu thông tin giao" }));
    expect(await screen.findByText("Chưa có thông tin giao")).toBeTruthy();
    expect(calls[3].body).toEqual({ delivery_name: "", delivery_phone: "", delivery_address: "" });
    expect(screen.queryByLabelText("Tên người nhận")).toBeNull();
  });

  it("đang lưu chỉ gửi một PUT và khoá Huỷ; lỗi giữ form và dữ liệu nháp", async () => {
    let finish!: (r: Reply) => void;
    const calls = mo(profile, (g) => g.method === "GET" ? { status: 200, body: profile } : new Promise((resolve) => { finish = resolve; }));
    await suaGiao();
    dien("Tên người nhận", "Nháp");
    const form = screen.getByRole("button", { name: "Lưu thông tin giao" }).closest("form")!;
    fireEvent.submit(form); fireEvent.submit(form);
    await waitFor(() => expect((screen.getByRole("button", { name: "Huỷ" }) as HTMLButtonElement).disabled).toBe(true));
    expect(calls.filter((g) => g.method === "PUT")).toHaveLength(1);
    finish({ status: 400, body: { code: "invalid_request", field: "delivery_phone" } });
    expect(await screen.findAllByRole("alert")).toHaveLength(2);
    expect((screen.getByLabelText("Tên người nhận") as HTMLInputElement).value).toBe("Nháp");
    expect(screen.getByLabelText("Số điện thoại người nhận").getAttribute("aria-invalid")).toBe("true");
    expect((screen.getByRole("button", { name: "Huỷ" }) as HTMLButtonElement).disabled).toBe(false);
  });

  it("PUT thành công nhưng đọc lại lỗi vẫn đóng form và giữ câu báo đọc lại", async () => {
    let reads = 0;
    mo(profile, (g) => g.method !== "GET" ? ok : ++reads === 1 ? { status: 200, body: profile } : { status: 503, body: { code: "service_unavailable" } });
    await suaGiao();
    fireEvent.click(screen.getByRole("button", { name: "Lưu thông tin giao" }));
    expect(await screen.findByText("Đã lưu nhưng chưa đọc lại được thông tin. Bấm Đọc lại để cập nhật.")).toBeTruthy();
    expect(screen.queryByLabelText("Tên người nhận")).toBeNull();
    expect(screen.getByRole("button", { name: "Đọc lại" })).toBeTruthy();
  });

  it("Của tôi có đúng hai liên kết và hai dòng phụ", async () => {
    mo();
    const mine = await screen.findByRole("region", { name: "Của tôi" });
    expect(within(mine).getAllByRole("link").map((link) => link.getAttribute("href"))).toEqual(["/khach/yeu-thich", "/khach/don"]);
    expect(within(mine).getByRole("link", { name: "Yêu thích Những món bạn đã lưu" })).toBeTruthy();
    expect(within(mine).getByRole("link", { name: "Đơn đã đặt Xem lại các đơn đã đặt" })).toBeTruthy();
  });

  it("mật khẩu mặc định gập, mở và gập được; PUT giữ phiên; đăng xuất POST rồi chuyển đăng nhập", async () => {
    const calls = mo();
    const toggle = await screen.findByRole("button", { name: "Đổi mật khẩu" });
    expect(toggle.getAttribute("aria-expanded")).toBe("false");
    expect(document.getElementById(toggle.getAttribute("aria-controls")!)?.hidden).toBe(true);
    await moMatKhau();
    const hide = screen.getByRole("button", { name: "Ẩn đổi mật khẩu" });
    expect(hide.getAttribute("aria-expanded")).toBe("true");
    fireEvent.click(hide);
    expect(toggle.getAttribute("aria-expanded")).toBe("false");
    await moMatKhau();
    dien("Mật khẩu hiện tại", "abcdefgh"); dien(/Mật khẩu mới/, "12345678");
    fireEvent.click(screen.getByRole("button", { name: "Đổi mật khẩu" }));
    expect(await screen.findByText("Đã đổi mật khẩu. Các phiên khác đã kết thúc; phiên này vẫn được giữ.")).toBeTruthy();
    expect(calls.find((g) => g.method === "PUT")).toEqual({ method: "PUT", path: "/customer-accounts/current/password", body: { current_password: "abcdefgh", new_password: "12345678" } });
    expect(replace).not.toHaveBeenCalled();
    fireEvent.click(screen.getByRole("button", { name: "Đăng xuất" }));
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/khach/dang-nhap"));
    expect(calls.find((g) => g.path === "/customer-sessions/current/end")).toMatchObject({ method: "POST", path: "/customer-sessions/current/end" });
  });

  it.each(["đọc phiên", "lưu giao", "đổi mật khẩu", "gửi lại thư", "đăng xuất"])("401 khi %s chuyển /khach/dang-nhap", async (action) => {
    const p = { ...profile, pending_email: "moi@gmail.com" };
    mo(p, (g) => action !== "đọc phiên" && g.method === "GET" ? { status: 200, body: p } : unauthorized);
    if (action === "lưu giao") { await suaGiao(); fireEvent.click(screen.getByRole("button", { name: "Lưu thông tin giao" })); }
    if (action === "đổi mật khẩu") {
      await moMatKhau(); dien("Mật khẩu hiện tại", "abcdefgh"); dien(/Mật khẩu mới/, "12345678");
      fireEvent.click(screen.getByRole("button", { name: "Đổi mật khẩu" }));
    }
    if (action === "gửi lại thư") fireEvent.click(await screen.findByRole("button", { name: "Gửi lại thư xác nhận" }));
    if (action === "đăng xuất") fireEvent.click(await screen.findByRole("button", { name: "Đăng xuất" }));
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/khach/dang-nhap"));
    if (action === "đọc phiên") expect(screen.queryByRole("region", { name: "Thông tin cá nhân" })).toBeNull();
  });
});
