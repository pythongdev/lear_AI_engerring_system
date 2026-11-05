// CHAT-32 — mẫu báo nghỉ trong ô chat (ADR-138 điểm 2 · 3 · 6 · 7, I-039). Claude viết trước, đỏ trước code.
//
// Hợp đồng màn Claude chốt cho bước này (2026-11-04) — test đọc đúng các tên dưới đây:
// - Bảng "Trò chuyện" của `OChat` có `role="tablist"` `aria-label="Mục trò chuyện"` với hai `role="tab"`: "Tin nhắn" (chọn sẵn,
//   chứa `HopTin` như CHAT-14) và "Báo nghỉ". Phần báo nghỉ chỉ dựng và chỉ đọc khi thẻ "Báo nghỉ" được chọn; chưa chọn thì
//   không gọi đường `/leave-notices*` nào. Mỗi thẻ điều khiển một `role="tabpanel"`; thẻ không chọn thì panel ẩn. Đổi thẻ
//   không làm mất nháp của hộp tin.
// - "Hôm nay" là ngày lịch Asia/Ho_Chi_Minh của đồng hồ máy. Ngày bày dạng dd/mm/yyyy, đọc thẳng từ chuỗi YYYY-MM-DD.
// - Khung "/tram" và "/quay" (người làm báo cho chính mình):
//   form `aria-label="Soạn báo nghỉ"`, ô ngày `<input type="date">` nhãn "Ngày nghỉ", `min` = hôm nay. Nút "Xem lại báo nghỉ"
//   chỉ bấm được khi đã chọn ngày ≥ hôm nay; ngày đã qua thì hiện "Chọn ngày từ hôm nay trở đi.".
//   Thẻ `<section aria-label="Kiểm báo nghỉ trước khi gửi">`: "Ngày nghỉ: dd/mm/yyyy", "Báo cho: Chủ quán", "Dự kiến: Báo trước"
//   khi ngày nghỉ − hôm nay ≥ 3 ngày, còn lại "Dự kiến: Đột xuất", và câu "Loại chính thức do quán ghi khi nhận báo nghỉ.";
//   nút "Xác nhận báo nghỉ" và "Sửa lại". Chỉ "Xác nhận báo nghỉ" gọi `POST /leave-notices` với đúng
//   `{ submission_code, leave_date }`. Bảng báo nghỉ không có chữ "duyệt", "được nghỉ", "lương", "trừ".
//   Gửi xong (201 hay 200): `role="status"` "Đã gửi báo nghỉ ngày dd/mm/yyyy.", thẻ đóng, ô ngày trống, đọc lại danh sách.
//   Mất phản hồi: alert "Chưa rõ báo nghỉ đã tới chưa. Bấm Gửi lại để gửi đúng báo nghỉ này.", thẻ giữ, không "Sửa lại", nút
//   "Gửi lại" gửi đúng thân và dấu cũ; bấm hai lần khi đang gửi chỉ gửi một lần.
//   Bị từ chối: thẻ đóng, ngày giữ, lần sau dấu mới; lời theo mã: `leave_date_in_past` "Ngày này đã qua. Chọn ngày từ hôm nay
//   trở đi."; `leave_notice_day_taken` "Bạn đã báo nghỉ ngày này rồi."; `leave_day_attendance_ticked` "Ngày này đã chấm có đi
//   làm. Báo chủ quán nếu cần đổi."; `submission_code_conflict` "Dấu gửi đã dùng cho báo nghỉ khác. Bấm Xem lại để gửi lần
//   mới."; `unauthenticated` "Phiên đã hết. Hãy đăng nhập lại."; mã khác của hợp đồng "Chưa gửi được báo nghỉ ({code}).". Mã ngoài
//   hợp đồng là `unexpected` của `call`, tức chưa rõ kết quả (sửa 2026-11-04 khi duyệt, Codex phát hiện đúng).
//   Danh sách `<ul aria-label="Báo nghỉ của tôi">` từ `GET /leave-notices/mine`: mỗi `<li>` có "Ngày dd/mm/yyyy", loại theo
//   `notice_kind` của backend ("Báo trước" · "Đột xuất"), trạng thái "Đã huỷ" khi `cancelled_at`, không thì "Chủ quán đã biết"
//   khi `acknowledged_at`, không thì "Chủ quán chưa xem"; nút "Huỷ báo nghỉ" chỉ khi `can_cancel`. Rỗng: "Chưa có báo nghỉ.".
//   Đọc lỗi: alert "Chưa đọc được báo nghỉ." và nút "Đọc lại báo nghỉ".
// - Khung "/chu-quan" (chủ quán): không có form tự báo, không đọc `/leave-notices/mine`. Đọc
//   `GET /leave-notices?from=<hôm nay>&to=<hôm nay + 30 ngày>`, danh sách `<ul aria-label="Báo nghỉ của nhân viên">`: mỗi `<li>`
//   có `person_name`, "Ngày …", loại, trạng thái như trên; nút "Đã biết" khi chưa có `acknowledged_at`; nút "Huỷ" khi
//   `can_cancel`. Rỗng: "Chưa có báo nghỉ.".
// - Huỷ (`POST /leave-notices/{id}/cancel`) và đã biết (`POST /leave-notices/{id}/acknowledge`) không gửi thân; xong thì đọc lại.
//   Từ chối: `leave_notice_cancel_closed` "Đã tới ngày nghỉ nên bạn không tự huỷ được. Báo chủ quán."; `leave_notice_not_found`
//   "Không tìm thấy báo nghỉ này."; `owner_only` "Chỉ chủ quán ghi được việc này."; mã khác "Chưa ghi được ({code}).".
//   Mất phản hồi: alert "Chưa rõ kết quả. Đã đọc lại danh sách.", đọc lại, không tự gửi lần hai.
// - Tên người, "Ngày dd/mm/yyyy", loại và trạng thái mỗi thứ là một phần tử riêng chỉ chứa đúng chữ ấy.
// - Khoá query: ["leave-notices", "mine", person_id] và ["leave-notices", "range", from, to]; ghi xong `invalidateQueries`
//   khoá ["leave-notices"]. Không localStorage, sessionStorage; ngày, thẻ, dấu chỉ ở state của component.
import { useEffect, type ReactNode } from "react";
import { QueryClient, useQueryClient } from "@tanstack/react-query";
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import type { components } from "@/lib/api/schema";
import { ApiProvider } from "@/lib/api/provider";
import type { Khung, Session } from "@/lib/auth/khung";
import { KHOA_PHIEN } from "@/lib/auth/session";
import { OChat } from "./o-chat";

vi.mock("@/lib/realtime/tin-hieu", async (goc) => ({
  ...(await goc<typeof import("@/lib/realtime/tin-hieu")>()),
  TinHieuProvider: ({ children }: { children: ReactNode }) => children,
  BaoMatKetNoi: () => null,
}));

type Nghi = components["schemas"]["LeaveNotice"];

const lan: Session = {
  person_id: 5, display_name: "Lan", role_code: "canh_don_ban", is_owner: false,
  must_change_password: false, counter_duty_id: 0,
};
const hoa: Session = { ...lan, person_id: 6, display_name: "Hoa", role_code: "trang_banh" };
const pos: Session = { ...lan, person_id: 1, display_name: "Minh", role_code: "quay", counter_duty_id: 9 };
const chu: Session = { ...lan, person_id: 2, display_name: "Chủ", role_code: "owner", is_owner: true };

// 00:30 ngày 05/11 giờ Việt Nam = 17:30 ngày 04/11 UTC: "hôm nay" phải là 05/11.
const BAY_GIO = new Date("2026-11-05T00:30:00+07:00");

function nghi(id: number, p: Partial<Nghi> = {}): Nghi {
  return {
    leave_notice_id: id, person_id: 5, person_name: "Lan", leave_date: "2026-11-10", notice_kind: "bao_truoc",
    created_at: "2026-11-04T09:00:00+07:00", acknowledged_at: null, acknowledged_by_person_id: null,
    cancelled_at: null, cancelled_by_person_id: null, can_cancel: true, ...p,
  };
}
const cuaToi = (leave_notices: Nghi[]) => ({ leave_notices, next_before_id: null, read_at: "2026-11-05T00:30:00+07:00" });
const theoKhoang = (leave_notices: Nghi[]) => ({ leave_notices, read_at: "2026-11-05T00:30:00+07:00" });

type Goi = { method: string; path: string; search: string; body: unknown };
type TraLoi = Response | Promise<Response> | "mat";
type CauHinh = {
  phien: () => Session;
  mine?: (s: Session) => TraLoi;
  range?: () => TraLoi;
  bao?: (body: Record<string, unknown>) => TraLoi;
  huy?: (id: number) => TraLoi;
  daBiet?: (id: number) => TraLoi;
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}

let qc: QueryClient | null = null;
function LayQc() {
  const q = useQueryClient();
  useEffect(() => { qc = q; }, [q]);
  return null;
}

function dung(children: ReactNode, cauHinh: CauHinh) {
  const goi: Goi[] = [];
  const fetch = vi.fn(async (request: Request) => {
    const url = new URL(request.url);
    const path = url.pathname.replace(/^\/api/, "");
    const text = request.method === "GET" ? "" : await request.text();
    const body = text ? JSON.parse(text) : undefined;
    goi.push({ method: request.method, path, search: url.search, body });
    let r: TraLoi;
    const ma = /^\/leave-notices\/(\d+)\/(cancel|acknowledge)$/.exec(path);
    if (request.method === "GET" && path === "/sessions/current") r = json(cauHinh.phien());
    else if (request.method === "GET" && path.startsWith("/station-messages/")) r = json({ messages: [], next_before_id: null, read_at: "2026-11-05T00:30:00+07:00", poll_interval_seconds: 20 });
    else if (request.method === "GET" && path === "/assigned-tasks/mine") r = json({ assigned_tasks: [] });
    else if (request.method === "GET" && path === "/people") r = json({ people: [] });
    else if (request.method === "GET" && path === "/dining-tables") r = json({ tables: [] });
    else if (request.method === "GET" && path === "/leave-notices/mine") r = (cauHinh.mine ?? (() => json(cuaToi([]))))(cauHinh.phien());
    else if (request.method === "GET" && path === "/leave-notices") r = (cauHinh.range ?? (() => json(theoKhoang([]))))();
    else if (request.method === "POST" && path === "/leave-notices") {
      r = (cauHinh.bao ?? ((b) => json(nghi(90, { leave_date: String(b.leave_date) }), 201)))(body);
    } else if (request.method === "POST" && ma && ma[2] === "cancel") {
      r = (cauHinh.huy ?? ((id) => json(nghi(id, { cancelled_at: "2026-11-05T00:31:00+07:00", cancelled_by_person_id: 5, can_cancel: false }))))(Number(ma[1]));
    } else if (request.method === "POST" && ma && ma[2] === "acknowledge") {
      r = (cauHinh.daBiet ?? ((id) => json(nghi(id, { acknowledged_at: "2026-11-05T00:31:00+07:00", acknowledged_by_person_id: 2 }))))(Number(ma[1]));
    } else r = json({ code: "unexpected_request" }, 500);
    if (r === "mat") throw new TypeError("mất mạng");
    return r;
  });
  const view = render(<ApiProvider fetch={fetch}><LayQc />{children}</ApiProvider>);
  return {
    ...view, goi,
    ghi: () => goi.filter((g) => g.method !== "GET"),
    doc: (path: string) => goi.filter((g) => g.method === "GET" && g.path === path),
  };
}

async function moBang() {
  fireEvent.click(await screen.findByRole("button", { name: "Mở trò chuyện" }));
  return screen.getByRole("dialog", { name: "Trò chuyện" });
}
async function moBaoNghi() {
  const bang = await moBang();
  fireEvent.click(within(bang).getByRole("tab", { name: "Báo nghỉ" }));
  return within(bang).getByRole("tabpanel", { name: "Báo nghỉ" });
}
const oNgay = () => screen.getByLabelText("Ngày nghỉ") as HTMLInputElement;
const nutXemLai = () => screen.getByRole("button", { name: "Xem lại báo nghỉ" }) as HTMLButtonElement;
const the = () => screen.getByRole("region", { name: "Kiểm báo nghỉ trước khi gửi" });
const chonNgay = (ngay: string) => fireEvent.change(oNgay(), { target: { value: ngay } });

beforeEach(() => {
  vi.clearAllMocks();
  vi.useFakeTimers({ toFake: ["Date"], now: BAY_GIO });
  vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", "true");
  qc = null;
});
afterEach(() => { cleanup(); vi.useRealTimers(); vi.unstubAllEnvs(); });

describe("CHAT-32 — thẻ Báo nghỉ trong bảng chat", () => {
  it("B1 bảng có ba thẻ (CHAT-07 thêm Hỏi quán), Tin nhắn chọn sẵn; báo nghỉ chỉ đọc khi chọn thẻ; đổi thẻ giữ nháp tin", async () => {
    const { goi } = dung(<OChat khung="/tram" />, { phien: () => lan });
    const bang = await moBang();
    const ds = within(bang).getByRole("tablist", { name: "Mục trò chuyện" });
    const nutThe = within(ds).getAllByRole("tab");
    expect(nutThe.map((t) => t.textContent?.trim())).toEqual(["Tin nhắn", "Báo nghỉ", "Hỏi quán"]);
    expect(nutThe[0].getAttribute("aria-selected")).toBe("true");
    expect(nutThe[1].getAttribute("aria-selected")).toBe("false");
    await screen.findByText("Chưa có tin.");
    expect(goi.filter((g) => g.path.startsWith("/leave-notices"))).toEqual([]);
    expect(within(bang).queryByRole("tabpanel", { name: "Báo nghỉ" })).toBeNull();

    const nhap = screen.getByRole("textbox", { name: "Nội dung tin" }) as HTMLTextAreaElement;
    fireEvent.change(nhap, { target: { value: "Nháp giữ lại" } });
    fireEvent.click(nutThe[1]);
    expect(nutThe[1].getAttribute("aria-selected")).toBe("true");
    const panel = within(bang).getByRole("tabpanel", { name: "Báo nghỉ" });
    expect(await within(panel).findByText("Chưa có báo nghỉ.")).toBeTruthy();
    expect(screen.queryByRole("textbox", { name: "Nội dung tin" })).toBeNull();
    fireEvent.click(nutThe[0]);
    expect((screen.getByRole("textbox", { name: "Nội dung tin" }) as HTMLTextAreaElement).value).toBe("Nháp giữ lại");
  });

  it("B2 hôm nay theo giờ Việt Nam; chưa chọn ngày hoặc ngày đã qua thì không xem lại được", async () => {
    dung(<OChat khung="/tram" />, { phien: () => lan });
    await moBaoNghi();
    await screen.findByRole("form", { name: "Soạn báo nghỉ" });
    expect(oNgay().type).toBe("date");
    expect(oNgay().min).toBe("2026-11-05");
    expect(nutXemLai().disabled).toBe(true);
    chonNgay("2026-11-04");
    expect(nutXemLai().disabled).toBe(true);
    expect(screen.getByText("Chọn ngày từ hôm nay trở đi.")).toBeTruthy();
    chonNgay("2026-11-05");
    expect(nutXemLai().disabled).toBe(false);
    expect(screen.queryByText("Chọn ngày từ hôm nay trở đi.")).toBeNull();
  });

  it("B3 thẻ kiểm nói trước báo trước hay đột xuất; chỉ Xác nhận mới gửi đúng hai trường, xong thì đọc lại", async () => {
    const { ghi, doc } = dung(<OChat khung="/tram" />, { phien: () => lan });
    const panel = await moBaoNghi();
    await screen.findByText("Chưa có báo nghỉ.");

    chonNgay("2026-11-07");
    fireEvent.click(nutXemLai());
    expect(within(the()).getByText("Ngày nghỉ: 07/11/2026")).toBeTruthy();
    expect(within(the()).getByText("Báo cho: Chủ quán")).toBeTruthy();
    expect(within(the()).getByText("Dự kiến: Đột xuất")).toBeTruthy();
    expect(within(the()).getByText("Loại chính thức do quán ghi khi nhận báo nghỉ.")).toBeTruthy();
    expect(ghi()).toEqual([]);
    fireEvent.click(within(the()).getByRole("button", { name: "Sửa lại" }));
    expect(screen.queryByRole("region", { name: "Kiểm báo nghỉ trước khi gửi" })).toBeNull();
    expect(ghi()).toEqual([]);

    chonNgay("2026-11-08");
    fireEvent.click(nutXemLai());
    expect(within(the()).getByText("Dự kiến: Báo trước")).toBeTruthy();
    expect(panel.textContent ?? "").not.toMatch(/duyệt|được nghỉ|lương|trừ/i);
    const docTruoc = doc("/leave-notices/mine").length;
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận báo nghỉ" }));
    expect(await screen.findByText("Đã gửi báo nghỉ ngày 08/11/2026.")).toBeTruthy();
    expect(ghi()).toHaveLength(1);
    expect(ghi()[0].path).toBe("/leave-notices");
    expect(Object.keys(ghi()[0].body as object).sort()).toEqual(["leave_date", "submission_code"]);
    expect(ghi()[0].body).toMatchObject({ leave_date: "2026-11-08" });
    expect(String((ghi()[0].body as Record<string, unknown>).submission_code)).toMatch(/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/);
    expect(screen.queryByRole("region", { name: "Kiểm báo nghỉ trước khi gửi" })).toBeNull();
    expect(oNgay().value).toBe("");
    await waitFor(() => expect(doc("/leave-notices/mine").length).toBeGreaterThan(docTruoc));
  });

  it("B4 mất phản hồi là chưa rõ: thẻ giữ, không Sửa lại, Gửi lại dùng đúng dấu và thân; bấm hai lần chỉ gửi một", async () => {
    let lan1 = true;
    let tha: (r: Response) => void = () => {};
    const { ghi } = dung(<OChat khung="/tram" />, { phien: () => lan, bao: (b) => {
      if (lan1) { lan1 = false; return "mat"; }
      return new Promise<Response>((ok) => { tha = () => ok(json(nghi(91, { leave_date: String(b.leave_date) }), 200)); });
    } });
    await moBaoNghi();
    await screen.findByText("Chưa có báo nghỉ.");
    chonNgay("2026-11-09");
    fireEvent.click(nutXemLai());
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận báo nghỉ" }));
    expect(await screen.findByText("Chưa rõ báo nghỉ đã tới chưa. Bấm Gửi lại để gửi đúng báo nghỉ này.")).toBeTruthy();
    expect(within(the()).queryByRole("button", { name: "Sửa lại" })).toBeNull();
    const guiLai = within(the()).getByRole("button", { name: "Gửi lại" });
    fireEvent.click(guiLai);
    fireEvent.click(guiLai);
    await waitFor(() => expect(ghi()).toHaveLength(2));
    tha(json({}));
    expect(await screen.findByText("Đã gửi báo nghỉ ngày 09/11/2026.")).toBeTruthy();
    expect(ghi()).toHaveLength(2);
    expect(ghi()[1].body).toEqual(ghi()[0].body);
  });

  it.each([
    ["leave_date_in_past", 422, "Ngày này đã qua. Chọn ngày từ hôm nay trở đi."],
    ["leave_notice_day_taken", 409, "Bạn đã báo nghỉ ngày này rồi."],
    ["leave_day_attendance_ticked", 409, "Ngày này đã chấm có đi làm. Báo chủ quán nếu cần đổi."],
    ["submission_code_conflict", 409, "Dấu gửi đã dùng cho báo nghỉ khác. Bấm Xem lại để gửi lần mới."],
    ["internal_error", 500, "Chưa gửi được báo nghỉ (internal_error)."],
  ])("B5 bị từ chối %s: thẻ đóng, ngày giữ, lần sau dấu mới", async (code, status, loi) => {
    let lanDau = true;
    const { ghi } = dung(<OChat khung="/tram" />, { phien: () => lan, bao: (b) => {
      if (lanDau) { lanDau = false; return json({ code }, status); }
      return json(nghi(92, { leave_date: String(b.leave_date) }), 201);
    } });
    await moBaoNghi();
    await screen.findByText("Chưa có báo nghỉ.");
    chonNgay("2026-11-12");
    fireEvent.click(nutXemLai());
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận báo nghỉ" }));
    expect((await screen.findByRole("alert")).textContent).toContain(loi);
    expect(screen.queryByRole("region", { name: "Kiểm báo nghỉ trước khi gửi" })).toBeNull();
    expect(oNgay().value).toBe("2026-11-12");
    fireEvent.click(nutXemLai());
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận báo nghỉ" }));
    expect(await screen.findByText("Đã gửi báo nghỉ ngày 12/11/2026.")).toBeTruthy();
    const dau = ghi().map((g) => (g.body as Record<string, unknown>).submission_code);
    expect(dau).toHaveLength(2);
    expect(dau[0]).not.toBe(dau[1]);
  });

  it("B6 danh sách của tôi bày loại và trạng thái theo backend; nút huỷ chỉ khi can_cancel", async () => {
    dung(<OChat khung="/tram" />, { phien: () => lan, mine: () => json(cuaToi([
      // Loại theo backend: ngày xa nhưng backend nói đột xuất (báo muộn) — màn không tự suy lại.
      nghi(44, { leave_date: "2026-11-20", notice_kind: "dot_xuat" }),
      nghi(43, { leave_date: "2026-11-15", acknowledged_at: "2026-11-04T10:00:00+07:00", acknowledged_by_person_id: 2 }),
      nghi(42, { leave_date: "2026-11-05", notice_kind: "dot_xuat", can_cancel: false }),
      nghi(41, { leave_date: "2026-11-09", cancelled_at: "2026-11-04T11:00:00+07:00", cancelled_by_person_id: 5, can_cancel: false }),
    ])) });
    await moBaoNghi();
    const ds = await screen.findByRole("list", { name: "Báo nghỉ của tôi" });
    const dong = within(ds).getAllByRole("listitem");
    expect(dong).toHaveLength(4);
    expect(within(dong[0]).getByText("Ngày 20/11/2026")).toBeTruthy();
    expect(within(dong[0]).getByText("Đột xuất")).toBeTruthy();
    expect(within(dong[0]).getByText("Chủ quán chưa xem")).toBeTruthy();
    expect(within(dong[0]).getByRole("button", { name: "Huỷ báo nghỉ" })).toBeTruthy();
    expect(within(dong[1]).getByText("Báo trước")).toBeTruthy();
    expect(within(dong[1]).getByText("Chủ quán đã biết")).toBeTruthy();
    expect(within(dong[2]).getByText("Chủ quán chưa xem")).toBeTruthy();
    expect(within(dong[2]).queryByRole("button")).toBeNull();
    expect(within(dong[3]).getByText("Đã huỷ")).toBeTruthy();
    expect(within(dong[3]).queryByText("Chủ quán chưa xem")).toBeNull();
    expect(within(dong[3]).queryByRole("button")).toBeNull();
  });

  it("B7 huỷ không gửi thân rồi đọc lại; từ chối bày lời; mất phản hồi đọc lại, không tự gửi lần hai", async () => {
    let luot = 0;
    const { ghi, doc } = dung(<OChat khung="/tram" />, {
      phien: () => lan,
      mine: () => json(cuaToi([nghi(44, { leave_date: "2026-11-20" })])),
      huy: (id) => {
        luot += 1;
        if (luot === 1) return json({ code: "leave_notice_cancel_closed" }, 422);
        if (luot === 2) return "mat";
        return json(nghi(id, { cancelled_at: "2026-11-05T00:31:00+07:00", cancelled_by_person_id: 5, can_cancel: false }));
      },
    });
    await moBaoNghi();
    const ds = await screen.findByRole("list", { name: "Báo nghỉ của tôi" });
    fireEvent.click(within(ds).getByRole("button", { name: "Huỷ báo nghỉ" }));
    expect(await screen.findByText("Đã tới ngày nghỉ nên bạn không tự huỷ được. Báo chủ quán.")).toBeTruthy();
    expect(ghi()).toEqual([{ method: "POST", path: "/leave-notices/44/cancel", search: "", body: undefined }]);

    const docTruoc = doc("/leave-notices/mine").length;
    fireEvent.click(within(ds).getByRole("button", { name: "Huỷ báo nghỉ" }));
    expect(await screen.findByText("Chưa rõ kết quả. Đã đọc lại danh sách.")).toBeTruthy();
    await waitFor(() => expect(doc("/leave-notices/mine").length).toBeGreaterThan(docTruoc));
    expect(ghi()).toHaveLength(2);

    const docSau = doc("/leave-notices/mine").length;
    fireEvent.click(within(ds).getByRole("button", { name: "Huỷ báo nghỉ" }));
    await waitFor(() => expect(doc("/leave-notices/mine").length).toBeGreaterThan(docSau));
    expect(ghi()).toHaveLength(3);
  });

  it("B8 đọc lỗi thì báo và có nút đọc lại", async () => {
    let hong = true;
    dung(<OChat khung="/tram" />, { phien: () => lan, mine: () => (hong ? json({ code: "internal_error" }, 500) : json(cuaToi([]))) });
    await moBaoNghi();
    expect((await screen.findByRole("alert")).textContent).toContain("Chưa đọc được báo nghỉ.");
    hong = false;
    fireEvent.click(screen.getByRole("button", { name: "Đọc lại báo nghỉ" }));
    expect(await screen.findByText("Chưa có báo nghỉ.")).toBeTruthy();
  });

  it("B9 khoá query mang người của phiên; đổi người không thấy báo nghỉ người cũ; không ghi kho trình duyệt", async () => {
    let nguoi = lan;
    const localTruoc = localStorage.length;
    const sessionTruoc = sessionStorage.length;
    function DoiNguoi() {
      const queries = useQueryClient();
      return <button onClick={() => { nguoi = hoa; void queries.invalidateQueries({ queryKey: KHOA_PHIEN }); }}>Đổi người</button>;
    }
    dung(<><OChat khung="/tram" /><DoiNguoi /></>, {
      phien: () => nguoi,
      mine: (s) => json(cuaToi(s.person_id === 5 ? [nghi(44, { leave_date: "2026-11-20" })] : [])),
    });
    await moBaoNghi();
    await screen.findByText("Ngày 20/11/2026");
    chonNgay("2026-11-21");
    expect(qc!.getQueryCache().findAll({ queryKey: ["leave-notices"] }).map((q) => q.queryKey)).toEqual([["leave-notices", "mine", 5]]);
    expect(localStorage.length).toBe(localTruoc);
    expect(sessionStorage.length).toBe(sessionTruoc);

    fireEvent.click(screen.getByRole("button", { name: "Đổi người" }));
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    await moBaoNghi();
    expect(await screen.findByText("Chưa có báo nghỉ.")).toBeTruthy();
    expect(screen.queryByText("Ngày 20/11/2026")).toBeNull();
    expect(oNgay().value).toBe("");
  });
});

describe.each([
  ["/tram", lan],
  ["/quay", pos],
] as const)("CHAT-32 — người làm ở khung %s tự báo nghỉ", (khung, phien) => {
  it("G1 có form tự báo, đọc báo nghỉ của tôi, không đọc danh sách của chủ quán", async () => {
    const { doc } = dung(<OChat khung={khung} />, { phien: () => phien });
    await moBaoNghi();
    await screen.findByRole("form", { name: "Soạn báo nghỉ" });
    await screen.findByText("Chưa có báo nghỉ.");
    expect(doc("/leave-notices/mine").length).toBeGreaterThan(0);
    expect(doc("/leave-notices")).toEqual([]);
    expect(screen.queryByRole("list", { name: "Báo nghỉ của nhân viên" })).toBeNull();
    expect(khung satisfies Khung).toBe(khung);
  });
});

describe("CHAT-32 — chủ quán ở khung /chu-quan", () => {
  it("C1 đọc báo nghỉ của nhân viên từ hôm nay tới 30 ngày tới; không có form tự báo", async () => {
    const { doc } = dung(<OChat khung="/chu-quan" />, { phien: () => chu });
    await moBaoNghi();
    expect(await screen.findByText("Chưa có báo nghỉ.")).toBeTruthy();
    const range = doc("/leave-notices");
    expect(range.length).toBeGreaterThan(0);
    const q = new URLSearchParams(range[0].search);
    expect([q.get("from"), q.get("to")]).toEqual(["2026-11-05", "2026-12-05"]);
    expect(doc("/leave-notices/mine")).toEqual([]);
    expect(screen.queryByRole("form", { name: "Soạn báo nghỉ" })).toBeNull();
    expect(qc!.getQueryCache().findAll({ queryKey: ["leave-notices"] }).map((x) => x.queryKey))
      .toEqual([["leave-notices", "range", "2026-11-05", "2026-12-05"]]);
  });

  it("C2 mỗi dòng có tên người, ngày, loại, trạng thái; Đã biết và Huỷ theo dữ liệu, bấm thì ghi rồi đọc lại", async () => {
    const { ghi, doc } = dung(<OChat khung="/chu-quan" />, { phien: () => chu, range: () => json(theoKhoang([
      nghi(51, { person_name: "Lan", leave_date: "2026-11-06", notice_kind: "dot_xuat" }),
      nghi(52, { person_id: 6, person_name: "Hoa", leave_date: "2026-11-10", acknowledged_at: "2026-11-04T10:00:00+07:00", acknowledged_by_person_id: 2 }),
      nghi(53, { person_id: 6, person_name: "Hoa", leave_date: "2026-11-11", cancelled_at: "2026-11-04T11:00:00+07:00", cancelled_by_person_id: 6, can_cancel: false }),
    ])) });
    await moBaoNghi();
    const ds = await screen.findByRole("list", { name: "Báo nghỉ của nhân viên" });
    const dong = within(ds).getAllByRole("listitem");
    expect(dong).toHaveLength(3);
    expect(within(dong[0]).getByText("Lan")).toBeTruthy();
    expect(within(dong[0]).getByText("Ngày 06/11/2026")).toBeTruthy();
    expect(within(dong[0]).getByText("Đột xuất")).toBeTruthy();
    expect(within(dong[0]).getByText("Chủ quán chưa xem")).toBeTruthy();
    expect(within(dong[0]).getAllByRole("button").map((b) => b.textContent?.trim())).toEqual(["Đã biết", "Huỷ"]);
    expect(within(dong[1]).getByText("Chủ quán đã biết")).toBeTruthy();
    expect(within(dong[1]).getAllByRole("button").map((b) => b.textContent?.trim())).toEqual(["Huỷ"]);
    expect(within(dong[2]).getByText("Đã huỷ")).toBeTruthy();
    expect(within(dong[2]).getAllByRole("button").map((b) => b.textContent?.trim())).toEqual(["Đã biết"]);

    const docTruoc = doc("/leave-notices").length;
    fireEvent.click(within(dong[0]).getByRole("button", { name: "Đã biết" }));
    await waitFor(() => expect(doc("/leave-notices").length).toBeGreaterThan(docTruoc));
    fireEvent.click(within(within(ds).getAllByRole("listitem")[1]).getByRole("button", { name: "Huỷ" }));
    await waitFor(() => expect(ghi()).toHaveLength(2));
    expect(ghi()).toEqual([
      { method: "POST", path: "/leave-notices/51/acknowledge", search: "", body: undefined },
      { method: "POST", path: "/leave-notices/52/cancel", search: "", body: undefined },
    ]);
  });

  it.each([
    ["leave_notice_not_found", 404, "Không tìm thấy báo nghỉ này."],
    ["owner_only", 403, "Chỉ chủ quán ghi được việc này."],
    ["internal_error", 500, "Chưa ghi được (internal_error)."],
  ])("C3 đã biết bị từ chối %s thì bày lời", async (code, status, loi) => {
    dung(<OChat khung="/chu-quan" />, { phien: () => chu, range: () => json(theoKhoang([nghi(51)])), daBiet: () => json({ code }, status) });
    await moBaoNghi();
    const ds = await screen.findByRole("list", { name: "Báo nghỉ của nhân viên" });
    fireEvent.click(within(ds).getByRole("button", { name: "Đã biết" }));
    expect((await screen.findByRole("alert")).textContent).toContain(loi);
  });
});
