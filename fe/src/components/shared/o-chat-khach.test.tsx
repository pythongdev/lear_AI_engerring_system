import { useQueryClient } from "@tanstack/react-query";
import { act, cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import { KHOA_KHACH, usePhienKhach } from "@/lib/khach/session";
import { OChatKhach } from "./o-chat-khach";

const route = vi.hoisted(() => ({ path: "/dat-mon" }));
vi.mock("next/navigation", () => ({ usePathname: () => route.path }));
beforeEach(() => { route.path = "/dat-mon"; vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", "true"); });
afterEach(() => { cleanup(); vi.unstubAllEnvs(); });
function json(body: unknown, status = 200) { return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } }); }
const answer = { answer: "Câu của khách cũ", sources: [], degraded_reason: null };
function dung(chat: (r: Request) => Promise<Response> = async () => json(answer), next: number | null = 2, theoDoi = true) {
  let account: number | null = 1;
  const fetch = vi.fn(async (r: Request) => {
    if (new URL(r.url).pathname === "/api/customer-sessions/current") return account === null ? json({ code: "unauthenticated" }, 401) : json({ customer_account_id: account });
    return chat(r);
  });
  function DoiNguoi() {
    const qc = useQueryClient();
    const phien = usePhienKhach();
    return <button data-phien={phien.isFetched ? "san-sang" : "cho"} onClick={() => { account = next; void qc.invalidateQueries({ queryKey: KHOA_KHACH }); }}>Đổi người</button>;
  }
  return { ...render(<ApiProvider fetch={fetch}><OChatKhach />{theoDoi && <DoiNguoi />}</ApiProvider>), fetch };
}
async function mo() {
  // Đợi phiên ổn định trước khi gõ; nút không đợi phiên.
  await waitFor(() => expect(screen.getByRole("button", { name: "Đổi người" }).getAttribute("data-phien")).toBe("san-sang"));
  const button = screen.getByRole("button", { name: "Trợ lý bánh cuốn" }); fireEvent.click(button); return button;
}
function hoi() { fireEvent.change(screen.getByRole("textbox"), { target: { value: "Câu hỏi cũ" } }); fireEvent.click(screen.getByRole("button", { name: "Hỏi" })); }

describe("CHAT-07 OChatKhach", () => {
  it.each([undefined, "", "false", "1"])("cờ %s tắt không có nút Trợ lý bánh cuốn", (flag) => {
    vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", flag); const { fetch } = dung(undefined, 2, false);
    expect(screen.queryByRole("button", { name: "Trợ lý bánh cuốn" })).toBeNull(); expect(fetch).not.toHaveBeenCalled();
  });
  it.each(["/quay/goi-mon", "/tram", "/chu-quan/van-hanh"])("đường nội bộ %s không vẽ vỏ khách", (path) => {
    route.path = path; const { fetch } = dung(undefined, 2, false); expect(screen.queryByRole("button", { name: "Trợ lý bánh cuốn" })).toBeNull(); expect(fetch).not.toHaveBeenCalled();
  });
  it("không chờ phiên mới bày nút, mở lần đầu mới dựng", () => {
    render(<ApiProvider fetch={() => new Promise(() => {})}><OChatKhach /></ApiProvider>);
    expect(screen.getByRole("button", { name: "Trợ lý bánh cuốn" })).toBeTruthy(); expect(screen.queryByRole("textbox", { hidden: true })).toBeNull();
  });
  it("mở focus Câu hỏi, Esc trả focus, đóng chỉ ẩn giữ hội thoại; vỏ giới hạn chiều rộng", async () => {
    dung(); const button = await mo(); const input = screen.getByRole("textbox", { name: "Câu hỏi" });
    expect(document.activeElement).toBe(input); expect(screen.getByRole("dialog").getAttribute("aria-modal")).toBe("false");
    expect(screen.getByRole("dialog").className).toContain("max-w-[calc(100vw-2rem)]");
    hoi(); await screen.findByText(answer.answer); fireEvent.keyDown(input, { key: "Escape" });
    expect(screen.queryByRole("dialog")).toBeNull(); expect(document.activeElement).toBe(button);
    fireEvent.click(button); expect(screen.getByText(answer.answer)).toBeTruthy(); expect(document.activeElement).toBe(input);
    fireEvent.click(screen.getByRole("button", { name: "Đóng trợ lý bánh cuốn" })); expect(document.activeElement).toBe(button);
  });
  it("nút nổi tròn có tên truy cập và biểu tượng, thay nút Hỏi quán", () => {
    dung();
    const button = screen.getByRole("button", { name: "Trợ lý bánh cuốn" });
    expect(button.getAttribute("aria-label")).toBe("Trợ lý bánh cuốn");
    expect(button.getAttribute("title")).toBe("Trợ lý bánh cuốn");
    expect(button.classList.contains("rounded-full")).toBe(true);
    expect(button.classList.contains("fixed")).toBe(true);
    expect(button.querySelectorAll("svg")).toHaveLength(1);
    expect(button.querySelector("svg")?.getAttribute("aria-hidden")).toBe("true");
    expect(screen.queryByRole("button", { name: "Hỏi quán" })).toBeNull();
  });
  it("bấm nút lần hai ẩn bảng, trả focus và giữ hội thoại khi mở lại", async () => {
    dung(); const button = await mo();
    const dialog = screen.getByRole("dialog", { name: "Trợ lý bánh cuốn" });
    expect(button.getAttribute("aria-expanded")).toBe("true");
    expect(button.getAttribute("aria-controls")).toBe(dialog.id);
    expect(button.querySelector("svg")?.classList.contains("lucide-x")).toBe(true);
    hoi(); await screen.findByText(answer.answer);
    fireEvent.click(button);
    expect(dialog.hidden).toBe(true);
    expect(button.getAttribute("aria-expanded")).toBe("false");
    expect(document.activeElement).toBe(button);
    expect(button.querySelector("svg")?.classList.contains("lucide-message-circle")).toBe(true);
    fireEvent.click(button);
    expect(dialog.hidden).toBe(false);
    expect(screen.getByText(answer.answer)).toBeTruthy();
    expect(document.activeElement).toBe(screen.getByRole("textbox", { name: "Câu hỏi" }));
  });
  it("bấm lại nút nổi khi chờ câu trả lời huỷ signal", async () => {
    let signal!: AbortSignal;
    dung((r) => { signal = r.signal; return new Promise(() => {}); });
    const button = await mo(); hoi();
    await waitFor(() => expect(signal).toBeTruthy());
    fireEvent.click(button);
    expect(signal.aborted).toBe(true);
    expect(screen.getByRole("dialog", { hidden: true }).hidden).toBe(true);
  });
  it.each([2, null])("đổi customer_account_id sang %s hoặc đăng xuất mất hội thoại", async (next) => {
    dung(undefined, next); await mo(); hoi(); await screen.findByText(answer.answer);
    fireEvent.click(screen.getByRole("button", { name: "Đổi người" })); await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    await mo(); expect(screen.queryByText(answer.answer)).toBeNull(); expect((screen.getByRole("textbox") as HTMLTextAreaElement).value).toBe("");
  });
  it("đóng bảng huỷ signal và phản hồi muộn không hiện", async () => {
    let tra!: (r: Response) => void; let signal!: AbortSignal;
    dung((r) => { signal = r.signal; return new Promise((resolve) => { tra = resolve; }); });
    await mo(); hoi(); await waitFor(() => expect(signal).toBeTruthy());
    fireEvent.click(screen.getByRole("button", { name: "Đóng trợ lý bánh cuốn" })); expect(signal.aborted).toBe(true);
    await act(async () => { tra(json(answer)); }); await mo();
    expect(screen.queryByText(answer.answer)).toBeNull(); expect(screen.queryByRole("alert")).toBeNull();
    expect((screen.getByRole("textbox") as HTMLTextAreaElement).value).toBe("Câu hỏi cũ");
  });
});
