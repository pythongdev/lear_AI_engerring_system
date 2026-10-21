// Test hồi quy P4-10 (khách: QR tại bàn) — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa điều
// kiện kiểm. Giữ (ADR-102 điểm 1 dòng Khách · 3 · 4, I-023, I-024, I-008): bàn và menu lấy ở server cho từng request
// (fetch `cache: "no-store"`, không cú pháp cache của Next); khách chỉ thấy nhãn bàn, thân gửi không mang định danh bàn; tổng
// khách thấy là total_vnd của POST /price-quotes cho đúng cả giỏ hiện tại, gửi chỉ mở khi lần tính thử mới nhất xong; mỗi lần
// bấm gửi một submission_code, mất phản hồi là chưa rõ kết quả, Gửi lại giữ dấu cũ; giỏ nháp ở Zustand theo mã QR, không một
// số tiền nào; lời tạm dừng · mất kết nối là nguyên văn master_plan/shop-facts.md §6.8 · §6.11 (chủ repo chọn 2026-10-21).
import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { ApiProvider } from "@/lib/api/provider";
import { useNhapKhach } from "@/lib/nhap-khach";

import BanPage from "./[ma]/page";
import { CAU_MAT_KET_NOI, CAU_NGOAI_GIO, CAU_TAM_DUNG, QR_BAN_3, UUID, baoGia, clientBackend, coGia, guiDi, serverBackend, sx, tinhThuDi,
  type Ghi, type TraLoi } from "./mau-khach";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/ban/x",
  useSearchParams: () => new URLSearchParams(),
}));
afterEach(() => {
  cleanup();
  vi.unstubAllGlobals();
  useNhapKhach.getState().xoaHet();
});

async function mo(ma: string, opts: { tinhThu?: Ghi; gui?: Ghi; qr?: { status: number; body?: unknown } } = {}) {
  const server = serverBackend(opts.qr ?? QR_BAN_3);
  const trang = await BanPage({ params: Promise.resolve({ ma }) });
  const b = clientBackend(opts.tinhThu, opts.gui, opts.qr ?? QR_BAN_3);
  render(<ApiProvider fetch={b.fetch}>{trang}</ApiProvider>);
  return { server, goi: b.goi };
}
const nutGui = () => screen.getByRole("button", { name: "Gửi lượt gọi" }) as HTMLButtonElement;
const luotXong = { status: 201, body: { sales_order_id: 70, table_session_id: 9, dining_table_id: 3, channel_code: "qr_table", status: "in_progress",
  total_vnd: 71000, lines: [] } };

describe("khách QR tại bàn — lấy trước ở server", () => {
  it.each([
    ["5", "Bàn 5"],
    [" 5 ", "Bàn 5"],
    ["Bàn 3", "Bàn 3"],
  ])("h1 nhãn %j hiện đúng %j và một biểu tượng QR", async (label, heading) => {
    await mo("ma-tieu-de", { qr: { status: 200, body: { label } } });
    const h1 = screen.getByRole("heading", { level: 1 });
    expect(h1.textContent?.trim()).toBe(heading);
    expect(h1.querySelectorAll("svg")).toHaveLength(1);
    expect(h1.querySelector("svg")?.getAttribute("aria-hidden")).toBe("true");
  });

  it("bàn và menu lấy ở server, không cache; lần vẽ đầu đã có nhãn bàn và món; không lộ định danh bàn", async () => {
    const { server } = await mo("ma-a1");
    expect(server.map((g) => new URL(g.url).pathname).sort()).toEqual(["/menu", "/qr-codes/ma-a1"]);
    expect(server.every((g) => g.cache === "no-store")).toBe(true);
    expect(screen.getByRole("heading", { level: 1 }).textContent).toContain("Bàn 3");
    expect(screen.getByRole("button", { name: "Thêm Bánh cuốn" })).toBeTruthy();
    expect(document.body.textContent).not.toMatch(/dining_table_id|table_session_id/);
  });

  it("mã không còn hiện hành (404 qr_code_not_current): mời quét lại, không bày menu", async () => {
    await mo("ma-cu", { qr: { status: 404, body: { code: "qr_code_not_current", message: "x" } } });
    expect(screen.getByText(/quét lại mã/i)).toBeTruthy();
    await new Promise((r) => setTimeout(r, 50));
    expect(screen.queryByRole("button", { name: /^Thêm / })).toBeNull();
  });
});

describe("khách QR tại bàn — giỏ, tổng tính thử, gửi", () => {
  it("tổng là total_vnd của POST /price-quotes cho cả giỏ; thân tính thử không giá, không mang về; đổi giỏ thì tính lại", async () => {
    const { goi } = await mo("ma-b1");
    fireEvent.click(screen.getByRole("button", { name: "Thêm Bánh cuốn" }));
    fireEvent.click(screen.getByRole("button", { name: "Thêm Canh" }));
    expect(await screen.findByText(/Tổng tạm tính 52\.000đ/)).toBeTruthy();
    const ca = tinhThuDi(goi).find((g) => (g.body?.lines as unknown[]).length === 2)!;
    const lines = ca.body?.lines as { menu_item_id: number; quantity: number; option_ids: number[] }[];
    expect(Object.keys(ca.body!)).toEqual(["lines"]);
    expect(lines.map((l) => ({ ...l, option_ids: sx(l.option_ids) }))).toEqual([
      { menu_item_id: 1, quantity: 1, option_ids: [11, 21] },
      { menu_item_id: 2, quantity: 1, option_ids: [] },
    ]);
    expect(coGia(ca.body)).toBe(false);
    expect(JSON.stringify(ca.body)).not.toMatch(/is_takeaway/);
    fireEvent.change(within(screen.getByRole("region", { name: "Dòng 2" })).getByRole("spinbutton", { name: "Số lượng" }), { target: { value: "3" } });
    expect(await screen.findByText(/Tổng tạm tính 63\.000đ/)).toBeTruthy();
    expect(screen.queryByText(/Tổng tạm tính 52\.000đ/)).toBeNull();
  });

  it("đang tính thử thì chưa gửi được; xong thì gửi POST /qr-codes/{ma}/orders đúng thân, không bàn, không giá", async () => {
    let xong!: (v: TraLoi) => void;
    const { goi } = await mo("ma-c1", { tinhThu: () => new Promise<TraLoi>((r) => { xong = r; }), gui: () => luotXong });
    fireEvent.click(screen.getByRole("button", { name: "Thêm Canh" }));
    await waitFor(() => expect(tinhThuDi(goi).length).toBeGreaterThan(0));
    expect(nutGui().disabled).toBe(true);
    await act(async () => xong(baoGia(41000)));
    await waitFor(() => expect(nutGui().disabled).toBe(false));
    fireEvent.click(nutGui());
    expect(await screen.findByText("Đã gửi lượt gọi · tổng 71.000đ")).toBeTruthy();
    const [g] = guiDi(goi);
    expect(g.path).toBe("/qr-codes/ma-c1/orders");
    expect(g.body?.submission_code).toMatch(UUID);
    expect(g.body).toEqual({ submission_code: g.body?.submission_code, lines: [{ menu_item_id: 2, quantity: 1, option_ids: [] }] });
    expect(coGia(g.body)).toBe(false);
    expect(screen.queryByRole("region", { name: "Dòng 1" })).toBeNull();
  });

  it("lượt sau mang dấu lần gửi mới", async () => {
    const { goi } = await mo("ma-c2", { gui: () => luotXong });
    for (let i = 0; i < 2; i++) {
      fireEvent.click(screen.getByRole("button", { name: "Thêm Canh" }));
      await waitFor(() => expect(nutGui().disabled).toBe(false));
      fireEvent.click(nutGui());
      await waitFor(() => expect(guiDi(goi)).toHaveLength(i + 1));
      await screen.findByText("Đã gửi lượt gọi · tổng 71.000đ");
    }
    expect(guiDi(goi)[1].body?.submission_code).not.toBe(guiDi(goi)[0].body?.submission_code);
  });

  it("mất phản hồi: chưa rõ kết quả, không tự gửi lại; Gửi lại giữ nguyên dấu; bấm hai lần một lời gọi (I-024)", async () => {
    let xong!: (v: TraLoi) => void;
    const { goi } = await mo("ma-d1", { gui: (_g, lan) => (lan === 1 ? "mat-mang" : new Promise<TraLoi>((r) => { xong = r; })) });
    fireEvent.click(screen.getByRole("button", { name: "Thêm Canh" }));
    await waitFor(() => expect(nutGui().disabled).toBe(false));
    fireEvent.click(nutGui());
    expect(await screen.findByText(/Chưa xác nhận được kết quả/)).toBeTruthy();
    await new Promise((r) => setTimeout(r, 50));
    expect(guiDi(goi)).toHaveLength(1);
    const lai = screen.getByRole("button", { name: "Gửi lại" });
    fireEvent.click(lai);
    fireEvent.click(lai);
    await waitFor(() => expect(guiDi(goi)).toHaveLength(2));
    await act(async () => xong({ ...luotXong, status: 200 }));
    expect(await screen.findByText("Đã gửi lượt gọi · tổng 71.000đ")).toBeTruthy();
    expect(guiDi(goi)).toHaveLength(2);
    expect(guiDi(goi)[1].body?.submission_code).toBe(guiDi(goi)[0].body?.submission_code);
  });

  it("lời từ chối của backend: tạm dừng, ngoài giờ, mất kết nối đúng nguyên văn; mã QR cũ mời quét lại; giỏ giữ nguyên", async () => {
    const ca: [string, number, string | RegExp][] = [
      ["order_intake_paused", 409, CAU_TAM_DUNG],
      ["outside_selling_hours", 409, CAU_NGOAI_GIO],
      ["shop_not_seeing_orders", 409, CAU_MAT_KET_NOI],
      ["qr_code_not_current", 404, /quét lại mã/i],
    ];
    for (const [code, status, chu] of ca) {
      await mo(`ma-e-${code}`, { gui: () => ({ status, body: { code, message: "x" } }) });
      fireEvent.click(screen.getByRole("button", { name: "Thêm Canh" }));
      await waitFor(() => expect(nutGui().disabled).toBe(false));
      fireEvent.click(nutGui());
      expect(await screen.findByText(chu)).toBeTruthy();
      expect(screen.queryByText(new RegExp(`Mã: ${code}`))).toBeNull();
      expect(screen.getByRole("region", { name: "Dòng 1" })).toBeTruthy();
      cleanup();
      vi.unstubAllGlobals();
    }
  });
});

describe("khách QR tại bàn — giỏ nháp", () => {
  it("giỏ giữ khi rời trang rồi quay lại cùng mã; mã khác thì giỏ trống; nháp không một số tiền nào", async () => {
    await mo("ma-f1");
    fireEvent.click(screen.getByRole("button", { name: "Thêm Bánh cuốn" }));
    fireEvent.click(within(screen.getByRole("region", { name: "Dòng 1" })).getByRole("radio", { name: "Chay" }));
    cleanup();
    await mo("ma-f1");
    const d = screen.getByRole("region", { name: "Dòng 1" });
    expect((within(d).getByRole("radio", { name: "Chay" }) as HTMLInputElement).checked).toBe(true);
    expect(JSON.stringify(useNhapKhach.getState())).toContain("12");
    expect(coGia(useNhapKhach.getState())).toBe(false);
    cleanup();
    await mo("ma-f2");
    expect(screen.queryByRole("region", { name: "Dòng 1" })).toBeNull();
  });
});
