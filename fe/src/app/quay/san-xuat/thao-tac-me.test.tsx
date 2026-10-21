// Test hồi quy P4-09 phần còn lại — bấm mẻ · lùi mẻ · chuyển · ghi làm sai ở màn quầy. Claude viết TRƯỚC khi có code (L2).
// Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm. Giữ (ADR-090, 07-san-xuat-theo-me.md §3): POS là nơi duy nhất ghi
// tiến độ; mọi mã việc · mã mẻ lấy từ GET /counter/station-jobs (T-217), không suy từ bảng gom; nút chỉ hiện theo đúng
// trạng thái · cờ backend trả (việc `pending` ⇒ bấm mẻ; mẻ `has_served_units` ⇒ không lùi; `transferable` ⇒ chuyển; việc
// đơn huỷ chưa có ghi chú ⇒ ghi làm sai); ghi xong đọc lại cả việc trạm lẫn bảng; lời từ chối theo code; một lần bấm một lời gọi.
import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";

import { ApiProvider } from "@/lib/api/provider";

import { bangMau, banMau, menuMau, ungVienMau, viecMau } from "./mau-san-xuat";
import Page from "./page";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ push: vi.fn(), replace: vi.fn() }),
  usePathname: () => "/quay/san-xuat",
  useSearchParams: () => new URLSearchParams(),
}));
afterEach(cleanup);

type Goi = { method: string; path: string; body: unknown };
type TraLoi = { status: number; body?: unknown } | "mat-mang";
type Ghi = (g: Goi) => TraLoi | Promise<TraLoi>;
function mo(ghi: Ghi = () => ({ status: 599, body: { code: "khong_co_trong_hop_dong" } }),
  doc: { viec?: TraLoi; ungVien?: TraLoi } = {}) {
  const goi: Goi[] = [];
  const fetch = async (req: Request) => {
    const text = await req.text();
    const g: Goi = { method: req.method, path: new URL(req.url).pathname.replace(/^\/api/, ""), body: text ? JSON.parse(text) : undefined };
    goi.push(g);
    let r: TraLoi = { status: 599, body: { code: "khong_co_trong_hop_dong" } };
    if (g.path === "/production-board") r = { status: 200, body: bangMau };
    else if (g.path === "/dining-tables") r = { status: 200, body: banMau };
    else if (g.path === "/menu") r = { status: 200, body: menuMau };
    else if (g.path === "/counter/station-jobs") r = doc.viec ?? { status: 200, body: viecMau };
    else if (/^\/station-jobs\/\d+\/transfer-candidates$/.test(g.path)) r = doc.ungVien ?? { status: 200, body: ungVienMau };
    else if (g.method === "POST") r = await ghi(g);
    if (r === "mat-mang") throw new TypeError("fetch failed");
    return new Response(JSON.stringify(r.body), { status: r.status, headers: { "content-type": "application/json" } });
  };
  render(<ApiProvider fetch={fetch}><Page /></ApiProvider>);
  return goi;
}
const ghiDi = (g: Goi[]) => g.filter((x) => x.method === "POST");
const dem = (g: Goi[], path: string) => g.filter((x) => x.method === "GET" && x.path === path).length;
async function moHop(nut: string) {
  fireEvent.click(await screen.findByRole("button", { name: nut }));
  return screen.findByRole("dialog");
}
const bam = (hop: HTMLElement, nut: string | RegExp) => fireEvent.click(within(hop).getByRole("button", { name: nut }));
const loi = { status: 409, body: { message: "x" } };
const voiMa = (code: string, status = 409): TraLoi => ({ ...loi, status, body: { code, message: "x" } });

describe("màn sản xuất ở quầy — nút theo đúng trạng thái backend trả", () => {
  it("bấm mẻ theo hàng còn việc chờ; lùi theo mẻ, khoá mẻ đã ra bàn; chuyển và ghi làm sai chỉ theo cờ", async () => {
    mo();
    expect(await screen.findByRole("button", { name: "Bấm mẻ Bánh cuốn · Thịt" })).toBeTruthy();
    expect(screen.queryByRole("button", { name: "Bấm mẻ Nước chấm" })).toBeNull();
    expect((screen.getByRole("button", { name: "Lùi mẻ 900" }) as HTMLButtonElement).disabled).toBe(false);
    expect((screen.getByRole("button", { name: "Lùi mẻ 901" }) as HTMLButtonElement).disabled).toBe(true);
    expect((screen.getByRole("button", { name: "Lùi mẻ 902" }) as HTMLButtonElement).disabled).toBe(false);
    expect(screen.getByRole("button", { name: "Chuyển việc 20" })).toBeTruthy();
    for (const id of [11, 12, 13, 14, 21]) expect(screen.queryByRole("button", { name: `Chuyển việc ${id}` })).toBeNull();
    expect(screen.getByRole("button", { name: "Ghi làm sai việc 20" })).toBeTruthy();
    for (const id of [11, 12, 13, 14, 21]) expect(screen.queryByRole("button", { name: `Ghi làm sai việc ${id}` })).toBeNull();
  });

  it("đọc việc trạm lỗi (403 not_on_counter_duty): báo theo code, không nút thao tác mẻ, bảng vẫn bày", async () => {
    mo(undefined, { viec: voiMa("not_on_counter_duty", 403) });
    expect(await screen.findByText(/đứng quầy/i)).toBeTruthy();
    expect(await screen.findByRole("region", { name: "Trạm cuon" })).toBeTruthy();
    expect(screen.queryByRole("button", { name: /^(Bấm mẻ|Lùi mẻ|Chuyển việc|Ghi làm sai)/ })).toBeNull();
  });
});

describe("bấm mẻ", () => {
  it("hộp thoại kê việc chờ của hàng; chưa chọn thì không gửi; gửi mã tăng dần; xong báo, đọc lại việc trạm và bảng", async () => {
    const goi = mo(() => ({ status: 201, body: { production_batch_id: 950, made_at: "2026-10-20T02:31:00Z", station_job_ids: [11, 12] } }));
    const hop = await moHop("Bấm mẻ Bánh cuốn · Thịt");
    expect(within(hop).queryByLabelText("Bàn 3 · việc 13")).toBeNull();
    bam(hop, "Ghi mẻ");
    expect(await within(hop).findByText("Chọn ít nhất một việc.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([]);
    fireEvent.click(within(hop).getByLabelText("Đơn 77 · việc 12"));
    fireEvent.click(within(hop).getByLabelText("Bàn 3 · việc 11"));
    const viec = dem(goi, "/counter/station-jobs"), bang = dem(goi, "/production-board");
    bam(hop, "Ghi mẻ");
    expect(await screen.findByText("Đã ghi mẻ 950.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([{ method: "POST", path: "/production-batches", body: { station_job_ids: [11, 12] } }]);
    await waitFor(() => expect(dem(goi, "/counter/station-jobs")).toBeGreaterThan(viec));
    await waitFor(() => expect(dem(goi, "/production-board")).toBeGreaterThan(bang));
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
  });

  it("việc đã đổi trạng thái (409) hay không còn (404): báo và đọc lại việc trạm", async () => {
    for (const r of [voiMa("station_job_transition_not_allowed"), voiMa("station_job_not_found", 404)]) {
      const goi = mo(() => r);
      const hop = await moHop("Bấm mẻ Bánh cuốn · Thịt");
      fireEvent.click(within(hop).getByLabelText("Bàn 3 · việc 11"));
      const truoc = dem(goi, "/counter/station-jobs");
      bam(hop, "Ghi mẻ");
      expect(await within(hop).findByText(/Đang đọc lại/)).toBeTruthy();
      await waitFor(() => expect(dem(goi, "/counter/station-jobs")).toBeGreaterThan(truoc));
      cleanup();
    }
  });

  it("mất phản hồi: chưa rõ kết quả, không tự gửi lại; bấm hai lần: một lời gọi", async () => {
    const goi = mo(() => "mat-mang");
    const hop = await moHop("Bấm mẻ Bánh cuốn · Thịt");
    fireEvent.click(within(hop).getByLabelText("Bàn 3 · việc 11"));
    bam(hop, "Ghi mẻ");
    expect(await within(hop).findByText(/Chưa xác nhận được kết quả/)).toBeTruthy();
    expect(ghiDi(goi)).toHaveLength(1);
    cleanup();
    let tra!: (v: TraLoi) => void;
    const goi2 = mo(() => new Promise<TraLoi>((r) => { tra = r; }));
    const hop2 = await moHop("Bấm mẻ Bánh cuốn · Thịt");
    fireEvent.click(within(hop2).getByLabelText("Bàn 3 · việc 11"));
    bam(hop2, "Ghi mẻ");
    bam(hop2, /^(Ghi mẻ|Đang lưu…)$/);
    expect(await within(hop2).findByRole("button", { name: "Đang lưu…" })).toBeTruthy();
    await act(async () => tra({ status: 201, body: { production_batch_id: 951, made_at: "2026-10-20T02:31:00Z", station_job_ids: [11] } }));
    expect(ghiDi(goi2)).toHaveLength(1);
  });
});

describe("lùi mẻ", () => {
  it("phải xác nhận; huỷ thì không gửi; xác nhận gửi đúng mã mẻ, không thân; xong báo và đọc lại", async () => {
    const goi = mo(() => ({ status: 200, body: { production_batch_id: 900, rolled_back_at: "2026-10-20T02:32:00Z", station_job_ids: [13] } }));
    let hop = await moHop("Lùi mẻ 900");
    bam(hop, "Huỷ");
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    expect(ghiDi(goi)).toEqual([]);
    hop = await moHop("Lùi mẻ 900");
    const truoc = dem(goi, "/counter/station-jobs");
    bam(hop, "Xác nhận lùi mẻ");
    expect(await screen.findByText("Đã lùi mẻ 900.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([{ method: "POST", path: "/production-batches/900/rollback", body: undefined }]);
    await waitFor(() => expect(dem(goi, "/counter/station-jobs")).toBeGreaterThan(truoc));
  });

  it("lời từ chối theo code: đã ra bàn · có ghi làm sai · đã lùi", async () => {
    for (const [code, chu] of [["production_batch_has_served_units", /đã ra bàn/i], ["station_job_has_wrong_make_note", /làm sai/i],
      ["production_batch_already_rolled_back", /đã lùi/i]] as const) {
      mo(() => voiMa(code));
      const hop = await moHop("Lùi mẻ 902");
      bam(hop, "Xác nhận lùi mẻ");
      expect(await within(hop).findByText(chu)).toBeTruthy();
      cleanup();
    }
  });
});

describe("chuyển việc của đơn huỷ", () => {
  it("đọc ứng viên của đúng việc; chưa chọn thì không gửi; gửi một cặp; xong báo và đọc lại", async () => {
    const goi = mo(() => ({ status: 201, body: { station_job_transfer_ids: [300] } }));
    const hop = await moHop("Chuyển việc 20");
    expect(goi.some((g) => g.method === "GET" && g.path === "/station-jobs/20/transfer-candidates")).toBe(true);
    expect(await within(hop).findByLabelText("Bàn 3 · việc 11")).toBeTruthy();
    bam(hop, "Chuyển");
    expect(await within(hop).findByText("Chọn việc nhận.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([]);
    fireEvent.click(within(hop).getByLabelText("Đơn 77 · việc 12"));
    const truoc = dem(goi, "/counter/station-jobs");
    bam(hop, "Chuyển");
    expect(await screen.findByText("Đã chuyển việc 20 sang việc 12.")).toBeTruthy();
    expect(ghiDi(goi)).toEqual([{ method: "POST", path: "/station-job-transfers",
      body: { transfers: [{ from_station_job_id: 20, to_station_job_id: 12 }] } }]);
    await waitFor(() => expect(dem(goi, "/counter/station-jobs")).toBeGreaterThan(truoc));
  });

  it("không ứng viên: báo, không gửi được", async () => {
    const goi = mo(undefined, { ungVien: { status: 200, body: { station_job_id: 20, candidates: [] } } });
    const hop = await moHop("Chuyển việc 20");
    expect(await within(hop).findByText("Không có việc nào đang chờ để nhận.")).toBeTruthy();
    const nut = within(hop).queryByRole("button", { name: "Chuyển" }) as HTMLButtonElement | null;
    if (nut) { expect(nut.disabled).toBe(true); fireEvent.click(nut); }
    expect(ghiDi(goi)).toEqual([]);
  });

  it("đích không còn chờ (409 transfer_target_not_waiting): báo và đọc lại", async () => {
    const goi = mo(() => voiMa("transfer_target_not_waiting"));
    const hop = await moHop("Chuyển việc 20");
    fireEvent.click(await within(hop).findByLabelText("Bàn 3 · việc 11"));
    const truoc = dem(goi, "/counter/station-jobs");
    bam(hop, "Chuyển");
    expect(await within(hop).findByText(/Đang đọc lại/)).toBeTruthy();
    await waitFor(() => expect(dem(goi, "/counter/station-jobs")).toBeGreaterThan(truoc));
  });
});

describe("ghi bánh làm sai", () => {
  it("ghi chú bỏ trống thì không gửi trường note; có chữ thì gửi nguyên văn; xong báo và đọc lại", async () => {
    const goi = mo((g) => ({ status: 201, body: { wrong_make_note_id: 6, station_job_id: 20, note: (g.body as { note?: string }).note ?? null } }));
    let hop = await moHop("Ghi làm sai việc 20");
    bam(hop, "Ghi làm sai");
    expect(await screen.findByText("Đã ghi làm sai việc 20.")).toBeTruthy();
    expect(ghiDi(goi)[0]).toEqual({ method: "POST", path: "/wrong-make-notes", body: { station_job_id: 20 } });
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    hop = await moHop("Ghi làm sai việc 20");
    fireEvent.change(within(hop).getByLabelText("Ghi chú (không bắt buộc)"), { target: { value: " rơi xuống đất " } });
    bam(hop, "Ghi làm sai");
    await screen.findAllByText("Đã ghi làm sai việc 20.");
    await waitFor(() => expect(ghiDi(goi)).toHaveLength(2));
    expect(ghiDi(goi)[1].body).toEqual({ station_job_id: 20, note: " rơi xuống đất " });
  });

  it("ghi chú chỉ có khoảng trắng: lỗi ở ô, không gửi", async () => {
    const goi = mo();
    const hop = await moHop("Ghi làm sai việc 20");
    const o = within(hop).getByLabelText("Ghi chú (không bắt buộc)");
    fireEvent.change(o, { target: { value: "   " } });
    bam(hop, "Ghi làm sai");
    await waitFor(() => expect(o.getAttribute("aria-invalid")).toBe("true"));
    expect(ghiDi(goi)).toEqual([]);
  });

  it("không được ghi (409 wrong_make_note_not_allowed): báo theo code và đọc lại", async () => {
    const goi = mo(() => voiMa("wrong_make_note_not_allowed"));
    const hop = await moHop("Ghi làm sai việc 20");
    const truoc = dem(goi, "/counter/station-jobs");
    bam(hop, "Ghi làm sai");
    expect(await within(hop).findByText(/Đang đọc lại/)).toBeTruthy();
    await waitFor(() => expect(dem(goi, "/counter/station-jobs")).toBeGreaterThan(truoc));
  });
});
