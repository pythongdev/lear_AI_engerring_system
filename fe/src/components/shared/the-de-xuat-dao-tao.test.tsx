// Test hồi quy CHAT-16 lát FE — Claude viết TRƯỚC khi có code (2026-11-09). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Đứng trên: ADR-140 điểm 1 · 4 · 5 · 6 · 7; I-031 · I-044; lát BE CHAT-16 (`be/internal/troly/ghi_dao_tao_test.go`, hợp đồng 0.70.0);
// lát FE CHAT-15 (`./the-de-xuat-giao-viec.test.tsx`) giữ nguyên.
//
// Hợp đồng Claude chốt (suy ra của phiên trong khung ADR-140, không phải lời quán; ghi ở entry CHAT-16 *Nhận việc* 2026-11-09 lát FE):
// - `cuaGhiChat` của bản chạy có đúng mười dòng, thứ tự: bốn cửa giao việc của CHAT-15, rồi attachAssignedTaskGuide ·
//   updateAssignedTaskGuide · hideAssignedTaskGuide · createTrainingRecord · updateTrainingRecord · hideTrainingRecord.
//   Cả mười `coDau: false`. `goi` gọi đúng hàm API sinh sẵn của cửa màn tay Đào tạo:
//   POST /assigned-tasks/{assigned_task_id}/guides (multipart) · PUT /assigned-task-guides/{id} · POST /assigned-task-guides/{id}/hiding ·
//   POST /training-records · PUT /training-records/{id} · POST /training-records/{id}/hiding; id lấy từ `path_params`.
//   Năm cửa JSON gửi thân đúng bằng thân của thẻ.
// - `attachAssignedTaskGuide` qua chat CHỈ gửi hướng dẫn chữ (lát BE: tệp ở màn tay): thân multipart có đúng hai phần, theo thứ tự
//   `kind` = "text" (hằng của FE, không lấy từ thẻ) rồi `body` = `body` của thẻ. Khoá nào khác trong thân thẻ (kể cả `file`, URL) KHÔNG
//   đi vào thân gửi, và FE không tải gì từ URL ấy.
// - Sáu cửa có link màn tay riêng: /quay → "/quay/dao-tao", /chu-quan → "/chu-quan/dao-tao", tên "Xem Đào tạo".
// - Tên nguồn của sáu công cụ `gan_huong_dan` · `sua_huong_dan` · `an_huong_dan` · `ghi_nhan_dao_tao` · `sua_ghi_nhan` · `an_ghi_nhan`
//   → "Đào tạo".
// - `createTrainingRecord` có `chonNguoi: "trainee_person_id"`; ô chọn đi đúng luật CHAT-15 (đọc `GET /people` chỉ khi `needs_choice`
//   đúng bằng [chonNguoi], đủ người theo thứ tự backend, không lọc — màn Đào tạo cũng không lọc; đổi lựa chọn là thẻ mới; đã bấm thì
//   khoá; mốc 10 phút từ `read_at` của đề xuất), chỉ khác chữ:
//   ô "Người được ghi", lựa chọn rỗng "Chọn người được ghi", lời CHU_CHON_DT, dòng "Người được ghi: <display_name> (Danh sách người,
//   đọc lúc HH:MM:SS)", đọc lỗi CHU_LOI_NGUOI_DT, danh sách rỗng CHU_KHONG_CO_NGUOI_DT. Chữ của ô chọn giao việc giữ nguyên như CHAT-15.
//   Cách mang chữ theo cửa (trường mới của `CuaGhi` hay cách khác) do người thi công chọn; `chonNguoi` vẫn là chuỗi tên trường.
// - `needs_choice` khác [chonNguoi] của cửa → giữ lời CHAT-11 "Cần chọn trên màn tay: …", không ô chọn, không đọc danh sách người.
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
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
// Phần multipart ghi lại từ FormData.set/append: Node treo khi đọc lại thân FormData của jsdom bằng req.formData().
const phan: [string, string][] = [];
const setGoc = FormData.prototype.set;
const appendGoc = FormData.prototype.append;
beforeEach(() => {
  vi.useFakeTimers({ toFake: ["Date"], now: BAY_GIO });
  vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", "true");
  phan.length = 0;
  for (const [ten, goc] of [["set", setGoc], ["append", appendGoc]] as const) {
    vi.spyOn(FormData.prototype, ten).mockImplementation(function (this: FormData, ...args: [string, string | Blob, string?]) {
      phan.push([args[0], typeof args[1] === "string" ? args[1] : `tệp:${(args[1] as File).name ?? "blob"}`]);
      return Reflect.apply(goc, this, args.filter((a) => a !== undefined));
    });
  }
});
afterEach(() => { cleanup(); vi.useRealTimers(); vi.unstubAllEnvs(); vi.restoreAllMocks(); });

const CHU_DA_GHI = "Đã ghi. Thẻ chưa đọc lại số; xem lại trên màn tay.";
const CHU_CHUA_RO = "Chưa rõ kết quả: chưa nhận được trả lời của quán. Xem lại trên màn tay trước khi làm lại.";
const CHU_QUA_GIO = "Đề xuất đã quá 10 phút từ mốc đọc, không ghi gì. Hỏi lại để có số mới.";
const CHU_CHON_DT = "Chọn người được ghi trước khi ghi.";
const CHU_LOI_NGUOI_DT = "Chưa đọc được danh sách người. Ghi trên màn tay.";
const CHU_KHONG_CO_NGUOI_DT = "Chưa có người để ghi nhận. Ghi trên màn tay.";

const DOC = "2026-11-08T03:00:05Z"; // 10:00:05
const dong = (label: string, value: string, tool: string) => ({ label, value, source: tool, read_at: DOC });
const deGan = {
  tool: "gan_huong_dan",
  operation_id: "attachAssignedTaskGuide",
  path_params: { assigned_task_id: 41 },
  body: { kind: "text", body: "Vớt bánh nhẹ tay, để ráo rồi mới xếp" },
  lines: [dong("Việc", "Tráng bánh", "gan_huong_dan"), dong("Người nhận", "Chị Lan", "gan_huong_dan"),
    dong("Hướng dẫn", "Vớt bánh nhẹ tay, để ráo rồi mới xếp", "gan_huong_dan")],
  needs_choice: [],
};
const deSuaHd = {
  tool: "sua_huong_dan",
  operation_id: "updateAssignedTaskGuide",
  path_params: { assigned_task_guide_id: 51 },
  body: { body: "Vớt bánh bằng đũa dài", reason: "Đổi dụng cụ" },
  lines: [dong("Việc", "Tráng bánh", "sua_huong_dan"), dong("Hướng dẫn", "Vớt bánh nhẹ tay", "sua_huong_dan"),
    dong("Nội dung mới", "Vớt bánh bằng đũa dài", "sua_huong_dan"), dong("Lý do", "Đổi dụng cụ", "sua_huong_dan")],
  needs_choice: [],
};
const deAnHd = {
  tool: "an_huong_dan",
  operation_id: "hideAssignedTaskGuide",
  path_params: { assigned_task_guide_id: 52 },
  body: { reason: "Hướng dẫn cũ" },
  lines: [dong("Việc", "Tráng bánh", "an_huong_dan"), dong("Hướng dẫn", "Vớt bánh nhẹ tay", "an_huong_dan"),
    dong("Lý do", "Hướng dẫn cũ", "an_huong_dan")],
  needs_choice: [],
};
const deGhiNhan = {
  tool: "ghi_nhan_dao_tao",
  operation_id: "createTrainingRecord",
  path_params: {},
  body: { remark: "Tráng đều tay hơn tuần trước", rating: "pass" },
  lines: [dong("Nhận xét", "Tráng đều tay hơn tuần trước", "ghi_nhan_dao_tao"), dong("Đánh giá", "Làm được", "ghi_nhan_dao_tao")],
  needs_choice: ["trainee_person_id"],
};
const deSuaGn = {
  tool: "sua_ghi_nhan",
  operation_id: "updateTrainingRecord",
  path_params: { training_record_id: 61 },
  body: { remark: "Tráng đều tay", rating: "not_yet", reason: "Chấm nhầm" },
  lines: [dong("Về", "Anh Minh", "sua_ghi_nhan"), dong("Nhận xét", "Tráng đều tay", "sua_ghi_nhan"),
    dong("Đánh giá", "Làm được", "sua_ghi_nhan"), dong("Đánh giá mới", "Chưa làm được", "sua_ghi_nhan"),
    dong("Lý do", "Chấm nhầm", "sua_ghi_nhan")],
  needs_choice: [],
};
const deAnGn = {
  tool: "an_ghi_nhan",
  operation_id: "hideTrainingRecord",
  path_params: { training_record_id: 62 },
  body: { reason: "Ghi trùng" },
  lines: [dong("Về", "Anh Minh", "an_ghi_nhan"), dong("Nhận xét", "Tráng đều tay", "an_ghi_nhan"),
    dong("Đánh giá", "Chưa đánh giá", "an_ghi_nhan"), dong("Lý do", "Ghi trùng", "an_ghi_nhan")],
  needs_choice: [],
};
const NGUOI = { people: [
  { person_id: 5, display_name: "Chị Lan", is_owner: false },
  { person_id: 7, display_name: "Anh Minh", is_owner: false },
  { person_id: 1, display_name: "Bà Thanh", is_owner: true },
] };
function traLoi(proposal: unknown) {
  return { answer: "Đã soạn đề xuất, chưa ghi gì.", sources: [], degraded_reason: null, proposal };
}
function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}
const cho = (ms: number) => new Promise((r) => setTimeout(r, ms));

type Goi = { method: string; path: string; multipart: boolean; body: unknown };
type Dung = { turns: unknown[]; khung?: Khung; nguoi?: () => Promise<Response>; ghi?: () => Promise<Response> };
function dung(tuy: Dung) {
  const p = { khung: "/quay" as Khung, nguoi: async () => json(NGUOI), ghi: async () => json({}, 201), ...tuy };
  const hang = [...p.turns];
  const ghiGoi: Goi[] = [];
  const docNguoi: string[] = [];
  const khac: string[] = [];
  const fetch = vi.fn(async (request: Request) => {
    const u = new URL(request.url);
    if (request.method === "POST" && u.pathname === "/api/chat/turns") return json(hang.shift());
    if (request.method === "GET" && u.pathname === "/api/people") { docNguoi.push(u.pathname); return p.nguoi(); }
    if (request.method === "GET") { khac.push(request.url); return json({}, 404); }
    const multipart = (request.headers.get("content-type") ?? "").startsWith("multipart/form-data");
    let body: unknown;
    if (multipart) body = phan.splice(0);
    else { const text = await request.clone().text(); body = text ? JSON.parse(text) : undefined; }
    ghiGoi.push({ method: request.method, path: u.pathname, multipart, body });
    return p.ghi();
  });
  render(<ApiProvider fetch={fetch}><HoiQuan mo khung={p.khung} nguoiBam="Người quầy" /></ApiProvider>);
  return { ghiGoi, docNguoi, khac };
}
function hoi(text = "Ghi nhận Minh tráng đều tay hơn") {
  fireEvent.change(screen.getByRole("textbox", { name: "Câu hỏi" }), { target: { value: text } });
  fireEvent.click(screen.getByRole("button", { name: "Hỏi" }));
}
const the = () => screen.getByRole("group", { name: "Đề xuất ghi" });
const nutGhi = () => within(the()).queryAllByRole("button", { name: "Xác nhận ghi" });
const oChon = () => within(the()).getByRole("combobox", { name: "Người được ghi" }) as HTMLSelectElement;
function coLinkDaoTao(href: string) {
  expect(within(the()).getByRole("link", { name: "Xem Đào tạo" }).getAttribute("href")).toBe(href);
}
async function bamVaChoGhi() {
  fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận ghi" }));
  await waitFor(() => expect(within(the()).getByRole("status").textContent).toContain(CHU_DA_GHI));
}

describe("CHAT-16 FE bảng cửa đào tạo của bản chạy", () => {
  it("A1 bảng có đúng mười cửa, giao việc trước rồi sáu cửa đào tạo, không cửa nào có dấu", () => {
    expect(Object.keys(cuaGhiChat)).toEqual([
      "createAssignedTask", "updateAssignedTask", "hideAssignedTask", "markAssignedTask",
      "attachAssignedTaskGuide", "updateAssignedTaskGuide", "hideAssignedTaskGuide",
      "createTrainingRecord", "updateTrainingRecord", "hideTrainingRecord",
    ]);
    for (const cua of Object.values(cuaGhiChat)) expect(cua.coDau).toBe(false);
    expect(cuaGhiChat.createTrainingRecord.chonNguoi).toBe("trainee_person_id");
    expect(cuaGhiChat.createAssignedTask.chonNguoi).toBe("assignee_person_id");
    for (const op of ["attachAssignedTaskGuide", "updateAssignedTaskGuide", "hideAssignedTaskGuide", "updateTrainingRecord", "hideTrainingRecord"]) {
      expect(cuaGhiChat[op].chonNguoi).toBeUndefined();
    }
    for (const op of ["attachAssignedTaskGuide", "updateAssignedTaskGuide", "hideAssignedTaskGuide",
      "createTrainingRecord", "updateTrainingRecord", "hideTrainingRecord"]) {
      expect(cuaGhiChat[op].manTay).toEqual({
        "/quay": { href: "/quay/dao-tao", ten: "Xem Đào tạo" },
        "/chu-quan": { href: "/chu-quan/dao-tao", ten: "Xem Đào tạo" },
      });
    }
    expect(Object.isFrozen(cuaGhiChat)).toBe(true);
  });

  it.each([
    ["sửa hướng dẫn", deSuaHd, "PUT", "/api/assigned-task-guides/51", "Nội dung mới: Vớt bánh bằng đũa dài (Đào tạo, đọc lúc 10:00:05)"],
    ["ẩn hướng dẫn", deAnHd, "POST", "/api/assigned-task-guides/52/hiding", "Lý do: Hướng dẫn cũ (Đào tạo, đọc lúc 10:00:05)"],
    ["sửa ghi nhận", deSuaGn, "PUT", "/api/training-records/61", "Đánh giá mới: Chưa làm được (Đào tạo, đọc lúc 10:00:05)"],
    ["ẩn ghi nhận", deAnGn, "POST", "/api/training-records/62/hiding", "Đánh giá: Chưa đánh giá (Đào tạo, đọc lúc 10:00:05)"],
  ])("A2 %s: bấm gọi đúng cửa màn tay với đúng thân JSON, không đọc danh sách người", async (_ten, de, method, path, dongThe) => {
    const { ghiGoi, docNguoi } = dung({ turns: [traLoi(de)], ghi: async () => json({}) });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).getByText(dongThe)).toBeTruthy();
    expect(within(the()).getByText("Người bấm: Người quầy")).toBeTruthy();
    expect(within(the()).queryByRole("combobox")).toBeNull();
    coLinkDaoTao("/quay/dao-tao");
    await bamVaChoGhi();
    expect(ghiGoi).toEqual([{ method, path, multipart: false, body: de.body }]);
    expect(docNguoi).toHaveLength(0);
  });

  it("A2 gắn hướng dẫn: multipart đúng hai phần kind=text rồi body, không phần tệp", async () => {
    const { ghiGoi, docNguoi } = dung({ turns: [traLoi(deGan)] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).getByText("Hướng dẫn: Vớt bánh nhẹ tay, để ráo rồi mới xếp (Đào tạo, đọc lúc 10:00:05)")).toBeTruthy();
    coLinkDaoTao("/quay/dao-tao");
    await bamVaChoGhi();
    expect(ghiGoi).toEqual([{ method: "POST", path: "/api/assigned-tasks/41/guides", multipart: true,
      body: [["kind", "text"], ["body", "Vớt bánh nhẹ tay, để ráo rồi mới xếp"]] }]);
    expect(docNguoi).toHaveLength(0);
  });

  it("A2 gắn hướng dẫn: thẻ mang khoá lạ (tệp, URL, kind khác) thì thân gửi vẫn chỉ kind=text và body, không tải URL", async () => {
    const la = { ...deGan, body: { kind: "image", body: "Xem ảnh", file: "https://vi-du.invalid/anh.jpg", url: "https://vi-du.invalid/x" } };
    const { ghiGoi, khac } = dung({ turns: [traLoi(la)] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    await bamVaChoGhi();
    expect(ghiGoi).toEqual([{ method: "POST", path: "/api/assigned-tasks/41/guides", multipart: true,
      body: [["kind", "text"], ["body", "Xem ảnh"]] }]);
    expect(khac).toHaveLength(0);
  });

  it("A2 cửa từ chối: nói chưa ghi kèm mã, khoá thẻ, một lần gọi", async () => {
    const { ghiGoi } = dung({ turns: [traLoi(deSuaHd)], ghi: async () => json({ code: "assigned_task_guide_not_text" }, 409) });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    fireEvent.click(nutGhi()[0]);
    expect((await within(the()).findByRole("alert")).textContent).toContain("Chưa ghi: cửa từ chối (assigned_task_guide_not_text).");
    expect(within(the()).queryAllByRole("button")).toHaveLength(0);
    await cho(50);
    expect(ghiGoi).toHaveLength(1);
  });

  it("A2 mất phản hồi: chưa rõ kết quả, không Gửi lại vì cửa không có dấu, link về Đào tạo của chủ quán", async () => {
    const { ghiGoi } = dung({ turns: [traLoi(deAnGn)], khung: "/chu-quan", ghi: async () => { throw new Error("mất mạng"); } });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    fireEvent.click(nutGhi()[0]);
    expect((await within(the()).findByRole("alert")).textContent).toContain(CHU_CHUA_RO);
    expect(within(the()).queryAllByRole("button")).toHaveLength(0);
    coLinkDaoTao("/chu-quan/dao-tao");
    await cho(50);
    expect(ghiGoi).toHaveLength(1);
  });
});

describe("CHAT-16 FE ghi nhận mới: chọn người được ghi trên thẻ", () => {
  it("A3 chưa chọn thì không nút ghi; ô chọn có đủ người theo thứ tự backend, không lọc", async () => {
    const { ghiGoi, docNguoi } = dung({ turns: [traLoi(deGhiNhan)] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).getByText("Nhận xét: Tráng đều tay hơn tuần trước (Đào tạo, đọc lúc 10:00:05)")).toBeTruthy();
    expect(within(the()).getByText("Đánh giá: Làm được (Đào tạo, đọc lúc 10:00:05)")).toBeTruthy();
    await waitFor(() => expect(oChon().options).toHaveLength(4));
    expect([...oChon().options].map((o) => [o.value, o.textContent])).toEqual([
      ["", "Chọn người được ghi"], ["5", "Chị Lan"], ["7", "Anh Minh"], ["1", "Bà Thanh"],
    ]);
    expect(within(the()).queryByRole("combobox", { name: "Người nhận" })).toBeNull();
    expect(within(the()).getByText(CHU_CHON_DT)).toBeTruthy();
    expect(within(the()).queryByText(/Cần chọn trên màn tay/)).toBeNull();
    expect(nutGhi()).toHaveLength(0);
    coLinkDaoTao("/quay/dao-tao");
    expect(docNguoi).toHaveLength(1);
    expect(ghiGoi).toHaveLength(0);
  });

  it("A3 chọn người: hiện dòng người được ghi có nguồn và mốc đọc; bấm gửi thân cộng đúng trainee_person_id", async () => {
    const { ghiGoi } = dung({ turns: [traLoi(deGhiNhan)] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    await waitFor(() => expect(oChon().options).toHaveLength(4));
    fireEvent.change(oChon(), { target: { value: "5" } });
    fireEvent.change(oChon(), { target: { value: "7" } });
    expect(within(the()).queryByText(/Người được ghi: Chị Lan/)).toBeNull();
    expect(within(the()).getByText("Người được ghi: Anh Minh (Danh sách người, đọc lúc 10:01:00)")).toBeTruthy();
    expect(within(the()).queryByText(/^Người nhận:/)).toBeNull();
    expect(within(the()).queryByText(CHU_CHON_DT)).toBeNull();
    await bamVaChoGhi();
    expect(oChon().disabled).toBe(true);
    expect(ghiGoi).toEqual([{ method: "POST", path: "/api/training-records", multipart: false,
      body: { remark: "Tráng đều tay hơn tuần trước", rating: "pass", trainee_person_id: 7 } }]);
  });

  it.each([
    ["đọc danh sách lỗi", async () => json({ code: "internal" }, 500), CHU_LOI_NGUOI_DT],
    ["mất kết nối khi đọc", async (): Promise<Response> => { throw new Error("mất mạng"); }, CHU_LOI_NGUOI_DT],
    ["danh sách rỗng", async () => json({ people: [] }), CHU_KHONG_CO_NGUOI_DT],
  ])("A4 %s: không nút ghi, có lời và link Đào tạo", async (_ten, nguoi, chu) => {
    const { ghiGoi } = dung({ turns: [traLoi(deGhiNhan)], nguoi });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(await within(the()).findByText(chu)).toBeTruthy();
    expect(nutGhi()).toHaveLength(0);
    coLinkDaoTao("/quay/dao-tao");
    await cho(50);
    expect(ghiGoi).toHaveLength(0);
  });

  it("A4 needs_choice không khớp trường chọn của cửa: giữ lời CHAT-11, không ô chọn, không đọc danh sách người", async () => {
    const { ghiGoi, docNguoi } = dung({ turns: [traLoi({ ...deGhiNhan, needs_choice: ["assignee_person_id"] })] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).getByText("Cần chọn trên màn tay: assignee_person_id.")).toBeTruthy();
    expect(within(the()).queryByRole("combobox")).toBeNull();
    expect(nutGhi()).toHaveLength(0);
    await cho(50);
    expect(docNguoi).toHaveLength(0);
    expect(ghiGoi).toHaveLength(0);
  });

  it("A4 chọn người không kéo dài mốc 10 phút: bấm lúc đủ 10 phút từ read_at của đề xuất thì không ghi", async () => {
    const { ghiGoi } = dung({ turns: [traLoi(deGhiNhan)] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    await waitFor(() => expect(oChon().options).toHaveLength(4));
    fireEvent.change(oChon(), { target: { value: "5" } });
    vi.setSystemTime(new Date(Date.parse(DOC) + 10 * 60 * 1000));
    fireEvent.click(nutGhi()[0]);
    expect(await within(the()).findByText(CHU_QUA_GIO)).toBeTruthy();
    await cho(50);
    expect(ghiGoi).toHaveLength(0);
  });
});
