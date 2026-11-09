// Test hồi quy CHAT-09 — Claude viết TRƯỚC khi có code (2026-11-08). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Đứng trên: ADR-139 điểm 2 · 8 · 9 và Sửa đổi 2026-11-06; ADR-102 (đổi người xoá cache); CHAT-07 (hoi-quan.test.tsx giữ nguyên).
//
// Hợp đồng Claude chốt:
// - `HoiQuan` nhận thêm prop `khung?: Khung` (`@/lib/auth/khung`). Không có `khung` = mặt khách, hành vi CHAT-07 giữ nguyên.
// - Có `khung` = mặt người làm:
//   * chữ dẫn: "Trợ lý chỉ đọc số mà tài khoản của bạn xem được trên màn tay, không ghi gì."
//   * tên nguồn: doc_bang_tram "Bảng trạm" · doc_bang_phuc_vu "Bảng phục vụ" · doc_tong_quan "Tổng quan" · doc_menu "Thực đơn" ·
//     tinh_gia "Bảng giá"; tên lạ giữ nguyên. Mốc giờ:phút:giây Asia/Ho_Chi_Minh, dạng
//     "Nguồn: Bảng trạm (đọc lúc 10:00:05), Tổng quan (đọc lúc 10:00:07)".
//   * có ít nhất một nguồn: thêm "Số chỉ đúng tại mốc đọc; màn tay có thể đã đổi." kèm link màn tay.
//   * có câu trả lời mà không nguồn: "Câu này không kèm nguồn đọc nào của quán; đừng dựa vào số trong câu." kèm link màn tay,
//     không có dòng "Nguồn:".
//   * link màn tay theo khung: /tram → "Xem Bảng trạm" (/tram) · /quay → "Xem Sản xuất" (/quay/san-xuat) ·
//     /chu-quan → "Xem Vận hành" (/chu-quan/van-hanh). Suy giảm và lỗi dùng link này; mặt người làm không link /dat-mon.
//   * 401 `unauthenticated`: "Phiên đăng nhập đã hết. Đăng nhập lại." Từ chối khác giữ chữ CHAT-07. Mọi lỗi: đúng một lần gọi,
//     không tự gọi lại, không gọi đường nào khác.
//   * mất kết nối: alert "Không kết nối được tới quán. Thử lại sau.", log rỗng — không bày câu trả lời hay số nào.
// - `OChat` truyền `khung` của mình vào `HoiQuan`.
// - Đổi người (cùng tab, hay tab khác báo qua BroadcastChannel "banhcuon-phien") khi đang hỏi: huỷ yêu cầu, phản hồi muộn
//   không hiện, người mới thấy hội thoại rỗng và gửi history rỗng.
import type { ReactNode } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { KhungTheoVai } from "@/components/tai-khoan/khung-theo-vai";
import { ApiProvider } from "@/lib/api/provider";
import type { Khung, Session } from "@/lib/auth/khung";
import { KHOA_PHIEN } from "@/lib/auth/session";
import { HoiQuan } from "./hoi-quan";
import { OChat } from "./o-chat";

const replace = vi.fn();
vi.mock("next/navigation", () => ({
  useRouter: () => ({ replace, push: vi.fn() }),
  usePathname: () => "/tram",
  useSearchParams: () => new URLSearchParams(),
}));

beforeEach(() => {
  replace.mockReset();
  vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", "true");
});
afterEach(() => { cleanup(); vi.unstubAllEnvs(); });

const CHU_DAN = "Trợ lý chỉ đọc số mà tài khoản của bạn xem được trên màn tay, không ghi gì.";
const CHU_MOC = "Số chỉ đúng tại mốc đọc; màn tay có thể đã đổi.";
const CHU_KHONG_NGUON = "Câu này không kèm nguồn đọc nào của quán; đừng dựa vào số trong câu.";
const manTay: Record<Khung, [string, string]> = {
  "/tram": ["Xem Bảng trạm", "/tram"],
  "/quay": ["Xem Sản xuất", "/quay/san-xuat"],
  "/chu-quan": ["Xem Vận hành", "/chu-quan/van-hanh"],
};
const coSo = {
  answer: "Bàn 3 còn thiếu 2 đĩa bánh cuốn.",
  degraded_reason: null,
  sources: [
    { tool: "doc_bang_tram", read_at: "2026-11-08T03:00:05Z" },
    { tool: "doc_tong_quan", read_at: "2026-11-08T03:00:07Z" },
  ],
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}
function dung(khung: Khung, respond: (r: Request) => Promise<Response> = async () => json(coSo)) {
  const fetch = vi.fn(respond);
  render(<ApiProvider fetch={fetch}><HoiQuan mo khung={khung} /></ApiProvider>);
  return fetch;
}
function hoi(text = "Bàn 3 còn thiếu gì?") {
  fireEvent.change(screen.getByRole("textbox", { name: "Câu hỏi" }), { target: { value: text } });
  fireEvent.click(screen.getByRole("button", { name: "Hỏi" }));
}
async function xong() { await waitFor(() => expect(screen.queryByText("Đang hỏi…")).toBeNull()); }
function linkManTay(khung: Khung, trong: HTMLElement = document.body) {
  const [ten, href] = manTay[khung];
  const link = within(trong).getByRole("link", { name: ten });
  expect(link.getAttribute("href")).toBe(href);
  return link;
}
function khongCoDatMon() {
  expect(screen.queryAllByRole("link").map((l) => l.getAttribute("href"))).not.toContain("/dat-mon");
}

describe.each(["/tram", "/quay", "/chu-quan"] as const)("CHAT-09 HoiQuan mặt người làm %s", (khung) => {
  it("A1 nguồn nội bộ bày tên, mốc giờ:phút:giây Việt Nam, lời mốc đọc và link màn tay", async () => {
    dung(khung); hoi(); await screen.findByText(coSo.answer);
    expect(screen.getByText(CHU_DAN)).toBeTruthy();
    expect(screen.getByText("Nguồn: Bảng trạm (đọc lúc 10:00:05), Tổng quan (đọc lúc 10:00:07)")).toBeTruthy();
    const loi = screen.getByText(CHU_MOC, { exact: false });
    linkManTay(khung, loi.closest("p")!);
    expect(screen.queryByText(CHU_KHONG_NGUON, { exact: false })).toBeNull();
    khongCoDatMon();
  });

  it("A1 câu trả lời không nguồn có lời cảnh báo, không dòng Nguồn", async () => {
    dung(khung, async () => json({ ...coSo, sources: [] })); hoi(); await screen.findByText(coSo.answer);
    expect(screen.queryByText(/Nguồn:/)).toBeNull();
    expect(screen.queryByText(CHU_MOC, { exact: false })).toBeNull();
    linkManTay(khung, screen.getByText(CHU_KHONG_NGUON, { exact: false }).closest("p")!);
  });

  it("A1 mất kết nối không bày câu trả lời hay số nào, link về màn tay", async () => {
    const fetch = dung(khung, async () => { throw new Error("offline"); }); hoi(); await xong();
    expect(screen.getByRole("alert").textContent).toContain("Không kết nối được tới quán. Thử lại sau.");
    linkManTay(khung, screen.getByRole("alert"));
    expect(screen.getByRole("log", { name: "Hội thoại" }).textContent).toBe("");
    expect(fetch).toHaveBeenCalledTimes(1);
    khongCoDatMon();
  });

  it("A1 suy giảm link về màn tay, không câu trả lời", async () => {
    dung(khung, async () => json({ ...coSo, answer: "Không được hiện", degraded_reason: "het_ngan_sach" })); hoi(); await xong();
    expect(screen.queryByText("Không được hiện")).toBeNull();
    expect(screen.queryByText(/Nguồn:/)).toBeNull();
    linkManTay(khung, screen.getByRole("status"));
    khongCoDatMon();
  });

  it.each([
    [401, "unauthenticated", "Phiên đăng nhập đã hết. Đăng nhập lại."],
    [403, "owner_only", "Chưa hỏi được (owner_only)."],
    [403, "not_on_counter_duty", "Chưa hỏi được (not_on_counter_duty)."],
  ])("A3 từ chối %s %s có lời rõ, đúng một lần gọi, không gọi đường khác", async (status, code, chu) => {
    const fetch = dung(khung, async () => json({ code }, status)); hoi(); await xong();
    expect(screen.getByRole("alert").textContent).toContain(chu);
    linkManTay(khung, screen.getByRole("alert"));
    await new Promise((r) => setTimeout(r, 50));
    expect(fetch).toHaveBeenCalledTimes(1);
    expect(new URL(fetch.mock.calls[0][0].url).pathname).toBe("/api/chat/turns");
    expect(screen.getByRole("log", { name: "Hội thoại" }).textContent).toBe("");
  });
});

describe("CHAT-09 mặt khách không đổi", () => {
  it("không khung vẫn link /dat-mon, chữ dẫn cũ, không lời mốc đọc", async () => {
    const fetch = vi.fn(async () => json({ ...coSo, sources: [{ tool: "doc_menu", read_at: "2026-11-08T03:00:05Z" }] }));
    render(<ApiProvider fetch={fetch}><HoiQuan mo /></ApiProvider>);
    hoi(); await screen.findByText(coSo.answer);
    expect(screen.getByText("Nguồn: Thực đơn (10:00)")).toBeTruthy();
    expect(screen.queryByText(CHU_DAN)).toBeNull();
    expect(screen.queryByText(CHU_MOC, { exact: false })).toBeNull();
    expect(screen.getByText("Trợ lý chỉ trả lời về món và giá, không nhận đặt món.")).toBeTruthy();
  });
});

// ——— Mức OChat: khung truyền xuống và đổi người ———

const nguoiA: Session = {
  person_id: 1, display_name: "Người A", role_code: "trang_banh", is_owner: false, must_change_password: false, counter_duty_id: 0,
};
const nguoiB: Session = { ...nguoiA, person_id: 2, display_name: "Người B" };

type Cho = { signal: AbortSignal; body: { question: string; history: unknown[] }; tra: (r: Response) => void };
function dungOChat(children: ReactNode, phien: () => Session) {
  const cho: Cho[] = [];
  const fetch = vi.fn(async (request: Request) => {
    const path = new URL(request.url).pathname;
    if (request.method === "GET" && path === "/api/sessions/current") return json(phien());
    if (request.method === "GET" && path.startsWith("/api/station-messages/")) {
      return json({ messages: [], next_before_id: null, read_at: "2026-11-08T10:00:00+07:00", poll_interval_seconds: 20 });
    }
    if (request.method === "GET" && path === "/api/assigned-tasks/mine") return json({ assigned_tasks: [] });
    if (request.method === "GET" && path === "/api/dining-tables") return json({ tables: [] });
    if (request.method === "GET" && path === "/api/leave-notices/mine") return json({ leave_notices: [] });
    if (request.method === "POST" && path === "/api/chat/turns") {
      const body = await request.clone().json();
      return new Promise<Response>((resolve) => { cho.push({ signal: request.signal, body, tra: resolve }); });
    }
    return json({ code: "unexpected_request" }, 500);
  });
  render(<ApiProvider fetch={fetch}>{children}</ApiProvider>);
  return { cho, fetch };
}
async function moHoiQuan() {
  fireEvent.click(await screen.findByRole("button", { name: "Mở trò chuyện" }));
  fireEvent.click(screen.getByRole("tab", { name: "Hỏi quán" }));
}

describe("CHAT-09 OChat", () => {
  it("A1 OChat truyền khung: chữ dẫn người làm và link màn tay của khung khi suy giảm", async () => {
    const { cho } = dungOChat(<OChat khung="/tram" />, () => nguoiA);
    await moHoiQuan();
    expect(screen.getByText(CHU_DAN)).toBeTruthy();
    hoi(); await waitFor(() => expect(cho).toHaveLength(1));
    await act(async () => { cho[0].tra(json({ answer: null, sources: [], degraded_reason: "tat" })); });
    await xong();
    linkManTay("/tram", screen.getByRole("status"));
    khongCoDatMon();
  });

  it("A2 đổi người cùng tab khi đang hỏi: huỷ yêu cầu, phản hồi muộn không hiện, người mới gửi history rỗng", async () => {
    let nguoi = nguoiA;
    function DoiNguoi() {
      const queries = useQueryClient();
      return <button onClick={() => { nguoi = nguoiB; void queries.invalidateQueries({ queryKey: KHOA_PHIEN }); }}>Đổi người</button>;
    }
    const { cho } = dungOChat(<><OChat khung="/tram" /><DoiNguoi /></>, () => nguoi);
    await moHoiQuan();
    hoi("Câu đầu của A"); await waitFor(() => expect(cho).toHaveLength(1));
    await act(async () => { cho[0].tra(json({ ...coSo, answer: "Trả lời cho A" })); });
    await screen.findByText("Trả lời cho A");
    hoi("Câu chờ của A"); await waitFor(() => expect(cho).toHaveLength(2));

    fireEvent.click(screen.getByRole("button", { name: "Đổi người" }));
    await waitFor(() => expect(cho[1].signal.aborted).toBe(true));
    await act(async () => { cho[1].tra(json({ ...coSo, answer: "Trả lời muộn cho A" })); });

    await moHoiQuan();
    expect(screen.queryByText("Trả lời cho A")).toBeNull();
    expect(screen.queryByText("Trả lời muộn cho A")).toBeNull();
    expect(screen.getByRole("log", { name: "Hội thoại" }).textContent).toBe("");
    hoi("Câu của B"); await waitFor(() => expect(cho).toHaveLength(3));
    expect(cho[2].body).toEqual({ question: "Câu của B", history: [] });
  });

  it("A2 tab khác báo đổi phiên khi đang hỏi: huỷ yêu cầu, về /dang-nhap, phản hồi muộn không hiện", async () => {
    const { cho } = dungOChat(<KhungTheoVai khung="/tram"><OChat khung="/tram" /></KhungTheoVai>, () => nguoiA);
    await moHoiQuan();
    hoi("Câu chờ"); await waitFor(() => expect(cho).toHaveLength(1));

    const kenh = new BroadcastChannel("banhcuon-phien");
    kenh.postMessage({ loai: "doi-phien", tab: "tab-khac" });
    kenh.close();

    await waitFor(() => expect(cho[0].signal.aborted).toBe(true));
    await waitFor(() => expect(replace).toHaveBeenCalledWith("/dang-nhap"));
    await act(async () => { cho[0].tra(json({ ...coSo, answer: "Trả lời muộn" })); });
    expect(screen.queryByText("Trả lời muộn")).toBeNull();
    expect(screen.queryByRole("textbox", { name: "Câu hỏi" })).toBeNull();
  });
});
