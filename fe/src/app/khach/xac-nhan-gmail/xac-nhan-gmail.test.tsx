import { cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, expect, it, vi } from "vitest";
import { StrictMode } from "react";
import { ApiProvider } from "@/lib/api/provider";
import { XacNhanGmail, LINK_KHONG_HOP_LE } from "@/components/khach/xac-nhan-gmail";
import { TaiKhoanKhach } from "@/components/khach/tai-khoan";

let query = "ma=ma-thu";
vi.mock("next/navigation", () => ({ useSearchParams: () => new URLSearchParams(query), useRouter: () => ({ replace: vi.fn() }) }));
afterEach(cleanup);
beforeEach(() => { query = "ma=ma-thu"; });
const profile = { customer_account_id: 1, display_name: "Lan", phone: null, email: null, pending_email: "lan@gmail.com", delivery_name: null, delivery_phone: null, delivery_address: null };
function response(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}
it.each([
  [200, { ...profile, email: profile.pending_email, pending_email: null }, "Đã xác nhận Gmail."],
  [400, { code: "verification_invalid" }, LINK_KHONG_HOP_LE],
  [409, { code: "email_taken" }, "Gmail này đã thuộc một tài khoản khác."],
])("xác nhận trả %s và chỉ gửi một lần trong StrictMode", async (status, body, message) => {
  const requests: { path: string; method: string; body: unknown }[] = [];
  render(<StrictMode><ApiProvider fetch={async (req) => {
    requests.push({ path: new URL(req.url).pathname, method: req.method, body: await req.json() });
    return response(body, status);
  }}><XacNhanGmail /></ApiProvider></StrictMode>);
  expect(await screen.findByText(message)).toBeTruthy();
  expect(requests).toEqual([{ path: "/api/customer-email-verifications", method: "POST", body: { token: "ma-thu" } }]);
  expect(screen.getByRole("link", { name: "Về tài khoản" }).getAttribute("href")).toBe("/khach/tai-khoan");
});
it("thiếu ma không gọi API", () => {
  query = ""; const fetch = vi.fn();
  render(<ApiProvider fetch={fetch}><XacNhanGmail /></ApiProvider>);
  expect(screen.getByText(LINK_KHONG_HOP_LE)).toBeTruthy(); expect(fetch).not.toHaveBeenCalled();
});
it.each([202, 429])("Gmail chờ và gửi lại đúng cửa: %s", async (status) => {
  const requests: string[] = [];
  render(<ApiProvider fetch={async (req) => {
    requests.push(req.method + " " + new URL(req.url).pathname);
    return req.method === "GET" ? response(profile) : response(status === 202 ? { status: "ok" } : { code: "verification_rate_limited" }, status);
  }}><TaiKhoanKhach /></ApiProvider>);
  await screen.findByText("Gmail lan@gmail.com đang chờ xác nhận");
  expect(screen.getByText("Đã gửi thư xác nhận tới lan@gmail.com. Mở thư và bấm link trong 24 giờ.")).toBeTruthy();
  fireEvent.click(screen.getByRole("button", { name: "Gửi lại thư xác nhận" }));
  await waitFor(() => expect(requests).toContain("POST /api/customer-accounts/current/email-verification"));
  if (status === 429) expect(await screen.findByText("Đã gửi nhiều lần, thử lại sau một giờ.")).toBeTruthy();
});
