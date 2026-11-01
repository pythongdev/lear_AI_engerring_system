import { act, cleanup, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import { DangNhapKhach } from "./dang-nhap";

const replace = vi.fn();
vi.mock("next/navigation", () => ({ useRouter: () => ({ replace }) }));
vi.mock("next/script", () => ({ default: () => null }));
let callback: (response: { credential: string }) => void;
const initialize = vi.fn((options) => { callback = options.callback; });
const renderButton = vi.fn((element: HTMLElement) => { element.textContent = "Tiếp tục với Google"; });
beforeEach(() => {
  vi.clearAllMocks();
  vi.stubEnv("NEXT_PUBLIC_GOOGLE_CLIENT_ID", "client-test");
  window.google = { accounts: { id: { initialize, renderButton } } };
});
afterEach(() => { cleanup(); vi.unstubAllEnvs(); delete window.google; });
function mo(status = 201, dangKy = false) {
  const calls: { path: string; method: string; body: unknown }[] = [];
  render(<ApiProvider fetch={async (request) => {
    calls.push({ path: new URL(request.url).pathname, method: request.method, body: await request.json() });
    return new Response(JSON.stringify(status === 201 ? {
      customer_account_id: 1, display_name: "Lan", email: "lan@gmail.com", phone: null,
      delivery_name: null, delivery_phone: null, delivery_address: null,
    } : { code: "email_taken" }), { status, headers: { "content-type": "application/json" } });
  }}><DangNhapKhach dangKy={dangKy} /></ApiProvider>);
  return calls;
}
describe("T-267 Google cho khách", () => {
  it("không Client ID thì không vẽ nút hoặc dòng ngăn", () => {
    vi.stubEnv("NEXT_PUBLIC_GOOGLE_CLIENT_ID", ""); mo();
    expect(screen.queryByLabelText("Tiếp tục với Google")).toBeNull();
    expect(screen.queryByText("hoặc")).toBeNull(); expect(initialize).not.toHaveBeenCalled();
  });
  it.each([false, true])("callback gửi credential và chuyển tài khoản, đăng ký=%s", async (dangKy) => {
    const calls = mo(201, dangKy);
    expect(initialize).toHaveBeenCalledWith({ client_id: "client-test", callback: expect.any(Function) });
    expect(renderButton).toHaveBeenCalledWith(expect.any(HTMLElement), expect.objectContaining({ text: "continue_with", locale: "vi" }));
    await act(async () => { callback({ credential: "signed-google-token" }); });
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/khach/tai-khoan"));
    expect(calls).toEqual([{ path: "/api/customer-sessions/google", method: "POST", body: { credential: "signed-google-token" } }]);
  });
  it("email_taken hướng dẫn dùng mật khẩu", async () => {
    mo(409);
    await act(async () => { callback({ credential: "token" }); });
    expect(await screen.findByText("Gmail này đã có tài khoản đặt bằng mật khẩu. Hãy đăng nhập bằng mật khẩu.")).toBeTruthy();
    expect(replace).not.toHaveBeenCalled();
  });
});
