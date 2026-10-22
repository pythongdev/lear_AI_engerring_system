import { cleanup, fireEvent, screen, waitFor, within } from "@testing-library/react";
import { afterEach, describe, expect, it, vi } from "vitest";
import { voiBackend } from "@/components/tai-khoan/test-utils";
import { cotVanHanh, type ThuVanHanh } from "../_components/cot-van-hanh";
import type { BangVanHanh } from "../_components/du-lieu-van-hanh";
import Page, { metadata } from "./page";

afterEach(() => { cleanup(); vi.restoreAllMocks(); });
const thu = (component_name: string, nhan?: string, extra: Partial<ThuVanHanh> = {}): ThuVanHanh => ({
  menu_component_id: 81, component_name, filling_option_ids: [], options: nhan ? [{ option_group_name: "Nhân", option_name: nhan }] : [],
  extra_filling: false, ordered: 13, served: 6, missing: 7, ...extra,
});
const items = [thu("Bánh cuốn", "Thịt", { extra_filling: true }), thu("Bánh cuốn", "Thịt + mộc nhĩ"), thu("Bánh cuốn", "Chay"), thu("Trứng tái"), thu("Trứng chín"), thu("Canh bánh cuốn"), thu("Giò")];
const phien = (id: number, service_group: BangVanHanh["sessions"][number]["service_group"], label: string, its = [items[0]]): BangVanHanh["sessions"][number] => ({
  table_session_id: id, session_status: "open", service_group, tables: [{ dining_table_id: id, label }], order_total_vnd: 79123, served_amount_vnd: service_group === "serving" ? 23123 : 0, items: its,
});
const hist = (served_at: string, name: string): BangVanHanh["serve_history"][number] => ({ served_at, dining_table_id: 21, table_label: "A", person_id: 91, person_name: "Người thử", station_code: "banh", menu_component_id: 81, component_name: name, filling_option_ids: [], quantity: 9 });
const data: BangVanHanh = {
  sale_date: "2025-02-03", read_at: "2025-02-03T03:17:29Z",
  sessions: [phien(28, "serving", "D"), { ...phien(21, "serving", "A", items), tables: [{ dining_table_id: 21, label: "A" }, { dining_table_id: 22, label: "B" }] }, phien(31, "waiting", "C", [thu("Bánh cuốn", "Thịt", { ordered: 11, served: 0, missing: 11 })]), phien(41, "no_order", "E", [])],
  empty_tables: [{ dining_table_id: 51, label: "F" }],
  serve_history: [hist("2025-02-03T03:16:12Z", "Món mới"), hist("2025-02-03T03:16:12Z", "Món cùng lần"), hist("2025-02-03T02:11:03Z", "Món cũ")],
};
function mo(doc: (n: number) => { status: number; body: unknown } = () => ({ status: 200, body: data })) {
  let n = 0;
  return voiBackend(<Page />, (g) => g.path === "/sessions/current" ? { status: 401, body: { code: "unauthenticated" } } : doc(++n));
}
const bang = async () => within(await screen.findByRole("region", { name: "Bảng tổng thiếu" }));
const cells = (r: HTMLElement) => within(r).getAllByRole("cell").map((x) => x.textContent);
const nut = (name: string) => screen.getByRole("button", { name });
const vungAn = (b: HTMLElement) => document.getElementById(b.getAttribute("aria-controls")!)!;

describe("Vận hành", () => {
  it("ánh xạ mỗi thứ đúng một cột, giữ chính xác tên và không giấu Khác", async () => {
    expect(items.map(cotVanHanh)).toEqual([{ cot: "Thịt", dong: "" }, { cot: "Mộc nhĩ", dong: "" }, { cot: "Chay", dong: "" }, { cot: "Trứng", dong: "tái" }, { cot: "Trứng", dong: "chín" }, { cot: "Canh", dong: "" }, { cot: "Khác", dong: "Giò" }]);
    for (const i of [thu("Bánh cuốn ", "Thịt"), thu("Bánh cuốn", "Thit"), thu("Bánh cuốn", " Thịt"), thu("Món đổi tên"), thu("Nước chấm")]) expect(cotVanHanh(i).cot).toBe("Khác");
    mo((n) => ({ status: 200, body: n === 1 ? data : { ...data, sessions: data.sessions.map((p) => ({ ...p, items: p.items.filter((i) => i.component_name !== "Giò") })) } }));
    expect((await bang()).getByRole("columnheader", { name: "Khác" })).toBeTruthy();
    fireEvent.click(nut("Đọc lại"));
    await waitFor(() => expect(screen.queryByRole("columnheader", { name: "Khác" })).toBeNull());
  });
  it("chỉ serving, ghép A + B, xếp theo mã bàn, cộng missing và tiền backend, đánh dấu nhiều", async () => {
    mo(); const b = await bang(); const rows = b.getAllByRole("row");
    expect(rows).toHaveLength(4);
    expect(rows[1].textContent).toContain("A + B"); expect(rows[2].textContent).toContain("D");
    expect(cells(rows[1])).toEqual(["7*", "7", "7 tái7 chín", "7", "7", "7 Giò", "23.123đ"]);
    expect(cells(rows[3])).toEqual(["14*", "7", "7 tái7 chín", "7", "7", "7 Giò", "46.246đ"]);
    expect(rows[1].querySelector(".nhieu")).toBeTruthy();
    expect(b.queryByRole("button", { name: "C" })).toBeNull();
    expect(metadata.title).toBe("Vận hành"); expect(screen.getByText(/Ngày bán: 2025-02-03/).textContent).toContain("10:17:29");
  });
  it("bấm nhãn bàn mở ngay dưới hàng với tổng, đã ra, thiếu, tiền đơn rồi đóng", async () => {
    mo(); const b = await bang(); const btn = b.getByRole("button", { name: "A + B" });
    fireEvent.click(btn); expect(btn.getAttribute("aria-expanded")).toBe("true");
    const detail = btn.closest("tr")!.nextElementSibling! as HTMLElement;
    expect(detail.id).toBe(btn.getAttribute("aria-controls"));
    expect(within(detail).getAllByText("tổng")).toHaveLength(6); expect(within(detail).getAllByText("đã ra")).toHaveLength(6); expect(within(detail).getAllByText("thiếu")).toHaveLength(6);
    expect(detail.textContent).toContain("Tiền đơn: 79.123đ");
    fireEvent.click(btn); expect(btn.getAttribute("aria-expanded")).toBe("false"); expect(document.getElementById(detail.id)).toBeNull();
  });
  it("tick thêm hàng đỏ và tổng x+y, bỏ chọn gỡ; chỉ GET service-board và sessions/current, không ghi trình duyệt", async () => {
    const set = vi.spyOn(Storage.prototype, "setItem"); const remove = vi.spyOn(Storage.prototype, "removeItem"); const clear = vi.spyOn(Storage.prototype, "clear");
    const g = mo(); const b = await bang();
    fireEvent.click(screen.getByRole("checkbox", { name: "C · 79.123đ" }));
    const row = b.getByRole("button", { name: "C" }).closest("tr")!;
    expect(row.className).toContain("dong-ghep"); expect(cells(row)[0]).toBe("11"); expect(cells(row).at(-1)).toBe("0đ");
    expect(cells(b.getAllByRole("row").at(-1)!)[0]).toBe("14+11*");
    expect(b.getByText("+11").className).toContain("them"); expect(screen.getByText("Đã chọn 1 bàn.")).toBeTruthy();
    fireEvent.click(nut("Bỏ chọn hết")); expect(b.queryByRole("button", { name: "C" })).toBeNull(); expect(screen.getByText("Đã chọn 0 bàn.")).toBeTruthy();
    expect(g.map(({ method, path }) => ({ method, path }))).toEqual([{ method: "GET", path: "/service-board" }, { method: "GET", path: "/sessions/current" }]);
    expect(set).not.toHaveBeenCalled(); expect(remove).not.toHaveBeenCalled(); expect(clear).not.toHaveBeenCalled();
  });
  it("đọc lại bỏ tick phiên hết waiting và không tự chọn lại khi nó quay về", async () => {
    mo((n) => ({ status: 200, body: n === 2 ? { ...data, sessions: data.sessions.map((p) => p.table_session_id === 31 ? { ...p, service_group: "serving" } : p) } : data }));
    await bang(); fireEvent.click(screen.getByRole("checkbox")); fireEvent.click(nut("Đọc lại"));
    await screen.findByText("Chưa bàn nào sắp phục vụ."); expect(screen.getByText("Đã chọn 0 bàn.")).toBeTruthy();
    fireEvent.click(nut("Đọc lại")); expect((await screen.findByRole("checkbox")).getAttribute("aria-checked")).toBe("false");
  });
  it("các phần mặc định ẩn; Hiện và Chi tiết đổi aria-expanded cùng hidden, bảng đủ data-label", async () => {
    mo(); await bang();
    for (const name of ["Hiện A + B", "Hiện D", "Chi tiết bàn đang phục vụ", "Hiện sơ đồ bàn", "Hiện lịch sử đem ra", "Hiện lịch sử theo bàn"]) {
      const b = nut(name), v = vungAn(b); expect(b.getAttribute("aria-expanded")).toBe("false"); expect(v.hidden).toBe(true);
      fireEvent.click(b); expect(b.getAttribute("aria-expanded")).toBe("true"); expect(v.hidden).toBe(false);
      fireEvent.click(b); expect(v.hidden).toBe(true);
    }
    fireEvent.click(nut("Chi tiết bàn đang phục vụ"));
    const rows = within(screen.getByRole("region", { name: "Bảng đầy đủ" })).getAllByRole("row");
    expect(cells(rows[1]).slice(0, 3)).toEqual(["91", "42", "49"]);
    expect(rows.at(-1)!.textContent).toContain("Tổng 2 bàn");
    expect(rows[1].querySelectorAll("td[data-label]")).toHaveLength(11);
  });
  it("sơ đồ đủ bốn trạng thái, số ô và thứ tự đúng bàn backend", async () => {
    mo(); await bang(); fireEvent.click(nut("Hiện sơ đồ bàn")); const list = screen.getByRole("list", { name: "Các bàn" });
    const rows = within(list).getAllByRole("listitem"); expect(rows).toHaveLength(6);
    expect(rows.map((r) => r.querySelector("strong")!.textContent)).toEqual(["A", "B", "D", "C", "E", "F"]);
    expect(within(list).getAllByText("Đang phục vụ")).toHaveLength(3);
    for (const text of ["Sắp phục vụ", "Đã mở, chưa gọi", "Còn trống"]) expect(within(list).getByText(text)).toBeTruthy();
  });
  it("lịch sử giữ thứ tự backend, lần thứ theo mốc khác nhau và có người, giờ Việt Nam", async () => {
    mo(); await bang(); fireEvent.click(nut("Hiện lịch sử đem ra"));
    const rows = within(screen.getByRole("region", { name: "Bảng lịch sử đem ra" })).getAllByRole("row").slice(1);
    expect(rows.map(cells)).toEqual([["10:16:12", "A", "Món mới", "9", "Người thử", "2"], ["10:16:12", "A", "Món cùng lần", "9", "Người thử", "2"], ["09:11:03", "A", "Món cũ", "9", "Người thử", "1"]]);
    fireEvent.click(nut("Hiện lịch sử theo bàn")); expect(screen.getByText("Lần 1 · 09:11:03 · Món cũ · 9 cái · Người thử")).toBeTruthy();
  });
  it.each([['unauthenticated', 'đăng nhập lại'], ['not_on_counter_duty', 'not_on_counter_duty']])("lỗi đầu %s có Alert, không khối dữ liệu", async (code, text) => {
    mo(() => ({ status: 403, body: { code } })); const a = await screen.findByRole("alert");
    expect(a.textContent).toContain("Chưa đọc được tình hình bàn"); expect(a.textContent).toContain(text);
    expect(screen.queryByRole("region")).toBeNull();
  });
  it("dữ liệu rỗng có ba câu rỗng, không lỗi", async () => {
    mo(() => ({ status: 200, body: { ...data, sessions: [], empty_tables: [], serve_history: [] } }));
    expect(await screen.findByText("Chưa bàn nào đang phục vụ.")).toBeTruthy(); expect(screen.getByText("Chưa bàn nào sắp phục vụ.")).toBeTruthy(); expect(screen.getByText("Chưa có lần đem ra nào hôm nay.")).toBeTruthy(); expect(screen.queryByRole("alert")).toBeNull();
  });
  it("lỗi đọc lại giữ bản cũ và giờ read_at backend", async () => {
    mo((n) => n === 1 ? { status: 200, body: data } : { status: 403, body: { code: "not_on_counter_duty" } }); await bang(); fireEvent.click(nut("Đọc lại"));
    expect((await screen.findByRole("alert")).textContent).toContain(`lúc ${new Date(data.read_at).toLocaleTimeString("vi-VN", { timeZone: "Asia/Ho_Chi_Minh", hour12: false })}.`); expect(nut("A + B")).toBeTruthy();
  });
  it("mọi chuỗi tiền lấy từ hai trường backend hoặc tổng, số món đổi không đổi tiền, số tiền không là nút", async () => {
    mo(() => ({ status: 200, body: { ...data, sessions: data.sessions.map((p) => ({ ...p, items: p.items.map((i) => ({ ...i, ordered: 107, served: 101, missing: 6 })) })) } }));
    await bang(); fireEvent.click(nut("A + B")); fireEvent.click(nut("Chi tiết bàn đang phục vụ"));
    const values = Array.from(document.querySelectorAll("td, p, label")).flatMap((el) => el.children.length && el.tagName === "TD" ? [] : el.textContent!.match(/[\d.]+đ/g) ?? []);
    expect(values.length).toBeGreaterThan(5);
    expect(values.every((v) => ["79.123đ", "23.123đ", "46.246đ", "158.246đ"].includes(v))).toBe(true);
    expect(screen.getAllByRole("button").every((b) => !/[\d.]+đ/.test(b.textContent!))).toBe(true);
    expect(document.body.textContent).toContain("Chỉ người đang đứng quầy ghi được đem ra. Bạn chưa đứng quầy nên các ô chỉ để xem.");
  });
  it("không đánh dấu nhiều khi không thiếu, Khác hiện cả khi chỉ có ở phiên no_order", async () => {
    mo(() => ({ status: 200, body: { ...data, sessions: [phien(21, "serving", "A", [thu("Bánh cuốn", "Thịt", { extra_filling: true, missing: 0, served: 13 })]), phien(41, "no_order", "E", [thu("Giò")])] } }));
    const b = await bang(); expect(cells(b.getAllByRole("row")[1])[0]).toBe("0"); expect(b.getByRole("columnheader", { name: "Khác" })).toBeTruthy();
  });
});
