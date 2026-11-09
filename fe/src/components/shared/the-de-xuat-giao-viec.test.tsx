// Test hồi quy CHAT-15 lát FE — Claude viết TRƯỚC khi có code (2026-11-09). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Đứng trên: ADR-140 điểm 1 · 4 · 5 · 6 · 7; I-030 · I-044; lát BE CHAT-15 (`be/internal/troly/ghi_giao_viec_test.go`, hợp đồng 0.69.0).
//
// Hợp đồng Claude chốt (suy ra của phiên trong khung ADR-140, không phải lời quán; ghi ở entry CHAT-15 *Nhận việc* 2026-11-09 lát FE):
// - `cuaGhiChat` của bản chạy có đúng bốn dòng, thứ tự: createAssignedTask · updateAssignedTask · hideAssignedTask · markAssignedTask.
//   Cả bốn `coDau: false` (hợp đồng không có `submission_code` cho các cửa này). `goi` gọi đúng hàm API sinh sẵn của cửa màn tay:
//   POST /assigned-tasks · PUT /assigned-tasks/{id} · POST /assigned-tasks/{id}/hiding · POST /assigned-tasks/{id}/marks,
//   `assigned_task_id` lấy từ `path_params`, thân gửi đúng bằng thân của thẻ.
// - `CuaGhi` thêm hai trường tuỳ chọn:
//   * `manTay?: Partial<Record<Khung, { href: string; ten: string }>>` — link màn tay riêng của cửa; thiếu thì dùng `manTay` theo khung
//     như CHAT-11. Bốn cửa giao việc: /quay → "/quay/giao-viec", /chu-quan → "/chu-quan/giao-viec", cả hai tên "Xem Giao việc".
//   * `chonNguoi?: string` — tên trường thân mà thẻ được điền bằng một người chọn từ `GET /people` (nguồn màn Giao việc dùng). Chỉ
//     createAssignedTask có `chonNguoi: "assignee_person_id"`.
// - Tên nguồn của bốn công cụ: `giao_viec` · `sua_viec` · `an_viec` · `danh_dau_viec` → "Giao việc".
// - Thẻ có `needs_choice` đúng bằng [chonNguoi của cửa]: đọc `GET /people` (chỉ khi ấy; thẻ khác không đọc), hiện ô chọn native
//   `select` tên "Người nhận", lựa chọn đầu "Chọn người nhận" giá trị rỗng rồi mỗi người một lựa chọn đúng `display_name`, theo thứ tự
//   backend trả, không lọc. Chưa chọn thì không nút "Xác nhận ghi" và có lời CHU_CHON. Chọn rồi thì hiện thêm một dòng
//   "Người nhận: <display_name> (Danh sách người, đọc lúc HH:MM:SS)" (mốc là lúc đọc xong danh sách) và nút "Xác nhận ghi";
//   bấm gửi thân của đề xuất cộng `<chonNguoi>: person_id`. Đổi lựa chọn là thẻ mới (ADR-140 điểm 5): thân gửi theo lựa chọn đang hiện.
//   Đã bấm thì ô chọn bị khoá và không đổi được người đang hiện. Mốc 10 phút vẫn tính từ `read_at` sớm nhất của đề xuất, lần đọc danh
//   sách người không kéo dài nó. Đọc danh sách lỗi → CHU_LOI_NGUOI, danh sách rỗng → CHU_KHONG_CO_NGUOI; cả hai không nút ghi, vẫn có
//   link màn tay. `needs_choice` có trường nào khác `chonNguoi` của cửa → giữ lời CHAT-11 "Cần chọn trên màn tay: …", không ô chọn.
import { act, cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { ApiProvider } from "@/lib/api/provider";
import type { Khung } from "@/lib/auth/khung";
import { HoiQuan } from "./hoi-quan";
import { cuaGhiChat } from "./the-de-xuat";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ replace: vi.fn(), push: vi.fn() }),
  usePathname: () => "/quay",
  useSearchParams: () => new URLSearchParams(),
}));

const BAY_GIO = new Date("2026-11-08T03:01:00Z"); // 10:01:00 giờ Việt Nam
beforeEach(() => {
  vi.useFakeTimers({ toFake: ["Date"], now: BAY_GIO });
  vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", "true");
});
afterEach(() => { cleanup(); vi.useRealTimers(); vi.unstubAllEnvs(); });

const CHU_DA_GHI = "Đã ghi. Thẻ chưa đọc lại số; xem lại trên màn tay.";
const CHU_CHUA_RO = "Chưa rõ kết quả: chưa nhận được trả lời của quán. Xem lại trên màn tay trước khi làm lại.";
const CHU_QUA_GIO = "Đề xuất đã quá 10 phút từ mốc đọc, không ghi gì. Hỏi lại để có số mới.";
const CHU_CHON = "Chọn người nhận trước khi ghi.";
const CHU_LOI_NGUOI = "Chưa đọc được danh sách người. Giao trên màn tay.";
const CHU_KHONG_CO_NGUOI = "Chưa có người để giao. Giao trên màn tay.";

const DOC = "2026-11-08T03:00:05Z"; // 10:00:05
const HAN = "2026-11-08T17:00:00+07:00";
const dong = (label: string, value: string, tool: string) => ({ label, value, source: tool, read_at: DOC });
const deGiao = {
  tool: "giao_viec",
  operation_id: "createAssignedTask",
  path_params: {},
  body: { content: "Rửa nồi lớn", due_at: HAN },
  lines: [dong("Nội dung", "Rửa nồi lớn", "giao_viec"), dong("Hạn", "17:00 ngày 08/11/2026", "giao_viec")],
  needs_choice: ["assignee_person_id"],
};
const deSua = {
  tool: "sua_viec",
  operation_id: "updateAssignedTask",
  path_params: { assigned_task_id: 41 },
  body: { content: "Rửa nồi lớn và nồi nhỏ", assignee_person_id: 5, reason: "Thêm nồi nhỏ" },
  lines: [dong("Việc", "Rửa nồi lớn", "sua_viec"), dong("Người nhận", "Chị Lan", "sua_viec"),
    dong("Nội dung mới", "Rửa nồi lớn và nồi nhỏ", "sua_viec"), dong("Lý do", "Thêm nồi nhỏ", "sua_viec")],
  needs_choice: [],
};
const deAn = {
  tool: "an_viec",
  operation_id: "hideAssignedTask",
  path_params: { assigned_task_id: 42 },
  body: { reason: "Giao trùng" },
  lines: [dong("Việc", "Lau bàn", "an_viec"), dong("Người nhận", "Anh Minh", "an_viec"), dong("Lý do", "Giao trùng", "an_viec")],
  needs_choice: [],
};
const deDanhDau = {
  tool: "danh_dau_viec",
  operation_id: "markAssignedTask",
  path_params: { assigned_task_id: 43 },
  body: { mark: "done" },
  lines: [dong("Việc", "Phơi khăn", "danh_dau_viec"), dong("Người nhận", "Anh Minh", "danh_dau_viec"),
    dong("Hiện tại", "Chưa xong", "danh_dau_viec"), dong("Đổi thành", "Đã xong", "danh_dau_viec")],
  needs_choice: [],
};
const NGUOI = { people: [
  { person_id: 5, display_name: "Chị Lan", is_owner: false },
  { person_id: 7, display_name: "Anh Minh", is_owner: false },
  { person_id: 1, display_name: "Bà Thanh", is_owner: true },
] };
const viec = (id: number) => ({ assigned_task_id: id });
function traLoi(proposal: unknown) {
  return { answer: "Đã soạn đề xuất, chưa ghi gì.", sources: [], degraded_reason: null, proposal };
}
function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}
const cho = (ms: number) => new Promise((r) => setTimeout(r, ms));

type Dung = { turns: unknown[]; khung?: Khung; nguoi?: () => Promise<Response>; ghi?: (r: Request) => Promise<Response> };
function dung(tuy: Dung) {
  const p = { khung: "/quay" as Khung, nguoi: async () => json(NGUOI), ghi: async () => json(viec(1), 201), ...tuy };
  const hang = [...p.turns];
  const fetch = vi.fn(async (request: Request) => {
    const path = new URL(request.url).pathname;
    if (request.method === "POST" && path === "/api/chat/turns") return json(hang.shift());
    if (request.method === "GET" && path === "/api/people") return p.nguoi();
    return p.ghi(request);
  });
  render(<ApiProvider fetch={fetch}><HoiQuan mo khung={p.khung} nguoiBam="Người quầy" /></ApiProvider>);
  const loc = (f: (r: Request) => boolean) => fetch.mock.calls.map(([r]) => r).filter(f);
  return {
    docNguoi: () => loc((r) => new URL(r.url).pathname === "/api/people"),
    ghiGoi: () => loc((r) => r.method !== "GET" && new URL(r.url).pathname !== "/api/chat/turns"),
  };
}
function hoi(text = "Giao rửa nồi lớn hạn 5 giờ chiều") {
  fireEvent.change(screen.getByRole("textbox", { name: "Câu hỏi" }), { target: { value: text } });
  fireEvent.click(screen.getByRole("button", { name: "Hỏi" }));
}
const the = () => screen.getByRole("group", { name: "Đề xuất ghi" });
const nutGhi = () => within(the()).queryAllByRole("button", { name: "Xác nhận ghi" });
const oChon = () => within(the()).getByRole("combobox", { name: "Người nhận" }) as HTMLSelectElement;
function coLinkGiaoViec(href: string) {
  expect(within(the()).getByRole("link", { name: "Xem Giao việc" }).getAttribute("href")).toBe(href);
}
async function bamVaChoGhi() {
  fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận ghi" }));
  await waitFor(() => expect(within(the()).getByRole("status").textContent).toContain(CHU_DA_GHI));
}

describe("CHAT-15 FE bảng cửa giao việc của bản chạy", () => {
  it("A1 bảng có đúng bốn cửa giao việc, không cửa nào có dấu, chỉ giao mới được chọn người", () => {
    expect(Object.keys(cuaGhiChat)).toEqual(["createAssignedTask", "updateAssignedTask", "hideAssignedTask", "markAssignedTask"]);
    for (const cua of Object.values(cuaGhiChat)) expect(cua.coDau).toBe(false);
    expect(cuaGhiChat.createAssignedTask.chonNguoi).toBe("assignee_person_id");
    for (const op of ["updateAssignedTask", "hideAssignedTask", "markAssignedTask"]) expect(cuaGhiChat[op].chonNguoi).toBeUndefined();
    expect(Object.isFrozen(cuaGhiChat)).toBe(true);
  });

  it.each([
    ["sửa", deSua, "PUT", "/api/assigned-tasks/41", "Việc: Rửa nồi lớn (Giao việc, đọc lúc 10:00:05)"],
    ["ẩn", deAn, "POST", "/api/assigned-tasks/42/hiding", "Lý do: Giao trùng (Giao việc, đọc lúc 10:00:05)"],
    ["đánh dấu", deDanhDau, "POST", "/api/assigned-tasks/43/marks", "Đổi thành: Đã xong (Giao việc, đọc lúc 10:00:05)"],
  ])("A2 %s: bấm gọi đúng cửa màn tay với đúng thân, không đọc danh sách người", async (_ten, de, method, path, dongThe) => {
    const { ghiGoi, docNguoi } = dung({ turns: [traLoi(de)], ghi: async () => json(viec(de.path_params.assigned_task_id)) });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).getByText(dongThe)).toBeTruthy();
    expect(within(the()).getByText("Người bấm: Người quầy")).toBeTruthy();
    expect(within(the()).queryByRole("combobox")).toBeNull();
    coLinkGiaoViec("/quay/giao-viec");
    await bamVaChoGhi();
    const goi = ghiGoi();
    expect(goi).toHaveLength(1);
    expect(goi[0].method).toBe(method);
    expect(new URL(goi[0].url).pathname).toBe(path);
    expect(await goi[0].clone().json()).toEqual(de.body);
    expect(docNguoi()).toHaveLength(0);
  });

  it("A2 cửa từ chối: nói chưa ghi kèm mã, khoá thẻ, một lần gọi", async () => {
    const { ghiGoi } = dung({ turns: [traLoi(deDanhDau)], ghi: async () => json({ code: "assigned_task_already_done" }, 409) });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    fireEvent.click(nutGhi()[0]);
    expect((await within(the()).findByRole("alert")).textContent).toContain("Chưa ghi: cửa từ chối (assigned_task_already_done).");
    expect(within(the()).queryAllByRole("button")).toHaveLength(0);
    await cho(50);
    expect(ghiGoi()).toHaveLength(1);
  });

  it("A2 mất phản hồi: chưa rõ kết quả, không Gửi lại vì cửa không có dấu, link về Giao việc", async () => {
    const { ghiGoi } = dung({ turns: [traLoi(deAn)], khung: "/chu-quan", ghi: async () => { throw new Error("mất mạng"); } });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    fireEvent.click(nutGhi()[0]);
    expect((await within(the()).findByRole("alert")).textContent).toContain(CHU_CHUA_RO);
    expect(within(the()).queryAllByRole("button")).toHaveLength(0);
    coLinkGiaoViec("/chu-quan/giao-viec");
    await cho(50);
    expect(ghiGoi()).toHaveLength(1);
  });
});

describe("CHAT-15 FE giao mới: chọn người nhận trên thẻ", () => {
  it("A3 chưa chọn thì không nút ghi; ô chọn có đủ người theo thứ tự backend, không lọc", async () => {
    const { ghiGoi, docNguoi } = dung({ turns: [traLoi(deGiao)] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).getByText("Nội dung: Rửa nồi lớn (Giao việc, đọc lúc 10:00:05)")).toBeTruthy();
    expect(within(the()).getByText("Hạn: 17:00 ngày 08/11/2026 (Giao việc, đọc lúc 10:00:05)")).toBeTruthy();
    await waitFor(() => expect(oChon().options).toHaveLength(4));
    expect([...oChon().options].map((o) => [o.value, o.textContent])).toEqual([
      ["", "Chọn người nhận"], ["5", "Chị Lan"], ["7", "Anh Minh"], ["1", "Bà Thanh"],
    ]);
    expect(oChon().value).toBe("");
    expect(within(the()).getByText(CHU_CHON)).toBeTruthy();
    expect(within(the()).queryByText(/Cần chọn trên màn tay/)).toBeNull();
    expect(nutGhi()).toHaveLength(0);
    coLinkGiaoViec("/quay/giao-viec");
    expect(docNguoi()).toHaveLength(1);
    expect(ghiGoi()).toHaveLength(0);
  });

  it("A3 chọn người: hiện dòng người nhận có nguồn và mốc đọc; bấm gửi thân cộng đúng person_id", async () => {
    const { ghiGoi } = dung({ turns: [traLoi(deGiao)] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    await waitFor(() => expect(oChon().options).toHaveLength(4));
    fireEvent.change(oChon(), { target: { value: "7" } });
    expect(within(the()).getByText("Người nhận: Anh Minh (Danh sách người, đọc lúc 10:01:00)")).toBeTruthy();
    expect(within(the()).queryByText(CHU_CHON)).toBeNull();
    expect(nutGhi()).toHaveLength(1);
    await bamVaChoGhi();
    const goi = ghiGoi();
    expect(goi).toHaveLength(1);
    expect(goi[0].method).toBe("POST");
    expect(new URL(goi[0].url).pathname).toBe("/api/assigned-tasks");
    expect(await goi[0].clone().json()).toEqual({ content: "Rửa nồi lớn", due_at: HAN, assignee_person_id: 7 });
  });

  it("A3 đổi lựa chọn là thẻ mới: thân gửi theo người đang hiện; đã bấm thì khoá ô chọn", async () => {
    let tra!: (r: Response) => void;
    const { ghiGoi } = dung({ turns: [traLoi(deGiao)], ghi: () => new Promise((r) => { tra = r; }) });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    await waitFor(() => expect(oChon().options).toHaveLength(4));
    fireEvent.change(oChon(), { target: { value: "7" } });
    fireEvent.change(oChon(), { target: { value: "5" } });
    expect(within(the()).queryByText(/Người nhận: Anh Minh/)).toBeNull();
    expect(within(the()).getByText("Người nhận: Chị Lan (Danh sách người, đọc lúc 10:01:00)")).toBeTruthy();
    fireEvent.click(nutGhi()[0]);
    await waitFor(() => expect(ghiGoi()).toHaveLength(1));
    expect(oChon().disabled).toBe(true);
    fireEvent.change(oChon(), { target: { value: "7" } });
    expect(within(the()).getByText("Người nhận: Chị Lan (Danh sách người, đọc lúc 10:01:00)")).toBeTruthy();
    await act(async () => { tra(json(viec(9), 201)); });
    await waitFor(() => expect(within(the()).getByRole("status").textContent).toContain(CHU_DA_GHI));
    expect(oChon().disabled).toBe(true);
    expect(await ghiGoi()[0].clone().json()).toEqual({ content: "Rửa nồi lớn", due_at: HAN, assignee_person_id: 5 });
    await cho(50);
    expect(ghiGoi()).toHaveLength(1);
  });

  it("A3 chọn lại lựa chọn rỗng: mất dòng người nhận và nút ghi", async () => {
    const { ghiGoi } = dung({ turns: [traLoi(deGiao)] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    await waitFor(() => expect(oChon().options).toHaveLength(4));
    fireEvent.change(oChon(), { target: { value: "5" } });
    fireEvent.change(oChon(), { target: { value: "" } });
    expect(within(the()).queryByText(/^Người nhận:/)).toBeNull();
    expect(within(the()).getByText(CHU_CHON)).toBeTruthy();
    expect(nutGhi()).toHaveLength(0);
    expect(ghiGoi()).toHaveLength(0);
  });

  it.each([
    ["đọc danh sách lỗi", async () => json({ code: "internal" }, 500), CHU_LOI_NGUOI],
    ["mất kết nối khi đọc", async (): Promise<Response> => { throw new Error("mất mạng"); }, CHU_LOI_NGUOI],
    ["danh sách rỗng", async () => json({ people: [] }), CHU_KHONG_CO_NGUOI],
  ])("A4 %s: không nút ghi, có lời và link Giao việc", async (_ten, nguoi, chu) => {
    const { ghiGoi } = dung({ turns: [traLoi(deGiao)], nguoi });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(await within(the()).findByText(chu)).toBeTruthy();
    expect(nutGhi()).toHaveLength(0);
    coLinkGiaoViec("/quay/giao-viec");
    await cho(50);
    expect(ghiGoi()).toHaveLength(0);
  });

  it("A4 còn trường cần chọn khác người nhận: giữ lời CHAT-11, không ô chọn, không đọc danh sách người", async () => {
    const { ghiGoi, docNguoi } = dung({ turns: [traLoi({ ...deGiao, needs_choice: ["assignee_person_id", "due_at"] })] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).getByText("Cần chọn trên màn tay: assignee_person_id, due_at.")).toBeTruthy();
    expect(within(the()).queryByRole("combobox")).toBeNull();
    expect(nutGhi()).toHaveLength(0);
    await cho(50);
    expect(docNguoi()).toHaveLength(0);
    expect(ghiGoi()).toHaveLength(0);
  });

  it("A4 chọn người không kéo dài mốc 10 phút: bấm lúc đủ 10 phút từ read_at của đề xuất thì không ghi", async () => {
    const { ghiGoi } = dung({ turns: [traLoi(deGiao)] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    await waitFor(() => expect(oChon().options).toHaveLength(4));
    fireEvent.change(oChon(), { target: { value: "5" } });
    vi.setSystemTime(new Date(Date.parse(DOC) + 10 * 60 * 1000));
    fireEvent.click(nutGhi()[0]);
    expect(await within(the()).findByText(CHU_QUA_GIO)).toBeTruthy();
    await cho(50);
    expect(ghiGoi()).toHaveLength(0);
  });
});
