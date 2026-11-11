// Test hồi quy CHAT-11 — Claude viết TRƯỚC khi có code (2026-11-09). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Đứng trên: ADR-140 điểm 1 · 3 · 4 · 5 · 6 · 7 · 9; I-044; ADR-102 điểm 2 (mất phản hồi của lệnh ghi là chưa rõ kết quả).
//
// Hợp đồng Claude chốt (suy ra của phiên trong khung ADR-140, không phải lời quán):
// - File mới `./the-de-xuat.tsx` xuất:
//   * `type CuaGhi = { coDau: boolean; goi: (api: ApiClient, de: { path_params: Record<string, unknown>;
//       body: Record<string, unknown> }) => Promise<ApiResult<unknown>> }` — một dòng của bảng operationId → hàm gọi API sinh sẵn.
//   * `cuaGhiChat: Readonly<Record<string, CuaGhi>>` — bảng của bản chạy, RỖNG (ADR-140 điểm 7: chưa nhóm ghi nào mở).
//     *Sửa 2026-11-09, CHAT-15 lát FE:* bảng nay có bốn cửa giao việc; nội dung bảng kiểm ở `./the-de-xuat-giao-viec.test.tsx`.
//     *Sửa 2026-11-09, CHAT-16 lát FE:* bảng nay có thêm sáu cửa đào tạo; nội dung kiểm ở `./the-de-xuat-dao-tao.test.tsx`.
//     *Sửa 2026-11-10, CHAT-17 lát FE:* bảng nay có thêm năm cửa nguyên liệu; nội dung kiểm ở `./the-de-xuat-nguyen-lieu.test.tsx`.
//   * component thẻ (tên tuỳ người thi công; dòng ở docs/product/4-fe/01-khung-fe.md).
// - `HoiQuan` nhận thêm `nguoiBam?: string` và `cuaGhi?: Readonly<Record<string, CuaGhi>>` (thiếu = `cuaGhiChat`).
//   `OChat` truyền `nguoiBam` = `display_name` của phiên. Mặt khách (không `khung`) không bày thẻ.
// - Thẻ: `role="group"` tên "Đề xuất ghi", nằm trong lượt có `proposal`. Thứ tự: CHU_THE, mỗi dòng một phần tử đúng chữ
//   "<label>: <value> (<tên nguồn>, đọc lúc HH:MM:SS)" (tên nguồn như CHAT-09, tên lạ giữ nguyên; giờ Asia/Ho_Chi_Minh),
//   "Người bấm: <nguoiBam>", rồi nút "Xác nhận ghi" · "Bỏ". Có link màn tay của `khung` (như CHAT-09) trong thẻ.
// - Không nút "Xác nhận ghi" (vẫn có link màn tay) khi: operation_id không có trong bảng → CHU_CHUA_MO; `needs_choice` không rỗng
//   → "Cần chọn trên màn tay: <các trường, nối ", ">."; `lines` rỗng → CHU_THIEU_DONG; không `nguoiBam` → CHU_KHONG_NGUOI;
//   lúc dựng hay lúc bấm đã đủ 10 phút từ `read_at` sớm nhất → CHU_QUA_GIO.
// - Bấm: gọi `goi(api, { path_params, body })` đúng một lần, thân là thân của đề xuất; cửa `coDau` thì `body.submission_code` là
//   UUID do FE sinh khi dựng thẻ (đè dấu có sẵn trong đề xuất). Đang gửi: status "Đang ghi…", không nút bấm được.
//   2xx → status CHU_DA_GHI, hết nút. Từ chối có `code` → alert "Chưa ghi: " + lời (`unauthenticated` dùng `loiTaiKhoan`, mã khác
//   "cửa từ chối (<code>)."), hết nút. Mất phản hồi hay phản hồi lạ → alert CHU_CHUA_RO, dòng thẻ vẫn hiện; `coDau` có nút
//   "Gửi lại" (đúng dấu, đúng thân), không dấu thì hết nút. Không tự gọi lại. Lệnh ghi đã gửi không bị huỷ khi đóng chat.
// - "Bỏ" → CHU_BO, không gọi gì. Lượt hỏi mới hay đóng chat → thẻ chưa bấm thành CHU_HET, thẻ chưa rõ mất "Gửi lại".
//   Một lúc nhiều nhất một nút "Xác nhận ghi". Đổi người: OChat tháo cả hội thoại (CHAT-09), thẻ cũ không còn.
import type { ReactNode } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { call } from "@/lib/api/client";
import { ApiProvider } from "@/lib/api/provider";
import type { Khung, Session } from "@/lib/auth/khung";
import { KHOA_PHIEN } from "@/lib/auth/session";
import { HoiQuan } from "./hoi-quan";
import { OChat } from "./o-chat";
import { cuaGhiChat, type CuaGhi } from "./the-de-xuat";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ replace: vi.fn(), push: vi.fn() }),
  usePathname: () => "/tram",
  useSearchParams: () => new URLSearchParams(),
}));

const BAY_GIO = new Date("2026-11-08T03:01:00Z");
beforeEach(() => {
  vi.useFakeTimers({ toFake: ["Date"], now: BAY_GIO });
  vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", "true");
});
afterEach(() => { cleanup(); vi.useRealTimers(); vi.unstubAllEnvs(); });

const CHU_THE = "Đề xuất, chưa ghi gì. Kiểm từng dòng trước khi bấm.";
const CHU_DANG = "Đang ghi…";
const CHU_DA_GHI = "Đã ghi. Thẻ chưa đọc lại số; xem lại trên màn tay.";
const CHU_CHUA_RO = "Chưa rõ kết quả: chưa nhận được trả lời của quán. Xem lại trên màn tay trước khi làm lại.";
const CHU_BO = "Đã bỏ đề xuất, không ghi gì.";
const CHU_HET = "Đề xuất đã hết hiệu lực, không ghi gì.";
const CHU_QUA_GIO = "Đề xuất đã quá 10 phút từ mốc đọc, không ghi gì. Hỏi lại để có số mới.";
const CHU_CHUA_MO = "Việc này chưa mở cho trợ lý. Làm trên màn tay.";
const CHU_THIEU_DONG = "Đề xuất thiếu dòng để kiểm, không ghi được từ đây.";
const CHU_KHONG_NGUOI = "Chưa biết người bấm, không ghi được từ đây.";
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;

const DOC = "2026-11-08T03:00:05Z"; // 10:00:05 giờ Việt Nam
const deXuatHuy = {
  tool: "huy_bao_nghi_thu",
  operation_id: "cancelLeaveNotice",
  path_params: { leave_notice_id: 7 },
  body: {},
  lines: [{ label: "Báo nghỉ", value: "Ngày 09/11/2026", source: "doc_tong_quan", read_at: DOC }],
  needs_choice: [],
};
const DONG_HUY = "Báo nghỉ: Ngày 09/11/2026 (Tổng quan, đọc lúc 10:00:05)";
const deXuatBao = {
  tool: "bao_nghi_thu",
  operation_id: "createLeaveNotice",
  path_params: {},
  body: { leave_date: "2026-11-10", submission_code: "dau-cua-model" },
  lines: [{ label: "Ngày nghỉ", value: "10/11/2026", source: "doc_bao_nghi", read_at: DOC }],
  needs_choice: [],
};
const DONG_BAO = "Ngày nghỉ: 10/11/2026 (doc_bao_nghi, đọc lúc 10:00:05)";
function traLoi(proposal: unknown) {
  return { answer: "Đã soạn đề xuất, chưa ghi gì.", sources: [], degraded_reason: null, proposal };
}
const thuong = { answer: "Bàn 3 còn thiếu 2 đĩa.", sources: [{ tool: "doc_bang_tram", read_at: DOC }], degraded_reason: null, proposal: null };

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}
const cho = (ms: number) => new Promise((r) => setTimeout(r, ms));

type De = { path_params: Record<string, unknown>; body: Record<string, unknown> };
function bangThu() {
  const nhan: De[] = [];
  const bang: Record<string, CuaGhi> = {
    cancelLeaveNotice: {
      coDau: false,
      goi: (api, de) => {
        nhan.push(structuredClone(de));
        return call(api.POST("/leave-notices/{leave_notice_id}/cancel", {
          params: { path: { leave_notice_id: Number(de.path_params.leave_notice_id) } },
        }));
      },
    },
    createLeaveNotice: {
      coDau: true,
      goi: (api, de) => {
        nhan.push(structuredClone(de));
        return call(api.POST("/leave-notices", { body: de.body as { leave_date: string; submission_code: string } }));
      },
    },
  };
  return { bang, nhan };
}

type Dung = {
  turns: unknown[];
  ghi?: (r: Request) => Promise<Response>;
  bang?: Record<string, CuaGhi>;
  nguoiBam?: string;
  khung?: Khung;
};
function dung(tuy: Dung) {
  const p = { khung: "/tram" as Khung | undefined, nguoiBam: "Người A" as string | undefined, ghi: async () => json({ leave_notice_id: 7 }), ...tuy };
  const hang = [...p.turns];
  const fetch = vi.fn(async (request: Request) => {
    const path = new URL(request.url).pathname;
    if (request.method === "POST" && path === "/api/chat/turns") return json(hang.shift() ?? thuong);
    return p.ghi(request);
  });
  const cay = (mo: boolean) => (
    <ApiProvider fetch={fetch}><HoiQuan mo={mo} khung={p.khung} nguoiBam={p.nguoiBam} cuaGhi={p.bang} /></ApiProvider>
  );
  const view = render(cay(true));
  return {
    fetch,
    mo: (mo: boolean) => view.rerender(cay(mo)),
    ghiGoi: () => fetch.mock.calls.filter(([r]) => new URL(r.url).pathname !== "/api/chat/turns"),
  };
}
function hoi(text = "Huỷ báo nghỉ ngày mai giúp tôi") {
  fireEvent.change(screen.getByRole("textbox", { name: "Câu hỏi" }), { target: { value: text } });
  fireEvent.click(screen.getByRole("button", { name: "Hỏi" }));
}
async function xongHoi() { await waitFor(() => expect(screen.queryByText("Đang hỏi…")).toBeNull()); }
const the = () => screen.getByRole("group", { name: "Đề xuất ghi" });
const cacThe = () => screen.queryAllByRole("group", { name: "Đề xuất ghi" });
const nutGhi = () => screen.queryAllByRole("button", { name: "Xác nhận ghi" });
function coLinkTram(trong: HTMLElement) {
  const link = within(trong).getByRole("link", { name: "Xem Bảng trạm" });
  expect(link.getAttribute("href")).toBe("/tram");
}
function truoc(a: Element, b: Element) {
  expect(a.compareDocumentPosition(b) & Node.DOCUMENT_POSITION_FOLLOWING).toBeTruthy();
}

describe("CHAT-11 thẻ đề xuất ở mặt người làm", () => {
  it("A1 thẻ bày đủ dòng, nguồn, mốc đọc và người bấm trước nút; câu trả lời không tự bấm", async () => {
    const { bang, nhan } = bangThu();
    const { fetch, ghiGoi } = dung({ turns: [traLoi(deXuatHuy)], bang });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    const nut = within(the()).getByRole("button", { name: "Xác nhận ghi" });
    truoc(within(the()).getByText(CHU_THE), nut);
    truoc(within(the()).getByText(DONG_HUY), nut);
    truoc(within(the()).getByText("Người bấm: Người A"), nut);
    expect(within(the()).getByRole("button", { name: "Bỏ" })).toBeTruthy();
    coLinkTram(the());

    const o = screen.getByRole("textbox", { name: "Câu hỏi" });
    expect(document.activeElement).toBe(o);
    fireEvent.keyDown(o, { key: "Enter" });
    await cho(50);
    expect(ghiGoi()).toHaveLength(0);
    expect(nhan).toHaveLength(0);
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it("A2 bấm gọi đúng cửa với đúng tham số đường và thân; bấm lặp chỉ một lần; đã ghi nói chưa đọc lại", async () => {
    let tra!: (r: Response) => void;
    const { bang, nhan } = bangThu();
    const { ghiGoi } = dung({ turns: [traLoi(deXuatHuy)], bang, ghi: () => new Promise((r) => { tra = r; }) });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    const nut = within(the()).getByRole("button", { name: "Xác nhận ghi" });
    fireEvent.click(nut); fireEvent.click(nut);
    await waitFor(() => expect(ghiGoi()).toHaveLength(1));
    expect(within(the()).getByRole("status").textContent).toContain(CHU_DANG);
    for (const b of within(the()).queryAllByRole("button")) expect(b.hasAttribute("disabled")).toBe(true);
    expect(nhan).toEqual([{ path_params: { leave_notice_id: 7 }, body: {} }]);
    const [req] = ghiGoi()[0];
    expect(req.method).toBe("POST");
    expect(new URL(req.url).pathname).toBe("/api/leave-notices/7/cancel");

    await act(async () => { tra(json({ leave_notice_id: 7 })); });
    await waitFor(() => expect(within(the()).getByRole("status").textContent).toContain(CHU_DA_GHI));
    coLinkTram(the());
    expect(within(the()).queryAllByRole("button")).toHaveLength(0);
    await cho(50);
    expect(ghiGoi()).toHaveLength(1);
  });

  it("A2 cửa có dấu: FE sinh dấu khi dựng thẻ; mất phản hồi giữ thẻ, Gửi lại dùng đúng dấu và thân", async () => {
    let lan = 0;
    const { bang, nhan } = bangThu();
    const { ghiGoi } = dung({
      turns: [traLoi(deXuatBao)], bang,
      ghi: async () => { lan += 1; if (lan === 1) throw new Error("mất mạng"); return json({ leave_notice_id: 9 }); },
    });
    hoi("Báo nghỉ ngày 10"); await screen.findByRole("group", { name: "Đề xuất ghi" });
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận ghi" }));
    const canh = await within(the()).findByRole("alert");
    expect(canh.textContent).toContain(CHU_CHUA_RO);
    coLinkTram(the());
    expect(within(the()).getByText(DONG_BAO)).toBeTruthy();
    expect(within(the()).queryByRole("button", { name: "Xác nhận ghi" })).toBeNull();
    await cho(50);
    expect(ghiGoi()).toHaveLength(1);

    fireEvent.click(within(the()).getByRole("button", { name: "Gửi lại" }));
    await waitFor(() => expect(within(the()).getByRole("status").textContent).toContain(CHU_DA_GHI));
    expect(nhan).toHaveLength(2);
    const dau = nhan[0].body.submission_code;
    expect(dau).toMatch(UUID);
    expect(nhan[0]).toEqual({ path_params: {}, body: { leave_date: "2026-11-10", submission_code: dau } });
    expect(nhan[1]).toEqual(nhan[0]);
    const than = await Promise.all(ghiGoi().map(([r]) => r.clone().json()));
    expect(than).toEqual([nhan[0].body, nhan[0].body]);
  });

  it.each([
    ["mất kết nối", async (): Promise<Response> => { throw new Error("mất mạng"); }],
    ["phản hồi lạ", async () => new Response("bad gateway", { status: 502 })],
  ])("A2 cửa không dấu, %s: chưa rõ kết quả, khoá thẻ, không gọi lại", async (_ten, ghi) => {
    const { bang } = bangThu();
    const { ghiGoi } = dung({ turns: [traLoi(deXuatHuy)], bang, ghi });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận ghi" }));
    expect((await within(the()).findByRole("alert")).textContent).toContain(CHU_CHUA_RO);
    coLinkTram(the());
    expect(within(the()).getByText(DONG_HUY)).toBeTruthy();
    expect(within(the()).queryAllByRole("button")).toHaveLength(0);
    await cho(50);
    expect(ghiGoi()).toHaveLength(1);
  });

  it.each([
    [422, "leave_notice_cancel_closed", "Chưa ghi: cửa từ chối (leave_notice_cancel_closed)."],
    [403, "owner_only", "Chưa ghi: cửa từ chối (owner_only)."],
    [401, "unauthenticated", "Chưa ghi: Phiên đăng nhập đã hết. Đăng nhập lại."],
  ])("A2 cửa từ chối %s %s: nói chưa ghi, khoá thẻ, một lần gọi", async (status, code, chu) => {
    const { bang } = bangThu();
    const { ghiGoi } = dung({ turns: [traLoi(deXuatHuy)], bang, ghi: async () => json({ code }, status) });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận ghi" }));
    expect((await within(the()).findByRole("alert")).textContent).toContain(chu);
    coLinkTram(the());
    expect(within(the()).queryAllByRole("button")).toHaveLength(0);
    await cho(50);
    expect(ghiGoi()).toHaveLength(1);
  });

  it("A2 Bỏ không ghi gì", async () => {
    const { bang, nhan } = bangThu();
    const { ghiGoi } = dung({ turns: [traLoi(deXuatHuy)], bang });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    fireEvent.click(within(the()).getByRole("button", { name: "Bỏ" }));
    expect(within(the()).getByText(CHU_BO, { exact: false })).toBeTruthy();
    expect(within(the()).queryAllByRole("button")).toHaveLength(0);
    await cho(50);
    expect(ghiGoi()).toHaveLength(0);
    expect(nhan).toHaveLength(0);
  });

  it.each([
    ["cửa chưa có trong bảng FE", { ...deXuatHuy, operation_id: "acknowledgeLeaveNotice" }, "Người A", CHU_CHUA_MO],
    ["còn trường cần chọn", { ...deXuatHuy, needs_choice: ["assignee_person_id"] }, "Người A", "Cần chọn trên màn tay: assignee_person_id."],
    ["không dòng để kiểm", { ...deXuatHuy, lines: [] }, "Người A", CHU_THIEU_DONG],
    ["chưa biết người bấm", deXuatHuy, undefined, CHU_KHONG_NGUOI],
    ["mốc đọc sớm nhất đã quá 10 phút", {
      ...deXuatHuy,
      lines: [...deXuatHuy.lines, { label: "Bàn", value: "3", source: "doc_bang_tram", read_at: "2026-11-08T02:50:59Z" }],
    }, "Người A", CHU_QUA_GIO],
  ])("A3 %s: thẻ không có nút ghi, có lời và link màn tay", async (_ten, proposal, nguoiBam, chu) => {
    const { bang, nhan } = bangThu();
    const { ghiGoi } = dung({ turns: [traLoi(proposal)], bang, nguoiBam });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).getByText(chu, { exact: false })).toBeTruthy();
    expect(nutGhi()).toHaveLength(0);
    coLinkTram(the());
    await cho(50);
    expect(ghiGoi()).toHaveLength(0);
    expect(nhan).toHaveLength(0);
  });

  it("A3 đủ 10 phút từ mốc đọc lúc bấm: không ghi, thẻ bị loại", async () => {
    const { bang, nhan } = bangThu();
    const { ghiGoi } = dung({ turns: [traLoi(deXuatHuy)], bang });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    vi.setSystemTime(new Date("2026-11-08T03:10:05Z"));
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận ghi" }));
    expect(await within(the()).findByText(CHU_QUA_GIO, { exact: false })).toBeTruthy();
    expect(nutGhi()).toHaveLength(0);
    await cho(50);
    expect(ghiGoi()).toHaveLength(0);
    expect(nhan).toHaveLength(0);
  });

  it("A4 lượt mới loại thẻ cũ; một lúc chỉ một nút Xác nhận ghi", async () => {
    const { bang } = bangThu();
    const { ghiGoi } = dung({
      turns: [traLoi(deXuatHuy), traLoi({ ...deXuatHuy, path_params: { leave_notice_id: 8 } }), thuong],
      bang,
    });
    hoi("Câu một"); await screen.findByRole("group", { name: "Đề xuất ghi" }); await xongHoi();
    hoi("Câu hai"); await waitFor(() => expect(cacThe()).toHaveLength(2)); await xongHoi();
    expect(nutGhi()).toHaveLength(1);
    expect(within(cacThe()[0]).getByText(CHU_HET, { exact: false })).toBeTruthy();
    expect(within(cacThe()[1]).getByRole("button", { name: "Xác nhận ghi" })).toBeTruthy();
    hoi("Câu ba"); await screen.findByText(thuong.answer); await xongHoi();
    expect(nutGhi()).toHaveLength(0);
    for (const t of cacThe()) expect(within(t).getByText(CHU_HET, { exact: false })).toBeTruthy();
    expect(ghiGoi()).toHaveLength(0);
  });

  it("A4 đóng chat loại thẻ chưa bấm; mở lại không còn nút", async () => {
    const { bang } = bangThu();
    const { mo, ghiGoi } = dung({ turns: [traLoi(deXuatHuy)], bang });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    mo(false); mo(true);
    expect(nutGhi()).toHaveLength(0);
    expect(within(the()).getByText(CHU_HET, { exact: false })).toBeTruthy();
    expect(ghiGoi()).toHaveLength(0);
  });

  it("A4 đang ghi mà đóng chat: lệnh ghi không bị huỷ, mở lại thấy kết quả", async () => {
    let tra!: (r: Response) => void;
    let tinHieu!: AbortSignal;
    const { bang } = bangThu();
    const { mo } = dung({
      turns: [traLoi(deXuatHuy)], bang,
      ghi: (r) => { tinHieu = r.signal; return new Promise((ok) => { tra = ok; }); },
    });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận ghi" }));
    await waitFor(() => expect(tinHieu).toBeDefined());
    mo(false);
    expect(tinHieu.aborted).toBe(false);
    await act(async () => { tra(json({ leave_notice_id: 7 })); });
    mo(true);
    await waitFor(() => expect(within(the()).getByRole("status").textContent).toContain(CHU_DA_GHI));
  });

  it("A4 chưa rõ kết quả rồi có lượt mới: không còn Gửi lại", async () => {
    const { bang } = bangThu();
    const { ghiGoi } = dung({ turns: [traLoi(deXuatBao), thuong], bang, ghi: async () => { throw new Error("mất mạng"); } });
    hoi("Báo nghỉ ngày 10"); await screen.findByRole("group", { name: "Đề xuất ghi" }); await xongHoi();
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận ghi" }));
    await within(the()).findByRole("button", { name: "Gửi lại" });
    hoi("Câu hai"); await screen.findByText(thuong.answer); await xongHoi();
    expect(screen.queryByRole("button", { name: "Gửi lại" })).toBeNull();
    expect(within(the()).getByText(CHU_CHUA_RO, { exact: false })).toBeTruthy();
    expect(ghiGoi()).toHaveLength(1);
  });
});

describe("CHAT-11 bảng cửa của bản chạy và mặt khách", () => {
  // Sửa 2026-11-09, CHAT-15 lát FE: nhóm giao việc đã mở; bảng chỉ còn được chứa các cửa của nhóm đã mở.
  // Sửa 2026-11-09, CHAT-16 lát FE: nhóm đào tạo đã mở, sáu cửa đứng sau bốn cửa giao việc.
  // Sửa 2026-11-10, CHAT-17 lát FE: nhóm nguyên liệu đã mở, năm cửa đứng sau sáu cửa đào tạo.
  it("A5 bảng cửa của bản chạy chỉ có các nhóm đã mở", () => {
    expect(Object.keys(cuaGhiChat)).toEqual(["createAssignedTask", "updateAssignedTask", "hideAssignedTask", "markAssignedTask",
      "attachAssignedTaskGuide", "updateAssignedTaskGuide", "hideAssignedTaskGuide",
      "createTrainingRecord", "updateTrainingRecord", "hideTrainingRecord",
      "createSupplyItem", "setSupplyItemPurchaseUnit", "createSupplyDayEntry", "updateSupplyDayEntry", "setSupplyItemReminderRatio"]);
  });

  it("A5 HoiQuan không truyền cuaGhi dùng bảng bản chạy: thẻ hiện, không nút ghi", async () => {
    const { ghiGoi } = dung({ turns: [traLoi(deXuatHuy)] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).getByText(CHU_CHUA_MO, { exact: false })).toBeTruthy();
    expect(within(the()).getByText(DONG_HUY)).toBeTruthy();
    expect(nutGhi()).toHaveLength(0);
    coLinkTram(the());
    expect(ghiGoi()).toHaveLength(0);
  });

  it("A5 mặt khách không bày thẻ đề xuất", async () => {
    const { bang } = bangThu();
    const { ghiGoi } = dung({ turns: [traLoi(deXuatHuy)], bang, khung: undefined, nguoiBam: undefined });
    hoi(); await screen.findByText("Đã soạn đề xuất, chưa ghi gì."); await xongHoi();
    expect(cacThe()).toHaveLength(0);
    expect(nutGhi()).toHaveLength(0);
    expect(ghiGoi()).toHaveLength(0);
  });
});

// ——— Mức OChat: người bấm lấy từ phiên, đổi người loại thẻ ———

const nguoiA: Session = {
  person_id: 1, display_name: "Người A", role_code: "trang_banh", is_owner: false, must_change_password: false, counter_duty_id: 0,
};
const nguoiB: Session = { ...nguoiA, person_id: 2, display_name: "Người B" };

function dungOChat(children: ReactNode, phien: () => Session) {
  const fetch = vi.fn(async (request: Request) => {
    const path = new URL(request.url).pathname;
    if (request.method === "GET" && path === "/api/sessions/current") return json(phien());
    if (request.method === "GET" && path.startsWith("/api/station-messages/")) {
      return json({ messages: [], next_before_id: null, read_at: "2026-11-08T10:00:00+07:00", poll_interval_seconds: 20 });
    }
    if (request.method === "GET" && path === "/api/assigned-tasks/mine") return json({ assigned_tasks: [] });
    if (request.method === "GET" && path === "/api/dining-tables") return json({ tables: [] });
    if (request.method === "GET" && path === "/api/leave-notices/mine") return json({ leave_notices: [] });
    if (request.method === "POST" && path === "/api/chat/turns") return json(traLoi(deXuatHuy));
    return json({ code: "unexpected_request" }, 500);
  });
  render(<ApiProvider fetch={fetch}>{children}</ApiProvider>);
  return fetch;
}
async function moHoiQuan() {
  fireEvent.click(await screen.findByRole("button", { name: "Mở trò chuyện" }));
  fireEvent.click(screen.getByRole("tab", { name: "Hỏi quán" }));
}

describe("CHAT-11 OChat", () => {
  it("A6 người bấm lấy từ phiên; đổi người thì thẻ cũ không còn", async () => {
    let nguoi = nguoiA;
    function DoiNguoi() {
      const queries = useQueryClient();
      return <button onClick={() => { nguoi = nguoiB; void queries.invalidateQueries({ queryKey: KHOA_PHIEN }); }}>Đổi người</button>;
    }
    const fetch = dungOChat(<><OChat khung="/tram" /><DoiNguoi /></>, () => nguoi);
    await moHoiQuan();
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).getByText("Người bấm: Người A")).toBeTruthy();
    expect(within(the()).getByText(CHU_CHUA_MO, { exact: false })).toBeTruthy();

    fireEvent.click(screen.getByRole("button", { name: "Đổi người" }));
    await waitFor(() => expect(cacThe()).toHaveLength(0));
    await moHoiQuan();
    expect(cacThe()).toHaveLength(0);
    expect(screen.queryByText("Người bấm: Người A")).toBeNull();
    const ghi = fetch.mock.calls.filter(([r]) => r.method !== "GET" && new URL(r.url).pathname !== "/api/chat/turns");
    expect(ghi).toHaveLength(0);
  });
});
