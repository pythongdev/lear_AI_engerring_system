// Test hồi quy P4-10 (khách: đơn web giao · mang đi · đặt trước) — Claude viết TRƯỚC khi có code (L2). Người thi công làm
// cho xanh, KHÔNG sửa điều kiện kiểm. Giữ (ADR-102 điểm 1 dòng Khách · 3 · 4, I-024, I-008, shop-facts §2): menu lấy ở server
// cho từng request; kênh `delivery` cần địa chỉ, giờ cần hàng tuỳ chọn (đặt trước); kênh `pickup` cần giờ hẹn lấy; giờ đọc theo
// giờ quán (+07:00); thân gửi không bàn, không giá, không mang về; tổng là total_vnd tính thử mới nhất; một submission_code mỗi
// lần bấm, giữ cho Gửi lại; giỏ nháp không một số tiền nào; lời tạm dừng · mất kết nối · ngoài giờ là nguyên văn shop-facts.
import { act, cleanup, fireEvent, render, screen, waitFor } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { ApiProvider } from "@/lib/api/provider";
import { useNhapKhach } from "@/lib/nhap-khach";

import { CAU_MAT_KET_NOI, CAU_NGOAI_GIO, CAU_TAM_DUNG, UUID, clientBackend, coGia, guiDi, serverBackend, type Ghi, type TraLoi } from "../ban/mau-khach";
import DatMonPage from "./page";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/dat-mon",
  useSearchParams: () => new URLSearchParams(),
}));
afterEach(() => {
  cleanup();
  vi.unstubAllGlobals();
  useNhapKhach.getState().xoaHet();
});

async function mo(gui?: Ghi) {
  const server = serverBackend();
  const trang = await DatMonPage();
  const b = clientBackend(undefined, gui);
  render(<ApiProvider fetch={b.fetch}>{trang}</ApiProvider>);
  await screen.findByRole("button", { name: "Thêm Bánh cuốn" });
  return { server, goi: b.goi };
}
const nutDat = () => screen.getByRole("button", { name: "Đặt đơn" }) as HTMLButtonElement;
const donXong = (channel: "delivery" | "pickup") => ({ status: 201, body: { sales_order_id: 88, channel_code: channel,
  handover_code: channel === "delivery" ? "door_delivery" : "shop_pickup", status: "pending_confirmation", total_vnd: 46000, lines: [],
  customer_phone: "0907777777", delivery_address: channel === "delivery" ? "5 Lò Sũ" : null, customer_needed_at: null, customer_name: null, contact_note: null } });
async function dien(cach: "Giao tận nơi" | "Đến lấy") {
  fireEvent.click(screen.getByRole("radio", { name: cach }));
  fireEvent.change(screen.getByRole("textbox", { name: "Số điện thoại" }), { target: { value: "0907777777" } });
  fireEvent.click(screen.getByRole("button", { name: "Thêm Canh" }));
}

describe("đơn web — lấy trước ở server", () => {
  it("menu lấy ở server, không cache; lần vẽ đầu đã có món", async () => {
    const { server } = await mo();
    expect(server.map((g) => new URL(g.url).pathname)).toEqual(["/menu"]);
    expect(server.every((g) => g.cache === "no-store")).toBe(true);
    expect(screen.getByRole("button", { name: "Thêm Bánh cuốn" })).toBeTruthy();
  });
});

describe("đơn web — thông tin và gửi", () => {
  it("giao tận nơi: thiếu địa chỉ thì chưa đặt được; giờ cần hàng bỏ trống được; POST /online-orders đúng thân, không bàn, không giá", async () => {
    const { goi } = await mo(() => donXong("delivery"));
    await dien("Giao tận nơi");
    expect(await screen.findByText(/Tổng tạm tính 41\.000đ/)).toBeTruthy();
    expect(nutDat().disabled).toBe(true);
    fireEvent.change(screen.getByRole("textbox", { name: "Địa chỉ giao" }), { target: { value: "5 Lò Sũ" } });
    fireEvent.change(screen.getByRole("textbox", { name: "Tên" }), { target: { value: "Anh Nam" } });
    await waitFor(() => expect(nutDat().disabled).toBe(false));
    fireEvent.click(nutDat());
    expect(await screen.findByText("Đã đặt đơn 88 · tổng 46.000đ")).toBeTruthy();
    const [g] = guiDi(goi);
    expect(g.path).toBe("/online-orders");
    expect(g.body?.submission_code).toMatch(UUID);
    expect(g.body).toMatchObject({ channel_code: "delivery", customer_phone: "0907777777", delivery_address: "5 Lò Sũ", customer_name: "Anh Nam",
      lines: [{ menu_item_id: 2, quantity: 1, option_ids: [] }] });
    expect(g.body?.customer_needed_at ?? null).toBeNull();
    for (const k of ["dining_table_id", "table_session_id", "handover_code"]) expect(g.body && k in g.body).toBe(false);
    expect(JSON.stringify(g.body)).not.toMatch(/is_takeaway/);
    expect(coGia(g.body)).toBe(false);
    expect(screen.queryByRole("region", { name: "Dòng 1" })).toBeNull();
  });

  it("giao tận nơi đặt trước: giờ cần hàng gửi theo giờ quán", async () => {
    const { goi } = await mo(() => donXong("delivery"));
    await dien("Giao tận nơi");
    fireEvent.change(screen.getByRole("textbox", { name: "Địa chỉ giao" }), { target: { value: "5 Lò Sũ" } });
    fireEvent.change(screen.getByLabelText("Giờ cần hàng"), { target: { value: "2026-10-22T07:30" } });
    await waitFor(() => expect(nutDat().disabled).toBe(false));
    fireEvent.click(nutDat());
    await waitFor(() => expect(guiDi(goi)).toHaveLength(1));
    expect(Date.parse(String(guiDi(goi)[0].body?.customer_needed_at))).toBe(Date.parse("2026-10-22T07:30:00+07:00"));
  });

  it("đến lấy: không ô địa chỉ; thiếu giờ hẹn lấy thì chưa đặt được; đủ thì gửi pickup kèm giờ theo giờ quán", async () => {
    const { goi } = await mo(() => donXong("pickup"));
    await dien("Đến lấy");
    expect(screen.queryByRole("textbox", { name: "Địa chỉ giao" })).toBeNull();
    await screen.findByText(/Tổng tạm tính 41\.000đ/);
    expect(nutDat().disabled).toBe(true);
    fireEvent.change(screen.getByLabelText("Giờ cần hàng"), { target: { value: "2026-10-22T08:15" } });
    await waitFor(() => expect(nutDat().disabled).toBe(false));
    fireEvent.click(nutDat());
    await waitFor(() => expect(guiDi(goi)).toHaveLength(1));
    const b = guiDi(goi)[0].body!;
    expect(b.channel_code).toBe("pickup");
    expect(b.delivery_address ?? null).toBeNull();
    expect(Date.parse(String(b.customer_needed_at))).toBe(Date.parse("2026-10-22T08:15:00+07:00"));
  });

  it("mất phản hồi: chưa rõ kết quả, không tự gửi lại; Gửi lại giữ nguyên dấu và thân; bấm hai lần một lời gọi (I-024)", async () => {
    let xong!: (v: TraLoi) => void;
    const { goi } = await mo((_g, lan) => (lan === 1 ? "mat-mang" : new Promise<TraLoi>((r) => { xong = r; })));
    await dien("Đến lấy");
    fireEvent.change(screen.getByLabelText("Giờ cần hàng"), { target: { value: "2026-10-22T08:15" } });
    await waitFor(() => expect(nutDat().disabled).toBe(false));
    fireEvent.click(nutDat());
    expect(await screen.findByText(/Chưa xác nhận được kết quả/)).toBeTruthy();
    await new Promise((r) => setTimeout(r, 50));
    expect(guiDi(goi)).toHaveLength(1);
    const lai = screen.getByRole("button", { name: "Gửi lại" });
    fireEvent.click(lai);
    fireEvent.click(lai);
    await waitFor(() => expect(guiDi(goi)).toHaveLength(2));
    await act(async () => xong({ ...donXong("pickup"), status: 200 }));
    expect(await screen.findByText("Đã đặt đơn 88 · tổng 46.000đ")).toBeTruthy();
    expect(guiDi(goi)).toHaveLength(2);
    expect(guiDi(goi)[1].body).toEqual(guiDi(goi)[0].body);
  });

  it("lời từ chối của backend: tạm dừng, ngoài giờ, mất kết nối đúng nguyên văn; phiếu giữ nguyên", async () => {
    const ca: [string, string][] = [
      ["order_intake_paused", CAU_TAM_DUNG],
      ["outside_selling_hours", CAU_NGOAI_GIO],
      ["shop_not_seeing_orders", CAU_MAT_KET_NOI],
    ];
    for (const [code, chu] of ca) {
      await mo(() => ({ status: 409, body: { code, message: "x" } }));
      await dien("Đến lấy");
      fireEvent.change(screen.getByLabelText("Giờ cần hàng"), { target: { value: "2026-10-22T08:15" } });
      await waitFor(() => expect(nutDat().disabled).toBe(false));
      fireEvent.click(nutDat());
      expect(await screen.findByText(chu)).toBeTruthy();
      expect(screen.queryByText(new RegExp(`Mã: ${code}`))).toBeNull();
      expect(screen.getByRole("region", { name: "Dòng 1" })).toBeTruthy();
      expect((screen.getByRole("textbox", { name: "Số điện thoại" }) as HTMLInputElement).value).toBe("0907777777");
      cleanup();
      vi.unstubAllGlobals();
      useNhapKhach.getState().xoaHet();
    }
  });

  it("giỏ nháp đơn web giữ khi quay lại và không một số tiền nào", async () => {
    await mo();
    fireEvent.click(screen.getByRole("button", { name: "Thêm Bánh cuốn" }));
    expect(coGia(useNhapKhach.getState())).toBe(false);
    cleanup();
    await mo();
    expect(screen.getByRole("region", { name: "Dòng 1" })).toBeTruthy();
  });
});
