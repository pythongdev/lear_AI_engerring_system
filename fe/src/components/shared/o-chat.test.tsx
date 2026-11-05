import type { ReactNode } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import LayoutChuQuan from "@/app/chu-quan/layout";
import LayoutQuay from "@/app/quay/layout";
import LayoutTram from "@/app/tram/layout";
import { ApiProvider } from "@/lib/api/provider";
import type { Session } from "@/lib/auth/khung";
import { KHOA_PHIEN, usePhien } from "@/lib/auth/session";
import { OChat } from "./o-chat";

const { renderTinHieu } = vi.hoisted(() => ({ renderTinHieu: vi.fn() }));
vi.mock("@/components/tai-khoan/khung-theo-vai", () => ({
  KhungTheoVai: ({ children }: { children: ReactNode }) => children,
}));
vi.mock("@/lib/realtime/tin-hieu", async (goc) => ({
  // CHAT-14: hộp tin dùng tuyChonKeo thật.
  ...(await goc<typeof import("@/lib/realtime/tin-hieu")>()),
  TinHieuProvider: ({ children }: { children: ReactNode }) => {
    renderTinHieu();
    return <div data-testid="tin-hieu">{children}</div>;
  },
  BaoMatKetNoi: () => null,
}));
vi.mock("@/app/quay/_components/tu-nha-don-hen", () => ({ TuNhaDonHen: () => null }));
vi.mock("@/app/chu-quan/_components/thanh-dieu-huong", () => ({ ThanhDieuHuong: () => null }));

const nguoiA: Session = {
  person_id: 1, display_name: "Người A", role_code: "quay", is_owner: false,
  must_change_password: false, counter_duty_id: 1,
};
const nguoiB: Session = { ...nguoiA, person_id: 2, display_name: "Người B" };
const nhanMo = "Mở trò chuyện";
const nhanDong = "Đóng trò chuyện";
const nhanNhap = "Nội dung tin";

beforeEach(() => {
  vi.clearAllMocks();
  vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", "true");
});
afterEach(() => { cleanup(); vi.unstubAllEnvs(); });

function traJson(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}

function dung(children: ReactNode = <OChat khung="/tram" />, phien: () => Session = () => nguoiA) {
  const requests: { method: string; path: string }[] = [];
  const fetch = vi.fn(async (request: Request) => {
    const path = new URL(request.url).pathname;
    requests.push({ method: request.method, path });
    if (request.method === "GET" && path === "/api/sessions/current") return traJson(phien());
    // CHAT-14: hộp tin đọc các đường này khi mở bảng; trả rỗng để vỏ không vướng lỗi đọc.
    const trangTin = { messages: [], next_before_id: null, read_at: "2026-11-04T10:00:00+07:00", poll_interval_seconds: 20 };
    if (request.method === "GET" && path.startsWith("/api/station-messages/")) return traJson(trangTin);
    if (request.method === "GET" && path === "/api/assigned-tasks/mine") return traJson({ assigned_tasks: [] });
    if (request.method === "GET" && path === "/api/people") return traJson({ people: [] });
    if (request.method === "GET" && path === "/api/dining-tables") return traJson({ tables: [] });
    return traJson({ code: "unexpected_request" }, 500);
  });
  return { ...render(<ApiProvider fetch={fetch}>{children}</ApiProvider>), requests, fetch };
}

async function moChat() {
  const nut = await screen.findByRole("button", { name: nhanMo });
  fireEvent.click(nut);
  return nut;
}

describe("CHAT-04 — vỏ ô chat", () => {
  it("A1 mở focus ô nhập, đóng bằng nút và Esc trả focus về nút mở", async () => {
    dung();
    const nut = await moChat();
    expect(document.activeElement).toBe(screen.getByRole("textbox", { name: nhanNhap }));
    const bang = screen.getByRole("dialog", { name: "Trò chuyện" });
    expect(bang.getAttribute("aria-modal")).toBe("false");
    // CHAT-14: bảng giờ chứa hộp tin; nút và chữ của hộp do hop-tin.test.tsx kiểm.
    expect(within(bang).getByRole("button", { name: nhanDong })).toBeTruthy();

    fireEvent.click(screen.getByRole("button", { name: nhanDong }));
    expect(screen.queryByRole("dialog")).toBeNull();
    expect(document.activeElement).toBe(nut);

    fireEvent.click(nut);
    expect(document.activeElement).toBe(screen.getByRole("textbox", { name: nhanNhap }));
    fireEvent.keyDown(document.activeElement!, { key: "Escape" });
    expect(screen.queryByRole("dialog")).toBeNull();
    expect(document.activeElement).toBe(nut);
  });

  it("A1 bảng mở vẫn bấm và gõ ngoài bảng; Esc bên ngoài không đóng chat", async () => {
    const bam = vi.fn();
    dung(<><OChat khung="/tram" /><button onClick={bam}>Nút ngoài</button><input aria-label="Ô ngoài" /></>);
    await moChat();
    fireEvent.click(screen.getByRole("button", { name: "Nút ngoài" }));
    expect(bam).toHaveBeenCalledTimes(1);
    const ngoai = screen.getByRole("textbox", { name: "Ô ngoài" });
    act(() => ngoai.focus());
    expect(document.activeElement).toBe(ngoai);
    fireEvent.change(ngoai, { target: { value: "Thao tác tay" } });
    expect((ngoai as HTMLInputElement).value).toBe("Thao tác tay");
    fireEvent.keyDown(ngoai, { key: "Escape" });
    expect(screen.getByRole("dialog")).toBeTruthy();
  });

  it.each([undefined, "", "false", "1", "true"])("A2 cờ=%s chỉ true mới vẽ nút mở", async (co) => {
    vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", co);
    const { container, fetch } = dung();
    if (co === "true") {
      expect(await screen.findByRole("button", { name: nhanMo })).toBeTruthy();
    } else {
      expect(screen.queryByRole("button", { name: nhanMo })).toBeNull();
      expect(container.innerHTML).toBe("");
      expect(fetch).not.toHaveBeenCalled();
    }
  });

  it("phiên đang tải không vẽ gì", () => {
    const { container } = render(<ApiProvider fetch={() => new Promise<Response>(() => {})}><OChat khung="/tram" /></ApiProvider>);
    expect(container.innerHTML).toBe("");
  });

  it.each([401, 500])("phiên null hoặc lỗi HTTP %s không vẽ gì", async (status) => {
    let daDoc = false;
    function TheoDoiPhien() {
      const phien = usePhien();
      daDoc = phien.isFetched;
      return null;
    }
    const { container } = render(
      <ApiProvider fetch={async () => traJson({ code: status === 401 ? "unauthenticated" : "internal_error" }, status)}>
        <TheoDoiPhien /><OChat khung="/tram" />
      </ApiProvider>,
    );
    await waitFor(() => expect(daDoc).toBe(true));
    expect(container.innerHTML).toBe("");
  });

  it("A4 mở, gõ, đóng chỉ đọc phiên dùng chung cache và các đường đọc của hộp tin, không lệnh ghi", async () => {
    function PhienCuaKhung() { usePhien(); return null; }
    const { requests } = dung(<><PhienCuaKhung /><OChat khung="/tram" /></>);
    await moChat();
    fireEvent.change(screen.getByRole("textbox", { name: nhanNhap }), { target: { value: "Nháp chưa gửi" } });
    fireEvent.click(screen.getByRole("button", { name: nhanDong }));
    // ApiProvider đi qua tiền tố /api của Next. Sửa 2026-11-04 (CHAT-14): mở bảng đọc hộp tin; vẫn không lệnh ghi nào.
    expect(requests.filter((r) => r.method !== "GET")).toEqual([]);
    expect(requests.filter((r) => r.path === "/api/sessions/current")).toHaveLength(1);
    expect(new Set(requests.map((r) => r.path))).toEqual(new Set([
      "/api/sessions/current", "/api/station-messages/mine", "/api/assigned-tasks/mine", "/api/dining-tables",
    ]));
  });

  it("A5 gõ nháp không ghi localStorage hay sessionStorage", async () => {
    const localTruoc = localStorage.length;
    const sessionTruoc = sessionStorage.length;
    dung();
    await moChat();
    fireEvent.change(screen.getByRole("textbox", { name: nhanNhap }), { target: { value: "Nháp riêng" } });
    expect((screen.getByRole("textbox", { name: nhanNhap }) as HTMLInputElement).value).toBe("Nháp riêng");
    expect(localStorage.length).toBe(localTruoc);
    expect(sessionStorage.length).toBe(sessionTruoc);
  });

  it("A6 đổi người A sang B xoá nháp và trạng thái mở của người A", async () => {
    let nguoi = nguoiA;
    function DoiNguoi() {
      const queries = useQueryClient();
      return <button onClick={() => {
        nguoi = nguoiB;
        void queries.invalidateQueries({ queryKey: KHOA_PHIEN });
      }}>Đổi người</button>;
    }
    dung(<><OChat khung="/tram" /><DoiNguoi /></>, () => nguoi);
    await moChat();
    fireEvent.change(screen.getByRole("textbox", { name: nhanNhap }), { target: { value: "Nháp của A" } });
    expect((screen.getByRole("textbox", { name: nhanNhap }) as HTMLInputElement).value).toBe("Nháp của A");
    fireEvent.click(screen.getByRole("button", { name: "Đổi người" }));
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    await moChat();
    expect((screen.getByRole("textbox", { name: nhanNhap }) as HTMLInputElement).value).toBe("");
  });
});

describe.each([
  ["/quay", LayoutQuay, true],
  ["/tram", LayoutTram, true],
  ["/chu-quan", LayoutChuQuan, false],
] as const)("CHAT-04 — layout %s", (_duong, Layout, coTinHieu) => {
  it("A3 chat ngoài TinHieuProvider, mở/đóng không render lại provider", async () => {
    dung(<Layout><p>Nội dung màn</p></Layout>);
    const nut = await screen.findByRole("button", { name: nhanMo });
    const provider = screen.queryByTestId("tin-hieu");
    expect(provider !== null).toBe(coTinHieu);
    expect(nut.closest('[data-testid="tin-hieu"]')).toBeNull();
    if (provider) expect(within(provider).getByText("Nội dung màn")).toBeTruthy();
    const soLanTruoc = renderTinHieu.mock.calls.length;
    expect(soLanTruoc).toBe(coTinHieu ? 1 : 0);
    fireEvent.click(nut);
    expect(screen.getByRole("dialog").closest('[data-testid="tin-hieu"]')).toBeNull();
    expect(renderTinHieu).toHaveBeenCalledTimes(soLanTruoc);
    fireEvent.click(screen.getByRole("button", { name: nhanDong }));
    expect(renderTinHieu).toHaveBeenCalledTimes(soLanTruoc);
    fireEvent.click(nut);
    fireEvent.keyDown(screen.getByRole("textbox", { name: nhanNhap }), { key: "Escape" });
    expect(screen.queryByRole("dialog")).toBeNull();
    expect(renderTinHieu).toHaveBeenCalledTimes(soLanTruoc);
  });

  it.each([undefined, "", "false", "1"])("A3 cờ=%s layout không có nút mở", (co) => {
    vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", co);
    dung(<Layout><p>Nội dung màn</p></Layout>);
    expect(screen.getByText("Nội dung màn")).toBeTruthy();
    expect(screen.queryByRole("button", { name: nhanMo })).toBeNull();
    expect(screen.queryByRole("dialog")).toBeNull();
  });
});

describe("CHAT-07 — thẻ Hỏi quán", () => {
  it("thẻ thứ ba mở lười, focus câu hỏi, giữ nháp khi đổi thẻ", async () => {
    dung(); await moChat();
    expect(screen.queryByRole("textbox", { name: "Câu hỏi", hidden: true })).toBeNull();
    expect(screen.getAllByRole("tab").map((t) => t.textContent)).toEqual(["Tin nhắn", "Báo nghỉ", "Hỏi quán"]);
    fireEvent.click(screen.getByRole("tab", { name: "Hỏi quán" }));
    const input = screen.getByRole("textbox", { name: "Câu hỏi" }); expect(document.activeElement).toBe(input);
    fireEvent.change(input, { target: { value: "Nháp hỏi" } });
    fireEvent.click(screen.getByRole("tab", { name: "Tin nhắn" }));
    fireEvent.click(screen.getByRole("tab", { name: "Hỏi quán" }));
    expect((screen.getByRole("textbox", { name: "Câu hỏi" }) as HTMLTextAreaElement).value).toBe("Nháp hỏi");
  });
  it("đổi thẻ huỷ hỏi đang chờ và bỏ phản hồi muộn", async () => {
    const { fetch } = dung(); await moChat();
    let tra!: (r: Response) => void; let signal!: AbortSignal;
    const goc = fetch.getMockImplementation()!;
    fetch.mockImplementation((r: Request) => {
      if (new URL(r.url).pathname === "/api/chat/turns") { signal = r.signal; return new Promise((resolve) => { tra = resolve; }); }
      return goc(r);
    });
    fireEvent.click(screen.getByRole("tab", { name: "Hỏi quán" }));
    fireEvent.change(screen.getByRole("textbox", { name: "Câu hỏi" }), { target: { value: "Hỏi thử" } });
    fireEvent.click(screen.getByRole("button", { name: "Hỏi" })); await waitFor(() => expect(signal).toBeTruthy());
    fireEvent.click(screen.getByRole("tab", { name: "Tin nhắn" })); expect(signal.aborted).toBe(true);
    await act(async () => { tra(traJson({ answer: "Câu muộn", sources: [], degraded_reason: null })); });
    fireEvent.click(screen.getByRole("tab", { name: "Hỏi quán" })); expect(screen.queryByText("Câu muộn")).toBeNull();
  });
});
