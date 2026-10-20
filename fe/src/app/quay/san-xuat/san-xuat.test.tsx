// Test hồi quy P4-09 (màn sản xuất ở quầy) — Claude viết TRƯỚC khi có code (L2). Người thi công làm cho xanh, KHÔNG sửa
// điều kiện kiểm. Giữ (ADR-090, lời S-5): POS là nơi duy nhất ghi tiến độ; màn quầy bày cùng bảng của trạm và cho ghi
// *ra bàn* theo từng bàn hay từng đơn không bàn — POS nhập số cái từng thứ, gửi đúng một trong dining_table_id ·
// sales_order_id, mỗi item là khoá gom của bảng; ghi xong đọc lại; lời từ chối theo code; một lần bấm một lời gọi.
// Bấm mẻ · lùi mẻ · chuyển · ghi làm sai CHƯA có trên màn: hợp đồng không có đường đọc mã việc trạm (F-073).
import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { voiBackend } from "@/components/tai-khoan/test-utils";
import { ApiProvider } from "@/lib/api/provider";

import QuayPage from "../page";
import { bangMau, banMau, menuMau } from "./mau-san-xuat";
import Page from "./page";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/quay/san-xuat",
  useSearchParams: () => new URLSearchParams(),
}));
afterEach(cleanup);

type Goi = { method: string; path: string; body: unknown };
type TraLoi = { status: number; body?: unknown } | "mat-mang";
function mo(ghi: (g: Goi) => TraLoi | Promise<TraLoi> = () => ({ status: 599, body: { code: "khong_co_trong_hop_dong" } })) {
  const goi: Goi[] = [];
  const fetch = async (req: Request) => {
    const text = await req.text();
    const g: Goi = { method: req.method, path: new URL(req.url).pathname.replace(/^\/api/, ""), body: text ? JSON.parse(text) : undefined };
    goi.push(g);
    let r: TraLoi = { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    if (g.path === "/production-board") r = { status: 200, body: bangMau };
    else if (g.path === "/dining-tables") r = { status: 200, body: banMau };
    else if (g.path === "/menu") r = { status: 200, body: menuMau };
    else if (g.method === "POST") r = await ghi(g);
    if (r === "mat-mang") throw new TypeError("fetch failed");
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  };
  render(<ApiProvider fetch={fetch}><Page /></ApiProvider>);
  return goi;
}
const ghiDi = (g: Goi[]) => g.filter((x) => x.method === "POST");
const docBang = (g: Goi[]) => g.filter((x) => x.path === "/production-board").length;

async function moRaBan(ten: string) {
  const nut = await screen.findByRole("button", { name: `Ra bàn ${ten}` });
  nut.focus();
  fireEvent.click(nut);
  return { nut, hop: await screen.findByRole("dialog") };
}
const go = (hop: HTMLElement, nhan: string, v: string) => fireEvent.change(within(hop).getByLabelText(nhan), { target: { value: v } });
const bam = (hop: HTMLElement) => fireEvent.click(within(hop).getByRole("button", { name: /^(Ghi ra bàn|Đang lưu…)$/ }));

describe("màn sản xuất ở quầy — ra bàn", () => {
  it("bày cùng bảng của trạm; mỗi bàn · đơn không bàn có một nút Ra bàn; không nút bấm mẻ · lùi · chuyển · làm sai", async () => {
    mo();
    expect(await screen.findByRole("region", { name: "Trạm cuon" })).toBeTruthy();
    expect(await screen.findByRole("button", { name: "Ra bàn Bàn 3" })).toBeTruthy();
    expect(screen.getByRole("button", { name: "Ra bàn Đơn 77" })).toBeTruthy();
    expect(screen.queryByRole("button", { name: /mẻ|chuyển|làm sai/i })).toBeNull();
  });

  it("ra bàn theo bàn: hộp thoại kê mọi thứ của bàn ấy; chỉ gửi thứ có số; thân đúng hợp đồng; xong thì báo và đọc lại", async () => {
    const goi = mo(() => ({ status: 200, body: { station_job_ids: [5, 6], completed_order_ids: [] } }));
    const { hop } = await moRaBan("Bàn 3");
    expect(within(hop).getByLabelText("Số cái Bánh cuốn · Thịt")).toBeTruthy();
    expect(within(hop).getByLabelText("Số cái Nước chấm")).toBeTruthy();
    const truoc = docBang(goi);
    go(hop, "Số cái Bánh cuốn · Thịt", "2");
    bam(hop);
    expect(await screen.findByText("Đã ghi ra bàn Bàn 3.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([{ method: "POST", path: "/served-marks", body: {
      dining_table_id: 3,
      items: [{ station_code: "cuon", menu_component_id: 101, filling_option_ids: [51], quantity: 2 }],
    } }]);
    await waitFor(() => expect(docBang(goi)).toBeGreaterThan(truoc));
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
  });

  it("ra bàn theo đơn không bàn: gửi sales_order_id, không dining_table_id; nước chấm gửi menu_component_id null", async () => {
    const goi = mo(() => ({ status: 200, body: { station_job_ids: [7], completed_order_ids: [] } }));
    const { hop } = await moRaBan("Đơn 77");
    expect(within(hop).queryByLabelText("Số cái Nước chấm")).toBeNull();
    go(hop, "Số cái Bánh cuốn · Thịt", "1");
    bam(hop);
    await screen.findByText("Đã ghi ra bàn Đơn 77.");
    expect(ghiDi(goi)[0].body).toEqual({
      sales_order_id: 77, items: [{ station_code: "cuon", menu_component_id: 101, filling_option_ids: [51], quantity: 1 }],
    });
    cleanup();
    const goi2 = mo(() => ({ status: 200, body: { station_job_ids: [8], completed_order_ids: [] } }));
    const r = await moRaBan("Bàn 3");
    go(r.hop, "Số cái Nước chấm", "1");
    bam(r.hop);
    await screen.findByText("Đã ghi ra bàn Bàn 3.");
    expect(ghiDi(goi2)[0].body).toEqual({
      dining_table_id: 3, items: [{ station_code: "canh", menu_component_id: null, filling_option_ids: [], quantity: 1 }],
    });
  });

  it("không ô nào có số: không gửi, báo; số sai hình: lỗi ở ô, không gửi", async () => {
    const goi = mo();
    const { hop } = await moRaBan("Bàn 3");
    bam(hop);
    expect(await within(hop).findByText(/Nhập số cái của ít nhất một thứ/)).toBeTruthy();
    for (const v of ["0", "1.5", "-1", "abc"]) {
      go(hop, "Số cái Bánh cuốn · Thịt", v);
      bam(hop);
      await waitFor(() => expect(within(hop).getByLabelText("Số cái Bánh cuốn · Thịt").getAttribute("aria-invalid")).toBe("true"));
    }
    expect(ghiDi(goi)).toEqual([]);
  });

  it("vượt số đã làm (409): báo trong hộp thoại và đọc lại bảng", async () => {
    const goi = mo(() => ({ status: 409, body: { code: "served_quantity_exceeds_made", message: "x" } }));
    const { hop } = await moRaBan("Bàn 3");
    const truoc = docBang(goi);
    go(hop, "Số cái Bánh cuốn · Thịt", "9");
    bam(hop);
    expect(await within(hop).findByText(/vượt số đã làm/i)).toBeTruthy();
    await waitFor(() => expect(docBang(goi)).toBeGreaterThan(truoc));
  });

  it("đơn giao tận nơi (409 delivery_served_mark_undecided): bày lời từ chối của backend", async () => {
    mo(() => ({ status: 409, body: { code: "delivery_served_mark_undecided", message: "x" } }));
    const { hop } = await moRaBan("Đơn 77");
    go(hop, "Số cái Bánh cuốn · Thịt", "1");
    bam(hop);
    expect(await within(hop).findByText(/đơn giao tận nơi/i)).toBeTruthy();
  });

  it("không đứng quầy (403 not_on_counter_duty): báo theo code", async () => {
    mo(() => ({ status: 403, body: { code: "not_on_counter_duty", message: "x" } }));
    const { hop } = await moRaBan("Bàn 3");
    go(hop, "Số cái Bánh cuốn · Thịt", "1");
    bam(hop);
    expect(await within(hop).findByText(/đứng quầy/i)).toBeTruthy();
  });

  it("mất phản hồi: chưa rõ kết quả, không gửi lại; bấm hai lần: một lời gọi", async () => {
    const goi = mo(() => "mat-mang");
    const { hop } = await moRaBan("Bàn 3");
    go(hop, "Số cái Bánh cuốn · Thịt", "1");
    bam(hop);
    expect(await within(hop).findByText(/Chưa xác nhận được kết quả/)).toBeTruthy();
    expect(ghiDi(goi)).toHaveLength(1);
    cleanup();
    let tra!: (v: TraLoi) => void;
    const goi2 = mo(() => new Promise<TraLoi>((r) => { tra = r; }));
    const r = await moRaBan("Bàn 3");
    go(r.hop, "Số cái Bánh cuốn · Thịt", "1");
    bam(r.hop);
    bam(r.hop);
    expect(await within(r.hop).findByRole("button", { name: "Đang lưu…" })).toBeTruthy();
    await act(async () => tra({ status: 200, body: { station_job_ids: [5], completed_order_ids: [] } }));
    expect(ghiDi(goi2)).toHaveLength(1);
  });

  it("màn quầy có lối vào Sản xuất", async () => {
    voiBackend(<QuayPage />, () => ({ status: 599, body: {} }));
    const nav = await screen.findByRole("navigation", { name: "Việc ở quầy" });
    expect(nav.querySelector('a[href="/quay/san-xuat"]')?.textContent).toBe("Sản xuất");
  });
});
