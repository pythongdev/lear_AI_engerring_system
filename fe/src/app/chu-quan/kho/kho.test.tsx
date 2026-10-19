import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it } from "vitest";
import { voiBackend, type GoiDen } from "@/components/tai-khoan/test-utils";
import type { components } from "@/lib/api/schema";
import Page from "./page";

afterEach(cleanup);
type Thu = components["schemas"]["SupplyItem"];
type Tra = { status: number; body?: unknown };
const thu: Thu = { supply_item_id: 9, name: "Gạo", purchase_unit: "kg", purchased_total: "1234567890123.125", used_total: "11.250", balance: "-4", reminder_ratio: "0.2", latest_purchase_date: "2026-10-08", latest_purchase_measure: "7.500", reminder_status: "ready", check_reminder: true };
function mo(opts: { doc?: (lan: number) => Tra; ghi?: () => Tra } = {}) {
  let lan = 0;
  return voiBackend(<Page />, (g) => {
    if (g.method === "GET" && g.path === "/supply-stock") return opts.doc?.(++lan) ?? { status: 200, body: { supply_items: [thu] } };
    if (g.method === "PUT") return opts.ghi?.() ?? { status: 200, body: thu };
    return { status: 404, body: { code: "supply_item_not_found" } };
  });
}
const ghi = (g: GoiDen[]) => g.filter((x) => x.method !== "GET");
const doc = (g: GoiDen[]) => g.filter((x) => x.path === "/supply-stock" && x.method === "GET");
const go = (f: HTMLElement, ten: string, value: string) => fireEvent.change(within(f).getByLabelText(ten), { target: { value } });
const sai = (f: HTMLElement, ten: string) => within(f).getByLabelText(ten).getAttribute("aria-invalid");
async function form() {
  fireEvent.click(await screen.findByRole("button", { name: "Đặt tỉ lệ Gạo" }));
  return screen.getByRole("form", { name: "Đặt tỉ lệ Gạo" });
}
async function nhap() { const f = await form(); go(f, "Tỉ lệ nhắc", " 0.35 "); go(f, "Lý do (bắt buộc)", " Đổi mức nhắc "); return f; }

describe("Kho", () => {
  it("giữ thứ tự backend, nguyên chuỗi ba số kể cả -4, lần nhập và tỉ lệ; không tự kết luận", async () => {
    const g = mo({ doc: () => ({ status: 200, body: { supply_items: [thu, { ...thu, supply_item_id: 2, name: "Bột", purchase_unit: null, latest_purchase_date: null, latest_purchase_measure: null, check_reminder: false }] } }) });
    const list = await screen.findByRole("list", { name: "Kho nguyên liệu" }); const rows = within(list).getAllByRole("listitem");
    expect(rows.map((r) => r.querySelector("h2")?.textContent)).toEqual(["Gạo", "Bột"]);
    expect(Array.from(rows[0].querySelectorAll("dd")).map((d) => d.textContent)).toEqual(["1234567890123.125 kg", "11.250 kg", "-4 kg", "08/10/2026 · 7.500 kg", "0.2"]);
    expect(within(rows[0]).getByText("Mua vào trừ đã dùng")).toBeTruthy();
    expect(within(rows[0]).getByText("Nhắc POS kiểm tra").tagName).toBe("STRONG");
    expect(within(rows[1]).getByText("Không nhắc")).toBeTruthy();
    expect(within(rows[1]).getByText("Chưa có đơn vị", { selector: "p" })).toBeTruthy();
    expect(within(rows[1]).getByText("Chưa có lần mua")).toBeTruthy();
    expect(document.body.textContent).not.toMatch(/sắp hết|dự kiến|hết hàng|dùng\/ngày|20%/i);
    expect(within(rows[0]).getByRole("link", { name: "Mở sổ" }).getAttribute("href")).toBe("/chu-quan/nguyen-lieu?thu=9");
    expect(g.map((x) => x.path)).toEqual(["/supply-stock"]);
  });
  // U-102 (T-204): chưa có mốc nhập ⇒ backend gửi cờ true kèm lý do; dùng trước lần mua đầu là ghi chú cạnh kết quả so tỉ lệ.
  it.each([
    ["no_purchase", true, "Lý do: chưa có lần mua"],
    ["latest_purchase_zero", true, "Lý do: lần mua gần nhất bằng 0"],
    ["usage_before_first_purchase", true, "Ghi chú: có số dùng trước lần mua đầu"],
    ["usage_before_first_purchase", false, "Ghi chú: có số dùng trước lần mua đầu"],
  ])("%s với cờ %s bày đúng lý do", async (status, co, label) => {
    mo({ doc: () => ({ status: 200, body: { supply_items: [{ ...thu, check_reminder: co, reminder_status: status }] } }) });
    expect(await screen.findByText(label)).toBeTruthy();
    if (co) expect(screen.getByText("Nhắc POS kiểm tra").tagName).toBe("STRONG");
    else { expect(screen.getByText("Không nhắc")).toBeTruthy(); expect(screen.queryByText("Nhắc POS kiểm tra")).toBeNull(); }
  });
  it("rỗng khác lỗi đọc lần đầu", async () => {
    mo({ doc: () => ({ status: 200, body: { supply_items: [] } }) });
    expect(await screen.findByText("Chưa có nguyên liệu nào.")).toBeTruthy(); expect(screen.queryByRole("alert")).toBeNull();
  });
  it("lỗi đọc lần đầu có cảnh báo và nút đọc lại", async () => {
    mo({ doc: () => ({ status: 403, body: { code: "owner_only" } }) });
    expect(await screen.findByRole("alert")).toBeTruthy(); expect(screen.queryByText("Chưa có nguyên liệu nào.")).toBeNull();
    expect(screen.getByRole("button", { name: "Đọc lại kho" })).toBeTruthy();
  });
  it("mặc định chuỗi hiện tại, gửi đúng thân và hiển thị kết quả đọc lại", async () => {
    const g = mo({ doc: (lan) => ({ status: 200, body: { supply_items: [{ ...thu, reminder_ratio: lan === 1 ? "0.2" : "0.35" }] } }) });
    const f = await form(); expect((within(f).getByLabelText("Tỉ lệ nhắc") as HTMLInputElement).value).toBe("0.2");
    go(f, "Tỉ lệ nhắc", " 0.35 "); go(f, "Lý do (bắt buộc)", " Đổi mức nhắc "); fireEvent.submit(f);
    await screen.findByText("Đã đặt tỉ lệ."); expect(await screen.findByText("0.35", { selector: "dd" })).toBeTruthy();
    expect(ghi(g)).toEqual([{ method: "PUT", path: "/supply-items/9/reminder-ratio", body: { reminder_ratio: "0.35", reason: "Đổi mức nhắc" } }]); expect(doc(g)).toHaveLength(2);
  });
  it.each(["1.5", "0,2", "-0.1", "0.1234567"])("tỉ lệ sai khuôn %s không gửi", async (value) => {
    const g = mo(); const f = await nhap(); go(f, "Tỉ lệ nhắc", value); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Tỉ lệ nhắc")).toBe("true")); expect(ghi(g)).toHaveLength(0);
  });
  it.each(["0", "1", "1.000000", "0.350000"])("giữ nguyên chuỗi hợp lệ %s", async (value) => {
    const g = mo(); const f = await nhap(); go(f, "Tỉ lệ nhắc", value); fireEvent.submit(f); await screen.findByText("Đã đặt tỉ lệ.");
    expect(ghi(g)[0].body).toEqual({ reminder_ratio: value, reason: "Đổi mức nhắc" });
  });
  it("thiếu lý do không gửi", async () => {
    const g = mo(); const f = await nhap(); go(f, "Lý do (bắt buộc)", "   "); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, "Lý do (bắt buộc)")).toBe("true")); expect(ghi(g)).toHaveLength(0);
  });
  it.each([["reminder_ratio", "Tỉ lệ nhắc"], ["reason", "Lý do (bắt buộc)"]])("400 field=%s gắn đúng ô và giữ nháp", async (field, label) => {
    mo({ ghi: () => ({ status: 400, body: { code: "invalid_request", field } }) }); const f = await nhap(); fireEvent.submit(f);
    await waitFor(() => expect(sai(f, label)).toBe("true"));
    expect((within(f).getByLabelText("Tỉ lệ nhắc") as HTMLInputElement).value).toBe(" 0.35 ");
  });
  it("nguyên liệu mất: báo còn sau khi đọc lại bỏ dòng", async () => {
    const g = mo({ doc: (lan) => ({ status: 200, body: { supply_items: lan === 1 ? [thu] : [] } }), ghi: () => ({ status: 404, body: { code: "supply_item_not_found" } }) });
    fireEvent.submit(await nhap()); await screen.findByText("Chưa có nguyên liệu nào.");
    expect(await screen.findByText(/Không tìm thấy nguyên liệu này/)).toBeTruthy(); expect(doc(g)).toHaveLength(2);
  });
  it("lỗi đọc lại giữ bản cũ kèm cảnh báo và mốc", async () => {
    mo({ doc: (lan) => lan === 1 ? { status: 200, body: { supply_items: [thu] } } : { status: 403, body: { code: "owner_only" } } });
    await screen.findByText("Gạo"); fireEvent.click(screen.getByRole("button", { name: "Đọc lại kho" }));
    expect((await screen.findByRole("alert")).textContent).toMatch(/Đang hiện bản đọc trước, lúc/); expect(screen.getByText("-4 kg")).toBeTruthy();
  });
  it("đã ghi nhưng đọc lại lỗi: nói đã ghi chưa cập nhật, giữ số cũ", async () => {
    const g = mo({ doc: (lan) => lan === 1 ? { status: 200, body: { supply_items: [thu] } } : { status: 403, body: { code: "owner_only" } } });
    fireEvent.submit(await nhap()); await screen.findByText(/Đã ghi, chưa cập nhật được dữ liệu/);
    expect(screen.getByText("0.2", { selector: "dd" })).toBeTruthy(); expect(ghi(g)).toHaveLength(1);
  });
  it("phản hồi không phải Error giữ nháp, giữ số, không tự gửi lại", async () => {
    const g = mo({ ghi: () => ({ status: 502, body: { strange: true } }) }); const f = await nhap(); fireEvent.submit(f);
    await screen.findByText(/Chưa xác nhận được kết quả/); expect((within(f).getByLabelText("Tỉ lệ nhắc") as HTMLInputElement).value).toBe(" 0.35 ");
    expect(screen.getByText("-4 kg")).toBeTruthy(); expect(ghi(g)).toHaveLength(1); expect(doc(g)).toHaveLength(1);
  });
  it("bấm gửi hai lần nhanh chỉ một lời gọi", async () => {
    const g = mo(); const f = await nhap(); const b = within(f).getByRole("button", { name: "Lưu tỉ lệ" }); fireEvent.click(b); fireEvent.click(b);
    await screen.findByText("Đã đặt tỉ lệ."); expect(ghi(g)).toHaveLength(1);
  });
});
