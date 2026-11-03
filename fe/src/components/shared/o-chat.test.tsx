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
vi.mock("@/lib/realtime/tin-hieu", () => ({
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
const nhanNhap = "Nháp trò chuyện";

beforeEach(() => {
  vi.clearAllMocks();
  vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", "true");
});
afterEach(() => { cleanup(); vi.unstubAllEnvs(); });

function traJson(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}

function dung(children: ReactNode = <OChat />, phien: () => Session = () => nguoiA) {
  const requests: { method: string; path: string }[] = [];
  const fetch = vi.fn(async (request: Request) => {
    const path = new URL(request.url).pathname;
    requests.push({ method: request.method, path });
    if (request.method === "GET" && path === "/api/sessions/current") return traJson(phien());
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
    expect(within(bang).getByText("Chat chưa nối. Hãy dùng màn thao tác tay.")).toBeTruthy();
    expect(within(bang).getAllByRole("button")).toEqual([screen.getByRole("button", { name: nhanDong })]);

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
    dung(<><OChat /><button onClick={bam}>Nút ngoài</button><input aria-label="Ô ngoài" /></>);
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
    const { container } = render(<ApiProvider fetch={() => new Promise<Response>(() => {})}><OChat /></ApiProvider>);
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
        <TheoDoiPhien /><OChat />
      </ApiProvider>,
    );
    await waitFor(() => expect(daDoc).toBe(true));
    expect(container.innerHTML).toBe("");
  });

  it("A4 mở, gõ, đóng chỉ gọi GET /sessions/current dùng chung cache phiên", async () => {
    function PhienCuaKhung() { usePhien(); return null; }
    const { requests } = dung(<><PhienCuaKhung /><OChat /></>);
    await moChat();
    fireEvent.change(screen.getByRole("textbox", { name: nhanNhap }), { target: { value: "Nháp chưa gửi" } });
    fireEvent.click(screen.getByRole("button", { name: nhanDong }));
    // ApiProvider đi qua tiền tố /api của Next, endpoint backend là /sessions/current.
    expect(requests).toEqual([{ method: "GET", path: "/api/sessions/current" }]);
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
    dung(<><OChat /><DoiNguoi /></>, () => nguoi);
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
