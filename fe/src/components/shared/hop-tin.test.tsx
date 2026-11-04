// CHAT-14 — hộp tin trạm ↔ quầy trong ô chat (ADR-137 điểm 4 · 5 · 6 · 7 · 8, I-038). Claude viết trước, đỏ trước code.
//
// Hợp đồng màn Claude chốt cho bước này (2026-11-04) — test đọc đúng các tên dưới đây:
// - `OChat` nhận prop `khung` ("/quay" · "/tram" · "/chu-quan"); ba layout truyền đúng khung của mình.
//   "/tram" là hộp cá nhân: đọc `GET /station-messages/mine`, gửi `POST /station-messages/to-counter`, không đọc `/people`.
//   "/quay" và "/chu-quan" là hộp quầy: đọc `GET /station-messages/counter` và `GET /people`, gửi `POST /station-messages`.
//   Cả ba đọc `GET /assigned-tasks/mine` và `GET /dining-tables` (nhãn bàn). Không đường nào khác.
// - Danh sách tin `<ul aria-label="Tin nhắn">`, mỗi tin một `<li>` có: nhãn loại việc (Canh · Dọn bàn · Tráng bánh ·
//   Gấp bánh · Khác), "Từ {sender_name}", "tới {recipient_name}" hoặc "về quầy" khi người nhận null, nội dung, "Bàn {label}"
//   khi có bàn, và nút "Trả lời". Rỗng: "Chưa có tin.". Mốc: "Cập nhật lúc …" theo `read_at`. Đọc lỗi khi đã có bản cũ:
//   `role="alert"` chứa "Chưa đọc được tin mới", bản cũ vẫn hiện; chưa có bản nào: alert "Chưa đọc được tin." + nút "Đọc lại tin".
// - Chỉ ở khung "/quay": tin canh · tráng · gấp có link "Mở Sản xuất" (`/quay/san-xuat`); tin khác có bàn có link
//   "Mở Gọi món" (`/quay/goi-mon`); tin dọn bàn không có link (màn dọn bàn tay chưa có, `cleanTable` giữ nguyên).
// - Form `aria-label="Soạn tin"`: hộp quầy có ô chọn "Người nhận" (từ `/people`, bỏ chính mình, ô đầu "Chọn người nhận");
//   hộp cá nhân hiện chữ "Gửi về quầy". Ô chọn "Loại việc" (ô đầu "Chọn loại việc"), ô chọn "Bàn" (ô đầu "Không gắn bàn"),
//   ô "Nội dung tin" (nhận focus khi mở bảng). Nút "Xem lại trước khi gửi" chỉ bấm được khi đủ người nhận (hộp quầy), loại
//   việc, nội dung có ký tự không phải khoảng trắng và ≤ 500 ký tự; quá thì hiện "Tối đa 500 ký tự".
//   "Trả lời" trên một tin: form hiện "Đang trả lời {sender_name}" và nút "Bỏ trả lời"; hộp quầy chọn sẵn người gửi tin ấy.
// - Thẻ `<section aria-label="Kiểm tin trước khi gửi">`: "Người nhận: {tên}" hoặc "Người nhận: Quầy", "Loại việc: {nhãn}",
//   "Bàn: {label}" khi có, nội dung, nút "Xác nhận gửi" và "Sửa lại". Chỉ "Xác nhận gửi" mới gọi cửa ghi.
// - Gửi xong: `role="status"` "Đã gửi tin.", xoá nội dung và trả lời, đọc lại hộp. Mất phản hồi: alert "Chưa rõ tin đã tới
//   chưa. Bấm Gửi lại để gửi đúng tin này.", thẻ giữ nguyên, không có "Sửa lại", nút "Gửi lại" gửi đúng thân và dấu cũ.
//   Bị từ chối: thẻ đóng, nháp giữ, lần sau dấu mới; `message_recipient_invalid` ⇒ "Người này chưa có tài khoản đang hoạt
//   động hoặc là chính bạn. Chọn người khác."; `not_on_counter_duty` ⇒ "Bạn không đứng quầy nên chưa gửi tin từ quầy được.".
// - "Việc của tôi" `<ul aria-label="Việc của tôi">`: nội dung, "Hạn {giờ Asia/Ho_Chi_Minh}" hoặc "Chưa có hạn",
//   "Giao bởi {assigned_by_name}", "Đã xong"/"Chưa xong", hướng dẫn chữ. Không một nút nào. Rỗng: "Không có việc được giao.".
// - Khoá query hộp tin: ["station-messages", "mine" | "counter", person_id], trải `tuyChonKeo()`.
// - Nhãn loại việc, nội dung tin, "Chưa xong"/"Đã xong", mỗi hướng dẫn chữ là một phần tử riêng chỉ chứa đúng chữ ấy; "Hạn …"
//   nằm trọn trong một phần tử. Nội dung trong thẻ kiểm giữ nguyên khoảng trắng; thẻ không chứa ô nhập nào.
// - Chỉ trang đầu (20 tin mới nhất); chưa có nút xem tin cũ hơn. Bảng không có nút nào ngoài Đóng, Trả lời, Bỏ trả lời,
//   Xem lại trước khi gửi, Xác nhận gửi, Sửa lại, Gửi lại, Đọc lại tin.
import { useEffect, type ReactNode } from "react";
import { QueryClient, useQueryClient } from "@tanstack/react-query";
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import LayoutChuQuan from "@/app/chu-quan/layout";
import LayoutQuay from "@/app/quay/layout";
import LayoutTram from "@/app/tram/layout";
import type { components } from "@/lib/api/schema";
import { ApiProvider } from "@/lib/api/provider";
import type { Khung, Session } from "@/lib/auth/khung";
import { KHOA_PHIEN } from "@/lib/auth/session";
import { OChat } from "./o-chat";

vi.mock("@/components/tai-khoan/khung-theo-vai", () => ({
  KhungTheoVai: ({ children }: { children: ReactNode }) => children,
}));
vi.mock("@/lib/realtime/tin-hieu", async (goc) => ({
  ...(await goc<typeof import("@/lib/realtime/tin-hieu")>()),
  TinHieuProvider: ({ children }: { children: ReactNode }) => children,
  BaoMatKetNoi: () => null,
}));
vi.mock("@/app/quay/_components/tu-nha-don-hen", () => ({ TuNhaDonHen: () => null }));
vi.mock("@/app/chu-quan/_components/thanh-dieu-huong", () => ({ ThanhDieuHuong: () => null }));

type Tin = components["schemas"]["StationMessage"];
type Viec = components["schemas"]["MyAssignedTask"];

const lan: Session = {
  person_id: 5, display_name: "Lan", role_code: "canh_don_ban", is_owner: false,
  must_change_password: false, counter_duty_id: 0,
};
const hoa: Session = { ...lan, person_id: 6, display_name: "Hoa", role_code: "trang_banh" };
const pos: Session = { ...lan, person_id: 1, display_name: "Minh", role_code: "quay", counter_duty_id: 9 };
const chu: Session = { ...lan, person_id: 2, display_name: "Chủ", role_code: "owner", is_owner: true };

const nguoi = [
  { person_id: 1, display_name: "Minh", is_owner: false },
  { person_id: 2, display_name: "Chủ", is_owner: true },
  { person_id: 5, display_name: "Lan", is_owner: false },
  { person_id: 6, display_name: "Hoa", is_owner: false },
  { person_id: 7, display_name: "Tú (đã khoá)", is_owner: false },
];
const ban = [
  { dining_table_id: 3, label: "B3", state: "needs_cleaning" },
  { dining_table_id: 4, label: "B4", state: "in_session" },
];

function tin(id: number, p: Partial<Tin> = {}): Tin {
  return {
    station_message_id: id, sender_person_id: 1, sender_name: "Minh", recipient_person_id: 5, recipient_name: "Lan",
    work_code: "canh", body: `Tin ${id}`, dining_table_id: null, reply_to_message_id: null,
    created_at: "2026-11-04T10:00:00+07:00", ...p,
  };
}
const viec = (p: Partial<Viec> = {}): Viec => ({
  assigned_task_id: 11, content: "Lau tủ kính", due_at: "2026-11-04T10:30:00+07:00", created_at: "2026-11-04T08:00:00+07:00",
  assigned_by_name: "Chủ", done: false, guides: [{ body: "Dùng khăn khô" }], ...p,
});
const trang = (messages: Tin[]) => ({
  messages, next_before_id: null, read_at: "2026-11-04T10:05:00+07:00", poll_interval_seconds: 20,
});

type Goi = { method: string; path: string; body: unknown };
type TraLoi = Response | Promise<Response> | "mat";
type CauHinh = {
  phien: () => Session;
  mine?: (s: Session) => TraLoi;
  counter?: () => TraLoi;
  viec?: () => TraLoi;
  gui?: (body: Record<string, unknown>) => TraLoi;
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
    const path = new URL(request.url).pathname.replace(/^\/api/, "");
    const text = request.method === "GET" ? "" : await request.text();
    const body = text ? JSON.parse(text) : undefined;
    goi.push({ method: request.method, path, body });
    let r: TraLoi;
    if (request.method === "GET" && path === "/sessions/current") r = json(cauHinh.phien());
    else if (request.method === "GET" && path === "/station-messages/mine") r = (cauHinh.mine ?? (() => json(trang([]))))(cauHinh.phien());
    else if (request.method === "GET" && path === "/station-messages/counter") r = (cauHinh.counter ?? (() => json(trang([]))))();
    else if (request.method === "GET" && path === "/assigned-tasks/mine") r = (cauHinh.viec ?? (() => json({ assigned_tasks: [] })))();
    else if (request.method === "GET" && path === "/people") r = json({ people: nguoi });
    else if (request.method === "GET" && path === "/dining-tables") r = json({ tables: ban });
    else if (request.method === "POST" && (path === "/station-messages" || path === "/station-messages/to-counter")) {
      r = (cauHinh.gui ?? ((b) => json(tin(99, { body: String(b.body) }), 201)))(body);
    } else r = json({ code: "unexpected_request" }, 500);
    if (r === "mat") throw new TypeError("mất mạng");
    return r;
  });
  const view = render(<ApiProvider fetch={fetch}><LayQc />{children}</ApiProvider>);
  return { ...view, goi, ghi: () => goi.filter((g) => g.method !== "GET") };
}

async function moBang() {
  fireEvent.click(await screen.findByRole("button", { name: "Mở trò chuyện" }));
  return screen.getByRole("dialog", { name: "Trò chuyện" });
}
const danhSachTin = () => screen.findByRole("list", { name: "Tin nhắn" });
const oNoiDung = () => screen.getByRole("textbox", { name: "Nội dung tin" }) as HTMLTextAreaElement;
const chon = (ten: string, value: string) => fireEvent.change(screen.getByRole("combobox", { name: ten }), { target: { value } });
const nutXemLai = () => screen.getByRole("button", { name: "Xem lại trước khi gửi" }) as HTMLButtonElement;
const the = () => screen.getByRole("region", { name: "Kiểm tin trước khi gửi" });

async function soanQuay(noiDung: string, p: { nguoiNhan?: string; viec?: string; ban?: string } = {}) {
  await screen.findByRole("option", { name: "Lan" });
  chon("Người nhận", p.nguoiNhan ?? "5");
  chon("Loại việc", p.viec ?? "canh");
  if (p.ban) chon("Bàn", p.ban);
  fireEvent.change(oNoiDung(), { target: { value: noiDung } });
}
async function soanTram(noiDung: string, p: { viec?: string; ban?: string } = {}) {
  await screen.findByRole("form", { name: "Soạn tin" });
  chon("Loại việc", p.viec ?? "don_ban");
  if (p.ban) { await screen.findByRole("option", { name: "B3" }); chon("Bàn", p.ban); }
  fireEvent.change(oNoiDung(), { target: { value: noiDung } });
}

beforeEach(() => {
  vi.clearAllMocks();
  vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", "true");
  qc = null;
});
afterEach(() => { cleanup(); vi.unstubAllEnvs(); });

describe("CHAT-14 — hộp cá nhân ở trạm", () => {
  it("A1 người canh+dọn thấy cả tin canh và tin dọn bàn, phân loại rõ, mỗi tin một lần", async () => {
    dung(<OChat khung="/tram" />, { phien: () => lan, mine: () => json(trang([
      tin(2, { work_code: "don_ban", body: "Dọn giúp B3", dining_table_id: 3 }),
      tin(1, { work_code: "canh", body: "Múc 2 bát canh" }),
    ])) });
    await moBang();
    const ds = await danhSachTin();
    const dong = within(ds).getAllByRole("listitem");
    expect(dong).toHaveLength(2);
    expect(within(dong[0]).getByText("Dọn bàn")).toBeTruthy();
    expect(within(dong[0]).getByText("Dọn giúp B3")).toBeTruthy();
    expect(within(dong[0]).getByText(/Bàn B3/)).toBeTruthy();
    expect(within(dong[1]).getByText("Canh")).toBeTruthy();
    expect(within(dong[1]).getByText("Múc 2 bát canh")).toBeTruthy();
    expect(within(dong[1]).getByText(/Từ Minh/)).toBeTruthy();
    expect(screen.getAllByText("Múc 2 bát canh")).toHaveLength(1);
    expect(screen.getByText(/Cập nhật lúc/)).toBeTruthy();
    expect(within(ds).queryByRole("link")).toBeNull();
  });

  it("A2 gửi về quầy chỉ gọi to-counter sau khi xác nhận thẻ, thân giữ nguyên từng byte", async () => {
    const { goi, ghi } = dung(<OChat khung="/tram" />, { phien: () => lan });
    await moBang();
    expect(document.activeElement).toBe(oNoiDung());
    expect(screen.getByText("Gửi về quầy")).toBeTruthy();
    expect(screen.queryByRole("combobox", { name: "Người nhận" })).toBeNull();
    await soanTram("  Đã dọn xong B3  ", { ban: "3" });
    fireEvent.click(nutXemLai());
    const kiem = the();
    expect(within(kiem).getByText("Người nhận: Quầy")).toBeTruthy();
    expect(within(kiem).getByText("Loại việc: Dọn bàn")).toBeTruthy();
    expect(within(kiem).getByText("Bàn: B3")).toBeTruthy();
    expect(within(kiem).getByText((_, el) => el?.textContent === "  Đã dọn xong B3  ")).toBeTruthy();
    expect(ghi()).toEqual([]);

    const docTruoc = goi.filter((g) => g.path === "/station-messages/mine").length;
    fireEvent.click(within(kiem).getByRole("button", { name: "Xác nhận gửi" }));
    fireEvent.click(within(kiem).getByRole("button", { name: "Xác nhận gửi" }));
    expect(await screen.findByText("Đã gửi tin.")).toBeTruthy();
    expect(ghi()).toHaveLength(1);
    const [g] = ghi();
    expect(g.path).toBe("/station-messages/to-counter");
    expect(g.body).toEqual({
      submission_code: expect.stringMatching(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/),
      work_code: "don_ban", body: "  Đã dọn xong B3  ", dining_table_id: 3, reply_to_message_id: null,
    });
    expect(g.body).not.toHaveProperty("recipient_person_id");
    expect(g.body).not.toHaveProperty("sender_person_id");
    expect(oNoiDung().value).toBe("");
    expect(screen.queryByRole("region", { name: "Kiểm tin trước khi gửi" })).toBeNull();
    await waitFor(() => expect(goi.filter((x) => x.path === "/station-messages/mine").length).toBeGreaterThan(docTruoc));
  });

  it("A2 Sửa lại bỏ thẻ, không ghi, giữ nháp", async () => {
    const { ghi } = dung(<OChat khung="/tram" />, { phien: () => lan });
    await moBang();
    await soanTram("Khách bàn 4 muốn thêm một đĩa", { viec: "khac" });
    fireEvent.click(nutXemLai());
    fireEvent.click(within(the()).getByRole("button", { name: "Sửa lại" }));
    expect(screen.queryByRole("region", { name: "Kiểm tin trước khi gửi" })).toBeNull();
    expect(oNoiDung().value).toBe("Khách bàn 4 muốn thêm một đĩa");
    expect(ghi()).toEqual([]);
  });

  it.each([
    ["rỗng", "", false],
    ["chỉ khoảng trắng", "   \n ", false],
    ["500 ký tự nhiều byte", "ằ".repeat(500), true],
    ["501 ký tự", "ằ".repeat(501), false],
  ])("A2 nội dung %s ⇒ nút xem lại bấm được đúng luật", async (_ten, noiDung, duoc) => {
    dung(<OChat khung="/tram" />, { phien: () => lan });
    await moBang();
    await soanTram(noiDung);
    expect(nutXemLai().disabled).toBe(!duoc);
    if (noiDung.length > 500) expect(screen.getByText("Tối đa 500 ký tự")).toBeTruthy();
  });

  it("A2 chưa chọn loại việc thì chưa xem lại được", async () => {
    dung(<OChat khung="/tram" />, { phien: () => lan });
    await moBang();
    await screen.findByRole("form", { name: "Soạn tin" });
    fireEvent.change(oNoiDung(), { target: { value: "Đã múc" } });
    expect(nutXemLai().disabled).toBe(true);
  });

  it("A2 trả lời một tin gửi kèm reply_to_message_id", async () => {
    const { ghi } = dung(<OChat khung="/tram" />, { phien: () => lan, mine: () => json(trang([tin(8, { body: "Múc 3 bát" })])) });
    await moBang();
    const ds = await danhSachTin();
    fireEvent.click(within(ds).getByRole("button", { name: "Trả lời" }));
    expect(screen.getByText("Đang trả lời Minh")).toBeTruthy();
    await soanTram("Đã đem ra", { viec: "canh" });
    fireEvent.click(nutXemLai());
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận gửi" }));
    await screen.findByText("Đã gửi tin.");
    expect(ghi()[0].body).toMatchObject({ reply_to_message_id: 8, work_code: "canh" });
    expect(screen.queryByText("Đang trả lời Minh")).toBeNull();
  });

  it("A2 Bỏ trả lời gửi reply_to_message_id null", async () => {
    const { ghi } = dung(<OChat khung="/tram" />, { phien: () => lan, mine: () => json(trang([tin(8)])) });
    await moBang();
    fireEvent.click(within(await danhSachTin()).getByRole("button", { name: "Trả lời" }));
    fireEvent.click(screen.getByRole("button", { name: "Bỏ trả lời" }));
    await soanTram("Tin mới");
    fireEvent.click(nutXemLai());
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận gửi" }));
    await screen.findByText("Đã gửi tin.");
    expect(ghi()[0].body).toMatchObject({ reply_to_message_id: null });
  });

  it("A5 tráng và gấp có cùng kiểu tin; trạm không có nút ghi tiến độ hay đánh dấu", async () => {
    dung(<OChat khung="/tram" />, { phien: () => hoa, mine: () => json(trang([tin(3, { recipient_person_id: 6, recipient_name: "Hoa", work_code: "trang_banh" })])) });
    const bang = await moBang();
    await danhSachTin();
    const loai = within(screen.getByRole("combobox", { name: "Loại việc" })).getAllByRole("option").map((o) => o.textContent);
    expect(loai).toEqual(["Chọn loại việc", "Canh", "Dọn bàn", "Tráng bánh", "Gấp bánh", "Khác"]);
    expect(screen.getByText("Tráng bánh", { selector: "li *" })).toBeTruthy();
    const nut = within(bang).getAllByRole("button").map((b) => b.textContent?.trim());
    expect(nut.filter((t) => t !== "Đóng" && t !== "Trả lời" && t !== "Xem lại trước khi gửi")).toEqual([]);
  });

  it("A4 mất phản hồi là chưa rõ: thẻ giữ, không Sửa lại, Gửi lại dùng đúng dấu và thân", async () => {
    let lan1 = true;
    const { ghi } = dung(<OChat khung="/tram" />, { phien: () => lan, gui: (b) => {
      if (lan1) { lan1 = false; return "mat"; }
      return json(tin(50, { body: String(b.body) }), 200);
    } });
    await moBang();
    await soanTram("Đã múc 2 bát", { viec: "canh" });
    fireEvent.click(nutXemLai());
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận gửi" }));
    expect(await screen.findByText("Chưa rõ tin đã tới chưa. Bấm Gửi lại để gửi đúng tin này.")).toBeTruthy();
    expect(the()).toBeTruthy();
    expect(screen.queryByRole("button", { name: "Sửa lại" })).toBeNull();
    expect(ghi()).toHaveLength(1);
    fireEvent.click(screen.getByRole("button", { name: "Gửi lại" }));
    await screen.findByText("Đã gửi tin.");
    expect(ghi()).toHaveLength(2);
    expect(ghi()[1].body).toEqual(ghi()[0].body);
  });

  it("A4 đọc lỗi khi đã có bản cũ: giữ tin cũ kèm cảnh báo; SSE gọi đọc lại thì đọc lại hộp", async () => {
    let lanDoc = 0;
    const { goi } = dung(<OChat khung="/tram" />, { phien: () => lan, mine: () => {
      lanDoc += 1;
      return lanDoc === 1 ? json(trang([tin(1, { body: "Tin cũ" })])) : json({ code: "internal_error" }, 500);
    } });
    await moBang();
    await screen.findByText("Tin cũ");
    await waitFor(() => expect(qc).not.toBeNull());
    await qc!.invalidateQueries();
    expect((await screen.findByRole("alert")).textContent).toContain("Chưa đọc được tin mới");
    expect(screen.getByText("Tin cũ")).toBeTruthy();
    expect(goi.filter((g) => g.path === "/station-messages/mine").length).toBe(2);
  });

  it("A4 chưa đọc được lần nào: báo lỗi và nút Đọc lại tin", async () => {
    let hong = true;
    dung(<OChat khung="/tram" />, { phien: () => lan, mine: () => (hong ? json({ code: "internal_error" }, 500) : json(trang([tin(1, { body: "Đọc được rồi" })]))) });
    await moBang();
    expect(await screen.findByText("Chưa đọc được tin.")).toBeTruthy();
    hong = false;
    fireEvent.click(screen.getByRole("button", { name: "Đọc lại tin" }));
    expect(await screen.findByText("Đọc được rồi")).toBeTruthy();
  });

  it("A4 hộp kéo theo chu kỳ của hợp đồng kể cả tab nền, khoá query mang người của phiên", async () => {
    dung(<OChat khung="/tram" />, { phien: () => lan, mine: () => json(trang([tin(1)])) });
    await moBang();
    await danhSachTin();
    const hop = qc!.getQueryCache().findAll({ queryKey: ["station-messages"] });
    expect(hop.map((q) => q.queryKey)).toEqual([["station-messages", "mine", 5]]);
    const o = hop[0].options as { refetchInterval?: unknown; refetchIntervalInBackground?: boolean };
    expect(typeof o.refetchInterval).toBe("function");
    expect((o.refetchInterval as (q: unknown) => number)(hop[0])).toBe(20_000);
    expect(o.refetchIntervalInBackground).toBe(true);
  });

  it("A4 tin riêng không vào bộ nhớ trình duyệt", async () => {
    const local = localStorage.length;
    const session = sessionStorage.length;
    dung(<OChat khung="/tram" />, { phien: () => lan, mine: () => json(trang([tin(1, { body: "Tin riêng" })])) });
    await moBang();
    await screen.findByText("Tin riêng");
    await soanTram("Nháp riêng");
    expect(localStorage.length).toBe(local);
    expect(sessionStorage.length).toBe(session);
  });

  it("A4 đổi người không thấy tin hay nháp của người trước, kể cả khi hộp người sau chưa đọc xong", async () => {
    let nguoiPhien = lan;
    function DoiNguoi() {
      const q = useQueryClient();
      return <button onClick={() => { nguoiPhien = hoa; void q.invalidateQueries({ queryKey: KHOA_PHIEN }); }}>Đổi người</button>;
    }
    dung(<><OChat khung="/tram" /><DoiNguoi /></>, {
      phien: () => nguoiPhien,
      mine: (s) => (s.person_id === 5 ? json(trang([tin(1, { body: "Tin riêng của Lan" })])) : new Promise<Response>(() => {})),
    });
    await moBang();
    await screen.findByText("Tin riêng của Lan");
    fireEvent.change(oNoiDung(), { target: { value: "Nháp của Lan" } });
    fireEvent.click(screen.getByRole("button", { name: "Đổi người" }));
    await waitFor(() => expect(screen.queryByRole("dialog")).toBeNull());
    await moBang();
    expect(screen.queryByText("Tin riêng của Lan")).toBeNull();
    expect(oNoiDung().value).toBe("");
  });

  it("A7 việc của tôi có hạn, người giao, hướng dẫn chữ và không có nút nào", async () => {
    dung(<OChat khung="/tram" />, { phien: () => lan, viec: () => json({ assigned_tasks: [
      viec(),
      viec({ assigned_task_id: 12, content: "Kiểm gas", due_at: null, done: true, guides: [] }),
    ] }) });
    await moBang();
    const ds = await screen.findByRole("list", { name: "Việc của tôi" });
    const dong = within(ds).getAllByRole("listitem");
    expect(dong).toHaveLength(2);
    expect(within(dong[0]).getByText("Lau tủ kính")).toBeTruthy();
    expect(within(dong[0]).getByText(/Hạn.*10:30/)).toBeTruthy();
    expect(within(dong[0]).getByText(/Giao bởi Chủ/)).toBeTruthy();
    expect(within(dong[0]).getByText("Chưa xong")).toBeTruthy();
    expect(within(dong[0]).getByText("Dùng khăn khô")).toBeTruthy();
    expect(within(dong[1]).getByText("Chưa có hạn")).toBeTruthy();
    expect(within(dong[1]).getByText("Đã xong")).toBeTruthy();
    expect(within(ds).queryAllByRole("button")).toEqual([]);
    expect(within(ds).queryAllByRole("checkbox")).toEqual([]);
  });

  it("A7 không có việc thì nói rõ", async () => {
    dung(<OChat khung="/tram" />, { phien: () => lan });
    await moBang();
    expect(await screen.findByText("Không có việc được giao.")).toBeTruthy();
    expect(await screen.findByText("Chưa có tin.")).toBeTruthy();
  });
});

describe("CHAT-14 — hộp quầy", () => {
  it("A3 POS thấy người gửi, người nhận hay về quầy, bàn và link màn tay đúng loại việc", async () => {
    dung(<OChat khung="/quay" />, { phien: () => pos, counter: () => json(trang([
      tin(4, { sender_person_id: 5, sender_name: "Lan", recipient_person_id: null, recipient_name: null, work_code: "khac", body: "Khách muốn thêm", dining_table_id: 4 }),
      tin(3, { sender_person_id: 5, sender_name: "Lan", recipient_person_id: null, recipient_name: null, work_code: "don_ban", body: "Đã dọn", dining_table_id: 3 }),
      tin(2, { sender_person_id: 6, sender_name: "Hoa", recipient_person_id: null, recipient_name: null, work_code: "trang_banh", body: "Hết bột" }),
      tin(1, { work_code: "canh", body: "Múc 2 bát" }),
    ])) });
    await moBang();
    const dong = within(await danhSachTin()).getAllByRole("listitem");
    expect(within(dong[0]).getByText(/Từ Lan/)).toBeTruthy();
    expect(within(dong[0]).getByText(/về quầy/)).toBeTruthy();
    expect(within(dong[0]).getByText(/Bàn B4/)).toBeTruthy();
    expect(within(dong[0]).getByRole("link", { name: "Mở Gọi món" }).getAttribute("href")).toBe("/quay/goi-mon");
    expect(within(dong[1]).queryByRole("link")).toBeNull();
    expect(within(dong[2]).getByRole("link", { name: "Mở Sản xuất" }).getAttribute("href")).toBe("/quay/san-xuat");
    expect(within(dong[3]).getByText(/tới Lan/)).toBeTruthy();
    expect(within(dong[3]).getByRole("link", { name: "Mở Sản xuất" })).toBeTruthy();
  });

  it("A8 POS chọn người nhận từng lần từ listPeople, bỏ chính mình; gửi đúng cửa và thân", async () => {
    const { goi, ghi } = dung(<OChat khung="/quay" />, { phien: () => pos });
    await moBang();
    await screen.findByRole("option", { name: "Lan" });
    const ten = within(screen.getByRole("combobox", { name: "Người nhận" })).getAllByRole("option").map((o) => o.textContent);
    expect(ten).toEqual(["Chọn người nhận", "Chủ", "Lan", "Hoa", "Tú (đã khoá)"]);
    chon("Loại việc", "canh");
    fireEvent.change(oNoiDung(), { target: { value: "Múc 2 bát cho B3" } });
    expect(nutXemLai().disabled).toBe(true);
    chon("Người nhận", "5");
    chon("Bàn", "3");
    fireEvent.click(nutXemLai());
    expect(within(the()).getByText("Người nhận: Lan")).toBeTruthy();
    expect(within(the()).getByText("Loại việc: Canh")).toBeTruthy();
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận gửi" }));
    await screen.findByText("Đã gửi tin.");
    expect(ghi()).toEqual([{ method: "POST", path: "/station-messages", body: {
      submission_code: expect.any(String), recipient_person_id: 5, work_code: "canh", body: "Múc 2 bát cho B3",
      dining_table_id: 3, reply_to_message_id: null,
    } }]);
    expect(goi.some((g) => g.path === "/station-messages/mine")).toBe(false);
  });

  it("A8 người nhận không hoạt động bị từ chối: lời rõ, nháp giữ, lần sau dấu mới", async () => {
    let lanGui = 0;
    const { ghi } = dung(<OChat khung="/quay" />, { phien: () => pos, gui: (b) => {
      lanGui += 1;
      return lanGui === 1 ? json({ code: "message_recipient_invalid" }, 422) : json(tin(70, { body: String(b.body) }), 201);
    } });
    await moBang();
    await soanQuay("Dọn B3", { nguoiNhan: "7", viec: "don_ban" });
    fireEvent.click(nutXemLai());
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận gửi" }));
    expect(await screen.findByText("Người này chưa có tài khoản đang hoạt động hoặc là chính bạn. Chọn người khác.")).toBeTruthy();
    expect(screen.queryByRole("region", { name: "Kiểm tin trước khi gửi" })).toBeNull();
    expect(oNoiDung().value).toBe("Dọn B3");
    chon("Người nhận", "5");
    fireEvent.click(nutXemLai());
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận gửi" }));
    await screen.findByText("Đã gửi tin.");
    const [a, b] = ghi().map((g) => g.body as { submission_code: string; recipient_person_id: number });
    expect(a.recipient_person_id).toBe(7);
    expect(b.recipient_person_id).toBe(5);
    expect(b.submission_code).not.toBe(a.submission_code);
  });

  it("A8 trả lời tin trạm chọn sẵn người gửi tin ấy", async () => {
    const { ghi } = dung(<OChat khung="/quay" />, { phien: () => pos, counter: () => json(trang([
      tin(9, { sender_person_id: 6, sender_name: "Hoa", recipient_person_id: null, recipient_name: null, work_code: "gap_banh", body: "Cần thêm lá" }),
    ])) });
    await moBang();
    fireEvent.click(within(await danhSachTin()).getByRole("button", { name: "Trả lời" }));
    await screen.findByRole("option", { name: "Hoa" });
    expect((screen.getByRole("combobox", { name: "Người nhận" }) as HTMLSelectElement).value).toBe("6");
    chon("Loại việc", "gap_banh");
    fireEvent.change(oNoiDung(), { target: { value: "Đang đem ra" } });
    fireEvent.click(nutXemLai());
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận gửi" }));
    await screen.findByText("Đã gửi tin.");
    expect(ghi()[0].body).toMatchObject({ recipient_person_id: 6, reply_to_message_id: 9 });
  });

  it("A8 chủ quán không đứng quầy gửi bị từ chối: lời rõ, không ghi gì khác", async () => {
    const { ghi } = dung(<OChat khung="/chu-quan" />, { phien: () => chu, gui: () => json({ code: "not_on_counter_duty" }, 403) });
    await moBang();
    await soanQuay("Múc giúp", { nguoiNhan: "5" });
    fireEvent.click(nutXemLai());
    fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận gửi" }));
    expect(await screen.findByText("Bạn không đứng quầy nên chưa gửi tin từ quầy được.")).toBeTruthy();
    expect(ghi().map((g) => g.path)).toEqual(["/station-messages"]);
  });
});

describe.each([
  ["/tram", LayoutTram, lan, ["/sessions/current", "/station-messages/mine", "/assigned-tasks/mine", "/dining-tables"]],
  ["/quay", LayoutQuay, pos, ["/sessions/current", "/station-messages/counter", "/assigned-tasks/mine", "/dining-tables", "/people"]],
  ["/chu-quan", LayoutChuQuan, chu, ["/sessions/current", "/station-messages/counter", "/assigned-tasks/mine", "/dining-tables", "/people"]],
] as const)("CHAT-14 — layout %s", (khung, Layout, phien, duocDoc) => {
  it("G1 layout truyền đúng khung; mở, gõ, đóng chỉ đọc đúng các đường của hộp, không gọi model hay cửa ghi", async () => {
    const { goi, ghi } = dung(<Layout><p>Màn tay</p></Layout>, { phien: () => phien });
    await moBang();
    await screen.findByText("Chưa có tin.");
    fireEvent.change(oNoiDung(), { target: { value: "Nháp" } });
    fireEvent.click(screen.getByRole("button", { name: "Đóng trò chuyện" }));
    expect(ghi()).toEqual([]);
    expect(new Set(goi.map((g) => g.path))).toEqual(new Set(duocDoc));
    expect(screen.getByText("Màn tay")).toBeTruthy();
    expect(khung satisfies Khung).toBe(khung);
  });
});
