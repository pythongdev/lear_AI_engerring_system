// Test hồi quy CHAT-17 lát FE — Claude viết TRƯỚC khi có code (2026-11-10). Người thi công làm cho xanh, KHÔNG sửa điều kiện kiểm.
// Đứng trên: ADR-140 điểm 1 · 4 · 5 · 6 · 7; I-025 · I-026 · I-044; lát BE CHAT-17 (`be/internal/troly/ghi_nguyen_lieu_test.go`, hợp đồng
// 0.72.0); lát FE CHAT-15 (`./the-de-xuat-giao-viec.test.tsx`) và CHAT-16 (`./the-de-xuat-dao-tao.test.tsx`) giữ nguyên.
//
// Hợp đồng Claude chốt (suy ra của phiên trong khung ADR-140, không phải lời quán; ghi ở entry CHAT-17 *Nhận việc* 2026-11-10 lát FE):
// - `cuaGhiChat` của bản chạy có đúng mười lăm dòng, thứ tự: mười cửa của CHAT-15 · CHAT-16, rồi createSupplyItem ·
//   setSupplyItemPurchaseUnit · createSupplyDayEntry · updateSupplyDayEntry · setSupplyItemReminderRatio. Cả mười lăm `coDau: false`
//   (năm cửa C07 không có `submission_code`). Năm cửa nguyên liệu không có `chonNguoi`.
// - `goi` gọi đúng hàm API sinh sẵn của cửa màn tay Nguyên liệu: POST /supply-items · PUT /supply-items/{supply_item_id}/purchase-unit ·
//   POST /supply-day-entries · PUT /supply-day-entries/{supply_day_entry_id} · PUT /supply-items/{supply_item_id}/reminder-ratio; id lấy
//   từ `path_params`. Thân gửi ĐÚNG BẰNG thân của thẻ: con số (`measure`) và tỉ lệ (`reminder_ratio`) vẫn là CHUỖI như hợp đồng,
//   không đổi sang số, không làm tròn, không thêm hay bỏ khoá; ngày (`entry_date`) giữ nguyên `YYYY-MM-DD` của thẻ.
// - Năm cửa chỉ có link màn tay của chủ quán: `{ "/chu-quan": { href: "/chu-quan/nguyen-lieu", ten: "Xem Nguyên liệu" } }` — không có dòng
//   `/quay` vì lớp `chu_quan`; khung khác dùng link mặc định của khung (CHAT-09). FE không tự chặn theo khung: quyền là của cửa backend.
// - Tên nguồn của năm công cụ `them_nguyen_lieu` · `dat_don_vi` · `ghi_so_nguyen_lieu` · `sua_so_nguyen_lieu` · `dat_ti_le_nhac`
//   → "Nguyên liệu".
// - Ghi xong thẻ không đọc lại sổ hay kho (giữ chữ CHAT-11 "Thẻ chưa đọc lại số"); không có lệnh GET nào ngoài lượt chat.
import { cleanup, fireEvent, render, screen, waitFor, within } from "@testing-library/react";
import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";

import { ApiProvider } from "@/lib/api/provider";
import type { Khung } from "@/lib/auth/khung";
import { HoiQuan } from "./hoi-quan";
import { cuaGhiChat } from "./the-de-xuat";

vi.mock("next/navigation", () => ({
  useRouter: () => ({ replace: vi.fn(), push: vi.fn() }),
  usePathname: () => "/chu-quan",
  useSearchParams: () => new URLSearchParams(),
}));

const BAY_GIO = new Date("2026-11-10T03:01:00Z"); // 10:01:00 giờ Việt Nam
beforeEach(() => {
  vi.useFakeTimers({ toFake: ["Date"], now: BAY_GIO });
  vi.stubEnv("NEXT_PUBLIC_CHAT_ENABLED", "true");
});
afterEach(() => { cleanup(); vi.useRealTimers(); vi.unstubAllEnvs(); vi.restoreAllMocks(); });

const CHU_DA_GHI = "Đã ghi. Thẻ chưa đọc lại số; xem lại trên màn tay.";
const CHU_CHUA_RO = "Chưa rõ kết quả: chưa nhận được trả lời của quán. Xem lại trên màn tay trước khi làm lại.";

const DOC = "2026-11-10T03:00:05Z"; // 10:00:05
const dong = (label: string, value: string, tool: string) => ({ label, value, source: tool, read_at: DOC });
const deThem = {
  tool: "them_nguyen_lieu",
  operation_id: "createSupplyItem",
  path_params: {},
  body: { name: "Hành khô", purchase_unit: "kg" },
  lines: [dong("Tên", "Hành khô", "them_nguyen_lieu"), dong("Đơn vị", "kg", "them_nguyen_lieu")],
  needs_choice: [],
};
const deDonVi = {
  tool: "dat_don_vi",
  operation_id: "setSupplyItemPurchaseUnit",
  path_params: { supply_item_id: 21 },
  body: { purchase_unit: "bó" },
  lines: [dong("Nguyên liệu", "Hành lá", "dat_don_vi"), dong("Đơn vị", "bó", "dat_don_vi")],
  needs_choice: [],
};
const deGhiSo = {
  tool: "ghi_so_nguyen_lieu",
  operation_id: "createSupplyDayEntry",
  path_params: {},
  body: { supply_item_id: 22, entry_date: "2026-11-09", kind: "purchased", measure: "2.5" },
  lines: [dong("Nguyên liệu", "Thịt nạc vai", "ghi_so_nguyen_lieu"), dong("Ngày", "09/11/2026", "ghi_so_nguyen_lieu"),
    dong("Loại", "Mua vào", "ghi_so_nguyen_lieu"), dong("Con số", "2.5 kg", "ghi_so_nguyen_lieu")],
  needs_choice: [],
};
const deSuaSo = {
  tool: "sua_so_nguyen_lieu",
  operation_id: "updateSupplyDayEntry",
  path_params: { supply_day_entry_id: 71 },
  body: { measure: "0.125", reason: "Cân lại" },
  lines: [dong("Nguyên liệu", "Thịt nạc vai", "sua_so_nguyen_lieu"), dong("Ngày", "09/11/2026", "sua_so_nguyen_lieu"),
    dong("Loại", "Đã dùng", "sua_so_nguyen_lieu"), dong("Con số hiện tại", "1.2 kg", "sua_so_nguyen_lieu"),
    dong("Con số mới", "0.125 kg", "sua_so_nguyen_lieu"), dong("Lý do", "Cân lại", "sua_so_nguyen_lieu")],
  needs_choice: [],
};
const deTiLe = {
  tool: "dat_ti_le_nhac",
  operation_id: "setSupplyItemReminderRatio",
  path_params: { supply_item_id: 22 },
  body: { reminder_ratio: "0.300", reason: "Nhắc sớm hơn" },
  lines: [dong("Nguyên liệu", "Thịt nạc vai", "dat_ti_le_nhac"), dong("Tỉ lệ nhắc hiện tại", "0.2", "dat_ti_le_nhac"),
    dong("Tỉ lệ nhắc mới", "0.300", "dat_ti_le_nhac"), dong("Lý do", "Nhắc sớm hơn", "dat_ti_le_nhac")],
  needs_choice: [],
};
function traLoi(proposal: unknown) {
  return { answer: "Đã soạn đề xuất, chưa ghi gì.", sources: [], degraded_reason: null, proposal };
}
function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "content-type": "application/json" } });
}
const cho = (ms: number) => new Promise((r) => setTimeout(r, ms));

type Goi = { method: string; path: string; body: unknown; raw: string };
type Dung = { turns: unknown[]; khung?: Khung; ghi?: () => Promise<Response> };
function dung(tuy: Dung) {
  const p = { khung: "/chu-quan" as Khung, ghi: async () => json({}, 201), ...tuy };
  const hang = [...p.turns];
  const ghiGoi: Goi[] = [];
  const doc: string[] = [];
  const fetch = vi.fn(async (request: Request) => {
    const u = new URL(request.url);
    if (request.method === "POST" && u.pathname === "/api/chat/turns") return json(hang.shift());
    if (request.method === "GET") { doc.push(request.url); return json({}, 404); }
    const raw = await request.clone().text();
    ghiGoi.push({ method: request.method, path: u.pathname, body: raw ? JSON.parse(raw) : undefined, raw });
    return p.ghi();
  });
  render(<ApiProvider fetch={fetch}><HoiQuan mo khung={p.khung} nguoiBam="Bà Thanh" /></ApiProvider>);
  return { ghiGoi, doc };
}
function hoi(text = "Hôm qua mua 2,5 kg thịt nạc vai") {
  fireEvent.change(screen.getByRole("textbox", { name: "Câu hỏi" }), { target: { value: text } });
  fireEvent.click(screen.getByRole("button", { name: "Hỏi" }));
}
const the = () => screen.getByRole("group", { name: "Đề xuất ghi" });
const nutGhi = () => within(the()).queryAllByRole("button", { name: "Xác nhận ghi" });
function coLink(ten: string, href: string) {
  expect(within(the()).getByRole("link", { name: ten }).getAttribute("href")).toBe(href);
}
async function bamVaChoGhi() {
  fireEvent.click(within(the()).getByRole("button", { name: "Xác nhận ghi" }));
  await waitFor(() => expect(within(the()).getByRole("status").textContent).toContain(CHU_DA_GHI));
}
const NAM_CUA = ["createSupplyItem", "setSupplyItemPurchaseUnit", "createSupplyDayEntry", "updateSupplyDayEntry", "setSupplyItemReminderRatio"];

describe("CHAT-17 FE bảng cửa nguyên liệu của bản chạy", () => {
  it("A1 bảng có đúng mười lăm cửa, mười cửa cũ trước rồi năm cửa nguyên liệu, không cửa nào có dấu", () => {
    expect(Object.keys(cuaGhiChat)).toEqual([
      "createAssignedTask", "updateAssignedTask", "hideAssignedTask", "markAssignedTask",
      "attachAssignedTaskGuide", "updateAssignedTaskGuide", "hideAssignedTaskGuide",
      "createTrainingRecord", "updateTrainingRecord", "hideTrainingRecord",
      ...NAM_CUA,
    ]);
    for (const cua of Object.values(cuaGhiChat)) expect(cua.coDau).toBe(false);
    for (const op of NAM_CUA) {
      expect(cuaGhiChat[op].chonNguoi).toBeUndefined();
      expect(cuaGhiChat[op].manTay).toEqual({ "/chu-quan": { href: "/chu-quan/nguyen-lieu", ten: "Xem Nguyên liệu" } });
    }
    expect(Object.isFrozen(cuaGhiChat)).toBe(true);
  });

  it.each([
    ["thêm nguyên liệu", deThem, "POST", "/api/supply-items", "Đơn vị: kg (Nguyên liệu, đọc lúc 10:00:05)"],
    ["đặt đơn vị", deDonVi, "PUT", "/api/supply-items/21/purchase-unit", "Đơn vị: bó (Nguyên liệu, đọc lúc 10:00:05)"],
    ["ghi con số", deGhiSo, "POST", "/api/supply-day-entries", "Con số: 2.5 kg (Nguyên liệu, đọc lúc 10:00:05)"],
    ["sửa con số", deSuaSo, "PUT", "/api/supply-day-entries/71", "Con số mới: 0.125 kg (Nguyên liệu, đọc lúc 10:00:05)"],
    ["đặt tỉ lệ nhắc", deTiLe, "PUT", "/api/supply-items/22/reminder-ratio", "Tỉ lệ nhắc mới: 0.300 (Nguyên liệu, đọc lúc 10:00:05)"],
  ])("A2 %s: bấm gọi đúng cửa màn tay với đúng thân của thẻ, không đọc lại gì", async (_ten, de, method, path, dongThe) => {
    const { ghiGoi, doc } = dung({ turns: [traLoi(de)], ghi: async () => json({}) });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).getByText(dongThe)).toBeTruthy();
    expect(within(the()).getByText("Người bấm: Bà Thanh")).toBeTruthy();
    expect(within(the()).queryByRole("combobox")).toBeNull();
    coLink("Xem Nguyên liệu", "/chu-quan/nguyen-lieu");
    await bamVaChoGhi();
    expect(ghiGoi).toHaveLength(1);
    expect({ method: ghiGoi[0].method, path: ghiGoi[0].path, body: ghiGoi[0].body }).toEqual({ method, path, body: de.body });
    await cho(50);
    expect(doc).toHaveLength(0);
  });

  it.each([
    ["ghi con số", deGhiSo, '"measure":"2.5"'],
    ["sửa con số", deSuaSo, '"measure":"0.125"'],
    ["đặt tỉ lệ nhắc", deTiLe, '"reminder_ratio":"0.300"'],
  ])("A2 %s: con số đi dạng chuỗi nguyên chữ, không thành số JSON hay bị làm tròn", async (_ten, de, chuoi) => {
    const { ghiGoi } = dung({ turns: [traLoi(de)] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    await bamVaChoGhi();
    expect(ghiGoi[0].raw).toContain(chuoi);
  });

  it("A2 ghi con số: ngày giữ nguyên YYYY-MM-DD và loại giữ mã của hợp đồng", async () => {
    const { ghiGoi } = dung({ turns: [traLoi({ ...deGhiSo, body: { ...deGhiSo.body, kind: "used" } })] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    await bamVaChoGhi();
    expect(ghiGoi[0].body).toEqual({ supply_item_id: 22, entry_date: "2026-11-09", kind: "used", measure: "2.5" });
  });

  it.each([
    ["trùng ngày và loại", deGhiSo, 409, "supply_day_entry_already_recorded"],
    ["đơn vị đã đặt", deDonVi, 409, "supply_item_unit_already_set"],
    ["ngày sau hôm nay", deGhiSo, 400, "invalid_request"],
  ])("A3 cửa từ chối %s: nói chưa ghi kèm mã, khoá thẻ, một lần gọi", async (_ten, de, status, code) => {
    const { ghiGoi } = dung({ turns: [traLoi(de)], ghi: async () => json({ code }, status) });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    fireEvent.click(nutGhi()[0]);
    expect((await within(the()).findByRole("alert")).textContent).toContain(`Chưa ghi: cửa từ chối (${code}).`);
    expect(within(the()).queryAllByRole("button")).toHaveLength(0);
    await cho(50);
    expect(ghiGoi).toHaveLength(1);
  });

  it("A3 khung quầy: link về màn mặc định của khung, cửa backend từ chối owner_only, FE không tự cho qua", async () => {
    const { ghiGoi } = dung({ turns: [traLoi(deGhiSo)], khung: "/quay", ghi: async () => json({ code: "owner_only" }, 403) });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).queryByRole("link", { name: "Xem Nguyên liệu" })).toBeNull();
    coLink("Xem Sản xuất", "/quay/san-xuat");
    fireEvent.click(nutGhi()[0]);
    expect((await within(the()).findByRole("alert")).textContent).toContain("Chưa ghi: cửa từ chối (owner_only).");
    await cho(50);
    expect(ghiGoi).toHaveLength(1);
  });

  it("A3 mất phản hồi: chưa rõ kết quả, không Gửi lại vì cửa không có dấu, link về Nguyên liệu", async () => {
    const { ghiGoi } = dung({ turns: [traLoi(deSuaSo)], ghi: async () => { throw new Error("mất mạng"); } });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    fireEvent.click(nutGhi()[0]);
    expect((await within(the()).findByRole("alert")).textContent).toContain(CHU_CHUA_RO);
    expect(within(the()).queryAllByRole("button")).toHaveLength(0);
    coLink("Xem Nguyên liệu", "/chu-quan/nguyen-lieu");
    await cho(50);
    expect(ghiGoi).toHaveLength(1);
  });

  it("A3 needs_choice không rỗng: giữ lời CHAT-11, không ô chọn, không gọi gì", async () => {
    const { ghiGoi, doc } = dung({ turns: [traLoi({ ...deGhiSo, needs_choice: ["supply_item_id"] })] });
    hoi(); await screen.findByRole("group", { name: "Đề xuất ghi" });
    expect(within(the()).getByText("Cần chọn trên màn tay: supply_item_id.")).toBeTruthy();
    expect(within(the()).queryByRole("combobox")).toBeNull();
    expect(nutGhi()).toHaveLength(0);
    await cho(50);
    expect(doc).toHaveLength(0);
    expect(ghiGoi).toHaveLength(0);
  });
});
