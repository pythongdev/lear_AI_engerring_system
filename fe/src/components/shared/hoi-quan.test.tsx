import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";
import { ApiProvider } from "@/lib/api/provider";
import { HoiQuan } from "./hoi-quan";

afterEach(cleanup);
const thanhCong = { answer: "Câu trả lời thật", degraded_reason: null, sources: [{ tool: "doc_menu", read_at: "2026-11-05T03:00:00Z" }] };
function json(body: unknown, status = 200) { return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } }); }
function dung(respond: (r: Request) => Promise<Response> = async () => json(thanhCong)) {
  const fetch = vi.fn(respond);
  const view = render(<ApiProvider fetch={fetch}><HoiQuan mo /></ApiProvider>);
  return { ...view, fetch, mo: (mo: boolean) => view.rerender(<ApiProvider fetch={fetch}><HoiQuan mo={mo} /></ApiProvider>) };
}
function nhap(text: string) { fireEvent.change(screen.getByRole("textbox", { name: "Câu hỏi" }), { target: { value: text } }); }
function hoi(text = "Có món gì?") { nhap(text); fireEvent.click(screen.getByRole("button", { name: "Hỏi" })); }
async function xong() { await waitFor(() => expect(screen.queryByText("Đang hỏi…")).toBeNull()); }

describe("CHAT-07 HoiQuan", () => {
  it("thành công bày câu, nguồn và giờ Việt Nam; Enter gửi, Shift+Enter không gửi", async () => {
    const { fetch } = dung();
    expect((screen.getByRole("button", { name: "Hỏi" }) as HTMLButtonElement).disabled).toBe(true);
    nhap("  Có món gì?  ");
    fireEvent.keyDown(screen.getByRole("textbox"), { key: "Enter", shiftKey: true });
    expect(fetch).not.toHaveBeenCalled();
    fireEvent.keyDown(screen.getByRole("textbox"), { key: "Enter" });
    expect(await screen.findByText(thanhCong.answer)).toBeTruthy();
    expect(screen.getByText("Nguồn: Thực đơn (10:00)")).toBeTruthy();
    expect((screen.getByRole("textbox") as HTMLTextAreaElement).value).toBe("");
    expect(screen.getByRole("log", { name: "Hội thoại" }).getAttribute("aria-live")).toBe("polite");
    expect(await fetch.mock.calls[0][0].json()).toEqual({ question: "Có món gì?", history: [] });
  });

  it("history chỉ sáu lượt thật gần nhất, bỏ suy giảm, nguồn và mốc; mọi request chỉ POST /chat/turns kể cả đặt luôn", async () => {
    const bodies: { question: string; history: unknown[] }[] = [];
    const requests: string[] = [];
    dung(async (r) => {
      const body = await r.json(); bodies.push(body); requests.push(`${r.method} ${new URL(r.url).pathname}`);
      return json(body.question === "suy giảm" ? { ...thanhCong, degraded_reason: "tat" } : { ...thanhCong, answer: `Trả ${body.question}` });
    });
    for (let i = 0; i < 8; i++) { hoi(`Câu ${i}`); await screen.findByText(`Trả Câu ${i}`); }
    hoi("suy giảm"); await screen.findByText(/Trợ lý đang tắt/);
    hoi("đặt luôn"); await screen.findByText("Trả đặt luôn");
    expect(bodies.at(-1)?.history).toEqual(Array.from({ length: 6 }, (_, i) => [
      { role: "user", text: `Câu ${i + 2}` }, { role: "assistant", text: `Trả Câu ${i + 2}` },
    ]).flat());
    expect(bodies.every((b) => b.history.length <= 12)).toBe(true);
    expect(new Set(requests)).toEqual(new Set(["POST /api/chat/turns"]));
  });

  it.each([
    ["tat", "Trợ lý đang tắt."], ["het_ngan_sach", "Trợ lý đã dùng hết lượt hỏi của hôm nay."],
    ["qua_han", "Trợ lý trả lời quá lâu nên đã dừng."], ["qua_so_lan", "Trợ lý chưa tìm được câu trả lời."],
    ["loi_hang", "Trợ lý đang gặp lỗi."], ["ma_moi", "Trợ lý chưa trả lời được (ma_moi)."],
  ])("suy giảm %s bỏ answer có chữ và luôn có link menu", async (code, message) => {
    dung(async () => json({ ...thanhCong, degraded_reason: code })); hoi(); await xong();
    expect(screen.queryByText(thanhCong.answer)).toBeNull();
    expect(screen.queryByText(/Nguồn:/)).toBeNull();
    expect(screen.getByRole("status").textContent).toContain(message);
    expect(within(screen.getByRole("status")).getByRole("link", { name: "Xem thực đơn" }).getAttribute("href")).toBe("/dat-mon");
  });

  it("no_response giữ câu, không bày câu giả, có link menu và không thêm history khi hỏi lại", async () => {
    const { fetch } = dung(async () => { throw new Error("offline"); });
    hoi("Câu cần giữ"); await xong();
    expect(screen.getByRole("alert").textContent).toContain("Không kết nối được tới quán. Thử lại sau.");
    expect(screen.getByRole("link").getAttribute("href")).toBe("/dat-mon");
    expect((screen.getByRole("textbox") as HTMLTextAreaElement).value).toBe("Câu cần giữ");
    expect(screen.getByRole("log").textContent).toBe("");
    fetch.mockImplementation(async () => json(thanhCong));
    fireEvent.click(screen.getByRole("button", { name: "Hỏi" })); await screen.findByText(thanhCong.answer);
    expect((await fetch.mock.calls[1][0].json()).history).toEqual([]);
  });

  it.each([[400, "invalid_request", "Câu hỏi chưa đúng hình."], [500, "internal_error", "Chưa hỏi được (internal_error)."], [502, "la", "Chưa hỏi được (502)."]])("lỗi HTTP %s giữ câu và có link menu", async (status, code, message) => {
    dung(async () => json({ code }, status)); hoi(); await xong();
    expect(screen.getByRole("alert").textContent).toContain(message);
    expect(screen.getByRole("link").getAttribute("href")).toBe("/dat-mon");
    expect((screen.getByRole("textbox") as HTMLTextAreaElement).value).toBe("Có món gì?");
  });

  it("rỗng và quá 500 ký tự không gọi mạng", () => {
    const { fetch } = dung(); hoi("   "); hoi("x".repeat(501));
    fireEvent.keyDown(screen.getByRole("textbox"), { key: "Enter" });
    expect(screen.getByRole("alert").textContent).toBe("Câu hỏi tối đa 500 ký tự.");
    expect(fetch).not.toHaveBeenCalled();
  });

  it("đóng huỷ signal, trả câu về ô, bỏ phản hồi muộn của lượt cũ khi đã hỏi lượt mới", async () => {
    let tra!: (r: Response) => void;
    const { fetch, mo } = dung(() => new Promise((resolve) => { tra = resolve; }));
    hoi("Câu đang chờ"); await waitFor(() => expect(fetch).toHaveBeenCalledTimes(1));
    const signal = fetch.mock.calls[0][0].signal;
    expect((screen.getByRole("button", { name: "Hỏi" }) as HTMLButtonElement).disabled).toBe(true);
    mo(false); expect(signal.aborted).toBe(true);
    expect(screen.queryByText("Đang hỏi…")).toBeNull();
    expect((screen.getByRole("textbox") as HTMLTextAreaElement).value).toBe("Câu đang chờ");
    mo(true); fetch.mockImplementation(async () => json({ ...thanhCong, answer: "Lượt mới" }));
    hoi("Câu mới"); await screen.findByText("Lượt mới");
    await act(async () => { tra(json(thanhCong)); });
    expect(screen.queryByText(thanhCong.answer)).toBeNull(); expect(screen.queryByRole("alert")).toBeNull();
  });

  it("tháo component huỷ yêu cầu", async () => {
    const { fetch, unmount } = dung(() => new Promise(() => {})); hoi();
    await waitFor(() => expect(fetch).toHaveBeenCalledTimes(1)); unmount();
    expect(fetch.mock.calls[0][0].signal.aborted).toBe(true);
  });
  it("nguồn bảng giá và tên lạ giữ đúng; không nguồn thì không bày dòng nguồn", async () => {
    const { fetch } = dung(async () => json({ ...thanhCong, sources: [] })); hoi(); await xong();
    expect(screen.queryByText(/Nguồn:/)).toBeNull();
    fetch.mockImplementation(async () => json({ ...thanhCong, sources: ["tinh_gia", "nguon_moi"].map((tool) => ({ tool, read_at: "2026-11-05T03:00:00Z" })) }));
    hoi("Hỏi tiếp"); await xong(); expect(screen.getByText("Nguồn: Bảng giá (10:00), nguon_moi (10:00)")).toBeTruthy();
  });
});
